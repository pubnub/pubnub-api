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
	import flash.text.TextField;
	import flash.text.TextFormat;
	import org.casalib.util.StringUtil;
	
	/**
		Utilities for working with TextFields.
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 09/06/09
	*/
	public class TextFieldUtil {
		
		
		/**
			Determines if textfield has more text than can be displayed at once.
			
			@param field: Textfield to check for text overflow.
			@return Returns <code>true</code> if textfield has text overflow; otherwise <code>false</code>.
		*/
		public static function hasOverFlow(field:TextField):Boolean {
			return field.maxScrollV > 1 || field.maxScrollH > 1;
		}
		
		/**
			Applies the supplied TextFormat to all upper case letters then upper cases all lower case characters.
			
			@param field: TextField to convert to small caps.
			@param largeFormat: The format you wish to apply to the upper case letters (usually a larger text size).
			@example
				<code>
					var small:TextFormat = new TextFormat();
					var large:TextFormat = new TextFormat();
					
					small.size = 15;
					large.size = 30;
					
					var title:TextField = new TextField();
					title.autoSize      = TextFieldAutoSize.LEFT;
					title.text          = "This Text is Small Caps.";
					title.setTextFormat(small);
					
					TextFieldUtil.formatSmallCaps(title, large);
					
					this.addChild(title);
				</code>
			@see TextFieldUtil#classSmallCaps
		*/
		public static function formatSmallCaps(field:TextField, largeFormat:TextFormat):void {
			var copy:String = field.text;
			var l:int       = copy.length;
			var char:String;
			
			field.text = copy.toUpperCase();
			
			while (l--) {
				char = copy.charAt(l);
				
				if (!StringUtil.isPunctuation(char) && !StringUtil.isLowerCase(char) || StringUtil.isNumber(char))
					field.setTextFormat(largeFormat, l, l + 1);
			}
		}
		
		/**
			Adds the supplied CSS class to all upper case letters then upper cases all lower case characters. The function works by wrapping each upper case letter in a <code>span</code> tag with the defined class name applied.
			
			@param field: TextField to convert to small caps.
			@param largeClass: The CSS class name you wish to apply to the upper case letters.
			@example
				<code>
					var smallCapsStyle:StyleSheet = new StyleSheet();
					smallCapsStyle.parseCSS("p {font-size:15px;} .smallCaps {font-size:30px;}");
					
					var title:TextField = new TextField();
					title.autoSize      = TextFieldAutoSize.LEFT;
					title.styleSheet    = smallCapsStyle;
					title.htmlText      = "<p>This Text is Small Caps.</p>";
					
					TextFieldUtil.classSmallCaps(title, "smallCaps");
					
					this.addChild(title);
				</code>
			@see TextFieldUtil#formatSmallCaps
		*/
		public static function classSmallCaps(field:TextField, largeClass:String):void {
			var copy:String = field.htmlText;
			var l:int       = copy.length;
			var char:String;
			var tag:Boolean;
			
			while (l--) {
				char = copy.charAt(l);
				
				if (char == '>')
					tag = true;
				
				if (char == '<')
					tag = false;
				
				if (tag)
					continue;
				
				if (!StringUtil.isPunctuation(char, false) && !StringUtil.isLowerCase(char) || StringUtil.isNumber(char))
					copy = StringUtil.replaceAt(copy, l, '<span class="' + largeClass + '">' + char + '</span>');
				else
					copy = StringUtil.replaceAt(copy, l, char.toUpperCase());
			}
			
			field.htmlText = copy.toUpperCase();
		}
		
		/**
			Removes text overflow on a textfield with the option of an ommission indicator.
			
			@param field: Textfield to remove overflow.
			@param omissionIndicator: Text indication that an omission has occured, normally <code>"..."</code>; defaults to no indication.
			@return Returns the omitted text; if there was no text ommitted function returns a empty String (<code>""</code>).
			@usageNote The TextField cannot contain HTML text.
		*/
		public static function removeOverFlow(field:TextField, omissionIndicator:String = ""):String {
			if (!TextFieldUtil.hasOverFlow(field))
				return '';
			
			omissionIndicator ||= '';
			
			var originalCopy:String        = field.text;
			var lines:Array                = field.text.split('. ');
			var isStillOverflowing:Boolean = false;
			var words:Array;
			var lastSentence:String;
			var sentences:String;
			var overFlow:String;
			
			while (TextFieldUtil.hasOverFlow(field)) {
				lastSentence = String(lines.pop());
				field.text   = (lines.length == 0) ? '' : lines.join('. ') + '. ';
			}
			
			sentences = (lines.length == 0) ? '' : lines.join('. ') + '. ';
			words     = lastSentence.split(' ');
			field.appendText(lastSentence);
			
			while (TextFieldUtil.hasOverFlow(field)) {
				if (words.length == 0) {
					isStillOverflowing = true;
					break;
				} else {
					words.pop();
					
					if (words.length == 0)
						field.text = sentences.substr(0, -1) + omissionIndicator;
					else
						field.text = sentences + words.join(' ') + omissionIndicator;
				}
			}
			
			if (isStillOverflowing) {
				words = field.text.split(' ');
				
				while (TextFieldUtil.hasOverFlow(field)) {
					words.pop();
					field.text = words.join(' ') + omissionIndicator;
				}
			}
			
			overFlow = originalCopy.substring(field.text.length);
			
			return (overFlow.charAt(0) == ' ') ? overFlow.substring(1) : overFlow;
		}
	}
}