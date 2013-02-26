require 'spec_helper'
require 'rr'
require 'vcr'

describe "Subscribe Integration Test" do

    before do
      @my_callback = lambda { |message| Rails.logger.debug(message) }
      @pn = Pubnub.new(:subscribe_key => :demo)
    end

    context "when it is successful" do

      context "on the initial timetoken fetch" do

        context "with basic subscribe config" do

          it "should retry on a bad json response" do
            my_response = [[], "13617737325885516"]
            mock(@my_callback).call(my_response) {EM.stop}

            any_instance_of(Pubnub) do |p|
              mock.proxy(p).retryRequest(false, anything, anything, 0.5)
            end

            VCR.use_cassette("integration_subscribe_4", :record => :none) do
              @pn.subscribe(:channel => :hello_world, :callback => @my_callback)
            end

          end

          it "should allow a custom origin at subscribe time" do
            my_response = [[], "13619080213373042"]
            mock(@my_callback).call(my_response) {EM.stop}

            VCR.use_cassette("integration_subscribe_6", :record => :none) do
              @pn.subscribe(:origin => "myorigin.pubnub.com", :channel => :hello_world, :callback => @my_callback)
            end

            # Test will fail if origin breaks per VCR tape

          end

          it "should retry on a non 200 server response" do
            my_response = [[], "13617798873598999"]
            mock(@my_callback).call(my_response) {EM.stop}

            any_instance_of(Pubnub) do |p|
              mock.proxy(p).retryRequest(false, anything, anything, 1)
            end

            VCR.use_cassette("integration_subscribe_5", :record => :none) do
              @pn.subscribe(:channel => :hello_world, :callback => @my_callback)
            end

          end

          it "should sub without ssl" do
            my_response = [[], "13451632748083262"]
            mock(@my_callback).call(my_response) {EM.stop}

            VCR.use_cassette("integration_subscribe_1", :record => :none) do
              @pn.subscribe(:channel => :hello_world, :callback => @my_callback)
            end
          end

          it "should subscribe with ssl" do

            my_response = [[], "13451632748083262"]
            mock(@my_callback).call(my_response) {EM.stop}

            @pn.ssl = true

            VCR.use_cassette("integration_subscribe_3", :record => :none) do
              @pn.subscribe(:channel => :hello_world, :callback => @my_callback)
            end
          end
        end
      end

      context "on the subsequent timetoken fetch" do

        context "with basic subscribe config" do


          it "should continue with a custom origin" do
            my_response = [[], "13619080213373042"]
            mock(@my_callback).call(my_response) {}
            mock(@my_callback).call(my_response) {EM.stop}

            VCR.use_cassette("integration_subscribe_7", :record => :none) do
              @pn.subscribe(:origin => "myorigin.pubnub.com", :channel => :hello_world, :callback => @my_callback)
            end

            # Test will fail if origin breaks per VCR tape

          end


          it "should sub without ssl" do
            my_response = [[{"text" => "bo"}], "13455067954018816"]
            mock(@my_callback).call(my_response) { EM.stop}

            VCR.use_cassette("integration_subscribe_1b", :record => :none) do
              @pn.subscribe(:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13455067091198286)
            end
          end

          it "should subscribe with ssl" do

            my_response = [[{"text" => "bo"}], "13455068901569588"]
            mock(@my_callback).call(my_response) {EM.stop}

            @pn.ssl = true

            VCR.use_cassette("integration_subscribe_3b", :record => :none) do
              @pn.subscribe(:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13455068696466554)
            end
          end
        end
      end


      context "when there is a cipher key" do

        before do
          @pn.cipher_key = "enigma"
        end

        it "should subscribe without ssl (implicit)" do

          my_response = [["DECRYPTION_ERROR", "this is my superduper long encrypted message. dont tell anyone!"], "13473292476449446"]
          mock(@my_callback).call(my_response) {EM.stop}

          VCR.use_cassette("integration_subscribe_2", :record => :none) do
            @pn.subscribe(:channel => :hello_world, :message => "hi", :callback => @my_callback, :override_timetoken => 13473291856851191)
          end

        end

      end
    end

end