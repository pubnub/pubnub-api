package org.hamcrest.object
{
	import org.hamcrest.Description;
	import org.hamcrest.Matcher;
	import org.hamcrest.SelfDescribing;
	import org.hamcrest.TypeSafeDiagnosingMatcher;
	import org.hamcrest.TypeSafeMatcher;

	/**
	 * Matches an item if every property has a matching value.
	 * 
	 * @see org.hamcrest.object#hasProperties()
	 * 
	 * @author Drew Bourne
	 */
	public class HasPropertiesMatcher extends TypeSafeDiagnosingMatcher
	{
		private var _properties:Object;
		
		/**
		 * Constructor.
		 * 
		 * @param properties Anonymous Object of property names and values.
		 */
		public function HasPropertiesMatcher(properties:Object)
		{
			super(Object);
			_properties = properties || {};
		}
		
		/**
		 * @inheritDoc
		 */
		override public function matchesSafely(item:Object, mismatchDescription:Description):Boolean
		{
			var fields:Array = getSortedFields();
			var needsComma:Boolean = false;
			var matched:Boolean = true;
			
			for each (var field:Object in fields)
			{
				// write-only properties may throw a ReferenceError here
				// however I am choosing to ignore it as it should be clear
				// to the user from the existing error message.
				// 
				var value:Object = _properties[field];
				var valueMatcher:Matcher = value is Matcher ? value as Matcher : equalTo(value);
				var propertyMatcher:Matcher = hasPropertyWithValue(String(field), valueMatcher);
				if (!propertyMatcher.matches(item))
				{
					if (needsComma)
						mismatchDescription.appendText(", ");
					
					propertyMatcher.describeMismatch(item, mismatchDescription);
					
					needsComma = true;
					matched = false;
				}
			}
			
			return matched;	
		}
		
		/**
		 * @inheritDoc
		 */
		override public function describeTo(description:Description):void 
		{
			description.appendText("has properties ");
			
			var needsComma:Boolean = false;
			
			// AVM2 does not iterate over fields in an anonymous object
			// in a consistent order. in order for the descrpitions to 
			// be consistent we sort the fields.
			//
			// additional because _properties is mutable 
			// we cannot cache the sorted fields list.
			//
			var fields:Array = getSortedFields();
			
			for each (var field:Object in fields)
			{
				var value:* = _properties[field];
				
				if (needsComma)
					description.appendText(", ");
				
				description
					.appendValue(field)
					.appendText(":");
					
				if (value is SelfDescribing)
					description.appendDescriptionOf(value as SelfDescribing)
				else
					description.appendValue(value);
					
				needsComma = true;
			}
		}
		
		protected function getSortedFields():Array 
		{
			var fields:Array = [];
			var field:Object;
			
			for (field in _properties)
			{
				fields.push(field);				
			}
			fields = fields.sort(Array.CASEINSENSITIVE);
			
			return fields;
		}
	}
}