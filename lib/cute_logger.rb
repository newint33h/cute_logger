require 'cute_logger/version'
require 'logger'
require 'json'
require 'awesome_print'
require 'utf8_converter'

# This module defines the functionality the the CuteLogger gem
module CuteLogger
  SEVERITY = {
    'DEBUG' => Logger::DEBUG,
    'INFO'  => Logger::INFO,
    'WARN'  => Logger::WARN,
    'ERROR' => Logger::ERROR,
    'FATAL' => Logger::FATAL
  }

  def self.setup(settings = {})
    @logger = Logger.new(
      ENV['CUTE_LOGGER_FILENAME'] || settings[:filename] || 'application.log',
      ENV['CUTE_LOGGER_SHIFT_AGE'] || settings[:shift_age] || 7,
      ENV['CUTE_LOGGER_SHIFT_SIZE'] || settings[:shift_size] || 1024 * 1024 * 1024 # One gigabyte
    )
    @logger.sev_threshold = severity(ENV['CUTE_LOGGER_SEVERITY'] || settings[:severity])
    @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime},#{severity},#{Process.pid.to_s(16)},#{Thread.current.object_id.to_s(16)}" \
      ",#{progname},#{msg}\n"
    end

    @signals_read, @signals_write = IO.pipe
  
    ['HUP', 'USR1'].each do |signal|
      Signal.trap(signal) {@signals_write.puts(true)}
    end
    
    Thread.new do
      while readable_io = IO.select([@signals_read])
          readable_io.first[0].gets
          @logger.reopen
      end
    end  
  end

  def self.severity=(text)
    @logger.sev_threshold = severity(text)
  end

  def self.severity(text)
    return Logger::INFO unless text
    fail("Unknown logger severity: #{text}") unless SEVERITY[text.upcase]
    SEVERITY[text.upcase]
  end

  def self.format_message(message)
    if message.is_a?(Array) && message.count == 1
      message.first.to_log_format.to_json
    else
      message.to_log_format.to_json
    end
  end

  def self.log(severity, classname, args, &block)
    setup unless defined?(@logger)
    if block_given?
      @logger.add(severity, nil, (args.first || classname)) { format_message(block.call) }
    else
      @logger.add(severity, format_message(args), classname)
    end
  end

  def self.logger
    setup unless defined?(@logger)
    @logger
  end

  # Methods to be included as part of the Object class
  module GeneralMethods
    def log_debug(*args, &block)
      CuteLogger.log(Logger::DEBUG, self.class, args, &block)
    end

    def log_info(*args, &block)
      CuteLogger.log(Logger::INFO, self.class, args, &block)
    end

    def log_warn(*args, &block)
      CuteLogger.log(Logger::WARN, self.class, args, &block)
    end

    def log_error(*args, &block)
      CuteLogger.log(Logger::ERROR, self.class, args, &block)
    end

    def log_fatal(*args, &block)
      CuteLogger.log(Logger::FATAL, self.class, args, &block)
    end

    def to_log_format
      to_s.to_utf8
    end
  end
end

# Add global logging methods to all scopes
class Object
  include CuteLogger::GeneralMethods
end

# Specify and special way of logging exceptions
class Exception
  def to_log_format
    { class: self.class, message: message, backtrace: backtrace }
  end
end

# Specify that the arrays must traverse all the children to format the log
class Array
  def to_log_format
    map(&:to_log_format)
  end
end

# Specify that the hash must traverse all the children to format the log
class Hash
  def to_log_format
    Hash[map { |key, value| [key.to_log_format, value.to_log_format] }]
  end
end
