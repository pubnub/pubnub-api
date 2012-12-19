package main

import (
	"log"
	"pubnub"
)

func main() {
	pub := pubnub.PubnubInit("demo", "demo", "", "enigma", false)
	channel := make(chan []byte)

	//start new goroutine  
	go pub.Publish("hello_world", "test", channel)

	//receive from channel
	for {
		value, ok := <-channel
		if !ok {
			break
		}
		log.Printf("%s", value)
	}
}
