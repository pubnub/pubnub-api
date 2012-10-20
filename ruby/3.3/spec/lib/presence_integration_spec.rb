require 'spec_helper'
require 'rr'
require 'vcr'
require 'em_request_helper'

describe "Presence Integration Test" do

    before do
      @my_callback = lambda { |message| Rails.logger.debug(message) }
    end

    context "when it is successful" do

      context "on the initial timetoken fetch" do

        context "with basic presence config" do

          it "should sub without ssl" do
            my_response = [[], "13456942772413940"]
            options = {:channel => :hello_world, :callback => @my_callback}

            VCR.use_cassette("integration_presence_1", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_presence_request(options).url).get(:keepalive => true, :timeout=> 310)
                http.errback{ failed(http) }
                http.callback {
                  http.response_header.status.should == 200
                  Yajl::Parser.parse(http.response).should == my_response
                  EventMachine.stop
                }
              }
            end
          end

          it "should presence with ssl" do

            my_response = [[], "13456942772413940"]
            options = {:channel => :hello_world, :callback => @my_callback}

            VCR.use_cassette("integration_presence_3", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_presence_request(options, true).url).get(:keepalive => true, :timeout=> 310)
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

        context "with basic presence config" do

          it "should sub without ssl" do
            my_response = [[{"action"=>"join", "timestamp"=>1345720165, "uuid"=>"1975", "occupancy"=>3}], "13456949659872604"]
            options = {:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13456942772413940}

            VCR.use_cassette("integration_presence_1b", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_presence_request(options).url).get(:keepalive => true, :timeout=> 310)
                http.errback{ failed(http) }
                http.callback {
                  http.response_header.status.should == 200
                  Yajl::Parser.parse(http.response).should == my_response
                  EventMachine.stop
                }
              }
            end
          end

          it "should presence with ssl" do

            my_response = [[{"action"=>"join", "timestamp"=>1345720165, "uuid"=>"1975", "occupancy"=>3}], "13456949659872604"]
            options = {:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13456942772413940}

            VCR.use_cassette("integration_presence_3b", :record => :none) do
              EventMachine.run {
                http = EM::HttpRequest.new(create_presence_request(options, true).url).get(:keepalive => true, :timeout=> 310)
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

        it "should presence without ssl (implicit)" do

          my_response = [[{"action"=>"join", "timestamp"=>1345720165, "uuid"=>"1975", "occupancy"=>3}], "13456949659872604"]
          options = {:cipher_key => "enigma", :channel => :hello_world, :callback => @my_callback, :override_timetoken => 13456942772413940}

          VCR.use_cassette("integration_presence_2", :record => :none) do
            EventMachine.run {
              http = EM::HttpRequest.new(create_presence_request(options).url).get(:keepalive => true, :timeout=> 310)
              http.errback{ failed(http) }
              http.callback {
                http.response_header.status.should == 200
                Yajl::Parser.parse(http.response).should == my_response
                EventMachine.stop
              }
            }
          end

        end

        it "should presence without ssl (explicit)" do

          my_response = [[{"action"=>"join", "timestamp"=>1345720165, "uuid"=>"1975", "occupancy"=>3}], "13456949659872604"]
          options = {:cipher_key => "enigma", :channel => :hello_world, :callback => @my_callback, :override_timetoken => 13456942772413940}

          VCR.use_cassette("integration_presence_2", :record => :none) do
            EventMachine.run {
              http = EM::HttpRequest.new(create_presence_request(options, false).url).get(:keepalive => true, :timeout=> 310)
              http.errback{ failed(http) }
              http.callback {
                http.response_header.status.should == 200
                Yajl::Parser.parse(http.response).should == my_response
                EventMachine.stop
              }
            }
          end

        end

        it "should presence with ssl (explicit)" do

          my_response = [[{"action"=>"join", "timestamp"=>1345720165, "uuid"=>"1975", "occupancy"=>3}], "13456949659872604"]
          options = {:cipher_key => "enigma", :channel => :hello_world, :callback => @my_callback, :override_timetoken => 13456942772413940}

          VCR.use_cassette("integration_presence_4", :record => :none) do
            EventMachine.run {
              http = EM::HttpRequest.new(create_presence_request(options, true).url).get(:keepalive => true, :timeout=> 310)
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