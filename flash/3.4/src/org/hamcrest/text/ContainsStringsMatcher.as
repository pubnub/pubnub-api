package org.hamcrest.text
{
	import org.hamcrest.BaseMatcher;
	import org.hamcrest.Description;
	import org.hamcrest.DiagnosingMatcher;
	
	public class ContainsStringsMatcher extends DiagnosingMatcher
	{
		private var _strings:Array;
		
		public function ContainsStringsMatcher(strings:Array)
		{
			super();
			
			_strings = strings || [];
		}
		
		override public function describeTo(description:Description):void
		{
			description.appendText("a String containing all of ").appendValue(_strings);
		}
		
		override protected function matchesOrDescribesMismatch(item:Object, description:Description):Boolean
		{
			var target:String = item as String;
			var missingStrings:Array = [];
			var result:Boolean = true;
			
			if (item is String)
			{
				for each (var string:String in _strings)
				{
					if (target.indexOf(string) == -1)
					{
						missingStrings[missingStrings.length] = string;
					}
				}
			}
			
			if (missingStrings.length > 0)
			{
				result = false;
				
				description
					.appendText("was ")
					.appendValue(item)
					.appendText(" did not contain ")
					.appendValue(missingStrings);
			}
			
			return result;
		}
	}
}