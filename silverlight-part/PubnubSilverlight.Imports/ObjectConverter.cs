namespace System.Web.Script.Serialization
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Globalization;
    using System.Reflection;
    using System.Runtime.InteropServices;
    using System.Web.Resources;

    internal static class ObjectConverter
    {
        private static Type _dictionaryGenericType = typeof(Dictionary<,>);
        private static Type _enumerableGenericType = typeof(IEnumerable<>);
        private static Type _idictionaryGenericType = typeof(IDictionary<,>);
        private static Type _listGenericType = typeof(List<>);
        private static readonly Type[] s_emptyTypeArray = new Type[0];

        private static bool AddItemToList(IList oldList, IList newList, Type elementType, JavaScriptSerializer serializer, bool throwOnError)
        {
            foreach (object obj3 in oldList)
            {
                object obj2;
                if (!ConvertObjectToTypeMain(obj3, elementType, serializer, throwOnError, out obj2))
                {
                    return false;
                }
                newList.Add(obj2);
            }
            return true;
        }

        private static bool AssignToPropertyOrField(object propertyValue, object o, string memberName, JavaScriptSerializer serializer, bool throwOnError)
        {
            IDictionary dictionary = o as IDictionary;
            if (dictionary != null)
            {
                if (!ConvertObjectToTypeMain(propertyValue, null, serializer, throwOnError, out propertyValue))
                {
                    return false;
                }
                dictionary[memberName] = propertyValue;
                return true;
            }
            Type type = o.GetType();
            PropertyInfo property = type.GetProperty(memberName, BindingFlags.Public | BindingFlags.Instance | BindingFlags.IgnoreCase);
            if (property != null)
            {
                MethodInfo setMethod = property.GetSetMethod();
                if (setMethod != null)
                {
                    if (!ConvertObjectToTypeMain(propertyValue, property.PropertyType, serializer, throwOnError, out propertyValue))
                    {
                        return false;
                    }
                    try
                    {
                        setMethod.Invoke(o, new object[] { propertyValue });
                        return true;
                    }
                    catch
                    {
                        if (throwOnError)
                        {
                            throw;
                        }
                        return false;
                    }
                }
            }
            FieldInfo field = type.GetField(memberName, BindingFlags.Public | BindingFlags.Instance | BindingFlags.IgnoreCase);
            if (field != null)
            {
                if (!ConvertObjectToTypeMain(propertyValue, field.FieldType, serializer, throwOnError, out propertyValue))
                {
                    return false;
                }
                try
                {
                    field.SetValue(o, propertyValue);
                    return true;
                }
                catch
                {
                    if (throwOnError)
                    {
                        throw;
                    }
                    return false;
                }
            }
            return true;
        }

        private static bool ConvertDictionaryToObject(IDictionary<string, object> dictionary, Type type, JavaScriptSerializer serializer, bool throwOnError, out object convertedObject)
        {
            object obj2;
            Type t = type;
            string id = null;
            object o = dictionary;
            if (dictionary.TryGetValue("__type", out obj2))
            {
                if (!ConvertObjectToTypeMain(obj2, typeof(string), serializer, throwOnError, out obj2))
                {
                    convertedObject = false;
                    return false;
                }
                id = (string)obj2;
                if (id != null)
                {
                    if (serializer.TypeResolver != null)
                    {
                        t = serializer.TypeResolver.ResolveType(id);
                        if (t == null)
                        {
                            if (throwOnError)
                            {
                                throw new InvalidOperationException();
                            }
                            convertedObject = null;
                            return false;
                        }
                    }
                    dictionary.Remove("__type");
                }
            }
            JavaScriptConverter converter = null;
            if ((t != null) && serializer.ConverterExistsForType(t, out converter))
            {
                try
                {
                    convertedObject = converter.Deserialize(dictionary, t, serializer);
                    return true;
                }
                catch
                {
                    if (throwOnError)
                    {
                        throw;
                    }
                    convertedObject = null;
                    return false;
                }
            }
            if ((id != null) || IsClientInstantiatableType(t, serializer))
            {
                o = Activator.CreateInstance(t);
            }
            List<string> list = new List<string>(dictionary.Keys);
            if (IsGenericDictionary(type))
            {
                Type type3 = type.GetGenericArguments()[0];
                if ((type3 != typeof(string)) && (type3 != typeof(object)))
                {
                    if (throwOnError)
                    {
                        throw new InvalidOperationException(string.Format(CultureInfo.InvariantCulture, AtlasWeb.JSON_DictionaryTypeNotSupported, new object[] { type.FullName }));
                    }
                    convertedObject = null;
                    return false;
                }
                Type type4 = type.GetGenericArguments()[1];
                IDictionary dictionary2 = null;
                if (IsClientInstantiatableType(type, serializer))
                {
                    dictionary2 = (IDictionary)Activator.CreateInstance(type);
                }
                else
                {
                    dictionary2 = (IDictionary)Activator.CreateInstance(_dictionaryGenericType.MakeGenericType(new Type[] { type3, type4 }));
                }
                if (dictionary2 != null)
                {
                    foreach (string str2 in list)
                    {
                        object obj4;
                        if (!ConvertObjectToTypeMain(dictionary[str2], type4, serializer, throwOnError, out obj4))
                        {
                            convertedObject = null;
                            return false;
                        }
                        dictionary2[str2] = obj4;
                    }
                    convertedObject = dictionary2;
                    return true;
                }
            }
            if ((type != null) && !type.IsAssignableFrom(o.GetType()))
            {
                if (!throwOnError)
                {
                    convertedObject = null;
                    return false;
                }
                if (type.GetConstructor(BindingFlags.Public | BindingFlags.Instance, null, s_emptyTypeArray, null) == null)
                {
                    throw new MissingMethodException(string.Format(CultureInfo.InvariantCulture, AtlasWeb.JSON_NoConstructor, new object[] { type.FullName }));
                }
                throw new InvalidOperationException(string.Format(CultureInfo.InvariantCulture, AtlasWeb.JSON_DeserializerTypeMismatch, new object[] { type.FullName }));
            }
            foreach (string str3 in list)
            {
                object propertyValue = dictionary[str3];
                if (!AssignToPropertyOrField(propertyValue, o, str3, serializer, throwOnError))
                {
                    convertedObject = null;
                    return false;
                }
            }
            convertedObject = o;
            return true;
        }

        private static bool ConvertListToObject(IList list, Type type, JavaScriptSerializer serializer, bool throwOnError, out IList convertedList)
        {
            if (((type == null) || (type == typeof(object))) || IsArrayListCompatible(type))
            {
                Type elementType = typeof(object);
                if ((type != null) && (type != typeof(object)))
                {
                    elementType = type.GetElementType();
                }
                List<object> newList = new List<object>();
                if (!AddItemToList(list, newList, elementType, serializer, throwOnError))
                {
                    convertedList = null;
                    return false;
                }
                if ((type == typeof(IEnumerable)) || ((type == typeof(IList)) || (type == typeof(ICollection))))
                {
                    convertedList = newList;
                    return true;
                }
                convertedList = newList.ToArray();
                return true;
            }
            if (type.IsGenericType && (type.GetGenericArguments().Length == 1))
            {
                Type type3 = type.GetGenericArguments()[0];
                if (_enumerableGenericType.MakeGenericType(new Type[] { type3 }).IsAssignableFrom(type))
                {
                    Type type5 = _listGenericType.MakeGenericType(new Type[] { type3 });
                    IList list3 = null;
                    if (IsClientInstantiatableType(type, serializer) && typeof(IList).IsAssignableFrom(type))
                    {
                        list3 = (IList)Activator.CreateInstance(type);
                    }
                    else
                    {
                        if (type5.IsAssignableFrom(type))
                        {
                            if (throwOnError)
                            {
                                throw new InvalidOperationException(string.Format(CultureInfo.InvariantCulture, AtlasWeb.JSON_CannotCreateListType, new object[] { type.FullName }));
                            }
                            convertedList = null;
                            return false;
                        }
                        list3 = (IList)Activator.CreateInstance(type5);
                    }
                    if (!AddItemToList(list, list3, type3, serializer, throwOnError))
                    {
                        convertedList = null;
                        return false;
                    }
                    convertedList = list3;
                    return true;
                }
            }
            else if (IsClientInstantiatableType(type, serializer) && typeof(IList).IsAssignableFrom(type))
            {
                IList list4 = (IList)Activator.CreateInstance(type);
                if (!AddItemToList(list, list4, null, serializer, throwOnError))
                {
                    convertedList = null;
                    return false;
                }
                convertedList = list4;
                return true;
            }
            if (throwOnError)
            {
                throw new InvalidOperationException(string.Format(CultureInfo.CurrentCulture, AtlasWeb.JSON_ArrayTypeNotSupported, new object[] { type.FullName }));
            }
            convertedList = null;
            return false;
        }

        internal static object ConvertObjectToType(object o, Type type, JavaScriptSerializer serializer)
        {
            object obj2;
            ConvertObjectToTypeMain(o, type, serializer, true, out obj2);
            return obj2;
        }

        private static bool ConvertObjectToTypeInternal(object o, Type type, JavaScriptSerializer serializer, bool throwOnError, out object convertedObject)
        {
            IDictionary<string, object> dictionary = o as IDictionary<string, object>;
            if (dictionary != null)
            {
                return ConvertDictionaryToObject(dictionary, type, serializer, throwOnError, out convertedObject);
            }
            IList list = o as IList;
            if (list != null)
            {
                IList list2;
                if (ConvertListToObject(list, type, serializer, throwOnError, out list2))
                {
                    convertedObject = list2;
                    return true;
                }
                convertedObject = null;
                return false;
            }
            if ((type == null) || (o.GetType() == type))
            {
                convertedObject = o;
                return true;
            }
            //TypeDescriptor.GetConverter(type) !!!
            TypeConverter converter = new TypeConverter();
            if (converter.CanConvertFrom(o.GetType()))
            {
                try
                {
                    convertedObject = converter.ConvertFrom(null, CultureInfo.InvariantCulture, o);
                    return true;
                }
                catch
                {
                    if (throwOnError)
                    {
                        throw;
                    }
                    convertedObject = null;
                    return false;
                }
            }
            if (converter.CanConvertFrom(typeof(string)))
            {
                try
                {
                    string str;
                    if (o is DateTime)
                    {
                        DateTime time = (DateTime)o;
                        str = time.ToUniversalTime().ToString("u", CultureInfo.InvariantCulture);
                    }
                    else
                    {
                        //ConvertToInvariantString(o); !!!
                        str = converter.ConvertToString(o);
                    }
                    //ConvertFromInvariantString(str); !!!
                    convertedObject = converter.ConvertToString(str);
                    return true;
                }
                catch
                {
                    if (throwOnError)
                    {
                        throw;
                    }
                    convertedObject = null;
                    return false;
                }
            }
            if (type.IsAssignableFrom(o.GetType()))
            {
                convertedObject = o;
                return true;
            }
            if (throwOnError)
            {
                throw new InvalidOperationException(string.Format(CultureInfo.CurrentCulture, AtlasWeb.JSON_CannotConvertObjectToType, new object[] { o.GetType(), type }));
            }
            convertedObject = null;
            return false;
        }

        private static bool ConvertObjectToTypeMain(object o, Type type, JavaScriptSerializer serializer, bool throwOnError, out object convertedObject)
        {
            if (o == null)
            {
                if (type == typeof(char))
                {
                    convertedObject = '\0';
                    return true;
                }
                if (IsNonNullableValueType(type))
                {
                    if (throwOnError)
                    {
                        throw new InvalidOperationException(AtlasWeb.JSON_ValueTypeCannotBeNull);
                    }
                    convertedObject = null;
                    return false;
                }
                convertedObject = null;
                return true;
            }
            if (o.GetType() == type)
            {
                convertedObject = o;
                return true;
            }
            return ConvertObjectToTypeInternal(o, type, serializer, throwOnError, out convertedObject);
        }

        private static bool IsArrayListCompatible(Type type)
        {
            if (!type.IsArray && (!(type == typeof(IEnumerable)) && !(type == typeof(IList))))
            {
                return (type == typeof(ICollection));
            }
            return true;
        }

        internal static bool IsClientInstantiatableType(Type t, JavaScriptSerializer serializer)
        {
            if (((t == null) || t.IsAbstract) || (t.IsInterface || t.IsArray))
            {
                return false;
            }
            if (t == typeof(object))
            {
                return false;
            }
            JavaScriptConverter converter = null;
            if (!serializer.ConverterExistsForType(t, out converter))
            {
                if (t.IsValueType)
                {
                    return true;
                }
                if (t.GetConstructor(BindingFlags.Public | BindingFlags.Instance, null, s_emptyTypeArray, null) == null)
                {
                    return false;
                }
            }
            return true;
        }

        private static bool IsGenericDictionary(Type type)
        {
            if (((type == null) || !type.IsGenericType) || (!typeof(IDictionary).IsAssignableFrom(type) && !(type.GetGenericTypeDefinition() == _idictionaryGenericType)))
            {
                return false;
            }
            return (type.GetGenericArguments().Length == 2);
        }

        private static bool IsNonNullableValueType(Type type)
        {
            if ((type == null) || !type.IsValueType)
            {
                return false;
            }
            if (type.IsGenericType)
            {
                return !(type.GetGenericTypeDefinition() == typeof(Nullable<>));
            }
            return true;
        }

        internal static bool TryConvertObjectToType(object o, Type type, JavaScriptSerializer serializer, out object convertedObject)
        {
            return ConvertObjectToTypeMain(o, type, serializer, false, out convertedObject);
        }
    }
}