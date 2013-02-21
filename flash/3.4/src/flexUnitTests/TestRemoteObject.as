package flexUnitTests
{
	import mx.collections.ArrayCollection;
	import mx.core.mx_internal;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.rpc.remoting.RemoteObject;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.flexunit.async.TestResponder;

	public class TestRemoteObject
	{		
		private static var service:HTTPService;
		[Before]
		public function setUp():void
		{
			service = new HTTPService();
			service.url = "http://192.168.1.23/test/testAsync.php";
			service.useProxy = false;
			service.resultFormat = "text";
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
		
		[Test(async)]
		public function testAyncResponderResultWithTestResponder() : void {
			var someVO:Object = new Object();
			someVO.myName = 'Mike Labriola';
			someVO.yourAddress = '1@2.com';
			
			var responder:IResponder = Async.asyncResponder( this, new TestResponder( handleIntendedResult, handleUnintendedFault ), 50, someVO );
			var token:AsyncToken = new AsyncToken( null );
			token.addResponder( responder );
			
			var result:ResultEvent = new ResultEvent( ResultEvent.RESULT, false, false, {myName:someVO.myName}, token, null );			
			token.mx_internal::applyResult( result );
			
		}
		
		protected function handleIntendedResult( data:Object, passThroughData:Object ):void {
			Assert.assertEquals( data.result.myName, passThroughData.myName );
		}
		
		protected function handleUnintendedFault( info:Object, passThroughData:Object ):void {
			Assert.fail("Responder threw a fault when result was expected");
		}
		
		[Test(async)]
		public function testMyMethod():void
		{
			var token:AsyncToken = service.send();
			token.addResponder( Async.asyncResponder( this, new TestResponder( verifyResult, verifyFault ), 2000 ));
		}
		
		protected function verifyResult( e:ResultEvent, token:AsyncToken ):void
		{
			Assert.assertTrue( "Result is what i want it to be", e.result == "aaa" );
		}
		
		protected function verifyFault( e:FaultEvent, token:AsyncToken ):void
		{
			Assert.fail( "Unintended fault from service" );
		}
		
	}
}