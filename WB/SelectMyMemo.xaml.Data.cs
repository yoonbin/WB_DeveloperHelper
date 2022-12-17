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
    public class SelectMyMemoData : ViewModelBase
    {
        #region [dac]
        //SelectMyMemoDL dac = new SelectMyMemoDL();
        #endregion
        #region [Constructor]
        public SelectMyMemoData()
        {
            if (LicenseManager.UsageMode == LicenseUsageMode.Designtime) return;
            this.Init();
        }
        #endregion
        #region [View Property]  
        private string edit_read = "EDIT";
        /// <summary>
        /// 
        /// </summary>
        public string EDIT_READ
        {
            get { return this.edit_read; }
            set { if (this.edit_read != value) { this.edit_read = value; OnPropertyChanged("EDIT_READ", value); } }
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
            this.LoadUserInfo();            
        }
        #endregion
    }
}
