package org.hamcrest.object
{
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;

    /**
     * Matches an item if it is === to the given value.
     *
     * @see org.hamcrest#sameInstance()
     *
     * @author Drew Bourne
     */
    public class IsSameMatcher extends BaseMatcher
    {
        private var _value:Object;

        /**
         * Constructor
         *
         * @param value Object the item must be === to
         */
        public function IsSameMatcher(value:Object)
        {
            _value = value;
        }

        /**
         * @inheritDoc
         */
        override public function matches(item:Object):Boolean
        {
            return item === _value;
        }

        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendText("same instance ").appendValue(_value);
        }
    }
}
