## ---------------------------------------------------
##
## YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
## http://www.pubnub.com/account
##
## ----------------------------------------------------

## -----------------------------------------
## PubNub 3.0 Real-time Cloud Push API - PHP
## -----------------------------------------
##
## www.pubnub.com - PubNub Real-time Push Service in the Cloud. 
## http://www.pubnub.com/blog/php-push-api-walkthrough
##
## PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
## This is a cloud-based service for broadcasting Real-time messages
## to thousands of web and mobile clients simultaneously.

## ------------
## PHP Push API
## ------------
$pubnub = new Pubnub(
    "demo",  ## PUBLISH_KEY
    "demo",  ## SUBSCRIBE_KEY
    "",      ## SECRET_KEY
    false    ## SSL_ON?
);

## ----------------------
## Send Message (PUBLISH)
## ----------------------
$info = $pubnub->publish(array(
    'channel' => 'hello_world', ## REQUIRED Channel to Send
    'message' => 'Hey World!'   ## REQUIRED Message String/Array
));
var_dump($info);

## --------------------------
## Request Messages (HISTORY, deprecated, use detailedHistory() below)
## --------------------------
$messages = $pubnub->history(array(
    'channel' => 'hello_world',  ## REQUIRED Channel to Send
    'limit'   => 100             ## OPTIONAL Limit Number of Messages
));
var_dump($messages);             ## Prints array of messages.

## --------------------------
## Request Server Time (TIME)
## --------------------------
$timestamp = $pubnub->time();
var_dump($timestamp);            ## Prints integer timestamp.

## ----------------------------------
## PHP 5.2.0. THIS WILL BLOCK!!!
## Receive Message (SUBSCRIBE)
## THIS WILL BLOCK. PHP 5.2.0
## ----------------------------------
$pubnub->subscribe(array(
    'channel'  => 'hello_world',        ## REQUIRED Channel to Listen
    'callback' => create_function(      ## REQUIRED PHP 5.2.0 Method
        '$message',
        'var_dump($message); return true;'
    )
));


## ----------------------------------
## PHP 5.3.0 ONLY. THIS WILL BLOCK!!!
## Receive Message (SUBSCRIBE)
## THIS WILL BLOCK. PHP 5.3.0 ONLY!!!
## ----------------------------------
$pubnub->subscribe(array(
    'channel'  => 'hello_world',        ## REQUIRED Channel to Listen
    'callback' => function($message) {  ## REQUIRED Callback With Response
        var_dump($message);  ## Print Message
        return true;         ## Keep listening (return false to stop)
    }
));

## --------------------------
## Realtime Join/Leave Events (Presence)
## --------------------------
$pubnub->presence(array(
    'channel'  => $channel,
    'callback' => function($message) {
        print_r($message);
		echo "\r\n";
        return true;
    }
));

## --------------------------
## On-demand Occupancy Status (here_now)
## --------------------------
$here_now = $pubnub->here_now(array(
    'channel' => $channel
));

## --------------------------
## Detailed History (detailedHistory())
## --------------------------
$history = $pubnub->detailedHistory(array(
    'channel' => $channel,
    'count'   => 10,
    'end'   => "13466530169226760"
));