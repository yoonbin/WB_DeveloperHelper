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
    public class SourceGenerater_INOUT : DTOBase
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

        private string queryid;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string QUERYID
        {
            get { return this.queryid; }
            set { if (this.queryid != value) { this.queryid = value; OnPropertyChanged("QUERYID", value); } }
        }

        private string querytext;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string QUERYTEXT
        {
            get { return this.querytext; }
            set { if (this.querytext != value) { this.querytext = value; OnPropertyChanged("QUERYTEXT", value); } }
        }

        private string eqs_id;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string EQS_ID
        {
            get { return this.eqs_id; }
            set { if (this.eqs_id != value) { this.eqs_id = value; OnPropertyChanged("EQS_ID", value); } }
        }

        private string pkg_name;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string PKG_NAME
        {
            get { return this.pkg_name; }
            set { if (this.pkg_name != value) { this.pkg_name = value; OnPropertyChanged("PKG_NAME", value); } }
        }

        private string proc_name;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string PROC_NAME
        {
            get { return this.proc_name; }
            set { if (this.proc_name != value) { this.proc_name = value; OnPropertyChanged("PROC_NAME", value); } }
        }

        private string argument_name;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string ARGUMENT_NAME
        {
            get { return this.argument_name; }
            set { if (this.argument_name != value) { this.argument_name = value; OnPropertyChanged("ARGUMENT_NAME", value); } }
        }

        private string data_type;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string DATA_TYPE
        {
            get { return this.data_type; }
            set { if (this.data_type != value) { this.data_type = value; OnPropertyChanged("DATA_TYPE", value); } }
        }

        private string in_out;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string IN_OUT
        {
            get { return this.in_out; }
            set { if (this.in_out != value) { this.in_out = value; OnPropertyChanged("IN_OUT", value); } }
        }


    }
}
