package baseTestSuite.tests {
	
	import com.pubnub.*;
	import org.flexunit.*;
	import org.flexunit.async.*;
	/**
	 * https://github.com/flexunit/flexunit
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	[BeforeClass (order=1)]
	public class InitTest {
		
		public static const SUB_KEY:String = 'demo';
		public static const CHANNEL:String = 'hello_world';
        public var origin:String = 'pubsub.pubnub.com';
        public var pub_key:String = 'demo';
        public var secret_key:String = '';
        public var cipher_key:String = '';
		
		[Test(async, description="[Pn.init] test")]
		public function test() : void {
			//trace(this);
			 var config:Object = {
                publish_key:this.pub_key,
                SUB_KEY:SUB_KEY,
                secret_key:this.secret_key,
                cipher_key:this.cipher_key
            }
			var acyncTimeout:int = 310000;
			var asyncHandler:Function = Async.asyncHandler(this, onInit, acyncTimeout, null, onInitTimeout);
			Pn.instance.addEventListener(PnEvent.INIT, asyncHandler);
			Pn.instance.addEventListener(PnEvent.INIT_ERROR, asyncHandler);
            Pn.init(config);
		}
		
		
		protected function onInit( event:PnEvent, passThroughData:Object = null ):void {
			//trace(this, event.status);
			if (event.type != PnEvent.INIT) {
				Assert.fail(event.type + ':' + event.data);
			}
		}
 
		protected function onInitTimeout( passThroughData:Object ):void {
			 Assert.fail( "Timeout reached before event");	
		}
	}

}