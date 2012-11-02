package org.hamcrest.text
{
    import org.hamcrest.Matcher;
    
    /**
     * Matches a String if it matches the RegExp
     *
     * @param re RegExp to match with.
     *
     * @see org.hamcrest.text.RegExpMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat("has some whitespace", "The quick brown fox", re(/\s+/));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function re(pattern:RegExp):Matcher
    {
        return new RegExpMatcher(pattern);
    }
}
