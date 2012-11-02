package org.hamcrest.number
{
	import org.hamcrest.Matcher;
	import org.hamcrest.core.allOf;
	import org.hamcrest.core.describedAs;
	import org.hamcrest.core.not;
	import org.hamcrest.object.instanceOf;

	/**
	 * Matches a value if it is a Number, excluding NaN, Infinity and -Infinity.
	 * 
 	 * @see org.hamcrest.number.IsNumberMatcher
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
	public function isNumber():Matcher 
	{
		return new IsNumberMatcher();
	}
}