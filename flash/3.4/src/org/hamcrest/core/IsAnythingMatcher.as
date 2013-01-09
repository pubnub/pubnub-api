package org.hamcrest.core
{
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;

    /**
     * Checks if item being matched is anything, effectively always matches.
     *
     * @see org.hamcrest.core#anything()
     *
     * @example
     * <listing version="3.0">
     *  assertThat("the great void", anything());
     * </listing>
     *
     * @author Drew Bourne
     */
    public class IsAnythingMatcher extends BaseMatcher
    {
        private var _message:String;

        /**
         * Constructor.
         *
         * @param message Custom message to use in <code>describeTo</code>
         */
        public function IsAnythingMatcher(message:String = null)
        {
            super();
            _message = message || "ANYTHING";
        }

        /**
         * Matches anything, always returns true.
         */
        override public function matches(item:Object):Boolean
        {
            return true;
        }

        /**
         * Describes this matcher with the message given to the constructor, or 'ANYTHING'.
         */
        override public function describeTo(description:Description):void
        {
            description.appendText(_message);
        }
    }
}
