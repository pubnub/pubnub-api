package com.pubnub.examples.blackberry;

import java.util.Hashtable;

import net.rim.device.api.command.Command;
import net.rim.device.api.command.CommandHandler;
import net.rim.device.api.command.ReadOnlyCommandMetadata;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.container.MainScreen;
import net.rim.device.api.util.StringProvider;

import com.pubnub.api.Callback;
import com.pubnub.api.Pubnub;
import com.pubnub.api.PubnubException;

/**
 * A class extending the MainScreen class, which provides default standard
 * behavior for BlackBerry GUI applications.
 */
public final class PubnubExampleScreen extends MainScreen
{
	String channel = "hello_world";
	String[] channels = { "hello_world1", "hello_world2", "hello_world3",
			"hello_world4" };
	Pubnub _pubnub = new Pubnub("demo","demo","demo", false);
    /**
     * Creates a new PubnubExampleScreen object
     */
    public PubnubExampleScreen()
    {
        // Set the displayed title of the screen
        setTitle("PubnubExample");
        add(new LabelField("Please select an item from the menu"));
        add(new LabelField("Subscribe will listen on following channels: "));
        add(new LabelField("hello_world1, hello_world2, hello_world3, hello_world4"));
        add(new LabelField("Publish, history, detailedHistory, hereNow, Presence use hello_world"));


        addMenuItem(new TimeMenuItem());
        addMenuItem(new PublishMenuItem());
        addMenuItem(new HereNowMenuItem());
        addMenuItem(new HistoryMenuItem());
        addMenuItem(new DetailedHistoryMenuItem());
        addMenuItem(new SubscribeMenuItem());
        addMenuItem(new UnsubscribeMenuItem());
        addMenuItem(new PresenceMenuItem());
        addMenuItem(new ToggleRoRMenuItem());
        addMenuItem(new DisconnectAndResubMenuItem());
    }


    private class TimeMenuItem extends MenuItem
    {
        public TimeMenuItem()
        {
            super(new StringProvider("Time"), 0x230010, 0);
            this.setCommand(new Command(new CommandHandler()
            {
                public void execute(ReadOnlyCommandMetadata metadata, Object context)
                {   _pubnub.time(new Callback() {
        			public void successCallback(String channel, Object message) {
        				PubnubExample.alertDialog(message.toString());
        			}

        			public void errorCallback(String channel, Object message) {
        				PubnubExample.alertDialog(message.toString());
        			}
        		});
                }
            }));
        }
    }
    private class DisconnectAndResubMenuItem extends MenuItem
    {
        public DisconnectAndResubMenuItem()
        {
            super(new StringProvider("Disconnect and Resubscribe"), 0x230010, 0);
            this.setCommand(new Command(new CommandHandler()
            {
                public void execute(ReadOnlyCommandMetadata metadata, Object context)
                {   _pubnub.disconnectAndResubscribe();
                }
            }));
        }
    }
    private class ToggleRoRMenuItem extends MenuItem
    {
        public ToggleRoRMenuItem()
        {
            super(new StringProvider("Toggle Resume on Reconnect"), 0x230010, 0);
            this.setCommand(new Command(new CommandHandler()
            {
                public void execute(ReadOnlyCommandMetadata metadata, Object context)
                {   _pubnub.setResumeOnReconnect(_pubnub.isResumeOnReconnect()?false:true);
                }
            }));
        }
    }
    private class PublishMenuItem extends MenuItem
    {
        public PublishMenuItem()
        {
            super(new StringProvider("Publish"), 0x230010, 0);
            this.setCommand(new Command(new CommandHandler()
            {
                public void execute(ReadOnlyCommandMetadata metadata, Object context) {

        			_pubnub.publish(channel, "Blackberry says hello world", new Callback() {
        				public void successCallback(String channel, Object message) {
        					PubnubExample.alertDialog("Channel : " + channel + ", " + message.toString());
        				}

        				public void errorCallback(String channel, Object message) {
        					PubnubExample.alertDialog("Channel : " + channel + ", " + message.toString());
        				}
        			});

            }}));
        }
    }
    private class HereNowMenuItem extends MenuItem
    {
        public HereNowMenuItem()
        {
            super(new StringProvider("HereNow"), 0x230010, 0);
            this.setCommand(new Command(new CommandHandler()
            {
                public void execute(ReadOnlyCommandMetadata metadata, Object context)
                {
        			_pubnub.hereNow(channel, new Callback() {
        				public void successCallback(String channel, Object message) {
        					PubnubExample.alertDialog("Channel : " + channel + ", " + message.toString());
        				}

        				public void errorCallback(String channel, Object message) {
        					PubnubExample.alertDialog("Channel : " + channel + ", " + message.toString());
        				}
        			});
                }
            }));
        }
    }
    private class HistoryMenuItem extends MenuItem
    {
        public HistoryMenuItem()
        {
            super(new StringProvider("History"), 0x230010, 0);
            this.setCommand(new Command(new CommandHandler()
            {
                public void execute(ReadOnlyCommandMetadata metadata, Object context)
                {
        			_pubnub.history(channel, 1, new Callback() {
        				public void successCallback(String channel, Object message) {
        					PubnubExample.alertDialog("Channel : " + channel + ", " + message.toString());
        				}

        				public void errorCallback(String channel, Object message) {
        					PubnubExample.alertDialog("Channel : " + channel + ", " + message.toString());
        				}
        			});
                }
            }));
        }
    }
    private class DetailedHistoryMenuItem extends MenuItem
    {
        public DetailedHistoryMenuItem()
        {
            super(new StringProvider("DetailedHistory"), 0x230010, 0);
            this.setCommand(new Command(new CommandHandler()
            {
                public void execute(ReadOnlyCommandMetadata metadata, Object context)
                {
        			_pubnub.detailedHistory(channel, 1, new Callback() {
        				public void successCallback(String channel, Object message) {
        					PubnubExample.alertDialog("Channel : " + channel + ", " + message.toString());
        				}

        				public void errorCallback(String channel, Object message) {
        					PubnubExample.alertDialog("Channel : " + channel + ", " + message.toString());
        				}
        			});
                }
            }));
        }
    }
    private class SubscribeMenuItem extends MenuItem
    {
        public SubscribeMenuItem()
        {
            super(new StringProvider("Subscribe"), 0x230010, 0);
            this.setCommand(new Command(new CommandHandler()
            {
                public void execute(ReadOnlyCommandMetadata metadata, Object context)
                {		Hashtable args = new Hashtable(6);
        		args.put("channels", channels);

        		try {
        			_pubnub.subscribe(args, new Callback() {
        				public void connectCallback(String channel) {
        					PubnubExample.alertDialog("CONNECT on channel:" + channel);
        				}

        				public void disconnectCallback(String channel) {
        					PubnubExample.alertDialog("DISCONNECT on channel:" + channel);
        				}

        				public void reconnectCallback(String channel) {
        					PubnubExample.alertDialog("RECONNECT on channel:" + channel);
        				}

        				public void successCallback(String channel, Object message) {
        					PubnubExample.alertDialog("Channel : " + channel + ", " + message.toString());
        				}
        			});

        		} catch (Exception e) {

        		}
                }
            }));
        }
    }
    private class PresenceMenuItem extends MenuItem
    {
        public PresenceMenuItem()
        {
            super(new StringProvider("Presence"), 0x230010, 0);
            this.setCommand(new Command(new CommandHandler()
            {
                public void execute(ReadOnlyCommandMetadata metadata, Object context)
                {
                	try {
            			_pubnub.presence(channel, new Callback() {
            				public void successCallback(String channel, Object message) {
            					PubnubExample.alertDialog("Channel : " + channel + ", " + message.toString());
            				}

            				public void errorCallback(String channel, Object message) {
            					PubnubExample.alertDialog("Channel : " + channel + ", " + message.toString());
            				}
            			});
            		} catch (PubnubException e) {

            		}
                }
            }));
        }
    }
    private class UnsubscribeMenuItem extends MenuItem
    {
        public UnsubscribeMenuItem()
        {
            super(new StringProvider("Unsubscribe"), 0x230010, 0);
            this.setCommand(new Command(new CommandHandler()
            {
                public void execute(ReadOnlyCommandMetadata metadata, Object context)
                {
            			_pubnub.unsubscribe(channels);
                }
            }));
        }
    }
}