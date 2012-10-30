package org.httpclient.events {
  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.ErrorEvent;
  import flash.events.SecurityErrorEvent;
  import flash.events.IOErrorEvent;
  
  /**
   * Registers for events and forwards notifications to specified listeners
   * if they are set.
   */
  public class HttpListener extends EventDispatcher {
    
    public var onClose:Function = null;
    public var onComplete:Function = null;
    public var onConnect:Function = null;
    public var onData:Function = null;
    public var onError:Function = null;
    public var onStatus:Function = null;
    public var onRequest:Function = null;
    
    /**
      * Listeners:
      *  - onClose(e:Event)
      *  - onComplete(e:HttpResponseEvent)
      *  - onConnect(e:HttpRequestEvent)
      *  - onData(e:HttpDataEvent)
      *  - onError(e:ErrorEvent)
      *  - onStatus(e:HttpStatusEvent)
      *  - onRequest(e:HttpRequestEvent)
      */
    public function HttpListener(listeners:Object = null) {
      if (listeners) {
        if (listeners["onClose"] != undefined) onClose = listeners.onClose;
        if (listeners["onComplete"] != undefined) onComplete = listeners.onComplete;
        if (listeners["onConnect"] != undefined) onConnect = listeners.onConnect;
        if (listeners["onData"] != undefined) onData = listeners.onData;
        if (listeners["onError"] != undefined) onError = listeners.onError;
        if (listeners["onStatus"] != undefined) onStatus = listeners.onStatus;
        if (listeners["onRequest"] != undefined) onRequest = listeners.onRequest;
      }
    }
    
    public function register(dispatcher:EventDispatcher = null):HttpListener {
      if (dispatcher == null) dispatcher = this;
      dispatcher.addEventListener(Event.CLOSE, onInternalClose);
      dispatcher.addEventListener(HttpResponseEvent.COMPLETE, onInternalComplete);
      dispatcher.addEventListener(HttpRequestEvent.CONNECT, onInternalConnect);
      dispatcher.addEventListener(HttpDataEvent.DATA, onInternalData);
      dispatcher.addEventListener(HttpErrorEvent.ERROR, onInternalError);
      dispatcher.addEventListener(HttpErrorEvent.TIMEOUT_ERROR, onInternalError);
      dispatcher.addEventListener(HttpStatusEvent.STATUS, onInternalStatus);
      dispatcher.addEventListener(HttpRequestEvent.COMPLETE, onInternalRequest);
      dispatcher.addEventListener(IOErrorEvent.IO_ERROR, onInternalError);
      dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onInternalError);
      return this;
    }
    
    public function unregister(dispatcher:EventDispatcher = null):HttpListener {
      if (dispatcher == null) dispatcher = this;
      dispatcher.removeEventListener(Event.CLOSE, onInternalClose);
      dispatcher.removeEventListener(HttpResponseEvent.COMPLETE, onInternalComplete);
      dispatcher.removeEventListener(HttpRequestEvent.CONNECT, onInternalConnect);
      dispatcher.removeEventListener(HttpDataEvent.DATA, onInternalData);
      dispatcher.removeEventListener(HttpErrorEvent.ERROR, onInternalError);
      dispatcher.removeEventListener(HttpErrorEvent.TIMEOUT_ERROR, onInternalError);
      dispatcher.removeEventListener(HttpStatusEvent.STATUS, onInternalStatus);
      dispatcher.removeEventListener(HttpRequestEvent.COMPLETE, onInternalRequest);
      dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, onInternalError);
      dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onInternalError);
      return this;
    }
    
    protected function onInternalClose(e:Event):void { 
      if (onClose != null) onClose(e);
    }
    
    protected function onInternalComplete(e:HttpResponseEvent):void { 
      if (onComplete != null) onComplete(e);
    }
    
    protected function onInternalConnect(e:HttpRequestEvent):void { 
      if (onConnect != null) onConnect(e);
    }
    
    protected function onInternalRequest(e:HttpRequestEvent):void {
      if (onRequest != null) onRequest(e);
    }
    
    protected function onInternalData(e:HttpDataEvent):void { 
      if (onData != null) onData(e);
    }
    
    protected function onInternalError(e:ErrorEvent):void { 
      if (onError != null) onError(e);
    }
    
    protected function onInternalStatus(e:HttpStatusEvent):void { 
      if (onStatus != null) onStatus(e);
    }
    
  }
}