using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.Windows.Navigation;
using System.Windows.Threading;

namespace PubNub_Messaging
{
    public partial class CodePerformanceMeterView : Page
    {
        private DispatcherTimer timer = new DispatcherTimer();

        private PubnubPerformanceMeter meter = null;

        public CodePerformanceMeterView()
        {
            InitializeComponent();

            meter = new PubnubPerformanceMeter("", "", "", 2000, 300);

            timer.Interval = TimeSpan.FromSeconds(1);
            timer.Tick += new EventHandler(timer_Tick);

            meter.Start();

            timer.Start();
        }
  
        protected void timer_Tick(object sender, EventArgs e)
        {
            PublishCount.Text = meter.NumberOfPublications.ToString();

            Meter.MinValue = 0;
            Meter.MaxValue = 2000;

            Meter.Value = meter.AverageLatency > 2000 ? 2000 : meter.AverageLatency;

            try
            {
                int fastest = (int)meter.GetMedianLow(0.02);
                int value5 = (int)meter.GetMedianLow(0.05);
                int value10 = (int)meter.GetMedianLow(0.1);
                int value20 = (int)meter.GetMedianLow(0.2);
                int value25 = (int)meter.GetMedianLow(0.5);
                int value30 = (int)meter.GetMedianLow(0.6);
                int value40 = (int)meter.GetMedianLow(0.8);
                int value45 = (int)meter.GetMedianLow(0.9);

                int value50 = (int)meter.Median[meter.Medlen];
                int value66 = (int)meter.GetMedianLow(0.16);
                int value75 = (int)meter.GetMedianLow(0.25);
                int value80 = (int)meter.GetMedianLow(0.30);
                int value90 = (int)meter.GetMedianLow(0.40);
                int value95 = (int)meter.GetMedianLow(0.45);
                int value98 = (int)meter.GetMedianLow(0.48);
                int slowest = (int)meter.Median[meter.Median.Count - 1];


                txt_fastest.Value = fastest.ToString();
                txt_5.Value = value5.ToString();
                txt_10.Value = value10.ToString();
                txt_20.Value = value20.ToString();
                txt_25.Value = value25.ToString();
                txt_30.Value = value30.ToString();
                txt_40.Value = value40.ToString();
                txt_45.Value = value45.ToString();

                txt_50.Value = value50.ToString();
                txt_66.Value = value66.ToString();
                txt_75.Value = value75.ToString();
                txt_80.Value = value80.ToString();
                txt_90.Value = value90.ToString();
                txt_95.Value = value95.ToString();
                txt_98.Value = value98.ToString();
                txt_slowest.Value = slowest.ToString();

                g_fastest.SetValue(fastest, 0, slowest);
                g_5.SetValue(value5, 0, slowest);
                g_10.SetValue(value10, 0, slowest);
                g_20.SetValue(value20, 0, slowest);
                g_25.SetValue(value25, 0, slowest);
                g_30.SetValue(value30, 0, slowest);
                g_40.SetValue(value40, 0, slowest);
                g_45.SetValue(value45, 0, slowest);

                g_50.SetValue(value50, 0, slowest);
                g_66.SetValue(value66, 0, slowest);
                g_75.SetValue(value75, 0, slowest);
                g_80.SetValue(value80, 0, slowest);
                g_90.SetValue(value90, 0, slowest);
                g_95.SetValue(value95, 0, slowest);
                g_98.SetValue(value98, 0, slowest);
                g_slowest.SetValue(slowest, 0, slowest);

            }
            catch { }
        }
    }
}
