package com.pubnub.api;

public class Logger {
	private Class _class;
	private Logger log;

	public Logger(Class _class) {
		this._class = _class;

	}

	public void debug(String s) {
		//System.out.println(s);
	}
	public void trace(String s) {
		//System.out.println(s);
	}
	public void error(String s) {
		//System.out.println(s);
	}
	public void info(String s) {
		//System.out.println(s);
	}
}
