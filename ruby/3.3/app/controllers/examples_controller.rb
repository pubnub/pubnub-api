require 'pubnub'

class ExamplesController < ApplicationController

  def pub

    init_vars

    @pubnub.publish(:channel => @channel, :message => @message, :callback => method(:set_output))
    render :text => @out

  end

  def sub
    init_vars

    @pubnub.subscribe(:channel => @channel, :callback => method(:set_output))
    render :text => @out
  end

  def init_vars
    @channel = params[:channel]
    @message = params[:message]
    @pubnub = Pubnub.new(:subscribe_key => :demo, :publish_key => :demo)
  end


  def set_output(out, cycle = false)
    @out = out
    cycle == false ? false : true
  end

end
