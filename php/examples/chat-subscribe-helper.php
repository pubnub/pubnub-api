<?php

    ## Capture Publish and Subscribe Keys from Command Line
    $publish_key   = isset($argv[1]) ? $argv[1] : false;
    $subscribe_key = isset($argv[2]) ? $argv[2] : false;

    ## Require Pubnub API
    require('../Pubnub.php');

    ## -----------------------------------------
    ## Create Pubnub Client API (INITIALIZATION)
    ## -----------------------------------------
    $pubnub = new Pubnub( $publish_key, $subscribe_key );

    ## ----------------------
    ## Send Message (PUBLISH)
    ## ----------------------
    $pubnub->subscribe(array(
        'channel'  => 'php_chat',           ## REQUIRED Channel to Listen
        'callback' => function($message) {  ## REQUIRED Callback With Response
            ## Print Message
            echo(
                "["              .
                date('H:i:s')    .
                "] <"            .
                $message['from'] .
                "> "             .
                $message['text'] .
                "\r\n"
            );

            ## Keep listening (return false to stop)
            return true;
        }
    ));

?>

