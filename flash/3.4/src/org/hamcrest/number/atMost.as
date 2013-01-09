package org.hamcrest.number
{
    import org.hamcrest.Matcher;
    import org.hamcrest.core.describedAsWithMismatch;
    
    /**
     * Matches if the item is less than the given value.
     *
     * @param value Number the matched item must be less than.
     * @return Matcher
     *
     * @see org.hamcrest.number.IsLessThanMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat(3, lessThan(4));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function atMost(value:Number):Matcher
    {
        return describedAsWithMismatch(
            "at most %0", 
            "was %0",
            lessThanOrEqualTo(value), 
            value);
    }
}