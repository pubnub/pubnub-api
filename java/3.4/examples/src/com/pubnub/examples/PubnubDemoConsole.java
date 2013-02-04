package com.pubnub.examples;

import java.util.Hashtable;
import java.util.Scanner;

import com.pubnub.api.Callback;
import com.pubnub.api.Pubnub;
import com.pubnub.api.PubnubException;
import com.pubnub.api.PubnubUtil;

public class PubnubDemoConsole {

	Pubnub pubnub;

	String cipher_key = "";
	boolean SSL;
	Scanner reader;

	private void notifyUser(Object message) {
		System.out.println(message.toString());
	}
	private void publish(String channel) {
		System.out.println("Enter the message for publish. To exit loop enter QUIT");
		String message ; 
		while (!(message = reader.nextLine()).equalsIgnoreCase("QUIT")) {
			Hashtable args = new Hashtable(2);
			args.put("channel", channel); // Channel Name
			args.put("message", message); // JSON Message
			pubnub.publish(args, new Callback() {
				public void successCallback(String channel, Object message) {
					notifyUser("PUBLISH : " + message);
				}

				public void errorCallback(String channel, Object message) {
					notifyUser("PUBLISH : " + message);
				}
			});
		}


	}
	private void subscribe(String channel) {
		Hashtable args = new Hashtable(6);
		args.put("channel", channel);

		try {
			pubnub.subscribe(args, new Callback() {
				public void connectCallback(String channel) {
					notifyUser("SUBSCRIBE : CONNECT on channel:" + channel);
				}

				public void disconnectCallback(String channel) {
					notifyUser("SUBSCRIBE : DISCONNECT on channel:" + channel);
				}

				public void reconnectCallback(String channel) {
					notifyUser("SUBSCRIBE : RECONNECT on channel:" + channel);
				}

				public void successCallback(String channel, Object message) {
					notifyUser("SUBSCRIBE : "  + channel + " : " + message.getClass() + " : " + message.toString());
				}
				public void errorCallback(String channel, Object message) {
					notifyUser("SUBSCRIBE : Unsubscribed from " + channel + " : " + message.getClass() + " : " + message.toString());
				}
			});

		} catch (Exception e) {

		}
	}
	private void presence(String channel) {
		try {
			pubnub.presence(channel, new Callback() {
				public void successCallback(String channel, Object message) {
					notifyUser("PRESENCE : " + message);
				}

				public void errorCallback(String channel, Object message) {
					notifyUser("PRESENCE : " + message);
				}
			});
		} catch (PubnubException e) {

		}
	}
	private void detailedHistory(String channel) {
		pubnub.detailedHistory(channel, 2, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser("DETAILED HISTORY : " + message);
			}

			public void errorCallback(String channel, Object message) {
				notifyUser("DETAILED HISTORY : " + message);
			}
		});
	}
	private void hereNow(String channel) {
		pubnub.hereNow(channel, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser("HERE NOW : " + message);
			}

			public void errorCallback(String channel, Object message) {
				notifyUser("HERE NOW : " + message);
			}
		});
	}

	private void unsubscribe(String channel) {
		pubnub.unsubscribe(channel);
	}

	private void unsubscribePresence(String channel) {
		pubnub.unsubscribePresence(channel);
	}

	private void time() {
		pubnub.time(new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser("TIME : " + message);
			}

			public void errorCallback(String channel, Object message) {
				notifyUser("TIME : " + message);
			}
		});
	}
	
	private void disconnectAndResubscribe() {
		pubnub.disconnectAndResubscribe();
		
	}
	
	private void setMaxRetries(int maxRetries) {
		pubnub.setMaxRetries(maxRetries);
	}
	
	private void setRetryInterval(int retryInterval) {
		pubnub.setRetryInterval(retryInterval);
	}
	
	public void startDemo() {
		reader = new Scanner(System.in);
		System.out.println("HINT:\tTo test Re-connect and catch-up");
		System.out.println("\tDisconnect your machine from network/internet and");
		System.out.println("\tre-connect your machine after sometime");

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

        displayMenuOptions();
		
		String channelName = null;
		int command = 0;
		while ((command = reader.nextInt()) != 9 ){
			reader.nextLine();
			switch(command) {

            case 0:
                displayMenuOptions();
			case 1:
				System.out.println("Subscribe: Enter Channel name");
				channelName = reader.nextLine();
				subscribe(channelName);
				System.out.println("Subscribed to following channels: ");
				System.out.println(PubnubUtil.joinString(pubnub.getSubscribedChannelsArray(), " : "));
				break;
			case 2:
				System.out.println("Publish: Enter Channel name");
				channelName = reader.nextLine();
				publish(channelName);
				break;
			case 3:
				System.out.println("Presence: Enter Channel name");
				channelName = reader.nextLine();
				presence(channelName);
				break;
			case 4:
				System.out.println("Detailed History: Enter Channel name");
				channelName = reader.nextLine();
				detailedHistory(channelName);
				break;
			case 5:
				System.out.println("Here Now : Enter Channel name");
				channelName = reader.nextLine();
				hereNow(channelName);
				break;
			case 6:
				System.out.println("Unsubscribe: Enter Channel name");
				channelName = reader.nextLine();
				unsubscribe(channelName);
				break;
			case 7:
				System.out.println("UnsubscribePresence : Enter Channel name");
				channelName = reader.nextLine();
				unsubscribePresence(channelName);
				break;
			case 8:
				time();
				break;
			case 10:
				disconnectAndResubscribe();
				break;
			case 11:
				pubnub.setResumeOnReconnect(pubnub.isResumeOnReconnect()?false:true);
				System.out.println("RESUME ON RECONNECT : " + pubnub.isResumeOnReconnect() );
				break;
			case 12: 
				System.out.println("Set Max Retries: Enter max retries");
				int maxRetries = reader.nextInt();
				reader.nextLine();
				setMaxRetries(maxRetries);
				break;
			case 13: 
				System.out.println("Set Retry Interval: Enter retry interval");
				int retryInterval = reader.nextInt();
				reader.nextLine();
				setRetryInterval(retryInterval);
				break;
			default: 
				System.out.println("Invalid Input");
			}
            displayMenuOptions();
		}
		System.out.println("Exiting");
		pubnub.shutdown();

	}

    private void displayMenuOptions() {
        System.out.println("ENTER 1  FOR Subscribe " + "(Currently subscribed to " + this.pubnub.getCurrentlySubscribedChannelNames() + ")");
        System.out.println("ENTER 2  FOR Publish");
        System.out.println("ENTER 3  FOR Presence");
        System.out.println("ENTER 4  FOR Detailed History");
        System.out.println("ENTER 5  FOR Here_Now");
        System.out.println("ENTER 6  FOR Unsubscribe");
        System.out.println("ENTER 7  FOR Presence-Unsubscribe");
        System.out.println("ENTER 8  FOR Time");
        System.out.println("ENTER 9  FOR EXIT OR QUIT");
        System.out.println("ENTER 10 FOR Disconnect-And-Resubscribe");
        System.out.println("ENTER 11 FOR Toggle Resume On Reconnect");
        System.out.println("ENTER 12 FOR Setting MAX Retries");
        System.out.println("ENTER 13 FOR Setting Retry Interval");
        System.out.println("\nENTER 0 to display this menu");
    }

    /**
	 * @param args
	 */
	public static void main(String[] args) {
		new PubnubDemoConsole().startDemo();
	}

}
