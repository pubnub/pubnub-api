package org.hamcrest.core
{
    import org.hamcrest.Matcher;
    import org.hamcrest.object.equalTo;

    /**
     * Inverts the result of another Matcher or value.
     *
     * @see org.hamcrest.core.IsNotMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat(3, not(4));
     *  assertThat(3, not(closeTo(10, 1)));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function not(value:Object):Matcher
    {
        if (value is Matcher)
        {
            return new IsNotMatcher(value as Matcher);
        }
        else
        {
            return not(equalTo(value));
        }
    }
}
