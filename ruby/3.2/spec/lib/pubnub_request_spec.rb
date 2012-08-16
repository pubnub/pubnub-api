require 'spec_helper'
require 'rr'
require 'vcr'

describe PubnubRequest do

  before do
    @pubnub_request = PubnubRequest.new
  end

  describe "#set_publish_key" do

    it "should throw if the publish_key is not set" do
      @pubnub_request.message.should == nil

      options = {}
      self_publish_key = nil

      lambda {  @pubnub_request.set_publish_key(options, self_publish_key).should == "0" }.should raise_error(Pubnub::PublishError, "publish_key is a required parameter.")
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

      options = { }
      self_publish_key = "my_self_key"

      @pubnub_request.set_publish_key(options, self_publish_key).should == "my_self_key"
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
        lambda { @pubnub_request.set_message(options, nil) }.should raise_error(Pubnub::PublishError)
      end
    end

    context "when there is a cipher key" do
      it "should set the message" do
        @pubnub_request.message.should == nil

        options = {:message => "my_message"}
        self_cipher_key = "foo"

        @pubnub_request.set_message(options, self_cipher_key)
        @pubnub_request.message.should == %^"opISGN77KPWGBB2wP/djBQ=="^
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
      lambda { @pubnub_request.set_channel(options) }.should raise_error(Pubnub::PublishError)

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

      lambda { @pubnub_request.set_callback(options) }.should raise_error(Pubnub::PublishError)

    end

    it "should throw on a missing callback" do
      @pubnub_request.callback.should == nil

      callback = nil
      options = {:callback => callback}

      lambda { @pubnub_request.set_callback(options) }.should raise_error(Pubnub::PublishError)

    end
  end


end