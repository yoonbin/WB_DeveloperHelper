using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WB.DTO
{
    [Serializable]
    public class FavQuery : DTOBase
    {
        public string QUERY_NAME { get; set; }

        public string QUERY_TEXT { get; set; }

        public string GROUP { get; set; }
    }
}
