require 'pubnub'

class ExamplesController < ApplicationController

  # PubNub Publish Message (Send Message)
  def pub

    init_vars

    @pubnub.publish(:channel => @channel, :message => @message, :callback => method(:set_output))
    render :text => @out

  end

  def blocking_pub

    #def self.publish!(channel, message, publish_key, subscribe_key, channel)
    init_vars

    BlockingPub.publish!
    render :text => @out
  end

  # PubNub Server Time (Get TimeToken)
  def time

    init_vars

    @pubnub.time(:callback => method(:set_output))
    render :text => @out

  end

  def here_now

    init_vars

    @pubnub.here_now(:channel => @channel, :callback => method(:set_output))
    render :text => @out

  end

  # PubNub Session UUID (Get Session UUID)
  def uuid
    init_vars

    render :text => @pubnub.uuid
  end

  def detailed_history

    init_vars

    @pubnub.detailed_history(:channel => @channel, :count => @count, :callback => method(:set_output))

    render :text => @out

  end

  def history

    init_vars

    @pubnub.history(:channel => @channel, :limit => @limit, :callback => method(:set_output))

    render :text => @out

  end

  def init_vars
    @channel = params[:channel]
    @message = params[:message]
    @count = params[:count]
    @limit = params[:limit]

    # Init Pubnub Object
    @pubnub = Pubnub.new(:subscribe_key => :demo, :publish_key => :demo)
  end

  # Response Callback
  def set_output(out); @out = out; end

end
