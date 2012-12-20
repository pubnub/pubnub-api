package com.pubnub.api;

import java.util.Enumeration;
import java.util.Hashtable;

/**
 * @author Pubnub
 *
 */
class Subscriptions {
	private Hashtable channels;
	public Subscriptions(){
		channels = new Hashtable();
	}
	public void addChannel(Channel channel){
		channels.put(channel.name, channel);
	}
	public void removeChannel(String name){
		channels.remove(name);
	}
	public Channel getFirstChannel() {
		return (Channel) channels
				.elements().nextElement();
		
	}
	public Channel getChannel(String name){
		return (Channel) channels.get(name);
	}
	public String[] getChannelNames(){

		return PubnubUtil.hashtableKeysToArray(channels);
	}
	public String getChannelString() {
		return PubnubUtil.hashTableKeysToDelimitedString(channels, ",");
		
	}
	public void invokeConnectCallbackOnChannels() {
		/*
		 * Iterate over all the channels and call connect
		 * callback for channels which were in disconnected
		 * state. Nothing to do for channels already connected
		 */
		synchronized(channels){
			Enumeration ch = channels.elements();
			while (ch.hasMoreElements()) {
				Channel _channel = (Channel) ch.nextElement();
				if (_channel.connected == false) {
					_channel.connected = true;
					_channel.callback
					.connectCallback(_channel.name);
				}
			}
		}
	}
	public void invokeDisconnectCallbackOnChannels() {
		/*
		 * Iterate over all the channels and call connect
		 * callback for channels which were in disconnected
		 * state. Nothing to do for channels already connected
		 */
		synchronized(channels){
			Enumeration ch = channels.elements();
			while (ch.hasMoreElements()) {
				Channel _channel = (Channel) ch.nextElement();
				if (_channel.connected == false) {
					_channel.connected = true;
					_channel.callback
					.disconnectCallback(_channel.name);
				}
			}
		}
	}
	public void invokeConnectCallbackOnChannels(String[] channels) {
	}
	public void invokeErrorCallbackOnChannels(String[] channels) {
	}
}
