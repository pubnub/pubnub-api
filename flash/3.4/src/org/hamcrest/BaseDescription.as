package org.hamcrest
{
    import flash.errors.IllegalOperationError;

    /**
     * Basic implementation of Description, normalises all methods to call <code>append</code>.
     *
     * Subclasses should override <code>append</code> to collect the result.
     *
     * @see org.hamcrest.StringDescription
     *
     * @author Drew Bourne
     */
    public class BaseDescription implements Description
    {
        /**
         * Map of special characters to use in the <code>toActionScriptSyntax</code> / <code>charToActionScriptSyntax</code>.
         *
         * @private
         */
        private static const charToActionScriptSyntaxMap:Object = { '"': "\\\"", "\n": "\\n", "\r": "\\r", "\t": "\\t" };

        /**
         * Constructor
         *
         * @private
         */
        public function BaseDescription()
        {
            super();
        }

        /**
         * Abstract. Subclasses should override <code>toString</code> to return the result.
         */
        public function toString():String
        {
            throw new IllegalOperationError("BaseDescription#toString is abstract and must be overriden by a subclass");
        }

        /**
         * @inheritDoc
         */
        public function appendText(text:String):Description
        {
            append(text);
            return this;
        }

        /**
         * @inheritDoc
         */
        public function appendDescriptionOf(value:SelfDescribing):Description
        {
            value.describeTo(this);
            return this;
        }
        
        /**
         * @inheritDoc
         */
        public function appendMismatchOf(matcher:Matcher, value:*):Description
        {
            matcher.describeMismatch(value, this);
            return this;
        }

        // TODO document output results for the various types of object.
        /**
         * @inheritDoc
         */
        public function appendValue(value:Object):Description
        {
            if (value == null)
            {
                append("null");
            }
            else if (value is String)
            {
                append('"');
                toActionScriptSyntax(value);
                append('"');
            }
            else if (value is Number)
            {
                append("<");
                append(value);
                append(">");
            }
            else if (value is Array)
            {
                appendValueList("[", ",", "]", value as Array);
            }
            else if (value is XML)
            {
                append(XML(value).toXMLString());
            }
			else if (value is Date)
			{
				var date:Date = value as Date;

				function pad(value:int):String 
				{
					return value < 10 
						? "0" + value.toString(10) 
						: value.toString(10);
				}
				
				function pad3(value:int):String 
				{
					return value < 10 
						? "00" + value.toString(10)
						: value < 100 
						? "0" + value.toString(10) 
						: value.toString(10);
				}
				
				append("<");
				append(date.fullYear);
				append("-");
				append(pad(date.month + 1));
				append("-");
				append(pad(date.date))
				append("T");
				append(pad(date.hours));
				append(":");
				append(pad(date.minutes));
				append(":");
				append(pad(date.seconds));
				append(".");
				append(pad3(date.milliseconds))
				append(">");
			}
			else if (value is Function)
			{
				append("<Function>");
			}
            else
            {
                append("<");
                append(value);
                append(">");
            }

            return this;
        }

        /**
         * @inheritDoc
         */
        public function appendValueList(start:String, separator:String, end:String, list:Array):Description
        {
            return appendList(start, separator, end, list.map(toSelfDescribingValue));
        }

        /**
         * @inheritDoc
         */
        public function appendList(start:String, separator:String, end:String, list:Array):Description
        {
            var separate:Boolean = false;

            append(start);
            
            for each (var item:Object in list)
            {
                if (separate)
                {
                    append(separator);
                }
                
                if (item is SelfDescribing)
                    appendDescriptionOf(item as SelfDescribing);
                else
                    appendValue(item);
                    
                separate = true;
            }
            
            append(end);

            return this;
        }

        /**
         * Subclasses should override <code>append</code> to collect the resulting description.
         */
        protected function append(value:Object):void
        {
            throw new IllegalOperationError("BaseDescription#append is abstract and must be overriden by a subclass");
        }

        // TODO is toSelfDescribingValue used?
        /**
         * @private
         */
        private function toSelfDescribingValue(value:Object, i:int = 0, a:Array = null):SelfDescribingValue
        {
            return new SelfDescribingValue(value);
        }

        /**
         * Converts special characters to printable characters.
         *
         * @private
         */
        private function toActionScriptSyntax(value:Object):void
        {
            String(value).split('').forEach(charToActionScriptSyntax);
        }

        /**
         * Iterator used to append a sequence of characters as printable characters
         *
         * @private
         */
        private function charToActionScriptSyntax(char:String, i:int = 0, a:Array = null):void
        {
            append(charToActionScriptSyntaxMap[char] || char);
        }
    }
}

import org.hamcrest.Description;
import org.hamcrest.SelfDescribing;

internal class SelfDescribingValue implements SelfDescribing
{
    private var _value:Object;

    public function SelfDescribingValue(value:Object)
    {
        _value = value;
    }

    public function describeTo(description:Description):void
    {
        description.appendValue(_value);
    }
}
