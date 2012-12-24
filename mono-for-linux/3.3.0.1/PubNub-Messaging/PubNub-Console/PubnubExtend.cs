#define TRACE

using System;
using PubNub_Messaging2;

namespace PubNubConsole
{
	public class PubnubExtend: PubnubBase
	{
		public PubnubExtend (string publish_key, string subscribe_key, string secret_key, string cipher_key, bool ssl_on): base (publish_key, subscribe_key, secret_key, cipher_key, ssl_on)
		{
		}

		public new void checkClientNetworkAvailability(Action<bool> callback)
		{
		}

	}

}

