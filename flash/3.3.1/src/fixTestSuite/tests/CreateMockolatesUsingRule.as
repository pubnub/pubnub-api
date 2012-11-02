package fixTestSuite.tests
{
	import mockolate.mock;
	import mockolate.runner.MockolateRule;
	
	import org.flexunit.assertThat;
	import org.hamcrest.object.isTrue;

	public class CreateMockolatesUsingRule
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();
		
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
