package baseTestSuite.tests {
	import com.pubnub.*;
	import org.flexunit.*;
	import org.flexunit.async.*;
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	[BeforeClass (order=3)]
	public class PublishTest {
		
		
		[Test(async, description="[Pn.subscribe] test")]
		public function test() : void {
			//trace(this);
			var acyncTimeout:int = 310000;
			var asyncHandler:Function = Async.asyncHandler(this, onTest, acyncTimeout, null, onTestTimeout);
			Pn.instance.addEventListener(PnEvent.PUBLISH, asyncHandler);
			Pn.publish({channel : InitTest.CHANNEL, message : 'test message'});
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