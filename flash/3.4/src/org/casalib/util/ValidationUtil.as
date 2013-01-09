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
	import org.casalib.util.ArrayUtil;
	
	/**
		Utilities for validating common string formats.
		
		@author Aaron Clinger
		@version 05/06/11
	*/
	public class ValidationUtil {
		
		
		/**
			Determines if String is a valid email address.
			
			@param email: String to verify as email.
			@return Returns <code>true</code> if String is a valid email; otherwise <code>false</code>.
			@see <a href="http://www.regular-expressions.info/email.html">Read more about the regular expression used by this method.</a>
		*/
		public static function isEmail(email:String):Boolean {
			const pattern:RegExp = /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i;
			return email.match(pattern) != null;
		}
		
		/**
			Determines if String is a valid USA state abbreviation.
			
			@param state: String to verify as two letter state abbreviation (includes DC).
			@return Returns <code>true</code> if String is a state abbreviation; otherwise <code>false</code>.
		*/
		public static function isUsaStateAbbreviation(state:String):Boolean {
			const states:Array = new Array('ak', 'al', 'ar', 'az', 'ca', 'co', 'ct', 'dc', 'de', 'fl', 'ga', 'hi', 'ia', 'id', 'il', 'in', 'ks', 'ky', 'la', 'ma', 'md', 'me', 'mi', 'mn', 'mo', 'ms', 'mt', 'nb', 'nc', 'nd', 'nh', 'nj', 'nm', 'nv', 'ny', 'oh', 'ok', 'or', 'pa', 'ri', 'sc', 'sd', 'tn', 'tx', 'ut', 'va', 'vt', 'wa', 'wi', 'wv', 'wy');
			return ArrayUtil.contains(states, state.toLowerCase()) == 1;
		}
		
		/**
			Determines if the date provided is equal to or greater than a certain age.
			
			@param age: The age to validate.
			@param yearBorn: The year of birth.
			@param monthBorn: The month of birth, <code>0 </code> for January to <code>11</code> for December.
			@param dateBorn: The day of the month of birth, from <code>1</code> to <code>31</code>.
			@return Returns <code>true</code> if the date provided is equal to or greater than the age; otherwise <code>false</code>.
		*/
		public static function isAge(age:uint, yearBorn:uint, monthBorn:uint = 0, dateBorn:uint = 1):Boolean {
			const currentDate:Date = new Date();
			
			if (yearBorn > currentDate.getFullYear() - age)
				return false;
			
			if (yearBorn < currentDate.getFullYear() - age)
				return true;
			
			if (monthBorn > currentDate.getMonth())
				return false;
			
			if (monthBorn < currentDate.getMonth())
				return true;
			
			if (dateBorn <= currentDate.getDate())
				return true;
			
			return false;
		}
		
		/**
			Determines if credit card is valid using the Luhn formula.
			
			@param cardNumber: The credit card number.
			@return Returns <code>true</code> if String is a valid credit card number; otherwise <code>false</code>.
		*/
		public static function isCreditCard(cardNumber:String):Boolean {
			if (cardNumber.length < 7 || cardNumber.length > 19 || Number(cardNumber) < 1000000)
				return false;
			
			var sum:Number  = 0;
			var alt:Boolean = true;
			var i:Number    = cardNumber.length;
			var pre:Number;
			
			while (--i > -1) {
				if (alt)
					sum += Number(cardNumber.substr(i, 1));
				else {
					pre =  Number(cardNumber.substr(i, 1)) * 2;
					sum += (pre > 8) ? pre -= 9 : pre;
				}
				
				alt = !alt;
			}
			
			return sum % 10 == 0;
		}
		
		/**
			Determines credit card provider by card number.
			
			@param cardNumber: The credit card number.
			@return Returns name of the provider; values can be <code>"visa"</code>, <code>"mastercard"</code>, <code>"discover"</code>, <code>"amex"</code>, <code>"diners"</code>, <code>"other"</code> or <code>"invalid"</code>.
		*/
		public static function getCreditCardProvider(cardNumber:String):String {
			if (!ValidationUtil.isCreditCard(cardNumber))
				return 'invalid';
			
			if (cardNumber.length == 13 ||
				cardNumber.length == 16 &&
				cardNumber.indexOf('4') == 0)
			{
				return 'visa';
			}
			else if (cardNumber.indexOf('51') == 0 ||
					 cardNumber.indexOf('52') == 0 ||
					 cardNumber.indexOf('53') == 0 ||
					 cardNumber.indexOf('54') == 0 ||
					 cardNumber.indexOf('55') == 0 &&
					 cardNumber.length == 16)
			{
				return 'mastercard';
			}
			else if (cardNumber.length == 16 &&
				     cardNumber.indexOf('6011') == 0)
			{
				 return 'discover';
			}
			else if (cardNumber.indexOf('34') == 0 ||
					 cardNumber.indexOf('37') == 0 &&
					 cardNumber.length == 15)
			{
				return 'amex';
			}
			else if (cardNumber.indexOf('300') == 0 ||
					 cardNumber.indexOf('301') == 0 ||
					 cardNumber.indexOf('302') == 0 ||
					 cardNumber.indexOf('303') == 0 ||
					 cardNumber.indexOf('304') == 0 ||
					 cardNumber.indexOf('305') == 0 ||
					 cardNumber.indexOf('36') == 0 ||
					 cardNumber.indexOf('38') == 0 &&
					 cardNumber.length == 14)
			{
				return 'diners';
			}
			else return 'other';
		}
	}
}