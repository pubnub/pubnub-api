package org.hamcrest.text
{

    /**
     * Matches a String if it starts with the given value
     *
     * @see org.hamcrest.text#endsWith()
     * @see org.hamcrest.text.SubstringMatcher
     *
     * @author Drew Bourne
     */
    public class StringStartsWithMatcher extends SubstringMatcher
    {
        /**
         * Constructor
         *
         * @param substring String to search for
         * @param ignoreCase Indicates if the match should ignore the case of the substring
         */
        public function StringStartsWithMatcher(substring:String, ignoreCase:Boolean = false)
        {
            super(substring, ignoreCase);
        }

        /**
         * @inheritDoc
         */
        override protected function evaluateSubstringOf(s:String):Boolean
        {
            return (new RegExp('^' + substring, ignoreCase ? 'i' : null)).test(s);
        }

        /**
         * @inheritDoc
         */
        override protected function relationship():String
        {
            return "starting with";
        }
    }
}
