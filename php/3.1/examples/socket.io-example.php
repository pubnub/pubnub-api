<?php

    //
    // Socket.IO JavaScript Example Code
    //
    /*
        var pubnub_setup = {
            channel       : 'PUBNUB_CHANNEL_HERE',
            publish_key   : 'demo',
            subscribe_key : 'demo',
            ssl           : false
        };

        var socket = io.connect( 'http://pubsub.pubnub.com/THREAD_123', pubnub_setup );

        socket.on( 'EVENT', function(data) {
            console.log(data);
        } );
    */

    //
    // Send Data to Socket.IO from PHP
    //
    require('../Pubnub.php');

    ## -----------------------------------------
    ## Create Pubnub Client API (INITIALIZATION)
    ## -----------------------------------------
    $publish_key   = 'demo';
    $subscribe_key = 'demo';
    $pubnub = new Pubnub( $publish_key, $subscribe_key );

    ## ----------------------
    ## Send Message (PUBLISH)
    ## ----------------------
    $info = $pubnub->publish(array(
        'channel' => 'PUBNUB_CHANNEL_HERE',
        'message' => array(
            'name' => 'EVENT',       ## emit( 'event-name', ... )
            'ns'   => 'THREAD_123',  ## chat, news, feed, etc.
            'data' => {'msg':'Hi'}   ## object to be received.
        )
    ));

    print_r($info);

?>
