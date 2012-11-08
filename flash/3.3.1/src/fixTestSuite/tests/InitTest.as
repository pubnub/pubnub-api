package fixTestSuite.tests {
	
	import com.pubnub.*;
	import com.pubnub.operation.Operation;
	import com.pubnub.operation.OperationEvent;
	import flash.events.Event;
	import mockolate.arg;
	import mockolate.expect;
	import mockolate.expectArg;
	import mockolate.expecting;
	import mockolate.ingredients.Sequence;
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.prepare;
	import mockolate.record;
	import mockolate.replay;
	import mockolate.runner.MockolateRule;
	import mockolate.sequence;
	import mockolate.stub;
	import mockolate.verify;
	import org.flexunit.*;
	import org.flexunit.async.*;
	import mockolate.runner.MockolateRunner; 
	import org.hamcrest.core.anything;
	MockolateRunner;
	import org.hamcrest.object.nullValue;
	/**
	 * https://github.com/flexunit/flexunit
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	[BeforeClass (order = 1)]
	//[RunWith("mockolate.runner.MockolateRunner")]
	public class InitTest {
		
		public static const SUB_KEY:String = 'demo';
		public static const CHANNEL:String = 'hello_world';
        public var origin:String = 'pubsub.pubnub.com';
        public var pub_key:String = 'demo';
        public var secret_key:String = '';
        public var cipher_key:String = '';
		
		
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock(type="strict")] 
		public var pn:Pn;
		
		[Mock(type="strict")] 
		public var operation:Operation;
		
		
		
		//[Test(async, description = "[Pn.init] test")]
		[Test]
		public function testInit() : void {
			
			 var config:Object = {
                publish_key:this.pub_key,
                SUB_KEY:SUB_KEY,
                secret_key:this.secret_key,
                cipher_key:this.cipher_key
            }
			
			//pn = nice(Pn);
			//mock(pn).method('init').dispatches(new OperationEvent(OperationEvent.RESULT, {}));
			//pn.init(config);
			
			operation = nice(Operation);
			mock(operation).method('send').dispatches(new OperationEvent(OperationEvent.RESULT, { } ));
			
			Pn.init(config);
			/*var pn:Pn = nice(Pn);
			expect(pn.init(config)).dispatches(new OperationEvent(OperationEvent.RESULT, { } ));
			trace(pn is Pn)*/
			
		}
		
		protected function onInit( event:PnEvent, passThroughData:Object = null ):void {
			trace(this, event.type, event.data);
			if (event.type != PnEvent.INIT) {
				Assert.fail(event.type + ':' + event.data);
			}
		}
 
		protected function onInitTimeout( passThroughData:Object ):void {
			 Assert.fail( "Timeout reached before event");	
		}
	}
}