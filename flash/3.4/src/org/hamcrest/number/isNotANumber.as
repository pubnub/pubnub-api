package org.hamcrest.number
{
	import org.hamcrest.Matcher;

	/**
	 * Matches a value if it is <code>NaN</code>.
	 * 
	 * @see org.hamcrest.number.IsNotANumberMatcher
	 * 
	 * @example
	 * <listing version="3.0">
	 * 	assertThat(0/0, isNotANumber());
	 * </listing>
	 * 
	 * @author Drew Bourne
	 */
	public function isNotANumber():Matcher 
	{
		return new IsNotANumberMatcher();
	}
}