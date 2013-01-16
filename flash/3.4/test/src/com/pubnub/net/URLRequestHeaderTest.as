package com.pubnub.net {
	import flexunit.framework.*;
	/**
	 * Tests for URLRequestHeader
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class URLRequestHeaderTest {
		
		private var header:URLRequestHeader;
		
		[Before]
		public function setUp():void {
			header = new URLRequestHeader();
		}
		
		[Test(description="KEEP_ALIVE")]
		public function keepAlive() : void { 
			Assert.assertEquals(
				header.getValue(URLRequestHeader.CONNECTION), 
				URLRequestHeader.KEEP_ALIVE);
		}
		
		[Test(description="IS_EMPTY")]
		public function isEmpty() : void { 
			Assert.assertEquals(header.isEmpty, false);
		}
		
		[Test(description="CONTENT")]
		public function content() : void {
			var testStr:String = 'Connection: Keep-Alive\r\n'
			Assert.assertEquals(header.content, testStr);
		}
	}
}