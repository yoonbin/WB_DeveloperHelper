using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WB.DTO;

namespace WB
{
    public class ParamInfo : DTOBase
    {
        public string PKG_NAME { get; set; }

        public string PROC_NAME { get; set; }

        public string ARGUMENT_NAME { get; set; }

        public string DATA_TYPE { get; set; }

        public string IN_OUT { get; set; }
    }
}
