# frozen_string_literal: true

describe SitePrism::Loadable do
  let(:loadable) do
    Class.new do
      include SitePrism::Loadable

      def false_thing?
        false
      end

      def true_thing?
        true
      end
    end
  end

  let(:instance) { loadable.new }

  describe '.load_validations' do
    let(:alpha_validation) { -> { true } }
    let(:beta_validation) { -> { true } }

    context 'with no inheritance' do
      it 'returns load_validations from the current class' do
        loadable.load_validation(&alpha_validation)
        loadable.load_validation(&beta_validation)

        expect(loadable.load_validations).to eq([alpha_validation, beta_validation])
      end
    end

    context 'with inheritance' do
      let(:subklass) { Class.new(loadable) }

      it 'returns load_validations from both the current AND inherited classes' do
        loadable.load_validation(&alpha_validation)
        subklass.load_validation(&beta_validation)

        expect(subklass.load_validations).to eq([alpha_validation, beta_validation])
      end

      it 'ensures that load validations of parents are checked first' do
        subklass.load_validation(&beta_validation)
        loadable.load_validation(&alpha_validation)

        expect(subklass.load_validations).to eq([alpha_validation, beta_validation])
      end
    end

    it 'has no default load validations' do
      expect(loadable.load_validations.length).to eq(0)
    end
  end

  describe '.load_validation' do
    it 'adds a single validation to the load_validations list' do
      expect { loadable.load_validation { true } }
        .to change { loadable.load_validations.size }.by(1)
    end
  end

  describe '#when_loaded' do
    context 'with passing load validations' do
      before { loadable.load_validation { true_thing? } }

      it 'executes and yields itself to the provided block when all load validations pass' do
        expect(instance).to receive(:foo)

        instance.when_loaded(&:foo)
      end

      it 'executes the inner-most nesting when applicable' do
        expect(instance).to receive(:drink_martini).once

        instance.when_loaded do
          instance.when_loaded { instance.drink_martini }
        end
      end

      it 'executes validations only once for nested calls' do
        expect(instance).to receive(:true_thing?).once.and_call_original

        instance.when_loaded do
          instance.when_loaded
        end
      end

      it 'resets the loaded cache at the end of the block' do
        previous_nil_loaded_state = instance.loaded

        instance.when_loaded do |instance|
          expect(previous_nil_loaded_state).not_to eq(instance.loaded)
        end
      end
    end

    context 'with failing validations' do
      before do
        loadable.load_validation { [false_thing?, 'false_thing? failed'] }
        loadable.load_validation { [true_thing?, 'true_thing? failed'] }
      end

      it 'raises a `FailedLoadValidationError`' do
        expect { instance.when_loaded { :foo } }
          .to raise_error(SitePrism::FailedLoadValidationError)
      end

      it 'can be supplied with a user-defined message' do
        expect { instance.when_loaded { :foo } }.to raise_error.with_message('false_thing? failed')
      end

      it 'raises an error immediately on the first validation failure' do
        swallow_bad_validation do
          expect(instance).to receive(:false_thing?).once

          instance.when_loaded
        end
      end

      it 'does not call other load validations after failing a load validation' do
        swallow_bad_validation do
          expect(instance).not_to receive(:true_thing?)

          instance.when_loaded
        end
      end
    end
  end

  describe '#loaded?' do
    let(:instance) { inheriting_loadable.new }
    let(:inheriting_loadable) { Class.new(loadable) }

    before { inheriting_loadable.load_validation { [true_thing?, 'valid2 failed'] } }

    context 'when already loaded' do
      before { instance.loaded = true }

      it 'returns true if loaded value is cached' do
        expect(instance).to be_loaded
      end

      it 'does not check load_validations if already loaded' do
        expect(instance).not_to receive(:true_thing?)

        instance.loaded?
      end
    end

    it 'returns true if all load validations pass' do
      loadable.load_validation { true }
      inheriting_loadable.load_validation { true }

      expect(instance).to be_loaded
    end

    it 'returns false if a defined load validation fails' do
      loadable.load_validation { true }
      inheriting_loadable.load_validation { false }

      expect(instance).not_to be_loaded
    end

    it 'returns false if an inherited load validation fails' do
      loadable.load_validation { false }
      inheriting_loadable.load_validation { true }

      expect(instance).not_to be_loaded
    end

    it 'sets the load_error if a failing load_validation supplies one' do
      loadable.load_validation { [true, 'this cannot fail'] }
      loadable.load_validation { [false, 'fubar'] }
      inheriting_loadable.load_validation { [true, 'this also cannot fail'] }

      instance.loaded?

      expect(instance.load_error).to eq('fubar')
    end
  end
end
