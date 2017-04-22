# Better Logging
One of the main purposes of logging is to be able to debug an application in case of a system failure. After thinking for a while about how we should log all the information to make it effective for debugging, I ended up with a bunch of rules we had to implement in the new gem to have quality logs. Some of such rules are:

* To be integrable with third party log viewers,
* To be multithreaded,
* To be Searchable searchable and
* To have meaningful output.

The main goal is to debug an application in case of error. However, there are many other cases to consider when logging, like how the application can be audited to determine if someone is hacking the system, or responding questions of how many times certain event happen with specific conditions. Or simply determine what changes were made by some employee. In any case, writing the logs in the right format can help you in the future to answer all these questions and more.

## Rules for a good logging system
Let's look at a couple of good practices that can help us create a good logging system. These are a set of rules that we implemented in our logging gem.

### One line logs
Logs that are one line long are perfect for being searched using console commands like `grep` without having to get the lines after and before to understand the log meaning. It is also easier for a log parser to determine where the log starts and ends. The line length can be any size, but one line.

```
# The next log is in one line, no matter the if log data contains multiple lines. Lines are "squashed" into a single log line
2016-09-11 14:04:51 -0500,ERROR,17083,3ffbceb4f99c,MyApp,["Something happen",{"result":"Some large text\nmultiline"}]
```

Even if the log content has new line elements by the nature of the data, these are escaped to encapsulate the full log entry in one line.

### Encoded User Input
All data that comes from the user must be encoded to avoid messing with special characters. A good format option for encoding the user input is using JSON, because this format does not use RETURNs and escapes special characters. It is important to ensure that the logging function encodes the logs in one charset. UTF-8 is very good choice for general purpose logs, however you should choose the encoding that best fits your needs.

```
# The next log contains carriage return characters encoded in JSON
2016-09-11 14:04:51 -0500,ERROR,17083,3ffbceb4f99c,MyApp,["Something happen",{"result":"Some large text\nmultiline\nline 3"}]
```

### Time and Timezone
Always log the time in UTC or ensure that your logs contain the correct timezone, and leave the job of displaying the time in local timezone to the tool in charge of visualizing the logs. Having milliseconds in the log's time is very useful to debug logs generated in the same server, unless you have all your servers in sync. As a suggestion, synchronize your servers with a NTP daemon.

```
# The next log contains the time encoded in UNIX timestamp format
1473620691361,ERROR,17083,3ffbceb4f99c,MyApp,["Something happen",{"result":"Some large text\nmultiline"}]
```

### Boilerplate log fields
There are some fields that always should be present in any log, like the time, severity, process ID, thread ID, and application identifier. The time and severity fields are obvious, but the process ID and thread ID are not. The process ID can identify the logs of an specific application if you are centralizing logs of many servers. Since the process ID values are limited to a short range and can collide among different servers, it is sometimes useful to add an unique machine identifier to the log. The thread ID is useful in any multi-threaded application to identify logs of a thread. In web development this is more important because with this field you can filter the logs corresponding to a single request. And finally the application identifier field is useful for filtering logs in a centralized log database.

All this fields should be abstracted in a log function that the application uses as the default log method. With this approach, the task of adding logs with all this information will be very simple for users o the logging gem.

```
# Time, Severity, Process ID, Thread ID, Application Tag, Message in JSON
2016-09-29 16:04:51 -0500,ERROR,17083,3ffbceb4f99c,Class,["Something happen",{"result":"Some large text\nmultiline"}]
```


## Rules for effective logging
Having a gem that implements the mentioned features is not even half of the way to have quality logs. As a developer, we need to follow some rules about how to write logs properly.

### Logging enough information
A good log must have all the variables needed to read the code and understand what path the execution took. That way, the programmer can reproduce the execution path by reading the log.

```ruby
def do_something(id, index, value_x)  
  random_value = rand(100)
  …
  # Logging all the variables to ensure an easy analysis in the future
  log_debug('Something happen', id: id, index: index, value_x: value_x, random_value: random_value)
  ...
end
```
  
### Multilevel error logs
A good code is divided in different layers that have a specific function. Logging the same log in different layers is a good practice as long as each layer is tagged properly and the information is not duplicated. For example, a service that consults via web service the actual exchange rate of dollars to another currency may have a connection timeout error, and that should log the request exception with the parameters needed to reproduce the error. But it's also possible to create another log entry in an upper layer to indicate that the operation to check the current exchange rate failed. Moreover, it is possible to generate a third log entry in the uppermost layer indicating that the action requested by the user failed. Each layer knows the context in which the execution is taking place, and that knowledge should be reflected in logs.

For the sake of simplicity, I wrote pseudocode with mixed Javascript and Ruby:

```javascript
function on_click(button) {  
  value_a = $("value1Input").val();
  value_b = $("value2Input").val();
  x = business_rule(value_a, value_b); # Function to get the result from the backend
  if (x.error) {
    # The only error handling to do here is to notify the user about the problem
    alert(x.error);
  } else {
    $("result").val(x.result);
  }
}
```

```ruby
def business_rule(value_a, value_ b)  
  try
    a = query_service(value_a)
    return a / value_b
  catch DivisionByZeroException
    # No log required because we know how to handle it
    return a # Business rule dictates that when value_b is zero, the default is 1.
  catch NotFoundException
    return 0 # Business rule dictates that if value_a is not found in the service, return 0
  end
end

def query_service(value)  
  try
    result = HTTP.request(url, data: {value: value}) # The service returns 404 if the value is not found and that raises an NotFoundException
    return result.body
  catch TimeoutException
    # We need to log, probably if we see many warnings we can decide to switch to another provider
    log_warn('Connection timeout with service X', value: value)
    redo
  end
end  
```

### Protect confidential information
Confidential information must NOT be logged. Instead of logging sensitive information, we must log IDs that a person with authority can relate with the real data. The log registry must be confidential and should be used only by a limited number of people. Avoiding logging confidential information is an always welcome protection to guarantee the privacy of clients and reduce the risk of a data breach.

```ruby
# Wrong
log_debug('User balance changed', name: data[:name], account_balance: data[:account_balance]) 

# Right
log_debug('User balance changed', user_id: data[:user_id], account_balance: data[:account_balance])  
```

### Logs everywhere
All paths of the code must have a log entry, enough to tell a story of the execution of the application. Very general paths must be logged using INFO severity, and very deep and detailed paths must be logged using DEBUG severity. If a code has a know issue that may affect the users, a log with WARN severity is a good way to keep that issue in the aim.

```ruby
def do_something_important(x, y)  
  # A log to indicate that an important action has started
  log_info('Some important', x: x, y: y)

  if x + y < 0
    # Warn about this special case that may cause problems
    log_warn('Special case of something', sum: x + y)
  end

  total = (x + y) * CONSTANT_Z + random(5) # A complex formula
  # Log detailed information about this complex formula for debugging
  log_debug("Result of complex formula of something", total: total)

rescue => error  
  # If something unexpected happend, log it
  log_error('Error executing something', error: error)
end
```
  
### Global Exception Handler
A global exception handler must be defined to log all exceptions, and this is a log with FATAL severity. This ensures that any problem not foreseen can be logged.

```ruby
# This will catch all the exceptions and generate a fatal severity log.
def global_exeception_handler(error)  
  log_fatal("Fatal error", error: error)
end
```

### Countable logs
A good log is something that can be counted. For example, the message that logs the user sign in should only contain "User signin" without any other information in the message. This allows a simple parser to split the log using commas and look for the exact message without worrying about special characters submitted by the user and affecting the parsing. This way, it is possible to generate metrics counting logs. Any additional information that needs to be logged can be added in an additional log fields.

```ruby
# Wrong
log_info("User login: #{user_id}")

# Right
log_info('User login', user_id: user_id)
```

### Additional log fields
Almost all logs have a context of execution in which there is at least one object ID that is the protagonist of all the action. That should be logged as an additional field in the log and NOT as part of the message. 
There may be additional fields that can be considered essential and must always be logged. For example, if an application can only work with a signed user, the log function must always log the signed user by default. Sometimes the application may have very well defined responsibilities and adding a tag may be very useful. For example, an application may want to differentiate among network operations and business rules. The tag NETWORK may be used for logs related to the code that establish the connection with a service, and the tag BUSINESS may be used to log information about the logic in the application.

```ruby
# Using tags to group logs and simplify future searches
log_warn('Network failure', tag: 'NETWORK', ...)  
log_warn('Calculating loan interest', tag: 'BUSINESS' loan: loan_id, interest: loan_interest)
```
  
### Log chaining
Design logs to be chainable, in other words, that one log can lead you to identify a bunch of other logs. For example, If you want to know what happened with the request of the person X, first search for the log message 'User signin' of user 'X'. That log must have a thread ID that should allow you to search for all the actions that happened during the request. This way, it is not needed to include the user's name in all logs.

```ruby
log_info('User login', user_id: user_id, name: user_name)
```

```bash
$ grep "John Doe" application.log

2016-09-11 14:04:51 -0500,INFO,17083,3ffbceb4f99c,MyApp,["User login",{"user_id":"2123","name":"John Doe"}]

$ grep "3ffbceb4f99c" application.log

2016-09-11 14:04:51 -0500,INFO,17083,3ffbceb4f99c,MyApp,["Load permissions",{"permissions":"RW"}]  
2016-09-11 14:04:51 -0500,INFO,17083,3ffbceb4f99c,MyApp,["Load Preferences",{"preferences":{"font-size":"34","background-color":"green"}}]  
```

### Rethrow vs throw new exceptions
There is a very thin line in between when to throw a new exception and when rethrow the last exception. Rethrow preserves the original message and line code of where the error raised while a new exception may contain different information depending of the context. Both possibilities are valid only when the actual code does not know how to handle the error properly and we need to transfer the responsibility to another part of the application.

Throwing new exception is useful when actual layer has additional information that may be useful for future purposes. Also is a good practice to throw new exception on each application layer, so a person interested in the business logic can filter for the error messages in that layer and have a meaningful error log.

Rethrowing the same exception is useful when you don't know how to handle the exception. For example, a code that query a service may handle a connection timeout exception by trying again, but a wrong credentials exception will require to rethrow the exception hoping that an upper layer knows how to handle it. When throwing a new exception, logging the old exception is a must, and when rethrowing the last exception the log is not needed.

Another approach is to always throw new exceptions nesting the previous exception in a new one. This allows to see how the exception bubbled up preserving the original error message and how this exception affects the different layers.

```ruby
# If is important, log the parameters in the error
def a_method(x, y)  
  try
    do_something_dangerous()
  catch NiceAndExpectedError => error
    # no log required, this was expected
    return DEFAULT_VALUE
  catch CustomError => error
    # An error we know how to handle
    log_warn('Error happen', x: x, y: y, error: error)
    return workaround_method(x, y)
  catch UnexpectedError => error
    # We don't know how to handle this, so notify the user and do nothing
    log_error('Error happen', x: x, y: y, error: error)
    notify_user(error) # This is not the right place to do this, but you get the idea
    abort() # Kill the thread/request, or simply ensure to do nothing after finishing this method
  catch SpecialCaseError => error
    # Log parameters for this special case and throw a new exception more manageable to the upper layer
    log_warn('Special case triggered', x: x, y: y, error: error)
    raise AnotherError.new('Error doing something')
  catch StandardError => error
    # Rethrowing the error, someone else's problem. (Is the same as not having this catch)
    raise error
  end
end
```

### Error resolution
Many errors can't be resolved by the application itself and require special attention. In these cases, the only solution is to inform the user about the problem and log the error with the proper severity. Some other errors are solved as time passes and some when the services recover itself, and in that case, the solution is to inform the user to try again later. In those examples, the error resolution is handled in the UI layer, and there is the place to catch the exception and log the error.

```ruby
get '/users' do  
  try
    users = Database.get_users()
  catch CustomError => error
    log_error('Failed to retrieve users', error: error)
    json_response({"status": "error", "message": error.message}) # Let the front end handle this
  end
end  
```

### Common ways to group and read logs
It is important to keep in mind the usual ways of reading logs, so the programmers can write their logs thinking in how effective they will be.

**Chronological** - Reading the logs sorted by time is the most common way of understanding what is happening, however this may be very hard to read if the logs are mixed with different threads executing the same actions.

**Severity** - This is useful if you want to view the errors in the system to pick one and solve it. But only useful for FATAL and ERROR severity.

**Thread ID** - This is very useful to read an history of one execution flow of an application.

**Tag** - Useful to only show logs related to an specific area or application layer.

**User** - Very useful to trace what was the user doing. This helps a lot to detect corner cases that the user triggers due their uncommon behaviour with the application.

**ID** - Using custom IDs to identify a resource can help you filter all the logs that has something to do with the given ID.

### Log severities
Identify the proper severity for the logs is essential to have an effective problem identification.

**FATAL** is when the immediate intervention is needed and the system can't continue running. (This should raise the alarms somewhere in your office).
**ERROR** is when something needs a fix because the system is failing and the information may be losing.
**WARN** is when there is potentially an error that may affect some the system. Also a warning could be issued when there is technical debt or something that is not fully implemented.
**INFO** is when you need to inform about an important event that is useful to determinate the lifecycle of the execution.
**DEBUG** is basically anything the programmer want to log to have better visibility of the values of the application in some part of the code.

## Summary
A lot can be said of how to treat logging in an application, but the idea here was to shed some light on tips and techniques that I have found to be useful to cope with the ever growing amount of information that is being produced by nowadays production systems.

Logging is a difficult task. We feel there is no correct or incorrect approach to logging, and how to implement it correctly depends on the needs of your system. Nevertheless we hope that this brief article provides some useful ideas.

This gem was inspired by a private gem developed at kueski.com, aswell this article which was slightly modified to be released in the public domain. Please refer to the original article at: 
[http://nerds.kueski.com/better-logging/](http://nerds.kueski.com/better-logging/)
