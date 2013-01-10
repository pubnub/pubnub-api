namespace System.Web.Script.Serialization
{
    using System;

    [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property)]
    public sealed class ScriptIgnoreAttribute : Attribute
    {
    }
}