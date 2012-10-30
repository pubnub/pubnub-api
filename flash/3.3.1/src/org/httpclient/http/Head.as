/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient.http {
  
  import org.httpclient.HttpRequest;
  
  public class Head extends HttpRequest {
    
    public function Head() {      
      super("HEAD");
    }
    
    override public function get hasRequestBody():Boolean {
      return false;
    }
    
    override public function get hasResponseBody():Boolean {
      return false;
    }
        
  }
  
}