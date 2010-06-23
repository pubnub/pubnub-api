<?php

/*
    PubNub Real Time Push APIs and Notifications Framework
    Copyright (c) 2010 Stephen Blum
    http://www.google.com/profiles/blum.stephen

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/**
 * Pubnub Client API
 *
 * PHP 5.2.0+ REQUIRED
 * PHP 5.3.0+ RECOMMENDED
 * For earlier of PHP versions, use CREATE_FUNCTION for callbacks.
 *
 * Client API for interfacing with Pubnub.
 * Publish/Subscribe and History APIs.
 *
 * NOTE: Subscribe API for PHP is BLOCKING.
 *       Your application will hault until a message is received.
 * 
 * USAGE PHP EXAMPLE:
 * ==================
 * More examples in the example folder.

    ## -----------------------------------------
    ## Create Pubnub Client API (INITIALIZATION)
    ## -----------------------------------------
    $pubnub = new Pubnub( 'YOUR-PUBLISH-KEY', 'YOUR-SUBSCRIBE-KEY' );

    ## ----------------------
    ## Send Message (PUBLISH)
    ## ----------------------
    $info = $pubnub->publish(array(
        'channel' => 'hello_world', ## REQUIRED Channel to Send
        'message' => 'Hey World!'   ## REQUIRED Message String/Array
    ));
    echo($info['status']);          ## 200 if successful.

    ## --------------------------
    ## Request Messages (HISTORY)
    ## --------------------------
    $messages = $pubnub->history(array(
        'channel' => 'hello_world',  ## REQUIRED Channel to Send
        'limit'   => 100             ## OPTIONAL Limit Number of Messages
    ));
    var_dump($messages);             ## Prints array of messages.

    ## ----------------------------------
    ## Receive Message (SUBSCRIBE)
    ## PHP 5.3.0 ONLY. THIS WILL BLOCK!!!
    ## THIS WILL BLOCK. PHP 5.3.0 ONLY!!!
    ## ----------------------------------
    $pubnub->subscribe(array(
        'channel'  => 'hello_world',        ## REQUIRED Channel to Listen
        'callback' => function($message) {  ## REQUIRED Callback With Response
            var_dump($message);  ## Print Message
            return true;         ## Keep listening (return false to stop)
        }
    ));

    ## ----------------------------------
    ## Receive Message (SUBSCRIBE)
    ## PHP 5.2.0 ONLY. THIS WILL BLOCK!!!
    ## THIS WILL BLOCK. PHP 5.2.0
    ## ----------------------------------
    $pubnub->subscribe(array(
        'channel'  => 'hello_world',        ## REQUIRED Channel to Listen
        'callback' => create_function(      ## REQUIRED PHP 5.2.0 Method
            '$message',
            'var_dump($message); return true;'
        )
    ));

 * More Examples in the examples folder.
 *
 * @author Stephen Blum
 * @package Pubnub
 */

class Pubnub {
    private static $ORIGIN        = 'http://pubnub-prod.appspot.com';
    private static $LIMIT         = 1700;
    private static $PUBLISH_KEY   = '';
    private static $SUBSCRIBE_KEY = '';

    /**
     * Pubnub
     *
     * Init the Pubnub Client API
     *
     * @param string $publish_key required key to send messages.
     * @param string $subscribe_key required key to receive messages.
     */
    function Pubnub( $publish_key, $subscribe_key ) {
        self::$PUBLISH_KEY   = $publish_key;
        self::$SUBSCRIBE_KEY = $subscribe_key;
    }

    /**
     * Publish
     *
     * Send a message to a channel.
     *
     * @param array $args with channel and message.
     * @return mixed false on fail, array on success.
     */
    function publish($args) {
        ## Fail if bad input.
        if (!(
            $args['channel'] &&
            $args['message']
        )) {
            echo('Missing Channel or Message');
            return false;
        }

        ## Capture User Input
        $channel = self::$SUBSCRIBE_KEY . '/' . $args['channel'];
        $message = json_encode($args['message']);

        ## Fail if message too long.
        if (strlen($message) > self::$LIMIT) {
            echo('Message TOO LONG (' . self::$LIMIT . ' LIMIT)');
            return false;
        }

        ## Send Message
        $response = $this->_request( self::$ORIGIN . '/pubnub-publish', array(
            'publish_key' => self::$PUBLISH_KEY,
            'channel'     => $channel,
            'message'     => $message
        ) );

        return $response;
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
        ## Fail if missing channel
        if (!$args['channel']) {
            echo("Missing Channel.\n");
            return false;
        }

        ## Fail if missing callback
        if (!$args['callback']) {
            echo("Missing Callback.\n");
            return false;
        }

        ## Capture User Input
        $channel   = self::$SUBSCRIBE_KEY . '/' . $args['channel'];
        $callback  = $args['callback'];
        $timetoken = isset($args['timetoken']) ? $args['timetoken'] : '0';
        $server    = isset($args['server'])    ? $args['server']    : false;
        $continue  = true;

        ## Find Server
        if (!$server) {
            $resp_for_server = $this->_request(
                self::$ORIGIN . '/pubnub-subscribe', array(
                    'channel' => $channel
                )
            );

            if (!isset($resp_for_server['server'])) {
                print_r($args);
                echo("Incorrect API Keys *OR* Out of PubNub Credits\n");
                echo("Account API Keys http://www.pubnub.com/account\n");
                echo("Buy Credits http://www.pubnub.com/account-buy-credit\n");
                return false;
            }

            $server = $resp_for_server['server'];
            $args['server'] = $server;
        }

        try {
            ## Wait for Message
            $response = $this->_request( 'http://' . $server, array(
                'channel'   => $channel,
                'timetoken' => $timetoken
            ) );

            ## If we lost a server connection.
            if (!isset($response['messages'][0])) {
                unset($args['server']);
                return $this->subscribe($args);
            }

            ## If it was a timeout
            if ($response['messages'][0] == 'xdr.timeout') {
                $args['timetoken'] = $response['timetoken'];
                return $this->subscribe($args);
            }

            ## Run user Callback and Reconnect if user permits.
            foreach ($response['messages'] as $message) {
                $continue = $continue && $callback($message);
            }

            ## If okay to keep listening.
            if ($continue) {
                $args['timetoken'] = $response['timetoken'];
                return $this->subscribe($args);
            }
        }
        catch (Exception $error) {
            unset($args['server']);
            return $this->subscribe($args);
        }

        ## Done listening.
        return true;
    }

    /**
     * History
     *
     * Load history from a channel.
     *
     * Messages remain in history for up to 30 days.
     * Up to 100 messages returnable.
     * Messages order by most recent first.
     *
     * @param array $args with 'channel' and 'limit'.
     * @return mixed false on fail, array on success.
     */
    function history($args) {
        ## Fail if bad input.
        if (!$args['channel']) {
            echo('Missing Channel');
            return false;
        }

        ## Capture User Input
        $channel = self::$SUBSCRIBE_KEY . '/' . $args['channel'];
        $limit   = +$args['limit'] ? +$args['limit'] : 10;

        ## Get History
        $response = $this->_request( self::$ORIGIN . '/pubnub-history', array(
            'channel' => $channel,
            'limit'   => $limit
        ) );

        return $response['messages'];
    }

    /**
     * Request URL
     *
     * @param string $request url.
     * @param array $args of key/vals.
     * @return object from response.
     */
    private function _request( $request, $args ) {
        ## Expecting JSONP
        $args['unique'] = time();

        ## Format URL Params
        $params = array();
        foreach ($args as $key => $val)
            $params[] = urlencode($key) .'='. urlencode($val);

        ## Append Params
        $request .= '?' . implode( '&', $params );

        ## Send Request Expecting JSONP Response
        $response = preg_replace(
            '|^this\[[^\]]+\]\((.+?)\)$|', '$1',
            file_get_contents($request)
        );

        return json_decode( $response, true );
    }
}


?>
