package org.hamcrest.collection
{
	import org.hamcrest.Description;
	import org.hamcrest.DiagnosingMatcher;
	import org.hamcrest.Matcher;

	public class InArrayMatcher extends DiagnosingMatcher
	{
		private var _elementMatchers:Array;
		
		public function InArrayMatcher(elementMatchers:Array)
		{
			super();
			
			_elementMatchers = elementMatchers;
		}
		
		override protected function matchesOrDescribesMismatch(item:Object, description:Description):Boolean
		{
			for each (var element:Matcher in _elementMatchers)
			{
				if (element.matches(item))
				{
					return true;
				}
			}
			
			description.appendValue(item);
			description.appendText(" was not ");
			describeTo(description);
			
			return false;
		}
		
		override public function describeTo(description:Description):void
		{
			description.appendText("contained in ");
			description.appendList("[", ", ", "]", _elementMatchers);
		}
	}
}