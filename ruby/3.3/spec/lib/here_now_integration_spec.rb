require 'spec_helper'
require 'rr'
require 'vcr'

describe "here_now Integration Test" do

  before do
    @my_sub_key = :demo
    @pn = Pubnub.new(:subscribe_key => @my_sub_key)
    @my_callback = lambda { |x| puts(x) }

    @no_here_now_channel = "no_here_now"
    @here_now_channel = "hello_world"
  end

  context "when not using ssl" do

    context "when there is no here_now" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = {"uuids"=>[], "occupancy"=>0}
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_here_now_2", :record => :none) do
            @pn.here_now(:cipher_key => "enigma", :channel => @no_here_now_channel, :callback => @my_callback)
          end

        end
      end

      context "when not using a cipher_key" do
        it "should return the correct response" do
          my_response = {"uuids"=>[], "occupancy"=>0}
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_here_now_1", :record => :none) do
            @pn.here_now(:channel => @no_here_now_channel, :callback => @my_callback)
          end
        end
      end

    end

    context "when there is here_now" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = {"uuids"=>["E33194F6-D6F1-4762-87D9-9D1DB5BC650B", "aa1686b0-cee8-012f-ba60-70def1fd2b7f", "1bc5667b-6443-403d-8e98-f5306791b595"], "occupancy"=>3}
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_here_now_4", :record => :none) do
            @pn.here_now(:cipher_key => "enigma", :channel => @here_now_channel, :callback => @my_callback)
          end

        end
      end
      context "when not using a cipher_key" do

          it "should return the correct response" do

            my_response = {"uuids"=>["E33194F6-D6F1-4762-87D9-9D1DB5BC650B", "aa1686b0-cee8-012f-ba60-70def1fd2b7f", "1bc5667b-6443-403d-8e98-f5306791b595"], "occupancy"=>3}
            mock(@my_callback).call(my_response) {}

            VCR.use_cassette("integration_here_now_3", :record => :none) do
              @pn.here_now(:channel => @here_now_channel, :callback => @my_callback)
            end

        end
      end

    end

  end


  context "when using ssl" do

    before do
      @pn.ssl = true
    end

    context "when there is no here_now" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = {"uuids"=>[], "occupancy"=>0}
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_here_now_2a", :record => :none) do
            @pn.here_now(:cipher_key => "enigma", :channel => @no_here_now_channel, :callback => @my_callback)
          end

        end
      end

      context "when not using a cipher_key" do

        it "should return the correct response" do

          my_response = {"uuids"=>[], "occupancy"=>0}
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_here_now_1a", :record => :none) do
            @pn.here_now(:channel => @no_here_now_channel, :callback => @my_callback)
          end

        end
      end

    end

    context "when there is here_now" do

      context "when using a cipher_key" do
        it "should return the correct response" do

          my_response = {"uuids"=>["E33194F6-D6F1-4762-87D9-9D1DB5BC650B", "aa1686b0-cee8-012f-ba60-70def1fd2b7f", "1bc5667b-6443-403d-8e98-f5306791b595"], "occupancy"=>3}
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_here_now_4a", :record => :none) do
            @pn.here_now(:cipher_key => "enigma", :channel => @here_now_channel, :callback => @my_callback)
          end

        end
      end
      context "when not using a cipher_key" do

        it "should return the correct response" do

          my_response = {"uuids"=>["E33194F6-D6F1-4762-87D9-9D1DB5BC650B", "aa1686b0-cee8-012f-ba60-70def1fd2b7f", "1bc5667b-6443-403d-8e98-f5306791b595"], "occupancy"=>3}
          mock(@my_callback).call(my_response) {}

          VCR.use_cassette("integration_here_now_3a", :record => :none) do
            @pn.here_now(:channel => @here_now_channel, :callback => @my_callback)
          end

        end
      end

    end

  end



end
