using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows.Input;
using System.Xml;
using WB.Common;
using WB.DAC;
using WB.DTO;

namespace WB
{
    public class SelectEqsDBSourceData : ViewModelBase
    {
        public SelectEqsDBSource thisWindow;
        #region [dac]
        SelectEqsDBSourceDL dac = new SelectEqsDBSourceDL();
        #endregion
        #region [Constructor]
        public SelectEqsDBSourceData()
        {
            if (LicenseManager.UsageMode == LicenseUsageMode.Designtime) return;
            this.Init();
        }
        #endregion
        #region [View Property]
        private string eqs_db_text;
        /// <summary>
        /// 
        /// </summary>
        public string EQS_DB_TEXT
        {
            get { return this.eqs_db_text; }
            set 
            { 
                if (this.eqs_db_text != value) 
                { 
                    this.eqs_db_text = value;
                    //this.thisWindow.txtCode.Text = value;
                    OnPropertyChanged(nameof(EQS_DB_TEXT)); 
                } 
            }
        }


        private string query_id;
        /// <summary>
        /// 
        /// </summary>
        public string QUERY_ID
        {
            get { return this.query_id; }
            set { if (this.query_id != value) { this.query_id = value; OnPropertyChanged("QUERY_ID", value); } }
        }

        private bool antn = true;
        /// <summary>
        /// 주석
        /// </summary>
        public bool ANTN
        {
            get { return this.antn; }
            set { if (this.antn != value) { this.antn = value; OnPropertyChanged("ANTN", value); } }
        }


        #endregion
        #region [Member Property]
        private SelectEqsDBSource_INOUT dblike_sel;
        /// <summary>
        /// name         : DB 리스트 조회 선택 DTO
        /// desc         : DB 리스트 조회 선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        public SelectEqsDBSource_INOUT DBLIKE_SEL
        {
            get { return this.dblike_sel; }
            set { if (this.dblike_sel != value) { this.dblike_sel = value; OnPropertyChanged("DBLIKE_SEL", value); } }
        }



        private List<SelectEqsDBSource_INOUT> dblike_list = new List<SelectEqsDBSource_INOUT>();
        /// <summary>
        /// name         : DB 리스트 조회 리스트
        /// desc         : DB 리스트 조회 리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        public List<SelectEqsDBSource_INOUT> DBLIKE_LIST
        {
            get { return this.dblike_list; }
            set { if (this.dblike_list != value) { this.dblike_list = value; OnPropertyChanged("DBLIKE_LIST", value); } }
        }


        private SelectEqsDBSource_INOUT eqslike_sel;
        /// <summary>
        /// name         : EQS 리스트 조회 선택 DTO
        /// desc         : EQS 리스트 조회 선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        public SelectEqsDBSource_INOUT EQSLIKE_SEL
        {
            get { return this.eqslike_sel; }
            set { if (this.eqslike_sel != value) { this.eqslike_sel = value; OnPropertyChanged("EQSLIKE_SEL", value); } }
        }



        private List<SelectEqsDBSource_INOUT> eqslike_list = new List<SelectEqsDBSource_INOUT>();
        /// <summary>
        /// name         : EQS 리스트 조회 리스트
        /// desc         : EQS 리스트 조회 리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        public List<SelectEqsDBSource_INOUT> EQSLIKE_LIST
        {
            get { return this.eqslike_list; }
            set { if (this.eqslike_list != value) { this.eqslike_list = value; OnPropertyChanged("EQSLIKE_LIST", value); } }
        }


        private SelectEqsDBSource_INOUT eqsdbsource_sel;
        /// <summary>
        /// name         : EQS,DB조회 선택 DTO
        /// desc         : EQS,DB조회 선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        public SelectEqsDBSource_INOUT EQSDBSOURCE_SEL
        {
            get { return this.eqsdbsource_sel; }
            set { if (this.eqsdbsource_sel != value) { this.eqsdbsource_sel = value; OnPropertyChanged("EQSDBSOURCE_SEL", value); } }
        }



        private List<SelectEqsDBSource_INOUT> eqsdbsource_list = new List<SelectEqsDBSource_INOUT>();
        /// <summary>
        /// name         : EQS,DB조회 리스트
        /// desc         : EQS,DB조회 리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        public List<SelectEqsDBSource_INOUT> EQSDBSOURCE_LIST
        {
            get { return this.eqsdbsource_list; }
            set { if (this.eqsdbsource_list != value) { this.eqsdbsource_list = value; OnPropertyChanged("EQSDBSOURCE_LIST", value); } }
        }


        #endregion
        #region [Command]
        private ICommand selectEqsDBSourceCommand;
        /// <summary>
        /// name         : EQS,DB조회
        /// desc         : EQS,DB조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        public ICommand SelectEqsDBSourceCommand
        {
            get
            {
                if (selectEqsDBSourceCommand == null)
                    selectEqsDBSourceCommand = new RelayCommand(p => this.SelectEqsDBSource(p));
                return selectEqsDBSourceCommand;
            }
        }

        private ICommand eQSSelectionChangedCommand;
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        public ICommand EQSSelectionChangedCommand
        {
            get
            {
                if (eQSSelectionChangedCommand == null)
                    eQSSelectionChangedCommand = new RelayCommand(p => this.EQSSelectionChanged(p));
                return eQSSelectionChangedCommand;
            }
        }
        private ICommand dBSelectionChangedCommand;
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        public ICommand DBSelectionChangedCommand
        {
            get
            {
                if (dBSelectionChangedCommand == null)
                    dBSelectionChangedCommand = new RelayCommand(p => this.DBSelectionChanged(p));
                return dBSelectionChangedCommand;
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
        /// name         : EQS,DB조회
        /// desc         : EQS,DB조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        private void SelectEqsDBSource(object p)
        {
            if (p is null && string.IsNullOrEmpty(QUERY_ID)) return;
            thisWindow.txtCode.SetFocusGubn(1);
            EQS_DB_TEXT = "";
            SelectEqsDBSource_INOUT param = new SelectEqsDBSource_INOUT();
            param.EQS_ID = p is null ? QUERY_ID.TrimEnd(' ') : p.ToString().TrimEnd(' ');
            this.EQSDBSOURCE_LIST = dac.SelectEqsDBSource(param);
            if (this.EQSDBSOURCE_LIST is null) return;

            if ( this.EQSDBSOURCE_LIST.Count > 0)
            {
                this.EQSDBSOURCE_SEL = this.EQSDBSOURCE_LIST.FirstOrDefault();

                //thisWindow.txtCode.Text = EQSDBSOURCE_SEL.REPLACE_QUERY_TEXT;
                if (EQSDBSOURCE_SEL == null || string.IsNullOrEmpty(EQSDBSOURCE_SEL.QUERYTEXT)) return;
                string input = GetQueryText(EQSDBSOURCE_SEL.QUERYTEXT);
                string str1 = "";
                List<string> source = new List<string>();
                foreach (Match match in Regex.Matches(input, "(?<!\\w):\\w+"))
                {
                    if (!(match.Value.ToUpper() == ":MI") && !(match.Value.ToUpper() == ":SS"))
                        source.Add(match.ToString());
                }
                foreach (string str2 in source.Distinct<string>().ToList<string>())
                    str1 = str1 + "EXEC " + str2 + " := '';" + Environment.NewLine;
                if (str1 != "")
                    str1 += Environment.NewLine;
                if (ANTN)
                    EQS_DB_TEXT = str1 + GetQueryText(EQSDBSOURCE_SEL.QUERYTEXT);
                else
                    EQS_DB_TEXT = str1 + EQSDBSOURCE_SEL.REPLACE_QUERY_TEXT;

            }
            else if(this.EQSDBSOURCE_LIST.Count == 0)
            {
                SelectDBSource(p);
            }
            if (p is null)
            {
                //EQS리스트 조회
                SelectEQSLike(p);
                //DB리스트 조회
                SelectDBLike(p);
            }
        }

        /// <summary>
        /// name         : DB조회
        /// desc         : DB조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        private void SelectDBSource(object p)
        {
            thisWindow.txtCode.SetFocusGubn(1);
            SelectEqsDBSource_INOUT param = new SelectEqsDBSource_INOUT();
            StringBuilder stringBuilder = new StringBuilder();
            param.NAME = p is null ? QUERY_ID.TrimEnd(' ') : p.ToString().TrimEnd(' ');
            this.EQSDBSOURCE_LIST = dac.SelectDBSource(param);

            if (this.EQSDBSOURCE_LIST.Count() > 0)
            {
                foreach (SelectEqsDBSource_INOUT source in EQSDBSOURCE_LIST)
                {
                    stringBuilder.Append(source.TEXT);
                }                
                EQS_DB_TEXT = stringBuilder.ToString();
            }            
            else
            {               
                EQS_DB_TEXT = "EQS 및 ALL_SOURCE View 찾지 못함.";            
            }
        }

        private string GetQueryText(string query)
        {
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.LoadXml(query);
            string queryText = xmlDocument.SelectNodes("sql")[0].InnerText.Trim();

            //var nodeList = xmlDocument.DocumentElement.ChildNodes;            
            //for (int i = 0; i < nodeList.Count; i++)
            //{
            //    queryText = nodeList[i].InnerXml;
            //    queryText = nodeList[i].InnerText;
            //}
            
            queryText.ToUpper();
            return queryText;
        }

        /// <summary>
        /// name         : EQS 리스트 조회
        /// desc         : EQS 리스트 조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        private void SelectEQSLike(object p)
        {
            SelectEqsDBSource_INOUT param = new SelectEqsDBSource_INOUT();
            param.EQS_ID = QUERY_ID;
            this.EQSLIKE_LIST = dac.SelectEQSSourceLike(param);

            if (this.EQSLIKE_LIST.Count > 0)
            {
                this.EQSLIKE_SEL = this.EQSLIKE_LIST.FirstOrDefault();
            }
        }
        /// <summary>
        /// name         : DB 리스트 조회
        /// desc         : DB 리스트 조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        private void SelectDBLike(object p)
        {
            SelectEqsDBSource_INOUT param = new SelectEqsDBSource_INOUT();
            param.NAME = QUERY_ID;
            this.DBLIKE_LIST = dac.SelectDBSourceLike(param);

            if (this.DBLIKE_LIST.Count > 0)
            {
                this.DBLIKE_SEL = this.DBLIKE_LIST.FirstOrDefault();
            }
        }
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        private void DBSelectionChanged(object p)
        {            
            if (DBLIKE_SEL is null || string.IsNullOrEmpty(DBLIKE_SEL.NAME)) return;
            if(DBLIKE_SEL.TYPE == "VIEW")
                EQS_DB_TEXT = thisWindow.GetViewSource(DBLIKE_SEL.OWNER, DBLIKE_SEL.NAME);
            else
                SelectDBSource(DBLIKE_SEL.NAME);
        }
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        /// <remarks></remarks>
        private void EQSSelectionChanged(object p)
        {
            if (EQSLIKE_SEL is null || string.IsNullOrEmpty(EQSLIKE_SEL.QUERYID)) return;
            SelectEqsDBSource(EQSLIKE_SEL.QUERYID);
        }
        #endregion
    }
}
