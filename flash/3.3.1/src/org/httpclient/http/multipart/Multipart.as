/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient.http.multipart {
  
  import flash.utils.ByteArray;
  
  public class Multipart {
    
    public static const BOUNDARY:String = "----------------314159265358979323846";
    
    private var _parts:Array = [];
    
    private var _footer:ByteArray;
    
    private var _partIndex:int = 0; // Index to current part
    private var _bytesSent:uint = 0; // Bytes sent for current part
    private var _footerSent:Boolean = false;
        
    /**
     * Create multipart.
     * @param parts Array of parts (Part)
     */
    public function Multipart(parts:Array) { 
      _parts = parts;
      _footer = footer();
    }
    
    /**
     * Get content length.
     * @return Content length
     */
    public function get length():uint {
      var length:uint = 0;
      for each(var part:Part in _parts) {
        length += part.length;
      }
      length += _footer.length;
      return length;
    }
    
    /**
     * Read available data from current part into specified byte array.
     * @param bytes Byte array to write into
     * @param offset Offset into array
     * @param length Number of bytes to read from current part
     */
    public function readBytes(bytes:ByteArray, offset:uint, length:uint):void {      
      if (!hasMoreParts) {
        if (!_footerSent) {
          _footer.readBytes(bytes, offset, length);
          _footerSent = true;
        }
        return;
      }
      
      currentPart.readBytes(bytes, offset, length);
      
      _bytesSent += bytes.length;
        
      // If no more payload, go to next part    
      if (_bytesSent >= currentPart.length) {                
        currentPart.close();
        _partIndex += 1;
        _bytesSent = 0;
      }
    }
    
    /**
     * Get number of bytes available in current part.
     * @return Number of bytes to read
     */
    public function get bytesAvailable():uint {
      if (hasMoreParts) return currentPart.bytesAvailable;
      else if (!_footerSent) return _footer.bytesAvailable;
      else return 0;
    }
    
    /**
     * Get current part for reading.
     * @return Current part
     */
    public function get currentPart():Part {
      if (!hasMoreParts) return null;
      return Part(_parts[_partIndex]);
    }
    
    /**
     * Check if have more parts for reading.
     * @return True if have parts left for reading, false otherwise
     */        
    protected function get hasMoreParts():Boolean {
      return _partIndex < _parts.length;
    }
        
    /**
     * Build footer
     * Example,
     *   --BOUNDARY--
     */
    protected function footer():ByteArray {
      var bytes:ByteArray = new ByteArray();
      bytes.writeUTFBytes("--" + Multipart.BOUNDARY + "--\r\n");
      bytes.position = 0;
      return bytes;
    }
    
    //
    // From apache httpclient, not using random boundary.
    //
    
    private static const BOUNDARY_CHARS:String = "-_1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";    
    
    /**
     * Generate random boundary (see java httpclient MultipartRequestEntity).
     * @return Random boundary
     */
    private static function generateBoundary():String {      
      var length:Number = Math.round(Math.random() * 10) * 30;
      var boundary:String = "";
      for(var i:Number = 0; i < length; i++) {
        var index:Number = Math.round(Math.random() * (BOUNDARY_CHARS.length - 1));
        boundary += BOUNDARY_CHARS.charAt(index);
      }
      return boundary;
    }
    
  }
}