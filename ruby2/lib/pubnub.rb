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

class Pubnub

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
      @publish_key = options_hash[:publish_key].to_s
      @subscribe_key = options_hash[:subscribe_key].to_s
      @secret_key = options_hash[:secret_key].to_s
      @cipher_key = options_hash[:cipher_key].to_s
      @ssl = options_hash[:ssl]

    else
      raise "Initialize with either a hash of options, or exactly 5 named parameters."
    end

    @origin = (@ssl.present? ? 'https://' : 'http://') + ORIGIN_HOST

  end

  def verify_config
    # publish_key and cipher_key are both optional.
    Rails.logger.debug("verifying configuration...")

    @subscribe_key.blank? ? raise("subscribe_key is a mandatory parameter.") : Rails.logger.debug("subscribe_key set to #{@subscribe_key}")

    Rails.logger.debug(@publish_key.present? ? "publish_key set to #{@publish_key}" : "publish_key not set.")
    Rails.logger.debug(@cipher_key.present? ? "cipher_key set to #{@cipher_key}. AES encryption enabled." : "cipher_key not set. AES encryption disabled.")
    Rails.logger.debug(@secret_key.present? ? "secret_key set to #{@secret_key}. HMAC message signing enabled." : "secret_key not set. HMAC signing disabled.")
    Rails.logger.debug(@ssl.present? ? "ssl is enabled." : "ssl is disabled.")
  end

  #**
  #* Publish
  #*
  #* Send a message to a channel.
  #*
  #* @param array args with channel and message.
  #* @return array success information.
  #*
  def publish(args)
    ## Fail if bad input.
    if !(args['channel'] && args['message'] && args['callback'])
      puts('Missing Channel or Message or Callback')
      return false
    end

    ## Capture User Input
    channel = args['channel']
    message = args['message']
    callback = args['callback']

    # Encryption of message
    if @cipher_key.length > 0
      pc=PubnubCrypto.new(@cipher_key)
      if message.is_a? Array
        message=pc.encryptArray(message)
      else
        message=pc.encryptObject(message)
      end
    else
      message = args['message'].to_json();
    end

    ## Sign message using HMAC
    String signature = '0'
    if @secret_key.length > 0
      signature = "{@publish_key,@subscribe_key,@secret_key,channel,message}"
      digest = OpenSSL::Digest.new("sha256")
      key = [@secret_key]
      hmac = OpenSSL::HMAC.hexdigest(digest, key.pack("H*"), signature)
      signature = hmac
    end

    ## Send Message
    request = ['publish', @publish_key, @subscribe_key, signature, channel, '0', message]
    args['request'] = request
    args['callback'] = callback
    _request(args)
  end

  #**
  #* Subscribe
  #*
  #* This is NON-BLOCKING.
  #* Listen for a message on a channel.
  #*
  #* @param array args with channel and message.
  #* @return false on fail, array on success.
  #*
  def subscribe(args)
    ## Capture User Input
    channel = args['channel']
    callback = args['callback']

    ## Fail if missing channel
    if !channel
      puts "Missing Channel."
      return false
    end

    ## Fail if missing callback
    if !callback
      puts "Missing Callback."
      return false
    end

    ## EventMachine loop
    #EventMachine.run do
    timetoken = 0
    request = ['subscribe', @subscribe_key, channel, '0', timetoken.to_s]
    args['request'] = request
    _subscribe(args)
    #end
  end

  #**
  #* History
  #*
  #* Load history from a channel.
  #*
  #* @param array args with 'channel' and 'limit'.
  #* @return mixed false on fail, array on success.
  #*
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

  #**
  #* Time
  #*
  #* Timestamp from PubNub Cloud.
  #*
  #* @return int timestamp.
  #*
  def time(options)
    options = HashWithIndifferentAccess.new(options)

    options['request'] = ['time', '0']
    options['callback'].blank? ? raise("You must supply a callback.") : _request(options)
  end

  #**
  #* UUID
  #*
  #* Unique identifier generation
  #*
  #* @return Unique Identifier
  #*
  def UUID()
    uuid=SecureRandom.base64(32).gsub("/", "_").gsub(/=+$/, "")
  end

  private

  #**
  #* Request URL for subscribe
  #*
  #* @param array request of url directories.
  #* @return array from JSON response.
  #*
  def _subscribe(args)
    channel = args['channel']
    callback = args['callback']
    request = args['request']

    # Construct Request
    url = encode_URL(request);
    url = @origin + url

    # Execute Request
    loop do
      begin

        open(url, 'r', :read_timeout => 300) do |f|
          http_response = JSON.parse(f.read)
          messages = http_response[0]
          timetoken = http_response[1]

          next if !messages.length

          ## Run user Callback and Reconnect if user permits.
          ## Capture the message and encrypt it
          if @cipher_key.length > 0
            pc = PubnubCrypto.new(@cipher_key)
            messages.each do |message|
              if message.is_a? Array
                message=pc.decryptArray(message)
              else
                message=pc.decryptObject(message)
              end
              if !callback.call(message)
                return
              end
            end
          else
            messages.each do |message|
              if !callback.call(message)
                return
              end
            end
          end

          request = ['subscribe', @subscribe_key, channel, '0', timetoken.to_s]
          args['request'] = request
          # Recusive call to _subscribe
          _subscribe(args)

        end

      rescue Timeout::Error => e
        logger.debug "Caught #{e.message}, restarting connection."
        retry

      end

    end

  end

  #**
  #* Request URL
  #*
  #* @param array request of url directories.
  #* @return array from JSON response.
  #*
  def _request(options)
    request = options['request']
    callback = options['callback']
    url = encode_URL(request)
    url = @origin + url
    open(url) do |f|
      response = JSON.parse(f.read)
      if request[0] == 'history'
        if @cipher_key.length > 0
          myarr=Array.new()
          response.each do |message|
            pc=PubnubCrypto.new(@cipher_key)
            if message.is_a? Array
              message=pc.decryptArray(message)
            else
              message=pc.decryptObject(message)
            end
            myarr.push(message)
          end
          callback.call(myarr)
        else
          callback.call(response)
        end
      elsif request[0] == 'publish'
        callback.call(response)
      else
        callback.call(response)
      end
    end
  end

  def encode_URL(request)
    ## Construct Request URL
    url = '/' + request.map { |bit| bit.split('').map { |ch|
      ' ~`!@#$%^&*()+=[]\\{}|;\':",./<>?'.index(ch) ?
        '%' + ch.unpack('H2')[0].to_s.upcase : URI.encode(ch)
    }.join('') }.join('/')
    return url
  end
end
