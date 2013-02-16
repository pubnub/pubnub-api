package flexUnitTests
{
	import flexUnitTests.*;
	
	import flexunit.framework.Test;
	
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuiteFull
	{
		public var test1:TestLibraryExistanceValidation;
		public var test2:TestPnCrypto;
		public var test3:TestTime;
		public var test4:TestUUID;
		public var test5:TestSubscribePresence;
		public var test6:TestSubscribePresenceMultiple;
		public var test7:TestSubscribeWithToken;
		public var test8:TestPublish; 
		public var test9:TestHistory; 
		public var test10:TestUnSubscribe;
	}
}