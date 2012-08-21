require 'spec_helper'
require 'rr'
require 'vcr'

describe PubnubCrypto do

  before do
    @cipher_key = "enigma"
    @plaintext = "hello"
    @ciphertext = %^N56FnGyifE+gjCxu12/f3A==^

    @plain_object = {"foo" => {"bar" => "foobar"}}.to_json
    @cipher_object = %^yLUdgdHs2Fsd5MUYXO7cJH2ciXPC8S3zVrmQHV00sxU=^
  end

  describe "#encrypt_array" do
    it "should not blow up on an empty array" do
      PubnubCrypto.new(@cipher_key).encryptArray([]).should == [].to_json
    end

    it "should encrypt an array with a single message" do
      PubnubCrypto.new(@cipher_key).encryptArray([@plaintext]).should == [@ciphertext].to_json
    end

  end

  describe "#encryptObject" do
    it "should not blow up on an empty hash" do
      PubnubCrypto.new(@cipher_key).encryptObject(Hash.new).should == {}.to_json
    end

    it "should encrypt a hash with a single message" do
      PubnubCrypto.new(@cipher_key).encryptObject(@plain_object).should == @cipher_object.to_json
    end
  end

  describe "#decryptObject" do
    it "should not blow up on an empty hash" do
      PubnubCrypto.new(@cipher_key).decryptObject(Hash.new).should == {}
    end

    it "should encrypt an hash with a single message" do
      PubnubCrypto.new(@cipher_key).decryptObject(@cipher_object).should == @plain_object
    end
  end

  describe "#decrypt_array" do
    it "should not blow up on an empty array" do
      PubnubCrypto.new(@cipher_key).decryptArray([]).should == []
    end

    it "should decrypt an array with a single message" do
      PubnubCrypto.new(@cipher_key).decryptArray([@ciphertext]).should == [@plaintext]
    end

  end
end


