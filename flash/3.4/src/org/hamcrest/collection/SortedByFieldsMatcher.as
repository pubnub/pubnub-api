package org.hamcrest.collection
{
    import mx.collections.ArrayCollection;
    import mx.collections.ListCollectionView;
    import mx.collections.Sort;
    import mx.collections.SortField;
    
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;

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
	 * @see org.hamcrest.collection#sortedByFields
     * 
     * @author Drew Bourne
     */
    public class SortedByFieldsMatcher extends BaseMatcher
    {
        private var _sortFields:Array;
        
        /**
         * Constructor.
         * 
         * @param sortFields
         */
        public function SortedByFieldsMatcher(sortFields:Array)
        {
            super();
            
            _sortFields = sortFields || [];
        }
        
        /**
         * Matches if the item being matched is an Array sorted by the given array 
         * of SortField instanes. 
         */
        override public function matches(item:Object):Boolean
        {
            if (item is Array)
            {
                item = new ArrayCollection(item as Array);
            }
            
            if (!(item is ListCollectionView))
            {
                return false;
            }
            
            var original:ListCollectionView = item as ListCollectionView;
            
            // create a sorted version of the collection
            var sorted:ListCollectionView = new ListCollectionView(original);
            sorted.sort = new Sort();
            sorted.sort.fields = _sortFields;
            sorted.refresh();
            
            // compare items
            for (var i:int = 0, n:int = original.length; i < n; i++)
            {
                var originalItem:Object = original[i];
                var sortedItem:Object = sorted[i];
                if (originalItem !== sortedItem)
                {
        	        return false;
                }
            }
        
            return true;
        }
        
        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendText("an Array sorted by ");
            
            var fieldNames:Array = [];
            for each (var sortField:SortField in _sortFields)
            {
                fieldNames[fieldNames.length] = sortField.name; 
            }
            description.appendValue(fieldNames);
        }
    }
}