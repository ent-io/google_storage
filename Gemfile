source "http://rubygems.org"

# Specify your gem's dependencies in google_storage.gemspec
gemspec

gem 'jruby-openssl', :platforms => :jruby

group :test, :development do
  gem 'rspec'
  gem 'simplecov'
  gem 'fakeweb'
  gem 'vcr'
  gem 'secret_data'
  gem 'uuid'
end

group :development do
  gem 'yard'
  gem 'RedCloth'

  gem 'guard-rspec'
  gem 'guard-bundler'

  # Watch file change events instead of polling
  gem 'rb-fsevent', :require => false, :group => :darwin              # OSX
  gem 'rb-inotify', :require => false, :group => :linux               # Linux
  gem 'wdm',        :require => false, :platforms => [:mswin, :mingw] # Windows

  gem 'debugger',   :platforms => :ruby_19

  gem 'travis',     :github => 'laserlemon/travis-cli'
end
