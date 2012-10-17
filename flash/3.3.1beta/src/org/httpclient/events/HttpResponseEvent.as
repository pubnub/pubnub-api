package org.httpclient.events {
  
  import flash.events.Event;
  
  import org.httpclient.HttpResponse;
  
  public class HttpResponseEvent extends Event {
    
    public static const COMPLETE:String = "responseComplete";
    
    private var _response:HttpResponse;
    
    public function HttpResponseEvent(response:HttpResponse, type:String = COMPLETE, bubbles:Boolean = false, cancelable:Boolean = false):void {
      super(type, bubbles, cancelable);
      _response = response;
    }
    
    public function get response():HttpResponse {
      return _response;
    }
    
  }
}