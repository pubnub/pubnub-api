require 'spec_helper'
require 'rr'
require 'vcr'

describe "Presence Integration Test" do

    before do
      @my_callback = lambda { |message| Rails.logger.debug(message) }
      @pn = Pubnub.new(:subscribe_key => :demo)
    end

    context "when it is successful" do

      context "on the initial timetoken fetch" do

        context "with basic presence config" do

          it "should sub without ssl" do
            my_response = [[], "13456942772413940"]
            mock(@my_callback).call(my_response) {EM.stop}

            VCR.use_cassette("integration_presence_1", :record => :none) do
              @pn.presence(:channel => :hello_world, :callback => @my_callback)
            end
          end

          it "should presence with ssl" do

            my_response = [[], "13456942772413940"]
            mock(@my_callback).call(my_response) {EM.stop}

            @pn.ssl = true

            VCR.use_cassette("integration_presence_3", :record => :none) do
              @pn.presence(:channel => :hello_world, :callback => @my_callback)
            end
          end
        end
      end

      context "on the subsequent timetoken fetch" do

        context "with basic presence config" do

          it "should sub without ssl" do
            my_response = [[{"action"=>"join", "timestamp"=>1345720165, "uuid"=>"1975", "occupancy"=>3}], "13456949659872604"]
            mock(@my_callback).call(my_response) {EM.stop}

            VCR.use_cassette("integration_presence_1b", :record => :none) do
              @pn.presence(:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13456942772413940)
            end
          end

          it "should presence with ssl" do

            my_response = [[{"action"=>"join", "timestamp"=>1345720165, "uuid"=>"1975", "occupancy"=>3}], "13456949659872604"]
            mock(@my_callback).call(my_response) {EM.stop}

            @pn.ssl = true

            VCR.use_cassette("integration_presence_3b", :record => :none) do
              @pn.presence(:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13456942772413940)
            end
          end
        end
      end


      context "when there is a cipher key" do

        before do
          @pn.cipher_key = "enigma"
        end

        it "should presence without ssl (implicit)" do

          my_response = [[{"action"=>"join", "timestamp"=>1345720165, "uuid"=>"1975", "occupancy"=>3}], "13456949659872604"]
          mock(@my_callback).call(my_response) {EM.stop}

          VCR.use_cassette("integration_presence_2", :record => :none) do
            @pn.presence(:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13456942772413940)
          end

        end

        it "should presence without ssl (explicit)" do

          my_response = [[{"action"=>"join", "timestamp"=>1345720165, "uuid"=>"1975", "occupancy"=>3}], "13456949659872604"]
          mock(@my_callback).call(my_response) {EM.stop}

          @pn.ssl = false

          VCR.use_cassette("integration_presence_2", :record => :none) do
            @pn.presence(:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13456942772413940)
          end

        end

        it "should presence with ssl (explicit)" do

          my_response = [[{"action"=>"join", "timestamp"=>1345720165, "uuid"=>"1975", "occupancy"=>3}], "13456949659872604"]
          mock(@my_callback).call(my_response) {EM.stop}

          @pn.ssl = true

          VCR.use_cassette("integration_presence_4", :record => :none) do
            @pn.presence(:channel => :hello_world, :callback => @my_callback, :override_timetoken => 13456942772413940)
          end

        end

      end
    end

end