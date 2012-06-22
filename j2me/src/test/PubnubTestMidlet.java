package test;

import Pubnub.Callback;
import Pubnub.Pubnub;
import java.util.Enumeration;
import java.util.Hashtable;
import javax.microedition.midlet.*;
import javax.microedition.lcdui.*;
import json.me.JSONArray;
import json.me.JSONException;
import json.me.JSONObject;

public class PubnubTestMidlet extends MIDlet implements CommandListener {

	private boolean midletPaused = false;

	private Command exitCommand;
	private Command publishCommand;
	private Command subcribeCommand;
	private Command timeCommand;
	private Command historyCommand;
	private Command unsubcribeCommand;
	private Form form;
	private StringItem stringItem;

	public PubnubTestMidlet() {
	}

	private void initialize() {

	}

	/**
	 * Performs an action assigned to the Mobile Device - MIDlet Started point.
	 */
	public void startMIDlet() {

		switchDisplayable(null, getForm());

	}

	/**
	 * Performs an action assigned to the Mobile Device - MIDlet Resumed point.
	 */
	public void resumeMIDlet() {
	}

	/**
	 * Switches a current displayable in a display. The <code>display</code>
	 * instance is taken from <code>getDisplay</code> method. This method is
	 * used by all actions in the design for switching displayable.
	 * 
	 * @param alert
	 *            the Alert which is temporarily set to the display; if
	 *            <code>null</code>, then <code>nextDisplayable</code> is set
	 *            immediately
	 * @param nextDisplayable
	 *            the Displayable to be set
	 */
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
	public void commandAction(Command command, Displayable displayable) {// GEN-END:|7-commandAction|0|7-preCommandAction

		if (displayable == form) {
			if (command == exitCommand) {

				exitMIDlet();

			} else if (command == historyCommand) {
				History();

			} else if (command == publishCommand) {
				Publish();

			} else if (command == subcribeCommand) {
				Subcribe();

			} else if (command == timeCommand) {
				Time();

			} else if (command == unsubcribeCommand) {
				UnSubcribe();

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

			form = new Form("Welcome", new Item[] { getStringItem() });// GEN-BEGIN:|14-getter|1|14-postInit
			form.addCommand(getExitCommand());
			form.addCommand(getPublishCommand());
			form.addCommand(getSubcribeCommand());
			form.addCommand(getTimeCommand());
			form.addCommand(getHistoryCommand());
			form.addCommand(getUnsubcribeCommand());
			form.setCommandListener(this);

		}
		return form;
	}

	/**
	 * Returns an initiliazed instance of stringItem component.
	 * 
	 * @return the initialized component instance
	 */
	public StringItem getStringItem() {
		if (stringItem == null) {

			stringItem = new StringItem("Hello", "Hello, World!", Item.PLAIN);

		}
		return stringItem;
	}

	/**
	 * Returns an initiliazed instance of publishCommand component.
	 * 
	 * @return the initialized component instance
	 */
	public Command getPublishCommand() {
		if (publishCommand == null) {

			publishCommand = new Command("Publish", "<null>", Command.SCREEN, 1);

		}
		return publishCommand;
	}

	/**
	 * Returns an initiliazed instance of subcribeCommand component.
	 * 
	 * @return the initialized component instance
	 */
	public Command getSubcribeCommand() {
		if (subcribeCommand == null) {

			subcribeCommand = new Command("Subcribe", Command.ITEM, 0);

		}
		return subcribeCommand;
	}

	/**
	 * Returns an initiliazed instance of timeCommand component.
	 * 
	 * @return the initialized component instance
	 */
	public Command getTimeCommand() {
		if (timeCommand == null) {

			timeCommand = new Command("Time", Command.ITEM, 0);// GEN-LINE:|27-getter|1|27-postInit

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

			historyCommand = new Command("History", Command.ITEM, 0);

		}
		return historyCommand;
	}

	/**
	 * Returns an initiliazed instance of unsubcribeCommand component.
	 * 
	 * @return the initialized component instance
	 */
	public Command getUnsubcribeCommand() {
		if (unsubcribeCommand == null) {

			unsubcribeCommand = new Command("Unsubcribe", Command.ITEM, 0);

		}
		return unsubcribeCommand;
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
			initialize();
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

	Pubnub _pubnub = new Pubnub("demo", "demo", "demo", "demo", false);

	public void Publish() {
		try {
			// Create JSON Message
			JSONObject message = new JSONObject();
			// Create HashMap parameter
			message.put("some_key", "Hello World!");

			Hashtable args = new Hashtable(2);
			args.put("channel", "hello_world"); // Channel Name
			args.put("message", message); // JSON Message
			JSONArray responece = _pubnub.publish(args);
			// Print Response from PubNub JSONP REST Service
			System.out.println(responece.toString());
			stringItem.setLabel("Publish::");
			stringItem.setText(responece + "");
		} catch (JSONException ex) {
			ex.printStackTrace();
		}
	}

	Hashtable subcribeThreads = new Hashtable();

	public void Subcribe() {

		String channel = "hello_world";
		Thread t = new Thread() {

			public void run() {
				Hashtable args = new Hashtable(6);
				args.put("channel", "hello_world");
				args.put("callback", new Receiver());                  // callback to get response
				args.put("connect_cb", new ConnectCallback());         // callback to get connect event
				args.put("disconnect_cb", new DisconnectCallback());   // callback to get disconnect event
				args.put("reconnect_cb", new ReconnectCallback());     // callback to get reconnect event
				args.put("error_cb", new ErrorCallback());             // callback to get error event
				// Listen for Messages (Subscribe)
				_pubnub.subscribe(args);
			}
		};

		t.start();
		if (!subcribeThreads.containsKey(channel)) {
			subcribeThreads.put(channel, t);
		}

	}

	public void UnSubcribe() {
		Hashtable args = new Hashtable(1);
		String channel = "hello_world";
		args.put("channel", channel);
		_pubnub.unsubscribe(args);

		if (!subcribeThreads.containsKey(channel)) {
			Thread t = (Thread) subcribeThreads.get(channel);
			t.interrupt();
			subcribeThreads.remove(channel);
		}
		System.out.println("UnSubcribe sucessfully");
	}

	// Callback Interface when a Message is Received
	class Receiver implements Callback {

		public boolean execute(Object message) {

			try {
				if (message instanceof JSONObject) {
					JSONObject obj = (JSONObject) message;
					Alert a = new Alert("Received", obj.toString(), null, null);
					a.setTimeout(Alert.FOREVER);
					getDisplay().setCurrent(a, form);

					Enumeration keys = obj.keys();
					while (keys.hasMoreElements()) {
						System.out.print(obj.get(keys.nextElement().toString())
								+ " ");
					}
					System.out.println();
				} else if (message instanceof String) {
					String obj = (String) message;
					System.out.print(obj + " ");
					System.out.println();

					Alert a = new Alert("Received", obj.toString(), null, null);
					a.setTimeout(Alert.FOREVER);
					getDisplay().setCurrent(a, form);
				} else if (message instanceof JSONArray) {
					JSONArray obj = (JSONArray) message;
					System.out.print(obj.toString() + " ");
					System.out.println();

					Alert a = new Alert("Received", obj.toString(), null, null);
					a.setTimeout(Alert.FOREVER);
					getDisplay().setCurrent(a, form);

				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			// Continue Listening?
			return true;
		}
	}

	// Callback Interface when a channel is connected
	class ConnectCallback implements Callback {

		public boolean execute(Object message) {
			System.out.println(message.toString());
			return false;
		}
	}

	// Callback Interface when a channel is disconnected
	class DisconnectCallback implements Callback {

		public boolean execute(Object message) {
			System.out.println(message.toString());
			return false;
		}
	}

	// Callback Interface when a channel is reconnected
	class ReconnectCallback implements Callback {

		public boolean execute(Object message) {
			System.out.println(message.toString());
			return false;
		}
	}

	// Callback Interface when error occurs
	class ErrorCallback implements Callback {

		public boolean execute(Object message) {
			System.out.println(message.toString());
			return false;
		}
	}

	public void Time() {
		System.out.println("Time::" + _pubnub.time());
		double responece = _pubnub.time();
		stringItem.setLabel("Time::");
		stringItem.setText(responece + "");
	}

	public void History() {
		Hashtable args = new Hashtable(2);
		args.put("channel", "hello_world");
		args.put("limit", new Integer(2));
		JSONArray responece = _pubnub.history(args);
		System.out.println("History" + responece);
		stringItem.setLabel("History");
		stringItem.setText("" + responece.toString());
	}
}
