package org.hamcrest.text
{
    import org.hamcrest.Description;
    import org.hamcrest.TypeSafeDiagnosingMatcher;
    import org.hamcrest.TypeSafeMatcher;
    
    /**
     * Matches a String if it is zero-length, or contains only whitespace.
     *
     * @see org.hamcrest.text#emptyString()
     *
     * @example
     * <listing version="3.0">
     *  assertThat(textInput.text, not(emptyString()));
     * </listing>
     *
     * @author Drew Bourne
     */
    public class EmptyStringMatcher extends TypeSafeMatcher
    {
        /**
         * Constructor
         */
        public function EmptyStringMatcher()
        {
            super(String);
        }
        
        /**
         * Matches a String that is zero length or contains only whitespace.
         */
        override public function matchesSafely(item:Object):Boolean
        {
            var string:String = String(item);
            return string.length == 0 || string.match(/^[\s]+$/);
        }
        
        /**
         * Describes this matcher as "an empty String".
         */
        override public function describeTo(description:Description):void
        {
            description.appendText("an empty String");
        }
    }
}
