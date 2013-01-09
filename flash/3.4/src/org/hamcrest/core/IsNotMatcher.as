package org.hamcrest.core
{
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;
    import org.hamcrest.Matcher;

    /**
     * Inverts the result of another Matcher or value.
     *
     * @see org.hamcrest.core#not()
     *
     * @example
     * <listing version="3.0">
     *  assertThat(3, not(4));
     *  assertThat(3, not(closeTo(10, 1)));
     * </listing>
     *
     * @author Drew Bourne
     */
    public class IsNotMatcher extends BaseMatcher
    {
        private var _matcher:Matcher;

        /**
         * Constructor.
         *
         * @param matcher Matcher to invert the result for.
         */
        public function IsNotMatcher(matcher:Matcher)
        {
            _matcher = matcher;
        }

        /**
         * @inheritDoc
         */
        override public function matches(item:Object):Boolean
        {
            return !_matcher.matches(item);
        }

        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendText("not ").appendDescriptionOf(_matcher);
        }
    }
}
