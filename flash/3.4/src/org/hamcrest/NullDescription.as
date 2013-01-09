package org.hamcrest
{
    import org.hamcrest.Description;
    import org.hamcrest.SelfDescribing;

    /**
     * No-Op implementation of Description.
     *
     * @author Drew Bourne
     */
    public class NullDescription implements Description
    {
        /**
         * Returns an empty String
         */
        public function toString():String
        {
            return "";
        }

        /**
         * No-op.
         * @return this
         */
        public function appendText(text:String):Description
        {
            return this;
        }

        /**
         * No-op.
         * @return this
         */
        public function appendDescriptionOf(value:SelfDescribing):Description
        {
            return this;
        }
        
        /**
         * No-op.
         * @return this
         */
        public function appendMismatchOf(matcher:Matcher, value:*):Description
        {
            return this;
        }
        
        /**
         * No-op.
         * @return this
         */
        public function appendValue(value:Object):Description
        {
            return this;
        }

        /**
         * No-op.
         * @return this
         */
        public function appendList(start:String, separator:String, end:String, list:Array):Description
        {
            return this;
        }
    }
}
