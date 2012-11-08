package org.hamcrest.object
{
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;
    
    /**
     * Checks the item being matched is equal (==).
     *
     * <ul>
     * <li><code>Number</code>s match if they are equal (==) </li>
     * <li><code>Number</code>s match if they are both <code>NaN</code>. </li>
     * <li><code>null</code>s match.</li>
     * <li><code>Array</code>s match if they are the same length and each item is equal.
     *  Checked recursively for child arrays. </li>
     * </ul>
     *
     * @see org.hamcrest.object#equalTo()
     *
     * @example
     * <listing version="3.0">
     *  assertThat("hi", equalTo("hi"));
     *  assertThat("bye", not(equalTo("hi")));
     * </listing>
     *
     * @author Drew Bourne
     */
    public class IsEqualMatcher extends BaseMatcher
    {
        private var _value:Object;
        
        /**
         * Constructor
         *
         * @param value Object the item being matched must be equal to
         */
        public function IsEqualMatcher(value:Object)
        {
            super();
            
            _value = value;
        }
        
        /**
         * @inheritDoc
         */
        override public function matches(item:Object):Boolean
        {
            return areEqual(item, _value);
        }
        
        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendValue(_value);
        }
        
        /**
         * Checks if the given items are equal
         *
         * @private
         */
        private function areEqual(o1:Object, o2:Object):Boolean
        {
            // remember your NaN is super special, give her a call, she'll appreciate it.
            if (isNaN(o1 as Number))
            {
                return isNaN(o2 as Number);
            }
            else if (o1 == null)
            {
                return o2 == null;
            }
            else if (o1 is Array)
            {
                return o2 is Array && areArraysEqual(o1 as Array, o2 as Array);
            }
            else
            {
                return o1 == o2;
            }
        }
        
        /**
         * Checks if the given arrays are of equal length, and contain the same elements.
         *
         * @private
         */
        private function areArraysEqual(o1:Array, o2:Array):Boolean
        {
            return areArraysLengthsEqual(o1, o2) && areArrayElementsEqual(o1, o2);
        }
        
        /**
         * Checks if the given arrays are of equal length
         *
         * @private
         */
        private function areArraysLengthsEqual(o1:Array, o2:Array):Boolean
        {
            return o1.length == o2.length;
        }
        
        /**
         * Checks the elements of both arrays are the equal
         *
         * @private
         */
        private function areArrayElementsEqual(o1:Array, o2:Array):Boolean
        {
            for (var i:int = 0, n:int = o1.length; i < n; i++)
            {
                if (!areEqual(o1[i], o2[i]))
                {
                    return false;
                }
            }
            return true;
        }
    }
}
