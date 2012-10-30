/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient.http.multipart {
  
  import flash.utils.ByteArray;
  
  public class Part {
        
    private var _name:String;
    private var _contentType:String;        
    private var _contentTransferEncoding:String;
    private var _contentDispositionExtras:Array;
    
    private var _header:ByteArray;
    private var _payload:*;
    private var _footer:ByteArray;
    
    /**
     * Create part section.
     *  
     * @param payload
     * @param contentType
     * @param contentDispositionExtras Extra parameters for content disposition [ { name:"filename", value:"foo.txt" }, ...]
     * @param contentTransferEncoding
     *  
     */
    public function Part(name:String, payload:*, contentType:String = null, 
      contentDispositionExtras:Array = null, contentTransferEncoding:String = null) { 
      
      // Convert payload to UTF bytes if its a String
      if (payload is String) {
        var stringBytes:ByteArray = new ByteArray();
        stringBytes.writeUTFBytes(payload);
        stringBytes.position = 0;
        payload = stringBytes;        
      }
      
      _name = name;
      _payload = payload;
      _contentType = contentType;
      _contentDispositionExtras = contentDispositionExtras;
      _contentTransferEncoding = contentTransferEncoding;
      
      _header = header();
      _footer = footer();
    }
    
    /**
     * Get bytes.
     * @return Next bytes
     */
    private function get nextBytes():* {
      if (_header.bytesAvailable > 0) return _header;      
      else if (_payload.bytesAvailable > 0) return _payload;
      else if (_footer.bytesAvailable > 0) return _footer;      
      else throw Error("Nothing left for part");
    }
    
    /**
     * Read available data from payload into byte array.
     * @param bytes Byte array to write into
     * @param offset Offset into array
     * @param length Number of bytes to read
     */
    public function readBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0):void {      
      if (nextBytes.bytesAvailable > 0) {
        length = Math.min(length, nextBytes.bytesAvailable);
        nextBytes.readBytes(bytes, offset, length);
      }
    }
    
    /**
     * Get bytes available in part.
     * @return Bytes available
     */
    public function get bytesAvailable():uint {
      return nextBytes.bytesAvailable;
    }
    
    /**
     * Get part content length.
     * @return Content length for this part
     */
    public function get length():uint {
      return _payload.length + _header.length + _footer.length;
    }
        
    /**
     * Close payload.
     */
    public function close():void {
      if (!(_payload is ByteArray)) _payload.close(); // TODO: Can we check responds to?
    }
        
    /**
     * Build header.
     *  
     * Example,
     *   --BOUNDARY
     *   Content-Disposition: form-data; name="field1"
     *
     *   <payload>
     *
     * Or, 
     *   --BOUNDARY
     *   Content-Disposition: form-data; name="userfile"; filename="$filename"
     *   Content-Type: $mimetype
     *   Content-Transfer-Encoding: binary
     * 
     *   <payload>
     * @return Header as byte array
     */
    protected function header():ByteArray {
      var bytes:ByteArray = new ByteArray();
      
      // Boundary
      bytes.writeUTFBytes("--" + Multipart.BOUNDARY + "\r\n");
      
      // Content disposition
      bytes.writeUTFBytes("Content-Disposition: form-data; ");
      if (_name) bytes.writeUTFBytes("name=\"" + _name + "\"")
      
      if (_contentDispositionExtras)
        _contentDispositionExtras.forEach(function(param:*, index:int, array:Array):void {
          bytes.writeUTFBytes("; " + param.name + "=\"" + param.value + "\"");
        });
      
      bytes.writeUTFBytes("\r\n");
      
      // Content type
      if (_contentType) bytes.writeUTFBytes("Content-Type: " + _contentType + "\r\n");
      
      // Content transfer encoding
      if (_contentTransferEncoding) bytes.writeUTFBytes("Content-Transfer-Encoding: " + _contentTransferEncoding + "\r\n");
      
      // Empty line      
      bytes.writeUTFBytes("\r\n");

      // DEBUG
      //bytes.position = 0;
      //var data:String = bytes.readUTFBytes(bytes.length);
      //Log.debug("='" + data + "'");      
            
      bytes.position = 0;
      
      return bytes;
    }
    
    /**
     * Part footer.
     * @return CRLF
     */
    protected function footer():ByteArray {
      var bytes:ByteArray = new ByteArray();
      bytes.writeUTFBytes("\r\n");
      bytes.position = 0;      
      return bytes;
    }
  }
        
}