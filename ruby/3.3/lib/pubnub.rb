## www.pubnub.com - PubNub realtime push service in the cloud.
## http://www.pubnub.com/blog/ruby-push-api - Ruby Push API Blog

## PubNub Real Time Push APIs and Notifications Framework
## Copyright (c) 2012 PubNub
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.3 Real-time Push Cloud API
## -----------------------------------

require 'base64'
require 'open-uri'
require 'uri'

require 'pubnub_crypto'
require 'pubnub_request'

require 'eventmachine'
require 'em-http-request'
require 'yajl'
require 'uuid'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/blank'


class Pubnub

  SUCCESS_RESPONSE = 200

  TIMEOUT_BAD_RESPONSE_CODE = 1
  TIMEOUT_BAD_JSON_RESPONSE = 0.5
  TIMEOUT_GENERAL_ERROR = 1
  TIMEOUT_SUBSCRIBE = 310
  TIMEOUT_NON_SUBSCRIBE = 5

  PUBNUB_LOGGER = Logger.new("/tmp/pubnubError.log")
  PUBNUB_LOGGER.level = Logger::DEBUG

  class PresenceError < RuntimeError;
  end
  class PublishError < RuntimeError;
  end
  class SubscribeError < RuntimeError;
  end
  class InitError < RuntimeError;
  end

  attr_accessor :publish_key, :subscribe_key, :secret_key, :cipher_key, :ssl, :channel, :origin, :session_uuid

  ORIGIN_HOST = 'pubsub.pubnub.com'
  #ORIGIN_HOST = 'test.pubnub.com'

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

    @session_uuid = uuid
    verify_init
  end

  def verify_init
    # publish_key and cipher_key are both optional.
    raise(InitError, "subscribe_key is a mandatory parameter.") if @subscribe_key.blank?
  end


  def publish(options)
    options = HashWithIndifferentAccess.new(options)
    publish_request = PubnubRequest.new(:operation => :publish)

    #TODO: refactor into initializer code on request instantiation

    publish_request.ssl = @ssl
    publish_request.set_origin(options)
    publish_request.set_channel(options)
    publish_request.set_callback(options)
    publish_request.set_cipher_key(options, self.cipher_key)
    publish_request.set_message(options, self.cipher_key)
    publish_request.set_publish_key(options, self.publish_key)
    publish_request.set_subscribe_key(options, self.subscribe_key)
    publish_request.set_secret_key(options, self.secret_key)


    publish_request.format_url!

    check_for_em publish_request
  end

  def subscribe(options)
    options = HashWithIndifferentAccess.new(options)

    operation = options[:operation].nil? ? :subscribe : :presence

    subscribe_request = PubnubRequest.new(:operation => operation, :session_uuid => @session_uuid)

    #TODO: refactor into initializer code on request instantiation

    subscribe_request.ssl = @ssl
    subscribe_request.set_origin(options)
    subscribe_request.set_channel(options)
    subscribe_request.set_callback(options)
    subscribe_request.set_cipher_key(options, self.cipher_key) unless subscribe_request.operation == "presence"

    subscribe_request.set_subscribe_key(options, self.subscribe_key)

    format_url_options = options[:override_timetoken].present? ? options[:override_timetoken] : nil
    subscribe_request.format_url!(format_url_options)

    check_for_em subscribe_request

  end

  def presence(options)
    usage_error = "presence() requires :channel and :callback options."
    if options.class != Hash
      raise(ArgumentError, usage_error)
    end

    options = HashWithIndifferentAccess.new(options) unless (options == nil)

    unless options[:channel] && options[:callback]
      raise(ArgumentError, usage_error)
    end

    subscribe(options.merge(:operation => "presence"))

  end


  def here_now(options = nil)
    usage_error = "here_now() requires :channel and :callback options."
    if options.class != Hash
      raise(ArgumentError, usage_error)
    end

    options = HashWithIndifferentAccess.new(options) unless (options == nil)

    unless options[:channel] && options[:callback]
      raise(ArgumentError, usage_error)
    end

    here_now_request = PubnubRequest.new(:operation => :here_now)

    here_now_request.ssl = @ssl
    here_now_request.set_channel(options)
    here_now_request.set_callback(options)

    here_now_request.set_subscribe_key(options, self.subscribe_key)

    here_now_request.format_url!
    check_for_em here_now_request

  end

  def detailed_history(options = nil)
    usage_error = "detailed_history() requires :channel, :callback, and :count options."
    if options.class != Hash
      raise(ArgumentError, usage_error)
    end

    options = HashWithIndifferentAccess.new(options) unless (options == nil)

    unless options[:count] && options[:channel] && options[:callback]
      raise(ArgumentError, usage_error)
    end


    detailed_history_request = PubnubRequest.new(:operation => :detailed_history)

    #TODO: refactor into initializer code on request instantiation

    # /detailed_history/SUBSCRIBE_KEY/CHANNEL/JSONP_CALLBACK/LIMIT

    detailed_history_request.ssl = @ssl
    detailed_history_request.set_channel(options)
    detailed_history_request.set_callback(options)
    detailed_history_request.set_cipher_key(options, self.cipher_key)

    detailed_history_request.set_subscribe_key(options, self.subscribe_key)

    detailed_history_request.history_count = options[:count]
    detailed_history_request.history_start = options[:start]
    detailed_history_request.history_end = options[:end]
    detailed_history_request.history_reverse = options[:reverse]

    detailed_history_request.format_url!
    check_for_em detailed_history_request

  end

  def history(options = nil)
    usage_error = "history() requires :channel, :callback, and :limit options."
    if options.class != Hash
      raise(ArgumentError, usage_error)
    end

    options = HashWithIndifferentAccess.new(options) unless (options == nil)

    unless options[:limit] && options[:channel] && options[:callback]
      raise(ArgumentError, usage_error)
    end


    history_request = PubnubRequest.new(:operation => :history)

    #TODO: refactor into initializer code on request instantiation

    # /history/SUBSCRIBE_KEY/CHANNEL/JSONP_CALLBACK/LIMIT

    history_request.ssl = @ssl
    history_request.set_channel(options)
    history_request.set_callback(options)
    history_request.set_cipher_key(options, self.cipher_key)

    history_request.set_subscribe_key(options, self.subscribe_key)
    history_request.history_limit = options[:limit]

    history_request.format_url!
    check_for_em history_request

  end

  def time(options)
    options = HashWithIndifferentAccess.new(options)
    raise(PubNubRuntimeError, "You must supply a callback.") if options['callback'].blank?

    time_request = PubnubRequest.new(:operation => :time)
    time_request.set_callback(options)

    time_request.format_url!
    check_for_em time_request
  end

  def my_callback(x, quiet = false)
    if quiet !=false
      puts("mycallback says: #{x.to_s}")
    else
      ""
    end

  end

  def uuid
    UUID.new.generate
  end

  def check_for_em request
    if EM.reactor_running?
      _request(request, true)
    else
      EM.run do
        _request(request)
      end
    end
  end

  private

  def _request(request, is_reactor_running = false)
    request.format_url!
    Thread.new{
      begin

        operation_timeout = %w(subscribe presence).include?(request.operation) ? TIMEOUT_SUBSCRIBE : TIMEOUT_NON_SUBSCRIBE
        conn = EM::HttpRequest.new(request.url, :inactivity_timeout => operation_timeout) #client times out in 310s unless the server returns or timeout first
        req = conn.get()

        req.errback{
          logAndRetryGeneralError(is_reactor_running, req, request)
        }

        req.callback {
          if checkForBadJSON(req) == true
            logAndRetryBadJSON(is_reactor_running, req, request)
          else
            processGoodResponse(is_reactor_running, req, request)
          end
        }

      rescue EventMachine::ConnectionError, RuntimeError => e # RuntimeError for catching "EventMachine not initialized"
        error_message = "Network Error: #{e.message}"
        puts(error_message)
        return [0, error_message]
      end
    }
  end

  def checkForBadJSON(req)
    jsonError = false
    begin
      JSON.parse(req.response)
    rescue => e
      jsonError = true
    end
    jsonError
  end

  def processGoodResponse(is_reactor_running, req, request)

    if (req.response_header.http_status.to_i != SUCCESS_RESPONSE)
      logAndRetryBadResponseCode(is_reactor_running, req, request)
    else

      request.package_response!(req.response)
      cycle = request.callback.call(request.response)

      if %w(subscribe presence).include?(request.operation) && (cycle != false || request.first_request?)
        _request(request, is_reactor_running)
      else
        EM.stop unless is_reactor_running
      end
    end
  end

  def logAndRetryGeneralError(is_reactor_running, req, request)
    errMsg = "#{Time.now}: Network connectivity issue while attempting to reach #{request.url}"
    logError(errMsg)
    retryRequest(is_reactor_running, req, request, TIMEOUT_GENERAL_ERROR)
  end

  def logAndRetryBadJSON(is_reactor_running, req, request)
    errMsg = "#{Time.now}: Retrying from bad JSON: #{req.response.to_s}"
    logError(errMsg)
    retryRequest(is_reactor_running, req, request, TIMEOUT_BAD_JSON_RESPONSE)
  end

  def logAndRetryBadResponseCode(is_reactor_running, req, request)
    errMsg = "#{Time.now}: Retrying from bad server response code: (#{req.response_header.http_status.to_i}) #{req.response.to_s}"
    logError(errMsg)
    retryRequest(is_reactor_running, req, request, TIMEOUT_BAD_RESPONSE_CODE)
  end

  def logError(errMsg)
    PUBNUB_LOGGER.debug(errMsg)
  end

  def retryRequest(is_reactor_running, req, request, delay)

    if %w(subscribe presence).include?(request.operation)
      EM::Timer.new(delay) do
        _request(request, is_reactor_running)
      end
    else
      error_msg = [0, "Request to #{request.url} failed."]

      request.set_error(true)
      request.callback.call(error_msg)

      PUBNUB_LOGGER.debug(error_msg)

      EM.stop unless is_reactor_running
    end

  end

end