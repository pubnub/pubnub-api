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
	
	
	public class TestTime
	{		
		public var pn:Pn;
		public var asyncFun:Function;
		
		[Before(async)]
		public function setUp():void
		{
			this.pn = Pn.instance;
			PrepareTesting.PnConfig(this.pn);
			
			//Pn.init process should be done
			//in 500 minseconds
			//Async.proceedOnEvent(this, pn, PnEvent.INIT, 500); 
			
			Async.delayCall(this, RequestTime, 500);
		}
		
		[After(async)]
		public function tearDown():void
		{
			pn.removeEventListener(PnEvent.TIME, asyncFun, false);
			var a:Boolean = pn.hasEventListener(PnEvent.TIME);
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
		public function TestTimeToken():void
		{
			asyncFun = Async.asyncHandler(this, handleIntendedResult, 2000, null, handleTimeout)
			pn.addEventListener(PnEvent.TIME, asyncFun, false, 0, true);
		}
		
		public function RequestTime():void
		{
			pn.time();
		}
		
		public function handleIntendedResult(e:PnEvent,  passThroughData:Object):void
		{
			switch (e.status) {
				case OperationStatus.DATA:
					var resultToken:String = e.data[0];
					var curentDateTime:Date = new Date();
					var currentTimestamp:Number = curentDateTime.time*10000;
					var timeOffSet:Number = Math.abs(currentTimestamp-Number(resultToken));
					Assert.assertTrue(timeOffSet<24*3600*10000);
					break;
				
				case OperationStatus.ERROR:
					Assert.fail("Time() did not return correct value but error out");
					break;
			}
		}
		
		public function handleTimeout(passThroughData:Object):void
		{
			Assert.fail("Time() request timeout");
		}		
	}
}