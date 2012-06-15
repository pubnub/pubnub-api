using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Newtonsoft.Json.Linq;
using System.Security.Cryptography;
using System.Text;

namespace csharp_webApp
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
        // for decrypt type= false
        public string EncryptOrDecrypt(bool type, string plainStr)
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

        // encrypt string
        public string encrypt(string plainStr)
        {
            return EncryptOrDecrypt(true, plainStr);
        }

        // decrypt string
        public string decrypt(string cipherStr)
        {
            return EncryptOrDecrypt(false, cipherStr);
        }

        // decrypt list of objects for history function
        public List<object> decrypt(List<object> cipherArr)
        {
            List<object> lstObj = new List<object>();
            if (cipherArr.Count > 0)
            {
                foreach (object o in cipherArr)
                {
                    if (o.GetType() == typeof(JArray))
                    {
                        if (((JArray)o).Count > 0)
                        {
                            lstObj.Add(decrypt((JArray)o));
                        }
                    }
                    else if (o.GetType() == typeof(string))
                    {
                        if ((string)o != "")
                        {
                            lstObj.Add(decrypt((string)o));
                        }
                    }
                    else
                    {
                        if (((JObject)o).Count > 0)
                        {
                            lstObj.Add(decrypt((JObject)o));
                        }
                    }
                }
            }
            return lstObj;
        }

        // encrypt array of objects
        public JArray encrypt(JArray plainArr)
        {
            JArray cipherArr = new JArray();

            for (int i = 0; i < plainArr.Count; i++)
            {
                if (plainArr[i].Type == JTokenType.String)
                {
                    cipherArr.Add(encrypt((string)plainArr[i]));
                }
            }
            return cipherArr;
        }

        // decrypt array of objects
        public JArray decrypt(JArray cipherArr)
        {
            JArray plainArr = new JArray();

            for (int i = 0; i < cipherArr.Count; i++)
            {
                if (cipherArr[i].Type == JTokenType.String)
                {
                    plainArr.Add(decrypt((string)cipherArr[i]));
                }
            }
            return plainArr;
        }

        // encrypt Dictionary object
        public JObject encrypt(JObject plainObj)
        {
            JObject cipherObj = new JObject();
            JToken jtoken;
            jtoken = plainObj.First;
            for (int i = 0; i < plainObj.Count; i++)
            {
                while (jtoken != null)
                {
                    if (((JProperty)jtoken).Value.Type == JTokenType.String)
                    {
                        cipherObj.Add(((JProperty)jtoken).Name.ToString(), encrypt((string)((JProperty)jtoken).Value));
                    }
                    else
                    {
                        cipherObj.Add(((JProperty)jtoken).Name.ToString(), encrypt((JObject)((JProperty)jtoken).Value));
                    }
                    jtoken = jtoken.Next;
                }
            }
            return cipherObj;
        }

        // decrypt Dictionary object
        public JObject decrypt(JObject cipherObj)
        {
            JObject objPlain = new JObject();
            JToken jtoken;
            jtoken = cipherObj.First;
            for (int i = 0; i < cipherObj.Count; i++)
            {
                while (jtoken != null)
                {
                    if (((JProperty)jtoken).Value.Type == JTokenType.String)
                    {
                        objPlain.Add(((JProperty)jtoken).Name.ToString(), decrypt((string)((JProperty)jtoken).Value));
                    }
                    else
                    {
                        cipherObj.Add(((JProperty)jtoken).Name.ToString(), decrypt((JObject)((JProperty)jtoken).Value));
                    }
                    jtoken = jtoken.Next;
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