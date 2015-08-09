# Librato::Client

Librato API Client for for Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'librato-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install librato-client

## Usage

* [Librato API Documentation — Librato API Documentation](http://dev.librato.com/v1)
* [RESOURCES](https://github.com/winebarrel/librato-client/blob/master/lib/librato/client/client.rb#L11)
* [SUB_RESOURCES](https://github.com/winebarrel/librato-client/blob/master/lib/librato/client/resource.rb#L2)

### Create client

```ruby
require 'librato/client'

client = Librato::Client.new(
  user: '...',
  token: '...'
  # [, Other Options]
)
```

* Other Options
  * `:debug`
  * `:expand_pageable_resources`
  * `:raise_error_if_not_exist`
  * `:wrap_faraday_client_error`
  * `:default_alerts_version`

### List metrics

```ruby
client.metrics.get
#=> [{"name"=>"login-delay",
#     "display_name"=>nil,
#     "type"=>"gauge",
#     "attributes"=>{"created_by_ua"=>"Ruby Librato Client 0.1.0"},
#     "description"=>nil,
#     "period"=>nil,
#     "source_lag"=>nil}]
```

### Show a metric

```ruby
client.metrics("login-delay").get
#=> {"name"=>"login-delay",
#    "display_name"=>nil,
#    "type"=>"gauge",
#    "attributes"=>{"created_by_ua"=>"Ruby Librato Client 0.1.0"},
#    "description"=>nil,
#    "period"=>nil,
#    "source_lag"=>nil}
```

```ruby
client.metrics("login-delay").get(
  compose: 'series("*")',
  start_time: 1439108273,
  resolution: 300
)

#=> {"measurements"=>
#     {"foo.bar.com"=>
#       [{"measure_time"=>1439108400,
#         "value"=>3.5,
#         "count"=>5,
#         "min"=>3.5,
#         "max"=>3.5,
#         "sum"=>17.5,
#         "sum_squares"=>61.25},
#         ...
```

see [Composite Metrics Language Specification – Customer Feedback & Support for Librato](http://support.metrics.librato.com/knowledgebase/articles/337431-composite-metrics-language-specification)

### Create a metric

```ruby
client.metrics.post({
  gauges: {
    "login-delay" => {
      value: 3.5,
      source: "foo.bar.com"
    }
  }
})
```

### Update a metric

```ruby
client.metrics("login-delay").put(display_name: "Login delay")
```

### Delete a metrics

```ruby
client.metrics("login-delay").delete
```

### List spaces

```ruby
client.spaces.get
```

### Show a space

```ruby
client.spaces(12345).get
```

### Create a space

```ruby
client.spaces.post(name: "My Space")
```

### List charts

```ruby
client.spaces(12345).charts.get
```

### Show a chart

```ruby
client.spaces(12345).charts(6789).get
```

### Create a chart

```ruby
client.spaces(77109).charts.post(
  name: "My Chart",
  type: "line",
  streams: [...]
)
```
