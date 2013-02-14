package com.pubnub.api;

import org.bouncycastle.util.SecureRandom;

import com.pubnub.crypto.PubnubCrypto;

public class Pubnub extends PubnubCore {

	public Pubnub(String publish_key, String subscribe_key, String secret_key,
			String cipher_key, boolean ssl_on) {
		super(publish_key, subscribe_key, secret_key, cipher_key, ssl_on);
	}

	public Pubnub(String publish_key, String subscribe_key, String secret_key,
			boolean ssl_on) {
		super(publish_key, subscribe_key, secret_key, "", ssl_on);
	}


	public Pubnub(String publish_key, String subscribe_key) {
		super(publish_key, subscribe_key, "", "", false);
	}

	public Pubnub(String publish_key, String subscribe_key, boolean ssl) {
		super(publish_key, subscribe_key, "", "", ssl);
	}

	public Pubnub(String publish_key, String subscribe_key, String secret_key) {
		super(publish_key, subscribe_key, secret_key, "", false);
	}

	/**
	 * UUID
	 *
	 * 32 digit UUID generation at client side.
	 *
	 * @return String uuid.
	 */
	public String uuid() {

		String valueBeforeMD5;
		String valueAfterMD5;
		SecureRandom mySecureRand = new SecureRandom();
		String s_id = String.valueOf(PubnubCore.class.hashCode());
		StringBuffer sbValueBeforeMD5 = new StringBuffer();
		try {
			long time = System.currentTimeMillis();
			long rand = 0;
			rand = mySecureRand.nextLong();
			sbValueBeforeMD5.append(s_id);
			sbValueBeforeMD5.append(":");
			sbValueBeforeMD5.append(Long.toString(time));
			sbValueBeforeMD5.append(":");
			sbValueBeforeMD5.append(Long.toString(rand));
			valueBeforeMD5 = sbValueBeforeMD5.toString();
			byte[] array = PubnubCrypto.md5(valueBeforeMD5);
			StringBuffer sb = new StringBuffer();
			for (int j = 0; j < array.length; ++j) {
				int b = array[j] & 0xFF;
				if (b < 0x10) {
					sb.append('0');
				}
				sb.append(Integer.toHexString(b));
			}
			valueAfterMD5 = sb.toString();
			String raw = valueAfterMD5.toUpperCase();
			sb = new StringBuffer();
			sb.append(raw.substring(0, 8));
			sb.append("-");
			sb.append(raw.substring(8, 12));
			sb.append("-");
			sb.append(raw.substring(12, 16));
			sb.append("-");
			sb.append(raw.substring(16, 20));
			sb.append("-");
			sb.append(raw.substring(20));
			return sb.toString();
		} catch (Exception e) {
			return null;
		}
	}


}
