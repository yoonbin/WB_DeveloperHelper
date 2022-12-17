using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Data;
using System.Deployment.Application;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;
using System.Xml.Serialization;
using WB.Common;
using WB.DTO;
using WB.UC;

namespace WB
{
    public class ViewModelBase :DTOBase
    {
        #region [DAC]
        MetaDL dac = new MetaDL();
        #endregion
        
        #region [View Property]
        public delegate void Delegate();
        private string popup_yn;
        /// <summary>
        /// 
        /// </summary>
        public string POPUP_YN
        {
            get { return this.popup_yn; }
            set { if (this.popup_yn != value) { this.popup_yn = value; OnPropertyChanged("POPUP_YN", value); } }
        }


        private string tr_table = "";
        /// <summary>
        /// 
        /// </summary>
        public string TR_TABLE
        {
            get { return this.tr_table; }
            set { if (this.tr_table != value) { this.tr_table = value; OnPropertyChanged("TR_TABLE", value); } }
        }

        private string alias = "A";
        /// <summary>
        /// 
        /// </summary>
        public string ALIAS
        {
            get { return this.alias; }
            set { if (this.alias != value) { this.alias = value; OnPropertyChanged("ALIAS", value); } }
        }
        private string alias2 = "A";
        /// <summary>
        /// 
        /// </summary>
        public string ALIAS2
        {
            get { return this.alias2; }
            set { if (this.alias2 != value) { this.alias2 = value; OnPropertyChanged("ALIAS2", value); } }
        }

        private string search_fav_text;
        /// <summary>
        /// 
        /// </summary>
        public string SEARCH_FAV_TEXT
        {
            get { return this.search_fav_text; }
            set { if (this.search_fav_text != value) { this.search_fav_text = value; OnPropertyChanged("SEARCH_FAV_TEXT", value); } }
        }


        private bool sel_chg_stop;
        /// <summary>
        /// 
        /// </summary>
        public bool SEL_CHG_STOP
        {
            get { return this.sel_chg_stop; }
            set { if (this.sel_chg_stop != value) { this.sel_chg_stop = value; OnPropertyChanged("SEL_CHG_STOP", value); } }
        }

        private DataGridSelectionUnit unit = DataGridSelectionUnit.FullRow;
        /// <summary>
        /// 단위
        /// </summary>
        public DataGridSelectionUnit UNIT
        {
            get { return this.unit; }
            set { if (this.unit != value) { this.unit = value; OnPropertyChanged("UNIT", value); } }
        }
        private string table_category;
        /// <summary>
        /// 
        /// </summary>
        public string TABLE_CATEGORY
        {
            get { return this.table_category; }
            set { if (this.table_category != value) { this.table_category = value; OnPropertyChanged("TABLE_CATEGORY", value); } }
        }



        private string search_text;
        /// <summary>
        /// name : SEARCH_TEXT
        /// </summary>        
        public string SEARCH_TEXT
        {
            get { return this.search_text; }
            set { if (this.search_text != value) { this.search_text = value; OnPropertyChanged("SEARCH_TEXT", value); } }
        }
        private string search_text_detail;
        /// <summary>
        /// name : SEARCH_TEXT_DETAIL
        /// </summary>
        public string SEARCH_TEXT_DETAIL
        {
            get { return this.search_text_detail; }
            set { if (this.search_text_detail != value) { this.search_text_detail = value; OnPropertyChanged("SEARCH_TEXT_DETAIL", value); } }
        }
        private string search_text_index;
        /// <summary>
        /// name : SEARCH_TEXT_INDEX
        /// </summary>
        public string SEARCH_TEXT_INDEX
        {
            get { return this.search_text_index; }
            set { if (this.search_text_index != value) { this.search_text_index = value; OnPropertyChanged("SEARCH_TEXT_INDEX", value); } }
        }

        private bool fsr_seq_yn = true;
        /// <summary>
        /// name : FSR_SEQ_YN
        /// </summary>        
        public bool FSR_SEQ_YN
        {
            get { return this.fsr_seq_yn; }
            set { if (this.fsr_seq_yn != value) { this.fsr_seq_yn = value; OnPropertyChanged("FSR_SEQ_YN", value); } }
        }



        private bool all_check = false;
        /// <summary>
        /// name : ALL_CHECK
        /// </summary>        
        public bool ALL_CHECK
        {
            get { return this.all_check; }
            set { if (this.all_check != value) { this.all_check = value; OnPropertyChanged("ALL_CHECK", value); } }
        }
        private bool exec_check;
        /// <summary>
        /// name : EXEC_CHECK
        /// </summary>        
        public bool EXEC_CHECK
        {
            get { return this.exec_check; }
            set { if (this.exec_check != value) { this.exec_check = value; OnPropertyChanged("EXEC_CHECK", value); } }
        }

        private bool chk_sc_stop;
        /// <summary>
        /// 
        /// </summary>
        public bool CHK_SC_STOP
        {
            get { return this.chk_sc_stop; }
            set { if (this.chk_sc_stop != value) { this.chk_sc_stop = value; OnPropertyChanged("CHK_SC_STOP", value); } }
        }

        private bool chk_cell_unit;
        /// <summary>
        /// 
        /// </summary>
        public bool CHK_CELL_UNIT
        {
            get { return this.chk_cell_unit; }
            set { if (this.chk_cell_unit != value) { this.chk_cell_unit = value; OnPropertyChanged("CHK_CELL_UNIT", value); } }
        }


        private DataTable _DT = new DataTable();
        /// <summary>
        /// name : GBN
        /// </summary>        
        public DataTable DT
        {
            get { return this._DT; }
            set { if (this._DT != value) { this._DT = value; OnPropertyChanged("DT", value); } }
        }
        private string sel_table_name;
        /// <summary>
        /// 
        /// </summary>
        public string SEL_TABLE_NAME
        {
            get { return this.sel_table_name; }
            set { if (this.sel_table_name != value) { this.sel_table_name = value; OnPropertyChanged("SEL_TABLE_NAME", value); } }
        }
        private string search_ref_obj;
        /// <summary>
        /// 
        /// </summary>
        public string SEARCH_REF_OBJ
        {
            get { return this.search_ref_obj; }
            set { if (this.search_ref_obj != value) { this.search_ref_obj = value; OnPropertyChanged("SEARCH_REF_OBJ", value); } }
        }



        #endregion
        #region [Member Property]

        private UserInfo_INOUT UserInfo = new UserInfo_INOUT();
        /// <summary>
        /// name         : USERINFO
        /// desc         : USERINFO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-03
        /// update date  : 2022-11-03
        /// </summary>
        /// <remarks></remarks>
        public UserInfo_INOUT USERINFO
        {
            get { return this.UserInfo; }
            set { if (this.UserInfo != value) { this.UserInfo = value; OnPropertyChanged("USERINFO", value); } }
        }

        private List<Meta_INOUT> metagrid = new List<Meta_INOUT>();
        /// <summary>
        /// name : METAGRID
        /// </summary>        
        public List<Meta_INOUT> METAGRID
        {
            get { return this.metagrid; }
            set { if (this.metagrid != value) { this.metagrid = value; OnPropertyChanged("METAGRID", value); } }
        }
        private List<Meta_INOUT> querygrid = new List<Meta_INOUT>();
        /// <summary>
        /// name : QUERYGRID
        /// </summary>        
        public List<Meta_INOUT> QUERYGRID
        {
            get { return this.querygrid; }
            set { if (this.querygrid != value) { this.querygrid = value; OnPropertyChanged("QUERYGRID", value); } }
        }
        private Meta_INOUT _META_SEARCH_IN = new Meta_INOUT();
        /// <summary>
        /// name : GBN
        /// </summary>        
        public Meta_INOUT META_SEARCH_IN
        {
            get { return this._META_SEARCH_IN; }
            set { if (this._META_SEARCH_IN != value) { this._META_SEARCH_IN = value; OnPropertyChanged("META_SEARCH_IN", value); } }
        }

        private TableInfo_INOUT tablerefobject_sel;
        /// <summary>
        /// name         : 테이블 관련 Obj조회 선택 DTO
        /// desc         : 테이블 관련 Obj조회 선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-24
        /// update date  : 2022-11-24
        /// </summary>
        /// <remarks></remarks>
        public TableInfo_INOUT TABLEREFOBJECT_SEL
        {
            get { return this.tablerefobject_sel; }
            set { if (this.tablerefobject_sel != value) { this.tablerefobject_sel = value; OnPropertyChanged("TABLEREFOBJECT_SEL", value); } }
        }



        private List<TableInfo_INOUT> tablerefobject_list = new List<TableInfo_INOUT>();
        /// <summary>
        /// name         : 테이블 관련 Obj조회 리스트
        /// desc         : 테이블 관련 Obj조회 리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-24
        /// update date  : 2022-11-24
        /// </summary>
        /// <remarks></remarks>
        public List<TableInfo_INOUT> TABLEREFOBJECT_LIST
        {
            get { return this.tablerefobject_list; }
            set { if (this.tablerefobject_list != value) { this.tablerefobject_list = value; OnPropertyChanged("TABLEREFOBJECT_LIST", value); } }
        }



        private ObservableCollection<Meta_INOUT> query_lsit = new ObservableCollection<Meta_INOUT>();
        public ObservableCollection<Meta_INOUT> QUERY_LIST
        {
            get => this.query_lsit;
            set => this.query_lsit = value;
        }


        private List<TableInfo_INOUT> tableGrid = new List<TableInfo_INOUT>();
        /// <summary>
        /// name : METAGRID
        /// </summary>        
        public List<TableInfo_INOUT> TABLEGRID
        {
            get { return this.tableGrid; }
            set { if (this.tableGrid != value) { this.tableGrid = value; OnPropertyChanged("TABLEGRID", value); } }
        }

        private TableInfo_INOUT tableGrid_sel = new TableInfo_INOUT();
        /// <summary>
        /// name : METAGRID
        /// </summary>        
        public TableInfo_INOUT TABLEGRID_SEL
        {
            get { return this.tableGrid_sel; }
            set { if (this.tableGrid_sel != value) { this.tableGrid_sel = value; OnPropertyChanged("TABLEGRID_SEL", value); } }
        }

        private List<TableInfo_INOUT> alltablegrid;
        /// <summary>
        /// name : METAGRID
        /// </summary>        
        public List<TableInfo_INOUT> ALLTABLEGRID
        {
            get { return this.alltablegrid; }
            set { if (this.alltablegrid != value) { this.alltablegrid = value; OnPropertyChanged("ALLTABLEGRID", value); } }
        }
        private TableInfo_INOUT _TABLEGRID_IN = new TableInfo_INOUT();
        /// <summary>
        /// name : GBN
        /// </summary>        
        public TableInfo_INOUT TABLEGRID_IN
        {
            get { return this._TABLEGRID_IN; }
            set { if (this._TABLEGRID_IN != value) { this._TABLEGRID_IN = value; OnPropertyChanged("TABLEGRID_IN", value); } }
        }


        private TableInfo_INOUT indextable_sel;
        /// <summary>
        /// name         : 테이블인덱스 선택 DTO
        /// desc         : 테이블인덱스 선택 DTO
        /// author       : 오원빈
        /// create date  : 2022-10-13
        /// update date  : 2022-10-13
        /// </summary>
        /// <remarks></remarks>
        public TableInfo_INOUT INDEXTABLE_SEL
        {
            get { return this.indextable_sel; }
            set { if (this.indextable_sel != value) { this.indextable_sel = value; OnPropertyChanged("INDEXTABLE_SEL", value); } }
        }



        private List<TableInfo_INOUT> indextable_list;
        /// <summary>
        /// name         : 테이블인덱스 리스트
        /// desc         : 테이블인덱스 리스트
        /// author       : 오원빈
        /// create date  : 2022-10-13
        /// update date  : 2022-10-13
        /// </summary>
        /// <remarks></remarks>
        public List<TableInfo_INOUT> INDEXTABLE_LIST
        {
            get { return this.indextable_list; }
            set { if (this.indextable_list != value) { this.indextable_list = value; OnPropertyChanged("INDEXTABLE_LIST", value); } }
        }

        private TableInfo_INOUT comncd_sel;
        /// <summary>
        /// name         : 공통코드 선택 DTO
        /// desc         : 공통코드 선택 DTO
        /// author       : 오원빈
        /// create date  : 2022-10-13
        /// update date  : 2022-10-13
        /// </summary>
        /// <remarks></remarks>
        public TableInfo_INOUT COMNCD_SEL
        {
            get { return this.comncd_sel; }
            set { if (this.comncd_sel != value) { this.comncd_sel = value; OnPropertyChanged("COMNCD_SEL", value); } }
        }



        private List<TableInfo_INOUT> comncd_list;
        /// <summary>
        /// name         : 공통코드 리스트
        /// desc         : 공통코드 리스트
        /// author       : 오원빈
        /// create date  : 2022-10-13
        /// update date  : 2022-10-13
        /// </summary>
        /// <remarks></remarks>
        public List<TableInfo_INOUT> COMNCD_LIST
        {
            get { return this.comncd_list; }
            set { if (this.comncd_list != value) { this.comncd_list = value; OnPropertyChanged("COMNCD_LIST", value); } }
        }

        #endregion
        #region [Command]
        private ICommand saveExcnMetaCommand;
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : 
        /// create date  : 2022-12-16
        /// update date  : 2022-12-16
        /// </summary>
        /// <remarks></remarks>
        public ICommand SaveExcnMetaCommand
        {
            get
            {
                if (saveExcnMetaCommand == null)
                {
                    saveExcnMetaCommand = new RelayCommand(p => this.SaveUserInfo());                    
                }
                return saveExcnMetaCommand;
            }
        }
        #endregion
        #region [Method]
        //internal string GetUserInfoPath()
        //{
        //    //string file_path = string.Format(@".\UserInfo.xml");
        //    string file_path = !ApplicationDeployment.IsNetworkDeployed ? string.Format(@".\UserInfo.xml") : System.IO.Path.Combine(ApplicationDeployment.CurrentDeployment.DataDirectory, string.Format("UserInfo.xml")); ;

        //    return file_path;
        //}
        public string GetUserInfoPath() => !ApplicationDeployment.IsNetworkDeployed ? string.Format(".\\UserInfo.xml") : Path.Combine(ApplicationDeployment.CurrentDeployment.DataDirectory, string.Format("UserInfo.xml"));
        internal void SaveUserInfo()
        {
            string file_path = this.GetUserInfoPath();

            XmlSerializer xs = new XmlSerializer(typeof(UserInfo_INOUT));
            using (StreamWriter wr = new StreamWriter(file_path))
            {
                xs.Serialize(wr, this.USERINFO);

                wr.Close();
            }

        }
       
        internal void LoadUserInfo()
        {
            string file_path = this.GetUserInfoPath();

            if (!File.Exists(file_path)) return;

            XmlSerializer xs = new XmlSerializer(typeof(UserInfo_INOUT));

            using (StreamReader rd = new StreamReader(file_path))
            {
                this.USERINFO = xs.Deserialize(rd) as UserInfo_INOUT;
            }
        }
        ///<summary> 
        ///name               : DataTable => List<T>
        ///logic              : DataTable => List<T>
        ///desc               : DataTable => List<T>
        ///author             : 오원빈        
        ///</summary>
        internal List<T> ConvertToList<T>(DataTable sDatatable)
        {
            List<T> sConvertList = new List<T>();
            
            for (int i = 0; i < sDatatable.Rows.Count; i++)
            {
                object instance = Activator.CreateInstance(typeof(T));
                for (int j = 0; j < sDatatable.Columns.Count; j++)
                {
                    instance.GetType().GetProperty(sDatatable.Columns[j].ColumnName).SetValue(instance, sDatatable.Rows[i][sDatatable.Columns[j].ColumnName].ToString());                    
                }
                sConvertList.Add((T)instance);
            }

            return sConvertList;
        }
        internal List<T> ConvertCellToRow<T>(IList<DataGridCellInfo> selectedCells)
        {
            List<T> list = new List<T>();
            foreach(var data in selectedCells)
            {
                list.Add((T)data.Item);
            }
            list = list.Distinct().ToList();
            return list;
        }

        internal ICollectionView SetFilter<T>(List<T> list,Predicate<object> filter)
        {
            ICollectionView view = null;
            //데이터 필터부분.
            if (list != null && list.Count > 0)
            {
                view = CollectionViewSource.GetDefaultView(list);
                view.Filter = filter;
            }
            return view;
        }
        internal void RefreshView(ICollectionView view)
        {
            try
            {
                if (view != null)
                    view.Refresh();
            }
            catch(Exception ex)
            {
                
            }
        }

        internal string GetMetaQuery(string text)
        {            
            string query = "";
            query += "SELECT C.CD_NM GBN" + WBCommon.BR;
            query += "     , B.CD_NM GBN_DTL" + WBCommon.BR;
            query += "     , DIC_LOG_NM" + WBCommon.BR;
            query += "     , DIC_PHY_NM" + WBCommon.BR;
            query += "     , A.DIC_PHY_FLL_NM" + WBCommon.BR;
            query += "     , DIC_DESC" + WBCommon.BR;
            query += "     , A.DATA_TYPE" + WBCommon.BR;
            query += "     , A.STANDARD_YN" + WBCommon.BR;
            query += "     , (SELECT B.CD_NM GBN_DTL" + WBCommon.BR;
            query += "          FROM STD_DOM X" + WBCommon.BR;
            query += "             , DA_CODE B" + WBCommon.BR;
            query += "             , MS_CODE C" + WBCommon.BR;
            query += "         WHERE 1 = 1" + WBCommon.BR;
            query += "           AND X.DOM_ID = A.DOM_ID" + WBCommon.BR;
            query += "           AND X.DOM_TYPE_CD = B.CD_ID" + WBCommon.BR;
            query += "           AND B.UP_CD_ID = C.CD_ID" + WBCommon.BR;
            query += "           AND C.UP_CD_ID = 'ROOT'" + WBCommon.BR;
            query += "           AND B.UP_CD_ID = '6022'" + WBCommon.BR;
            query += "           AND SYSDATE BETWEEN TO_DATE(AVAL_ST_DT, 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE(AVAL_END_DT,'YYYY-MM-DD HH24:MI:SS')) DOM_GRP_NM" + WBCommon.BR;
            query += "  FROM STD_DIC A" + WBCommon.BR;
            query += "     , DA_CODE B" + WBCommon.BR;
            query += "     , MS_CODE C" + WBCommon.BR;
            query += "  WHERE 1 = 1" + WBCommon.BR;
            query += "    AND DIC_PHY_NM IN" + WBCommon.BR;
            query += "(" + WBCommon.BR;
            query += string.Format("SELECT TRIM(REGEXP_SUBSTR('{0}','[^'||','||']+',1,LEVEL)) AS TXT", text) + WBCommon.BR;
            query += "FROM DUAL" + WBCommon.BR;
            query += string.Format("CONNECT BY INSTR('{0}',',',1,LEVEL-1)>0", text) + WBCommon.BR;
            query += ")" + WBCommon.BR;
            query += "    AND A.DIC_GBN_CD = B.CD_ID" + WBCommon.BR;
            query += "    AND B.UP_CD_ID = C.CD_ID" + WBCommon.BR;
            query += "    AND C.UP_CD_ID = 'ROOT'" + WBCommon.BR;
            query += "    AND B.UP_CD_ID = '6019'" + WBCommon.BR;
            query += "    AND SYSDATE BETWEEN TO_DATE(AVAL_ST_DT, 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE(AVAL_END_DT, 'YYYY-MM-DD HH24:MI:SS')" + WBCommon.BR;
            query += "UNION ALL" + WBCommon.BR;
            query += "SELECT C.CD_NM GBN" + WBCommon.BR;
            query += "     , B.CD_NM GBN_DTL" + WBCommon.BR;
            query += "     , DIC_LOG_NM" + WBCommon.BR;
            query += "     , DIC_PHY_NM" + WBCommon.BR;
            query += "     , A.DIC_PHY_FLL_NM" + WBCommon.BR;
            query += "     , DIC_DESC" + WBCommon.BR;
            query += "     , A.DATA_TYPE" + WBCommon.BR;
            query += "     , A.STANDARD_YN" + WBCommon.BR;
            query += "     , (SELECT B.CD_NM GBN_DTL" + WBCommon.BR;
            query += "          FROM STD_DOM X" + WBCommon.BR;
            query += "          , DA_CODE B" + WBCommon.BR;
            query += "          , MS_CODE C" + WBCommon.BR;
            query += "         WHERE 1 = 1" + WBCommon.BR;
            query += "           AND X.DOM_ID = A.DOM_ID" + WBCommon.BR;
            query += "           AND X.DOM_TYPE_CD = B.CD_ID" + WBCommon.BR;
            query += "           AND B.UP_CD_ID = C.CD_ID" + WBCommon.BR;
            query += "           AND C.UP_CD_ID = 'ROOT'" + WBCommon.BR;
            query += "           AND B.UP_CD_ID = '6022'" + WBCommon.BR;
            query += "           AND SYSDATE BETWEEN TO_DATE(AVAL_ST_DT, 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE(AVAL_END_DT, 'YYYY-MM-DD HH24:MI:SS')) DOM_GRP_NM" + WBCommon.BR;
            query += "  FROM STD_DIC A" + WBCommon.BR;
            query += "     , DA_CODE B" + WBCommon.BR;
            query += "     , MS_CODE C" + WBCommon.BR;
            query += " WHERE 1 = 1" + WBCommon.BR;
            query += "   AND DIC_LOG_NM IN" + WBCommon.BR;
            query += "(" + WBCommon.BR;
            query += string.Format("SELECT TRIM(REGEXP_SUBSTR('{0}','[^'||','||']+',1,LEVEL)) AS TXT", text) + WBCommon.BR;
            query += "FROM DUAL" + WBCommon.BR;
            query += string.Format("CONNECT BY INSTR('{0}',',',1,LEVEL-1)>0", text) + WBCommon.BR;
            query += ")" + WBCommon.BR;
            query += "   AND A.DIC_GBN_CD = B.CD_ID" + WBCommon.BR;
            query += "   AND B.UP_CD_ID = C.CD_ID" + WBCommon.BR;
            query += "   AND C.UP_CD_ID = 'ROOT'" + WBCommon.BR;
            query += "   AND B.UP_CD_ID = '6019'" + WBCommon.BR;
            query += "   AND SYSDATE BETWEEN TO_DATE(AVAL_ST_DT, 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE(AVAL_END_DT, 'YYYY-MM-DD HH24:MI:SS')" + WBCommon.BR;
           
            return query; 
        }
        #endregion
    }
}
