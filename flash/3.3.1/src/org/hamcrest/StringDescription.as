package org.hamcrest
{
	
	/**
	 * Description implementation that appends to a <code>String</code>.
	 *
	 * To get result call <code>toString()</code>.
	 *
	 * @see org.hamcrest.Description
	 *
	 * @author Drew Bourne
	 */
	public class StringDescription extends BaseDescription
	{
		/**
		 * Converts a <code>SelfDescribing</code> implementation into a <code>String</code>.
		 *
		 * @see org.hamcrest.SelfDescribing
		 */
		public static function toString(selfDescribing:SelfDescribing):String
		{
			return (new StringDescription()).appendDescriptionOf(selfDescribing).toString();
		}
		
		private var _out:String;
		
		/**
		 * Constructor.
		 */
		public function StringDescription()
		{
			clear();
		}
		
		/**
		 * Appends the string to the description.
		 */
		override protected function append(string:Object):void
		{
			_out += String(string);
		}
		
		/**
		 * Clears the StringDescription buffer.
		 */
		public function clear():void
		{
			_out = "";
		}
		
		/**
		 * Returns a String of the description.
		 */
		override public function toString():String
		{
			return _out;
		}
	}
}
