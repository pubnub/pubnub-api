<?php
require_once('Pubnub.php');

// TODO: Add SSL version of these tests
## ---------------------------------------------------------------------------
## USAGE:
## ---------------------------------------------------------------------------
#
# php ./pubnubPlaintextTests.php
# php ./pubnubPlaintextTests.php [PUB-KEY] [SUB-KEY] [SECRET-KEY] [CIPHER-KEY] [USE SSL]
#


## Capture Publish and Subscribe Keys from Command Line
$publish_key   = isset($argv[1]) ? $argv[1] : 'demo';
$subscribe_key = isset($argv[2]) ? $argv[2] : 'demo';
$secret_key    = isset($argv[3]) ? $argv[3] : false;
$cipher_key	   = isset($argv[4]) ? $argv[4] : false;
$ssl_on        = false;

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
    'message' => 'Hello from PHP!'
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

// This should return a failure (0) JSON Array
$publish_success = $pubnub->publish(array(
    'channel' => $channel,
    'message' => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
));
echo($publish_success[0] . $publish_success[1]);
echo "\r\n";

## ---------------------------------------------------------------------------
## History Example
## ---------------------------------------------------------------------------
echo "Running history\r\n";
$history = $pubnub->history(array(
    'channel' => $channel,
    'limit'   => 2
));
print_r($history);
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
//        return true;
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
