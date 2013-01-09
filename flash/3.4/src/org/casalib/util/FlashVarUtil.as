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
	import org.casalib.util.StageReference;
	
	/**
		Utility for providing easy access to HTML embeded FlashVars.
		
		@author Aaron Clinger
		@version 09/15/08
		@usageNote You must first initialize {@link StageReference} before using this class.
	*/
	public class FlashVarUtil {
		
		
		/**
			Returns a FlashVar value by key.
			
			@param key: The name of the FlashVar to retrieve.
			@return The string value of the FlashVar.
			@usageNote You must first initialize {@link StageReference} before using this class.
		*/
		public static function getValue(key:String):String {
			return StageReference.getStage().loaderInfo.parameters[key];
		}
		
		/**
			Checks to if FlashVar exists.
			
			@param key: The name of the FlashVar to check for existence.
			@return Returns <code>true</code> if the key exists; otherwise <code>false</code>.
			@usageNote You must first initialize {@link StageReference} before using this class.
		*/
		public static function hasKey(key:String):Boolean {
			return FlashVarUtil.getValue(key) ? true : false;
		}
	}
}