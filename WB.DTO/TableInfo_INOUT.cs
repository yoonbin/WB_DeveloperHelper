using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace WB
{
    public class TableInfo_INOUT : DTOBase
    {
        private string group;
        /// <summary>
        /// 
        /// </summary>
        public string GROUP
        {
            get { return this.group; }
            set { if (this.group != value) { this.group = value; OnPropertyChanged("GROUP", value); } }
        }


        private string obj_name;
        /// <summary>
        /// name : OBJ_NAME
        /// </summary>
        [DataMember]
        public string OBJ_NAME
        {
            get { return this.obj_name; }
            set { if (this.obj_name != value) { this.obj_name = value; OnPropertyChanged("OBJ_NAME", value); } }
        }

        private string obj_type;
        /// <summary>
        /// name : OBJ_TYPE
        /// </summary>
        [DataMember]
        public string OBJ_TYPE
        {
            get { return this.obj_type; }
            set { if (this.obj_type != value) { this.obj_type = value; OnPropertyChanged("OBJ_TYPE", value); } }
        }

        private string status;
        /// <summary>
        /// name : STATUS
        /// </summary>
        [DataMember]
        public string STATUS
        {
            get { return this.status; }
            set { if (this.status != value) { this.status = value; OnPropertyChanged("STATUS", value); } }
        }

        private string hsp_tp_cd;
        /// <summary>
        /// name : 병원구분코드
        /// </summary>
        [DataMember]
        public string HSP_TP_CD
        {
            get { return this.hsp_tp_cd; }
            set { if (this.hsp_tp_cd != value) { this.hsp_tp_cd = value; OnPropertyChanged("HSP_TP_CD", value); } }
        }

        private string dtrl3_nm;
        /// <summary>
        /// name : 3번째업무규칙명
        /// </summary>
        [DataMember]
        public string DTRL3_NM
        {
            get { return this.dtrl3_nm; }
            set { if (this.dtrl3_nm != value) { this.dtrl3_nm = value; OnPropertyChanged("DTRL3_NM", value); } }
        }

        private string dtrl4_nm;
        /// <summary>
        /// name : 4번째업무규칙명
        /// </summary>
        [DataMember]
        public string DTRL4_NM
        {
            get { return this.dtrl4_nm; }
            set { if (this.dtrl4_nm != value) { this.dtrl4_nm = value; OnPropertyChanged("DTRL4_NM", value); } }
        }

        private string dtrl5_nm;
        /// <summary>
        /// name : 5번째업무규칙명
        /// </summary>
        [DataMember]
        public string DTRL5_NM
        {
            get { return this.dtrl5_nm; }
            set { if (this.dtrl5_nm != value) { this.dtrl5_nm = value; OnPropertyChanged("DTRL5_NM", value); } }
        }

        private string dtrl6_nm;
        /// <summary>
        /// name : 6번째업무규칙명
        /// </summary>
        [DataMember]
        public string DTRL6_NM
        {
            get { return this.dtrl6_nm; }
            set { if (this.dtrl6_nm != value) { this.dtrl6_nm = value; OnPropertyChanged("DTRL6_NM", value); } }
        }
      

        private string nextg_fmr_comn_cd;
        /// <summary>
        /// name : 차세대이전공통코드
        /// </summary>
        [DataMember]
        public string NEXTG_FMR_COMN_CD
        {
            get { return this.nextg_fmr_comn_cd; }
            set { if (this.nextg_fmr_comn_cd != value) { this.nextg_fmr_comn_cd = value; OnPropertyChanged("NEXTG_FMR_COMN_CD", value); } }
        }
       
        private string table_name;
        /// <summary>
        /// name : TABLE_NAME
        /// </summary>
        [DataMember]
        public string TABLE_NAME
        {
            get { return this.table_name; }
            set { if (this.table_name != value) { this.table_name = value; OnPropertyChanged("TABLE_NAME", value); } }
        }

        private string table_comments;
        /// <summary>
        /// name : TABLE_COMMENTS
        /// </summary>
        [DataMember]
        public string TABLE_COMMENTS
        {
            get { return this.table_comments; }
            set { if (this.table_comments != value) { this.table_comments = value; OnPropertyChanged("TABLE_COMMENTS", value); } }
        }

        private decimal seq;
        /// <summary>
        /// name : 순번
        /// </summary>
        [DataMember]
        public decimal SEQ
        {
            get { return this.seq; }
            set { if (this.seq != value) { this.seq = value; OnPropertyChanged("SEQ", value); } }
        }

        private string key_field;
        /// <summary>
        /// name : KEY_FIELD
        /// </summary>
        [DataMember]
        public string KEY_FIELD
        {
            get { return this.key_field; }
            set { if (this.key_field != value) { this.key_field = value; OnPropertyChanged("KEY_FIELD", value); } }
        }

        private string column_name;
        /// <summary>
        /// name : COLUMN_NAME
        /// </summary>
        [DataMember]
        public string COLUMN_NAME
        {
            get { return this.column_name; }
            set { if (this.column_name != value) { this.column_name = value; OnPropertyChanged("COLUMN_NAME", value); } }
        }

        private string data_type;
        /// <summary>
        /// name : DATA_TYPE
        /// </summary>
        [DataMember]
        public string DATA_TYPE
        {
            get { return this.data_type; }
            set { if (this.data_type != value) { this.data_type = value; OnPropertyChanged("DATA_TYPE", value); } }
        }

        private string nullable;
        /// <summary>
        /// name : NULLABLE
        /// </summary>
        [DataMember]
        public string NULLABLE
        {
            get { return this.nullable; }
            set { if (this.nullable != value) { this.nullable = value; OnPropertyChanged("NULLABLE", value); } }
        }

        private string comments;
        /// <summary>
        /// name : COMMENTS
        /// </summary>
        [DataMember]
        public string COMMENTS
        {
            get { return this.comments; }
            set { if (this.comments != value) { this.comments = value; OnPropertyChanged("COMMENTS", value); } }
        }

        private string owner;
        /// <summary>
        /// name : OWNER
        /// </summary>
        [DataMember]
        public string OWNER
        {
            get { return this.owner; }
            set { if (this.owner != value) { this.owner = value; OnPropertyChanged("OWNER", value); } }
        }
        private string _TAB_NAME;
        /// <summary>
        /// name : TEXT
        /// </summary>
        [DataMember]
        public string TAB_NAME
        {
            get { return this._TAB_NAME; }
            set { if (this._TAB_NAME != value) { this._TAB_NAME = value; OnPropertyChanged("TAB_NAME", value); } }
        }

        private string query_id;
        /// <summary>
        /// name : QUERY_ID
        /// </summary>
        [DataMember]
        public string QUERY_ID
        {
            get { return this.query_id; }
            set { if (this.query_id != value) { this.query_id = value; OnPropertyChanged("QUERY_ID", value); } }
        }

        private string comn_grp_cd;
        /// <summary>
        /// 공통그룹코드
        /// </summary>
        [DataMember]
        public string COMN_GRP_CD
        {
            get { return this.comn_grp_cd; }
            set { if (this.comn_grp_cd != value) { this.comn_grp_cd = value; OnPropertyChanged("COMN_GRP_CD", value); } }
        }

        private string comn_cd;
        /// <summary>
        /// 공통코드
        /// </summary>
        [DataMember]
        public string COMN_CD
        {
            get { return this.comn_cd; }
            set { if (this.comn_cd != value) { this.comn_cd = value; OnPropertyChanged("COMN_CD", value); } }
        }

        private string comn_cd_nm;
        /// <summary>
        /// 공통코드명
        /// </summary>
        [DataMember]
        public string COMN_CD_NM
        {
            get { return this.comn_cd_nm; }
            set { if (this.comn_cd_nm != value) { this.comn_cd_nm = value; OnPropertyChanged("COMN_CD_NM", value); } }
        }

        private string comn_cd_expl;
        /// <summary>
        /// 공통코드설명
        /// </summary>
        [DataMember]
        public string COMN_CD_EXPL
        {
            get { return this.comn_cd_expl; }
            set { if (this.comn_cd_expl != value) { this.comn_cd_expl = value; OnPropertyChanged("COMN_CD_EXPL", value); } }
        }

        private decimal scrn_mrk_seq;
        /// <summary>
        /// 화면표시순번
        /// </summary>
        [DataMember]
        public decimal SCRN_MRK_SEQ
        {
            get { return this.scrn_mrk_seq; }
            set { if (this.scrn_mrk_seq != value) { this.scrn_mrk_seq = value; OnPropertyChanged("SCRN_MRK_SEQ", value); } }
        }

        private string use_yn;
        /// <summary>
        /// 사용여부
        /// </summary>
        [DataMember]
        public string USE_YN
        {
            get { return this.use_yn; }
            set { if (this.use_yn != value) { this.use_yn = value; OnPropertyChanged("USE_YN", value); } }
        }

        private string dtrl1_nm;
        /// <summary>
        /// 1번째업무규칙명
        /// </summary>
        [DataMember]
        public string DTRL1_NM
        {
            get { return this.dtrl1_nm; }
            set { if (this.dtrl1_nm != value) { this.dtrl1_nm = value; OnPropertyChanged("DTRL1_NM", value); } }
        }

        private string dtrl2_nm;
        /// <summary>
        /// 2번째업무규칙명
        /// </summary>
        [DataMember]
        public string DTRL2_NM
        {
            get { return this.dtrl2_nm; }
            set { if (this.dtrl2_nm != value) { this.dtrl2_nm = value; OnPropertyChanged("DTRL2_NM", value); } }
        }


        private string comment;
        /// <summary>
        /// name : COMMENT
        /// </summary>
        [DataMember]
        public string COMMENT
        {
            get { return this.comment; }
            set { if (this.comment != value) { this.comment = value; OnPropertyChanged("COMMENT", value); } }
        }

        private string column;
        /// <summary>
        /// name : COLUMN
        /// </summary>
        [DataMember]
        public string COLUMN
        {
            get { return this.column; }
            set { if (this.column != value) { this.column = value; OnPropertyChanged("COLUMN", value); } }
        }

        private string index_name;
        /// <summary>
        /// name : INDEX_NAME
        /// </summary>
        [DataMember]
        public string INDEX_NAME
        {
            get { return this.index_name; }
            set { if (this.index_name != value) { this.index_name = value; OnPropertyChanged("INDEX_NAME", value); } }
        }

        private decimal column_position;
        /// <summary>
        /// name : COLUMN_POSITION
        /// </summary>
        [DataMember]
        public decimal COLUMN_POSITION
        {
            get { return this.column_position; }
            set { if (this.column_position != value) { this.column_position = value; OnPropertyChanged("COLUMN_POSITION", value); } }
        }


    }
}
