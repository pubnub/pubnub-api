package org.hamcrest
{

    /**
     * Description allows an implementation to normalise the description of text, values, and lists from <code>SelfDescribing</code> and<code>Matcher</code> implementations.
     *
     * @see org.hamcrest.Matcher
     * @see org.hamcrest.SelfDescribing
     *
     * @author Drew Bourne
     */
    public interface Description
    {
        /**
         * Should return the collected description
         */
        function toString():String;

        /**
         * Should append text to the result
         */
        function appendText(text:String):Description;

        /**
         * Should append the description of a <code>SelfDescribing</code> to the result.
         */
        function appendDescriptionOf(value:SelfDescribing):Description;
        
        /**
         * Should append the description of a <code>SelfDescribing</code> to the result.
         */
        function appendMismatchOf(matcher:Matcher, value:*):Description;

        /**
         * Should append the value to the result.
         *
         * @example
         * <listing version="3.0">
         *    var result:String = description.appendValue(3).toString();
         *    // result is "&lt;3&gt;"
         * </listing>
         */
        function appendValue(value:Object):Description;

        /**
         * Should append the description of the list, and each of its values to the result.
         *
         * @example
         * <listing version="3.0">
         *    var result:String = description.appendList("[", ",", "]", [1, 2, 3]).toString();
         *    // result is "[1, 2, 3]";
         * </listing>
         */
        function appendList(start:String, separator:String, end:String, list:Array):Description;
    }
}
