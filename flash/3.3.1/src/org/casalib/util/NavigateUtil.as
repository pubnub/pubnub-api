/*
	CASA Lib for ActionScript 3.0
	Copyright (c) 2011, Aaron Clinger & Contributors of CASA Lib
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	- Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	
	- Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	
	- Neither the name of the CASA Lib nor the names of its contributors
	  may be used to endorse or promote products derived from this software
	  without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/
package org.casalib.util {
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import org.casalib.errors.ArguementTypeError;
	import org.casalib.util.LocationUtil;
	
	
	/**
		Simplifies <code>navigateToURL</code> and <code>window.open</code> requests.
		
		@author Aaron Clinger
		@version 02/13/10
	*/
	public class NavigateUtil {
		public static const WINDOW_SELF:String   = '_self';
		public static const WINDOW_BLANK:String  = '_blank';
		public static const WINDOW_PARENT:String = '_parent';
		public static const WINDOW_TOP:String    = '_top';
		
		
		/**
			Simlifies <code>navigateToURL</code> by allowing you to either use a <code>String</code> or an <code>URLRequest</code> reference to the URL. This method also helps prevent pop-up blocking by trying to use {@link #openWindow} before calling <code>navigateToURL</code>.
			
			@param request: A <code>String</code> or an <code>URLRequest</code> reference to the URL you wish to open/navigate to.
			@param window: The browser window or HTML frame in which to display the URL indicated by the <code>request</code> parameter.
			@throws ArguementTypeError if you pass a type other than a <code>String</code> or <code>URLRequest</code> to parameter <code>request</code>.
		*/
		public static function openUrl(request:*, window:String = NavigateUtil.WINDOW_SELF):void {
			if (request is String)
				request = new URLRequest(request);
			else if (!(request is URLRequest))
				throw new ArguementTypeError('request');
			
			if (window == NavigateUtil.WINDOW_BLANK && ExternalInterface.available && !LocationUtil.isIde() && request.data == null)
				if (NavigateUtil.openWindow(request.url, window))
					return;
			
			navigateToURL(request, window);
		}
		
		/**
			A Flash wrapper for JavaScript’s <code>window.open</code>.
			
			@param url: Specifies the URL you wish to open/navigate to.
			@param window: The browser window or HTML frame in which to display the URL indicated by the <code>url</code> parameter.
			@param features: Defines the various window features to be included.
			@return Returns <code>true</code> if the window was successfully created; otherwise <code>false</code>.
			@see <a href="http://google.com/search?q=JavaScript+window.open+documentation">JavaScript documentation for window.open</a>.
		*/
		public static function openWindow(url:String, window:String = NavigateUtil.WINDOW_BLANK, features:String = ""):Boolean {
			if (ExternalInterface.available) {
				try {
					return ExternalInterface.call("function casaOpenWindow(url, windowOrName, features) { return window.open(url, windowOrName, features) != null; }", url, (window == NavigateUtil.WINDOW_BLANK) ? 'casaWindow' + int(1000 * Math.random()) : window, features);
				} catch (e:Error) {}
			}
			
			return false;
		}
	}
}