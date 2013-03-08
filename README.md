# CED

The **C**entral **E**mail **D**atabase is an email verification service. You pass it an email address and it tells you if the email address is real or not. This gem wraps the API in a more Ruby friendly syntax. CED also corrects common typos in email domains.

## Installation

The CED gem is Ruby 1.9.x and 2.0.x compatible.

Add this line to your application's Gemfile:

    gem 'ced'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ced -P LowSecurity

## Usage

Minimum workable example:

```ruby
require "ced"
 => true
email = CED::Email.new("john@example.con", "ced.example.com", "client", "key")
 => #<CED::Email:0x007ffd4198c358 @address="john@example.con", @client="client", @key="key">
email.verified?
 => true
email.corrected_email
 => "john@example.com"
email.valid?
 => false
email.seen_before?
 => true
email.error
 => "Invalid domain name"
email.error_code
 => "invalid_domain_name"
```

You can skip the host, client and key parameters and specify the `ENV['CED_HOST']`, `ENV['CED_CLIENT']` and `ENV['CED_KEY']` environment variable for convenience.

**WARNING** Don't blindly trust `email.valid?` as it will also return `false` when the request failed. Always check for `email.verified?` before inspecting the other attributes!

## Contributing

Something missing? Found a bug? Horrified by the code? Open a [github issue](https://github.com/cimm/ced/issues), write a failing test or add some code using pull requests. Your help is greatly appreciated!
