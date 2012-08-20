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
    php ./chat-command-line.php PUBLISH-KEY SUBSCRIBE-KEY

");
        exit();
    }

    ## Require Pubnub API
    echo("Connecting...\n");
    echo("(Press ^C to exit)\n");
    require('../Pubnub.php');

    ## -----------------------------------------
    ## Create Pubnub Client API (INITIALIZATION)
    ## -----------------------------------------
    $pubnub = new Pubnub( $publish_key, $subscribe_key );

    ## ----------------------------------------
    ## Send/Recieve Message (PUBLISH/SUBSCRIBE)
    ## ----------------------------------------
    $pid = pcntl_fork();

    if ($pid == -1) {

        ## Fail :'(
        die('Could not fork. Get newer version of PHP!');

    } else if ($pid) {

        ## Get Username
        echo("ENTER USERNAME: ");
        $user = trim(fgets(STDIN));
        $user = $user ? $user : 'chad';
        echo("YOUR NAME IS $user\n\n");

        ## Listen for Messages From User
        while (true) {
            $text = trim(fgets(STDIN));
            $pubnub->publish(array(
                'channel' => 'php_chat',
                'message' => array(
                    'text' => $text,
                    'from' => $user
                )
            ));
        }

        ## Protect against Zombie children
        pcntl_wait($status); 

    }
    else {
        ## Launch Subscriber
        system("php ./chat-subscribe-helper.php $publish_key $subscribe_key");
    }

?>
