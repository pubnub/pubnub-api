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
	
	
	public class TestSubscribePresenceMultiple
	{		
		public var pn:Pn;
		public var multipleChannel:String = "aa,bb,cc";
		public var asyncFun:Function;
		
		[Before(async)]
		public function setUp():void
		{
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
		
		[Test(async, timeout=5000)]
		public function TestSubscribeMultiple():void
		{
			this.asyncFun = Async.asyncHandler(this, handleIntendedResult, 2000, null, handleTimeout)
			pn.addEventListener(PnEvent.SUBSCRIBE, asyncFun, false, 0, true);
		}
		
		private function requestSubscribe():void
		{
			pn.unsubscribeAll();
			pn.subscribe(this.multipleChannel);
		}
		
		public function handleIntendedResult(e:PnEvent,  passThroughData:Object):void
		{
			var channelArray:Array =  Pn.getSubscribeChannels();
			Assert.assertEquals(channelArray.length, 3);
			Assert.assertEquals(channelArray[0], 'aa');
			Assert.assertEquals(channelArray[1], 'bb');
			Assert.assertEquals(channelArray[2], 'cc');
		}
		
		public function handleTimeout(passThroughData:Object):void
		{
			Assert.fail("multiple subscribe timeout");
		}		
	}
}