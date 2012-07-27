require 'spec_helper'
require 'rr'
require 'vcr'

describe Pubnub do

  describe ".initialize" do

    before do
      @publish_key = "demo_pub_key"
      @subscribe_key = "demo_sub_key"
      @secret_key = "demo_md5_key"
      @cipher_key = "demo_cipher_key"
      @ssl_enabled = false
      @channel = "pn_test"
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
        lambda { pn.verify_config }.should_not raise_error
      end

      it "should not throw an exception if present" do
        pn = Pubnub.new(:subscribe_key => :bar)
        lambda { pn.verify_config }.should_not raise_error
      end
    end
  end

  describe "#time" do
    before do
      @pn = Pubnub.new(:publish_key => :demo)
      @my_callback = lambda { |message| Rails.logger.debug(message) }
    end

    context "should enforce a callback parameter" do

      it "should raise with no callback parameter" do
        lambda { @pn.time(:foo => :bar) }.should raise_error
      end

      it "should allow for a symbol" do
        mock(@pn)._request({"callback" => @my_callback, "request" => ["time", "0"]}) {}
        @pn.time(:callback => @my_callback)
      end

      it "should allow for a string" do
        mock(@pn)._request({"callback" => @my_callback, "request" => ["time", "0"]}) {}
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

  describe "#publish" do

    before do

      @my_callback = lambda { |message| Rails.logger.debug(message) }
      @my_pub_key = "demo_pub_key"
      @my_sub_key = "demo_sub_key"
      @my_message = "hello_world!"
      @my_channel = "demo_channel"

      @pn = Pubnub.new(:subscribe_key => @my_sub_key)

    end

    context "required parameters" do
      it "should raise when channel is missing" do
        lambda { @pn.publish(:message => @my_message) }.should raise_error(Pubnub::PublishError, "channel is a required parameter.")
      end

      it "should raise when callback is missing" do
        lambda { @pn.publish(:message => @my_message, :channel => @my_channel) }.should raise_error(Pubnub::PublishError, "callback is a required parameter.")
      end

      it "should raise when callback is invalid" do
        lambda { @pn.publish(:message => @my_message, :channel => @my_channel, :callback => :blah) }.should raise_error(Pubnub::PublishError, "callback is invalid.")
      end

      it "should raise when message is missing" do
        lambda { @pn.publish(:channel => @my_channel, :callback => @my_callback) }.should raise_error(Pubnub::PublishError, "message is a required parameter.")
      end
    end

    context "publish key" do
      it "should let you override an existing instantiated publish key" do

        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)

        @request = [] << "publish" << @my_pub_key << @my_sub_key << "0" << @my_channel << "0" << (@my_message.to_json)
        @alt_pub_key = "alt_pub_key"

        @options = HashWithIndifferentAccess.new({"channel" => @my_channel,
                                                  "callback" => @my_callback,
                                                  "message" => @my_message,
                                                  "publish_key" => @alt_pub_key,
                                                  "request" => @request})

        mock(@pn)._request(@options) {}
        @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :publish_key => @alt_pub_key)
      end

      it "should let you define a publish key at publish time if it was not instantiated with one" do

        @pn = Pubnub.new(:subscribe_key => @my_sub_key)

        @request = [] << "publish" << "" << @my_sub_key << "0" << @my_channel << "0" << (@my_message.to_json)
        @alt_pub_key = "alt_pub_key"

        @options = HashWithIndifferentAccess.new({"channel" => @my_channel,
                                                  "callback" => @my_callback,
                                                  "message" => @my_message,
                                                  "publish_key" => @alt_pub_key,
                                                  "request" => @request})

        mock(@pn)._request(@options) {}
        @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :publish_key => @alt_pub_key)

      end

      it "should throw if you publish without a publish key" do

        @pn = Pubnub.new(:subscribe_key => @my_sub_key)

        @request = [] << "publish" << "" << @my_sub_key << "0" << @my_channel << "0" << (@my_message.to_json)

        @options = HashWithIndifferentAccess.new({"channel" => @my_channel,
                                                  "callback" => @my_callback,
                                                  "message" => @my_message,
                                                  "publish_key" => "",
                                                  "request" => @request})

        lambda { @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :publish_key => @alt_pub_key) }.should raise_error(Pubnub::PublishError, "publish_key is a required parameter.")
      end


    end

    context "secret key" do
      it "should let you override an existing instantiated secret key"
      it "should let you define a publish key at publish time if it was not instantiated with one"
      it "should publish without signing the message if you publish without a secret key"
    end

    context "ssl" do
      it "should default to false if not defined"
    end

  end

end