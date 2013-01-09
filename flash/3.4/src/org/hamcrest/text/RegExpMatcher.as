package org.hamcrest.text
{
    import org.hamcrest.BaseMatcher;
    
    /**
     * Matches a String if it matches the RegExp
     *
     * @param re RegExp to match with.
     *
     * @see org.hamcrest.text#re()
     *
     * @example
     * <listing version="3.0">
     *  assertThat("has some whitespace", "The quick brown fox", re(/\s+/));
     * </listing>
     *
     * @author Drew Bourne
     */
    public class RegExpMatcher extends SubstringMatcher
    {
        private var _pattern:RegExp;
        
        /**
         * Constructor
         *
         * @param substring Substring to search for
         */
        public function RegExpMatcher(pattern:RegExp)
        {
            _pattern = pattern;
            
            super(_pattern.toString());
        }
        
        /**
         * @inheritDoc
         */
        override protected function evaluateSubstringOf(s:String):Boolean
        {
            return _pattern.test(s);
        }
        
        /**
         * @inheritDoc
         */
        override protected function relationship():String
        {
            return "matching";
        }
    }
}