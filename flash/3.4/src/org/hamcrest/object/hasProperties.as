package org.hamcrest.object
{
    import org.hamcrest.Matcher;
    import org.hamcrest.core.allOf;

    /**
     * Matches if <code>item.hasOwnProperty(propertyName)</code> is <code>true</code>, and the value
     * for that property matches the valueMatcher for each of the key-value pairs in the given object.
     *
     * @see org.hamcrest.object#hasPropertyWithValue()
     *
     * @example
     * <listing version="3.0">
     *  var event:Event = new Event(Event.COMPLETE, true, false);
     *  assertThat(event, hasProperties({
     *    type: equalTo(Event.COMPLETE),
     *    bubbles: true // automatically wrapped in equalTo()
     *    cancelable: anything()
     *  }))
     * </listing>
     * 
     * @author Drew Bourne
     */
    public function hasProperties(properties:Object):Matcher
    {
		return new HasPropertiesMatcher(properties);
		
//        var matchers:Array = [];
//        for (var field:String in object)
//        {
//            var value:Object = object[field];
//            var valueMatcher:Matcher = value is Matcher ? value as Matcher : equalTo(value);
//            var propertyMatcher:Matcher = hasPropertyWithValue(field, valueMatcher);
//            matchers.push(propertyMatcher);
//        }
//
//        // TODO determine if this is still the case
//        // NB anonymous objects seem to be iterating their fields in reverse order
//        return allOf.apply(null, matchers.reverse());
    }
}
