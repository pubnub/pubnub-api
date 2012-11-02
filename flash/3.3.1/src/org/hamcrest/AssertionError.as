package org.hamcrest
{

    /**
     * Thrown by <code>assertThat</code>.
     *
     * @see org.hamcrest#assertThat()
     *
     * @author Drew Bourne
     */
    public class AssertionError extends Error
    {
        private var _cause:Error;
		private var _matcherDescription:String;
		private var _mismatchDescription:String;
		private var _value:*;

        /**
		 * Constructor.
		 * 
         * @param message Description of assertion failure
         * @param cause Error that caused the assertion failure, or null.
         */
        public function AssertionError(message:String, cause:Error = null,
									   matcherDescription:String = null,
									   mismatchDescription:String = null, 
									   value:* = undefined)
        {
            super(message);
            _cause = cause;
			_matcherDescription = matcherDescription;
			_mismatchDescription = mismatchDescription;
			_value = value;
        }

        /**
         * @return Error that caused the assertion failure, or null.
         */
        public function get cause():Error
        {
            return _cause;
        }
		
		/**
		 * @return Description of the Matcher that caused this AssertionError.
		 */
		public function get matcherDescription():String 
		{
			return _matcherDescription;
		}
		
		/**
		 * @return Description of the Mismatch that caused this AssertionError.
		 */
		public function get mismatchDescription():String 
		{
			return _mismatchDescription;
		}
		
		/**
		 * @return Value that caused this AssertionError.
		 */
		public function get value():*
		{
			return _value;
		}

        /**
         * @return String including the stack trace from <code>cause</code>.
         */
        override public function getStackTrace():String
        {
            var stackTrace:String = super.getStackTrace();

            if (_cause)
            {
                stackTrace += "\n\n";
                stackTrace += "Nested Error:\n";
                stackTrace += _cause.getStackTrace();
            }

            return stackTrace;
        }
    }
}
