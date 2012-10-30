package org.httpclient.events {
  
  import flash.events.Event;
  import flash.utils.ByteArray;
  
  public class HttpDataEvent extends Event {
    
    public static const DATA:String = "httpData";
    
    private var _bytes:ByteArray;
    
    public function HttpDataEvent(bytes:ByteArray, type:String = DATA, bubbles:Boolean = false, cancelable:Boolean = false):void {
      super(type, bubbles, cancelable);
      _bytes = bytes;
    }
    
    public function get bytes():ByteArray { return _bytes; }
    
    public function readUTFBytes():String {
      return _bytes.readUTFBytes(_bytes.length);
    }
  }
}