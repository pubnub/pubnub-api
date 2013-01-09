package org.hamcrest.core
{
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;
    import org.hamcrest.Matcher;

    /**
     * Shortcuts with a given shortcut on the first Matcher that does not match shortcut value.
     *
     * @see org.hamcrest.core.AnyOfMatcher
     *
     * @author Drew Bourne
     */
    public class ShortcutCombinationMatcher extends BaseMatcher
    {
        private var _matchers:Array;
        private var _operator:String;

        /**
         * Constructor.
         *
         * @param matchers Array of Matchers to matcher with.
         * @param operator description of the shortcut operation.
         */
        public function ShortcutCombinationMatcher(matchers:Array, operator:String)
        {
            super();

            // TODO ensure matchers are actually Matcher instances 
            _matchers = matchers || [];
            _operator = operator || "";
        }

        /**
         * @param item Object to match
         * @param shortcut Boolean value to shortcut on if the matcher.matches(item) result does not equal.
         */
        public function matchesOrShortcuts(item:Object, shortcut:Boolean):Boolean
        {
            for each (var matcher:Matcher in _matchers)
            {
                if (matcher.matches(item) == shortcut)
                {
                    return shortcut;
                }
            }

            return !shortcut;
        }

        /**
         * Describes this Matcher, its list of Matchers, and the operator.
         */
        override public function describeTo(description:Description):void
        {
            description.appendList("(", " " + _operator + " ", ")", _matchers);
        }
    }
}
