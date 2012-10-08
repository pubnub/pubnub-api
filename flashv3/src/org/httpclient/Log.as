package org.httpclient {
  
  import flash.utils.getQualifiedClassName;
  import flash.utils.describeType;
  
  /**
   * Log class.
   */
  public class Log {
    
    public static const DEBUG:Number = 1;
    public static const INFO:Number = 2;
    public static const WARN:Number = 3;
    public static const ERROR:Number = 4;
    public static const OFF:Number = 5;
    
    public static var level:Number = INFO;
      
    // What to do with logged string  
    private static function output(s:String):void {
      trace(s);
    }
        
    /**
     * Log at debug level.
     * @param Debug string
     * @param Objects to describe
     */
    public static function debug(... args):void {
      if (level > DEBUG) return;
      output(describeArgsToString(args));
    }
    
    /**
     * Log at warn level.
     */
    public static function warn(... args):void {
      if (level > WARN) return;
      output("[WARNING] " + describeArgsToString(args));
    }
    
    /**
     * Log at error level.
     */
    public static function error(... args):void {
      output("[ERROR] " + describeArgsToString(args));
    }
        
    /**
     * Describe an object.
     */
    public static function describe(obj:*):String {
      if (obj == null) return "null";
      if (obj is String) return obj.toString();
      if (obj is Number) return obj.toString();
      if (obj is Function) return "(Function)";
      if (obj is Array) return "[ " + (obj as Array).map(function(item:*, index:int, a:Array):String { return describe(item); }).join(", ") + " ]";
      
      var entries:Array = [];
      for(var key:String in obj) {
        // Make sure we don't stack overflow on cyclical reference
        if (obj[key] == obj) continue;
        entries.push(key + ": " + obj[key]); //describe(obj[key]));
      }
      if (entries.length > 0) return "{" + entries.join(", ") + "}";
      
      var className:String = getQualifiedClassName(obj);
      return "(" + className + ") " + obj.toString();      
    }

    /**
     * Describe arguments list.
     * @param Arguments to describe
     */
    public static function describeArgs(args:Array):Array {
      return args.map(function(item:*, index:int, array:Array):* { return describe(item); });
    }
    
    public static function describeArgsToString(args:Array):String {
      if (args.length == 0) return "";
      var described:Array = describeArgs(args);
      if (described.length == 0) return "";
      return described.join(", ");
    }

    
  }
}