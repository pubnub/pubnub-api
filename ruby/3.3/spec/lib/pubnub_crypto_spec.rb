require 'spec_helper'
require 'rr'
require 'vcr'

describe PubnubCrypto do

  before do
    @cipher_key = "enigma"

    @plain_string = %^Pubnub Messaging API 1^
    @cipher_string = "f42pIQcWZ9zbTbH8cyLwByD/GsviOE0vcREIEVPARR0="

    @plain_hash = {"foo" => {"bar" => "foobar"}}
    @encrypted_hash = "GsvkCYZoYylL5a7/DKhysDjNbwn+BtBtHj2CvzC4Y4g="

    @cipher_empty_hash = "IDjZE9BHSjcX67RddfCYYg=="

    @cipher_object = %^yLUdgdHs2Fsd5MUYXO7cJH2ciXPC8S3zVrmQHV00sxU=^

    @cipher_empty_object = "IDjZE9BHSjcX67RddfCYYg=="

    @cipher_empty_array = "Ns4TB41JjT2NCXaGLWSPAQ=="
    @cipher_array = "bz1jaOW3wT/MBPMN8SI0GvWPKT2PUfj2TD/Rg746jSc="

  end

  describe "#when there is a message encrypted on PHP AES256" do

    context "pubnub standard tests" do
      it "should encrypt" do
        crypto = PubnubCrypto.new(@cipher_key)
        crypto.encrypt(@plain_string).should == @cipher_string
      end

      it "should decrypt" do
        crypto = PubnubCrypto.new(@cipher_key)
        crypto.decrypt(@cipher_string).should == @plain_string
      end
    end

  end

  describe "encrypt array" do
    it "should not blow up on an empty array" do
      PubnubCrypto.new(@cipher_key).encrypt([]).should == @cipher_empty_array
    end

    it "should encrypt an array with a single message" do
      PubnubCrypto.new(@cipher_key).encrypt([@plain_string]).should == @cipher_array
    end

  end

  describe "decrypt array" do
    it "should not blow up on an empty array" do
      PubnubCrypto.new(@cipher_key).decrypt(@cipher_empty_array).should == []
    end

    it "should decrypt an array with a single message" do
      PubnubCrypto.new(@cipher_key).decrypt(@cipher_array).should == [@plain_string]
    end

  end


  describe "encrypt Hash" do
    it "should not blow up on an empty hash" do
      PubnubCrypto.new(@cipher_key).encrypt({}).should == @cipher_empty_hash
    end

    it "should encrypt a hash with a single message" do
      PubnubCrypto.new(@cipher_key).encrypt(@plain_hash).should == @encrypted_hash
    end
  end

  describe "decrypt Hash" do
    it "should not blow up on an empty hash" do
      PubnubCrypto.new(@cipher_key).decrypt(@cipher_empty_hash).should == {}
    end

    it "should decrypt an hash with a single message" do
      PubnubCrypto.new(@cipher_key).decrypt(@encrypted_hash).should == @plain_hash
    end
  end


end


