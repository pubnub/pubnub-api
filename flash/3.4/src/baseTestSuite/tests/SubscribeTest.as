package baseTestSuite.tests {
	import com.pubnub.*;
	import org.flexunit.*;
	import org.flexunit.async.*;
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	[BeforeClass (order=2)]
	public class SubscribeTest {
		
		
		[Test(async, description="[Pn.subscribe] test")]
		public function test() : void {
			//trace(this);
			var acyncTimeout:int = 310000;
			var asyncHandler:Function = Async.asyncHandler(this, onTest, acyncTimeout, null, onTestTimeout);
			Pn.instance.addEventListener(PnEvent.SUBSCRIBE, asyncHandler);
			Pn.subscribe(InitTest.CHANNEL);
		}
		
		private function onTest(event:PnEvent, passThroughData:Object = null):void {
			//trace(this, event.status);
			if ( event.status == OperationStatus.ERROR) {
				Assert.fail(event.type + ':' + event.data);	
			}
        }
		
		protected function onTestTimeout( passThroughData:Object ):void {
			 Assert.fail( "Timeout reached before event");	
		}
	}
}