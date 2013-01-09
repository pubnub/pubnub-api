/*
	CASA Framework for ActionScript 3.0
	Copyright (c) 2011, Contributors of CASA Framework
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	- Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	
	- Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	
	- Neither the name of the CASA Framework nor the names of its contributors
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
	
	/**
		Utilities for constructing and working with Classes.
		
		@author Aaron Clinger
		@version 02/13/10
	*/
	public class ClassUtil {
		
		/**
			Dynamically constructs a Class.
			
			@param type: The Class to create.
			@param arguments: Up to ten arguments to the constructor.
			@return Returns the dynamically created instance of the Class specified by <code>type</code> parameter.
			@throws <code>Error</code> if you pass more arguments than this method accepts (accepts ten or less).
			@example
				<code>
					var bData:* = ClassUtil.construct(BitmapData, 200, 200);
					
					trace(bData is BitmapData, bData.width);
				</code>
		*/
		public static function construct(type:Class, ...arguments):* {
			if (arguments.length > 10)
				throw new Error('You have passed more arguments than the "construct" method accepts (accepts ten or less).');
			
			switch (arguments.length) {
					case 0 :
						return new type();
					case 1 :
						return new type(arguments[0]);
					case 2 :
						return new type(arguments[0], arguments[1]);
					case 3 :
						return new type(arguments[0], arguments[1], arguments[2]);
					case 4 :
						return new type(arguments[0], arguments[1], arguments[2], arguments[3]);
					case 5 :
						return new type(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]);
					case 6 :
						return new type(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5]);
					case 7 :
						return new type(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6]);
					case 8 :
						return new type(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7]);
					case 9 :
						return new type(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7], arguments[8]);
					case 10 :
						return new type(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7], arguments[8], arguments[9]);
			}
		}
	}
}