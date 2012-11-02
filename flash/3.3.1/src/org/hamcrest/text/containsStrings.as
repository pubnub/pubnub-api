package org.hamcrest.text
{
	import org.hamcrest.Description;
	import org.hamcrest.Matcher;
	import org.hamcrest.StringDescription;
	import org.hamcrest.core.allOf;
	import org.hamcrest.core.describedAs;

	/**
	 * Matches a String if it contains all of the given substring.
	 *
	 * @param ...strings Array of Strings to search for. 
	 *
	 * @see org.hamcrest.text.StringContainsMatcher
	 *
	 * @example
	 * <listing version="3.0">
	 *	assertThat("The quick brown fox", containsStrings("quick", "fox"));
	 *	assertThat("The quick brown fox", containsStrings(["quick", "fox"]));
	 * </listing>
	 *
	 * @author Drew Bourne
	 */
	public function containsStrings(...rest):Matcher 
	{
		var strings:Array = rest;

		if (rest.length == 1 && rest[0] is Array)
		{
			strings = rest[0];
		}
		
		return new ContainsStringsMatcher(strings);
	}
}