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
using WB.UC;

namespace WB
{
    /// <summary>
    /// TabPopup.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class TabPopup : Window, IDisposable
    {
        public TabPopup()
        {
            InitializeComponent();
        }
        public TabPopup(string type_name , MainWindow window)
        {
            InitializeComponent();

            Type t = Type.GetType(type_name);

            if (t == null) return;

            object uc = Activator.CreateInstance(t);
            //(uc as UCBase).OwnerWindow = window;
            
            ctcTabPopup.Content = uc;
            
        }

        public void Dispose()
        {
           
        }
    }
}
