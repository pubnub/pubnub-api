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
	import org.casalib.load.SwfLoad;
	import flash.utils.Dictionary;
	import org.casalib.util.ClassUtil;
	
	
	/**
		Creates an easy way to store multiple {@link SwfLoad libraries} in groups and perform centralized retrieval of assets.
		
		@author Aaron Clinger
		@version 12/04/09
		@example
			<code>
				package {
					import flash.display.DisplayObject;
					import org.casalib.display.CasaMovieClip;
					import org.casalib.events.LoadEvent;
					import org.casalib.load.GroupLoad;
					import org.casalib.load.SwfLoad;
					import org.casalib.util.LibraryManager;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _redLibLoad:SwfLoad;
						protected var _greenLibLoad:SwfLoad;
						protected var _groupLoad:GroupLoad;
						
						
						public function MyExample() {
							super();
							
							this._redLibLoad   = new SwfLoad("redExternalLib.swf");
							this._greenLibLoad = new SwfLoad("greenExternalLib.swf");
							
							LibraryManager.addSwfLoad(this._redLibLoad);
							LibraryManager.addSwfLoad(this._greenLibLoad);
							
							this._groupLoad = new GroupLoad();
							this._groupLoad.addLoad(this._redLibLoad);
							this._groupLoad.addLoad(this._greenLibLoad);
							this._groupLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._groupLoad.start();
						}
						
						protected function _onComplete(e:LoadEvent):void {
							var red:DisplayObject   = LibraryManager.createClassByName("RedBox");
							var green:DisplayObject = LibraryManager.createClassByName("GreenBox");
							
							green.x = 100;
							
							this.addChild(red);
							this.addChild(green);
						}
					}
				}
			</code>
	*/
	public class LibraryManager {
		public static const GROUP_DEFAULT:String = 'groupDefault';
		protected static var _groupMap:Dictionary;
		
		
		/**
			Adds a SwfLoad to LibraryManager.
			
			@param swfLoad: The SwfLoad you wish to add.
			@param groupId: The identifier of the group you wish to add the SwfLoad to.
		*/
		public static function addSwfLoad(swfLoad:SwfLoad, groupId:String = LibraryManager.GROUP_DEFAULT):void {
			LibraryManager._getGroup(groupId)[swfLoad] = swfLoad;
		}
		
		/**
			Removes a SwfLoad from LibraryManager.
			
			@param swfLoad: The SwfLoad you wish to remove.
			@param groupId: The identifier of the group you wish to remove the SwfLoad from.
		*/
		public static function removeSwfLoad(swfLoad:SwfLoad, groupId:String = LibraryManager.GROUP_DEFAULT):void {
			if (LibraryManager._hasGroup(groupId))
				if (swfLoad in LibraryManager._groupMap[groupId])
					delete LibraryManager._groupMap[groupId][swfLoad];
		}
		
		/**
			Determines if a LibraryManager group contains a specific SwfLoad.
			
			@param swfLoad: The SwfLoad you wish to search for.
			@param groupId: The identifier of the group you wish to search for the SwfLoad in.
			@return Returns <code>true</code> if the specified SwfLoad is contained in the LibraryManager group; otherwise <code>false</code>.
		*/
		public static function hasSwfLoad(swfLoad:SwfLoad, groupId:String = LibraryManager.GROUP_DEFAULT):Boolean {
			if (LibraryManager._hasGroup(groupId)) {
				var lib:Dictionary = LibraryManager._getGroup(groupId);
				
				for each (var s:SwfLoad in lib)
					if (s == swfLoad)
						return true;
			}
			
			return false;
		}
		
		/**
			Removes all SwfLoads from a group.
			
			@param groupId: The identifier of the group you wish to empty.
		*/
		public static function removeGroup(groupId:String):void {
			LibraryManager._initGroup();
			
			if (groupId in LibraryManager._groupMap)
				delete LibraryManager._groupMap[groupId];
		}
		
		/**
			Determines which LibraryManager group contains a specific SwfLoad.
			
			@param swfLoad: The SwfLoad to determine which group it belongs to.
			@return The id for the containing group or <code>null</code> if the SwfLoad is not part of a group.
			@usageNote A SwfLoad could belong to more than one group.
		*/
		public static function getGroupIdBySwfLoad(swfLoad:SwfLoad):String {
			var group:Dictionary;
			for (var id:String in LibraryManager._groupMap) {
				group = LibraryManager._groupMap[id];
				
				for each (var l:SwfLoad in group)
					if (l == swfLoad)
						return id;
			}
			
			return null;
		}
		
		/**
			Determines which LibraryManager group contains a specific definition.
			
			@param name: The name of the definition to determine which group it belongs to.
			@return The id for the containing group or <code>null</code> if the definition is not part of a group.
			@usageNote A definition could belong to more than one group.
		*/
		public static function getGroupIdByDefinition(name:String):String {
			for (var id:String in LibraryManager._groupMap)
				if (LibraryManager.hasDefinition(name, id))
					return id;
			
			return null;
		}
		
		/**
			Gets a public definition from a library group.
			
			@param name: The name of the definition.
			@param groupId: The identifier of the group you wish to retrieve the definition from.
			@return The object associated with the definition or <code>null</code> if the <code>name</code> doesn't exist.
		*/
		public static function getDefinition(name:String, groupId:String = LibraryManager.GROUP_DEFAULT):Object {
			if (LibraryManager._hasGroup(groupId)) {
				var lib:Dictionary = LibraryManager._getGroup(groupId);
				
				for each (var s:SwfLoad in lib)
					if (s.loaded)
						if (s.hasDefinition(name))
							return s.getDefinition(name);
			}
			
			return null;
		}
		
		/**
			Checks to see if a public definition exists within the library group.
			
			@param name: The name of the definition.
			@param groupId: The identifier of the group in which to search for the definition.
			@return Returns <code>true</code> if the specified definition exists; otherwise <code>false</code>.
		*/
		public static function hasDefinition(name:String, groupId:String = LibraryManager.GROUP_DEFAULT):Boolean {
			if (LibraryManager._hasGroup(groupId)) {
				var lib:Dictionary = LibraryManager._getGroup(groupId);
				
				for each (var s:SwfLoad in lib)
					if (s.loaded)
						if (s.hasDefinition(name))
							return true;
			}
			
			return false;
		}
		
		/**
			Retrieves a class from a library group.
			
			@param className: The full name of the class you wish to receive from the loaded SWF.
			@param groupId: The identifier of the group you wish to retrieve the class from.
			@return A Class reference or <code>null</code> if the <code>className</code> doesn't exist.
		*/
		public static function getClassByName(className:String, groupId:String = LibraryManager.GROUP_DEFAULT):Class {
			return LibraryManager.getDefinition(className, groupId) as Class;
		}
		
		/**
			Instatiates a class from a library group.
			
			@param className: The full name of the class you wish to instantiate from the loaded SWF.
			@param arguments: The optional parameters to be passed to the class constructor.
			@param groupId: The identifier of the group you wish to instantiate the class from.
			@return A reference to the newly instantiated class or <code>null</code> if the <code>className</code> doesn't exist.
		*/
		public static function createClassByName(className:String, arguments:Array = null, groupId:String = LibraryManager.GROUP_DEFAULT):* {
			var c:Class = LibraryManager.getClassByName(className, groupId);
			
			if (c == null)
				return null;
			
			arguments ||= new Array();
			arguments.unshift(c);
			
			return ClassUtil.construct.apply(null, arguments);
		}
		
		protected static function _initGroup():void {
			LibraryManager._groupMap ||= new Dictionary();
		}
		
		protected static function _hasGroup(groupId:String):Boolean {
			LibraryManager._initGroup();
			
			return groupId in LibraryManager._groupMap;
		}
		
		protected static function _getGroup(groupId:String):Dictionary {
			LibraryManager._initGroup();
			
			return LibraryManager._groupMap[groupId] ||= new Dictionary();
		}
	}
}