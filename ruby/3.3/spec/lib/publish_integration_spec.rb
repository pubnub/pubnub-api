require 'spec_helper'
require 'rr'
require 'vcr'
require 'em_request_helper'

describe "Publish Integration Test" do

  before do
    @my_callback = lambda { |message| Rails.logger.debug(message) }
  end

  context "when it is successful" do

    context "with basic publish config" do

      it "should publish without ssl" do
        my_response = [1, "Sent", "13450923394327693"]
        options = {:channel => :hello_world, :message => "hi", :callback => @my_callback}

        VCR.use_cassette("integration_publish_1", :record => :none) do
          EventMachine.run {
            http = EM::HttpRequest.new(create_publish_request(options).url).get(:keepalive => true, :timeout=> 310)
            http.errback{ failed(http) }
            http.callback {
              http.response_header.status.should == 200
              Yajl::Parser.parse(http.response).should == my_response
              EventMachine.stop
            }
          }
        end
      end

      it "should publish with ssl" do

        my_response = [1, "Sent", "13451428018571368"]
        options = {:channel => :hello_world, :message => "hi", :callback => @my_callback}

        VCR.use_cassette("integration_publish_3", :record => :none) do
          EventMachine.run {
            http = EM::HttpRequest.new(create_publish_request(options, nil, true).url).get(:keepalive => true, :timeout=> 310)
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


    context "when there is a cipher key" do

      it "should publish without ssl (implicit)" do

        my_response = [1, "Sent", "13473285565926387"]
        options = {:cipher_key => "enigma", :channel => :hello_world, :message => "hi", :callback => @my_callback}

        VCR.use_cassette("integration_publish_2", :record => :none) do
          EventMachine.run {
            http = EM::HttpRequest.new(create_publish_request(options).url).get(:keepalive => true, :timeout=> 310)
            http.errback{ failed(http) }
            http.callback {
              http.response_header.status.should == 200
              Yajl::Parser.parse(http.response).should == my_response
              EventMachine.stop
            }
          }
        end

      end

      it "should publish without ssl (explicit)" do

        my_response = [1, "Sent", "13473285565926387"]
        options = {:cipher_key => "enigma", :channel => :hello_world, :message => "hi", :callback => @my_callback}

        VCR.use_cassette("integration_publish_2", :record => :none) do
          EventMachine.run {
            http = EM::HttpRequest.new(create_publish_request(options, nil, false).url).get(:keepalive => true, :timeout=> 310)
            http.errback{ failed(http) }
            http.callback {
              http.response_header.status.should == 200
              Yajl::Parser.parse(http.response).should == my_response
              EventMachine.stop
            }
          }
        end

      end

      context "ssl on" do

        context "message signing off" do

          it "should publish" do

            my_response = [1, "Sent", "13473286442585026"]
            options = {:cipher_key => "enigma", :channel => :hello_world, :message => "hi", :callback => @my_callback}

            VCR.use_cassette("integration_publish_4", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_publish_request(options, nil, true).url).get(:keepalive => true, :timeout=> 310)
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

        context "message signing on" do

          it "should publish" do

            my_response = [1, "Sent", "13473288269652075"]
            options = {:cipher_key => "enigma", :channel => :hello_world, :message => "hi", :callback => @my_callback}

            VCR.use_cassette("integration_publish_5", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_publish_request(options, "itsmysecret", true).url).get(:keepalive => true, :timeout=> 310)
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

    context "when message signing is on" do

      it "should publish without ssl (implicit)" do

        my_response = [1, "Sent", "13451493026321630"]
        options = {:channel => :hello_world, :message => "hi", :callback => @my_callback}

        VCR.use_cassette("integration_publish_6", :record => :none) do
          EventMachine.run {
            http = EM::HttpRequest.new(create_publish_request(options, "enigma").url).get(:keepalive => true, :timeout=> 310)
            http.errback{ failed(http) }
            http.callback {
              http.response_header.status.should == 200
              Yajl::Parser.parse(http.response).should == my_response
              EventMachine.stop
            }
          }
        end

      end

      it "should publish without ssl (explicit)" do

        my_response = [1, "Sent", "13451494117873005"]
        options = {:channel => :hello_world, :message => "hi", :callback => @my_callback}

        VCR.use_cassette("integration_publish_7", :record => :none) do
          EventMachine.run {
            http = EM::HttpRequest.new(create_publish_request(options, "enigma", false).url).get(:keepalive => true, :timeout=> 310)
            http.errback{ failed(http) }
            http.callback {
              http.response_header.status.should == 200
              Yajl::Parser.parse(http.response).should == my_response
              EventMachine.stop
            }
          }
        end

      end

      context "ssl on" do

        context "cipher key off" do

          it "should publish" do

            my_response = [1, "Sent", "13451493874063684"]
            options = {:channel => :hello_world, :message => "hi", :callback => @my_callback}

            VCR.use_cassette("integration_publish_8", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_publish_request(options, "enigma", true).url).get(:keepalive => true, :timeout=> 310)
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

        context "cipher key on" do

          it "should publish" do

            my_response = [1, "Sent", "13473284333280114"]
            options = {:cipher_key => "itsmysecret", :channel => :hello_world, :message => "hi", :callback => @my_callback}

            VCR.use_cassette("integration_publish_9", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_publish_request(options, "enigma", true).url).get(:keepalive => true, :timeout=> 310)
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
end