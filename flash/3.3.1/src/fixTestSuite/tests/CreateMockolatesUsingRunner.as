package fixTestSuite.tests
{
	import mockolate.mock;
	import mockolate.runner.MockolateRunner;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.isTrue;

	MockolateRunner;
	
	[RunWith("mockolate.runner.MockolateRunner")]
	public class CreateMockolatesUsingRunner
	{
		[Mock]
		public var myClass:MyClass;
		
		[Test]
		public function myClass_shouldDoSomething():void 
		{
			mock(myClass).method("doSomething").returns(true);
			
			assertThat(myClass.doSomething(), isTrue());
		}
	}
}
