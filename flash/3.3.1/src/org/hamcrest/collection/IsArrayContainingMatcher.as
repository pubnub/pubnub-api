package org.hamcrest.collection
{
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;
    import org.hamcrest.Matcher;

    /**
     * Matches if the item being matched is an Array and contains at least one item that matches
     * the given Matcher.
     *
     * @see org.hamcrest.collection#hasItem()
     * @see org.hamcrest.collection#hasItems()
     *
     * @example
     * <listing version="3.0">
     *  assertThat([1, 2, 3], hasItem(equalTo(3)));
     *  assertThat([1, 2, 3], hasItems(equalTo(2), equalTo(3)));
     * </listing>
     *
     * @author Drew Bourne
     */
    public class IsArrayContainingMatcher extends BaseMatcher
    {
        private var _elementMatcher:Matcher;

        /**
         * Constructor.
         *
         * @param elementMatcher Matcher to apply to items in the Array being matched.
         */
        public function IsArrayContainingMatcher(elementMatcher:Matcher)
        {
            super();
            _elementMatcher = elementMatcher;
        }

        /**
         * Checks if any item in the given Array matches with the Matcher given in the constructor.
         *
         * @param collection Array to check items for a match.
         */
        override public function matches(collection:Object):Boolean
        {
            for each (var item:Object in collection)
            {
                if (_elementMatcher.matches(item))
                {
                    return true;
                }
            }

            return false;
        }

        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendText("an Array containing ").appendDescriptionOf(_elementMatcher);
        }
    }
}
