package org.hamcrest.core
{
    import org.hamcrest.Matcher;
    import org.hamcrest.object.instanceOf;

    /**
     * Matches if the item under test is a Function, and throws an Error matching the given Matcher.
     *
     * @see org.hamcrest.core.ThrowsMatcher
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
    public function throws(error:Object):Matcher
    {
        if (error is Class)
        {
            return throws(instanceOf(error as Class));
        }
        else if (error is Matcher)
        {
            return new ThrowsMatcher(error as Matcher);
        }
        else
        {
            throw new ArgumentError("error must be either Class or Matcher");
        }
    }
}
