require 'crack'
require 'google_storage/config'
require 'google_storage/client'
require 'google_storage/logger'

require 'google_storage/railties'

module GoogleStorage
  class << self
    def config
      @config ||= GoogleStorage::Config.new
    end

    def configure(&block)
      block.call self.config
      self
    end

    def client
      @client ||= GoogleStorage::Client.new
    end

    def logger
      @logger ||= new_logger
    end

    private

    def new_logger
      l = GoogleStorage::Logger.new(self.config.log_stream)
      l.sev_threshold = self.config.log_level
      l
    end
  end
end
