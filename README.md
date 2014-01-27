# Grape::RablRails

Use [RablRails](https://github.com/ccocchi/rabl-rails) templates in [Grape](https://github.com/intridea/grape)!

[![Build Status](https://secure.travis-ci.org/ifad/grape-rabl-rails.png)](http://travis-ci.org/ifad/grape-rabl-rails)
[![Dependency Status](https://gemnasium.com/ifad/grape-rabl-rails.png)](https://gemnasium.com/ifad/grape-rabl-rails)
[![Code Climate](https://codeclimate.com/github/ifad/grape-rabl-rails.png)](https://codeclimate.com/github/ifad/grape-rabl-rails)
[![Coverage Status](https://coveralls.io/repos/ifad/grape-rabl-rails/badge.png?branch=master)](https://coveralls.io/r/ifad/grape-rabl-rails?branch=master)
[![Gem Version](https://badge.fury.io/rb/grape-rabl-rails.png)](http://badge.fury.io/rb/grape-rabl-rails)

## Installation

Add the `grape` and `grape-rabl-rails` gems to Gemfile.

```ruby
gem 'grape'
gem 'grape-rabl-rails'
```

And then execute:

    $ bundle

## Usage

### Require grape-rabl-rails

```ruby
# config.ru
require 'grape/rabl-rails'
```

### Setup view root directory
```ruby
# config.ru
require 'grape/rabl-rails'

use Rack::Config do |env|
  env['api.rabl.root'] = '/path/to/view/root/directory'
end
```

### Tell your API to use Grape::Formatter::RablRails

```ruby
class API < Grape::API
  format :json
  formatter :json, Grape::Formatter::RablRails
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
object @user => :user
attributes :name, :email

child @project => :project do
  attributes :name
end
```

### Example

```ruby
# config.ru
require 'grape/rabl-rails'

use Rack::Config do |env|
  env['api.rabl.root'] = '/path/to/view/root/directory'
end

class UserAPI < Grape::API
  format :json
  formatter :json, Grape::Formatter::RablRails

  # use rabl with 'user.rabl' template
  get '/user/:id', :rabl => 'user' do
    @user = User.find(params[:id])
  end

  # do not use rabl, fallback to the defalt Grape JSON formatter
  get '/users' do
    User.all
  end
end
```

```ruby
# user.rabl
object :@user => :user

attributes :name
```

## Usage with rails

Create grape application

```ruby
# app/api/user.rb
class MyAPI < Grape::API
  format :json
  formatter :json, Grape::Formatter::RablRails

  get '/user/:id', :rabl => "user" do
    @user = User.find(params[:id])
  end
end
```

```ruby
# app/views/api/user.rabl
object :@user => :user
```

Edit your **config/application.rb** and add view path

```ruby
# application.rb
class Application < Rails::Application
  config.middleware.use(Rack::Config) do |env|
    env['api.rabl.root'] = Rails.root.join "app", "views", "api"
  end
end
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


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/LTe/grape-rabl-rails/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

