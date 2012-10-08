/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient {
  
  /**
   * HTTP Response.
   */  
  public class HttpResponse {
        
    private var _version:String;
    private var _code:String;
    private var _message:String;
    private var _header:HttpHeader;            
        
    public function HttpResponse(version:String, code:String, message:String, header:HttpHeader) {
      _version = version;
      _code = code;
      _message = message;
      _header = header;
    }
    
    // Header
    public function get header():HttpHeader { return _header; }
    
    // HTTP result code string. For example, '302'
    public function get code():String { return _code; }
    
    // HTTP result message. For example, 'Not Found'
    public function get message():String { return _message; }
    
    // The HTTP version supported by the server
    public function get version():String { return _version; }
    
    public function get isInformation():Boolean { return _code.search(/\A1\d\d/) != -1; } // 1xx
    public function get isSuccess():Boolean { return _code.search(/\A2\d\d/) != -1; } // 2xx
    public function get isRedirection():Boolean { return _code.search(/\A3\d\d/) != -1; } // 3xx
    public function get isClientError():Boolean { return _code.search(/\A4\d\d/) != -1; } // 4xx
    public function get isServerError():Boolean { return _code.search(/\A5\d\d/) != -1; } // 5xx
    
    /**
     * Get content length.
     * @return contentLength or -1 if content length was not available
     */
    public function get contentLength():Number {
      var lengthString:String = _header.getValue("Content-Length");
      if (!lengthString) return -1;
      return parseInt(lengthString);
    }
    
    public function get isChunked():Boolean {
      return _header.contains("Transfer-Encoding", "Chunked");
    }
    
    /**
     * To string.
     */
    public function toString():String {
      return "version: " + _version + ", code: " + _code + ", message: " + _message + "\nheader:\n" + _header + "\n--\n";
    }
    
  }
}