package org.hamcrest.text
{

    import flash.errors.IllegalOperationError;
    
    import org.hamcrest.Description;
    import org.hamcrest.TypeSafeMatcher;

    /**
     * Matcher for Substring matching, provides a default implementation of describeTo.
     *
     * Subclasses should override <code>evalSubstringOf</code> for matching logic,
     * and <code>relationship</code> to describe the type of match being performed.
     *
     * @author Drew Bourne
     */
    public class SubstringMatcher extends TypeSafeMatcher
    {
        private var _substring:String;
        private var _ignoreCase:Boolean;

        /**
         * Constructor
         *
         * @param substring String to search for
         * @param ignoreCase Indicates if the match should ignore the case of the substring
         */
        public function SubstringMatcher(substring:String, ignoreCase:Boolean = false)
        {
            super(String);
            _substring = substring;
            _ignoreCase = ignoreCase;
        }

        /**
         * Return the substring given to the constructor.
         */
        protected function get substring():String
        {
            return _substring;
        }
        
        /**
         * Indicates if match should ignore the case of the substring
         */
        protected function get ignoreCase():Boolean 
        {
            return _ignoreCase;
        }

        /**
         * Delegates matching to <code>evalSubstringOf</code>
         *
         * @inheritDoc
         */
        override public function matchesSafely(item:Object):Boolean
        {
            return evaluateSubstringOf(item as String);
        }

        override public function describeTo(description:Description):void
        {
            description.appendText("a string ").appendText(relationship()).appendText(" ").appendValue(_substring);
        }

        /**
         * Subclasses should override to perform matching logic.
         */
        protected function evaluateSubstringOf(item:String):Boolean
        {
            throw new IllegalOperationError("SubstringMatcher#evalueSubstringOf must be override by subclass");
        }

        /**
         * Subclasses should override to descibe the type of match being performed.
         */
        protected function relationship():String
        {
            throw new IllegalOperationError("SubstringMatcher#relationship must be override by subclass");
        }
    }
}
