package org.hamcrest.core
{
    import org.hamcrest.Matcher;

    /**
     * Checks if the item being matched matches any of the given Matchers.
     *
     * @see org.hamcrest.core.AnyOfMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat("good", anyOf(equalTo("bad"), equalTo("good")));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function anyOf(... rest):Matcher
    {
        // FIXME enable passing a single array to anyOf([ matcher, ...matchers ]) so the matchers can be built out of line.
        var matchers:Array = rest;

        if (rest.length == 1 && rest[0] is Array)
        {
            matchers = rest[0];
        }

        return new AnyOfMatcher(matchers);
    }
}
