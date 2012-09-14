using System;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;

namespace silverlight
{
    public interface Callback
    {
        bool responseCallback(string channel, object message);

        void errorCallback(String channel, Object message);

        void connectCallback(String channel);

        void reconnectCallback(String channel);

        void disconnectCallback(String channel);
    }    
}
