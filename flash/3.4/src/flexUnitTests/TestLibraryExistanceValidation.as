package flexUnitTests
{
	import com.pubnub.Pn;
	import com.pubnub.PnCrypto;
	import com.pubnub.PnEvent;
	import com.pubnub.connection.*;
	import com.pubnub.subscribe.Subscribe;
	
	import flexunit.framework.Assert;
	
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;

	public class TestLibraryExistanceValidation
	{		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function TestMainClassesExistance():void
		{
			var pn:Pn = Pn.instance;
			Assert.assertNotNull(pn);	
			
			var subscripber:Subscribe = new Subscribe();
			Assert.assertNotNull(subscripber);	
			
			var pncrypto:PnCrypto = new PnCrypto();
			Assert.assertNotNull(pncrypto);	
			
			var connection_Async:AsyncConnection = new AsyncConnection();
			Assert.assertNotNull(connection_Async);	
			
			var connection_Sync:SyncConnection = new SyncConnection();
			Assert.assertNotNull(connection_Sync);	
			
			var connection_heartbeat:HeartBeatConnection = new HeartBeatConnection();
			Assert.assertNotNull(connection_heartbeat);	
		}
		
		
	}
}