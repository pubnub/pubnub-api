package org.hamcrest
{
    import flash.errors.IllegalOperationError;

    // TODO example TypeSafeMatcher
    /**
     * Matcher that checks the value to be matched is of an expected type before passing it to <code>matchesSafely</code>.
     *
     * Subclasses should override <code>matchesSafely</code>.
     *
     * @author Drew Bourne
     */
    public class TypeSafeMatcher extends BaseMatcher
    {
        private var _expectedType:Class;

        /**
         * Constructor.
         *
         * @param expectedType Class the value to match must be or extend.
         */
        public function TypeSafeMatcher(expectedType:Class)
        {
            super();
            
            if (expectedType == null)
            {
                throw new ArgumentError('expectedType must be non null');
            }

            _expectedType = expectedType;
        }

        /**
         * Abstract. Subclasses should override <code>matchesSafely</code> to implement their matching logic on a real value of the expected Class.
         */
        public function matchesSafely(item:Object):Boolean
        {
            throw new IllegalOperationError('TypeSafeMatcher#matchesSafely is abstract and must be override in subclass');
        }

        /**
         * Matches an item against the expected type given in the constructor before calling <code>matchSafely</code>
         */
        override public final function matches(item:Object):Boolean
        {
            return item is _expectedType
                && matchesSafely(item);
        }
    }
}
