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
    public class CodeGenerater_INOUT : DTOBase
    {
        private string data_type_nm;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string DATA_TYPE_NM
        {
            get { return this.data_type_nm; }
            set { if (this.data_type_nm != value) { this.data_type_nm = value; OnPropertyChanged("DATA_TYPE_NM", value); } }
        }

        private string data_type_cd;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string DATA_TYPE_CD
        {
            get { return this.data_type_cd; }
            set { if (this.data_type_cd != value) { this.data_type_cd = value; OnPropertyChanged("DATA_TYPE_CD", value); } }
        }




    }
}
