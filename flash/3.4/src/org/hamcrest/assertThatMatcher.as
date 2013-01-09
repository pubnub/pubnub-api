package org.hamcrest
{
    /**
     * Used internally by <code>assertThat</code>.
     *
     * @param reason Description of failure should <code>actual</code> not match <code>matcher</code>
     * @param actual Object to match
     * @param matcher Matcher to match <code>actual</code> with.
     *
     * @author Drew Bourne
     */
    internal function assertThatMatcher(reason:String, actual:Object, matcher:Matcher):void
    {
        if (!matcher.matches(actual))
        {
			var errorDescription:Description = new StringDescription();
            var matcherDescription:Description = new StringDescription();
			var mismatchDescription:Description = new StringDescription();

            if (reason && reason.length > 0)
            {
				errorDescription
                    .appendText(reason)
                    .appendText("\n");
            }

			errorDescription
                .appendText("Expected: ")
                .appendDescriptionOf(matcher)
                .appendText("\n     but: ")
                .appendMismatchOf(matcher, actual);

			matcherDescription.appendDescriptionOf(matcher);
			
			mismatchDescription.appendMismatchOf(matcher, actual);
				
            throw new AssertionError(
				errorDescription.toString(), 
				null, 
				matcherDescription.toString(), 
				mismatchDescription.toString(), 
				actual);
        }
    }
}
