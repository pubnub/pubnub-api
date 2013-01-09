package org.hamcrest.core
{
	import org.hamcrest.Matcher;
	
	/**
	 * Never matches. Opposite of <code>anything()</code>.
	 *
	 * @param message Custom message to use in <code>describeTo</code>
	 *
	 * @see org.hamcrest.core.IsNothingMatcher
	 * @see org.hamcrest.core#anything()
	 *
	 * @example
	 * <listing version="3.0">
	 * 	// all fail
     *  assertThat("the great void", nothing());
	 * 	assertThat(true, nothing());
	 * 	assertThat(false, nothing());
	 * 	assertThat({}, nothing());
	 * 	assertThat(123, nothing());
	 * </listing>
	 *
	 * @author Drew Bourne
	 */
	public function nothing(message:String = null):Matcher
	{
		return new IsNothingMatcher(message);
	}
}
