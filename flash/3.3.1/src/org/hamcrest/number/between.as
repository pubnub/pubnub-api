package org.hamcrest.number
{
    import org.hamcrest.Matcher;
    import org.hamcrest.core.allOf;
    import org.hamcrest.core.describedAs;
    
    /**
     * Matches if the values is between the min and max values.
     *
     * @param min Minimum value
     * @param max Maximum value
     * @param exclusive
     *    <code>false</code> to allow the value to be equal to any number between the min or max,
     *    <code>true</code> to require the value to be inside the range of the min and max but not equal to min or max.
	 * 
     * @return Matcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat(2, between(2, 4));
     *  // passes
     *
     *  assertThat(2, between(2, 4, true));
     *  // fails
     * </listing>
     *
     * @author Drew Bourne
     */
    public function between(min:Number, max:Number, exclusive:Boolean=false):Matcher
    {
        if (min > max)
        {
            throw new ArgumentError("min value cannot be greater than the max value");
        }
        
        if (max < min)
        {
            throw new ArgumentError("max value cannot be less than the min value");
        }
        
        var matcher:Matcher = exclusive
			? allOf(greaterThan(min), lessThan(max))
			: allOf(greaterThanOrEqualTo(min), lessThanOrEqualTo(max));
        
        var description:String = "a Number between %0 and %1";
        if (exclusive)
        {
            description += " exclusive";
        }
        
        return describedAs(description, matcher, min, max);
    }
}
