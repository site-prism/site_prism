# Upgrading from SitePrism 3.x to 4.x

## DSL name validation

An initial attempt to start banning invalid DSL names has been introduced through a `DSLValidator` module.

For 4.x this will be disabled by default. We may look to switch this to a default on/toggleable state further down
the road, but for now this is experimental.

Setting the env variable `SITEPRISM_DSL_VALIDATION_ENABLED` will then perform these checks during the build metaprogram
phase of suite execution.

It is **highly** advisable to set full verbose logging on when using this by using `SitePrism.logger.level = :DEBUG`.

## Passing blocks to invalid DSL items

SitePrism 3.x permitted you to create DSL items using a block in all situations. However when you created an item
that was an `:element`, `:elements` or `:sections` the overall resultant method generation was an error method
(This is because we don't permit blocks for these DSL items).

Now in 4.x we ban these creations and will hard-fail instantly.

## Removal of #page

In SitePrism 3.x (Specifically when using capybara < 3.29), often people would want to obtain their "current" scope,
either deliberately or by using a chained method. The way we used to do this was by calling `#page`, which would then
return your scope. From later versions of capybara they implemented a `#to_capybara_node` method which would be called
and pre-chained to ensure your scope was correct.

At SitePrism, we left in the legacy method. However in the v4 beta the method will crash with a
fatal error (And this will be removed entirely in the v4 proper -> so you'll get a standard Ruby `NoMethodError`).

When operating on a regular `SitePrism::Page` object the call to `#page` will still work and it
will still return either the `Capybara::String` that was passed in as a html fragment or the
current `Capybara::Session`.

**However ...** This is also not advisable, and as such this is now going to be deprecated

If you want to obtain your full page scoping. Using `#parent_page` will get you your top level page, or simply using
`#parent` will get you to go up one level of scoping.

# Upgrading from SitePrism 2.x to 3.x

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

You can also create a `BasePage` class if you want to retain this functionality across all your pages ...

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
Check [error.rb](https://github.com/site-prism/site_prism/blob/main/lib/site_prism/error.rb)
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
The wait time should now be passed using hash args like: `wait: <seconds>`.

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
this may indicate that you still need to make this change.
