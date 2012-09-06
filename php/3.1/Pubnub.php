<?php

/**
 * PubNub 3.0 Real-time Push Cloud API
 *
 * @author Stephen Blum
 * @package Pubnub
 */
class Pubnub {
    private $ORIGIN        = 'pubsub.pubnub.com';
    private $PUBLISH_KEY   = 'demo';
    private $SUBSCRIBE_KEY = 'demo';
    private $SECRET_KEY    = false;
    private $SSL           = false;

    /**
     * Pubnub
     *
     * Init the Pubnub Client API
     *
     * @param string $publish_key required key to send messages.
     * @param string $subscribe_key required key to receive messages.
     * @param string $secret_key optional key to sign messages.
     * @param string $origin optional setting for cloud origin.
     * @param boolean $ssl required for 2048 bit encrypted messages.
     */
    function Pubnub(
        $publish_key   = 'demo',
        $subscribe_key = 'demo',
        $secret_key    = false,
        $ssl           = false,
        $origin        = false
    ) {
        $this->PUBLISH_KEY   = $publish_key;
        $this->SUBSCRIBE_KEY = $subscribe_key;
        $this->SECRET_KEY    = $secret_key;
        $this->SSL           = $ssl;

        if ($origin) $this->ORIGIN = $origin;

        if ($ssl) $this->ORIGIN = 'https://' . $this->ORIGIN;
        else      $this->ORIGIN = 'http://'  . $this->ORIGIN;
    }

    /**
     * Publish
     *
     * Send a message to a channel.
     *
     * @param array $args with channel and message.
     * @return array success information.
     */
    function publish($args) {
        ## Fail if bad input.
        if (!($args['channel'] && $args['message'])) {
            echo('Missing Channel or Message');
            return false;
        }

        ## Capture User Input
        $channel = $args['channel'];
        $message = json_encode($args['message']);

        ## Generate String to Sign
        $string_to_sign = implode( '/', array(
            $this->PUBLISH_KEY,
            $this->SUBSCRIBE_KEY,
            $this->SECRET_KEY,
            $channel,
            $message
        ) );

        ## Sign Message
        $signature = $this->SECRET_KEY ? md5($string_to_sign) : '0';

        ## Send Message
        return $this->_request(array(
            'publish',
            $this->PUBLISH_KEY,
            $this->SUBSCRIBE_KEY,
            $signature,
            $channel,
            '0',
            $message
        ));
    }

    /**
     * Subscribe
     *
     * This is BLOCKING.
     * Listen for a message on a channel.
     *
     * @param array $args with channel and message.
     * @return mixed false on fail, array on success.
     */
    function subscribe($args) {
        ## Capture User Input
        $channel   = $args['channel'];
        $callback  = $args['callback'];
        $timetoken = isset($args['timetoken']) ? $args['timetoken'] : '0';

        ## Fail if missing channel
        if (!$channel) {
            echo("Missing Channel.\n");
            return false;
        }

        ## Fail if missing callback
        if (!$callback) {
            echo("Missing Callback.\n");
            return false;
        }

        ## Begin Recusive Subscribe
        try {
            ## Wait for Message
            $response = $this->_request(array(
                'subscribe',
                $this->SUBSCRIBE_KEY,
                $channel,
                '0',
                $timetoken
            ));

            $messages          = $response[0];
            $args['timetoken'] = $response[1];

            ## If it was a timeout
            if (!count($messages)) {
                return $this->subscribe($args);
            }

            ## Run user Callback and Reconnect if user permits.
            foreach ($messages as $message) {
                if (!$callback($message)) return;
            }

            ## Keep Listening.
            return $this->subscribe($args);
        }
        catch (Exception $error) {
            sleep(1);
            return $this->subscribe($args);
        }
    }

    /**
     * History
     *
     * Load history from a channel.
     *
     * @param array $args with 'channel' and 'limit'.
     * @return mixed false on fail, array on success.
     */
    function history($args) {
        ## Capture User Input
        $limit   = +$args['limit'] ? +$args['limit'] : 10;
        $channel = $args['channel'];

        ## Fail if bad input.
        if (!$channel) {
            echo('Missing Channel');
            return false;
        }

        ## Get History
        return $this->_request(array(
            'history',
            $this->SUBSCRIBE_KEY,
            $channel,
            '0',
            $limit
        ));
    }

    /**
     * Time
     *
     * Timestamp from PubNub Cloud.
     *
     * @return int timestamp.
     */
    function time() {
        ## Get History
        $response = $this->_request(array(
            'time',
            '0'
        ));

        return $response[0];
    }

    /**
     * Request URL
     *
     * @param array $request of url directories.
     * @return array from JSON response.
     */
    private function _request($request) {
        $request = array_map( 'Pubnub::_encode', $request );
        array_unshift( $request, $this->ORIGIN );

        $ctx = stream_context_create(array(
            'http' => array( 'timeout' => 200 ) 
        ));

        return json_decode( @file_get_contents(
            implode( '/', $request ), 0, $ctx
        ), true );
    }

    /**
     * Encode
     *
     * @param string $part of url directories.
     * @return string encoded string.
     */
    private static function _encode($part) {
        return implode( '', array_map(
            'Pubnub::_encode_char', str_split($part)
        ) );
    }

    /**
     * Encode Char
     *
     * @param string $char val.
     * @return string encoded char.
     */
    private static function _encode_char($char) {
        if (strpos( ' ~`!@#$%^&*()+=[]\\{}|;\':",./<>?', $char ) === false)
            return $char;
        return rawurlencode($char);
    }
}


?>