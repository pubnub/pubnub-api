package org.hamcrest
{

    /**
     * Used internally by <code>assertThat</code>.
     *
     * @param reason Description of failure if <code>result</code> is <code>false</code>.
     * @param result Boolean indicating a pass if <code>true</code> or a failure if <code>false</code>
     *
     * @private
     *
     * @author Drew Bourne
     */
    internal function assertThatBoolean(reason:String, result:Boolean):void
    {
        if (!result)
        {
            throw new AssertionError(reason, null, null, null, result);
        }
    }
}
