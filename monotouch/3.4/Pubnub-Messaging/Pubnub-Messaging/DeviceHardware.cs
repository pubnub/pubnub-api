using System;
using System.Runtime.InteropServices;
using MonoTouch.Foundation;
using MonoTouch.UIKit;

namespace PubnubMessaging
{
	public class DeviceHardware 
	{
		public const string HardwareProperty = "hw.machine";
		
		public enum HardwareVersion {
			iPhone,
			iPhone3G,
			iPhone3GS,
			iPhone4,
			VerizoniPhone4,
			iPhone4S,
			iPod1G,
			iPod2G,
			iPod3G,
			iPod4G,
			iPad,
			iPad2WIFI,
			iPad2WIFI24,
			iPad2GSM,
			iPad2CDMA,
			iPad3WIFI,
			iPad3GSM,
			iPad3CDMA,
			iPhoneSimulator,
			iPhone4Simulator,
			iPadSimulator,
			Unknown
		}
		
		[DllImport(MonoTouch.Constants.SystemLibrary)]
		static internal extern int sysctlbyname([MarshalAs(UnmanagedType.LPStr)] string property, IntPtr output, IntPtr oldLen, IntPtr newp, uint newlen);
		
		public static HardwareVersion Version {
			get {
				var pLen = Marshal.AllocHGlobal(sizeof(int));
				sysctlbyname(DeviceHardware.HardwareProperty, IntPtr.Zero, pLen, IntPtr.Zero, 0);
				
				var length = Marshal.ReadInt32(pLen);
				
				if (length == 0) {
					Marshal.FreeHGlobal(pLen);
					
					return HardwareVersion.Unknown;
				}
				
				var pStr = Marshal.AllocHGlobal(length);
				sysctlbyname(DeviceHardware.HardwareProperty, pStr, pLen, IntPtr.Zero, 0);
				
				var hardwareStr = Marshal.PtrToStringAnsi(pStr);
				var ret = HardwareVersion.Unknown;
				
				
				
				if (hardwareStr == "iPhone1,1")
					ret = HardwareVersion.iPhone;
				else if (hardwareStr == "iPhone1,2")
					ret = HardwareVersion.iPhone3G;
				else if (hardwareStr == "iPhone2,1")
					ret = HardwareVersion.iPhone3GS;
				else if (hardwareStr == "iPhone3,1")
					ret = HardwareVersion.iPhone4;
				else if (hardwareStr == "iPhone3,3")
					ret = HardwareVersion.VerizoniPhone4;
				else if(hardwareStr == "iPhone4,1")
					ret = HardwareVersion.iPhone4S;
				else if (hardwareStr == "iPad1,1")
					ret = HardwareVersion.iPad;
				else if (hardwareStr == "iPad2,1")
					ret = HardwareVersion.iPad2WIFI;
				else if (hardwareStr == "iPad2,2")
					ret = HardwareVersion.iPad2GSM;
				else if (hardwareStr == "iPad2,3")
					ret = HardwareVersion.iPad2CDMA;
				else if (hardwareStr == "iPad2,4")
					ret = HardwareVersion.iPad2WIFI24;
				else if (hardwareStr == "iPad3,1")
					ret = HardwareVersion.iPad3WIFI;
				else if (hardwareStr == "iPad3,2")
					ret = HardwareVersion.iPad3GSM;
				else if (hardwareStr == "iPad3,3")
					ret = HardwareVersion.iPad3CDMA;
				else if (hardwareStr == "iPod1,1")
					ret = HardwareVersion.iPod1G;
				else if (hardwareStr == "iPod2,1")
					ret = HardwareVersion.iPod2G;
				else if (hardwareStr == "iPod3,1")
					ret = HardwareVersion.iPod3G;
				else if (hardwareStr == "iPod4,1")
					ret = HardwareVersion.iPod4G;
				else if (hardwareStr == "i386" || hardwareStr=="x86_64") {
					if (UIDevice.CurrentDevice.Model.Contains("iPhone"))
						ret = UIScreen.MainScreen.Bounds.Height * UIScreen.MainScreen.Scale == 960 || UIScreen.MainScreen.Bounds.Width * UIScreen.MainScreen.Scale == 960 ? HardwareVersion.iPhone4Simulator : HardwareVersion.iPhoneSimulator;
					else
						ret = HardwareVersion.iPadSimulator;
				}
				
				Marshal.FreeHGlobal(pLen);
				Marshal.FreeHGlobal(pStr);
				
				return ret;
			}
		}
	}
}

