package org.hamcrest.collection
{
    import org.hamcrest.Matcher;
    import org.hamcrest.core.describedAs;

    /**
     * Checks item being matched is an <code>Array</code> and has zero (0) items.
     *
     * @example
     * <listing version="3.0">
     *  assertThat([], emptyArray());
     * </listing>
     *
     * @author Drew Bourne
     */
    public function emptyArray():Matcher
    {
        return describedAs("an empty Array", arrayWithSize(0));
    }
}
