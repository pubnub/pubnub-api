<?php

    ## Capture Publish and Subscribe Keys from Command Line
    $publish_key   = isset($argv[1]) ? $argv[1] : false;
    $subscribe_key = isset($argv[2]) ? $argv[2] : false;

    # Print usage if missing info.
    if (!($publish_key && $subscribe_key)) {
echo("
    ==============
    EXAMPLE USAGE:
    ==============
    php ./publish-example.php PUBLISH-KEY SUBSCRIBE-KEY

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
    echo("Listening for Messages (Press ^C to stop)\n");
    $pubnub->subscribe(array(
        'channel'  => 'hello_world',        ## REQUIRED Channel to Listen
        'callback' => function($response) { ## REQUIRED Callback With Response
            var_dump($response); ## Print Response
            return true;         ## Keep listening (return false to stop)
        }
    ));


?>

