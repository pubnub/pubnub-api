package org.hamcrest.core
{
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;

	/**
	 * Never matches. Opposite of <code>anything()</code>.
	 *
	 * @param message Custom message to use in <code>describeTo</code>
	 *
	 * @see org.hamcrest.core.IsNothingMatcher
	 *
	 * @example
	 * <listing version="3.0">
	 *  assertThat("the great void", nothing());
	 * </listing>
	 *
	 * @author Drew Bourne
	 */
    public class IsNothingMatcher extends BaseMatcher
    {
        private var _message:String;

        /**
         * Constructor.
         *
         * @param message Custom message to use in <code>describeTo</code>
         */
        public function IsNothingMatcher(message:String = null)
        {
            super();
            _message = message || "NOTHING";
        }

        /**
         * Matches anything, always returns true.
         */
        override public function matches(item:Object):Boolean
        {
            return false;
        }

        /**
         * Describes this matcher with the message given to the constructor, or 'NOTHING'.
         */
        override public function describeTo(description:Description):void
        {
            description.appendText(_message);
        }
    }
}
