using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Pubnub;

namespace csharp
{
    class UUIDExample
    {
        static public void Main()
        {
            //Initialize pubnub state
            pubnub objPubnub = new pubnub(
                "demo",  // PUBLISH_KEY
                "demo",  // SUBSCRIBE_KEY
                "demo",  // SECRET_KEY
                "",  // CIPHER_KEY   [Cipher key is Optional]
                false    // SSL_ON?
            );
            Console.WriteLine("UUID - " + objPubnub.UUID());
            Console.ReadKey();
        }
    }
}
