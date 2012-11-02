package org.hamcrest.core
{
    import org.hamcrest.BaseMatcher;
    import org.hamcrest.Description;
    import org.hamcrest.Matcher;

    /**
     * Wraps another Matcher to return a modified description for <code>describeTo</code>.
     *
     * Can replace values in the description using <code>%n</code> placeholders, where <code>n</code>
     * is a number into the extra values given.
     *
     * @see org.hamcrest.core#describedAs()
     *
     * @example
     * <listing version="3.0">
     *  assertThat(3, describedAs("%0 is a magic number", equalTo(4), 3);
     * </listing>
     *
     * @author Drew Bourne
     */
    public class DescribedAsMatcher extends BaseMatcher
    {
        private static const ARG_PATTERN:RegExp = /%([\d+])/g;

        private var _descriptionTemplate:String;
        private var _matcher:Matcher;
        private var _values:Array;
        private var _mismatchDescriptionTemplate:String;

        /**
         * Constructor.
         *
         * @param description Custom message
         * @param matcher Matcher to wrap
         * @param values Array of replacement values for the description
         * @param mismatchDescriptionTemplate Custom mismatch message
         */
        public function DescribedAsMatcher(descriptionTemplate:String, matcher:Matcher, values:Array, 
                                           mismatchDescriptionTemplate:String = null)
        {
            _descriptionTemplate = descriptionTemplate;
            _matcher = matcher;
            _values = values;
            _mismatchDescriptionTemplate = mismatchDescriptionTemplate;
        }

        /**
         * @inheritDoc
         */
        override public function matches(item:Object):Boolean
        {
            return _matcher.matches(item);
        }

        /**
         * @inheritDoc
         */
        override public function describeTo(description:Description):void
        {
            var textStart:int = 0;
            
            _descriptionTemplate.replace(ARG_PATTERN, function(... rest):String
                {
                    var index:int = rest[1];
                    description.appendText(_descriptionTemplate.substring(textStart, rest[2]));
                    description.appendValue(_values[index]);
                    textStart = rest[2] + rest[1].length + 1;
                    return "";
                });

            if (textStart < _descriptionTemplate.length)
            {
                description.appendText(_descriptionTemplate.substring(textStart));
            }
        }

        override public function describeMismatch(item:Object, mismatchDescription:Description):void 
        {
            if (!_mismatchDescriptionTemplate)
            {
                return super.describeMismatch(item, mismatchDescription);

                // TODO should we diagnose using the given matcher? 
                // return _matcher.describeMismatch(item, mismatchDescription);
            }

            var textStart:int = 0;
            var values:Array = [ item ].concat(_values);

            _mismatchDescriptionTemplate.replace(ARG_PATTERN, function(... rest):String {
                var index:int = rest[1];
                mismatchDescription.appendText(_mismatchDescriptionTemplate.substring(textStart, rest[2]));
                mismatchDescription.appendValue(values[index]);
                textStart = rest[2] + rest[1].length + 1;
                return "";
            });

            if (textStart < _descriptionTemplate.length)
            {
                mismatchDescription.appendText(_mismatchDescriptionTemplate.substring(textStart));
            }
        }
    }
}
