/**
 * TLSTest
 * 
 * A test class for TLS. Not a finished product.
 * Copyright (c) 2007 Henri Torgemane
 * 
 * See LICENSE.txt for full license information.
 */
package com.hurlant.crypto.tls {
	import flash.net.Socket;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import com.hurlant.util.Hex;
	import flash.events.Event;
	import flash.utils.getTimer;
	import com.hurlant.crypto.cert.X509CertificateCollection;
	import com.hurlant.crypto.cert.X509Certificate;
	import com.hurlant.util.der.PEM;
	
	public class TLSTest {
		
		[Embed(source="/certs/host.cert",mimeType="application/octet-stream")]
		public var myCert:Class;
		[Embed(source="/certs/host.key",mimeType="application/octet-stream")]
		public var myKey:Class;
		
		public function TLSTest() {
			//loopback();
			//connectLoginYahooCom();
			testSocket();
		}
		
		public function connectLoginYahooCom():void {
			var s:Socket = new Socket("login.yahoo.com", 443);
			
			var clientConfig:TLSConfig = new TLSConfig(TLSEngine.CLIENT);
			
			var client:TLSEngine = new TLSEngine(clientConfig, s, s);
			// hook some events.
			s.addEventListener(ProgressEvent.SOCKET_DATA, client.dataAvailable);
			client.addEventListener(ProgressEvent.SOCKET_DATA, function(e:*):void { s.flush(); });
			
			client.start();
		}
		
		public function loopback():void {
			
			var server_write:ByteArray = new ByteArray;
			var client_write:ByteArray = new ByteArray;
			var server_write_cursor:uint = 0;
			var client_write_cursor:uint = 0;
			
			var clientConfig:TLSConfig = new TLSConfig(TLSEngine.CLIENT);
			var serverConfig:TLSConfig = new TLSConfig(TLSEngine.SERVER);

			var cert:ByteArray = new myCert;
			var key:ByteArray = new myKey;
			serverConfig.setPEMCertificate(cert.readUTFBytes(cert.length), key.readUTFBytes(key.length));
			// tmp, for debugging. currently useless
			cert.position = 0;
			key.position = 0;
			clientConfig.setPEMCertificate(cert.readUTFBytes(cert.length), key.readUTFBytes(key.length));
			// put the server cert in the client's trusted store, to keep things happy.
			clientConfig.CAStore = new X509CertificateCollection;
			cert.position = 0;
			var x509:X509Certificate = new X509Certificate(PEM.readCertIntoArray(cert.readUTFBytes(cert.length)));
			clientConfig.CAStore.addCertificate(x509);

			var server:TLSEngine = new TLSEngine(serverConfig, client_write, server_write);
			var client:TLSEngine = new TLSEngine(clientConfig, server_write, client_write);
			
			server.addEventListener(ProgressEvent.SOCKET_DATA, function(e:*=null):void {
				trace("server wrote something!");
				trace(Hex.fromArray(server_write));
				var l:uint = server_write.position;
				server_write.position = server_write_cursor;
				client.dataAvailable(e);
				server_write.position = l;
				server_write_cursor = l;
			});
			client.addEventListener(ProgressEvent.SOCKET_DATA, function(e:*=null):void {
				trace("client wrote something!");
				trace(Hex.fromArray(client_write));
				var l:uint = client_write.position;
				client_write.position = client_write_cursor;
				server.dataAvailable(e);
				client_write.position = l;
				client_write_cursor = l;
			});
			
			server.start();
			client.start();
		}
		
		public function testSocket():void {
			var hosts:Array = [
				"bugs.adobe.com",			// apache
				"login.yahoo.com",  		// apache, bigger response
				"login.live.com",			// IIS-6, chain of 3 certs
				"banking.wellsfargo.com",	// custom, sends its CA cert along for the ride.
				"www.bankofamerica.com"		// sun-one, chain of 3 certs
			];
			var i:int =0;
			(function next():void {
				testHost(hosts[i++], next);
			})();
		}
		private function testHost(host:String, next:Function):void {
			if (host==null) return;
			var t1:int = getTimer();
			var host:String = host;
			var t:TLSSocket = new TLSSocket;
			t.connect(host, 443); 
			t.writeUTFBytes("GET / HTTP/1.0\nHost: "+host+"\n\n");
			t.addEventListener(Event.CLOSE, function(e:*):void {
				var s:String = t.readUTFBytes(t.bytesAvailable);
				trace("Response from "+host+": "+s.length+" characters");
				trace("Time used = "+(getTimer()-t1)+"ms");
				next();
			});
		}
	}
}