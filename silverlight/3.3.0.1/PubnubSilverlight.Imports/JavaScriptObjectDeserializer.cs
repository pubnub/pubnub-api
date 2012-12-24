namespace System.Web.Script.Serialization
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Globalization;
    using System.Text;
    using System.Text.RegularExpressions;
    using System.Web.Resources;

    internal class JavaScriptObjectDeserializer
    {
        private int _depthLimit;
        internal JavaScriptString _s;
        private JavaScriptSerializer _serializer;
        private const string DateTimePrefix = "\"\\/Date(";
        private const int DateTimePrefixLength = 8;

        private JavaScriptObjectDeserializer(string input, int depthLimit, JavaScriptSerializer serializer)
        {
            this._s = new JavaScriptString(input);
            this._depthLimit = depthLimit;
            this._serializer = serializer;
        }

        private void AppendCharToBuilder(char? c, StringBuilder sb)
        {
            if (((c == '"') || (c == '\'')) || (c == '/'))
            {
                sb.Append(c);
            }
            else if (c == 'b')
            {
                sb.Append('\b');
            }
            else if (c == 'f')
            {
                sb.Append('\f');
            }
            else if (c == 'n')
            {
                sb.Append('\n');
            }
            else if (c == 'r')
            {
                sb.Append('\r');
            }
            else if (c == 't')
            {
                sb.Append('\t');
            }
            else
            {
                if (c != 'u')
                {
                    throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_BadEscape));
                }
                sb.Append((char)int.Parse(this._s.MoveNext(4), NumberStyles.HexNumber, CultureInfo.InvariantCulture));
            }
        }

        internal static object BasicDeserialize(string input, int depthLimit, JavaScriptSerializer serializer)
        {
            JavaScriptObjectDeserializer deserializer = new JavaScriptObjectDeserializer(input, depthLimit, serializer);
            object obj2 = deserializer.DeserializeInternal(0);
            char? nextNonEmptyChar = deserializer._s.GetNextNonEmptyChar();
            int? nullable3 = nextNonEmptyChar.HasValue ? new int?(nextNonEmptyChar.GetValueOrDefault()) : null;
            if (nullable3.HasValue)
            {
                throw new ArgumentException(string.Format(CultureInfo.InvariantCulture, AtlasWeb.JSON_IllegalPrimitive, new object[] { deserializer._s.ToString() }));
            }
            return obj2;
        }

        private char CheckQuoteChar(char? c)
        {
            if (c == '\'')
            {
                return c.Value;
            }
            if (c != '"')
            {
                throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_StringNotQuoted));
            }
            return '"';
        }

        private IDictionary<string, object> DeserializeDictionary(int depth)
        {
            IDictionary<string, object> dictionary = null;
            char? nextNonEmptyChar;
            char? nullable8;
            char? nullable11;
            if (this._s.MoveNext() != '{')
            {
                throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_ExpectedOpenBrace));
            }
        Label_0199:
            nullable8 = nextNonEmptyChar = this._s.GetNextNonEmptyChar();
            int? nullable10 = nullable8.HasValue ? new int?(nullable8.GetValueOrDefault()) : null;
            if (nullable10.HasValue)
            {
                this._s.MovePrev();
                if (nextNonEmptyChar == ':')
                {
                    throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_InvalidMemberName));
                }
                string str = null;
                if (nextNonEmptyChar != '}')
                {
                    str = this.DeserializeMemberName();
                    if (string.IsNullOrEmpty(str))
                    {
                        throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_InvalidMemberName));
                    }
                    if (this._s.GetNextNonEmptyChar() != ':')
                    {
                        //throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_InvalidObject));
                    }
                }
                if (dictionary == null)
                {
                    dictionary = new Dictionary<string, object>();
                    if (string.IsNullOrEmpty(str))
                    {
                        nextNonEmptyChar = this._s.GetNextNonEmptyChar();
                        goto Label_01D7;
                    }
                }
                this.ThrowIfMaxJsonDeserializerMembersExceeded(dictionary.Count);
                object obj2 = this.DeserializeInternal(depth);
                dictionary[str] = obj2;
                nextNonEmptyChar = this._s.GetNextNonEmptyChar();
                if (nextNonEmptyChar != '}')
                {
                    //if (nextNonEmptyChar != ',')
                    //{
                        //throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_InvalidObject));
                    //}
                    goto Label_0199;
                }
            }
        Label_01D7:
            nullable11 = nextNonEmptyChar;
            if ((nullable11.GetValueOrDefault() != '}') || !nullable11.HasValue)
            {
                throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_InvalidObject));
            }
            return dictionary;
        }

        private object DeserializeInternal(int depth)
        {
            if (++depth > this._depthLimit)
            {
                throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_DepthLimitExceeded));
            }
            char? nextNonEmptyChar = this._s.GetNextNonEmptyChar();
            char? nullable2 = nextNonEmptyChar;
            int? nullable4 = nullable2.HasValue ? new int?(nullable2.GetValueOrDefault()) : null;
            if (!nullable4.HasValue)
            {
                return null;
            }
            this._s.MovePrev();
            if (this.IsNextElementDateTime())
            {
                return this.DeserializeStringIntoDateTime();
            }
            if (IsNextElementObject(nextNonEmptyChar))
            {
                IDictionary<string, object> o = this.DeserializeDictionary(depth);
                if (o.ContainsKey("__type"))
                {
                    return ObjectConverter.ConvertObjectToType(o, null, this._serializer);
                }
                return o;
            }
            if (IsNextElementArray(nextNonEmptyChar))
            {
                return this.DeserializeList(depth);
            }
            if (IsNextElementString(nextNonEmptyChar))
            {
                return this.DeserializeString();
            }
            return this.DeserializePrimitiveObject();
        }

        private IList DeserializeList(int depth)
        {
            char? nextNonEmptyChar;
            char? nullable5;
            IList list = new List<object>();
            if (this._s.MoveNext() != '[')
            {
                throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_InvalidArrayStart));
            }
            bool flag = false;
        Label_00C4:
            nullable5 = nextNonEmptyChar = this._s.GetNextNonEmptyChar();
            int? nullable7 = nullable5.HasValue ? new int?(nullable5.GetValueOrDefault()) : null;
            if (nullable7.HasValue && (nextNonEmptyChar != ']'))
            {
                this._s.MovePrev();
                object obj2 = this.DeserializeInternal(depth);
                list.Add(obj2);
                flag = false;
                nextNonEmptyChar = this._s.GetNextNonEmptyChar();
                if (nextNonEmptyChar != ']')
                {
                    flag = true;
                    if (nextNonEmptyChar != ',')
                    {
                        throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_InvalidArrayExpectComma));
                    }
                    goto Label_00C4;
                }
            }
            if (flag)
            {
                throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_InvalidArrayExtraComma));
            }
            if (nextNonEmptyChar != ']')
            {
                throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_InvalidArrayEnd));
            }
            return list;
        }

        private string DeserializeMemberName()
        {
            char? nextNonEmptyChar = this._s.GetNextNonEmptyChar();
            char? nullable2 = nextNonEmptyChar;
            int? nullable4 = nullable2.HasValue ? new int?(nullable2.GetValueOrDefault()) : null;
            if (!nullable4.HasValue)
            {
                return null;
            }
            this._s.MovePrev();
            if (IsNextElementString(nextNonEmptyChar))
            {
                return this.DeserializeString();
            }
            return this.DeserializePrimitiveToken();
        }

        private object DeserializePrimitiveObject()
        {
            double num4;
            string s = this.DeserializePrimitiveToken();
            if (s.Equals("null"))
            {
                return null;
            }
            if (s.Equals("true"))
            {
                return true;
            }
            if (s.Equals("false"))
            {
                return false;
            }
            bool flag = s.IndexOf('.') >= 0;
            if (s.LastIndexOf("e", StringComparison.OrdinalIgnoreCase) < 0)
            {
                decimal num3;
                if (!flag)
                {
                    int num;
                    long num2;
                    if (int.TryParse(s, NumberStyles.Integer, CultureInfo.InvariantCulture, out num))
                    {
                        return num;
                    }
                    if (long.TryParse(s, NumberStyles.Integer, CultureInfo.InvariantCulture, out num2))
                    {
                        return num2;
                    }
                }
                if (decimal.TryParse(s, NumberStyles.Number, CultureInfo.InvariantCulture, out num3))
                {
                    return num3;
                }
            }
            if (!double.TryParse(s, NumberStyles.Float, CultureInfo.InvariantCulture, out num4))
            {
                throw new ArgumentException(string.Format(CultureInfo.InvariantCulture, AtlasWeb.JSON_IllegalPrimitive, new object[] { s }));
            }
            return num4;
        }

        private string DeserializePrimitiveToken()
        {
            char? nullable2;
            StringBuilder builder = new StringBuilder();
            char? nullable = null;
        Label_0066:
            nullable2 = nullable = this._s.MoveNext();
            int? nullable4 = nullable2.HasValue ? new int?(nullable2.GetValueOrDefault()) : null;
            if (nullable4.HasValue)
            {
                if ((char.IsLetterOrDigit(nullable.Value) || (nullable.Value == '.')) || (((nullable.Value == '-') || (nullable.Value == '_')) || (nullable.Value == '+')))
                {
                    builder.Append(nullable);
                }
                else
                {
                    this._s.MovePrev();
                    goto Label_00A2;
                }
                goto Label_0066;
            }
        Label_00A2:
            return builder.ToString();
        }

        private string DeserializeString()
        {
            StringBuilder sb = new StringBuilder();
            bool flag = false;
            char? c = this._s.MoveNext();
            char ch = this.CheckQuoteChar(c);
            while (true)
            {
                char? nullable4 = c = this._s.MoveNext();
                int? nullable6 = nullable4.HasValue ? new int?(nullable4.GetValueOrDefault()) : null;
                if (!nullable6.HasValue)
                {
                    throw new ArgumentException(this._s.GetDebugString(AtlasWeb.JSON_UnterminatedString));
                }
                if (c == '\\')
                {
                    if (flag)
                    {
                        sb.Append('\\');
                        flag = false;
                    }
                    else
                    {
                        flag = true;
                    }
                }
                else if (flag)
                {
                    this.AppendCharToBuilder(c, sb);
                    flag = false;
                }
                else
                {
                    char? nullable3 = c;
                    int num = ch;
                    if ((nullable3.GetValueOrDefault() == num) && nullable3.HasValue)
                    {
                        return sb.ToString();
                    }
                    sb.Append(c);
                }
            }
        }

        private object DeserializeStringIntoDateTime()
        {
            long num;
            Match match = Regex.Match(this._s.ToString(), "^\"\\\\/Date\\((?<ticks>-?[0-9]+)(?:[a-zA-Z]|(?:\\+|-)[0-9]{4})?\\)\\\\/\"");
            if (long.TryParse(match.Groups["ticks"].Value, out num))
            {
                this._s.MoveNext(match.Length);
                return new DateTime((num * 0x2710L) + JavaScriptSerializer.DatetimeMinTimeTicks, DateTimeKind.Utc);
            }
            return this.DeserializeString();
        }

        private static bool IsNextElementArray(char? c)
        {
            return (c == '[');
        }

        private bool IsNextElementDateTime()
        {
            string a = this._s.MoveNext(8);
            if (a != null)
            {
                this._s.MovePrev(8);
                return string.Equals(a, "\"\\/Date(", StringComparison.Ordinal);
            }
            return false;
        }

        private static bool IsNextElementObject(char? c)
        {
            return (c == '{');
        }

        private static bool IsNextElementString(char? c)
        {
            return ((c == '"') || (c == '\''));
        }

        private static int MaxJsonDeserializerMembers = 0x3e8;

        private void ThrowIfMaxJsonDeserializerMembersExceeded(int count)
        {
            if (count >= MaxJsonDeserializerMembers)
            {
                throw new InvalidOperationException();
            }
        }
    }
}