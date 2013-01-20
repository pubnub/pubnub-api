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

namespace PubNub_Messaging
{
    public partial class PubnubDiagramItem : UserControl
    {
        public PubnubDiagramItem()
        {
            InitializeComponent();
            DataContext = this;
        }

        public void SetValue(int value, int min, int max)
        {
            Storyboard animation = new Storyboard();

            DoubleAnimation animationBock = new DoubleAnimation();

            animationBock.To = Math.Round((value / ((max - min) / 100.0f)) * (this.Height / 100.0f), 1);

            Value.Text = value.ToString();

            animationBock.Duration = new Duration(TimeSpan.FromSeconds(1));

            animation.Children.Add(animationBock);

            Storyboard.SetTarget(animationBock, Column);

            Storyboard.SetTargetProperty(animationBock, new PropertyPath("(Rectangle.Height)"));

            animation.Begin();
        }
    }
}
