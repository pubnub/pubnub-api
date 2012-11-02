package fixTestSuite.tests
{
	import flash.events.Event;
	import org.hamcrest.object.isTrue;
	
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.prepare;
	
	import org.flexunit.assertThat;
	import org.flexunit.async.Async;
	//import org.hamcrest.object.isTrue;

	public class CreateMockolatesManually
	{
		public var myClass:MyClass;
		public var date:Date;
		
		[Before(async, order=1)]
		public function prepareMockClasses():void 
		{
			trace('prepareMockClasses');
			Async.proceedOnEvent(this, prepare(MyClass), Event.COMPLETE);
			//Async.proceedOnEvent(this, prepare(Date), Event.COMPLETE);
		}
		
		[Before(order=2)]
		public function setup():void 
		{
			
			myClass = nice(MyClass);
			trace('setup : ' + myClass);
			//date = nice(Date);
		}
		
		[Test]
		public function myClass_shouldDoSomething():void 
		{
			mock(myClass).method("doSomething").returns(true);
			trace('myClass_shouldDoSomething : ' + myClass); 
			
			assertThat(myClass.doSomething(), isTrue());
		}
	}
}
