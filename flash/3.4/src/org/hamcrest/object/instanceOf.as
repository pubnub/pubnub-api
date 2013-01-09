package org.hamcrest.object
{
    import org.hamcrest.Matcher;

    /**
     * Matches if the item is an instance of the given type.
     *
     * @param type Class the item must be an instance of
     *
     * @see org.hamcrest.object.IsInstanceOfMatcher
     *
     * @exmaple
     * <listing version="3.0">
     *  assertThat("waffles", instanceOf(String));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function instanceOf(type:Class):Matcher
    {
        return new IsInstanceOfMatcher(type);
    }
}
