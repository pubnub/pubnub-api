package pubnubMessaging

import (
    "encoding/json"
    "fmt"
    "io/ioutil"
    "net/http"
    "strings"
    "time"
    "net"
    "crypto/tls"
)

const _limit = 1800
const _origin = "pubsub.pubnub.com"
const _timeout = 310


type Pubnub struct {
    origin        		string
    publishKey   		string
    subscribeKey 		string
    secretKey    		string
    cipherKey    		string
    limit         		int
    ssl           		bool
    uuid          		string
    subscribedChannels 	string 
    timeToken			string
    resetTimeToken 		bool   
}

//Init pubnub struct
func PubnubInit(publishKey string, subscribeKey string, secretKey string, cipherKey string, sslOn bool, customUuid string) *Pubnub {
    newPubnub := &Pubnub{
        origin:        		_origin,
        publishKey:   		publishKey,
        subscribeKey: 		subscribeKey,
        secretKey:    		secretKey,
        cipherKey:    		cipherKey,
        limit:         		_limit,
        ssl:           		sslOn,
        uuid:          		"",
        subscribedChannels: "",
        resetTimeToken:		true,
        timeToken:			"0",
    }

    if newPubnub.ssl {
        newPubnub.origin = "https://" + newPubnub.origin
    } else {
        newPubnub.origin = "http://" + newPubnub.origin
    }

    if customUuid == "" {
        uuid, err := GenUuid()
        if err == nil {
            newPubnub.uuid = uuid
        } else {
            fmt.Println(err)
        }
    } else {
        newPubnub.uuid = customUuid
    }

    return newPubnub
}

func (pub *Pubnub) Abort() {
	pub.subscribedChannels = ""
}

func (pub *Pubnub) GetTime(c chan []byte) {
    url := ""
    url += "/time"
    url += "/0"

    value, err := pub.HttpRequest(url)

    // send response to channel
    if err != nil {
        c <- value
    } else {
     	c <- []byte(fmt.Sprintf("%s", value))
    }
    close(c)
}

func (pub *Pubnub) Publish(channel string, message string, c chan []byte) {
    signature := ""
    if pub.secretKey != "" {
        signature = GetHmacSha256(pub.secretKey, fmt.Sprintf("%s/%s/%s/%s/%s", pub.publishKey, pub.subscribeKey, pub.secretKey, channel, message))
    } else {
        signature = "0"
    }
    url := ""
    url += "/publish"
    url += "/" + pub.publishKey
    url += "/" + pub.subscribeKey
    url += "/" + signature
    url += "/" + channel
    url += "/0"

    //Now only for string, need add encrypt for other types
    // use "/{\"msg\":\"%s\"}" for sending hash 
    if pub.cipherKey != "" {
        url += fmt.Sprintf("/\"%s\"", EncryptString(pub.cipherKey, fmt.Sprintf("\"%s\"", message)))
    } else {
        url += fmt.Sprintf("/\"%s\"", message)
    }

    value, err := pub.HttpRequest(url)

    if err != nil {
        c <- value
    } else {
     	c <- []byte(fmt.Sprintf("%s", value))
    }
    close(c)
}

func (pub *Pubnub) Subscribe(channels string, c chan []byte, isPresenceSubscribe bool) {
    channelArray := strings.Split(channels, ",")
	pub.resetTimeToken = true
	if isPresenceSubscribe {
	    for i := 0; i < len(channelArray); i++ {
	    	channelToSub := strings.TrimSpace(channelArray[i]) + "-pnpres"
	    	if pub.NotDuplicate(channelToSub) {
		    	if len(pub.subscribedChannels)>0 {
		    		pub.subscribedChannels += ","
		    	}      	
	    		pub.subscribedChannels += channelToSub
	    	}else{
	    		//TODO: channel already subscribed message
	    	}
	    }	
	}else{
	    for i := 0; i < len(channelArray); i++ {
	    	channelToSub := strings.TrimSpace(channelArray[i])
	    	if pub.NotDuplicate(channelToSub) {
		    	if len(pub.subscribedChannels)>0 {
		    		pub.subscribedChannels += ","
		    	}    	
	    		pub.subscribedChannels += channelToSub
	    	}else{
	    		//TODO: channel already subscribed message
	    	}    	
	    }
	}
    for {
  		if len(pub.subscribedChannels) > 0 {
            url := ""
            url += "/subscribe"
            url += "/" + pub.subscribeKey
            url += "/" + pub.subscribedChannels
            url += "/0"
            if pub.resetTimeToken {
            	url += "/0"
            	pub.resetTimeToken = false
            }else{
            	url += "/" + pub.timeToken
           	}
            	
            if pub.uuid != "" {
                url += "?uuid=" + pub.uuid
            }
            
            value, err := pub.HttpRequest(url)

            if err != nil {
                c <- value
                if strings.Contains(err.Error(), "timeout") || strings.Contains(err.Error(), "no such host") {
					SleepForAWhile()
				}
            } else if string(value) != "" {
	            if string(value) == "[]" {
	            	SleepForAWhile()
	            	continue
	            }      
	            
	            //data, returnTimeToken, returnedChannels, err := ParseJson(value)
	           	data, returnTimeToken, _ , err := ParseJson(value)
	            pub.timeToken = returnTimeToken
				if data == "[]" {
					continue
				}
				           
	            if err != nil {  
					fmt.Println(fmt.Sprintf("Error: %s", err))
				}

				//fmt.Println(fmt.Sprintf("timetoken %s:", pub.timeToken))

                c <- []byte(fmt.Sprintf("%s", value))
                /*if pub.cipherKey != "" {
                	c <- []byte(DecryptString(pub.cipherKey, fmt.Sprintf("%s", value)))
                } else {
                   	//c <- []byte(fmt.Sprintf("%s %s %s %s ", value, data, timeToken, returnedChannels))
                    c <- []byte(fmt.Sprintf("%s", value))
              	}*/
            }
        }else {
        	break;
        }
    }
    fmt.Println("Closing Subscribe channel")
    //close(c)
}

func SleepForAWhile(){
    //TODO: change to reconnect val
	time.Sleep(1000 * time.Millisecond)
}

func (pub *Pubnub) NotDuplicate(channel string) (b bool){
	var channels = strings.Split(pub.subscribedChannels, ",")
	for i, u := range channels {
		if channel == u {
			return false
		} 
		i++
		//fmt.Println(i, u)
    }
    return true 
}

func (pub *Pubnub) RemoveFromSubscribeList(channel string) (b bool){
	var channels = strings.Split(pub.subscribedChannels, ",")
	newChannels := ""
	found := false
	for i, u := range channels {
		if channel == u {
			found = true
		} else {
			if len(newChannels)>0 {
		    	newChannels += ","
		    }      	
	    	newChannels += u			
		}
		i++
		//fmt.Println(i, u)
    }
    if found {
    	pub.subscribedChannels = newChannels
    	//fmt.Println(fmt.Sprintf("%s", newChannels))
    }
	return found
}

func (pub *Pubnub) Unsubscribe(channels string, c chan []byte) {
    channelArray := strings.Split(channels, ",")
    unsubscribeChannels := ""
    for i := 0; i < len(channelArray); i++ {
    	if i>0 {
    		unsubscribeChannels += ","
    	}
    	channelToUnsub := strings.TrimSpace(channelArray[i]);
    	unsubscribeChannels += channelToUnsub
    	removed := pub.RemoveFromSubscribeList(channelToUnsub)
    	if !removed {
    		//TODO: channel not subscribed message
    	}    	
    }
    pub.resetTimeToken = true
    
	url := ""
	url += "/v2/presence"
	url += "/sub-key/" + pub.subscribeKey
	url += "/channel/" + unsubscribeChannels
	url += "/leave?uuid=" + pub.uuid
	value, err := pub.HttpRequest(url)
	c <- value
	if err != nil {
	   c <- value
	}
    close(c)
}

func (pub *Pubnub) PrsenceUnsubscribe(channels string, c chan []byte) {
    channelArray := strings.Split(channels, ",")
    presenceChannels := ""
    for i := 0; i < len(channelArray); i++ {
    	if i>0 {
    		presenceChannels += ","
    	}
    	channelToUnsub := strings.TrimSpace(channelArray[i]) + "-pnpres"
    	presenceChannels += channelToUnsub
    	removed := pub.RemoveFromSubscribeList(channelToUnsub) 
    	if !removed {
    		//TODO: channel not subscribed message
    	}
    	   	
    }
    pub.resetTimeToken = true
    
    url := ""
    url += "/v2/presence"
    url += "/sub-key/" + pub.subscribeKey
    url += "/channel/" + presenceChannels
    url += "/leave?uuid=" + pub.uuid
		
    value, err := pub.HttpRequest(url)
    c <- value
    if err != nil {
    	c <- value
    }
    close(c)
}

func (pub *Pubnub) History(channel string, limit int, c chan []byte) {
    url := ""
    url += "/history"
    url += "/" + pub.subscribeKey
    url += "/" + channel
    url += "/0"
    url += "/" + fmt.Sprintf("%d", limit)

    value, err := pub.HttpRequest(url)

    if err != nil {
        c <- value
    } else {
     	c <- []byte(fmt.Sprintf("%s", value))
    }
    close(c)
}

func (pub *Pubnub) HereNow(channel string, c chan []byte) {
    url := ""
    url += "/v2/presence"
    url += "/sub-key/" + pub.subscribeKey
    url += "/channel/" + channel

    value, err := pub.HttpRequest(url)

    if err != nil {
        c <- value
    } else {
     	c <- []byte(fmt.Sprintf("%s", value))
    }
    close(c)
}

func ParseJson (contents []byte) (data string, timeToken string, channels string, err error){
    var s interface{}
    returnData := ""
    returnTimeToken := ""
    returnChannels := ""
	if err := json.Unmarshal(contents, &s); err == nil {
	     v := s.(interface{})
        switch vv := v.(type) {
        case string:
            //fmt.Println("is string", vv)
        case int:
            //fmt.Println("is int", vv)
        case []interface{}:
            //fmt.Println("is an array:")
            
            for i, u := range vv {
                //fmt.Println(i, u)
                if i==0 {
                	returnData = fmt.Sprintf("%s", u) 
                }else if (i==1){
                	returnTimeToken = fmt.Sprintf("%s", u)
                }else if (i==2){
                	channels = fmt.Sprintf("%s", u);
                }
                
            }
        default:
            //fmt.Println("is of a type I don't know how to handle")
        }
	} else {
	    //something went wrong
	    fmt.Println("err:", err)
	}
	return returnData, returnTimeToken, returnChannels, err
}

func (pub *Pubnub) HttpRequest(url string) ([]byte, error) {
    //fmt.Println("pub.ORIGIN+url:", pub.origin+url)
	response, err := Connect(pub.origin+url)
	
    if err != nil {
    	if neterr, ok := err.(net.Error); ok && neterr.Timeout() {
            return []byte(fmt.Sprintf("%s: Reconnecting from timeout", time.Now().String())), nil
        } else {
            return []byte(fmt.Sprintf("Network Error: %s", err.Error())), err
        }
    }
    
    contents, err := ioutil.ReadAll(response.Body)
    return contents, err
}

func Connect (url string) (*http.Response, error) {
	transport := &http.Transport{TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		Dial: func(netw, addr string) (net.Conn, error) {
			deadline := time.Now().Add(_timeout * time.Second)
			c, err := net.DialTimeout(netw, addr, time.Second)
			if err != nil {
				return nil, err
			}
			c.SetDeadline(deadline)
			return c, nil
		}}
	httpclient := &http.Client{Transport: transport, CheckRedirect: nil}
 	
	response, err := httpclient.Get(url)
	if err != nil {
		 //fmt.Printf("Connect error here: %s", err) 
	}
 
    return response, err
}


