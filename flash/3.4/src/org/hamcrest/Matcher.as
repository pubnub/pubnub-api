package org.hamcrest
{
    /**
     * Describes methods a Matcher is expected to implement.
     *
     * @author Drew Bourne
     */
    public interface Matcher extends SelfDescribing
    {
        /**
         * Given an item, a Matcher implementation should return true if the item is correct, false if the item is not wrong.
         */
        function matches(item:Object):Boolean;

        /**
         * When a Matcher returns false <code>describeMismatch</code> can be called with a Description, to which this matcher will describe how the item was wrong.
         *
         * @see org.hamcrest.Description
         */
        function describeMismatch(item:Object, mismatchDescription:Description):void;
    }
}
