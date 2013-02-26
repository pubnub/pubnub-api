require 'spec_helper'
require 'rr'
require 'vcr'

describe PubnubRequest do

  before do
    @pubnub_request = PubnubRequest.new
  end

  describe "#format_url!" do
    before do
      @my_callback = lambda { |message| Rails.logger.debug(message) }
    end

    context "#port" do
      it "should set port to 80 if ssl.blank? (explicit)" do
        pubnub_request = PubnubRequest.new(:operation => "publish", :channel => :hello_world, :publish_key => :demo, :subscribe_key => :demo,
                                           :message => "hi", :callback => @my_callback, :ssl => false).format_url!

        pubnub_request.port.should == 80
      end

      it "should set port to 80 if ssl.blank? (implicit)" do
        pubnub_request = PubnubRequest.new(:operation => "publish", :channel => :hello_world, :publish_key => :demo, :subscribe_key => :demo,
                                           :message => "hi", :callback => @my_callback, :ssl => false).format_url!

        pubnub_request.port.should == 80
      end

      it "should set port to 443 if ssl.present?" do
        pubnub_request = PubnubRequest.new(:operation => "publish", :channel => :hello_world, :publish_key => :demo, :subscribe_key => :demo,
                                           :message => "hi", :callback => @my_callback, :ssl => true).format_url!

        pubnub_request.port.should == 443
      end
    end

    it "should raise if the operation is missing" do
      pubnub_request = PubnubRequest.new(:channel => :hello_world, :publish_key => :demo, :subscribe_key => :demo,
                                         :message => "hi", :callback => @my_callback)

      lambda { pubnub_request.format_url! }.should raise_error(Pubnub::PublishError, "Missing .operation in PubnubRequest object")


    end


    context "when it is a presence operation" do

      before do
        @operation = "presence"
        @pubnub_request = PubnubRequest.new(:session_uuid => "123-456", :channel => :"hello_world", :subscribe_key => :demo,
                                            :message => @message, :callback => @my_callback, :operation => @operation)
      end

      it "should set the url" do
        @pubnub_request.format_url!
        @pubnub_request.url.should == %^http://pubsub.pubnub.com/subscribe/demo/hello_world-pnpres/0/0^
      end

      it "should set the query" do
        @pubnub_request.format_url!
        @pubnub_request.query.should == %^/subscribe/demo/hello_world-pnpres/0/0?uuid=123-456^
      end
    end

    context "when it is a subscribe operation" do

      before do
        @operation = "subscribe"
        @pubnub_request = PubnubRequest.new(:session_uuid => "123-456", :channel => :hello_world, :subscribe_key => :demo,
                                            :message => @message, :callback => @my_callback, :operation => @operation)
      end

      it "should set the url" do
        @pubnub_request.format_url!
        @pubnub_request.url.should == %^http://pubsub.pubnub.com/subscribe/demo/hello_world/0/0^
      end

      it "should set the query" do
        @pubnub_request.format_url!
        @pubnub_request.query.should == %^/subscribe/demo/hello_world/0/0?uuid=123-456^
      end
    end

    context "when it is a publish operation" do

      before do
        @operation = "publish"
        @message = "hello from ruby!".to_json
        @pubnub_request = PubnubRequest.new(:session_uuid => "123-456", :channel => :hello_world, :publish_key => :demo, :subscribe_key => :demo,
                                            :message => @message, :callback => @my_callback, :operation => @operation)
      end

      it "should set the url" do
        @pubnub_request.format_url!
        @pubnub_request.url.should == %^http://pubsub.pubnub.com/publish/demo/demo/0/hello_world/0/%22hello%20from%20ruby%21%22^
      end

      it "should set the query" do
        @pubnub_request.format_url!
        @pubnub_request.query.should == %^/publish/demo/demo/0/hello_world/0/%22hello%20from%20ruby%21%22^
      end

      it "should set the origin" do
        @pubnub_request.set_origin(:origin => "foo.pubnub.com")
        @pubnub_request.format_url!
        @pubnub_request.url.should == %^http://foo.pubnub.com/publish/demo/demo/0/hello_world/0/%22hello%20from%20ruby%21%22^
      end

    end

    context "when it is a time operation" do
      before do
        @operation = "time"
        @pubnub_request = PubnubRequest.new(:session_uuid => "123-456", :callback => @my_callback, :operation => @operation)
      end

      it "should set the url" do
        @pubnub_request.format_url!
        @pubnub_request.url.should == %^http://pubsub.pubnub.com/time/0^
      end

      it "should set the query" do
        @pubnub_request.format_url!
        @pubnub_request.query.should == %^/time/0^
      end
    end


    context "when it is a history operation" do
      before do
        @operation = "history"
        @pubnub_request = PubnubRequest.new(:session_uuid => "123-456", :channel => :hello_world, :subscribe_key => :demo,
                                            :callback => @my_callback, :operation => @operation)

      end

      it "should set the url" do
        @pubnub_request.format_url!
        @pubnub_request.url.should == %^http://pubsub.pubnub.com/history/demo/hello_world/0/^
      end

      it "should set the query" do
        @pubnub_request.format_url!
        @pubnub_request.query.should == %^/history/demo/hello_world/0/^
      end

    end


    context "when it is a detailed_history operation" do
      before do
        @operation = "detailed_history"
        @pubnub_request = PubnubRequest.new(:channel => :hello_world, :subscribe_key => :demo,
                                            :callback => @my_callback, :operation => @operation)
      end

      # /v2/history/sub-key/<sub-key>/channel/<channel>
      it "should set the url" do
        @pubnub_request.format_url!
        @pubnub_request.url.should == %^http://pubsub.pubnub.com/v2/history/sub-key/demo/channel/hello_world^
      end

      context "with query parameters" do

        it "should set the query with no url params" do
          @pubnub_request.format_url!
          @pubnub_request.query.should == %^/v2/history/sub-key/demo/channel/hello_world^
        end

        it "should append a count parameter when count is present" do
          @pubnub_request.history_count = 5
          @pubnub_request.format_url!
          @pubnub_request.query.should == %^/v2/history/sub-key/demo/channel/hello_world?count=5^
        end

        it "should append a count parameter when start is present" do
          @pubnub_request.history_start = 123
          @pubnub_request.format_url!
          @pubnub_request.query.should == %^/v2/history/sub-key/demo/channel/hello_world?start=123^
        end

        it "should append a count parameter when end is present" do
          @pubnub_request.history_end = 456
          @pubnub_request.format_url!
          @pubnub_request.query.should == %^/v2/history/sub-key/demo/channel/hello_world?end=456^
        end

        it "should append a count parameter when reverse is true" do
          @pubnub_request.history_reverse = true
          @pubnub_request.format_url!
          @pubnub_request.query.should == %^/v2/history/sub-key/demo/channel/hello_world?reverse=true^
        end

        it "should append a count parameter when reverse is false" do
          @pubnub_request.history_reverse = false
          @pubnub_request.format_url!
          @pubnub_request.query.should == %^/v2/history/sub-key/demo/channel/hello_world^
        end

        it "should append a count and start parameter" do
          @pubnub_request.history_count = 10
          @pubnub_request.history_start = 999
          @pubnub_request.format_url!
          @pubnub_request.query.should == %^/v2/history/sub-key/demo/channel/hello_world?count=10&start=999^
        end

        it "should append a start and end parameter" do
          @pubnub_request.history_end = 10
          @pubnub_request.history_start = 999
          @pubnub_request.format_url!
          @pubnub_request.query.should == %^/v2/history/sub-key/demo/channel/hello_world?start=999&end=10^
        end

        it "should append a start and end and reverse = true parameter" do
          @pubnub_request.history_end = 10
          @pubnub_request.history_start = 999
          @pubnub_request.history_reverse = true
          @pubnub_request.format_url!
          @pubnub_request.query.should == %^/v2/history/sub-key/demo/channel/hello_world?start=999&end=10&reverse=true^
        end

        it "should append a start and end and reverse = false parameter" do
          @pubnub_request.history_end = 10
          @pubnub_request.history_start = 999
          @pubnub_request.history_reverse = false
          @pubnub_request.format_url!
          @pubnub_request.query.should == %^/v2/history/sub-key/demo/channel/hello_world?start=999&end=10^
        end
      end
    end

  end


  describe "#set_subscribe_key" do

    it "should throw if the subscribe_key is not set" do
      @pubnub_request.message.should == nil

      options = {}
      self_subscribe_key = nil

      lambda { @pubnub_request.set_subscribe_key(options, self_subscribe_key).should == "0" }.should raise_error(PubnubRequest::RequestError, "subscribe_key is a required parameter.")
    end

    it "should not let you override a previously set subscribe_key" do
      @pubnub_request.message.should == nil

      options = {:subscribe_key => "my_key"}
      self_subscribe_key = "foo"

      lambda { @pubnub_request.set_subscribe_key(options, self_subscribe_key) }.should raise_error(PubnubRequest::RequestError, "existing subscribe_key #{self_subscribe_key} cannot be overridden at subscribe-time.")
    end

    it "should set the subscribe_key when self_subscribe_key is set" do
      @pubnub_request.message.should == nil

      options = {:subscribe_key => "my_self_key"}
      self_subscribe_key = nil

      @pubnub_request.set_subscribe_key(options, self_subscribe_key).should == "my_self_key"
    end

    it "should set the subscribe_key when hash_subscribe_key is set" do
      @pubnub_request.message.should == nil

      options = {}
      self_subscribe_key = "my_self_key"

      @pubnub_request.set_subscribe_key(options, self_subscribe_key).should == "my_self_key"
    end

  end

  describe "#set_publish_key" do

    it "should throw if the publish_key is not set" do
      @pubnub_request.message.should == nil

      options = {}
      self_publish_key = nil

      lambda { @pubnub_request.set_publish_key(options, self_publish_key).should == "0" }.should raise_error(Pubnub::PublishError, "publish_key is a required parameter.")
    end

    it "should not let you override a previously set publish_key" do
      @pubnub_request.message.should == nil

      options = {:publish_key => "my_key"}
      self_publish_key = "foo"

      lambda { @pubnub_request.set_publish_key(options, self_publish_key) }.should raise_error(Pubnub::PublishError, "existing publish_key #{self_publish_key} cannot be overridden at publish-time.")
    end

    it "should set the publish_key when self_publish_key is set" do
      @pubnub_request.message.should == nil

      options = {:publish_key => "my_self_key"}
      self_publish_key = nil

      @pubnub_request.set_publish_key(options, self_publish_key).should == "my_self_key"
    end

    it "should set the publish_key when hash_publish_key is set" do
      @pubnub_request.message.should == nil

      options = {}
      self_publish_key = "my_self_key"

      @pubnub_request.set_publish_key(options, self_publish_key).should == "my_self_key"
    end

  end

  describe "#set_request_cipher_key" do

    it "should not let you override a previously set cipher_key" do
      @pubnub_request.message.should == nil

      options = {:cipher_key => "my_key"}
      self_cipher_key = "foo"

      lambda { @pubnub_request.set_cipher_key(options, self_cipher_key) }.should raise_error(PubnubRequest::RequestError, "existing cipher_key foo cannot be overridden at publish-time.")
    end

    it "should let you define a cipher_key if one was not previously set" do
      @pubnub_request.message.should == nil

      options = {:cipher_key => "my_key"}
      self_cipher_key = nil

      @pubnub_request.set_cipher_key(options, self_cipher_key).should == "my_key"

    end

    it "should set the secret key to nil if it is not set" do
      @pubnub_request.message.should == nil

      options = {}
      self_cipher_key = nil

      @pubnub_request.set_cipher_key(options, self_cipher_key).should == nil

    end

  end

  describe "#set_request_secret_key" do

    it "should not let you override a previously set secret_key" do
      @pubnub_request.message.should == nil

      options = {:secret_key => "my_key"}
      self_secret_key = "foo"

      lambda { @pubnub_request.set_secret_key(options, self_secret_key) }.should raise_error(Pubnub::PublishError, "existing secret_key foo cannot be overridden at publish-time.")
    end

    it "should let you define a secret key if one was not previously set" do
      @pubnub_request.message.should == nil

      options = {:secret_key => "my_key"}
      self_secret_key = nil

      @pubnub_request.set_secret_key(options, self_secret_key).should == "fb448a1554675dcb9898d08073ceec717145de84cd8e36f1d471202b94487da7"

    end

    it "should set the secret key to 0 string if it is not set" do
      @pubnub_request.message.should == nil

      options = {}
      self_secret_key = nil

      @pubnub_request.set_secret_key(options, self_secret_key).should == "0"

    end

  end

  describe "#set_message" do
    context "when the message is nil" do
      it "should throw on a missing message" do
        @pubnub_request.message.should == nil

        options = {}
        lambda { @pubnub_request.set_message(options, nil) }.should raise_error(PubnubRequest::RequestError)
      end
    end

    context "when there is a cipher key" do
      it "should set the message" do
        @pubnub_request.message.should == nil

        options = {:message => "Pubnub Messaging API 1"}
        self_cipher_key = "enigma"

        @pubnub_request.set_message(options, self_cipher_key)
        @pubnub_request.message.should == "\"f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0=\""
      end
    end

    context "when there is not a cipher key" do
      it "should set the message" do

        @pubnub_request.message.should == nil

        options = {:message => "my_message"}
        self_cipher_key = ""

        @pubnub_request.set_message(options, self_cipher_key)
        @pubnub_request.message.should == %^"my_message"^
      end
    end
  end

  describe "#set_channel" do
    it "should set the channel" do
      @pubnub_request.channel.should == nil

      options = {:channel => "my_channel"}

      @pubnub_request.set_channel(options)
      @pubnub_request.channel.should == "my_channel"
    end

    it "should throw on a missing channel" do
      @pubnub_request.channel.should == nil

      options = {}
      lambda { @pubnub_request.set_channel(options) }.should raise_error(PubnubRequest::RequestError)

    end
  end


  describe "#set_error" do
    it "should set the error" do
      @pubnub_request.error.should == nil

      options = {:error => true}

      @pubnub_request.set_error(options)
      @pubnub_request.error.should == true
    end

    it "should should be not true by default" do
      @pubnub_request.error.should_not == true
    end

  end

  describe "#set_callback" do

    it "should set the callback" do
      @pubnub_request.callback.should == nil

      callback = lambda { |m| puts(m) }
      options = {:callback => callback}

      @pubnub_request.set_callback(options)
      @pubnub_request.callback.should == callback
    end

    it "should throw on an invalid callback" do
      @pubnub_request.callback.should == nil

      callback = "hi"
      options = {:callback => callback}

      lambda { @pubnub_request.set_callback(options) }.should raise_error(PubnubRequest::RequestError)

    end

    it "should throw on a missing callback" do
      @pubnub_request.callback.should == nil

      callback = nil
      options = {:callback => callback}

      lambda { @pubnub_request.set_callback(options) }.should raise_error(PubnubRequest::RequestError)

    end
  end


end