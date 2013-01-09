package org.hamcrest.core
{
    import org.hamcrest.Matcher;

    /**
     * Always matches. Opposite of <code>nothing().</code>
     *
     * @param message Custom message to use in <code>describeTo</code>
     *
     * @see org.hamcrest.core.IsAnythingMatcher
	 * @see org.hamcrest.core#nothing()
     *
     * @example
     * <listing version="3.0">
	 * 	// all pass
     *  assertThat("the great void", anything());
	 * 	assertThat(true, anything());
	 * 	assertThat(false, anything());
	 * 	assertThat({}, anything());
	 * 	assertThat(123, anything());
     * </listing>
     *
     * @author Drew Bourne
     */
    public function anything(message:String = null):Matcher
    {
        return new IsAnythingMatcher(message);
    }
}
