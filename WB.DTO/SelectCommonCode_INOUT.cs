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
    public class SelectCommonCode_INOUT : DTOBase
    {
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

        private string comn_grp_cd;
        /// <summary>
        /// name : 공통그룹코드
        /// </summary>
        [DataMember]
        public string COMN_GRP_CD
        {
            get { return this.comn_grp_cd; }
            set { if (this.comn_grp_cd != value) { this.comn_grp_cd = value; OnPropertyChanged("COMN_GRP_CD", value); } }
        }

        private string comn_cd;
        /// <summary>
        /// name : 공통코드
        /// </summary>
        [DataMember]
        public string COMN_CD
        {
            get { return this.comn_cd; }
            set { if (this.comn_cd != value) { this.comn_cd = value; OnPropertyChanged("COMN_CD", value); } }
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

        private string comn_cd_expl;
        /// <summary>
        /// name : 공통코드설명
        /// </summary>
        [DataMember]
        public string COMN_CD_EXPL
        {
            get { return this.comn_cd_expl; }
            set { if (this.comn_cd_expl != value) { this.comn_cd_expl = value; OnPropertyChanged("COMN_CD_EXPL", value); } }
        }

        private decimal scrn_mrk_seq;
        /// <summary>
        /// name : 화면표시순번
        /// </summary>
        [DataMember]
        public decimal SCRN_MRK_SEQ
        {
            get { return this.scrn_mrk_seq; }
            set { if (this.scrn_mrk_seq != value) { this.scrn_mrk_seq = value; OnPropertyChanged("SCRN_MRK_SEQ", value); } }
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

        private string dtrl1_nm;
        /// <summary>
        /// name : 1번째업무규칙명
        /// </summary>
        [DataMember]
        public string DTRL1_NM
        {
            get { return this.dtrl1_nm; }
            set { if (this.dtrl1_nm != value) { this.dtrl1_nm = value; OnPropertyChanged("DTRL1_NM", value); } }
        }

        private string dtrl2_nm;
        /// <summary>
        /// name : 2번째업무규칙명
        /// </summary>
        [DataMember]
        public string DTRL2_NM
        {
            get { return this.dtrl2_nm; }
            set { if (this.dtrl2_nm != value) { this.dtrl2_nm = value; OnPropertyChanged("DTRL2_NM", value); } }
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




        //매개변수 Property ---------------------------------------------------

        private string in_hsp_tp_cd;
        /// <summary>
        /// name : 병원구분코드
        /// </summary>
        [DataMember]
        public string IN_HSP_TP_CD
        {
            get { return this.in_hsp_tp_cd; }
            set { if (this.in_hsp_tp_cd != value) { this.in_hsp_tp_cd = value; OnPropertyChanged("IN_HSP_TP_CD", value); } }
        }
        private string table_nm;
        /// <summary>
        /// name : TABLE_NM
        /// </summary>
        [DataMember]
        public string TABLE_NM
        {
            get { return this.table_nm; }
            set { if (this.table_nm != value) { this.table_nm = value; OnPropertyChanged("TABLE_NM", value); } }
        }      
        private string comn_grp_cd_nm;
        /// <summary>
        /// name : 공통그룹코드명
        /// </summary>
        [DataMember]
        public string COMN_GRP_CD_NM
        {
            get { return this.comn_grp_cd_nm; }
            set { if (this.comn_grp_cd_nm != value) { this.comn_grp_cd_nm = value; OnPropertyChanged("COMN_GRP_CD_NM", value); } }
        }

        private string comn_grp_cd_expl;
        /// <summary>
        /// name : 공통그룹코드설명
        /// </summary>
        [DataMember]
        public string COMN_GRP_CD_EXPL
        {
            get { return this.comn_grp_cd_expl; }
            set { if (this.comn_grp_cd_expl != value) { this.comn_grp_cd_expl = value; OnPropertyChanged("COMN_GRP_CD_EXPL", value); } }
        }

        private string upr_comn_grp_cd;
        /// <summary>
        /// name : 상위공통그룹코드
        /// </summary>
        [DataMember]
        public string UPR_COMN_GRP_CD
        {
            get { return this.upr_comn_grp_cd; }
            set { if (this.upr_comn_grp_cd != value) { this.upr_comn_grp_cd = value; OnPropertyChanged("UPR_COMN_GRP_CD", value); } }
        }

        private string team_tp_cd;
        /// <summary>
        /// name : 팀구분코드
        /// </summary>
        [DataMember]
        public string TEAM_TP_CD
        {
            get { return this.team_tp_cd; }
            set { if (this.team_tp_cd != value) { this.team_tp_cd = value; OnPropertyChanged("TEAM_TP_CD", value); } }
        }

        private string sbar_nm;
        /// <summary>
        /// name : 주제영역명
        /// </summary>
        [DataMember]
        public string SBAR_NM
        {
            get { return this.sbar_nm; }
            set { if (this.sbar_nm != value) { this.sbar_nm = value; OnPropertyChanged("SBAR_NM", value); } }
        }

        private string dtrl1_expl;
        /// <summary>
        /// name : 1번째업무규칙설명
        /// </summary>
        [DataMember]
        public string DTRL1_EXPL
        {
            get { return this.dtrl1_expl; }
            set { if (this.dtrl1_expl != value) { this.dtrl1_expl = value; OnPropertyChanged("DTRL1_EXPL", value); } }
        }

        private string dtrl2_expl;
        /// <summary>
        /// name : 2번째업무규칙설명
        /// </summary>
        [DataMember]
        public string DTRL2_EXPL
        {
            get { return this.dtrl2_expl; }
            set { if (this.dtrl2_expl != value) { this.dtrl2_expl = value; OnPropertyChanged("DTRL2_EXPL", value); } }
        }

        private string dtrl3_expl;
        /// <summary>
        /// name : 3번째업무규칙설명
        /// </summary>
        [DataMember]
        public string DTRL3_EXPL
        {
            get { return this.dtrl3_expl; }
            set { if (this.dtrl3_expl != value) { this.dtrl3_expl = value; OnPropertyChanged("DTRL3_EXPL", value); } }
        }

        private string dtrl4_expl;
        /// <summary>
        /// name : 4번째업무규칙설명
        /// </summary>
        [DataMember]
        public string DTRL4_EXPL
        {
            get { return this.dtrl4_expl; }
            set { if (this.dtrl4_expl != value) { this.dtrl4_expl = value; OnPropertyChanged("DTRL4_EXPL", value); } }
        }

        private string dtrl5_expl;
        /// <summary>
        /// name : 5번째업무규칙설명
        /// </summary>
        [DataMember]
        public string DTRL5_EXPL
        {
            get { return this.dtrl5_expl; }
            set { if (this.dtrl5_expl != value) { this.dtrl5_expl = value; OnPropertyChanged("DTRL5_EXPL", value); } }
        }

        private string dtrl6_expl;
        /// <summary>
        /// name : 6번째업무규칙설명
        /// </summary>
        [DataMember]
        public string DTRL6_EXPL
        {
            get { return this.dtrl6_expl; }
            set { if (this.dtrl6_expl != value) { this.dtrl6_expl = value; OnPropertyChanged("DTRL6_EXPL", value); } }
        }



    }
}
