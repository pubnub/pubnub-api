package org.hamcrest.number
{
    import org.hamcrest.Matcher;
    
    /**
     * Matches if a value is within +/- the delta value from the given value.
     *
     * @param value
     * @param delta
     *
     * @see org.hamcrest.number.IsCloseToMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat(3, closeTo(4, 1));
     *  // passes
     *
     *  assertThat(3, closeTo(5, 0.5));
     *  // fails
     *
     *  assertThat(4.5, closeTo(5, 0.5));
     *  // passes
     * </listing>
     *
     * @author Drew Bourne
     */
    public function closeTo(value:Number, delta:Number):Matcher
    {
        return new IsCloseToMatcher(value, delta);
    }
}