using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WB.DTO;

namespace WB
{
    public class ALL_SOURCE : DTOBase
    {
        public string OWNER { get; set; }

        public string NAME { get; set; }

        public string TYPE { get; set; }

        public int LINE { get; set; }

        public string TEXT { get; set; }
    }
}
