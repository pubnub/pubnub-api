package org.hamcrest
{

    // TODO example CustomTypeSafeMatcher
    /**
     * TypeSafeMatcher that defers logic for <code>matchesSafely</code> an another Function.
     *
     * @author Drew Bourne
     */
    public class CustomTypeSafeMatcher extends TypeSafeMatcher
    {
        private var _fixedDescription:String;
        private var _matchesSafelyFunc:Function;

        /**
         * Constructor.
         *
         * @param description
         * @param expectedType
         * @param matchesSafelyFunc
         */
        public function CustomTypeSafeMatcher(description:String, expectedType:Class, matchesSafelyFunc:Function)
        {
            super(expectedType);

            if (description == null)
            {
                throw new ArgumentError('description must be non null');
            }

            if (matchesSafelyFunc == null)
            {
                throw new ArgumentError('matchesSafelyFunc must be non null');
            }

            _fixedDescription = description;
            _matchesSafelyFunc = matchesSafelyFunc;
        }

        /**
         * @inheritDoc
         */
        override public function matchesSafely(item:Object):Boolean
        {
            return _matchesSafelyFunc(item);
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
