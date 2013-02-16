package flexUnitTests
{
	import com.pubnub.Pn;
	import com.pubnub.PnCrypto;
	
	import flexunit.framework.Assert;
	
	import mx.controls.Alert;

	public class TestPnCrypto
	{		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testEncyption_single():void
		{
			var cipher_key:String = "enigma";
			var plain_text:String = "yay!";
			var cipher_text:String = "q/xJqqN6qbiZMXYmiQC1Fw==";
			Assert.assertEquals(PnCrypto.encrypt(cipher_key, plain_text), cipher_text);
		}
		
		[Test]
		public function testEncyption_longerText():void
		{
			var cipher_key:String = "enigma";
			var plain_text:String = "Pubnub Messaging API 2";
			var cipher_text:String = "dyeYNg3Ngd800QkdA0pSmt8OvP22zLfuvcnlkGLvIIU=";
			Assert.assertEquals(PnCrypto.encrypt(cipher_key, plain_text), cipher_text);
		}
		
		[Test]
		public function testEncyption_JasonText():void
		{
			var cipher_key:String = "enigma";
			var plain_text:String = '{"foo": {"bar": "foobar"}}';
			var cipher_text:String = "TTSJuy0ocG0qx8qrEJCPLPLWIhYgbxcPkB/adFr+Nos=";
			Assert.assertEquals(PnCrypto.encrypt(cipher_key, plain_text), cipher_text);
		}
		
		[Test]
		public function testEncyption_JasonTextLonger():void
		{
			var cipher_key:String = "enigma";
			var plain_text:String = '{"this stuff": {"can get": "complicated!"}}';
			var cipher_text:String = "vFBqDLBkQKa5z3btZVoIgfywSp0QwTg3DFRH8QMdejIK7Vjf3nSxnLAxWzGQI+Qb";
			Assert.assertEquals(PnCrypto.encrypt(cipher_key, plain_text), cipher_text);
		}
		
		[Test]
		public function testEncyption_UniCode():void
		{
			var cipher_key:String = "enigma";
			var plain_text:String = '漢語';
			var cipher_text:String = "pgoJayUNzvZ8bDf8IZ1L1g==";
			Assert.assertEquals(PnCrypto.encrypt(cipher_key, plain_text), cipher_text);
		}
		
		[Test]
		public function testDecyption_single():void
		{
			var cipher_key:String = "enigma";
			var plain_text:String = "yay!";
			var cipher_text:String = PnCrypto.encrypt(cipher_key, plain_text);
			Assert.assertEquals(PnCrypto.decrypt(cipher_key,cipher_text), plain_text);
		}	
		
		[Test]
		public function testDecyption_longerText():void
		{
			var cipher_key:String = "enigma";
			var plain_text:String = "Pubnub Messaging API 2";
			var cipher_text:String = PnCrypto.encrypt(cipher_key, plain_text);
			Assert.assertEquals(PnCrypto.decrypt(cipher_key,cipher_text), plain_text);
		}
		
		[Test]
		public function testDecyption_JasonText():void
		{
			var cipher_key:String = "enigma";
			var plain_text:String = '{"foo": {"bar": "foobar"}}';
			var cipher_text:String = PnCrypto.encrypt(cipher_key, plain_text);
			Assert.assertEquals(PnCrypto.decrypt(cipher_key,cipher_text), plain_text);
		}
		
		[Test]
		public function testDecyption_UniCode():void
		{
			var cipher_key:String = "enigma";
			var plain_text:String = '漢語';
			var cipher_text:String = PnCrypto.encrypt(cipher_key, plain_text);
			Assert.assertEquals(PnCrypto.decrypt(cipher_key,cipher_text), plain_text);
		}
		
		[Test]
		public function testDecyption_JasonTextLonger():void
		{
			var cipher_key:String = "enigma";
			var plain_text:String = '{"this stuff": {"can get": "complicated!"}}';
			var cipher_text:String = PnCrypto.encrypt(cipher_key, plain_text);
			Assert.assertEquals(PnCrypto.decrypt(cipher_key,cipher_text), plain_text);
		}
		
		
		
		
	}
}