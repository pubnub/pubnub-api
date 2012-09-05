<?php
    require('../Pubnub.php');

    $pubnub = new Pubnub( 'demo', 'demo' );
    $pubnub->publish(array(
        'channel' => 'my_test_channel',
        'message' => array( 'some_text' => 'hello!' )
    ));
?>
