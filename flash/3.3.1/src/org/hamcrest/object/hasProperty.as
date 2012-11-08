package org.hamcrest.object
{
    import org.hamcrest.Matcher;
    
    /**
     * Matches if <code>item.hasOwnProperty(propertyName)</code> is <code>true</code>.
     *
     * @param propertyName Name of the property the item being matched must have.
     * @param valueOrMatcher Optional value or Matcher to compare the property value against.
     *
     * @see org.hamcrest.object#hasPropertyWithValue()
     * @see org.hamcrest.object#hasPropertyChain()
     * @see org.hamcrest.object.HasPropertyMatcher
     * @see org.hamcrest.object.HasPropertyWithValueMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat({ id: 1234, data: null }, hasProperty("data"));
     *  assertThat({ id: 1234, data: null }, hasProperty("data", nullValue()));
     * </listing>
     *
     * @author Drew Bourne
     */
    public function hasProperty(propertyName:String, ... rest):Matcher
    {
        switch (rest.length)
        {
            case 0:
                return new HasPropertyMatcher(propertyName);
            case 1:
                return hasPropertyWithValue(propertyName, rest[0]);
            default:
                throw new ArgumentError('hasProperty accepts 1 or 2 arguments only.');
        }
        
        return null;
    }
}
