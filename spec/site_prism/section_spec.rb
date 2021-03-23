# frozen_string_literal: true

describe SitePrism::Section do
  let(:dont_wait) { { wait: 0 } }
  let(:section_without_block) { described_class.new(SitePrism::Page.new, locator) }
  let!(:locator) { instance_double('Capybara::Node::Element') }
  let(:section_with_block) do
    described_class.new(SitePrism::Page.new, locator) { 1 + 1 }
  end

  it 'responds to Capybara methods' do
    expect(section_without_block).to respond_to(*Capybara::Session::DSL_METHODS)
  end

  describe '.sections' do
    it 'can be set on `SitePrism::Page`' do
      expect(SitePrism::Page).to respond_to(:section)
    end

    it 'can be set on `SitePrism::Section`' do
      expect(described_class).to respond_to(:section)
    end
  end

  describe 'a section' do
    class SingleSection < SitePrism::Section
      element :single_section_element, '.foo'
    end

    let(:page_with_sections) do
      Class.new(SitePrism::Page) do
        section :single_section, SingleSection, '.bob'

        section :section_with_a_block, SingleSection, '.bob' do
          element :block_element, '.btn'
        end
      end
    end

    let(:page_with_sections_instance) do
      page_with_sections.new
    end

    before do
      allow(page_with_sections_instance).to receive(:_find).and_return(:element)
    end

    it 'is an instance of the defined section class' do
      expect(page_with_sections_instance.section_with_a_block.class.ancestors)
        .to include(SingleSection)
    end

    it 'has elements from the defined section' do
      expect(page_with_sections_instance.section_with_a_block)
        .to respond_to(:single_section_element)
    end

    it 'has elements from the block' do
      expect(page_with_sections_instance.section_with_a_block).to respond_to(:block_element)
    end

    context 'when second argument is a Class' do
      subject { page_with_section.new }

      let(:page_with_section) do
        Class.new(SitePrism::Page) do
          section :section, SitePrism::Section, '.section'
        end
      end

      it { is_expected.to respond_to(:section) }
      it { is_expected.to respond_to(:has_section?) }
      it { is_expected.to respond_to(:has_no_section?) }
      it { is_expected.to respond_to(:wait_until_section_visible) }
      it { is_expected.to respond_to(:wait_until_section_invisible) }
      it { is_expected.to respond_to(:all_there?) }
      it { is_expected.to respond_to(:within) }
    end

    context 'when second argument is not a Class but a block is given' do
      subject { page_with_anonymous_section.new }

      let(:page_with_anonymous_section) do
        Class.new(SitePrism::Page) do
          section :anonymous_section, '.section' do
            element :title, 'h1'
          end
        end
      end

      it { is_expected.to respond_to(:anonymous_section) }
      it { is_expected.to respond_to(:has_anonymous_section?) }
      it { is_expected.to respond_to(:has_no_anonymous_section?) }
      it { is_expected.to respond_to(:wait_until_anonymous_section_visible) }
      it { is_expected.to respond_to(:wait_until_anonymous_section_invisible) }
      it { is_expected.to respond_to(:all_there?) }
      it { is_expected.to respond_to(:within) }
    end

    context 'when second argument is a Class and a block is given' do
      subject { page_with_anonymous_section.new }

      let(:page_with_anonymous_section) do
        Class.new(SitePrism::Page) do
          section :anonymous_section, SitePrism::Section, '.section' do
            element :title, 'h1'
          end
        end
      end

      it { is_expected.to respond_to(:anonymous_section) }
      it { is_expected.to respond_to(:has_anonymous_section?) }
      it { is_expected.to respond_to(:has_no_anonymous_section?) }
      it { is_expected.to respond_to(:wait_until_anonymous_section_visible) }
      it { is_expected.to respond_to(:wait_until_anonymous_section_invisible) }
      it { is_expected.to respond_to(:all_there?) }
      it { is_expected.to respond_to(:within) }
    end

    context 'when second argument is not a Class and no block is given' do
      let(:section) { SitePrism::Page.section(:incorrect_section, '.section') }
      let(:message) do
        "You should provide descendant of SitePrism::Section \
class or/and a block as the second argument."
      end

      it 'raises an ArgumentError' do
        expect { section }.to raise_error(ArgumentError).with_message(message)
      end
    end
  end

  describe '.set_default search arguments' do
    let(:page_with_section_with_default_search_arguments) do
      Class.new(SitePrism::Page) do
        class SectionWithDefaultArguments < SitePrism::Section
          set_default_search_arguments :css, '.section'
        end

        class SectionWithDefaultArgumentsForParent < SectionWithDefaultArguments; end

        section :section_using_defaults, SectionWithDefaultArguments
        section :section_using_defaults_from_parent,
                SectionWithDefaultArgumentsForParent
        section :section_with_locator, SectionWithDefaultArguments, '.other-section'
        sections :sections, SectionWithDefaultArguments
      end
    end

    let(:page) { page_with_section_with_default_search_arguments.new }
    let(:default_search_arguments) { [:css, '.section'] }

    context 'when search arguments are provided during the DSL definition' do
      let(:search_arguments) { ['.other-section'] }

      it 'returns the search arguments for a section' do
        expect(page).to receive(:_find).with(*search_arguments, **dont_wait)

        page.section_with_locator
      end

      it 'ignores the `default_search_arguments`' do
        expect(page).not_to receive(:_find).with(*default_search_arguments, **dont_wait)

        page.section_with_locator
      end
    end

    context 'when search arguments are not provided during the DSL definition' do
      let(:search_arguments) { default_search_arguments }
      let(:invalid_page) do
        Class.new(SitePrism::Page) do
          section :section, SitePrism::Section
        end
      end
      let(:error_message) do
        'search arguments are needed in `section` definition or alternatively use `set_default_search_arguments`'
      end

      it 'uses the default search arguments set on the section' do
        expect(page).to receive(:_find).with(*search_arguments, **dont_wait)

        page.section_using_defaults
      end

      it 'uses the default_search_arguments set on the parent if none set on section' do
        expect(page).to receive(:_find).with(*search_arguments, **dont_wait)

        page.section_using_defaults_from_parent
      end

      it 'raises an ArgumentError if no default_search_arguments exist in the inheritane tree' do
        expect { invalid_page }.to raise_error(ArgumentError).with_message(error_message)
      end
    end
  end

  describe '.default_search_arguments' do
    let(:base_section) do
      Class.new(SitePrism::Section) do
        set_default_search_arguments :css, 'a.b'
      end
    end

    let(:child_section) do
      Class.new(base_section) do
        set_default_search_arguments :xpath, '//h3'
      end
    end

    let(:other_child_section) do
      Class.new(base_section)
    end

    it 'is false by default' do
      expect(described_class.default_search_arguments).to be false
    end

    it 'returns the default search arguments' do
      expect(base_section.default_search_arguments).to eq([:css, 'a.b'])
    end

    context 'when both parent and child class have default_search_arguments' do
      it 'returns the child level arguments' do
        expect(child_section.default_search_arguments).to eq([:xpath, '//h3'])
      end
    end

    context 'when only parent class has default_search_arguments' do
      it 'returns the parent level arguments' do
        expect(other_child_section.default_search_arguments).to eq([:css, 'a.b'])
      end
    end
  end

  describe '.set_default_search_arguments' do
    it { expect(described_class).to respond_to(:set_default_search_arguments) }
  end

  describe '#new' do
    let(:new_page) do
      Class.new(SitePrism::Page) do
        section :new_section, SitePrism::Section, '.class-one', css: '.my-css', text: 'Hi'
        element :new_element, '.class-two'
      end
    end

    let(:page) { new_page.new }

    context 'with a block given' do
      it 'passes the locator to Capybara.within' do
        expect(Capybara).to receive(:within).with(locator)

        section_with_block
      end
    end

    context 'without a block given' do
      it 'does not pass the locator to Capybara.within' do
        expect(Capybara).not_to receive(:within)

        section_without_block
      end
    end

    context 'with Capybara query arguments' do
      let(:query_args) { { css: '.my-css', text: 'Hi' } }
      let(:locator_args) { '.class-one' }

      it 'passes in a hash of query arguments' do
        expect(page).to receive(:_find).with(*locator_args, **query_args, **dont_wait)

        page.new_section
      end
    end

    context 'without Capybara query arguments' do
      let(:query_args) { {} }
      let(:locator_args) { '.class-two' }

      it 'passes in an empty hash, which is then sanitized out' do
        expect(page).to receive(:_find).with(*locator_args, **dont_wait)

        page.new_element
      end
    end
  end

  describe '#within' do
    it 'passes the block to Capybara#within' do
      expect(Capybara).to receive(:within).with(locator)

      section_without_block.within { :noop }
    end
  end

  describe '#visible?' do
    it 'delegates through root_element' do
      expect(locator).to receive(:visible?)

      section_without_block.visible?
    end
  end

  describe '#text' do
    it 'delegates through root_element' do
      expect(locator).to receive(:text)

      section_without_block.text
    end
  end

  describe '#native' do
    it 'delegates through root_element' do
      expect(locator).to receive(:native)

      section_without_block.native
    end
  end

  describe '#execute_script' do
    it 'delegates through Capybara.current_session' do
      expect(Capybara.current_session).to receive(:execute_script).with('JUMP!')

      section_without_block.execute_script('JUMP!')
    end
  end

  describe '#evaluate_script' do
    it 'delegates through Capybara.current_session' do
      expect(Capybara.current_session)
        .to receive(:evaluate_script)
        .with('How High?')
        .and_return('To the sky!')

      section_without_block.evaluate_script('How High?') == 'To the sky!'
    end
  end

  describe '#parent_page' do
    let(:section) { described_class.new(parent, '.locator') }
    let(:deeply_nested_section) do
      described_class.new(
        described_class.new(
          described_class.new(
            parent, '.locator-section-large'
          ), '.locator-section-medium'
        ), '.locator-small'
      )
    end
    let(:parent) { SitePrism::Page.new }

    it 'returns the parent page of a section' do
      expect(section.parent_page).to eq(parent)
    end

    it 'returns the parent page of a deeply nested section' do
      expect(deeply_nested_section.parent_page).to eq(parent)
    end
  end

  describe '#page' do
    subject(:page_method) { described_class.new('parent', root_element).page }

    let(:root_element) { 'root' }

    it { is_expected.to eq('root') }

    context 'when root element is nil' do
      let(:root_element) { nil }

      before do
        allow(Capybara).to receive(:current_session).and_return('current session')
      end

      it { is_expected.to eq('current session') }
    end
  end
end
