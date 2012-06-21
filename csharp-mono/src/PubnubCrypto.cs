using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security.Cryptography;
using Newtonsoft.Json.Linq;

namespace PubnubCrypto
{
    public class clsPubnubCrypto
    {
        private string CIPHER_KEY = "";
        public clsPubnubCrypto(string cipher_key)
        {
            this.CIPHER_KEY = cipher_key;            
        }
        // Basic function for encrypt or decrypt a string 
        // for encrypt type=true
        // for decrypt type=false
        public string EncryptOrDecrypt(bool type,string plainStr)   
        {
            RijndaelManaged aesEncryption = new RijndaelManaged();   
            aesEncryption.KeySize = 256;             
            aesEncryption.BlockSize = 128;             
            aesEncryption.Mode = CipherMode.CBC;          
            aesEncryption.Padding = PaddingMode.PKCS7;
            aesEncryption.IV = ASCIIEncoding.UTF8.GetBytes("0123456789012345");
            aesEncryption.Key = md5(this.CIPHER_KEY);
            if (type)
            {
                ICryptoTransform crypto = aesEncryption.CreateEncryptor();
                byte[] plainText = ASCIIEncoding.UTF8.GetBytes(plainStr);
                byte[] cipherText = crypto.TransformFinalBlock(plainText, 0, plainText.Length);
                return Convert.ToBase64String(cipherText);
            }
            else
            {
                ICryptoTransform decrypto = aesEncryption.CreateDecryptor();
                byte[] encryptedBytes = Convert.FromBase64CharArray(plainStr.ToCharArray(), 0, plainStr.Length);
                return ASCIIEncoding.UTF8.GetString(decrypto.TransformFinalBlock(encryptedBytes, 0, encryptedBytes.Length));
            }
        }

        //encrypt string
        public string encrypt(string plainStr)
        {
            return EncryptOrDecrypt(true, plainStr);
        }

        //decrypt string
        public string decrypt(string cipherStr)
        {
            return EncryptOrDecrypt(false, cipherStr);
        }

        // encrypt array of objects
        public object encrypt(object[] plainArr)
        {
            object[] cipherArr = new object[plainArr.Count()];
            for (int i = 0; i < plainArr.Count(); i++)
            {
                cipherArr[i] = encrypt((string)plainArr[i]);
            }
            return cipherArr;
        }

        // decrypt array of objects
        public JArray decrypt(object[] cipherArr)
        {
            JArray plainArr = new JArray();

            for (int i = 0; i < cipherArr.Count(); i++)
            {
                if (cipherArr[i].GetType() == typeof(object[]))
                {
                    plainArr.Add(decrypt((List<object>)cipherArr[i]));
                }
                else if (cipherArr[i].GetType() == typeof(string))
                {
                    plainArr.Add(decrypt((string)cipherArr[i]));
                }
                else
                {
                    plainArr.Add(decrypt((Dictionary<string, object>)cipherArr[i]));
                }
            }
            return plainArr;
        }

        // decrypt list of objects for history function
        public List<object> decrypt(List<object> cipherArr)
        {
            List<object> lstObj = new List<object>();
            foreach (object o in cipherArr)
            {
                if (o.GetType() == typeof(object[]))
                {
                    lstObj.Add(decrypt((object[])o));
                }
                else if (o.GetType() == typeof(string))
                {
                    lstObj.Add(decrypt(o.ToString()));
                }
                else
                {
                    lstObj.Add(decrypt((Dictionary<string,object>)o));
                }
            }
            return lstObj;
        }

        // encrypt object with key value pair <string,object> format
        public Dictionary<string, object> encrypt(Dictionary<string, object> plainObj)
        {
            Dictionary<string, object> newDict = new Dictionary<string, object>();
            foreach (KeyValuePair<string, object> pair in plainObj)
            {
                if (pair.Value.GetType() == typeof(string))
                {
                    newDict.Add(pair.Key, encrypt(pair.Value.ToString()));
                }
                else
                {
                    newDict.Add(pair.Key, encrypt((Dictionary<string, object>)pair.Value));
                }
            }
            return newDict;
        }

        // decrypt object with key value pair <string,object> format
        public JObject decrypt(Dictionary<string, object> cipherObj)
        {
            JObject objPlain = new JObject();

            foreach (KeyValuePair<string, object> pair in cipherObj)
            {
                if (pair.Value.GetType() == typeof(string))
                {
                    objPlain.Add(pair.Key, decrypt(pair.Value.ToString()));
                }
                else
                {
                    objPlain.Add(pair.Key, decrypt((Dictionary<string, object>)pair.Value));
                }
            }
            return objPlain;
        }

       //md5 used for AES encryption key
        private static byte[] md5(string cipher_key)
        {
            MD5 obj = new MD5CryptoServiceProvider();
            byte[] data = Encoding.Default.GetBytes(cipher_key);
            return obj.ComputeHash(data);
        }
    }
}
