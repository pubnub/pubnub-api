package org.hamcrest.object
{
    import org.hamcrest.Matcher;
    import org.hamcrest.core.not;

    /**
     * Matches if the item is not <code>null</code>
     *
     * @see org.hamcrest.object.IsNullMatcher
     * @see org.hamcrest.object#nullValue()
     *
     * @example
     * <listing version="3.0">
     * assertThat({ any: "object" }, notNullValue());
     * </listing>
     *
     * @author Drew Bourne
     */
    public function notNullValue():Matcher
    {
        return not(nullValue());
    }
}
