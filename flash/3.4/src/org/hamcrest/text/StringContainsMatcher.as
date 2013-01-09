package org.hamcrest.text
{

    /**
     * Matches a String if it contains the given substring.
     *
     * @see org.hamcrest.text#containsString()
     * @see org.hamcrest.text.SubstringMatcher
     *
     * @author Drew Bourne
     */
    public class StringContainsMatcher extends SubstringMatcher
    {
        /**
         * Constructor
         *
         * @param substring Substring to search for
         * @param ignoreCase Indicates if the match should ignore the case of the substring
         */
        public function StringContainsMatcher(substring:String, ignoreCase:Boolean = false)
        {
            super(substring, ignoreCase);
        }

        /**
         * @inheritDoc
         */
        override protected function evaluateSubstringOf(s:String):Boolean
        {
            if (ignoreCase)
            {
                return s.toLowerCase().indexOf(substring.toLowerCase()) >= 0;
            }
            
            return s.indexOf(substring) >= 0;
        }

        /**
         * @inheritDoc
         */
        override protected function relationship():String
        {
            return "containing";
        }
    }
}
