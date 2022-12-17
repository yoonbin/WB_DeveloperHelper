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
    public class SelectCalMemo_INOUT : DTOBase
    {
        private string memo_date;
        /// <summary>
        /// 
        /// </summary>
        public string MEMO_DATE
        {
            get { return this.memo_date; }
            set { if (this.memo_date != value) { this.memo_date = value; OnPropertyChanged("MEMO_DATE", value); } }
        }

        private string memo_text;
        /// <summary>
        /// 
        /// </summary>
        public string MEMO_TEXT
        {
            get { return this.memo_text; }
            set { if (this.memo_text != value) { this.memo_text = value; OnPropertyChanged("MEMO_TEXT", value); } }
        }



    }
}
