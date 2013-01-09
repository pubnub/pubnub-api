package org.hamcrest.object
{
	import flash.utils.describeType;
	
	import org.hamcrest.BaseMatcher;
	import org.hamcrest.Description;

	public class IsInterfaceMatcher extends BaseMatcher
	{
		override public function matches(item:Object):Boolean
		{
			if (item is Class)
			{
				var type:XML = describeType(item);
				return (type.factory.extendsClass.length() == 0);
			}
			
			return false;
		}
		
		override public function describeTo(description:Description):void
		{
			description.appendText("an interface");
		}
	}
}