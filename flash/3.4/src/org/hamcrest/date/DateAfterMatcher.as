package org.hamcrest.date
{
    import org.hamcrest.Description;
    import org.hamcrest.TypeSafeMatcher;

    /**
     * Matches a Date after the expected Date
     *
     * @see org.hamcrest.date#dateAfter()
     */
    public class DateAfterMatcher extends TypeSafeMatcher
    {
        private var _compareDate:Date;
        private var _inclusive:Boolean;

        /**
         * Constructor.
         *
         * @param value Expected Date the matched value must occur after
         * @param inclusive
         *  <code>true</code> to match a Date exactly equal or after the expected Date,
         *  <code>false</code> to match a Date only if it is after the expected.
         */
        public function DateAfterMatcher(value:Date, inclusive:Boolean = false)
        {
            super(Date);
            _compareDate = value;
            _inclusive = inclusive;
        }

        /**
         * @inheritDoc
         */
        override public function matchesSafely(value:Object):Boolean
        {
            if (_inclusive)
            {
                return (value >= _compareDate);
            }
            else
            {
                return (value > _compareDate);
            }

        }

        /**
         * @inheritDoc
         */
        override public function describeMismatch(item:Object, mismatchDescription:Description):void
        {
            mismatchDescription
                .appendValue(item)
                .appendText(" is not after ")
                .appendValue(_compareDate);
        }

        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description
                .appendText("a date after ")
                .appendValue(_compareDate);
        }
    }
}

