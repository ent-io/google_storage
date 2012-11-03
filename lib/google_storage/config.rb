module GoogleStorage
  class Config
    attr_accessor :log_stream, :log_level

    def initialize
      @log_stream = STDOUT
      @log_level  = GSync::Logger::FATAL
    end

  end
end
