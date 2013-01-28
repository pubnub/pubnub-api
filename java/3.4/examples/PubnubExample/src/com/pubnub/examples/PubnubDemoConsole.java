package com.pubnub.examples;

import java.util.Hashtable;
import java.util.Scanner;

import com.pubnub.api.Callback;
import com.pubnub.api.Pubnub;
import com.pubnub.api.PubnubException;

public class PubnubDemoConsole {

	Pubnub pubnub;
	String channel = "";
	String cipher_key = "";
	boolean SSL;
	Scanner reader;

	private void notifyUser(Object message) {
		System.out.println(message.toString());
	}
	private void publish() {
		System.out.println("Enter the message for publish. To exit loop enter QUIT");
		String message ; 
		while (!(message = reader.nextLine()).equalsIgnoreCase("QUIT")) {
			Hashtable args = new Hashtable(2);
			args.put("channel", this.channel); // Channel Name
			args.put("message", message); // JSON Message
			pubnub.publish(args, new Callback() {
				public void successCallback(String channel, Object message) {
					notifyUser(message);
				}

				public void errorCallback(String channel, Object message) {
					notifyUser(message);
				}
			});
		}


	}
	private void subscribe() {
		Hashtable args = new Hashtable(6);
		args.put("channel", channel);

		try {
			pubnub.subscribe(args, new Callback() {
				public void connectCallback(String channel) {
					notifyUser("CONNECT on channel:" + channel);
				}

				public void disconnectCallback(String channel) {
					notifyUser("DISCONNECT on channel:" + channel);
				}

				public void reconnectCallback(String channel) {
					notifyUser("RECONNECT on channel:" + channel);
				}

				public void successCallback(String channel, Object message) {
					notifyUser(message);
				}
				public void errorCallback(String channel, Object message) {
					notifyUser(message);
				}
			});

		} catch (Exception e) {

		}
	}
	private void presence() {
		try {
			pubnub.presence(this.channel, new Callback() {
				public void successCallback(String channel, Object message) {
					notifyUser(message);
				}

				public void errorCallback(String channel, Object message) {
					notifyUser(message);
				}
			});
		} catch (PubnubException e) {

		}
	}
	private void detailedHistory() {
		pubnub.detailedHistory(this.channel, 2, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(message);
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(message);
			}
		});
	}
	private void hereNow() {
		pubnub.hereNow(this.channel, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(message);
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(message);
			}
		});
	}

	private void unsubscribe() {
		pubnub.unsubscribe(this.channel);
	}

	private void presenceUnsubscribe() {

	}

	private void time() {
		pubnub.time(new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(message);
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(message);
			}
		});
	}
	public void startDemo() {
		reader = new Scanner(System.in);
		System.out.println("HINT:\tTo test Re-connect and catch-up");
		System.out.println("\tDisconnect your machine from network/internet and");
		System.out.println("\tre-connect your machine after sometime");

		while (this.channel.length() == 0) {
			System.out.println("Enter Channel Name");
			this.channel = reader.nextLine();
		}
		System.out.println("Channel = " + this.channel);
		System.out.println("Enable SSL ? Enter Y for Yes, else N");
		String sslOn = reader.nextLine();
		System.out.println(sslOn);
		this.SSL = (sslOn.equalsIgnoreCase("y"))?true:false;
		if (this.SSL) {
			System.out.println("SSL enabled");
		} else {
			System.out.println("SSL not enabled");
		}

		System.out.println("Enter cipher key for encryption feature");
		System.out.println("If you don't want to avail at this time, press ENTER");
		this.cipher_key = reader.nextLine();
		if (this.cipher_key.length() == 0) {
			System.out.println("No Cipher key provided");
			pubnub = new Pubnub("demo", "demo", "demo", this.SSL);
		} else {
			System.out.println("Cipher Key = " + this.cipher_key);
			pubnub = new Pubnub("demo", "demo", "demo", this.cipher_key, this.SSL);
		}

		System.out.println("ENTER 1 FOR Subscribe");
		System.out.println("ENTER 2 FOR Publish");
		System.out.println("ENTER 3 FOR Presence");
		System.out.println("ENTER 4 FOR Detailed History");
		System.out.println("ENTER 5 FOR Here_Now");
		System.out.println("ENTER 6 FOR Unsubscribe");
		//System.out.println("ENTER 7 FOR Presence-Unsubscribe");
		System.out.println("ENTER 8 FOR Time");
		System.out.println("ENTER 9 FOR EXIT OR QUIT");

		int command = 0;
		while ((command = reader.nextInt()) != 9 ){
			switch(command) {
			case 1:
				System.out.println("Running subscribe()");
				subscribe();
				break;
			case 2:
				publish();
				break;
			case 3:
				System.out.println("Running presence()");
				presence();	
				break;
			case 4:
				detailedHistory();
				break;
			case 5:
				hereNow();
				break;
			case 6:
				unsubscribe();
				break;
				/*case 7:
				presenceUnsubscribe();
				break;*/
			case 8:
				time();
				break;
			default: 
				System.out.println("Invalid Input");
			}
		}
		System.out.println("Exiting");
	}
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		new PubnubDemoConsole().startDemo();
	}

}
