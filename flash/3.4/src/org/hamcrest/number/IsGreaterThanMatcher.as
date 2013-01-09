package org.hamcrest.number
{
    import org.hamcrest.Description;
    import org.hamcrest.TypeSafeMatcher;

    /**
     * Matches if the item is greater than the given value.
     *
     * @see org.hamcrest.number#greaterThan()
     * @see org.hamcrest.number#greaterThanOrEqualTo()
     *
     * @example
     * <listing version="3.0">
     * assertThat(5, greaterThan(4));
     * </listing>
     *
     * @author Drew Bourne
     */
    public class IsGreaterThanMatcher extends TypeSafeMatcher
    {
        private var _value:Number;
        private var _inclusive:Boolean;

        /**
         * Constructor.
         */
        public function IsGreaterThanMatcher(value:Number, inclusive:Boolean)
        {
            super(Number);
            _value = value;
            _inclusive = inclusive;
        }

        override public function matchesSafely(item:Object):Boolean
        {
            return _inclusive
                ? Number(item) >= _value
                : Number(item) > _value;
        }

        override public function describeMismatch(item:Object, mismatchDescription:Description):void
        {
            mismatchDescription
                .appendValue(item)
                .appendText(" was not greater than ");
            
            if (_inclusive)
            {
                mismatchDescription.appendText("or equal to ");    
            }    
            
            mismatchDescription.appendValue(_value);
        }

        override public function describeTo(description:Description):void
        {
            description.appendText("a value greater than ");
            
             if (_inclusive)
            {
                description.appendText("or equal to ")
            }
            
            description.appendValue(_value);
        }
    }
}
