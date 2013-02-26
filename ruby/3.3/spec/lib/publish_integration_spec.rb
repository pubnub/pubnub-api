require 'spec_helper'
require 'rr'
require 'vcr'

describe "Publish Integration Test" do

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

      it "should publish without ssl with custom origin" do
        my_response = [1, "Sent", "13619174360247577"]
        mock(@my_callback).call(my_response) {}

        VCR.use_cassette("integration_publish_10", :record => :none) do
          @pn.publish(:origin => "a.pubnub.com", :channel => :hello_world, :message => "hi", :callback => @my_callback)
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

        my_response = [1, "Sent", "13473285565926387"]
        mock(@my_callback).call(my_response) {}

        VCR.use_cassette("integration_publish_2", :record => :none) do
          @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
        end

      end

      it "should publish without ssl (explicit)" do

        my_response = [1, "Sent", "13473285565926387"]
        mock(@my_callback).call(my_response) {}

        @pn.ssl = false

        VCR.use_cassette("integration_publish_2", :record => :none) do
          @pn.publish(:channel => :hello_world, :message => "hi", :callback => @my_callback)
        end

      end

      context "ssl on" do

        context "message signing off" do

          it "should publish" do

            my_response = [1, "Sent", "13473286442585026"]
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

            my_response = [1, "Sent", "13473288269652075"]
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

            my_response = [1, "Sent", "13473284333280114"]
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