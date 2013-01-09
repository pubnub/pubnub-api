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
	import flash.xml.XMLDocument;
	import flash.xml.XMLNodeType;
	import flash.xml.XMLNode;
	import org.casalib.util.NumberUtil;
	
	
	/**
		Utilities for manipulating and searching Strings.
		
		@author Aaron Clinger
		@author Mike Creighton
		@author David Nelson
		@author Jon Adams
		@version 06/23/11
	*/
	public class StringUtil {
		public static const WHITESPACE:String = " \t\n\r"; /**< Whitespace characters (space, tab, new line and return). */
		public static var SMALL_WORDS:Array   = new Array("a", "an", "and", "as", "at", "but", "by", "en", "for", "if", "is", "in", "of", "on", "or", "the", "to", "v", "via", "vs"); /**< The default list of small/short words to be used with {@link #toTitleCase}. */
		
		
		/**
			Determines if the singular or plural versions of a noun should be used given a number.
			
			@param count: The number of items.
			@param singular: The singular version of the word.
			@param plural: The plural version of the word. If no word is defined method appends "s" to the singular word. 
			@return The singular or plural version of the word.
			@example
				<code>
					trace(StringUtil.pluralize(1, "Dog")); // Traces "Dog"
					trace(StringUtil.pluralize(3, "Dog")); // Traces "Dogs"
					trace(StringUtil.pluralize(2, "Child", "Children")); // Traces "Children"
				</code>
		*/
		public static function pluralize(count:int, singular:String, plural:String = null):String {
			plural ||= singular + 's';
			
			return Math.abs(count) == 1 ? singular : plural;
		}
		
		/**
			Returns a shortened String.
			
			@param source: String to shorten.
			@param trailing: The number of characters to remove from the end of the String.
			@param leading: The number of characters to remove from the begining of the String.
			@param separator: Characters to seperate the begining and the end of the String.
			@return The shortened String.
			@example
				<code>
					trace(StringUtil.truncate('Mississippi', 2, 3, '...')); // Traces "Mis...pi"
				</code>
		*/
		public static function truncate(source:String, trailing:uint, leading:uint = 0, separator:String = ""):String {
			const lead:String  = source.substr(0, leading);
			const trail:String = source.substr(-trailing, trailing);
			
			return lead + separator + trail;
		}
		
		
		/**
			Transforms source String to title case.
			
			@param source: String to return as title cased.
			@param lowerCaseSmallWords: Indicates to make {@link #SMALL_WORDS small words} lower case <code>true</code>, or to capitalized small words <code>false</code>.
			@return String with capitalized words.
		*/
		public static function toTitleCase(source:String, lowerCaseSmallWords:Boolean = true):String {
			source = StringUtil._checkWords(source.toLowerCase(), ' ', true, lowerCaseSmallWords);
			
			var parts:Array = source.split(' ');
			var last:int    = parts.length - 1;
			
			if (!StringUtil._isIgnoredWord(parts[0]))
				parts[0] = StringUtil._capitalizeFirstLetter(parts[0]);
				
			if (!StringUtil._isIgnoredWord(parts[last]) && (!lowerCaseSmallWords || !StringUtil._isSmallWord(parts[last])))
				parts[last] = StringUtil._capitalizeFirstLetter(parts[last]);
			
			source = parts.join(' ');
			
			if (StringUtil.contains(source, ': ')) {
				var i:int = -1;
				parts     = source.split(': ');
				
				while (++i < parts.length)
					parts[i] = StringUtil._capitalizeFirstLetter(parts[i]);
				
				source = parts.join(': ');
			}
			
			return source;
		}
		
		protected static function _checkWords(source:String, delimiter:String, checkForDashes:Boolean = false, lowerCaseSmallWords:Boolean = false):String {
			var words:Array = source.split(delimiter);
			var l:int       = words.length;
			var word:String;
			
			while (l--) {
				word = words[l];
				
				words[l] = StringUtil._checkWord(word, checkForDashes, lowerCaseSmallWords);
			}
			
			return words.join(delimiter);
		}
		
		protected static function _checkWord(word:String, checkForDashes:Boolean, lowerCaseSmallWords:Boolean):String {
			if (StringUtil._isIgnoredWord(word))
				return word;
			
			if (lowerCaseSmallWords)
				if (StringUtil._isSmallWord(word))
					return word.toLowerCase();
			
			if (checkForDashes) {
				var dashes:Array = new Array('-', '–', '—');
				var i:int        = -1;
				var dashFound:Boolean;
				
				while (++i < dashes.length) {
					if (StringUtil.contains(word, dashes[i]) != 0) {
						word = StringUtil._checkWords(word, dashes[i], false, true);
						dashFound = true;
					}
				}
				
				if (dashFound)
					return word;
			}
			
			return StringUtil._capitalizeFirstLetter(word);
		}
		
		protected static function _isIgnoredWord(word:String):Boolean {
			var periodIndex:int = word.indexOf('.');
			var upperIndex:int  = StringUtil.indexOfUpperCase(word);
			
			if (periodIndex != -1 && periodIndex != word.length - 1 || upperIndex != -1 && upperIndex != 0)
				return true;
			
			return false;
		}
		
		protected static function _isSmallWord(word:String):Boolean {
			return StringUtil.SMALL_WORDS.indexOf(StringUtil.getLettersFromString(word).toLowerCase()) > -1;
		}
		
		protected static function _capitalizeFirstLetter(source:String):String {
			var i:int = -1;
			while (++i < source.length)
				if (!StringUtil.isPunctuation(source.charAt(i)))
					return StringUtil.replaceAt(source, i, source.charAt(i).toUpperCase());
			
			return source;
		}
		
		/**
			Creates an "universally unique" identifier (RFC 4122, version 4).
			
			@return Returns an UUID.
		*/
		public static function uuid():String {
			const specialChars:Array = new Array('8', '9', 'A', 'B');
			
			return StringUtil.createRandomIdentifier(8, 15) + '-' + StringUtil.createRandomIdentifier(4, 15) + '-4' + StringUtil.createRandomIdentifier(3, 15) + '-' + specialChars[NumberUtil.randomIntegerWithinRange(0, 3)] + StringUtil.createRandomIdentifier(3, 15) + '-' + StringUtil.createRandomIdentifier(12, 15);
		}
		
		/**
			Creates a random identifier of a specified length and complexity.
			
			@param length: The character length of the random identifier.
			@param radix: The number of unique/allowed values for each character (61 is the maximum complexity).
			@return Returns a random identifier.
			@usageNote For a case-insensitive identifier pass in a max <code>radix</code> of 35, for a numberic identifier pass in a max <code>radix</code> of 9.
		*/
		public static function createRandomIdentifier(length:uint, radix:uint = 61):String {
			const characters:Array = new Array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z');
			const id:Array         = new Array();
			radix                  = (radix > 61) ? 61 : radix;
			
			while (length--) {
				id.push(characters[NumberUtil.randomIntegerWithinRange(0, radix)]);
			}
			
			return id.join('');
		}
		
		/**
			Detects URLs in a String and wraps them in a link.
			
			@param source: String in which to automatically wrap links around URLs.
			@param window: The browser window or HTML frame in which to display the URL.
			@param className: An optional CSS class name to add to the link. You can specify multiple classes by seperating the class names with spaces.
			@return Returns the String with any URLs wrapped in a link.
			@see <a href="http://daringfireball.net/2010/07/improved_regex_for_matching_urls">Read more about the regular expression used by this method.</a>
		*/
		public static function autoLink(source:String, window:String = "_blank", className:String = null):String {
			const pattern:RegExp = new RegExp('(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:\'".,<>?«»“”‘’]))', 'g')
			className            = (className != "" && className != null) ? ' class="' + className + '"' : '';
			window               = (window != null) ? ' target="' + window + '"' : '';
			
			return source.replace(pattern, '<a href="$1"' + window + className + '>$1</a>');
		}
		
		/**
			Converts all applicable characters to HTML entities.
			
			@param source: String to convert.
			@return Returns the converted string.
		*/
		public static function htmlEncode(source:String):String {
			return new XML(new XMLNode(XMLNodeType.TEXT_NODE, source)).toXMLString();
		}
		
		/**
			Converts all HTML entities to their applicable characters.
			
			@param source: String to convert.
			@return Returns the converted string.
		*/
		public static function htmlDecode(source:String):String {
			return new XMLDocument(source).firstChild.nodeValue;
		}
		
		/**
			Determines if String is only comprised of punctuation characters (any character other than the letters or numbers).
			
			@param source: String to check.
			@param allowSpaces: Indicates to count spaces as punctuation <code>true</code>, or not to <code>false</code>.
			@return Returns <code>true</code> if String is only punctuation; otherwise <code>false</code>.
		*/
		public static function isPunctuation(source:String, allowSpaces:Boolean = true):Boolean {
			if (StringUtil.getNumbersFromString(source).length != 0 || StringUtil.getLettersFromString(source).length != 0)
				return false;
			
			if (!allowSpaces)
				return source.split(' ').length == 1;
			
			return true;
		}
		
		/**
			Determines if String is only comprised of upper case letters.
			
			@param source: String to check.
			@return Returns <code>true</code> if String is only upper case characters; otherwise <code>false</code>.
			@usageNote This function counts numbers, spaces, punctuation and special characters as upper case.
		*/
		public static function isUpperCase(source:String):Boolean {
			if (source != source.toUpperCase())
				return false;
			
			return true;
		}
		
		/**
			Determines if String is only comprised of lower case letters.
			
			@param source: String to check.
			@return Returns <code>true</code> if String is only lower case characters; otherwise <code>false</code>.
			@usageNote This function counts numbers, spaces, punctuation and special characters as lower case.
		*/
		public static function isLowerCase(source:String):Boolean {
			if (source != source.toLowerCase())
				return false;
			
			return true;
		}
		
		/**
			Determines if String is only comprised of numbers.
			
			@param source: String to check.
			@return Returns <code>true</code> if String is a number; otherwise <code>false</code>.
		*/
		public static function isNumber(source:String):Boolean {
			var trimmed:String = StringUtil.trim(source);
			
			if (trimmed.length < source.length || source.length == 0)
				return false;
			
			return !isNaN(Number(source));
		}
		
		/**
			Searches the String for an occurrence of an upper case letter.
			
			@param source: String to search for a upper case letter.
			@return The index of the first occurrence of a upper case letter or <code>-1</code>.
		*/
		public static function indexOfUpperCase(source:String, startIndex:uint = 0):int {
			var letters:Array = source.split('');
			var i:int         = startIndex - 1;
			
			while (++i < letters.length)
				if (letters[i] == letters[i].toUpperCase() && letters[i] != letters[i].toLowerCase())
					return i;
			
			return -1;
		}
		
		/**
			Searches the String for an occurrence of a lower case letter.
			
			@param source: String to search for a lower case letter.
			@return The index of the first occurrence of a lower case letter or <code>-1</code>.
		*/
		public static function indexOfLowerCase(source:String, startIndex:uint = 0):int {
			var letters:Array = source.split('');
			var i:int         = startIndex - 1;
			
			while (++i < letters.length)
				if (letters[i] == letters[i].toLowerCase() && letters[i] != letters[i].toUpperCase())
					return i;
			
			return -1;
		}
		
		/**
			Returns all the numeric characters from a String.
			
			@param source: String to return numbers from.
			@return String containing only numbers.
		*/
		public static function getNumbersFromString(source:String):String {
			var pattern:RegExp = /[^0-9]/g;
			return source.replace(pattern, '');
		}
		
		/**
			Returns all the letter characters from a String.
			
			@param source: String to return letters from.
			@return String containing only letters.
		*/
		public static function getLettersFromString(source:String):String {
			var pattern:RegExp = /[[:digit:]|[:punct:]|\s]/g;
			return source.replace(pattern, '');
		}
		
		/**
			Determines if String contains search String.
			
			@param source: String to search in.
			@param search: String to search for.
			@return Returns the frequency of the search term found in source String.
		*/
		public static function contains(source:String, search:String):uint {
			var pattern:RegExp = new RegExp(search, 'g');
			return source.match(pattern).length;
		}
		
		/**
			Strips whitespace (or other characters) from the beginning of a String.
			
			@param source: String to remove characters from.
			@param removeChars: Characters to strip (case sensitive). Defaults to whitespace characters.
			@return String with characters removed.
		*/
		public static function trimLeft(source:String, removeChars:String = StringUtil.WHITESPACE):String {
			var pattern:RegExp = new RegExp('^[' + removeChars + ']+', '');
			return source.replace(pattern, '');
		}
		
		/**
			Strips whitespace (or other characters) from the end of a String.
			
			@param source: String to remove characters from.
			@param removeChars: Characters to strip (case sensitive). Defaults to whitespace characters.
			@return String with characters removed.
		*/
		public static function trimRight(source:String, removeChars:String = StringUtil.WHITESPACE):String {
			var pattern:RegExp = new RegExp('[' + removeChars + ']+$', '');
			return source.replace(pattern, '');
		}
		
		/**
			Strips whitespace (or other characters) from the beginning and end of a String.
			
			@param source: String to remove characters from.
			@param removeChars: Characters to strip (case sensitive). Defaults to whitespace characters.
			@return String with characters removed.
		*/
		public static function trim(source:String, removeChars:String = StringUtil.WHITESPACE):String {
			var pattern:RegExp = new RegExp('^[' + removeChars + ']+|[' + removeChars + ']+$', 'g');
			return source.replace(pattern, '');
		}
		
		/**
			Removes additional spaces from String.
			
			@param source: String to remove extra spaces from.
			@return String with additional spaces removed.
		*/
		public static function removeExtraSpaces(source:String):String {
			var pattern:RegExp = /( )+/g;
			return StringUtil.trim(source.replace(pattern, ' '), ' ');
		}
		
		/**
			Removes tabs, linefeeds, carriage returns and spaces from String.
			
			@param source: String to remove whitespace from.
			@return String with whitespace removed.
		*/
		public static function removeWhitespace(source:String):String {
			var pattern:RegExp = new RegExp('[' + StringUtil.WHITESPACE + ']', 'g');
			return source.replace(pattern, '');
		}
		
		/**
			Removes characters from a source String.
			
			@param source: String to remove characters from.
			@param remove: String describing characters to remove.
			@return String with characters removed.
		*/
		public static function remove(source:String, remove:String):String {
			return StringUtil.replace(source, remove, '');
		}
		
		/**
			Replaces target characters with new characters.
			
			@param source: String to replace characters from.
			@param remove: String describing characters to remove.
			@param replace: String to replace removed characters.
			@return String with characters replaced.
		*/
		public static function replace(source:String, remove:String, replace:String):String {
			return source.split(remove).join(replace);
		}
		
		/**
			Removes a character at a specific index.
			
			@param source: String to remove character from.
			@param position: Position of character to remove.
			@return String with character removed.
		*/
		public static function removeAt(source:String, position:int):String {
			return StringUtil.replaceAt(source, position, '');
		}
		
		/**
			Replaces a character at a specific index with new characters.
			
			@param source: String to replace characters from.
			@param position: Position of character to replace.
			@param replace: String to replace removed character.
			@return String with character replaced.
		*/
		public static function replaceAt(source:String, position:int, replace:String):String {
			var parts:Array = source.split('');
			parts.splice(position, 1, replace);
			return parts.join('');
		}
		
		/**
			Adds characters at a specific index.
			
			@param source: String to add characters to.
			@param position: Position in which to add characters.
			@param addition: String to add.
			@return String with characters added.
		*/
		public static function addAt(source:String, position:int, addition:String):String {
			var parts:Array = source.split('');
			parts.splice(position, 0, addition);
			return parts.join('');
		}
		
		/**
			Counts the number of words in a String.
			
			@param source: String in which to count words.
			@return The amount of words.
		*/
		public static function getWordCount(source:String):uint {
			return StringUtil.removeExtraSpaces(StringUtil.trim(source)).split(' ').length;
		}
		
		/**
			Extracts all the unique characters from a source String.
			
			@param source: String to find unique characters within.
			@return String containing unique characters from source String.
		*/
		public static function getUniqueCharacters(source:String):String {
			var unique:String = '';
			var i:uint        = 0;
			var char:String;
			
			while (i < source.length) {
				char = source.charAt(i);
				
				if (unique.indexOf(char) == -1)
					unique += char;
				
				i++;
			}
			
			return unique;
		}
	}
}