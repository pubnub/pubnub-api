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
using System.Windows.Threading;

namespace silverlight
{
    public static class UIThread
    {
        public static readonly Dispatcher Dispatcher;

        static UIThread()
        {
            Dispatcher = Deployment.Current.Dispatcher;
        }
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
        public static void Invoke(Action action)
        {
            if (Dispatcher.CheckAccess())
            {
                action.Invoke();
            }
            else
            {
                Dispatcher.BeginInvoke(action);
            }

        }
    }

}
