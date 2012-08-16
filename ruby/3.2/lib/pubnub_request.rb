class PubnubRequest
  attr_accessor :callback, :operation, :callback, :publish_key, :subscribe_key, :secret_key, :channel, :jsonp, :message

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

      secret_key = self_secret_key.present? ? self_secret_key : options[:secret_key]

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
        self.message = aes_encrypt(cipher_key, options, self)
      else
        self.message = options[:message].to_json()
      end
    end
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

end