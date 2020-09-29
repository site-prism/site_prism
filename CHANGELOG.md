## Unreleased
### Removed

### Added

### Changed

### Fixed
- Updated the maximum version of Capybara to `<= 3.33` to support Ruby 2.7+

## [3.6] - 2020-08-17
### Added
- Added `#elements_missing` method which returns all missing elements from the expected_elements list ([ineverov])

### Changed
- **Required Ruby Version is now 2.4+**
  - Alongside this, initial support will be offered for `selenium-webdriver` in alpha versions
([luke-hill])

- Refined SitePrism's `Waiter.wait_until_true` logic
  - SitePrism can now be used with `Timecop.freeze` and Rails' `travel_to`  
  - `FrozenInTimeError` was removed as it is no longer needed
([sos4nt])

### Fixed
- SitePrism's RSpec matchers fall back to behaviour matching that of the standard RSpec
  built-in matchers when called on anything that is not a SitePrism object.
([lparry]) & ([luke-hill])

- Fixed up a bunch more RSpec cop offenses and updated the minimum dev requirement of rubocop to `0.81` as it was ancient!
([luke-hill])

## [3.5] - 2020-06-04
### Added
- Added new logging that will notify users (And team!), when a user creates a name with a `no_` prefix
  - This will cause race condition conflicts which are intractable, and as such will be banned in a later release
([anuj-ssharma]) & ([luke-hill])
 
### Fixed
- Fixed warnings about keyword arguments in Ruby 2.7
  - The official explanation of keyword arguments in Ruby 2.7 can be found [HERE](https://www.ruby-lang.org/en/news/2019/12/12/separation-of-positional-and-keyword-arguments-in-ruby-3-0/)
([oieioi])

- Generic suite fixes for making tests more robust
([ineverov])

- Fixed an issue where block syntax wouldn't work properly for a singular DSL item (element / section)
  - If using one of these items, the block syntax would only work on initialization, as such it is advised to
  use SitePrism's `#within` scoping method which accesses the Capybara one using the SitePrism initializer.
  Read [HERE](https://github.com/site-prism/site_prism#accessing-within-a-collection-of-sections) for more info
([tgaff])

## [3.4.2] - 2020-01-30
### Added
- Simplecov now triggers for both local and CI builds
([luke-hill])

### Changed
- All internal SitePrism tests now will enable `site_prism-all_there` gem by default
  - Note there are still a couple of tests that make use of not using this
  (Whilst the gem is still optional)
  - During the `v3.x` series this gem will slowly move more into mainstream and will become the default
  option for `v4.0`
([luke-hill])

- Travis now builds on ruby `2.7` instead of `ruby-head`
([luke-hill])

- gemspec now forces version `0.3.1` minimum of `site_prism-all_there`
  - This will include the latest bug-fix required to make the gem fully operational
  - All versions up to `< 1` are permitted to future-proof it against further tweaks
([luke-hill])

- v13 of `rake` can now be used
([luke-hill])

### Fixed
- Fixed up some RSpec cop offenses & Added reasons for rule definitions
([luke-hill])

## [3.4.1] - 2019-09-26
### Changed
- Update the `Gemfile.low_spec` as it was untouched in over 6months
([luke-hill])

- Unlock `site_prism-all_there` to any `0.x` version higher than `0.3` now it is more stable
([luke-hill])

- Added more rubocop rule definitions
([luke-hill])

### Fixed
- Fixed up some RSpec cop offenses
([luke-hill])

## [3.4] - 2019-08-01
### Added
- Added first bunch of Feature Deprecation notices for users to advise of the items which
will either be changing for version4 or being removed entirely.
  - This also advises of a couple of areas that had some minor bugs in the codebase in the DSL
  creation phase (These will be fixed going forwards in v4)
([luke-hill])

- Added `rubocop-rspec` and regenerated the `.rubocop_todo.yml` file, fixing up some cops in the process
([luke-hill])

### Changed
- `#all_there?` now can be used both internally by site_prism and by the all_there gem
  - Users can set `SitePrism.use_all_there_gem` to use the latest bleeding edge logic
  - Note this also requires users to use the `0.2` version of the new gem
  - Users need to manually add `require site_prism-all_there` whilst this gem is still under
  migration from the existing code-base. It will be auto-added at a later date
([luke-hill])

- Upped some gem dependencies
  - `rubocop` now is upped to `0.73`, `rubocop` performance is at `1.4`
  - Added `rubocop-rspec` and re-generated config file (Plenty to fix up)
  - `simplecov` minimum requirement is `0.17`
([luke-hill])

### Fixed
- Fixed all legacy links to ([natritmeyer])'s Github page. They all now point here.
([luke-hill]) & ([igas])

- Fixed up / Improved some dead documentation links on the README, warning about outdated plugins
([luke-hill])

## [3.3] - 2019-07-01
### Added
- Initial `#all_there?` recursion logic
  - For now only two options are valid (`:none` and `:one`)
  - When setting it to `:none` (The default), the behaviour is identical
  - When setting it to `:one`, `#all_there?` will recurse through every section and sections item
  that has been defined, and run `#all_there?` on those items also.
  
  **NB: This is very much a working prototype, and additional refactors / tweaks will be forthcoming**
([luke-hill])

- Added a feature deprecator to allow easier deprecation / removal of obsolete or old parts of
the codebase
([luke-hill])

### Changed
- SitePrism is now hosted in it's own individual organisation! Special thanks to everyone who has helped
out in the past, but now we're looking to host multiple co-dependent gems from this new organisation
([luke-hill])

- Capybara dependency has been slightly bumped from `3.2+` to `3.3+` to mitigate against a minor
locator reference issue (None reported, but future-proofing)
([luke-hill])

### Fixed
- README fixes
([andyw8] & [TheSpartan1980])

- Fix an issue where chrome wasn't building successfully due to the migration to W3C capabilities
([luke-hill])

## [3.2] - 2019-05-14
### Added
- Allow `#load` to be called with a new option `:with_validations`
  - When this is set to `false` this will skip load_validations for the one method invocation
  - If not passed in or set to `true` the previous behaviour is retained (Validations running)
([JanStevens])

- `rubocop-performance` has been added as a development dependency to future-proof against
impending major rubocop release
([luke-hill])

- When using rspec matchers, the `.not_to` matcher will now use the `has_no_<element>?` method call
  - Previously this used the `!has_<element>?` call, which waited for the full duration to fail
([hoffi])

- Added new `#wait_until_displayed` method that sits alongside `#displayed?`
  - Initial `#displayed?` call has now been refactored to be a bit cleaner
  - `#wait_until_displayed` will wait or crash (Not return a booleanlike `#displayed?`
([TheSpartan1980] & [luke-hill])

### Changed
- `rubocop` rules regarding formatting (To bring it more in-line with the 21st century!)
([luke-hill])

### Fixed
- Travis now uses `webdrivers` gem to build and mitigate driver issues
([luke-hill])

- SitePrism can now detect if Time has been frozen (i.e. with Timecop), whilst using `.wait_until_true` 
([dkniffin])

## [3.1] - 2019-03-26
### Added
- Add info on how to deal with V2 -> V3 upgrade warnings RE Capybara selectors
  - In particular how to deal with adding `wait` keys to `wait_until_*` methods
([tgaff])

- Added gem version badge to `README.md`
([luke-hill])

- Some of the README docs surrounding how to setup site_prism have been improved
  - Distinction between how to layout the `require` statements in cucumber / rspec stacks
  - Open ended statements about further optimisations are available dependent on the stack
([luke-hill])

- XPath vs CSS iFrame inconsistency (There was the potential for an xpath iFrame to be "read" as CSS)
  - In this situation the locator would fail, but attempt to fall-back using Capybara
  - A new guard has been placed to check to see if iFrames have been created using XPath without `:xpath` type
([luke-hill])

- The SitePrism Logger has been massively refactored
  - It now almost entirely mimics the Full Ruby Logger API
  - The full list of delegated methods can be found [HERE](https://github.com/site-prism/site_prism/blob/v3.1/lib/site_prism.rb)
  - Consequently, the minimum Ruby Version for the suite has been bumped to `2.3`
  - Alongside this higher ruby requirement, changes have been made to Capybara/Rubocop/Test code
([luke-hill])

### Changed
- Travis now uses `xenial` Ubuntu in the Docker VM Tests, bringing it more up to date
([luke-hill])

- Travis now will build on some more (older), permutations of gems to increase test coverage
([luke-hill])

- The `HISTORY.md` document has now moved to `CHANGELOG.md` to try keep it in-line with other OSS repos
([luke-hill])

### Fixed
- During DSL Map phase, ensure all items are cast to symbol to ensure type-standardisation
([luke-hill])

- In some unit tests the XPath iFrame was created using CSS, this has now been fixed
  - This has also enabled the Mock Pages to be a little more extensible going forwards
([luke-hill])

- Added waiter methods for iFrame's that were previously missing, bringing them in-line with other DSL items
([luke-hill])

## [3.0.3] - 2019-02-20
### Changed
- Upped some gem dependencies
  - `rubocop` now is finally upped to v63
  - `dotenv ~> 2.6` - Only used in internal development
  - The `low_spec.gemfile` version of `addressable` is capped at `2.5` now a `2.6` version exists
([luke-hill])

- DRY up some internal tests by using rspec profiles and `.rspec` file
([luke-hill])

### Fixed
- Fixed an issue that caused SitePrism not to change scopes when two different Capybara sessions were in use
([luke-hill]) & ([twalpole])

- Fixed an issue where SitePrism could fail a travis build because of the load order of tests
  - This was caused by a state leakage between a single Unit Test that wasn't caught by an RSpec hook
([luke-hill])

- Load Validations
  - Are now slightly optimised making 2 less checks per batch (One less check per initial run)
  - Actually perform the checks they were documented to (They didn't run against a url without a block)
  - Fix `#loaded` `attr_accessor` to actually cache - It never did! (This speeds up `#loaded?` calls)
  - Add a couple more specs and a bunch of new scenarios to cover these missing edge cases 
([luke-hill])

## [3.0.2] - 2019-01-21
### Added
- Travis now runs on Ruby `2.6` and `ruby-head`
([tadashi0713])

### Changed
- Completely altered the namespace of the SitePrism DSL
  - Now fed from `SitePrism::DSL` (Nearly all is still package private)
  - Began to add documentation for `ElementChecker` introducing recursion
([luke-hill])

- Improve runtime of cucumber tests by another 10-20%
  - All remaining JS injections now isolated to their own pages
([luke-hill])

## [3.0.1] - 2019-01-08
### Added
- Travis tweaks
  - Show the browser/driver version in the script dump
  - Update firefox/geckodriver to latest versions
([luke-hill])

### Changed
- Local Testing Page improvements
  - Cleared out all javascript from Section Experiments and simplified the page
  - Added the Slow / Vanishing pages into consumption, so we now have a bit more Single Responsibility in tests
([luke-hill])

- Complete name-check/sweep of all poorly named test components
  - All files now match their class names
  - All sample items are now more succinctly named
  - Removed some of the slower JS injected components in favour of the Slow/Vanishing pages
([luke-hill]) 

- Item mapping (A large component of the site_prism build phase) has been refactored and slightly extended
  - Initially we will map the "type" of each site_prism item that has been mapped.
  - The public interface has been refactored to accommodate that and provide a like for like replacement
  - This will be the base of the work required to extend `#all_there?` to provide recursion capabilities
([luke-hill]) 

- Upped some gem dependencies
  - `rubocop` now is finally upped to v60 (More to come)
  - `rspec ~> 3.8` / `rake ~> 12.3`
  - `capybara` is now only supported on `2.18` outside of the `3.x` series
  - `cucumber` / `selenium-webdriver` both bumped one minor version
([luke-hill])
  
### Fixed
- A config setting that causes local single test (rspec/cucumber) runs to crash
  - This is due to `simplecov` caching dual results
([luke-hill])

- Stopped Ruby `2.5` users getting spammed with warnings about uninitialised instance variables
([menge101])

- Updated user documentation to not advise using now removed methods!
([TheSpartan1980])

## [3.0] - 2018-10-12
### Removed
- All Statically configured Error messages for all SitePrism defined Errors
  - Loadables still have an error message passed if defined
([luke-hill])

### Added
- `.simplecov` configuration file to allow easier configuration of the suite going forward
([luke-hill])

- A base SitePrism logger that wraps the Ruby Logger library
  - For now this will only output to `$stdout` and can only be configured as ON/OFF
  - Logger can be enabled with `SitePrism.enable_logging = true` (Default set to `false`)
  - Initial set of logger messages have been setup to debug / warn users when calling methods
([luke-hill])

- A new set of unconsumed leaner html pages which will in time replace the muddled ones
([luke-hill])

### Changed
- Upped Version Dependencies
  - `capybara` must be at least `2.17`, and can use any v3 version
  - `addressable ~> 2.5`
([luke-hill])

### Fixed
- Cucumber Rework
  - Began work on fixing up the erroneous and misleading names inside the `features` directory
  - Re-ordered the directory structure to use cucumbers autoload functionality
  - Added timings document to give us a set of goalposts to aim for
([luke-hill])

- Some of the `ElementContainer` module has been rewritten to be a little more concise
([luke-hill])

- All of the existing feature tests have now been adapted to fit to the aims of v3
  - Some of the new feature tests have been migrated to test implicit waiting logic
  - Previously defunct tests have now been fully migrated over to use wait key assignment
([luke-hill])

## [3.0.beta] - 2018-09-15
### Removed
- `wait_for_<element>` and `wait_for_no_<element>` have been removed
  - As per deprecation warnings, users should use the regular methods with a `wait` parameter
([luke-hill])

- All SitePrism configuration options ...
  - A warning message is thrown when a user sets any configuration option using `SitePrism.configure`
  - Default load validations should now be customised by the user (Detailed in the Upgrading docs)
  - `raise_on_wait_fors` was only triggered on the `wait_for` / `wait_for_no` methods
  - Implicit waiting is now hard-coded to always be on.
    - This can be overridden at runtime by using a `wait` key
    - You can still not use implicit waits by setting `Capybara.default_max_wait_time = 0`
([luke-hill])

### Added
- An UPGRADING.md document to help facilitate the switch from SitePrism v2 to v3
([luke-hill])

### Changed
- Most error message classes have been re-written into a more Ruby naming scheme (Ending in Error)
  - The previously aliased names have all been removed
  - The `error.rb` file details the previous names to help with the transition
([luke-hill])

- Upped Version Dependency of `selenium-webdriver` to `~> 3.6`
([luke-hill])

- SitePrism will now use the configured Capybara wait time to implicitly wait at all times
([luke-hill])

### Fixed
- The names/locations of some waiting tests, which were testing implicit instead of explicit waits
([luke-hill])

## [2.17.1] - 2018-09-15
### Fixed
- Configuration options now only throw warnings when written to
  - This fixes travis and other CI environments throwing an abnormally large number of warnings
([luke-hill])

- Fixed a name collision for a private method in `ElementChecker` that conflicted with ActiveRecord
([Systho])

## [2.17] - 2018-09-07
### Removed
- `collection` has been removed from the SitePrism DSL (Was just an alias of `sections`)
([luke-hill])

### Changed
- Made all configuration options throw deprecation warnings
([luke-hill])
- Advised users of a better way to use in-line waiting keys instead of `wait_for_*` methods (Deprecated)
([luke-hill])

## [2.16] - 2018-08-22
### Added
- A configuration switch to toggle the default Page Load Validation behaviours (By default set to on)
([luke-hill])

### Changed
- Refactored the way in which the procedural `Loadable` block is set for `SitePrism::Page`
([luke-hill])

- Upped Version Dependencies
  - `capybara` must be at least `2.15`
  - `selenium-webdriver ~> 3.5`
  - **Required Ruby Version is now 2.2+**
([luke-hill])

- Altered `HISTORY.md` into more hyperlinked and declarative format
([luke-hill]) & ([JaniJegoroff])

- Tidied up the Sample HTML files so they had less un-required information
([luke-hill])

- Refactored the way the `wait` key is assigned for all meta-programmed methods
  - Now assigned in a consistent way across all methods
  - Method set-up for further refactors due in v3 (Standardisation of API)
([luke-hill])

### Fixed
- Spec locations (All are now in correct files)
([luke-hill])

- README / rubocop fixes
([luke-hill])

## [2.15.1] - 2018-07-20
### Added
- Initial backwards compatible work for rewriting the Error protocols for site_prism 3.0
  - All Error Classes inherit from one common Error Class
  - All names have suffix `Error`
([luke-hill])

### Changed
- Add ability to test multiple gemfiles in travis
([luke-hill])

- Removed all constants aside from `VERSION`
([luke-hill])

- Improve runtime of cucumber tests by around 30% overall by tweaking some internal JS code
([luke-hill])

- Upped Capybara Version Dependency `capybara >= 2.14, < 3.3`
([luke-hill])

- Altered travis config to test for lowest gem configuration permissible in site_prism
([luke-hill])

### Fixed
- Fixed up some unit tests to cover pages defined with differing selectors
([luke-hill])

- README fixes
([luke-hill])

- Fix scoping issue that prevented iFrames / JS methods defined inside a `section` working
([ineverov])

## [2.15] - 2018-07-09
### Added
- Added more gem metadata into the `.gemspec` file to be read by RubyGems (Changelog e.t.c.)
([luke-hill])

- Enabled support for Capybara 3. Making sure suite is backwards compatible
([luke-hill])

- Added a huge portion of new feature tests to validate timings RE implicit/explicit waits
([tgaff])

### Fixed
- rubocop fixes
([ineverov])

- Fix implicit waiting not working for some DSL defined methods
([luke-hill]) & ([tgaff])

- Add better error message when iFrame's are called without a block (Than a stacktrace)
([luke-hill]) & ([mdesantis])

## [2.14] - 2018-06-22
### Removed
- Previously deprecated `Waiter.default_wait_time` (As this just called the Capybara method)
([luke-hill])

### Added
- Introduced new sister method to `#expected_elements` - `#elements_present`
  - This will return an Array of every Element that is present on the Page/Section
([luke-hill])

- Enabled ability to set default search arguments inside a Section
  - If set then a section will set `@root_element` to be defined from `.set_default_search_arguments`
  - If unset / overridden. You are able to still define them in-line using the DSL
([ineverov])

- Testing for Ruby 2.5 on Travis
([luke-hill])

### Changed
- Tidied up specs and made Code Coverage 100% compliant
([luke-hill])

- Upped Development Version Dependencies
  - `selenium-webdriver ~> 3.4`
  - `rubocop ~> 52.0`
([luke-hill])

- Rewrite `ElementContainer` by using `klass.extend`, removing several `self.class` calls
([ineverov]) 

- Added positive and negative timing tests to several scenarios in `waiting.feature`
([luke-hill])

### Fixed
- Fixed waiting bug that caused `Waiter.default_wait_time` not to wait the correct duration
  - Bug only seemed to be present when implicit waits were toggled on
([luke-hill])

- Removed references to `Timeout.timeout` as this isn't threadsafe
([twalpole])

- Fixed issue where multiple runtime arguments weren't set at run-time (ignored by Capybara)
([twalpole])

- rubocop fixes
([ineverov]) & ([jgs731])

## [2.13] - 2018-05-21
### Removed
- Removed testing for Ruby `2.0` on Travis
([luke-hill])

### Added
- Added new development docs to aid new and existing contributors
([luke-hill])

- Added Feature to wait for non-existence of element/section
([ricmatsui])

- Introduced configuration to raise an Exception after running `wait_for` methods
  - These aren't in sync with others, and this configuration option will be removed in time!
([ricmatsui])

### Changed
- Refactored Waiter Class
  - cleaner `.wait_until_true`
  - deprecated `.default_wait_time`
([luke-hill])

- Updated Suite Ruby Requirements (**Minimum Ruby is now `2.1`**)
([luke-hill])

- Internal testing tweaks
  - Updated cucumber dependency to `3.0.1` (Allowing new syntax testing)
  - Cleaned up cucumber tests into more granular structure
  - Altered output of RSpec to show test names
  - Unlock testing on Selenium up to `3.10`
([luke-hill])

- Use `shared_examples` in RSpec tests to enhance coverage and check xpath selectors
([luke-hill])

### Fixed
- `README.md` fixes
([robd])

## [2.12] - 2018-04-20
### Added
- Added Ruby `2.4` testing to Travis
([luke-hill])

- Update Travis Environment to now test on Chrome and Firefox
([RustyNail]) & ([luke-hill])

### Changed
- Updated development dependencies to be a little more up to date
([luke-hill])

- Allow iFrames to be specified using any selector (ID / Class / XPath / Index)
([ricmatsui])

- Upped Development Dependency of Selenium (3.4 - 3.8)
([luke-hill])

- Expose the `#native` method on Section Objects
([luke-hill])

### Fixed
- `README.md` / rubocop / Test / TODO fixes
([luke-hill])

- Fix suite incidentally masking several issues due to incorrect cucumber setup
([luke-hill])

- Fix issue where within a section, we lose our scoping
  - This is due to leveraging `Capybara::DSL`. We need to rescope `#page` to `#root_element`
([ilyasgaraev])

- Performed a suite-wide cleanup of Gherkin. Made everything a lot more organised
([luke-hill])

## [2.11] - 2018-03-07
### Added
- Re-enable Rubocop compliance from PR signoff (Including fixing up some offences)
([RustyNail])

- Allow `#all_there?` to be extended in the DSL with `#expected_elements`
  - This Allows pages to stipulate that some elements may not be there
  - This facilitates testing pages with error messages much easier
([TheMetalCode])

### Changed
- Use the `.gemspec` file for all gem versions and remove any references to gems in `Gemfile`
([luke-hill]) & ([tgaff])

- Compressed `Rakefile` into smaller tasks for Increased Verbosity on Failures
([luke-hill])

- Update Travis to test on a variety of rubies: `2.0 -> 2.3`, using the latest geckodriver
([luke-hill])

- Refactored SitePrism's Addressable library so its slightly less confusing to debug
([luke-hill])

### Fixed
- Fix bug where SitePrism failed load-validation's when passed Block Parameters with no URL
([kei2100])

- README / rubocop fixes
([luke-hill])

## [2.10] - 2018-02-23
### Removed
- Disable Rubocop compliance from PR signoff whilst suite is still being reworked
  - Fixes coming soon to future releases
  - Will be switched on once the suite is stabilised
([luke-hill])

### Added
- Added base contributing / issue templates
([luke-hill])

- Established Roadmap of items to be fixed in coming months
([luke-hill])

- Reworked specs / developmental code to read better
  - Established a base "correct syntax"
  - Improved performance slightly in block code
([luke-hill])

### Changed
- Upped Version Dependencies
  - `capybara ~> 2.3`
  - `rspec ~> 3.2`
  - Required Ruby Version is now 2.0+
([luke-hill])

- Capped Development dependencies for `cucumber (2.4)` and `selenium-webdriver (3.4)` 
  - Establish a baseline for what is expected with these dependencies
  - Suite is still being reworked (So unsure of what results to expect)
([luke-hill])

- Reworked all text files into Markdown structure to allow formatting
([luke-hill])

### Fixed
- Travis Fixes
  - Not pulling in geckodriver dependency
  - Ubuntu container migrated to `trusty` from `precise`
([RustyNail])

- Allow `#all_there?` to use in-line configured implicit wait (Still defaulted to false)
([RustyNail])

- README / rubocop fixes
([luke-hill]) & ([iwollmann])

## [2.9.1] - 2018-02-20
### Removed
- Travis tests for EOL Rubies (`2.0` / `2.1` / `2.2`)
([natritmeyer])

- Codebase cleanup of non-used config files
([luke-hill])

### Changed
- Bumped Travis Ruby version from `2.2` to `2.3`
([natritmeyer])

- Upped Version Dependency of `addressable` to `~> 2.4`
([luke-hill])

### Fixed
- README / rubocop fixes
([whoojemaflip]) & ([natritmeyer]) & ([luke-hill])

- Fixed namespace clashes with sections and rspec
([tobithiel])

- Improved Codecoverage pass-rate from `85%` to `99%` (1 outstanding item)
([luke-hill])

## [2.9] - 2016-03-29
### Removed
- Travis tests for Ruby `1.9.x` versions, Travis only tests on 2.0+
([natritmeyer])

### Added
- Implement new `Loadable` behaviour for pages and sections
  - This will allow you to add procs that get executed when you call `#load`
  - Also checks that the page is displayed before continuing
([tmertens])

- Added ability to use block syntax inside a `section` (Previously only iFrames could)
([tgaff])

### Fixed
- README / rubocop fixes
([nitinsurfs]) & ([cantonic]) & ([bhaibel]) & ([natritmeyer])

- Fix a Section Element calling `#text` incorrectly returning the full page text
([ddzz])

## [2.8] - 2015-10-30
### Removed
- `reek` as we have `rubocop`
([natritmeyer])

### Added
- Add ruby 2.2 to rubies used in Travis
([natritmeyer])

### Changed
- Use the latest version of Capybara's waiting time method
  - `#default_max_wait_time` from Capybara 2.5 onwards
  - `#default_wait_time` for 2.4 and below
([tpbowden]) & ([mnohai-mdsol]) & ([tmertens])

- Simplified `#secure?` method
([benlovell])

### Fixed
- Fix up rubocop issues from suite updates
([tgaff])

- README doc fixes
([khaidpham])

## [2.7] - 2015-04-23
### Added
- Allow `#load` to be passed an HTML block to facilitate cleaner view tests
([rugginoso])

- Spring clean of the code, integrated suite with `rubocop`
([jonathanchrisp])

- Test on ruby 2.1 as an additional part of sign-off procedure in Travis
([natritmeyer])

- SitePrism can now leverage URL component parts during the matching process
  - Substituting all parts of url_matcher into the relevant types (port/fragment e.t.c.)
  - Only pass the matching test after each component part matches the `url_matcher` set
([jmileham])
  
- Added check for block being passed to page (Will raise error accordingly)
([sponte])

### Changed
- Altered legacy RSpec syntax in favour of `expect` in tests
([petergoldstein]) 

- Extend `#displayed?` to work when a `url_matcher` is templated
([jmileham])

### Fixed
- README doc fixes
([vanburg]) & ([csgavino])

- Amended issues that occurred on RSpec 3 by making the suite agnostic to the version used
([tgaff]) & ([natritmeyer])

- Internal test suite altered to avoid conflicting with Capybara's `#title` method
([tgaff])

## [2.6] - 2014-02-11
### Added
- Added anonymous sections (That need no explicit Class declaration)
([bassneck])

### Changed
- Upped Version Dependency of rspec to `< 4.0`, and altered it to be a development dependency
([soulcutter]) & ([KarthikDot]) & ([natritmeyer])

### Fixed
- README / License data inconsistencies
([dnesteryuk]) & ([natritmeyer])

- Using runtime options but not specifying a wait time would throw a Type mismatch error
  - This will now default to `Capybara.default_max_wait_time` if implicit waiting is enabled
  - This won't wait if implicit waiting is disabled
([tgaff])

## [2.5] - 2013-10-28
### Added
- Allowed iFrames to be selected by index
([mikekelly])

- Integrated a Rack App into the suite to allow for enhanced spec testing
([natritmeyer])

- `site_prism` gem now does lazy loading
([mrsutter])

- `SitePrism::Waiter.wait_until_true` class method now re-evaluates blocks until they pass as true
([tmertens])

- Improved `capybara` integration to allow runtime arguments to be passed into methods
([tmertens])

- Added configuration for the entire Suite to use implicit waits (Default configured off)
([tmertens])

### Changed
- README tweaks relevant to the new version of the gem
([abotalov]) & ([natritmeyer]) & ([tommyh])

### Fixed
- README inconsistencies fixed
([antonio]) & ([LukasMac]) & ([Mustang949])

- Allow `#displayed?` test used in load validations to use newly made `Waiter` class to avoid false failures
([tmertens])

- Changed `#set_url` to convert its input to a string - fixing method inconsistencies
([modsognir])

## [2.4] - 2013-05-18
### Added
- Added `#has_no_<thing>?`, to test for non-presence
([johnwake])

### Changed
- `site_prism` now uses `Capybara::Node::Finders#find` instead of `#first` to locate an element / section
([natritmeyer])

- Upped Version Dependency of capybara to `~> 2.1`
([natritmeyer])

- `SitePrism::Page#title` now returns `""` instead of `nil` when there is no title
([natritmeyer])

- Altered suite configuration to ignore hidden elements in internal feature testing
([natritmeyer])

### Fixed
- Improved the waiting logic for visible / invisible waiters to avoid false failures
([j16r])

## [2.3] - 2013-04-05
### Added
- Initial Dynamic URL support 
  - Adds new dependency to suite `addressable`
  - Allows templating of URL parameters to be passed in as KVP's
([therabidbanana])

- Added Yard Rake task to dynamically generate documentation on gem
([natritmeyer])

## [2.2] - 2013-03-12
### Added
- Added `#parent` and `#parent_page` to `SitePrism::Section` that will find a Sections Parent, and their Parent Page respectively
([dnesteryuk])

- Ruby 1.9 Code cleanup (Hash / gemspec)
([abotalov])

- Travis integration on repository
([abotalov])

### Changed
- Required ruby version now 1.9.3+
([abotalov])

### Fixed
- Various visibility and waiting bug fixes
([dnesteryuk])

## [2.1] - 2013-02-06
### Added
- Added xpath support
([3coins])

- Added `reek` to the suite to try clean up some code-smells
([natritmeyer])

## [2.0] - 2013-01-15
### Added
- Added rake-tasks to suite for `rspec` and `cucumber` tests
([natritmeyer])

### Changed
- Upped Version Dependency of `capybara` to `~> 2.0`
([natritmeyer])

- `site_prism` gem now depends on Ruby 1.9; 1.8 is deprecated (`capybara` no longer supports 1.8)
([natritmeyer])

## [1.4] - 2012-11-20
### Changed
- Changed all references of 'locator' to 'selector' in the code / documentation
([natritmeyer])

- Upped Version Dependencies
  - `capybara ~> 1.1`
  - `rspec ~> 2.0`
([natritmeyer])
  
- Internal API Changes:
  - `#element_names` is now `#mapped_items` in `SitePrism::Page` and `SitePrism::Section`
  - We now use a `build` method to decide what methods are created for each element/section and in what order
([natritmeyer])

- External API Change (Probably breaking change):
  - `NoLocatorForElement` is now `NoSelectorForElement`
([natritmeyer])

### Fixed
- README typo sweep done. Errors fixed
([nathanbain])

## [1.3] - 2012-07-29
### Added
- Added `wait_until_<element_name>_visible` / `wait_until_<element_name>_invisible` for elements and sections
([natritmeyer])

- Added `simplecov` to the suite to give some internal usage statistics
([natritmeyer])

## [1.2] - 2012-07-02
### Added
- Added ability to interact with iFrames
([natritmeyer])

## [1.1.1] - 2012-06-17

### Fixed
- Added ruby 1.8.* support that was broken in [1.1]
([remi])

## [1.1] - 2012-06-14
### Added
- Added `page.secure?` method
([natritmeyer])

## [1.0] - 2012-04-19
- First public release!

### Added
- Added `README.md`
([natritmeyer])

### Fixed
- Fixed issue where cucumber tests wouldn't run due to hardcoded test path
([andyw8])

## [0.9.9] - 2012-03-24
### Added
- Base History document
([natritmeyer])

### Fixed
- Fixed bug where `wait_for_` didn't work in sections
([natritmeyer])

## [0.9.8] - 2012-03-16
### Added
- Added ability to call `execute_javascript` and `evaluate_javascript` inside a `section`
([natritmeyer])

## [0.9.7] - 2012-03-11
### Added
- Added ability to have pending elements, ie: elements declared without locators
([natritmeyer])

## [0.9.6] - 2012-03-06
### Changed
- Refactored parameterised `wait_for_` to accept an overriden wait time
([natritmeyer])

## [0.9.5] - 2012-03-05
### Changed
- Refactored `all_there?` to run faster
([natritmeyer])

## [0.9.4] - 2012-03-01
### Added
- Added `all_there?` method
  - Returns `true` if all mapped elements and sections are present, `false` otherwise
([natritmeyer])

## [0.9.3] - 2012-02-11
### Added
- Added `wait_for_` functionality to pages and sections
([natritmeyer])

## [0.9.2] - 2012-01-11
### Added
- Added ability to access a section's `root_element`
([natritmeyer])

## [0.9.1] - 2012-01-11
### Added
- Added `visible?` to section
([natritmeyer])

## [0.9] - 2011-12-22
- First release!

<!-- Releases -->
[Unreleased]: https://github.com/site-prism/site_prism/compare/v3.6...master
[3.6]:        https://github.com/site-prism/site_prism/compare/v3.5...v3.6
[3.5]:        https://github.com/site-prism/site_prism/compare/v3.4.2...v3.5
[3.4.2]:      https://github.com/site-prism/site_prism/compare/v3.4.1...v3.4.2
[3.4.1]:      https://github.com/site-prism/site_prism/compare/v3.4...v3.4.1
[3.4]:        https://github.com/site-prism/site_prism/compare/v3.3...v3.4
[3.3]:        https://github.com/site-prism/site_prism/compare/v3.2...v3.3
[3.2]:        https://github.com/site-prism/site_prism/compare/v3.1...v3.2
[3.1]:        https://github.com/site-prism/site_prism/compare/v3.0.3...v3.1
[3.0.3]:      https://github.com/site-prism/site_prism/compare/v3.0.2...v3.0.3
[3.0.2]:      https://github.com/site-prism/site_prism/compare/v3.0.1...v3.0.2
[3.0.1]:      https://github.com/site-prism/site_prism/compare/v3.0...v3.0.1
[3.0]:        https://github.com/site-prism/site_prism/compare/v3.0.beta...v3.0
[3.0.beta]:   https://github.com/site-prism/site_prism/compare/v2.17.1...v3.0.beta
[2.17.1]:     https://github.com/site-prism/site_prism/compare/v2.17...v2.17.1
[2.17]:       https://github.com/site-prism/site_prism/compare/v2.16...v2.17
[2.16]:       https://github.com/site-prism/site_prism/compare/v2.15.1...v2.16
[2.15.1]:     https://github.com/site-prism/site_prism/compare/v2.15...v2.15.1
[2.15]:       https://github.com/site-prism/site_prism/compare/v2.14...v2.15
[2.14]:       https://github.com/site-prism/site_prism/compare/v2.13...v2.14
[2.13]:       https://github.com/site-prism/site_prism/compare/v2.12...v2.13
[2.12]:       https://github.com/site-prism/site_prism/compare/v2.11...v2.12
[2.11]:       https://github.com/site-prism/site_prism/compare/v2.10...v2.11
[2.10]:       https://github.com/site-prism/site_prism/compare/v2.9.1...v2.10
[2.9.1]:      https://github.com/site-prism/site_prism/compare/v2.9...v2.9.1
[2.9]:        https://github.com/site-prism/site_prism/compare/v2.8...v2.9
[2.8]:        https://github.com/site-prism/site_prism/compare/v2.7...v2.8
[2.7]:        https://github.com/site-prism/site_prism/compare/v2.6...v2.7
[2.6]:        https://github.com/site-prism/site_prism/compare/v2.5...v2.6
[2.5]:        https://github.com/site-prism/site_prism/compare/v2.4...v2.5
[2.4]:        https://github.com/site-prism/site_prism/compare/v2.3...v2.4
[2.3]:        https://github.com/site-prism/site_prism/compare/v2.2...v2.3
[2.2]:        https://github.com/site-prism/site_prism/compare/v2.1...v2.2
[2.1]:        https://github.com/site-prism/site_prism/compare/v2.0...v2.1
[2.0]:        https://github.com/site-prism/site_prism/compare/v1.4...v2.0
[1.4]:        https://github.com/site-prism/site_prism/compare/v1.3...v1.4
[1.3]:        https://github.com/site-prism/site_prism/compare/v1.2...v1.3
[1.2]:        https://github.com/site-prism/site_prism/compare/v1.1.1...v1.2
[1.1.1]:      https://github.com/site-prism/site_prism/compare/v1.1...v1.1.1
[1.1]:        https://github.com/site-prism/site_prism/compare/v1.0...v1.1
[1.0]:        https://github.com/site-prism/site_prism/compare/v0.9.9...v1.0
[0.9.9]:      https://github.com/site-prism/site_prism/compare/v0.9.8...v0.9.9
[0.9.8]:      https://github.com/site-prism/site_prism/compare/v0.9.7...v0.9.8
[0.9.7]:      https://github.com/site-prism/site_prism/compare/v0.9.6...v0.9.7
[0.9.6]:      https://github.com/site-prism/site_prism/compare/v0.9.5...v0.9.6
[0.9.5]:      https://github.com/site-prism/site_prism/compare/v0.9.4...v0.9.5
[0.9.4]:      https://github.com/site-prism/site_prism/compare/v0.9.3...v0.9.4
[0.9.3]:      https://github.com/site-prism/site_prism/compare/v0.9.2...v0.9.3
[0.9.2]:      https://github.com/site-prism/site_prism/compare/v0.9.1...v0.9.2
[0.9.1]:      https://github.com/site-prism/site_prism/compare/v0.9...v0.9.1
[0.9]:        https://github.com/site-prism/site_prism/compare/7b15706...v0.9

<!-- Contributors in chronological order -->
[natritmeyer]:    https://github.com/natritmeyer
[andyw8]:         https://github.com/andyw8
[remi]:           https://github.com/remi
[nathanbain]:     https://github.com/nathanbain
[3coins]:         https://github.com/3coins
[dnesteryuk]:     https://github.com/dnesteryuk
[abotalov]:       https://github.com/abotalov
[therabidbanana]: https://github.com/therabidbanana
[johnwake]:       https://github.com/johnwake
[j16r]:           https://github.com/j16r
[mikekelly]:      https://github.com/mikekelly
[antonio]:        https://github.com/antonio
[LukasMac]:       https://github.com/LukasMac
[tmertens]:       https://github.com/tmertens
[modsognir]:      https://github.com/modsognir
[Mustang949]:     https://github.com/tmertens
[mrsutter]:       https://github.com/mrsutter
[tommyh]:         https://github.com/tommyh
[bassneck]:       https://github.com/bassneck
[soulcutter]:     https://github.com/soulcutter
[KarthikDot]:     https://github.com/KarthikDot
[tgaff]:          https://github.com/tgaff
[petergoldstein]: https://github.com/petergoldstein
[rugginoso]:      https://github.com/rugginoso
[vanburg]:        https://github.com/vanburg
[jonathanchrisp]: https://github.com/jonathanchrisp
[jmileham]:       https://github.com/jmileham
[sponte]:         https://github.com/sponte
[csgavino]:       https://github.com/csgavino
[tpbowden]:       https://github.com/tpbowden
[mnohai-mdsol]:   https://github.com/mnohai-mdsol
[khaidpham]:      https://github.com/khaidpham
[benlovell]:      https://github.com/benlovell
[nitinsurfs]:     https://github.com/nitinsurfs
[cantonic]:       https://github.com/cantonic
[bhaibel]:        https://github.com/bhaibel
[ddzz]:           https://github.com/ddzz
[whoojemaflip]:   https://github.com/whoojemaflip
[tobithiel]:      https://github.com/tobithiel
[luke-hill]:      https://github.com/luke-hill
[RustyNail]:      https://github.com/RustyNail
[iwollmann]:      https://github.com/iwollmann
[TheMetalCode]:   https://github.com/TheMetalCode
[kei2100]:        https://github.com/kei2100
[ricmatsui]:      https://github.com/ricmatsui
[ilyasgaraev]:    https://github.com/ilyasgaraev
[ricmatsui]:      https://github.com/ricmatsui
[robd]:           https://github.com/robd
[ineverov]:       https://github.com/ineverov
[twalpole]:       https://github.com/twalpole
[jgs731]:         https://github.com/jgs731
[mdesantis]:      https://github.com/mdesantis
[JaniJegoroff]:   https://github.com/JaniJegoroff
[Systho]:         https://github.com/Systho
[menge101]:       https://github.com/menge101
[TheSpartan1980]: https://github.com/TheSpartan1980
[tadashi0713]:    https://github.com/tadashi0713
[JanStevens]:     https://github.com/JanStevens
[dkniffin]:       https://github.com/dkniffin
[hoffi]:          https://github.com/hoffi
[igas]:           https://github.com/igas
[oieioi]:         https://github.com/oieioi
[anuj-ssharma]:   https://github.com/anuj-ssharma
[sos4nt]:         https://github.com/sos4nt
[lparry]:         https://github.com/lparry
