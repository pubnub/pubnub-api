/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient {
  
  import com.adobe.utils.StringUtil;
  
  public class HttpHeader {
    
    private var _headers:Array;
    
    /**
     * Create header.
     * Initialize with headers, [ { name: "Name", value: "Value" }, ... ]
     */
    public function HttpHeader(headers:Array = null) {
      _headers = headers;
      if (!_headers) _headers = [];
    }
    
    /**
     * Add a header.
     * @param name
     * @param value
     */
    public function add(name:String, value:String):void {
      _headers.push({ name: name, value: value });
    }
    
    /**
     * Remove header.
     * @param name
     */
    public function remove(name:String):void {
      var index:int = indexOf(name);
      if (index != -1) _headers.splice(index, 1)
    }
    
    /**
     * Number of header (name, value) pairs.
     */
    public function get length():Number {
      return _headers.length;
    }
        
    /**
     * Check if we have any headers.
     */
    public function get isEmpty():Boolean { return _headers.length == 0; }
    
    /**
     * Get header value for name.
     * @param name
     * @return Value
     */
    public function getValue(name:String):String {
      var prop:Object = find(name);
      if (prop) return prop["value"];
      return null;
    }
    
    /**
     * Replace header, if set. (otherwise add)
     */
    public function replace(name:String, value:String):void {
      if (value == null) {
        remove(name);
        return;
      }
      
      var prop:Object = find(name);
      if (prop) prop["value"] = value;
      else add(name, value);
    }
    
    /**
     * Index of header.
     */
    public function indexOf(name:String):int {      
      for(var i:int = 0; i < _headers.length; i++) {
        if (_headers[i]["name"].toLowerCase() == name.toLowerCase()) return i;
      }
      return -1;
    }
    
    /**
     * Find header property. (Case insensitive)
     * @param name
     * @return Header property
     */
    public function find(name:String):Object {
      var index:int = indexOf(name);
      if (index != -1) return _headers[index];
      return null;
    }
    
    /**
     * Check if we have the name, value pair.
     * Case insensitive and trimmed.
     *  
     * @param name
     * @param value
     * @return True if the name with value pair exists
     */
    public function contains(name:String, value:String):Boolean {
      var prop:Object = find(name);
      if (!prop) return false;
      return StringUtil.trim(prop["value"].toLowerCase()) == value.toLowerCase();
    }
    
    /**
     * Get the header content for HTTP request.
     */
    public function get content():String {
      var data:String = "";
      
      for each(var prop:Object in _headers) 
        data += prop["name"] + ": " + prop["value"] + "\r\n";
      
      return data;
    }
    
    /**
     * To string.
     */
    public function toString():String {
      var arr:Array = [];
      for each(var prop:Object in _headers) 
        arr.push(prop["name"] + ": " + prop["value"]);
        
      return arr.join("\n");
    }
  }
}