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
package org.casalib.time {	
	import flash.display.Shape;
	import flash.events.Event;
	import org.casalib.events.RemovableEventDispatcher;
	
	[Event(name="enterFrame", type="flash.events.Event")]
	
	/**
		Creates a centralized <code>enterFrame</code> event. Also enables classes that do not extend a display object to react to an <code>enterFrame</code> event.
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 09/06/09
		@example
			<code>
				package {
					import flash.events.Event;
					import org.casalib.display.CasaMovieClip;
					import org.casalib.time.EnterFrame;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _pulseInstance:EnterFrame;
						
						
						public function MyExample() {
							super();
							
							this._pulseInstance = EnterFrame.getInstance();
							this._pulseInstance.addEventListener(Event.ENTER_FRAME, this._onFrameFire);
						}
						
						protected function _onFrameFire(e:Event):void {
							trace("I will be called every frame.");
						}
					}
				}
			</code>
	*/
	public class EnterFrame extends RemovableEventDispatcher {
		protected static var _instance:EnterFrame;
		protected static var _pulseShape:Shape;
		
		/**
			@return {@link EnterFrame} instance.
		*/
		public static function getInstance():EnterFrame {
			if (EnterFrame._instance == null)
				EnterFrame._instance = new EnterFrame(new SingletonEnforcer());
			
			return EnterFrame._instance;
		}
		
		/**
			@exclude
		*/
		public function EnterFrame(singletonEnforcer:SingletonEnforcer) {
			super();
			this._createBeacon();
		}
		
		/**
			@throws <code>Error</code> if called. Cannot destroy a singleton.
		*/
		override public function destroy():void {
			throw new Error('Cannot destroy a singleton.');
		}
		
		protected function _createBeacon():void {
			EnterFrame._pulseShape = new Shape();
			EnterFrame._pulseShape.addEventListener(Event.ENTER_FRAME, this._handlePulseEnterFrame);
		}
		
		/**
			@sends Event#ENTER_FRAME - Dispatched when a new frame is entered.
		*/
		protected function _handlePulseEnterFrame(e:Event):void {
			this.dispatchEvent(new Event(Event.ENTER_FRAME));
		}
	}
}

class SingletonEnforcer {}