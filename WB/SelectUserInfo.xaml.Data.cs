using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Data;
using System.Windows.Input;
using WB.Common;
using WB.DAC;
using WB.DTO;

namespace WB
{
    public class SelectUserInfoData : ViewModelBase
    {
        #region [dac]
        SelectUserInfoDL dac = new SelectUserInfoDL();
        #endregion
        #region [Constructor]
        public SelectUserInfoData()
        {
            if (LicenseManager.UsageMode == LicenseUsageMode.Designtime) return;
            this.Init();
        }
        #endregion
        #region [View Property]
        private ICollectionView collectionView;
        private bool rtrm_yn = true;
        /// <summary>
        /// 퇴직여부
        /// </summary>
        public bool RTRM_YN
        {
            get { return this.rtrm_yn; }
            set { if (this.rtrm_yn != value) { this.rtrm_yn = value; OnPropertyChanged("RTRM_YN", value); } }
        }


        private string sel_hsp_tp_cd_radio = "01";
        /// <summary>
        /// 
        /// </summary>
        public string SEL_HSP_TP_CD_RADIO
        {
            get { return this.sel_hsp_tp_cd_radio; }
            set { if (this.sel_hsp_tp_cd_radio != value) { this.sel_hsp_tp_cd_radio = value; OnPropertyChanged("SEL_HSP_TP_CD_RADIO", value); } }
        }


        private string user_info_text;
        /// <summary>
        /// 
        /// </summary>
        public string USER_INFO_TEXT
        {
            get { return this.user_info_text; }
            set { if (this.user_info_text != value) { this.user_info_text = value; OnPropertyChanged("USER_INFO_TEXT", value); } }
        }


        #endregion
        #region [Member Property]
        private SelectUserInfo_INOUT userinfo_sel;
        /// <summary>
        /// name         : 사용자정보 조회 선택 DTO
        /// desc         : 사용자정보 조회 선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-27
        /// update date  : 2022-10-27
        /// </summary>
        /// <remarks></remarks>
        public SelectUserInfo_INOUT USERINFO_SEL
        {
            get { return this.userinfo_sel; }
            set { if (this.userinfo_sel != value) { this.userinfo_sel = value; OnPropertyChanged("USERINFO_SEL", value); } }
        }



        private List<SelectUserInfo_INOUT> userinfo_list;
        /// <summary>
        /// name         : 사용자정보 조회 리스트
        /// desc         : 사용자정보 조회 리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-27
        /// update date  : 2022-10-27
        /// </summary>
        /// <remarks></remarks>
        public List<SelectUserInfo_INOUT> USERINFO_LIST
        {
            get { return this.userinfo_list; }
            set { if (this.userinfo_list != value) { this.userinfo_list = value; OnPropertyChanged("USERINFO_LIST", value); } }
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
        private ICommand selectUserInfoCommand;
        /// <summary>
        /// name         : 사용자정보 조회
        /// desc         : 사용자정보 조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-27
        /// update date  : 2022-10-27
        /// </summary>
        /// <remarks></remarks>
        public ICommand SelectUserInfoCommand
        {
            get
            {
                if (selectUserInfoCommand == null)
                    selectUserInfoCommand = new RelayCommand(p => this.SelectUserInfo(p));
                return selectUserInfoCommand;
            }
        }
        private ICommand rTRM_CHECKCommand;
        /// <summary>
        /// name         : 퇴사자제외 체크
        /// desc         : 퇴사자제외 체크
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-27
        /// update date  : 2022-10-27
        /// </summary>
        /// <remarks></remarks>
        public ICommand RTRM_CHECKCommand
        {
            get
            {
                if (rTRM_CHECKCommand == null)
                    rTRM_CHECKCommand = new RelayCommand(p => this.RTRM_CHECK(p));
                return rTRM_CHECKCommand;
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
        /// name         : 사용자정보 조회
        /// desc         : 사용자정보 조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-27
        /// update date  : 2022-10-27
        /// </summary>
        /// <remarks></remarks>
        private void SelectUserInfo(object p)
        {
            SelectUserInfo_INOUT param = new SelectUserInfo_INOUT();            
            param.IN_STF_NO = USER_INFO_TEXT;            
            param.SEL_HSP_TP_CD = SEL_HSP_TP_CD_RADIO;
            this.USERINFO_LIST = dac.SelectUserInfo(param);

            if (this.USERINFO_LIST.Count > 0)
            {
                this.USERINFO_SEL = this.USERINFO_LIST.FirstOrDefault();

                collectionView = CollectionViewSource.GetDefaultView(USERINFO_LIST);
                collectionView.Filter = CustomerFilter;
            }
        }
        private bool CustomerFilter(object item)
        {
            bool filter = true;
            SelectUserInfo_INOUT list = item as SelectUserInfo_INOUT;

            if (RTRM_YN && !string.IsNullOrEmpty(list.RTRM_DT)) //퇴사자 제외
                filter = false;            
                
            return filter;
        }
        /// <summary>
        /// name         : 퇴사자제외 체크
        /// desc         : 퇴사자제외 체크
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-27
        /// update date  : 2022-10-27
        /// </summary>
        /// <remarks></remarks>
        private void RTRM_CHECK(object p)
        {
            collectionView.Refresh();
        }
        #endregion
    }
}
