package org.hamcrest.core
{
    import org.hamcrest.Matcher;

    /**
     * Checks if an item matches all of the given Matchers.
     *
     * @param ...rest Matcher instances
     *
     * @see org.hamcrest.core.AllOfMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat("good", allOf(equalTo("good"), not(equalTo("bad"))));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function allOf(... rest):Matcher
    {
        var matchers:Array = rest;

        if (rest.length == 1 && rest[0] is Array)
        {
            matchers = rest[0];
        }

        return new AllOfMatcher(matchers);
    }
}
