package org.hamcrest.core
{
    import org.hamcrest.Matcher;
    import org.hamcrest.object.equalTo;
    import org.hamcrest.object.instanceOf;

    // TODO example isA
    /**
     * Decorates another Matcher, retaining the behavior but allowing tests
     * to be slightly more expressive.
     *
     * @see org.hamcrest.core.IsMatcher
     *
     * @author Drew Bourne
     */
    public function isA(value:Object):Matcher
    {
        if (value is Class)
        {
            return isA(instanceOf(value as Class));
        }

        if (value is Matcher)
        {
            return new IsMatcher(value as Matcher);
        }

        return isA(equalTo(value));
    }
}
