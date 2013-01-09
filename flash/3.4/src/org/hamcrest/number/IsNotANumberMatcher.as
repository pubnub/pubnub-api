package org.hamcrest.number
{
	import org.hamcrest.Description;
	import org.hamcrest.TypeSafeMatcher;
	
	/**
	 * Matches a value if it is <code>NaN</code>.
	 * 
	 * @see org.hamcrest.number.isNotANumber()
	 * 
	 * @example
	 * <listing version="3.0">
	 * 	assertThat(0/0, isNotANumber());
	 * </listing>
	 * 
	 * @author Drew Bourne
	 */
	public class IsNotANumberMatcher extends TypeSafeMatcher
	{
		/**
		 * Constructor. 
		 */
		public function IsNotANumberMatcher()
		{
			super(Number);
		}
		
		/**
		 * Matches if <code>isNaN(item)</code> is <code>true</code>
		 */
		override public function matchesSafely(item:Object):Boolean
		{
			return isNaN(item as Number);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function describeTo(description:Description):void
		{
			description.appendText("NaN");
		}
	}
}