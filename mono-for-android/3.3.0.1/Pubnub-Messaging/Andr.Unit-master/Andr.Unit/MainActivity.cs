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

using System.Reflection;

using Android.App;
using Android.OS;
using Android.NUnitLite;
using Android.NUnitLite.UI;

namespace Andr.Unit {
	
	[Activity (Label = "Xamarin's Andr.Unit", MainLauncher = true)]
	public class MainActivity : RunnerActivity {
		
		protected override void OnCreate (Bundle bundle)
		{
			// tests can be inside the main assembly
			Add (Assembly.GetExecutingAssembly ());
			// or in any reference assemblies			
			//Add (typeof (PubNubTest.EncryptionTests).Assembly);
			// or in any assembly that you load (since JIT is available)
			
#if false
			// you can use the default or set your own custom writer (e.g. save to web site and tweet it ;-)
			Runner.Writer = new TcpTextWriter ("10.0.1.2", 16384);
			// start running the test suites as soon as the application is loaded
			Runner.AutoStart = true;
			// crash the application (to ensure it's ended) and return to springboard
			Runner.TerminateAfterExecution = true;
#endif
			// you cannot add more assemblies once calling base
			base.OnCreate (bundle);
		}
	}
}