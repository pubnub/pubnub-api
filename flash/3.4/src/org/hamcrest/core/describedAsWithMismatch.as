package org.hamcrest.core
{
    import org.hamcrest.Matcher;

    /**
     * Wraps another Matcher to return a modified description for <code>describeTo</code>.
     *
     * Can replace values in the description using <code>%n</code> placeholders, where <code>n</code>
     * is a number into the extra values given.
     *
     * @param description Custom message
     * @param mismatchDescription Custom mismatch message
     * @param matcher Matcher to wrap
     * @param ...values replacement values for the message
     *
     * @see org.hamcrest.core.DescribedAsMatcher
     *
     * @example
     * <listing version="3.0">
     *  assertThat(3, describedAsWithMismatch("%0 is a magic number", "%0 is not magic", equalTo(4), 4);
     * </listing>
     *
     * @author Drew Bourne
     */
    public function describedAsWithMismatch(description:String, mismatchDescription:String, matcher:Matcher, ... values):Matcher
    {
        return new DescribedAsMatcher(description, matcher, values, mismatchDescription);
    }
}
