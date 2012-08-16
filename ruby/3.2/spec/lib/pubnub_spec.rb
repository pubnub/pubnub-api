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
        mock(@pn)._request(mock_pubnub_request) {}

        @pn.time(:callback => @my_callback)
      end

      it "should allow for a string" do
        mock_pubnub_request = PubnubRequest.new(:callback => @my_callback, :operation => "time")
        mock(@pn)._request(mock_pubnub_request) {}

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

  end

  describe "#publish" do

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
        mock(@pn)._request(mock_publish_request) {}

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

        mock(@pn)._request(mock_publish_request) {}
        @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :secret_key => @my_sec_key)
      end


      it "should publish without signing the message if you publish without a secret key" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)

        mock_publish_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel, :message => @my_message.to_json,
                                                 :operation => :publish, :publish_key => @my_pub_key, :subscribe_key => @my_sub_key)

        mock(@pn)._request(mock_publish_request) {}
        @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message)
      end

    end

    context "cipher key" do

      it "should let you override an existing instantiated cipher key" do

        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key, :cipher_key => @my_cipher_key)
        alt_cipher_key = "alt_cipher_key"

        # TODO: generate this from the pn encryption instance method, mock the response

        encrypted_message = "\"2s0JT2eBNrM3jQaaTVatog==\""

        mock_publish_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel, :message => encrypted_message,
                                                 :operation => :publish, :publish_key => @my_pub_key, :subscribe_key => @my_sub_key,
                                                 :secret_key => "0", :cipher_key => alt_cipher_key)

        mock(@pn)._request(mock_publish_request) {}
        @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :cipher_key => alt_cipher_key)

      end


      it "should let you define a cipher key at publish time if it was not instantiated with one" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)
        encryped_message = "\"h6lDpklaNSzEEdrahmpQjA==\""

        mock_publish_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel, :message => encryped_message,
                                                 :operation => :publish, :publish_key => @my_pub_key, :subscribe_key => @my_sub_key,
                                                 :cipher_key => @my_cipher_key)

        mock(@pn)._request(mock_publish_request) {}
        @pn.publish(:channel => @my_channel, :callback => @my_callback, :message => @my_message, :cipher_key => @my_cipher_key)
      end


      it "should publish without a cipher key" do
        @pn = Pubnub.new(:subscribe_key => @my_sub_key, :publish_key => @my_pub_key)

        mock_publish_request = PubnubRequest.new(:callback => @my_callback, :channel => @my_channel, :message => @my_message.to_json,
                                                 :operation => :publish, :publish_key => @my_pub_key, :subscribe_key => @my_sub_key)

        mock(@pn)._request(mock_publish_request) {}
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


    context "integration publish test" do

      before do
        @my_callback = lambda { |message| Rails.logger.debug(message) }
        @pn = Pubnub.new(:publish_key => :demo, :subscribe_key => :demo)
      end

      context "when it is successful" do

        context "with basic publish config" do

          it "should publish without ssl" do
            my_response = [1, "Sent", "13450923394327693"]
            mock(@my_callback).call(my_response) {}

            VCR.use_cassette("integration_publish_1", :record => :none) do
              @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
            end
          end

          it "should publish with ssl" do

            my_response = [1, "Sent", "13451428018571368"]
            mock(@my_callback).call(my_response) {}

            @pn.ssl = true

            VCR.use_cassette("integration_publish_3", :record => :none) do
              @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
            end
          end

        end


        context "when there is a cipher key" do

          before do
            @pn.cipher_key = "enigma"
          end

          it "should publish without ssl (implicit)" do

            my_response = [1, "Sent", "13451424376740954"]
            mock(@my_callback).call(my_response) {}

            VCR.use_cassette("integration_publish_2", :record => :none) do
              @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
            end

          end

          it "should publish without ssl (explicit)" do

            my_response = [1, "Sent", "13451424376740954"]
            mock(@my_callback).call(my_response) {}

            @pn.ssl = false

            VCR.use_cassette("integration_publish_2", :record => :none) do
              @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
            end

          end

          context "ssl on" do

            context "message signing off" do

              it "should publish" do

                my_response = [1, "Sent", "13451474646150471"]
                mock(@my_callback).call(my_response) {}

                @pn.ssl = true
                @pn.secret_key = nil

                VCR.use_cassette("integration_publish_4", :record => :none) do
                  @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
                end
              end

            end

            context "message signing on" do

              it "should publish" do

                my_response = [1, "Sent", "13451476456534121"]
                mock(@my_callback).call(my_response) {}

                @pn.ssl = true
                @pn.secret_key = "itsmysecret"

                VCR.use_cassette("integration_publish_5", :record => :none) do
                  @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
                end
              end

            end

          end


        end

        context "when message signing is on" do

          before do
            @pn.secret_key = "enigma"
          end

          it "should publish without ssl (implicit)" do

            my_response = [1, "Sent", "13451493026321630"]
            mock(@my_callback).call(my_response) {}

            VCR.use_cassette("integration_publish_6", :record => :none) do
              @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
            end

          end

          it "should publish without ssl (explicit)" do

            my_response = [1, "Sent", "13451494117873005"]
            mock(@my_callback).call(my_response) {}

            @pn.ssl = false

            VCR.use_cassette("integration_publish_7", :record => :none) do
              @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
            end

          end

          context "ssl on" do

            context "cipher key off" do

              it "should publish" do

                my_response = [1, "Sent", "13451493874063684"]
                mock(@my_callback).call(my_response) {}

                @pn.ssl = true
                @pn.cipher_key = nil

                VCR.use_cassette("integration_publish_8", :record => :none) do
                  @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
                end
              end

            end

            context "cipher key on" do

              it "should publish" do

                my_response = [1, "Sent", "13451494427815122"]
                mock(@my_callback).call(my_response) {}

                @pn.ssl = true
                @pn.cipher_key = "itsmysecret"

                VCR.use_cassette("integration_publish_9", :record => :none) do
                  @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
                end
              end

            end
          end
        end
      end
    end
  end
end