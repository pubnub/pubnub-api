/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient.http.multipart {
  
  import flash.filesystem.File;
  import org.httpclient.io.HttpFileStream;
  
  public class FilePart extends Part {
    
    /**
     * Create file part.
     * @param file File
     * @param contentType Content type
     */
    public function FilePart(file:File, contentType:String = "application/octet-stream") {      
      super("file", HttpFileStream.readFile(file), contentType, [ { name:"filename", value:file.name } ], "binary");
    }
    
  }
  
  
}