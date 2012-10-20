require 'em-http-request'
require 'yajl'
require 'uuid'
require 'pubnub'

def create_here_now_request options, subscribe_key, ssl = false
  here_now_request = PubnubRequest.new(:operation => :here_now)
  here_now_request.ssl = ssl
  here_now_request.set_channel(options)
  here_now_request.set_callback(options)
  here_now_request.set_cipher_key(options, nil)
  here_now_request.set_subscribe_key(options, subscribe_key)
  here_now_request.format_url!
  here_now_request
end

def create_detailed_history_request options, subscribe_key, ssl = false
  detailed_history_request = PubnubRequest.new(:operation => :detailed_history)
  detailed_history_request.ssl = ssl
  detailed_history_request.set_channel(options)
  detailed_history_request.set_callback(options)
  detailed_history_request.set_cipher_key(options, nil)
  detailed_history_request.set_subscribe_key(options, subscribe_key)
  detailed_history_request.history_count = options[:count]
  detailed_history_request.history_start = options[:start]
  detailed_history_request.history_end = options[:end]
  detailed_history_request.history_reverse = options[:reverse]
  detailed_history_request.format_url!
  detailed_history_request
end

def create_publish_request options, secret_key = nil, ssl = false
  publish_request = PubnubRequest.new(:operation => :publish)
  publish_request.ssl = ssl
  publish_request.set_channel(options)
  publish_request.set_callback(options)
  publish_request.set_cipher_key(options, nil)
  publish_request.set_message(options, nil)
  publish_request.set_publish_key(options, :demo)
  publish_request.set_subscribe_key(options, :demo)
  publish_request.set_secret_key(options, secret_key)
  publish_request.format_url!
  publish_request
end

def create_history_request options, subscribe_key, ssl = false
  history_request = PubnubRequest.new(:operation => :history)
  history_request.ssl = ssl
  history_request.set_channel(options)
  history_request.set_callback(options)
  history_request.set_cipher_key(options, nil)
  history_request.set_subscribe_key(options, subscribe_key)
  history_request.history_limit = options[:limit]
  history_request.format_url!
  history_request
end

def create_subscribe_request options, ssl = false
  subscribe_request = PubnubRequest.new(:operation => :subscribe, :session_uuid => UUID.new.generate)
  subscribe_request.ssl = ssl
  subscribe_request.set_channel(options)
  subscribe_request.set_callback(options)
  subscribe_request.set_cipher_key(options, nil)
  subscribe_request.set_subscribe_key(options, :demo)
  format_url_options = options[:override_timetoken].present? ? options[:override_timetoken] : nil
  subscribe_request.format_url!(format_url_options)
  subscribe_request
end

def create_presence_request options, ssl = false
  presence_request = PubnubRequest.new(:operation => :presence, :session_uuid => UUID.new.generate)
  presence_request.ssl = ssl
  presence_request.set_channel(options)
  presence_request.set_callback(options)
  presence_request.set_cipher_key(options, nil)
  presence_request.set_subscribe_key(options, :demo)
  format_url_options = options[:override_timetoken].present? ? options[:override_timetoken] : nil
  presence_request.format_url!(format_url_options)
  presence_request
end

def create_time_request options
  time_request = PubnubRequest.new(:operation => :time)
  time_request.set_callback(options)
  time_request.format_url!
  time_request
end