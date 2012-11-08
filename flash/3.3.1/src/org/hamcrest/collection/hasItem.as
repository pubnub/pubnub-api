package org.hamcrest.collection
{
    import org.hamcrest.Matcher;
    import org.hamcrest.object.equalTo;

    /**
     * Matches if the item being matched is an Array and contains at least one item that matches
     * the given Matcher.
     *
     * @param value Object or Matcher that must be in the Array.
     *
     * @see org.hamcrest.collection.IsArrayContainingMatcher
     * @example
     * <listing version="3.0">
     *  assertThat([1, 2, 3], hasItem(equalTo(3));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function hasItem(value:Object):Matcher
    {
        if (value is Matcher)
        {
            return new IsArrayContainingMatcher(value as Matcher);
        }
        else
        {
            return hasItem(equalTo(value));
        }
    }
}
