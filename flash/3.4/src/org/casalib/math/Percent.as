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
package org.casalib.math {
	
	/**
		Creates a standardized way of describing and storing percentages. You can store and receive percentages in two different formats; regular percentage or as an decimal percentage.
		
		If percent is 37.5% a regular percentage would be expressed as <code>37.5</code> while the decimal percentage will be expressed <code>0.375</code>.
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 02/16/09
	*/
	public class Percent {
		protected var _percent:Number;
		
		
		/**
			Creates a new Percent.
			
			@param percentage: Percent formatted at a percentage or an decimal percentage.
			@param isDecimalPercentage: Indicates if the parameter <code>percentage</code> is a decimal percentage <code>true</code>, or regular percentage <code>false</code>.
		*/
		public function Percent(percentage:Number = 0, isDecimalPercentage:Boolean = true) {
			super();
			
			if (isDecimalPercentage) {
				this.decimalPercentage = percentage;
			} else {
				this.percentage = percentage;
			}
		}
		
		/**
			The percent expressed as a regular percentage. 37.5% would be expressed as <code>37.5</code>.
		*/
		public function get percentage():Number {
			return 100 * this._percent;
		}
		
		public function set percentage(percent:Number):void {
			this._percent = percent * .01;
		}
		
		/**
			The percent expressed as a decimal percentage. 37.5% would be expressed as <code>0.375</code>.
		*/
		public function get decimalPercentage():Number {
			return this._percent;
		}
		
		public function set decimalPercentage(percent:Number):void {
			this._percent = percent;
		}
		
		/**
			Determines if the percent specified in the <code>percent</code> parameter is equal to this percent object.
			
			@param percent: A Percent object.
			@return Returns <code>true</code> if percents are identical; otherwise <code>false</code>.
		*/
		public function equals(percent:Percent):Boolean {
			return this.decimalPercentage == percent.decimalPercentage;
		}
		
		/**
			@return A new percent object with the same value as this percent.
		*/
		public function clone():Percent {
			return new Percent(this.decimalPercentage);
		}
		
		public function valueOf():Number {
			return this.decimalPercentage;
		}
		
		public function toString():String {
			return this.decimalPercentage.toString();
		}
	}
}