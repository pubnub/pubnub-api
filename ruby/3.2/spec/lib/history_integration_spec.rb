require 'spec_helper'
require 'rr'
require 'vcr'

describe "History Integration Test" do

  before do
    @my_sub_key = :demo
    @pn = Pubnub.new(:subscribe_key => @my_sub_key)
    @my_callback = lambda { |x| puts(x) }

    @no_history_channel = "no_history"
    @history_channel = "hello_world"
  end

  context "when not using ssl" do

    context "when there is no history" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = []
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_history_2", :record => :none) do
            @pn.history(:cipher_key => "enigma", :channel => @no_history_channel, :limit => 10, :callback => @my_callback)
          end

        end
      end

      context "when not using a cipher_key" do

        it "should return the correct response" do

          my_response = []
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_history_1", :record => :none) do
            @pn.history(:channel => @no_history_channel, :limit => 10, :callback => @my_callback)
          end

        end
      end

    end

    context "when there is history" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = []
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_history_4", :record => :none) do
            @pn.history(:cipher_key => "enigma", :channel => @history_channel, :limit => 10, :callback => @my_callback)
          end

        end
      end
      context "when not using a cipher_key" do

          it "should return the correct response" do

            my_response = []
            mock(@my_callback).call(my_response) {}

            VCR.use_cassette("integration_history_3", :record => :none) do
              @pn.history(:channel => @history_channel, :limit => 10, :callback => @my_callback)
            end

        end
      end

    end

  end

  #context "when using ssl" do
  #
  #  context "when there is no history" do
  #
  #    context "when using a cipher_key" do
  #      it "should return the correct response"
  #    end
  #    context "when not using a cipher_key" do
  #      it "should return the correct response"
  #    end
  #
  #  end
  #
  #  context "when there is history" do
  #
  #    context "when using a cipher_key" do
  #      it "should return the correct response"
  #    end
  #    context "when not using a cipher_key" do
  #      it "should return the correct response"
  #    end
  #
  #  end
  #
  #end
end
