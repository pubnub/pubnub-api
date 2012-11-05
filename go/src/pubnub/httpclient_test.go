package pubnub

import (
	"bytes"
	"io"
	"io/ioutil"
	"net"
	"net/http"
	"sync"
	"testing"
	"time"
)

var starter sync.Once
var addr net.Addr

func testHandler(w http.ResponseWriter, req *http.Request) {
	time.Sleep(200 * time.Millisecond)
	io.WriteString(w, "hello, world!\n")
}

func postHandler(w http.ResponseWriter, req *http.Request) {
	ioutil.ReadAll(req.Body)
	w.Header().Set("Content-Length", "2")
	io.WriteString(w, "OK")
}

func redirectHandler(w http.ResponseWriter, req *http.Request) {
	ioutil.ReadAll(req.Body)
	http.Redirect(w, req, "/post", 302)
}

func setupMockServer(t *testing.T) {
	http.HandleFunc("/test", testHandler)
	http.HandleFunc("/post", postHandler)
	http.HandleFunc("/redirect", redirectHandler)
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

func TestHttpsConnection(t *testing.T) {
	httpClient := New()
	httpClient.TLSClientConfig.InsecureSkipVerify = true

	req, _ := http.NewRequest("GET", "https://httpbin.org/ip", nil)

	resp, err := httpClient.Do(req)
	if err != nil {
		t.Fatalf("1st request failed - %s", err.Error())
	}
	defer resp.Body.Close()
	_, err = ioutil.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("1st failed to read body - %s", err.Error())
	}
	httpClient.FinishRequest(req)

	httpClient.ReadWriteTimeout = 20 * time.Millisecond
	req2, _ := http.NewRequest("GET", "https://httpbin.org/delay/5", nil)

	_, err = httpClient.Do(req)
	if err == nil {
		t.Fatalf("HTTPS request should have timed out")
	}
	httpClient.FinishRequest(req2)
}

func TestCustomRedirectPolicy(t *testing.T) {
	starter.Do(func() { setupMockServer(t) })

	httpClient := New()
	numRedirects := 0
	httpClient.RedirectPolicy = func(r *http.Request, v []*http.Request) error {
		numRedirects += 1
		return DefaultRedirectPolicy(r, v)
	}

	req, _ := http.NewRequest("GET", "http://"+addr.String()+"/redirect", nil)

	resp, err := httpClient.Do(req)
	if err != nil {
		t.Fatalf("1st request failed - %s", err.Error())
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("1st failed to read body - %s", err.Error())
	}
	httpClient.FinishRequest(req)

	if numRedirects != 1 {
		t.Fatalf("Did not correctly redirect with custom redirect policy", err.Error())
	}

	t.Logf("%s", body)
}

func TestHttpClient(t *testing.T) {
	starter.Do(func() { setupMockServer(t) })

	httpClient := New()
	if httpClient == nil {
		t.Fatalf("failed to instantiate HttpClient")
	}

	req, _ := http.NewRequest("GET", "http://"+addr.String()+"/test", nil)

	resp, err := httpClient.Do(req)
	if err != nil {
		t.Fatalf("1st request failed - %s", err.Error())
	}
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("1st failed to read body - %s", err.Error())
	}
	t.Logf("%s", body)
	httpClient.FinishRequest(req)

	httpClient.ReadWriteTimeout = 50 * time.Millisecond
	resp, err = httpClient.Do(req)
	if err == nil {
		t.Fatalf("2nd request should have timed out")
	}
	httpClient.FinishRequest(req)

	httpClient.ReadWriteTimeout = 250 * time.Millisecond
	resp, err = httpClient.Do(req)
	if err != nil {
		t.Fatalf("3nd request should not have timed out")
	}
	httpClient.FinishRequest(req)
}

func TestManyPosts(t *testing.T) {
	starter.Do(func() { setupMockServer(t) })

	httpClient := New()
	if httpClient == nil {
		t.Fatalf("failed to instantiate HttpClient")
	}

	data := ""
	for i := 0; i < 100; i++ {
		data = data + "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	}
	data = data + "\n"

	for i := 0; i < 10000; i++ {
		buffer := bytes.NewBuffer([]byte(data))
		req, _ := http.NewRequest("POST", "http://"+addr.String()+"/post", buffer)

		resp, err := httpClient.Do(req)
		if err != nil {
			t.Fatalf("%d post request failed - %s", i, err.Error())
		}
		_, err = ioutil.ReadAll(resp.Body)
		if err != nil {
			t.Fatalf("%d failed to read body - %s", i, err.Error())
		}
		resp.Body.Close()
		httpClient.FinishRequest(req)
	}
}
