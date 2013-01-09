package org.hamcrest.object
{
	import org.hamcrest.Matcher;
	
	/**
	 * Matches if the item is <code>null</code>
	 *
	 * @see org.hamcrest.object.IsNullMatcher
	 *
	 * @example
	 * <listing version="3.0">
	 * assertThat(null, isNull());
	 * </listing>
	 *
	 * @author Drew Bourne
	 */
	public function isNull():Matcher
	{
		return new IsNullMatcher();
	}
}
