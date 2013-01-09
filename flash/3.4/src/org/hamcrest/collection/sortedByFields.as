package org.hamcrest.collection
{
    import org.hamcrest.Matcher;
    
    /**
     * Matches if the item being matched is an Array sorted by the given array 
     * of SortField instanes. 
     * 
     * @param sortFields Array of SortField
     * @return Matcher 
     * 
     * @example
	 * <listing version="3.0">
	 * 	assertThat(
	 *    [
	 *    { field1: 1, field2: 1 }, 
	 *    { field1: 1, field2: 2 },
	 *    { field1: 2, field2: 2 },
	 *    ], 
	 *    sortedByFields([new SortField('field1'), new SortField('field2')]));
	 * </listing>
     * 
     * @author Drew Bourne
     */
    public function sortedByFields(sortFields:Array):Matcher
    {
        return new SortedByFieldsMatcher(sortFields);
    }
}