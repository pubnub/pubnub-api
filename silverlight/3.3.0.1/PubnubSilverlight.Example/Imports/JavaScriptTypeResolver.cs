namespace System.Web.Script.Serialization
{
    using System;

    public abstract class JavaScriptTypeResolver
    {
        protected JavaScriptTypeResolver()
        {
        }

        public abstract Type ResolveType(string id);
        public abstract string ResolveTypeId(Type type);
    }
}