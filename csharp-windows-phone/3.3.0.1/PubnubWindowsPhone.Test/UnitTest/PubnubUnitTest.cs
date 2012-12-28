using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PubNub_Messaging;

using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Phone.Testing;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Threading;

namespace PubnubWindowsPhone.Test.UnitTest
{
    public class PubnubUnitTest : IPubnubUnitTest
    {
        private bool _enableStubTest = true;
        private string _testClassName = "";
        private string _testCaseName = "";

        public bool EnableStubTest
        {
            get
            {
                return _enableStubTest;
            }
            set
            {
                _enableStubTest = value;
            }
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenAClientIsPresented_ThenPresenceShouldReturnReceivedMessage()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/subscribe/demo/my%2Fchannel-pnpres/0/0", "[[],\"13559007117760880\"]");
            data.Add("/subscribe/demo/my%2Fchannel-pnpres/0/13559007117760880", "[[{\"action\": \"join\", \"timestamp\": 1355929955, \"uuid\": \"eb4c1645-1319-4425-865f-008563009d67\", \"occupancy\": 1}],\"13559011560379628\"]");
            data.Add("/subscribe/demo/my%2Fchannel-pnpres/0/13559011560379628", "[[],\"13559011560379628\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/13559006802662768", "[[\"demo test for stubs\"],\"13559014566792816\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/13559014566792816", "[[],\"13559014566792816\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%2Fchannel/leave", "{\"action\": \"leave\"}");
#else
            data.Add("/subscribe/demo/my/channel-pnpres/0/0", "[[],\"13559007117760880\"]");
            data.Add("/subscribe/demo/my/channel-pnpres/0/13559007117760880", "[[{\"action\": \"join\", \"timestamp\": 1355929955, \"uuid\": \"eb4c1645-1319-4425-865f-008563009d67\", \"occupancy\": 1}],\"13559011560379628\"]");
            data.Add("/subscribe/demo/my/channel-pnpres/0/13559011560379628", "[[],\"13559011560379628\"]");
            data.Add("/subscribe/demo/my/channel/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my/channel/0/13559006802662768", "[[\"demo test for stubs\"],\"13559014566792816\"]");
            data.Add("/subscribe/demo/my/channel/0/13559014566792816", "[[],\"13559014566792816\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%252Fchannel/leave", "{\"action\": \"leave\"}");
#endif
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenAClientIsPresented_IfHereNowIsCalledThenItShouldReturnInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/v2/presence/sub_key/demo/channel/my%2Fchannel", "{\"uuids\":[\"eb4c1645-1319-4425-865f-008563009d67\"],\"occupancy\":1}");
            #else
            data.Add("/v2/presence/sub_key/demo/channel/my%252Fchannel", "{\"uuids\":[\"eb4c1645-1319-4425-865f-008563009d67\"],\"occupancy\":1}");
            #endif
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenUnencryptPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/v2/history/sub-key/demo/channel/my%2Fchannel", "[[\"Pubnub Messaging API 1\"],13557486057035336,13559006802662769]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22Pubnub%20Messaging%20API%201%22", "[1,\"Sent\",\"13559014566792817\"]");
            #else
            data.Add("/publish/demo/demo/0/my/channel/0/%22Pubnub%20Messaging%20API%201%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"Pubnub Messaging API 1\"],13557486057035336,13559006802662769]");
            #endif
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%7B%22foo%22%3A%22hi%21%22%2C%22bar%22%3A%5B1%2C2%2C3%2C4%2C5%5D%7D", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%2Fchannel", "[[{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]}],13557486057035336,13559006802662769]");
            #else
            data.Add("/publish/demo/demo/0/my/channel/0/%7B%22foo%22%3A%22hi%21%22%2C%22bar%22%3A%5B1%2C2%2C3%2C4%2C5%5D%7D", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]}],13557486057035336,13559006802662769]");
            #endif
            return data;
        }

        [Asynchronous] //TODO:
        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%2Fchannel", "[[\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\"],13559215464464812,13559215464464812]");
#else
            data.Add("/publish/demo/demo/0/my/channel/0/%22nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\"],13559215464464812,13559215464464812]");
#endif
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22%2BBY5%2FmiAA8aeuhVl4d13Kg%3D%3D%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%2Fchannel", "[[\"+BY5/miAA8aeuhVl4d13Kg==\"],13557486057035336,13559006802662769]");
#else
            data.Add("/publish/demo/demo/0/my/channel/0/%22%2BBY5/miAA8aeuhVl4d13Kg%3D%3D%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"+BY5/miAA8aeuhVl4d13Kg==\"],13557486057035336,13559006802662769]");
#endif
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/3f75435fcd800f5d0476fc0fb5b572d1/my%2Fchannel/0/%22f42pIQcWZ9zbTbH8cyLwB%2FtdvRxjFLOYcBNMVKeHS54%3D%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%2Fchannel", "[[\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\"],13559191494674157,13559191494674157]");
#else
            data.Add("/publish/demo/demo/3f75435fcd800f5d0476fc0fb5b572d1/my/channel/0/%22f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54%3D%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\"],13559191494674157,13559191494674157]");
#endif

            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenOptionalSecretKeyShouldBeProvidedInConstructor()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/d759c756abbd45a9864adc7f2b91393e/my%2Fchannel/0/%22Pubnub%20API%20Usage%20Example%22", "[1,\"Sent\",\"13559014566792817\"]");
#else
            data.Add("/publish/demo/demo/d759c756abbd45a9864adc7f2b91393e/my/channel/0/%22Pubnub%20API%20Usage%20Example%22", "[1,\"Sent\",\"13559014566792817\"]");
#endif
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenAMessageIsPublished_IfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22Pubnub%20API%20Usage%20Example%22", "[1,\"Sent\",\"13559014566792817\"]");
            #else
            data.Add("/publish/demo/demo/0/my/channel/0/%22Pubnub%20API%20Usage%20Example%22", "[1,\"Sent\",\"13559014566792817\"]");
            #endif
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_DetailHistoryCount10ReturnsRecords()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/v2/history/sub-key/demo/channel/my%2Fchannel", "[[\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"+BY5/miAA8aeuhVl4d13Kg==\",\"Pubnub API Usage Example\",\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]},\"Pubnub Messaging API 1\"],13559191494674157,13559319777162196]");
#else
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"+BY5/miAA8aeuhVl4d13Kg==\",\"Pubnub API Usage Example\",\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]},\"Pubnub Messaging API 1\"],13559191494674157,13559319777162196]");
#endif
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_DetailHistoryCount10ReverseTrueReturnsRecords()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/v2/history/sub-key/demo/channel/my%2Fchannel", "[[\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"+BY5/miAA8aeuhVl4d13Kg==\",\"Pubnub API Usage Example\",\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]},\"Pubnub Messaging API 1\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 0\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 1\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 3\"],13557486057035336,13557486128690220]");
            #else
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"+BY5/miAA8aeuhVl4d13Kg==\",\"Pubnub API Usage Example\",\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]},\"Pubnub Messaging API 1\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 0\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 1\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 3\"],13557486057035336,13557486128690220]");
            #endif
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_DetailedHistoryStartWithReverseTrue()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/v2/history/sub-key/demo/channel/my%2Fchannel", "[[\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 0\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 1\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 2\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 3\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 4\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 4\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 6\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 7\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 8\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 9\"],13559326456056557,13559327017296315]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22DetailedHistoryStartTimeWithReverseTrue%200%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22DetailedHistoryStartTimeWithReverseTrue%201%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22DetailedHistoryStartTimeWithReverseTrue%202%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22DetailedHistoryStartTimeWithReverseTrue%203%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22DetailedHistoryStartTimeWithReverseTrue%204%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22DetailedHistoryStartTimeWithReverseTrue%205%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22DetailedHistoryStartTimeWithReverseTrue%206%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22DetailedHistoryStartTimeWithReverseTrue%207%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22DetailedHistoryStartTimeWithReverseTrue%208%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22DetailedHistoryStartTimeWithReverseTrue%209%22", "[1,\"Sent\",\"13559014566792817\"]");
#else
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 0\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 1\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 2\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 3\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 4\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 4\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 6\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 7\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 8\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 9\"],13559326456056557,13559327017296315]");
            data.Add("/publish/demo/demo/0/my/channel/0/%22DetailedHistoryStartTimeWithReverseTrue%200%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my/channel/0/%22DetailedHistoryStartTimeWithReverseTrue%201%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my/channel/0/%22DetailedHistoryStartTimeWithReverseTrue%202%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my/channel/0/%22DetailedHistoryStartTimeWithReverseTrue%203%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my/channel/0/%22DetailedHistoryStartTimeWithReverseTrue%204%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my/channel/0/%22DetailedHistoryStartTimeWithReverseTrue%205%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my/channel/0/%22DetailedHistoryStartTimeWithReverseTrue%206%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my/channel/0/%22DetailedHistoryStartTimeWithReverseTrue%207%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my/channel/0/%22DetailedHistoryStartTimeWithReverseTrue%208%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/my/channel/0/%22DetailedHistoryStartTimeWithReverseTrue%209%22", "[1,\"Sent\",\"13559014566792817\"]");
#endif
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenGetRequestServerTime_ThenItShouldReturnTimeStamp()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/time/0", "[13559011090230537]");
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenSubscribedToAChannel_ThenSubscribeShouldReturnReceivedMessage()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            #if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22Test%20for%20WhenSubscribedToAChannel%20ThenItShouldReturnReceivedMessage%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/13559006802662768", "[[\"Test for WhenSubscribedToAChannel ThenItShouldReturnReceivedMessage\"],\"13559014566792816\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/13559014566792816", "[[],\"13559014566792816\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%2Fchannel/leave", "{\"action\": \"leave\"}");
#else
            data.Add("/publish/demo/demo/0/my/channel/0/%22Test%20for%20WhenSubscribedToAChannel%20ThenItShouldReturnReceivedMessage%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/subscribe/demo/my/channel/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my/channel/0/13559006802662768", "[[\"Test for WhenSubscribedToAChannel ThenItShouldReturnReceivedMessage\"],\"13559014566792816\"]");
            data.Add("/subscribe/demo/my/channel/0/13559014566792816", "[[],\"13559014566792816\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%252Fchannel/leave", "{\"action\": \"leave\"}");
#endif
            return data;
        }

        [Asynchronous]
        private Dictionary<string, string> Load_WhenSubscribedToAChannel_ThenSubscribeShouldReturnConnectStatus()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22Test%20for%20WhenSubscribedToAChannel%20ThenItShouldReturnReceivedMessage%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/13559006802662768", "[[\"Test for WhenSubscribedToAChannel ThenItShouldReturnReceivedMessage\"],\"13559014566792816\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/13559014566792816", "[[],\"13559014566792816\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%2Fchannel/leave", "{\"action\": \"leave\"}");
#else
            data.Add("/publish/demo/demo/0/my/channel/0/%22Test%20for%20WhenSubscribedToAChannel%20ThenItShouldReturnReceivedMessage%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/subscribe/demo/my/channel/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my/channel/0/13559006802662768", "[[\"Test for WhenSubscribedToAChannel ThenItShouldReturnReceivedMessage\"],\"13559014566792816\"]");
            data.Add("/subscribe/demo/my/channel/0/13559014566792816", "[[],\"13559014566792816\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%252Fchannel/leave", "{\"action\": \"leave\"}");
#endif
            return data;
        }

        [Asynchronous]
        public string GetStubResponse(Uri request)
        {
            Dictionary<string,string> respDic = null;
            string stubResponse = "!! Stub Response Not Assigned !!";
            
            switch (_testClassName)
            {
                case "WhenAClientIsPresented":
                    switch (_testCaseName)
                    {
                        case "ThenPresenceShouldReturnReceivedMessage":
                            respDic = Load_WhenAClientIsPresented_ThenPresenceShouldReturnReceivedMessage();
                            break;
                        case "IfHereNowIsCalledThenItShouldReturnInfo":
                            respDic = Load_WhenAClientIsPresented_IfHereNowIsCalledThenItShouldReturnInfo();
                            break;
                        default:
                            break;
                    }
                    break;
                case "WhenAMessageIsPublished":
                    switch (_testCaseName)
                    {
                        case "ThenUnencryptPublishShouldReturnSuccessCodeAndInfo":
                            respDic = Load_WhenAMessageIsPublished_ThenUnencryptPublishShouldReturnSuccessCodeAndInfo();
                            break;
                        case "ThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo":
                            respDic = Load_WhenAMessageIsPublished_ThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo();
                            break;
                        case "ThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo":
                            respDic = Load_WhenAMessageIsPublished_ThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo();
                            break;
                        case "ThenEncryptPublishShouldReturnSuccessCodeAndInfo":
                            respDic = Load_WhenAMessageIsPublished_ThenEncryptPublishShouldReturnSuccessCodeAndInfo();
                            break;
                        case "ThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo":
                            respDic = Load_WhenAMessageIsPublished_ThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo();
                            break;
                        case "ThenOptionalSecretKeyShouldBeProvidedInConstructor":
                            respDic = Load_WhenAMessageIsPublished_ThenOptionalSecretKeyShouldBeProvidedInConstructor();
                            break;
                        case "IfSSLNotProvidedThenDefaultShouldBeFalse":
                            respDic = Load_WhenAMessageIsPublished_IfSSLNotProvidedThenDefaultShouldBeFalse();
                            break;
                        default:
                            break;
                    }
                    break;
                case "WhenDetailedHistoryIsRequested":
                    switch (_testCaseName)
                    {
                        case "DetailHistoryCount10ReturnsRecords":
                            respDic = Load_WhenDetailedHistoryIsRequested_DetailHistoryCount10ReturnsRecords();
                            break;
                        case "DetailHistoryCount10ReverseTrueReturnsRecords":
                            respDic = Load_WhenDetailedHistoryIsRequested_DetailHistoryCount10ReverseTrueReturnsRecords();
                            break;
                        case "DetailedHistoryStartWithReverseTrue":
                            respDic = Load_WhenDetailedHistoryIsRequested_DetailedHistoryStartWithReverseTrue();
                            break;
                        default:
                            break;
                    }
                    break;
                case "WhenGetRequestServerTime":
                    switch (_testCaseName)
                    {
                        case "ThenItShouldReturnTimeStamp":
                            respDic = Load_WhenGetRequestServerTime_ThenItShouldReturnTimeStamp();
                            break;
                        default:
                            break;
                    }
                    break;
                case "WhenSubscribedToAChannel":
                    switch (_testCaseName)
                    {
                        case "ThenSubscribeShouldReturnReceivedMessage":
                            respDic = Load_WhenSubscribedToAChannel_ThenSubscribeShouldReturnReceivedMessage();
                            break;
                        case "ThenSubscribeShouldReturnConnectStatus":
                            respDic = Load_WhenSubscribedToAChannel_ThenSubscribeShouldReturnConnectStatus();
                            break;
                        default:
                            break;
                    }
                    break;
                default:
                    break;
            }

            if (respDic != null && respDic.ContainsKey(request.AbsolutePath))
            {
                stubResponse = respDic[request.AbsolutePath];
            }
            else
            {
                stubResponse = "!! Stub Response Not Assigned !!";
            }

            return stubResponse;
        }

        public string TestCaseName
        {
            get
            {
                return _testCaseName;
            }
            set
            {
                _testCaseName = value;
            }
        }


        public string TestClassName
        {
            get
            {
                return _testClassName;
            }
            set
            {
                _testClassName = value;
            }
        }
    }
}
