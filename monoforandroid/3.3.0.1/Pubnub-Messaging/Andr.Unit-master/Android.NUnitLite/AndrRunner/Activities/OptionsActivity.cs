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
using Android.Content.PM;
using Android.OS;
using Android.Views;
using Android.Widget;

using MonoDroid.Dialog;

namespace Android.NUnitLite.UI {
	
	[Activity (Label = "Options", WindowSoftInputMode = SoftInput.AdjustPan,
		ConfigurationChanges = ConfigChanges.KeyboardHidden | ConfigChanges.Orientation)]
	public class OptionsActivity : DialogActivity {
		BooleanElement remote;
		EntryElement host_name;
		EntryElement host_port;
		
		protected override void OnCreate (Bundle bundle)
		{
			Options options = AndroidRunner.Runner.Options;
			remote = new BooleanElement ("Remote Server", options.EnableNetwork);
			host_name = new EntryElement ("HostName", options.HostName);
			host_port = new EntryElement ("Port", options.HostPort.ToString ()) { Numeric = true };
			
			Root = new RootElement ("Options") {
				new Section () { remote, host_name, host_port }
			};
			
			base.OnCreate (bundle);
		}
		
		int GetPort ()
		{
			int port;
			ushort p;
			if (UInt16.TryParse (host_port.Value, out p))
				port = p;
			else
				port = -1;
			return port;
		}
		
		protected override void OnPause ()
		{
			Options options = AndroidRunner.Runner.Options;
			options.EnableNetwork = remote.Value;
			options.HostName = host_name.Value;
			options.HostPort = GetPort ();
			options.Save (this);
			base.OnPause ();
		}
	}
}