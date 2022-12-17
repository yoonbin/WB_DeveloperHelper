using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

namespace WB
{
    /// <summary>
    /// WBMsgBox.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class WBMsgBox : Window, IDisposable
    {
        public WBMsgBox()
        {
            InitializeComponent();
        }
        public WBMsgBox(string msg)
        {
            InitializeComponent();
            var enterCnt = msg.Split(new char[] {'\n','\r' });
            if(enterCnt.Count() > 0)
            {
                this.grdYesNoMsgBox.Height = 90 + ((enterCnt.Count()-1) * 60);
            }
            tbYesNoMsgBox.Text = msg;
        }
        private bool yesOrNo;
        public bool YesOrNo
        {
            get => this.yesOrNo;
            set => this.yesOrNo = value;
        }
        public void Dispose()
        {
           
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            this.YesOrNo = true;
            Close();
        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            this.YesOrNo = false;
            Close();
        }
    }
}
