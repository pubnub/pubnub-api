package org.httpclient.events {
    
  import org.httpclient.Log;
  import flash.utils.ByteArray;
  
  
  /**
   * Same as HttpListener but stores data. 
   * You may want to use the regular HttpListener to handle the data as it becomes
   * available instead of storing it in memory.
   */
  public class HttpDataListener extends HttpListener {
    
    public var onDataComplete:Function = null;
    
    private var _data:ByteArray = null;
    
    /**
      * In addition to HttpListener listeners, we have:
      *  - onDataComplete(e:HttpResponseEvent, data:ByteArray)
      */
    public function HttpDataListener(listeners:Object = null) {
      super(listeners);  
      if (listeners && listeners["onDataComplete"] != undefined) onDataComplete = listeners.onDataComplete;
      _data = new ByteArray();
    }
    
    override protected function onInternalData(e:HttpDataEvent):void {
      if (_data != null) _data.writeBytes(e.bytes, 0, e.bytes.length);
      super.onInternalData(e);
    }
    
    override protected function onInternalComplete(e:HttpResponseEvent):void { 
      if (onDataComplete != null) onDataComplete(e, _data);
      _data = null;
      super.onInternalComplete(e);
    }
  }
}