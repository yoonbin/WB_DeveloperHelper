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
    public class SelectDBSourceFinder_INOUT : DTOBase
    {
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


        private string type;
        /// <summary>
        /// 
        /// </summary>
        public string TYPE
        {
            get { return this.type; }
            set { if (this.type != value) { this.type = value; OnPropertyChanged("TYPE", value); } }
        }

        private string owner;
        /// <summary>
        /// 
        /// </summary>
        public string OWNER
        {
            get { return this.owner; }
            set { if (this.owner != value) { this.owner = value; OnPropertyChanged("OWNER", value); } }
        }



        //매개변수 Property ---------------------------------------------------

        private string text;
        /// <summary>
        /// 
        /// </summary>
        public string TEXT
        {
            get { return this.text; }
            set { if (this.text != value) { this.text = value; OnPropertyChanged("TEXT", value); } }
        }



    }
}
