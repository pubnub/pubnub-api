package pubnub.crypto;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.security.Key;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Iterator;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.Mac;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * PubNub 3.1 Cryptography
 * 
 */

public class PubnubCrypto {

	private final String CIPHER_KEY;  
	  
    public PubnubCrypto(String CIPHER_KEY) {
        this.CIPHER_KEY = CIPHER_KEY;  
    }  
  
    /**
     * Encrypt
     * 
     * @param JSONObject Message to encrypt
     * @return JSONObject as Encrypted message
     */
    @SuppressWarnings("unchecked")
	public JSONObject encrypt(JSONObject message) {
    	try {
    		JSONObject message_encrypted = new JSONObject();
        	Iterator<String> it = message.keys();
        	
	    	while(it.hasNext()) {
	    		String key = it.next();
	    		String val = message.getString(key);
	    		message_encrypted.put(key, encrypt(val));
	    	}
	    	return message_encrypted;

    	} catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    
    /**
     * Decrypt
     * 
     * @param JSONObject Encrypted message
     * @return JSONObject Message decrypted
     */
    @SuppressWarnings("unchecked")
	public JSONObject decrypt(JSONObject message_encrypted) {
    	try {
    		JSONObject message_decrypted = new JSONObject();
        	Iterator<String> it = message_encrypted.keys();
        	
	    	while(it.hasNext()) {
	    		String key = it.next();
	    		String encrypted_str = message_encrypted.getString(key);
	    		String decrypted_str = decrypt(encrypted_str);
	    		message_decrypted.put(key, decrypted_str);
	    	}
	    	return message_decrypted;
    	} catch(Exception e) {
    		throw new RuntimeException(e);
    	}
    }
    
    /**
     * Encrypt JSONArray
     * 
     * @param JSONArray - Encrypted JSONArray
     * @return JSONArray - Decrypted JSONArray
     */
    public JSONArray encryptJSONArray(JSONArray jsona_arry) {
    	try {
    		JSONArray jsona_decrypted = new JSONArray();
    		
    		for (int i = 0; i < jsona_arry.length(); i++) {
				 Object o = jsona_arry.get(i);
				 if(o != null) {
					 if(o instanceof JSONObject) {
						 jsona_decrypted.put(i, encrypt((JSONObject)o));
					 } else if(o instanceof JSONArray) {
						 jsona_decrypted.put(i, encryptJSONArray((JSONArray)o));
					 } else if(o instanceof String) {
						 jsona_decrypted.put(i, encrypt(o.toString()));
					 }
				 }
			}
    		
    		return jsona_decrypted;
    		
    	} catch(Exception e) {
    		throw new RuntimeException(e);
    	}
    }
    
    /**
     * Decrypt JSONArray
     * 
     * @param JSONArray - Encrypted JSONArray
     * @return JSONArray - Decrypted JSONArray
     */
    public JSONArray decryptJSONArray(JSONArray jsona_encrypted) {
    	try {
    		JSONArray jsona_decrypted = new JSONArray();
    		
    		for (int i = 0; i < jsona_encrypted.length(); i++) {
				 Object o = jsona_encrypted.get(i);
				 if(o != null) {
					 if(o instanceof JSONObject) {
						 jsona_decrypted.put(i, decrypt((JSONObject)o));
					 } else if(o instanceof JSONArray) {
						 jsona_decrypted.put(i, decryptJSONArray((JSONArray)o));
					 } else if(o instanceof String) {
						 jsona_decrypted.put(i, decrypt(o.toString()));
					 }
				 }
			}
    		
    		return jsona_decrypted;
    		
    	} catch(Exception e) {
    		throw new RuntimeException(e);
    	}
    }
    
    /**
     * Encrypt
     * 
     * @param String plain text to encrypt
     * @return String cipher text
     * @throws Exception
     */
    public String encrypt(String plain_text) throws Exception {
        byte[] out = transform(true, plain_text.getBytes());
        return new String(Base64Encoder.encode(out));
    }  
  
    /**
     * Decrypt
     * 
     * @param String cipherText
     * @return String
     * @throws Exception
     */
    public String decrypt(String cipher_text) throws Exception {
    	byte[] out = transform(false, Base64Encoder.decode(cipher_text));
        return new String(out).trim();
    }  
  
    /**
     * AES Encryption
     * 
     * @param boolean encrypt_or_decrypt ENCRYPT/DECRYPT mode
     * @param ByteArray input_bytes
     * @return ByteArray
     * @throws Exception
     */
    private byte[] transform(boolean encrypt_or_decrypt, byte[] input_bytes) throws Exception {  
    	ByteArrayOutputStream output = new ByteArrayOutputStream();
    	byte[] iv_bytes = "0123456789012345".getBytes();
    	byte[] key_bytes = md5(this.CIPHER_KEY);

    	SecretKeySpec key = new SecretKeySpec(key_bytes, "AES");
        IvParameterSpec ivSpec = new IvParameterSpec(iv_bytes);
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");

        if(encrypt_or_decrypt) {
	        cipher.init(Cipher.ENCRYPT_MODE, key, ivSpec);
	    	ByteArrayInputStream b_in = new ByteArrayInputStream(input_bytes);
	        CipherInputStream c_in = new CipherInputStream(b_in, cipher);
	        int ch;
	        while ((ch = c_in.read()) >= 0) {
	        	output.write(ch);
	        }
        } else {
        	cipher.init(Cipher.DECRYPT_MODE, key, ivSpec);
        	CipherOutputStream c_out = new CipherOutputStream(output, cipher);
        	c_out.write(input_bytes);
        	c_out.close();
        }
        return output.toByteArray();  
    }
    
    /**
     * Sign Message
     * 
     * @param String input
     * @return String as HashText
     */
	public static String getHMacSHA256(String secret_key, String input) {
		try {
			Key KEY = new SecretKeySpec(input.getBytes("UTF-8"), "HmacSHA256");
			Mac sha256_HMAC = Mac.getInstance("HMACSHA256");
	    	
			sha256_HMAC.init(KEY);
			byte[] mac_data = sha256_HMAC.doFinal(secret_key.getBytes());
	    	
	    	BigInteger number = new BigInteger(1, mac_data);
	    	String hashtext = number.toString(16);
            
            return hashtext;
		} catch (Exception e) {
            throw new RuntimeException(e);
        }
	}
	/**
	 * Get MD5
	 * @param string
	 * @return
	 */
	public static byte[] md5(String string) { 
	    byte[] hash; 
	 
	    try { 
	        hash = MessageDigest.getInstance("MD5").digest(string.getBytes("UTF-8")); 
	    } catch (NoSuchAlgorithmException e) { 
	        throw new RuntimeException("MD5 should be supported!", e); 
	    } catch (UnsupportedEncodingException e) { 
	        throw new RuntimeException("UTF-8 should be supported!", e); 
	    } 
	 
	    StringBuilder hex = new StringBuilder(hash.length * 2); 
	    for (byte b : hash) { 
	        if ((b & 0xFF) < 0x10) hex.append("0"); 
	        hex.append(Integer.toHexString(b & 0xFF)); 
	    }
	    return hexStringToByteArray(hex.toString());
	}
	
	public static byte[] hexStringToByteArray(String s) {
        int len = s.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                    + Character.digit(s.charAt(i+1), 16));
        }
        return data;
    }
}
