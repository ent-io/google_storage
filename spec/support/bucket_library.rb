require 'yaml'
require 'erb'
require 'uuid'
require 'google_storage'

class BucketLibrary
  class << self
    def use(key, opt={})
      self.config.buckets[key] || self.config.new_bucket!(key, opt)
    end

    def config
      @config ||= Config.new
    end

    def configure(&block)
      block.call self.config
    end
  end

  class Config
    attr_accessor :yaml_path
    attr_accessor :buckets
    attr_accessor :gs_client

    def save
      File.open(self.yaml_path, 'w') { |file| file.write(self.buckets.to_yaml) }
    end

    def buckets
      @buckets ||= reload_yaml
    end

    def reload_yaml!
      @buckets = reload_yaml
    end

    def new_bucket!(key, opt={})
      b = new_bucket(key, opt)
      uuid = b[key]['uuid']
      self.buckets = b.merge self.buckets
      return self.buckets[key] if process_options(uuid, opt) && self.save
      false
    end

    private
    def reload_yaml
      File.open(self.yaml_path, 'w') {|f| f.write('')} unless File.exists?(self.yaml_path)
      YAML.load(File.read(self.yaml_path)) || {}
    end

    def new_bucket(key, opt={})
      self.reload_yaml!
      raise "`#{key}` already exists!" if self.buckets[key]
      {key => {'uuid'=>"gs-gem-test-suite-#{uuid.generate}"}.merge(opt) }
    end

    def uuid
      @uuid ||= UUID.new
    end

    def process_options(bucket_name, opts)
      method      = opts[:method]
      bucket_opts = opts[:method_opt] || {}

      return perform_client(method, bucket_name, bucket_opts) if method
      true
    end

    def perform_client(method, bucket_name, bucket_opts)
      self.gs_client.send(method, bucket_name, bucket_opts)
    end
  end
end
