package com.pubnub.httpclient;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.Hashtable;

import javax.microedition.io.Connector;
import javax.microedition.io.HttpConnection;

public class HttpClientCore extends HttpClient {
	private int requestTimeout = 310000;
	private int connTimeout = 5000;

	public HttpClientCore() {

	}

	public HttpClientCore(int requestTimeout, int connTimeout) {
		this.setRequestTimeout(requestTimeout);
		this.setConnTimeout(connTimeout);
	}

	public int getRequestTimeout() {
		return requestTimeout;
	}

	public void setRequestTimeout(int requestTimeout) {
		this.requestTimeout = requestTimeout;
	}

	public int getConnTimeout() {
		return connTimeout;
	}

	public void setConnTimeout(int connTimeout) {
		this.connTimeout = connTimeout;
	}

	private String readResponse(HttpConnection hconn) {
		InputStream in = null;
		String prefix = "";
		try {
			StringBuffer b = new StringBuffer();
			int ch;
			b.append(prefix);
			in = hconn.openInputStream();

			byte[] data = null;
			ByteArrayOutputStream tmp = new ByteArrayOutputStream();

			while ((ch = in.read()) != -1) {
				tmp.write(ch);
			}
			data = tmp.toByteArray();
			tmp.close();
			b.append(new String(data, "UTF-8"));

			if (b.length() > 0) {
				return b.toString();
			} else
				return null;

		} catch (IOException ioe) {
			return null;
		} finally {
			if (in != null) {
				try {
					in.close();
				} catch (IOException e) {
				}
			}
		}
	}

	public boolean isRedirect(int rc) {
		return (rc == HttpConnection.HTTP_MOVED_PERM
				|| rc == HttpConnection.HTTP_MOVED_TEMP
				|| rc == HttpConnection.HTTP_SEE_OTHER || rc == HttpConnection.HTTP_TEMP_REDIRECT);
	}

	public boolean checkResponse(int rc) {

		return (rc == HttpConnection.HTTP_OK || isRedirect(rc));
	}

	public HttpResponse fetch(String url) throws IOException {
		return fetch(url, null);
	}

	public HttpResponse fetch(String url, Hashtable headers) throws IOException {
		if (url == null)
			throw new IOException("Invalid Url");

		int follow = 5;
		int rc = 0;
		HttpConnection hc = null;
		String response = null;

		while (follow-- > 0) {

			hc = (HttpConnection) Connector.open(url, Connector.READ_WRITE,
					true);
			hc.setRequestMethod(HttpConnection.GET);
			if (headers != null) {
				Enumeration en = headers.keys();
				while (en.hasMoreElements()) {
					String key = (String) en.nextElement();
					String val = (String) headers.get(key);
					hc.setRequestProperty(key, val);

				}
			}

			rc = hc.getResponseCode();

			if (!checkResponse(rc)) {
				break;
			} else if (!isRedirect(rc)) {
				break;
			}

			url = hc.getHeaderField("Location");

			if (url == null) {
				throw new IOException("No Location header");
			}

			if (url.startsWith("/")) {
				StringBuffer b = new StringBuffer();
				b.append("http://");
				b.append(hc.getHost());
				b.append(':');
				b.append(hc.getPort());
				b.append(url);
				url = b.toString();
			} else if (url.startsWith("ttp:")) {
				url = "h" + url;
			}
			hc.close();
		}

		if (follow == 0) {
			throw new IOException("Too many redirects");
		}

		response = readResponse(hc);
		hc.close();
		return new HttpResponse(rc, response);
	}

	public boolean isOk(int rc) {
		return (rc == HttpConnection.HTTP_OK );
	}
}
