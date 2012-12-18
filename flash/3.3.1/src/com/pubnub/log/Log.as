package com.pubnub.log {
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Log {
		public static const MAX_RECORDS:Number = 1000;
		/*public static const TIMEOUT_LOGGING:Boolean = true;
		public static const RETRY_LOGGING:Boolean = true;
		public static const URL_LOGGING:Boolean = true;
		
		
		public static const TIMEOUT:String = 'timeout';
		public static const RETRY:String = 'retry';
		public static const URL:String = 'url';
		public static const ALL:String = 'all';*/
		public static const RECONNECT_HEARTBEAT_TIMEOUT:String = 'RECONNECT_HEARTBEAT_TIMEOUT';
		public static const OPERATION_TIMEOUT:String = 'OPERATION_TIMEOUT';
		
		public static const NORMAL:String = 'normal';
		public static const DEBUG:String = 'debug';
		public static const WARNING:String = 'warning';
		public static const ERROR:String = 'error';
		public static const FATAL:String = 'fatal';
		
		private static var __instance:Log;
		private var recodrs:/*LogRecord*/Array = [];
		
		public function Log() {
			if (__instance) throw('Use get insctance');
			__instance = this;
		}
		
		static public function get instance():Log {
			return __instance || new Log();
		}
		
		static public function log(message:String, level:String = NORMAL, type:String = ''):void{
			trace(new Date() + " " + message);
            instance.recodrs.push(new LogRecord(message, type, level, instance.recodrs.length));
			// to do refactor to unshift/pop it is more faster ????
			if (instance.recodrs.length > MAX_RECORDS) {
				instance.recodrs.shift();
			}
		}
		
		static public function out(type:String = null, level:String = null):Array {
			var result:Array = [];
			var records:/*LogRecord*/Array = instance.recodrs;
			var rec:LogRecord;
			var levelResult:Boolean;
			var typeResult:Boolean;
			var len:int = records.length;
			for (var i:int = 0; i < len; i++) {
				rec = records[i];
				typeResult = false
				levelResult = false
				
				typeResult = (type == null) ||  (rec.type == type);
				levelResult = (level == null) ||  (rec.level == level);
				
				if (typeResult && levelResult) {
					result.push(rec.toString());
				}
			}
			return result;
		}
		
		static public function clear():void {
			instance.recodrs.length = 0;
		}
		
		static public function get errors():Array {
			return out(null, ERROR);
		}
		
		static public function get warnings():Array {
			return out(null, WARNING);
		}
		
		static public function get fatals():Array {
			return out(null, FATAL);
		}
		
		static public function get debugs():Array {
			return out(null, DEBUG);
		}
		
		static public function get normals():Array {
			return out(null, NORMAL);
		}
	}
}

class LogRecord {
	public var level:String;
	public var type:String;
	public var message:String;
	public var date:Date;
	public var index:int = -1;
	public function LogRecord(message:String, type:String, level:String = 'normal', index:int = -1){
		this.level = level;
		this.index = index;
		this.type = type;
		this.message = message;
		date = new Date();
	}
	
	public function toString():String{
		//return (index+1) + '.' +  date.toString() + ' [' + level+  '] '+': ' + message;
		return (index+1) + '.' + ' [' + level.toUpperCase()+  '] '+' : ' +  '[' + date.toString() + '] : ' + message;
	}
	
}