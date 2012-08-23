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

          it "should sub without ssl" do
            my_response = [[], "13451632748083262"]
            mock(@my_callback).call(my_response) {}

            VCR.use_cassette("integration_subscribe_1", :record => :none) do
              @pn.subscribe(:channel => :hello_world, :callback => @my_callback)
            end
          end

          it "should subscribe with ssl" do

            my_response = [[], "13451632748083262"]
            mock(@my_callback).call(my_response) {}

            @pn.ssl = true

            VCR.use_cassette("integration_subscribe_3", :record => :none) do
              @pn.subscribe(:channel => :hello_world, :callback => @my_callback)
            end
          end
        end
      end

      context "on the subsequent timetoken fetch" do

        context "with basic subscribe config" do

          it "should sub without ssl" do
            my_response = [[{"text" => "bo"}], "13455067954018816"]
            mock(@my_callback).call(my_response) {}

            VCR.use_cassette("integration_subscribe_1b", :record => :none) do
              @pn.subscribe(:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13455067091198286)
            end
          end

          it "should subscribe with ssl" do

            my_response = [[{"text" => "bo"}], "13455068901569588"]
            mock(@my_callback).call(my_response) {}

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

          my_response = [["hello"], "13455305163038924"]
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_subscribe_2", :record => :none) do
            @pn.subscribe(:channel => :hello_world, :message => "hi", :callback => @my_callback, :override_timetoken => 13455304919137038)
          end

        end

        it "should subscribe without ssl (explicit)" do

          my_response = [["hello"], "13455305163038924"]
          mock(@my_callback).call(my_response) {}

          @pn.ssl = false

          VCR.use_cassette("integration_subscribe_2", :record => :none) do
            @pn.subscribe(:channel => :hello_world, :message => "hi", :callback => @my_callback, :override_timetoken => 13455304919137038)
          end

        end
      end
    end

end