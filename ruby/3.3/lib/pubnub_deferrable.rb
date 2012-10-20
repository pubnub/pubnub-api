require 'eventmachine'

class PubnubDeferrable < EM::HttpRequest

  include EM::Deferrable

  attr_accessor :start_time, :end_time, :elapsed_time, :pubnub_request

end