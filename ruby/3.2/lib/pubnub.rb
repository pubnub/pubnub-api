## www.pubnub.com - PubNub realtime push service in the cloud.
## http://www.pubnub.com/blog/ruby-push-api - Ruby Push API Blog

## PubNub Real Time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.1 Real-time Push Cloud API
## -----------------------------------

## including required libraries
require 'openssl'
require 'base64'
require 'open-uri'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'pp'
require 'rubygems'
require 'securerandom'
require 'digest'
require 'pubnub_crypto'
require 'pubnub_request'

require 'eventmachine'

class Pubnub

  class PublishError < RuntimeError;
  end
  class SubscribeError < RuntimeError;
  end
  class InitError < RuntimeError;
  end

  attr_accessor :publish_key, :subscribe_key, :secret_key, :cipher_key, :ssl, :channel, :origin

  MAX_RETRIES = 3
  ORIGIN_HOST = 'pubsub.pubnub.com'

  def initialize(*args)

    if args.size == 5 # passing in named parameters

      @publish_key = args[0].to_s
      @subscribe_key = args[1].to_s
      @secret_key = args[2].to_s
      @cipher_key = args[3].to_s
      @ssl = args[4]

    elsif args.size == 1 && args[0].class == Hash # passing in an options hash

      options_hash = HashWithIndifferentAccess.new(args[0])
      @publish_key = options_hash[:publish_key].blank? ? nil : options_hash[:publish_key].to_s
      @subscribe_key = options_hash[:subscribe_key].blank? ? nil : options_hash[:subscribe_key].to_s
      @secret_key = options_hash[:secret_key].blank? ? nil : options_hash[:secret_key].to_s
      @cipher_key = options_hash[:cipher_key].blank? ? nil : options_hash[:cipher_key].to_s
      @ssl = options_hash[:ssl].blank? ? false : true

    else
      raise(InitError, "Initialize with either a hash of options, or exactly 5 named parameters.")
    end

    verify_init
  end

  def verify_init
    # publish_key and cipher_key are both optional.
    Rails.logger.debug("verifying configuration...")
    @subscribe_key.blank? ? raise(InitError, "subscribe_key is a mandatory parameter.") : Rails.logger.debug("subscribe_key set to #{@subscribe_key}")

    init_logger
  end

  def init_logger
    Rails.logger.debug(@publish_key.present? ? "publish_key set to #{@publish_key}" : "publish_key not set.")
    Rails.logger.debug(@cipher_key.present? ? "cipher_key set to #{@cipher_key}. AES encryption enabled." : "cipher_key not set. AES encryption disabled.")
    Rails.logger.debug(@secret_key.present? ? "secret_key set to #{@secret_key}. HMAC message signing enabled." : "secret_key not set. HMAC signing disabled.")
    Rails.logger.debug(@ssl.present? ? "ssl is enabled." : "ssl is disabled.")
  end

  def publish(options)
    options = HashWithIndifferentAccess.new(options)
    publish_request = PubnubRequest.new(:operation => :publish)

    #TODO: This is ugly, refactor

    publish_request.ssl = @ssl
    publish_request.set_channel(options)
    publish_request.set_callback(options)
    publish_request.set_message(options, self.cipher_key)
    publish_request.set_publish_key(options, self.publish_key)
    publish_request.set_subscribe_key(options, self.subscribe_key)
    publish_request.set_secret_key(options, self.secret_key)


    publish_request.format_url!

    _request(publish_request)
  end

  def subscribe(options)
    options = HashWithIndifferentAccess.new(options)

    subscribe_request = PubnubRequest.new(:operation => :subscribe)

    #TODO: This is ugly, refactor

    subscribe_request.ssl = @ssl
    subscribe_request.set_channel(options)
    subscribe_request.set_callback(options)
    subscribe_request.set_cipher_key(options, self.cipher_key)

    subscribe_request.set_subscribe_key(options, self.subscribe_key)

    format_url_options = options[:override_timetoken].present? ? options[:override_timetoken] : nil
    subscribe_request.format_url!(format_url_options)

    _request(subscribe_request)

  end


  def history(args)
    ## Capture User Input
    limit = +args['limit'] ? +args['limit'] : 5
    channel = args['channel']
    callback = args['callback']

    ## Fail if bad input.
    if (!channel)
      puts 'Missing Channel.'
      return false
    end
    if (!callback)
      puts 'Missing Callback.'
      return false
    end

    ## Get History
    request = ['history', @subscribe_key, channel, '0', limit.to_s]
    args['request'] = request
    _request(args)
  end

  def time(options)
    options = HashWithIndifferentAccess.new(options)
    raise(PubNubRuntimeError, "You must supply a callback.") if options['callback'].blank?

    time_request = PubnubRequest.new(:operation => :time)
    time_request.set_callback(options)

    time_request.format_url!
    _request(time_request)

  end


  def UUID()
    SecureRandom.base64(32).gsub("/", "_").gsub(/=+$/, "")
  end


  #def _subscribe(args)
  #  channel = args['channel']
  #  callback = args['callback']
  #  request = args['request']
  #
  #  # Construct Request
  #  url = encode_URL(request);
  #  url = @origin + url
  #
  #  # Execute Request
  #  loop do
  #    begin
  #
  #      open(url, 'r', :read_timeout => 300) do |f|
  #        http_response = JSON.parse(f.read)
  #        messages = http_response[0]
  #        timetoken = http_response[1]
  #
  #        next if !messages.length
  #
  #        ## Run user Callback and Reconnect if user permits.
  #        ## Capture the message and encrypt it
  #        if @cipher_key.length > 0
  #          pc = PubnubCrypto.new(@cipher_key)
  #          messages.each do |message|
  #            if message.is_a? Array
  #              message=pc.decryptArray(message)
  #            else
  #              message=pc.decryptObject(message)
  #            end
  #            if !callback.call(message)
  #              return
  #            end
  #          end
  #        else
  #          messages.each do |message|
  #            if !callback.call(message)
  #              return
  #            end
  #          end
  #        end
  #
  #        request = ['subscribe', @subscribe_key, channel, '0', timetoken.to_s]
  #        args['request'] = request
  #        # Recusive call to _subscribe
  #        _subscribe(args)
  #
  #      end
  #
  #    rescue Timeout::Error => e
  #      logger.debug "Caught #{e.message}, restarting connection."
  #      retry
  #
  #    end
  #
  #  end
  #
  #end

  module DumbHttpClient
    def post_init
      send_data "GET / HTTP/1.1\r\nHost: _\r\n\r\n"
      @data = ""
      @parsed = false
    end

    def receive_data data
      @data << data
      if !@parsed and @data =~ /[\n][\r]*[\n]/m
        @parsed = true
        puts "RECEIVED HTTP HEADER:"
        $`.each { |line| puts ">>> #{line}" }

        puts "Now we'll terminate the loop, which will also close the connection"
        EventMachine::stop_event_loop
      end
    end

    def unbind
      puts "A connection has terminated"
    end
  end

  module Echo
    def receive_data(data)
      p data
    end
  end

  def _request(request)



    if !Rails.env.test?

      puts("tt0: #{request.timetoken}")
      port = request.ssl.present? ? 443 : 80

      puts("start loop")

      request.format_url!
      puts("new url is #{request.url}")


      begin


      EM.run do

        conn = EM::Protocols::HttpClient2.connect request.host, port

        req = conn.get(request.query)

        req.errback do |response|
          puts("error: #{response}")
          [0, "Unknown Error: #{response.to_s}"]
        end

        req.callback do |response|

          request.package_response!(response.content)
          request.callback.call(request.response)

          EM.next_tick do
            puts("#{Time.now} - recursing on next timetoken: #{request.timetoken}")
            _request(request)
          end
        end
      end

      rescue EventMachine::ConnectionError => e
        [0, "Network Error"]
      end


    else
      open(request.url, 'r', :read_timeout => 300) do |response |
        request.package_response!(response.read)
        request.callback.call(request.response)
      end

    end


    #end


    #EM.run do
    #
    #  puts("go!")


    #
    #
    #  puts("new request url is: #{request.url}")
    #
    #  puts(request.host)
    #  puts(port)
    #  puts("request.query: #{request.query}")
    #
    #  conn = EM::Protocols::HttpClient2.connect request.host, port
    #  req = conn.get(request.query)
    #
    #  req.callback do |response|
    #    puts(response.content)
    #    request.timetoken = JSON.parse(response.content)[1]
    #    request.format_url!
    #    puts("done 1.")
    #
    #  end
    #
    #  puts("done 2.")
    #

    #
    #puts("done 3.")


    #end


    #EventMachine::HttpRequest.new(request.url).get.callback do |http|
    #  request.response = http.response
    #
    #  puts ("response: #{request.response}")
    #  request.timetoken = JSON.parse(http.response)[1]
    #  request.format_url!
    #
    #
    #end

    #puts("callback or not?")
    #request.callback.call(request.response) if request.response.present?

    #if JSON.parse(http.response)[0].blank? && JSON.parse(http.response)[1].present?
    #
    #
    #  new_timetoken = JSON.parse(http.response)[1]
    #  request.timetoken = new_timetoken
    #  request.format_url!
    #  puts("tt1: #{request.timetoken}")
    #  http = EventMachine::HttpRequest.new(request.url).get
    #  http.callback do
    #
    #    new_timetoken = JSON.parse(http.response)[1]
    #    request.timetoken = new_timetoken
    #
    #    puts("tt2: #{request.timetoken}: #{JSON.parse(http.response)[0]}")
    #
    #    #EventMachine.stop
    #  end
    #
    #else
    #
    #  if JSON.parse(http.response)[0].blank? && JSON.parse(http.response)[1].present?
    #
    #  end
    #  #EventMachine.stop
    #end


    #end


    #if request.operation == 'history'
    #
    #  if request.cipher_key.present?
    #
    #    myarr = Array.new
    #
    #    response.each do |message|
    #      pc = PubnubCrypto.new(@cipher_key)
    #      if message.is_a? Array
    #        message = pc.decryptArray(message)
    #      else
    #        message = pc.decryptObject(message)
    #      end
    #      myarr.push(message)
    #    end
    #
    #    request.callback.call(myarr)
    #  else
    #    request.callback.call(response)
    #  end
    #
    #else
    #request.callback.call(response)
    #end
    #end

  end



end
