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
using Microsoft.Phone.Controls;

namespace PubnubWindowsPhone
{
    public partial class MainPage : PhoneApplicationPage
    {
        // Constructor
        public MainPage()
        {
            InitializeComponent();

            //Border border = new Border();
            //border.BorderBrush = new SolidColorBrush(Colors.Black);
            //border.BorderThickness = new Thickness(5.0);

            //StackPanel panel1 = new StackPanel();
            //panel1.Background = new SolidColorBrush(Colors.Black);
            //panel1.Width = 600;
            //panel1.Height = 600;

            //Popup popup = new Popup();
            //popup.Height = 300;
            //popup.Width = 300;
            //popup.VerticalOffset = 100;
            //popup.HorizontalOffset = 100;
            //PubnubInit control = new PubnubInit();
            //panel1.Children.Add(control);
            //border.Child = panel1;

            //popup.Child = border;
            //popup.IsOpen = true;
            //control.btnSubmit.Click += (s, args) =>
            //{
            //    popup.IsOpen = false;
            //    channel = control.txtChannel.Text;
            //    ssl = control.chkSSL.IsChecked.Value;
            //    cipherKey = control.txtChipher.Text;
            //    secretKey = control.txtSecret.Text;
            //};
            //control.btnCancel.Click += (s, args) =>
            //{
            //    popup.IsOpen = false;
            //};
            //pubnub = new Pubnub("demo", "demo", secretKey, cipherKey, ssl);
        }

        private void btnContinue_Click(object sender, RoutedEventArgs e)
        {
            string channel = txtChannel.Text.Trim();
            bool ssl = chkSSL.IsChecked.Value;
            string secretKey = txtSecret.Text;
            string cipherKey = txtCipher.Text;


            Uri nextPage = new Uri(string.Format("/PubnubOperation.xaml?channel={0}&ssl={1}&cipherkey={2}&secretkey={3}",channel,ssl,cipherKey,secretKey), UriKind.Relative);
            NavigationService.Navigate(nextPage);
        }

        private void HandleListResult(WebResponse response)
        {
            using (var stream = response.GetResponseStream())
            {
                using (var reader = new System.IO.StreamReader(stream, false))
                {
                    string str = reader.ReadToEnd();
                    Deployment.Current.Dispatcher.BeginInvoke(() => MessageBox.Show(str));
                    reader.Close();
                }
                stream.Close();
            }
        }

        private void HandleListResultTimeOut(Exception ex)
        {
            Deployment.Current.Dispatcher.BeginInvoke(()=>MessageBox.Show(ex.ToString()));
        }


    }


}