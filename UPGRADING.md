# Upgrading from SitePrism 2.x to 3.x

## 2.11 to 2.14 first
To reduce the overhead of the upgrade, I recommend you lock capybara at 2.18 until site_prism is upgraded until v.A.
In my case, I was going from SitePrism 2.11

at 2.14 you must remove the deprecated timeout paramater on invisible matcher, eg:

```
-    wait_until_loading_indicator_invisible(timeout)
+    wait_until_loading_indicator_invisible
```

Modify your Gemfile so you have something like this.
```
gem 'site_prism', '< 2.15'
gem 'capybara', '~> 2.18'
```

making sure you go step by step

at 2.15.1

I started getting these errors

```
Selenium::WebDriver::Error::StaleElementReferenceError:
        stale element reference: element is not attached to the page document
          (Session info: chrome=67.0.3396.79)
          (Driver info: chromedriver=2.39.562737 (dba483cee6a5f15e2e2d73df16968ab10b38a2bf),platform=Linux 4.14.133-113.105.amzn2.x86_64 x86_64)
```

2.15 is also stricker on matching, you might get error such as:

```
     Capybara::Ambiguous:
       Ambiguous match, found 2 elements matching visible css ".ui-dialog.ui-widget"
```

in some cases, waiting might help, at least until you can upgrade capybara as well

```
def wait_for_ajax
  Timeout.timeout(30) do
    loop until all_ajax_requests_finished?
  end
end
```

from 3.0, you need to update your matchers, eg:

```
-    wait_for_custom_schedule_dialog_buttons
+    wait_until_custom_schedule_dialog_buttons_visible
```

## Updating Capybara

From site_prism 2.15, you can update capybara 3.2
And from site_prism 2.16, you can update to capybara 3.5
But if you are stuck like me, I recommend you postpone this update and keep capybara 2.18 until site_prism 3.0.3
which is the last version that supports capybara 2.x

At that point, you have to upgrade if you want to use site_prism 3.1-3.4

## Default Load Validations

SitePrism 2.x contains 1 inbuilt load validation for any Page that is a
direct descendant of `SitePrism::Page`. This has now been removed.
If you wish to retain the previous functionality then ...

```ruby
class MyPage < SitePrism::Page
end
```

now becomes ...

```ruby
class MyPage < SitePrism::Page
  load_validation { [displayed?, "Expected #{current_url} to match #{url_matcher} but it did not."] }
end
```

You can also create a `BasePage` class if you want to retain this functionality
across all your Pages

```ruby
class BasePage < SitePrism::Page
   load_validation { [displayed?, "Expected #{current_url} to match #{url_matcher} but it did not."] }
end
```

And then you just need to have ...

```ruby
class MyPage < BasePage
end
```

## Error Classes

The entire set of error names have been re-written.
Check [error.rb](https://github.com/site-prism/site_prism/blob/master/lib/site_prism/error.rb)
for previous names.

## Configuration Options

Previously `site_prism` (As of `2.17.1`), had 3 configuration options. These were ...

```ruby
  default_load_validations = true #=> Whether the default load validation for displayed? was set 
  use_implicit_waits = false #=> Whether site_prism would use Capybara's implicit waiting by default
  raise_on_wait_fors = false #=> Whether running wait_for_<element/section> methods that failed would crash
```

These have all been removed with the `3.0` release. Implicit Waiting is
controlled / modifiable either in-line for each method-call, or you can set the default
timeout by re-configuring `Capybara.default_max_wait_time`.

## `wait_until` methods

Previously `wait_until` methods accepted a numerical value for wait time.
The wait time should now be passed using hash args like: `wait: <seconds>`

For example, previously:

```ruby
@page.wait_until_dialog_invisible(10)
@page.wait_until_notification_flag_visible(5, count: 3)
```

These now become:

```ruby
@page.wait_until_dialog_invisible(wait: 10)
@page.wait_until_notification_flag_visible(wait: 5, count: 3)
```

> Note: If after upgrading you see `Unused parameters passed to Capybara::Queries::SelectorQuery : [NUMBER]`
this may indicate that you need to make this change.
