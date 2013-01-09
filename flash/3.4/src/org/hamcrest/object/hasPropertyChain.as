package org.hamcrest.object
{
    import org.hamcrest.Matcher;
    
    /**
     * Matches an object with properties for each link in the given property 
     * chain, optionally checking for an expected value.
     * 
     * @see org.hamcrest.object#hasProperty()
     * @see org.hamcrest.object#hasPropertyWithValue()
     * @see org.hamcrest.object.HasPropertyChainMatcher
     * 
     * @example
     * <listing version="3.0">
     *    assertThat({ one: { two: 3 } }, hasPropertyChain("one.two"));
     *    assertThat({ one: { two: 3 } }, hasPropertyChain("one.two", equalTo(3)));
     * </listing> 
     * 
     * @author Drew Bourne 
     */
    public function hasPropertyChain(propertyChain:Object, valueOrMatcher:Object = null):Matcher 
    {
        var valueMatcher:Matcher 
            = valueOrMatcher is Matcher
            ? valueOrMatcher as Matcher
            : valueOrMatcher != null
            ? equalTo(valueOrMatcher)
            : null;        
        
        return new HasPropertyChainMatcher(propertyChain, valueMatcher);
    }
}