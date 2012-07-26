require 'spec_helper'

describe "initialize" do

  before do
    @publish_key = "demo_pub_key"
    @subscribe_key = "demo_sub_key"
    @secret_key = "demo_md5_key"
    @cipher_key = "demo_cipher_key"
    @ssl_enabled = false
    @channel = "pn_test"
  end

  context "parameters" do

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

    end
  end
end