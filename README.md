[![Dependency Status](https://gemnasium.com/badges/github.com/saberespoder/sep-danger.svg)](https://gemnasium.com/github.com/saberespoder/sep-danger)
[![Build Status](https://travis-ci.org/saberespoder/sep-danger.svg?branch=master)](https://travis-ci.org/saberespoder/sep-danger)

# Sep::Danger

This is based on Danger and helps us automate our code-reviews. Everything is very opionated and aimed only for Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sep-danger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sep-danger

## Usage

After you've added gem to Gemfile, just add Dangerfile to root of your project with contents:

```
danger.import_dangerfile(gem: 'sep-danger')
```

## Features
- Run linters on the code diff using [pronto](https://github.com/mmozuras/pronto). By default the following linters are included:
  * [pronto-haml](https://github.com/mmozuras/pronto-haml)
  * [pronto-rails_best_practices](https://github.com/mmozuras/pronto-rails_best_practices)
  * [pronto-rubocop](https://github.com/mmozuras/pronto-rubocop)
  * [pronto-stylelint](https://github.com/kevinjalbert/pronto-stylelint) with the [standard stylelint config](https://github.com/stylelint/stylelint-config-standard)
  * [pronto-eslint_npm](https://github.com/doits/pronto-eslint_npm) with typescript parser and the [AirBnB styleguide](https://github.com/airbnb/javascript/tree/master/packages/eslint-config-airbnb)
  Any other pronto linters you have installed will also be ran
- Ask for review using slack webhook (use the `SLACK_REVIEW_WEBHOOK` env var) unless the PR is a WIP or tests failed
- Link to issue in the pull request if the branch starts with an issue number (If you keep all issues in one repository, use the `DANGER_ISSUES_REPO` env variable)

## Releasing new version
1. be sure to be in master branch
2. Change version in version file
3. run **rake master_release**

Yes, it so simple!

## Development
Automate code review process to maximize time on what matters.

Ideas for this, could be found in:
- Potential security checks -> https://github.com/brunofacca/zen-rails-security-checklist
- Improving our transition to more Functionality Style coding - improve checks for immutable object and/or data.
- Using ruby and rails best practices

Lead maintainer for this project is @dvdbng


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

