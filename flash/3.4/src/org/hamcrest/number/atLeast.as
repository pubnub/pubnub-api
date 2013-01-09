package org.hamcrest.number
{
    import org.hamcrest.Matcher;
    import org.hamcrest.core.describedAsWithMismatch;
    
    /**
     * Matches if the item is greater than or equal to the given value
     *
     * @param value Number the matched item must be greater than.
     * @return Matcher
     *
     * @see org.hamcrest.number.IsGreaterThanMatcher
     * 
     * @example
     * <listing version="3.0">
     *  assertThat(5, atLeat(4));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function atLeast(value:Number):Matcher
    {
        return describedAsWithMismatch(
            "at least %0", 
            "was %0",
            greaterThanOrEqualTo(value), 
            value);
    }
}