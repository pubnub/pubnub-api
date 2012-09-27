# encoding: utf-8

require 'spec_helper'
require 'rr'
require 'vcr'

describe "History V2 Integration Test" do

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

          my_response = [[], 0, 0]
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_detailed_history_2", :record => :none) do
            @pn.detailed_history(:cipher_key => "enigma", :channel => @no_history_channel, :count => 10, :callback => @my_callback)
          end

        end
      end

      context "when not using a cipher_key" do

        it "should return the correct response" do

          my_response = [[], 0, 0]
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_detailed_history_1", :record => :none) do
            @pn.detailed_history(:channel => @no_history_channel, :count => 10, :callback => @my_callback)
          end

        end
      end

    end

    context "when there is history" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response =   [["this is my superduper long encrypted message. dont tell anyone!", {"foo"=>"bar"}, {"foo"=>"bar"}, {"foo"=>"hahahahah"}, "DECRYPTION_ERROR"], 13473942988885387, 13473943634298512]

          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_detailed_history_4", :record => :none) do
            @pn.detailed_history(:cipher_key => "enigma", :channel => @history_channel, :count => 5, :callback => @my_callback)
          end

        end
      end
      context "when not using a cipher_key" do

          it "should return the correct response" do

            my_response = [[{"text"=>"hi"}, "and", "bye", "bye", "Hello World", ["seven", "eight", {"food"=>"Cheeseburger", "drink"=>"Coffee"}], {"Editer"=>"X-code->ÇÈ°∂@\#$%^&*()!", "Language"=>"Objective-c"}, {"Editer"=>"X-code->ÇÈ°∂@\#$%^&*()!", "Language"=>"Objective-c"}, "bye", "bye", "bye", "bye", "bye", "bye", "bye"], 13469689662605929, 13469738465138144]

            mock(@my_callback).call(my_response) {}

            VCR.use_cassette("integration_detailed_history_3", :record => :none) do
              @pn.detailed_history(:channel => @history_channel, :count => 15, :reverse => true, :callback => @my_callback)
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

          my_response = [[], 0, 0]
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_detailed_history_2a", :record => :none) do
            @pn.detailed_history(:cipher_key => "enigma", :channel => @no_history_channel, :count => 3, :callback => @my_callback)
          end

        end
      end

      context "when not using a cipher_key" do

        it "should return the correct response" do

          my_response = [[], 0, 0]
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_detailed_history_1a", :record => :none) do
            @pn.detailed_history(:channel => @no_history_channel, :count => 4, :start => 3, :end => 10, :reverse => false, :callback => @my_callback)
          end
        end
      end
    end

    context "when there is history" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response =   [["this is my superduper long encrypted message. dont tell anyone!", "Pubnub Messaging API 1", "Pubnub Messaging API 2", "漢語", {"this stuff"=>{"can get"=>"complicated!"}}, [], "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", {"foo"=>"bar"}, "this is my superduper long encrypted message. dont tell anyone!", {"foo"=>"bar"}, {"foo"=>"bar"}, {"foo"=>"hahahahah"}, "DECRYPTION_ERROR"], 13473292476449446, 13473943634298512]

          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_detailed_history_4a", :record => :none) do
            @pn.detailed_history(:cipher_key => "enigma", :channel => @history_channel, :count => 30, :reverse => false, :callback => @my_callback)
          end

        end
      end
      context "when not using a cipher_key" do

        it "should return the correct response" do

          my_response =   [[{"text"=>"hi"}, "and", "bye", "bye", "Hello World", ["seven", "eight", {"food"=>"Cheeseburger", "drink"=>"Coffee"}], {"Editer"=>"X-code->ÇÈ°∂@\#$%^&*()!", "Language"=>"Objective-c"}, {"Editer"=>"X-code->ÇÈ°∂@\#$%^&*()!", "Language"=>"Objective-c"}, "bye", "bye", "bye", "bye", "bye", "bye", "bye", {"bye"=>2}, {"bye"=>2}, ["seven", "eight", {"food"=>"Cheeseburger", "drink"=>"Coffee"}], ["seven", "eight", {"food"=>"Cheeseburger", "drink"=>"Coffee"}], ["seven", "eight", {"food"=>"Cheeseburger", "drink"=>"Coffee"}]], 13469689662605929, 13469739851798076]

          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_detailed_history_3a", :record => :none) do
            @pn.detailed_history(:channel => @history_channel, :count => 20, :reverse => true, :callback => @my_callback)
          end

        end
      end

    end

  end



end
