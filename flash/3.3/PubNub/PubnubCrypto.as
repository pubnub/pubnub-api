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
import com.hurlant.util.*;
import com.hurlant.util.der.ByteString;

import flash.display.Sprite;
import flash.utils.ByteArray;
import flash.utils.ByteArray;

public class PubnubCrypto extends Sprite {
    private var type:String = 'aes-cbc';

    //Basic encryption for string
    public function encryptString(cipher_key:String, plainStr:String):String {

        // hash the cipher key
        var sha256:SHA256 = new SHA256;

        var hexFromString:String = Hex.fromString(cipher_key); // string representation of hex string of cipher_key
        var hexToString:String = Hex.toString(cipher_key); // string representation of hex string of cipher_key

        var src:ByteArray = Hex.toArray(hexFromString); // ByteArray of cipher_key
        var hexCipherKey:ByteArray = sha256.hash(src) // ByteArray of hashed_cipher_key


        var cipherString:String = Hex.fromArray(hexCipherKey).slice(0,32);
        trace("cipherString: " + cipherString);


        var key:ByteArray = Hex.toArray(Hex.fromString(cipherString));
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
            return encryptString(cipher_key, plainObj);
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

    private function d2h( d:int ) : String {
        var c:Array = [ '0', '1', '2', '3', '4', '5', '6', '7', '8',
            '9', 'A', 'B', 'C', 'D', 'E', 'F' ];
        if( d > 255 ) d = 255;
        var l:int = d / 16;
        var r:int = d % 16;
        return c[l]+c[r];
    }

    public function dec2hex( dec:String ) : String {
        var hex:String = "";
        var bytes:Array = dec.split(" ");
        for( var i:int = 0; i < bytes.length; i++ )
            hex += d2h( int(bytes[i]) );
        return hex;
    }

    public function hex2dec( hex:String ) : String {
        var bytes:Array = [];
        while( hex.length > 2 ) {
            var byte:String = hex.substr( -2 );
            hex = hex.substr(0, hex.length-2 );
            bytes.splice( 0, 0, int("0x"+byte) );
        }
        return bytes.join(" ");
    }
}
}
