class PubnubRequest
  attr_accessor :url, :callback, :operation, :callback, :publish_key, :subscribe_key, :secret_key, :channel, :jsonp, :message, :ssl

  def initialize(args = {})
    args = HashWithIndifferentAccess.new(args)

    @operation = args[:operation].to_s
    @callback = args[:callback]
    @publish_key = args[:publish_key]
    @subscribe_key = args[:subscribe_key]
    @channel = args[:channel]
    @jsonp = args[:jsonp].present? ? "1" : "0"
    @message = args[:message]
    @secret_key = args[:secret_key] || "0"
    @ssl = args[:ssl]
  end

  def ==(another)
    self.operation == another.operation && self.callback == another.callback &&
        self.channel == another.channel && self.message == another.message
  end

  def set_channel(options)
    options = HashWithIndifferentAccess.new(options)

    if options[:channel].blank?
      raise(Pubnub::PublishError, "channel is a required parameter.")
    else
      self.channel = options[:channel]
      self
    end
  end

  def set_callback(options)
    options = HashWithIndifferentAccess.new(options)

    if options[:callback].blank?
      raise(Pubnub::PublishError, "callback is a required parameter.")
    elsif !options[:callback].try(:respond_to?, "call")
      raise(Pubnub::PublishError, "callback is invalid.")
    else
      self.callback = options[:callback]
      self
    end
  end

  def set_secret_key(options, self_secret_key)
    options = HashWithIndifferentAccess.new(options)

    if self_secret_key.present? && options['secret_key'].present?
      raise(Pubnub::PublishError, "existing secret_key #{self_secret_key} cannot be overridden at publish-time.")

    elsif (self_secret_key.present? && options[:secret_key].blank?) || (self_secret_key.blank? && options[:secret_key].present?)

      secret_key = self_secret_key || options[:secret_key]
      raise(Pubnub::PublishError, "secret key must be a string.") if secret_key.class != String

      signature = "{ @publish_key, @subscribe_key, @secret_key, channel, message}"
      digest = OpenSSL::Digest.new("sha256")
      key = [secret_key]
      hmac = OpenSSL::HMAC.hexdigest(digest, key.pack("H*"), signature)
      self.secret_key = hmac
    else
      self.secret_key = "0"
    end
  end

  def set_message(options, self_cipher_key)
    options = HashWithIndifferentAccess.new(options)

    if options[:message].blank? && options[:message] != ""
      raise(Pubnub::PublishError, "message is a required parameter.")
    else
      cipher_key = options[:cipher_key] || self_cipher_key

      if cipher_key.present?
        self.message = aes_encrypt(cipher_key, options, self)    #TODO: Need a to_json here?
      else
        self.message = options[:message].to_json
      end
    end
  end

  def set_publish_key(options, self_publish_key)
    options = HashWithIndifferentAccess.new(options)

    if options[:publish_key].blank? && self_publish_key.blank?
      raise(Pubnub::PublishError, "publish_key is a required parameter.")
    elsif self_publish_key.present? && options['publish_key'].present?
      raise(Pubnub::PublishError, "existing publish_key #{self_publish_key} cannot be overridden at publish-time.")
    else
      self.publish_key = self_publish_key || options[:publish_key]
    end
  end

  def set_subscribe_key(options, self_subscribe_key)
    options = HashWithIndifferentAccess.new(options)

    if options[:subscribe_key].blank? && self_subscribe_key.blank?
      raise(Pubnub::PublishError, "subscribe_key is a required parameter.")
    elsif self_subscribe_key.present? && options['subscribe_key'].present?
      raise(Pubnub::PublishError, "existing subscribe_key #{self_subscribe_key} cannot be overridden at subscribe-time.")
    else
      self.subscribe_key = self_subscribe_key || options[:subscribe_key]
    end
  end

  def format_url!

    raise(Pubnub::PublishError, "Missing .operation in PubnubRequst object") if self.operation.blank?

    origin = (@ssl.present? ? 'https://' : 'http://') + Pubnub::ORIGIN_HOST


    case self.operation.to_s
      when "publish"
        url_array = [ self.operation.to_s, self.publish_key.to_s, self.subscribe_key.to_s,
                      self.secret_key.to_s, self.channel.to_s, "0", self.message ]
      when "time"
        url_array = [ self.operation.to_s, "0" ]
    end

    self.url = origin + encode_URL(url_array)

  end

  def aes_encrypt(cipher_key, options, publish_request)
    options = HashWithIndifferentAccess.new(options)

    pc = PubnubCrypto.new(cipher_key)
    if options[:message].is_a? Array
      publish_request.message = pc.encryptArray(options[:message])
    else
      publish_request.message = pc.encryptObject(options[:message])
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