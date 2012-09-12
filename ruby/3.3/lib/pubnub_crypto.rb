class PubnubCrypto
  require 'yajl'

  def initialize(cipher_key)
    @alg = "AES-256-CBC"
    sha256_key = Digest::SHA256.hexdigest(cipher_key)
    @key = sha256_key.slice(0,32)

    #puts("\nraw sha cipher_key is: #{cipher_key}")
    #puts("raw sha cipher_key is: #{sha256_key}")
    #puts("padded cipher_key is: #{@key}\n")

    @iv = '0123456789012345'
  end


  def encrypt(message)

    aes = OpenSSL::Cipher::Cipher.new(@alg)
    aes.encrypt
    aes.key = @key
    aes.iv = @iv

    json_message = Yajl.dump(message)
    cipher = aes.update(json_message)
    cipher << aes.final

    Base64.strict_encode64(cipher)

  end


  def decrypt(cipher_text)
    decode_cipher = OpenSSL::Cipher::Cipher.new(@alg)
    decode_cipher.decrypt
    decode_cipher.key = @key
    decode_cipher.iv = @iv

    plain_text = ""

    begin
    undecoded_text = Base64.decode64(cipher_text)
    plain_text = decode_cipher.update(undecoded_text)
    plain_text << decode_cipher.final
    rescue => e

      return "DECRYPTION_ERROR"

    end

    return Yajl.load(plain_text)
  end
end
