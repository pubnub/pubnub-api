package main

import (
	"log"
	"pubnub"
)

func main() {
	pub := pubnub.PubnubInit("demo", "demo", "", "", false)
	channel := make(chan []byte)

	//start new goroutine  
	go pub.Publish("my-channel", "hi", channel)

	//receive from channel
	for {
		value, ok := <-channel
		if !ok {
			break
		}
		log.Printf("%s", value)
	}
}
