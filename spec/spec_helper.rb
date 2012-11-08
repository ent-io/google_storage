# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
end

require 'google_storage'
require 'fakeweb'
require 'secret_data'
require 'vcr'

require File.expand_path('../support/bucket_library', __FILE__)

$google_storage_yml_path = 'spec/support/google_storage.yml'

BucketLibrary.configure do |c|
  c.yaml_path = 'spec/support/bucket_library.yml'
  c.gs_client = GoogleStorage::Client.new :config_yml => $google_storage_yml_path
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :fakeweb
  if mode = ENV['GOOGLE_STORAGE_RECORD_MODE']
    c.default_cassette_options = { :record => mode.to_sym }
  end
  c.configure_rspec_metadata!
  SecretData.new(
    :yml_path => $google_storage_yml_path
  ).silence do |find, replace|
    c.filter_sensitive_data(replace) { find }
  end
end

$silence_access_token = lambda {|response|
  VCR.configure do |c|
    c.filter_sensitive_data('____SILENCED_access_token____') do
      response['access_token']
    end
  end
}

GoogleStorage.configure do |config|
  config.log_level = GoogleStorage::Logger::INFO
  config.after_refresh_access_token do |response|
    $silence_access_token.call response
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # Add VCR to all tests
  config.around(:each) do |example|
    options = example.metadata[:vcr] || {}
    if options[:record] == :skip 
      VCR.turned_off(&example)
    else
      name = example.metadata[:full_description].split(/\s+/, 2).join("/").gsub!(/(.)([A-Z])/,'\1_\2').downcase!.gsub(/[^\w\/]+/, "_")
      VCR.use_cassette(name, options, &example)
    end
  end

  # config.around(:each) do |example|
  #   if example.metadata[:stdout] == :silence
  #     $stdout.reopen(IO::NULL, 'w')
  #   else
  #     $stdout = STDOUT
  #   end
  # end
end
