using System;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.Collections.Generic;

namespace TvdP.Collections
{
    public static class ConcurrentDictionaryExtentions
    {
        public static bool TryRemove<TKey, TValue>(this ConcurrentDictionary<TKey, TValue> dictionary, TKey key, out TValue value)
        {
            if (key == null)
            {
                throw new ArgumentNullException("key");
            }

            if (dictionary.ContainsKey(key))
            {
                value = dictionary[key];
                return dictionary.Remove(key);
            }

            value = default(TValue);
            return false;
        }

        public static TValue GetOrAdd<TKey, TValue>(this ConcurrentDictionary<TKey, TValue> dictionary, TKey key, TValue value)
        {
            if (key == null)
            {
                throw new ArgumentNullException("key");
            }

            if (dictionary.ContainsKey(key))
            {
                return dictionary[key];
            }

            dictionary.Add(new KeyValuePair<TKey, TValue>(key, value));
            return value;
        }

    }
}
