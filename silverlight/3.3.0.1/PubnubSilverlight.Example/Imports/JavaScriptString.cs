namespace System.Web.Script.Serialization
{
    using System;

    internal class JavaScriptString
    {
        private int _index;
        private string _s;

        internal JavaScriptString(string s)
        {
            this._s = s;
        }

        internal string GetDebugString(string message)
        {
            return string.Concat(new object[] { message, " (", this._index, "): ", this._s });
        }

        internal char? GetNextNonEmptyChar()
        {
            while (this._s.Length > this._index)
            {
                char c = this._s[this._index++];
                if (!char.IsWhiteSpace(c))
                {
                    return new char?(c);
                }
            }
            return null;
        }

        internal char? MoveNext()
        {
            if (this._s.Length > this._index)
            {
                return new char?(this._s[this._index++]);
            }
            return null;
        }

        internal string MoveNext(int count)
        {
            if (this._s.Length >= (this._index + count))
            {
                string str = this._s.Substring(this._index, count);
                this._index += count;
                return str;
            }
            return null;
        }

        internal void MovePrev()
        {
            if (this._index > 0)
            {
                this._index--;
            }
        }

        internal void MovePrev(int count)
        {
            while ((this._index > 0) && (count > 0))
            {
                this._index--;
                count--;
            }
        }

        public override string ToString()
        {
            if (this._s.Length > this._index)
            {
                return this._s.Substring(this._index);
            }
            return string.Empty;
        }
    }
}