using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WB.DTO;

namespace WB
{
    public class DBUser : DTOBase
    {
        public string USER_NAME { get; set; }

        public string CONNECT_STRING { get; set; }
    }
}
