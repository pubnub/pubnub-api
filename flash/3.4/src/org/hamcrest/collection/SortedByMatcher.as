package org.hamcrest.collection
{
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import org.hamcrest.BaseMatcher;
	import org.hamcrest.Description;

	/**
	 * Matches if the item being matched is an Array sorted by the given field, 
	 * and flags. 
	 * 
	 * @see org.hamcrest.collection#sortedBy
	 * 
	 * @example
	 * <listing version="3.0">
	 * 	assertThat([{ value: 1 }, { value: 3 }], sortedBy('value', false, false, true));
	 * </listing>
	 * 
	 * @author Drew Bourne
	 */
	public class SortedByMatcher extends BaseMatcher
	{
		private var _field:String;
		private var _caseInsensitive:Boolean;
		private var _descending:Boolean;
		private var _numeric:Boolean;
		
		/**
	     * Constructor.
	     * 
	     * @param field Name of the field or property to sort by
	     * @param caseInsensitive Indicates if the field values should be compared case-insensitive.  
	     * @param descending Indicates if the field values should be compared in descending order
	     * @param numeric Indicates if the field value should be considered numeric. 
	     */
		public function SortedByMatcher(
			field:String, 
			caseInsensitive:Boolean = false, 
			descending:Boolean = false, 
			numeric:Boolean = false)
		{
			super();
			
			_field = field;
			_caseInsensitive = caseInsensitive;
			_descending = descending;
			_numeric = numeric;
		}
		
		/**
		 * Matches if the item being matched is an Array sorted by the given field, 
	     * and flags. 
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
            sorted.sort.fields = [new SortField(_field, _caseInsensitive, _descending, _numeric)];
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
            description.appendText("an Array sorted by ").appendValue(_field);
        }
	}
}