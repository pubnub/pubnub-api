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
package org.casalib.display {
	import flash.events.Event;
	import org.casalib.display.CasaMovieClip;
	import org.casalib.time.EnterFrame;
	
	
	/**
		Provides additional timeline controlling functions: {@link #reverse} and {@link #gotoAndReverse}.
		
		@author Aaron Clinger
		@version 05/30/09
	*/
	public class ReversibleMovieClip extends CasaMovieClip {
		protected var _isReversing:Boolean;
		protected var _reverseController:EnterFrame;
		
		
		/**
			Creates a new ReversibleMovieClip.
		*/
		public function ReversibleMovieClip() {
			super();
			
			this._reverseController = EnterFrame.getInstance();
		}
		
		/**
			Plays the timeline in reverse from current playhead position.
		*/
		public function reverse():void {
			this._playInReverse();
		}
		
		/**
			Sends the playhead to the specified frame on and reverses from that frame.
			
			@param frame: A number representing the frame number or a string representing the label of the frame to which the playhead is sent.
		*/
		public function gotoAndReverse(frame:Object):void {
			super.gotoAndStop(frame);
			
			this._playInReverse();
		}
		
		/**
			@exclude
		*/
		override public function gotoAndPlay(frame:Object, scene:String = null):void {
			this._stopReversing();
			
			super.gotoAndPlay(frame, scene);
		}
		
		/**
			@exclude
		*/
		override public function gotoAndStop(frame:Object, scene:String = null):void {
			this._stopReversing();
			
			super.gotoAndStop(frame, scene);
		}
		
		/**
			@exclude
		*/
		override public function play():void {
			this._stopReversing();
			
			super.play();
		}
		
		/**
			@exclude
		*/
		override public function stop():void {
			this._stopReversing();
			
			super.stop();
		}
		
		/**
			Determines if the MovieClip is currently reversing <code>true</code>, or is stopped or playing <code>false</code>.
		*/
		public function get reversing():Boolean {
			return this._isReversing;
		}
		
		override public function destroy():void {
			this._stopReversing();
			
			super.destroy();
		}
		
		protected function _stopReversing():void {
			if (!this._isReversing)
				return;
			
			this._isReversing = false;
			
			this._reverseController.removeEventListener(Event.ENTER_FRAME, this._gotoFrameBefore);
		}
		
		protected function _playInReverse():void {
			if (this._isReversing)
				return;
			
			this._isReversing = true;
			
			this._reverseController.addEventListener(Event.ENTER_FRAME, this._gotoFrameBefore, false, 0, true);
		}
		
		protected function _gotoFrameBefore(e:Event):void {
			if (this.currentFrame == 1)
				super.gotoAndStop(this.totalFrames);
			else
				this.prevFrame();
		}
	}
}