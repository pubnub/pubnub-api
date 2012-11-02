require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'eventmachine'

describe ExamplesController do
  
  # GET examples/pub/:channel/:message
  describe "responding to GET pub" do

    it "should send message and render message text" do
      EM.run {
        get :pub, :channel => 'hello_world' , :message => 'hi'
        EM.stop
      }

      assigns[:message].should == 'hi'
      response.should render_template(:text => 'OK')
    end

  end

  # GET examples/time
  describe "responding to GET time" do

    it "should render server time" do
      EM.run {
        get :time
        EM.stop
      }

      response.should render_template(:text => 'OK')
    end

  end

  # GET examples/uuid
  describe "responding to GET uuid" do

    it "should render session UUID" do

      get :uuid

      response.should render_template(:text => 'OK')
    end

  end

  # GET examples/here_now/:channel
  describe "responding to GET here_now" do

    it "should render current occupancy status of the channel" do
      EM.run {
        get :here_now, :channel => 'hello_world'
        EM.stop
      }

      response.should render_template(:text => 'OK')
    end

  end

  # GET examples/history/:channel/:limit
  describe "responding to GET history" do

    it "should render the last 5 messages published to the channel" do
      EM.run {
        get :history, :channel => 'hello_world', :limit => 5
        EM.stop
      }

      assigns[:limit].to_i.should == 5
      response.should render_template(:text => 'OK')
    end

  end

  # GET examples/detailed_history/:channel/:count
  describe "responding to GET detailed_history" do

    it "should render archive messages of on a given channel" do
      EM.run {
        get :detailed_history, :channel => 'hello_world', :count => 5
        EM.stop
      }

      assigns[:count].to_i.should == 5
      response.should render_template(:text => 'OK')
    end

  end

end

