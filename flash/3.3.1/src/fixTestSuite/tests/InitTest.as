package fixTestSuite.tests {
	
	import com.pubnub.*;
	import flash.events.Event;
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.prepare;
	import mockolate.runner.MockolateRule;
	import org.flexunit.*;
	import org.flexunit.async.*;
	import mockolate.runner.MockolateRunner; 
	MockolateRunner;
	import org.hamcrest.object.nullValue;
	/**
	 * https://github.com/flexunit/flexunit
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	[RunWith("mockolate.runner.MockolateRunner")]
	[BeforeClass (order = 1)]
	public class InitTest {
		
		public static const SUB_KEY:String = 'demo';
		public static const CHANNEL:String = 'hello_world';
        public var origin:String = 'pubsub.pubnub.com';
        public var pub_key:String = 'demo';
        public var secret_key:String = '';
        public var cipher_key:String = '';
		
		
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock]
		public var date:Date;
		
		
		public var pn:Pn;
		
		
		[Before(async, timeout=5000)]
		public function prepareMockolates():void{
			Async.proceedOnEvent(this,
				prepare(Date),
				Event.COMPLETE);
		}
		
		
		//[Test(async, description = "[Pn.init] test")]
		[Test]
		public function testInit() : void {
			//trace(this);
			 var config:Object = {
                publish_key:this.pub_key,
                SUB_KEY:SUB_KEY,
                secret_key:this.secret_key,
                cipher_key:this.cipher_key
            }
			var d:Date = nice(Date);
			
			mock(d).method("hours").returns(12);
			mock(d).method("minutes").returns(0);
			mock(d).method("seconds").returns(0);
			
			//assertThat(date, nullValue());
			//nice(Date);
			//mocks.mock(date).method("hours").returns(12);
			//mocks.mock(pn).method("init").args(config)
			//mock(date);
			
			/*mock(date).method("hours").returns(12);
			mock(date).method("minutes").returns(0);
			mock(date).method("seconds").returns(0);*/
			
			//Assert.assertTrue(date.hours == 12);
			//testObj = Pn.instance;
			//mock(testObj).method('init').args(config);
			
			/*var acyncTimeout:int = 310000;
			var asyncHandler:Function = Async.asyncHandler(this, onInit, acyncTimeout, null, onInitTimeout);
			Pn.instance.addEventListener(PnEvent.INIT, asyncHandler);
			Pn.instance.addEventListener(PnEvent.INIT_ERROR, asyncHandler);
            Pn.instance.init(config);*/
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