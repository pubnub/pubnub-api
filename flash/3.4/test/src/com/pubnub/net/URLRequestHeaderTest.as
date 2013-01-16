package com.pubnub.net {
	import flexunit.framework.Assert;
	/**
	 * Tests for URLRequestHeader
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class URLRequestHeaderTest {
		
		[Test(description="KEEP_ALIVE")]
		public function keepAlive() : void { 
			var header:URLRequestHeader = new URLRequestHeader();
			Assert.assertEquals(
				header.getValue(URLRequestHeader.CONNECTION), 
				URLRequestHeader.KEEP_ALIVE);
		}
		
		[Test(description="IS_EMPTY")]
		public function isEmpty() : void { 
			var header:URLRequestHeader = new URLRequestHeader();
			Assert.assertEquals(header.isEmpty, false);
			trace(header.content);
		}
		
		[Test(description="CONTENT")]
		public function content() : void {
			var testStr:String = 'Connection: Keep-Alive\r\n'
			var header:URLRequestHeader = new URLRequestHeader();
			Assert.assertEquals(header.content, testStr);
		}
	}
}