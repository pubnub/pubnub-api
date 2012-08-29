<?php

require_once('Pubnub.php');

## ---------------------------------------------------------------------------
## USAGE:
## ---------------------------------------------------------------------------
#
# php ./unit-test.php
# php ./unit-test.php [PUB-KEY] [SUB-KEY] [SECRET-KEY] [USE SSL]
#


## Capture Publish and Subscribe Keys from Command Line
$publish_key   = isset($argv[1]) ? $argv[1] : 'demo';
$subscribe_key = isset($argv[2]) ? $argv[2] : 'demo';
$secret_key    = isset($argv[3]) ? $argv[3] : false;
$ssl_on        = isset($argv[4]);

## ---------------------------------------------------------------------------
## Create Pubnub Object
## ---------------------------------------------------------------------------
$pubnub = new Pubnub( $publish_key, $subscribe_key, $secret_key, $ssl_on );

## ---------------------------------------------------------------------------
## Generate Random Channel Name
## ---------------------------------------------------------------------------
$channel = 'unit-test-' . rand( 0, 100000000 ) . rand( 0, 100000000 );


## ---------------------------------------------------------------------------
## Get History Part 1
## ---------------------------------------------------------------------------
$history = $pubnub->history(array(
    'channel' => $channel,
    'limit'   => 1
));
test( count($history), 0, 'Initial Empty History' );


## ---------------------------------------------------------------------------
## PUBLISH
## ---------------------------------------------------------------------------
$pubish_success = $pubnub->publish(array(
    'channel' => $channel,
    'message' => 'Hi. (顶顅Ȓ)'
));
test( $pubish_success[0], 1, 'Publish First Message' );


## ---------------------------------------------------------------------------
## Get History Part 2
## ---------------------------------------------------------------------------
$history = $pubnub->history(array(
    'channel' => $channel,
    'limit'   => 1
));
test( count($history), 1, 'History With 1 Item' );
test( $history[0], 'Hi. (顶顅Ȓ)', 'History Message Text == "Hi. (顶顅Ȓ)"' );


## ---------------------------------------------------------------------------
## PUBLISH 2
## ---------------------------------------------------------------------------
$pubish_success = $pubnub->publish(array(
    'channel' => $channel,
    'message' => 'Hi Again.'
));
test( $pubish_success[0], 1, 'Publish Second Message' );


## ---------------------------------------------------------------------------
## Get History Part 3
## ---------------------------------------------------------------------------
$history = $pubnub->history(array(
    'channel' => $channel,
    'limit'   => 1
));
test( count($history), 1, 'History With 2 Items Limit 1' );
test( $history[0], 'Hi Again.', 'History Message is Text == "Hi Again."' );

$history = $pubnub->history(array(
    'channel' => $channel,
    'limit'   => 2
));
test( count($history), 2, 'History With 2 Item Limit 2' );
test( $history[0], 'Hi. (顶顅Ȓ)', 'History Message Text == "Hi. (顶顅Ȓ)"' );
test( $history[1], 'Hi Again.', 'History Message is Text == "Hi Again."' );

## ---------------------------------------------------------------------------
## Test Timestamp API
## ---------------------------------------------------------------------------
$timestamp = $pubnub->time();
test( $timestamp, true, 'Timestamp API Test: ' . $timestamp );


## ---------------------------------------------------------------------------
## PUBLISH Special Characters
## ---------------------------------------------------------------------------
$craziness      = 'crazy -> ~!@#$%^&*()_+`-=\\][{}\'";:,./<>?顶頴ģŃՃ';
$pubish_success = $pubnub->publish(array(
    'channel' => $craziness,
    'message' => $craziness
));
test( $pubish_success[0], 1, 'Publish Crazy Channel/Message' );

$history = $pubnub->history(array(
    'channel' => $craziness,
    'limit'   => 1
));
test( count($history), 1, 'History With 3 Items Limit 1' );
test( $history[0], $craziness, 'History Message is Crazy' );


## ---------------------------------------------------------------------------
## Test Subscribe
## ---------------------------------------------------------------------------
$message = 1234;

## Generate String to Sign
$string_to_sign = implode( '/', array(
    $publish_key,
    $subscribe_key,
    $secret_key,
    $channel,
    $message
) );
$signature       = $secret_key ? md5($string_to_sign) : '0';
$pubsub_url_test = "http://pubsub.pubnub.com/publish/" .
                   $publish_key . "/" .
                   $subscribe_key . "/" .
                   $signature . "/" .
                   $channel . "/0/" . $message;

echo("\nHIT THIS URL to CONTINUE -> $pubsub_url_test");
echo("\n\nHit CTRL+C to finish.");
echo("\nYou may continue reloading the URL to keep testing.\n\n");
$pubnub->subscribe(array(
    'channel'  => $channel,
    'callback' => function($message) {
        test( $message, 1234, 'Subscribe: ' . $message );
        return true;
    }
));



## ---------------------------------------------------------------------------
## Unit Test Function
## ---------------------------------------------------------------------------
function test( $val1, $val2, $name ) {
    if ($val1 == $val2) echo('PASS: ');
    else                echo('FAIL: ');
    echo("$name\n");
}
?>

