package org.hamcrest.object
{
    import org.hamcrest.Matcher;

    /**
     * Matches an item if it is === to the given value.
     *
     * @param
     *
     * @see org.hamcrest.object.IsSameMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat(3, sameInstance(3));
     *
     *  var event:Event = new Event("example"):
     *  assertThat(event, sameInstance(event));
     *  assertThat(event, not(sameInstance(new Event("example"))));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function sameInstance(value:Object):Matcher
    {
        return new IsSameMatcher(value);
    }
}
