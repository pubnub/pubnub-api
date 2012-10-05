package {
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.Timer;

public class URLLoaderDeluxe extends URLLoader {
    private var _timeoutTimer:Timer;
    public var timeout:Number; // default timeout value

    public static const TIMEOUT:String = 'loaderTimeout';

    [Event(name="loaderTimeout", type="flash.events.Event")]

    public function URLLoaderDeluxe(timeout:Number = 1000, request:URLRequest = null) {
        this.timeout = timeout;
        _timeoutTimer = new Timer(timeout);
        super(request);
    }

    override public function load(request:URLRequest):void {
        _timeoutTimer.addEventListener(TimerEvent.TIMER, handleTimeout);
        _timeoutTimer.delay = timeout;

        addEventListener(IOErrorEvent.IO_ERROR, handleLoadActivity);
        addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadActivity);
        addEventListener(Event.COMPLETE, handleLoadActivity);
        addEventListener(ProgressEvent.PROGRESS, handleLoadActivity);
        addEventListener(Event.OPEN, handleLoadActivity);

        super.load(request);
        _timeoutTimer.start();
    }

    override public function close():void {
        killTimer();
        super.close();
    }

    private function handleLoadActivity(event:Event):void {
        killTimer();
    }

    private function killTimer(event:Event = null):void {
        removeEventListener(IOErrorEvent.IO_ERROR, handleLoadActivity);
        removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadActivity);
        removeEventListener(Event.COMPLETE, handleLoadActivity);
        removeEventListener(ProgressEvent.PROGRESS, handleLoadActivity);
        removeEventListener(Event.OPEN, handleLoadActivity);

        _timeoutTimer.reset();
        _timeoutTimer.removeEventListener(TimerEvent.TIMER, handleTimeout);

        if (event)
            super.dispatchEvent(event.clone());
    }

    private function handleTimeout(event:TimerEvent):void {
        killTimer();
        super.dispatchEvent(new Event(TIMEOUT, true));
//                      this.dispatchEvent(new Event(TIMEOUT, true));
//                      var dis:EventDispatcher = new EventDispatcher(this);
//                      dis.dispatchEvent(new Event(TIMEOUT, true));
    }
}
}
