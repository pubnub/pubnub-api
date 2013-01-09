package org.hamcrest.text
{

    import org.hamcrest.Matcher;

    /**
     * Matches a String if it starts with the given substring.
     *
     * @param substring String to search for
     * @param ignoreCase Indicates if the match should ignore the case of the substring
     *
     * @see org.hamcrest.text.StringStartsWithMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat("The quick brown fox", startsWith("The"));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function startsWith(substring:String, ignoreCase:Boolean = false):Matcher
    {
        return new StringStartsWithMatcher(substring, ignoreCase);
    }
}
