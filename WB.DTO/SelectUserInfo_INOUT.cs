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
    public class SelectUserInfo_INOUT : DTOBase
    {
        //private string data_tyhpe;
        ///// <summary>
        ///// 
        ///// </summary>
        //[DataMember]
        //public string DATA_TYHPE
        //{
        //    get { return this.data_tyhpe; }
        //    set { if (this.data_tyhpe != value) { this.data_tyhpe = value; OnPropertyChanged("DATA_TYHPE", value); } }
        //}
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

        private string stf_no;
        /// <summary>
        /// name : 직원번호
        /// </summary>
        [DataMember]
        public string STF_NO
        {
            get { return this.stf_no; }
            set { if (this.stf_no != value) { this.stf_no = value; OnPropertyChanged("STF_NO", value); } }
        }

        private string sid;
        /// <summary>
        /// name : 직원식별ID
        /// </summary>
        [DataMember]
        public string SID
        {
            get { return this.sid; }
            set { if (this.sid != value) { this.sid = value; OnPropertyChanged("SID", value); } }
        }

        private string kor_srnm_nm;
        /// <summary>
        /// name : 한글성명
        /// </summary>
        [DataMember]
        public string KOR_SRNM_NM
        {
            get { return this.kor_srnm_nm; }
            set { if (this.kor_srnm_nm != value) { this.kor_srnm_nm = value; OnPropertyChanged("KOR_SRNM_NM", value); } }
        }

        private string aadp_cd;
        /// <summary>
        /// name : 발령부서코드
        /// </summary>
        [DataMember]
        public string AADP_CD
        {
            get { return this.aadp_cd; }
            set { if (this.aadp_cd != value) { this.aadp_cd = value; OnPropertyChanged("AADP_CD", value); } }
        }

        private string aoa_wkdp_cd;
        /// <summary>
        /// name : 발령근무부서코드
        /// </summary>
        [DataMember]
        public string AOA_WKDP_CD
        {
            get { return this.aoa_wkdp_cd; }
            set { if (this.aoa_wkdp_cd != value) { this.aoa_wkdp_cd = value; OnPropertyChanged("AOA_WKDP_CD", value); } }
        }

        private string use_grp_cd;
        /// <summary>
        /// name : 사용그룹코드
        /// </summary>
        [DataMember]
        public string USE_GRP_CD
        {
            get { return this.use_grp_cd; }
            set { if (this.use_grp_cd != value) { this.use_grp_cd = value; OnPropertyChanged("USE_GRP_CD", value); } }
        }

        private string use_grp_dtl_cd;
        /// <summary>
        /// name : 사용그룹상세코드
        /// </summary>
        [DataMember]
        public string USE_GRP_DTL_CD
        {
            get { return this.use_grp_dtl_cd; }
            set { if (this.use_grp_dtl_cd != value) { this.use_grp_dtl_cd = value; OnPropertyChanged("USE_GRP_DTL_CD", value); } }
        }

        private string octy_tp_cd;
        /// <summary>
        /// name : 직종구분코드
        /// </summary>
        [DataMember]
        public string OCTY_TP_CD
        {
            get { return this.octy_tp_cd; }
            set { if (this.octy_tp_cd != value) { this.octy_tp_cd = value; OnPropertyChanged("OCTY_TP_CD", value); } }
        }

        private string comn_cd_nm;
        /// <summary>
        /// name : 공통코드명
        /// </summary>
        [DataMember]
        public string COMN_CD_NM
        {
            get { return this.comn_cd_nm; }
            set { if (this.comn_cd_nm != value) { this.comn_cd_nm = value; OnPropertyChanged("COMN_CD_NM", value); } }
        }

        private string rtrm_dt;
        /// <summary>
        /// name : 퇴직일자
        /// </summary>
        [DataMember]
        public string RTRM_DT
        {
            get { return this.rtrm_dt; }
            set { if (this.rtrm_dt != value) { this.rtrm_dt = value; OnPropertyChanged("RTRM_DT", value); } }
        }

        private string lgin_pwd_lsh_dtm;
        /// <summary>
        /// name : 로그인비밀번호최종변경일시
        /// </summary>
        [DataMember]
        public string LGIN_PWD_LSH_DTM
        {
            get { return this.lgin_pwd_lsh_dtm; }
            set { if (this.lgin_pwd_lsh_dtm != value) { this.lgin_pwd_lsh_dtm = value; OnPropertyChanged("LGIN_PWD_LSH_DTM", value); } }
        }




        //매개변수 Property ---------------------------------------------------

        private string sel_hsp_tp_cd;
        /// <summary>
        /// name : SEL_HSP_TP_CD
        /// </summary>
        [DataMember]
        public string SEL_HSP_TP_CD
        {
            get { return this.sel_hsp_tp_cd; }
            set { if (this.sel_hsp_tp_cd != value) { this.sel_hsp_tp_cd = value; OnPropertyChanged("SEL_HSP_TP_CD", value); } }
        }

        private string in_kor_srnm_nm;
        /// <summary>
        /// name : 한글성명
        /// </summary>
        [DataMember]
        public string IN_KOR_SRNM_NM
        {
            get { return this.in_kor_srnm_nm; }
            set { if (this.in_kor_srnm_nm != value) { this.in_kor_srnm_nm = value; OnPropertyChanged("IN_KOR_SRNM_NM", value); } }
        }

        private string in_stf_no;
        /// <summary>
        /// name : 직원번호
        /// </summary>
        [DataMember]
        public string IN_STF_NO
        {
            get { return this.in_stf_no; }
            set { if (this.in_stf_no != value) { this.in_stf_no = value; OnPropertyChanged("IN_STF_NO", value); } }
        }

        private string in_sid;
        /// <summary>
        /// name : 직원식별ID
        /// </summary>
        [DataMember]
        public string IN_SID
        {
            get { return this.in_sid; }
            set { if (this.in_sid != value) { this.in_sid = value; OnPropertyChanged("IN_SID", value); } }
        }



    }
}
