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
	[BeforeClass (order=4)]
	public class DetailedHistoryTest {
		
		[Test(async, description="[Pn.detailedHistory] test")]
		public function test() : void {
			var args:Object = { };
            args.start = null ;
            args.end =  null;
            args.count = 5;
            args.reverse = false;
            args.channel = InitTest.CHANNEL;
            args['sub-key'] = InitTest.SUB_KEY;
			
			var acyncTimeout:int = 310000;
			var asyncHandler:Function = Async.asyncHandler(this, onTest, acyncTimeout, null, onTestTimeout);
			Pn.instance.addEventListener(PnEvent.DETAILED_HISTORY, asyncHandler);
			Pn.instance.detailedHistory(args);
		}
		
		private function onTest(event:PnEvent, passThroughData:Object = null):void {
			if ( event.status == OperationStatus.ERROR) {
				Assert.fail(event.type + ':' + event.data);	
			}
			//trace(event.data);
        }
		
		protected function onTestTimeout( passThroughData:Object ):void {
			 Assert.fail( "Timeout reached before event");	
		}
	}
}