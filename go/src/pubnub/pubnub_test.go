package pubnub

import (
	"fmt"
	"io"
	"net/http"
	"testing"
)

//Moc server hendlers
func timePubnubHandler(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, "[13533127815769808]")
}

func publishPubnubSuccessHandler(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, "[1, \"Sent\", \"13533127815769808\"]")
}

func publishPubnubFailHandler(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, "[0,\"Invalid Key\",\"13533127815769808\"]")
}

func historyPubnubHandler(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, "[\"hi\",\"hello\",\"test\"]")
}

func noHistoryPubnubHandler(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, "[]")
}

func historyChipherPubnubHandler(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, "[\"yykEzOQyZkot3YShvlzQfw==\",\"BQ2Ywm6XtvTCGCFPTY6FJw==\",\"mQQQxYFQokcxi8yWwxT56Q==\"]")
}

func hereNowPubnubHandler(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, "{\"uuids\":[\"E33194F6-D6F1-4762-87D9-9D1DB5BC650B\",\"aa1686b0-cee8-012f-ba60-70def1fd2b7f\"],\"occupancy\":2}")
}

func noHereNowPubnubHandler(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, "{\"uuids\":[], \"occupancy\":0}")
}

func subscribePubnubHandler(w http.ResponseWriter, req *http.Request) {
	if timeToken == "0" {
		io.WriteString(w, "[[], \"13533127815769808\"]")
	} else {
		io.WriteString(w, "[[\"hi\"], \"13533127815769808\"]")
	}
}

func subscribeChipherPubnubHandler(w http.ResponseWriter, req *http.Request) {
	if timeToken == "0" {
		io.WriteString(w, "[[], \"13533127815769808\"]")
	} else {
		io.WriteString(w, "[[\"yykEzOQyZkot3YShvlzQfw==\"], \"13533127815769808\"]")
	}
}

func presencePubnubHandler(w http.ResponseWriter, req *http.Request) {
	if timeToken == "0" {
		io.WriteString(w, "[[], \"13533127815769808\"]")
	} else {
		io.WriteString(w, "[[{\"action\": \"join\", \"timestamp\": 1345720165, \"uuid\": \"1975\", \"occupancy\":3}],\"13533127815769808\"]")
	}
}

func TestPubnubInit(t *testing.T) {
	testPUBNUB := PubnubInit("demo_pub_key", "demo_sub_key", "demo_sec_key", "demo_cipher_key", false)

	if testPUBNUB.ORIGIN != "http://"+_ORIGIN {
		t.Fatalf("Failed initialization origin url")
	}
	if testPUBNUB.PUBLISH_KEY != "demo_pub_key" {
		t.Fatalf("Failed initialization publish key")
	}
	if testPUBNUB.SUBSCRIBE_KEY != "demo_sub_key" {
		t.Fatalf("Failed initialization subscribe key")
	}
	if testPUBNUB.SECRET_KEY != "demo_sec_key" {
		t.Fatalf("Failed initialization secret key")
	}
	if testPUBNUB.CIPHER_KEY != "demo_cipher_key" {
		t.Fatalf("Failed initialization cipher key")
	}
}

func TestGetTime(t *testing.T) {
	starter.Do(func() { setupMockServer(t) })

	testPUBNUB := PubnubInit("demo", "demo", "", "", false)
	testPUBNUB.ORIGIN = "http://" + addr.String()

	testchannel := make(chan []byte)
	go testPUBNUB.GetTime(testchannel)

	response := <-testchannel
	if fmt.Sprintf("%s", response) != "13533127815769808" {
		t.Fatalf("Failed to get server time: %s", response)
	}
}

func TestSuccessPublish(t *testing.T) {
	starter.Do(func() { setupMockServer(t) })

	testPUBNUB := PubnubInit("demo", "demo", "", "", false)
	testPUBNUB.ORIGIN = "http://" + addr.String()

	publish_channel_1 := make(chan []byte)
	publish_channel_2 := make(chan []byte)
	publish_channel_3 := make(chan []byte)
	publish_channel_4 := make(chan []byte)
	var response []byte

	go testPUBNUB.Publish("test-channel", "test", publish_channel_1)
	for {
		value, ok := <-publish_channel_1
		if !ok {
			break
		}
		response = append(response, value...)
	}
	if fmt.Sprintf("%s", response) != "1Sent13533127815769808" {
		t.Fatalf("Failed to publish message without chipher key: %s", response)
	}

	testPUBNUB.CIPHER_KEY = "enigma"
	response = []byte{}
	go testPUBNUB.Publish("test-channel", "test", publish_channel_2)
	for {
		value, ok := <-publish_channel_2
		if !ok {
			break
		}
		response = append(response, value...)
	}
	if fmt.Sprintf("%s", response) != "1Sent13533127815769808" {
		t.Fatalf("Failed to publish message with chipher key: %s", response)
	}

	testPUBNUB.CIPHER_KEY = ""
	testPUBNUB.SECRET_KEY = "itsmysecret"
	response = []byte{}
	go testPUBNUB.Publish("test-channel", "test", publish_channel_3)
	for {
		value, ok := <-publish_channel_3
		if !ok {
			break
		}
		response = append(response, value...)
	}
	if fmt.Sprintf("%s", response) != "1Sent13533127815769808" {
		t.Fatalf("Failed to publish message with secret key: %s", response)
	}

	testPUBNUB.CIPHER_KEY = "enigma"
	testPUBNUB.SECRET_KEY = "itsmysecret"
	response = []byte{}
	go testPUBNUB.Publish("test-channel", "test", publish_channel_4)
	for {
		value, ok := <-publish_channel_4
		if !ok {
			break
		}
		response = append(response, value...)
	}
	if fmt.Sprintf("%s", response) != "1Sent13533127815769808" {
		t.Fatalf("Failed to publish message with cipher and secret keys: %s", response)
	}
}

func TestFailPublish(t *testing.T) {
	starter.Do(func() { setupMockServer(t) })

	testPUBNUB := PubnubInit("demo", "demo-fail", "", "", false)
	testPUBNUB.ORIGIN = "http://" + addr.String()

	publish_channel := make(chan []byte)
	var response []byte

	go testPUBNUB.Publish("test-channel", "test", publish_channel)
	for {
		value, ok := <-publish_channel
		if !ok {
			break
		}
		response = append(response, value...)
	}
	if fmt.Sprintf("%s", response) != "0Invalid Key13533127815769808" {
		t.Fatalf("Invalid error response: %s", response)
	}
}

func TestHistory(t *testing.T) {
	starter.Do(func() { setupMockServer(t) })

	testPUBNUB := PubnubInit("demo", "demo", "", "", false)
	testPUBNUB.ORIGIN = "http://" + addr.String()

	history_channel_1 := make(chan []byte)
	no_history_channel := make(chan []byte)
	history_chipher_channel := make(chan []byte)

	var response []byte

	go testPUBNUB.History("test-channel", 3, history_channel_1)
	for {
		value, ok := <-history_channel_1
		if !ok {
			break
		}
		response = append(response, value...)
	}
	if fmt.Sprintf("%s", response) != "hihellotest" {
		t.Fatalf("Failed to get history without chipher key: %s", response)
	}

	response = []byte{}
	go testPUBNUB.History("no-history-channel", 3, no_history_channel)
	for {
		value, ok := <-no_history_channel
		if !ok {
			break
		}
		response = append(response, value...)
	}
	if fmt.Sprintf("%s", response) != "" {
		t.Fatalf("Failed to get history without chipher key: %s", response)
	}

	testPUBNUB.CIPHER_KEY = "enigma"
	response = []byte{}
	go testPUBNUB.History("chipher-history-channel", 3, history_chipher_channel)
	for {
		value, ok := <-history_chipher_channel
		if !ok {
			break
		}
		response = append(response, value...)
	}
	if fmt.Sprintf("%s", response) != "\"hi\"\"hello\"\"test\"" {
		t.Fatalf("Failed to get history with chipher key: %s", response)
	}
}

func TestHereNow(t *testing.T) {
	starter.Do(func() { setupMockServer(t) })

	testPUBNUB := PubnubInit("demo", "demo", "", "", false)
	testPUBNUB.ORIGIN = "http://" + addr.String()

	here_now_channel_1 := make(chan []byte)
	here_now_channel_2 := make(chan []byte)
	here_now_chipher_channel := make(chan []byte)

	var response []byte

	go testPUBNUB.HereNow("test-channel", here_now_channel_1)
	for {
		value, ok := <-here_now_channel_1
		if !ok {
			break
		}
		response = append(response, value...)
	}

	if fmt.Sprintf("%s", response) != "E33194F6-D6F1-4762-87D9-9D1DB5BC650Baa1686b0-cee8-012f-ba60-70def1fd2b7f2" {
		t.Fatalf("Failed here now request without chipher key: %s", response)
	}

	response = []byte{}
	go testPUBNUB.HereNow("no-here-now-channel", here_now_channel_2)
	for {
		value, ok := <-here_now_channel_2
		if !ok {
			break
		}
		response = append(response, value...)
	}
	if fmt.Sprintf("%s", response) != "0" {
		t.Fatalf("Failed here now request without chipher key: %s", response)
	}

	testPUBNUB.CIPHER_KEY = "enigma"
	response = []byte{}
	go testPUBNUB.HereNow("test-channel", here_now_chipher_channel)
	for {
		value, ok := <-here_now_chipher_channel
		if !ok {
			break
		}
		response = append(response, value...)
	}

	if fmt.Sprintf("%s", response) != "E33194F6-D6F1-4762-87D9-9D1DB5BC650Baa1686b0-cee8-012f-ba60-70def1fd2b7f2" {
		t.Fatalf("Failed here now request with chipher key: %s", response)
	}
}

func TestSubscribe(t *testing.T) {
	starter.Do(func() { setupMockServer(t) })

	testPUBNUB := PubnubInit("demo", "demo", "", "", false)
	testPUBNUB.ORIGIN = "http://" + addr.String()
	testPUBNUB.UUID = "aa1686b0-cee8-012f-ba60-70def1fd2b7f"
	timeToken = "0"

	subscribe_channel := make(chan []byte)
	subscribe_channel_with_chipher := make(chan []byte)

	var response []byte

	go testPUBNUB.Subscribe("test-channel", subscribe_channel)
	for {
		value, _ := <-subscribe_channel
		response = append(response, value...)
		break
	}

	if fmt.Sprintf("%s", response) != "hi" {
		t.Fatalf("Failed to subscribe without chipher key: %s", response)
	}

	testPUBNUB.CIPHER_KEY = "enigma"
	response = []byte{}
	go testPUBNUB.Subscribe("test-chipher-channel", subscribe_channel_with_chipher)
	for {
		value, _ := <-subscribe_channel_with_chipher
		response = append(response, value...)
		break
	}

	if fmt.Sprintf("%s", response) != "\"hi\"" {
		t.Fatalf("Failed to subscribe with chipher key: %s", response)
	}

}

func TestPresence(t *testing.T) {
	starter.Do(func() { setupMockServer(t) })

	testPUBNUB := PubnubInit("demo", "demo", "", "", false)
	testPUBNUB.ORIGIN = "http://" + addr.String()
	testPUBNUB.UUID = "aa1686b0-cee8-012f-ba60-70def1fd2b7f"
	timeToken = "0"

	presence_channel := make(chan []byte)
	presence_chipher_channel := make(chan []byte)

	var response []byte

	go testPUBNUB.Presence("test-channel", presence_channel)
	for i := 0; i < 4; i++ {
		value, ok := <-presence_channel
		if !ok {
			break
		}
		response = append(response, value...)
	}

	if fmt.Sprintf("%s", response) != "join134572016519753" {
		t.Fatalf("Failed to presence without chipher key: %s", response)
	}

	testPUBNUB.CIPHER_KEY = "enigma"
	response = []byte{}
	go testPUBNUB.Presence("test-channel", presence_chipher_channel)
	for i := 0; i < 4; i++ {
		value, ok := <-presence_chipher_channel
		if !ok {
			break
		}
		response = append(response, value...)
	}

	if fmt.Sprintf("%s", response) != "join134572016519753" {
		t.Fatalf("Failed to presence with chipher key: %s", response)
	}
}
