package org.hamcrest.text
{
    import org.hamcrest.Matcher;

    /**
     * Matches a String if it contains the given substring.
     *
     * @param substring String to search for
     *
     * @see org.hamcrest.text.StringContainsMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat("The quick brown fox", containsString("fox"));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function containsString(substring:String, ignoreCase:Boolean = false):Matcher
    {
        return new StringContainsMatcher(substring, ignoreCase);
    }
}
