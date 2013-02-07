package com.pubnub.net {
import com.adobe.net.*;
import com.hurlant.crypto.tls.TLSSocket;
import com.pubnub.log.Log;
import com.pubnub.net.URLResponse;

import flash.errors.IOError;
import flash.events.*;
import flash.net.Socket;
import flash.utils.*;

import org.httpclient.HttpHeader;

/**
 * ...
 * @author firsoff maxim, firsoffmaxim@gmail.com, icq : 235859730
 */
[Event(name="URLLoaderEvent.complete", type="com.pubnub.net.URLLoaderEvent")]
[Event(name="URLLoaderEvent.error", type="com.pubnub.net.URLLoaderEvent")]
public class URLLoader extends EventDispatcher {

    public static const HTTP_PORT:uint = 80;
    public static const HTTPS_PORT:uint = 443;
    public static const HTTP_VERSION:String = "1.1";
    public static const END_LINE:String = '\r\n';


    public static const END_SYMBOL_CHUNKED:String = '0\r\n';
    public static const END_SYMBOL:String = '\r\n';
    static private const pattern:RegExp = new RegExp("(https):\/\/");

    protected var socket:*;
    protected var secureSocket:TLSSocket;
    protected var normalSocket:Socket;
    protected var uri:URI;
    protected var request:URLRequest;

    protected var _response:URLResponse;
    protected var _headers:Array;

    protected var _contentEncoding:String;
    private var _isChunked:Boolean;
    private var _responseInProgress:Boolean;
    private var _socketStarted:Boolean;

    protected var answer:ByteArray = new ByteArray();
    protected var temp:ByteArray = new ByteArray();


    protected var _destroyed:Boolean;

    public function URLLoader() {
        super(null);
        init();
    }

    public function load(request:URLRequest):void {
        this.request = request;
        uri = new URI(request.url);
        //trace(request.url);
        socket = getSocket(request.url);
        destroyRESPONSE();
        sendRequest(request);
        Log.logURL('REQUEST: ' + unescape(request.url), Log.DEBUG);
    }

    private function getSocket(url:String):* {
        return pattern.test(url) ? secureSocket : normalSocket;
    }

    private function getPort(url:String):* {
        return pattern.test(url) ? HTTPS_PORT : HTTP_PORT;
    }

    public function connect(request:URLRequest):void {
        if (!request) return;
        var url:String = request.url;
        var uri:URI = new URI(url);
        var host:String = uri.authority;
        //trace(host);
        var port:int = getPort(url);
        socket = getSocket(url);
        //trace('connect : ' + host, port, socket);
        //Security.loadPolicyFile("xmlsocket://pubsub.pubnub.com:80");
        socket.connect(host, port);
    }

    public function close():void {
        //trace('*CLOSE* ' + socket);
        try {
            if (normalSocket.connected) normalSocket.close();
        } catch (err:IOError) {
            Log.log("Close: " + err, Log.WARNING);
        }

        try {
            if (socket == secureSocket && secureSocket.connected) {
                secureSocket.close();
            }
        } catch (err:IOError) {
            Log.log("Close: " + err, Log.WARNING);
        }
        destroyRESPONSE();
        request = null;
    }

    protected function init():void {
        normalSocket = new Socket();
        normalSocket.addEventListener(Event.CONNECT, onConnect);
        normalSocket.addEventListener(Event.CLOSE, onClose);
        normalSocket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        normalSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
        normalSocket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);

        secureSocket = new TLSSocket();
        secureSocket.addEventListener(Event.CONNECT, onConnect);
        secureSocket.addEventListener(Event.CLOSE, onClose);
        secureSocket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        secureSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
        secureSocket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);

        socket = normalSocket;
    }

    // When we get socket data. Fire ONResponse() when the response has been complete.
    // We determine if its complete by either Content-size or Chunked strategies.

    protected function onSocketData(e:ProgressEvent):void {

        Log.log("Entering onSocketData: " + e, Log.DEBUG);

        //trace('------onSocketData------' + socket.bytesAvailable);
        temp.clear();
        Log.log("onSocketData start", Log.DEBUG);

        while (socketHasData()) {
            try {
                // Load data from socket
                socket.readBytes(temp);
                temp.readBytes(answer, answer.bytesAvailable);
            } catch (e:Error) {
                Log.log("onSocketData error: " + e, Log.DEBUG);
                break;
            }

            _socketStarted = true;
        }

        Log.log("onSocketData end", Log.DEBUG);

        temp.position = 0;
        var tempStr:String = temp.readUTFBytes(temp.bytesAvailable);

        Log.log("THE DATA: " + tempStr, Log.DEBUG);

        if (_responseInProgress == false) {
            Log.log("Getting headers", Log.DEBUG);
            _headers = URLResponse.getHeaders(tempStr);
            Log.log("Setting responseInProgress to TRUE", Log.DEBUG);
            _responseInProgress = true;

        }

        if (_headers && (_headers != [])) {
            Log.log("Headers are present:", Log.DEBUG);
            Log.log(_headers.toString(), Log.DEBUG);
            _responseInProgress = true;

            if (URLResponse.isChunked(_headers)) {
                _contentEncoding = "chunked";
                Log.log("Setting to chunked", Log.DEBUG);
            } else {
                _contentEncoding = "cl";
                Log.log("Setting to CL", Log.DEBUG);
            }
        } else {
            Log.log("Headers are not present.", Log.DEBUG);
        }

        // 2. Based on the headers, do we have the start and the end?

        if (_contentEncoding == "chunked") {
            if (tempStr.match(END_SYMBOL_CHUNKED)) {
                Log.log("Transfer completed: CHUNKED", Log.DEBUG);
                _responseInProgress = false;
            }
        } else if (_contentEncoding == "cl") {
            if (tempStr.match(END_SYMBOL)) {   // Be sure to match on content-length size
                Log.log("Transfer completed: CL", Log.DEBUG);
                _responseInProgress = false;
            }
        }

        if (!_responseInProgress) {
            Log.log("Firing onResponse!", Log.DEBUG);
            onRESPONSE(answer)
            answer.clear();
        } else {
            Log.log("Transfer in progress.", Log.DEBUG);
        }

    }



    protected function onRESPONSE(bytes:ByteArray):void {
        try {
            if (request) {
                _response = new URLResponse(bytes, request);
                //trace(_response.body);
                Log.log('RESPONSE: ' + _response.body, Log.DEBUG);
            }
            //trace('onRESPONSE : ' + _response.body);
            dispatchEvent(new URLLoaderEvent(URLLoaderEvent.COMPLETE, _response));
        } catch (err:Error) {
            dispatchEvent(new URLLoaderEvent(URLLoaderEvent.ERROR, _response));
        }
    }

    protected function socketHasData():Boolean {
        return (socket && socket.connected && socket.bytesAvailable);
    }

    protected function onSecurityError(e:SecurityErrorEvent):void {
        // abstract
        dispatchEvent(new URLLoaderEvent(URLLoaderEvent.ERROR, request));
    }

    protected function onIOError(e:IOErrorEvent):void {
        // abstract
        dispatchEvent(new URLLoaderEvent(URLLoaderEvent.ERROR, request));
    }

    protected function onClose(e:Event):void {
        //trace(socket, ' onClose');
        dispatchEvent(e);
    }

    protected function onConnect(e:Event):void {
        //trace(this, ' onConnect', socket);
        dispatchEvent(e);
    }

    public function get ready():Boolean {
        return socket && socket.connected;
    }

    public function get connected():Boolean {
        return socket && socket.connected;
    }

    private function destroyRESPONSE():void {
        if (_response) {
            _response.destroy();
            _response = null;
        }
    }

    public function destroy():void {
        if (_destroyed) return;
        _destroyed = true;
        close()
        normalSocket.removeEventListener(Event.CONNECT, onConnect);
        normalSocket.removeEventListener(Event.CLOSE, onClose);
        normalSocket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
        normalSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
        normalSocket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);


        secureSocket.removeEventListener(Event.CONNECT, onConnect);
        secureSocket.removeEventListener(Event.CLOSE, onClose);
        secureSocket.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
        secureSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
        secureSocket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
        socket = null;
        temp.clear();
        answer.clear();
        temp = answer = null;
        request = null;
    }

    /**
     * Send request.
     * @param request Request to write
     */
    protected function sendRequest(request:URLRequest):void {
        if (ready) {
            doSendRequest(request);
        } else {
            connect(request);
        }
    }

    protected function doSendRequest(request:URLRequest):void {
        //trace('doSendRequest');
        var requestBytes:ByteArray = request.toByteArray();
        requestBytes.position = 0;
        // Debug
        var hStr:String = "Header:\n" + requestBytes.readUTFBytes(requestBytes.length);
        //trace('socket.connected : ' + socket.connected);
        Log.log(Log.DEBUG, "Request Header:\n" + hStr);
        socket.writeBytes(requestBytes);
        socket.flush();
    }


    public function get destroyed():Boolean {
        return _destroyed;
    }

    public function get response():URLResponse {
        return _response;
    }


}
}