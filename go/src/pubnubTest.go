package main 

import (
    "bufio"
    "os"
    "fmt"
    "time"
    "pubnubMessaging"
    "strings"
)

const delim = '\n'

var pubnubChannel = ""
var ssl bool
var cipher = ""
var uuid = ""
var pub *pubnubMessaging.Pubnub

func main() {
    b := Init()
    if b {
	    ch := make(chan int)
	    ReadLoop(ch)
    }
    fmt.Println("Exit")
}

func Init() (b bool){
    fmt.Println("Please enter the channel name(s). Enter multiple channels separated by comma.")
    reader := bufio.NewReader(os.Stdin)
    
    line, _ , err := reader.ReadLine()
    if err != nil {
        fmt.Println(err)
    }else{
        pubnubChannel = string(line)
        if strings.TrimSpace(pubnubChannel) != "" { 
	        fmt.Println("Channel: ", pubnubChannel)
	        fmt.Println("Enable SSL. Enter y for Yes, n for No.")
	        var enableSsl string
	        fmt.Scanln(&enableSsl)
	        
	        if enableSsl == "y" || enableSsl == "Y" {
	            ssl = true
	            fmt.Println("SSL enabled")    
	        }else{
	            ssl = false
	            fmt.Println("SSL disabled")
	        }
	        
	        fmt.Println("Please enter a CIPHER key, leave blank if you don't want to use this.")
	        fmt.Scanln(&cipher)
	        fmt.Println("Cipher: ", cipher)
	        
	        fmt.Println("Please enter a Custom UUID, leave blank for default.")
	        fmt.Scanln(&uuid)
	        fmt.Println("UUID: ", uuid)
	        
	        pubInstance := pubnubMessaging.PubnubInit("demo", "demo", "", cipher, ssl, uuid)
	        pub = pubInstance
	        return true
	    }else{
	    	fmt.Println("Channel cannot be empty.")
	    }    
    }
    return false
}

func ReadLoop(ch chan int){
	fmt.Println("")
    fmt.Println("ENTER 1 FOR Subscribe")
    fmt.Println("ENTER 2 FOR Publish")
    fmt.Println("ENTER 3 FOR Presence")
    fmt.Println("ENTER 4 FOR Detailed History")
    fmt.Println("ENTER 5 FOR Here_Now")
    fmt.Println("ENTER 6 FOR Unsubscribe")
    fmt.Println("ENTER 7 FOR Presence-Unsubscribe")
    fmt.Println("ENTER 8 FOR Time")
    fmt.Println("ENTER 9 FOR Exit")
    fmt.Println("")
    reader := bufio.NewReader(os.Stdin)
    
    for{
        var action string
        fmt.Scanln(&action)
        breakOut := false
        switch action {
            case "1":
                fmt.Println("Running Subscribe")
                go SubscribeRoutine()
            case "2":
                fmt.Println("Please enter the message")
                message, _ , err := reader.ReadLine()
                if err != nil {
                    fmt.Println(err)
                }else{
                    go PublishRoutine(string(message))
                }
            case "3":
                fmt.Println("Running Presence")
                go PresenceRoutine()    
            case "4":
                fmt.Println("Running detailed history")
                go DetailedHistoryRoutine()
            case "5":
                fmt.Println("Running here now")
                go HereNowRoutine()            
            case "6":
                fmt.Println("Running Unsubscribe")
                go UnsubscribeRoutine()
            case "7":
                fmt.Println("Running Unsubscribe Presence")
                go UnsubscribePresenceRoutine()
            case "8":
                fmt.Println("Running Time")
                go TimeRoutine()
            case "9":
                fmt.Println("Exiting") 
                pub.Abort()   
                breakOut = true
            case "default":            
        }
        if breakOut {
            break
        }else{
            time.Sleep(1000 * time.Millisecond)
        }
    }
    close(ch)
}

func ParseResponseSubscribe(channel chan []byte){
    for {
        value, ok := <-channel
        if !ok {  
        	fmt.Println("")            
            break
        }
		if string(value) != "[]"{
	        fmt.Println(fmt.Sprintf("Subscribe: %s", value))
	        //fmt.Println(fmt.Sprintf("%s", value))
	        fmt.Println("")
        }
    }
}

func ParseResponsePresence(channel chan []byte){
    for {
        value, ok := <-channel
        if !ok {  
            break
        }
        if string(value) != "[]"{
        	fmt.Println(fmt.Sprintf("Presence: %s ", value))
        	//fmt.Println(fmt.Sprintf("%s", value))
        	fmt.Println("");
        }
    }
}

func ParseResponse(channel chan []byte){
    for {
        value, ok := <-channel
        if !ok {
            break
        }
        if string(value) != "[]"{
	        fmt.Println(fmt.Sprintf("Response: %s ", value))
	        //fmt.Println(fmt.Sprintf("%s", value))
	        fmt.Println("");
	    }
    }
}

func SubscribeRoutine(){
	var subscribeChannel = make(chan []byte)
    go pub.Subscribe(pubnubChannel, subscribeChannel, false)
    ParseResponseSubscribe(subscribeChannel)
}

func PublishRoutine(message string){
    channelArray := strings.Split(pubnubChannel, ",");
    
    for i:=0; i < len(channelArray); i++ {
        ch := strings.TrimSpace(channelArray[i])
        fmt.Println("Publish to channel: ",ch)
        channel := make(chan []byte)
        go pub.Publish(ch, message, channel)
        ParseResponse(channel)
    }
}

func PresenceRoutine(){
	var presenceChannel = make(chan []byte)
    //go pub.Subscribe(pubnubChannel, subscribeChannel, true)
    go pub.Subscribe(pubnubChannel, presenceChannel, true)
    ParseResponsePresence(presenceChannel)
}

func DetailedHistoryRoutine(){
    channelArray := strings.Split(pubnubChannel, ",");
    for i:=0; i < len(channelArray); i++ {
        ch := strings.TrimSpace(channelArray[i])
        fmt.Println("DetailedHistory for channel: ", ch)
        
        channel := make(chan []byte)
        
        go pub.History(ch, 100, channel)
        ParseResponse(channel)
    }
}

func HereNowRoutine(){
    channelArray := strings.Split(pubnubChannel, ",");
    for i:=0; i < len(channelArray); i++ {    
        channel := make(chan []byte)
        ch := strings.TrimSpace(channelArray[i])
        fmt.Println("HereNow for channel: ", ch)
        
        go pub.HereNow(ch, channel)
        ParseResponse(channel)
    }
}

func UnsubscribeRoutine(){
    channel := make(chan []byte)
    
    go pub.Unsubscribe(pubnubChannel, channel)
    ParseResponse(channel)
}

func UnsubscribePresenceRoutine(){
    channel := make(chan []byte)
    
    go pub.PrsenceUnsubscribe(pubnubChannel, channel)
    ParseResponse(channel)
}

func TimeRoutine(){
    channel := make(chan []byte)
    go pub.GetTime(channel)
    ParseResponse(channel)
}