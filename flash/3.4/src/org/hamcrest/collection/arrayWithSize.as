package org.hamcrest.collection
{
    import org.hamcrest.Matcher;
    import org.hamcrest.object.equalTo;
    
    // FIXME arrayWithSize() should take a matcher for the size, to allow usage of lessThan(), greaterThan(), between() etc.
    // FIXME test arrayWithSize() behaviour when taking a Matcher 
    /**
     * Checks the item being matched is an <code>Array</code> and has the expected number of items.
     *
     * @param size Number, int, uint in the range of >= 0.
     *
     * @see org.hamcrest.collection.IsArrayWithSizeMatcher
     * @example
     * <listing version="3.0">
     *  assertThat([], arrayWithSize(0));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function arrayWithSize(size:*):Matcher
    {
        if (size is Number || size is int || size is uint)
        {
            return arrayWithSize(equalTo(size));
        }
        else if (size is Matcher)
        {
            return new IsArrayWithSizeMatcher(size as Matcher);
        }
        else
        {
            throw new ArgumentError("Expecting Number, int, or uint for size, received:" + size);
        }
    }
}
