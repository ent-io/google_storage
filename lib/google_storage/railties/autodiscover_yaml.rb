module GoogleStorage
  class AutodiscoverYaml < Rails::Railtie
    initializer 'Check for yaml config and load if it exists' do
      default_path = File.join(Rails.root, 'config', 'google_storage.yml'))
      if File.exists?(default_path) && !File.directory?(default_path)
        config = GoogleStorage::Config.new
        config.from_yaml(default_path)
        GoogleStorage.instance_variable_set(:@config, config)
      end
    end
  end
end
