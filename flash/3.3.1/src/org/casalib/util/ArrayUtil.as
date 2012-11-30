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
	import org.casalib.util.NumberUtil;
	
	
	/**
		Utilities for sorting, searching and manipulating Arrays.
		
		@author Aaron Clinger
		@author David Nelson
		@author Jon Adams
		@version 02/09/10
	*/
	public class ArrayUtil {
		
		/**
			Returns the first item that match the key values of all properties of the object <code>keyValues</code>.
			
			@param inArray: Array to search for an element with every key value in the object <code>keyValues</code>.
			@param keyValues: An object with key value pairs.
			@return Returns the first matched item; otherwise <code>null</code>.
			@example
				<code>
					var people:Array  = new Array({name: "Aaron", sex: "Male", hair: "Brown"}, {name: "Linda", sex: "Female", hair: "Blonde"}, {name: "Katie", sex: "Female", hair: "Brown"}, {name: "Nikki", sex: "Female", hair: "Blonde"});
					var person:Object = ArrayUtil.getItemByKeys(people, {sex: "Female", hair: "Brown"});
					
					trace(person.name); // Traces "Katie"
				</code>
		*/
		public static function getItemByKeys(inArray:Array, keyValues:Object):* {
			var i:int = -1;
			var item:*;
			var hasKeys:Boolean;
			
			while (++i < inArray.length) {
				item    = inArray[i];
				hasKeys = true;
				
				for (var j:String in keyValues)
					if (!item.hasOwnProperty(j) || item[j] != keyValues[j])
						hasKeys = false;
				
				if (hasKeys)
					return item;
			}
			
			return null;
		}
		
		/**
			Returns all items that match the key values of all properties of the object <code>keyValues</code>.
			
			@param inArray: Array to search for elements with every key value in the object <code>keyValues</code>.
			@param keyValues: An object with key value pairs.
			@return Returns all the matched items.
			@example
				<code>
					var people:Array        = new Array({name: "Aaron", sex: "Male", hair: "Brown"}, {name: "Linda", sex: "Female", hair: "Blonde"}, {name: "Katie", sex: "Female", hair: "Brown"}, {name: "Nikki", sex: "Female", hair: "Blonde"});
					var blondeFemales:Array = ArrayUtil.getItemsByKeys(people, {sex: "Female", hair: "Blonde"});
					
					for each (var p:Object in blondeFemales) {
						trace(p.name);
					}
				</code>
		*/
		public static function getItemsByKeys(inArray:Array, keyValues:Object):Array {
			var t:Array = new Array();
			var i:int   = -1;
			var item:*;
			var hasKeys:Boolean;
			
			while (++i < inArray.length) {
				item    = inArray[i];
				hasKeys = true;
				
				for (var j:String in keyValues)
					if (!item.hasOwnProperty(j) || item[j] != keyValues[j])
						hasKeys = false;
				
				if (hasKeys)
					t.push(item);
			}
			
			return t;
		}
		
		/**
			Returns the first item that match a key value of any property of the object <code>keyValues</code>.
			
			@param inArray: Array to search for an element with any key value in the object <code>keyValues</code>.
			@param keyValues: An object with key value pairs.
			@return Returns the first matched item; otherwise <code>null</code>.
			@example
				<code>
					var people:Array  = new Array({name: "Aaron", sex: "Male", hair: "Brown"}, {name: "Linda", sex: "Female", hair: "Blonde"}, {name: "Katie", sex: "Female", hair: "Brown"}, {name: "Nikki", sex: "Female", hair: "Blonde"});
					var person:Object = ArrayUtil.getItemByAnyKey(people, {sex: "Female", hair: "Brown"});
					
					trace(person.name); // Traces "Aaron"
				</code>
		*/
		public static function getItemByAnyKey(inArray:Array, keyValues:Object):* {
			var i:int = -1;
			var item:*;
			
			while (++i < inArray.length) {
				item = inArray[i];
				
				for (var j:String in keyValues)
					if (item.hasOwnProperty(j) && item[j] == keyValues[j])
						return item;
			}
			
			return null;
		}
		
		/**
			Returns all items that match a key value of any property of the object <code>keyValues</code>.
			
			@param inArray: Array to search for elements with any key value in the object <code>keyValues</code>.
			@param keyValues: An object with key value pairs.
			@return Returns all the matched items.
			@example
				<code>
					var people:Array         = new Array({name: "Aaron", sex: "Male", hair: "Brown"}, {name: "Linda", sex: "Female", hair: "Blonde"}, {name: "Katie", sex: "Female", hair: "Brown"}, {name: "Nikki", sex: "Female", hair: "Blonde"});
					var brownOrFemales:Array = ArrayUtil.getItemsByAnyKey(people, {sex: "Female", hair: "Brown"});
					
					for each (var p:Object in brownOrFemales) {
						trace(p.name);
					}
				</code>
		*/
		public static function getItemsByAnyKey(inArray:Array, keyValues:Object):Array {
			var t:Array = new Array();
			var i:int   = -1;
			var item:*;
			var hasKeys:Boolean;
			
			while (++i < inArray.length) {
				item    = inArray[i];
				hasKeys = true;
				
				for (var j:String in keyValues) {
					if (item.hasOwnProperty(j) && item[j] == keyValues[j]) {
						t.push(item);
						
						break;
					}
				}
			}
			
			return t;
		}
		
		/**
			Returns the first element that matches <code>match</code> for the property <code>key</code>.
			
			@param inArray: Array to search for an element with a <code>key</code> that matches <code>match</code>.
			@param key: Name of the property to match.
			@param match: Value to match against.
			@return Returns matched item; otherwise <code>null</code>.
		*/
		public static function getItemByKey(inArray:Array, key:String, match:*):* {
			for each (var item:* in inArray)
				if (item.hasOwnProperty(key))
					if (item[key] == match)
						return item;
			
			return null;
		}
		
		/**
			Returns every element that matches <code>match</code> for the property <code>key</code>.
			
			@param inArray: Array to search for object with <code>key</code> that matches <code>match</code>.
			@param key: Name of the property to match.
			@param match: Value to match against.
			@return Returns all the matched items.
		*/
		public static function getItemsByKey(inArray:Array, key:String, match:*):Array {
			var t:Array = new Array();
			
			for each (var item:* in inArray)
				if (item.hasOwnProperty(key))
					if (item[key] == match)
						t.push(item);
			
			return t;
		}
		
		/**
			Returns the first element that is compatible with a specific data type, class, or interface.
			
			@param inArray: Array to search for an element of a specific type.
			@param type: The type to compare the elements to.
			@return Returns all the matched elements.
		*/
		public static function getItemByType(inArray:Array, type:Class):* {
			for each (var item:* in inArray)
				if (item is type)
					return item;
			
			return null;
		}
		
		/**
			Returns every element that is compatible with a specific data type, class, or interface.
			
			@param inArray: Array to search for elements of a specific type.
			@param type: The type to compare the elements to.
			@return Returns all the matched elements.
		*/
		public static function getItemsByType(inArray:Array, type:Class):Array {
			var t:Array = new Array();
			
			for each (var item:* in inArray)
				if (item is type)
					t.push(item);
			
			return t;
		}
		
		/**
			Returns the value of the specified property for every element where the key is present.
			
			@param inArray: Array to get the values from.
			@param key: Name of the property to retrieve the value of.
			@return Returns all the present key values.
		*/
		public static function getValuesByKey(inArray:Array, key:String):Array {
			var k:Array = new Array();
			
			for each (var item:* in inArray)
				if (item.hasOwnProperty(key))
					k.push(item[key]);
			
			return k;
		}
		
		/**
			Determines if two Arrays contain the same elements at the same index.
			
			@param first: First Array to compare to the <code>second</code>.
			@param second: Second Array to compare to the <code>first</code>.
			@return Returns <code>true</code> if Arrays are the same; otherwise <code>false</code>.
		*/
		public static function equals(first:Array, second:Array):Boolean {
			var i:uint = first.length;
			if (i != second.length)
				return false;
			
			while (i--)
				if (first[i] != second[i])
					return false;
			
			return true;
		}
		
		/**
			Modifies original Array by adding all the elements from another Array at a specified position.
			
			@param tarArray: Array to add elements to.
			@param items: Array of elements to add.
			@param index: Position where the elements should be added.
			@return Returns <code>true</code> if the Array was changed as a result of the call; otherwise <code>false</code>.
			@example
				<code>
					var alphabet:Array = new Array("a", "d", "e");
					var parts:Array    = new Array("b", "c");
					
					ArrayUtil.addItemsAt(alphabet, parts, 1);
					
					trace(alphabet); // Traces a,b,c,d,e
				</code>
		*/
		public static function addItemsAt(tarArray:Array, items:Array, index:int = 0x7FFFFFFF):Boolean {
			if (items.length == 0)
				return false;
			
			var args:Array = items.concat();
			args.splice(0, 0, index, 0);
			
			tarArray.splice.apply(null, args);
			
			return true;
		}
		
		/**
			Creates new Array composed of only the non-identical elements of passed Array.
			
			@param inArray: Array to remove equivalent items.
			@return A new Array composed of only unique elements.
			@example
				<code>
					var numberArray:Array = new Array(1, 2, 3, 4, 4, 4, 4, 5);
					trace(ArrayUtil.removeDuplicates(numberArray)); // Traces 1,2,3,4,5
				</code>
		*/
		public static function removeDuplicates(inArray:Array):Array {
			return inArray.filter(ArrayUtil._removeDuplicatesFilter);
		}
		
		protected static function _removeDuplicatesFilter(e:*, i:int, inArray:Array):Boolean {
			return (i == 0) ? true : inArray.lastIndexOf(e, i - 1) == -1;
		}
		
		/**
			Modifies original Array by removing all items that are identical to the specified item.
			
			@param tarArray: Array to remove passed <code>item</code>.
			@param item: Element to remove.
			@return The amount of removed elements that matched <code>item</code>, if none found returns <code>0 </code>.
			@example
				<code>
					var numberArray:Array = new Array(1, 2, 3, 7, 7, 7, 4, 5);
					trace("Removed " + ArrayUtil.removeItem(numberArray, 7) + " items."); // Traces 3
					trace(numberArray); // Traces 1,2,3,4,5
				</code>
		*/
		public static function removeItem(tarArray:Array, item:*):uint {
			var i:int  = tarArray.indexOf(item);
			var f:uint = 0;
			
			while (i != -1) {
				tarArray.splice(i, 1);
				
				i = tarArray.indexOf(item, i);
				
				f++;
			}
			
			return f;
		}
		
		/**
			Removes only the specified items in an Array.
			
			@param tarArray: Array to remove specified items from.
			@param items: Array of elements to remove.
			@return Returns <code>true</code> if the Array was changed as a result of the call; otherwise <code>false</code>.
			@example
				<code>
					var numberArray:Array = new Array(1, 2, 3, 7, 7, 7, 4, 5);
					ArrayUtil.removeItems(numberArray, new Array(1, 3, 7, 5));
					trace(numberArray); // Traces 2,4
				</code>
		*/
		public static function removeItems(tarArray:Array, items:Array):Boolean {
			var removed:Boolean = false;
			var l:uint          = tarArray.length;
			
			while (l--) {
				if (items.indexOf(tarArray[l]) > -1) {
					tarArray.splice(l, 1);
					removed = true;
				}
			}
			
			return removed;
		}
		
		/**
			Retains only the specified items in an Array.
			
			@param tarArray: Array to remove non specified items from.
			@param items: Array of elements to keep.
			@return Returns <code>true</code> if the Array was changed as a result of the call; otherwise <code>false</code>.
			@example
				<code>
					var numberArray:Array = new Array(1, 2, 3, 7, 7, 7, 4, 5);
					ArrayUtil.retainItems(numberArray, new Array(2, 4));
					trace(numberArray); // Traces 2,4
				</code>
		*/
		public static function retainItems(tarArray:Array, items:Array):Boolean {
			var removed:Boolean = false;
			var l:uint          = tarArray.length;
			
			while (l--) {
				if (items.indexOf(tarArray[l]) == -1) {
					tarArray.splice(l, 1);
					removed = true;
				}
			}
			
			return removed;
		}
		
		/**
			Finds out how many instances of <code>item</code> Array contains.
			
			@param inArray: Array to search for <code>item</code> in.
			@param item: Object to find.
			@return The amount of <code>item</code>'s found; if none were found returns <code>0 </code>.
			@example
				<code>
					var numberArray:Array = new Array(1, 2, 3, 7, 7, 7, 4, 5);
					trace("numberArray contains " + ArrayUtil.contains(numberArray, 7) + " 7's."); // Traces 3
				</code>
		*/
		public static function contains(inArray:Array, item:*):uint {
			var i:int  = inArray.indexOf(item, 0);
			var t:uint = 0;
			
			while (i != -1) {
				i = inArray.indexOf(item, i + 1);
				t++;
			}
			
			return t;
		}
		
		/**
			Determines if Array contains all items.
			
			@param inArray: Array to search for <code>items</code> in.
			@param items: Array of elements to search for.
			@return Returns <code>true</code> if <code>inArray</code> contains all elements of <code>items</code>; otherwise <code>false</code>.
			@example
				<code>
					var numberArray:Array = new Array(1, 2, 3, 4, 5);
					trace(ArrayUtil.containsAll(numberArray, new Array(1, 3, 5))); // Traces true
				</code>
		*/
		public static function containsAll(inArray:Array, items:Array):Boolean {
			var l:uint = items.length;
			
			while (l--)
				if (inArray.indexOf(items[l]) == -1)
					return false;
			
			return true;
		}
		
		/**
			Determines if Array <code>inArray</code> contains any element of Array <code>items</code>.
			
			@param inArray: Array to search for <code>items</code> in.
			@param items: Array of elements to search for.
			@return Returns <code>true</code> if <code>inArray</code> contains any element of <code>items</code>; otherwise <code>false</code>.
			@example
				<code>
					var numberArray:Array = new Array(1, 2, 3, 4, 5);
					trace(ArrayUtil.containsAny(numberArray, new Array(9, 3, 6))); // Traces true
				</code>
		*/
		public static function containsAny(inArray:Array, items:Array):Boolean {
			var l:uint = items.length;
			
			while (l--)
				if (inArray.indexOf(items[l]) > -1)
					return true;
			
			return false;
		}
		
		/**
			Compares two Arrays and finds the first index where they differ.
			
			@param first: First Array to compare to the <code>second</code>.
			@param second: Second Array to compare to the <code>first</code>.
			@param fromIndex: The location in the Arrays from which to start searching for a difference.
			@return The first position/index where the Arrays differ; if Arrays are identical returns <code>-1</code>.
			@example
				<code>
					var color:Array     = new Array("Red", "Blue", "Green", "Indigo", "Violet");
					var colorsAlt:Array = new Array("Red", "Blue", "Green", "Violet");
					
					trace(ArrayUtil.getIndexOfDifference(color, colorsAlt)); // Traces 3
				</code>
		*/
		public static function getIndexOfDifference(first:Array, second:Array, fromIndex:uint = 0):int {
			var i:int = fromIndex - 1;
			
			while (++i < first.length)
				if (first[i] != second[i])
					return i;
			
			return -1;
		}
		
		/**
			Returns a random element from an array.
			
			@param inArray: Array to get random item from.
			@param keys: A random object from the array.
			@return A random item from the array.
			@example
				<code>
					var numberArray:Array = new Array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
					trace(ArrayUtil.random(numberArray));
				</code>
		*/
		public static function random(inArray:Array):* {
			return ArrayUtil.randomize(inArray)[0];
		}
		
		/**
			Creates new Array composed of passed Array's items in a random order.
			
			@param inArray: Array to create copy of, and randomize.
			@return A new Array composed of passed Array's items in a random order.
			@example
				<code>
					var numberArray:Array = new Array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
					trace(ArrayUtil.randomize(numberArray));
				</code>
		*/
		public static function randomize(inArray:Array):Array {
			var t:Array = new Array();
			var r:Array = inArray.sort(ArrayUtil._sortRandom, Array.RETURNINDEXEDARRAY);
			var i:int   = -1;
			
			while (++i < inArray.length)
				t.push(inArray[r[i]]);
			
			return t;
		}
		
		protected static function _sortRandom(a:*, b:*):int {
			return NumberUtil.randomIntegerWithinRange(0, 1) ? 1 : -1;
		}
		
		/**
			Adds all items in <code>inArray</code> and returns the value.
			
			@param inArray: Array composed only of numbers.
			@return The total of all numbers in <code>inArray</code> added.
			@example
				<code>
					var numberArray:Array = new Array(2, 3);
					trace("Total is: " + ArrayUtil.sum(numberArray)); // Traces 5
				</code>
		*/
		public static function sum(inArray:Array):Number {
			var t:Number = 0;
			var l:uint   = inArray.length;
			
			while (l--)
				t += inArray[l];
			
			return t;
		}
		
		/**
			Averages the values in <code>inArray</code>.
			
			@param inArray: Array composed only of numbers.
			@return The average of all numbers in the <code>inArray</code>.
			@example
				<code>
					var numberArray:Array = new Array(2, 3, 8, 3);
					trace("Average is: " + ArrayUtil.average(numberArray)); // Traces 4
				</code>
		*/
		public static function average(inArray:Array):Number {
			if (inArray.length == 0)
				return 0;
			
			return ArrayUtil.sum(inArray) / inArray.length;
		}
		
		/**
			Finds the lowest value in <code>inArray</code>.
			
			@param inArray: Array composed only of numbers.
			@return The lowest value in <code>inArray</code>.
			@example
				<code>
					var numberArray:Array = new Array(2, 1, 5, 4, 3);
					trace("The lowest value is: " + ArrayUtil.getLowestValue(numberArray)); // Traces 1
				</code>
		*/
		public static function getLowestValue(inArray:Array):Number {
			return inArray[inArray.sort(16|8)[0]];
		}
		
		/**
			Finds the highest value in <code>inArray</code>.
			
			@param inArray: Array composed only of numbers.
			@return The highest value in <code>inArray</code>.
			@example
				<code>
					var numberArray:Array = new Array(2, 1, 5, 4, 3);
					trace("The highest value is: " + ArrayUtil.getHighestValue(numberArray)); // Traces 5
				</code>
		*/
		public static function getHighestValue(inArray:Array):Number {
			return inArray[inArray.sort(16|8)[inArray.length - 1]];
		}
	}
}