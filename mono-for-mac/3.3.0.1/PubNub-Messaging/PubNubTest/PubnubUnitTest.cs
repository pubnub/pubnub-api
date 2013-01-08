using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PubNub_Messaging;

namespace PubNubTest
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

        private Dictionary<string, string> Load_WhenAClientIsPresented_ThenPresenceShouldReturnReceivedMessageCipher()
        {
          Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
      data.Add("/subscribe/demo/hello_world-pnpres/0/0", "[[],\"13559007117760880\"]");
      data.Add("/subscribe/demo/hello_world-pnpres/0/13559007117760880", "[[{\"action\": \"join\", \"timestamp\": 1355929955, \"uuid\": \"eb4c1645-1319-4425-865f-008563009d67\", \"occupancy\": 1}],\"13559011560379628\"]");
      data.Add("/subscribe/demo/hello_world-pnpres/0/13559011560379628", "[[],\"13559011560379628\"]");
      data.Add("/subscribe/demo/hello_world/0/0", "[[],\"13559006802662768\"]");
      data.Add("/subscribe/demo/hello_world/0/13559006802662768", "[[\"f7wNXpx8Ys8pVJNR5ZHT9g==\"],\"13559014566792816\"]");
      data.Add("/subscribe/demo/hello_world/0/13559014566792816", "[[],\"13559014566792816\"]");
#else
      data.Add("/subscribe/demo/hello_world-pnpres/0/0", "[[],\"13559007117760880\"]");
      data.Add("/subscribe/demo/hello_world-pnpres/0/13559007117760880", "[[{\"action\": \"join\", \"timestamp\": 1355929955, \"uuid\": \"eb4c1645-1319-4425-865f-008563009d67\", \"occupancy\": 1}],\"13559011560379628\"]");
      data.Add("/subscribe/demo/hello_world-pnpres/0/13559011560379628", "[[],\"13559011560379628\"]");
      data.Add("/subscribe/demo/hello_world/0/0", "[[],\"13559006802662768\"]");
      data.Add("/subscribe/demo/hello_world/0/13559006802662768", "[[\"f7wNXpx8Ys8pVJNR5ZHT9g==\"],\"13559014566792816\"]");      
      data.Add("/subscribe/demo/hello_world/0/13559014566792816", "[[],\"13559014566792816\"]");

#endif
          data.Add("/v2/presence/sub_key/demo/channel/hello_world/leave", "{\"action\": \"leave\"}");
          return data;
        }

        private Dictionary<string, string> Load_WhenAClientIsPresented_ThenPresenceShouldReturnReceivedMessage()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
#if ((!__MonoCS__) && (!SILVERLIGHT) && (!WINDOWS_PHONE))
            data.Add("/subscribe/demo/hello_world-pnpres/0/0", "[[],\"13559007117760880\"]");
            data.Add("/subscribe/demo/hello_world-pnpres/0/13559007117760880", "[[{\"action\": \"join\", \"timestamp\": 1355929955, \"uuid\": \"eb4c1645-1319-4425-865f-008563009d67\", \"occupancy\": 1}],\"13559011560379628\"]");
            data.Add("/subscribe/demo/hello_world-pnpres/0/13559011560379628", "[[],\"13559011560379628\"]");
            data.Add("/subscribe/demo/hello_world/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/hello_world/0/13559006802662768", "[[\"demo test for stubs\"],\"13559014566792816\"]");
            data.Add("/subscribe/demo/hello_world/0/13559014566792816", "[[],\"13559014566792816\"]");
#else
      data.Add("/subscribe/demo/hello_world-pnpres/0/0", "[[],\"13559007117760880\"]");
      data.Add("/subscribe/demo/hello_world-pnpres/0/13559007117760880", "[[{\"action\": \"join\", \"timestamp\": 1355929955, \"uuid\": \"eb4c1645-1319-4425-865f-008563009d67\", \"occupancy\": 1}],\"13559011560379628\"]");
      data.Add("/subscribe/demo/hello_world-pnpres/0/13559011560379628", "[[],\"13559011560379628\"]");
      data.Add("/subscribe/demo/hello_world/0/0", "[[],\"13559006802662768\"]");
      data.Add("/subscribe/demo/hello_world/0/13559006802662768", "[[\"demo test for stubs\"],\"13559014566792816\"]");
      data.Add("/subscribe/demo/hello_world/0/13559014566792816", "[[],\"13559014566792816\"]");
#endif
            data.Add("/v2/presence/sub_key/demo/channel/hello_world/leave", "{\"action\": \"leave\"}");
            return data;
        }

        private Dictionary<string, string> Load_WhenAClientIsPresented_IfHereNowIsCalledThenItShouldReturnInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/presence/sub_key/demo/channel/hello_world", "{\"uuids\":[\"eb4c1645-1319-4425-865f-008563009d67\"],\"occupancy\":1}");
            return data;
        }

        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenItShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/publish/demo/demo/0/hello_world/0/\"Pubnub API Usage Example\"", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"Pubnub API Usage Example\"],13557486057035336,13559006802662769]");
            return data;
        }

        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenUnencryptPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/publish/demo/demo/0/hello_world/0/\"Pubnub Messaging API 1\"", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"Pubnub Messaging API 1\"],13557486057035336,13559006802662769]");
            return data;
        }

        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenUnencryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/publish/demo/demo/0/hello_world/0/%7B%22foo%22%3A%22hi%21%22%2C%22bar%22%3A%5B1%2C2%2C3%2C4%2C5%5D%7D", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]}],13557486057035336,13559006802662769]");
            return data;
        }

        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenEncryptObjectPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/publish/demo/demo/0/hello_world/0/%22nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\"],13559215464464812,13559215464464812]");
            return data;
        }

        
        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/publish/demo/demo/0/hello_world/0/%22%2BBY5%2FmiAA8aeuhVl4d13Kg%3D%3D%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"+BY5/miAA8aeuhVl4d13Kg==\"],13557486057035336,13559006802662769]");
            return data;
        }

        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenSecretKeyWithEncryptPublishShouldReturnSuccessCodeAndInfo()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/publish/demo/demo/3f75435fcd800f5d0476fc0fb5b572d1/hello_world/0/%22f42pIQcWZ9zbTbH8cyLwB%2FtdvRxjFLOYcBNMVKeHS54%3D%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\"],13559191494674157,13559191494674157]");
            return data;
        }

        private Dictionary<string, string> Load_WhenAMessageIsPublished_ThenOptionalSecretKeyShouldBeProvidedInConstructor()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/publish/demo/demo/d759c756abbd45a9864adc7f2b91393e/hello_world/0/%22Pubnub%20API%20Usage%20Example%22", "[1,\"Sent\",\"13559014566792817\"]");
            return data;
        }

        private Dictionary<string, string> Load_WhenAMessageIsPublished_IfSSLNotProvidedThenDefaultShouldBeFalse()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/publish/demo/demo/0/hello_world/0/%22Pubnub%20API%20Usage%20Example%22", "[1,\"Sent\",\"13559014566792817\"]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestEncryptedDetailedHistory()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"EyKRq4Bzi1V44Lwz9i/cZw==\",\"BIWan5yOqIz3a0hAinJJ9Q==\",\"2x9t3rbm6Jr6YcCCuWCRdQ==\",\"NmPPeaSVnChejVR44rFJ5Q==\",\"y4FSc7Y9IEEoEmtDAJO3FQ==\",\"QByvge9lb/3H008RfX+VRA==\",\"tEJ1HKlGhYklpZqZLUDQjA==\",\"XZGNx138XpiwS5aVESXuYg==\",\"ayWFXhv+qv09Gj+I/ooNQQ==\",\"4N2LhvhnPG3v3bvWuqEb0g==\"],13561926677985130,13561926705714509]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestUnencryptedDetailedHistory()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"0\",\"1\",\"2\",\"3\",\"4\",\"5\",\"6\",\"7\",\"8\",\"9\"],13561931614319981,13561931641037537]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_DetailedHistory_Decrypted_Example()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"f7wNXpx8Ys8pVJNR5ZHT9g==\"],13561993102217562,13561993102217562]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_ItShouldReturnDetailedHistory()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"Test message\"],13561916644576302,13561916644576302]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestEncryptedSecretDetailedHistoryParams1()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"EyKRq4Bzi1V44Lwz9i/cZw==\",\"BIWan5yOqIz3a0hAinJJ9Q==\",\"2x9t3rbm6Jr6YcCCuWCRdQ==\",\"NmPPeaSVnChejVR44rFJ5Q==\",\"y4FSc7Y9IEEoEmtDAJO3FQ==\"],13561997459447496,13561997470537187]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestEncryptedSecretDetailedHistoryParams2()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"QByvge9lb/3H008RfX+VRA==\",\"tEJ1HKlGhYklpZqZLUDQjA==\",\"XZGNx138XpiwS5aVESXuYg==\",\"ayWFXhv+qv09Gj+I/ooNQQ==\",\"4N2LhvhnPG3v3bvWuqEb0g==\"],13561997475925030,13561997486798712]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestEncryptedSecretDetailedHistoryParams3()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"EyKRq4Bzi1V44Lwz9i/cZw==\",\"BIWan5yOqIz3a0hAinJJ9Q==\",\"2x9t3rbm6Jr6YcCCuWCRdQ==\",\"NmPPeaSVnChejVR44rFJ5Q==\",\"y4FSc7Y9IEEoEmtDAJO3FQ==\"],13561997459447496,13561997470537187]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestUnencryptedSecretDetailedHistoryParams1()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"0\",\"1\",\"2\",\"3\",\"4\"],13561998607085158,13561998618677990]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestUnencryptedSecretDetailedHistoryParams2()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"5\",\"6\",\"7\",\"8\",\"9\"],13561998626205890,13561998636560986]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestUnencryptedSecretDetailedHistoryParams3()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"0\",\"1\",\"2\",\"3\",\"4\"],13561998607085158,13561998618677990]");
            return data;        
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestEncryptedDetailedHistoryParams1()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"EyKRq4Bzi1V44Lwz9i/cZw==\",\"BIWan5yOqIz3a0hAinJJ9Q==\",\"2x9t3rbm6Jr6YcCCuWCRdQ==\",\"NmPPeaSVnChejVR44rFJ5Q==\",\"y4FSc7Y9IEEoEmtDAJO3FQ==\"],13561885846793689,13561885857459163]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestEncryptedDetailedHistoryParams2()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"QByvge9lb/3H008RfX+VRA==\",\"tEJ1HKlGhYklpZqZLUDQjA==\",\"XZGNx138XpiwS5aVESXuYg==\",\"ayWFXhv+qv09Gj+I/ooNQQ==\",\"4N2LhvhnPG3v3bvWuqEb0g==\"],13561885862589838,13561885872731649]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestEncryptedDetailedHistoryParams3()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"EyKRq4Bzi1V44Lwz9i/cZw==\",\"BIWan5yOqIz3a0hAinJJ9Q==\",\"2x9t3rbm6Jr6YcCCuWCRdQ==\",\"NmPPeaSVnChejVR44rFJ5Q==\",\"y4FSc7Y9IEEoEmtDAJO3FQ==\"],13561885846793689,13561885857459163]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestUnencryptedDetailedHistoryParams1()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"0\",\"1\",\"2\",\"3\",\"4\"],13561969547888925,13561969560429174]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestUnencryptedDetailedHistoryParams2()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"5\",\"6\",\"7\",\"8\",\"9\"],13561969565962377,13561969576984085]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_TestUnencryptedDetailedHistoryParams3()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"0\",\"1\",\"2\",\"3\",\"4\"],13561969547888925,13561969560429174]");
            return data;        
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_DetailHistoryCount10ReturnsRecords()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"+BY5/miAA8aeuhVl4d13Kg==\",\"Pubnub API Usage Example\",\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]},\"Pubnub Messaging API 1\"],13559191494674157,13559319777162196]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_DetailHistoryCount10ReverseTrueReturnsRecords()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"Pubnub API Usage Example\",\"nQTUCOeyWWgWh5NRLhSlhIingu92WIQ6RFloD9rOZsTUjAhD7AkMaZJVgU7l28e2\",\"+BY5/miAA8aeuhVl4d13Kg==\",\"Pubnub API Usage Example\",\"f42pIQcWZ9zbTbH8cyLwB/tdvRxjFLOYcBNMVKeHS54=\",{\"foo\":\"hi!\",\"bar\":[1,2,3,4,5]},\"Pubnub Messaging API 1\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 0\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 1\",\"DetailedHistoryStartTimeWithReverseTrue 13557486100000000 3\"],13557486057035336,13557486128690220]");
            return data;
        }

        private Dictionary<string, string> Load_WhenDetailedHistoryIsRequested_DetailedHistoryStartWithReverseTrue()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/v2/history/sub-key/demo/channel/hello_world", "[[\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 0\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 1\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 2\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 3\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 4\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 4\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 6\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 7\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 8\",\"DetailedHistoryStartTimeWithReverseTrue 13559326410000000 9\"],13559326456056557,13559327017296315]");
            data.Add("/publish/demo/demo/0/hello_world/0/%22DetailedHistoryStartTimeWithReverseTrue%200%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/hello_world/0/%22DetailedHistoryStartTimeWithReverseTrue%201%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/hello_world/0/%22DetailedHistoryStartTimeWithReverseTrue%202%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/hello_world/0/%22DetailedHistoryStartTimeWithReverseTrue%203%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/hello_world/0/%22DetailedHistoryStartTimeWithReverseTrue%204%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/hello_world/0/%22DetailedHistoryStartTimeWithReverseTrue%205%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/hello_world/0/%22DetailedHistoryStartTimeWithReverseTrue%206%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/hello_world/0/%22DetailedHistoryStartTimeWithReverseTrue%207%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/hello_world/0/%22DetailedHistoryStartTimeWithReverseTrue%208%22", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/publish/demo/demo/0/hello_world/0/%22DetailedHistoryStartTimeWithReverseTrue%209%22", "[1,\"Sent\",\"13559014566792817\"]");
            return data;
        }

        private Dictionary<string, string> Load_WhenGetRequestServerTime_ThenItShouldReturnTimeStamp()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/time/0", "[13559011090230537]");
            return data;
        }

        private Dictionary<string, string> Load_WhenSubscribedToAChannel_ThenSubscribeShouldReturnReceivedMessageCipher()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/subscribe/demo/hello_world/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/hello_world/0/13559006802662768", "[[\"f7wNXpx8Ys8pVJNR5ZHT9g==\"],\"13559014566792816\"]");
            data.Add("/subscribe/demo/hello_world/0/13559014566792816", "[[],\"13559014566792816\"]");
            data.Add("/publish/demo/demo/0/hello_world/0/\"f7wNXpx8Ys8pVJNR5ZHT9g==\"", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/presence/sub_key/demo/channel/hello_world/leave", "{\"action\": \"leave\"}");
            return data;
        }

        private Dictionary<string, string> Load_WhenSubscribedToAChannel_ThenSubscribeShouldReturnReceivedMessage()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/subscribe/demo/hello_world/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/hello_world/0/13559006802662768", "[[\"Test Message\"],\"13559014566792816\"]");
            data.Add("/subscribe/demo/hello_world/0/13559014566792816", "[[],\"13559014566792816\"]");
            data.Add("/publish/demo/demo/0/hello_world/0/\"Test Message\"", "[1,\"Sent\",\"13559014566792817\"]");
            data.Add("/v2/presence/sub_key/demo/channel/hello_world/leave", "{\"action\": \"leave\"}");
            return data;
        }

        private Dictionary<string, string> Load_WhenSubscribedToAChannel_ThenSubscribeShouldReturnConnectStatus()
        {
            Dictionary<string, string> data = new Dictionary<string, string>();
            data.Add("/subscribe/demo/hello_world/0/0", "[[],\"13559006802662768\"]");
            data.Add("/subscribe/demo/hello_world/0/13559006802662768", "[[],\"13559006802662768\"]");
            data.Add("/v2/presence/sub_key/demo/channel/hello_world/leave", "{\"action\": \"leave\"}");
            return data;
        }

        public string GetStubResponse(Uri request)
        {
            Dictionary<string,string> respDic = null;
            string response = "!! Stub Response Not Assigned !!";
            string lookUpString = request.PathAndQuery;
            switch (_testClassName)
            {
                case "WhenAClientIsPresented":
                    switch (_testCaseName)
                    {
                        case "ThenPresenceShouldReturnReceivedMessage":
                          respDic = Load_WhenAClientIsPresented_ThenPresenceShouldReturnReceivedMessage();
                          break;
                        case "ThenPresenceShouldReturnReceivedMessageCipher":
                          respDic = Load_WhenAClientIsPresented_ThenPresenceShouldReturnReceivedMessageCipher();
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
                        case "ThenItShouldReturnSuccessCodeAndInfo":
                            respDic = Load_WhenAMessageIsPublished_ThenItShouldReturnSuccessCodeAndInfo();
                            break;
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

                        case "DetailedHistory_Decrypted_Example":
                            respDic = Load_WhenDetailedHistoryIsRequested_DetailedHistory_Decrypted_Example();
                            break;
                        case "TestUnencryptedSecretDetailedHistoryParams1":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestUnencryptedSecretDetailedHistoryParams1();
                            break;
                        case "TestUnencryptedSecretDetailedHistoryParams2":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestUnencryptedSecretDetailedHistoryParams2();
                            break;
                        case "TestUnencryptedSecretDetailedHistoryParams3":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestUnencryptedSecretDetailedHistoryParams3();
                            break;
                        case "TestEncryptedSecretDetailedHistoryParams1":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestEncryptedSecretDetailedHistoryParams1();
                            break;
                        case "TestEncryptedSecretDetailedHistoryParams2":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestEncryptedSecretDetailedHistoryParams2();
                            break;
                        case "TestEncryptedSecretDetailedHistoryParams3":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestEncryptedSecretDetailedHistoryParams3();
                            break;
                        case "TestUnencryptedDetailedHistoryParams1":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestUnencryptedDetailedHistoryParams1();
                            break;
                        case "TestUnencryptedDetailedHistoryParams2":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestUnencryptedDetailedHistoryParams2();
                            break;
                        case "TestUnencryptedDetailedHistoryParams3":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestUnencryptedDetailedHistoryParams3();
                            break;
                        case "TestEncryptedDetailedHistory":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestEncryptedDetailedHistory();
                            break;
                        case "TestUnencryptedDetailedHistory":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestUnencryptedDetailedHistory();
                            break;
                        case "ItShouldReturnDetailedHistory":
                            respDic = Load_WhenDetailedHistoryIsRequested_ItShouldReturnDetailedHistory();
                            break;
                        case "TestEncryptedDetailedHistoryParams1":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestEncryptedDetailedHistoryParams1();
                            break;
                        case "TestEncryptedDetailedHistoryParams2":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestEncryptedDetailedHistoryParams2();
                            break;
                        case "TestEncryptedDetailedHistoryParams3":
                            respDic = Load_WhenDetailedHistoryIsRequested_TestEncryptedDetailedHistoryParams3();
                            break;
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
                        case "ThenSubscribeShouldReturnReceivedMessageCipher":
                            respDic = Load_WhenSubscribedToAChannel_ThenSubscribeShouldReturnReceivedMessageCipher();
                            break;    
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

            if (respDic != null && respDic.ContainsKey(request.LocalPath))
            {
                response = respDic[request.LocalPath];
            }

            return response;
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
