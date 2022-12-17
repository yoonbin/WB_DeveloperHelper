using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Timers;
using System.Windows.Data;
using System.Windows.Input;
using System.Windows.Threading;
using WB.Common;
using WB.DAC;
using WB.DTO;

namespace WB
{
    public class SelectDBSourceFinderData : ViewModelBase
    {
        #region [dac]
        SelectDBSourceFinderDL dac = new SelectDBSourceFinderDL();
        #endregion
        #region [Constructor]
        public SelectDBSourceFinderData()
        {
            if (LicenseManager.UsageMode == LicenseUsageMode.Designtime) return;
            this.Init();
        }
        #endregion
        #region [View Property]
        private Thread DBthread;
        private Thread EQSThread;
        private DispatcherTimer timer;
        public SelectDBSourceFinder thisWindow;

        private bool abort_yn = false;
        /// <summary>
        /// 
        /// </summary>
        public bool ABORT_YN
        {
            get { return this.abort_yn; }
            set { if (this.abort_yn != value) { this.abort_yn = value; OnPropertyChanged("ABORT_YN", value); } }
        }


        private string text;
        /// <summary>
        /// 
        /// </summary>
        public string TEXT
        {
            get { return this.text; }
            set { if (this.text != value) { this.text = value; OnPropertyChanged("TEXT", value); } }
        }

        private ICollectionView eqs_view;
        /// <summary>
        /// 
        /// </summary>
        public ICollectionView EQS_VIEW
        {
            get { return this.eqs_view; }
            set { if (this.eqs_view != value) { this.eqs_view = value; OnPropertyChanged("EQS_VIEW", value); } }
        }

        private ICollectionView db_view;
        /// <summary>
        /// 
        /// </summary>
        public ICollectionView DB_VIEW
        {
            get { return this.db_view; }
            set { if (this.db_view != value) { this.db_view = value; OnPropertyChanged("DB_VIEW", value); } }
        }

        private string keyward;
        /// <summary>
        /// 
        /// </summary>
        public string KEYWARD
        {
            get { return this.keyward; }
            set { if (this.keyward != value) { this.keyward = value; OnPropertyChanged("KEYWARD", value); } }
        }




        #endregion
        #region [Member Property]
        private SelectDBSourceFinder_INOUT eqssource_sel;
        /// <summary>
        /// name         :  선택 DTO
        /// desc         :  선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-12-01
        /// update date  : 2022-12-01
        /// </summary>
        /// <remarks></remarks>
        public SelectDBSourceFinder_INOUT EQSSOURCE_SEL
        {
            get { return this.eqssource_sel; }
            set { if (this.eqssource_sel != value) { this.eqssource_sel = value; OnPropertyChanged("EQSSOURCE_SEL", value); } }
        }



        private List<SelectDBSourceFinder_INOUT> eqssource_list = new List<SelectDBSourceFinder_INOUT>();
        /// <summary>
        /// name         :  리스트
        /// desc         :  리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-12-01
        /// update date  : 2022-12-01
        /// </summary>
        /// <remarks></remarks>
        public List<SelectDBSourceFinder_INOUT> EQSSOURCE_LIST
        {
            get { return this.eqssource_list; }
            set { if (this.eqssource_list != value) { this.eqssource_list = value; OnPropertyChanged("EQSSOURCE_LIST", value); } }
        }


        private SelectDBSourceFinder_INOUT dbsourcefinder_sel;
        /// <summary>
        /// name         : DB조회 선택 DTO
        /// desc         : DB조회 선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-30
        /// update date  : 2022-11-30
        /// </summary>
        /// <remarks></remarks>
        public SelectDBSourceFinder_INOUT DBSOURCEFINDER_SEL
        {
            get { return this.dbsourcefinder_sel; }
            set { if (this.dbsourcefinder_sel != value) { this.dbsourcefinder_sel = value; OnPropertyChanged("DBSOURCEFINDER_SEL", value); } }
        }



        private List<SelectDBSourceFinder_INOUT> dbsourcefinder_list = new List<SelectDBSourceFinder_INOUT>();
        /// <summary>
        /// name         : DB조회 리스트
        /// desc         : DB조회 리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-30
        /// update date  : 2022-11-30
        /// </summary>
        /// <remarks></remarks>
        public List<SelectDBSourceFinder_INOUT> DBSOURCEFINDER_LIST
        {
            get { return this.dbsourcefinder_list; }
            set { if (this.dbsourcefinder_list != value) { this.dbsourcefinder_list = value; OnPropertyChanged("DBSOURCEFINDER_LIST", value); } }
        }


        #endregion
        #region [Command]
        private ICommand selectDBSourceFinderCommand;
        /// <summary>
        /// name         : DB조회
        /// desc         : DB조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-30
        /// update date  : 2022-11-30
        /// </summary>
        /// <remarks></remarks>
        public ICommand SelectDBSourceFinderCommand
        {
            get
            {
                if (selectDBSourceFinderCommand == null)
                    selectDBSourceFinderCommand = new RelayCommand(p => this.SelectDBSourceFinder(p));
                return selectDBSourceFinderCommand;
            }
        }
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
        }
        /// <summary>
        /// name         : DB조회
        /// desc         : DB조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-30
        /// update date  : 2022-11-30
        /// </summary>
        /// <remarks></remarks>
        private void SelectDBSourceFinder(object p)
        {
            if (string.IsNullOrEmpty(this.TEXT))
            {
                if (!thisWindow.ShowYesNoMsgBox("전체 Object 조회시 조회시간이 길어질 수 있습니다. \n                그럼에도 조회하시겠습니까?" ))
                {
                    return;
                }
            }

            thisWindow.grdMain.IsEnabled = false;
            DBthread = new Thread(new ThreadStart(SelectDBSource));
            DBthread.Start();
            thisWindow.ProgreesOn();
                        
            System.Timers.Timer timer = new System.Timers.Timer((double)300)
            {
                AutoReset = true
            };
            timer.Elapsed += (ElapsedEventHandler)((_param1, _param2) => System.Windows.Application.Current.Dispatcher.BeginInvoke((Delegate)(() =>
            {                
                if(!DBthread.IsAlive)
                {
                    thisWindow.grdMain.IsEnabled = true;                    
                    DB_VIEW = SetFilter<SelectDBSourceFinder_INOUT>(DBSOURCEFINDER_LIST, CustomerFilter);
                    EQS_VIEW = SetFilter<SelectDBSourceFinder_INOUT>(EQSSOURCE_LIST, CustomerFilter);
                    thisWindow.ProgreesOff();
                    timer.Enabled = false;
                }                
                
            }), DispatcherPriority.Send));
            timer.Enabled = true;

            
        }
        
        private void SelectDBSource()
        {
                        
            this.KEYWARD = "";
            SelectDBSourceFinder_INOUT param = new SelectDBSourceFinder_INOUT();
            param.TEXT = this.TEXT;
            try
            {
                this.DBSOURCEFINDER_LIST = dac.SelectDBSource(param);
            }
            catch
            {
                this.DBSOURCEFINDER_LIST = dac.SelectDBSource2(param);
            }
            this.EQSSOURCE_LIST = dac.SelectEQSSource(param);
            //DB_VIEW = SetFilter<SelectDBSourceFinder_INOUT>(DBSOURCEFINDER_LIST, CustomerFilter);
            //EQS_VIEW = SetFilter<SelectDBSourceFinder_INOUT>(EQSSOURCE_LIST, CustomerFilter);
            //thisWindow.ProgreesOff();
        }
      
        /// <summary>
        /// 검색
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        private bool CustomerFilter(object item)
        {
            bool filter = true;
            if (string.IsNullOrEmpty(this.KEYWARD))
                return filter;
            SelectDBSourceFinder_INOUT code_list = item as SelectDBSourceFinder_INOUT;
            char[] chArray = new char[1] { ',' };
            foreach (string str in this.KEYWARD.Split(chArray,StringSplitOptions.RemoveEmptyEntries))
            {
                if (!string.IsNullOrEmpty(str))
                {
                    if (code_list.QUERYTEXT.IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0)
                        filter = true;
                    else
                        return false;                                        
                }
            }
            return filter;

        }
        
        #endregion
    }
}
