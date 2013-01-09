package org.hamcrest
{
    import flash.errors.IllegalOperationError;

    /**
     * Matcher that checks the value to be matched is of an expected type before passing it to <code>matchesSafely</code>.
     *
     * @author Drew Bourne
     */
    public class TypeSafeDiagnosingMatcher extends BaseMatcher
    {
        private var _expectedType:Class;

        /**
         * Constructor.
         *
         * @param expectedType Class the value to match must be or extend.
         */
        public function TypeSafeDiagnosingMatcher(expectedType:Class)
        {
            super();
            
            _expectedType = expectedType;
        }

        /**
         * Abstract. Subclasses should override <code>matchesSafely</code> to implement their matching logic
         * on a real value of the expected Class, and to describe the mismatch to the mismatchDescription.
         */
        public function matchesSafely(item:Object, mismatchDescription:Description):Boolean
        {
            throw new IllegalOperationError('TypeSafeDiagnosingMatcher#matchesSafely is abstract and must be override in subclass');
        }

        /**
         * Checks if the item is not null, is of the expectedType and <code>matchesSafely</code>
         *
         * @param item Object to match.
         * @param mismatchDescription Description to describe the mismatch to.
         */
        override public function matches(item:Object):Boolean
        {
            return item != null
                && item is _expectedType
                && matchesSafely(item, new NullDescription());
        }

        /**
         * Describes the mismatch by passing the item and Description to <code>matchesSafely</code>.
         *
         * @param item Object to match.
         * @param mismatchDescription Description to describe the mismatch to.
         */
        override public function describeMismatch(item:Object, mismatchDescription:Description):void
        {
            matchesSafely(item, mismatchDescription);
        }
    }
}
