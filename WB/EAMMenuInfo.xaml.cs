using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
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
using WB.Interface;
using WB.UC;

namespace WB
{
    /// <summary>
    /// EAMMenuInfo.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class EAMMenuInfo : UCBase
    {
        private EAMMenuInfoData model;
       
        public EAMMenuInfo()
        {
            InitializeComponent();
            this.model = DataContext as EAMMenuInfoData;
            this.model.thisWindow = this;
            this.searchText.Focus();
            this.KeyDown -= FocusSearchText;
            this.KeyDown += FocusSearchText;
        }      

        private void TextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
                this.model.EAMMenuInfoCommand.Execute(null);
        }

        private void GridSplitter_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            try
            {
                grdMain.ColumnDefinitions[0].Width = new GridLength(0.7, GridUnitType.Star);
                grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                grdMain.ColumnDefinitions[2].Width = new GridLength(0.3, GridUnitType.Star);
            }
            catch (Exception)
            {

            }
        }
        private void FocusSearchText(object sender, RoutedEventArgs e)
        {
            if (Keyboard.IsKeyDown(Key.LeftCtrl) && Keyboard.IsKeyDown(Key.F))
                this.searchText.Focus();           
            if (Keyboard.IsKeyDown(Key.F1))
            {
                try
                {
                    if (this.grdMain.ColumnDefinitions[2].Width == new GridLength(0, GridUnitType.Star))
                    {
                        this.grdMain.ColumnDefinitions[0].Width = new GridLength(0.7, GridUnitType.Star);
                        this.grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                        this.grdMain.ColumnDefinitions[2].Width = new GridLength(0.3, GridUnitType.Star);
                    }
                    else if (this.grdMain.ColumnDefinitions[2].Width != new GridLength(0, GridUnitType.Star))
                    {
                        this.grdMain.ColumnDefinitions[0].Width = new GridLength(0.7, GridUnitType.Star);
                        this.grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                        this.grdMain.ColumnDefinitions[2].Width = new GridLength(0, GridUnitType.Star);
                    }
                }
                catch (Exception)
                { }
            }
        }

        private void searchText_TextChanged(object sender, TextChangedEventArgs e)
        {
            BindingExpression bindingExpression = ((TextBox)sender).GetBindingExpression(TextBox.TextProperty);
            bindingExpression.UpdateSource();
        }

        public void ShowMsgBox(string msg,int timeout)
        {
            this.OwnerWindow.ShowMsgBox(msg, timeout);
        }

        public ObservableCollection<BasicSetting> GetBasicSetting() => this.OwnerWindow.OcBasicSetting;
    }
}
