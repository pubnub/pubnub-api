## Pubnub cryptography

## including required libraries
require "openssl"
require 'digest/MD5'
require 'base64'
require 'rubygems'
require 'json'

class PubnubCrypto
  #**
  #* initialize encryption with cipher key, IV and algorithm
  #*
  #* @param cipher key (plain text password)
  #*
  def initialize(cipher_key)
    @@alg = "AES-128-CBC"
    digest = Digest::MD5.new
    digest.update(cipher_key)
    @@key = digest.digest
    @@iv = '0123456789012345'
    raise 'Key Error' if(@@key.nil? or @@key.size != 16)
  end

  #**
  #* encrypt object
  #*
  #* @param plain text(message)
  #* @return cipher text (encrypted text)
  #*
  def encryptObject(message)
    params = Hash.new
    if message.is_a? String
      return encrypt(message)
    else
      message.each do |key,value|
        case(key)
        when(key)
          params[key] = encrypt(value).chop.reverse.chop.reverse();
        end
      end
      params = params.to_json
      return params
    end
  end

  #**
  #* decrypt object
  #*
  #* @param cipher object (cipher to decrypt)
  #* @return plain text (decrypted text)
  #*
  def decryptObject(cipher_Object)
    params = {};
    if cipher_Object.is_a? String
      return decrypt(cipher_Object)
    else
      cipher_Object.each do |key,value|
        case(key)
        when(key)
          params[key] = decrypt(value);
        end
      end
      return params
    end
  end

  #**
  #* encrypt array
  #*
  #* @param message to encrypt (array)
  #* @return cipher text array (encrypted array)
  #*
  def encryptArray(message)
    params = []
    i=0
    message.each do |val|
      case(val)
      when(val)
        params[i] = encrypt(val).chop.reverse.chop.reverse();
        i = i+1
      end
    end
    params = params.to_json
    return params
  end

  #**
  #* decrypt array
  #*
  #* @param cipher array (cipher text array to decrypt)
  #* @return message decrypted (decrypted array)
  #*
  def decryptArray(message)
    params = []
    i=0
    message.each do |val|
      case(val)
      when(val)
        params[i] = decrypt(val);
        i = i+1
      end
    end
    return params
  end

  #**
  #* encrypt plain text
  #*
  #* @param plain text (string to encrypt)
  #* @return cipher text (encrypted text)
  #*
  def encrypt(message)
    aes = OpenSSL::Cipher::Cipher.new(@@alg)
    aes.encrypt
    aes.key = @@key
    aes.iv = @@iv
    @@cipher = aes.update(message)
    @@cipher << aes.final
    @@ciphertext = [@@cipher].pack('m')
    @@ciphertext =  @@ciphertext.strip
    @@ciphertext = '"' + @@ciphertext + '"'
    return @@ciphertext
  end

  #**
  #* decrypt plain text
  #*
  #* @param cipher text
  #* @return plain text (decrypted text)
  #*
  def decrypt(cipher_text)
    decode_cipher = OpenSSL::Cipher::Cipher.new(@@alg)
    decode_cipher.decrypt
    decode_cipher.key = @@key
    decode_cipher.iv = @@iv
    plain_text = decode_cipher.update(cipher_text.unpack('m')[0])
    plain_text << decode_cipher.final
    return plain_text
  end
end
