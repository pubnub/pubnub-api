package org.hamcrest.date
{
    import org.hamcrest.Matcher;
    
    /**
     * Matches if the date item is after the given date.
     *
     * @param value Date the matched number must be after.
     * @return Matcher
     *
     * @see org.hamcrest.date.DateAfterMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat( new Date(), dateAfter( new Date( 1920, 1, 1)));
     * </listing>>
     */
    public function dateAfter(value:Date):Matcher
    {
        return new DateAfterMatcher(value);
    }
}
