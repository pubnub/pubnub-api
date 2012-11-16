package pubnub

import (
	"io"
	"io/ioutil"
	"net"
	"net/http"
	"testing"
)

func TestPubnubInit(t *testing.T) {
	//test body
}

func timePubnubHandler(w http.ResponseWriter, req *http.Request) {
	ioutil.ReadAll(req.Body)
	w.Header().Set("Content-Length", "2")
	io.WriteString(w, "OK")
}

func setupPubnubMockServer(t *testing.T) {
	http.HandleFunc("/time/0", timePubnubHandler)
	ln, err := net.Listen("tcp", ":0")
	if err != nil {
		t.Fatalf("failed to listen - %s", err.Error())
	}
	go func() {
		err = http.Serve(ln, nil)
		if err != nil {
			t.Fatalf("failed to start HTTP server - %s", err.Error())
		}
	}()
	addr = ln.Addr()
}

func TestGetTime(t *testing.T) {
	//starter.Do(func() { setupMockServer(t) })

	testPUBNUB := PubnubInit("demo", "demo", "", "", false)
	//testPUBNUB.ORIGIN = "http://" + addr.String()

	testchannel := make(chan []byte)
	go testPUBNUB.GetTime(testchannel)

	response := <-testchannel
	if len(response) == 0 {
		t.Fatalf("Failed to get server time: %s", response)
	}
}

func TestPublish(t *testing.T) {
	testPUBNUB := PubnubInit("demo", "demo", "", "", false)
	publish_channel_1 := make(chan []byte)
	publish_channel_2 := make(chan []byte)
	var response []byte

	go testPUBNUB.Publish("test-channel", "test", publish_channel_1)
	for {
		value, ok := <-publish_channel_1
		if !ok {
			break
		}
		response = append(response, value...)
	}
	if response[0] != '0' && response[0] != '1' {
		t.Fatalf("Failed to publish message without chipher key and ssl: %s", response)
	}
	if response[0] == '0' {
		t.Fatalf("Failed to publish message without chipher key and ssl: %s", response[1])
	}

	testPUBNUB.SSL = true
	response = []byte{}
	go testPUBNUB.Publish("test-channel", "test", publish_channel_2)
	for {
		value, ok := <-publish_channel_2
		if !ok {
			break
		}
		response = append(response, value...)
	}
	if response[0] != '0' && response[0] != '1' {
		t.Fatalf("Failed to publish message with ssl and without chipher key: %s", response)
	}
	if response[0] == '0' {
		t.Fatalf("Failed to publish message with ssl and without chipher key: %s", response[1])
	}
}
