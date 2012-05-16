# AES Encryption

##including required libraries
require "openssl"
require 'digest/MD5'
require 'base64'
require 'rubygems'


class PubnubCrypto

  # Initialization of cipher key,iv and algorithm type of aes
  
  def initialize(cipher_key)
    @@alg = "AES-128-CBC"
    digest = Digest::MD5.new
    digest.update(cipher_key)
    @@key = digest.digest
    @@iv = '0123456789012345'
    raise 'Key Error' if(@@key.nil? or @@key.size != 16)
  end

  #  encrypt
  #* @param plain text(message)
  #* @return cipher text (encrypted text)
  #
  
  def encrypt(message)
    aes = OpenSSL::Cipher::Cipher.new(@@alg)
    aes.encrypt
    aes.key = @@key
    aes.iv = @@iv
    @@cipher = aes.update(message)
    @@cipher << aes.final
    @@ciphertext = [@@cipher].pack('m')
    return @@ciphertext
  end
  
   #  decrypt
   #* @param cipher text
   #* @return plain text (decrypted text)
   #
  
  def decrypt(cipher_text)
    decode_cipher = OpenSSL::Cipher::Cipher.new(@@alg)
    decode_cipher.decrypt
    decode_cipher.key = @@key
    decode_cipher.iv = @@iv
    plain = decode_cipher.update(cipher_text.unpack('m')[0])
    plain << decode_cipher.final
    return plain
  end
end
