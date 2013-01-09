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
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import org.casalib.control.IRunnable;
	import org.casalib.events.InactivityEvent;
	import org.casalib.events.RemovableEventDispatcher;
	import org.casalib.time.Interval;
	import org.casalib.util.StageReference;
	import org.casalib.time.Stopwatch;
	
	
	[Event(name="activated", type="org.casalib.events.InactivityEvent")]
	[Event(name="inactive", type="org.casalib.events.InactivityEvent")]
	
	/**
		Detects user inactivity by checking for a void in mouse movement and key presses.
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 05/04/11
		@usageNote You must first initialize {@link StageReference} before using this class.
		@example
			<code>
				package {
					import org.casalib.display.CasaMovieClip;
					import org.casalib.events.InactivityEvent;
					import org.casalib.time.Inactivity;
					import org.casalib.util.StageReference;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _inactivity:Inactivity;
						
						
						public function MyExample() {
							super();
							
							StageReference.setStage(this.stage);
							
							this._inactivity = new Inactivity(3000);
							this._inactivity.addEventListener(InactivityEvent.INACTIVE, this.onUserInactive);
							this._inactivity.addEventListener(InactivityEvent.ACTIVATED, this.onUserActivated);
							this._inactivity.start();
						}
						
						public function onUserInactive(e:InactivityEvent):void {
							trace("User inactive for " + e.milliseconds + " milliseconds.");
						}
						
						public function onUserActivated(e:InactivityEvent):void {
							trace("User active after being inactive for " + e.milliseconds + " milliseconds.");
						}
					}
				}
			</code>
	*/
	public class Inactivity extends RemovableEventDispatcher implements IRunnable {
		protected var _interval:Interval;
		protected var _stopwatch:Stopwatch;
		
		
		/**
			Creates an Inactivity.
			
			@param milliseconds: The time until a user is considered inactive.
			@usageNote You must first initialize {@link StageReference} before using this class.
		*/
		public function Inactivity(milliseconds:uint) {
			super();
			
			this._interval  = Interval.setTimeout(this._userInactive, milliseconds);
			this._stopwatch = new Stopwatch();
		}
		
		/**
			Starts detecting inactivity.
		*/
		public function start():void {
			if (this._interval.running)
				return;
			
			StageReference.getStage().addEventListener(Event.RESIZE, this._userInput, false, 0, true);
			StageReference.getStage().addEventListener(KeyboardEvent.KEY_DOWN, this._userInput, false, 0, true);
			StageReference.getStage().addEventListener(KeyboardEvent.KEY_UP, this._userInput, false, 0, true);
			StageReference.getStage().addEventListener(MouseEvent.MOUSE_DOWN, this._userInput, false, 0, true);
			StageReference.getStage().addEventListener(MouseEvent.MOUSE_MOVE, this._userInput, false, 0, true);
			StageReference.getStage().addEventListener(MouseEvent.MOUSE_WHEEL, this._userInput, false, 0, true);
			StageReference.getStage().addEventListener(MouseEvent.MOUSE_DOWN, this._userInput, false, 0, true);
			StageReference.getStage().addEventListener(MouseEvent.MOUSE_UP, this._userInput, false, 0, true);
			
			this._stopwatch.start();
			this._interval.start();
		}
		
		/**
			Stops detecting inactivity.
		*/
		public function stop():void {
			this._interval.reset();
			
			StageReference.getStage().removeEventListener(Event.RESIZE, this._userInput);
			StageReference.getStage().removeEventListener(KeyboardEvent.KEY_DOWN, this._userInput);
			StageReference.getStage().removeEventListener(KeyboardEvent.KEY_UP, this._userInput);
			StageReference.getStage().removeEventListener(MouseEvent.MOUSE_DOWN, this._userInput);
			StageReference.getStage().removeEventListener(MouseEvent.MOUSE_MOVE, this._userInput);
			StageReference.getStage().removeEventListener(MouseEvent.MOUSE_WHEEL, this._userInput);
			StageReference.getStage().removeEventListener(MouseEvent.MOUSE_DOWN, this._userInput);
			StageReference.getStage().removeEventListener(MouseEvent.MOUSE_UP, this._userInput);
		}
		
		override public function destroy():void {
			this.stop();
			
			this._interval.destroy();
			
			super.destroy();
		}
		
		/**
			@sends InactivityEvent#INACTIVE - Dispatched when the user is inactive.
		*/
		protected function _userInactive():void {
			this._interval.stop();
			
			var event:InactivityEvent = new InactivityEvent(InactivityEvent.INACTIVE);
			event.milliseconds        = this._interval.delay;
			
			this.dispatchEvent(event);
			
			this._stopwatch.start();
		}
		
		/**
			@sends InactivityEvent#ACTIVATED - Dispatched when the user becomes active after a period of inactivity.
		*/
		protected function _userInput(e:*):void {
			if (!this._interval.running) {
				var event:InactivityEvent = new InactivityEvent(InactivityEvent.ACTIVATED);
				event.milliseconds        = this._stopwatch.time + this._interval.delay;
				
				this.dispatchEvent(event);
				
				this._stopwatch.stop();
			}
			
			this._interval.reset();
			this._interval.start();
		}
	}
}