# SitePrism dev setup

To successfully get SitePrism running locally, you need to just fork the repo

```bash
$ git clone git@github.com:your_user_name/site_prism.git
$ cd site_prism
$ bundle
```

Hacking commands you may need are ...

```bash
$ bundle exec cucumber # Run feature tests on Chrome (Default browser)
$ bundle exec cucumber BROWSER=firefox # Run feature tests on Firefox
$ bundle exec rspec # Run all rspec tests
$ bundle exec rubocop # Runs RuboCop
```

- Write your code. Make sure to add tests AND documentation (if appropriate)
- Submit a pull request, ensuring it passes CI
- If you encounter issues regarding not being able to perform browser tests check whether
`geckodriver` and/or `chromedriver` have been downloaded (The `webdrivers` gem controls this).

Happy Testing / Developing!

Cheers,

The SitePrism Team
