# = GSync::Logger
#
# Try for color support but fall back to Ruby's standard Logger 
# if `gem 'ansi'` is not available.
#
begin
  require 'ansi/logger'
  module GoogleStorage
    class Logger < ANSI::Logger ; end
  end
rescue LoadError
  require 'logger'
  module GoogleStorage
    class Logger < Logger ; end
  end
end
