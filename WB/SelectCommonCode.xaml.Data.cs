using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
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
    public class SelectCommonCodeData : ViewModelBase
    {
        #region [dac]
        SelectCommonCodeDL dac = new SelectCommonCodeDL();
        #endregion
        #region [Constructor]
        public SelectCommonCodeData()
        {
            if (LicenseManager.UsageMode == LicenseUsageMode.Designtime) return;
            this.Init();
        }
        #endregion
        #region [View Property]
        public SelectCommonCode thisWindow;
        private string search_text = "";
        /// <summary>
        /// 
        /// </summary>
        public string SEARCH_TEXT
        {
            get { return this.search_text; }
            set { if (this.search_text != value) { this.search_text = value; OnPropertyChanged("SEARCH_TEXT", value); } }
        }
        private string sel_hsp_tp_cd = "01";
        /// <summary>
        /// 
        /// </summary>
        public string SEL_HSP_TP_CD
        {
            get { return this.sel_hsp_tp_cd; }
            set { if (this.sel_hsp_tp_cd != value) { this.sel_hsp_tp_cd = value; OnPropertyChanged("SEL_HSP_TP_CD", value); } }
        }
        




        #endregion
        #region [Member Property]
        private SelectCommonCode_INOUT commoncode_sel;
        /// <summary>
        /// name         : 공통코드 조회 선택 DTO
        /// desc         : 공통코드 조회 선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public SelectCommonCode_INOUT COMMONCODE_SEL
        {
            get { return this.commoncode_sel; }
            set { if (this.commoncode_sel != value) { this.commoncode_sel = value; OnPropertyChanged("COMMONCODE_SEL", value); } }
        }



        private List<SelectCommonCode_INOUT> commoncode_list = new List<SelectCommonCode_INOUT>();
        /// <summary>
        /// name         : 공통코드 조회 리스트
        /// desc         : 공통코드 조회 리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public List<SelectCommonCode_INOUT> COMMONCODE_LIST
        {
            get { return this.commoncode_list; }
            set { if (this.commoncode_list != value) { this.commoncode_list = value; OnPropertyChanged("COMMONCODE_LIST", value); } }
        }

        private SelectCommonCode_INOUT hspcommoncode_sel;
        /// <summary>
        /// name         : 병원별 공통코드 조회 선택 DTO
        /// desc         : 병원별 공통코드 조회 선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public SelectCommonCode_INOUT HSPCOMMONCODE_SEL
        {
            get { return this.hspcommoncode_sel; }
            set { if (this.hspcommoncode_sel != value) { this.hspcommoncode_sel = value; OnPropertyChanged("HSPCOMMONCODE_SEL", value); } }
        }



        private List<SelectCommonCode_INOUT> hspcommoncode_list = new List<SelectCommonCode_INOUT>();
        /// <summary>
        /// name         : 병원별 공통코드 조회 리스트
        /// desc         : 병원별 공통코드 조회 리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public List<SelectCommonCode_INOUT> HSPCOMMONCODE_LIST
        {
            get { return this.hspcommoncode_list; }
            set { if (this.hspcommoncode_list != value) { this.hspcommoncode_list = value; OnPropertyChanged("HSPCOMMONCODE_LIST", value); } }
        }       

        private SelectCommonCode_INOUT commoncodedetail_sel;
        /// <summary>
        /// name         : 공통코드 조회 선택 DTO
        /// desc         : 공통코드 조회 선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public SelectCommonCode_INOUT COMMONCODEDETAIL_SEL
        {
            get { return this.commoncodedetail_sel; }
            set { if (this.commoncodedetail_sel != value) { this.commoncodedetail_sel = value; OnPropertyChanged("COMMONCODEDETAIL_SEL", value); } }
        }



        private List<SelectCommonCode_INOUT> commoncodedetail_list = new List<SelectCommonCode_INOUT>();
        /// <summary>
        /// name         : 공통코드 조회 리스트
        /// desc         : 공통코드 조회 리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public List<SelectCommonCode_INOUT> COMMONCODEDETAIL_LIST
        {
            get { return this.commoncodedetail_list; }
            set { if (this.commoncodedetail_list != value) { this.commoncodedetail_list = value; OnPropertyChanged("COMMONCODEDETAIL_LIST", value); } }
        }

        private SelectCommonCode_INOUT commonltc_sel;
        /// <summary>
        /// name         :  선택 DTO
        /// desc         :  선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public SelectCommonCode_INOUT COMMONLTC_SEL
        {
            get { return this.commonltc_sel; }
            set { if (this.commonltc_sel != value) { this.commonltc_sel = value; OnPropertyChanged("COMMONLTC_SEL", value); } }
        }



        private List<SelectCommonCode_INOUT> commonltc_list = new List<SelectCommonCode_INOUT>();
        /// <summary>
        /// name         :  리스트
        /// desc         :  리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public List<SelectCommonCode_INOUT> COMMONLTC_LIST
        {
            get { return this.commonltc_list; }
            set { if (this.commonltc_list != value) { this.commonltc_list = value; OnPropertyChanged("COMMONLTC_LIST", value); } }
        }

                
        private ICommand selectCommonLtcCommand;
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public ICommand SelectCommonLtcCommand
        {
            get
            {
                if (selectCommonLtcCommand == null)
                    selectCommonLtcCommand = new RelayCommand(p => this.SelectCommonLtc(p));
                return selectCommonLtcCommand;
            }
        }

        #endregion
        #region [Command]
        private ICommand selectCommonCodeCommand;
        /// <summary>
        /// name         : 공통코드 조회
        /// desc         : 공통코드 조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public ICommand SelectCommonCodeCommand
        {
            get
            {
                if (selectCommonCodeCommand == null)
                    selectCommonCodeCommand = new RelayCommand(p => this.SelectCommonCode(p));
                return selectCommonCodeCommand;
            }
        }
        private ICommand sTD_MouseUpCommand;
        /// <summary>
        /// name         : STD클릭
        /// desc         : STD클릭
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public ICommand STD_MouseUpCommand
        {
            get
            {
                if (sTD_MouseUpCommand == null)
                    sTD_MouseUpCommand = new RelayCommand(p => this.SelectCommonLtc(p));
                return sTD_MouseUpCommand;
            }
        }
        private ICommand lTC_MouseUpCommand;
        /// <summary>
        /// name         : LTC클릭
        /// desc         : LTC클릭
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        public ICommand LTC_MouseUpCommand
        {
            get
            {
                if (lTC_MouseUpCommand == null)
                    lTC_MouseUpCommand = new RelayCommand(p => this.SelectCommonDetailCode(p));
                return lTC_MouseUpCommand;
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
            this.LoadUserInfo();
        }

        /// <summary>
        /// name         : 공통코드 조회
        /// desc         : 공통코드 조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        private void SelectCommonCode(object p)
        {
            BasicSetting connection = thisWindow.GetMetaConnection();
            string query = string.Format("SELECT CD_ENG_NM,CD_NM,CD_VAL COMN_GRP_CD\n                    FROM STD_CODE\n                   WHERE (CD_ENG_NM LIKE '%' || '{0}' || '%' OR CD_NM LIKE '%' || '{0}' || '%' ) \n AND SYSDATE BETWEEN TO_DATE(AVAL_ST_DT,'YYYYMMDDHH24MISS') AND TO_DATE(AVAL_END_DT,'YYYYMMDDHH24MISS') \n AND CD_VAL IS NOT NULL", (object)SEARCH_TEXT);
            try
            {
                if (!USERINFO.EXCN_META)
                {
                    DataTable table = dac.ExecuteQuery(connection.VALUE, query).Tables[0];

                    if (table.Rows.Count > 0)
                    {
                        thisWindow.dgrdStdCode.ItemsSource = table.DefaultView;
                    }
                    else
                    {
                        thisWindow.dgrdStdCode.ItemsSource = new DataTable().DefaultView;
                    }
                }
            }
            catch (Exception ex)
            {
                thisWindow.ErrorMsg(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요.", ex.ToString()));
            }
            SelectCommonLtc(this.SEARCH_TEXT);

        }
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        private void SelectCommonLtc(object p)
        {
            //if (p is null && string.IsNullOrEmpty(this.SEARCH_TEXT)) return;
            string comn_grp_Cd = "";
            SelectCommonCode_INOUT selectedItem = new SelectCommonCode_INOUT();
            if (p is string)
                comn_grp_Cd = p.ToString();
            else
            {
                DataRowView item = ((DataGrid)p).SelectedItem as DataRowView;
                if (item is null) return;
                comn_grp_Cd = item.Row["COMN_GRP_CD"].ToString();
                
            }

            try
            {
                SelectCommonCode_INOUT param = new SelectCommonCode_INOUT();
                param.COMN_GRP_CD = comn_grp_Cd;
                param.IN_HSP_TP_CD = SEL_HSP_TP_CD;
                COMMONLTC_LIST = dac.SelectCCCCCLTC(param);
                if (this.COMMONLTC_LIST.Count > 0)
                {
                    this.COMMONLTC_SEL = this.COMMONLTC_LIST.FirstOrDefault();
                }
            }
            catch
            {

            }

        }
        /// <summary>
        /// name         : 공통코드 조회
        /// desc         : 공통코드 조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-21
        /// update date  : 2022-11-21
        /// </summary>
        /// <remarks></remarks>
        private void SelectCommonDetailCode(object p)
        {           
            if (COMMONLTC_SEL == null || string.IsNullOrEmpty(COMMONLTC_SEL.TABLE_NM)) return;

            SelectCommonCode_INOUT param = new SelectCommonCode_INOUT();
            param.COMN_GRP_CD = COMMONLTC_SEL.COMN_GRP_CD;
            param.IN_HSP_TP_CD = SEL_HSP_TP_CD;
            if(COMMONLTC_SEL.TABLE_NM == "CCCCCSTE")
                this.COMMONCODEDETAIL_LIST = dac.SelectCCCCCSTE(param);
            else if(COMMONLTC_SEL.TABLE_NM == "CCCMCSTE")
                this.COMMONCODEDETAIL_LIST = dac.SelectCCCMCSTE(param);            
        }
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : 
        /// create date  : 2022-12-16
        /// update date  : 2022-12-16
        /// </summary>
        /// <remarks></remarks>
        private void SaveExcnMeta(object p)
        {
            SaveUserInfo();
        }
        #endregion
    }
}
