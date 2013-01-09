package org.hamcrest.object
{
    import org.hamcrest.Matcher;
    
    /**
     * Checks the item being matched are strictly equal (===).
     *
     * @see org.hamcrest.object.IsStrictlyEqualMatcher
     *
     * @example
     * <listing version="3.0">
     *  var o1:Object = {};
     *  var o2:Object = {};
     *  assertThat(o1, strictlyEqualTo(o1"));
     *  assertThat(o1, not(strictlyEqualTo(o2)));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function strictlyEqualTo(value:Object):Matcher
    {
        return new IsStrictlyEqualMatcher(value);
    }
}
