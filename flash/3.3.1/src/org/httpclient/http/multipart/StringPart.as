/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient.http.multipart {
  
  public class StringPart extends Part {
        
    /**
     * Create string name, value part.
     * @param name
     * @param value
     */
    public function StringPart(name:String, value:String) {
      super(name, value);
    }
    
  }
}
