package org.hamcrest.collection
{
    import org.hamcrest.Description;
    import org.hamcrest.DiagnosingMatcher;
    import org.hamcrest.Matcher;
    import org.hamcrest.TypeSafeMatcher;
    
    /**
     * Checks the item being matched is an <code>Array</code> and has the expected number of items.
     *
     * @see org.hamcrest.collection#arrayWithSize()
     * @see org.hamcrest.collection#emptyArray()
     *
     * @example
     * <listing version="3.0">
     *  assertThat([true, false], arrayWithSize(2));
     * </listing>
     *
     * @author Drew Bourne
     */
    public class IsArrayWithSizeMatcher extends DiagnosingMatcher
    {
        private var _sizeMatcher:Matcher;
        
        /**
         * Constructor.
         *
         * @param sizeMatcher should be an instance of equalTo(n) where n is the expected size.
         */
        public function IsArrayWithSizeMatcher(sizeMatcher:Matcher)
        {
            super();
            
            _sizeMatcher = sizeMatcher;
        }
        
        /**
         * @inheritDoc
         */
        override protected function matchesOrDescribesMismatch(item:Object, description:Description):Boolean
        {
			// bail out for obvious non-iterable objects
			if (!isIterable(item))
			{
				description.appendText("was ").appendValue(item);
				return false;
			}
			
			// otherwise convert with for-each to an Array
            var array:Array = toArray(item);
            var result:Boolean = true;
			
            if (!_sizeMatcher.matches(array.length))
            {
                description
                    .appendText("size ")
                    .appendMismatchOf(_sizeMatcher, array.length);
                    
                result = false;
            }
            
            return result;
        }
        
        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description
                .appendText("an Array with size ")
                .appendDescriptionOf(_sizeMatcher);
        }
    }
}

import flash.utils.Proxy;
import flash.utils.getQualifiedClassName;

/**
 * Naive checks for an potential iterable objects.
 */
internal function isIterable(item:Object):Boolean
{
	if (item is Array)
		return true;
	
	// Proxy is often used for for-each iterable objects
	if (item is Proxy)
		return true;
	
	// Vectors dont with nicely with 'is' unless with know the type it is expecting
	if (getQualifiedClassName(item).indexOf('__AS3__.vec::Vector') == 0)
		return true;
		
	return false;
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