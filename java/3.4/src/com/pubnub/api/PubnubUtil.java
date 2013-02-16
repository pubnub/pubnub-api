package com.pubnub.api;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

public class PubnubUtil extends PubnubUtilCore {
	
	/**
	 * Returns encoded String
	 *
	 * @param sUrl
	 *            , input string
	 * @return , encoded string
	 */
	public static String urlEncode(String sUrl) {
		try {
			return URLEncoder.encode(sUrl, "UTF-8").replace("+", "%20");
		} catch (UnsupportedEncodingException e) {
			return null;
		}
	}
}
