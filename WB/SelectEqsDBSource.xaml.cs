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
    /// SelectEqsDBSource.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class SelectEqsDBSource : UCBase
    {
        private SelectEqsDBSourceData model;
        
        public bool IsSelectWithStart = false;  

        public SelectEqsDBSource()
        {
            InitializeComponent();
            this.model = DataContext as SelectEqsDBSourceData;
            this.model.thisWindow = this;
            this.txtCode.Focus();            
            this.KeyDown -= FocusSearchText;
            this.KeyDown += FocusSearchText;


            if (this.IsSelectWithStart)
            {
                if (!this.OwnerWindow.IsSettingCompleted)
                {
                    this.OwnerWindow.ShowMsgBox("Setting탭에서 DB세팅해주세요.", 3000);
                    return;
                }
                this.IsSelectWithStart = false;
            }

        }
        
        private void TextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
                this.model.SelectEqsDBSourceCommand.Execute(null);
        }
        
        private void FocusSearchText(object sender, RoutedEventArgs e)
        {            
            if (Keyboard.IsKeyDown(Key.F1))
            {
                try
                {
                    if (this.grdMain.ColumnDefinitions[2].Width == new GridLength(0, GridUnitType.Star))
                    {
                        this.grdMain.ColumnDefinitions[0].Width = new GridLength(1, GridUnitType.Star);
                        this.grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                        this.grdMain.ColumnDefinitions[2].Width = new GridLength(0.3, GridUnitType.Star);
                    }
                    else if (this.grdMain.ColumnDefinitions[2].Width != new GridLength(0, GridUnitType.Star))
                    {
                        this.grdMain.ColumnDefinitions[0].Width = new GridLength(1, GridUnitType.Star);
                        this.grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                        this.grdMain.ColumnDefinitions[2].Width = new GridLength(0, GridUnitType.Star);
                    }
                }
                catch(Exception)
                { }
            }
        }     

        private void GridSplitter_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            try
            {
                grdMain.ColumnDefinitions[0].Width = new GridLength(1, GridUnitType.Star);
                grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                grdMain.ColumnDefinitions[2].Width = new GridLength(0.3, GridUnitType.Star);
            }
            catch (Exception)
            {

            }
        }

        private void btnGolden_Click(object sender, RoutedEventArgs e)
        {
            string title = "";
            title = this.model.QUERY_ID;
            this.StartGoldenCode(txtCode.Text, title);
        }

        private void btnPlEdit_Click(object sender, RoutedEventArgs e)
        {
            string title = "";
            title = this.model.QUERY_ID;
            this.StartPLEditCode(txtCode.Text, title);
        }

        public string GetViewSource(string owner,string objName) => this.GetViewSourceText(owner, objName);
    }

}
