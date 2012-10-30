/**
 * Copyright (c) 2007 Gabriel Handford
 * See LICENSE.txt for full license information.
 */
package org.httpclient {

  import flash.utils.Timer;
  import flash.events.TimerEvent;

  public class HttpTimer {
    
    private var _timer:Timer;
    
    // Timeout in millis 
    private var _timeout:Number = 1 * 60 * 1000;
    private var _lastSeen:Number = -1;
    
    private var _onTimeout:Function;
    
    /**
     * Timer.
     * @param timeout Timeout (in millis)
     * @param onTimeout onTimeout(time:Number)
     */
    public function HttpTimer(timeout:Number, onTimeout:Function) {
      if (timeout <= 0) throw new ArgumentError("Timeout should be specified in milliseconds greater than 0");
      
      if (timeout > 0) _timeout = timeout;
      _onTimeout = onTimeout;
      _timer = new Timer(1000);
      _timer.addEventListener(TimerEvent.TIMER, onTimer);
    }
    
    public function start():void {
      reset();
      _timer.start();
    }
    
    public function stop():void {
      _timer.stop();
    }
    
    public function reset():void {
      _lastSeen = new Date().time;
    }
    
    public function onTimer(event:TimerEvent):void {
      var idleTime:Number = now - _lastSeen;
      if (idleTime > _timeout) {
        _onTimeout(idleTime);
        reset();
      }
    }
    
    public function get now():Number {
      return new Date().time;
    }
    
  }

  
}