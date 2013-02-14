package com.pubnub.crypto;

import org.bouncycastle.crypto.digests.SHA256Digest;
import org.bouncycastle.crypto.macs.HMac;
import org.bouncycastle.crypto.params.KeyParameter;
import org.bouncycastle.util.BigInteger;

public class PubnubCrypto extends PubnubCryptoCore {

	public PubnubCrypto(String CIPHER_KEY) {
		super(CIPHER_KEY);
	}

	/**
	 * Sign Message
	 *
	 * @param String
	 *            input
	 * @return String as HashText
	 */
	public String getHMacSHA256(String secret_key, String input) {

		String signature = "0";
		try {
			HMac m = new HMac(new SHA256Digest());
			m.init(new KeyParameter(secret_key.getBytes("UTF-8")));
			byte[] bytes = input.getBytes("UTF-8");
			m.update(bytes, 0, bytes.length);
			byte[] mac = new byte[m.getMacSize()];
			m.doFinal(mac, 0);
			BigInteger number = new BigInteger(1,mac);
			String hashtext = number.toString();
			signature = hashtext;
		} catch (java.io.UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}

		return signature;
	}

}
