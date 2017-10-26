# frozen_string_literal: true

module CuteLogger
  class LogInterface
    attr_reader :sev_threshold
    def initialize(setup)
      @setup = setup
    end

    def sev_threshold=(_threshold)
      raise(NoMethodError, 'Undefined Method `sev_threshold=`')
    end

    def log(_severity, _message, _module)
      raise(NoMethodError, 'Undefined Method `log`')
    end
  end
end
