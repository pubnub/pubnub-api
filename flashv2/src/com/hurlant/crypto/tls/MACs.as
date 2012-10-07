/**
 * MACs
 * 
 * An enumeration of MACs implemented for TLS
 * Copyright (c) 2007 Henri Torgemane
 * 
 * See LICENSE.txt for full license information.
 */
package com.hurlant.crypto.tls {
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.crypto.Crypto;
	
	public class MACs {
		public static const NULL:uint = 0;
		public static const MD5:uint = 1;
		public static const SHA1:uint = 2;

		public static function getHashSize(hash:uint):uint {
			return [0,16,20][hash];
		}		
		
		public static function getHMAC(hash:uint):HMAC {
			if (hash==NULL) return null;
			return Crypto.getHMAC(['',"md5","sha1"][hash]);
		}
	}
}