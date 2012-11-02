require 'pubnub'

namespace :examples do

  desc "PubNub Subscribe (Receive Messages)"
  task :subscribe, :channel do |task, args|

    pn = Pubnub.new(:publish_key => "demo", :subscribe_key => "demo")

    # if my_callback returns false, return immediately, otherwise, keep going...
    my_callback = lambda{ |message| puts(message.inspect); return false; }


    pn.subscribe(:channel => args.channel, :callback => my_callback)
  end

  task :re_subscribe, :channel do |task, args|

    pn = Pubnub.new(:publish_key => "demo", :subscribe_key => "demo")

    time_callback = lambda{ |timetoken| @timetoken = timetoken }
    my_callback = lambda{ |message| puts(message.inspect); }

    pn.time(:callback => time_callback)
    pn.subscribe(:channel => args.channel, :callback => my_callback, :override_timetoken => @timetoken)
  end

  desc "Realtime see who channel events, such as joins, leaves, and occupancy"
  task :presence, :channel do |task, args|

    pn = Pubnub.new(:publish_key => "demo", :subscribe_key => "demo")

    # if my_callback returns false, return immediately, otherwise, keep going...
    my_callback = lambda{ |message| puts(message.inspect); return false; }

    pn.presence(:channel => args.channel, :callback => my_callback)
  end

end