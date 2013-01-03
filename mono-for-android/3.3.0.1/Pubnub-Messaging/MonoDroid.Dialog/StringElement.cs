using System;

using System.Linq;

using Android.App;
using Android.Content;
using Android.OS;
using Android.Views;
using Android.Widget;
using Android.Runtime;


namespace MonoDroid.Dialog
{
    public class StringElement : Element
    {
		public int FontSize {get;set;}
        public string Value
        {
            get { return _value; }
            set { _value = value; if (_text != null) { _text.Text = _value; } }
        }
        private string _value;

        public object Alignment;
		
		public int Lines { get; set; }
		public bool Multiline { get; set; }

        public StringElement(string caption)
            : base(caption, (int)DroidResources.ElementLayout.dialog_labelfieldright)
        {
        }

        public StringElement(string caption, int layoutId)
            : base(caption, layoutId)
        {
        }

        public StringElement(string caption, string value)
            : base(caption, (int)DroidResources.ElementLayout.dialog_labelfieldright)
        {
            Value = value;
        }
		
		
        public StringElement(string caption, string value, Action clicked)
            : base(caption, (int)DroidResources.ElementLayout.dialog_labelfieldright)
        {
            Value = value;
			this.Tapped = clicked;
        }

        public StringElement(string caption, string value, int layoutId)
            : base(caption, layoutId)
        {
            Value = value;
        }
		
		public StringElement(string caption, Action clicked)
            : base(caption, (int)DroidResources.ElementLayout.dialog_labelfieldright)
        {
            Value = null;
			this.Tapped = clicked;
        }

        public override View GetView(Context context, View convertView, ViewGroup parent)
        {
            View view = DroidResources.LoadStringElementLayout(context, convertView, parent, LayoutId, out _caption, out _text);
            if (view != null)
            {
                _caption.Text = Caption;
				if (FontSize != 0)
				  _caption.TextSize = FontSize;
				
				_text.SetSingleLine(!Multiline);
				if (Multiline)
					_text.SetLines(Lines);
                _text.Text = Value;
				if (FontSize != 0)
				  _text.TextSize = FontSize;
				
				if (Tapped != null)
					view.Click += delegate { this.Tapped(); };
            }
            return view;
        }
		
		public override void Selected ()
		{
			base.Selected ();
			
			if(this.Tapped != null) {
				Tapped();
			}
		}

        public override string Summary()
        {
            return Value;
        }

        public override bool Matches(string text)
        {
            return (Value != null ? Value.IndexOf(text, StringComparison.CurrentCultureIgnoreCase) != -1 : false) ||
                   base.Matches(text);
        }

        protected TextView _caption;
        protected TextView _text;

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                //_caption.Dispose();
                _caption = null;
                //_text.Dispose();
                _text = null;
            }
        }
    }
}