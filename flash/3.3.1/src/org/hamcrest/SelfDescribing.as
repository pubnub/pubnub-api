package org.hamcrest
{

    // TODO example SelfDescribing
    /**
     * An implementation of SelfDescribing should describe itself in as much detail as relevant.
     *
     * @author Drew Bourne
     */
    public interface SelfDescribing
    {
        /**
         * Given a Description, an implementation should describe itself is as much detail as relevant.
         */
        function describeTo(description:Description):void;
    }
}
