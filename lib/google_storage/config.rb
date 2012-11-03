require 'google_storage/message'
require 'google_storage/client'

require 'erb'
require 'yaml'

module GoogleStorage
  class Config
    attr_accessor :log_stream, :log_level,
                  :project_id, :client_id, :client_secret, :refresh_token,
                  :gsid_you, :gsid_owners, :gsid_editors, :gsid_team,
                  :redirect_uri, :host, :api_version, :debug, :timeout


    def initialize
      @log_stream = $stdout
      @log_level  = GoogleStorage::Logger::FATAL
    end

    def from_yaml(path)
      unless File.exists?(path)
        GoogleStorage.logger.fatal Message.yaml_not_found
        raise SystemCallError, "No such file - #{path}"
      end
      if File.directory?(path)
        GoogleStorage.logger.fatal Message.yaml_not_found
        raise SystemCallError, "File needed, directory found - #{path}"
      end

      config_yml = YAML.load(ERB.new(File.read(path)).result)

      self.project_id      = config_yml['google_config']['x-goog-project-id']
      self.client_id       = config_yml['web_applications']['client_id']
      self.client_secret   = config_yml['web_applications']['client_secret']
      self.client_secret.force_encoding('UTF-8') if client_secret.respond_to?(:force_encoding)

      self.refresh_token   = config_yml['refresh_token'] if config_yml['refresh_token']

      #TODO Add support for individual permission types
      if config_yml['google_storage_ids']
        self.gsid_you      = config_yml['google_storage_ids']['you'] if config_yml['google_storage_ids']['you']
        self.gsid_owners   = config_yml['google_storage_ids']['owners'] if config_yml['google_storage_ids']['owners']
        self.gsid_editors  = config_yml['google_storage_ids']['editors'] if config_yml['google_storage_ids']['editors']
        self.gsid_team     = config_yml['google_storage_ids']['team'] if config_yml['google_storage_ids']['team']
      end

      #TODO - make redirect_uri's support multiple urls
      self.redirect_uri   = config_yml['web_applications']['redirect_uris']

      #TODO - maybe add support for API v1 as well... but probably not..
      self.host           = ( config_yml['host'] || 'commondatastorage.googleapis.com' )
      self.api_version    = ( config_yml['x_goog_api_version'] || 2 )
      self.debug          = config_yml['debug']
      self.timeout        = config_yml['timeout']

      return self
    end

    def access_token
      access_token_valid? ? @access_token : refresh_access_token
    end

    def access_token_valid?
      return true if @access_token && !access_token_expired?
      false
    end

    def access_token_expired?
      return true unless @access_token_expiry
      @access_token_expiry  < Time.now.to_i
    end

    def refresh_access_token
      # TODO(wenzowski): use the calling Client if it exists
      GoogleStorage.config == self ? config = nil : config = self
      response = Client.new(:config => config).refresh_access_token

      @access_token_expiry  = response['expires_in'].to_i + Time.now.to_i
      @access_token         = response['access_token']
    end

    def google_storage_id(id)
      case id
      when :you
        gsid_you
      when :owners
        gsid_owners
      when :editors
        gsid_editors
      when :team
        gsid_team
      end
    end

  end
end
