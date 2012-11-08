package pubnub

import (
	"errors"
	"fmt"
	"io/ioutil"
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
	value, err := pub.HttpRequest(url)
	c <- value
	if err != nil {
		close(c)
	}
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
	value, err := pub.HttpRequest(url)
	c <- value
	if err != nil {
		close(c)
	}
}

func (pub *PUBNUB) Subscribe(channel string, c chan []byte) {
	for {
		url := ""
		url += "/subscribe"
		url += "/" + pub.SUBSCRIBE_KEY
		url += "/" + channel
		url += "/0"
		url += "/" + timeToken

		value, err := pub.HttpRequest(url)
		c <- value
		if err != nil {
			close(c)
		}
		//Get timetoken from success response
		timeTokenArr := strings.Split(fmt.Sprintf("%s", value), ",")
		if len(timeTokenArr) > 1 {
			timeToken = strings.Replace(timeTokenArr[1], "\"", "", -1)
		}
	}
}

func (pub *PUBNUB) Unsubscribe(c chan []byte) {
	close(c)
}

func (pub *PUBNUB) History(channel string, limit int, c chan []byte) {
	url := ""
	url += "/history"
	url += "/" + pub.SUBSCRIBE_KEY
	url += "/" + channel
	url += "/0"
	url += "/" + fmt.Sprintf("%d", limit)

	// send response to channel
	value, err := pub.HttpRequest(url)
	c <- value
	if err != nil {
		close(c)
	}
}

func ResponseParser(response []byte) ([]byte, error) {
	string_resp := fmt.Sprintf("%s", response)

	//need better investigate this error
	if strings.Contains(string_resp, "<HTML>") && !strings.Contains(string_resp, "[") {
		new_error := errors.New("Invalid method in request")
		return []byte(fmt.Sprintf("Method Not Implemented: %s", new_error.Error())), new_error
	}
	return response, nil
}

func (pub *PUBNUB) HttpRequest(url string) ([]byte, error) {
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
		if strings.Contains(err.Error(), "timeout") {
			return []byte(fmt.Sprintf("%s: Reconnecting from timeout", time.Now().String())), nil
		} else {
			//log.Fatalf("request failed - %s", err.Error())
			return []byte(fmt.Sprintf("Network Error: %s", err.Error())), err
		}
	}
	defer resp.Body.Close()

	conn, err := httpClient.GetConn(req)
	if err != nil {
		//log.Fatalf("failed to get conn for req")
		return []byte(fmt.Sprintf("Connection Error: %s", err.Error())), err
	}
	if conn != nil {
		// do something with conn	
	}

	body, err := ioutil.ReadAll(resp.Body)

	httpClient.FinishRequest(req)
	return ResponseParser(body)
}
