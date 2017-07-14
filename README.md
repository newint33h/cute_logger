# Cute Logger

This gem provides accesible methods for doing the application logging in a simple manner.

## Description

Cute Logger provides globally accesible methods to do the logging. It also provides a log parser
command for easy view during development. The gem includes mechanisms for log rotation, improved
exception logging and nice formatted log viewing among many other features and best practices.

Please refer to the document [Better Logging](docs/better_logging.md) for a better understanding of the functionality of Cute Logger.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cute_logger'
```

And then execute:

```bash
$ bundle update
```

Or install it yourself as:

```bash
$ gem install cute_logger
```

## Usage

To use this gem, require it into your application and **optionally** call the setup function to specify how the log information should be stored, for how long and the minimum accepted severity.

```ruby
require 'cute_logger'

CuteLogger.setup(
    filename: 'application.log',
    severity: 'INFO',
    shift_age: 7, # 7 days
    shift_size: 1024 * 1024 * 1024 # On gigabyte
)
```

The previous values are actually the **default** ones if the `setup` method is not explicitly called.

To log something you could use the following formats:

```ruby
log_info('Some event')
log_info('Some event', status: 'Working', value: '123')
log_debug(my_hash)
log_debug { 'Delayed evaluation' }
log_info('MyAppName') { 'Something to log' }
log_error('Error X', my_exception)
```

Hashes and arrays are logged as JSON format:

```ruby
my_array = {a: 'letter A', b: [1, 2, 3]}
log_info('Useful data', data: my_array)
```

Results in an entry like the following:

```bash
2017-04-21 22:12:56 -0500,INFO,a801,3ff44803f9f4,Object,["Useful data",{"data":{"a":"letter A","b":["1","2","3"]}}]
```

To view the log in a cute format (awesome_print):

```bash
$ cat application.log | cute_log
```

```bash
2017-04-21 22:12:56 -0500 INFO 43009-3ff44803f9f4 (Object)
[
    [0] "Useful data",
    [1] {
        "data" => {
            "a" => "letter A",
            "b" => [
                [0] "1",
                [1] "2",
                [2] "3"
            ]
        }
    }
]
```

Exceptions have their own formatting:

```ruby
begin
  nil.hello
rescue => error
  log_error('Error during X event', error: error)
end
```

```bash
$ cat application.log | cute_log
```

```ruby
2017-04-21 22:18:28 -0500 ERROR 44691-3fe53703fa14 (Object)
[
    [0] "Error during X event",
    [1] {
        "error" => {
                "class" => "NoMethodError",
              "message" => "undefined method `hello' for nil:NilClass",
            "backtrace" => [
                [ 0] "(irb):3:in `irb_binding'",
                [ 1] "/Users/johndoe/.rbenv/versions/2.3.1/lib/ruby/2.3.0/irb/workspace.rb:87:in `eval'",
                [ 2] "/Users/johndoe/.rbenv/versions/2.3.1/lib/ruby/2.3.0/irb/workspace.rb:87:in `evaluate'",
                [ 3] "/Users/johndoe/.rbenv/versions/2.3.1/lib/ruby/2.3.0/irb/context.rb:380:in `evaluate'",
                [ 4] "/Users/johndoe/.rbenv/versions/2.3.1/lib/ruby/2.3.0/irb.rb:489:in `block (2 levels) in eval_input'",
               ... log intentionally cutted down for better legibility  ...
            ]
        }
    }
]
```


The `cute_log` script utility helps to visualize the contents of the log. For example:

```
# View the all the logs
$ cat application.log | cute_log

# View the logs in real time with awesome print
$ tail -F application.log | cute_log

# View the logs in real time with JSON pretty_generate
$ tail -F application.log | cute_log --json

# View all errors with awesome print (The switch --awesome is the default anyway)
$ grep "ERROR" application.log | cute_log --awesome

# View all errors of ID 223
$ grep "ERROR" application.log | grep "ID000233" | cute_log

# View all warns from Jaunuary 2017
$ grep "WARN" application.log | grep "2017-01" | cute_log
```

### Using environment variables

It is possible to configure the logging settings via environment variables. For example:

```bash
export CUTE_LOGGER_FILENAME=archive.log
export CUTE_LOGGER_SHIFT_AGE=7
export CUTE_LOGGER_SHIFT_SIZE=1000000
export CUTE_LOGGER_SEVERITY=DEBUG
```

This is the recommended way to configuring the logger settings.

## Development

Run `rake test` to run the tests. 

