using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WB.DTO
{
    public class BasicSetting : DTOBase
    {
        public string CODE { get; set; }

        public string PROPERTY { get; set; }

        public string VALUE { get; set; }

        public string REMARK { get; set; }
    }
}
