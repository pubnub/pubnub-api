package org.casalib.events {
	import flash.events.Event;
	
	
	/**
		An event dispatched from {@link Sequence}.
		
		@author Jon Adams
		@author Aaron Clinger
		@version 10/27/08
	*/
	public class SequenceEvent extends Event {
		public static const COMPLETE:String = 'complete';
		public static const RESUME:String   = 'resume';
		public static const START:String    = 'start';
		public static const STOP:String     = 'stop';
		public static const LOOP:String     = 'loop';
		protected var _loops:uint;
		
		
		/**
			Creates a new SequenceEvent.
			
			@param type: The type of event.
			@param bubbles: Determines whether the Event object participates in the bubbling stage of the event flow.
			@param cancelable: Determines whether the Event object can be canceled.
		*/
		public function SequenceEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
		/**
			The number of times the sequence has run.
		*/
		public function get loops():uint {
			return this._loops;
		}
		
		public function set loops(loops:uint):void {
			this._loops = loops;
		}
		
		/**
			@return A string containing all the properties of the event.
		*/
		override public function toString():String {
			return formatToString('SequenceEvent', 'type', 'bubbles', 'cancelable', 'loops');
		}
		
		/**
			@return Duplicates an instance of the event.
		*/
		override public function clone():Event {
			var e:SequenceEvent = new SequenceEvent(this.type, this.bubbles, this.cancelable);
			e.loops = this.loops;
			
			return e;
		}
	}
}
