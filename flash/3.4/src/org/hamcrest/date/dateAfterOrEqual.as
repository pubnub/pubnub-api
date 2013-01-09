package org.hamcrest.date
{
    import org.hamcrest.Matcher;
    import org.hamcrest.core.describedAs;

    /**
     * Matches if the date item is after or equal to the given date.
     *
     * @param value Date the matched number must be after or equal to.
     * @return Matcher
     *
     * @see org.hamcrest.date.DateAfterMatcher
     *
     * @example
     * <listing version="3.0">
     * assertThat( new Date(), dateAfterOrEqual( new Date( 1920, 1, 1)));
     * </listing>
     */
    public function dateAfterOrEqual(value:Date):Matcher
    {
        var afterMatcher:DateAfterMatcher = new DateAfterMatcher(value, true);
        return describedAs("a date after or equal to %0", afterMatcher, value);
    }
}
