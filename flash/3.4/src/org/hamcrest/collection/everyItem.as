package org.hamcrest.collection
{
    import org.hamcrest.Matcher;

    /**
     * Matches an Array or Array-like Object if every item matches the given Matcher.
     *
     * @param itemMatcher Matcher that each item in the collection being matched must match.
     *
     * @see org.hamcrest.collection.EveryMatcher
     * @example
     * <listing version="3.0">
     *  assertThat([1, 2, 3], everyItem(isA(Number)));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function everyItem(itemMatcher:Matcher):Matcher
    {
        return new EveryMatcher(itemMatcher);
    }
}
