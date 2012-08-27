require 'spec_helper'
require 'rr'
require 'vcr'

describe PubnubRequest do

  before do
    @pubnub_request = PubnubRequest.new
  end

  describe "#set_message" do

    it "should set the message" do
      @pubnub_request.message.should == nil

      options = {:message => "my_message"}

      @pubnub_request.set_message(options)
      @pubnub_request.message.should == "my_message"
    end

    #it "should throw on a missing message" do
    #  @pubnub_request.message.should == nil
    #
    #  options = {}
    #  lambda { @pubnub_request.set_message(options) }.should raise_error(Pubnub::PublishError)
    #
    #end

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

      callback = lambda { |m| puts(m)}
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