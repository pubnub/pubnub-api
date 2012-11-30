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
package org.casalib.collection {
	import org.casalib.collection.IList;
	import org.casalib.util.ArrayUtil;
	
	/**
		An ordered or sequence collection that can contain duplicates. Loosely follows Java's List API.
		
		@author Aaron Clinger
		@author Dave Nelson
		@version 06/04/09
		@see UniqueList
	*/
	public class List implements IList {
		protected var _collection:Array;
		
		
		/**
			Creates a new List;
			
			@param collection: An Array of items to populate the contents of this list.
		*/
		public function List(collection:Array = null) {
			this._collection = (collection == null) ? new Array() : collection.concat();
		}
		
		/**
			Appends the specified item to the end of this list.
			
			@param item: Element to be inserted.
			@return Returns <code>true</code> if the list was changed as a result of the call; otherwise <code>false</code>.
		*/
		public function addItem(item:*):Boolean {
			this._collection.push(item);
			
			return true;
		}
		
		/**
			Inserts an item as a specified position.
			
			@param item: Element to be inserted.
			@param index: Position where the elements should be added.
			@return Returns <code>true</code> if the list was changed as a result of the call; otherwise <code>false</code>.
		*/
		public function addItemAt(item:*, index:int):Boolean {
			this._collection.splice(index, 0, item);
			
			return true;
		}
		
		/**
			Modifies original list by adding all the elements from another list.
			
			@param items: List of elements to add.
			@return Returns <code>true</code> if the list was changed as a result of the call; otherwise <code>false</code>.
		*/
		public function addItems(items:IList):Boolean {
			this._collection = this._collection.concat(items.toArray());
			
			return true;
		}
		
		/**
			Modifies original list by adding all the elements from another list at a specified position.
			
			@param items: List of elements to add.
			@param index: Position where the elements should be added.
			@return Returns <code>true</code> if the list was changed as a result of the call; otherwise <code>false</code>.
		*/
		public function addItemsAt(items:IList, index:int = 0x7fffffff):Boolean {
			return ArrayUtil.addItemsAt(this._collection, items.toArray(), index);
		}
		
		/**
			Removes all of the items from this list.
		*/
		public function clear():void {
			this._collection.splice(0);
		}
		
		/**
			Determines if this list contains a specified element.
			
			@param item: Element to search for.
			@return Returns <code>true</code> if the list contains the element; otherwise <code>false</code>.
		*/
		public function contains(item:*):Boolean {
			return (this.indexOf(item) == -1) ? false : true;
		}
		
		/**
			Determines if this list contains all of the elements of the specified list.
			
			@param items: List of elements to be checked for containment.
			@return Returns <code>true</code> if list contains all elements of the list; otherwise <code>false</code>.
		*/
		public function containsAll(items:IList):Boolean {
			return ArrayUtil.containsAll(this._collection, items.toArray());
		}
		
		/**
			Determines if the list specified in the <code>list</code> parameter is equal to this list object.
			
			@param list: An object that implements {@link IList}.
			@return Returns <code>true</code> if the object is equal to this list; otherwise <code>false</code>.
		*/
		public function equals(list:IList):Boolean {
			return ArrayUtil.equals(this._collection, list.toArray());
		}
		
		/**
			Returns the element at the specified position in this list.
			
			@param index: The position of the element to return.
			@return The element at the specified position in this list.
		*/
		public function getItemAt(index:uint):* {
			return this._collection[index];
		}
		
		/**
			Returns a portion of this list.
			
			@param startIndex: The starting position.
			@param endIndex: The ending position.
			@return The specified portion of the list.
		*/
		public function subList(startIndex:int = 0, endIndex:int = 16777215):IList {
			return new List(this._collection.slice(startIndex, endIndex));
		}
		
		/**
			Finds the position of the first occurrence of a specified item.
			
			@param item: The element to search for.
			@param fromIndex: The position in the list from which to start searching for the item.
			@return Returns the index of the last occurrence, or <code>-1</code> if the element doesn't exist.
		*/
		public function indexOf(item:*, fromIndex:int = 0):int {
			return this._collection.indexOf(item, fromIndex);
		}
		
		/**
			Determines if this list contains no elements.
			
			@return Returns <code>true</code> if the list contains no items; otherwise <code>false</code>.
		*/
		public function isEmpty():Boolean {
			return this.size == 0;
		}
		
		/**
			Finds the position of the last occurrence of a specified item.
			
			@param item: The element to search for.
			@param fromIndex: The position in the list from which to start searching for the item.
			@return Returns the index of the last occurrence, or <code>-1</code> if the element doesn't exist.
		*/
		public function lastIndexOf(item:*, fromIndex:int = 0x7fffffff):int {
			return this._collection.lastIndexOf(item, fromIndex);
		}
		
		/**
			The number of elements in the list.
		*/
		public function get size():uint {
			return this._collection.length;
		}
		
		/**
			Modifies the list by removing all items that are identical to the specified item.
			
			@param item: Element to remove.
			@return Returns <code>true</code> if the list was changed as a result of the call; otherwise <code>false</code>.
		*/
		public function removeAllInstancesOfItem(item:*):Boolean {
			return ArrayUtil.removeItem(this._collection, item) != 0;
		}
		
		/**
			Removes the first occurance of the specified item in the list.
			
			@param item: Element to remove.
			@return Returns <code>true</code> if the list contained the item; otherwise <code>false</code>.
		*/
		public function removeItem(item:*):Boolean {
			var i:int = this._collection.indexOf(item);
			
			if (i == -1)
				return false;
			
			this._collection.splice(i, 1);
			
			return true;
		}
		
		/**
			Removes the element at the specified position in this list.
			
			@param index: The position of the item to removed.
			@return The item previously at the specified index.
		*/
		public function removeItemAt(index:int):* {
			return this._collection.splice(index, 1)[0];
		}
		
		/**
			Removes only the specified items in a list.
			
			@param items: List of elements to remove.
			@return Returns <code>true</code> if the list was changed as a result of the call; otherwise <code>false</code>.
		*/
		public function removeItems(items:IList):Boolean {
			return ArrayUtil.removeItems(this._collection, items.toArray());
		}
		
		/**
			Retains only the specified items in a list.
			
			@param items: List of elements to keep.
			@return Returns <code>true</code> if the list was changed as a result of the call; otherwise <code>false</code>.
		*/
		public function retainItems(items:IList):Boolean {
			return ArrayUtil.retainItems(this._collection, items.toArray());
		}
		
		/**
			Replaces an item at a specified position.
			
			@param item: The item to be stored.
			@param index: The index of the item to replace.
			@return The element previously at the specified position.
		*/
		public function setItem(item:*, index:int):* {
			return this._collection.splice(index, 1, item)[0];
		}
		
		/**
			Returns an Array containing all of the elements in the list in order.
			
			@return Returns an Array containing all of the elements in the list in order.
		*/
		public function toArray():Array {
			return this._collection.concat();
		}
		
		/**
			Returns a list that is an exact copy of the original list.
			
			@return Returns a list that is an exact copy of the original list.
		*/
		public function clone():IList {
			return new List(this.toArray());
		}
		
		/**
			Returns a string that represents the items in the list.
			
			@return Returns a string that represents the items in the list.
		*/
		public function toString():String {
			return this._collection.toString();
		}
	}
}