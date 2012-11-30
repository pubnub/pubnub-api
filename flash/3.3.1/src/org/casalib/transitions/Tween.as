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
package org.casalib.transitions {
	import flash.events.Event;
	import org.casalib.events.TweenEvent;
	import org.casalib.math.Percent;
	import org.casalib.process.Process;
	import org.casalib.time.EnterFrame;
	import org.casalib.time.FrameTimeStopwatch;
	
	[Event(name="start", type="org.casalib.events.TweenEvent")]
	[Event(name="stop", type="org.casalib.events.TweenEvent")]
	[Event(name="resume", type="org.casalib.events.TweenEvent")]
	[Event(name="update", type="org.casalib.events.TweenEvent")]
	[Event(name="complete", type="org.casalib.events.TweenEvent")]
	
	/**
		Simple and easily extendable tween/transition class.
		
		Advantages of using this tween class over others:
		<ul>
			<li>Does not include any tweening equations, only the equation(s) a user defines.</li>
			<li>Using the built in events you are able to tween more than one value.</li>
			<li>Ability to tween any value, not only DisplayObject properties.</li>
			<li>Works with all easing equations that follow the current time, start position, end position, total time standard.</li>
		</ul>
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 09/06/09
		@example
			<code>
				package {
					import fl.motion.easing.Bounce;
					import org.casalib.display.CasaMovieClip;
					import org.casalib.events.TweenEvent;
					import org.casalib.transitions.Tween;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _tween:Tween;
						
						
						public function MyExample() {
							super();
							
							this._tween = new Tween(Bounce.easeOut, 0, 1, 2);
							this._tween.addEventListener(TweenEvent.UPDATE, this._onTweenPosition);
							this._tween.start();
						}
						
						protected function _onTweenPosition(e:TweenEvent):void {
							trace(e.position);
						}
					}
				}
			</code>
			
			You can tween color by using {@link ColorUtil}'s {@link ColorUtil#interpolateColor interpolateColor} function:
			<code>
				package {
					import fl.motion.easing.Linear;
					import flash.geom.ColorTransform;
					import org.casalib.display.CasaMovieClip;
					import org.casalib.display.CasaSprite;
					import org.casalib.events.TweenEvent;
					import org.casalib.transitions.Tween;
					import org.casalib.util.ColorUtil;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _box:CasaSprite;
						protected var _finishColor:ColorTransform;
						protected var _tween:Tween;
						
						
						public function MyExample() {
							super();
							
							this._box = new CasaSprite();
							this._box.graphics.beginFill(0x0000FF);
							this._box.graphics.drawRect(0, 0, 250, 250);
							this._box.graphics.endFill();
							
							this.addChild(this._box);
							
							this._finishColor       = new ColorTransform();
							this._finishColor.color = 0xFF0000;
							
							this._tween = new Tween(Linear.easeNone, 0, 1, 1);
							this._tween.addEventListener(TweenEvent.UPDATE, this._onTweenPosition);
							this._tween.start();
						}
						
						protected function _onTweenPosition(e:TweenEvent):void {
							this._box.transform.colorTransform = ColorUtil.interpolateColor(new ColorTransform(), this._finishColor, e.progress);
						}
					}
				}
			</code>
			
			If you want to tween an item on a ellipse you can use the {@link Ellipse} class and its {@link Ellipse#getPointOfDegree getPointOfDegree} function:
			<code>
				package {
					import fl.motion.easing.Bounce;
					import flash.geom.Point;
					import org.casalib.display.CasaMovieClip;
					import org.casalib.display.CasaSprite;
					import org.casalib.events.TweenEvent;
					import org.casalib.math.geom.Ellipse;
					import org.casalib.transitions.Tween;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _box:CasaSprite;
						protected var _tween:Tween;
						protected var _ellipse:Ellipse = new Ellipse(20, 50, 300, 200);
						
						
						public function MyExample() {
							super();
							
							this._box = new CasaSprite();
							this._box.graphics.beginFill(0xFF00FF);
							this._box.graphics.drawRect(0, 0, 25, 25);
							this._box.graphics.endFill();
							
							this.addChild(this._box);
							
							this._tween = new Tween(Bounce.easeOut, 0, 360, 5);
							this._tween.addEventListener(TweenEvent.UPDATE, this._onTweenPosition);
							this._tween.start();
						}
						
						protected function _onTweenPosition(e:TweenEvent):void {
							var point:Point = this._ellipse.getPointOfDegree(e.position);
							
							this._box.x = point.x;
							this._box.y = point.y;
						}
					}
				}
			</code>
			
		@usageNote If you want to tween a property use {@link PropertyTween}.
		@see {@link PropertySetter}
	*/
	public class Tween extends Process {
		protected var _hasInit:Boolean;
		protected var _equat:Function;
		protected var _frameFires:int;
		protected var _framePulse:EnterFrame;
		protected var _stopwatch:FrameTimeStopwatch;
		protected var _time:Number;
		protected var _useFrames:Boolean;
		protected var _begin:Number;
		protected var _currentPosition:Number;
		protected var _diff:Number;
		protected var _end:Number;
		
		
		/**
			Creates and defines a new Tween.
			
			@param equat: The tween equation.
			@param startPos: The starting value of the transition.
			@param endPos: The ending value of the transition.
			@param duration: The length of time of the tween transition.
			@param useFrames: Indicates to use frames <code>true</code>, or seconds <code>false</code> in relation to the value specified in the <code>duration</code> parameter.
			@usageNote The function specified in the <code>equation</code> parameter must follow the (currentTime, startPosition, endPosition, totalTime) parameter standard.
		*/
		public function Tween(equat:Function, startPos:Number, endPos:Number, duration:Number, useFrames:Boolean = false) {
			super();
			
			this.equation   = equat;
			this._begin     = this.position = startPos;
			this._end       = endPos;
			this._diff      = this._end - this._begin;
			this._useFrames = useFrames;
			this.duration   = duration;
			
			if (!this._useFrames)
				this._stopwatch = new FrameTimeStopwatch();
			
			this._framePulse = EnterFrame.getInstance();
		}
		
		/**
			Starts the transition from its starting position.
			
			@sends TweenEvent#START - Dispatched when transition starts.
		*/
		override public function start():void {
			if (this._useFrames)
				this._frameFires = 0;
			else
				this._stopwatch.start();
			
			this._hasInit = true;
			this._framePulse.addEventListener(Event.ENTER_FRAME, this._onFrame, false, 0, true);
			
			super.start();
			
			var updateEvent:TweenEvent = new TweenEvent(TweenEvent.START);
			updateEvent.progress       = this.progress;
			updateEvent.position       = this.position;
			this.dispatchEvent(updateEvent);
			
			this._onFrame();
		}
		
		/**
			Stops the transition at its current position.
			
			@sends TweenEvent#STOP - Dispatched when transition is stopped.
		*/
		override public function stop():void {
			if (!this.running || this.completed)
				return;
			
			if (!this._useFrames)
				this._stopwatch.stop();
			
			this._framePulse.removeEventListener(Event.ENTER_FRAME, this._onFrame);
			
			super.stop();
			
			var updateEvent:TweenEvent = new TweenEvent(TweenEvent.STOP);
			updateEvent.progress       = this.progress;
			updateEvent.position       = this.position;
			this.dispatchEvent(updateEvent);
		}
		
		/**
			Resumes the transition from {@link Tween#stop stopped} position.
			
			@sends TweenEvent#RESUME - Dispatched when transition is resumed.
		*/
		public function resume():void {
			if (!this._hasInit)
				this.start();
			
			if (this.running || this.completed)
				return;
			
			if (!this._useFrames)
				this._stopwatch.resume();
			
			this._framePulse.addEventListener(Event.ENTER_FRAME, this._onFrame);
			
			super.start();
			
			var updateEvent:TweenEvent = new TweenEvent(TweenEvent.RESUME);
			updateEvent.progress       = this.progress;
			updateEvent.position       = this.position;
			this.dispatchEvent(updateEvent);
		}
		
		/**
			Transitions from the tween's current position to a new end position and duration.
			
			@param endPos: The ending value of the transition.
			@param duration: Length of time of the transition.
			@usageNote Will automatically start tween if currently stopped.
		*/
		public function continueTo(endPos:Number, duration:Number):void {
			this._begin   = this.position;
			this._end     = endPos;
			this._diff    = this._end - this._begin;
			this.duration = duration;
			
			this.start();
		}
		
		/**
			The tween equation.
		*/
		public function get equation():Function {
			return this._equat;
		}
		
		public function set equation(equat:Function):void {
			this._equat = equat;
		}
		
		/**
			The length of time of the tween transition.
		*/
		public function get duration():Number {
			return (this._useFrames) ? this._time : this._time / 1000;
		}
		
		public function set duration(dur:Number):void {
			this._time = (this._useFrames) ? dur : dur * 1000;
		}
		
		/**
			The current position of the tween.
		*/
		public function get position():Number {
			return this._currentPosition;
		}
		
		public function set position(pos:Number):void {
			this._currentPosition = pos;
		}
		
		/**
			The percent completed of the tween's duration.
		*/
		public function get progress():Percent {
			return new Percent(this._timeProgress / this._time);
		}
		
		override public function destroy():void {
			super.destroy();
		}
		
		/**
			@sends TweenEvent#UPDATE - Dispatched as the transition progresses.
			@sends TweenEvent#COMPLETE - Dispatched when transition completes.
		*/
		protected function _onFrame(e:Event = null):void {
			const timePos:Number   = this._timeProgress;
			const finished:Boolean = timePos == this._time;
			
			this.position = finished ? this._end : this.equation.apply(null, [timePos, this._begin, this._diff, this._time]);
			
			var updateEvent:TweenEvent = new TweenEvent(TweenEvent.UPDATE);
			updateEvent.progress       = this.progress;
			updateEvent.position       = this.position;
			this.dispatchEvent(updateEvent);
			
			if (finished) {
				if (!this._useFrames)
					this._stopwatch.stop();
				
				this._framePulse.removeEventListener(Event.ENTER_FRAME, this._onFrame);
				
				this._complete();
				
				updateEvent          = new TweenEvent(TweenEvent.COMPLETE);
				updateEvent.progress = this.progress;
				updateEvent.position = this.position;
				this.dispatchEvent(updateEvent);
			}
		}
		
		protected function get _timeProgress():Number {
			var timeProgress:Number = (this._useFrames) ? ++this._frameFires : this._stopwatch.time;
			
			return (timeProgress > this._time) ? this._time : timeProgress;
		}
	}
}