package com.pubnub.log {
	/**
	 * ...
	 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
	 */
	public class Log {
		public static const MAX_RECORDS:Number = 2000;
		
		public static const RETRY_LOGGING:Boolean = 	true;
		public static const URL_LOGGING:Boolean = 		true;
		public static const TIMEOUT_LOGGING:Boolean = 	true;
		
		// types of log
		public static const TIMEOUT:String = 'timeout';
		public static const RETRY:String = 'retry';
		public static const URL:String = 'url';
		
		// LEVELS of log
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
			//trace(new Date() + " " + message);
			var record:LogRecord = new LogRecord(message, type, level, instance.recodrs.length);
			if (instance.recodrs.length > MAX_RECORDS) {
				// flush log
				instance.recodrs.length = 0;
			}
			instance.recodrs.push(record);
		}
		
		static public function logRetry(message:String, level:String = NORMAL):void {
			if (RETRY_LOGGING) {
				log(message, level, RETRY);
			}
		}
		
		static public function logURL(message:String, level:String = NORMAL):void {
			if (TIMEOUT_LOGGING) {
				log(message, level, TIMEOUT);
			}
		}
		
		static public function logTimeout(message:String, level:String = NORMAL):void {
			if (URL_LOGGING) {
				log(message, level, URL);
			}
		}
		
		static public function out(type:String = null, level:String = null, reverse:Boolean = true):Array {
			var result:Array = [];
			var records:/*LogRecord*/Array = instance.recodrs;
			var rec:LogRecord;
			var levelResult:Boolean;
			var typeResult:Boolean;
			var len:int = records.length;
			var types:Array = type ? type.split(',') : null;
			for (var i:int = 0; i < len; i++) {
				rec = records[i];
				typeResult = false
				levelResult = false
				
				typeResult = (types == null) ||  (types.indexOf(rec.type) > -1);
				levelResult = (level == null) ||  (rec.level == level);
				
				if (typeResult && levelResult) {
					result.push(rec.toString());
				}
			}
			if (reverse) result.reverse();
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
		return (index+1) + '.' + ' [' + level.toUpperCase()+  '], \n'+ message +', \ndate: [' + date.toString() + ']' ;
	}
	
}