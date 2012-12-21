namespace System.Web.Script.Serialization
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Globalization;
    using System.Reflection;
    using System.Runtime.CompilerServices;
    using System.Runtime.InteropServices;
    using System.Text;
    using System.Web;
    using System.Web.Resources;
    using System.Web.Util;

    public class Hashtable : Dictionary<object, object>
    { }

    public class JavaScriptSerializer
    {
        private Dictionary<Type, JavaScriptConverter> _converters;
        private int _maxJsonLength;
        private int _recursionLimit;
        private JavaScriptTypeResolver _typeResolver;
        internal static readonly long DatetimeMinTimeTicks;
        internal const int DefaultMaxJsonLength = 0x200000;
        internal const int DefaultRecursionLimit = 100;
        internal const string ServerTypeFieldName = "__type";

        static JavaScriptSerializer()
        {
            DateTime time = new DateTime(0x7b2, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            DatetimeMinTimeTicks = time.Ticks;
        }

        public JavaScriptSerializer() : this(null)
        {
        }

        public JavaScriptSerializer(JavaScriptTypeResolver resolver)
        {
            this._typeResolver = resolver;
            this.RecursionLimit = 100;
            this.MaxJsonLength = 0x200000;
        }

        internal bool ConverterExistsForType(Type t, out JavaScriptConverter converter)
        {
            converter = this.GetConverter(t);
            return (converter != null);
        }

        public T ConvertToType<T>(object obj)
        {
            return (T)ObjectConverter.ConvertObjectToType(obj, typeof(T), this);
        }

        public object ConvertToType(object obj, Type targetType)
        {
            return ObjectConverter.ConvertObjectToType(obj, targetType, this);
        }

        public T Deserialize<T>(string input)
        {
            return (T)Deserialize(this, input, typeof(T), this.RecursionLimit);
        }

        public object Deserialize(string input, Type targetType)
        {
            return Deserialize(this, input, targetType, this.RecursionLimit);
        }

        internal static object Deserialize(JavaScriptSerializer serializer, string input, Type type, int depthLimit)
        {
            if (input == null)
            {
                throw new ArgumentNullException("input");
            }
            if (input.Length > serializer.MaxJsonLength)
            {
                throw new ArgumentException(AtlasWeb.JSON_MaxJsonLengthExceeded, "input");
            }
            return ObjectConverter.ConvertObjectToType(JavaScriptObjectDeserializer.BasicDeserialize(input, depthLimit, serializer), type, serializer);
        }

        public object DeserializeObject(string input)
        {
            return Deserialize(this, input, null, this.RecursionLimit);
        }

        private JavaScriptConverter GetConverter(Type t)
        {
            if (this._converters != null)
            {
                while (t != null)
                {
                    if (this._converters.ContainsKey(t))
                    {
                        return this._converters[t];
                    }
                    t = t.BaseType;
                }
            }
            return null;
        }

        public void RegisterConverters(IEnumerable<JavaScriptConverter> converters)
        {
            if (converters == null)
            {
                throw new ArgumentNullException("converters");
            }
            foreach (JavaScriptConverter converter in converters)
            {
                IEnumerable<Type> supportedTypes = converter.SupportedTypes;
                if (supportedTypes != null)
                {
                    foreach (Type type in supportedTypes)
                    {
                        this.Converters[type] = converter;
                    }
                }
            }
        }

        public string Serialize(object obj)
        {
            return this.Serialize(obj, SerializationFormat.JSON);
        }

        public void Serialize(object obj, StringBuilder output)
        {
            this.Serialize(obj, output, SerializationFormat.JSON);
        }

        internal string Serialize(object obj, SerializationFormat serializationFormat)
        {
            StringBuilder output = new StringBuilder();
            this.Serialize(obj, output, serializationFormat);
            return output.ToString();
        }

        internal void Serialize(object obj, StringBuilder output, SerializationFormat serializationFormat)
        {
            this.SerializeValue(obj, output, 0, null, serializationFormat);
            if ((serializationFormat == SerializationFormat.JSON) && (output.Length > this.MaxJsonLength))
            {
                throw new InvalidOperationException(AtlasWeb.JSON_MaxJsonLengthExceeded);
            }
        }

        private static void SerializeBoolean(bool o, StringBuilder sb)
        {
            if (o)
            {
                sb.Append("true");
            }
            else
            {
                sb.Append("false");
            }
        }

        private void SerializeCustomObject(object o, StringBuilder sb, int depth, Hashtable objectsInUse, SerializationFormat serializationFormat)
        {
            bool flag = true;
            Type type = o.GetType();
            sb.Append('{');
            if (this.TypeResolver != null)
            {
                string str = this.TypeResolver.ResolveTypeId(type);
                if (str != null)
                {
                    SerializeString("__type", sb);
                    sb.Append(':');
                    this.SerializeValue(str, sb, depth, objectsInUse, serializationFormat);
                    flag = false;
                }
            }
            foreach (FieldInfo info in type.GetFields(BindingFlags.Public | BindingFlags.Instance))
            {
                if (!info.IsDefined(typeof(ScriptIgnoreAttribute), true))
                {
                    if (!flag)
                    {
                        sb.Append(',');
                    }
                    SerializeString(info.Name, sb);
                    sb.Append(':');
                    //System.Web.SecurityUtils.FieldInfoGetValue(info, o) 
                    this.SerializeValue(info.GetValue(o), sb, depth, objectsInUse, serializationFormat);
                    flag = false;
                }
            }
            foreach (PropertyInfo info2 in type.GetProperties(BindingFlags.GetProperty | BindingFlags.Public | BindingFlags.Instance))
            {
                if (!info2.IsDefined(typeof(ScriptIgnoreAttribute), true))
                {
                    MethodInfo getMethod = info2.GetGetMethod();
                    if ((getMethod != null) && (getMethod.GetParameters().Length <= 0))
                    {
                        if (!flag)
                        {
                            sb.Append(',');
                        }
                        SerializeString(info2.Name, sb);
                        sb.Append(':');
                        //System.Web.SecurityUtils.MethodInfoInvoke(getMethod, o, null)
                        this.SerializeValue(getMethod.Invoke(o, null), sb, depth, objectsInUse, serializationFormat);
                        flag = false;
                    }
                }
            }
            sb.Append('}');
        }

        private static void SerializeDateTime(DateTime datetime, StringBuilder sb, SerializationFormat serializationFormat)
        {
            if (serializationFormat == SerializationFormat.JSON)
            {
                sb.Append("\"\\/Date(");
                sb.Append((long)((datetime.ToUniversalTime().Ticks - DatetimeMinTimeTicks) / 0x2710L));
                sb.Append(")\\/\"");
            }
            else
            {
                sb.Append("new Date(");
                sb.Append((long)((datetime.ToUniversalTime().Ticks - DatetimeMinTimeTicks) / 0x2710L));
                sb.Append(")");
            }
        }

        private void SerializeDictionary(IDictionary o, StringBuilder sb, int depth, Hashtable objectsInUse, SerializationFormat serializationFormat)
        {
            sb.Append('{');
            bool flag = true;
            bool flag2 = false;
            if (o.Contains("__type"))
            {
                flag = false;
                flag2 = true;
                this.SerializeDictionaryKeyValue("__type", o["__type"], sb, depth, objectsInUse, serializationFormat);
            }
            foreach (DictionaryEntry entry in o)
            {
                string key = entry.Key as string;
                if (key == null)
                {
                    throw new ArgumentException(string.Format(CultureInfo.InvariantCulture, AtlasWeb.JSON_DictionaryTypeNotSupported, new object[] { o.GetType().FullName }));
                }
                if (flag2 && string.Equals(key, "__type", StringComparison.Ordinal))
                {
                    flag2 = false;
                }
                else
                {
                    if (!flag)
                    {
                        sb.Append(',');
                    }
                    this.SerializeDictionaryKeyValue(key, entry.Value, sb, depth, objectsInUse, serializationFormat);
                    flag = false;
                }
            }
            sb.Append('}');
        }

        private void SerializeDictionaryKeyValue(string key, object value, StringBuilder sb, int depth, Hashtable objectsInUse, SerializationFormat serializationFormat)
        {
            SerializeString(key, sb);
            sb.Append(':');
            this.SerializeValue(value, sb, depth, objectsInUse, serializationFormat);
        }

        private void SerializeEnumerable(IEnumerable enumerable, StringBuilder sb, int depth, Hashtable objectsInUse, SerializationFormat serializationFormat)
        {
            sb.Append('[');
            bool flag = true;
            foreach (object obj2 in enumerable)
            {
                if (!flag)
                {
                    sb.Append(',');
                }
                this.SerializeValue(obj2, sb, depth, objectsInUse, serializationFormat);
                flag = false;
            }
            sb.Append(']');
        }

        private static void SerializeGuid(Guid guid, StringBuilder sb)
        {
            sb.Append("\"").Append(guid.ToString()).Append("\"");
        }

        internal static string SerializeInternal(object o)
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            return serializer.Serialize(o);
        }

        private static void SerializeString(string input, StringBuilder sb)
        {
            sb.Append('"');
            sb.Append(JavaScriptStringEncode(input));
            sb.Append('"');
        }

        public static string JavaScriptStringEncode(string value)
        {
            return JavaScriptStringEncode(value, false);
        }

        public static string JavaScriptStringEncode(string value, bool addDoubleQuotes)
        {
            string str = HttpEncoder.JavaScriptStringEncode(value);
            if (!addDoubleQuotes)
            {
                return str;
            }
            return ("\"" + str + "\"");
        }

        private static void SerializeUri(Uri uri, StringBuilder sb)
        {
            sb.Append("\"").Append(uri.GetComponents(UriComponents.SerializationInfoString, UriFormat.UriEscaped)).Append("\"");
        }

        private void SerializeValue(object o, StringBuilder sb, int depth, Hashtable objectsInUse, SerializationFormat serializationFormat)
        {
            if (++depth > this._recursionLimit)
            {
                throw new ArgumentException(AtlasWeb.JSON_DepthLimitExceeded);
            }
            JavaScriptConverter converter = null;
            if ((o != null) && this.ConverterExistsForType(o.GetType(), out converter))
            {
                IDictionary<string, object> dictionary = converter.Serialize(o, this);
                if (this.TypeResolver != null)
                {
                    string str = this.TypeResolver.ResolveTypeId(o.GetType());
                    if (str != null)
                    {
                        dictionary["__type"] = str;
                    }
                }
                sb.Append(this.Serialize(dictionary, serializationFormat));
            }
            else
            {
                this.SerializeValueInternal(o, sb, depth, objectsInUse, serializationFormat);
            }
        }

        private void SerializeValueInternal(object o, StringBuilder sb, int depth, Hashtable objectsInUse, SerializationFormat serializationFormat)
        {
            if ((o == null) || DBNull.Value.Equals(o))
            {
                sb.Append("null");
            }
            else
            {
                string input = o as string;
                if (input != null)
                {
                    SerializeString(input, sb);
                }
                else if (o is char)
                {
                    if (((char)o) == '\0')
                    {
                        sb.Append("null");
                    }
                    else
                    {
                        SerializeString(o.ToString(), sb);
                    }
                }
                else if (o is bool)
                {
                    SerializeBoolean((bool)o, sb);
                }
                else if (o is DateTime)
                {
                    SerializeDateTime((DateTime)o, sb, serializationFormat);
                }
                else if (o is DateTimeOffset)
                {
                    DateTimeOffset offset = (DateTimeOffset)o;
                    SerializeDateTime(offset.UtcDateTime, sb, serializationFormat);
                }
                else if (o is Guid)
                {
                    SerializeGuid((Guid)o, sb);
                }
                else
                {
                    Uri uri = o as Uri;
                    if (uri != null)
                    {
                        SerializeUri(uri, sb);
                    }
                    else if (o is double)
                    {
                        sb.Append(((double)o).ToString("r", CultureInfo.InvariantCulture));
                    }
                    else if (o is float)
                    {
                        sb.Append(((float)o).ToString("r", CultureInfo.InvariantCulture));
                    }
                    else if (o.GetType().IsPrimitive || (o is decimal))
                    {
                        IConvertible convertible = o as IConvertible;
                        if (convertible != null)
                        {
                            sb.Append(convertible.ToString(CultureInfo.InvariantCulture));
                        }
                        else
                        {
                            sb.Append(o.ToString());
                        }
                    }
                    else
                    {
                        Type enumType = o.GetType();
                        if (enumType.IsEnum)
                        {
                            Type underlyingType = Enum.GetUnderlyingType(enumType);
                            if ((underlyingType == typeof(long)) || (underlyingType == typeof(ulong)))
                            {
                                throw new InvalidOperationException(AtlasWeb.JSON_InvalidEnumType);
                            }
                            sb.Append(((Enum)o).ToString("D"));
                        }
                        else
                        {
                            try
                            {
                                if (objectsInUse == null)
                                {
                                    //new Hashtable(new ReferenceComparer());
                                    objectsInUse = new Hashtable();
                                }
                                else if (objectsInUse.ContainsKey(o))
                                {
                                    throw new InvalidOperationException(string.Format(CultureInfo.CurrentCulture, AtlasWeb.JSON_CircularReference, new object[] { enumType.FullName }));
                                }
                                objectsInUse.Add(o, null);
                                IDictionary dictionary = o as IDictionary;
                                if (dictionary != null)
                                {
                                    this.SerializeDictionary(dictionary, sb, depth, objectsInUse, serializationFormat);
                                }
                                else
                                {
                                    IEnumerable enumerable = o as IEnumerable;
                                    if (enumerable != null)
                                    {
                                        this.SerializeEnumerable(enumerable, sb, depth, objectsInUse, serializationFormat);
                                    }
                                    else
                                    {
                                        this.SerializeCustomObject(o, sb, depth, objectsInUse, serializationFormat);
                                    }
                                }
                            }
                            finally
                            {
                                if (objectsInUse != null)
                                {
                                    objectsInUse.Remove(o);
                                }
                            }
                        }
                    }
                }
            }
        }

        private Dictionary<Type, JavaScriptConverter> Converters
        {
            get
            {
                if (this._converters == null)
                {
                    this._converters = new Dictionary<Type, JavaScriptConverter>();
                }
                return this._converters;
            }
        }

        public int MaxJsonLength
        {
            get
            {
                return this._maxJsonLength;
            }
            set
            {
                if (value < 1)
                {
                    throw new ArgumentOutOfRangeException(AtlasWeb.JSON_InvalidMaxJsonLength);
                }
                this._maxJsonLength = value;
            }
        }

        public int RecursionLimit
        {
            get
            {
                return this._recursionLimit;
            }
            set
            {
                if (value < 1)
                {
                    throw new ArgumentOutOfRangeException(AtlasWeb.JSON_InvalidRecursionLimit);
                }
                this._recursionLimit = value;
            }
        }

        internal JavaScriptTypeResolver TypeResolver
        {
            get
            {
                return this._typeResolver;
            }
        }

        private class ReferenceComparer : IEqualityComparer
        {
            bool IEqualityComparer.Equals(object x, object y)
            {
                return (x == y);
            }

            int IEqualityComparer.GetHashCode(object obj)
            {
                return RuntimeHelpers.GetHashCode(obj);
            }
        }

        internal enum SerializationFormat
        {
            JSON,
            JavaScript
        }
    }
}