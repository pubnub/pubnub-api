/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient.io {
  
  import com.adobe.utils.StringUtil;
  import flash.utils.ByteArray;
  
  public class HttpRequestBuffer {
       
    private var _body:*;
    
    private var _bytesSent:uint = 0;
    
    private static const BLOCK_SIZE:uint = 16 * 1024;
    
    /**
     * Create request buffer.
     */   
    public function HttpRequestBuffer(body:*) {
      _body = body;
    }
    
    public function get bytesSent():uint { return _bytesSent; }
    
    public function get hasData():Boolean { 
      if (!_body) return false;
      return _bytesSent < _body.length; 
    }
    
    /**
     * Get data for request body.
     * @return Bytes, or null if end was reached.
     */
    public function read():ByteArray {      
      var bytes:ByteArray = new ByteArray();    
      if (_body.bytesAvailable > 0) {
        var length:uint = Math.min(BLOCK_SIZE, _body.bytesAvailable);
        _body.readBytes(bytes, 0, length);      
        bytes.position = 0;
        _bytesSent += bytes.length;        
      }
      
      return bytes;
    }
   
    
  }
}