# frozen_string_literal: true

describe SitePrism::Page do
  let(:page) { described_class.new }
  let(:locator) { instance_double(Capybara::Node::Element) }

  before { allow(SitePrism::Waiter).to receive(:default_wait_time).and_return(0) }

  it 'responds to set_url' do
    expect(described_class).to respond_to(:set_url)
  end

  it 'responds to set_url_matcher' do
    expect(described_class).to respond_to(:set_url_matcher)
  end

  describe '#url' do
    let(:page_with_url) do
      Class.new(described_class) do
        set_url '/bob'
      end.new
    end

    let(:page_with_uri_template) do
      Class.new(described_class) do
        set_url '/users{/username}{?query*}'
      end.new
    end

    it 'shows the base url of a page object' do
      expect(page_with_url.url).to eq('/bob')
    end

    it 'is nil by default' do
      expect(page.url).to be_nil
    end

    it 'shows the base url of a page object - omitting the parametrisation parts' do
      expect(page_with_uri_template.url).to eq('/users')
    end

    it 'shows the full url of a page object including the parametrisation parts' do
      expect(page_with_uri_template.url(username: 'foobar', query: { 'key' => 'value' }))
        .to eq('/users/foobar?key=value')
    end
  end

  describe '#url_matcher' do
    let(:page_with_url_matcher) do
      Class.new(described_class) do
        set_url_matcher(/bob/)
      end.new
    end

    it 'shows the base url regex matcher of the `SitePrism::Page`' do
      expect(page_with_url_matcher.url_matcher).to eq(/bob/)
    end

    it 'is nil by default on the Class' do
      expect(described_class.url_matcher).to be_nil
    end

    it 'is nil by default on the Instance' do
      expect(page.url_matcher).to be_nil
    end
  end

  it 'raises an exception if passing a block to an element' do
    expect { CSSPage.new.element_one { :foo } }.to raise_error(SitePrism::UnsupportedBlockError)
  end

  it 'raises an exception if passing a block to elements' do
    expect { CSSPage.new.elements_one { :any_old_block } }.to raise_error(SitePrism::UnsupportedBlockError)
  end

  it 'raises an exception if passing a block to sections' do
    expect { CSSPage.new.sections_one { :foo } }.to raise_error(SitePrism::UnsupportedBlockError)
  end

  it { is_expected.to respond_to(*Capybara::Session::DSL_METHODS) }

  describe '#page' do
    subject { page_with_url.page }

    let(:page_with_url) do
      Class.new(described_class) do
        set_url '/bob'
      end.new
    end

    context 'with #load called previously' do
      before { page_with_url.instance_variable_set(:@page, :some_value) }

      it { is_expected.to eq(:some_value) }
    end

    context 'with #load not called previously' do
      it { is_expected.to eq(Capybara.current_session) }
    end
  end

  describe '#load' do
    let(:page_with_load_validations) do
      Class.new(described_class) do
        set_url '/foo_page'

        def must_be_true
          true
        end

        def also_true
          true
        end

        def foo?
          true
        end

        load_validation { [must_be_true, 'It is not true!'] }
        load_validation { [also_true, 'It is not also true!'] }
      end.new
    end
    let(:page_with_url) do
      Class.new(described_class) do
        set_url '/bob'
      end.new
    end
    let(:page_with_uri_template) do
      Class.new(described_class) do
        set_url '/users{/username}{?query*}'
      end.new
    end

    it "does not allow loading if the url hasn't been set" do
      expect { page.load }.to raise_error(SitePrism::NoUrlForPageError)
    end

    it 'allows loading if the url has been set' do
      expect { page_with_url.load }.not_to raise_error
    end

    it 'allows loading with arguments if the url has been set with them' do
      expect { page_with_uri_template.load(username: 'foobar') }.not_to raise_error
    end

    it 'does not crash when loading a page with arguments if the url does not recognise them' do
      expect { page_with_load_validations.load(username: 'foobar') }.not_to raise_error
    end

    it 'loads the html' do
      expect { page_with_url.load('<html/>') }.not_to raise_error
    end

    context 'with Passing Load Validations' do
      it 'executes the pre-defined load validation blocks' do
        expect(page_with_load_validations.load).to be true
      end

      it 'executes and returns the block passed into it at runtime' do
        expect(page.load('<html>hi<html/>', &:text)).to eq('hi')
      end

      it 'yields itself to the passed block' do
        expect(page_with_load_validations).to receive(:foo?).and_call_original

        page_with_load_validations.load(&:foo?)
      end

      it 'loads the page' do
        page_with_load_validations.load

        expect(page_with_load_validations).to be_loaded
      end

      it 'does not call the load validations if they are disabled' do
        expect(page_with_load_validations).not_to receive(:must_be_true)

        page_with_load_validations.load(with_validations: false)
      end

      it 'still executes and returns the block passed into it when load validations are disabled' do
        expect(page_with_load_validations.load(with_validations: false) { :return_this }).to eq(:return_this)
      end
    end

    context 'with Failing Load Validations' do
      before do
        allow(page_with_load_validations).to receive(:must_be_true).and_return(false)
      end

      it 'raises an error' do
        expect { page_with_load_validations.load }
          .to raise_error(SitePrism::FailedLoadValidationError)
          .with_message('It is not true!')
      end

      it 'still raises an error when passed a truthy block' do
        expect { page_with_load_validations.load { puts 'foo' } }
          .to raise_error(SitePrism::FailedLoadValidationError)
          .with_message('It is not true!')
      end

      it 'loads the page when validations are disabled' do
        expect(page_with_load_validations.load(with_validations: false)).to be_truthy
      end

      it 'still executes and returns the block passed into it when load validations are disabled' do
        expect(page_with_load_validations.load(with_validations: false) { :return_this }).to eq(:return_this)
      end
    end
  end

  describe '#displayed?' do
    let(:page_with_url) do
      Class.new(described_class) do
        set_url '/bob'
      end.new
    end

    let(:page_with_url_matcher) do
      Class.new(described_class) do
        set_url_matcher(/bob/)
      end.new
    end

    it 'allow calls if the url matcher has been set' do
      expect { page_with_url_matcher.displayed? }.not_to raise_error
    end

    it 'raises an exception if called before the matcher has been set' do
      expect { page.displayed? }.to raise_error(SitePrism::NoUrlMatcherForPageError)
    end

    it 'delegates through #wait_until_displayed' do
      expect(page_with_url).to receive(:wait_until_displayed).with(:foo, :bar, :baz)

      page_with_url.displayed?(:foo, :bar, :baz)
    end

    context 'with a full string URL matcher' do
      subject(:page) do
        Class.new(SitePrism::Page) do
          set_url_matcher('https://joe:bump@bla.org:443/foo?bar=baz&bar=boof#frag')
        end.new
      end

      it 'matches with all elements matching' do
        swap_current_url('https://joe:bump@bla.org:443/foo?bar=baz&bar=boof#frag')

        expect(page.displayed?).to be true
      end

      it "doesn't match with a non-matching fragment" do
        swap_current_url('https://joe:bump@bla.org:443/foo?bar=baz&bar=boof#otherfr')

        expect(page.displayed?).to be false
      end

      it "doesn't match with a missing param" do
        swap_current_url('https://joe:bump@bla.org:443/foo?bar=baz#frag')

        expect(page.displayed?).to be false
      end

      it "doesn't match with wrong path" do
        swap_current_url('https://joe:bump@bla.org:443/not_foo?bar=baz&bar=boof#frag')

        expect(page.displayed?).to be false
      end

      it "doesn't match with wrong host" do
        swap_current_url('https://joe:bump@blabber.org:443/foo?bar=baz&bar=boof#frag')

        expect(page.displayed?).to be false
      end

      it "doesn't match with wrong user" do
        swap_current_url('https://joseph:bump@bla.org:443/foo?bar=baz&bar=boof#frag')

        expect(page.displayed?).to be false
      end

      it "doesn't match with wrong password" do
        swap_current_url('https://joe:bean@bla.org:443/foo?bar=baz&bar=boof#frag')

        expect(page.displayed?).to be false
      end

      it "doesn't match with wrong scheme" do
        swap_current_url('http://joe:bump@bla.org:443/foo?bar=baz&bar=boof#frag')

        expect(page.displayed?).to be false
      end

      it "doesn't match with wrong port" do
        swap_current_url('https://joe:bump@bla.org:8000/foo?bar=baz&bar=boof#frag')

        expect(page.displayed?).to be false
      end
    end

    context 'with a minimal URL matcher' do
      let(:page) do
        Class.new(SitePrism::Page) do
          set_url_matcher('/foo')
        end.new
      end

      it 'matches a complex URL by only path' do
        swap_current_url('https://joe:bump@bla.org:443/foo?bar=baz&bar=boof#frag')

        expect(page.displayed?).to be true
      end
    end

    context 'with an implicit matcher' do
      let(:page) do
        Class.new(SitePrism::Page) do
          set_url '/foo'
        end.new
      end

      it 'sets the `url_matcher` to the url property' do
        expect(page.url_matcher).to eq('/foo')
      end

      it 'matches a realistic local dev URL' do
        swap_current_url('http://localhost:3000/foo')

        expect(page.displayed?).to be true
      end
    end

    context 'with a parameterized URL matcher' do
      let(:page) do
        Class.new(SitePrism::Page) do
          set_url_matcher('{scheme}:///foos{/id}')
        end.new
      end

      it 'returns true without expected_mappings provided' do
        swap_current_url('http://localhost:3000/foos/28')

        expect(page).to be_displayed
      end

      it 'returns true with correct expected_mappings provided' do
        swap_current_url('http://localhost:3000/foos/28')

        expect(page).to be_displayed(id: 28)
      end

      it 'returns false with incorrect expected_mappings provided' do
        swap_current_url('http://localhost:3000/foos/28')

        expect(page).not_to be_displayed(id: 17)
      end
    end

    context 'with a bogus URL matcher' do
      let(:page) do
        Class.new(SitePrism::Page) do
          set_url_matcher(this: "isn't a URL matcher")
        end.new
      end

      it 'raises an InvalidUrlMatcherError' do
        expect { page.displayed? }.to raise_error(SitePrism::InvalidUrlMatcherError)
      end
    end
  end

  describe '#wait_until_displayed' do
    subject(:wait_for_page) { page.wait_until_displayed }

    context 'with a full string URL matcher' do
      let(:page) do
        Class.new(SitePrism::Page) do
          set_url_matcher('https://joe:bump@bla.org:443/foo?bar=baz&bar=boof#frag')
        end.new
      end

      it 'matches with all elements matching' do
        swap_current_url('https://joe:bump@bla.org:443/foo?bar=baz&bar=boof#frag')

        expect { wait_for_page }.not_to raise_error
      end

      it "doesn't match with a non-matching fragment" do
        swap_current_url('https://joe:bump@bla.org:443/foo?bar=baz&bar=boof#otherfr')

        expect { wait_for_page }.to raise_error(SitePrism::TimeoutError)
      end

      it "doesn't match with a missing param" do
        swap_current_url('https://joe:bump@bla.org:443/foo?bar=baz#frag')

        expect { wait_for_page }.to raise_error(SitePrism::TimeoutError)
      end

      it "doesn't match with wrong path" do
        swap_current_url('https://joe:bump@bla.org:443/not_foo?bar=baz&bar=boof#frag')

        expect { wait_for_page }.to raise_error(SitePrism::TimeoutError)
      end

      it "doesn't match with wrong host" do
        swap_current_url('https://joe:bump@blabber.org:443/foo?bar=baz&bar=boof#frag')

        expect { wait_for_page }.to raise_error(SitePrism::TimeoutError)
      end

      it "doesn't match with wrong user" do
        swap_current_url('https://joseph:bump@bla.org:443/foo?bar=baz&bar=boof#frag')

        expect { wait_for_page }.to raise_error(SitePrism::TimeoutError)
      end

      it "doesn't match with wrong password" do
        swap_current_url('https://joe:bean@bla.org:443/foo?bar=baz&bar=boof#frag')

        expect { wait_for_page }.to raise_error(SitePrism::TimeoutError)
      end

      it "doesn't match with wrong scheme" do
        swap_current_url('http://joe:bump@bla.org:443/foo?bar=baz&bar=boof#frag')

        expect { wait_for_page }.to raise_error(SitePrism::TimeoutError)
      end

      it "doesn't match with wrong port" do
        swap_current_url('https://joe:bump@bla.org:8000/foo?bar=baz&bar=boof#frag')

        expect { wait_for_page }.to raise_error(SitePrism::TimeoutError)
      end
    end

    context 'with a minimal URL matcher' do
      let(:page) do
        Class.new(described_class) do
          set_url_matcher('/foo')
        end.new
      end

      it 'matches a complex URL by only path' do
        swap_current_url('https://joe:bump@bla.org:443/foo?bar=baz&bar=boof#frag')

        expect { wait_for_page }.not_to raise_error
      end
    end

    context 'with an implicit matcher' do
      let(:page) do
        Class.new(described_class) do
          set_url '/foo'
        end.new
      end

      it 'sets the `url_matcher` to the url property' do
        expect(page.url_matcher).to eq('/foo')
      end

      it 'matches a realistic local dev URL' do
        swap_current_url('http://localhost:3000/foo')

        expect { wait_for_page }.not_to raise_error
      end
    end

    context 'with a parameterized URL matcher' do
      let(:page) do
        Class.new(described_class) do
          set_url_matcher('{scheme}:///foos{/id}')
        end.new
      end

      it 'passes without expected_mappings provided' do
        swap_current_url('http://localhost:3000/foos/28')

        expect { wait_for_page }.not_to raise_error
      end

      it 'passes with correct expected_mappings provided' do
        swap_current_url('http://localhost:3000/foos/28')

        expect { page.wait_until_displayed(id: 28) }.not_to raise_error
      end

      it 'fails with incorrect expected_mappings provided' do
        swap_current_url('http://localhost:3000/foos/28')

        expect { page.wait_until_displayed(id: 17) }.to raise_error(SitePrism::TimeoutError)
      end
    end

    context 'with a bogus URL matcher' do
      let(:page) do
        Class.new(described_class) do
          set_url_matcher(this: "isn't a URL matcher")
        end.new
      end

      it 'raises InvalidUrlMatcherError' do
        expect { wait_for_page }.to raise_error(SitePrism::InvalidUrlMatcherError)
      end
    end
  end

  describe '#url_matches' do
    let(:url_matches) { page.url_matches }

    context 'with a templated matcher' do
      let(:page) do
        Class.new(described_class) do
          set_url_matcher('{scheme}:///foos{/id}')
        end.new
      end

      it 'returns mappings from the current_url' do
        swap_current_url('http://localhost:3000/foos/15')

        expect(url_matches).to eq('scheme' => 'http', 'id' => '15')
      end

      it "returns nil if current_url doesn't match the url_matcher" do
        swap_current_url('http://localhost:3000/bars/15')

        expect(url_matches).to be_nil
      end
    end

    context 'with a regexp matcher' do
      let(:page) do
        Class.new(described_class) do
          set_url_matcher(/foos\/(\d+)/)
        end.new
      end

      it 'returns regexp MatchData' do
        swap_current_url('http://localhost:3000/foos/15')

        expect(url_matches).to be_a(MatchData)
      end

      it 'lets you get at the captures' do
        swap_current_url('http://localhost:3000/foos/15')

        expect(page.url_matches[1]).to eq('15')
      end

      it "returns nil if current_url doesn't match the url_matcher" do
        swap_current_url('http://localhost:3000/bars/15')

        expect(url_matches).to be_nil
      end
    end

    context 'with a bogus URL matcher' do
      let(:page) do
        Class.new(described_class) do
          set_url_matcher(this: "isn't a URL matcher")
        end.new
      end

      it 'raises InvalidUrlMatcherError' do
        expect { url_matches }.to raise_error(SitePrism::InvalidUrlMatcherError)
      end
    end
  end

  describe '#execute_script' do
    it 'delegates through Capybara.current_session' do
      expect(Capybara.current_session).to receive(:execute_script).with('JUMP!')

      page.execute_script('JUMP!')
    end
  end

  describe '#evaluate_script' do
    it 'delegates through Capybara.current_session' do
      allow(Capybara.current_session).to receive(:evaluate_script).with('How High?').and_return('To the sky!')

      expect(page.evaluate_script('How High?')).to eq('To the sky!')
    end
  end

  describe '#secure?' do
    it 'is true for secure pages' do
      swap_current_url('https://www.secure.com/')

      expect(page).to be_secure
    end

    it 'is false for insecure pages' do
      swap_current_url('http://www.insecure.com/')

      expect(page).not_to be_secure
    end

    it 'is false for pages where the prefix is www' do
      swap_current_url('www.unsure.com')

      expect(page).not_to be_secure
    end
  end

  def swap_current_url(url)
    allow(page).to receive(:page).and_return(instance_double(SitePrism::Page, current_url: url))
  end
end
