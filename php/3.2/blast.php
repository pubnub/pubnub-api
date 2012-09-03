<?php
require_once('Pubnub.php');

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
$ssl_on        = isset($argv[4]);

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

while ( true ) {
    $publish_success = $pubnub->publish(array(
        'channel' => $channel,
        'message' => 'Hello from PHP!'
    ));
    echo($publish_success[0] . $publish_success[1]);
    echo "\r\n";
}


?>
