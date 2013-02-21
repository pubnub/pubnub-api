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
	
	
	public class TestPublish
	{		
		public var pn:Pn;
		public var singleChannel:String;
		public var asyncFun:Function;
		
		private var messageUnicode:String = "中文";
		
		[Before(async)]
		public function setUp():void
		{
			//make sure the channel label is unque so other listener wont be there
			singleChannel = PrepareTesting.CreateUnqueChannel();
			pn = Pn.instance;
			PrepareTesting.PnConfig(pn);
			Async.delayCall(this, requestSubscribe, 2000);
			Async.delayCall(this, PublishMessage, 3000);
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
		public function TestSubscribeSingle():void
		{
			this.asyncFun = Async.asyncHandler(this, handleIntendedResult,20000, null, handleTimeout);
			pn.addEventListener(PnEvent.PUBLISH, asyncFun, false, 0, true);
		}
		
		private function requestSubscribe():void
		{
			pn.unsubscribeAll();
			pn.subscribe(this.singleChannel);
		}
		
		private function PublishMessage():void
		{
			Pn.publish({channel : this.singleChannel, message : messageUnicode});
		}
		
		public function handleIntendedResult(e:PnEvent,  passThroughData:Object):void
		{
			Assert.assertEquals(e.data[0], 1);
			Assert.assertEquals(e.data[1], "Sent");
			Assert.assertEquals(e.data.length,3);
		}
		
		public function handleTimeout(passThroughData:Object):void
		{
			Assert.fail("publish timeout");
		}		
	}
}