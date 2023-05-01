source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0', '>= 7.0.4.3'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5.5'
# Use Puma as the app server
gem 'puma', '~> 6.2', '>= 6.2.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'active_model_serializers', '~> 0.10.13'
gem 'bootsnap', '~> 1.16', require: false
gem 'config', '~> 4.1'
gem 'dotenv-rails', '~> 2.8', '>= 2.8.1', require: 'dotenv/rails-now'
gem 'jwt', '~> 2.7'
gem 'rest-client', '~> 2.1'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '~> 2.0', '>= 2.0.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails', '~> 6.2'
  gem 'rspec-rails', '~> 6.0', '>= 6.0.1'
end

group :development do
  gem 'listen', '~> 3.8'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.1', '>= 4.1.1'
  gem 'spring-watcher-listen', '~> 2.1'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]