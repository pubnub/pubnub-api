/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient.io {

  import flash.filesystem.FileStream;
  import flash.filesystem.File;
  import flash.filesystem.FileMode;

  public class HttpFileStream extends FileStream {
    
    private var _length:uint; // File size
    
    public function HttpFileStream(length:uint) {
      super();
      _length = length;
    }
  
    public function get length():uint {
      return _length;
    }
    
    /**
     * Create filestream for reading file.
     * @param file (Should be flash.filesystem.File; Not typed for compatibility with Flash)
     */
    public static function readFile(file:*):HttpFileStream {
      var stream:HttpFileStream = new HttpFileStream(file.size);
      stream.open(file, FileMode.READ);
      return stream;
    }
    
  }
  
}