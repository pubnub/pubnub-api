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
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import org.casalib.errors.ArguementTypeError;
	import org.casalib.events.LoadEvent;
	import org.casalib.events.RetryEvent;
	import org.casalib.math.Percent;
	import org.casalib.process.Process;
	import org.casalib.util.LoadUtil;
	import org.casalib.util.StringUtil;
	
	
	[Event(name="complete", type="org.casalib.events.LoadEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="open", type="flash.events.Event")]
	[Event(name="progress", type="org.casalib.events.LoadEvent")]
	[Event(name="retry", type="org.casalib.events.RetryEvent")]
	[Event(name="start", type="org.casalib.events.LoadEvent")]
	[Event(name="stop", type="org.casalib.events.LoadEvent")]
	
	/**
		Base class used by load classes. LoadItem is not designed to be used on its own and needs to be extended to function.
		
		@author Aaron Clinger
		@version 02/13/10
	*/
	public class LoadItem extends Process {
		protected var _attempts:uint;
		protected var _Bps:int;
		protected var _dispatcher:IEventDispatcher;
		protected var _errrored:Boolean;
		protected var _httpStatus:uint;
		protected var _latency:uint;
		protected var _loaded:Boolean;
		protected var _loadItem:*;
		protected var _preventCache:Boolean;
		protected var _progress:Percent;
		protected var _request:URLRequest;
		protected var _retries:uint;
		protected var _startTime:uint;
		protected var _time:uint;
		protected var _url:String;
		
		
		/**
			Defines the load object and file location.
			
			@param load: The load object.
			@param request: A <code>String</code> or an <code>URLRequest</code> reference to the file you wish to load.
			@throws ArguementTypeError if you pass a type other than a <code>String</code> or an <code>URLRequest</code> to parameter <code>request</code>.
			@throws <code>Error</code> if you try to load an empty <code>String</code> or <code>URLRequest</code>.
		*/
		public function LoadItem(load:*, request:*) {
			super();
			
			this._createRequest(request);
			
			this._loadItem = load;
			this._retries  = 2;
			this._Bps      = -1;
			this._progress = new Percent();
		}
		
		/**
			Begins the loading process.
			
			@sends LoadEvent#START - Dispatched when a load is started.
		*/
		override public function start():void {
			if (this.loading)
				return;
			
			super.start();
			
			this._loaded    = false;
			this._errrored  = false;
			this._startTime = getTimer();
			this._attempts  = 0;
			this._progress  = new Percent();
			this._Bps       = -1;
			this._time      = 0;
			
			if (this._preventCache) {
				const cache:String = 'casaCache=' + (new Date()).time;
				
				this._request.url = (this._request.url.indexOf('?') == -1) ? this._request.url + '?' + cache : this._request.url + '&' + cache;
			}
			
			this._load();
			
			this.dispatchEvent(this._createDefinedLoadEvent(LoadEvent.START));
		}
		
		/**
			Cancels the currently loading file from completing.
			
			@sends LoadEvent#STOP - Dispatched if the load is stopped during the loading process.
		*/
		override public function stop():void {
			if (!this.loading || this.loaded)
				return;
			
			if (this.bytesTotal == this.bytesLoaded && this.bytesLoaded > 0)
				return;
			
			super.stop();
			
			try {
				this._loadItem.close();
			} catch (error:IOError) {}
			
			this.dispatchEvent(this._createDefinedLoadEvent(LoadEvent.STOP));
		}
		
		/**
			Specifies if a random value name/value pair should be appended to the query string to help prevent caching <code>true</code>, or not append <code>false</code>; defaults to <code>false</code>.
		*/
		public function get preventCache():Boolean {
			return this._preventCache;
		}
		
		public function set preventCache(cache:Boolean):void {
			this._preventCache = cache;
		}
		
		/**
			The total number of bytes of the requested file.
		*/
		public function get bytesTotal():Number {
			return (this._loadItem.bytesTotal == 0 && this.bytesLoaded != 0) ? Number.POSITIVE_INFINITY : this._loadItem.bytesTotal;
		}
		
		/**
			The number of bytes loaded of the requested file.
		*/
		public function get bytesLoaded():uint {
			return this._loadItem.bytesLoaded;
		}
		
		/**
			The percent that the requested file has loaded.
		*/
		public function get progress():Percent {
			return this._progress.clone();
		}
		
		/**
			The number of additional times the file has attempted to load after {@link #start start} was called.
		*/
		public function get attempts():uint {
			return this._attempts;
		}
		
		/**
			The number of additional load retries the class should attempt before failing; defaults to <code>2</code> additional retries / <code>3</code> total load attempts.
		*/
		public function get retries():uint {
			return this._retries;
		}
		
		public function set retries(amount:uint):void {
			this._retries = amount;
		}
		
		/**
			The URLRequest reference to the requested file.
		*/
		public function get urlRequest():URLRequest {
			return this._request;
		}
		
		/**
			The URL of the requested file.
		*/
		public function get url():String {
			return this._url;
		}
		
		/**
			Determines if the requested file is loading <code>true</code>, or if it isn't currently loading <code>false</code>.
		*/
		public function get loading():Boolean {
			return this.running;
		}
		
		/**
			Determines if the requested file has loaded <code>true</code>, or hasn't finished loading <code>false</code>.
		*/
		public function get loaded():Boolean {
			return this._loaded;
		}
		
		/**
			Determines if the requested file could not complete because of an error <code>true</code>, or hasn't encountered an error <code>false</code>.
		*/
		public function get errored():Boolean {
			return this._errrored;
		}
		
		/**
			The current download speed of the requested file in bytes per second.
		*/
		public function get Bps():int {
			return this._Bps;
		}
		
		/**
			The current time duration in milliseconds the load has taken.
		*/
		public function get time():uint {
			return this._time;
		}
		
		/**
			The time in milliseconds that the server took to respond.
		*/
		public function get latency():uint {
			return this._latency;
		}
		
		/**
			The HTTP status code returned by the server; or <code>0 </code> if no status has/can been received or the load is a stream.
		*/
		public function get httpStatus():uint {
			return this._httpStatus;
		}
		
		override public function destroy():void {
			this._dispatcher.removeEventListener(Event.COMPLETE, this._onComplete);
			this._dispatcher.removeEventListener(Event.OPEN, this._onOpen);
			this._dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, this._onLoadError);
			this._dispatcher.removeEventListener(ProgressEvent.PROGRESS, this._onProgress);
			
			super.destroy();
		}
		
		protected function _initListeners(dispatcher:IEventDispatcher):void {
			this._dispatcher = dispatcher;
			
			this._dispatcher.addEventListener(Event.COMPLETE, this._onComplete, false, 0, true);
			this._dispatcher.addEventListener(Event.OPEN, this._onOpen, false, 0, true);
			this._dispatcher.addEventListener(IOErrorEvent.IO_ERROR, this._onLoadError, false, 0, true);
			this._dispatcher.addEventListener(ProgressEvent.PROGRESS, this._onProgress, false, 0, true);
		}
		
		protected function _load():void {
			this._loadItem.load(this._request);
		}
		
		protected function _createRequest(request:*):void {
			if (request is String) {
				request = StringUtil.trim(request);
				
				if (request == '')
					throw new Error('Cannot load an empty reference/String');
				
				request = new URLRequest(request);
			} else if (!(request is URLRequest))
				throw new ArguementTypeError('request');
			
			this._request = request;
			this._url     = this._request.url;
		}
		
		/**
			@sends RetryEvent#RETRY - Dispatched if the download attempt failed and the class is going to attempt to download the file again.
			@sends IOErrorEvent#IO_ERROR - Dispatched if requested file cannot be loaded and the download terminates.
		*/
		protected function _onLoadError(error:Event):void {
			if (++this._attempts <= this._retries) {
				var retry:RetryEvent = new RetryEvent(RetryEvent.RETRY);
				retry.attempts       = this._attempts;
				
				this.dispatchEvent(retry);
				
				this._load();
			} else {
				this._errrored = true;
				
				super._complete();
				
				this.dispatchEvent(error);
			}
		}
		
		/**
			@sends Event#OPEN - Dispatched when a load operation starts.
		*/
		protected function _onOpen(e:Event):void {
			this._latency = getTimer() - this._startTime;
			
			this.dispatchEvent(e);
		}
		
		protected function _onHttpStatus(e:HTTPStatusEvent):void {
			this._httpStatus = e.status;
			
			this.dispatchEvent(e);
		}
		
		protected function _onProgress(progress:ProgressEvent):void {
			this._calculateLoadProgress();
		}
		
		/**
			@sends LoadEvent#PROGRESS - Dispatched as data is received during the download process.
		*/
		protected function _calculateLoadProgress():void {
			var currentTime:int = getTimer();
			
			this._Bps  = LoadUtil.calculateBps(this.bytesLoaded, this._startTime, currentTime);
			this._time = currentTime - this._startTime;
			
			this._progress.decimalPercentage = Math.min(this.bytesLoaded / this.bytesTotal, 1);
			
			this.dispatchEvent(this._createDefinedLoadEvent(LoadEvent.PROGRESS));
		}
		
		/**
			@sends LoadEvent#COMPLETE - Dispatched when file has completely loaded.
		*/
		protected function _onComplete(complete:Event = null):void {
			this._complete();
			
			this.dispatchEvent(this._createDefinedLoadEvent(LoadEvent.COMPLETE));
		}
		
		protected function _createDefinedLoadEvent(type:String):LoadEvent {
			var loadEvent:LoadEvent = new LoadEvent(type);
			loadEvent.attempts      = this.attempts;
			loadEvent.Bps           = this.Bps;
			loadEvent.bytesLoaded   = this.bytesLoaded;
			loadEvent.bytesTotal    = this.bytesTotal;
			loadEvent.latency       = this.latency;
			loadEvent.progress      = this.progress;
			loadEvent.retries       = this.retries;
			loadEvent.time          = this.time;
			
			return loadEvent;
		}
		
		override protected function _complete():void {
			var currentTime:int              = getTimer();
			this._Bps                        = LoadUtil.calculateBps(this.bytesTotal, this._startTime, currentTime);
			this._time                       = currentTime - this._startTime;
			this._loaded                     = true;
			this._progress.decimalPercentage = 1;
			
			super._complete();
		}
	}
}