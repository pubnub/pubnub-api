###YOU MUST HAVE A PUBNUB ACCOUNT TO USE THE API.
###http://www.pubnub.com/account

## PubNub 3.3 Real-time Cloud Push API - PHP

www.pubnub.com - PubNub Real-time Push Service in the Cloud. 
http://www.pubnub.com/blog/php-push-api-walkthrough

### PubNub is a Massively Scalable Real-time Service for Web and Mobile Games.
### This is a cloud-based service for broadcasting Real-time messages
### to thousands of web and mobile clients simultaneously.


## PHP Push API
```php
$pubnub = new Pubnub(
    "demo",  ## PUBLISH_KEY
    "demo",  ## SUBSCRIBE_KEY
    "",      ## SECRET_KEY
    false    ## SSL_ON?
);
```


## Send Message (PUBLISH)
```php
$info = $pubnub->publish(array(
    'channel' => 'hello_world', ## REQUIRED Channel to Send
    'message' => 'Hey World!'   ## REQUIRED Message String/Array
));
print_r($info);
```

## Request Messages (HISTORY, deprecated, use detailedHistory() below)
```php
$messages = $pubnub->history(array(
    'channel' => 'hello_world',  ## REQUIRED Channel to Send
    'limit'   => 100             ## OPTIONAL Limit Number of Messages
));
print_r($messages);             ## Prints array of messages.
```

## Request Server Time (TIME)
```php
$timestamp = $pubnub->time();
var_dump($timestamp);            ## Prints integer timestamp.
```

## Receive Message (SUBSCRIBE) PHP 5.2.0
```php
$pubnub->subscribe(array(
    'channel'  => 'hello_world',        ## REQUIRED Channel to Listen
    'callback' => create_function(      ## REQUIRED PHP 5.2.0 Method
        '$message',
        'var_dump($message); return true;'
    )
));
```

## Receive Message (SUBSCRIBE) PHP 5.3.0
```php
$pubnub->subscribe(array(
    'channel'  => 'hello_world',        ## REQUIRED Channel to Listen
    'callback' => function($message) {  ## REQUIRED Callback With Response
        var_dump($message);  ## Print Message
        return true;         ## Keep listening (return false to stop)
    }
));
```


## Realtime Join/Leave Events (Presence)
```php
$pubnub->presence(array(
    'channel'  => $channel,
    'callback' => function($message) {
        print_r($message);
		echo "\r\n";
        return true;
    }
));
```

## On-demand Occupancy Status (here_now)
```php
$here_now = $pubnub->here_now(array(
    'channel' => $channel
));
```

## Detailed History (detailedHistory())
```php
$history = $pubnub->detailedHistory(array(
    'channel' => $channel,
    'count'   => 10,
    'end'   => "13466530169226760"
));
```