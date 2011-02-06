<?php

    ## Capture Publish and Subscribe Keys from Command Line
    $publish_key   = isset($argv[1]) ? $argv[1] : false;
    $subscribe_key = isset($argv[2]) ? $argv[2] : false;
    $message       = isset($argv[3]) ? $argv[3] : false;
    $channel_name  = isset($argv[4]) ? $argv[4] : 'hello_world2';

    ## Print usage if missing info.
    if (!($publish_key && $subscribe_key && $message)) {
echo("
    ==============
    EXAMPLE USAGE:
    ==============
    php ./publish-example.php PUBLISH-KEY SUBSCRIBE-KEY 'ANY MESSAGE HERE' 'CHANNEL_NAME'
    php ./publish-example.php demo demo 'Hey what is up?' 'hello_world_channel'

");
        exit();
    }

    ## Require Pubnub API
    echo("Loading Pubnub.php Class\n");
    require('../Pubnub.php');

    ## -----------------------------------------
    ## Create Pubnub Client API (INITIALIZATION)
    ## -----------------------------------------
    echo("Creating new Pubnub Client API\n");
    $pubnub = new Pubnub( $publish_key, $subscribe_key );

    ## ----------------------
    ## Send Message (PUBLISH)
    ## ----------------------
    echo("Sending a message with Publish Function\n");
    $message = array( 'text' => $message );
    $info = $pubnub->publish(array(
        'channel' => $channel_name,
        'message' => $message
    ));

    echo("Response:\n");
    print_r(array( 'published' => $message/*, 'success' => $info*/ ));

?>
