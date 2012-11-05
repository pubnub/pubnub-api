package pubnub

import (
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

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
		ORIGIN:        "pubsub.pubnub.com",
		PUBLISH_KEY:   publish_key,
		SUBSCRIBE_KEY: subscribe_key,
		SECRET_KEY:    secret_key,
		CIPHER_KEY:    chipher_key,
		LIMIT:         0,
		SSL:           ssl_on,
	}

	if new_pubnub.SSL {
		new_pubnub.ORIGIN = "https://" + new_pubnub.ORIGIN
	} else {
		new_pubnub.ORIGIN = "http://" + new_pubnub.ORIGIN
	}

	return new_pubnub
}

func (pub *PUBNUB) GetTime() []byte {
	httpClient := New()
	httpClient.ConnectTimeout = time.Second
	httpClient.ReadWriteTimeout = time.Second

	// Allow insecure HTTPS connections.  Note: the TLSClientConfig pointer can't change
	// places, so you can only modify the existing tls.Config object
	httpClient.TLSClientConfig.InsecureSkipVerify = pub.SSL

	// Make a custom redirect policy to keep track of the number of redirects we've followed
	var numRedirects int
	httpClient.RedirectPolicy = func(r *http.Request, v []*http.Request) error {
		numRedirects += 1
		return DefaultRedirectPolicy(r, v)
	}

	req, _ := http.NewRequest("GET", pub.ORIGIN+"/time/0", nil)
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
	//log.Printf("%s", body)

	httpClient.FinishRequest(req)
	return body
}
