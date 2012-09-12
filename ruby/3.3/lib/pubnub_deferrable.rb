require 'eventmachine'

class PubnubDeferrable < EM::Protocols::HttpClient2

  include EM::Deferrable

  attr_accessor :start_time, :end_time, :elapsed_time, :pubnub_request

  def initialize
    super
  end

  def post_init
    #puts("deferrable says my query is: #{pubnub_request.query}")
    super
  end

  def connection_completed
    @start_time = Time.now
    #puts("\n--- #{@start_time}: Connected with string: #{self.pubnub_request.query}")
    super
  end

  def unbind
    @end_time = Time.now

    if @start_time == nil
      @start_time = Time.now
    end

    #puts("-- #{@end_time}: Disconnected.")
    #puts("--- Elapsed connection time: #{@end_time - @start_time}s")
    super
  end


end