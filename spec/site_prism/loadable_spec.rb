# frozen_string_literal: true

describe SitePrism::Loadable do
  let(:loadable) do
    Class.new do
      include SitePrism::Loadable

      def valid1?
        false
      end

      def valid2?
        true
      end
    end
  end

  let(:instance) { loadable.new }

  describe '.load_validations' do
    let(:validation1) { -> { true } }
    let(:validation2) { -> { true } }
    let(:validation3) { -> { true } }

    context 'with no inheritance classes' do
      it 'returns load_validations from the current class' do
        loadable.load_validation(&validation1)
        loadable.load_validation(&validation2)

        expect(loadable.load_validations).to eq([validation1, validation2])
      end
    end

    context 'with inheritance classes' do
      let(:subklass) { Class.new(loadable) }

      it 'returns load_validations from the current and inherited classes' do
        loadable.load_validation(&validation1)
        subklass.load_validation(&validation2)

        expect(subklass.load_validations).to eq([validation1, validation2])
      end

      it 'ensures that load validations of parents are checked first' do
        loadable.load_validation(&validation1)
        subklass.load_validation(&validation2)
        loadable.load_validation(&validation3)

        expect(subklass.load_validations).to eq([validation1, validation3, validation2])
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
    let(:james_bond) { instance_spy('007') }

    context 'with passing load validations' do
      before { loadable.load_validation { valid2? } }

      it 'executes and yields itself to the provided block when all load validations pass' do
        expect(instance).to receive(:foo)

        instance.when_loaded(&:foo)
      end

      it 'executes the inner-most nesting when applicable' do
        expect(james_bond).to receive(:drink_martini).once

        instance.when_loaded do
          instance.when_loaded { james_bond.drink_martini }
        end
      end

      it 'executes validations only once for nested calls' do
        expect(instance).to receive(:valid2?).once.and_call_original

        instance.when_loaded do
          instance.when_loaded {}
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
        loadable.load_validation { [valid1?, 'valid1 failed'] }
        loadable.load_validation { [valid2?, 'valid2 failed'] }
      end

      it 'raises a `FailedLoadValidationError`' do
        expect { instance.when_loaded { :foo } }
          .to raise_error(SitePrism::FailedLoadValidationError)
      end

      it 'can be supplied with a user-defined message' do
        expect { instance.when_loaded { :foo } }.to raise_error.with_message('valid1 failed')
      end

      it 'raises an error immediately on the first validation failure' do
        swallow_bad_validation do
          expect(instance).to receive(:valid1?).once

          instance.when_loaded
        end
      end

      it 'does not call other load validations after failing a load validation' do
        swallow_bad_validation do
          expect(instance).not_to receive(:valid2?)

          instance.when_loaded
        end
      end
    end
  end

  describe '#loaded?' do
    subject(:instance) { inheriting_loadable.new }

    let(:inheriting_loadable) { Class.new(loadable) }

    before do
      inheriting_loadable.load_validation { [valid2?, 'valid2 failed'] }
    end

    it { is_expected.to be_loaded }

    it 'returns true if loaded value is cached' do
      instance.loaded = true

      expect(instance).to be_loaded
    end

    it 'does not check load_validations if already loaded' do
      instance.loaded = true

      expect(instance).not_to receive(:valid2?)

      instance.loaded?
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
