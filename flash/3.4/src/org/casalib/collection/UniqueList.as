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
	import org.casalib.collection.List;
	import org.casalib.util.ArrayUtil;
	
	/**
		An ordered or sequence collection that contains no duplicates. Similar to Java's Set but contains all the methods of List.
		
		@author Aaron Clinger
		@version 04/27/08
		@see List
	*/
	public class UniqueList extends List {
		
		
		/**
			Creates a new UniqueList;
			
			@param collection: An Array of items to populate the contents of this list; UniqueList will only accept the unique elements of the Array.
		*/
		public function UniqueList(collection:Array = null) {
			super((collection == null) ? null : ArrayUtil.removeDuplicates(collection));
		}
		
		/**
			{@inheritDoc}
			
			@param item: {@inheritDoc}
			@return Returns <code>true</code> if the element was unique and added; otherwise <code>false</code>.
		*/
		override public function addItem(item:*):Boolean {
			if (this.contains(item))
				return false;
			
			this._collection.push(item);
			
			return true;
		}
		
		/**
			{@inheritDoc}
			
			@param item: {@inheritDoc}
			@param index: {@inheritDoc}
			@return Returns <code>true</code> if the element was unique and added; otherwise <code>false</code>.
		*/
		override public function addItemAt(item:*, index:int):Boolean {
			if (this.contains(item))
				return false;
			
			this._collection.splice(index, 0, item);
			
			return true;
		}
		
		/**
			Modifies original list by adding all the elements from another list that aren't already present.
			
			@param items: {@inheritDoc}
			@return Returns <code>true</code> if any elements of the specified list were unique and added; otherwise <code>false</code>.
		*/
		override public function addItems(items:IList):Boolean {
			var uniqueItems:Array = items.toArray();
			
			ArrayUtil.removeItems(uniqueItems, this.toArray());
			
			if (uniqueItems.length == 0)
				return false;
			
			this._collection = this._collection.concat(uniqueItems);
			
			return true;
		}
		
		/**
			Modifies original list by adding all the elements from another list, that aren't already present, at a specified position.
			
			@param items: {@inheritDoc}
			@param index: {@inheritDoc}
			@return Returns <code>true</code> if any elements of the specified list were unique and added; otherwise <code>false</code>.
		*/
		override public function addItemsAt(items:IList, index:int = 0x7fffffff):Boolean {
			var uniqueItems:Array = items.toArray();
			
			ArrayUtil.removeItems(uniqueItems, this.toArray());
			
			if (uniqueItems.length == 0)
				return false;
			
			return ArrayUtil.addItemsAt(this._collection, uniqueItems, index);
		}
		
		/**
			{@inheritDoc}
			
			@param item: {@inheritDoc}
			@param index: {@inheritDoc}
			@return {@inheritDoc}
			@throws <code>Error</code> if you try to set an item that is already contained in the list.
		*/
		override public function setItem(item:*, index:int):* {
			if (this.contains(item))
				throw new Error('List already contains specified item (' + item + ').');
			
			return this._collection.splice(index, 1, item)[0];
		}
		
		/**
			{@inheritDoc}
			
			@param startIndex: {@inheritDoc}
			@param endIndex: {@inheritDoc}
			@return {@inheritDoc}
		*/
		override public function subList(startIndex:int = 0, endIndex:int = 16777215):IList {
			return new UniqueList(this._collection.slice(startIndex, endIndex));
		}
		
		/**
			{@inheritDoc}
			
			@return {@inheritDoc}
		*/
		override public function clone():IList {
			return new UniqueList(this.toArray());
		}
	}
}