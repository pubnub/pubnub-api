package org.hamcrest.object
{
    import org.hamcrest.Matcher;
    
    /**
     * Matches if <code>item.hasOwnProperty(propertyName)</code> is <code>true</code>, and the value
     * for that property matches the given valueMatcher.
     *
     * @param propertyName Name of the property the item being matched must have.
     *
     * @see org.hamcrest.object#hasProperty()
     * @see org.hamcrest.object#hasPropertyChain() 
     * @see org.hamcrest.object.HasPropertyWithValueMatcher
     * 
     * @example
     * <listing version="3.0">
     *  assertThat({ id: 1234, data: [1, 2, 3] }, hasPropertyWithValue("data", everyItem(isA(Number))));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function hasPropertyWithValue(propertyName:String, valueOrMatcher:Object):Matcher
    {
        var valueMatcher:Matcher 
            = valueOrMatcher is Matcher
            ? valueOrMatcher as Matcher
            : equalTo(valueOrMatcher);
        
        return new HasPropertyWithValueMatcher(propertyName, valueMatcher);
    }
}
