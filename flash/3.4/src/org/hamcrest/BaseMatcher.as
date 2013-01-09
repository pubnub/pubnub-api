package org.hamcrest
{
    import flash.errors.IllegalOperationError;

    // TODO example BaseMatcher subclass implementation
    /**
     * Abstract. Subclasses must override <code>matches</code> and <code>describeTo</code>, and should override <code>describeMismatch</code>.
     *
     * @author Drew Bourne
     */
    public class BaseMatcher implements Matcher
    {
        /**
         * Constructor.
         *
         * @private
         */
        public function BaseMatcher()
        {
            super();
        }

        /**
         * Abstract. Implementations should return <code>true</code> if the given item matches, or <code>false</code> if not.
         *
         * @inheritDoc
         */
        public function matches(item:Object):Boolean
        {
            throw new IllegalOperationError('BaseMatcher#matches must be override by subclass');
        }

        /**
         * When <code>matches</code> returns <code>false</code>, then <code>describeMismatch</code> should append to the given Description a description for why the match failed.
         */
        public function describeMismatch(item:Object, mismatchDescription:Description):void
        {
            mismatchDescription.appendText("was ").appendValue(item);
        }

        /**
         * Abstract. Implementations should override an describe themselves to the given <code>Description</code> in as much detail as relevant.
         */
        public function describeTo(description:Description):void
        {
            throw new IllegalOperationError('BaseMatcher#describeTo must be override by subclass');
        }

        /**
         * Returns a description of this Matcher
         */
        public function toString():String
        {
            return StringDescription.toString(this);
        }
    }
}
