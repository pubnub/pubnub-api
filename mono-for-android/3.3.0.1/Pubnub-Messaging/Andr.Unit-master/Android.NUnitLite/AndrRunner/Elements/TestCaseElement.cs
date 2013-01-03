//
// Copyright 2011-2012 Xamarin Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

using System;

using Android.App;
using Android.Content;
using Android.Views;

using NUnitLite;

namespace Android.NUnitLite.UI {
	
	class TestCaseElement : TestElement {
		
		public TestCaseElement (TestCase test) : base (test)
		{
			if (test.RunState == RunState.Runnable)
				Indicator = "..."; // hint there's more
		}
		
		protected override string GetCaption ()
		{
			if (TestCase.RunState == RunState.Ignored) {
				return String.Format ("<b>{0}</b><br><font color='#FF7700'>{1}: {2}</font>", 
					TestCase.Name, TestCase.RunState, TestCase.IgnoreReason); 
			} else if (Result == null) {
				return String.Format ("<b>{0}</b><br><font color='grey'>{1}</font>", TestCase.Name, TestCase.RunState);
			} else if (Result.IsSuccess) {
				return String.Format ("<b>{0}</b><br><font color='green'>Success!</font>", TestCase.Name); 
			} else {
				return String.Format ("<b>{0}</b><br><font color='red'>{1}</font>", TestCase.Name, Result.Message); 
			}
		}
		
		public TestCase TestCase {
			get { return Test as TestCase; }
		}
		
		public override View GetView (Context context, View convertView, ViewGroup parent)
		{
			View view = base.GetView (context, convertView, parent);
			view.Click += delegate {
				if (TestCase.RunState != RunState.Runnable)
					return;
								
				AndroidRunner runner = AndroidRunner.Runner;
				if (!runner.OpenWriter ("Run " + TestCase.FullName, context))
					return;
				
				try {
					TestCase.Run (runner);
				}
				finally {
					runner.CloseWriter ();
				}

				if (!Result.IsSuccess) {
					Intent intent = new Intent (context, typeof (TestResultActivity));
					intent.PutExtra ("TestCase", Name);
					intent.AddFlags (ActivityFlags.NewTask);			
					context.StartActivity (intent);
				}
			};
			return view;
		}
	}
}