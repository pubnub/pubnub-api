package org.httpclient.events {
  
  import flash.events.Event;
  
  import org.httpclient.HttpResponse;
  import org.httpclient.HttpHeader;
  
  public class HttpStatusEvent extends Event {
    
    public static const STATUS:String = "httpStatus";
    
    private var _response:HttpResponse;
    
    public function HttpStatusEvent(response:HttpResponse, type:String = STATUS, bubbles:Boolean = false, cancelable:Boolean = false):void {
      super(type, bubbles, cancelable);
      _response = response;     
    }
    
    public function get response():HttpResponse {
      return _response;
    }
    
    public function get code():String { 
      return _response.code; 
    }
    
    public function get header():HttpHeader
    {
      return _response.header;
    }
  }
}