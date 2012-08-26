<?php
require_once('AES.class.php');
/**
 * PubNub 3.2 Real-time Push Cloud API
 *
 * @author Leonardo Redmond
 * @author Stephen Blum
 * @package Pubnub
 */
class Pubnub {
    private $ORIGIN        = 'pubsub.pubnub.com';
    private $PUBLISH_KEY   = 'demo';
    private $SUBSCRIBE_KEY = 'demo';
    private $SECRET_KEY    = false;
	private $CIPHER_KEY	   = '';
    private $SSL           = false;
	private $SESSION_UUID  = '';
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
		$cipher_key	   = false,
        $ssl           = false,
        $origin        = false
    ) {
        $this->PUBLISH_KEY   = $publish_key;
        $this->SUBSCRIBE_KEY = $subscribe_key;
        $this->SECRET_KEY    = $secret_key;
		$len = strlen($cipher_key);
		if($len > 0) {
			if ($len > 32) {
				$cipher_key = substr($cipher_key, 0, 32);
			} else {
				$cipher_key = str_pad($cipher_key, 32, "-", STR_PAD_RIGHT);
			}
		}
			   
		$this->CIPHER_KEY	 = $cipher_key;
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
		$message_org = $args['message'];
		if($this->CIPHER_KEY != false) {
			$aes = new AES($this->CIPHER_KEY);
			$encrypted = $aes->encrypt($message_org);
			$message = json_encode(base64_encode($encrypted));
		}else{
			$message = json_encode($message_org);
		}

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

	function here_now($args) {
		if (!($args['channel'])) {
            echo('Missing Channel');
            return false;
        }

        ## Capture User Input
        $channel = $args['channel'];
		
		return $this->_request(array(
			'v2',
            'presence',
            'sub_key',
            $this->SUBSCRIBE_KEY,
            'channel',
            $channel
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
				$message_org = $message;
				if($this->CIPHER_KEY != false) {
					$aes = new AES($this->CIPHER_KEY);
					$encrypted = base64_decode($message_org);
					$decrypted = $aes->decrypt($encrypted);
					$message = json_encode($decrypted);
				}else{
					$message = json_encode($message_org);
				}
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
     * Presence
     *
     * This is BLOCKING.
     * Listen for a message on a channel.
     *
     * @param array $args with channel and message.
     * @return mixed false on fail, array on success.
     */
    function presence($args) {
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
                $channel . '-pnpres',
                '0',
                $timetoken
            ));

            $messages          = $response[0];
            $args['timetoken'] = $response[1];

            ## If it was a timeout
            if (!count($messages)) {
                return $this->presence($args);
            }

            ## Run user Callback and Reconnect if user permits.
            foreach ($messages as $message) {
				$message_org = $message;
				if($this->CIPHER_KEY != false) {
					$aes = new AES($this->CIPHER_KEY);
					$encrypted = base64_decode($message_org);
					$decrypted = $aes->decrypt($encrypted);
					$message = json_encode($decrypted);
					$message = json_encode($message_org);
				}else{
					$message = json_encode($message_org);
				}
				if (!$callback($message)) return;
            }

            ## Keep Listening.
            return $this->presence($args);
        }
        catch (Exception $error) {
            sleep(1);
            return $this->presence($args);
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
		$response = $this->_request(array(
					'history',
					$this->SUBSCRIBE_KEY,
					$channel,
					'0',
					$limit
				));;
		if($this->CIPHER_KEY != false) {
			echo("AESImpl"); echo("\r\n");
			$message = array_values($response);
			$aes = new AES($this->CIPHER_KEY);
			$count = count($message);
			$history = array();
			for ($i = 0; $i < $count; $i++) {
				$encrypted = base64_decode($message[$i]);
				$decrypted = $aes->decrypt($encrypted);
				echo($decrypted); echo("\r\n");
				array_push($history, $decrypted);
			}
			return json_encode($history);
		}else{
			return json_encode($response);
		}		
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
	 * UUID
	 *
	 * UUID generator
	 *
	 * @return UUID
	 */
	function uuid() {
		if (function_exists('com_create_guid') === true)
		{
			return trim(com_create_guid(), '{}');
		}

		return sprintf('%04X%04X-%04X-%04X-%04X-%04X%04X%04X', mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(16384, 20479), mt_rand(32768, 49151), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535));
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
		if($this->SESSION_UUID === '') {
			$this->SESSION_UUID = $this->uuid();
		}
		if(($request[1] === 'presence') || ($request[1] === 'subscribe')) {
			array_push( $request, '?uuid=' . $this->SESSION_UUID );
		}
		
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