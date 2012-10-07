package org.httpclient.ui {
  
  import flash.system.*;
  import mx.controls.*;
  import mx.containers.*;
  import flash.events.*;
  import mx.core.Application;
  import mx.events.MenuEvent;
  import flash.utils.ByteArray;
  import mx.collections.ArrayCollection;
  
  import org.httpclient.*;
  import org.httpclient.http.*;
  import org.httpclient.events.*;
  import com.adobe.net.URI;
  import com.adobe.utils.StringUtil;

  public class HttpClientAppImpl extends Application {
    
    [Bindable]
    public var verbs:ArrayCollection = new ArrayCollection([ { label:"GET" }, { label:"HEAD" }, { label:"DELETE" }, { label:"PUT" }, { label:"POST" } ]);
    
    [Bindable]
    public var requestSent:String = "";
    
    [Bindable]
    public var status:String = "";
  
    [Bindable]
    public var responseStatus:String;
    
    [Bindable]
    public var responseHeader:String;
    
    [Bindable]
    public var responseBody:String;    
    
    // Components
    public var uriInput:TextInput;
    public var requestHeaderArea:TextArea;
    public var requestBodyArea:TextArea;    
    public var tabNavigator:TabNavigator;
    public var verbCombo:ComboBox;

    public function onCreationComplete(event:Event):void {      
      //Security.loadPolicyFile("xmlsocket://domain.com:5001");
    }

    public function onRequest(event:Event):void {
      
      var verb:String = verbCombo.selectedItem.label;
  
      requestSent = "";
      responseBody = "";
      responseStatus = "";
      responseHeader = "";    
      
      var listeners:Object = { 
        onConnect: function(e:HttpRequestEvent):void {
          status = "Connected";
        },
        onRequest: function(e:HttpRequestEvent):void {
          status = "Request sent";
          requestSent = e.header.replace(/\r\n/g, "\n");
          if (e.request.body) requestSent += e.request.body;
        },
        onStatus: function(e:HttpStatusEvent):void {
          status = "Got response header";
          responseStatus = e.code + " " + e.response.message;
          responseHeader = e.header.toString();
        },
        onData: function(e:HttpDataEvent):void {           
          status = "Received " + e.bytes.length + " bytes";
          responseBody += e.readUTFBytes();
        },        
        onClose: function():void {
          status = "Closed";
          tabNavigator.selectedIndex = 1;
        },
        onComplete: function(e:HttpResponseEvent):void {          
          status = "Completed";
        },
        onError: function(event:ErrorEvent):void {
          status = "Error: " + event.text;
        }
      };
      
      status = "Connecting";
      
      var client:HttpClient = new HttpClient();
      client.timeout = 5000;
      client.listener = new HttpListener(listeners);
      
      var request:HttpRequest = null;  
      if (verb == "GET") request = new Get();        
      else if (verb == "HEAD") request = new Head();
      else if (verb == "DELETE") request = new Delete();
      else if (verb == "PUT") request = new Put();
      else if (verb == "POST") request = new Post();
      else throw new ArgumentError("Invalid verb: " + verb);
        
      addCustomHeaders(request);
      if (verb == "PUT" || verb == "POST") addBody(request);
      
      client.request(new URI(uriInput.text), request);
    }
    
    /**
     * Add custom headers.
     */
    public function addCustomHeaders(request:HttpRequest):void {
      var headerToAdd:Array = [];
      var headerLines:Array = requestHeaderArea.text.split(/\r+/);
      for each(var headerLine:String in headerLines) {
        var index:int = headerLine.indexOf(":");
        if (index != -1) {
          var key:String = StringUtil.trim(headerLine.substring(0, index));
          var value:String = StringUtil.trim(headerLine.substr(index + 1));
          request.addHeader(key, value);
        }
      }      
    }

    /**
     * Add body.
     */    
    public function addBody(request:HttpRequest):void {
      var data:ByteArray = new ByteArray();
      data.writeUTFBytes(requestBodyArea.text);
      data.position = 0;  
          
      request.body = data;
    }
    
  }

}