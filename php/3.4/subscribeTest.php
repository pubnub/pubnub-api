<?php
require_once('Pubnub.php');

$pubnub = new Pubnub( 'demo', 'demo', false , false, false );
$pubnub->subscribe(array(
    'channel'  => 'testChannel',
    'callback' => function($message) {
        $fp = fopen('subscribeOut.txt', 'w');
        fwrite($fp, serialize($message));
        fclose($fp);
        exit;
    }
));