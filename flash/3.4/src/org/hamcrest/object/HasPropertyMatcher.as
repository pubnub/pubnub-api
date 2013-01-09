package org.hamcrest.object
{
    
    import org.hamcrest.Description;
    import org.hamcrest.TypeSafeMatcher;
    
    /**
     * Matches if <code>item.hasOwnProperty(propertyName)</code> is <code>true</code>.
     *
     * @see org.hamcrest.object#hasProperty()
     *
     * @author Drew Bourne
     */
    public class HasPropertyMatcher extends TypeSafeMatcher
    {
        private var _propertyName:String;
        
        /**
         * Constructor.
         *
         * @param propertyName Name of the property the item being matched must have.
         */
        public function HasPropertyMatcher(propertyName:String)
        {
            super(Object);
            _propertyName = propertyName;
        }
        
        /**
         * @inheritDoc
         */
        override public function matchesSafely(item:Object):Boolean
        {
            return item.hasOwnProperty(_propertyName);
        }
        
        /**
         * @inheritDoc
         */
        override public function describeMismatch(item:Object, mismatchDescription:Description):void
        {
            mismatchDescription
                .appendText("no property ")
                .appendValue(_propertyName)
                .appendText(" on ")
                .appendValue(item);
        }
        
        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendText("has property ").appendValue(_propertyName);
        }
    
    }
}
