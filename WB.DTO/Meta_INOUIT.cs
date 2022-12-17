using System;
using System.Collections.ObjectModel;
using System.Runtime.Serialization;

namespace WB
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
    public class Meta_INOUT : DTOBase
    {
        private string gbn;
        /// <summary>
        /// name : GBN
        /// </summary>
        [DataMember]
        public string GBN
        {
            get { return this.gbn; }
            set { if (this.gbn != value) { this.gbn = value; OnPropertyChanged("GBN", value); } }
        }

        private string gbn_dtl;
        /// <summary>
        /// name : GBN_DTL
        /// </summary>
        [DataMember]
        public string GBN_DTL
        {
            get { return this.gbn_dtl; }
            set { if (this.gbn_dtl != value) { this.gbn_dtl = value; OnPropertyChanged("GBN_DTL", value); } }
        }

        private string dic_log_nm;
        /// <summary>
        /// name : DIC_LOG_NM
        /// </summary>
        [DataMember]
        public string DIC_LOG_NM
        {
            get { return this.dic_log_nm; }
            set { if (this.dic_log_nm != value) { this.dic_log_nm = value; OnPropertyChanged("DIC_LOG_NM", value); } }
        }

        private string dic_phy_nm;
        /// <summary>
        /// name : DIC_PHY_NM
        /// </summary>
        [DataMember]
        public string DIC_PHY_NM
        {
            get { return this.dic_phy_nm; }
            set { if (this.dic_phy_nm != value) { this.dic_phy_nm = value; OnPropertyChanged("DIC_PHY_NM", value); } }
        }

        private string dic_phy_fll_nm;
        /// <summary>
        /// name : DIC_PHY_FLL_NM
        /// </summary>
        [DataMember]
        public string DIC_PHY_FLL_NM
        {
            get { return this.dic_phy_fll_nm; }
            set { if (this.dic_phy_fll_nm != value) { this.dic_phy_fll_nm = value; OnPropertyChanged("DIC_PHY_FLL_NM", value); } }
        }

        private string dic_desc;
        /// <summary>
        /// name : DIC_DESC
        /// </summary>
        [DataMember]
        public string DIC_DESC
        {
            get { return this.dic_desc; }
            set { if (this.dic_desc != value) { this.dic_desc = value; OnPropertyChanged("DIC_DESC", value); } }
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

        private string standard_yn;
        /// <summary>
        /// name : STANDARD_YN
        /// </summary>
        [DataMember]
        public string STANDARD_YN
        {
            get { return this.standard_yn; }
            set { if (this.standard_yn != value) { this.standard_yn = value; OnPropertyChanged("STANDARD_YN", value); } }
        }

        private string dom_grp_nm;
        /// <summary>
        /// name : DOM_GRP_NM
        /// </summary>
        [DataMember]
        public string DOM_GRP_NM
        {
            get { return this.dom_grp_nm; }
            set { if (this.dom_grp_nm != value) { this.dom_grp_nm = value; OnPropertyChanged("DOM_GRP_NM", value); } }
        }

        private string text;
        /// <summary>
        /// name : GBN
        /// </summary>
        [DataMember]
        public string TEXT
        {
            get { return this.text; }
            set { if (this.text != value) { this.text = value; OnPropertyChanged("TEXT", value); } }
        }

        private string query_name;
        /// <summary>
        /// name : QUERY_NAME
        /// </summary>
        [DataMember]
        public string QUERY_NAME
        {
            get { return this.query_name; }
            set { if (this.query_name != value) { this.query_name = value; OnPropertyChanged("QUERY_NAME", value); } }
        }


    }
}
