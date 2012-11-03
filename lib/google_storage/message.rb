module GoogleStorage
  module Message
    class << self
      def yaml_not_found
        <<-EOF


        Can't find a google_storage.yml file to initialise with.
        ========================================================

        If running inside a Rails Application, run

            $ rails generate google_storage:install

        To generate a google_storage.yml file in your config directory.


        Otherwise, configure your credentials:

        Example 1
        ---------

            GoogleStorage.configure do |config|
              config.from_yml '~/.your_google_secrets.yml'
            end

            client = GoogleStorage::Client.new

        Example 2
        ---------

            GoogleStorage.configure do |config|
              config.project_id     = ''
              config.client_id      = ''
              config.client_secret  = ''
              config.refresh_token  = ''
            end

            client = GoogleStorage::Client.new

        EOF
      end
    end
  end
end
