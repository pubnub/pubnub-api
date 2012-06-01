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
require 'json'
require 'pp'
require 'rubygems'
require 'securerandom'
require 'digest'
require 'pubnub_ruby/pubnub_crypto'
require 'eventmachine'
require 'em-http'
require 'fiber'

class Pubnub
  MAX_RETRIES = 3
  retries=0
  #**
  #* Pubnub
  #*
  #* Init the Pubnub Client API
  #*
  #* @param string publish_key required key to send messages.
  #* @param string subscribe_key required key to receive messages.
  #* @param string secret_key required key to sign messages.
  #* @param string cipher_key required to encrypt messages.
  #* @param boolean ssl required for 2048 bit encrypted messages.
  #*
  def initialize( publish_key, subscribe_key, secret_key, cipher_key, ssl_on )
    @publish_key   = publish_key
    @subscribe_key = subscribe_key
    @secret_key    = secret_key
    @cipher_key    = cipher_key
    @ssl           = ssl_on
    @origin        = 'pubsub.pubnub.com'

    if @ssl
      @origin = 'https://' + @origin
    else
      @origin = 'http://'  + @origin
    end
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
    if !(args['channel'] && args['message'])
      puts('Missing Channel or Message')
      return false
    end

    ## Capture User Input
    channel = args['channel']
    message = args['message']

    #encryption of message
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
      key = [ @secret_key ]
      hmac = OpenSSL::HMAC.hexdigest(digest, key.pack("H*"), signature)
      signature = hmac
    end

    ## Send Message
    return _request([
      'publish',
      @publish_key,
      @subscribe_key,
      signature,
      channel,
      '0',
      message
    ])
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
    channel   = args['channel']
    callback  = args['callback']

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

    ## Begin Subscribe
    loop do
      begin
        timetoken = args['timetoken'] ? args['timetoken'] : 0

        ## Wait for Message
        response = _request([
          'subscribe',
          @subscribe_key,
          channel,
          '0',
          timetoken.to_s
        ])

        messages          = response[0]
        args['timetoken'] = response[1]

        ## If it was a timeout
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
      rescue  Timeout::Error
      rescue
        sleep(1)
      end
    end
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
    limit   = +args['limit'] ? +args['limit'] : 5
    channel = args['channel']

    ## Fail if bad input.
    if (!channel)
      puts 'Missing Channel.'
      return false
    end

    ## Get History
    response = _request([ 'history', @subscribe_key, channel, '0', limit.to_s])
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
      return myarr
    else
      return response
    end
  end

  #**
  #* Time
  #*
  #* Timestamp from PubNub Cloud.
  #*
  #* @return int timestamp.
  #*
  def time()
    return _request([
      'time',
      '0'
    ])[0]
  end

  #**
  #* UUID
  #*
  #* Unique identifier generation
  #*
  #* @return Unique Identifier
  #*
  def UUID()
    uuid=SecureRandom.base64(32).gsub("/","_").gsub(/=+$/,"")
  end

  private

  #**
  #* Request URL
  #*
  #* @param array request of url directories.
  #* @return array from JSON response.
  #*
  def _request(request)
    ## Construct Request URL
    url = '/' + request.map{ |bit| bit.split('').map{ |ch|
        ' ~`!@#$%^&*()+=[]\\{}|;\':",./<>?'.index(ch) ?
        '%' + ch.unpack('H2')[0].to_s.upcase : URI.encode(ch)
      }.join('') }.join('/')

    url = @origin + url
    http_response = ''

    EventMachine.run do
      Fiber.new{
        http = async_fetch(url)
        http_response = http.response
        EventMachine.stop
      }.resume
    end
    JSON.parse(http_response)
  end

  ## Non-blocking IO using EventMachine
  def async_fetch(url)
    f = Fiber.current

    request_options = {
      :timeout => 310,  # set request timeout
      :query => {'V' => '3.1', 'User-Agent' => 'Ruby', 'Accept-Encoding' => 'gzip'},  # set request headers
    }

    http = EventMachine::HttpRequest.new(url).get request_options
    http.callback { f.resume(http) }
    http.errback  { f.resume(http) }

    Fiber.yield

    if http.error
      p [:HTTP_ERROR, http.error]
    end

    http
  end

end
