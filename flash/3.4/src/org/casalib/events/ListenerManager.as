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
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import org.casalib.core.Destroyable;
	import org.casalib.events.IRemovableEventDispatcher;
	import org.casalib.util.ArrayUtil;
	
	/**
		Creates an easy way to implement {@link IRemovableEventDispatcher} when you cannot extend directly from {@link RemovableEventDispatcher}. 
		
		@author Aaron Clinger
		@version 02/11/10
		@example
			<code>
				package {
					import flash.events.MouseEvent;
					import org.casalib.display.CasaMovieClip;
					import org.casalib.display.CasaSprite;
					import org.casalib.events.ListenerManager;
					
					
					public class MyExample extends CasaMovieClip {
						protected var _button:CasaSprite;
						protected var _buttonListenerManager:ListenerManager;
						
						
						public function MyExample() {
							super();
							
							this._button = new CasaSprite();
							this._button.graphics.beginFill(0x00FF00);
							this._button.graphics.drawRect(0, 0, 150, 150);
							this._button.graphics.endFill();
							
							this.addChild(this._button);
							
							this._buttonListenerManager = ListenerManager.getManager(this._button);
							
							this._buttonListenerManager.addEventListener(MouseEvent.MOUSE_OVER, this._onMouseOver);
							this._button.addEventListener(MouseEvent.MOUSE_OVER, this._onMouseOver);
							
							this._buttonListenerManager.addEventListener(MouseEvent.MOUSE_OUT, this._onMouseOut);
							this._button.addEventListener(MouseEvent.MOUSE_OUT, this._onMouseOut);
							
							this._buttonListenerManager.addEventListener(MouseEvent.CLICK, this._onClick);
							this._button.addEventListener(MouseEvent.CLICK, this._onClick);
						}
						
						protected function _onMouseOver(e:MouseEvent):void {
							trace("On mouse over.");
						}
						
						protected function _onMouseOut(e:MouseEvent):void {
							trace("On mouse out.");
						}
						
						protected function _onClick(e:MouseEvent):void {
							trace("On mouse clicked. No more events will fire.");
							
							this._buttonListenerManager.removeEventListeners();
						}
					}
				}
			</code>
			
			To implement {@link IRemovableEventDispatcher} with out the option to extend from {@link RemovableEventDispatcher} you can use ListenerManager in this way:
			<code>
				package {
					import flash.display.Sprite;
					import org.casalib.core.IDestroyable;
					import org.casalib.events.IRemovableEventDispatcher;
					import org.casalib.events.ListenerManager;
					
					
					public class RemovableSprite extends Sprite implements IRemovableEventDispatcher, IDestroyable {
						protected var _listenerManager:ListenerManager;
						protected var _isDestroyed:Boolean;
						
						
						public function RemovableSprite() {
							super();
							
							this._listenerManager = ListenerManager.getManager(this);
						}
						
						override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
							super.addEventListener(type, listener, useCapture, priority, useWeakReference);
							this._listenerManager.addEventListener(type, listener, useCapture, priority, useWeakReference);
						}
						
						override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
							super.removeEventListener(type, listener, useCapture);
							this._listenerManager.removeEventListener(type, listener, useCapture);
						}
						
						public function removeEventsForType(type:String):void {
							this._listenerManager.removeEventsForType(type);
						}
						
						public function removeEventsForListener(listener:Function):void {
							this._listenerManager.removeEventsForListener(listener);
						}
						
						public function removeEventListeners():void {
							this._listenerManager.removeEventListeners();
						}
						
						public function getTotalEventListeners(type:String = null):uint {
							return this._listenerManager.getTotalEventListeners(type);
						}
						
						public function get destroyed():Boolean {
							return this._isDestroyed;
						}
						
						public function destroy():void {
							this._listenerManager.destroy();
							
							this._isDestroyed = true;
						}
					}
				}
			</code>
	*/
	public class ListenerManager extends Destroyable implements IRemovableEventDispatcher {
		protected static var _proxyMap:Dictionary;
		protected var _eventDispatcher:IEventDispatcher;
		protected var _events:Array;
		protected var _blockRequest:Boolean;
		
		
		/**
			Registers a <code>IEventDispatcher</code> to be managed by ListenerManager.
			
			@param eventDispatcher: The <code>IEventDispatcher</code> instance to manage.
			@return A ListenerManager instance.
		*/
		public static function getManager(dispatcher:IEventDispatcher):ListenerManager {
			if (ListenerManager._proxyMap == null)
				ListenerManager._proxyMap = new Dictionary();
			
			if (!(dispatcher in ListenerManager._proxyMap))
				ListenerManager._proxyMap[dispatcher] = new ListenerManager(new EventInfo(null, null, false), dispatcher);
			
			return ListenerManager._proxyMap[dispatcher];
		}
		
		/**
			@exclude
		*/
		public function ListenerManager(singletonEnforcer:EventInfo, dispatcher:IEventDispatcher) {
			super();
			
			this._eventDispatcher = dispatcher;
			this._events          = new Array();
		}
		
		/**
			Notifies the ListenerManager instance that a listener has been added to the <code>IEventDispatcher</code>.
			
			@param type: The type of event.
			@param listener: The listener function that processes the event.
			@param useCapture: Determines whether the listener works in the capture phase or the target and bubbling phases.
			@param priority: The priority level of the event listener.
			@param: useWeakReference: Determines whether the reference to the listener is strong or weak.
		*/
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			var info:EventInfo = new EventInfo(type, listener, useCapture);
			
			var l:int = this._events.length;
			while (l--)
				if (this._events[l].equals(info))
					return;
			
			this._events.push(info);
		}
		
		/**
			@exclude
		*/
		public function dispatchEvent(event:Event):Boolean {
			return this._eventDispatcher.dispatchEvent(event);
		}
		
		/**
			@exclude
		*/
		public function hasEventListener(type:String):Boolean {
			return this._eventDispatcher.hasEventListener(type);
		}
		
		/**
			@exclude
		*/
		public function willTrigger(type:String):Boolean {
			return this._eventDispatcher.willTrigger(type);
		}
		
		/**
			Notifies the ListenerManager instance that a listener has been removed from the <code>IEventDispatcher</code>.
			
			@param type: The type of event.
			@param listener: The listener function that processes the event.
			@param useCapture: Determines whether the listener works in the capture phase or the target and bubbling phases.
		*/
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			if (this._blockRequest)
				return;
			
			var info:EventInfo = new EventInfo(type, listener, useCapture);
			
			var l:int = this._events.length;
			while (l--)
				if (this._events[l].equals(info))
					this._events.splice(l, 1);
		}
		
		public function removeEventsForType(type:String):void {
			this._blockRequest = true;
			
			var l:int = this._events.length;
			var eventInfo:EventInfo;
			while (l--) {
				eventInfo = this._events[l];
				
				if (eventInfo.type == type) {
					this._events.splice(l, 1);
					
					this._eventDispatcher.removeEventListener(eventInfo.type, eventInfo.listener, eventInfo.useCapture);
				}
			}
			
			this._blockRequest = false;
		}
		
		public function removeEventsForListener(listener:Function):void {
			this._blockRequest = true;
			
			var l:int = this._events.length;
			var eventInfo:EventInfo;
			while (l--) {
				eventInfo = this._events[l];
				
				if (eventInfo.listener == listener) {
					this._events.splice(l, 1);
					
					this._eventDispatcher.removeEventListener(eventInfo.type, eventInfo.listener, eventInfo.useCapture);
				}
			}
			
			this._blockRequest = false;
		}
		
		public function removeEventListeners():void {
			this._blockRequest = true;
			
			var l:int = this._events.length;
			var eventInfo:EventInfo;
			while (l--) {
				eventInfo = this._events.splice(l, 1)[0];
				
				this._eventDispatcher.removeEventListener(eventInfo.type, eventInfo.listener, eventInfo.useCapture);
			}
			
			this._blockRequest = false;
		}
		
		public function getTotalEventListeners(type:String = null):uint {
			return (type == null) ? this._events.length : ArrayUtil.getItemsByKey(this._events, 'type', type).length;
		}
		
		override public function destroy():void {
			this.removeEventListeners();
			
			delete ListenerManager._proxyMap[this._eventDispatcher];
			
			this._eventDispatcher = null;
			
			super.destroy();
		}
	}
}

class EventInfo {
	public var type:String;
	public var listener:Function;
	public var useCapture:Boolean;
	
	
	public function EventInfo(type:String, listener:Function, useCapture:Boolean) {
		this.type       = type;
		this.listener   = listener;
		this.useCapture = useCapture;
	}
	
	public function equals(eventInfo:EventInfo):Boolean {
		return this.type == eventInfo.type && this.listener == eventInfo.listener && this.useCapture == eventInfo.useCapture;
	}
}