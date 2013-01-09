package org.hamcrest.object
{
    import org.hamcrest.Matcher;

    /**
     * Matches if the item is <code>null</code>
     *
     * @see org.hamcrest.object.IsNullMatcher
     *
     * @example
     * <listing version="3.0">
     * assertThat(null, nullValue());
     * </listing>
     *
     * @author Drew Bourne
     */
    public function nullValue():Matcher
    {
        return new IsNullMatcher();
    }
}
