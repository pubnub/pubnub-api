<?php

include('Pubnub.php');

class PubnubTest extends PHPUnit_Framework_TestCase
{
	protected $pubnub;
	public static $channel = 'testChannel';
	static $configs = array('default'   => array('publish_key' => 'demo', 'subscribe_key' => 'demo', 'secret_key' => false, 'cipher_key' => false, 'ssl_on' => false),
							'cipher'    => array('publish_key' => 'demo', 'subscribe_key' => 'demo', 'secret_key' => false, 'cipher_key' => 'enigma', 'ssl_on' => false),
							'ssl'       => array('publish_key' => 'demo', 'subscribe_key' => 'demo', 'secret_key' => false, 'cipher_key' => false, 'ssl_on' => true),
							'cipherSsl' => array('publish_key' => 'demo', 'subscribe_key' => 'demo', 'secret_key' => false, 'cipher_key' => 'enigma', 'ssl_on' => true));


	private function getObject($config)
	{
		return new Pubnub($config['publish_key'],$config['subscribe_key'],$config['secret_key'],$config['cipher_key'],$config['ssl_on']);
	}


	public static function setUpBeforeClass()
    {
        exec( 'php subscribeTest.php > /dev/null &', $Out );
        exec( 'php presenceTest.php > /dev/null &', $Out );
    }


## ------------------ ENCRIPTION TEST ------------------ ##
	public function testEncryption(){
		$plain_text = "yay!";
		$cipher_text = "q/xJqqN6qbiZMXYmiQC1Fw==";

		$this->assertEquals( decrypt($cipher_text, self::$configs['cipher']['cipher_key']), $plain_text );
		$this->assertEquals( encrypt($plain_text,  self::$configs['cipher']['cipher_key']), $cipher_text );
	}


## ------------------ HERE NOW TEST ------------------ ##
	/**
     * @dataProvider configsProvider
     */
	public function testHereNow($config)
	{
		$pubnub = $this->getObject($config);
		$here_now = $pubnub->here_now( array(
											 'channel' => self::$channel
											));
		$this->assertNotCount( 0, $here_now['uuids'] );
	}


## ------------------ PUBLISH TEST ------------------ ##
	/**
     * @dataProvider publishProvider
     * @depends testHereNow
     */
	public function testPublish($config, $message, $statusResponse, $msgResponse, $channel = false)
	{
		$pubnub = $this->getObject($config);
		$publish_success = $pubnub->publish( array(
													 'channel' => $channel ? $channel : self::$channel,
													 'message' => $message 
													));
		$this->assertEquals( $publish_success[0], $statusResponse);
		$this->assertEquals( $publish_success[1], $msgResponse);
	}

	public function publishProvider()
	{
		return array(
					// NoCipher, NoSsl
					array(self::$configs['default'],'Hello from PHP!', 1, 'Sent'),
					array(self::$configs['default'],'漢語', 1, 'Sent'),
					array(self::$configs['default'],array( 'this stuff' => array( 'can get' => 'complicated!' )), 1, 'Sent'),
					array(self::$configs['default'],array(), 1, 'Sent'),
					array(self::$configs['default'],str_repeat('a', 2000), 0, 'Message Too Large'),
					// Cipher, NoSsl
					array(self::$configs['cipher'],'Pubnub Messaging API 1', 1, 'Sent'),
					array(self::$configs['cipher'],'漢語', 1, 'Sent'),
					array(self::$configs['cipher'],array( 'this stuff' => array( 'can get' => 'complicated!' )), 1, 'Sent'),
					array(self::$configs['cipher'],array(), 1, 'Sent'),
					array(self::$configs['cipher'],str_repeat('a', 2000), 0, 'Message Too Large'),
					// NoCipher, Ssl
					array(self::$configs['ssl'],'Pubnub Messaging API 1', 1, 'Sent'),
					array(self::$configs['ssl'],'漢語', 1, 'Sent'),
					array(self::$configs['ssl'],array( 'this stuff' => array( 'can get' => 'complicated!' )), 1, 'Sent'),
					array(self::$configs['ssl'],array(), 1, 'Sent'),
					array(self::$configs['ssl'],str_repeat('a', 2000), 0, 'Message Too Large'),
					// Cipher, Ssl
					array(self::$configs['cipherSsl'],'Pubnub Messaging API 1', 1, 'Sent'),
					array(self::$configs['cipherSsl'],'漢語', 1, 'Sent'),
					array(self::$configs['cipherSsl'],array( 'this stuff' => array( 'can get' => 'complicated!' )), 1, 'Sent'),
					array(self::$configs['cipherSsl'],array(), 1, 'Sent'),
					array(self::$configs['cipherSsl'],str_repeat('a', 2000), 0, 'Message Too Large'),
					// Message to presence
					array(self::$configs['default'],'Test Presence', 1, 'Sent', self::$channel.'-pnpres'),
					);
	}


## ------------------ HISTORY TEST ------------------ ##
	/**
     * @dataProvider historyProvider
     */
	public function testHistory($config, $limit)
	{
		$pubnub = $this->getObject($config);
		$history = $pubnub->history( array(
											 'channel' => self::$channel,
											 'limit'   => $limit 
											));
		$this->assertNotEmpty( $history );
		$this->assertGreaterThanOrEqual( count($history), $limit );
	}

	public function historyProvider()
	{
		return array(
					// NoCipher, NoSsl
					array(self::$configs['default'],1),
					array(self::$configs['default'],2),
					array(self::$configs['default'],3),
					array(self::$configs['default'],4),
					array(self::$configs['default'],5),
					// Cipher, NoSsl
					array(self::$configs['cipher'],1),
					array(self::$configs['cipher'],2),
					array(self::$configs['cipher'],3),
					array(self::$configs['cipher'],4),
					array(self::$configs['cipher'],5),
					// NoCipher, Ssl
					array(self::$configs['ssl'],1),
					array(self::$configs['ssl'],2),
					array(self::$configs['ssl'],3),
					array(self::$configs['ssl'],4),
					array(self::$configs['ssl'],5),
					// Cipher, Ssl
					array(self::$configs['cipherSsl'],1),
					array(self::$configs['cipherSsl'],2),
					array(self::$configs['cipherSsl'],3),
					array(self::$configs['cipherSsl'],4),
					array(self::$configs['cipherSsl'],5)
					);
	}


## ------------------ DETAILED HISTORY TEST ------------------ ##
	/**
     * @dataProvider historyProvider
     */
	public function testDetailedHistory($config, $count)
	{
		$pubnub = $this->getObject($config);
		$history = $pubnub->detailedHistory( array(
											 'channel' => self::$channel,
											 'count'   => $count,
											 'end'	   => '13466530169226760'
											));
		$this->assertNotEmpty( $history );
		$this->assertGreaterThanOrEqual( count($history), $count );
	}


## ------------------ TIME TEST ------------------ ##
	/**
     * @dataProvider configsProvider
     */
	public function testTime($config)
	{
		$pubnub = $this->getObject($config);
		$time = $pubnub->time();
		$this->assertTrue( is_integer($time) && $time );
	}


	public function configsProvider()
	{
		return array(
					// NoCipher, NoSsl
					array(self::$configs['default']),
					array(self::$configs['cipher']),
					array(self::$configs['ssl']),
					array(self::$configs['cipherSsl'])
					);
	}


## ------------------ SUBSCRIBE TEST ------------------ ##
	/**
     * @depends testPublish
     */
	public function testSubscribe()
	{
		$this->assertTrue( is_array($subs = unserialize(file_get_contents('subscribeOut.txt'))) );
		$this->assertNotEmpty( $subs );
		unlink('subscribeOut.txt');
	}


## ------------------ SUBSCRIBE TEST ------------------ ##
	/**
     * @depends testPublish
     */
	public function testPresenceO()
	{
		$this->assertTrue( is_array($subs = unserialize(file_get_contents('presenceOut.txt'))) );
		$this->assertNotEmpty( $subs );
		unlink('presenceOut.txt');
	}

}