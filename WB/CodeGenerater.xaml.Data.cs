using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Timers;
using System.Windows.Input;
using System.Windows.Threading;
using System.Xml;
using System.Xml.Serialization;
using WB.Common;
using WB.DAC;
using WB.DTO;
using WB.UC;

namespace WB
{
    public class CodeGeneraterData : ViewModelBase
    {
        #region [dac]
        MetaDL dac = new MetaDL();
        #endregion
        UCBase ucBase = new UCBase();
        public CodeGenerater thisWindow;
        #region [Constructor]
        public CodeGeneraterData()
        {
            if (LicenseManager.UsageMode == LicenseUsageMode.Designtime) return;
            this.Init();
        }
        #endregion

        #region [View Property]
        private string sync_text;
        /// <summary>
        /// 
        /// </summary>
        public string SYNC_TEXT
        {
            get { return this.sync_text; }
            set { if (this.sync_text != value) { this.sync_text = value; OnPropertyChanged("SYNC_TEXT", value); } }
        }


        private string error_param;
        /// <summary>
        /// 
        /// </summary>
        public string ERROR_PARAM
        {
            get { return this.error_param; }
            set { if (this.error_param != value) { this.error_param = value; OnPropertyChanged("ERROR_PARAM", value); AutoChgText("6"); } }
        }

        private string error_param_rslt;
        /// <summary>
        /// 
        /// </summary>
        public string ERROR_PARAM_RSLT
        {
            get { return this.error_param_rslt; }
            set { if (this.error_param_rslt != value) { this.error_param_rslt = value; OnPropertyChanged("ERROR_PARAM_RSLT", value); } }
        }


        private string query_text;
        /// <summary>
        /// 
        /// </summary>
        public string QUERY_TEXT
        {
            get { return this.query_text; }
            set { if (this.query_text != value) { this.query_text = value; OnPropertyChanged("QUERY_TEXT", value); } }
        }

        private string query_dto_text;
        /// <summary>
        /// 
        /// </summary>
        public string QUERY_DTO_TEXT
        {
            get { return this.query_dto_text; }
            set { if (this.query_dto_text != value) { this.query_dto_text = value; OnPropertyChanged("QUERY_DTO_TEXT", value); } }
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



        private string view_text_r;
        /// <summary>
        /// name : VIEW_TEXT_R
        /// </summary>
        public string VIEW_TEXT_R
        {
            get { return this.view_text_r; }
            set { if (this.view_text_r != value) { this.view_text_r = value; OnPropertyChanged("VIEW_TEXT_R", value); } }
        }

        private string comma_text_r;
        /// <summary>
        /// name : COMMA_TEXT_R
        /// </summary>
        public string COMMA_TEXT_R
        {
            get { return this.comma_text_r; }
            set { if (this.comma_text_r != value) { this.comma_text_r = value; OnPropertyChanged("COMMA_TEXT_R", value); } }
        }

        private string dto_text_r;
        /// <summary>
        /// name : DTO_TEXT_R
        /// </summary>
        public string DTO_TEXT_R
        {
            get { return this.dto_text_r; }
            set { if (this.dto_text_r != value) { this.dto_text_r = value; OnPropertyChanged("DTO_TEXT_R", value); } }
        }

        private string eqs_text_r;
        /// <summary>
        /// name : EQS_TEXT_R
        /// </summary>
        public string EQS_TEXT_R
        {
            get { return this.eqs_text_r; }
            set { if (this.eqs_text_r != value) { this.eqs_text_r = value; OnPropertyChanged("EQS_TEXT_R", value); } }
        }

        private string view_text;
        /// <summary>
        /// name : VIEW_TEXT
        /// </summary>
        public string VIEW_TEXT
        {
            get { return this.view_text; }
            set { if (this.view_text != value) { this.view_text = value; OnPropertyChanged("VIEW_TEXT", value);  } }
        }

        private string comma_text;
        /// <summary>
        /// name : COMMA_TEXT
        /// </summary>   
        public string COMMA_TEXT
        {
            get { return this.comma_text; }
            set { if (this.comma_text != value) { this.comma_text = value; OnPropertyChanged("COMMA_TEXT", value); AutoChgText("3"); } }
        }

        private string dto_text;
        /// <summary>
        /// name : DTO_TEXT
        /// </summary>  
        public string DTO_TEXT
        {
            get { return this.dto_text; }
            set { if (this.dto_text != value) { this.dto_text = value; OnPropertyChanged("DTO_TEXT", value);} }
        }

        private string eqs_text;
        /// <summary>
        /// name : EQS_TEXT
        /// </summary>
        public string EQS_TEXT
        {
            get { return this.eqs_text; }
            set { if (this.eqs_text != value) { this.eqs_text = value; OnPropertyChanged("EQS_TEXT", value); AutoChgText("1"); } }
        }
        private bool sync;
        /// <summary>
        /// 동기
        /// </summary>
        public bool SYNC
        {
            get { return this.sync; }
            set { if (this.sync != value) { this.sync = value; OnPropertyChanged("SYNC", value); } }
        }

        private string convert_date_text;
        /// <summary>
        /// 
        /// </summary>
        public string CONVERT_DATE_TEXT
        {
            get { return this.convert_date_text; }
            set { if (this.convert_date_text != value) { this.convert_date_text = value; OnPropertyChanged("CONVERT_DATE_TEXT", value); AutoChgText("5"); } }
        }

        private string convert_date_text_r;
        /// <summary>
        /// 
        /// </summary>
        public string CONVERT_DATE_TEXT_R
        {
            get { return this.convert_date_text_r; }
            set { if (this.convert_date_text_r != value) { this.convert_date_text_r = value; OnPropertyChanged("CONVERT_DATE_TEXT_R", value); } }
        }


        private string convert_date_text_r2;
        /// <summary>
        /// 
        /// </summary>
        public string CONVERT_DATE_TEXT_R2
        {
            get { return this.convert_date_text_r2; }
            set { if (this.convert_date_text_r2 != value) { this.convert_date_text_r2 = value; OnPropertyChanged("CONVERT_DATE_TEXT_R2", value); } }
        }
        private string data_type_nm = "";
        /// <summary>
        /// 
        /// </summary>
        public string DATA_TYPE_NM
        {
            get { return this.data_type_nm; }
            set { if (this.data_type_nm != value) { this.data_type_nm = value; OnPropertyChanged("DATA_TYPE_NM", value); AutoChgText("4"); } }
        }



        #endregion
        #region [Member Property]
        private CodeGenerater_INOUT dto_drtn_sel;
        /// <summary>
        /// name         :  선택 DTO
        /// desc         :  선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-08
        /// update date  : 2022-11-08
        /// </summary>
        /// <remarks></remarks>
        public CodeGenerater_INOUT DTO_DRTN_SEL
        {
            get { return this.dto_drtn_sel; }
            set { if (this.dto_drtn_sel != value) { this.dto_drtn_sel = value; OnPropertyChanged("DTO_DRTN_SEL", value); } }
        }



        private List<CodeGenerater_INOUT> dto_drtn_list = new List<CodeGenerater_INOUT>();
        /// <summary>
        /// name         :  리스트
        /// desc         :  리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-08
        /// update date  : 2022-11-08
        /// </summary>
        /// <remarks></remarks>
        public List<CodeGenerater_INOUT> DTO_DRTN_LIST
        {
            get { return this.dto_drtn_list; }
            set { if (this.dto_drtn_list != value) { this.dto_drtn_list = value; OnPropertyChanged("DTO_DRTN_LIST", value); } }
        }

        private CodeGenerater_INOUT query_dto_drtn_sel;
        /// <summary>
        /// name         :  선택 DTO
        /// desc         :  선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-08
        /// update date  : 2022-11-08
        /// </summary>
        /// <remarks></remarks>
        public CodeGenerater_INOUT QUERY_DTO_DRTN_SEL
        {
            get { return this.query_dto_drtn_sel; }
            set { if (this.query_dto_drtn_sel != value) { this.query_dto_drtn_sel = value; OnPropertyChanged("QUERY_DTO_DRTN_SEL", value); } }
        }



        private List<CodeGenerater_INOUT> query_dto_drtn_list = new List<CodeGenerater_INOUT>();
        /// <summary>
        /// name         :  리스트
        /// desc         :  리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-08
        /// update date  : 2022-11-08
        /// </summary>
        /// <remarks></remarks>
        public List<CodeGenerater_INOUT> QUERY_DTO_DRTN_LIST
        {
            get { return this.query_dto_drtn_list; }
            set { if (this.query_dto_drtn_list != value) { this.query_dto_drtn_list = value; OnPropertyChanged("QUERY_DTO_DRTN_LIST", value); } }
        }



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
        private CodeGenerater_INOUT datatype_sel;
        /// <summary>
        /// name         : DataType 리스트 선택 DTO
        /// desc         : DataType 리스트 선택 DTO
        /// author       : 오원빈
        /// create date  : 2022-10-18
        /// update date  : 2022-10-18
        /// </summary>
        /// <remarks></remarks>
        public CodeGenerater_INOUT DATATYPE_SEL
        {
            get { return this.datatype_sel; }
            set { if (this.datatype_sel != value) { this.datatype_sel = value; OnPropertyChanged("DATATYPE_SEL", value); } }
        }



        private List<CodeGenerater_INOUT> datatype_list = new List<CodeGenerater_INOUT>();
        /// <summary>
        /// name         : DataType 리스트 리스트
        /// desc         : DataType 리스트 리스트
        /// author       : 오원빈
        /// create date  : 2022-10-18
        /// update date  : 2022-10-18
        /// </summary>
        /// <remarks></remarks>
        public List<CodeGenerater_INOUT> DATATYPE_LIST
        {
            get { return this.datatype_list; }
            set { if (this.datatype_list != value) { this.datatype_list = value; OnPropertyChanged("DATATYPE_LIST", value); } }
        }

        private CodeGenerater_INOUT converttype_sel;
        /// <summary>
        /// name         : ConvertType 선택 DTO
        /// desc         : ConvertType 선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-28
        /// update date  : 2022-10-28
        /// </summary>
        /// <remarks></remarks>
        public CodeGenerater_INOUT CONVERTTYPE_SEL
        {
            get { return this.converttype_sel; }
            set { if (this.converttype_sel != value) { this.converttype_sel = value; OnPropertyChanged("CONVERTTYPE_SEL", value); } }
        }



        private List<CodeGenerater_INOUT> converttype_list = new List<CodeGenerater_INOUT>();
        /// <summary>
        /// name         : ConvertType 리스트
        /// desc         : ConvertType 리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-28
        /// update date  : 2022-10-28
        /// </summary>
        /// <remarks></remarks>
        public List<CodeGenerater_INOUT> CONVERTTYPE_LIST
        {
            get { return this.converttype_list; }
            set { if (this.converttype_list != value) { this.converttype_list = value; OnPropertyChanged("CONVERTTYPE_LIST", value); } }
        }


        private CodeGenerater_INOUT comma_sel;
        /// <summary>
        /// name         : COMMA_TEXT 정렬 리스트 선택 DTO
        /// desc         : COMMA_TEXT 정렬 리스트 선택 DTO
        /// author       : 오원빈
        /// create date  : 2022-10-18
        /// update date  : 2022-10-18
        /// </summary>
        /// <remarks></remarks>
        public CodeGenerater_INOUT COMMA_SEL
        {
            get { return this.comma_sel; }
            set { if (this.comma_sel != value) { this.comma_sel = value; OnPropertyChanged("COMMA_SEL", value); } }
        }



        private List<CodeGenerater_INOUT> comma_list = new List<CodeGenerater_INOUT>();
        /// <summary>
        /// name         : COMMA_TEXT 정렬 리스트 리스트
        /// desc         : COMMA_TEXT 정렬 리스트 리스트
        /// author       : 오원빈
        /// create date  : 2022-10-18
        /// update date  : 2022-10-18
        /// </summary>
        /// <remarks></remarks>
        public List<CodeGenerater_INOUT> COMMA_LIST
        {
            get { return this.comma_list; }
            set { if (this.comma_list != value) { this.comma_list = value; OnPropertyChanged("COMMA_LIST", value); } }
        }



        #endregion
        #region [Command]
        private ICommand autoChgTextCommand;
        /// <summary>
        /// name         : DataType 리스트
        /// desc         : DataType 리스트
        /// author       : 오원빈
        /// create date  : 2022-10-18
        /// update date  : 2022-10-18
        /// </summary>
        /// <remarks></remarks>
        public ICommand AutoChgTextCommand
        {
            get
            {
                if (autoChgTextCommand == null)
                    autoChgTextCommand = new RelayCommand(p => this.AutoChgText(p));
                return autoChgTextCommand;
            }
        }

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
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "string", DATA_TYPE_CD = "1" });
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "bool", DATA_TYPE_CD = "2" });
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "bool?", DATA_TYPE_CD = "3" });
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "DateTime", DATA_TYPE_CD = "4" });
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "DateTime?", DATA_TYPE_CD = "5" });
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "Visibilty", DATA_TYPE_CD = "6" });
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "decimal", DATA_TYPE_CD = "7" });
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "decimal?", DATA_TYPE_CD = "8" });
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "int", DATA_TYPE_CD = "9" });
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "int?", DATA_TYPE_CD = "10" });
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "double", DATA_TYPE_CD = "11" });
            DATATYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "float", DATA_TYPE_CD = "12" });

            COMMA_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "가로", DATA_TYPE_CD = "," });
            COMMA_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "세로", DATA_TYPE_CD = WBCommon.BR + "," });

            CONVERTTYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "TO_DATE", DATA_TYPE_CD = "TO_DATE*YYYY-MM-DD" });
            CONVERTTYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "TO_CHAR", DATA_TYPE_CD = "TO_CHAR*YYYY-MM-DD" });
            CONVERTTYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "TO_DATE(HH24:MI:SS)", DATA_TYPE_CD = "TO_DATE*YYYY-MM-DD HH24:MI:SS" });
            CONVERTTYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "TO_CHAR(HH24:MI:SS)", DATA_TYPE_CD = "TO_CHAR*YYYY-MM-DD HH24:MI:SS" });
            CONVERTTYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "TO_DATE(HH24:MI)", DATA_TYPE_CD = "TO_DATE*YYYY-MM-DD HH24:MI" });
            CONVERTTYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "TO_CHAR(HH24:MI)", DATA_TYPE_CD = "TO_CHAR*YYYY-MM-DD HH24:MI" });
            CONVERTTYPE_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "TIMESTAMP(HH24:MI:SS)", DATA_TYPE_CD = "AS OF TIMESTAMP TO_TIMESTAMP*YYYY-MM-DD HH24:MI:SS" });

            DTO_DRTN_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "DTO별", DATA_TYPE_CD = "1" });
            DTO_DRTN_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "Private별", DATA_TYPE_CD = "2" });

            QUERY_DTO_DRTN_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "DTO별", DATA_TYPE_CD = "1" });
            QUERY_DTO_DRTN_LIST.Add(new CodeGenerater_INOUT { DATA_TYPE_NM = "Private별", DATA_TYPE_CD = "2" });

            string file_path = this.GetUserInfoPath();


            if (!File.Exists(file_path)) return;

            XmlSerializer xs = new XmlSerializer(typeof(UserInfo_INOUT));

            using (StreamReader rd = new StreamReader(file_path))
            {
                this.USERINFO = xs.Deserialize(rd) as UserInfo_INOUT;
            }

            SYNC = this.USERINFO.SYNC == "Y" ? true : false;
        }
        /// <summary>
        /// name         : Code자동변환
        /// desc         : Code자동변환
        /// author       : 오원빈
        /// create date  : 2022-10-18
        /// update date  : 2022-10-18
        /// </summary>
        /// <remarks></remarks>
        public void AutoChgText(object p)
        {
            string btn = p.ToString();
            switch (btn)
            {
                case "1":
                    AutoEqsText(null);
                    break;
                case "2":
                    AutoDTOText(null);
                    break;
                case "3":
                    AutoCommaText(null);
                    break;
                case "4":
                    AutoViewText(null);
                    break;               
                case "5":
                    AutoDateText(null);
                    break;
                case "6":
                    AutoErrorText(null);
                    break;
            }
            
        }
        public void SyncAutoText()
        {
            AutoEqsText(SYNC_TEXT);

            AutoDTOText(SYNC_TEXT);

            AutoCommaText(SYNC_TEXT);

            AutoViewText(SYNC_TEXT);

            AutoErrorText(SYNC_TEXT);
        }
        /// <summary>
        /// name         : EQS변환
        /// desc         : EQS변환
        /// author       : 오원빈
        /// create date  : 2022-10-18
        /// update date  : 2022-10-18
        /// </summary>
        /// <remarks></remarks>
        private void AutoEqsText(object p)
        {
            string text = p is string ? p.ToString() : EQS_TEXT;
            EQS_TEXT_R = "";
            if (string.IsNullOrEmpty(text))
            {
                if (SYNC)
                    SyncText(text);
                return;
            }
            string substr = "";            
            string[] inPara = text.Split('\n');
            if (inPara.Count() < 1) return;
            for (int i = 0; i < inPara.Count(); i++)
            {
                substr = GetExecParm(inPara[i]);                
                EQS_TEXT_R += substr;               
            }
            if (SYNC)
                SyncText(text);
        }
        /// <summary>
        /// name         : DTO_TEXT 자동변환
        /// desc         : DTO_TEXT 자동변환
        /// author       : 오원빈
        /// create date  : 2022-10-18
        /// update date  : 2022-10-18
        /// </summary>
        /// <remarks></remarks>
        private void AutoDTOText(object p)
        {
            try
            {
                string text = p is string ? p.ToString() : DTO_TEXT;
                DTO_TEXT_R = "";
                if (string.IsNullOrEmpty(text))
                {
                    //if (SYNC)
                    //    SyncText(text);
                    return;
                }
                string substr = "";
                string col_comment = "";
                string[] inPara = text.Split('\n');
                if (inPara.Count() < 1) return;

                if (this.DTO_DRTN_SEL.DATA_TYPE_CD == "1")
                {
                    for (int i = 0; i < inPara.Count(); i++)
                    {
                        substr = GetDTOText(inPara[i]);
                        if (!string.IsNullOrEmpty(substr))
                        {
                            this.META_SEARCH_IN.TEXT = substr.ToUpper();
                            col_comment = USERINFO.EXCN_META == true ? "" : dac.GetMetaList(this.META_SEARCH_IN).Select(d => d.DIC_LOG_NM).FirstOrDefault() ?? "";
                            WBCommon.GetBlank(substr);
                            string dataType = "string";

                            DTO_TEXT_R += string.Format("{1}{1}private {2} {3};{0}", (object)WBCommon.BR, (object)"    ", (object)dataType, (object)substr.ToLower());
                            DTO_TEXT_R += WBCommon.SUMMARY.Replace("#TITLE#", col_comment.Trim());
                            DTO_TEXT_R += string.Format("{0}{1}{1}[DataMember]{0}", (object)WBCommon.BR, (object)"    ");
                            DTO_TEXT_R += string.Format("{1}{1}public {2} {3}{0}", (object)WBCommon.BR, (object)"    ", (object)dataType, (object)substr.ToUpper());
                            DTO_TEXT_R += string.Format("{1}{1}{{ {0}", (object)WBCommon.BR, (object)"    ");
                            DTO_TEXT_R += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)WBCommon.BR, (object)"    ", (object)substr.ToLower());
                            DTO_TEXT_R += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)WBCommon.BR, (object)"    "
                                                    , (object)substr.ToLower(), (object)substr.ToUpper());
                            DTO_TEXT_R += string.Format("{1}{1}}} {0}{0}", (object)WBCommon.BR, (object)"    ");
                        }
                    }
                }
                else if (this.DTO_DRTN_SEL.DATA_TYPE_CD == "2")
                {
                    for (int i = 0; i < inPara.Count(); i++)
                    {
                        substr = GetDTOText(inPara[i]);
                        if (!string.IsNullOrEmpty(substr))
                        {
                            this.META_SEARCH_IN.TEXT = substr.ToUpper();
                            col_comment = USERINFO.EXCN_META == true ? "" : dac.GetMetaList(this.META_SEARCH_IN).Select(d => d.DIC_LOG_NM).FirstOrDefault() ?? "";
                            WBCommon.GetBlank(substr);
                            string dataType = "string";

                            DTO_TEXT_R += string.Format("{1}{1}private {2} {3};{0}", (object)WBCommon.BR, (object)"    ", (object)dataType, (object)substr.ToLower());
                        }
                    }
                    DTO_TEXT_R += WBCommon.BR;
                    for (int i = 0; i < inPara.Count(); i++)
                    {
                        substr = GetDTOText(inPara[i]);
                        if (!string.IsNullOrEmpty(substr))
                        {
                            this.META_SEARCH_IN.TEXT = substr.ToUpper();
                            col_comment = USERINFO.EXCN_META == true ? "" : dac.GetMetaList(this.META_SEARCH_IN).Select(d => d.DIC_LOG_NM).FirstOrDefault() ?? "";
                            WBCommon.GetBlank(substr);
                            string dataType = "string";

                            DTO_TEXT_R += WBCommon.SUMMARY.Replace("#TITLE#", col_comment.Trim());
                            DTO_TEXT_R += string.Format("{0}{1}{1}[DataMember]{0}", (object)WBCommon.BR, (object)"    ");
                            DTO_TEXT_R += string.Format("{1}{1}public {2} {3}{0}", (object)WBCommon.BR, (object)"    ", (object)dataType, (object)substr.ToUpper());
                            DTO_TEXT_R += string.Format("{1}{1}{{ {0}", (object)WBCommon.BR, (object)"    ");
                            DTO_TEXT_R += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)WBCommon.BR, (object)"    ", (object)substr.ToLower());
                            DTO_TEXT_R += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)WBCommon.BR, (object)"    "
                                                    , (object)substr.ToLower(), (object)substr.ToUpper());
                            DTO_TEXT_R += string.Format("{1}{1}}} {0}{0}", (object)WBCommon.BR, (object)"    ");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                thisWindow.ErrorMsg(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요.", ex.ToString()));
            }
        }

        /// <summary>
        /// name         : IN 파라미터 변환
        /// desc         : IN 파라미터 변환
        /// author       : 오원빈
        /// create date  : 2022-10-18
        /// update date  : 2022-10-18
        /// </summary>
        /// <remarks></remarks>
        private void AutoCommaText(object p)
        {
            string text = p is string ? p.ToString() : COMMA_TEXT;
            COMMA_TEXT_R = "";
            if (string.IsNullOrEmpty(text))
            {
                //if (SYNC)
                //    SyncText(text);
                return;
            }
            string substr = "";
            string[] inPara = text.Split('\n');

            if (inPara.Count() < 1) return;

            for (int i = 0; i < inPara.Count(); i++)
            {
                substr = GetCommaText(inPara[i]);
                COMMA_TEXT_R += substr;
            }
            if(COMMA_SEL.DATA_TYPE_NM == "가로" && COMMA_TEXT_R.Length > 0)
                COMMA_TEXT_R = "(" + COMMA_TEXT_R.Substring(0, COMMA_TEXT_R.Length - 1) + ")";
            else if(COMMA_TEXT_R.Length > 0)
                COMMA_TEXT_R = "(" + WBCommon.BR + " " + COMMA_TEXT_R.Substring(0, COMMA_TEXT_R.Length - 1) + ")";

            //if (SYNC)
            //    SyncText(text);
        }

        /// <summary>
        /// name         : View 프로퍼티 변환
        /// desc         : View 프로퍼티 변환
        /// author       : 오원빈
        /// create date  : 2022-10-18
        /// update date  : 2022-10-18
        /// </summary>
        /// <remarks></remarks>
        private void AutoViewText(object p)
        {
            try
            {
                string text = p is string ? p.ToString() : VIEW_TEXT;
                VIEW_TEXT_R = "";
                if (string.IsNullOrEmpty(text))
                {
                    //if (SYNC)
                    //    SyncText(text);
                    return;
                }

                string substr = "";
                string col_comment = "";
                string dataType = DATATYPE_SEL == null ? DATA_TYPE_NM : DATATYPE_SEL.DATA_TYPE_NM;
                string[] inPara = text.Split('\n');

                if (inPara.Count() < 1) return;
                for (int i = 0; i < inPara.Count(); i++)
                {
                    substr = GetDTOText(inPara[i]);
                    if (!string.IsNullOrEmpty(substr))
                    {
                        this.META_SEARCH_IN.TEXT = substr.ToUpper();
                        col_comment = USERINFO.EXCN_META == true ? "" : dac.GetMetaList(this.META_SEARCH_IN).Select(d => d.DIC_LOG_NM).FirstOrDefault() ?? "";
                        WBCommon.GetBlank(substr);

                        VIEW_TEXT_R += string.Format("{1}{1}private {2} {3};{0}", (object)WBCommon.BR, (object)"    ", (object)dataType, (object)substr.ToLower());
                        VIEW_TEXT_R += WBCommon.SUMMARY.Replace("#TITLE#", col_comment.Trim());
                        VIEW_TEXT_R += string.Format("{0}", (object)WBCommon.BR, (object)"    ");
                        VIEW_TEXT_R += string.Format("{1}{1}public {2} {3}{0}", (object)WBCommon.BR, (object)"    ", (object)dataType, (object)substr.ToUpper());
                        VIEW_TEXT_R += string.Format("{1}{1}{{ {0}", (object)WBCommon.BR, (object)"    ");
                        VIEW_TEXT_R += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)WBCommon.BR, (object)"    ", (object)substr.ToLower());
                        VIEW_TEXT_R += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)WBCommon.BR, (object)"    "
                                                , (object)substr.ToLower(), (object)substr.ToUpper());
                        VIEW_TEXT_R += string.Format("{1}{1}}} {0}{0}", (object)WBCommon.BR, (object)"    ");
                    }
                }
            }
            catch (Exception ex)
            {
                thisWindow.ErrorMsg(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요.", ex.ToString()));
            }
        }
        /// <summary>
        /// name         : 날짜 타입 자동변환
        /// desc         : 날짜 타입 자동변환
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-28
        /// update date  : 2022-10-28
        /// </summary>
        /// <remarks></remarks>
        private void AutoDateText(object p)
        {
            CONVERT_DATE_TEXT_R = "";
            CONVERT_DATE_TEXT_R2 = "";


            if (string.IsNullOrEmpty(CONVERT_DATE_TEXT))
            {                
                return;
            }

            string substr = "";            
            string[] dataType = CONVERTTYPE_SEL.DATA_TYPE_CD.Split('*');
            string[] inPara = CONVERT_DATE_TEXT.Split(new char[] { '\n' ,'\r'},StringSplitOptions.RemoveEmptyEntries);

            if (inPara.Count() < 1) return;
            //CONVERT_DATE_TEXT_R
            for (int i = 0; i < inPara.Count(); i++)
            {
                string code = "";
                substr = inPara[i].TrimEnd(' ');
                if (!string.IsNullOrEmpty(substr))
                {
                    code += string.Format("{0}({1},'{2}')", dataType[0], substr, dataType[1]);
                    if (!Regex.IsMatch(substr, @"-|:") && Regex.IsMatch(code, @"(?<=\()[\0-9].*(?=\,)"))
                    {
                        code = Regex.Replace(code, @"-|:", string.Empty);
                    }
                    code = Regex.Replace(code, @"(?<=\()[\0-9].*(?=\,)", new MatchEvaluator(GetString));                   
                }
                CONVERT_DATE_TEXT_R += code + WBCommon.BR;
            }
            CONVERT_DATE_TEXT_R = CONVERT_DATE_TEXT_R.TrimEnd(new char[] { '\n', '\r' });
            //CONVERT_DATE_TEXT_R2
            if (inPara.Count() == 1)
            {
                for (int i = 0; i < 2; i++)
                {
                    string code = "";
                    substr = inPara[0].TrimEnd(' ');
                    if (!string.IsNullOrEmpty(substr))
                    {
                        code += string.Format("{0}({1},'{2}')", dataType[0], substr, dataType[1]);
                        if (!Regex.IsMatch(substr, @"-|:") && Regex.IsMatch(code, @"(?<=\()[\0-9].*(?=\,)"))
                        {
                            code = Regex.Replace(code, @"-|:", string.Empty);
                        }
                        code = Regex.Replace(code, @"(?<=\()[\0-9].*(?=\,)", new MatchEvaluator(GetString));

                    }
                    CONVERT_DATE_TEXT_R2 += code + (i == 0 ? " AND " : i == 1 ? " + .99999" : "");
                }
            }
            else if (inPara.Count() == 2)
            {
                for (int i = 0; i < inPara.Count(); i++)
                {
                    string code = "";
                    substr = inPara[i].TrimEnd(' ');
                    if (!string.IsNullOrEmpty(substr))
                    {
                        code += string.Format("{0}({1},'{2}')", dataType[0], substr, dataType[1]);
                        if (!Regex.IsMatch(substr, @"-|:") && Regex.IsMatch(code, @"(?<=\()[\0-9].*(?=\,)"))
                        {
                            code = Regex.Replace(code, @"-|:", string.Empty);
                        }
                        code = Regex.Replace(code, @"(?<=\()[\0-9].*(?=\,)", new MatchEvaluator(GetString));
                    }
                    CONVERT_DATE_TEXT_R2 += code + (i == 0? " AND " : i == 1? " + .99999" : "");
                }
            }
            else
            {
                for (int i = 0; i < inPara.Count(); i++)
                {
                    string code = "";
                    substr = inPara[i].TrimEnd(' ');
                    if (!string.IsNullOrEmpty(substr))
                    {
                        code += string.Format("{0}({1},'{2}')", dataType[0], substr, dataType[1]);
                        if (!Regex.IsMatch(substr, @"-|:") && Regex.IsMatch(code, @"(?<=\()[\0-9].*(?=\,)"))
                        {
                            code = Regex.Replace(code, @"-|:", string.Empty);
                        }
                        code = Regex.Replace(code, @"(?<=\()[\0-9].*(?=\,)", new MatchEvaluator(GetString));
                    }
                    CONVERT_DATE_TEXT_R2 += code + WBCommon.BR;
                }
            }
            CONVERT_DATE_TEXT_R2 = CONVERT_DATE_TEXT_R2.TrimEnd(new char[] { '\n', '\r' });
        }
        /// <summary>
        /// name         : IN 파라미터 변환
        /// desc         : IN 파라미터 변환
        /// author       : 오원빈
        /// create date  : 2022-10-18
        /// update date  : 2022-10-18
        /// </summary>
        /// <remarks></remarks>
        private void AutoErrorText(object p)
        {
            string text = p is string ? p.ToString() : ERROR_PARAM;
            ERROR_PARAM_RSLT = "RAISE_APPLICATION_ERROR(-20001,";
            if (string.IsNullOrEmpty(text))
            {
                //if (SYNC)
                //    SyncText(text);
                return;
            }
            string substr = "";
            string[] inPara = text.Split(new char[] { '\n', '\r' },StringSplitOptions.RemoveEmptyEntries);

            if (inPara.Count() < 1) return;

            for (int i = 0; i < inPara.Count(); i++)
            {
                substr = GetInParam(inPara[i]);
                ERROR_PARAM_RSLT += substr + " || " + ":" + inPara[i].Trim() + " || " + "' , '" + " || ";
            }
            ERROR_PARAM_RSLT += "' ERRMSG : ' || SQLERRM);";

            //if (SYNC)
            //    SyncText(text);
        }
        private string GetInParam(string inparam)
        {
            string code = string.Empty;
            inparam = ExceptionText(inparam);
            if (!string.IsNullOrEmpty(inparam))
                code = "'" + inparam  + " : " + "'";
            return code;
        }
        private string GetString(Match m)
        {
            string code = m.Value;
            //if (!Regex.IsMatch(code, @"-|:"))
            //    code = Regex.Replace(m.Value, @"-|:", string.Empty);
            return "\'" + code + "\'";
        }
        private string GetDTOText(string inPara)
        {
            string strSubstr = inPara.Trim();

            strSubstr = ExceptionText(strSubstr);

            return strSubstr;
        }

        private string GetExecParm(string col_name)
        {
            string execParm = string.Empty;
            col_name = ExceptionText2(col_name.Trim());
            string param = "";
            if(Regex.IsMatch(col_name, @"(?<=\s).+"))
            {
                Regex.Replace(col_name, @"(?<=\s).+", new MatchEvaluator(m => param = m.Value.Trim()));
                Regex.Replace(col_name, @"^.+?(?=\s)", new MatchEvaluator(m => col_name = m.Value.Trim()));
            }
            if (!string.IsNullOrEmpty(col_name))
                execParm = "EXEC " + ":" + col_name.ToUpper() + WBCommon.GetBlank("EXEC " + ":" + col_name,30) + string.Format(" := '{0}';",param)+ WBCommon.BR;
            return execParm;
        }
        private string GetCommaText(string comma_text)
        {
            string comma = string.Empty;
            comma_text = ExceptionText(comma_text);
            if(!string.IsNullOrEmpty(comma_text))
                comma = "'" + comma_text + "'" + COMMA_SEL.DATA_TYPE_CD;
            return comma;
        }
        private string ExceptionText(string str)
        {
            string[] seperator = { ",", " ", "\n", "\r" };

            foreach (string item in seperator)
            {
                if (str.IndexOf(item) >= 0 && str.Length > 0)
                {
                    str = Regex.Replace(str, @item, "");
                    //str = str.Substring(0, str.IndexOf(item));
                }
            }
            return str;
        }
        private string ExceptionText2(string str)
        {
            string[] seperator = { ",", "\n", "\r" };

            foreach (string item in seperator)
            {
                if (str.IndexOf(item) >= 0 && str.Length > 0)
                {
                    str = Regex.Replace(str, @item, "");
                }
            }
            return str;
        }
        public void SyncText(string syncText)
        {
            this.DTO_TEXT = this.EQS_TEXT = this.VIEW_TEXT = this.COMMA_TEXT = this.ERROR_PARAM = syncText;
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
            SourceGeneraterDL sourceGeneraterDL = new SourceGeneraterDL();
            SourceGenerater_INOUT param = new SourceGenerater_INOUT();
            param = p as SourceGenerater_INOUT;
            this.PAKAGE_LIST = sourceGeneraterDL.SelectPKG(param);

            if (this.PAKAGE_LIST.Count > 0)
            {
                this.PAKAGE_SEL = this.PAKAGE_LIST.FirstOrDefault();
            }
        }
        #endregion
    }
}
