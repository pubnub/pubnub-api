package org.hamcrest.date
{
    import org.hamcrest.Matcher;
    
    /**
     * Matches if the date item is before the given date.
     *
     * @param value Date the matched number must be before.
     * @return Matcher
     *
     * @see org.hamcrest.date.DateBeforeMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat( new Date(1920, 1, 1), dateBefore( new Date() ) );
     * </listing>
     */
    public function dateBefore(value:Date):Matcher
    {
        return new DateBeforeMatcher(value);
    }
}
