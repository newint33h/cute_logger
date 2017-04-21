require_relative 'test_helper'

# Test the functionality of CuteLogger gem
class CuteLoggerTest < Minitest::Test
  def setup
    File.delete('application.log') if File.exist?('application.log')

    CuteLogger.setup(
      filename: 'application.log',
      severity: 'DEBUG'
    )
  end

  def test_basic_logging
    log_info('LogA')
    log_warn { 'LogB' }
    log_info('A nasty error', id: '123')
    log_info('TestApp') { 'LogC' }
    log_debug('LogD')

    data = File.readlines('application.log')
    assert_match(/LogA/, data[1])
    assert_match(/LogB/, data[2])
    assert_match(/nasty/, data[3])
    assert_match(/TestApp/, data[4])
    assert_match(/LogD/, data[5])
  end

  def test_exception_logging
    log_info(StandardError.new('ErrorA'))
    begin
      # Triggering an error on purpose
      x + 1
      assert(false, 'This line should not run')
    rescue => error
      log_fatal('ErrorB', error)
    end

    data = File.readlines('application.log')
    assert_match(/ErrorA/, data[1])
    assert_match(/ErrorB/, data[2])
    assert_match(/test_exception_logging/, data[2])
  end

  def test_severity
    CuteLogger.severity = 'DEBUG'
    log_debug('TestA')
    log_error('TestB')

    CuteLogger.severity = 'WARN'
    log_debug('TestC') # Should not be logged
    log_info('TestD') # Should not be logged
    log_warn('TestE')

    data = File.readlines('application.log')
    assert_match(/TestA/, data[1])
    assert_match(/TestB/, data[2])
    assert_match(/TestE/, data[3])
  end

  def test_delayed_message
    CuteLogger.severity = 'WARN'

    time = Time.now.to_f
    log_info do
      sleep(1)
      'Done'
    end
    time = Time.now.to_f - time
    assert(time < 0.1, 'It should not evaluate the block if the severity is lower than required')

    time = Time.now.to_f
    log_error do
      sleep(1)
      'Done'
    end
    time = Time.now.to_f - time
    assert(time > 0.9, 'It should evaluate the block if the severity is at least the required')
  end
end
