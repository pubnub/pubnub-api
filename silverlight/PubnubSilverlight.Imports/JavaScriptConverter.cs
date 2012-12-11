namespace System.Web.Script.Serialization
{
    using System;
    using System.Collections.Generic;

    public abstract class JavaScriptConverter
    {
        protected JavaScriptConverter()
        {
        }

        public abstract object Deserialize(IDictionary<string, object> dictionary, Type type, JavaScriptSerializer serializer);
        public abstract IDictionary<string, object> Serialize(object obj, JavaScriptSerializer serializer);

        public abstract IEnumerable<Type> SupportedTypes { get; }
    }
}