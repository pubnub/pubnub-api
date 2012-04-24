package com.aimx.androidpubnub;

import java.security.AlgorithmParameters;
import java.security.SecureRandom;
import java.security.spec.KeySpec;
import java.util.Random;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;

/**
 * AES encryption
 */
class AES {

	/**
	 * Cipher key (Password) based encryption with random salt and random IV
	 * 
	 * @param String Cipher Key.
	 * @param String Message to Encrypt.
	 * @return String Encrypted Message.
	 * @throws Exception
	 */
	protected static String encryptWithCipherKeySaltAndIV(String cipher_key, String message) 
	        throws Exception {
		
	    // 8 bytes random salt generation
	    Random r = new SecureRandom();
	    byte[] salt = new byte[8];
	    r.nextBytes(salt);
	    
	    int iteration_count = 1024, key_length = 128;
	    
	    // prepare to use PBKDF2/HMAC+SHA1
	    SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
	    
	    // our key is 128 bits, and can be generated knowing the cipher key and salt
	    KeySpec spec = new PBEKeySpec(cipher_key.toCharArray(), salt, iteration_count, key_length);
	    SecretKey skey = factory.generateSecret(spec);
	    SecretKey secret = new SecretKeySpec(skey.getEncoded(), "AES");
	 
	    // given key above, our cipher will be AES-128-CBC
	    Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");	// ISO10126Padding/PKCS5Padding
	    cipher.init(Cipher.ENCRYPT_MODE, secret);
	    AlgorithmParameters params = cipher.getParameters();
	 
	    // generate the initialization vector (IV needed as using CBC cipher mode)
	    byte[] iv = params.getParameterSpec(IvParameterSpec.class).getIV();
	    
	    // encryption
	    byte[] cipher_text = cipher.doFinal(message.getBytes("UTF-8"));
	    
	    // Convert from byte array to base64 string
	    String cipher_text_encoded = new String(Base64Encoder.encode(cipher_text));
	    String iv_encoded = new String(Base64Encoder.encode(iv));
	    String salt_encoded = new String(Base64Encoder.encode(salt));
	    
	    // Prepare message to send
	    StringBuffer message_encrypted = new StringBuffer(cipher_text_encoded);
	    message_encrypted.append(","+iv_encoded).append(","+salt_encoded);
	    
	    return message_encrypted.toString(); 
	} 
	
	/**
	 * Cipher key (Password) based decryption with random salt and random IV
	 * 
	 * @param String Cipher Key.
	 * @param String Encrypted Message.
	 * @return String Decrypted Message.
	 * @throws Exception
	 */
	protected static String decryptWithCipherKeySaltAndIV(String cipher_key, String message_encrypted)
    		throws Exception {
		
		int iteration_count = 1024, key_length = 128;
		
		// get ciphertext, iv, salt
		String[] temp = message_encrypted.split(",");
	    
	    // Convert from base64 string to byte array
	    byte[] cipher_text = Base64Encoder.decode(temp[0]);
	    byte[] iv = Base64Encoder.decode(temp[1]);
	    byte[] salt = Base64Encoder.decode(temp[2]);
		// prepare to use PBKDF2/HMAC+SHA1
		SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
		
		// our key is 128 bits, and can be generated knowing the cipher key and salt
		KeySpec spec = new PBEKeySpec(cipher_key.toCharArray(), salt, iteration_count, key_length);
		SecretKey skey = factory.generateSecret(spec);
		SecretKey secret = new SecretKeySpec(skey.getEncoded(), "AES");
		IvParameterSpec ivspec = new IvParameterSpec(iv);
		
		// given key above, our cipher will be AES-128-CBC
		Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");	// ISO10126Padding/PKCS5Padding
		cipher.init(Cipher.DECRYPT_MODE, secret, ivspec);

		// decryption
		byte[] message_decrypted = cipher.doFinal(cipher_text);
		
		return new String(message_decrypted, "UTF-8");
	}
}
