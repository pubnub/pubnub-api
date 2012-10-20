require 'spec_helper'
require 'rr'
require 'vcr'
require 'em_request_helper'

describe "History Integration Test" do

  before do
    @my_sub_key = :demo
    @my_callback = lambda { |x| puts(x) }

    @no_history_channel = "no_history"
    @history_channel = "hello_world"
  end

  context "when not using ssl" do

    context "when there is no history" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = []
          options = {:cipher_key => "enigma", :channel => @no_history_channel, :limit => 10, :callback => @my_callback}

          VCR.use_cassette("integration_history_2", :record => :none) do
            EventMachine.run {
              http = EM::HttpRequest.new(create_history_request(options, @my_sub_key).url).get(:keepalive => true, :timeout=> 310)
              http.errback{ failed(http) }
              http.callback {
                http.response_header.status.should == 200
                Yajl::Parser.parse(http.response).should == my_response
                EventMachine.stop
              }
            }
          end

        end
      end

      context "when not using a cipher_key" do

        it "should return the correct response" do

          my_response = []
          options = {:channel => @no_history_channel, :limit => 10, :callback => @my_callback}

          VCR.use_cassette("integration_history_1", :record => :none) do
            EventMachine.run {
              http = EM::HttpRequest.new(create_history_request(options, @my_sub_key).url).get(:keepalive => true, :timeout=> 310)
              http.errback{ failed(http) }
              http.callback {
                http.response_header.status.should == 200
                Yajl::Parser.parse(http.response).should == my_response
                EventMachine.stop
              }
            }
          end

        end
      end

    end

    context "when there is history" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = ["DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "this is my superduper long encrypted message. dont tell anyone!", "this is my superduper long encrypted message. dont tell anyone!", "hi!", {"foo"=>"bar"}, "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR"]
          options = {:cipher_key => "enigma", :channel => @history_channel, :limit => 10, :callback => @my_callback}

          VCR.use_cassette("integration_history_4", :record => :none) do
            EventMachine.run {
              req = create_history_request(options, @my_sub_key)
              http = EM::HttpRequest.new(req.url).get(:keepalive => true, :timeout=> 310)
              http.errback{ failed(http) }
              http.callback {
                http.response_header.status.should == 200
                req.package_response!(http.response)
                req.response.should == my_response
                EventMachine.stop
              }
            }
          end

        end
      end
      context "when not using a cipher_key" do

          it "should return the correct response" do

            my_response = ["lc5uKVSourn2HAdKjibN5Q==", "6xF+winkQUvBrdnUcPlJTA==", "GT6WFmFEa2se9lFGN4WpCg==", "vtgMlQHvsTzC1iK0GpzX8Q==", "87VzsxKXVhbeag0w8YcnQA==", "7Dh3P5+9obPrsGWTpro4zA==", "sAiMkWxQs9bLKT987QyGew==", {"text"=>"hey"}, "yay", 1]
            options = {:channel => @history_channel, :limit => 10, :callback => @my_callback}

            VCR.use_cassette("integration_history_3", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_history_request(options, @my_sub_key).url).get(:keepalive => true, :timeout=> 310)
                http.errback{ failed(http) }
                http.callback {
                  http.response_header.status.should == 200
                  Yajl::Parser.parse(http.response).should == my_response
                  EventMachine.stop
                }
              }
            end

        end
      end

    end

  end


  context "when using ssl" do

    context "when there is no history" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = []
          options = {:cipher_key => "enigma", :channel => @no_history_channel, :limit => 10, :callback => @my_callback}

          VCR.use_cassette("integration_history_2a", :record => :none) do
            EventMachine.run {
              http = EM::HttpRequest.new(create_history_request(options, @my_sub_key, true).url).get(:keepalive => true, :timeout=> 310)
              http.errback{ failed(http) }
              http.callback {
                http.response_header.status.should == 200
                Yajl::Parser.parse(http.response).should == my_response
                EventMachine.stop
              }
            }
          end

        end
      end

      context "when not using a cipher_key" do

        it "should return the correct response" do

          my_response = []
          options = {:channel => @no_history_channel, :limit => 10, :callback => @my_callback}

          VCR.use_cassette("integration_history_1a", :record => :none) do
            EventMachine.run {
              http = EM::HttpRequest.new(create_history_request(options, @my_sub_key, true).url).get(:keepalive => true, :timeout=> 310)
              http.errback{ failed(http) }
              http.callback {
                http.response_header.status.should == 200
                Yajl::Parser.parse(http.response).should == my_response
                EventMachine.stop
              }
            }
          end

        end
      end

    end

    context "when there is history" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = ["DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR", "this is my superduper long encrypted message. dont tell anyone!", "this is my superduper long encrypted message. dont tell anyone!", "hi!", {"foo"=>"bar"}, "DECRYPTION_ERROR", "DECRYPTION_ERROR", "DECRYPTION_ERROR"]
          options = {:cipher_key => "enigma", :channel => @history_channel, :limit => 10, :callback => @my_callback}

          VCR.use_cassette("integration_history_4a", :record => :none) do
            EventMachine.run {
              req = create_history_request(options, @my_sub_key, true)
              http = EM::HttpRequest.new(req.url).get(:keepalive => true, :timeout=> 310)
              http.errback{ failed(http) }
              http.callback {
                http.response_header.status.should == 200
                req.package_response!(http.response)
                req.response.should == my_response
                EventMachine.stop
              }
            }
          end

        end
      end
      context "when not using a cipher_key" do

        it "should return the correct response" do

          my_response = ["9i3mZPQSM/1oWFHEnk/ePA==", "2F87t6YX1sYTa7UB/JPZuw==", "FoOj1qJougRs0ipQWoC2Lw==", "B3rnhs8YN23zMI5AgBNa8g==", "4fUVKf/qQqIJjzfEAbPRJw==", "sJYvOBgbTFhmG/PiGm5M3Q==", "SOrWBrdLaQAj2GyGuK12hA==", "NknCcdMyrUGGCeoTW1IDog==", {"my"=>"obj"}, "doo"]
          options = {:channel => @history_channel, :limit => 10, :callback => @my_callback}

          VCR.use_cassette("integration_history_3a", :record => :none) do
            EventMachine.run {
              http = EM::HttpRequest.new(create_history_request(options, @my_sub_key, true).url).get(:keepalive => true, :timeout=> 310)
              http.errback{ failed(http) }
              http.callback {
                http.response_header.status.should == 200
                Yajl::Parser.parse(http.response).should == my_response
                EventMachine.stop
              }
            }
          end

        end
      end

    end

  end



end
