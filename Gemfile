source 'https://rubygems.org'

gemspec

gem "grape",      github: "intridea/grape"
gem "rabl-rails", github: "ifad/rabl-rails", ref: 'e75c74e21ba73f2c83c63206620877e62d13350a'

group :test do
  gem "json", '~> 1.7.7'
  gem "rspec", "~> 2.12.0"
  gem "rack-test"
  gem "rake"
  gem "coveralls", require: false
end

platform :ruby do
  gem RUBY_VERSION.to_f >= 2.0 ? "byebug" : "debugger"
end
