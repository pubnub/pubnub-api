## www.pubnub.com - PubNub Real-time push service in the cloud. 
# coding=utf8

## PubNub Real-time Push APIs and Notifications Framework
## Copyright (c) 2010 Stephen Blum
## http://www.pubnub.com/

## -----------------------------------
## PubNub 3.1 Real-time Push Cloud API
## -----------------------------------

from Crypto.Cipher import AES
from Crypto.Hash import MD5
from base64 import encodestring, decodestring 
import hashlib
import hmac

class PubnubCrypto() :
    """
    #**
    #* PubnubCrypto
    #*
    #**

    ## Initiate Class
    pc = PubnubCrypto

    """
   
    def pad( self, msg, block_size=16 ):
        """
        #**
        #* pad
        #*
        #* pad the text to be encrypted
        #* appends a padding character to the end of the String
        #* until the string has block_size length
        #* @return msg with padding.
        #**
        """
        return msg + ((block_size - len(msg) % block_size) * chr(block_size - len(msg) % block_size))
       
    def depad( self, msg ):
        """
        #**
        #* depad
        #*
        #* depad the decryptet message"
        #* @return msg without padding.
        #**
        """
        return msg[0:-ord(msg[-1])]

    def getSecret( self, key ):
        """
        #**
        #* getSecret
        #*
        #* hases the key to MD5
        #* @return key in MD5 format
        #**
        """
        return MD5.new(key).digest()

    def encrypt( self, key, msg ):
        """
        #**
        #* encrypt
        #*
        #* encrypts the message
        #* @return message in encrypted format
        #**
        """
        secret = self.getSecret(key)
        Initial16bytes='0123456789012345'
        cipher = AES.new(secret,AES.MODE_CBC,Initial16bytes)
        return encodestring(cipher.encrypt(self.pad(msg)))
    
    def decrypt( self, key, msg ):
        """
        #**
        #* decrypt
        #*
        #* decrypts the message
        #* @return message in decryped format
        #**
        """
        secret = self.getSecret(key)
        Initial16bytes='0123456789012345'
        cipher = AES.new(secret,AES.MODE_CBC,Initial16bytes)
        return self.depad((cipher.decrypt(decodestring(msg))))
    
