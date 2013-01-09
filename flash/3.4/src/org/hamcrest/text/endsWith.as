package org.hamcrest.text
{
    import org.hamcrest.Matcher;

    /**
     * Matches a String if it ends with the given substring.
     *
     * @param substring String to search for
     * @param ignoreCase Indicates if the match should ignore the case of the substring
     *
     * @see org.hamcrest.text.StringEndsWithMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat("The quick brown fox", endsWith("fox"));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function endsWith(substring:String, ignoreCase:Boolean = false):Matcher
    {
        return new StringEndsWithMatcher(substring, ignoreCase);
    }
}
