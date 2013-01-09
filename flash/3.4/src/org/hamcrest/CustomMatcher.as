package org.hamcrest
{

    // TODO example CustomMatcher
    // TODO factory method for customMatcher
    /**
     * Matcher implementation that defers logic for <code>matches</code> an another Function.
     *
     * @author Drew Bourne
     */
    public class CustomMatcher extends BaseMatcher
    {
        private var _fixedDescription:String;
        private var _matchesFunc:Function;

        /**
         * @param description Description of the CustomMatcher instance.
         * @param matcherFunc
         *    Function to defer to for <code>matches</code>,
         *    <code>function(item:Object):Boolean</code>
         *
         */
        public function CustomMatcher(description:String, matchesFunc:Function)
        {
            super();

            if (description == null)
            {
                throw new ArgumentError('description must be non null');
            }

            if (matchesFunc == null)
            {
                throw new ArgumentError('matchesFunc must be non null');
            }

            _fixedDescription = description;
            _matchesFunc = matchesFunc;
        }

        /**
         * @inheritDoc
         */
        override public function matches(item:Object):Boolean
        {
            return _matchesFunc(item);
        }

        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendText(_fixedDescription);
        }
    }
}
