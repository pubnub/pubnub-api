package flexUnitTests
{
	import com.pubnub.Pn;
	import com.pubnub.PnCrypto;
	import com.pubnub.PnEvent;
	import com.pubnub.connection.*;
	import com.pubnub.environment.NetMonEvent;
	import com.pubnub.json.PnJSON;
	import com.pubnub.operation.OperationStatus;
	import com.pubnub.subscribe.Subscribe;
	
	import flexunit.framework.Assert;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.flexunit.async.Async;
	import org.flexunit.async.TestResponder;
	import org.flexunit.token.AsyncTestToken;
	
	
	public class TestHistory
	{		
		public var pn:Pn;
		public var singleChannel:String;
		public var asyncFun:Function;
		
		
		private var message1:String = "hello, world";
		private var message2:String = "hello/world/";
		private var message3:String = "中文";
		
		[Before(async)]
		public function setUp():void
		{
			//make sure the channel label is unque so other listener wont be there
			singleChannel = PrepareTesting.CreateUnqueChannel();
			pn = Pn.instance;
			PrepareTesting.PnConfig(pn);
			Async.delayCall(this, requestSubscribe, 2000);
		}
		
		[After(async)]
		public function tearDown():void
		{
			this.pn.removeEventListener(PnEvent.SUBSCRIBE, asyncFun, false);
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test(async, timeout=50000)]
		public function TestHistoryInOrder():void
		{
			this.asyncFun = Async.asyncHandler(this, handleIntendedResult,10000, null, handleTimeout);
			pn.addEventListener(PnEvent.DETAILED_HISTORY, asyncFun, false, 0, true);
		}
		
		private function requestSubscribe():void
		{
			pn.unsubscribeAll();
			pn.subscribe(this.singleChannel);
			Async.delayCall(this, SendFirstMessage, 2000);
		}
		
		private function SendFirstMessage():void
		{
			Pn.publish({channel : this.singleChannel, message : message1});
			Async.delayCall(this, SendSecondMessage, 2000);
		}
		
		private function SendSecondMessage():void
		{
			Pn.publish({channel : this.singleChannel, message : message2});
			Async.delayCall(this, SendThirdMessage, 2000);
		}
		
		private function SendThirdMessage():void
		{
			Pn.publish({channel : this.singleChannel, message : message3});
			Async.delayCall(this, fetchHistory, 2000);
		}
		
		private function fetchHistory():void
		{
			var args:Object = { };
			args.start = null;
			args.end = null;
			args.count = null;
			args.reverse = false;
			args.channel = this.singleChannel;
			args['sub-key'] = pn.subscribeKey;
			Pn.instance.detailedHistory(args);
		}
		
		public function handleIntendedResult(e:PnEvent,  passThroughData:Object):void
		{
			var messageDataArray:Array = e.data as Array;
			Assert.assertEquals(messageDataArray.length, 3);
			Assert.assertEquals(messageDataArray[0][1], '{"text":"'+message1+'"}');
			Assert.assertEquals(messageDataArray[1][1], '{"text":"'+message2+'"}');
			Assert.assertEquals(messageDataArray[2][1], '{"text":"'+message3+'"}');
		}
		
		public function handleTimeout(passThroughData:Object):void
		{
			Assert.fail("subscribe timeout");
		}		
	}
}