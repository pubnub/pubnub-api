package org.hamcrest.collection
{
	import org.hamcrest.Matcher;
	
	/**
	 * Matches if the item being matched is an Array sorted by the given field, 
	 * and flags.  
	 * 
	 * @param field
	 * @param caseInsensitive
	 * @param descending
	 * @param numeric
	 * 
	 * @example
	 * <listing version="3.0">
	 * 	assertThat([{ value: 1 }, { value: 3 }], sortedBy('value', false, false, true));
	 * </listing>
	 * 
	 * @author Drew Bourne
	 */
	public function sortedBy(field:String, caseInsensitive:Boolean = false, descending:Boolean = false, numeric:Object = null):Matcher
	{
		return new SortedByMatcher(field, caseInsensitive, descending, numeric);
	}
}