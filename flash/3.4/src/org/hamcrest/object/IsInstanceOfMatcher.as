package org.hamcrest.object
{
    import flash.utils.getQualifiedClassName;
    
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;
    
    /**
     * Matches if the item is an instance of the given type.
     *
     * @see org.hamcrest.object#instanceOf()
     *
     * @exmaple
     * <listing version="3.0">
     *  assertThat("waffles", instanceOf(String));
     * </listing>
     *
     * @author Drew Bourne
     */
    public class IsInstanceOfMatcher extends BaseMatcher
    {
        private var _type:Class;
        private var _typeName:String;
        
        /**
         * Constructor
         *
         * @param type Class the item must be an instance of.
         */
        public function IsInstanceOfMatcher(type:Class)
        {
            _type = type;
            _typeName = getQualifiedClassName(type);
        }
        
        /**
         * @inheritDoc
         */
        override public function matches(item:Object):Boolean
        {
            return item is _type;
        }
        
        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendText("an instance of ").appendText(_typeName);
        }
    }
}
