package org.hamcrest.collection
{
    import org.hamcrest.Description;
    import org.hamcrest.Matcher;
    import org.hamcrest.TypeSafeMatcher;

    /**
     * Creates a Matcher that only matches if each of the matchers given are satisfied by the
     * element at the same index in the array that is being matched.
     *
     * Matcher will fail if the number of items in the array being matched does not equal the number
     * of matchers given to this Matcher.
     *
     * @see org.hamcrest.collection#array()
     * @example
     * <listing version="3.0">
     *  // explicit definition of matchers
     *  assertThat([1, 1.9, 4], array(equalTo(1), closeTo(2, 0.1), equalTo(4));
     *
     *  // implicit conversion to equalTo()
     *  assertThat([1, 1.9, 4], array(1, 2, 4));
     *  // fails as item at index 2 is not equal to 2
     *
     *  // must be the same length
     *  assertThat([1, 2], array(1, 2, 3));
     *  // fails as different lengths
     * </listing>
     *
     * @author Drew Bourne
     */
    public class IsArrayMatcher extends TypeSafeMatcher
    {
        private var _elementMatchers:Array;

        /**
         * Constructor.
         *
         * @param elementMatchers
         */
        public function IsArrayMatcher(elementMatchers:Array)
        {
            super(Object);
            
            _elementMatchers = elementMatchers;
        }

        /**
         * @inheritDoc
         */
        override public function matchesSafely(item:Object):Boolean
        {
            var array:Array = toArray(item);
            
            if (array.length != _elementMatchers.length)
            {
                return false;
            }
            
            function matchesElement(matcher:Matcher, i:int, a:Array):Boolean
            {
                return matcher.matches(array[i]);
            }

            return _elementMatchers.every(matchesElement);
        }

        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendList(descriptionStart(), descriptionSeparator(), descriptionEnd(), _elementMatchers);
        }

        /**
         * @private
         */
        protected function descriptionStart():String
        {
            return "[";
        }

        /**
         * @private
         */
        protected function descriptionSeparator():String
        {
            return ", ";
        }

        /**
         * @private
         */
        protected function descriptionEnd():String
        {
            return "]";
        }
    }
}

/**
 * Converts an Array-like Object to an Array.
 * 
 * @param iterable Object
 * @returns Array
 */
internal function toArray(iterable:Object):Array 
{
    var result:Array = [];
	
	for each (var item:Object in iterable)
	{
		result[result.length] = item;
	}
	
	return result;		
}