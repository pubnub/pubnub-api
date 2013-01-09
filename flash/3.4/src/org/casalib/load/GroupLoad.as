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
package org.casalib.load {
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import org.casalib.errors.ArguementTypeError;
	import org.casalib.events.LoadEvent;
	import org.casalib.events.ProcessEvent;
	import org.casalib.load.LoadItem;
	import org.casalib.math.Percent;
	import org.casalib.process.Process;
	import org.casalib.process.ProcessGroup;
	import org.casalib.util.ArrayUtil;
	import flash.events.NetStatusEvent;
	
	
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="netStatus", type="flash.events.NetStatusEvent")]
	[Event(name="complete", type="org.casalib.events.LoadEvent")]
	[Event(name="progress", type="org.casalib.events.LoadEvent")]
	
	/**
		Allows multiple loads to be grouped and treated as one larger load.
		
		@author Aaron Clinger
		@version 06/21/11
		@example
			<code>
				package {
					import flash.events.IOErrorEvent;
					import org.casalib.display.CasaMovieClip;
					import org.casalib.events.LoadEvent;
					import org.casalib.load.GroupLoad;
					import org.casalib.load.ImageLoad;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _groupLoad:GroupLoad;
						protected var _imageOne:ImageLoad;
						protected var _imageTwo:ImageLoad;
						protected var _imageThree:ImageLoad;
						protected var _imageFour:ImageLoad;
						
						
						public function MyExample() {
							super();
							
							this._imageOne   = new ImageLoad("test1.jpg");
							this._imageTwo   = new ImageLoad("test2.jpg");
							this._imageThree = new ImageLoad("test3.jpg");
							this._imageFour  = new ImageLoad("test4.jpg");
							
							this._imageTwo.loader.x   = 10;
							this._imageThree.loader.x = 20;
							this._imageFour.loader.x  = 30;
							
							this.addChild(this._imageOne.loader);
							this.addChild(this._imageTwo.loader);
							this.addChild(this._imageThree.loader);
							this.addChild(this._imageFour.loader);
							
							this._groupLoad = new GroupLoad();
							this._groupLoad.addLoad(this._imageOne);
							this._groupLoad.addLoad(this._imageTwo);
							this._groupLoad.addLoad(this._imageThree);
							this._groupLoad.addLoad(this._imageFour);
							this._groupLoad.addEventListener(IOErrorEvent.IO_ERROR, this._onError);
							this._groupLoad.addEventListener(LoadEvent.PROGRESS, this._onProgress);
							this._groupLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._groupLoad.start();
						}
						
						protected function _onError(e:IOErrorEvent):void {
							trace("There was an error");
							this._groupLoad.removeLoad(this._groupLoad.erroredLoads[0]);
						}
						
						protected function _onProgress(e:LoadEvent):void {
							trace("Group is " + e.progress.percentage + "% loaded at " + e.Bps + "Bps.");
						}
						
						protected function _onComplete(e:LoadEvent):void {
							trace("Group has loaded.");
						}
					}
				}
			</code>
	*/
	public class GroupLoad extends ProcessGroup {
		protected static var _instanceMap:Dictionary;
		protected var _Bps:int;
		protected var _id:String;
		protected var _percentMap:Dictionary;
		protected var _preventCache:Boolean;
		protected var _preventCacheSet:Boolean;
		protected var _progress:Percent;
		
		
		/**
			Returns an instance of GroupLoad.
			
			@param id: The unique identifier for the GroupLoad instance.
			@return A previously created instance of GroupLoad or <code>null</code> if no instance with that identifier exists.
		*/
		public static function getGroupLoadById(id:String):GroupLoad {
			if (GroupLoad._instanceMap == null)
				return null;
			
			return GroupLoad._instanceMap[id];
		}
		
		/**
			Returns the instance of GroupLoad which contains a specific file.
			
			@param request: A <code>String</code> or an <code>URLRequest</code> reference to the file.
			@return The instance of GroupLoad which contains a specific file.
			@throws ArguementTypeError if you pass a type other than a <code>String</code> or an <code>URLRequest</code> to parameter <code>request</code>.
		*/
		public static function getGroupLoadByAsset(request:*):GroupLoad {
			if (GroupLoad._instanceMap != null)
				for each (var group:GroupLoad in GroupLoad._instanceMap)
					if (group.hasAsset(request, false))
						return group;
			
			return null;
		}
		
		
		/**
			Creates a new GroupLoad.
			
			@param id: The optional unique identifier for the instance of GroupLoad.
			@throws <code>Error</code> if the identifier provided is <code>null</code> or not unique.
		*/
		public function GroupLoad(id:String = null) {
			super();
			
			if (id != null && GroupLoad.getGroupLoadById(id) != null)
				throw new Error('The identifier provided is not unique.');
			
			this._id         = id;
			this._percentMap = new Dictionary();
			this._progress   = new Percent();
			
			GroupLoad._instanceMap           ||= new Dictionary();
			GroupLoad._instanceMap[id || this] = this;
		}
		
		/**
			Add a load to the group.
			
			@param load: Load to be added to the group. Can be any class that extends from {@link LoadItem} or another <code>GroupLoad</code> instance.
			@param percentOfGroup: Defines the percentage of the total group the size of the load item represents; defaults to equal increments.
			@throws ArguementTypeError if you pass a type other than a <code>LoadItem</code> or a <code>GroupLoad</code> to parameter <code>load</code>.
			@throws <code>Error</code> if you try to add the same <code>GroupLoad</code> to itself.
		*/
		public function addLoad(load:*, percentOfGroup:Percent = null):void {
			if (!(load is LoadItem) && !(load is GroupLoad))
				throw new ArguementTypeError('load');
			
			if (load == this)
				throw new Error('You cannot add the same GroupLoad to itself.');
			
			super.addProcess(load);
			
			if (this._preventCacheSet)
				load.preventCache = this.preventCache;
			
			this._percentMap[load] = (percentOfGroup == null || percentOfGroup.decimalPercentage == 0) ? new Percent(0.01) : percentOfGroup.clone();
			
			if (this.autoStart && !this.completed && this.running)
				this._checkTotalPercentValidity();
		}
		
		/**
			Removes a load item from the group.
			
			@param load: Load to be removed from the group. Can be any class that extends from {@link LoadItem} or another <code>GroupLoad</code> instance.
			@throws ArguementTypeError if you pass a type other than a <code>LoadItem</code> or a <code>GroupLoad</code> to parameter <code>load</code>.
		*/
		public function removeLoad(load:*):void {
			if (!(load is LoadItem) && !(load is GroupLoad))
				throw new ArguementTypeError('load');
			
			this._percentMap[load] = null;
			delete this._percentMap[load];
			
			super.removeProcess(load);
			
			if (this.running)
				this._checkTotalPercentValidity();
		}
		
		/**
			Determines if this GroupLoad contains a specific load item.
			
			@param load: The load item to search for. Can be any class that extends from {@link LoadItem} or another <code>GroupLoad</code> instance.
			@param recursive: If any child of this GroupLoad is also a GroupLoad search its children <code>true</code>, or only search this GroupLoad's children <code>false</code>.
			@return Returns <code>true</code> if the GroupLoad contains the load item; otherwise <code>false</code>.
			@throws ArguementTypeError if you pass a type other than a <code>LoadItem</code> or a <code>GroupLoad</code> to parameter <code>load</code>.
		*/
		public function hasLoad(load:*, recursive:Boolean = true):Boolean {
			if (!(load is LoadItem) && !(load is GroupLoad))
				throw new ArguementTypeError('load');
			
			return this.hasProcess(load, recursive);
		}
		
		/**
			Gets a load item from this GroupLoad, or a child GroupLoad, by its request.
			
			@param request: A <code>String</code> or an <code>URLRequest</code> reference to the file.
			@return The requested LoadItem instance.
			@throws ArguementTypeError if you pass a type other than a <code>String</code> or an <code>URLRequest</code> to parameter <code>request</code>.
		*/
		public function getLoad(request:*):LoadItem {
			const url:String  = this._getFileUrl(request);
			const items:Array = this.loads;
			var l:uint        = items.length;
			var i:*;
			
			while (l--) {
				i = items[l];
				
				if (i is GroupLoad) {
					i = i.getLoad(request);
					
					if (i != null)
						return i;
				} else
					if (i.url == url)
						return i;
			}
			
			return null;
		}
		
		/**
			Determines if this instance of GroupLoad contains a specific file.
			
			@param request: A <code>String</code> or an <code>URLRequest</code> reference to the file.
			@param recursive: If any child of this GroupLoad is also a GroupLoad search its children <code>true</code>, or only search this GroupLoad's children <code>false</code>.
			@return Returns <code>true</code> if this instance contains the file; otherwise <code>false</code>.
			@throws ArguementTypeError if you pass a type other than a <code>String</code> or an <code>URLRequest</code> to parameter <code>request</code>.
		*/
		public function hasAsset(request:*, recursive:Boolean = true):Boolean {
			const url:String = this._getFileUrl(request);
			
			if (!recursive)
				return ArrayUtil.getItemByKey(this.loads, 'url', url) != null;
			
			const items:Array = this.loads;
			var l:uint        = items.length;
			var i:*;
			
			while (l--) {
				i = items[l];
				
				if (i is GroupLoad) {
					if (i.hasAsset(request, true))
						return true;
				} else {
					if (i.url == url)
						return true;
				}
			}
			
			return false;
		}
		
		/**
			The identifier name for this instance of GroupLoad, if specified.
		*/
		public function get id():String {
			return this._id;
		}
		
		/**
			The loads that compose the group.
		*/
		public function get loads():Array {
			return this.processes;
		}
		
		/**
			The loads that are neither complete nor loading.
		*/
		public function get queuedLoads():Array {
			return this.queuedProcesses;
		}
		
		/**
			The loads that are currently loading.
		*/
		public function get loadingLoads():Array {
			return this.runningProcesses;
		}
		
		/**
			The loads that have not completed.
		*/
		public function get incompletedLoads():Array {
			return this.incompletedProcesses;
		}
		
		/**
			The loads that could not complete because of an error.
		*/
		public function get erroredLoads():Array {
			return ArrayUtil.getItemsByKey(this.processes, 'errored', true);
		}
		
		/**
			The loads that are either currently loading or that have completed.
		*/
		public function get loadingAndCompletedLoads():Array {
			return this.loadingLoads.concat(this.completedLoads);
		}
		
		/**
			The loads that have completed.
		*/
		public function get completedLoads():Array {
			return this.completedProcesses;
		}
		
		/**
			Specifies if a random value name/value pair should be appended to every load in GroupLoad <code>true</code>, or not append <code>false</code>; defaults to <code>false</code>.
			
			@see LoadItem#preventCache
		*/
		public function get preventCache():Boolean {
			return this._preventCache;
		}
		
		public function set preventCache(cache:Boolean):void {
			this._preventCacheSet = true;
			this._preventCache    = cache;
			
			const items:Array = this.loads;
			var l:uint        = items.length;
			
			while (l--)
				items[l].preventCache = this.preventCache;
		}
		
		/**
			The percent that the group is loaded.
		*/
		public function get progress():Percent {
			return this._progress.clone();
		}
		
		/**
			Determines if the group is loading <code>true</code>, or if it isn't currently loading <code>false</code>.
		*/
		public function get loading():Boolean {
			return this.running;
		}
		
		/**
			Determines if all loads in the group are loaded <code>true</code>, or if the group hasn't finished loading <code>false</code>.
		*/
		public function get loaded():Boolean {
			return this.completed;
		}
		
		/**
			Determines if the GroupLoad could not complete because of an error <code>true</code>, or hasn't encountered an error <code>false</code>.
		*/
		public function get errored():Boolean {
			return this.erroredLoads.length > 0;
		}
		
		/**
			The current download speed of the group in bytes per second.
		*/
		public function get Bps():int {
			return this._Bps;
		}
		
		/**	
			The number of bytes loaded.
		*/
		public function get bytesLoaded():Number {
			return ArrayUtil.sum(ArrayUtil.getValuesByKey(this.loadingAndCompletedLoads, 'bytesLoaded'));
		}
		
		/**
			The total number of bytes that will be loaded if the loading process succeeds.
			
			@usageNote Will return <code>Infinity</code> until all loads in group have started loading.
		*/
		public function get bytesTotal():Number {
			const total:uint = this.loads.length;
			const l:Array    = this.loadingAndCompletedLoads;
			
			if (total == l.length && total != 0)
				return ArrayUtil.sum(ArrayUtil.getValuesByKey(l, 'bytesTotal'));
			
			return Number.POSITIVE_INFINITY;
		}
		
		/**
			@exclude
		*/
		override public function start():void {
			this._checkTotalPercentValidity();
			
			super.start();
		}
		
		/**
			@exclude
		*/
		override public function addProcess(process:Process):void {
			this.addLoad(process);
		}
		
		/**
			@exclude
		*/
		override public function removeProcess(process:Process):void {
			if (process is LoadItem || process is GroupLoad)
				this.removeLoad(process);
		}
		
		/**
			@exclude
		*/
		override public function destroyProcesses(recursive:Boolean = true):void {
			this._percentMap = new Dictionary();
			
			super.destroyProcesses(recursive);
		}
		
		/**
			Calls <code>destroy</code> on all loads in the group and removes them from the GroupLoad.
			
			@param recursive: If any child of this GroupLoad is also a GroupLoad destroy its children <code>true</code>, or only destroy this GroupLoad's children <code>false</code>.
		*/
		public function destroyLoads(recursive:Boolean = true):void {
			this.destroyProcesses(recursive);
		}
		
		override public function destroy():void {
			this._percentMap = null;
			this._progress   = null;
			this._Bps        = -1;
			
			GroupLoad._instanceMap[this.id || this] = null;
			delete GroupLoad._instanceMap[this.id || this];
			
			super.destroy();
		}
		
		protected function _checkTotalPercentValidity():void {
			var perTotal:Number = 0;
			
			for (var i:Object in this._percentMap)
				perTotal += this._percentMap[i].decimalPercentage;
			
			if (perTotal != 1)
				for (i in this._percentMap)
					this._percentMap[i].decimalPercentage = this._percentMap[i].decimalPercentage / perTotal;
		}
		
		override protected function _addProcessListeners(process:Process):void {
			process.addEventListener(LoadEvent.PROGRESS, this._onProgress, false, 0, true);
			process.addEventListener(ProcessEvent.STOP, this._onProcessStopped, false, 0, true);
			process.addEventListener(IOErrorEvent.IO_ERROR, this._onLoadError, false, 0, true);
			process.addEventListener(NetStatusEvent.NET_STATUS, this._onNetStatus, false, 0, true);
			process.addEventListener(LoadEvent.COMPLETE, this._onLoadCompleted, false, 0, true);
		}
		
		override protected function _removeProcessListeners(process:Process):void {
			process.removeEventListener(LoadEvent.PROGRESS, this._onProgress);
			process.removeEventListener(ProcessEvent.STOP, this._onProcessStopped);
			process.removeEventListener(IOErrorEvent.IO_ERROR, this._onLoadError);
			process.removeEventListener(NetStatusEvent.NET_STATUS, this._onNetStatus);
			process.removeEventListener(LoadEvent.COMPLETE, this._onLoadCompleted);
		}
		
		/**
			@sends LoadEvent#PROGRESS - Dispatched as the loads in the group are downloading.
		*/
		protected function _onProgress(e:LoadEvent):void {
			var speed:Array     = new Array();
			var perTotal:Number = 0;
			var p:Array         = this.processes;
			var l:uint          = p.length;
			var load:*;
			
			while (l--) {
				load = p[l];
				
				if (load.loading) {
					speed.push(load.Bps);
					perTotal += this._percentMap[load].decimalPercentage * load.progress.decimalPercentage;
				} else if (load.loaded) {
					speed.push(load.Bps);
					perTotal += this._percentMap[load].decimalPercentage;
				}
			}
			
			const Bps:int = int(ArrayUtil.average(speed));
			
			if (this._Bps != Bps || this._progress.decimalPercentage != perTotal) {
				this._Bps                        = Bps;
				this._progress.decimalPercentage = perTotal;
				
				this.dispatchEvent(this._createDefinedLoadEvent(LoadEvent.PROGRESS));
			}
		}
		
		/**
			@sends IOErrorEvent#IO_ERROR - Dispatched if a requested load cannot be loaded and the download terminates.
		*/
		protected function _onLoadError(e:IOErrorEvent):void {
			this.dispatchEvent(e);
			
			this._checkThreads();
		}
		
		/**
			@sends NetStatusEvent#NET_STATUS - Dispatched if a requested load cannot be loaded and the download terminates.
		*/
		protected function _onNetStatus(e:NetStatusEvent):void {
			if (e.info.level == 'error' && !this.loaded) {
				this.dispatchEvent(e);
				
				this._checkThreads();
			}
		}
		
		protected function _onLoadCompleted(e:LoadEvent):void {
			this._checkThreads();
		}
		
		/**
			@sends LoadEvent#COMPLETE - When GroupLoad has completed loading all the loads in the group.
		*/
		override protected function _complete():void {
			if (this.erroredLoads.length > 0)
				return;
			
			super._complete();
			
			if (this._progress.decimalPercentage != 1) {
				this._progress.decimalPercentage = 1;
				this.dispatchEvent(this._createDefinedLoadEvent(LoadEvent.PROGRESS));
			}
			
			this.dispatchEvent(this._createDefinedLoadEvent(LoadEvent.COMPLETE));
		}
		
		protected function _getFileUrl(request:*):String {
			var url:String;
			
			if (request is String)
				url = request;
			else if (request is URLRequest)
				url = request.url;
			else
				throw new ArguementTypeError('request');
			
			return url;
		}
		
		protected function _createDefinedLoadEvent(type:String):LoadEvent {
			const loadEvent:LoadEvent = new LoadEvent(type);
			loadEvent.bytesLoaded     = this.bytesLoaded;
			loadEvent.bytesTotal      = this.bytesTotal;
			loadEvent.progress        = this.progress;
			loadEvent.Bps             = this.Bps;
			
			return loadEvent;
		}
	}
}