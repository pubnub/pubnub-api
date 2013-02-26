require "httparty"

class BlockingPub < ActiveRecord::Base


  def self.publish!
    url = PubnubRequest.encode(['publish', "demo", "demo", '0', "b", '0', "hello there".to_json])
    url = "http://pubsub.pubnub.com#{url}"

    begin
      response = HTTParty.get(url, :headers => {'V' => '3.3', 'User-Agent' => 'Ruby (tophatter)', 'Accept' => '*/*'}, :timeout => 1)
    rescue Exception => e
      if (e.to_s == "execution expired")
        puts "Timed out: #{e}"
        puts "url: #{url}"
        puts "time: #{Time.now.to_s}"
        return
      else
        puts "some other bad error :("
        return
      end

      #raise e
    end

    z = ""

    begin
      z = JSON.parse(response.body)
    rescue
      puts("Malformed JSON response.")
      return
    end

    puts(z)

  end

  class PubnubRequest

    attr_accessor :operation, :channel, :subscribe_key, :session_uuid, :timetoken, :last_timetoken, :response, :callback

    def initialize(options = {})
      options = HashWithIndifferentAccess.new(options)
      @operation = 'subscribe'
      @channel = options[:channel].to_s
      @subscribe_key = options[:subscribe_key].to_s
      @session_uuid = options[:session_uuid]
      @timetoken = options[:timetoken] || '0'
      @callback = options[:callback]
    end


    def self.encode(request)
      '/' + request.map { |bit| bit.split('').map { |ch| ' ~`!@#$%^&*()+=[]\\{}|;\':",./<>?'.index(ch) ? '%' + ch.unpack('H2')[0].to_s.upcase : URI.encode(ch) }.join('') }.join('/')
    end

  end


end
