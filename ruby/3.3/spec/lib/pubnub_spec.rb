require 'spec_helper'
require 'rr'
require 'vcr'

describe Pubnub do

  before do
    @mocked_uuid = "123-456-789"
    any_instance_of(Pubnub) do |pubnub|
      stub(pubnub).uuid { @mocked_uuid }
    end
  end

  describe "#retry_request" do

    before do
      @pn = Pubnub.new("demo_pub_key", "demo_sub_key", "demo_md5_key", "demo_cipher_key", false)
      @pn_request = PubnubRequest.new
      @req_mock = Object.new
      stub(@req_mock).response {}
      @retryArgs = [true, @req_mock, @pn_request, Pubnub::TIMEOUT_GENERAL_ERROR]


    end

    it "should retry the request if its a presence call" do
      @pn_request.operation = "presence"

      mock(EM::Timer).new(Pubnub::TIMEOUT_GENERAL_ERROR).yields {}
      mock(@pn)._request(@retryArgs[2], @retryArgs[0]) {}
      dont_allow(@pn_request).send(:set_error, true)
      dont_allow(@pn_request).send(:package_response!, anything)

      @pn.send(:retryRequest, @retryArgs[0], @retryArgs[1], @retryArgs[2], @retryArgs[3])

    end


    it "should retry the request if its a subscribe call" do
      @pn_request.operation = "subscribe"

      mock(EM::Timer).new(Pubnub::TIMEOUT_GENERAL_ERROR).yields {}
      mock(@pn)._request(@retryArgs[2], @retryArgs[0]) {}
      dont_allow(@pn_request).send(:set_error, true)
      dont_allow(@pn_request).send(:package_response!, anything)

      @pn.send(:retryRequest, @retryArgs[0], @retryArgs[1], @retryArgs[2], @retryArgs[3])
    end

    it "should not retry the request if its a publish call" do
      @pn_request.operation = "publish"
      @pn_request.url = "somewhere"
      my_callback = lambda { |x| x }
      @pn_request.callback = my_callback

      callback_msg = [0, "Request to somewhere failed."]


      dont_allow(EM::Timer).new(Pubnub::TIMEOUT_GENERAL_ERROR).yields {}
      dont_allow(@pn)._request(@retryArgs[1], @retryArgs[0]) {}

      mock(@pn_request).set_error(true) {}
      mock(my_callback).call(callback_msg) {}

      @pn.send(:retryRequest, @retryArgs[0], @retryArgs[1], @retryArgs[2], @retryArgs[3])
    end

  end

  describe "#UUID" do
    it "should return a UUID" do

      Pubnub.new(:subscribe_key => :demo).uuid.should == @mocked_uuid
    end
  end

  describe ".initialize" do

    before do
      @publish_key = "demo_pub_key"
      @subscribe_key = "demo_sub_key"
      @secret_key = "demo_md5_key"
      @cipher_key = "demo_cipher_key"
      @ssl_enabled = false
      @channel = "pn_test"
    end

    context "when initialized" do
      it "should set a sessionUUID" do
        @pn = Pubnub.new("demo_pub_key", "demo_sub_key", "demo_md5_key", "demo_cipher_key", false)
        @pn.session_uuid.should == @mocked_uuid
      end
    end

    shared_examples_for "successful initialization" do
      it "should initialize" do
        @pn.publish_key.should == @publish_key
        @pn.subscribe_key.should == @subscribe_key
        @pn.secret_key.should == @secret_key
        @pn.cipher_key.should == @cipher_key
        @pn.ssl.should == @ssl_enabled
      end
    end

    context "when named" do
      context "and there are exactly 5 arguments" do
        before do
          @pn = Pubnub.new("demo_pub_key", "demo_sub_key", "demo_md5_key", "demo_cipher_key", false)
        end
        it_behaves_like "successful initialization"
      end

      it "should throw an error if there are not exactly 5" do
        lambda { Pubnub.new("arg1", "arg2", "arg3") }.should raise_error
      end

    end

    context "when passed with optional parameters in a hash" do

      context "when the hash key is a symbol" do
        before do
          @pn = Pubnub.new(:publish_key => @publish_key,
                           :subscribe_key => @subscribe_key,
                           :secret_key => @secret_key,
                           :cipher_key => @cipher_key,
                           :ssl => @ssl_enabled)
        end
        it_behaves_like "successful initialization"
      end

      context "when the hash key is named" do

        before do
          @pn = Pubnub.new("publish_key" => @publish_key,
                           "subscribe_key" => @subscribe_key,
                           "secret_key" => @secret_key,
                           "cipher_key" => @cipher_key,
                           "ssl" => @ssl_enabled)
        end
        it_behaves_like "successful initialization"

      end


    end
  end

  describe ".verify_config" do
    context "subscribe_key" do
      it "should not throw an exception if present" do
        pn = Pubnub.new(:subscribe_key => "demo")
        lambda { pn.verify_init }.should_not raise_error
      end

      it "should not throw an exception if present" do
        pn = Pubnub.new(:subscribe_key => :bar)
        lambda { pn.verify_init }.should_not raise_error
      end
    end
  end

  describe "#time" do
    before do
      @pn = Pubnub.new(:subscribe_key => :demo)
      @my_callback = lambda { |message| Rails.logger.debug(message) }
    end

    context "should enforce a callback parameter" do

      it "should raise with no callback parameter" do
        lambda { @pn.time(:foo => :bar) }.should raise_error
      end

      it "should allow for a symbol" do
        mock_pubnub_request = PubnubRequest.new(:callback => @my_callback, :operation => "time")
        mock(@pn).check_for_em(mock_pubnub_request) {}

        @pn.time(:callback => @my_callback)
      end

      it "should allow for a string" do
        mock_pubnub_request = PubnubRequest.new(:callback => @my_callback, :operation => "time")
        mock(@pn).check_for_em(mock_pubnub_request) {}

        @pn.time("callback" => @my_callback)
      end
    end

    it "should return the current time" do
      mock(@my_callback).call([13433410952661319]) {}

      VCR.use_cassette("time", :record => :none) do
        @pn.time("callback" => @my_callback)
      end
    end
  end


  describe "#presence" do

    before do

      @my_callback = lambda { |message| Rails.logger.debug(message) }
      @my_pub_key = "demo"
      @my_sub_key = "demo"
      @my_message = "hello_world!"
      @my_channel = "hello_world"

      @my_cipher_key = "my_cipher_key"
      @my_sec_key = "my_sec_key"
      @alt_sec_key = "alt_sec_key"
    end

    context "required parameters" do

      before do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key)
      end

      it "should raise when channel is missing" do
        lambda { @pn.presence(:foo => :bar) }.
            should raise_error(ArgumentError, "presence() requires :channel and :callback options.")
      end

      it "should raise when callback is missing" do
        lambda { @pn.presence(:channel => @my_channel) }.
            should raise_error(ArgumentError, "presence() requires :channel and :callback options.")
      end

      it "should raise when callback is invalid" do
        lambda { @pn.presence(:channel => @my_channel, :callback => :blah) }.
            should raise_error(Pubnub::PresenceError, "callback is invalid.")
      end

    end

    context "subscribe key" do

      before do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key)
      end

      it "should not let you override an existing instantiated subscribe key" do
        #TODO: unless its the same as existing

        @pn = Pubnub.new(:subscribe_key => @my_sub_key)
        @alt_sub_key = "alt_sub_key"

        lambda { @pn.presence(:channel => @my_channel, :callback => @my_callback, :subscribe_key => @alt_sub_key) }.
            should raise_error(Pubnub::PresenceError, "existing subscribe_key demo cannot be overridden at subscribe-time.")
      end

      it "should throw if you create a PubNub object without a sub key" do
        lambda { @pn = Pubnub.new(:publish_key => @my_pub_key).presence(:channel => @my_channel, :callback => @my_callback) }.should raise_error(Pubnub::InitError, "subscribe_key is a mandatory parameter.")
      end
    end

    context "cipher key" do

      it "should ignore the cipher key at subscribe time if it was not instantiated with one" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)

        mock_presence_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel,
                                                   :operation => :presence, :subscribe_key => @my_sub_key,
                                                   :cipher_key => "foo" )

        mock(@pn).check_for_em(mock_presence_request) {}
        @pn.presence(:channel => @my_channel, :callback => @my_callback, :message => @my_message)
      end


      it "should subscribe without a cipher key" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)

        mock_presence_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel,
                                                   :operation => :presence, :subscribe_key => @my_sub_key)

        mock(@pn).check_for_em(mock_presence_request) {}
        @pn.presence(:channel => @my_channel, :callback => @my_callback, :message => @my_message)
      end

    end

    context "#ssl" do

      it "should default to false if not defined" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key)
        @pn.ssl.should == false
      end

      it "should set to true if defined at instantiation" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :ssl => true)
        @pn.ssl.should == true
      end
    end
  end

  describe "#subscribe" do

    before do

      @my_callback = lambda { |message| Rails.logger.debug(message) }
      @my_pub_key = "demo_pub_key"
      @my_sub_key = "demo_sub_key"
      @my_message = "hello_world!"
      @my_channel = "demo_channel"

      @my_cipher_key = "my_cipher_key"
      @my_sec_key = "my_sec_key"
      @alt_sec_key = "alt_sec_key"
    end

    context "required parameters" do

      before do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key)
      end

      it "should raise when channel is missing" do
        lambda { @pn.subscribe(:foo => :bar) }.
            should raise_error(Pubnub::SubscribeError, "channel is a required parameter.")
      end

      it "should raise when callback is missing" do
        lambda { @pn.subscribe(:channel => @my_channel) }.
            should raise_error(Pubnub::SubscribeError, "callback is a required parameter.")
      end

      it "should raise when callback is invalid" do
        lambda { @pn.subscribe(:channel => @my_channel, :callback => :blah) }.
            should raise_error(Pubnub::SubscribeError, "callback is invalid.")
      end

    end

    context "subscribe key" do

      before do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key)
      end

      it "should not let you override an existing instantiated subscribe key" do
        #TODO: unless its the same as existing

        @pn = Pubnub.new(:subscribe_key => @my_sub_key)
        @alt_sub_key = "alt_sub_key"

        lambda { @pn.subscribe(:channel => @my_channel, :callback => @my_callback, :subscribe_key => @alt_sub_key) }.
            should raise_error(Pubnub::SubscribeError, "existing subscribe_key demo_sub_key cannot be overridden at subscribe-time.")
      end

      it "should throw if you create a PubNub object without a sub key" do
        lambda { @pn = Pubnub.new(:publish_key => @my_pub_key).subscribe(:channel => @my_channel, :callback => @my_callback) }.should raise_error(Pubnub::InitError, "subscribe_key is a mandatory parameter.")
      end
    end

    context "cipher key" do

      it "should not let you override an existing instantiated cipher key" do

        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key, :cipher_key => @my_cipher_key)
        alt_cipher_key = "alt_cipher_key"

        # TODO: generate this from the pn encryption instance method, mock the response

        lambda { @pn.subscribe(:channel => @my_channel, :callback => @my_callback, :cipher_key => alt_cipher_key) }.should raise_error(Pubnub::SubscribeError, "existing cipher_key my_cipher_key cannot be overridden at publish-time.")

      end


      it "should let you define a cipher key at subscribe time if it was not instantiated with one" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)

        mock_subscribe_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel,
                                                   :operation => :subscribe, :subscribe_key => @my_sub_key,
                                                   :cipher_key => @my_cipher_key)

        mock(@pn).check_for_em(mock_subscribe_request) {}
        @pn.subscribe(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :cipher_key => @my_cipher_key)
      end


      it "should subscribe without a cipher key" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)

        mock_subscribe_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel,
                                                   :operation => :subscribe, :subscribe_key => @my_sub_key)

        mock(@pn).check_for_em(mock_subscribe_request) {}
        @pn.subscribe(:channel => @my_channel, :callback => @my_callback, :message => @my_message)
      end

    end

    context "#ssl" do

      it "should default to false if not defined" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key)
        @pn.ssl.should == false
      end

      it "should set to true if defined at instantiation" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :ssl => true)
        @pn.ssl.should == true
      end
    end
  end


  describe "#publish" do

    before do

      @my_callback = lambda { |message| Rails.logger.debug(message) }
      @my_pub_key = "demo_pub_key"
      @my_sub_key = "demo_sub_key"
      @my_message = "hello_world!"
      @my_channel = "demo_channel"

      @my_cipher_key = "enigma"
      @my_sec_key = "my_sec_key"
      @alt_sec_key = "alt_sec_key"
    end

    context "required parameters" do

      before do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key)
      end

      it "should raise when channel is missing" do
        lambda { @pn.publish(:message => @my_message) }.
            should raise_error(Pubnub::PublishError, "channel is a required parameter.")
      end

      it "should raise when callback is missing" do
        lambda { @pn.publish(:message => @my_message, :channel => @my_channel) }.
            should raise_error(Pubnub::PublishError, "callback is a required parameter.")
      end

      it "should raise when callback is invalid" do
        lambda { @pn.publish(:message => @my_message, :channel => @my_channel, :callback => :blah) }.
            should raise_error(Pubnub::PublishError, "callback is invalid.")
      end

      it "should raise when message is missing" do
        lambda { @pn.publish(:channel => @my_channel, :callback => @my_callback) }.
            should raise_error(Pubnub::PublishError, "message is a required parameter.")
      end
    end

    context "publish key" do

      before do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key)
      end

      it "should not let you override an existing instantiated publish key" do
        #TODO: unless its the same as existing

        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)
        @alt_pub_key = "alt_pub_key"

        lambda { @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :publish_key => @alt_pub_key) }.
            should raise_error(Pubnub::PublishError, "existing publish_key demo_pub_key cannot be overridden at publish-time.")
      end

      it "should let you define a publish key at publish time if it was not instantiated with one" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key)
        @alt_pub_key = "alt_pub_key"

        mock_publish_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel, :message => @my_message.to_json,
                                                 :operation => :publish, :publish_key => @alt_pub_key, :subscribe_key => @my_sub_key)
        mock(@pn).check_for_em(mock_publish_request) {}

        @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :publish_key => @alt_pub_key)
      end

      it "should throw if you publish without a publish key" do
        lambda { @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :publish_key => @alt_pub_key) }.should raise_error(Pubnub::PublishError, "publish_key is a required parameter.")
      end
    end

    context "secret key" do

      it "should not let you override an existing instantiated secret key" do
        #TODO: unless its the same as existing
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key, :secret_key => @my_sec_key)
        @alt_sec_key = "alt_sec_key"

        lambda { @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :secret_key => @alt_sec_key) }.
            should raise_error(Pubnub::PublishError, "existing secret_key my_sec_key cannot be overridden at publish-time.")
      end

      it "should let you define a secret key at publish time if it was not instantiated with one" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)

        mock_publish_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel, :message => @my_message.to_json,
                                                 :operation => :publish, :publish_key => @my_pub_key, :subscribe_key => @my_sub_key,
                                                 :secret_key => @my_sec_key)

        mock(@pn).check_for_em(mock_publish_request) {}
        @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :secret_key => @my_sec_key)
      end


      it "should publish without signing the message if you publish without a secret key" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)

        mock_publish_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel, :message => @my_message.to_json,
                                                 :operation => :publish, :publish_key => @my_pub_key, :subscribe_key => @my_sub_key)

        mock(@pn).check_for_em(mock_publish_request) {}
        @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message)
      end

    end

    context "cipher key" do

      it "should not let you override an existing instantiated cipher key" do

        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key, :cipher_key => @my_cipher_key)
        alt_cipher_key = "alt_cipher_key"

        # TODO: generate this from the pn encryption instance method, mock the response

        lambda { @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :cipher_key => alt_cipher_key) }.should raise_error(Pubnub::PublishError, "existing cipher_key #{@pn.cipher_key} cannot be overridden at publish-time.")

      end


      it "should let you define a cipher key at publish time if it was not instantiated with one" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)
        message = "Pubnub Messaging API 1"
        encrypted_message = PubnubCrypto.new(@my_cipher_key).encrypt(message)

        mock_publish_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel, :message => Yajl.dump(encrypted_message),
                                                 :operation => :publish, :publish_key => @my_pub_key, :subscribe_key => @my_sub_key,
                                                 :cipher_key => @my_cipher_key, :ssl => false, :port => 80,
                                                 :url => "http://pubsub.pubnub.com/publish/demo_pub_key/demo_sub_key/0/demo_channel/0/%22f42pIQcWZ9zbTbH8cyLwByD%2FGsviOE0vcREIEVPARR0%3D%22",
                                                 :host => "pubsub.pubnub.com",
                                                 :query => "/publish/demo_pub_key/demo_sub_key/0/demo_channel/0/%22f42pIQcWZ9zbTbH8cyLwByD%2FGsviOE0vcREIEVPARR0%3D%22"
                                                  )

        mock(@pn).check_for_em(mock_publish_request) {}
        @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => message, :cipher_key => @my_cipher_key)
      end


      it "should publish without a cipher key" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)

        mock_publish_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel, :message => @my_message.to_json,
                                                 :operation => :publish, :publish_key => @my_pub_key, :subscribe_key => @my_sub_key)

        mock(@pn).check_for_em(mock_publish_request) {}
        @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message)
      end

    end

    context "#ssl" do

      it "should default to false if not defined" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)
        @pn.ssl.should == false
      end

      it "should set to true if defined at instantiation" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key, :ssl => true)
        @pn.ssl.should == true
      end


    end

    describe "#detailed_history" do

      before do
        @sub_key = "demo"
        @pn = Pubnub.new(:subscribe_key => @sub_key)
        @my_callback = lambda { |x| puts(x) }
      end

      it "should require channel" do
        lambda { @pn.detailed_history }.should raise_error(ArgumentError, "detailed_history() requires :channel, :callback, and :count options.")
      end

      it "should require callback" do
        lambda { @pn.detailed_history(:channel => :foo) }.should raise_error(ArgumentError, "detailed_history() requires :channel, :callback, and :count options.")
      end

      it "should require count" do
        lambda { @pn.detailed_history(:channel => :foo, :callback => @my_callback) }.should raise_error(ArgumentError, "detailed_history() requires :channel, :callback, and :count options.")
      end

      it "should initialize the request object correctly" do
        mock_pubnub_request = PubnubRequest.new(:subscribe_key => "demo", :callback => @my_callback, :operation => "detailed_history", :channel => "foo", :count => 10)
        mock(@pn).check_for_em(mock_pubnub_request) {}
        @pn.detailed_history(:channel => :foo, :callback => @my_callback, :count => 10)
      end

    end

    describe "#history" do

      before do
        @sub_key = "demo"
        @pn = Pubnub.new(:subscribe_key => @sub_key)
        @my_callback = lambda { |x| puts(x) }
      end

      it "should require channel" do
        lambda { @pn.history }.should raise_error(ArgumentError, "history() requires :channel, :callback, and :limit options.")
      end

      it "should require callback" do
        lambda { @pn.history(:channel => :foo) }.should raise_error(ArgumentError, "history() requires :channel, :callback, and :limit options.")
      end

      it "should require limit" do
        lambda { @pn.history(:channel => :foo, :callback => @my_callback) }.should raise_error(ArgumentError, "history() requires :channel, :callback, and :limit options.")
      end

      it "should initialize the request object correctly" do
        mock_pubnub_request = PubnubRequest.new(:subscribe_key => "demo", :callback => @my_callback, :operation => "history", :channel => "foo", :limit => 10)
        mock(@pn).check_for_em(mock_pubnub_request) {}
        @pn.history(:channel => :foo, :callback => @my_callback, :limit => 10)
      end

    end
    
    describe "#here_now" do

      before do
        @sub_key = "demo"
        @pn = Pubnub.new(:subscribe_key => @sub_key)
        @my_callback = lambda { |x| puts(x) }
      end

      it "should require channel" do
        lambda { @pn.here_now }.should raise_error(ArgumentError, "here_now() requires :channel and :callback options.")
      end

      it "should require callback" do
        lambda { @pn.here_now(:channel => :foo) }.should raise_error(ArgumentError, "here_now() requires :channel and :callback options.")
      end

      it "should initialize the request object correctly" do
        mock_pubnub_request = PubnubRequest.new(:subscribe_key => "demo", :callback => @my_callback, :operation => "here_now", :channel => "hello_world")
        mock(@pn).check_for_em(mock_pubnub_request) {}
        @pn.here_now(:channel => :hello_world, :callback => @my_callback)
      end

    end

  end

end