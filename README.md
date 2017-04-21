# Cute Logger

This gem provides methods to log events in an easy way and accessible from anywhere.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cute_logger'
```

Or install it yourself as:

    $ gem install cute_logger

## Usage

To use this gem, require it into your application and optionally call the setup function to specify how the information should be stored.

```
CuteLogger.setup(
    filename: 'application.log',
    severity: 'INFO',
    shift_age: 7, # 7 days
    shift_size: 1024 * 1024 * 1024 # On gigabyte
)
```

To log something you could use the following formats:

```
log_info('Some text')
log_info(status: 'Working', value: '123')
log_debug(my_hash)
log_debug { 'Delayed evaluation' }
log_info('MyAppName') { 'Something to log' }
log_error('Error X', my_exception)
```

There is an utility script that helps to visualize the contents of the log. For example:

```
$ cat application.log | cute_log
$ tail -F application.log | cute_log
$ tail -F application.log | cute_log --json
$ grep "ERROR" application.log | cute_log --awesome
```

## Development

Run `rake test` to run the tests. 

