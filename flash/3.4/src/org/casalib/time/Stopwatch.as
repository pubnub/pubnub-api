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
	import flash.utils.getTimer;
	import org.casalib.control.IResumable;
	
	/**
		Simple stopwatch class that records elapsed time in milliseconds.
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 02/11/11
		@example
			<code>
				package {
					import org.casalib.display.CasaMovieClip;
					import org.casalib.time.Stopwatch;
					
					
					public class MyExample extends CasaMovieClip {
						
						public function MyExample() {
							super();
							
							var stopwatch:Stopwatch = new Stopwatch();
							stopwatch.start();
							
							var l:uint = 1000000;
							while (l--) {
								doSomething();
							}
							
							trace(stopwatch.time);
						}
						
						public function doSomething():void {
							
						}
					}
				}
			</code>
	*/
	public class Stopwatch implements IResumable {
		protected var _elapsedTime:int;
		protected var _startTime:int;
		protected var _isRunning:Boolean;
		
		
		/**
			Creates a new Stopwatch.
		*/
		public function Stopwatch() {
			super();
			
			this._startTime   = 0;
			this._elapsedTime = 0;
		}
		
		/**
			Starts stopwatch and resets previous elapsed time.
		*/
		public function start():void {
			this._elapsedTime = 0;
			this._startTime   = this._timer;
			this._isRunning   = true;
		}
			
		/**
			Stops stopwatch.
		*/
		public function stop():void {
			this._elapsedTime = this.time;
			this._startTime   = 0;
			this._isRunning   = false;
		}
		
		/**
			Resumes stopwatch from {@link Stopwatch#stop}.
		*/
		public function resume():void {
			if (!this.running) {
				this._startTime = this._timer;
				this._isRunning = true;
			}
		}
		
		/**
			Determines if the stopwatch is currently running <code>true</code>, or if it isn't <code>false</code>.
		*/
		public function get running():Boolean {
			return this._isRunning;
		}
		
		/**
			Gets the time elapsed since {@link Stopwatch#start} or until {@link Stopwatch#stop} was called.
			
			@return Returns the elapsed time in milliseconds.
			@usageNote Can be called before or after calling {@link Stopwatch#stop}.
		*/
		public function get time():int {
			return (this._startTime != 0) ? this._timer - this._startTime + this._elapsedTime : this._elapsedTime;
		}
		
		protected function get _timer():int {
			return getTimer();
		}
	}
}