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
    public class FavQueryTree_INOUT : DTOBase
    {
        private string fldr_item_tp;
        /// <summary>
        /// name : FLDR_ITEM_TP
        /// </summary>
        [DataMember]
        public string FLDR_ITEM_TP
        {
            get { return this.fldr_item_tp; }
            set { if (this.fldr_item_tp != value) { this.fldr_item_tp = value; OnPropertyChanged("FLDR_ITEM_TP", value); } }
        }

        private string upr_fldr_id;
        /// <summary>
        /// name : UPR_FLDR_ID
        /// </summary>
        [DataMember]
        public string UPR_FLDR_ID
        {
            get { return this.upr_fldr_id; }
            set { if (this.upr_fldr_id != value) { this.upr_fldr_id = value; OnPropertyChanged("UPR_FLDR_ID", value); } }
        }

        private string fldr_id;
        /// <summary>
        /// name : FLDR_ID
        /// </summary>
        [DataMember]
        public string FLDR_ID
        {
            get { return this.fldr_id; }
            set { if (this.fldr_id != value) { this.fldr_id = value; OnPropertyChanged("FLDR_ID", value); } }
        }

        private string dis_nm;
        /// <summary>
        /// name : DIS_NM
        /// </summary>
        [DataMember]
        public string DIS_NM
        {
            get { return this.dis_nm; }
            set { if (this.dis_nm != value) { this.dis_nm = value; OnPropertyChanged("DIS_NM", value); } }
        }

        private string dept_cd;
        /// <summary>
        /// name : 부서코드
        /// </summary>
        [DataMember]
        public string DEPT_CD
        {
            get { return this.dept_cd; }
            set { if (this.dept_cd != value) { this.dept_cd = value; OnPropertyChanged("DEPT_CD", value); } }
        }

        private string fldr_nm;
        /// <summary>
        /// name : 폴더명
        /// </summary>
        [DataMember]
        public string FLDR_NM
        {
            get { return this.fldr_nm; }
            set { if (this.fldr_nm != value) { this.fldr_nm = value; OnPropertyChanged("FLDR_NM", value); } }
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

        private string memo_cnte;
        /// <summary>
        /// name : 메모내용
        /// </summary>
        [DataMember]
        public string MEMO_CNTE
        {
            get { return this.memo_cnte; }
            set { if (this.memo_cnte != value) { this.memo_cnte = value; OnPropertyChanged("MEMO_CNTE", value); } }
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

        private decimal wrt_seq;
        /// <summary>
        /// name : 작성순번
        /// </summary>
        [DataMember]
        public decimal WRT_SEQ
        {
            get { return this.wrt_seq; }
            set { if (this.wrt_seq != value) { this.wrt_seq = value; OnPropertyChanged("WRT_SEQ", value); } }
        }

        private string ord_nm;
        /// <summary>
        /// name : 처방명
        /// </summary>
        [DataMember]
        public string ORD_NM
        {
            get { return this.ord_nm; }
            set { if (this.ord_nm != value) { this.ord_nm = value; OnPropertyChanged("ORD_NM", value); } }
        }

        private string ord_cd;
        /// <summary>
        /// name : 처방코드
        /// </summary>
        [DataMember]
        public string ORD_CD
        {
            get { return this.ord_cd; }
            set { if (this.ord_cd != value) { this.ord_cd = value; OnPropertyChanged("ORD_CD", value); } }
        }

        private string orgn_ord_cd;
        /// <summary>
        /// name : ORGN_ORD_CD
        /// </summary>
        [DataMember]
        public string ORGN_ORD_CD
        {
            get { return this.orgn_ord_cd; }
            set { if (this.orgn_ord_cd != value) { this.orgn_ord_cd = value; OnPropertyChanged("ORGN_ORD_CD", value); } }
        }

        private string mif_cd;
        /// <summary>
        /// name : 수가코드
        /// </summary>
        [DataMember]
        public string MIF_CD
        {
            get { return this.mif_cd; }
            set { if (this.mif_cd != value) { this.mif_cd = value; OnPropertyChanged("MIF_CD", value); } }
        }

        private string mt_yn;
        /// <summary>
        /// name : MT_YN
        /// </summary>
        [DataMember]
        public string MT_YN
        {
            get { return this.mt_yn; }
            set { if (this.mt_yn != value) { this.mt_yn = value; OnPropertyChanged("MT_YN", value); } }
        }

        private string med_mifi_tp_cd;
        /// <summary>
        /// name : 진료수가보험구분코드
        /// </summary>
        [DataMember]
        public string MED_MIFI_TP_CD
        {
            get { return this.med_mifi_tp_cd; }
            set { if (this.med_mifi_tp_cd != value) { this.med_mifi_tp_cd = value; OnPropertyChanged("MED_MIFI_TP_CD", value); } }
        }

        private decimal qty;
        /// <summary>
        /// name : 수량
        /// </summary>
        [DataMember]
        public decimal QTY
        {
            get { return this.qty; }
            set { if (this.qty != value) { this.qty = value; OnPropertyChanged("QTY", value); } }
        }

        private decimal prpd_notm;
        /// <summary>
        /// name : 기간별횟수
        /// </summary>
        [DataMember]
        public decimal PRPD_NOTM
        {
            get { return this.prpd_notm; }
            set { if (this.prpd_notm != value) { this.prpd_notm = value; OnPropertyChanged("PRPD_NOTM", value); } }
        }

        private string ord_psb_yn;
        /// <summary>
        /// name : 처방가능여부
        /// </summary>
        [DataMember]
        public string ORD_PSB_YN
        {
            get { return this.ord_psb_yn; }
            set { if (this.ord_psb_yn != value) { this.ord_psb_yn = value; OnPropertyChanged("ORD_PSB_YN", value); } }
        }

        private string ngt_adn_yn;
        /// <summary>
        /// name : 야간가산여부
        /// </summary>
        [DataMember]
        public string NGT_ADN_YN
        {
            get { return this.ngt_adn_yn; }
            set { if (this.ngt_adn_yn != value) { this.ngt_adn_yn = value; OnPropertyChanged("NGT_ADN_YN", value); } }
        }

        private string trmt_emrg_adn_yn;
        /// <summary>
        /// name : 처치재료응급가산여부
        /// </summary>
        [DataMember]
        public string TRMT_EMRG_ADN_YN
        {
            get { return this.trmt_emrg_adn_yn; }
            set { if (this.trmt_emrg_adn_yn != value) { this.trmt_emrg_adn_yn = value; OnPropertyChanged("TRMT_EMRG_ADN_YN", value); } }
        }

        private string chdr_stf_no;
        /// <summary>
        /// name : 선택의직원번호
        /// </summary>
        [DataMember]
        public string CHDR_STF_NO
        {
            get { return this.chdr_stf_no; }
            set { if (this.chdr_stf_no != value) { this.chdr_stf_no = value; OnPropertyChanged("CHDR_STF_NO", value); } }
        }

        private decimal rtc_notm;
        /// <summary>
        /// name : RTC_NOTM
        /// </summary>
        [DataMember]
        public decimal RTC_NOTM
        {
            get { return this.rtc_notm; }
            set { if (this.rtc_notm != value) { this.rtc_notm = value; OnPropertyChanged("RTC_NOTM", value); } }
        }

        private string anmc_yn;
        /// <summary>
        /// name : ANMC_YN
        /// </summary>
        [DataMember]
        public string ANMC_YN
        {
            get { return this.anmc_yn; }
            set { if (this.anmc_yn != value) { this.anmc_yn = value; OnPropertyChanged("ANMC_YN", value); } }
        }

        private string vat_cls_cd;
        /// <summary>
        /// name : 부가세유형코드
        /// </summary>
        [DataMember]
        public string VAT_CLS_CD
        {
            get { return this.vat_cls_cd; }
            set { if (this.vat_cls_cd != value) { this.vat_cls_cd = value; OnPropertyChanged("VAT_CLS_CD", value); } }
        }

        private string otpt_owh_psb_yn;
        /// <summary>
        /// name : OTPT_OWH_PSB_YN
        /// </summary>
        [DataMember]
        public string OTPT_OWH_PSB_YN
        {
            get { return this.otpt_owh_psb_yn; }
            set { if (this.otpt_owh_psb_yn != value) { this.otpt_owh_psb_yn = value; OnPropertyChanged("OTPT_OWH_PSB_YN", value); } }
        }

        private string brst_exsn_aom_yn;
        /// <summary>
        /// name : BRST_EXSN_AOM_YN
        /// </summary>
        [DataMember]
        public string BRST_EXSN_AOM_YN
        {
            get { return this.brst_exsn_aom_yn; }
            set { if (this.brst_exsn_aom_yn != value) { this.brst_exsn_aom_yn = value; OnPropertyChanged("BRST_EXSN_AOM_YN", value); } }
        }

        private string ngt_adn_mif_val;
        /// <summary>
        /// name : NGT_ADN_MIF_VAL
        /// </summary>
        [DataMember]
        public string NGT_ADN_MIF_VAL
        {
            get { return this.ngt_adn_mif_val; }
            set { if (this.ngt_adn_mif_val != value) { this.ngt_adn_mif_val = value; OnPropertyChanged("NGT_ADN_MIF_VAL", value); } }
        }

        private string ord_ctrl_cd;
        /// <summary>
        /// name : 처방제어코드
        /// </summary>
        [DataMember]
        public string ORD_CTRL_CD
        {
            get { return this.ord_ctrl_cd; }
            set { if (this.ord_ctrl_cd != value) { this.ord_ctrl_cd = value; OnPropertyChanged("ORD_CTRL_CD", value); } }
        }

        private string mdng_adn_mif_val;
        /// <summary>
        /// name : MDNG_ADN_MIF_VAL
        /// </summary>
        [DataMember]
        public string MDNG_ADN_MIF_VAL
        {
            get { return this.mdng_adn_mif_val; }
            set { if (this.mdng_adn_mif_val != value) { this.mdng_adn_mif_val = value; OnPropertyChanged("MDNG_ADN_MIF_VAL", value); } }
        }

        private string aim_ord_chk_val;
        /// <summary>
        /// name : AIM_ORD_CHK_VAL
        /// </summary>
        [DataMember]
        public string AIM_ORD_CHK_VAL
        {
            get { return this.aim_ord_chk_val; }
            set { if (this.aim_ord_chk_val != value) { this.aim_ord_chk_val = value; OnPropertyChanged("AIM_ORD_CHK_VAL", value); } }
        }

        private string aim_ord_chk_type;
        /// <summary>
        /// name : AIM_ORD_CHK_TYPE
        /// </summary>
        [DataMember]
        public string AIM_ORD_CHK_TYPE
        {
            get { return this.aim_ord_chk_type; }
            set { if (this.aim_ord_chk_type != value) { this.aim_ord_chk_type = value; OnPropertyChanged("AIM_ORD_CHK_TYPE", value); } }
        }

        private string aim_ord_chk_val_chg_yn;
        /// <summary>
        /// name : AIM_ORD_CHK_VAL_CHG_YN
        /// </summary>
        [DataMember]
        public string AIM_ORD_CHK_VAL_CHG_YN
        {
            get { return this.aim_ord_chk_val_chg_yn; }
            set { if (this.aim_ord_chk_val_chg_yn != value) { this.aim_ord_chk_val_chg_yn = value; OnPropertyChanged("AIM_ORD_CHK_VAL_CHG_YN", value); } }
        }




        //매개변수 Property ---------------------------------------------------

        private string aoa_wkdp_cd;
        /// <summary>
        /// name : AOA_WKDP_CD
        /// </summary>
        [DataMember]
        public string AOA_WKDP_CD
        {
            get { return this.aoa_wkdp_cd; }
            set { if (this.aoa_wkdp_cd != value) { this.aoa_wkdp_cd = value; OnPropertyChanged("AOA_WKDP_CD", value); } }
        }

        private string pact_tp_cd;
        /// <summary>
        /// name : PACT_TP_CD
        /// </summary>
        [DataMember]
        public string PACT_TP_CD
        {
            get { return this.pact_tp_cd; }
            set { if (this.pact_tp_cd != value) { this.pact_tp_cd = value; OnPropertyChanged("PACT_TP_CD", value); } }
        }



    }
}
