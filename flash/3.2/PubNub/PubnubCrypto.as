package PubNub {
import com.adobe.crypto.MD5;
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

import flash.display.Sprite;
import flash.utils.ByteArray;

public class PubnubCrypto extends Sprite {
    private var type:String = 'aes-cbc';

    //Basic encryption for string
    public function encryptString(cipher_key:String, plainStr:String):String {

        var sha256:SHA256 = new SHA256;
        var src:ByteArray = Hex.toArray(Hex.fromString(cipher_key));
        cipher_key = sha256.hash(src).toString().slice(0,31);

        var key:ByteArray = Hex.toArray(cipher_key);
        var data:ByteArray = Hex.toArray(Hex.fromString(plainStr));
        var cbc:CBCMode = new CBCMode(new AESKey(key), new PKCS5());
        cbc.IV = Hex.toArray(Hex.fromString("0123456789012345"));
        cbc.encrypt(data);
        return Base64.encodeByteArray(data);
    }

    //Basic decryption for string
    public function decryptString(cipher_key:String, cipherStr:String):String {
        var data:ByteArray = Base64.decodeToByteArray(cipherStr);

        var sha256:SHA256 = new SHA256;
        var src:ByteArray = Hex.toArray(Hex.fromString(cipher_key));
        cipher_key = sha256.hash(src).toString().slice(0,31);

        var key:ByteArray = Hex.toArray(cipher_key);
        var testkey:ByteArray = new ByteArray;
        var cbc:CBCMode = new CBCMode(new AESKey(key), new PKCS5());
        cbc.IV = Hex.toArray(Hex.fromString("0123456789012345"));
        cbc.decrypt(data);
        return Hex.toString(Hex.fromArray(data));
    }

    //Encryption for string/object/array
    public function encrypt(cipher_key:String, plainObj:*):* {
        if (typeof(plainObj) == "object") {
            if (plainObj.length == undefined) //plainObj is object
            {
                var cipherObj:Object = new Object();
                for (var s:String in plainObj) {
                    if (typeof(plainObj[s]) == "object") {
                        cipherObj[s] = encrypt(cipher_key, plainObj[s]);
                    }
                    else {
                        cipherObj[s] = encryptString(cipher_key, plainObj[s]);
                    }
                }
                return cipherObj;
            }
            else {
                //plainObj is array
                var cipherArray:Array = new Array();
                for (var i:int = 0; i < plainObj.length; i++) {
                    cipherArray[i] = encryptString(cipher_key, plainObj[i])
                }
                return cipherArray;
            }
        }
        else if (typeof(plainObj) == "string") {
            return encryptString(cipher_key, plainObj);
        }
    }

    //Decryption for string/object/array
    public function decrypt(cipher_key:String, cipherObj:*):* {
        if (typeof(cipherObj) == "object") {
            if (cipherObj.length == undefined) //cipherObj is object
            {
                var plainObj:Object = new Object();
                for (var s:String in cipherObj) {
                    if (typeof(cipherObj[s]) == "object") {
                        plainObj[s] = decrypt(cipher_key, cipherObj[s]);
                        plainObj[s] = JSON.parse(plainObj[s].toString());
                    }
                    else {
                        plainObj[s] = decryptString(cipher_key, cipherObj[s]);
                    }
                }
                return JSON.stringify(plainObj);
            }
            else {
                //cipherObj is array
                var plainArray:Array = new Array();
                for (var i:int = 0; i < cipherObj.length; i++) {
                    plainArray[i] = decryptString(cipher_key, cipherObj[i])
                }
                return JSON.stringify(plainArray);
            }
        }
        else if (typeof(cipherObj) == "string") {
            return JSON.stringify(decryptString(cipher_key, cipherObj));
        }
    }

    public function md5Key(s:String):String {
        var ba:ByteArray = new ByteArray();
        ba.writeUTFBytes(s);
        return MD5.hashBinary(ba);
    }
}
}
