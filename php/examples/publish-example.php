<?php

    ## Capture Publish and Subscribe Keys from Command Line
    $publish_key   = isset($argv[1]) ? $argv[1] : false;
    $subscribe_key = isset($argv[2]) ? $argv[2] : false;
    $message       = isset($argv[3]) ? $argv[3] : false;

    ## Print usage if missing info.
    if (!($publish_key && $subscribe_key && $message)) {
echo("
    ==============
    EXAMPLE USAGE:
    ==============
    php ./publish-example.php PUBLISH-KEY SUBSCRIBE-KEY 'ANY MESSAGE HERE'
    php ./publish-example.php PUBLISH-KEY SUBSCRIBE-KEY 'Hey what is up?'

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
    $info = $pubnub->publish(array(
        'channel' => 'hello_world2',
        'message' => $message
    ));

    echo("Response:\n");
    var_dump($info);

?>
