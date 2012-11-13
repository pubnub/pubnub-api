package fixTestSuite.tests {
	import com.pubnub.*;
	import com.pubnub.json.*;
	import com.pubnub.operation.*;
	import mockolate.*;
	import mockolate.runner.*;
	import org.flexunit.*;
	import org.flexunit.async.*;
	
	
	MockolateRunner;
	
	use namespace pn_internal;
	
	/**
		FlexUnit:
		https://github.com/flexunit/flexunit
		 
		Mokolate: 
		http://mockolate.org/
	 * 	@author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	[BeforeClass (order = 1)]
	public class InitTest {
		
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
		[Mock] 
		public var operation:Operation;
		
		public var pn:Pn;
		
		public static const initToken:Number = 13527819890213787;
		
		public static var counterInitEvents:int = 0;
		public static var counterErrorEvents:int = 0;
		
		[Test (async, order=1)]
		public function operationInit() : void {
			 var config:Object = {
                publish_key:'demo',
                sub_key:'demo',
                secret_key:'',
                cipher_key:'',
                origin: 'pubsub.pubnub.com'
            }
			
			// prepare async handlers
			var initHandler:Function = Async.asyncHandler( this, onInit, 1000, null, onInitTimeout );
			var errorHandler:Function = Async.asyncHandler( this, onInitError, 1000, null, onErrorTimeout);
			
			// mock operation
			operation = nice(Operation);
			mock(operation).method('send').dispatches(new OperationEvent(OperationEvent.RESULT, PnJSON.parse('[' + initToken+ ']') ));
			
			// configure events handlers
			Pn.instance.addEventListener(PnEvent.INIT, initHandler);
			Pn.instance.addEventListener(PnEvent.INIT_ERROR, errorHandler);
			Pn.instance.initOperation = operation;
			Pn.instance.init(config);
		}
		
		[Test (order=2)]
		public function numInitEvents() : void {
			Assert.assertTrue(counterInitEvents == 1);
		}
		
		[Test (order=3)]
		public function numErrorEvents() : void {
			Assert.assertTrue(counterErrorEvents == 0);
		}
			
		protected function onInit( event:PnEvent, passThroughData:Object = null):void {
			Assert.assertEquals(event.data, initToken);
			counterInitEvents++;
		}
		
		protected function onInitTimeout( event:PnEvent, passThroughData:Object = null):void {
			Assert.fail('init timeout');
		}
		
		protected function onInitError( event:PnEvent, passThroughData:Object = null):void {
			counterErrorEvents++;
		}
		
		protected function onErrorTimeout( event:PnEvent, passThroughData:Object = null):void {
			// nothing to do
		}
	}
}