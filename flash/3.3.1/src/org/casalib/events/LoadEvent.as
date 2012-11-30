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
package org.casalib.events {
	import flash.events.Event;
	import org.casalib.math.Percent;
	
	/**
		An event dispatched during loading.
		
		@author Aaron Clinger
		@version 02/01/10
	*/
	public class LoadEvent extends Event {
		public static const COMPLETE:String = 'complete';
		public static const PROGRESS:String = 'progress';
		public static const START:String    = 'start';
		public static const STOP:String     = 'stop';
		protected var _progress:Percent;
		protected var _Bps:int;
		protected var _bytesLoaded:Number;
		protected var _bytesTotal:Number;
		protected var _time:uint;
		protected var _httpStatus:uint;
		protected var _attempts:uint;
		protected var _retries:uint;
		protected var _latency:uint;
		
		
		/**
			Creates a new LoadEvent.
			
			@param type: The type of event.
			@param bubbles: Determines whether the Event object participates in the bubbling stage of the event flow.
			@param cancelable: Determines whether the Event object can be canceled.
		*/
		public function LoadEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
		/**
			The percent that the requested file has loaded.
		*/
		public function get progress():Percent {
			return this._progress.clone();
		}
		
		public function set progress(per:Percent):void {
			this._progress = per.clone();
		}
		
		/**
			The number of additional times the file has attempted to load.
		*/
		public function get attempts():uint {
			return this._attempts;
		}
		
		public function set attempts(a:uint):void {
			this._attempts = a;
		}
		
		/**
			The number of additional load retries the class will attempt before failing.
		*/
		public function get retries():uint {
			return this._retries;
		}
		
		public function set retries(r:uint):void {
			this._retries = r;
		}
		
		/**
			The current download speed of the requested file in bytes per second.
		*/
		public function get Bps():int {
			return this._Bps;
		}
		
		public function set Bps(bytes:int):void {
			this._Bps = bytes;
		}
		
		/**
			The number of bytes loaded when the listener processed the event.
		*/
		public function get bytesLoaded():Number {
			return this._bytesLoaded;
		}
		
		public function set bytesLoaded(bytes:Number):void {
			this._bytesLoaded = bytes;
		}
		
		/**
			The total number of bytes that will be loaded if the loading process succeeds.
		*/
		public function get bytesTotal():Number {
			return this._bytesTotal;
		}
		
		public function set bytesTotal(bytes:Number):void {
			this._bytesTotal = bytes;
		}
		
		/**
			The current time duration in milliseconds the load has taken.
		*/
		public function get time():uint {
			return this._time;
		}
		
		public function set time(milliseconds:uint):void {
			this._time = milliseconds;
		}
		
		/**
			The time in milliseconds that the server took to respond.
		*/
		public function get latency():uint {
			return this._latency;
		}
		
		public function set latency(l:uint):void {
			this._latency = l;
		}
		
		/**
			The HTTP status code returned by the server; or <code>0 </code> if no status has/can been received or the load is a stream.
		*/
		public function get httpStatus():uint {
			return this._httpStatus;
		}
		
		public function set httpStatus(status:uint):void {
			this._httpStatus = status;
		}
		
		/**
			@return A string containing all the properties of the event.
		*/
		override public function toString():String {
			return this.formatToString('LoadEvent', 'type', 'bubbles', 'cancelable', 'attempts', 'Bps', 'bytesLoaded', 'bytesTotal', 'httpStatus', 'latency', 'progress', 'retries', 'time');
		}
		
		/**
			@return Duplicates an instance of the event.
		*/
		override public function clone():Event {
			var e:LoadEvent = new LoadEvent(this.type, this.bubbles, this.cancelable);
			e.attempts      = this.attempts;
			e.Bps           = this.Bps;
			e.bytesLoaded   = this.bytesLoaded;
			e.bytesTotal    = this.bytesTotal;
			e.httpStatus    = this.httpStatus;
			e.latency       = this.latency;
			e.progress      = this.progress;
			e.retries       = this.retries;
			e.time          = this.time;
			
			return e;
		}
	}
}