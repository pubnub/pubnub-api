package org.hamcrest
{
    import flash.errors.IllegalOperationError;

    /**
     * Combines matching (<code>matches</code>) and describing mismatches (<code>describeMismatch</code>) into a single method <code>matchesOrDescribesMismatch</code>.
     *
     * Typically used when the matching logic and description logic are the same and/or deferred to another Matcher.
     *
     * @author Drew Bourne
     */
    public class DiagnosingMatcher extends BaseMatcher
    {
        /**
         * Deferred to <code>matchesOrDescribesMismatch</code>.
         *
         * @see #matchesOrDescribesMismatch
         */
        override public function matches(item:Object):Boolean
        {
            return matchesOrDescribesMismatch(item, new NullDescription());
        }

        /**
         * Deferred to <code>matchesOrDescribesMismatch</code>.
         *
         * @see #matchesOrDescribesMismatch
         */
        override public function describeMismatch(item:Object, description:Description):void
        {
            matchesOrDescribesMismatch(item, description);
        }

        /**
         * Abstract. Subclasses should override to provide the combined logic for matching and describing mismatches.
         */
        protected function matchesOrDescribesMismatch(item:Object, description:Description):Boolean
        {
            throw new IllegalOperationError('DiagnosingMatcher#matches is abstract and must be overriden in a subclass');
        }
    }
}
