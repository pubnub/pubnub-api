## Pubnub cryptography

## including required libraries
require "openssl"
require 'digest'
require 'base64'
require 'rubygems'
require 'json'

class PubnubCrypto

  def initialize(cipher_key)
    @alg = "AES-256-CBC"
    sha256_key = Digest::SHA256.hexdigest(cipher_key)
    @key = sha256_key.slice(0,32)

    puts("\nraw sha cipher_key is: #{cipher_key}")
    puts("raw sha cipher_key is: #{sha256_key}")
    puts("padded cipher_key is: #{@key}\n")

    @iv = '0123456789012345'
  end


  def encrypt(message)

    aes = OpenSSL::Cipher::Cipher.new(@alg)
    aes.encrypt
    aes.key = @key
    aes.iv = @iv

    cipher = aes.update(message.to_json)
    cipher << aes.final
    ciphertext = Base64.strict_encode64 (cipher)

  end


  def decrypt(cipher_text)
    decode_cipher = OpenSSL::Cipher::Cipher.new(@alg)
    decode_cipher.decrypt
    decode_cipher.key = @key
    decode_cipher.iv = @iv

    begin
    plain_text = decode_cipher.update(cipher_text.unpack('m')[0])
    plain_text << decode_cipher.final
    rescue => e

      return "DECRYPTION_ERROR"

    end

    return plain_text
  end
end
