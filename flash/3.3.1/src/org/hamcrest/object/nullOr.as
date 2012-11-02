package org.hamcrest.object 
{
	import org.hamcrest.Matcher;
	import org.hamcrest.core.anyOf;

	/**
	 * Matches either <code>null</code> or the specified matcher or value.
	 *
	 * @param matcherOrValue Matcher or value to be wrapped in <code>equalTo()</code>.
	 * 
	 * @example
	 * <listing version="3.0">
	 * 	assertThat(value, nullOr(3));
	 * 	assertThat(value, nullOr(greaterThan(2));
	 * </listing>
	 */
	public function nullOr(matcherOrValue:*):Matcher 
	{
		var matcher:Matcher = matcherOrValue is Matcher
			? matcherOrValue
			: equalTo(matcherOrValue);
		
		return anyOf(nullValue(), matcher);
	}
}