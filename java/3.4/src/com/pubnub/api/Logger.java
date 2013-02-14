package com.pubnub.api;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class Logger {
	private Class _class;
	private Log log ;

	public Logger(Class _class) {
		this._class = _class;
		log = LogFactory.getLog(this._class);
	}

	public void debug(String s) {
		log.debug(s);
	}
	public void trace(String s) {
		log.trace(s);
	}
	public void error(String s) {
		log.error(s);
	}
	public void info(String s) {
		log.info(s);
	}
}
