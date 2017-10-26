# frozen_string_literal: true

require_relative 'log_interface'

module CuteLogger
  ##
  # Implements LogInterface ussing Ruby Logger
  class DefaultLogger < LogInterface
    SEVERITY = {
      'DEBUG' => Logger::DEBUG,
      'INFO'  => Logger::INFO,
      'WARN'  => Logger::WARN,
      'ERROR' => Logger::ERROR,
      'FATAL' => Logger::FATAL
    }.freeze

    ONE_GIGABYTE = 1024 * 1024 * 1024
    DEFAULT_PATH = 'application.log'
    DEFAULT_SHIFT_TIME = 7
    DEFAULT_SEVERITY = 'INFO'
    DEFAULT_DATE_FORMAT = '%Y-%m-%d %H:%M:%S'

    def initialize(settings)
      @logger = Logger.new(
        settings[:filename] || DEFAULT_PATH,
        settings[:shift_age] || DEFAULT_SHIFT_TIME,
        settings[:shift_size] || ONE_GIGABYTE
      )
      @sev_threshold = severity(settings[:log_level] || DEFAULT_SEVERITY)
      configure_format
      configure_date_format(settings[:date_format] || DEFAULT_DATE_FORMAT)
    end

    def sev_threshold=(severity)
      @logger.sev_threshold = severity(severity)
    end

    def log(severity, classname, args)
      if block_given?
        module_name = (args.first || classname)
        @logger.add(severity, nil, module_name) { format_message(yield) }
      else
        @logger.add(severity, format_message(args), classname)
      end
    end

    private

    def severity(text)
      severity = SEVERITY[text.upcase]
      raise("Unknown logger severity: #{text}") if severity.nil?
      severity
    end

    def format_message(message)
      if message.is_a?(Array) && message.count == 1
        message.first.to_log_format.to_json
      else
        message.to_log_format.to_json
      end
    end

    def configure_date_format(format_string)
      @logger.datetime_format = format_string
    end

    def configure_format
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "#{datetime},#{severity},#{Process.pid.to_s(16)}," \
        "#{Thread.current.object_id.to_s(16)},#{progname},#{msg}\n"
      end
    end
  end
end
