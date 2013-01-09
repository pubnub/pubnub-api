package org.hamcrest.object
{
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;
    import org.hamcrest.DiagnosingMatcher;
    import org.hamcrest.Matcher;

    /**
     * Matches an object with properties for each link in the given property 
     * chain, optionally checking for an expected value.
     * 
     * @see org.hamcrest.object#hasPropertyChain()
     * 
     * @example
     * <listing version="3.0">
     *    assertThat({ one: { two: 3 } }, hasPropertyChain("one.two"));
     *    assertThat({ one: { two: 3 } }, hasPropertyChain("one.two", equalTo(3)));
     * </listing> 
     * 
     * @author Drew Bourne 
     */
    public class HasPropertyChainMatcher extends DiagnosingMatcher
    {
        private var _propertyChain:Array;
        private var _valueMatcher:Matcher;
        
        public function HasPropertyChainMatcher(propertyChain:Object, valueMatcher:Matcher = null)
        {
            super();
            
            _propertyChain = propertyChain is Array
                ? propertyChain as Array
                : String(propertyChain).split(".");
                
            _valueMatcher = valueMatcher;
        }

        override protected function matchesOrDescribesMismatch(item:Object, description:Description):Boolean
        {
            var current:Object = item;
            
            for each (var property:String in _propertyChain)
            {
                if (current && current.hasOwnProperty(property))
                {
                    current = current[property];
                }
                else
                {
                    description
                        .appendText("missing property ")
                        .appendValue(property);
                    
                    return false;
                }
            }
            
            if (_valueMatcher && !_valueMatcher.matches(current))
            {
                description.appendMismatchOf(_valueMatcher, current);
                
                return false;
            }
            
            return true;
        }
        
        override public function describeTo(description:Description):void
        {
            description
                .appendText("has property chain ")
                .appendValue(_propertyChain.join("."));
                
            if (_valueMatcher)
            {
                description
                    .appendText(" with a value of ")
                    .appendDescriptionOf(_valueMatcher);
            }
        }
    }
}