using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Input;
using WB.Common;
using WB.DAC;
using WB.DTO;

namespace WB
{
    public class SourceGeneraterData : ViewModelBase
    {
        #region [dac]
        SourceGeneraterDL dac = new SourceGeneraterDL();
        #endregion
        #region [Constructor]
        public SourceGeneraterData()
        {
            if (LicenseManager.UsageMode == LicenseUsageMode.Designtime) return;
            this.Init();
        }
        #endregion
        #region [View Property]
        private string in_dto = "_INOUT";
        /// <summary>
        /// 
        /// </summary>
        public string IN_DTO
        {
            get { return this.in_dto; }
            set { if (this.in_dto != value) { this.in_dto = value; OnPropertyChanged("IN_DTO", value); } }
        }

        private string out_dto = "_INOUT";
        /// <summary>
        /// 
        /// </summary>
        public string OUT_DTO
        {
            get { return this.out_dto; }
            set { if (this.out_dto != value) { this.out_dto = value; OnPropertyChanged("OUT_DTO", value); } }
        }

        private string inout_dto = "_INOUT";
        /// <summary>
        /// 
        /// </summary>
        public string INOUT_DTO
        {
            get { return this.inout_dto; }
            set { if (this.inout_dto != value) { this.inout_dto = value; OnPropertyChanged("INOUT_DTO", value); SyncDto(); } }
        }


        private string summary_desc = "";
        /// <summary>
        /// 
        /// </summary>
        public string SUMMARY_DESC
        {
            get { return this.summary_desc; }
            set { if (this.summary_desc != value) { this.summary_desc = value; OnPropertyChanged("SUMMARY_DESC", value); } }
        }


        private string pkg_nm = "";
        /// <summary>
        /// 패키지명
        /// </summary>
        public string PKG_NM
        {
            get { return this.pkg_nm; }
            set { if (this.pkg_nm != value) { this.pkg_nm = value; OnPropertyChanged("PKG_NM", value); } }
        }


        private string eqs_id;
        /// <summary>
        /// 
        /// </summary>
        public string EQS_ID
        {
            get { return this.eqs_id; }
            set { if (this.eqs_id != value) { this.eqs_id = value; OnPropertyChanged("EQS_ID", value); } }
        }
        private string if_text;
        /// <summary>
        /// 
        /// </summary>
        public string IF_TEXT
        {
            get { return this.if_text; }
            set { if (this.if_text != value) { this.if_text = value; OnPropertyChanged("IF_TEXT", value); } }
        }

        private string biz_text;
        /// <summary>
        /// 
        /// </summary>
        public string BIZ_TEXT
        {
            get { return this.biz_text; }
            set { if (this.biz_text != value) { this.biz_text = value; OnPropertyChanged("BIZ_TEXT", value); } }
        }

        private string dl_text;
        /// <summary>
        /// 
        /// </summary>
        public string DL_TEXT
        {
            get { return this.dl_text; }
            set { if (this.dl_text != value) { this.dl_text = value; OnPropertyChanged("DL_TEXT", value); } }
        }

        private string dto_text = "";
        /// <summary>
        /// 
        /// </summary>
        public string DTO_TEXT
        {
            get { return this.dto_text; }
            set { if (this.dto_text != value) { this.dto_text = value; OnPropertyChanged("DTO_TEXT", value); } }
        }

        private string property_text;
        /// <summary>
        /// 
        /// </summary>
        public string PROPERTY_TEXT
        {
            get { return this.property_text; }
            set { if (this.property_text != value) { this.property_text = value; OnPropertyChanged("PROPERTY_TEXT", value); } }
        }

        private string method_text;
        /// <summary>
        /// 
        /// </summary>
        public string METHOD_TEXT
        {
            get { return this.method_text; }
            set { if (this.method_text != value) { this.method_text = value; OnPropertyChanged("METHOD_TEXT", value); } }
        }

        private string command_text;
        /// <summary>
        /// 
        /// </summary>
        public string COMMAND_TEXT
        {
            get { return this.command_text; }
            set { if (this.command_text != value) { this.command_text = value; OnPropertyChanged("COMMAND_TEXT", value); } }
        }

        private bool dto_sync = true;
        /// <summary>
        /// 
        /// </summary>
        public bool DTO_SYNC
        {
            get { return this.dto_sync; }
            set { if (this.dto_sync != value) { this.dto_sync = value; OnPropertyChanged("DTO_SYNC", value); } }
        }


        #endregion
        #region [Member Property]
     
        private SourceGenerater_INOUT pakage_sel;
        /// <summary>
        /// name         : PKG 파라미터 선택 DTO
        /// desc         : PKG 파라미터 선택 DTO
        /// author       : 오원빈
        /// create date  : 2022-10-24
        /// update date  : 2022-10-24
        /// </summary>
        /// <remarks></remarks>
        public SourceGenerater_INOUT PAKAGE_SEL
        {
            get { return this.pakage_sel; }
            set { if (this.pakage_sel != value) { this.pakage_sel = value; OnPropertyChanged("PAKAGE_SEL", value); } }
        }



        private List<SourceGenerater_INOUT> pakage_list = new List<SourceGenerater_INOUT>();
        /// <summary>
        /// name         : PKG 파라미터 리스트
        /// desc         : PKG 파라미터 리스트
        /// author       : 오원빈
        /// create date  : 2022-10-24
        /// update date  : 2022-10-24
        /// </summary>
        /// <remarks></remarks>
        public List<SourceGenerater_INOUT> PAKAGE_LIST
        {
            get { return this.pakage_list; }
            set { if (this.pakage_list != value) { this.pakage_list = value; OnPropertyChanged("PAKAGE_LIST", value); } }
        }


        private SourceGenerater_INOUT eqs_sel;
        /// <summary>
        /// name         : EQS 선택 DTO
        /// desc         : EQS 선택 DTO
        /// author       : 오원빈
        /// create date  : 2022-10-21
        /// update date  : 2022-10-21
        /// </summary>
        /// <remarks></remarks>
        public SourceGenerater_INOUT EQS_SEL
        {
            get { return this.eqs_sel; }
            set { if (this.eqs_sel != value) { this.eqs_sel = value; OnPropertyChanged("EQS_SEL", value); } }
        }



        private List<SourceGenerater_INOUT> eqs_list;
        /// <summary>
        /// name         : EQS 리스트
        /// desc         : EQS 리스트
        /// author       : 오원빈
        /// create date  : 2022-10-21
        /// update date  : 2022-10-21
        /// </summary>
        /// <remarks></remarks>
        public List<SourceGenerater_INOUT> EQS_LIST
        {
            get { return this.eqs_list; }
            set { if (this.eqs_list != value) { this.eqs_list = value; OnPropertyChanged("EQS_LIST", value); } }
        }


        #endregion
        #region [Command]
       
        private ICommand pAKAGECommand;
        /// <summary>
        /// name         : PKG 파라미터
        /// desc         : PKG 파라미터
        /// author       : 오원빈
        /// create date  : 2022-10-24
        /// update date  : 2022-10-24
        /// </summary>
        /// <remarks></remarks>
        public ICommand PAKAGECommand
        {
            get
            {
                if (pAKAGECommand == null)
                    pAKAGECommand = new RelayCommand(p => this.PAKAGE(p));
                return pAKAGECommand;
            }
        }
        private ICommand searchEQSCommand;
        /// <summary>
        /// name         : EQS 조회
        /// desc         : EQS 조회
        /// author       : 오원빈
        /// create date  : 2022-10-21
        /// update date  : 2022-10-21
        /// </summary>
        /// <remarks></remarks>
        public ICommand SearchEQSCommand
        {
            get
            {
                if (searchEQSCommand == null)
                    searchEQSCommand = new RelayCommand(p => this.SearchEQS(p));
                return searchEQSCommand;
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
            LoadUserInfo();
        }

        /// <summary>
        /// name         : EQS 조회
        /// desc         : EQS 조회
        /// author       : 오원빈
        /// create date  : 2022-10-21
        /// update date  : 2022-10-21
        /// </summary>
        /// <remarks></remarks>
        private void SearchEQS(object p)
        {
            SourceGenerater_INOUT param = new SourceGenerater_INOUT();
            param.EQS_ID = EQS_ID;
            this.EQS_LIST = dac.SelectEQS(param);

            if (this.EQS_LIST != null && this.EQS_LIST.Count > 0)
            {
                this.EQS_SEL = this.EQS_LIST.FirstOrDefault();
            }
            else if (this.EQS_LIST != null && this.EQS_LIST.Count == 0 && this.EQS_SEL != null)
                this.EQS_SEL = new SourceGenerater_INOUT();
        }

        /// <summary>
        /// name         : PKG 파라미터
        /// desc         : PKG 파라미터
        /// author       : 오원빈
        /// create date  : 2022-10-24
        /// update date  : 2022-10-24
        /// </summary>
        /// <remarks></remarks>
        private void PAKAGE(object p)
        {
            SourceGenerater_INOUT param = new SourceGenerater_INOUT();
            param = p as SourceGenerater_INOUT;
            this.PAKAGE_LIST = dac.SelectPKG(param);

            if (this.PAKAGE_LIST.Count > 0)
            {
                this.PAKAGE_SEL = this.PAKAGE_LIST.FirstOrDefault();
            }
        }

        /// <summary>
        /// name         : DTO동기화
        /// desc         : DTO동기화
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-25
        /// update date  : 2022-10-25
        /// </summary>
        /// <remarks></remarks>
        private void SyncDto()
        {
            if (this.DTO_SYNC)
            {
                this.IN_DTO = this.INOUT_DTO ;
                this.OUT_DTO = this.INOUT_DTO;
            }
        }
        #endregion
    }
}
