# Grape::RablRails

Use [RablRails](https://github.com/ccocchi/rabl-rails) templates in [Grape](https://github.com/intridea/grape)!

[![Build Status](https://secure.travis-ci.org/ifad/grape-rabl-rails.png)](http://travis-ci.org/ifad/grape-rabl-rails)
[![Dependency Status](https://gemnasium.com/ifad/grape-rabl-rails.png)](https://gemnasium.com/ifad/grape-rabl-rails)
[![Code Climate](https://codeclimate.com/github/ifad/grape-rabl-rails.png)](https://codeclimate.com/github/ifad/grape-rabl-rails)
[![Coverage Status](https://coveralls.io/repos/ifad/grape-rabl-rails/badge.png?branch=master)](https://coveralls.io/r/ifad/grape-rabl-rails?branch=master)

## Installation

Add the `grape` and `grape-rabl-rails` gems to Gemfile.

```ruby
gem 'grape'
gem 'grape-rabl-rails'
```

And then execute:

    $ bundle

## Usage

### Tell your API to use Grape::Formatter::RablRails

```ruby
require 'grape/rabl-rails'

class API < Grape::API
  format :json
  formatter :json, Grape::Formatter::RablRails.new(views: 'views/api')
end
```

### Use rabl-rails templates conditionally

Add the template name to the API options.

```ruby
get "/user/:id", :rabl => "user" do
  @user = User.find(params[:id])
end
```

You can use instance variables in the RablRails template.

```ruby
object :@user
attributes :name, :email

child :@project do
  attributes :name
end
```

### Example

```ruby
# config.ru
require 'grape/rabl-rails'

class UserAPI < Grape::API
  format :json
  formatter :json, Grape::Formatter::RablRails.new(views: '/path/to/view/root')

  namespace :users do
    # do not use rabl, fallback to the defalut Grape formatter
    get '/' do
      User.all
    end

    # use rabl with 'user.rabl' template
    get '/:id', :rabl => 'user' do
      @user = User.find(params[:id])
    end
  end

end
```

```ruby
# users/user.rabl
object :@user

attributes :name
```

## Usage with rails

Create grape application

```ruby
# app/api/user.rb
class MyAPI < Grape::API
  format :json
  formatter :json, Grape::Formatter::RablRails.new(views: Rails.root.join("app/views/api"))

  get '/user/:id', :rabl => "user" do
    @user = User.find(params[:id])
  end
end
```

```ruby
# app/views/api/user.rabl
object :@user => :user
```

Mount application to rails router

```ruby
# routes.rb
GrapeExampleRails::Application.routes.draw do
  mount MyAPI => "/api"
end
```

## Specs

See ["Writing Tests"](https://github.com/intridea/grape#writing-tests) in [https://github.com/intridea/grape](grape) README.

Enjoy :)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

