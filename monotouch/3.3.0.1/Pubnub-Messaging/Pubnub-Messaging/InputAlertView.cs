using System;
using MonoTouch.UIKit;
using MonoTouch.CoreGraphics;
using System.Drawing;

namespace PubnubMessaging
{
	public class InputAlertView : UIAlertView
	{
		public InputAlertView ( string sTitle, string sMessage, string sCancel, params string[] aOtherButtons ) : base( sTitle, sMessage, null, sCancel, aOtherButtons )
		{
			this.KeyboardType = UIKeyboardType.ASCIICapable;
			this.KeyboardReturnType = UIReturnKeyType.Done;
			this.InputFieldTextAlignment = UITextAlignment.Center;
			this.InputFieldCapitalization = UITextAutocapitalizationType.AllCharacters;
			this.InputFieldAutocorrection = UITextAutocorrectionType.No;
			this.InputFieldIsSecure = false;
			this.InputFieldPlaceholder = "";
			this.Presented += delegate
			{
				this.oTxtInput.BecomeFirstResponder (  );
				this.Transform = CGAffineTransform.MakeTranslation ( 0, -100 );
			};
		}
		
		private UITextField oTxtInput;
		
		// If the view has been dismissed, this property contains the entered text.
		public string EnteredText
		{
			get
			{
				return this.oTxtInput.Text;
			}
		}
		
		public UIKeyboardType KeyboardType
		{
			get;
			set;
		}
		
		public UIReturnKeyType KeyboardReturnType
		{
			get;
			set;
		}
		
		public UITextAlignment InputFieldTextAlignment
		{
			get;
			set;
		}
		
		public UITextAutocapitalizationType InputFieldCapitalization
		{
			get;
			set;
		}
		
		public UITextAutocorrectionType InputFieldAutocorrection
		{
			get;
			set;
		}
		
		public bool InputFieldIsSecure
		{
			get;
			set;
		}
		
		public string InputFieldPlaceholder
		{
			get;
			set;
		}
		
		public override void Show ()
		{
			base.Show ( );
			
			this.oTxtInput = new UITextField ( new System.Drawing.RectangleF ( 12f, 75f, 260f, 25f ) );
			this.oTxtInput.BackgroundColor = UIColor.White;
			this.oTxtInput.UserInteractionEnabled = true;
			this.oTxtInput.KeyboardType = this.KeyboardType;
			this.oTxtInput.ReturnKeyType = this.KeyboardReturnType;
			this.oTxtInput.TextAlignment = this.InputFieldTextAlignment;
			this.oTxtInput.AutocapitalizationType = this.InputFieldCapitalization;
			this.oTxtInput.AutocorrectionType = this.InputFieldAutocorrection;
			this.oTxtInput.SecureTextEntry = this.InputFieldIsSecure;
			this.oTxtInput.Placeholder = this.InputFieldPlaceholder;
			
			this.Frame = new RectangleF ( this.Frame.X, this.Frame.Y, this.Frame.Size.Width, this.Frame.Size.Height + this.oTxtInput.Bounds.Height + 20 );
			
			this.fInitialHeight = this.Bounds.Height;
			// Increase height of the alert view to have space for the textfield.
			this.AddSubview ( this.oTxtInput );
			this.Superview.SetNeedsLayout (  );
			this.SetNeedsLayout (  );
			this.fInitialY = this.Frame.Y;
		}
		private float fInitialHeight;
		private float fInitialY;
		
		public override void LayoutSubviews ()
		{
			base.LayoutSubviews (  );
			this.Frame = new RectangleF ( this.Frame.X, this.fInitialY - 80, this.Frame.Size.Width, this.fInitialHeight );
			foreach ( UIView oSubView in this.Subviews )
			{
				if ( oSubView is UITextField )
				{
					oSubView.Frame = new RectangleF ( oSubView.Frame.X, this.Bounds.Height - oSubView.Frame.Height - 65, oSubView.Frame.Width, oSubView.Frame.Height );
					continue;
				}
				if ( oSubView is UIControl )
				{
					oSubView.Frame = new RectangleF ( oSubView.Frame.X, this.Bounds.Height - oSubView.Frame.Height - 20, oSubView.Frame.Width, oSubView.Frame.Height );
				}
			}
		}
	}
}

