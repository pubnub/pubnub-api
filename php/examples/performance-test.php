<?php
    ## Require Pubnub API
    echo("Loading Pubnub.php Class\n");
    require('../Pubnub.php');

    ## -----------------------------------------
    ## Create Pubnub Client API (INITIALIZATION)
    ## -----------------------------------------
    echo("Creating new Pubnub Client API\n");
    $pubnub = new Pubnub();

    ## ----------------------
    ## Send Message (PUBLISH)
    ## ----------------------
    echo("Sending a message with Publish Function\n");

    $start   = microtime(1);
    $tries   = 50.0;
    $success = 0;
    $failes  = 0;
    $sent    = 0;

    while ($sent++ < $tries) {
        $info = $pubnub->publish(array(
            'channel' => 'performance-test',
            'message' => 'hi'
        ));

        $info[0] && $success++;
        $info[0] || $failes++;

        $sent % (int)($tries/50) || print('.');
    }

    ## DONE
    $end = microtime(1);
    print("\n");
    print_r(array(
        'total successful publishes'      => $success,
        'total failed publishes'          => $failes,
        'total sequential publishes sent' => $tries,
        'successful delivery rate'        => '%' . ($success / $tries * 100),
        'failure delivery rate'           => '%' . ($failes / $tries * 100),
        'total test duration in seconds'  => $end - $start,
        'average delivery in seconds'     => ($end - $start) / $tries,
        'publishes per second'            => $tries / ($end - $start),
        'start'                           => $start,
        'end'                             => $end
    ));

?>
