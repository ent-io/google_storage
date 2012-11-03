require 'google_storage/client/request'
require 'google_storage/client/token'
require 'google_storage/client/bucket'
require 'google_storage/client/object'

module GoogleStorage

  ###
  #
  # ==Buckets & Objects
  #
  # Buckets are the basic containers that hold all of your data. There is only one Google namespace so every bucket across the
  # entire namespace has to be uniquely named so you may find that some bucket names have already been taken.
  #
  # You can have multiple folders and files within a bucket but you can't nest buckets inside of each other.
  #
  # Objects are basically just another name for Files, stored within Google Storage. Google Storage stores Objects in 2 parts,
  # holding both the object data and the object metadata. The metadata just holds key value data that describes the objects
  # properties.
  #
  # ==Predefined ACL's (Access Control Lists)
  #
  # ACL's allow you to control permission settings on Objects and Buckets
  #
  # Google Storage uses access control lists (ACLs) to manage object and bucket access.
  # ACLs are the mechanism you use to share objects with other users and allow other users to access your buckets and objects.
  #
  # At the moment, this google_storage gem only supports the following pre-defined ACL's. I'll add support for custom ACL's soon.
  #
  # project-private ::        Gives permission to the project team based on their roles. Anyone who is part of the team has READ permission and project owners and project editors have FULL_CONTROL permission. This is the default ACL that's applied when you create a bucket.
  # private ::                Gives the requester FULL_CONTROL permission for a bucket or object. This is the default ACL that's applied when you upload an object.
  # public-read ::            Gives the requester FULL_CONTROL permission and gives all anonymous users READ permission. When you apply this to an object, anyone on the Internet can read the object without authenticating.
  # public-read-write ::      Gives the requester FULL_CONTROL permission and gives all anonymous users READ and WRITE permission. This ACL applies only to buckets.
  # authenticated-read ::     Gives the requester FULL_CONTROL permission and gives all authenticated Google account holders READ permission.
  # bucket-owner-read ::      Gives the requester FULL_CONTROL permission and gives the bucket owner READ permission. This is used only with objects.
  # bucket-owner-full-control :: Gives the requester FULL_CONTROL permission and gives the bucket owner FULL_CONTROL permission. This is used only with objects.
  #
  ###
  
  class Client

    ###
    #
    # <b>You need to initialize a client to be able to make requests with the google_storage gem</b>
    #
    # Example:
    #
    # The following will look for google_storage.yml in your rails config directory
    #
    #   client = GoogleStorage::Client.new
    #
    # Otherwise you can pass in the path to the google_storage.yml
    #
    #   client = GoogleStorage::Client.new(:config_yml => 'C:/example_path/google_storage.yml')
    #
    # Other options:
    #
    #   :debug => true      <-- This will output all debug information from the HTTP requests to $stderr
    #
    ###
    def initialize(opts={})
      opts[:config] ? @config = opts[:config] : @config = GoogleStorage.config
      opts[:logger] ? @logger = opts[:logger] : @logger = GoogleStorage.logger
    end

    private
      
      def get(bucket, path, options={})
        http_request(Net::HTTP::Get, bucket, path, options)
      end
      
      def put(bucket, path, options={})
        http_request(Net::HTTP::Put, bucket, path, options)
      end
      
      def delete(bucket, path, options={})
        http_request(Net::HTTP::Delete, bucket, path, options)
      end
      
      def head(bucket, path, options={})
        http_request(Net::HTTP::Head, bucket, path, options)
      end

      def post_request(host, path, token, options={})
        params = options.delete(:params) || {}
        headers = options.delete(:headers) || {}
        params[:"client_id"]      = @config.client_id
        params[:"client_secret"]  = @config.client_secret
        params[:"grant_type"]     = options['grant_type']

        case options['grant_type']
          when 'authorization_code'
            params[:"code"]           = token
            params[:"redirect_uri"]   = @config.redirect_uri
          when 'refresh_token'
            params[:"refresh_token"]  = @config.refresh_token
        end

        construct_post_request(host, path, headers, params, options)
      end
      
      def http_request(method, bucket, path, options={})
        host = bucket ? "#{bucket}.#{@config.host}" : @config.host
        params = options.delete(:params) || {}
        headers = options.delete(:headers) || {}
        construct_http_request(host, path, method, headers, params, options)
      end
      
  end
end
