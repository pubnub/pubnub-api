package org.hamcrest.date
{
    import org.hamcrest.Description;
    import org.hamcrest.TypeSafeMatcher;

    /**
     * Matches a Date before the expected Date
     *
     * @see org.hamcrest.date#dateBefore()
     */
    public class DateBeforeMatcher extends TypeSafeMatcher
    {
        private var _compareDate:Date;
        private var _inclusive:Boolean;

        /**
         * Constructor.
         *
         * @param value Expected Date the matched value must occur before
         * @param inclusive
         *  <code>true</code> to match a Date exactly equal or before the expected Date,
         *  <code>false</code> to match a Date only if it is before the expected.
         */
        public function DateBeforeMatcher(value:Date, inclusive:Boolean = false)
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
                return (value <= _compareDate);
            }
            else
            {
                return (value < _compareDate);
            }
        }

        /**
         * @inheritDoc
         */
        override public function describeMismatch(item:Object, mismatchDescription:Description):void
        {
            mismatchDescription
                .appendValue(item)
                .appendText(" is not before ")
                .appendValue(_compareDate);
        }

        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendText("a date before ").appendValue(_compareDate);
        }

    }
}
