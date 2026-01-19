# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0.4'
# Use Puma as the app server
gem 'puma', '~> 7.1'

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem 'propshaft'

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails', '~> 1.4'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails', '~> 1.3'

# For making fetch request calls
gem 'requestjs-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.14'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# for cognito
gem 'aws-sdk-cognitoidentityprovider', '~> 1.134.0'
# importing creds
gem 'aws-sdk-s3', '~> 1'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.21.1', require: false

# For background jobs
gem 'solid_queue', '~> 1.3.1'

# for postgresql
gem 'activerecord-postgis-adapter', '~> 11.0.0'
gem 'pg', '~> 1.6.3'
# remove if not option two taken in project
gem 'jwt', '~> 3.1.2'
gem 'rest-client', '~> 2.1'
gem 'rollbar', '~> 3.7.0'
gem 'roo', '~> 3.0.0'
gem 'csv', '~> 3.3.5'
# remove if not option two taken in project

# For canonical urls
gem 'canonical-rails', github: 'jumph4x/canonical-rails'

# For environment variables
gem 'aws-sdk-ssm', '~> 1.209.0'

# Add rate limiting on the API
gem 'rack-attack', '~> 6.8.0'

# GOV.UK Frontend helpers
gem 'ccs-frontend_helpers', '~> 3.3.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 13.0.0', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '~> 3.2.0'
  gem 'i18n-tasks', '~> 1.1.2'
  gem 'rspec-rails', '~> 8.0.2'
  gem 'rubocop', '~> 1.82.1'
  gem 'rubocop-performance', '~> 1.26.1'
  gem 'rubocop-rails', '~> 2.34.3'
  gem 'rubocop-rspec', '~> 3.9.0'
  gem 'rubocop-rspec_rails', '~> 2.32.0'
  gem 'brakeman', '~> 7.1.2'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.10'
  gem 'web-console', '~> 4.2.1'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.4.0'
  gem 'spring-watcher-listen', '~> 2.1.0'
end

group :test do
  gem 'rails-controller-testing', '~> 1.0.5', '>= 1.0.5'
  gem 'simplecov', '~> 0.22.0', '>= 0.16.1', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
