package org.hamcrest.number
{
	import org.hamcrest.Description;
	import org.hamcrest.TypeSafeMatcher;
	
	/**
	 * Matches a value if it is a Number, excluding NaN, Infinity and -Infinity.
	 * 
	 * @see org.hamcrest.number.isNumber()
	 * 
	 * @example
	 * <listing version="3.0">
	 *  // passes
	 * 	assertThat(0, isNumber());
	 * 
	 *  // fails
	 *  assertThat(NaN, isNumber());
	 *  assertThat(Infinity, isNumber());
	 *  assertThat(-Infinity, isNumber());
	 * </listing>
	 * 
	 * @author Drew Bourne
	 */
	public class IsNumberMatcher extends TypeSafeMatcher
	{
		/**
		 * Constructor. 
		 */
		public function IsNumberMatcher()
		{
			super(Number);
		}
		
		override public function matchesSafely(item:Object):Boolean
		{
			return !isNaN(item as Number) 
				&& item != Number.POSITIVE_INFINITY
				&& item != Number.NEGATIVE_INFINITY;
		}
		
		override public function describeTo(description:Description):void
		{
			description.appendText("a Number");
		}
	}
}