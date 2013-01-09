package org.hamcrest.core
{
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;
    import org.hamcrest.Matcher;

    /**
     * Provides a Fluent Interface to combining Matchers
     *
     * @see org.hamcrest.core#both()
     * @see org.hamcrest.core#either()
     *
     * @example
     * <listing version="3.0">
     *  assertThat(5.5, both(between(3, 7)).and(closeTo(4, 2)));
     * </listing>
     *
     * @author Drew Bourne
     */
    public class CombinableMatcher extends BaseMatcher
    {
        private var _matcher:Matcher;

        /**
         * Constructor.
         *
         * @param matcher to match with
         */
        public function CombinableMatcher(matcher:Matcher)
        {
            super();
            _matcher = matcher;
        }

        /**
         * @inheritDoc
         */
        override public function matches(item:Object):Boolean
        {
            return _matcher.matches(item);
        }

        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendDescriptionOf(_matcher);
        }

        /**
         * Combines matchers that must both pass.
         *
         * @example
         * <listing version="3.0">
         *  assertThat(string, both(containsString("a")).and(containsString("b"));
         * </listing>
         */
        public function and(matcher:Matcher):CombinableMatcher
        {
            return new CombinableMatcher(allOf(_matcher, matcher));
        }

        /**
         * Combines matches where either may pass.
         *
         * @example
         * <listing version="3.0">
         *  assertThat(string, either(containsString("a")).or(containsString("b"));
         * </listing>
         */
        public function or(matcher:Matcher):CombinableMatcher
        {
            return new CombinableMatcher(anyOf(_matcher, matcher));
        }
    }
}
