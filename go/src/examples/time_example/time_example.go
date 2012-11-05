package main

import (
	"log"
	"pubnub"
)

func main() {
	pub := pubnub.PubnubInit("", "", "", "", false)
	log.Printf("%s", pub.GetTime())
}
