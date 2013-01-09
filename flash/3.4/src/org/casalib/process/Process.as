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
package org.casalib.process {
	import org.casalib.control.IRunnable;
	import org.casalib.events.RemovableEventDispatcher;
	import org.casalib.events.ProcessEvent;
	
	[Event(name="processStart", type="org.casalib.events.ProcessEvent")]
	[Event(name="processStop", type="org.casalib.events.ProcessEvent")]
	[Event(name="processComplete", type="org.casalib.events.ProcessEvent")]
	
	/**
		Base process class. Process is not designed to be used on its own and needs to be extended to function.
		
		@author Aaron Clinger
		@version 02/11/10
	*/
	public class Process extends RemovableEventDispatcher implements IRunnable {
		public static var NORM_PRIORITY:int = 0; /**< The default priority for all Process instances. */
		protected var _priority:uint;
		protected var _isRunning:Boolean;
		protected var _hasCompleted:Boolean;
		
		
		/**
			Creates a new Process.
		*/
		public function Process() {
			super();
			
			this.priority = Process.NORM_PRIORITY;
		}
		
		/**
			@sends ProcessEvent#START - Dispatched when process starts.
		*/
		public function start():void {
			this._isRunning    = true;
			this._hasCompleted = false;
			
			this.dispatchEvent(new ProcessEvent(ProcessEvent.START));
		}
		
		/**
			@sends ProcessEvent#STOP - Dispatched when process is stopped.
		*/
		public function stop():void {
			this._isRunning = false;
			
			this.dispatchEvent(new ProcessEvent(ProcessEvent.STOP));
		}
		
		/**
			Determines if the process is currently running <code>true</code>, or if it isn't <code>false</code>.
		*/
		public function get running():Boolean {
			return this._isRunning;
		}
		
		/**
			Determines if the process has completed <code>true</code>, or if it hasn't <code>false</code>.
		*/
		public function get completed():Boolean {
			return this._hasCompleted;
		}
		
		/**
			The priority relative to other processes. The higher priority processes will take precedence over lower priority processes in a {@link ProcessGroup}.
		*/
		public function get priority():int {
			return this._priority;
		}
		
		public function set priority(priority:int):void {
			this._priority = priority;
		}
		
		override public function destroy():void {
			if (this.running)
				this.stop();
			
			super.destroy();
		}
		
		/**
			@sends ProcessEvent#COMPLETE - Dispatched when process completes.
		*/
		protected function _complete():void {
			this._isRunning    = false;
			this._hasCompleted = true;
			
			this.dispatchEvent(new ProcessEvent(ProcessEvent.COMPLETE));
		}
	}
}