# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.1.3'
# Use Puma as the app server
gem 'puma', '~> 6.4'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.4', '>= 5.4.4'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11', '>= 2.11.5'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# for cognito
gem 'aws-sdk-cognitoidentityprovider', '~> 1.87.0'
# importing creds
gem 'aws-sdk-s3', '~> 1'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.17.1', require: false

# For scheduling tasks
gem 'arask', '~> 1.2.3'

# for postgresql
gem 'activerecord-postgis-adapter', '~> 9.0.1'
gem 'pg', '~> 1.5.4'
# remove if not option two taken in project
gem 'jwt', '~> 2.7.1'
gem 'rest-client', '~> 2.1'
gem 'rollbar', '~> 3.5.1'
gem 'roo', '~> 2.10.1'
# remove if not option two taken in project

# For canonical urls
gem 'canonical-rails', github: 'jumph4x/canonical-rails'

# For environment variables
gem 'aws-sdk-ssm', '~> 1.162.0'

# Add rate limiting on the API
gem 'rack-attack', '~> 6.7.0'

# GOV.UK Frontend helpers
gem 'ccs-frontend_helpers', '~> 0.1.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', '~> 11.1.3', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '~> 3.0.2'
  gem 'i18n-tasks', '~> 1.0.13'
  gem 'rspec-rails', '~> 6.1.1'
  gem 'rubocop', '~> 1.60.2'
  gem 'rubocop-performance', '~> 1.20.2'
  gem 'rubocop-rails', '~> 2.23.1'
  gem 'rubocop-rspec', '~> 2.26.1' # or gem 'rubocop-minitest'
  gem 'brakeman', '~> 6.1.1'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.8'
  gem 'web-console', '~> 4.2.1'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.1.3'
  gem 'spring-watcher-listen', '~> 2.1.0'
end

group :test do
  gem 'rails-controller-testing', '~> 1.0.5', '>= 1.0.5'
  gem 'simplecov', '~> 0.22.0', '>= 0.16.1', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
