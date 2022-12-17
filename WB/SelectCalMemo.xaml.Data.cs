using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Controls;
using System.Windows.Input;
using WB.Common;
using WB.DAC;
using WB.DTO;

namespace WB
{
    public class SelectCalMemoData : ViewModelBase
    {
        #region [dac]
        //SelectCalTestDL dac = new SelectCalTestDL();
        #endregion
        #region [Constructor]
        public SelectCalMemoData()
        {
            if (LicenseManager.UsageMode == LicenseUsageMode.Designtime) return;
            this.Init();
        }
        #endregion
        #region [View Property]
        public static Calendar thisWindow;
        public SelectCalMemo thisView;

        private ObservableCollection<DateTime> holiday = new ObservableCollection<DateTime>();
        /// <summary>
        /// 
        /// </summary>
        public ObservableCollection<DateTime> HOLIDAY
        {
            get { return this.holiday; }
            set { if (this.holiday != value) { this.holiday = value; OnPropertyChanged("HOLIDAY", value); } }
        }


        #endregion
        #region [Member Property]
        private string sel_memo_date;
        /// <summary>
        /// 
        /// </summary>
        public string SEL_MEMO_DATE
        {
            get { return this.sel_memo_date; }
            set { if (this.sel_memo_date != value) { this.sel_memo_date = value; OnPropertyChanged("SEL_MEMO_DATE", value); } }
        }

        private string sel_memo_text;
        /// <summary>
        /// 
        /// </summary>
        public string SEL_MEMO_TEXT
        {
            get { return this.sel_memo_text; }
            set { if (this.sel_memo_text != value) { this.sel_memo_text = value; OnPropertyChanged("SEL_MEMO_TEXT", value); } }
        }


        #endregion
        #region [Command]
        //private ICommand autoChgTextCommand;
        ///// <summary>
        ///// name         : DataType 리스트
        ///// desc         : DataType 리스트
        ///// author       : 오원빈
        ///// create date  : 2022-10-18
        ///// update date  : 2022-10-18
        ///// </summary>
        ///// <remarks></remarks>
        //public ICommand AutoChgTextCommand
        //{
        //    get
        //    {
        //        if (autoChgTextCommand == null)
        //            autoChgTextCommand = new RelayCommand(p => this.AutoChgText(p));
        //        return autoChgTextCommand;
        //    }
        //}
        #endregion
        #region [Method]
        /// <summary>
        /// name         : ViewModel 초기화
        /// desc         : ViewModel을 초기화함
        /// author       : ohwonbin 
        /// create date  : 2022-07-11 오전 8:44:06
        /// update date  : 최종 수정 일자, 수정자, 수정개요 
        /// </summary>
        private void Init()
        {
            SEL_MEMO_DATE = SEL_MEMO_DATE != null ? SEL_MEMO_DATE : DateTime.Now.ToString("yyyy-MM-dd");
            
        }

        public void GetHoliDay(CalendarBlackoutDatesCollection col)
        {
          
        }

        public void UpdateCalendarBlackoutDates()
        {            
            // Because we can't reach the real calendar from the viewmodel, and we can't create a
            // new CalendarBlackoutDatesCollection without specifying a Calendar to
            // the constructor, we provide a "Dummy calendar", only to satisfy
            // the CalendarBlackoutDatesCollection...
            // because you can't do: BlackoutDates = new CalendarBlackoutDatesCollection().            
            HOLIDAY.Add(DateTime.Now);
            HOLIDAY.Add(DateTime.Now.AddDays(2));
            HOLIDAY.Add(DateTime.Now.AddDays(3));
            HOLIDAY.Add(DateTime.Now.AddDays(7));
        }
        public void GetCalendarText()
        {
            if (this.USERINFO.MY_CAL_LIST == null) return;
            this.SEL_MEMO_TEXT = this.USERINFO.MY_CAL_LIST.Where(d => d.MEMO_DATE == this.SEL_MEMO_DATE).Select(d => d.MEMO_TEXT).FirstOrDefault();
        }
        #endregion
    }
}
