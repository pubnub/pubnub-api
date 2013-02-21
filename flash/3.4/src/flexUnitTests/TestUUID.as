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
	
	
	public class TestUUID
	{		
		public var pn:Pn;
		public var asyncFun:Function;
		
		[Before(async)]
		public function setUp():void
		{
			pn = Pn.instance;
			PrepareTesting.PnConfig(pn);
		}
		
		[After(async)]
		public function tearDown():void
		{
			pn.removeEventListener(PnEvent.INIT, asyncFun, false);
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
		public function TestUUIDLongerThan10():void
		{
			this.asyncFun =  Async.asyncHandler(this, handleIntendedResult,1000, null, handleTimeout);
			pn.addEventListener(PnEvent.INIT,asyncFun, false, 0, true);
		}
		
		public function handleIntendedResult(e:PnEvent,  passThroughData:Object):void
		{
			//UUID longer than 10
			Assert.assertTrue(pn.sessionUUID.length>10);	
		}
		
		public function handleTimeout(passThroughData:Object):void
		{
			Assert.fail("PN init timeout");
		}		
	}
}