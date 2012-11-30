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
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import org.casalib.load.LoadItem;
	
	[Event(name="id3", type="flash.events.Event")]
	
	/**
		Provides an easy and standardized way to load audio files.
		
		@author Aaron Clinger
		@version 02/13/10
		@example
			<code>
				package {
					import org.casalib.display.CasaMovieClip;
					import org.casalib.events.LoadEvent;
					import org.casalib.load.AudioLoad;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _audioLoad:AudioLoad;
						
						
						public function MyExample() {
							super();
							
							this._audioLoad = new AudioLoad("test.mp3");
							this._audioLoad.addEventListener(LoadEvent.COMPLETE, this._onComplete);
							this._audioLoad.start();
						}
						
						protected function _onComplete(e:LoadEvent):void {
							this._audioLoad.sound.play();
						}
					}
				}
			</code>
	*/
	public class AudioLoad extends LoadItem {
		protected var _context:SoundLoaderContext;
		protected var _isFirstLoad:Boolean;
		
		
		/**
			Creates and defines an AudioLoad.
			
			@param request: A <code>String</code> or an <code>URLRequest</code> reference to the file you wish to load.
			@param context: An optional SoundLoaderContext object.
			@throws ArguementTypeError if you pass a type other than a <code>String</code> or an <code>URLRequest</code> to parameter <code>request</code>.
			@throws <code>Error</code> if you try to load an empty <code>String</code> or <code>URLRequest</code>.
		*/
		public function AudioLoad(request:*, context:SoundLoaderContext = null) {
			super(new Sound(), request);
			
			this._context     = context;
			this._isFirstLoad = true;
			
			this._initListeners(this._loadItem);
		}
		
		/**
			The Sound object.
		*/
		public function get sound():Sound {
			return this._loadItem as Sound;
		}
		
		override public function destroy():void {
			this._dispatcher.removeEventListener(Event.ID3, this.dispatchEvent);
			
			super.destroy();
		}
		
		override protected function _load():void {
			if (!this._isFirstLoad) {
				this._dispatcher.removeEventListener(Event.COMPLETE, this._onComplete);
				this._dispatcher.removeEventListener(Event.OPEN, this._onOpen);
				this._dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, this._onLoadError);
				this._dispatcher.removeEventListener(ProgressEvent.PROGRESS, this._onProgress);
				this._dispatcher.removeEventListener(Event.ID3, this.dispatchEvent);
				
				this._loadItem = new Sound();
				this._initListeners(this._loadItem);
			}
			
			this._isFirstLoad = false;
			
			this._loadItem.load(this._request, this._context);
		}
		
		/**
			@sends Event#ID3 - Dispatched when ID3 data is available.
		*/
		override protected function _initListeners(dispatcher:IEventDispatcher):void {
			super._initListeners(dispatcher);
			
			this._dispatcher.addEventListener(Event.ID3, this.dispatchEvent, false, 0, true);
		}
	}
}