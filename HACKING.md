# SitePrism dev setup

To successfully get SitePrism running locally, you need to just fork the repo

```bash
$ git clone git@github.com:your_user_name/site_prism.git
$ cd site_prism
$ bundle
```

Hacking commands you may need are ...

```bash
$ bundle exec rake cukes # Run feature tests on Chrome (Default browser)
$ bundle exec rake cukes browser=firefox # Run feature tests on Firefox
$ bundle exec rake specs # Run all rspec tests
$ bundle exec rake # Runs feature tests on Chrome, then specs, then runs RuboCop
```

- Write your code. Make sure to add tests AND documentation (if appropriate)
- Run `bundle exec rake` and ensure it passes
- Submit a pull request
- If you encounter issues regarding not being able to perform browser tests check whether
`geckodriver` and/or `chromedriver` have been downloaded (The `webdrivers` controls this)

Happy Testing / Developing!

Cheers,

The SitePrism Team
