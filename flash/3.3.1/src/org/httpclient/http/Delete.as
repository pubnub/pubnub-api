/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient.http {
  
  import org.httpclient.HttpRequest;
  
  public class Delete extends HttpRequest {
    
    public function Delete() {      
      super("DELETE");
    }
    
    override public function get hasRequestBody():Boolean {
      return false;
    }
    
    override public function get hasResponseBody():Boolean {
      return true;
    }
        
  }
  
}