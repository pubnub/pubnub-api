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
     *  assertThat("good", both(equalTo("good")).and(not(equalTo("bad"));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function both(... rest):CombinableMatcher
    {
        return new CombinableMatcher(rest.length > 1 ? allOf.apply(null, rest) : rest[0]);
    }
}
