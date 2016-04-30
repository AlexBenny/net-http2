[![Build Status](https://travis-ci.org/ostinelli/net-http2.svg?branch=master)](https://travis-ci.org/ostinelli/net-http2)
[![Code Climate](https://codeclimate.com/github/ostinelli/net-http2/badges/gpa.svg)](https://codeclimate.com/github/ostinelli/net-http2)

# NetHttp2

NetHttp2 is an HTTP/2 client for Ruby.

## Installation
Just install the gem:

```
$ gem install net-http2
```

Or add it to your Gemfile:

```ruby
gem 'net-http2'
```

## Usage
NetHttp2 can perform sync and async calls. Sync calls are very similar to the HTTP/1 calls, while async calls take advantage of the streaming properties of HTTP/2.

To perform a sync call:
```ruby
require 'net-http2'

# create a client
client = NetHttp2::Client.new("http://106.186.112.116")

# send request
response = client.call(:get, '/')

# read the response
response.ok?      # => true
response.status   # => '200'
response.headers  # => {":status"=>"200"}
response.body     # => "A body"

# close the connection
client.close
```

To perform an async call:
```ruby
require 'net-http2'

# create a client
client = NetHttp2::Client.new("http://106.186.112.116")

# prepare request
request = client.prepare_request(:get, '/')
request.on(:headers) { |headers| p headers }
request.on(:body_chunk) { |chunk| p chunk }
request.on(:close) { puts "request completed!" }

# send
client.call_async(request)

# We need to wait for the callbacks to be triggered, so here's a quick and dirty fix for this example.
# In real life, if you are using async requests so you probably have a running loop that keeps your program alive.
sleep 5

# close the connection
client.close
```

## Objects

### `NetHttp2::Client`

#### Methods

 * **new(url, options={})** → **`NetHttp2::Client`**

 Returns a new client. `url` is a `string` such as https://localhost:443.
 The only current option is `:ssl_context`, in case the url has an https scheme and you want your SSL client to use a custom context.

 To create a new client:
 ```ruby
 NetHttp2::Client.new("http://106.186.112.116")
 ```

 To create a new client with a custom SSL context:
 ```ruby
 certificate = File.read("cert.pem")
 ctx         = OpenSSL::SSL::SSLContext.new
 ctx.key     = OpenSSL::PKey::RSA.new(certificate, "cert_password")
 ctx.cert    = OpenSSL::X509::Certificate.new(certificate)

 NetHttp2::Client.new("http://106.186.112.116", ssl_context: ctx)
 ```

 * **uri** → **`URI`**

 Returns the URI of the endpoint.

##### Blocking calls
These behave similarly to HTTP/1 calls.

 * **call(method, path, options={})** → **`NetHttp2::Response` or `nil`**

 Sends a request. Returns `nil` in case a timeout occurs.

 `method` is a symbol that specifies the `:method` header (`:get`, `:post`, `:put`, `:patch`, `:delete`, `:options`). The body and the headers of the request can be specified in the options, together with the timeout.

 ```ruby
 response_1 = client.call(:get, '/path1')
 response_2 = client.call(:get, '/path2', headers: { 'x-custom' => 'custom' })
 response_3 = client.call(:post '/path3', body: "the request body", timeout: 1)
 ```


##### Non-blocking calls
The real benefit of HTTP/2 is being able to receive body and header streams. Instead of buffering the whole response, you might want to react immediately upon receiving those streams. This is what non-blocking calls are for.

 * **prepare_request(method, path, options={})** → **`NetHttp2::Request`**

 Prepares an async request. Arguments are the same as the `call` method, with the difference that the `:timeout` option will be ignored. In an async call, you will need to write your own logic for timeouts.

 ```ruby
 request = client.prepare_request(:get, '/path', headers: { 'x-custom-header' => 'custom' })
 ```

 * **on(event, &block)** 

 Allows to set a callback for the request. Available events are:
 
  * `:headers`: triggered when headers are received (called once).
  * `:body_chunk`: triggered when body chunks are received (may be called multiple times).
  * `:close`: triggered when the request has been completed (called once).

 Even if NetHttp2 is thread-safe, the async callbacks will be executed in a different thread, so ensure that your code in the callbacks is thread-safe.

 ```ruby
 request.on(:headers) { |headers| p headers }
 request.on(:body_chunk) { |chunk| p chunk }
 request.on(:close) { puts "request completed!" }
 ```

 * **call_async(request)**

 Calls the server with the async request.


### `NetHttp2::Request`

#### Methods

 * **method** → **`symbol`**
 
 The request's method.

 * **uri** → **`URI`**
 
 The request's URI.

 * **path** → **`string`**
 
 The request's path.

 * **body** → **`string`**
 
 The request's body.

 * **timeout** → **`integer`**
 
 The request's timeout.


### `NetHttp2::Response`

#### Methods

 * **ok?** → **`boolean`**

 Returns if the request was successful.

 * **headers** → **`hash`**

 Returns a Hash containing the Headers of the response.

 * **status** → **`string`**

 Returns the status code.

 * **body** → **`string`**

 Returns the RAW body of the response.


## Thread-Safety
NetHttp2 is thread-safe.

## Contributing
So you want to contribute? That's great! Please follow the guidelines below. It will make it easier to get merged in.

Before implementing a new feature, please submit a ticket to discuss what you intend to do. Your feature might already be in the works, or an alternative implementation might have already been discussed.

Do not commit to master in your fork. Provide a clean branch without merge commits. Every pull request should have its own topic branch. In this way, every additional adjustments to the original pull request might be done easily, and squashed with `git rebase -i`. The updated branch will be visible in the same pull request, so there will be no need to open new pull requests when there are changes to be applied.

Ensure to include proper testing. To run tests you simply have to be in the project's root directory and run:

```bash
$ rake
```
