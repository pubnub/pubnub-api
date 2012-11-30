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
	import flash.net.URLVariables;
	
	
	/**
		Utilities for manipulating URLVariables.
		
		@author Aaron Clinger
		@version 05/04/11
	*/
	public class UrlVariablesUtil {
		
		/**
			Sorts the provided <code>URLVariables</code> key/value pairs alphabetically.
			
			@param urlVars: The <code>URLVariables</code> to alphabetize.
			@return Returns the alphabetized key/value pairs as an ampersand (<code>&</code>) delimited <code>String</code>.
		*/
		public static function alphabetize(urlVars:URLVariables):String {
			var pairs:Array = urlVars.toString().split('&');
			pairs.sort(UrlVariablesUtil._sortAlphabetically);
			
			return pairs.join('&');
		}
		
		protected static function _sortAlphabetically(a:String, b:String):Number {
			if (a < b)
				return -1;
			else if (a > b)
				return 1;
			else
				return 0;
		}
	}
}