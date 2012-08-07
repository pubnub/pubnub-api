/**
 * TLSEngine
 * 
 * A TLS protocol implementation.
 * See comment below for some details.
 * Copyright (c) 2007 Henri Torgemane
 * 
 * See LICENSE.txt for full license information.
 */
package com.hurlant.crypto.tls {
	import com.hurlant.crypto.cert.X509Certificate;
	import com.hurlant.crypto.cert.X509CertificateCollection;
	import com.hurlant.crypto.prng.Random;
	import com.hurlant.util.ArrayUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	[Event(name="close", type="flash.events.Event")]
	[Event(name="socketData", type="flash.events.ProgressEvent")]
	[Event(name="ready", type="com.hurlant.crypto.tls.TLSEvent")]
	[Event(name="data", type="com.hurlant.crypto.tls.TLSEvent")]
	
	/**
	 * The heart of the TLS protocol.
	 * This class can work in server or client mode.
	 * 
	 * This doesn't fully implement the TLS protocol.
	 * 
	 * Things missing that I'd like to add:
	 * - support for client-side certificates
	 * - general code clean-up to make sure we don't have gaping securite holes
	 * 
	 * Things that aren't there that I won't add:
	 * - support for "export" cypher suites (deprecated in later TLS versions)
	 * - support for "anon" cypher suites (deprecated in later TLS versions)
	 * 
	 * Things that I'm unsure about adding later:
	 * - compression. Compressing encrypted streams is barely worth the CPU cycles.
	 * - diffie-hellman based key exchange mechanisms. Nifty, but would we miss it?
	 * 
	 * @author henri
	 * 
	 */
	public class TLSEngine extends EventDispatcher {
		
		public static const SERVER:uint = 0;
		public static const CLIENT:uint = 1;

		public static const TLS_VERSION:uint = 0x0301;
		
		private static const PROTOCOL_HANDSHAKE:uint = 22;
		private static const PROTOCOL_ALERT:uint = 21;
		private static const PROTOCOL_CHANGE_CIPHER_SPEC:uint = 20;
		private static const PROTOCOL_APPLICATION_DATA:uint = 23;

		private static const STATE_NEW:uint = 0; // brand new. nothing happened yet
		private static const STATE_NEGOTIATING:uint = 1; // we're figuring out what to use
		private static const STATE_READY:uint = 2; // we're ready for AppData stuff to go over us.
		private static const STATE_CLOSED:uint = 3; // we're done done.
		
		private var _entity:uint; // SERVER | CLIENT
		private var _config:TLSConfig;
		
		private var _state:uint;
		
		private var _securityParameters:TLSSecurityParameters;
		
		private var _currentReadState:TLSConnectionState;
		private var _currentWriteState:TLSConnectionState;
		private var _pendingReadState:TLSConnectionState;
		private var _pendingWriteState:TLSConnectionState;
		
		private var _handshakePayloads:ByteArray;
		
		private var _iStream:IDataInput;
		private var _oStream:IDataOutput;
		
		// temporary store for X509 certs received by this engine.
		private var _store:X509CertificateCollection;
		// the main certificate received from the other side.
		private var _otherCertificate:X509Certificate;
		// If this isn't null, we expect this identity to be found in the Cert's Subject CN.
		private var _otherIdentity:String;
		
		/**
		 * 
		 * @param config		A TLSConfig instance describing how we're supposed to work
		 * @param iStream		An input stream to read TLS data from
		 * @param oStream		An output stream to write TLS data to
		 * @param otherIdentity	An optional identifier. If set, this will be checked against the Subject CN of the other side's certificate.
		 * 
		 */
		function TLSEngine(config:TLSConfig, iStream:IDataInput, oStream:IDataOutput, otherIdentity:String = null) {
			_entity = config.entity;
			_config = config;
			_iStream = iStream;
			_oStream = oStream;
			_otherIdentity = otherIdentity;
			
			_state = STATE_NEW;
			
			_securityParameters = new TLSSecurityParameters(_entity);
			var states:Object = _securityParameters.getConnectionStates();
			_currentReadState = states.read;
			_currentWriteState = states.write;
			
			_handshakePayloads = new ByteArray;
			
			_store = new X509CertificateCollection;
		}
		
		/**
		 * This starts the TLS negotiation for a TLS Client.
		 * 
		 * This is a no-op for a TLS Server.
		 * 
		 */
		public function start():void {
			if (_entity == CLIENT) {
				try {
					startHandshake();
				} catch (e:TLSError) {
					handleTLSError(e);
				}
			}
		}
		
		
		public function dataAvailable(e:* = null):void {
			if (_state == STATE_CLOSED) return; // ignore
			try {
				parseRecord(_iStream);
			} catch (e:TLSError) {
				handleTLSError(e);
			}
		}
		
		public function close(e:TLSError = null):void {
			if (_state == STATE_CLOSED) return; // ignore
			// ok. send an Alert to let the peer know
			var rec:ByteArray = new ByteArray;
			if (e==null && _state != STATE_READY) {
				// use canceled while handshaking. be nice about it
				rec[0] = 1;
				rec[1] = TLSError.user_canceled;
				sendRecord(PROTOCOL_ALERT, rec);
			}
			rec[0] = 2;
			if (e == null) {
				rec[1] = TLSError.close_notify;
			} else {
				rec[1] = e.errorID;
				trace("TLSEngine shutdown triggered by "+e);
			}
			sendRecord(PROTOCOL_ALERT, rec);

			_state = STATE_CLOSED;
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private var _packetQueue:Array = [];
		private function parseRecord(stream:IDataInput):void {
			var p:ByteArray;
			while(_state!=STATE_CLOSED && stream.bytesAvailable>4) {
				
				if (_packetQueue.length>0) {
					var packet:Object = _packetQueue.shift();
					p = packet.data;
					if (stream.bytesAvailable+p.length>=packet.length) {
						// we have a whole packet. put together.
						stream.readBytes(p, p.length, packet.length-p.length);
						parseOneRecord(packet.type, packet.length, p);
						// do another loop to parse any leftover record
						continue;
					} else {
						// not enough. grab the data and park it.
						stream.readBytes(p, p.length, stream.bytesAvailable);
						_packetQueue.push(packet);
						continue;
					}
				}

				var type:uint = stream.readByte();
				var ver:uint = stream.readShort();
				var length:uint = stream.readShort();
				if (length>16384+2048) { // support compression and encryption overhead.
					throw new TLSError("Excessive TLS Record length: "+length, TLSError.record_overflow);
				}
				if (ver != TLS_VERSION) {
					throw new TLSError("Unsupported TLS version: "+ver.toString(16), TLSError.protocol_version);
				}
				if (stream.bytesAvailable<length) {
					
				}
				p = new ByteArray;
				var actualLength:uint = Math.min(stream.bytesAvailable, length);
				stream.readBytes(p, 0, actualLength);
				if (actualLength == length) {
					parseOneRecord(type, length, p);
				} else {
					_packetQueue.push({type:type, length:length, data:p});
				}
			}
		}
		
		private function parseOneRecord(type:uint, length:uint, p:ByteArray):void {
			p = _currentReadState.decrypt(type, length, p);
			if (p.length>16384) { 
				throw new TLSError("Excessive Decrypted TLS Record length: "+p.length, TLSError.record_overflow);
			}
			switch (type) {
				case PROTOCOL_APPLICATION_DATA:
					if (_state == STATE_READY) {
						parseApplicationData(p);
					} else {
						throw new TLSError("Too soon for data!", TLSError.unexpected_message);
					}
					break;
				case PROTOCOL_HANDSHAKE:
					while (p!=null) {
						p = parseHandshake(p);
					}
					break;
				case PROTOCOL_ALERT:
					parseAlert(p);
					break;
				case PROTOCOL_CHANGE_CIPHER_SPEC:
					parseChangeCipherSpec(p);
					break;
				default:
					throw new TLSError("Unsupported TLS Record Content Type: "+type.toString(16), TLSError.unexpected_message);
			}
		}
		
		///////// handshake handling
		// session identifier
		// peer certificate
		// compression method
		// cipher spec
		// master secret
		// is resumable
		private static const HANDSHAKE_HELLO_REQUEST:uint = 0;
		private static const HANDSHAKE_CLIENT_HELLO:uint = 1;
		private static const HANDSHAKE_SERVER_HELLO:uint = 2;
		private static const HANDSHAKE_CERTIFICATE:uint = 11;
		private static const HANDSHAKE_SERVER_KEY_EXCHANGE:uint = 12;
		private static const HANDSHAKE_CERTIFICATE_REQUEST:uint = 13;
		private static const HANDSHAKE_HELLO_DONE:uint = 14;
		private static const HANDSHAKE_CERTIFICATE_VERIFY:uint = 15;
		private static const HANDSHAKE_CLIENT_KEY_EXCHANGE:uint = 16;
		private static const HANDSHAKE_FINISHED:uint = 20;

		/**
		 * The handshake is always started by the client.
		 * 
		 */
		private function startHandshake():void {
			_state = STATE_NEGOTIATING;
			// reset some other handshake state. XXX
			sendClientHello();
		}
		
		private function parseHandshake(p:ByteArray):ByteArray {
			if (p.length<4) {
				trace("Handshake packet is way too short. bailing.");
				return null;
			}
			
			p.position = 0;
			
			var rec:ByteArray = p;
			var type:uint = rec.readUnsignedByte();
			var tmp:uint = rec.readUnsignedByte();
			var length:uint = (tmp<<16) | rec.readUnsignedShort();
			if (length+4>p.length) {
				// partial read.
				trace("Handshake packet is incomplete. bailing.");
				return null;
			}

			// we need to copy the record, to have a valid FINISHED exchange.
			if (p[0]!=HANDSHAKE_FINISHED) {
				_handshakePayloads.writeBytes(p, 0, length+4);
			}
			
			switch (type) {
				case HANDSHAKE_HELLO_REQUEST:
					if (!enforceClient()) break;
					if (_state != STATE_READY) {
						trace("Received an HELLO_REQUEST before being in state READY. ignoring.");
						break;
					}
					_handshakePayloads = new ByteArray;
					startHandshake();
					break;
				case HANDSHAKE_CLIENT_HELLO:
					if (!enforceServer()) break;
					var v:Object = parseHandshakeHello(type, length, rec);
					sendServerHello(v);
					sendCertificate();
					sendServerHelloDone();
					break;
				case HANDSHAKE_SERVER_HELLO:
					if (!enforceClient()) break;
					v = parseHandshakeHello(type, length, rec);
					_securityParameters.setCipher(v.suites[0]);
					_securityParameters.setCompression(v.compressions[0]);
					_securityParameters.setServerRandom(v.random);
					break;
				case HANDSHAKE_CERTIFICATE:
					// okay to receive on both sides.
					tmp = rec.readByte();
					var certs_len:uint = (tmp<<16) | rec.readShort();
					var certs:Array = [];
					while (certs_len>0) {
						tmp = rec.readByte();
						var cert_len:uint = (tmp<<16) | rec.readShort();
						var cert:ByteArray = new ByteArray;
						rec.readBytes(cert, 0, cert_len);
						certs.push(cert);
						certs_len -= 3 + cert_len;
					}
					loadCertificates(certs);
					break;
				case HANDSHAKE_SERVER_KEY_EXCHANGE:
					if (!enforceClient()) break;
					throw new TLSError("Server Key Exchange Not Implemented", TLSError.internal_error);
					break;
				case HANDSHAKE_CERTIFICATE_REQUEST:
					if (!enforceClient()) break;
					throw new TLSError("Certificate Request Not Implemented", TLSError.internal_error);
					break;
				case HANDSHAKE_HELLO_DONE:
					if (!enforceClient()) break;
					sendClientAck();
					break;
				case HANDSHAKE_CLIENT_KEY_EXCHANGE:
					if (!enforceServer()) break;
					parseHandshakeClientKeyExchange(type, length, rec);
					break;
				case HANDSHAKE_CERTIFICATE_VERIFY:
					if (!enforceServer()) break;
					throw new TLSError("Certificate Verify not implemented", TLSError.internal_error);
					break;
				case HANDSHAKE_FINISHED:
					// okay to receive on both sides
					var verifyData:ByteArray = new ByteArray;
					rec.readBytes(verifyData, 0, 12);
					verifyHandshake(verifyData);
					break;
			}

			if (length+4<p.length) {
				var n:ByteArray = new ByteArray;
				n.writeBytes(p,length+4, p.length-(length+4));
				return n;
			} else {
				return null;
			}
		}


		private function verifyHandshake(verifyData:ByteArray):void {
			var data:ByteArray = _securityParameters.computeVerifyData(1-_entity, _handshakePayloads);
			if (ArrayUtil.equals(verifyData, data)) {
				_state = STATE_READY;
				dispatchEvent(new TLSEvent(TLSEvent.READY));
			} else {
				throw new TLSError("Invalid Finished mac.", TLSError.bad_record_mac);
			}
		}

		private function enforceClient():Boolean {
			if (_entity == SERVER) {
				trace("Invalid state for a TLS server.");
				return false;
			}
			return true;
		}
		private function enforceServer():Boolean {
			if (_entity == CLIENT) {
				trace("Invalid state for a TLS client.");
				return false;
			}
			return true;
		}
		
		private function parseHandshakeClientKeyExchange(type:uint, length:uint, rec:ByteArray):void {
			if (_securityParameters.useRSA) {
				// skip 2 bytes for length.
				var len:uint = rec.readShort();
				var cipher:ByteArray = new ByteArray;
				rec.readBytes(cipher, 0, len);
				var preMasterSecret:ByteArray = new ByteArray;
				_config.privateKey.decrypt(cipher, preMasterSecret, len);
				_securityParameters.setPreMasterSecret(preMasterSecret);
				
				// now is a good time to get our pending states
				var o:Object = _securityParameters.getConnectionStates();
				_pendingReadState = o.read;
				_pendingWriteState = o.write;
				
			} else {
				throw new TLSError("parseHandshakeClientKeyExchange not implemented for DH modes.", TLSError.internal_error);
			}
			
		}
		
		private function parseHandshakeHello(type:uint, length:uint, rec:IDataInput):Object {
			var ret:Object;
			var ver:uint = rec.readShort();
			if (ver != TLS_VERSION) {
				throw new TLSError("Unsupported TLS version: "+ver.toString(16), TLSError.protocol_version);
			}
			var random:ByteArray = new ByteArray;
			rec.readBytes(random, 0, 32);
			var session_length:uint = rec.readByte();
			var session:ByteArray = new ByteArray;
			rec.readBytes(session, 0, session_length);
			var suites:Array = [];
			if (type==HANDSHAKE_CLIENT_HELLO) {
				var suites_length:uint = rec.readShort();
				for (var i:uint=0;i<suites_length/2;i++) {
					suites.push(rec.readShort());
				}
			} else {
				suites.push(rec.readShort()); // just one winner.
			}
			var compressions:Array = [];
			if (type==HANDSHAKE_CLIENT_HELLO) {
				var comp_length:uint = rec.readByte();
				for (i=0;i<comp_length;i++) {
					compressions.push(rec.readByte());
				}
			} else {
				compressions.push(rec.readByte());
			}
			ret = {random:random, session:session, suites:suites, compressions:compressions};
			
			if (type==HANDSHAKE_CLIENT_HELLO) {
				var sofar:uint = 2+32+1+session_length+2+suites_length+1+comp_length;
				var extensions:Array = [];
				if (sofar<length) {
					// we have extensions. great.
					var ext_total_length:uint = rec.readShort();
					while (ext_total_length>0) {
						var ext_type:uint = rec.readShort();
						var ext_length:uint = rec.readShort();
						var ext_data:ByteArray = new ByteArray;
						rec.readBytes(ext_data, 0, ext_length);
						ext_total_length -= 4+ext_length;
						extensions.push({type:ext_type, length:ext_length, data:ext_data});
					}
				}
				ret.ext = extensions;
			}
			
			return ret;
		}
		
		private function sendClientHello():void {
			var rec:ByteArray = new ByteArray;
			// version
			rec.writeShort(TLS_VERSION);
			// random
			var prng:Random = new Random;
			var clientRandom:ByteArray = new ByteArray;
			prng.nextBytes(clientRandom, 32);
			_securityParameters.setClientRandom(clientRandom);
			rec.writeBytes(clientRandom,0,32);
			// session
			rec.writeByte(32);
			prng.nextBytes(rec, 32);
			// Cipher suites
			var cs:Array = _config.cipherSuites;
			rec.writeShort(2* cs.length);
			for (var i:int=0;i<cs.length;i++) {
				rec.writeShort(cs[i]);
			}
			// Compression
			cs = _config.compressions;
			rec.writeByte(cs.length);
			for (i=0;i<cs.length;i++) {
				rec.writeByte(cs[i]);
			}
			// no extensions, yet.
			rec.position = 0;
			sendHandshake(HANDSHAKE_CLIENT_HELLO, rec.length, rec);
		}
		
		private function findMatch(a1:Array, a2:Array):int {
			for (var i:int=0;i<a1.length;i++) {
				var e:uint = a1[i];
				if (a2.indexOf(e)>-1) {
					return e;
				}
			}
			return -1;
		}
		
		private function sendServerHello(v:Object):void {
			var cipher:int = findMatch(_config.cipherSuites, v.suites);
			if (cipher == -1) {
				throw new TLSError("No compatible cipher found.", TLSError.handshake_failure);
			}
			_securityParameters.setCipher(cipher);
			
			var comp:int = findMatch(_config.compressions, v.compressions);
			if (comp == 01) {
				throw new TLSError("No compatible compression method found.", TLSError.handshake_failure);
			}
			_securityParameters.setCompression(comp);
			_securityParameters.setClientRandom(v.random);

			var rec:ByteArray = new ByteArray;
			rec.writeShort(TLS_VERSION);
			var prng:Random = new Random;
			var serverRandom:ByteArray = new ByteArray;
			prng.nextBytes(serverRandom, 32);
			_securityParameters.setServerRandom(serverRandom);
			rec.writeBytes(serverRandom,0,32);
			// session
			rec.writeByte(32);
			prng.nextBytes(rec, 32);
			// Cipher suite
			rec.writeShort(v.suites[0]);
			// Compression
			rec.writeByte(v.compressions[0]);
			rec.position = 0;
			sendHandshake(HANDSHAKE_SERVER_HELLO, rec.length, rec);
		}
		private function sendCertificate():void {
			var cert:ByteArray = _config.certificate;
			if (cert == null) return; // no cert for you!
			var len:uint = cert.length;
			var len2:uint = len + 3; // this implies we only ever send 1 certificate. XXX okay for now.
			var rec:ByteArray = new ByteArray;
			rec.writeByte(len2>>16);
			rec.writeShort(len2&65535);
			rec.writeByte(len>>16);
			rec.writeShort(len&65535);
			rec.writeBytes(cert);
			rec.position = 0;
			sendHandshake(HANDSHAKE_CERTIFICATE, rec.length, rec);
		}
		private function sendServerHelloDone():void {
			var rec:ByteArray = new ByteArray;
			sendHandshake(HANDSHAKE_HELLO_DONE, rec.length, rec);
		}
		private function sendClientKeyExchange():void {
			if (_securityParameters.useRSA) {
				var p:ByteArray = new ByteArray;
				p.writeShort(TLS_VERSION);
				var prng:Random = new Random;
				prng.nextBytes(p, 46);
				p.position = 0;

				var preMasterSecret:ByteArray = new ByteArray;
				preMasterSecret.writeBytes(p, 0, p.length);
				_securityParameters.setPreMasterSecret(preMasterSecret);
				
				
				var tmp:ByteArray = new ByteArray;
				_otherCertificate.getPublicKey().encrypt(p, tmp, p.length);
				
				var rec:ByteArray = new ByteArray;
				rec.writeShort(tmp.length);
				rec.writeBytes(tmp, 0, tmp.length);
				rec.position=0;
				
				sendHandshake(HANDSHAKE_CLIENT_KEY_EXCHANGE, rec.length, rec);
				
				// now is a good time to get our pending states
				var o:Object = _securityParameters.getConnectionStates();
				_pendingReadState = o.read;
				_pendingWriteState = o.write;
				
				
			} else {
				throw new TLSError("Non-RSA Client Key Exchange not implemented.", TLSError.internal_error);
			}
		}
		private function sendFinished():void {
			var data:ByteArray = _securityParameters.computeVerifyData(_entity, _handshakePayloads);
			data.position=0;
			sendHandshake(HANDSHAKE_FINISHED, data.length, data);
		}
		private function sendHandshake(type:uint, len:uint, payload:IDataInput):void {
			var rec:ByteArray = new ByteArray;
			rec.writeByte(type);
			rec.writeByte(0);
			rec.writeShort(len);
			payload.readBytes(rec, rec.position, len);
			_handshakePayloads.writeBytes(rec, 0, rec.length);
			sendRecord(PROTOCOL_HANDSHAKE, rec);
		}
		private function sendChangeCipherSpec():void {
			var rec:ByteArray = new ByteArray;
			rec[0] = 1;
			sendRecord(PROTOCOL_CHANGE_CIPHER_SPEC, rec);
			
			// right after, switch the cipher for writing.
			_currentWriteState = _pendingWriteState;
			_pendingWriteState = null;
			
		}
		public function sendApplicationData(data:ByteArray, offset:uint=0, length:uint=0):void {
			var rec:ByteArray = new ByteArray;
			var len:uint = length;
			while (len>16384) {
				rec.position = 0;
				rec.writeBytes(data, offset, 16384);
				rec.position = 0;
				sendRecord(PROTOCOL_APPLICATION_DATA, rec);
				offset += 16384;
				len -= 16384;
			}
			rec.position = 0;
			rec.writeBytes(data, offset, len);
			rec.position = 0;
			sendRecord(PROTOCOL_APPLICATION_DATA, rec);
		}
		private function sendRecord(type:uint, payload:ByteArray):void {
			// encrypt
			payload = _currentWriteState.encrypt(type, payload);
			
			_oStream.writeByte(type);
			_oStream.writeShort(TLS_VERSION);
			_oStream.writeShort(payload.length);
			_oStream.writeBytes(payload, 0, payload.length);
			
			scheduleWrite();
		}
		
		private var _writeScheduler:uint;
		private function scheduleWrite():void {
			if (_writeScheduler!=0) return;
			_writeScheduler = setTimeout(commitWrite, 0);
		}
		private function commitWrite():void {
			clearTimeout(_writeScheduler);
			_writeScheduler = 0;
			if (_state != STATE_CLOSED) {
				dispatchEvent(new ProgressEvent(ProgressEvent.SOCKET_DATA));
			}
		}
		
		private function sendClientAck():void {
			// send a client cert if we were asked for one. (although we don't support that yet. XXX)
			// send a client key exchange
			sendClientKeyExchange();
			// send a change cipher spec
			sendChangeCipherSpec();
			// send a finished
			sendFinished();
		}
		
		/**
		 * Vaguely gross function that parses a RSA key out of a certificate.
		 * 
		 * As long as that certificate looks just the way we expect it to.
		 * 
		 * @param cert: A bytearray that contains some DER-encoded goodness.
		 * 
		 */
		private function loadCertificates(certs:Array):void {
			
			var firstCert:X509Certificate = null;
			for (var i:int=0;i<certs.length;i++) {
				var x509:X509Certificate = new X509Certificate(certs[i]);
				_store.addCertificate(x509);
				if (firstCert==null) {
					firstCert = x509;
				}
			}
			
			if (firstCert.isSigned(_store, _config.CAStore)) {
				// ok, that's encouraging. now for the hostname match.
				if (_otherIdentity==null) {
					// we don't care who we're talking with. groovy.
					trace("TLS WARNING: No check made on the certificate's identity.");
					_otherCertificate = firstCert;
				} else {
					if (firstCert.getCommonName()==_otherIdentity) {
						_otherCertificate = firstCert;
					} else {
						throw new TLSError("Invalid common name: "+firstCert.getCommonName()+", expected "+_otherIdentity, TLSError.bad_certificate);
					}
				}
			} else {
				throw new TLSError("Cannot verify certificate", TLSError.bad_certificate);
			}
		}
		
		private function parseAlert(p:ByteArray):void {
			//throw new Error("Alert not implemented.");
			// 7.2
			trace("GOT ALERT! type="+p[1]);
			close();
		}
		private function parseChangeCipherSpec(p:ByteArray):void {
			p.readUnsignedByte();
			if (_pendingReadState==null) {
				throw new TLSError("Not ready to Change Cipher Spec, damnit.", TLSError.unexpected_message);
			}
			_currentReadState = _pendingReadState;
			_pendingReadState = null;
			// 7.1
		}
		private function parseApplicationData(p:ByteArray):void {
			dispatchEvent(new TLSEvent(TLSEvent.DATA, p));
		}
		
		private function handleTLSError(e:TLSError):void {
			// basic rules to keep things simple:
			// - Make a good faith attempt at notifying peers
			// - TLSErrors are always fatal.
			close(e);
		}
	}
}