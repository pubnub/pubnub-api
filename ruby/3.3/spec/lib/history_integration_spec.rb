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

          my_response = ["DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "this is my superduper long encrypted message. dont tell anyone!", "this is my superduper long encrypted message. dont tell anyone!", "hi!", {"foo"=>"bar"}, "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR"]
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_history_4", :record => :none) do
            @pn.history(:cipher_key => "enigma", :channel => @history_channel, :limit => 10, :callback => @my_callback)
          end

        end
      end
      context "when not using a cipher_key" do

          it "should return the correct response" do

            my_response = ["lc5uKVSourn2HAdKjibN5Q==", "6xF+winkQUvBrdnUcPlJTA==", "GT6WFmFEa2se9lFGN4WpCg==", "vtgMlQHvsTzC1iK0GpzX8Q==", "87VzsxKXVhbeag0w8YcnQA==", "7Dh3P5+9obPrsGWTpro4zA==", "sAiMkWxQs9bLKT987QyGew==", {"text"=>"hey"}, "yay", 1]
            mock(@my_callback).call(my_response) {}

            VCR.use_cassette("integration_history_3", :record => :none) do
              @pn.history(:channel => @history_channel, :limit => 10, :callback => @my_callback)
            end

        end
      end

    end

  end


  context "when using ssl" do

    before do
      @pn.ssl = true
    end

    context "when there is no history" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = []
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_history_2a", :record => :none) do
            @pn.history(:cipher_key => "enigma", :channel => @no_history_channel, :limit => 10, :callback => @my_callback)
          end

        end
      end

      context "when not using a cipher_key" do

        it "should return the correct response" do

          my_response = []
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_history_1a", :record => :none) do
            @pn.history(:channel => @no_history_channel, :limit => 10, :callback => @my_callback)
          end

        end
      end

    end

    context "when there is history" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = ["DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "this is my superduper long encrypted message. dont tell anyone!", "this is my superduper long encrypted message. dont tell anyone!", "hi!", {"foo"=>"bar"}, "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR"]
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_history_4a", :record => :none) do
            @pn.history(:cipher_key => "enigma", :channel => @history_channel, :limit => 10, :callback => @my_callback)
          end

        end
      end
      context "when not using a cipher_key" do

        it "should return the correct response" do

          my_response = ["9i3mZPQSM/1oWFHEnk/ePA==", "2F87t6YX1sYTa7UB/JPZuw==", "FoOj1qJougRs0ipQWoC2Lw==", "B3rnhs8YN23zMI5AgBNa8g==", "4fUVKf/qQqIJjzfEAbPRJw==", "sJYvOBgbTFhmG/PiGm5M3Q==", "SOrWBrdLaQAj2GyGuK12hA==", "NknCcdMyrUGGCeoTW1IDog==", {"my"=>"obj"}, "doo"]
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_history_3a", :record => :none) do
            @pn.history(:channel => @history_channel, :limit => 10, :callback => @my_callback)
          end

        end
      end

    end

  end



end
