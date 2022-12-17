using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using WB.Common;
using WB.DAC;
using WB.DTO;

namespace WB
{
    public class CodeReOrderData : ViewModelBase
    {
        #region [dac]
        //CodeReOrderDL dac = new CodeReOrderDL();
        #endregion
        #region [Constructor]
        public CodeReOrderData()
        {
            if (LicenseManager.UsageMode == LicenseUsageMode.Designtime) return;
            this.Init();
        }
        #endregion
        #region [View Property]
        private int tab_number;
        /// <summary>
        /// 
        /// </summary>
        public int TAB_NUMBER
        {
            get { return this.tab_number; }
            set { if (this.tab_number != value) { this.tab_number = value; OnPropertyChanged("TAB_NUMBER", value); } }
        }


        private string target_code;
        /// <summary>
        /// 
        /// </summary>
        public string TARGET_CODE
        {
            get { return this.target_code; }
            set { if (this.target_code != value) { this.target_code = value; OnPropertyChanged("TARGET_CODE", value); } }
        }

        private string result_code;
        /// <summary>
        /// 
        /// </summary>
        public string RESULT_CODE
        {
            get { return this.result_code; }
            set { if (this.result_code != value) { this.result_code = value; OnPropertyChanged("RESULT_CODE", value); } }
        }
        private int column_name_spaced = 50;
        /// <summary>
        /// 
        /// </summary>
        public int COLUMN_NAME_SPACED
        {
            get { return this.column_name_spaced; }
            set { if (this.column_name_spaced != value) { this.column_name_spaced = value; OnPropertyChanged("COLUMN_NAME_SPACED", value); } }
        }



        #endregion
        #region [Member Property]
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
        }
        #endregion
    }
}
