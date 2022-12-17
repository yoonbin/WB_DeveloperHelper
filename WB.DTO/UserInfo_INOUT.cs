using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace WB.DTO
{
    /// <summary>
    /// name        : #논리DTO 클래스명
    /// desc        : #DTO클래스 개요 
    /// author      : ohwonbin 
    /// create date : 2022-09-13 오전 10:39:22
    /// update date : #최종 수정 일자, 수정자, 수정개요 
    /// </summary>
    [Serializable]
    [DataContract]
    public class UserInfo_INOUT : DTOBase
    {
        private bool excn_meta;
        /// <summary>
        /// 메타정보 조회 제외
        /// </summary>
        public bool EXCN_META
        {
            get { return this.excn_meta; }
            set { if (this.excn_meta != value) { this.excn_meta = value; OnPropertyChanged("EXCN_META", value); } }
        }

        private List<TabInfo_INOUT> tab_info_list;
        /// <summary>
        /// 
        /// </summary>
        public List<TabInfo_INOUT> TAB_INFO_LIST
        {
            get { return this.tab_info_list; }
            set { if (this.tab_info_list != value) { this.tab_info_list = value; OnPropertyChanged("TAB_INFO_LIST", value); } }
        }


        private List<SelectCalMemo_INOUT> my_cal_list;
        /// <summary>
        /// 
        /// </summary>
        public List<SelectCalMemo_INOUT> MY_CAL_LIST
        {
            get { return this.my_cal_list; }
            set { if (this.my_cal_list != value) { this.my_cal_list = value; OnPropertyChanged("MY_CAL_LIST", value); } }
        }

        private List<EAMMenuInfo_INOUT> faveaminfo_list = new List<EAMMenuInfo_INOUT>();
        /// <summary>
        /// name         : 즐겨찾기 EAM
        /// desc         :  리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-08
        /// update date  : 2022-11-08
        /// </summary>
        /// <remarks></remarks>
        public List<EAMMenuInfo_INOUT> FAVEAMINFO_LIST
        {
            get { return this.faveaminfo_list; }
            set { if (this.faveaminfo_list != value) { this.faveaminfo_list = value; OnPropertyChanged("FAVEAMINFO_LIST", value); } }
        }

        private List<TableInfo_INOUT> fav_table;
        /// <summary>
        /// 즐겨찾기 테이블
        /// </summary>
        public List<TableInfo_INOUT> FAV_TABLE
        {
            get { return this.fav_table; }
            set { if (this.fav_table != value) { this.fav_table = value; OnPropertyChanged("FAV_TABLE", value); } }
        }


        private List<Category_INOUT> category;
        /// <summary>
        /// 
        /// </summary>
        public List<Category_INOUT> CATEGORY
        {
            get { return this.category; }
            set { if (this.category != value) { this.category = value; OnPropertyChanged("CATEGORY", value); } }
        }
        private List<Category_INOUT> table_category;
        /// <summary>
        /// 
        /// </summary>
        public List<Category_INOUT> TABLE_CATEGORY
        {
            get { return this.table_category; }
            set { if (this.table_category != value) { this.table_category = value; OnPropertyChanged("TABLE_CATEGORY", value); } }
        }



        private string chk_sc_stop;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string CHK_SC_STOP
        {
            get { return this.chk_sc_stop; }
            set { if (this.chk_sc_stop != value) { this.chk_sc_stop = value; OnPropertyChanged("CHK_SC_STOP", value); } }
        }

        private string chk_cell_unit;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string CHK_CELL_UNIT
        {
            get { return this.chk_cell_unit; }
            set { if (this.chk_cell_unit != value) { this.chk_cell_unit = value; OnPropertyChanged("CHK_CELL_UNIT", value); } }
        }

        private string hsp_tp_cd;
        /// <summary>
        /// 병원구분코드
        /// </summary>
        [DataMember]
        public string HSP_TP_CD
        {
            get { return this.hsp_tp_cd; }
            set { if (this.hsp_tp_cd != value) { this.hsp_tp_cd = value; OnPropertyChanged("HSP_TP_CD", value); } }
        }

        private string stf_no;
        /// <summary>
        /// 직원번호
        /// </summary>
        [DataMember]
        public string STF_NO
        {
            get { return this.stf_no; }
            set { if (this.stf_no != value) { this.stf_no = value; OnPropertyChanged("STF_NO", value); } }
        }

        private string db_info;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string DB_INFO
        {
            get { return this.db_info; }
            set { if (this.db_info != value) { this.db_info = value; OnPropertyChanged("DB_INFO", value); } }
        }

        private string sync;
        /// <summary>
        /// 동기
        /// </summary>
        [DataMember]
        public string SYNC
        {
            get { return this.sync; }
            set { if (this.sync != value) { this.sync = value; OnPropertyChanged("SYNC", value); } }
        }

        private string my_memo;
        /// <summary>
        /// 
        /// </summary>
        public string MY_MEMO
        {
            get { return this.my_memo; }
            set { if (this.my_memo != value) { this.my_memo = value; OnPropertyChanged("MY_MEMO", value); } }
        }

        private string bak_path;
        /// <summary>
        /// 백업경로
        /// </summary>
        public string BAK_PATH
        {
            get { return this.bak_path; }
            set { if (this.bak_path != value) { this.bak_path = value; OnPropertyChanged("BAK_PATH", value); } }
        }
        private string bak_interval;
        /// <summary>
        /// 
        /// </summary>
        public string BAK_INTERVAL
        {
            get { return this.bak_interval; }
            set { if (this.bak_interval != value) { this.bak_interval = value; OnPropertyChanged("BAK_INTERVAL", value); } }
        }

        private string auto_backup_yn;
        /// <summary>
        /// 
        /// </summary>
        public string AUTO_BACKUP_YN
        {
            get { return this.auto_backup_yn; }
            set { if (this.auto_backup_yn != value) { this.auto_backup_yn = value; OnPropertyChanged("AUTO_BACKUP_YN", value); } }
        }



    }

    /// <summary>
    /// name        : #논리DTO 클래스명
    /// desc        : #DTO클래스 개요 
    /// author      : ohwonbin 
    /// create date : 2022-09-13 오전 10:39:22
    /// update date : #최종 수정 일자, 수정자, 수정개요 
    /// </summary>
    [Serializable]
    [DataContract]
    public class Category_INOUT : DTOBase
    {
        private string category;
        /// <summary>
        /// 
        /// </summary>
        public string CATEGORY
        {
            get { return this.category; }
            set
            {
                if (this.category != value)
                {
                    this.old_category = category;
                    this.category = value; 
                    OnPropertyChanged("CATEGORY", value);
                }
            }
        }
        private string old_category;
        /// <summary>
        /// 
        /// </summary>
        public string OLD_CATEGORY
        {
            get { return this.old_category; }
            set { if (this.old_category != value) { this.old_category = value; OnPropertyChanged("OLD_CATEGORY", value); } }
        }
    }

    /// <summary>
    /// name        : #논리DTO 클래스명
    /// desc        : #DTO클래스 개요 
    /// author      : ohwonbin 
    /// create date : 2022-09-13 오전 10:39:22
    /// update date : #최종 수정 일자, 수정자, 수정개요 
    /// </summary>
    [Serializable]
    [DataContract]
    public class TabInfo_INOUT : DTOBase
    {
        private string tab_name;
        /// <summary>
        /// 
        /// </summary>
        public string TAB_NAME
        {
            get { return this.tab_name; }
            set { if (this.tab_name != value) { this.tab_name = value; OnPropertyChanged("TAB_NAME", value); } }
        }

        private int seq;
        /// <summary>
        /// 순번
        /// </summary>
        public int SEQ
        {
            get { return this.seq; }
            set { if (this.seq != value) { this.seq = value; OnPropertyChanged("SEQ", value); } }
        }


    }
}
