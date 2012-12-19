package main

import (
	"log"
	"pubnub"
)

func main() {
	pub := pubnub.PubnubInit("demo", "demo", "", "enigma", false)
	channel := make(chan []byte)

	//start new goroutine  
	go pub.History("hello_world", 10, channel)

	//receive from channel
	for {
		value, ok := <-channel
		if !ok {
			break
		}
		log.Printf("%s", value)
	}
}
