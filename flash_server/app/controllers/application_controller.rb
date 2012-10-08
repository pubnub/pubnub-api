class ApplicationController < ActionController::Base
  protect_from_forgery

  def time
    render :inline => "[666]"
  end

  def subscribe
    sleep(5)
    render :inline => '[[],"13497314205537966"]'
  end

end
