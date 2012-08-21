## www.pubnub.com - PubNub realtime push service in the cloud.
## http://www.pubnub.com/blog/ruby-push-api - Ruby Push API Blog

## PubNub Real Time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.3 Real-time Push Cloud API
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
require 'pubnub_deferrable'

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

  end

  def time(options)
    options = HashWithIndifferentAccess.new(options)
    raise(PubNubRuntimeError, "You must supply a callback.") if options['callback'].blank?

    time_request = PubnubRequest.new(:operation => :time)
    time_request.set_callback(options)

    time_request.format_url!
    _request(time_request)

  end


  def UUID
    UUID.new.generate
  end

  def _request(request)

    if !Rails.env.test?

      request.format_url!
      puts("- Fetching #{request.url}")

      begin

      EM.run do
        conn = PubnubDeferrable.connect request.host, request.port # TODO: Add a 300s timeout, keep-alive
        req = conn.get(request.query)
        puts("req is a #{req.class}")

        req.errback do |response|
          puts("error: #{response}")
          [0, "Unknown Error: #{response.to_s}"]
        end

        req.callback do |response|
          request.package_response!(response.content)
          request.callback.call(request.response)

          EM.next_tick do
            if request.operation == "subscribe"
              puts("- #{Time.now} - Recursing on timetoken: #{request.timetoken}")
              conn.close_connection
              _request(request)
            else
              conn.close_connection # TODO: play with close_connection / reconnect / send_data on pub and sub to note open sockets
              return
            end

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
