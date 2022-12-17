using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Threading;
using WB.DTO;
using WB.UC;

namespace WB
{
    /// <summary>
    /// SelectCalTest.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class SelectCalMemo : UCBase
    {
        private SelectCalMemoData model;
        public ICollectionView view;
        private Style calendarDayBtnStyle = new Style();
        private DataTrigger dataTrigger = new DataTrigger();
        public SelectCalMemo()
        {
            InitializeComponent();
            this.model = DataContext as SelectCalMemoData;
            this.model.thisView = this;
            //this.model.HOLIDAY = new CalendarBlackoutDatesCollection(this.calTest);
            //this.model.HOLIDAY.Add(new CalendarDateRange(DateTime.Now.AddDays(1), DateTime.Now.AddDays(10)));            
            //this.model.UpdateCalendarBlackoutDates();
            this.calMemo.SelectedDatesChanged -= calTest_SelectedDatesChanged;
            this.calMemo.SelectedDatesChanged += calTest_SelectedDatesChanged;
            this.model.LoadUserInfo();
            //데이터 필터부분.
            SetFilter(this.model.USERINFO.MY_CAL_LIST);
            if (this.model.USERINFO.MY_CAL_LIST != null && this.model.USERINFO.MY_CAL_LIST.Count > 0)
            {
                model.SEL_MEMO_TEXT = this.model.USERINFO.MY_CAL_LIST.Where(d => d.MEMO_DATE == model.SEL_MEMO_DATE).Select(d => d.MEMO_TEXT).FirstOrDefault();
            }
            SelectToDay();
            SetDataTrigger();
        }
        private void SetDataTrigger()
        {
            try
            {
                Style dayButtonStyle = new Style(typeof(CalendarDayButton)) { BasedOn = (Style)this.Resources["styCalendarDay"] };
                foreach (var item in this.model.USERINFO.MY_CAL_LIST)
                {
                    if (this.model.SEL_MEMO_DATE != item.MEMO_DATE)
                    {
                        dataTrigger = new DataTrigger() { Binding = new Binding("Date"), Value = Convert.ToDateTime(item.MEMO_DATE) };
                        dataTrigger.Setters.Add(new Setter(CalendarDayButton.BackgroundProperty, Brushes.SandyBrown));
                        dayButtonStyle.Triggers.Add(dataTrigger);
                    }
                }
                calMemo.CalendarDayButtonStyle = dayButtonStyle;
            }
            catch(Exception ex)
            {
                this.OwnerWindow.ShowErrorMsgBox(ex.ToString());
            }
        }
        private void SelectToDay()
        {
            DateTime runTime = DateTime.ParseExact("00:00:00", "HH:mm:ss", System.Globalization.CultureInfo.InvariantCulture);
            TimeSpan diffDate = runTime - DateTime.ParseExact(DateTime.Now.ToString("HH:mm:ss"), "HH:mm:ss", System.Globalization.CultureInfo.InvariantCulture);
            int hour = 0;
            int minute = 0;
            int second = 0;
            if (diffDate.Seconds < 0)
            {
                if(runTime.Hour - DateTime.Now.Hour == 0)
                {
                    hour = runTime.Hour - DateTime.Now.Hour + 23;
                }
                else if(runTime.Hour == 0)
                {
                    hour = runTime.Hour - DateTime.Now.Hour + 23;
                }
                else
                {
                    hour = runTime.Hour - DateTime.Now.Hour + 24;
                }
                second = diffDate.Seconds + 60;
                minute = diffDate.Minutes + 59;
            }
            else
            {
                if (runTime.Hour - DateTime.Now.Hour == 0)
                {
                    hour = runTime.Hour - DateTime.Now.Hour;
                }
                else
                {
                    hour = runTime.Hour - DateTime.Now.Hour + 1; 
                }
                second = diffDate.Seconds;
                minute = diffDate.Minutes;
            }
            try
            {
                Timer timer = new Timer();
                timer.Interval = 1000 * ((hour * 3600) + (minute * 60) + second);
                timer.Elapsed += (ElapsedEventHandler)((_param1, _param2) => System.Windows.Application.Current.Dispatcher.BeginInvoke((Delegate)(() =>
                {
                    if (hour != 24)
                    {
                        hour = 24;
                        timer.Interval = hour * 3600 * 1000;
                    }
                    this.calMemo.SelectedDate = DateTime.Now;
                    this.calMemo.DisplayDate = DateTime.Now;
                    this.txtMemo.FocusTextBox();
                }), DispatcherPriority.Send));
                timer.Enabled = true;
            }
            catch
            {

            }

        }
        private void SelectMyMemo_LostFocus(object sender, RoutedEventArgs e)
        {
            SelectCalMemo_INOUT inObj = new SelectCalMemo_INOUT();
            inObj.MEMO_DATE = this.model.SEL_MEMO_DATE;            
            inObj.MEMO_TEXT = this.model.SEL_MEMO_TEXT;
            if (this.model.USERINFO.MY_CAL_LIST.Where(d => d.MEMO_DATE == inObj.MEMO_DATE).Count() > 0)
            {
                if(string.IsNullOrEmpty(inObj.MEMO_TEXT))
                {
                    this.model.USERINFO.MY_CAL_LIST.Where(d => d.MEMO_DATE == inObj.MEMO_DATE).Cast<SelectCalMemo_INOUT>().ToList().ForEach(x => this.model.USERINFO.MY_CAL_LIST.Remove(x));
                }
                else
                    this.model.USERINFO.MY_CAL_LIST.Where(d => d.MEMO_DATE == inObj.MEMO_DATE).Cast<SelectCalMemo_INOUT>().ToList().ForEach(x => x.MEMO_TEXT = inObj.MEMO_TEXT);
            }
            else if (!string.IsNullOrEmpty(this.model.SEL_MEMO_TEXT))
                this.model.USERINFO.MY_CAL_LIST.Add(inObj);

            this.model.SaveUserInfo();

            this.SetDataTrigger();
        }

        private void calTest_SelectedDatesChanged(object sender, SelectionChangedEventArgs e)
        {            
            this.model.GetCalendarText();
            this.model.LoadUserInfo();
            //데이터 필터부분.
            SetFilter(this.model.USERINFO.MY_CAL_LIST);            
            this.SetDataTrigger();
        }
        public void SetFilter(List<SelectCalMemo_INOUT> list)
        {
            //데이터 필터부분.
            if (list != null && list.Count > 0)
            {
                view = CollectionViewSource.GetDefaultView(list);
                view.Filter = CustomerFilter;
                this.view.SortDescriptions.Add(new SortDescription("MEMO_DATE", ListSortDirection.Ascending));                
            }
        }
        /// <summary>
        /// 검색
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        private bool CustomerFilter(object item)
        {
            bool filter = true;            

            SelectCalMemo_INOUT code_list = item as SelectCalMemo_INOUT;

            if((bool)this.chkToday.IsChecked)
            {
                if (DateTime.Compare(Convert.ToDateTime(code_list.MEMO_DATE), Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd"))) < 0)
                    filter = false;
                else
                    filter = true;
            }            
            return filter;

        }
        private void calMemo_PreviewMouseUp(object sender, MouseButtonEventArgs e)
        {
            if (Mouse.Captured is CalendarItem)
            {
                Mouse.Capture(null);
            }
        }

        private void GridSplitter_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            try
            {
                grdMain.ColumnDefinitions[0].Width = new GridLength(0.15, GridUnitType.Star);
                grdMain.ColumnDefinitions[1].Width = new GridLength(7);
                grdMain.ColumnDefinitions[2].Width = new GridLength(0.7, GridUnitType.Star);
            }
            catch (Exception)
            {

            }
        }

        private void DataGrid_MouseUp(object sender, MouseButtonEventArgs e)
        {
            SelectCalMemo_INOUT item = ((DataGrid)sender).SelectedItem as SelectCalMemo_INOUT;
            if (item is null) return;
            this.calMemo.SelectedDate = DateTime.ParseExact(item.MEMO_DATE,"yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture);
            this.calMemo.DisplayDate = DateTime.ParseExact(item.MEMO_DATE, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture);
            this.txtMemo.FocusTextBox();
        }

        private void chkToday_Checked(object sender, RoutedEventArgs e)
        {
            if (view != null)
                view.Refresh();
        }

        private void chkToday_Unchecked(object sender, RoutedEventArgs e)
        {
            if (view != null)
                view.Refresh();
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            SelectCalMemo_INOUT item = this.model.ConvertCellToRow<SelectCalMemo_INOUT>(this.dgrdMemoList.SelectedCells).FirstOrDefault();
            if (item is null) return;
            this.model.USERINFO.MY_CAL_LIST.Remove(item);
            this.model.SaveUserInfo();
            this.model.LoadUserInfo();
            SetFilter(this.model.USERINFO.MY_CAL_LIST);
            this.SetDataTrigger();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                this.calMemo.SelectedDate = DateTime.ParseExact(DateTime.Now.ToString("yyyy-MM-dd"), "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture);
                this.calMemo.DisplayDate = DateTime.ParseExact(DateTime.Now.ToString("yyyy-MM-dd"), "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture);
                this.txtMemo.FocusTextBox();
            }
            catch
            {

            }
        }
    }
}
