require_relative "../../lib/pubnub"

class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
    puts "HI"

    p = Pubnub.new(:subscribe_key => :demo, :publish_key => :demo)
    p.publish(:channel => :hello_world, :message => "hi", :callback => lambda { |x| puts(x)})
    render :inline => "hi"



  end

end
