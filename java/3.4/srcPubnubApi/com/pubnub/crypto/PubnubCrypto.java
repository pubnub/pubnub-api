package com.pubnub.crypto;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.util.Enumeration;

import org.bouncycastle.crypto.DataLengthException;
import org.bouncycastle.crypto.Digest;
import org.bouncycastle.crypto.InvalidCipherTextException;
import org.bouncycastle.crypto.digests.MD5Digest;
import org.bouncycastle.crypto.digests.SHA256Digest;
import org.bouncycastle.crypto.engines.AESEngine;
import org.bouncycastle.crypto.macs.HMac;
import org.bouncycastle.crypto.modes.CBCBlockCipher;
import org.bouncycastle.crypto.paddings.PaddedBufferedBlockCipher;
import org.bouncycastle.crypto.params.KeyParameter;
import org.bouncycastle.crypto.params.ParametersWithIV;
import org.bouncycastle.util.BigInteger;
import org.bouncycastle.util.encoders.Hex;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * PubNub 3.1 Cryptography
 *
 */
public class PubnubCrypto {

	PaddedBufferedBlockCipher encryptCipher = null;
	PaddedBufferedBlockCipher decryptCipher = null;
	byte[] buf = new byte[16]; // input buffer
	byte[] obuf = new byte[512]; // output buffer
	byte[] key = null;
	byte[] IV = null;
	public static int blockSize = 16;
	String CIPHER_KEY;

	public PubnubCrypto(String CIPHER_KEY) {
		this.CIPHER_KEY = CIPHER_KEY;
	}

	public void InitCiphers() throws UnsupportedEncodingException {

		key = new String(Hex.encode(sha256(this.CIPHER_KEY.getBytes("UTF-8"))),
				"UTF-8").substring(0, 32).toLowerCase().getBytes("UTF-8");
		IV = "0123456789012345".getBytes("UTF-8");

		encryptCipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(
				new AESEngine()));

		decryptCipher = new PaddedBufferedBlockCipher(new CBCBlockCipher(
				new AESEngine()));

		// create the IV parameter
		ParametersWithIV parameterIV = new ParametersWithIV(new KeyParameter(
				key), IV);

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

	public String encrypt(String input) throws DataLengthException,
			IllegalStateException, InvalidCipherTextException {
		try {
			InputStream st = new ByteArrayInputStream(input.getBytes("UTF-8"));
			ByteArrayOutputStream ou = new ByteArrayOutputStream();
			CBCEncryptOrDecrypt(st, ou, true);
			String s = new String(Base64Encoder.encode(ou.toByteArray()));
			return s;
		} catch (IOException ex) {
			ex.printStackTrace();
		}
		return "NULL";
	}

	/**
	 * Decrypt
	 *
	 * @param String
	 *            cipherText
	 * @return String
	 * @throws Exception
	 */
	public String decrypt(String cipher_text) throws DataLengthException,
			IllegalStateException, InvalidCipherTextException, IOException {

		byte[] cipher = Base64Encoder.decode(cipher_text);
		InputStream st = new ByteArrayInputStream(cipher);
		ByteArrayOutputStream ou = new ByteArrayOutputStream();
		CBCEncryptOrDecrypt(st, ou, false);

		return new String(ou.toByteArray());

	}

	public void CBCEncryptOrDecrypt(InputStream in, OutputStream out,
			boolean encrypt) throws DataLengthException, IllegalStateException,
			InvalidCipherTextException, IOException {
		if (encryptCipher == null || decryptCipher == null) {
			InitCiphers();
		}
		PaddedBufferedBlockCipher cipher = (encrypt) ? encryptCipher
				: decryptCipher;
		int noBytesRead = 0; // number of bytes read from input
		int noBytesProcessed = 0; // number of bytes processed

		while ((noBytesRead = in.read(buf)) >= 0) {
			noBytesProcessed = cipher
					.processBytes(buf, 0, noBytesRead, obuf, 0);
			out.write(obuf, 0, noBytesProcessed);
		}

		noBytesProcessed = cipher.doFinal(obuf, 0);
		out.write(obuf, 0, noBytesProcessed);
		out.flush();
		in.close();
		out.close();
	}

	public static byte[] hexStringToByteArray(String s) {
		int len = s.length();
		byte[] data = new byte[len / 2];
		for (int i = 0; i < len; i += 2) {
			data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4) + Character
					.digit(s.charAt(i + 1), 16));
		}
		return data;
	}

	/**
	 * Sign Message
	 *
	 * @param String
	 *            input
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

	/**
	 * Get SHA256
	 *
	 * @param string
	 * @return
	 */
	public static byte[] sha256(byte[] input) {

		Digest digest = new SHA256Digest();
		byte[] resBuf = new byte[digest.getDigestSize()];
		byte[] bytes = input;
		digest.update(bytes, 0, bytes.length);
		digest.doFinal(resBuf, 0);
		return resBuf;
	}

}
