package test;

import pubnub.Pubnub;
import pubnub.Callback;
import java.util.Enumeration;
import java.util.Hashtable;
import javax.microedition.midlet.*;
import javax.microedition.lcdui.*;
import org.json.me.JSONArray;
import org.json.me.JSONException;
import org.json.me.JSONObject;

public class PubnubTestMIDlet extends MIDlet implements CommandListener,Callback {

    private boolean midletPaused = false;
    private Command exitCommand;
    private Command publishCommand;
    private Command timeCommand;
    private Command historyCommand;
    private Command unsubscribeCommand;
    private Command subscribeCommand;
    private Form form;
    private StringItem stringItem;
    String Channel = "hello_world";

    public PubnubTestMIDlet() {
    }

    private void initialize() {
        _pubnub.setCallback(this);
    }

    Pubnub _pubnub = new Pubnub("demo", "demo", "demo", "", false);

    /**
     * Performs an action assigned to the Mobile Device - MIDlet Started point.
     */
    public void startMIDlet() {
        switchDisplayable(null, getForm());
        subscribe();
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
            }
            else if (command == subscribeCommand) {
               subscribe();
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
            stringItem = new StringItem("Pubnub", "Hello Pubnub!", Item.PLAIN);
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
            timeCommand = new Command("Time", Command.ITEM, 2);// GEN-LINE:|27-getter|1|27-postInit
            // GEN-LINE:|7-commandAction|13|7-postCommandAction
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

    public void publish() {
        try {
            // Create JSON Message
            JSONObject message = new JSONObject();
            // Create HashMap parameter
            message.put("some_key", "Hello World!");
           
            Hashtable args = new Hashtable(2);
            args.put("channel", Channel); // Channel Name
            args.put("message", message); // JSON Message
            _pubnub.publish(args);

        } catch (JSONException ex) {
            ex.printStackTrace();
        }
    }

    public void subscribe() {
        Hashtable args = new Hashtable(6);
        args.put("channel", Channel);
        _pubnub.subscribe(args);
    }

    public void unsubscribe() {
        Hashtable args = new Hashtable(1);
        String channel = Channel;
        args.put("channel", channel);
        _pubnub.unsubscribe(args);
        System.out.println("UnSubscribed sucessfully");
    }

    public void time() {
        System.out.println("Time::" + _pubnub.time());
        double response = _pubnub.time();
        stringItem.setLabel("Time::");
        stringItem.setText(response + "");
    }

    public void history() {
        Hashtable args = new Hashtable(2);
        args.put("channel", Channel);
        args.put("limit", new Integer(2));
        _pubnub.history(args);
    }

    public void publishCallback(String channel, Object message) {

        JSONArray meg = (JSONArray) message;
        System.out.println("Message sent responce:" + message.toString()
                + " on channel:" + channel);
        try {
            int sucess = Integer.parseInt(meg.get(0).toString());
            if (sucess == 1) {
                stringItem.setLabel("Publish");
                stringItem.setText("Message sent successfully on channel:"
                        + channel + "\n" + message.toString());
            } else {
                stringItem.setLabel("Publish");
                stringItem.setText("Message sent failure on channel:" + channel
                        + "\n" + message.toString());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void subscribeCallback(String channel, Object message) {
        System.out.println("Message recevie on channel:" + channel
                + " Message:" + message.toString());
        try {
            if (message instanceof JSONObject) {
                JSONObject obj = (JSONObject) message;
                Alert a = new Alert("Received", obj.toString(), null, null);
                a.setTimeout(Alert.FOREVER);
                getDisplay().setCurrent(a, form);

                Enumeration keys = obj.keys();
                while (keys.hasMoreElements()) {
                    System.out.println(obj.get(keys.nextElement().toString())
                            + " ");
                }

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

    }

    public void historyCallback(String channel, Object message) {
        JSONArray meg = (JSONArray) message;
        System.out.println("History recevie on channel:" + channel+ " Message:" + meg.toString());

        stringItem.setLabel("History");
        stringItem.setText("History recevie on channel:" + channel + "\n" + meg.toString());
    }

    public void errorCallback(String channel, Object message) {
        System.out.println("Error on channel:" + channel + " Message:"+ message.toString());

    }

    public void connectCallback(String channel) {
        System.out.println("Connect channel:" + channel);
    }

    public void reconnectCallback(String channel) {
        System.out.println("Reconnect channel:" + channel);
    }

    public void disconnectCallback(String channel) {
        System.out.println("Disconnect channel:" + channel);
    }
}
