require 'cute_logger/version'
require 'logger'
require 'json'
require 'awesome_print'
require 'utf8_converter'
require 'cute_logger/default_logger'

##
# This module defines the functionality the the CuteLogger gem
module CuteLogger
  class << self
    def setup(settings = {})
      @logger = DefaultLogger.new(
        filename:    ENV['CUTE_LOGGER_FILENAME']    || settings[:filename],
        shift_age:   ENV['CUTE_LOGGER_SHIFT_AGE']   || settings[:shift_age],
        shift_size:  ENV['CUTE_LOGGER_SHIFT_SIZE']  || settings[:shift_size],
        date_format: ENV['CUTE_LOGGER_DATE_FORMAT'] || settings[:date_format],
        log_level:   ENV['CUTE_LOGGER_LOG_LEVEL']   || settings[:log_level]
      )
    end

    def severity=(text)
      logger.sev_threshold = text
    end

    def kick_logger!(logger)
      @logger = logger
    end

    def log(severity, classname, args)
      if block_given?
        logger.log(severity, classname, args) { yield }
      else
        logger.log(severity, classname, args)
      end
    end

    def logger
      setup unless defined?(@logger)
      @logger
    end

    def sev_threshold(severity)
      @loger.sev_threshold(severity)
    end
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

# nil values should be logged as nulls
class NilClass
  def to_log_format
    nil
  end
end
