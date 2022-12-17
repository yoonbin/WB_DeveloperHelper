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
    /// SelectUserInfo.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class SelectUserInfo : UCBase
    {
        private SelectUserInfoData model;

        public SelectUserInfo()
        {
            InitializeComponent();
            this.model = DataContext as SelectUserInfoData;
        }

        private void UCBase_Loaded(object sender, RoutedEventArgs e)
        {
            txtSearch.Focus();
        }

        private void RadioButton_Checked(object sender, RoutedEventArgs e)
        {
            if (txtSearch is null) return;
            
            txtSearch.Focus();
            if(!string.IsNullOrWhiteSpace(txtSearch.Text))
                this.model.SelectUserInfoCommand.Execute(null);
        }
    }
}
