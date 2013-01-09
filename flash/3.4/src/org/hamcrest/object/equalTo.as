package org.hamcrest.object
{
    import org.hamcrest.Matcher;
    
    /**
     * Checks the item being matched is equal (==).
     *
     * <ul>
     * <li><code>Number</code>s match if they are equal (==) </li>
     * <li><code>Number</code>s match if they are both <code>NaN</code>. </li>
     * <li><code>null</code>s match.</li>
     * <li><code>Array</code>s match if they are the same length and each item is equal.
     *  Checked recursively for child arrays. </li>
     * </ul>
     *
     * @see org.hamcrest.object.IsEqualMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat("hi", equalTo("hi"));
     *  assertThat("bye", not(equalTo("hi")));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function equalTo(value:Object):Matcher
    {
        return new IsEqualMatcher(value);
    }
}
