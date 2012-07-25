class PNClient

  attr_accessor :publish_key, :subscribe_key, :secret_key, :cipher_key, :ssl_enabled, :channel
  attr_accessor :client

  def initialize
    puts "running init..."
    @publish_key = "pub-bfe6270e-d3a4-4aa0-aae8-17c638d6bf50"
    @subscribe_key = "sub-1679a957-9d72-11e1-adcd-63711b3a7d48"
    @secret_key = "sec-MmNlMmFjMDQtZTRkYy00OGEzLTg4OWEtMDY3MjQ2Y2VjZWUx"
    @cipher_key = ""
    @ssl_enabled = false
    @channel = "gcohen_1234"

    @client = Pubnub.new(@publish_key, @subscribe_key, @secret_key, @cipher_key, @ssl_enabled)
  end

  def pub(message)
    options = {"channel" => @channel, "message" => message, "callback" => lambda { |m| puts m }}
    @client.publish(options)
  end


  def sub
    @client.subscribe({
        'channel'  => @channel,
        'callback' => lambda do |message|
            puts(message)    ## get and print message
            #return true      ## keep listening?
        end
    })
  end


  def self.rand_string(size = 100)
    string = (0...size).map { ('a'..'z').to_a[rand(26)] }.join
    puts string[0..2]
    string
  end

  #################################################################################
  # Message size too big

  def self.good_and_bad
    puts "bad!"
    self.msg_size_too_big
    puts "good!"
    self.good_msg
  end

  def self.msg_size_too_big
    begin
      z = PNClient.new.pub(self.rand_string(4001))
    rescue => e

      puts "exception raised: #{e.message}"
      puts e.backtrace
      puts z
    end

  end

  def self.good_msg
    z = PNClient.new.pub(self.rand_string(600))
    z
  end

end