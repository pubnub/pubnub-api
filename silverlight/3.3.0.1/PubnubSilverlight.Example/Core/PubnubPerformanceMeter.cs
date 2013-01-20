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
using System.Collections.Generic;
using System.Threading;

namespace PubNub_Messaging
{
    public class PubnubPerformanceMeter
    {
        public int NumberOfPublications { get; set; }

        private readonly List<double> median = new List<double>();
        public List<double> Median
        {
            get { return median; }
        }

        public int Medlen { get; set; }

        public double AverageLatency { get; set; }

        public bool IsWorks { get; set; }

        private Random random = new Random();

        private string message = "demo";

        private double startPublishTime;

        private string pub_key;

        private string sub_key;

        private string channel;

        private Pubnub pubnub = null;

        private int maxLatency;

        private int publishInterval;

        public PubnubPerformanceMeter(string pub_key, string sub_key, string channel, int maxLatency, int publishInterval)
        {
            this.pub_key = string.IsNullOrEmpty(pub_key) ? "demo" : pub_key;

            this.sub_key = string.IsNullOrEmpty(sub_key) ? "demo" : sub_key;

            this.channel = string.IsNullOrEmpty(channel) ? GetChannel() : channel;

            this.maxLatency = maxLatency;

            this.publishInterval = publishInterval;

            pubnub = new Pubnub(this.pub_key, this.sub_key);
        }

        public void Start()
        {
            NumberOfPublications = 0;

            AverageLatency = 0.0d;

            median.Clear();

            IsWorks = true;

            Publish();
        }

        public void Stop()
        {
            IsWorks = false;
        }

        private void DisplayReturnMessage(object result)
        {
            NumberOfPublications++;
            double latency = GetTime() - startPublishTime;
            AverageLatency = Math.Floor((latency + AverageLatency) / 2);

            median.Add(latency);

            UpdateMedian();

            Thread.Sleep(publishInterval);

            if (IsWorks)
            {
                Publish();
            }
        }

        private void Publish()
        {
            startPublishTime = GetTime();

            pubnub.publish(channel, message, DisplayReturnMessage);
        }

        private void UpdateMedian()
        {
            int length = median.Count - 1;
            Medlen = (int)Math.Floor(length / 2.0d);
            median.Sort();
        }

        public double GetMedian(double value)
        {
            int lenght = median.Count - 1;
            return median[Medlen + (int)Math.Floor(lenght * value)];
        }

        public double GetMedianLow(double value)
        {
            int lenght = median.Count - 1;
            return median[(int)Math.Floor(lenght * value)];
        }

        private double GetTime()
        {
            return Math.Floor((DateTime.Now - new DateTime(1970, 1, 1)).TotalMilliseconds);
        }

        private string GetChannel()
        {
            return "performance-meter-" + Math.Floor(GetTime() + random.NextDouble());
        }
    }
}
