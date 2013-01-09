package org.hamcrest.date
{
    import org.hamcrest.Matcher;
    import org.hamcrest.core.allOf;
    import org.hamcrest.core.describedAs;
    
    /**
     * Matches if the values is between the min and max values.
     *
     * @param min Minimum value
     * @param max Maximum value
     * @param inclusive
     *    <code>true</code> to allow the value to be equal to the min or max,
     *    <code>false</code> to require the value to be inside the range of the min and max.
     * @return Matcher
     *
     * @example
     * <listing version="3.0">
     * assertThat( new Date() , dateBetween( new Date( 1920, 1, 1 ), new Date( 2200, 1, 1 )) );
     * // passes
     *
     * assertThat(new Date( 2200, 1, 1 ) , dateBetween( new Date( 1920, 1, 1 ), new Date( 2200, 1, 1 ) , true) )
     * // fails
     * </listing>
     */
    public function dateBetween(min:Date, max:Date, exclusive:Boolean=false):Matcher
    {
        if (min > max)
        {
            throw new ArgumentError("min value cannot be greater than the max value");
        }
        
        if (max < min)
        {
            throw new ArgumentError("max value cannot be less than the min value");
        }
        
        var matcher:Matcher = !exclusive
            ? allOf(dateBeforeOrEqual(max), dateAfterOrEqual(min))
            : allOf(dateBefore(max), dateAfter(min));
        
        var description:String = "a date between %0 and %1";
        if (exclusive)
        {
            description += " exclusive";
        }
        
        return describedAs(description, matcher, min, max);
    }
}
