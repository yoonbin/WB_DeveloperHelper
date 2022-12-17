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
    public class SelectEqsDBSource_INOUT : DTOBase
    {       
        private string queryid;
        /// <summary>
        /// name : QUERYID
        /// </summary>
        [DataMember]
        public string QUERYID
        {
            get { return this.queryid; }
            set { if (this.queryid != value) { this.queryid = value; OnPropertyChanged("QUERYID", value); } }
        }

        private string querytext;
        /// <summary>
        /// name : QUERYTEXT
        /// </summary>
        [DataMember]
        public string QUERYTEXT
        {
            get { return this.querytext; }
            set { if (this.querytext != value) { this.querytext = value; OnPropertyChanged("QUERYTEXT", value); } }
        }




        //매개변수 Property ---------------------------------------------------

        private string eqs_id;
        /// <summary>
        /// name : EQS_ID
        /// </summary>
        [DataMember]
        public string EQS_ID
        {
            get { return this.eqs_id; }
            set { if (this.eqs_id != value) { this.eqs_id = value; OnPropertyChanged("EQS_ID", value); } }
        }
        private string owner;
        /// <summary>
        /// name : OWNER
        /// </summary>
        [DataMember]
        public string OWNER
        {
            get { return this.owner; }
            set { if (this.owner != value) { this.owner = value; OnPropertyChanged("OWNER", value); } }
        }

        private string name;
        /// <summary>
        /// name : NAME
        /// </summary>
        [DataMember]
        public string NAME
        {
            get { return this.name; }
            set { if (this.name != value) { this.name = value; OnPropertyChanged("NAME", value); } }
        }

        private string type;
        /// <summary>
        /// name : TYPE
        /// </summary>
        [DataMember]
        public string TYPE
        {
            get { return this.type; }
            set { if (this.type != value) { this.type = value; OnPropertyChanged("TYPE", value); } }
        }

        private decimal line;
        /// <summary>
        /// name : LINE
        /// </summary>
        [DataMember]
        public decimal LINE
        {
            get { return this.line; }
            set { if (this.line != value) { this.line = value; OnPropertyChanged("LINE", value); } }
        }

        private string text;
        /// <summary>
        /// name : TEXT
        /// </summary>
        [DataMember]
        public string TEXT
        {
            get { return this.text; }
            set { if (this.text != value) { this.text = value; OnPropertyChanged("TEXT", value); } }
        }


        private string replace_query_text;
        /// <summary>
        /// 
        /// </summary>
        [DataMember]
        public string REPLACE_QUERY_TEXT
        {
            get { return this.replace_query_text; }
            set { if (this.replace_query_text != value) { this.replace_query_text = value; OnPropertyChanged("REPLACE_QUERY_TEXT", value); } }
        }


    }
}
