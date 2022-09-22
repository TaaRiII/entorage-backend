source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'

gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# ADDED
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem "font-awesome-rails"
gem 'american_date'
gem 'devise'
gem 'slim'
gem 'simple_form'
gem 'decent_exposure', '3.0.0'
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'kaminari', github: "amatsuda/kaminari", branch: '0-17-stable'
gem 'mimemagic', github: 'mimemagicrb/mimemagic', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f'
gem "paperclip", "~> 5.0.0"

gem 'awesome_print', require: 'ap'
gem 'dotenv-rails'
gem "cocoon"

# grape API
# gem 'grape'
# gem 'grape-active_model_serializers'
# gem 'grape_on_rails_routes'
# gem 'grape-swagger'
# gem 'grape-swagger-rails'
# gem 'hashie-forbidden_attributes'

# for api and api documenation
gem 'grape', '~> 0.14.0'
gem 'grape-swagger', '~> 0.20.2'
gem 'grape-swagger-rails', '~> 0.3.0'
gem 'active_model_serializers', '~> 0.9.5'
gem 'grape-active_model_serializers', '1.3.2'

gem 'hashie-forbidden_attributes'

#geo locations
gem 'geocoder'
#s3
gem 'aws-sdk', '~> 2'
gem 'rack-cors', require: 'rack/cors'

#push notification
gem 'fcm'

#messages
gem 'twilio-ruby'

#generate data
gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch => 'master'
# background jobs
gem 'sidekiq'
gem 'sidekiq-cron'
#errors
gem 'rollbar'
#phone numbers
gem 'phony_rails'

# soft delete
gem 'discard', '~> 1.2'

# sort
gem 'acts_as_list'
gem 'language_filter'

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem "rails-erd"
  gem 'pry'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
