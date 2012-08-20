<?php
    require('../Pubnub.php');

    $pubnub = new Pubnub( 'demo', 'demo' );
    $pubnub->subscribe(array(
        'channel'  => 'extra_cool_channel',
        'callback' => function($message) {
            var_dump($message);
            return true;         ## continue listening
        }
    ));
?>
