<?php

require_once('Pubnub.php');

##
# php ./pubnubPlaintextTests.php
# php ./pubnubPlaintextTests.php [PUB-KEY] [SUB-KEY] [SECRET-KEY] [CIPHER-KEY] [USE SSL]

## Capture Publish and Subscribe Keys from Command Line


// TODO: Need SSL tests

$publish_key   = 'demo';
$subscribe_key = 'demo';
$secret_key    =  false;
$cipher_key =  "enigma";
$ssl_on        = false;

$plain_text = "yay!";
$cipher_text = "q/xJqqN6qbiZMXYmiQC1Fw==";
$cipher_key = "enigma";

## Encryption Test
if (decrypt($cipher_text, $cipher_key) == $plain_text) {
    echo "Standard encryption test PASS.\n\n";
} else
    echo "Standard encryption test FAIL.\n\n";

## Decryption Test
if (encrypt($plain_text, $cipher_key) == $cipher_text) {
    echo "Standard decryption test PASS.\n\n";
} else
    echo "Standard decryption test FAIL.\n\n";


## ---------------------------------------------------------------------------
## Create Pubnub Object
## ---------------------------------------------------------------------------
$pubnub = new Pubnub( $publish_key, $subscribe_key, $secret_key, $cipher_key, $ssl_on );

## ---------------------------------------------------------------------------
## Define Messaging Channel
## ---------------------------------------------------------------------------
$channel = "hello_world";

## ---------------------------------------------------------------------------
## Publish Example
## ---------------------------------------------------------------------------
echo "Running publish\r\n";
$publish_success = $pubnub->publish(array(
    'channel' => $channel,
    'message' => 'Pubnub Messaging API 1'
));
echo($publish_success[0] . $publish_success[1]);
echo "\r\n";

$publish_success = $pubnub->publish(array(
    'channel' => $channel,
    'message' => 'Pubnub Messaging API 2'
));
echo($publish_success[0] . $publish_success[1]);
echo "\r\n";



$publish_success = $pubnub->publish(array(
    'channel' => $channel,
    'message' => '漢語'
));
echo($publish_success[0] . $publish_success[1]);
echo "\r\n";

// Publish an associative array

$big_array = array();
$big_array["this stuff"]["can get"] = "complicated!";

$publish_success = $pubnub->publish(array(
    'channel' => $channel,
    'message' => $big_array
));

echo($publish_success[0] . $publish_success[1]);
echo "\r\n";

// Publish an empty array
$emptyArray = array();
$publish_success = $pubnub->publish(array(
    'channel' => $channel,
    'message' => $emptyArray
));

echo($publish_success[0] . $publish_success[1]);
echo "\r\n";

// This should return a failure (0) JSON Array
$publish_success = $pubnub->publish(array(
    'channel' => $channel,
    'message' => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
));
echo($publish_success[0] . $publish_success[1]);
echo "\r\n";


## ---------------------------------------------------------------------------
## detailedHistory Example
## ---------------------------------------------------------------------------
echo "Running detailedHistory\r\n";
$history = $pubnub->detailedHistory(array(
    'channel' => $channel,
    'count'   => 5,
    'end'   => "13466530169226760"
));
print_r($history);
echo "\r\n";

## ---------------------------------------------------------------------------
## History Example
## ---------------------------------------------------------------------------
echo "Running history\r\n";
$history = $pubnub->history(array(
    'channel' => $channel,
    'limit'   => 2
));
echo($history);
echo "\r\n";

## ---------------------------------------------------------------------------
## Here_Now Example
## ---------------------------------------------------------------------------
echo "Running here_now\r\n";
$here_now = $pubnub->here_now(array(
    'channel' => $channel
));
var_dump($here_now);
echo "\r\n";

## ---------------------------------------------------------------------------
## Timestamp Example
## ---------------------------------------------------------------------------
echo "Running timestamp\r\n";
$timestamp = $pubnub->time();
echo('Timestamp: ' . $timestamp);
echo "\r\n";

## ---------------------------------------------------------------------------
## Presence Example
## ---------------------------------------------------------------------------
//echo("\nWaiting for Presence message... Hit CTRL+C to finish.\n");
//
//$pubnub->presence(array(
//    'channel'  => $channel,
//    'callback' => function($message) {
//        print_r($message);
//		echo "\r\n";
//        return false;
//    }
//));

## ---------------------------------------------------------------------------
## Subscribe Example
## ---------------------------------------------------------------------------
echo("\nWaiting for Publish message... Hit CTRL+C to finish.\n");

$pubnub->subscribe(array(
    'channel'  => $channel,
    'callback' => function($message) {
        print_r($message);
		echo "\r\n";
        return true;
    }
));

?>

