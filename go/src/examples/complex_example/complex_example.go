package main

import (
	"log"
	"pubnub"
)

var channel = "hello_world"
var publish_key = "demo"
var subscribe_key = "demo"
var secret_key = "demo"
var chipher_key = "enigma"

var presenceCallback = make(chan []byte)
var subscribeCallback = make(chan []byte)
var publishCallback = make(chan []byte)
var timeCallback = make(chan []byte)
var hereNowCallback = make(chan []byte)
var historyCallback = make(chan []byte)

func Callback(channel chan []byte, callback_type string) {
	for {
		value, ok := <-channel
		if !ok {
			break
		}
		log.Printf("%s callback: %s", callback_type, value)
	}
}

func main() {
	// ------------------
	// Init Pubnub Object
	// ------------------
	pub := pubnub.PubnubInit(publish_key, subscribe_key, secret_key, chipher_key, false)

	// -----------------------------------
	// PubNub presence
	// -----------------------------------
	log.Printf("Presence to: %s channel", channel)
	go pub.Presence(channel, presenceCallback)
	go Callback(presenceCallback, "Presence")

	// -----------------------------------
	// PubNub Subscribe (Receive Messages)
	// -----------------------------------
	log.Printf("Listening to: %s channel", channel)
	go pub.Subscribe(channel, subscribeCallback)
	go Callback(subscribeCallback, "Subscribe")

	// ----------------------------------
	// PubNub Server Time (Get TimeToken)
	// ----------------------------------
	go pub.GetTime(timeCallback)
	Callback(timeCallback, "Time")

	// -------------------------------------
	// PubNub Publish Message (Send Message)
	// -------------------------------------
	go pub.Publish(channel, "Test message", publishCallback)
	Callback(publishCallback, "Publish")

	// ---------------------------------------
	// PubNub History (Recent Message History)
	// ---------------------------------------
	go pub.History(channel, 3, historyCallback)
	Callback(historyCallback, "History")

	// -----------------------------------
	// Here Now
	// -----------------------------------
	go pub.HereNow(channel, hereNowCallback)
	Callback(hereNowCallback, "HereNow")

	pub.Unsubscribe(channel, subscribeCallback)
	pub.Unsubscribe(channel, presenceCallback)
}
