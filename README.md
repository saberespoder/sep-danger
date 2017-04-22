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

## Releasing new version
1. be sure to be in master branch
2. Change version in version file
3. run **rake master_release**

Yes, it so simple!

## Development
Idea is to automate code review process to maximaise our time on discussion of what is really important.

Ideas for this, could be found in:
- Potential security checks -> https://github.com/brunofacca/zen-rails-security-checklist
- Improving our transition to more Functionality Style coding - improve checks for immutable object and/or data.
- Using ruby and rails best practices



This project is being maintained by SEP Geek squad. We run multiple project to help immigrants at http://saberespoder.com 


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

