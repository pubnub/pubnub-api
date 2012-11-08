package org.hamcrest.object
{
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;
    
    /**
     * Checks the item being matched are strictly equal (===).
     *
     * @see org.hamcrest.object#strictlyEqualTo()
     *
     * @example
     * <listing version="3.0">
     *  var o1:Object = {};
     *  var o2:Object = {};
     *  assertThat(o1, strictlyEqualTo(o1"));
     *  assertThat(o1, not(strictlyEqualTo(o2)));
     * </listing>
     *
     * @author Drew Bourne
     */
    public class IsStrictlyEqualMatcher extends BaseMatcher
    {
        private var _value:Object;
        
        /**
         * Constructor
         *
         * @param value Object the item being matched must be equal to
         */
        public function IsStrictlyEqualMatcher(value:Object)
        {
            super();
            
            _value = value;
        }
        
        /**
         * @inheritDoc
         */
        override public function matches(item:Object):Boolean
        {
            return _value === item;
        }
        
        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendValue(_value);
        }
    }
}
