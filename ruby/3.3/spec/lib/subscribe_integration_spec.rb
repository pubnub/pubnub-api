require 'spec_helper'
require 'rr'
require 'vcr'
require 'em_request_helper'

describe "Subscribe Integration Test" do

    before do
      @my_callback = lambda { |message| Rails.logger.debug(message) }
    end

    context "when it is successful" do

      context "on the initial timetoken fetch" do

        context "with basic subscribe config" do

          it "should sub without ssl" do
            my_response = [[], "13451632748083262"]
            options = {:channel => :hello_world, :callback => @my_callback}

            VCR.use_cassette("integration_subscribe_1", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_subscribe_request(options).url).get(:keepalive => true, :timeout=> 310)
                http.errback{ failed(http) }
                http.callback {
                  http.response_header.status.should == 200
                  Yajl::Parser.parse(http.response).should == my_response
                  EventMachine.stop
                }
              }
            end
          end

          it "should subscribe with ssl" do

            my_response = [[], "13451632748083262"]
            options = {:channel => :hello_world, :callback => @my_callback}
            VCR.use_cassette("integration_subscribe_3", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_subscribe_request(options, true).url).get(:keepalive => true, :timeout=> 310)
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

      context "on the subsequent timetoken fetch" do

        context "with basic subscribe config" do

          it "should sub without ssl" do
            my_response = [[{"text" => "bo"}], "13455067954018816"]
            options = {:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13455067091198286}

            VCR.use_cassette("integration_subscribe_1b", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_subscribe_request(options).url).get(:keepalive => true, :timeout=> 310)
                http.errback{ failed(http) }
                http.callback {
                  http.response_header.status.should == 200
                  Yajl::Parser.parse(http.response).should == my_response
                  EventMachine.stop
                }
              }
            end
          end

          it "should subscribe with ssl" do

            my_response = [[{"text" => "bo"}], "13455068901569588"]
            options = {:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13455068696466554}
            VCR.use_cassette("integration_subscribe_3b", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_subscribe_request(options, true).url).get(:keepalive => true, :timeout=> 310)
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


      context "when there is a cipher key" do

        it "should subscribe without ssl (implicit)" do

          my_response = [["DECRYPTION_ERROR", "this is my superduper long encrypted message. dont tell anyone!"], "13473292476449446"]
          options = {:cipher_key => "enigma", :channel => :hello_world, :message => "hi", :callback => @my_callback, :override_timetoken => 13473291856851191}

          VCR.use_cassette("integration_subscribe_2", :record => :none) do
            EventMachine.run {
              req = create_subscribe_request(options)
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
    end

end