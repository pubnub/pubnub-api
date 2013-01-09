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
	import org.casalib.events.ProcessEvent;
	import org.casalib.process.Process;
	import org.casalib.util.ArrayUtil;
	
	
	/**
		Manages and threads {@link Process processes}.
		
		@author Aaron Clinger
		@version 02/09/10
		@example
			<code>
				package {
					import fl.motion.easing.Linear;
					import org.casalib.display.CasaMovieClip;
					import org.casalib.display.CasaSprite;
					import org.casalib.events.ProcessEvent;
					import org.casalib.process.ProcessGroup;
					import org.casalib.transitions.PropertyTween;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _processGroup:ProcessGroup;
						
						
						public function MyExample() {
							super();
							
							this._processGroup = new ProcessGroup();
							this._processGroup.addEventListener(ProcessEvent.COMPLETE, this._onProcessComplete);
							
							var i:int = -1;
							var box:CasaSprite;
							while (++i < 10) {
								box   = new CasaSprite();
								box.y = 30 * i;
								box.graphics.beginFill(0xFF00FF);
								box.graphics.drawRect(0, 0, 25, 25);
								box.graphics.endFill();
								
								this.addChild(box);
								
								this._processGroup.addProcess(new PropertyTween(box, 'x', Linear.easeNone, 500, 1));
							}
							
							this._processGroup.start();
						}
						
						protected function _onProcessComplete(e:ProcessEvent):void {
							this._processGroup.destroyProcesses();
							this._processGroup.destroy();
							
							trace("Done!");
						}
					}
				}
			</code>
	*/
	public class ProcessGroup extends Process {
		public static var NORM_THREADS:uint  = 1; /**< The default amount of threads for all ProcessGroup instances. */
		public static const MAX_THREADS:uint = uint.MAX_VALUE;  /**< The maximum amount of threads for a ProcessGroup instance. Use this value if you wish to disable threading. */
		protected var _threads:uint;
		protected var _processes:Array;
		protected var _autoStart:Boolean;
		
		
		/**
			Creates a new ProcessGroup.
		*/
		public function ProcessGroup() {
			super();
			
			this.threads    = ProcessGroup.NORM_THREADS;
			this._processes = new Array();
		}
		
		override public function start():void {
			super.start();
			
			this._checkThreads();
		}
		
		override public function stop():void {
			this._isRunning = false;
			
			var l:uint = this._processes.length;
			while (l--) {
				if (this._processes[l].running) {
					this._processes[l].stop();
					return;
				}
			}
			
			super.stop();
		}
		
		/**
			Instructs the ProcessGroup to {@link #start} automatically if it contains an incomplete {@link Process} or if an incomplete is {@link Process#addProcess added}.
		*/
		public function get autoStart():Boolean {
			return this._autoStart;
		}
		
		public function set autoStart(autoStart:Boolean):void {
			this._autoStart = autoStart;
			
			if (!this.completed && !this.running)
				this.start();
		}
		
		/**
			Adds a process to be threaded and run by the ProcessGroup.
			
			@param process: The process to be added and run by the group.
			@usageNote You can add a different instance of ProcessGroup to another ProcessGroup.
			@throws <code>Error</code> if you try add the same Process to itself.
		*/
		public function addProcess(process:Process):void {
			if (process == this)
				throw new Error('You cannot add the same Process to itself.');
			
			this.removeProcess(process);
			
			this._addProcessListeners(process);
			
			this._hasCompleted = process.completed;
			
			if (this._processes.length == 0) {
				this._processes.push(process);
			} else {
				var i:int = -1;
				var l:int = this._processes.length - 1;
				var hasAdded:Boolean;
				var p:Process;
				
				while (++i < this._processes.length) {
					p = this._processes[i];
					
					if (!p.completed) {
						this._hasCompleted = false;
						
						if (hasAdded)
							break;
					}
					
					if (!hasAdded) {
						if (process.priority > p.priority) {
							this._processes.splice(i, 0, process);
							hasAdded = true;
						} else if (i == l) {
							this._processes.push(process);
							hasAdded = true;
						}
						
						if (hasAdded && !this._hasCompleted)
							break;
					}
				}
			}
			
			if (this.autoStart && !this.completed) {
				if (this.running)
					this._checkThreads();
				else
					this.start();
			}
		}
		
		/**
			Removes a process from the ProcessGroup.
			
			@param process: The process to be removed.
		*/
		public function removeProcess(process:Process):void {
			this._removeProcessListeners(process);
			
			this._hasCompleted = true;
			
			var l:uint = this._processes.length;
			while (l--) {
				if (this._processes[l] == process)
					this._processes.splice(l, 1);
				else if (!this._processes[l].completed)
					this._hasCompleted = false;
			}
		}
		
		/**
			Determines if this ProcessGroup contains a specific process.
			
			@param process: The process to search for.
			@param recursive: If any child of this ProcessGroup is also a ProcessGroup search its children <code>true</code>, or only search this ProcessGroup's children <code>false</code>.
			@return Returns <code>true</code> if the ProcessGroup contains the process; otherwise <code>false</code>.
		*/
		public function hasProcess(process:Process, recursive:Boolean = true):Boolean {
			const processFound:Boolean = this._processes.indexOf(process) > -1;
			
			if (!recursive)
				return processFound;
			
			if (processFound)
				return true;
			
			var l:uint = this._processes.length;
			var p:Process;
			var g:ProcessGroup;
			
			while (l--) {
				p = this._processes[l];
				
				if (p is ProcessGroup) {
					g = p as ProcessGroup;
					
					if (g.hasProcess(process, true))
						return true;
				}
			}
			
			return false;
		}
		
		/**
			The processes that compose the group.
		*/
		public function get processes():Array {
			return this._processes.concat();
		}
		
		/**
			The processes that are neither complete or running.
		*/
		public function get queuedProcesses():Array {
			return ArrayUtil.getItemsByKey(this.incompletedProcesses, 'running', false);
		}
		
		/**
			The processes that are currently running.
		*/
		public function get runningProcesses():Array {
			return ArrayUtil.getItemsByKey(this.processes, 'running', true);
		}
		
		/**
			The processes that have not completed.
		*/
		public function get incompletedProcesses():Array {
			return ArrayUtil.getItemsByKey(this.processes, 'completed', false);
		}
		
		/**
			The processes that have completed.
		*/
		public function get completedProcesses():Array {
			return ArrayUtil.getItemsByKey(this.processes, 'completed', true);
		}
		
		/**
			The number of simultaneous processes to run at once.
		*/
		public function get threads():uint {
			return this._threads;
		}
		
		public function set threads(threadAmount:uint):void {
			this._threads = threadAmount;
		}
		
		/**
			Calls {@link Process#destroy destroy} on all processes in the group and removes them from the ProcessGroup.
			
			@param recursive: If any child of this ProcessGroup is also a ProcessGroup destroy its children <code>true</code>, or only destroy this ProcessGroup's children <code>false</code>.
		*/
		public function destroyProcesses(recursive:Boolean = true):void {
			this.stop();
			
			var l:uint = this._processes.length;
			
			if (recursive) {
				var p:Process;
				var g:ProcessGroup;
				
				while (l--) {
					p = this._processes[l];
					
					if (p is ProcessGroup) {
						g = p as ProcessGroup;
						g.destroyProcesses(true);
					} else
						p.destroy();
				}
			} else
				while (l--)
					this._processes[l].destroy();
			
			this._processes = new Array();
		}
		
		override public function destroy():void {
			var l:uint = this._processes.length;
			while (l--)
				this._removeProcessListeners(this._processes[l]);
			
			this._processes = new Array();
			
			super.destroy();
		}
		
		protected function _checkThreads():void {
			var t:uint = this.threads;
			var i:int  = -1;
			var p:Process;
			
			while (++i < this._processes.length) {
				if (t == 0)
					return;
				
				p = this._processes[i];
				
				if (p.running)
					t--;
				else if (!p.completed && this.running) {
					p.start();
					t--;
				}
			}
			
			if (t == this.threads && this.running)
				this._complete();
		}
		
		protected function _onProcessStopped(e:ProcessEvent):void {
			this._checkThreads();
		}
		
		protected function _onProcessCompleted(e:ProcessEvent):void {
			this._checkThreads();
		}
		
		protected function _addProcessListeners(process:Process):void {
			process.addEventListener(ProcessEvent.STOP, this._onProcessStopped, false, 0, true);
			process.addEventListener(ProcessEvent.COMPLETE, this._onProcessCompleted, false, 0, true);
		}
		
		protected function _removeProcessListeners(process:Process):void {
			process.removeEventListener(ProcessEvent.STOP, this._onProcessStopped);
			process.removeEventListener(ProcessEvent.COMPLETE, this._onProcessCompleted);
		}
	}
}