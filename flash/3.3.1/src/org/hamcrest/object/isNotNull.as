package org.hamcrest.object
{
	import org.hamcrest.Matcher;
	import org.hamcrest.core.not;
	
	/**
	 * Matches if the item is not <code>null</code>
	 *
	 * @see org.hamcrest.object.IsNullMatcher
	 * @see org.hamcrest.object#isNull()
	 *
	 * @example
	 * <listing version="3.0">
	 * assertThat({ any: "object" }, isNotNull());
	 * </listing>
	 *
	 * @author Drew Bourne
	 */
	public function isNotNull():Matcher
	{
		return not(isNull());
	}
}
