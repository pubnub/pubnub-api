<?php

    ## Capture Publish and Subscribe Keys from Command Line
    $publish_key   = "demo";
    $subscribe_key = "demo";
    $channel_name  = "while-loop-channel";

    ## Require Pubnub API
    echo("Loading Pubnub.php Class\n");
    require('../Pubnub.php');

    ## -----------------------------------------
    ## Create Pubnub Client API (INITIALIZATION)
    ## -----------------------------------------
    echo("Creating new Pubnub Client API\n");
    $pubnub = new Pubnub(
        $publish_key,
        $subscribe_key,
        '',
        false,
        'pubsub.pubnub.com'
    );

    ## ----------------------
    ## Send Message (PUBLISH)
    ## ----------------------
    echo("Sending a message with Publish Function\n");

    $start   = microtime(1);
    $tries   = 100.0;
    $i       = 0;
    $message = json_decode('{"id":"130051906964946945","type":"newtopic","created_at":"Fri Oct 28 22:42:45 +0000 2011","current_time":1319841837,"posted_at":1319841837,"reply_count":0,"from_user":"WeDemo","from_user_name":"Demo","profile_image_url":"http:\/\/a1.twimg.com\/profile_images\/1568426943\/Screen_shot_2011-10-01_at_1.40.42_PM_normal.png","tweettext":"#uynb5598 ggttrru  <a href=\"http:\/\/t.co\/QkKBpjRS\" rel=\"nofollow\" target=\"_blank\">http:\/\/t.co\/QkKBpjRS<\/a>","bubble_color":"","product_shorturl":null,"product_longurl":null,"media_type":"YFrog","message_video_url":null,"message_image_id":"21067","message_o_image_url":"http:\/\/c797842.r42.cf2.rackcdn.com\/TIKZuz.jpg","message_l_image_url":"http:\/\/c797844.r44.cf2.rackcdn.com\/TIKZuz.jpg","message_t_image_url":"http:\/\/c797843.r43.cf2.rackcdn.com\/TIKZuz.jpg","message_f_image_url":null,"message_tvt_image_url":null,"message_tvl_image_url":null}');#array( 'text' => $message );

    while ($i++ < $tries) {
        $pubnub->publish(array(
            'channel' => $channel_name,
            'message' => $message
        ));
    }

    ## DONE
    $end = microtime(1);
    print_r(array(
        'total publishes sent' => $tries,
        'start' => $start,
        'end' => $end,
        'total test duration in seconds' => $end - $start,
        'average delivery in seconds' => ($end - $start) / $tries,
        'publishes per second' => $tries / ($end - $start)
    ));

?>
