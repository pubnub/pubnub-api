class PubnubRequest
  attr_accessor :cipher_key, :host, :query, :response, :timetoken, :url, :operation, :callback, :publish_key, :subscribe_key, :secret_key, :channel, :jsonp, :message, :ssl, :port
  attr_accessor :history_limit, :history_count, :history_start, :history_end, :history_reverse, :session_uuid, :last_timetoken, :origin, :error

  class RequestError < RuntimeError;
  end

  def initialize(args = {})
    args = HashWithIndifferentAccess.new(args)

    @operation = args[:operation].to_s
    @callback = args[:callback]
    @cipher_key = args[:cipher_key]
    @session_uuid = args[:session_uuid]
    @publish_key = args[:publish_key]
    @subscribe_key = args[:subscribe_key]
    @channel = args[:channel]
    @jsonp = args[:jsonp].present? ? "1" : "0"
    @message = args[:message]
    @secret_key = args[:secret_key] || "0"
    @timetoken = args[:timetoken] || "0"
    @ssl = args[:ssl]

    @port = args[:port]
    @url = args[:url]
    @host = args[:host]
    @query = args[:query]
  end

  def op_exception
    if @operation.present?
      ("Pubnub::" + @operation.to_s.capitalize + "Error").constantize
    else
      PubnubRequest::RequestError
    end
  end

  def ==(another)
    self.operation == another.operation && self.callback == another.callback &&
        self.channel == another.channel && self.message == another.message
  end

  def set_error(options)
    options = HashWithIndifferentAccess.new(options)

    if options[:error].present?
      self.error = true
    end
    self
  end

  def set_origin(options)
    options = HashWithIndifferentAccess.new(options)

    if options[:origin].present?
      self.origin = options[:origin].to_s
      self
    end
  end

  def set_channel(options)
    options = HashWithIndifferentAccess.new(options)

    if options[:channel].blank?
      raise(op_exception, "channel is a required parameter.")
    else
      self.channel = options[:channel].to_s
      self
    end
  end

  def set_callback(options)
    options = HashWithIndifferentAccess.new(options)

    if options[:callback].blank?
      raise(op_exception, "callback is a required parameter.")
    elsif !options[:callback].try(:respond_to?, "call")
      raise(op_exception, "callback is invalid.")
    else
      self.callback = options[:callback]
      self
    end
  end


  def set_cipher_key(options, self_cipher_key)
    options = HashWithIndifferentAccess.new(options)

    if self_cipher_key.present? && options['cipher_key'].present?
      raise(op_exception, "existing cipher_key #{self_cipher_key} cannot be overridden at publish-time.")

    elsif (self_cipher_key.present? && options[:cipher_key].blank?) || (self_cipher_key.blank? && options[:cipher_key].present?)

      this_cipher_key = self_cipher_key || options[:cipher_key]
      raise(Pubnub::PublishError, "secret key must be a string.") if this_cipher_key.class != String
      self.cipher_key = this_cipher_key
    end
  end

  def set_secret_key(options, self_secret_key)
    options = HashWithIndifferentAccess.new(options)

    if self_secret_key.present? && options['secret_key'].present?
      raise(Pubnub::PublishError, "existing secret_key #{self_secret_key} cannot be overridden at publish-time.")

    elsif (self_secret_key.present? && options[:secret_key].blank?) || (self_secret_key.blank? && options[:secret_key].present?)

      my_secret_key = self_secret_key || options[:secret_key]
      raise(Pubnub::PublishError, "secret key must be a string.") if my_secret_key.class != String

      signature = "{ @publish_key, @subscribe_key, @secret_key, channel, message}"
      digest = OpenSSL::Digest.new("sha256")
      key = [my_secret_key]
      hmac = OpenSSL::HMAC.hexdigest(digest, key.pack("H*"), signature)
      self.secret_key = hmac
    else
      self.secret_key = "0"
    end
  end

  def set_message(options, self_cipher_key)
    options = HashWithIndifferentAccess.new(options)

    if options[:message].blank? && options[:message] != ""
      raise(op_exception, "message is a required parameter.")
    else
      my_cipher_key = options[:cipher_key] || self_cipher_key

      if my_cipher_key.present?
        self.message = Yajl.dump(aes_encrypt(my_cipher_key, options, self))
      else
        self.message = Yajl.dump(options[:message])
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
      self.publish_key = (self_publish_key || options[:publish_key]).to_s
    end
  end

  def set_subscribe_key(options, self_subscribe_key)
    options = HashWithIndifferentAccess.new(options)

    if options[:subscribe_key].blank? && self_subscribe_key.blank?
      raise(op_exception, "subscribe_key is a required parameter.")
    elsif self_subscribe_key.present? && options['subscribe_key'].present?
      raise(op_exception, "existing subscribe_key #{self_subscribe_key} cannot be overridden at subscribe-time.")
    else
      self.subscribe_key = (self_subscribe_key || options[:subscribe_key]).to_s
    end
  end

  def package_response!(response_data)
    self.response = response_data.respond_to?(:content) ? Yajl.load(response_data.content) : Yajl.load(response_data)
    self.last_timetoken = self.timetoken
    self.timetoken = self.response[1] unless self.operation == "time"

    if self.cipher_key.present? && %w(subscribe history detailed_history).include?(self.operation)

      myarr = Array.new
      pc = PubnubCrypto.new(@cipher_key)

      case @operation
        when "publish"
          iterate = self.response.first
        when "subscribe"
          iterate = self.response.first
        when "history"
          iterate = self.response
        when "detailed_history"
          iterate = self.response.first

        else
          raise(RequestError, "Don't know how to iterate on this operation.")
      end

      iterate.each do |message|
        message = pc.decrypt(message)
        myarr.push(message)
      end

      if %w(publish subscribe).include?(@operation)
        self.response[0] = myarr
      elsif @operation == "detailed_history"
        json_response_data = Yajl.load(response_data)
        self.response = [myarr, json_response_data[1], json_response_data[2]]
      else
        self.response = myarr
      end

    end
  end

  def format_url!(override_timetoken = nil)

    raise(Pubnub::PublishError, "Missing .operation in PubnubRequest object") if self.operation.blank?

    if @ssl.present?
      origin = 'https://' + (self.origin.present? ? self.origin : Pubnub::ORIGIN_HOST)
      @port = 443
    else
      origin = 'http://' + (self.origin.present? ? self.origin : Pubnub::ORIGIN_HOST)
      @port = 80
    end

    if override_timetoken.present?
      self.timetoken = override_timetoken.to_s
    end

    case self.operation.to_s
      when "publish"
        url_array = [self.operation.to_s, self.publish_key.to_s, self.subscribe_key.to_s,
                     self.secret_key.to_s, self.channel.to_s, "0", self.message]

      when "subscribe"
        url_array = [self.operation.to_s, self.subscribe_key.to_s, self.channel.to_s, "0", @timetoken]

      when "presence"
        url_array = ["subscribe", self.subscribe_key.to_s, ((self.channel.to_s) + "-pnpres"), "0", @timetoken]

      when "time"
        url_array = [self.operation.to_s, "0"]

      when "history"
        url_array = [self.operation.to_s, self.subscribe_key.to_s, self.channel.to_s, "0", self.history_limit.to_s]

      when "detailed_history"
        url_array = ["v2", "history", "sub-key", self.subscribe_key.to_s, "channel", self.channel.to_s]

      when "here_now"
        url_array = ["v2", "presence", "sub-key", self.subscribe_key.to_s, "channel", self.channel.to_s]

      else

        raise(PubnubRequest::RequestError, "I can't create that URL for you due to unknown operation type.")
    end

    self.url = origin + encode_URL(url_array)

    uri = URI.parse(self.url)

    self.host = uri.host
    url_params = ""

    if %w(subscribe presence).include?(@operation)
      uri.query = uri.query.blank? ? "uuid=#{@session_uuid}" : (uri.query + "uuid=#{@session_uuid}")

    elsif @operation == "detailed_history"
      url_sep = "?"

      if @history_count || @history_start || @history_end || @history_reverse

        if @history_count
          url_params += url_sep + "count=" + @history_count.to_s
          url_sep = "&"
        end

        if @history_start
          url_params += url_sep + "start=" + @history_start.to_s
          url_sep = "&"
        end

        if @history_end
          url_params += url_sep + "end=" + @history_end.to_s
          url_sep = "&"
        end

        if @history_reverse
          url_params += url_sep + "reverse=true"
          url_sep = "&"
        end
      end
    end

    self.query = uri.path + (uri.query.present? ? ("?" + uri.query) : "") + url_params
    self.url += url_params
    self

  end

  def aes_encrypt(cipher_key, options, publish_request)
    options = HashWithIndifferentAccess.new(options)

    pc = PubnubCrypto.new(cipher_key)
    publish_request.message = pc.encrypt(options[:message])

  end

  def encode_URL(request)
    ## Construct Request URL
    url = '/' + request.map { |bit| bit.split('').map { |ch|
      ' ~`!@#$%^&*()+=[]\\{}|;\':",./<>?'.index(ch) ?
          '%' + ch.unpack('H2')[0].to_s.upcase : URI.encode(ch)
    }.join('') }.join('/')
    return url
  end

  def first_request?
    @last_timetoken == "0"
  end

end