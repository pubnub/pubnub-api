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
using Microsoft.Silverlight.Testing.Controls;
using Microsoft.Silverlight.Testing.Client;
using PubnubSilverlight.UnitTest;

namespace PubnubSilverlight.Example.Views
{
    public partial class CodeUnitTestView : Page
    {
        public CodeUnitTestView()
        {
            InitializeComponent();

            var page = Instance.GetPage;

            ContainerForTest.Children.Add(page);

            (page as TestPage).TreeView.SelectedItemChanged += new RoutedPropertyChangedEventHandler<object>(TreeView_SelectedItemChanged);
        }

        void TreeView_SelectedItemChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
           var tree = sender as Microsoft.Silverlight.Testing.Controls.TreeView;
               
           tree.ExpandAll();
        }

        // Executes when the user navigates to this page.
        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
        }

    }
}
