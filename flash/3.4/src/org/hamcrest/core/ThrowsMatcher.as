package org.hamcrest.core
{
    import org.hamcrest.Description;
    import org.hamcrest.Matcher;
    import org.hamcrest.TypeSafeDiagnosingMatcher;
    import org.hamcrest.TypeSafeMatcher;

    /**
     * Matches if the item under test is a Function, and throws an Error matching the given Matcher.
     *
     * @see org.hamcrest.core#throws()
     *
     * @example
     * <listing version="3.0">
     *  assertThat(function():void {
     *      systemUnderTest.methodCall(given, bad, args);
     *  }, throws(allOf(
     *      instanceOf(OhNoItsAnError),
     *      hasPropertyWithValue("message", "oh no"))));
     * </listing>
     *
     * @author Drew Bourne
     */
    public class ThrowsMatcher extends TypeSafeMatcher
    {
        private var _matcher:Matcher;
		private var _thrownError:Error;

        /**
         * Constructor.
         *
         * @param matcher Matcher to match the thrown error with.
         */
        public function ThrowsMatcher(matcher:Matcher)
        {
            super(Function);
            _matcher = matcher;
        }

        /**
         * @inheritDoc
         */
        override public function matchesSafely(item:Object):Boolean
        {
			// reset cached error to ensure matching and mismatch descriptions are correct
			_thrownError = null;
			
            var closure:Function = item as Function;
            var thrown:Boolean = false;
            var error:Error = null;

            try
            {
                closure();
            }
            catch (e:Error)
            {
                _thrownError = error = e;
				
                if (_matcher.matches(e))
                {
                    thrown = true;
                }
                else
                {
                    throw e;
                }
            }
            finally
            {
                return thrown;
            }
        }

        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            description.appendDescriptionOf(_matcher).appendText(" to be thrown");
        }
		
		/**
		 * @inheritDoc
		 */
		override public function describeMismatch(item:Object, mismatchDescription:Description):void
		{
			if (_thrownError) 
			{
				mismatchDescription.appendMismatchOf(_matcher, _thrownError);
			}
			else
			{
				mismatchDescription.appendText("was not thrown");
			}
			
		}
    }
}
