package org.hamcrest.text
{
    import org.hamcrest.Matcher;
    
    /**
     * Matches a String if it is zero-length, or contains only whitespace.
     *
     * @see org.hamcrest.text.EmptyStringMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat(textInput.text, not(emptyString()));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function emptyString():Matcher
    {
//        return describedAs("an empty String", 
//            both(isA(String)).and(anyOf(hasProperty('length', 0), re(/^[\s]+$/))))
        
        return new EmptyStringMatcher();
    }
}
