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
using WB.DTO;
using WB.UC;

namespace WB
{
    /// <summary>
    /// SelectCommonCode.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class SelectCommonCode : UCBase
    {
        private SelectCommonCodeData model;

        public SelectCommonCode()
        {
            InitializeComponent();
            this.model = DataContext as SelectCommonCodeData;
            this.model.thisWindow = this;
            txtSearch.Focus();
        }
        private void GridSplitter_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            try
            {
                grdMain.ColumnDefinitions[0].Width = new GridLength(0.4, GridUnitType.Star);
                grdMain.ColumnDefinitions[1].Width = new GridLength(7);
                grdMain.ColumnDefinitions[2].Width = new GridLength(0.4, GridUnitType.Star);
                grdMain.ColumnDefinitions[3].Width = new GridLength(7);
                grdMain.ColumnDefinitions[4].Width = new GridLength(1, GridUnitType.Star);
            }
            catch (Exception)
            {

            }
        }
        public BasicSetting GetMetaConnection() => this.MetaConnection;

        public void ErrorMsg(string msg) => this.OwnerWindow.ShowErrorMsgBox(msg);

        private void UCBase_Loaded(object sender, RoutedEventArgs e)
        {
            if (model != null)
                this.model.LoadUserInfo();
        }
    }
}
