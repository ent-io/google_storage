module GoogleStorage
  class InheritLogger < Rails::Railtie
    initializer 'Rails logger' do
      GoogleStorage.instance_variable_set(:@logger, Rails.logger)
    end
  end
end
