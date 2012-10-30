/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient.io {
  
  import com.adobe.utils.StringUtil;
  import flash.utils.ByteArray;
  import org.httpclient.Log;
  
  public class HttpBuffer {
    
    protected var _data:ByteArray = new ByteArray();
    protected var _cursor:uint = 0; // Read position
    
    protected var _chunkLength:uint = 0; // Last chunk length
    
    public function HttpBuffer() { 
      super();
    }

    /**
     * Write bytes to this buffer. Appends data, does not rely on current position.
     */
    public function write(bytes:ByteArray):void {
      _data.position = _data.length;
      _data.writeBytes(bytes);      
      _data.position = _cursor;
    }
    
    /**
     * Read all data from the current position into the specified byte array.
     */
    public function read(bytes:ByteArray):void {
      _data.readBytes(bytes);
      _cursor = _data.position;      
    }
    
    /**
     * Get number of bytes available for reading.
     */
    public function get bytesAvailable():uint {
      return _data.bytesAvailable;
    }
    
    /**
     * Read all available bytes.
     */
    public function readAvailable():ByteArray {
      var bytes:ByteArray = new ByteArray();
      read(bytes);
      bytes.position = 0;
      return bytes;
    }
    
    /**
     * Read a line from the buffer.
     * @return Next line, or null if there was no newline character found.
     */
    public function readLine(trim:Boolean = false):String {    
      if (_data.bytesAvailable == 0) return null;
      
      var start:uint = _data.position;
      var bytes:ByteArray = new ByteArray();
      var foundLine:Boolean = false;
      
      while(_data.bytesAvailable > 0) {
        var char:int = _data.readByte();
        bytes.writeByte(char);
        // Char code 10 == '\n'
        if (char == 10) {
          foundLine = true;
          break; 
        }
      }
      
      var line:String = null;
      if (foundLine) {
        bytes.position = 0;
        line = bytes.readUTFBytes(bytes.length);                 
        _cursor = _data.position;
        return trim ? StringUtil.rtrim(line) : line;        
      } else {
        // If no newline, then set the position to the original cursor position
        _data.position = _cursor;
        return null;
      }
      
    }
            
    /**
     * Take bytes from current position to the end, and put them into new byte array.
     */
    public function truncate():void {
      var nextData:ByteArray = new ByteArray();
      if (_data.bytesAvailable) _data.readBytes(nextData);
      _data = nextData;
      _cursor = 0;
    }
    
    /**
     * Read chunked encoding.
     * @param onData For each chunk, call function(bytes:ByteArray)
     * @return True if done, and no more chunks, false if there is more data to expect.
     *  
     * TODO: Footers...
     */
    public function readChunks(onData:Function):Boolean {
      
      while(_data.bytesAvailable > 0) {
        
        if (_chunkLength == 0) { 
          var line:String = readLine();
          if (!line)
            throw new Error("No data available");
          
          var match:Array = line.match(/\A([0-9a-fA-F]+).*/);
          if (!match) {
            throw new Error("Invalid chunk; trying to find chunk length at line: " + line);
          }

          var hexlen:String = match[1];
          //Log.debug("Found hex length: " + hexlen);
          var length:Number = parseInt(hexlen, 16);
          Log.debug("Chunk size: " + length);
          if (length <= 0) return true;
          _chunkLength = length;
        }
        
        if (_data.bytesAvailable >= (_chunkLength + 2)) {          
          var bytes:ByteArray = new ByteArray();  
          _data.readBytes(bytes, 0, _chunkLength);             
          Log.debug("Read chunk size: " + _chunkLength);
          _data.position += 2; // Skip CRLF
          _cursor = _data.position;
          _chunkLength = 0;
          onData(bytes);          
        } else {
          // Back it up, copy the bytes subset into new array (to save memory) and break out
          truncate();
          return false;
        }
      }
      
      return false;
    }

  }
  
}