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
    public class DTOTemplate : DTOBase
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


    }
}
