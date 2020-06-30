[![Build Status](https://travis-ci.com/WilliamMcCumstie/output_mode.svg?branch=master)](https://travis-ci.com/WilliamMcCumstie/output_mode)

# OutputMode

Provides a set of wrapper `Outputs` to common libraries: `TTY::Table`, `CSV`, and `ERB`. Focus on "what" you want to print to a terminal instead of "how" it should be formatted.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'output_mode'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install output_mode

## Usage

Checkout the [demo script](bin/demo) for a basic getting started example. It uses the two prefabricated modules:
 * `OutputMode::TLDR::Index` - Tabulate the data models for humans and tab ("\t") delimit it for machines
 * `OutputMode::TLDR::Show` - List the data model(s) for humans and tab ("\t") delimit it for machines

The `TLDR` modules are designed for a fairly limited use case, where:
 * The humanized/machine outputs is toggled if `StandardOut` is connected to a `TTY`,
 * Certain columns/fields need to be hidden based on a user supplied verbosity toggle.

A basic use case would be:

```
class Foo
  include OutputMode::TLDR::Index

  # Adds a "column" to the output. Fundamentally the "column" is a block transform function
  register_callable
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/WilliamMcCumstie/output_mode.

## Copyright and License

See [LICENSE](LICENSE.txt) for dual licensing details.

