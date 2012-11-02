package org.hamcrest.date
{
    import org.hamcrest.Matcher;

    /**
     * Matches if the date item is equal to the given date.
     *
     * @param value Date the matched item must be equal.
     * @return Matcher
     *
     * @see org.hamcrest.date.DateEqualMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat(new Date(), dateEqual( new Date() ));
     * </listing>
     */
    public function dateEqual(value:Date):Matcher
    {
        return new DateEqualMatcher(value);
    }
}
