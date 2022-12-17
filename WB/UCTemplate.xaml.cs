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
using System.Windows.Navigation;
using System.Windows.Shapes;
using WB.UC;

namespace WB
{
    /// <summary>
    /// UCTemplate.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class UCTemplate : UCBase
    {
        private ViewModelBase model;

        public UCTemplate()
        {
            InitializeComponent();
            this.model = DataContext as ViewModelBase;
        }
    }
}
