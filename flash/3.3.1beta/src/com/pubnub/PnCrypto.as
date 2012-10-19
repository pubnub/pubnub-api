package com.pubnub {	
	import com.adobe.crypto.MD5;
	import com.hurlant.crypto.hash.SHA256;
	import com.hurlant.crypto.symmetric.AESKey;
	import com.hurlant.crypto.symmetric.CBCMode;
	import com.hurlant.crypto.symmetric.PKCS5;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	import com.pubnub.json.PnJSON;
	import flash.utils.ByteArray;
	//import com.adobe.serialization.json.JSON;
		
	public class PnCrypto extends Object{

		static public function encrypt(cipher_key:String, plainStr:String):String {
			var key:ByteArray = hashKey(cipher_key);
			var data:ByteArray = Hex.toArray(Hex.fromString(plainStr));
			var cbc:CBCMode = new CBCMode(new AESKey(key), new PKCS5());
			cbc.IV =  Hex.toArray(Hex.fromString("0123456789012345"));
			cbc.encrypt(data);
			var encryptedEncodedData:String = Base64.encodeByteArray(data);
			return encryptedEncodedData;
		}
		
		//Basic decryption for string
		static public function decrypt(cipher_key:String, cipherText:String):String {

			var decodedCipherText:ByteArray = Base64.decodeToByteArray(cipherText)
			var key:ByteArray = hashKey(cipher_key);
			//trace("key: " + key);

			var cbc:CBCMode = new CBCMode(new AESKey(key), new PKCS5());
			cbc.IV =  Hex.toArray(Hex.fromString("0123456789012345"));

			cbc.decrypt(decodedCipherText);
			//return PnJSON.decode(Hex.toString(Hex.fromArray(decodedCipherText)));
			return PnJSON.stringify(Hex.toString(Hex.fromArray(decodedCipherText)));
		}

		static private function hashKey(cipher_key:String):ByteArray {
			// hash the cipher key
			var sha256:SHA256 = new SHA256;

			var hexFromString:String = Hex.fromString(cipher_key); // string representation of hex string of cipher_key
			var src:ByteArray = Hex.toArray(hexFromString); // ByteArray of cipher_key
			var hexCipherKey:ByteArray = sha256.hash(src) // ByteArray of hashed_cipher_key
			var cipherString:String = Hex.fromArray(hexCipherKey).slice(0, 32);

			//trace("cipherString: " + cipherString);
			var key:ByteArray = Hex.toArray(Hex.fromString(cipherString));
			return key;
		}

		static public function md5Key(s:String):String {
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(s);
			return MD5.hashBinary(ba);
		}
	}
}
