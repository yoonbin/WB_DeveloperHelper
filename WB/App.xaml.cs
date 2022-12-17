using System;
using System.CodeDom.Compiler;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;

namespace WB
{
    /// <summary>
    /// App.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class App : Application
    {
        private bool _contentLoaded;

        protected override void OnStartup(StartupEventArgs e)
        {
            EventManager.RegisterClassHandler(typeof(TextBox), UIElement.GotFocusEvent, (Delegate)new RoutedEventHandler(this.TextBox_GotFocus));
            base.OnStartup(e);
        }

        private void TextBox_GotFocus(object sender, RoutedEventArgs e) => (sender as TextBox).SelectAll();

        //[DebuggerNonUserCode]
        //[GeneratedCode("PresentationBuildTasks", "4.0.0.0")]
        //public void InitializeComponent()
        //{
        //    if (this._contentLoaded)
        //        return;
        //    this._contentLoaded = true;
        //    this.StartupUri = new Uri("MainWindow.xaml", UriKind.Relative);
        //    Application.LoadComponent((object)this, new Uri("/WB;component/app.xaml", UriKind.Relative));
        //}

        //[STAThread]
        //[DebuggerNonUserCode]
        //[GeneratedCode("PresentationBuildTasks", "4.0.0.0")]
        //public static void Main()
        //{
        //    App app = new App();
        //    app.InitializeComponent();
        //    app.Run();
        //}
    }
}
