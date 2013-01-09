package baseTestSuite.tests {
	import com.pubnub.OperationStatus;
	import com.pubnub.Pn;
	import com.pubnub.PnEvent;
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	/**
	 * ...
	 * @author firsoff maxim, support@pubnub.com
	 */
	[BeforeClass (order=5)]
	public class UnsubTest {
				
		[Test(async, description="[Pn.unsubscribe] test")]
		public function test() : void {
			//trace(this);
			var acyncTimeout:int = 310000;
			var asyncHandler:Function = Async.asyncHandler(this, onTest, acyncTimeout, null, onTestTimeout);
			Pn.instance.addEventListener(PnEvent.SUBSCRIBE, asyncHandler);
			Pn.unsubscribe(InitTest.CHANNEL);
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