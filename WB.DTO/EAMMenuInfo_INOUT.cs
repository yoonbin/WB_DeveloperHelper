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
    public class EAMMenuInfo_INOUT : DTOBase
    {

        private string abbr_nm;
        /// <summary>
        /// 약어명
        /// </summary>
        public string ABBR_NM
        {
            get { return this.abbr_nm; }
            set { if (this.abbr_nm != value) { this.abbr_nm = value; OnPropertyChanged("ABBR_NM", value); } }
        }



        private string business_typ;
        /// <summary>
        /// name : BUSINESS_TYP
        /// </summary>
        [DataMember]
        public string BUSINESS_TYP
        {
            get { return this.business_typ; }
            set { if (this.business_typ != value) { this.business_typ = value; OnPropertyChanged("BUSINESS_TYP", value); } }
        }

        private string menu_cd;
        /// <summary>
        /// name : 메뉴코드
        /// </summary>
        [DataMember]
        public string MENU_CD
        {
            get { return this.menu_cd; }
            set { if (this.menu_cd != value) { this.menu_cd = value; OnPropertyChanged("MENU_CD", value); } }
        }

        private decimal biz_menu_id;
        /// <summary>
        /// name : BIZ_MENU_ID
        /// </summary>
        [DataMember]
        public decimal BIZ_MENU_ID
        {
            get { return this.biz_menu_id; }
            set { if (this.biz_menu_id != value) { this.biz_menu_id = value; OnPropertyChanged("BIZ_MENU_ID", value); } }
        }

        private string menu_id;
        /// <summary>
        /// name : MENU_ID
        /// </summary>
        [DataMember]
        public string MENU_ID
        {
            get { return this.menu_id; }
            set { if (this.menu_id != value) { this.menu_id = value; OnPropertyChanged("MENU_ID", value); } }
        }

        private string menu_nm;
        /// <summary>
        /// name : 메뉴명
        /// </summary>
        [DataMember]
        public string MENU_NM
        {
            get { return this.menu_nm; }
            set { if (this.menu_nm != value) { this.menu_nm = value; OnPropertyChanged("MENU_NM", value); } }
        }

        private string folder_yn;
        /// <summary>
        /// name : FOLDER_YN
        /// </summary>
        [DataMember]
        public string FOLDER_YN
        {
            get { return this.folder_yn; }
            set { if (this.folder_yn != value) { this.folder_yn = value; OnPropertyChanged("FOLDER_YN", value); } }
        }

        private string up_menu_cd;
        /// <summary>
        /// name : UP_MENU_CD
        /// </summary>
        [DataMember]
        public string UP_MENU_CD
        {
            get { return this.up_menu_cd; }
            set { if (this.up_menu_cd != value) { this.up_menu_cd = value; OnPropertyChanged("UP_MENU_CD", value); } }
        }

        private string use_yn;
        /// <summary>
        /// name : 사용여부
        /// </summary>
        [DataMember]
        public string USE_YN
        {
            get { return this.use_yn; }
            set { if (this.use_yn != value) { this.use_yn = value; OnPropertyChanged("USE_YN", value); } }
        }

        private decimal sort_seq;
        /// <summary>
        /// name : 정렬순번
        /// </summary>
        [DataMember]
        public decimal SORT_SEQ
        {
            get { return this.sort_seq; }
            set { if (this.sort_seq != value) { this.sort_seq = value; OnPropertyChanged("SORT_SEQ", value); } }
        }

        private string assembly_nm;
        /// <summary>
        /// name : ASSEMBLY_NM
        /// </summary>
        [DataMember]
        public string ASSEMBLY_NM
        {
            get { return this.assembly_nm; }
            set { if (this.assembly_nm != value) { this.assembly_nm = value; OnPropertyChanged("ASSEMBLY_NM", value); } }
        }

        private string app_url;
        /// <summary>
        /// name : APP_URL
        /// </summary>
        [DataMember]
        public string APP_URL
        {
            get { return this.app_url; }
            set { if (this.app_url != value) { this.app_url = value; OnPropertyChanged("APP_URL", value); } }
        }

        private string icon_uri;
        /// <summary>
        /// name : ICON_URI
        /// </summary>
        [DataMember]
        public string ICON_URI
        {
            get { return this.icon_uri; }
            set { if (this.icon_uri != value) { this.icon_uri = value; OnPropertyChanged("ICON_URI", value); } }
        }

        private string menu_type;
        /// <summary>
        /// name : MENU_TYPE
        /// </summary>
        [DataMember]
        public string MENU_TYPE
        {
            get { return this.menu_type; }
            set { if (this.menu_type != value) { this.menu_type = value; OnPropertyChanged("MENU_TYPE", value); } }
        }

        private string dup_yn;
        /// <summary>
        /// name : DUP_YN
        /// </summary>
        [DataMember]
        public string DUP_YN
        {
            get { return this.dup_yn; }
            set { if (this.dup_yn != value) { this.dup_yn = value; OnPropertyChanged("DUP_YN", value); } }
        }

        private string menu_open_type;
        /// <summary>
        /// name : MENU_OPEN_TYPE
        /// </summary>
        [DataMember]
        public string MENU_OPEN_TYPE
        {
            get { return this.menu_open_type; }
            set { if (this.menu_open_type != value) { this.menu_open_type = value; OnPropertyChanged("MENU_OPEN_TYPE", value); } }
        }

        private string dr_open_type;
        /// <summary>
        /// name : DR_OPEN_TYPE
        /// </summary>
        [DataMember]
        public string DR_OPEN_TYPE
        {
            get { return this.dr_open_type; }
            set { if (this.dr_open_type != value) { this.dr_open_type = value; OnPropertyChanged("DR_OPEN_TYPE", value); } }
        }

        private string nr_open_type;
        /// <summary>
        /// name : NR_OPEN_TYPE
        /// </summary>
        [DataMember]
        public string NR_OPEN_TYPE
        {
            get { return this.nr_open_type; }
            set { if (this.nr_open_type != value) { this.nr_open_type = value; OnPropertyChanged("NR_OPEN_TYPE", value); } }
        }

        private string ms_open_type;
        /// <summary>
        /// name : MS_OPEN_TYPE
        /// </summary>
        [DataMember]
        public string MS_OPEN_TYPE
        {
            get { return this.ms_open_type; }
            set { if (this.ms_open_type != value) { this.ms_open_type = value; OnPropertyChanged("MS_OPEN_TYPE", value); } }
        }

        private string pa_open_type;
        /// <summary>
        /// name : PA_OPEN_TYPE
        /// </summary>
        [DataMember]
        public string PA_OPEN_TYPE
        {
            get { return this.pa_open_type; }
            set { if (this.pa_open_type != value) { this.pa_open_type = value; OnPropertyChanged("PA_OPEN_TYPE", value); } }
        }

        private string rp_open_type;
        /// <summary>
        /// name : RP_OPEN_TYPE
        /// </summary>
        [DataMember]
        public string RP_OPEN_TYPE
        {
            get { return this.rp_open_type; }
            set { if (this.rp_open_type != value) { this.rp_open_type = value; OnPropertyChanged("RP_OPEN_TYPE", value); } }
        }

        private string modal_yn;
        /// <summary>
        /// name : MODAL_YN
        /// </summary>
        [DataMember]
        public string MODAL_YN
        {
            get { return this.modal_yn; }
            set { if (this.modal_yn != value) { this.modal_yn = value; OnPropertyChanged("MODAL_YN", value); } }
        }

        private string win_val;
        /// <summary>
        /// name : WIN_VAL
        /// </summary>
        [DataMember]
        public string WIN_VAL
        {
            get { return this.win_val; }
            set { if (this.win_val != value) { this.win_val = value; OnPropertyChanged("WIN_VAL", value); } }
        }

        private string tile_full_size_yn;
        /// <summary>
        /// name : TILE_FULL_SIZE_YN
        /// </summary>
        [DataMember]
        public string TILE_FULL_SIZE_YN
        {
            get { return this.tile_full_size_yn; }
            set { if (this.tile_full_size_yn != value) { this.tile_full_size_yn = value; OnPropertyChanged("TILE_FULL_SIZE_YN", value); } }
        }

        private string tile_default_size;
        /// <summary>
        /// name : TILE_DEFAULT_SIZE
        /// </summary>
        [DataMember]
        public string TILE_DEFAULT_SIZE
        {
            get { return this.tile_default_size; }
            set { if (this.tile_default_size != value) { this.tile_default_size = value; OnPropertyChanged("TILE_DEFAULT_SIZE", value); } }
        }

        private string tile_max_size;
        /// <summary>
        /// name : TILE_MAX_SIZE
        /// </summary>
        [DataMember]
        public string TILE_MAX_SIZE
        {
            get { return this.tile_max_size; }
            set { if (this.tile_max_size != value) { this.tile_max_size = value; OnPropertyChanged("TILE_MAX_SIZE", value); } }
        }

        private string tile_min_size;
        /// <summary>
        /// name : TILE_MIN_SIZE
        /// </summary>
        [DataMember]
        public string TILE_MIN_SIZE
        {
            get { return this.tile_min_size; }
            set { if (this.tile_min_size != value) { this.tile_min_size = value; OnPropertyChanged("TILE_MIN_SIZE", value); } }
        }

        private string search_default_duration;
        /// <summary>
        /// name : SEARCH_DEFAULT_DURATION
        /// </summary>
        [DataMember]
        public string SEARCH_DEFAULT_DURATION
        {
            get { return this.search_default_duration; }
            set { if (this.search_default_duration != value) { this.search_default_duration = value; OnPropertyChanged("SEARCH_DEFAULT_DURATION", value); } }
        }

        private string search_max_duration;
        /// <summary>
        /// name : SEARCH_MAX_DURATION
        /// </summary>
        [DataMember]
        public string SEARCH_MAX_DURATION
        {
            get { return this.search_max_duration; }
            set { if (this.search_max_duration != value) { this.search_max_duration = value; OnPropertyChanged("SEARCH_MAX_DURATION", value); } }
        }

        private string patient_info_yn;
        /// <summary>
        /// name : PATIENT_INFO_YN
        /// </summary>
        [DataMember]
        public string PATIENT_INFO_YN
        {
            get { return this.patient_info_yn; }
            set { if (this.patient_info_yn != value) { this.patient_info_yn = value; OnPropertyChanged("PATIENT_INFO_YN", value); } }
        }

        private string private_info_yn;
        /// <summary>
        /// name : PRIVATE_INFO_YN
        /// </summary>
        [DataMember]
        public string PRIVATE_INFO_YN
        {
            get { return this.private_info_yn; }
            set { if (this.private_info_yn != value) { this.private_info_yn = value; OnPropertyChanged("PRIVATE_INFO_YN", value); } }
        }

        private string medical_record_yn;
        /// <summary>
        /// name : MEDICAL_RECORD_YN
        /// </summary>
        [DataMember]
        public string MEDICAL_RECORD_YN
        {
            get { return this.medical_record_yn; }
            set { if (this.medical_record_yn != value) { this.medical_record_yn = value; OnPropertyChanged("MEDICAL_RECORD_YN", value); } }
        }

        private string electronic_signature_yn;
        /// <summary>
        /// name : ELECTRONIC_SIGNATURE_YN
        /// </summary>
        [DataMember]
        public string ELECTRONIC_SIGNATURE_YN
        {
            get { return this.electronic_signature_yn; }
            set { if (this.electronic_signature_yn != value) { this.electronic_signature_yn = value; OnPropertyChanged("ELECTRONIC_SIGNATURE_YN", value); } }
        }

        private string disp_yn;
        /// <summary>
        /// name : DISP_YN
        /// </summary>
        [DataMember]
        public string DISP_YN
        {
            get { return this.disp_yn; }
            set { if (this.disp_yn != value) { this.disp_yn = value; OnPropertyChanged("DISP_YN", value); } }
        }

        private string active_yn;
        /// <summary>
        /// name : ACTIVE_YN
        /// </summary>
        [DataMember]
        public string ACTIVE_YN
        {
            get { return this.active_yn; }
            set { if (this.active_yn != value) { this.active_yn = value; OnPropertyChanged("ACTIVE_YN", value); } }
        }

        private string approve_yn;
        /// <summary>
        /// name : APPROVE_YN
        /// </summary>
        [DataMember]
        public string APPROVE_YN
        {
            get { return this.approve_yn; }
            set { if (this.approve_yn != value) { this.approve_yn = value; OnPropertyChanged("APPROVE_YN", value); } }
        }

        private string sys_cd;
        /// <summary>
        /// name : SYS_CD
        /// </summary>
        [DataMember]
        public string SYS_CD
        {
            get { return this.sys_cd; }
            set { if (this.sys_cd != value) { this.sys_cd = value; OnPropertyChanged("SYS_CD", value); } }
        }

        private string use_str_dtm;
        /// <summary>
        /// name : 사용시작일시
        /// </summary>
        [DataMember]
        public string USE_STR_DTM
        {
            get { return this.use_str_dtm; }
            set { if (this.use_str_dtm != value) { this.use_str_dtm = value; OnPropertyChanged("USE_STR_DTM", value); } }
        }

        private string use_end_dtm;
        /// <summary>
        /// name : 사용종료일시
        /// </summary>
        [DataMember]
        public string USE_END_DTM
        {
            get { return this.use_end_dtm; }
            set { if (this.use_end_dtm != value) { this.use_end_dtm = value; OnPropertyChanged("USE_END_DTM", value); } }
        }

        private string popup_only_yn;
        /// <summary>
        /// name : POPUP_ONLY_YN
        /// </summary>
        [DataMember]
        public string POPUP_ONLY_YN
        {
            get { return this.popup_only_yn; }
            set { if (this.popup_only_yn != value) { this.popup_only_yn = value; OnPropertyChanged("POPUP_ONLY_YN", value); } }
        }

        private string qck_menu_yn;
        /// <summary>
        /// name : 퀵메뉴여부
        /// </summary>
        [DataMember]
        public string QCK_MENU_YN
        {
            get { return this.qck_menu_yn; }
            set { if (this.qck_menu_yn != value) { this.qck_menu_yn = value; OnPropertyChanged("QCK_MENU_YN", value); } }
        }

        private string report_yn;
        /// <summary>
        /// name : REPORT_YN
        /// </summary>
        [DataMember]
        public string REPORT_YN
        {
            get { return this.report_yn; }
            set { if (this.report_yn != value) { this.report_yn = value; OnPropertyChanged("REPORT_YN", value); } }
        }

        private string auth_check_yn;
        /// <summary>
        /// name : AUTH_CHECK_YN
        /// </summary>
        [DataMember]
        public string AUTH_CHECK_YN
        {
            get { return this.auth_check_yn; }
            set { if (this.auth_check_yn != value) { this.auth_check_yn = value; OnPropertyChanged("AUTH_CHECK_YN", value); } }
        }

        private string title_disp_yn;
        /// <summary>
        /// name : TITLE_DISP_YN
        /// </summary>
        [DataMember]
        public string TITLE_DISP_YN
        {
            get { return this.title_disp_yn; }
            set { if (this.title_disp_yn != value) { this.title_disp_yn = value; OnPropertyChanged("TITLE_DISP_YN", value); } }
        }

        private string pt_info_need_type;
        /// <summary>
        /// name : PT_INFO_NEED_TYPE
        /// </summary>
        [DataMember]
        public string PT_INFO_NEED_TYPE
        {
            get { return this.pt_info_need_type; }
            set { if (this.pt_info_need_type != value) { this.pt_info_need_type = value; OnPropertyChanged("PT_INFO_NEED_TYPE", value); } }
        }

        private string scale_disp_yn;
        /// <summary>
        /// name : SCALE_DISP_YN
        /// </summary>
        [DataMember]
        public string SCALE_DISP_YN
        {
            get { return this.scale_disp_yn; }
            set { if (this.scale_disp_yn != value) { this.scale_disp_yn = value; OnPropertyChanged("SCALE_DISP_YN", value); } }
        }

        private string kor_file_nm;
        /// <summary>
        /// name : 한글파일명
        /// </summary>
        [DataMember]
        public string KOR_FILE_NM
        {
            get { return this.kor_file_nm; }
            set { if (this.kor_file_nm != value) { this.kor_file_nm = value; OnPropertyChanged("KOR_FILE_NM", value); } }
        }

        private string ogcp_file_path;
        /// <summary>
        /// name : OGCP_FILE_PATH
        /// </summary>
        [DataMember]
        public string OGCP_FILE_PATH
        {
            get { return this.ogcp_file_path; }
            set { if (this.ogcp_file_path != value) { this.ogcp_file_path = value; OnPropertyChanged("OGCP_FILE_PATH", value); } }
        }

        private string empl_file_path;
        /// <summary>
        /// name : EMPL_FILE_PATH
        /// </summary>
        [DataMember]
        public string EMPL_FILE_PATH
        {
            get { return this.empl_file_path; }
            set { if (this.empl_file_path != value) { this.empl_file_path = value; OnPropertyChanged("EMPL_FILE_PATH", value); } }
        }

        private decimal file_lth;
        /// <summary>
        /// name : 파일길이
        /// </summary>
        [DataMember]
        public decimal FILE_LTH
        {
            get { return this.file_lth; }
            set { if (this.file_lth != value) { this.file_lth = value; OnPropertyChanged("FILE_LTH", value); } }
        }

        private string repeat_show_hide;
        /// <summary>
        /// name : REPEAT_SHOW_HIDE
        /// </summary>
        [DataMember]
        public string REPEAT_SHOW_HIDE
        {
            get { return this.repeat_show_hide; }
            set { if (this.repeat_show_hide != value) { this.repeat_show_hide = value; OnPropertyChanged("REPEAT_SHOW_HIDE", value); } }
        }

        private string repeat_year_month;
        /// <summary>
        /// name : REPEAT_YEAR_MONTH
        /// </summary>
        [DataMember]
        public string REPEAT_YEAR_MONTH
        {
            get { return this.repeat_year_month; }
            set { if (this.repeat_year_month != value) { this.repeat_year_month = value; OnPropertyChanged("REPEAT_YEAR_MONTH", value); } }
        }

        private string repeat_start;
        /// <summary>
        /// name : REPEAT_START
        /// </summary>
        [DataMember]
        public string REPEAT_START
        {
            get { return this.repeat_start; }
            set { if (this.repeat_start != value) { this.repeat_start = value; OnPropertyChanged("REPEAT_START", value); } }
        }

        private string repeat_end;
        /// <summary>
        /// name : REPEAT_END
        /// </summary>
        [DataMember]
        public string REPEAT_END
        {
            get { return this.repeat_end; }
            set { if (this.repeat_end != value) { this.repeat_end = value; OnPropertyChanged("REPEAT_END", value); } }
        }

        private string page_usage_rmks;
        /// <summary>
        /// name : PAGE_USAGE_RMKS
        /// </summary>
        [DataMember]
        public string PAGE_USAGE_RMKS
        {
            get { return this.page_usage_rmks; }
            set { if (this.page_usage_rmks != value) { this.page_usage_rmks = value; OnPropertyChanged("PAGE_USAGE_RMKS", value); } }
        }

        private string aggr_except_yn;
        /// <summary>
        /// name : AGGR_EXCEPT_YN
        /// </summary>
        [DataMember]
        public string AGGR_EXCEPT_YN
        {
            get { return this.aggr_except_yn; }
            set { if (this.aggr_except_yn != value) { this.aggr_except_yn = value; OnPropertyChanged("AGGR_EXCEPT_YN", value); } }
        }

        private string deploy_start_dtm;
        /// <summary>
        /// name : DEPLOY_START_DTM
        /// </summary>
        [DataMember]
        public string DEPLOY_START_DTM
        {
            get { return this.deploy_start_dtm; }
            set { if (this.deploy_start_dtm != value) { this.deploy_start_dtm = value; OnPropertyChanged("DEPLOY_START_DTM", value); } }
        }

        private string menu_desc;
        /// <summary>
        /// name : MENU_DESC
        /// </summary>
        [DataMember]
        public string MENU_DESC
        {
            get { return this.menu_desc; }
            set { if (this.menu_desc != value) { this.menu_desc = value; OnPropertyChanged("MENU_DESC", value); } }
        }        

    }
}
