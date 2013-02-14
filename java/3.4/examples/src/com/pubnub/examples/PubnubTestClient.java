package com.pubnub.examples;

import java.util.Hashtable;

import com.pubnub.api.Callback;
import com.pubnub.api.Pubnub;

public class PubnubTestClient {
	Pubnub pubnub;
	int recvSuccess;
	int recvErrors;
	int sendSuccess;
	int sendErrors;
	
	PubnubTestClient() {
		pubnub = new Pubnub("demo", "demo", "demo",  false);
	}
	
	public void runTest() {
		Hashtable args = new Hashtable();
		args.put("channel", "TestClientChannel");
		try {
			pubnub.subscribe(args, new Callback() {

				public void successCallback(String channel, Object message) {
					recvSuccess++;
				}
				public void errorCallback(String channel, Object message) {
					recvErrors++;
				}
			});

		} catch (Exception e) {

		}
		Callback publishCb = new Callback() {
			public void successCallback(String channel, Object message) {
				sendSuccess++;
			}

			public void errorCallback(String channel, Object message) {
				System.out.println(message.toString());
				sendErrors++;
			}
		};
		args.put("message", "Test Client Message");
		for (int i = 0; i < 10; i++) {
			pubnub.publish(args, publishCb);
			try {
				Thread.sleep(100);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			System.out.println("Send Success : " + sendSuccess );
			System.out.println("Send Errors : " + sendErrors );
			System.out.println("Receive Success : " + recvSuccess );
			System.out.println("Receive Errors : " + recvErrors );
		}
		System.out.println("Send Success : " + sendSuccess );
		System.out.println("Send Errors : " + sendErrors );
		System.out.println("Receive Success : " + recvSuccess );
		System.out.println("Receive Errors : " + recvErrors );
		
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		new PubnubTestClient().runTest();
		
	}

}
