using System;
using PubNubMessaging.Core;
using System.Collections.Generic;
using System.ComponentModel;

namespace PubNubMessaging.Tests
{
  public class Common
  {
        public object Response { get; set; }
        public bool DeliveryStatus  { get; set; }

        public PubnubUnitTest CreateUnitTestInstance(string testClassName, string testCaseName)
        {
          PubnubUnitTest unitTest = new PubnubUnitTest();
          unitTest.TestClassName = testClassName;
          unitTest.TestCaseName = testCaseName;
          return unitTest;
        }
        
        public void DisplayReturnMessageDummy(object result)
        {
          //deliveryStatus = true;
          Response = result;
        }

        public void DisplayReturnMessage(object result)
        {
            DeliveryStatus = true;
            Response = result;
        }

        public long Timestamp(Pubnub pubnub)
        {
            DeliveryStatus = false;

            pubnub.Time(DisplayReturnMessage);
            while (!DeliveryStatus) ;

            IList<object> fields = Response as IList<object>;
            return Convert.ToInt64(fields[0].ToString());
        }
  }
}

