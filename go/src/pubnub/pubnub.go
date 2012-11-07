package pubnub

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"time"
)

const _LIMIT = 1800
const _ORIGIN = "pubsub.pubnub.com"
const _TIMEOUT = 310

var timeToken = "0"

type PUBNUB struct {
	ORIGIN        string
	PUBLISH_KEY   string
	SUBSCRIBE_KEY string
	SECRET_KEY    string
	CIPHER_KEY    string
	LIMIT         int
	SSL           bool
}

//Init pubnub struct
func PubnubInit(publish_key string, subscribe_key string, secret_key string, chipher_key string, ssl_on bool) *PUBNUB {
	new_pubnub := &PUBNUB{
		ORIGIN:        _ORIGIN,
		PUBLISH_KEY:   publish_key,
		SUBSCRIBE_KEY: subscribe_key,
		SECRET_KEY:    secret_key,
		CIPHER_KEY:    chipher_key,
		LIMIT:         _LIMIT,
		SSL:           ssl_on,
	}

	if new_pubnub.SSL {
		new_pubnub.ORIGIN = "https://" + new_pubnub.ORIGIN
	} else {
		new_pubnub.ORIGIN = "http://" + new_pubnub.ORIGIN
	}

	return new_pubnub
}

func (pub *PUBNUB) GetTime(c chan []byte) {
	url := ""
	url += "/time"
	url += "/0"

	// send response to channel
	c <- pub.HttpRequest(url)
}

func (pub *PUBNUB) Publish(channel string, message string, c chan []byte) {
	signature := ""
	if pub.SECRET_KEY != "" {
		signature = GetHmacSha256(pub.SECRET_KEY, fmt.Sprintf("%s/%s/%s/%s/%s", pub.PUBLISH_KEY, pub.SUBSCRIBE_KEY, pub.SECRET_KEY, channel, message))
	} else {
		signature = "0"
	}
	url := ""
	url += "/publish"
	url += "/" + pub.PUBLISH_KEY
	url += "/" + pub.SUBSCRIBE_KEY
	url += "/" + signature
	url += "/" + channel
	url += "/0"
	url += fmt.Sprintf("/{\"msg\":\"%s\"}", message)

	// send response to channel
	c <- pub.HttpRequest(url)
}

func (pub *PUBNUB) Subscribe(channel string, c chan []byte) {
	for {
		url := ""
		url += "/subscribe"
		url += "/" + pub.SUBSCRIBE_KEY
		url += "/" + channel
		url += "/0"
		url += "/" + timeToken

		c <- pub.HttpRequest(url)
	}
}

func (pub *PUBNUB) History(channel string, limit int, c chan []byte) {
	url := ""
	url += "/history"
	url += "/" + pub.SUBSCRIBE_KEY
	url += "/" + channel
	url += "/0"
	url += "/" + fmt.Sprintf("%d", limit)

	// send response to channel
	c <- pub.HttpRequest(url)
}

func (pub *PUBNUB) HttpRequest(url string) []byte {
	httpClient := New()
	httpClient.ConnectTimeout = _TIMEOUT * time.Second
	httpClient.ReadWriteTimeout = _TIMEOUT * time.Second

	// Allow insecure HTTPS connections.  Note: the TLSClientConfig pointer can't change
	// places, so you can only modify the existing tls.Config object
	httpClient.TLSClientConfig.InsecureSkipVerify = pub.SSL

	// Make a custom redirect policy to keep track of the number of redirects we've followed
	var numRedirects int
	httpClient.RedirectPolicy = func(r *http.Request, v []*http.Request) error {
		numRedirects += 1
		return DefaultRedirectPolicy(r, v)
	}

	req, _ := http.NewRequest("GET", pub.ORIGIN+url, nil)
	//log.Printf("%s", req)

	resp, err := httpClient.Do(req)
	if err != nil {
		log.Fatalf("request failed - %s", err.Error())
	}
	defer resp.Body.Close()

	conn, err := httpClient.GetConn(req)
	if err != nil {
		log.Fatalf("failed to get conn for req")
	}
	if conn != nil {
		// do something with conn	
	}

	body, err := ioutil.ReadAll(resp.Body)

	//Only for test
	//Need to create normal response parser
	timeTokenArr := strings.Split(fmt.Sprintf("%s", body), ",")
	if len(timeTokenArr) > 1 {
		timeToken = strings.Replace(timeTokenArr[1], "\"", "", -1)
	}

	httpClient.FinishRequest(req)
	return body
}
