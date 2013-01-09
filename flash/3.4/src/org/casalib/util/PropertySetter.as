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
	
	
	/**
		Creates a setter function for properties. Designed to be used with objects where methods require a function but you want to ultimately set a value of a property.
		
		@author Aaron Clinger
		@author Mike Creighton
		@author David Nelson
		@version 02/13/10
	*/
	public class PropertySetter {
		protected var _scope:Object;
		protected var _property:String;
		protected var _argument:int;
		
		
		/**
			Defines the property you wish to define with {@link #defineProperty}.
			
			@param scope: An object that contains the property specified by <code>property</code>.
			@param property: Name of the property you want to assign the value of.
			@param argument: The position the value to assign falls in the argument order.
			@throws <code>Error</code> if the property does not exist or is not available in defined scope.
		*/
		public function PropertySetter(scope:Object, property:String, argument:uint = 0) {
			if (scope[property] == undefined)
				throw new Error('Property "' + property + '" does not exist or is not available in defined scope.');
			
			this._scope    = scope;
			this._property = property;
			this._argument = argument;
		}
		
		/**
			Defines property with the value of the targeted argument.
		*/
		public function defineProperty(...arguments):void {
			this._scope[this._property] = arguments[this._argument];
		}
	}
}