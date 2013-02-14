package com.pubnub.examples.me;

import javax.microedition.midlet.MIDlet;

import com.pubnub.api.Callback;
import com.pubnub.api.Pubnub;
import com.pubnub.api.PubnubException;

import java.util.Enumeration;
import java.util.Hashtable;
import javax.microedition.lcdui.*;

import org.json.me.JSONArray;
import org.json.me.JSONException;
import org.json.me.JSONObject;

public class PubnubExample extends MIDlet implements CommandListener {

	private boolean midletPaused = false;
	private Command exitCommand;
	private Command publishCommand;
	private Command timeCommand;
	private Command historyCommand;
	private Command unsubscribeCommand;
	private Command subscribeCommand;
	private Command hereNowCommand;
	private Command presenceCommand;
	private Command detailedHistoryCommand;
	private Form form;
	private StringItem stringItem;
	private int count;
	private int recvCount;
	String channel = "hello_world";
	String[] channels = { "hello_world1", "hello_world2", "hello_world3",
			"hello_world4" };

	public PubnubExample() {
	}

	Pubnub _pubnub = new Pubnub("demo", "demo", "demo", false);
	private Command disconnectAndResubscribeCommand;
	private Command toggleResumeOnReconnectCommand;


	/**
	 * Performs an action assigned to the Mobile Device - MIDlet Started point.
	 */
	public void startMIDlet() {
		switchDisplayable(null, getForm());
		_pubnub.setResumeOnReconnect(true);
	}

	/**
	 * Performs an action assigned to the Mobile Device - MIDlet Resumed point.
	 */
	public void resumeMIDlet() {
	}

	public void switchDisplayable(Alert alert, Displayable nextDisplayable) {
		Display display = getDisplay();
		if (alert == null) {
			display.setCurrent(nextDisplayable);
		} else {
			display.setCurrent(alert, nextDisplayable);
		}
	}

	/**
	 * Called by a system to indicated that a command has been invoked on a
	 * particular displayable.
	 *
	 * @param command
	 *            the Command that was invoked
	 * @param displayable
	 *            the Displayable where the command was invoked
	 */
	public void commandAction(Command command, Displayable displayable) {
		if (displayable == form) {
			if (command == exitCommand) {
				exitMIDlet();
			} else if (command == historyCommand) {
				history();
			} else if (command == publishCommand) {
				publish();
			} else if (command == timeCommand) {
				time();
			} else if (command == unsubscribeCommand) {
				unsubscribe();
			} else if (command == subscribeCommand) {
				subscribe();
			} else if (command == hereNowCommand) {
				hereNow();
			} else if (command == presenceCommand) {
				presence();
			} else if (command == detailedHistoryCommand) {
				detailedHistory();
			} else if (command == disconnectAndResubscribeCommand) {
				disconnectAndResubscribe();
			} else if (command == toggleResumeOnReconnectCommand) {
				toggleResumeOnReconnect();
			}
		}
	}



	/**
	 * Returns an initiliazed instance of exitCommand component.
	 *
	 * @return the initialized component instance
	 */
	public Command getExitCommand() {
		if (exitCommand == null) {
			exitCommand = new Command("Exit", Command.EXIT, 0);
		}
		return exitCommand;
	}

	/**
	 * Returns an initiliazed instance of form component.
	 *
	 * @return the initialized component instance
	 */
	public Form getForm() {
		if (form == null) {
			form = new Form("Welcome", new Item[] { getStringItem() });
			form.addCommand(getExitCommand());
			form.addCommand(getPublishCommand());
			form.addCommand(getTimeCommand());
			form.addCommand(getHistoryCommand());
			form.addCommand(getUnsubscribeCommand());
			form.addCommand(getSubscribeCommand());
			form.addCommand(getHereNowCommand());
			form.addCommand(getPresenceCommand());
			form.addCommand(getDetailedHistoryCommand());
			form.addCommand(getDisconnectAndResubscribe());
			form.addCommand(getToggleResumeOnReconnect());
			form.setCommandListener(this);
		}
		return form;
	}

	private Command getToggleResumeOnReconnect() {
		if (toggleResumeOnReconnectCommand == null) {
			toggleResumeOnReconnectCommand = new Command("ToggleResumeOnReconnect",
					Command.ITEM, 0);
		}
		return toggleResumeOnReconnectCommand;
	}

	private Command getDisconnectAndResubscribe() {
		if (disconnectAndResubscribeCommand == null) {
			disconnectAndResubscribeCommand = new Command("DisconnectAndResubscribe",
					Command.ITEM, 0);
		}
		return disconnectAndResubscribeCommand;
	}

	/**
	 * Returns an initiliazed instance of stringItem component.
	 *
	 * @return the initialized component instance
	 */
	public StringItem getStringItem() {
		if (stringItem == null) {
			stringItem = new StringItem("PubnubCore", "Hello PubnubCore!", Item.PLAIN);
		}
		return stringItem;
	}

	/**
	 * Returns an initiliazed instance of detailedHistoryCommand component.
	 *
	 * @return the initialized component instance
	 */
	public Command getDetailedHistoryCommand() {
		if (detailedHistoryCommand == null) {
			detailedHistoryCommand = new Command("DetailedHistory",
					Command.ITEM, 0);
		}
		return detailedHistoryCommand;
	}

	/**
	 * Returns an initiliazed instance of presenceCommand component.
	 *
	 * @return the initialized component instance
	 */
	public Command getPresenceCommand() {
		if (presenceCommand == null) {
			presenceCommand = new Command("Presence", Command.ITEM, 0);
		}
		return presenceCommand;
	}

	/**
	 * Returns an initiliazed instance of publishCommand component.
	 *
	 * @return the initialized component instance
	 */
	public Command getPublishCommand() {
		if (publishCommand == null) {
			publishCommand = new Command("Publish", Command.ITEM, 0);
		}
		return publishCommand;
	}

	/**
	 * Returns an initiliazed instance of timeCommand component.
	 *
	 * @return the initialized component instance
	 */
	public Command getTimeCommand() {
		if (timeCommand == null) {
			timeCommand = new Command("Time", Command.ITEM, 2);
		}
		return timeCommand;
	}

	/**
	 * Returns an initiliazed instance of historyCommand component.
	 *
	 * @return the initialized component instance
	 */
	public Command getHistoryCommand() {
		if (historyCommand == null) {
			historyCommand = new Command("History", Command.ITEM, 1);
		}
		return historyCommand;
	}

	/**
	 * Returns an initiliazed instance of unsubscribeCommand component.
	 *
	 * @return the initialized component instance
	 */
	public Command getUnsubscribeCommand() {
		if (unsubscribeCommand == null) {
			unsubscribeCommand = new Command("Unsubscribe", Command.ITEM, 0);
		}
		return unsubscribeCommand;
	}

	/**
	 * Returns an initiliazed instance of subscribeCommand component.
	 *
	 * @return the initialized component instance
	 */
	public Command getSubscribeCommand() {
		if (subscribeCommand == null) {
			subscribeCommand = new Command("Subscribe", Command.ITEM, 0);
		}
		return subscribeCommand;
	}

	/**
	 * Returns an initiliazed instance of subscribeCommand component.
	 *
	 * @return the initialized component instance
	 */
	private Command getHereNowCommand() {
		if (hereNowCommand == null) {
			hereNowCommand = new Command("HereNow", Command.ITEM, 1);
		}
		return hereNowCommand;
	}

	/**
	 * Returns a display instance.
	 *
	 * @return the display instance.
	 */
	public Display getDisplay() {
		return Display.getDisplay(this);
	}

	/**
	 * Exits MIDlet.
	 */
	public void exitMIDlet() {
		switchDisplayable(null, null);
		destroyApp(true);
		notifyDestroyed();
	}

	/**
	 * Called when MIDlet is started. Checks whether the MIDlet have been
	 * already started and initialize/starts or resumes the MIDlet.
	 */
	public void startApp() {

		if (midletPaused) {
			resumeMIDlet();
		} else {

			startMIDlet();
		}
		midletPaused = false;
	}

	/**
	 * Called when MIDlet is paused.
	 */
	public void pauseApp() {
		midletPaused = true;
	}

	/**
	 * Called to signal the MIDlet to terminate.
	 *
	 * @param unconditional
	 *            if true, then the MIDlet has to be unconditionally terminated
	 *            and all resources has to be released.
	 */
	public void destroyApp(boolean unconditional) {
	}

	private void notifyUser(Object message) {
		try {
			if (message instanceof JSONObject) {
				JSONObject obj = (JSONObject) message;
				Alert a = new Alert("Received", obj.toString(), null, null);
				a.setTimeout(Alert.FOREVER);
				getDisplay().setCurrent(a, form);

				Enumeration keys = obj.keys();
				while (keys.hasMoreElements()) {
				}

			} else if (message instanceof String) {
				String obj = (String) message;
				Alert a = new Alert("Received", obj.toString(), null, null);
				a.setTimeout(Alert.FOREVER);
				getDisplay().setCurrent(a, form);
			} else if (message instanceof JSONArray) {
				JSONArray obj = (JSONArray) message;
				Alert a = new Alert("Received", obj.toString(), null, null);
				a.setTimeout(Alert.FOREVER);
				getDisplay().setCurrent(a, form);
			}
		} catch (Exception e) {

		}

	}


	public void disconnectAndResubscribe() {
		_pubnub.disconnectAndResubscribe();
	}

	public void toggleResumeOnReconnect() {
		_pubnub.setResumeOnReconnect(_pubnub.isResumeOnReconnect()?false:true);
	}

	public void publish() {
		try {
			JSONObject message = new JSONObject();
			message.put("some_key", "j2me says hello, world!");

			Hashtable args = new Hashtable(2);
			args.put("channel", channel); // Channel Name
			args.put("message", message); // JSON Message
			_pubnub.publish(args, new Callback() {
				public void successCallback(String channel, Object message) {
					notifyUser(message.toString());
				}

				public void errorCallback(String channel, Object message) {
					notifyUser(channel + " : " + message.toString());
				}
			});

		} catch (JSONException ex) {

		}
	}

	public void subscribe() {
		Hashtable args = new Hashtable(6);
		args.put("channel", channel + ++count);

		try {
			_pubnub.subscribe(args, new Callback() {
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
					notifyUser(recvCount++ + " " + channel + " " + message.toString());
				}
				public void errorCallback(String channel, Object message) {
					notifyUser(channel + " " + message.toString());
				}
			});

		} catch (Exception e) {

		}
	}

	public void unsubscribe() {
		Hashtable args = new Hashtable(1);
		args.put("channels", channels);
		_pubnub.unsubscribe(args);

	}

	public void time() {
		_pubnub.time(new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.toString());
			}
		});
	}

	public void history() {

		_pubnub.history(channel, 2, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.toString());
			}
		});
	}

	private void hereNow() {
		_pubnub.hereNow(channel, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.toString());
			}
		});
	}

	private void presence() {
		try {
			_pubnub.presence(channel, new Callback() {
				public void successCallback(String channel, Object message) {
					notifyUser(message.toString());
				}

				public void errorCallback(String channel, Object message) {
					notifyUser(channel + " : " + message.toString());
				}
			});
		} catch (PubnubException e) {

		}
	}

	private void detailedHistory() {

		_pubnub.detailedHistory(channel, 2, new Callback() {
			public void successCallback(String channel, Object message) {
				notifyUser(message.toString());
			}

			public void errorCallback(String channel, Object message) {
				notifyUser(channel + " : " + message.toString());
			}
		});
	}

}
