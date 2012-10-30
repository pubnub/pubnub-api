package org.httpclient.events {
  
  import flash.events.ErrorEvent;
  
  public class HttpErrorEvent extends ErrorEvent {
    
    public static const ERROR:String = "httpError";
    public static const TIMEOUT_ERROR:String = "httpTimeoutError";
    
    public function HttpErrorEvent(type:String = ERROR, bubbles:Boolean = false, 
      cancelable:Boolean = false, text:String = "", id:int = 0):void {
        
      super(type, bubbles, cancelable, text);
    }
        
  }
}