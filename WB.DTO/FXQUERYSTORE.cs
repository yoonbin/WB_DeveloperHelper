using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WB.DTO;

namespace WB
{
    public class FXQUERYSTORE : DTOBase
    {
        public string QUERY_ID { get; set; }

        public string QUERYID { get; set; }

        public int CATEGORYID { get; set; }

        public string QUERYTEXT { get; set; }

        public string REMARKS { get; set; }

        public string CREATEUSERID { get; set; }

        public DateTime CREATEDATE { get; set; }
    }
}
