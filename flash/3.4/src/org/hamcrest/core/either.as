package org.hamcrest.core
{
    import org.hamcrest.Matcher;

    /**
     * Creates a CombinableMatcher
     *
     * @see org.hamcrest.core.CombinableMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat("good", either(equalTo("good")).or(not(equalTo("bad"));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function either(... rest):CombinableMatcher
    {
        // alias of both, 
        return both.apply(null, rest);
    }
}
