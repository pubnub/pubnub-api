<?php
require_once('Pubnub.php');

$pubnub = new Pubnub( 'demo', 'demo', false , false, false );
$pubnub->presence(array(
    'channel'  => 'testChannel',
    'callback' => function($message) {
        $fp = fopen('presenceOut.txt', 'w');
        fwrite($fp, serialize($message));
        fclose($fp);
        exit;
    }
));