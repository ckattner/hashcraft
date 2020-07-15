# Hashcraft

[![Gem Version](https://badge.fury.io/rb/hashcraft.svg)](https://badge.fury.io/rb/hashcraft) [![Build Status](https://travis-ci.org/bluemarblepayroll/hashcraft.svg?branch=master)](https://travis-ci.org/bluemarblepayroll/hashcraft) [![Maintainability](https://api.codeclimate.com/v1/badges/d0efe1bf0603a5dcd4e4/maintainability)](https://codeclimate.com/github/bluemarblepayroll/hashcraft/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/d0efe1bf0603a5dcd4e4/test_coverage)](https://codeclimate.com/github/bluemarblepayroll/hashcraft/test_coverage) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Provides a DSL for implementing classes which can then be consumed to create pre-defined hashes.  At Blue Marble we use this library to help define user interface components like grids, modals, panes, tabs, dialogs, etc.  It allows for our team to create code-first Ruby contracts for a React component library, essentially helping to create a "transpilation" pipeline: Ruby -> JSON -> React.

## Installation

To install through Rubygems:

````
gem install install hashcraft
````

You can also add this to your Gemfile:

````
bundle add hashcraft
````

## Getting Started

### A Simple Example

Imagine we want to build a Ruby class that defines a grid.  Imagine we would also like to use this class to derive grids from it, using the class as the "contract".  We could start with this:

````ruby
class Grid < Hashcraft::Base
  option :api_url,
         :name
end
````

We could then derive grids from it using the constructor:

````ruby
config = Grid.new(api_url: '/patients', name: 'PatientsGrid').to_h
````

or using blocks:

````ruby
config = Grid.new do
  api_url '/patients'
  name 'PatientsGrid'
end.to_h
````

Both net the same value for `config`:

````ruby
{
  "api_url" => "/patients",
  "name" => "PatientsGrid"
}
````

But what if we want to add columns?  We could add two new building blocks: the column and the content (what goes in a column):

````ruby
class Content < Hashcraft::Base
  option :property
end

class Column < Hashcraft::Base
  option :header

  option :content, craft: Content,
                   mutator: :array,
                   key: :contents
end

class Grid < Hashcraft::Base
  option :api_url,
         :name

  option :column, craft: Column,
                  mutator: :array,
                  key: :columns
end
````

Now that we have declared the overall structure of the contract, we can use it like this:

````ruby
config = Grid.new do
  api_url '/patients'
  name 'PatientsGrid'

  column header: 'ID #' do
    content property: :id
  end

  column header: 'First Name' do
    content property: :first
  end

  column header: 'Last Name' do
    content property: :last
  end
end.to_h
````

This would net us the following value for config:

````ruby
{
  "api_url" => "/patients",
  "name" => "PatientsGrid",
  "columns" => [
    {
      "header" => "ID #",
      "contents" => [
        { "property" => :id }
      ]
    },
    {
      "header" => "First Name",
      "contents" => [
        { "property" => :first }
      ]
    },
    {
      "header" => "Last Name",
      "contents" => [
        { "property" => :last }
      ]
    }
  ]
}
````

### The Option API

The minimal declaration of an available option for a class is as follows:

````ruby
class Grid < Hashcraft::Base
  option :api_url
end
````

This means there is an available method called api_url that can be called to set a key, called api_url, to its passed in value.  But there are several additional options available:

* **craft**: Hashable::Base subclass constant used as a building block (Column in the above example.)  When defined it will be hydrated with the declared arguments and block and have #to_h called on it.
* **default**: the value to initialize the key to, used in conjunction with eager.  When eager is true then this value will be used to set the key's default value to.  Note that this value will be simply overridden if it is declared at run-time.
* **eager**: always assign a value.  When true it will always assign the key a value.
* **key**: allows for aliasing keys.  If omitted, the key will be the option's method name (api_url as noted above).
* **meta**: used to store any arbitrary data that can be accessed with transformers.
* **mutator**: defines the *type of update* to be made to the underlying value, defaulting to `property`.  When the default, `property`, is used then it will simply assign the passed in value.  Some other options are: `hash` and `array`.  When hash is used then the passed in value will be merged onto the key's value.  When array is used then the passed in value will be pushed onto the key's value.  For other types see the `Hashcraft::MutatorRegistry` file.

### Internationalization Support

There is currently no first-class support for internationalization, but you can easily leverage the Option API meta field along with a custom value transformer to achieve this.  See the Transformers section for an example using Rails I18n mechanic.

### Transformers

Transformers are optional but come into play when you need any additional/special processing of keys and values.  By default, keys and values use the pass-thru transformer, `Hashcraft::Transformers::PassThru`, but can be explicitly passed any object that responds to `#transform(value, option)`.

#### Key Transformer Example

Say, for example, we wanted to transform all keys to camel case.  We could create our own transformer, such as:

````ruby
  class CamelCase
    def transform(value, _option)
      name = value.to_s.split('_').collect(&:capitalize).join

      name[0, 1].downcase + name[1..-1]
    end
  end
````

We can then use this when deriving hashes (building on the Grid example above):

````ruby
class Content < Hashcraft::Base
  option :property
end

class Column < Hashcraft::Base
  option :header

  option :content, craft: Content,
                   mutator: :array,
                   key: :contents
end

class Grid < Hashcraft::Base
  key_transformer CamelCase.new

  option :api_url,
         :name

  option :column, craft: Column,
                  mutator: :array,
                  key: :columns
end

config = Grid.new do
  api_url '/patients'
end.to_h
````

The resulting `config` value will now be:

````ruby
{
  "apiUrl" => "/patients"
}
````

Note that this library ships with some basic transformers like the one mentioned above.  If you want to use this then you can simply do this:

````ruby
class Grid < Hashcraft::Base
  key_transformer :camel_case

  option :api_url,
         :name

  option :column, craft: Column,
                  mutator: :array,
                  key: :columns
end

config = Grid.new do
  api_url '/patients'
end.to_h
````

See the `Hashcraft::TransformerRegistry` file for a full list of provided transformers.

#### Value Transformer Example

You can plug in internationalization by creating a custom value transformer and leveraging the Option API meta directive:

````ruby
class Localizer
  def transform(value, option)
    if option.meta(:localize)
      I18n.l(value)
    else
      value
    end
  end
end
````

Building on our Grid example, we could enhance the Column object:

````ruby
class Column < Hashcraft::Base
  value_transformer Localizer.new

  option :header, meta: { localize: true }

  option :content, craft: Content,
                   mutator: :array,
                   key: :contents
end
````

We can then use the new value transformer, `Localizer`, when deriving hashes (building on the above Grid and updated Column example):

````yaml
en:
  id: Identification Number
  first: First Name
````

````ruby
config = Grid.new do
  column header: :id
  column header: :first
end.to_h
````

Assuming our en.yml looks like the above example and our locale is set to :en then the resulting `config` value will now be:

````ruby
{
  "columns" => [
    { header: 'Identification Number' },
    { header: 'First Name' },
  ]
}
````

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check hashcraft.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/hashcraft.git)
4. Navigate to the root folder (cd hashcraft)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````
bundle exec guard
````

Also, do not forget to run Rubocop:

````
bundle exec rubocop
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update `lib/hashcraft/version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push master to remote and ensure CI builds master successfully
6. Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code of Conduct

Everyone interacting in this codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bluemarblepayroll/hashcraft/blob/master/CODE_OF_CONDUCT.md).

## License

This project is MIT Licensed.
