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

namespace SpeedMetterControl
{
    public partial class SpeedMetter : UserControl
    {
        public SpeedMetter()
        {
            InitializeComponent();
        }

        public double Value
        {
            get { return (double)GetValue(ValueProperty); }
            set { SetValue(ValueProperty, value); }
        }

        public double MinValue
        {
            get { return (double)GetValue(MinValueProperty); }
            set { SetValue(MinValueProperty, value); }
        }

        // Using a DependencyProperty as the backing store for MinValue.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty MinValueProperty =
            DependencyProperty.Register("MinValue", typeof(double), typeof(SpeedMetter), new PropertyMetadata(0.0d));


        public double MaxValue
        {
            get { return (double)GetValue(MaxValueProperty); }
            set { SetValue(MaxValueProperty, value); }
        }

        // Using a DependencyProperty as the backing store for MaxValue.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty MaxValueProperty =
            DependencyProperty.Register("MaxValue", typeof(double), typeof(SpeedMetter), new PropertyMetadata(100.0d));

        

        // Using a DependencyProperty as the backing store for Value.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty ValueProperty =
            DependencyProperty.Register("Value", typeof(double), typeof(SpeedMetter), new PropertyMetadata(0.0d, new PropertyChangedCallback(OnValueChanged)));

        private static void OnValueChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            var conrol = d as SpeedMetter;
            var arrow = conrol.ARROW;
            double percentFromMaxValue = conrol.MaxValue / 100.0d;

            double angle = Math.Round((double)e.NewValue / percentFromMaxValue * (90 / 100.0f));

            if ((double)e.NewValue > 0.0d)
            {
                if (arrow.RenderTransform == null || !(arrow.RenderTransform is RotateTransform))
                {
                    arrow.RenderTransform = new RotateTransform();
                }
                DoubleAnimation da = new DoubleAnimation
                {
                    To = Convert.ToInt32(angle),
                    Duration = TimeSpan.FromSeconds(0.2),
                    EasingFunction = new ElasticEase() { EasingMode = EasingMode.EaseOut }
                };
                Storyboard.SetTarget(da, arrow.RenderTransform);
                Storyboard.SetTargetProperty(da, new PropertyPath(RotateTransform.AngleProperty));
                Storyboard sb = new Storyboard();
                sb.Children.Add(da);
                sb.Begin();

                conrol.txtDelayValue.Text = e.NewValue + "MS";
            }
        }
    }
}
