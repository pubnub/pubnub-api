using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PubNubMessaging.Core;

namespace PubnubWindowsPhone.Test.UnitTest
{
    public class PubnubUnitTest : IPubnubUnitTest
    {
        private bool enableStubTest = true;
        private string _testClassName = "";
        private string _testCaseName = "";

        public bool EnableStubTest
        {
            get
            {
                return enableStubTest;
            }
            set
            {
                enableStubTest = value;
            }
        }

        private Dictionary<string, string> LoadWhenAClientIsPresentedThenPresenceShouldReturnReceivedMessage()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/subscribe/demo/my%2Fchannel-pnpres/0/0", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my%2Fchannel-pnpres/0/13596603179264912", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my%2Fchannel,my%2Fchannel-pnpres/0/0", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my%2Fchannel,my%2Fchannel-pnpres/0/13596603179264912", "[[{\"action\": \"join\", \"timestamp\": 1355929955, \"uuid\": \"eb4c1645-1319-4425-865f-008563009d67\", \"occupancy\": 1}],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my%2Fchannel,my%2Fchannel-pnpres/0/13559006802662768", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my%2Fchannel-pnpres/0/13559006802662768", "[[{\"action\": \"leave\", \"timestamp\": 1359660369, \"uuid\": \"eb4c1645-1319-4425-865f-008563009d67\", \"occupancy\": 0}],\"13596603694444112\"]");
            data.Add("/subscribe/demo/my%2Fchannel,my%2Fchannel-pnpres/0/13596603694444112", "[[],\"13596603694444112\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%252Fchannel/leave", "{\"action\": \"leave\"}");
#else
            data.Add("/subscribe/demo/my/channel-pnpres/0/0", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my/channel-pnpres/0/13596603179264912", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my/channel,my/channel-pnpres/0/0", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my/channel,my/channel-pnpres/0/13596603179264912", "[[{\"action\": \"join\", \"timestamp\": 1355929955, \"uuid\": \"eb4c1645-1319-4425-865f-008563009d67\", \"occupancy\": 1}],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my/channel,my/channel-pnpres/0/13559006802662768", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my/channel-pnpres/0/13559006802662768", "[[{\"action\": \"leave\", \"timestamp\": 1359660369, \"uuid\": \"eb4c1645-1319-4425-865f-008563009d67\", \"occupancy\": 0}],\"13596603694444112\"]");
            data.Add("/subscribe/demo/my/channel,my/channel-pnpres/0/13596603694444112", "[[],\"13596603694444112\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%252Fchannel/leave", "{\"action\": \"leave\"}");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenAClientIsPresentedThenPresenceShouldReturnCustomUUID()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/subscribe/demo/my%2Fchannel-pnpres/0/0", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my%2Fchannel-pnpres/0/13596603179264912", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my%2Fchannel,my%2Fchannel-pnpres/0/0", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my%2Fchannel,my%2Fchannel-pnpres/0/13596603179264912", "[[{\"action\": \"join\", \"timestamp\": 1355929955, \"uuid\": \"mylocalmachine.mydomain.com\", \"occupancy\": 1}],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my%2Fchannel,my%2Fchannel-pnpres/0/13559006802662768", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my%2Fchannel-pnpres/0/13559006802662768", "[[{\"action\": \"leave\", \"timestamp\": 1359660369, \"uuid\": \"mylocalmachine.mydomain.com\", \"occupancy\": 0}],\"13596603694444112\"]");
            data.Add("/subscribe/demo/my%2Fchannel,my%2Fchannel-pnpres/0/13596603694444112", "[[],\"13596603694444112\"]");
            data.Add("/subscribe/demo/my%2Fchannel-pnpres/0/13596603694444112", "[[],\"13596603694444112\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%252Fchannel/leave", "{\"action\": \"leave\"}");
#else
            data.Add("/subscribe/demo/my/channel-pnpres/0/0", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my/channel-pnpres/0/13596603179264912", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my/channel,my/channel-pnpres/0/0", "[[],\"13596603179264912\"]");
            data.Add("/subscribe/demo/my/channel,my/channel-pnpres/0/13596603179264912", "[[{\"action\": \"join\", \"timestamp\": 1355929955, \"uuid\": \"mylocalmachine.mydomain.com\", \"occupancy\": 1}],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my/channel,my/channel-pnpres/0/13559006802662768", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my/channel-pnpres/0/13559006802662768", "[[{\"action\": \"leave\", \"timestamp\": 1359660369, \"uuid\": \"mylocalmachine.mydomain.com\", \"occupancy\": 0}],\"13596603694444112\"]");
            data.Add("/subscribe/demo/my/channel-pnpres/0/13596603694444112", "[[],\"13596603694444112\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%252Fchannel/leave", "{\"action\": \"leave\"}");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenAClientIsPresentedIfHereNowIsCalledThenItShouldReturnInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/v2/presence/sub_key/demo/channel/my%252Fchannel", "{\"uuids\":[\"eb4c1645-1319-4425-865f-008563009d67\"],\"occupancy\":1}");
#else
            data.Add("/v2/presence/sub_key/demo/channel/my%252Fchannel", "{\"uuids\":[\"eb4c1645-1319-4425-865f-008563009d67\"],\"occupancy\":1}");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenAMessageIsPublishedThenUnencryptPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"Pubnub Messaging API 1\"],13557486057035336,13559006802662769]");
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22Pubnub%20Messaging%20API%201%22", "[1,\"Sent\",\"13559014566792817\"]");
#else
            data.Add("/publish/demo/demo/0/my/channel/0/%22Pubnub%20Messaging%20API%201%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"Pubnub Messaging API 1\"],13557486057035336,13559006802662769]");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenAMessageIsPublishedThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%7B%22foo%22%3A%22hi%21%22%2C%22bar%22%3A%5B1%2C2%2C3%2C4%2C5%5D%7D", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]}],13557486057035336,13559006802662769]");
#else
            data.Add("/publish/demo/demo/0/my/channel/0/%7B%22foo%22%3A%22hi%21%22%2C%22bar%22%3A%5B1%2C2%2C3%2C4%2C5%5D%7D", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]}],13557486057035336,13559006802662769]");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenAMessageIsPublishedThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\"],13559215464464812,13559215464464812]");
#else
            data.Add("/publish/demo/demo/0/my/channel/0/%22nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\"],13559215464464812,13559215464464812]");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenAMessageIsPublishedThenEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22%2BBY5%2FmiAA8aeuhVl4d13Kg%3D%3D%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"+BY5/miAA8aeuhVl4d13Kg==\"],13557486057035336,13559006802662769]");
#else
            data.Add("/publish/demo/demo/0/my/channel/0/%22%2BBY5/miAA8aeuhVl4d13Kg%3D%3D%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"+BY5/miAA8aeuhVl4d13Kg==\"],13557486057035336,13559006802662769]");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenAMessageIsPublishedThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/3f75435fcd800f5d0476fc0fb5b572d1/my%2Fchannel/0/%22f42pIQcWZ9zbTbH8cyLwB%2FtdvRxjFLOYcBNMVKeHS54%3D%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\"],13559191494674157,13559191494674157]");
#else
            data.Add("/publish/demo/demo/3f75435fcd800f5d0476fc0fb5b572d1/my/channel/0/%22f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54%3D%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\"],13559191494674157,13559191494674157]");
#endif

            return data;
        }

        private Dictionary<string, string> LoadWhenAMessageIsPublishedThenComplexMessageObjectShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%7B%22VersionID%22%3A3%2E4%2C%22Timetoken%22%3A13601488652764619%2C%22OperationName%22%3A%22Publish%22%2C%22Channels%22%3A%5B%22ch1%22%5D%2C%22DemoMessage%22%3A%7B%22DefaultMessage%22%3A%22%7E%21%40%23%24%25%5E%26%2A%28%29_%2B%20%601234567890-%3D%20qwertyuiop%5B%5D%5C%5C%20%7B%7D%7C%20asdfghjkl%3B%27%20%3A%5C%22%20zxcvbnm%2C%2E%2F%20%3C%3E%3F%20%22%7D%2C%22CustomMessage%22%3A%7B%22DefaultMessage%22%3A%22Welcome%20to%20the%20world%20of%20Pubnub%20for%20Publish%20and%20Subscribe%2E%20Hah%21%22%7D%2C%22SampleXml%22%3A%7B%22DemoRoot%22%3A%7B%22Person%22%3A%5B%7B%22%40ID%22%3A%22ABCD123%22%2C%22Name%22%3A%7B%22First%22%3A%22John%22%2C%22Middle%22%3A%22P%2E%22%2C%22Last%22%3A%22Doe%22%7D%2C%22Address%22%3A%7B%22Street%22%3A%22123%20Duck%20Street%22%2C%22City%22%3A%22New%20City%22%2C%22State%22%3A%22New%20York%22%2C%22Country%22%3A%22United%20States%22%7D%7D%2C%7B%22%40ID%22%3A%22ABCD456%22%2C%22Name%22%3A%7B%22First%22%3A%22Peter%22%2C%22Middle%22%3A%22Z%2E%22%2C%22Last%22%3A%22Smith%22%7D%2C%22Address%22%3A%7B%22Street%22%3A%2212%20Hollow%20Street%22%2C%22City%22%3A%22Philadelphia%22%2C%22State%22%3A%22Pennsylvania%22%2C%22Country%22%3A%22United%20States%22%7D%7D%5D%7D%7D%7D", "[1,\"Sent\",\"13602210467298480\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[{\"VersionID\":3.4,\"Timetoken\":13601488652764619,\"OperationName\":\"Publish\",\"Channels\":[\"ch1\"],\"DemoMessage\":{\"DefaultMessage\":\"~!@#$%^&*()_+ `1234567890-= qwertyuiop[]\\\\ {}| asdfghjkl;' :\\\" zxcvbnm,./ <>? \"},\"CustomMessage\":{\"DefaultMessage\":\"Welcome to the world of Pubnub for Publish and Subscribe. Hah!\"},\"SampleXml\":{\"DemoRoot\":{\"Person\":[{\"@ID\":\"ABCD123\",\"Name\":{\"First\":\"John\",\"Middle\":\"P.\",\"Last\":\"Doe\"},\"Address\":{\"Street\":\"123 Duck Street\",\"City\":\"New City\",\"State\":\"New York\",\"Country\":\"United States\"}},{\"@ID\":\"ABCD456\",\"Name\":{\"First\":\"Peter\",\"Middle\":\"Z.\",\"Last\":\"Smith\"},\"Address\":{\"Street\":\"12 Hollow Street\",\"City\":\"Philadelphia\",\"State\":\"Pennsylvania\",\"Country\":\"United States\"}}]}}}],13602274270564989,13602274270564989]");
#else
            data.Add("/publish/demo/demo/0/my/channel/0/%7B%22VersionID%22%3A3%2E4%2C%22Timetoken%22%3A13601488652764619%2C%22OperationName%22%3A%22Publish%22%2C%22Channels%22%3A%5B%22ch1%22%5D%2C%22DemoMessage%22%3A%7B%22DefaultMessage%22%3A%22%7E%21%40%23%24%25%5E%26%2A%28%29_%2B%20%601234567890-%3D%20qwertyuiop%5B%5D%5C%5C%20%7B%7D%7C%20asdfghjkl%3B%27%20%3A%5C%22%20zxcvbnm%2C%2E%2F%20%3C%3E%3F%20%22%7D%2C%22CustomMessage%22%3A%7B%22DefaultMessage%22%3A%22Welcome%20to%20the%20world%20of%20Pubnub%20for%20Publish%20and%20Subscribe%2E%20Hah%21%22%7D%2C%22SampleXml%22%3A%7B%22DemoRoot%22%3A%7B%22Person%22%3A%5B%7B%22%40ID%22%3A%22ABCD123%22%2C%22Name%22%3A%7B%22First%22%3A%22John%22%2C%22Middle%22%3A%22P%2E%22%2C%22Last%22%3A%22Doe%22%7D%2C%22Address%22%3A%7B%22Street%22%3A%22123%20Duck%20Street%22%2C%22City%22%3A%22New%20City%22%2C%22State%22%3A%22New%20York%22%2C%22Country%22%3A%22United%20States%22%7D%7D%2C%7B%22%40ID%22%3A%22ABCD456%22%2C%22Name%22%3A%7B%22First%22%3A%22Peter%22%2C%22Middle%22%3A%22Z%2E%22%2C%22Last%22%3A%22Smith%22%7D%2C%22Address%22%3A%7B%22Street%22%3A%2212%20Hollow%20Street%22%2C%22City%22%3A%22Philadelphia%22%2C%22State%22%3A%22Pennsylvania%22%2C%22Country%22%3A%22United%20States%22%7D%7D%5D%7D%7D%7D", "[1,\"Sent\",\"13602210467298480\"]");
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[{\"VersionID\":3.4,\"Timetoken\":13601488652764619,\"OperationName\":\"Publish\",\"Channels\":[\"ch1\"],\"DemoMessage\":{\"DefaultMessage\":\"~!@#$%^&*()_+ `1234567890-= qwertyuiop[]\\\\ {}| asdfghjkl;' :\\\" zxcvbnm,./ <>? \"},\"CustomMessage\":{\"DefaultMessage\":\"Welcome to the world of Pubnub for Publish and Subscribe. Hah!\"},\"SampleXml\":{\"DemoRoot\":{\"Person\":[{\"@ID\":\"ABCD123\",\"Name\":{\"First\":\"John\",\"Middle\":\"P.\",\"Last\":\"Doe\"},\"Address\":{\"Street\":\"123 Duck Street\",\"City\":\"New City\",\"State\":\"New York\",\"Country\":\"United States\"}},{\"@ID\":\"ABCD456\",\"Name\":{\"First\":\"Peter\",\"Middle\":\"Z.\",\"Last\":\"Smith\"},\"Address\":{\"Street\":\"12 Hollow Street\",\"City\":\"Philadelphia\",\"State\":\"Pennsylvania\",\"Country\":\"United States\"}}]}}}],13602274270564989,13602274270564989]");
#endif

            return data;
        }

        private Dictionary<string, string> LoadWhenAMessageIsPublishedThenOptionalSecretKeyShouldBeProvidedInConstructor()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/d759c756abbd45a9864adc7f2b91393e/my%2Fchannel/0/%22Pubnub%20API%20Usage%20Example%22", "[1,\"Sent\",\"13559014566792817\"]");
#else
            data.Add("/publish/demo/demo/d759c756abbd45a9864adc7f2b91393e/my/channel/0/%22Pubnub%20API%20Usage%20Example%22", "[1,\"Sent\",\"13559014566792817\"]");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenAMessageIsPublishedIfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/publish/demo/demo/0/my%2Fchannel/0/%22Pubnub%20API%20Usage%20Example%22", "[1,\"Sent\",\"13559014566792817\"]");
#else
            data.Add("/publish/demo/demo/0/my/channel/0/%22Pubnub%20API%20Usage%20Example%22", "[1,\"Sent\",\"13559014566792817\"]");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenDetailedHistoryIsRequestedDetailHistoryCount10ReturnsRecords()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"+BY5/miAA8aeuhVl4d13Kg==\",\"Pubnub API Usage Example\",\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]},\"Pubnub Messaging API 1\"],13559191494674157,13559319777162196]");
#else
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"+BY5/miAA8aeuhVl4d13Kg==\",\"Pubnub API Usage Example\",\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]},\"Pubnub Messaging API 1\"],13559191494674157,13559319777162196]");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenDetailedHistoryIsRequestedDetailHistoryCount10ReverseTrueReturnsRecords()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"+BY5/miAA8aeuhVl4d13Kg==\",\"Pubnub API Usage Example\",\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]},\"Pubnub Messaging API 1\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 0\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 1\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 3\"],13557486057035336,13557486128690220]");
#else
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"+BY5/miAA8aeuhVl4d13Kg==\",\"Pubnub API Usage Example\",\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]},\"Pubnub Messaging API 1\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 0\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 1\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 3\"],13557486057035336,13557486128690220]");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenDetailedHistoryIsRequestedDetailedHistoryStartWithReverseTrue()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/v2/history/sub-key/demo/channel/my%252Fchannel", "[[\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 0\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 1\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 2\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 3\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 4\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 5\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 6\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 7\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 8\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 9\"],13559326456056557,13559327017296315]");
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

        private Dictionary<string, string> LoadWhenGetRequestServerTimeThenItShouldReturnTimeStamp()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/time/0", "[13559011090230537]");
            return data;
        }

        private Dictionary<string, string> LoadWhenGetRequestServerTimeThenWithProxyItShouldReturnTimeStamp()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/time/0", "[13559011090230537]");
            return data;
        }

        private Dictionary<string, string> LoadWhenSubscribedToAChannelThenSubscribeShouldReturnReceivedMessage()
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

        private Dictionary<string, string> LoadWhenSubscribedToAChannelThenSubscribeShouldReturnConnectStatus()
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

        private Dictionary<string, string> LoadWhenSubscribedToAChannelThenMultiSubscribeShouldReturnConnectStatus()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/subscribe/demo/my%2Fchannel1/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my%2Fchannel1/0/13559006802662768", "[[],\"13559006802662768\"]");

            data.Add("/subscribe/demo/my%2Fchannel1,my%2Fchannel2/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my%2Fchannel1,my%2Fchannel2/0/13559006802662768", "[[],\"13559006802662768\"]");
#else
            data.Add("/subscribe/demo/my/channel1/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my/channel1/0/13559006802662768", "[[],\"13559006802662768\"]");

            data.Add("/subscribe/demo/my/channel2,my/channel1/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my/channel2,my/channel1/0/13559006802662768", "[[],\"13559006802662768\"]");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenSubscribedToAChannelThenDuplicateChannelShouldReturnAlreadySubscribed()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/subscribe/demo/my%2Fchannel/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/13559006802662768", "[[],\"13559006802662768\"]");
#else
            data.Add("/subscribe/demo/my/channel/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my/channel/0/13559006802662768", "[[],\"13559006802662768\"]");
#endif
            return data;
        }

        private Dictionary<string, string> LoadWhenSubscribedToAChannelThenSubscriberShouldBeAbleToReceiveManyMessages()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/subscribe/demo/my%2Fchannel/0/0", "[[],\"13602645380839594\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/13602645380839594", "[[742730406,1853970548,1899616327,1043229779,1270838952,788288787,627599385,1517373321,1202317119,184893837],\"13602645382888692\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/13602645382888692", "[[],\"13602645382888692\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%2Fchannel/leave", "{\"action\": \"leave\"}");
#else
            data.Add("/subscribe/demo/my/channel/0/0", "[[],\"13602645380839594\"]");
            data.Add("/subscribe/demo/my/channel/0/13602645380839594", "[[742730406,1853970548,1899616327,1043229779,1270838952,788288787,627599385,1517373321,1202317119,184893837],\"13602645382888692\"]");
            data.Add("/subscribe/demo/my/channel/0/13602645382888692", "[[],\"13602645382888692\"]");
            data.Add("/v2/presence/sub_key/demo/channel/my%252Fchannel/leave", "{\"action\": \"leave\"}");
#endif
            return data;
        }


        private Dictionary<string, string> LoadWhenUnsubscribedToAChannelThenShouldReturnUnsubscribedMessage()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/subscribe/demo/my%2Fchannel/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my%2Fchannel/0/13559006802662768", "[[],\"13559006802662768\"]");
#else
            data.Add("/subscribe/demo/my/channel/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/my/channel/0/13559006802662768", "[[],\"13559006802662768\"]");
#endif
            return data;
        }

        public string GetStubResponse(Uri request)
        {
            Dictionary<string, string> responseDictionary = null;
            string stubResponse = "!! Stub Response Not Assigned !!";
            System.Diagnostics.Debug.WriteLine(string.Format("{0} - {1}",_testClassName,_testCaseName));
            switch (_testClassName)
            {
                case "WhenAClientIsPresented":
                    switch (_testCaseName)
                    {
                        case "ThenPresenceShouldReturnReceivedMessage":
                            responseDictionary = LoadWhenAClientIsPresentedThenPresenceShouldReturnReceivedMessage();
                            break;
                        case "ThenPresenceShouldReturnCustomUUID":
                            responseDictionary = LoadWhenAClientIsPresentedThenPresenceShouldReturnCustomUUID();
                            break;
                        case "IfHereNowIsCalledThenItShouldReturnInfo":
                            responseDictionary = LoadWhenAClientIsPresentedIfHereNowIsCalledThenItShouldReturnInfo();
                            break;
                        default:
                            break;
                    }
                    break;
                case "WhenAMessageIsPublished":
                    switch (_testCaseName)
                    {
                        case "ThenUnencryptPublishShouldReturnSuccessCodeAndInfo":
                            responseDictionary = LoadWhenAMessageIsPublishedThenUnencryptPublishShouldReturnSuccessCodeAndInfo();
                            break;
                        case "ThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo":
                            responseDictionary = LoadWhenAMessageIsPublishedThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo();
                            break;
                        case "ThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo":
                            responseDictionary = LoadWhenAMessageIsPublishedThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo();
                            break;
                        case "ThenEncryptPublishShouldReturnSuccessCodeAndInfo":
                            responseDictionary = LoadWhenAMessageIsPublishedThenEncryptPublishShouldReturnSuccessCodeAndInfo();
                            break;
                        case "ThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo":
                            responseDictionary = LoadWhenAMessageIsPublishedThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo();
                            break;
                        case "ThenComplexMessageObjectShouldReturnSuccessCodeAndInfo":
                            responseDictionary = LoadWhenAMessageIsPublishedThenComplexMessageObjectShouldReturnSuccessCodeAndInfo();
                            break;
                        case "ThenOptionalSecretKeyShouldBeProvidedInConstructor":
                            responseDictionary = LoadWhenAMessageIsPublishedThenOptionalSecretKeyShouldBeProvidedInConstructor();
                            break;
                        case "IfSSLNotProvidedThenDefaultShouldBeFalse":
                            responseDictionary = LoadWhenAMessageIsPublishedIfSSLNotProvidedThenDefaultShouldBeFalse();
                            break;
                        default:
                            break;
                    }
                    break;
                case "WhenDetailedHistoryIsRequested":
                    switch (_testCaseName)
                    {
                        case "DetailHistoryCount10ReturnsRecords":
                            responseDictionary = LoadWhenDetailedHistoryIsRequestedDetailHistoryCount10ReturnsRecords();
                            break;
                        case "DetailHistoryCount10ReverseTrueReturnsRecords":
                            responseDictionary = LoadWhenDetailedHistoryIsRequestedDetailHistoryCount10ReverseTrueReturnsRecords();
                            break;
                        case "DetailedHistoryStartWithReverseTrue":
                            responseDictionary = LoadWhenDetailedHistoryIsRequestedDetailedHistoryStartWithReverseTrue();
                            break;
                        default:
                            break;
                    }
                    break;
                case "WhenGetRequestServerTime":
                    switch (_testCaseName)
                    {
                        case "ThenItShouldReturnTimeStamp":
                            responseDictionary = LoadWhenGetRequestServerTimeThenItShouldReturnTimeStamp();
                            break;
                        case "ThenWithProxyItShouldReturnTimeStamp":
                            responseDictionary = LoadWhenGetRequestServerTimeThenWithProxyItShouldReturnTimeStamp();
                            break;
                        default:
                            break;
                    }
                    break;
                case "WhenSubscribedToAChannel":
                    switch (_testCaseName)
                    {
                        case "ThenSubscribeShouldReturnReceivedMessage":
                            responseDictionary = LoadWhenSubscribedToAChannelThenSubscribeShouldReturnReceivedMessage();
                            break;
                        case "ThenSubscribeShouldReturnConnectStatus":
                            responseDictionary = LoadWhenSubscribedToAChannelThenSubscribeShouldReturnConnectStatus();
                            break;
                        case "ThenMultiSubscribeShouldReturnConnectStatus":
                            responseDictionary = LoadWhenSubscribedToAChannelThenMultiSubscribeShouldReturnConnectStatus();
                            break;
                        case "ThenDuplicateChannelShouldReturnAlreadySubscribed":
                            responseDictionary = LoadWhenSubscribedToAChannelThenDuplicateChannelShouldReturnAlreadySubscribed();
                            break;
                        case "ThenSubscriberShouldBeAbleToReceiveManyMessages":
                            responseDictionary = LoadWhenSubscribedToAChannelThenSubscriberShouldBeAbleToReceiveManyMessages();
                            break;
                        default:
                            break;
                    }
                    break;
                case "WhenUnsubscribedToAChannel":
                    switch (_testCaseName)
                    {
                        case "ThenShouldReturnUnsubscribedMessage":
                            responseDictionary = LoadWhenUnsubscribedToAChannelThenShouldReturnUnsubscribedMessage();
                            break;
                        default:
                            break;
                    }
                    break;
                default:
                    break;
            }

            if (responseDictionary != null && responseDictionary.ContainsKey(request.AbsolutePath))
            {
                stubResponse = responseDictionary[request.AbsolutePath];
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
