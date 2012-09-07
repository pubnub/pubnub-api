package PubNub {
import com.adobe.crypto.MD5;
import com.adobe.serialization.json.JSON;
import com.hurlant.crypto.hash.SHA256;

import com.adobe.utils.IntUtil;
import com.hurlant.crypto.Crypto;
import com.hurlant.crypto.symmetric.AESKey;
import com.hurlant.crypto.symmetric.CBCMode;
import com.hurlant.crypto.symmetric.ICipher;
import com.hurlant.crypto.symmetric.IMode;
import com.hurlant.crypto.symmetric.IPad;
import com.hurlant.crypto.symmetric.IVMode;
import com.hurlant.crypto.symmetric.NullPad;
import com.hurlant.crypto.symmetric.PKCS5;
import com.hurlant.util.Base64;
import com.hurlant.util.Hex;
import com.hurlant.util.*;
import com.hurlant.util.der.ByteString;

import flash.display.Sprite;
import flash.utils.ByteArray;
import flash.utils.ByteArray;

public class PubnubCrypto extends Sprite {

    public function encrypt(cipher_key:String, plainStr:String):String {
        var key:ByteArray = hashKey(cipher_key);
        trace("key: " + key);

        var data:ByteArray = Hex.toArray(Hex.fromString(plainStr));
        var cbc:CBCMode = new CBCMode(new AESKey(key), new PKCS5());
        cbc.IV =  Hex.toArray(Hex.fromString("0123456789012345"));

        trace(cbc.IV);
        cbc.encrypt(data);
        var encryptedEncodedData:String = Base64.encodeByteArray(data);
        return encryptedEncodedData;
    }


    //Basic decryption for string
    public function decrypt(cipher_key:String, cipherText:String):String {

        var decodedCipherText:ByteArray = Base64.decodeToByteArray(cipherText)
        var key:ByteArray = hashKey(cipher_key);
        trace("key: " + key);

        var cbc:CBCMode = new CBCMode(new AESKey(key), new PKCS5());
        cbc.IV =  Hex.toArray(Hex.fromString("0123456789012345"));

        cbc.decrypt(decodedCipherText);
        return com.adobe.serialization.json.JSON.decode(Hex.toString(Hex.fromArray(decodedCipherText)));
    }

    private function hashKey(cipher_key:String):ByteArray {
        // hash the cipher key
        var sha256:SHA256 = new SHA256;

        var hexFromString:String = Hex.fromString(cipher_key); // string representation of hex string of cipher_key
        var src:ByteArray = Hex.toArray(hexFromString); // ByteArray of cipher_key
        var hexCipherKey:ByteArray = sha256.hash(src) // ByteArray of hashed_cipher_key
        var cipherString:String = Hex.fromArray(hexCipherKey).slice(0, 32);

        trace("cipherString: " + cipherString);

        var key:ByteArray = Hex.toArray(Hex.fromString(cipherString));
        return key;
    }

    public function md5Key(s:String):String {
        var ba:ByteArray = new ByteArray();
        ba.writeUTFBytes(s);
        return MD5.hashBinary(ba);
    }

}
}
