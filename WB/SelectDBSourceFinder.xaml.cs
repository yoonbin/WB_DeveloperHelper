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
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Threading;
using WB.DTO;
using WB.UC;

namespace WB
{
    /// <summary>
    /// SelectDBSourceFinder.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class SelectDBSourceFinder : UCBase
    {
        private SelectDBSourceFinderData model;
        private DispatcherTimer timer;
        public SelectDBSourceFinder()
        {
            InitializeComponent();
            this.model = DataContext as SelectDBSourceFinderData;
            this.model.thisWindow = this;            
        }

        private void TextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
                this.model.SelectDBSourceFinderCommand.Execute(null);
        }

     
        private void TextBox_KeyDown_1(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                this.model.RefreshView(this.model.DB_VIEW);
                this.model.RefreshView(this.model.EQS_VIEW);
            }
        }

        private void TextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (timer == null) 
            {
                timer = new DispatcherTimer();
                timer.Interval = TimeSpan.FromMilliseconds(300);
                timer.Tick += new EventHandler(handleTypingTimerTimeout);
            }
            timer.Stop();
            timer.Tag = (sender as TextBox).Text;
            timer.Start();
        }
        private void handleTypingTimerTimeout(object sender, EventArgs e)
        {
            var timer = sender as DispatcherTimer; // WPF
            if (timer == null)
            {
                return;
            }
            //work
            this.model.RefreshView(this.model.DB_VIEW);
            this.model.RefreshView(this.model.EQS_VIEW);
            // The timer must be stopped! We want to act only once per keystroke.
            timer.Stop();
        }

        private void btnEqsGolden_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                SelectDBSourceFinder_INOUT selectedItem = this.model.ConvertCellToRow<SelectDBSourceFinder_INOUT>(this.dgrdEQS.SelectedCells).FirstOrDefault();
                this.StartGoldenCode(selectedItem.QUERYTEXT, selectedItem.NAME);
            }
            catch
            {

            }
        }

        private void btnEqsPLEdit_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                SelectDBSourceFinder_INOUT selectedItem = this.model.ConvertCellToRow<SelectDBSourceFinder_INOUT>(this.dgrdEQS.SelectedCells).FirstOrDefault();
                this.StartPLEditCode(selectedItem.QUERYTEXT, selectedItem.NAME);
            }
            catch
            {

            }
        }

        private void btnDBPLEdit_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                string code = "";
                SelectDBSourceFinder_INOUT selectedItem = this.model.ConvertCellToRow<SelectDBSourceFinder_INOUT>(this.dgrdDB.SelectedCells).FirstOrDefault();
                code = selectedItem.TYPE.ToUpper() != "VIEW" ? this.GetDBSourceText(selectedItem.NAME.Trim()) : this.GetViewSourceText(selectedItem.OWNER, selectedItem.NAME.Trim());
                this.StartPLEditCode(code, selectedItem.NAME);
            }
            catch
            {

            }
        }

        private void btnDBGolden_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                SelectDBSourceFinder_INOUT selectedItem = this.model.ConvertCellToRow<SelectDBSourceFinder_INOUT>(this.dgrdDB.SelectedCells).FirstOrDefault();
                
                this.StartGoldenCode(selectedItem.QUERYTEXT, selectedItem.NAME);
            }
            catch
            {

            }
        }

        public void ProgreesOn()
        {
            this.OwnerWindow.ProgressOn();
        }
        public void ProgreesOff()
        {
            this.OwnerWindow.ProgressOff();
        }
        public void ShowMsgBox(string msg,int time)
        {
            this.OwnerWindow.ShowMsgBox(msg,time);
        }

        private void GridSplitter_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            try
            {
                grdMain.ColumnDefinitions[0].Width = new GridLength(1, GridUnitType.Star);
                grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                grdMain.ColumnDefinitions[2].Width = new GridLength(1, GridUnitType.Star);
            }
            catch (Exception)
            {

            }
        }

        public bool ShowYesNoMsgBox(string msg) => this.OwnerWindow.ShowYesNoMsgBox(msg);
    }
}
