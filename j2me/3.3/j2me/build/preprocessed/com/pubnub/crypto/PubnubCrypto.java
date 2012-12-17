package com.pubnub.crypto;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import java.util.Enumeration;
import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.ShortBufferException;
import org.bouncycastle.crypto.digests.MD5Digest;
import org.bouncycastle.crypto.macs.HMac;
import org.bouncycastle.crypto.digests.SHA256Digest;

import org.bouncycastle.crypto.DataLengthException;
import org.bouncycastle.crypto.InvalidCipherTextException;
import org.bouncycastle.crypto.engines.AESEngine;

import org.bouncycastle.crypto.modes.CBCBlockCipher;
import org.bouncycastle.crypto.paddings.PaddedBufferedBlockCipher;
import org.bouncycastle.crypto.params.KeyParameter;
import org.bouncycastle.crypto.params.ParametersWithIV;
import org.bouncycastle.util.BigInteger;
import org.json.me.JSONArray;
import org.json.me.JSONException;
import org.json.me.JSONObject;

/**
 * PubNub 3.1 Cryptography
 *
 */
public class PubnubCrypto {

    private final String CIPHER_KEY;
    PaddedBufferedBlockCipher encryptCipher = null;
    PaddedBufferedBlockCipher decryptCipher = null;
    byte[] buf = new byte[16];              //input buffer
    byte[] obuf = new byte[512];            //output buffer
    byte[] key = null;
    byte[] IV = null;
    public static int blockSize = 16;

    public PubnubCrypto(String CIPHER_KEY) {
        this.CIPHER_KEY = CIPHER_KEY;
        key = PubnubCrypto.md5(CIPHER_KEY);
        IV = "0123456789012345".getBytes();
        InitCiphers();
    }

    public void InitCiphers() {
        encryptCipher = new PaddedBufferedBlockCipher(
                new CBCBlockCipher(new AESEngine()));

        decryptCipher = new PaddedBufferedBlockCipher(
                new CBCBlockCipher(new AESEngine()));

        //create the IV parameter
        ParametersWithIV parameterIV =
                new ParametersWithIV(new KeyParameter(key), IV);

        encryptCipher.init(true, parameterIV);
        decryptCipher.init(false, parameterIV);
    }

    public void ResetCiphers() {
        if (encryptCipher != null) {
            encryptCipher.reset();
        }
        if (decryptCipher != null) {
            decryptCipher.reset();
        }
    }

    public String encrypt(String input)
            throws ShortBufferException, IllegalBlockSizeException, BadPaddingException,
            DataLengthException, IllegalStateException, InvalidCipherTextException {
        try {
            InputStream st = new ByteArrayInputStream(input.getBytes());
            ByteArrayOutputStream ou = new ByteArrayOutputStream();
            CBCEncrypt(st, ou);

            return new String(Base64Encoder.encode(ou.toByteArray()));
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        return "NULL";
    }

    /**
     * Decrypt
     *
     * @param String cipherText
     * @return String
     * @throws Exception
     */
    public String decrypt(String cipher_text) throws ShortBufferException,
            IllegalBlockSizeException,
            BadPaddingException,
            DataLengthException,
            IllegalStateException,
            InvalidCipherTextException,
            IOException {
        try {
            byte[] cipher = Base64Encoder.decode(cipher_text);
            InputStream st = new ByteArrayInputStream(cipher);
            ByteArrayOutputStream ou = new ByteArrayOutputStream();
            CBCDecrypt(st, ou);

            return new String(ou.toByteArray());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return cipher_text;
    }

    public void CBCEncrypt(InputStream in, OutputStream out)
            throws ShortBufferException,
            IllegalBlockSizeException,
            BadPaddingException,
            DataLengthException,
            IllegalStateException,
            InvalidCipherTextException,
            IOException {

        int noBytesRead = 0;        //number of bytes read from input
        int noBytesProcessed = 0;   //number of bytes processed

        while ((noBytesRead = in.read(buf)) >= 0) {

            noBytesProcessed =
                    encryptCipher.processBytes(buf, 0, noBytesRead, obuf, 0);
            out.write(obuf, 0, noBytesProcessed);
        }

        noBytesProcessed = encryptCipher.doFinal(obuf, 0);
        out.write(obuf, 0, noBytesProcessed);
        out.flush();
        in.close();
        out.close();
    }

    public void CBCDecrypt(InputStream in, OutputStream out)
            throws ShortBufferException,
            IllegalBlockSizeException,
            BadPaddingException,
            DataLengthException,
            IllegalStateException,
            InvalidCipherTextException,
            IOException {
        int noBytesRead = 0;        //number of bytes read from input
        int noBytesProcessed = 0;   //number of bytes processed

        while ((noBytesRead = in.read(buf)) >= 0) {
            noBytesProcessed =
                    decryptCipher.processBytes(buf, 0, noBytesRead, obuf, 0);
            out.write(obuf, 0, noBytesProcessed);
        }
        noBytesProcessed = decryptCipher.doFinal(obuf, 0);
        out.write(obuf, 0, noBytesProcessed);

        out.flush();

        in.close();
        out.close();
    }

    public static byte[] hexStringToByteArray(String s) {
        int len = s.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
                    + Character.digit(s.charAt(i + 1), 16));
        }
        return data;
    }

    /**
     * Encrypt
     *
     * @param JSONObject Message to encrypt
     * @return JSONObject as Encrypted message
     */
    public JSONObject encrypt(JSONObject message) {

        JSONObject message_encrypted = new JSONObject();
        try {
            Enumeration it = message.keys();
            while (it.hasMoreElements()) {
                String key = (String) it.nextElement();
                String val = message.getString(key);
                message_encrypted.put(key, encrypt(val));
            }
        } catch (ShortBufferException ex) {
            ex.printStackTrace();
        } catch (IllegalBlockSizeException ex) {
            ex.printStackTrace();
        } catch (BadPaddingException ex) {
            ex.printStackTrace();
        } catch (DataLengthException ex) {
            ex.printStackTrace();
        } catch (IllegalStateException ex) {
            ex.printStackTrace();
        } catch (InvalidCipherTextException ex) {
            ex.printStackTrace();
        } catch (JSONException ex) {
            ex.printStackTrace();
        }
        return message_encrypted;
    }

    /**
     * Decrypt
     *
     * @param JSONObject Encrypted message
     * @return JSONObject Message decrypted
     */
    public JSONObject decrypt(JSONObject message_encrypted) {

        JSONObject message_decrypted = new JSONObject();
        try {
            Enumeration it = message_encrypted.keys();

            while (it.hasMoreElements()) {
                String key1 = (String) it.nextElement();
                String encrypted_str = message_encrypted.getString(key1);
                String decrypted_str;
                decrypted_str = decrypt(encrypted_str);
                message_decrypted.put(key1, decrypted_str);
            }

        } catch (ShortBufferException ex) {
        } catch (IllegalBlockSizeException ex) {
            ex.printStackTrace();
        } catch (BadPaddingException ex) {
            ex.printStackTrace();
        } catch (DataLengthException ex) {
            ex.printStackTrace();
        } catch (IllegalStateException ex) {
            ex.printStackTrace();
        } catch (InvalidCipherTextException ex) {
            ex.printStackTrace();
        } catch (IOException ex) {
            ex.printStackTrace();
        } catch (JSONException ex) {
            ex.printStackTrace();
        }
        return message_decrypted;
    }

    /**
     * Encrypt JSONArray
     *
     * @param JSONArray - Encrypted JSONArray
     * @return JSONArray - Decrypted JSONArray
     */
    public JSONArray encryptJSONArray(JSONArray jsona_arry) {

        JSONArray jsona_decrypted = new JSONArray();
        try {
            for (int i = 0; i < jsona_arry.length(); i++) {
                Object o = jsona_arry.get(i);
                if (o != null) {
                    if (o instanceof JSONObject) {
                        jsona_decrypted.put(i, encrypt((JSONObject) o));
                    } else if (o instanceof JSONArray) {
                        jsona_decrypted.put(i, encryptJSONArray((JSONArray) o));
                    } else if (o instanceof String) {
                        jsona_decrypted.put(i, encrypt(o.toString()));
                    }
                }
            }



        } catch (ShortBufferException ex) {
            ex.printStackTrace();
        } catch (IllegalBlockSizeException ex) {
            ex.printStackTrace();
        } catch (BadPaddingException ex) {
            ex.printStackTrace();
        } catch (DataLengthException ex) {
            ex.printStackTrace();
        } catch (IllegalStateException ex) {
            ex.printStackTrace();
        } catch (InvalidCipherTextException ex) {
            ex.printStackTrace();

        } catch (JSONException ex) {
            ex.printStackTrace();
        }
        return jsona_decrypted;
    }

    /**
     * Decrypt JSONArray
     *
     * @param JSONArray - Encrypted JSONArray
     * @return JSONArray - Decrypted JSONArray
     */
    public JSONArray decryptJSONArray(JSONArray jsona_encrypted) throws IOException {

        JSONArray jsona_decrypted = new JSONArray();
        try {
            for (int i = 0; i < jsona_encrypted.length(); i++) {
                Object o = jsona_encrypted.get(i);
                if (o != null) {
                    if (o instanceof JSONObject) {
                        jsona_decrypted.put(i, decrypt((JSONObject) o));
                    } else if (o instanceof JSONArray) {
                        jsona_decrypted.put(i, decryptJSONArray((JSONArray) o));
                    } else if (o instanceof String) {
                        jsona_decrypted.put(i, decrypt(o.toString()));
                    }
                }
            }
        } catch (ShortBufferException ex) {
            ex.printStackTrace();
        } catch (IllegalBlockSizeException ex) {
            ex.printStackTrace();
        } catch (BadPaddingException ex) {
            ex.printStackTrace();
        } catch (DataLengthException ex) {
            ex.printStackTrace();
        } catch (IllegalStateException ex) {
            ex.printStackTrace();
        } catch (InvalidCipherTextException ex) {
            ex.printStackTrace();

        } catch (JSONException ex) {
            ex.printStackTrace();
        }
        return jsona_decrypted;


    }

    /**
     * Sign Message
     *
     * @param String input
     * @return String as HashText
     */
    public static String getHMacSHA256(String secret_key, String input) {

        String signature = "0";
        try {
            HMac m = new HMac(new SHA256Digest());
            m.init(new KeyParameter(secret_key.getBytes("UTF-8")));
            byte[] bytes = input.getBytes("UTF-8");
            m.update(bytes, 0, bytes.length);
            byte[] mac = new byte[m.getMacSize()];
            m.doFinal(mac, 0);
            BigInteger number = new BigInteger(1, mac);
            String hashtext = number.toString(16);
            signature = hashtext;	
        } catch (java.io.UnsupportedEncodingException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return signature;
    }

    public static final String base64Encode(byte[] in) {
        int iLen = in.length;
        int oDataLen = (iLen * 4 + 2) / 3; // output length without padding
        int oLen = ((iLen + 2) / 3) * 4;   // output length including padding
        char[] out = new char[oLen];
        int ip = 0;
        int op = 0;
        int i0;
        int i1;
        int i2;
        int o0;
        int o1;
        int o2;
        int o3;
        while (ip < iLen) {
            i0 = in[ip++] & 0xff;
            i1 = ip < iLen ? in[ip++] & 0xff : 0;
            i2 = ip < iLen ? in[ip++] & 0xff : 0;
            o0 = i0 >>> 2;
            o1 = ((i0 & 3) << 4) | (i1 >>> 4);
            o2 = ((i1 & 0xf) << 2) | (i2 >>> 6);
            o3 = i2 & 0x3F;
            out[op++] = map1[o0];
            out[op++] = map1[o1];
            out[op] = op < oDataLen ? map1[o2] : '=';
            op++;
            out[op] = op < oDataLen ? map1[o3] : '=';
            op++;
        }
        return new String(out);
    }
    private static char[] map1 = new char[64];

    static {
        int i = 0;
        for (char c = 'A'; c <= 'Z'; c++) {
            map1[i++] = c;
        }
        for (char c = 'a'; c <= 'z'; c++) {
            map1[i++] = c;
        }
        for (char c = '0'; c <= '9'; c++) {
            map1[i++] = c;
        }
        map1[i++] = '+';
        map1[i++] = '/';
    }

    /**
     * Get MD5
     *
     * @param string
     * @return
     */
    public static byte[] md5(String myString) {
        MD5Digest digest = new MD5Digest();
        byte[] bytes = myString.getBytes();
        digest.update(bytes, 0, bytes.length);
        byte[] md5 = new byte[digest.getDigestSize()];
        digest.doFinal(md5, 0);
        StringBuffer hex = new StringBuffer(md5.length * 2);
        for (int i = 0; i < md5.length; i++) {
            byte b = md5[i];
            if ((b & 0xFF) < 0x10) {
                hex.append("0");
            }
            hex.append(Integer.toHexString(b & 0xFF));
        }
        return hexStringToByteArray(hex.toString());
    }
}
