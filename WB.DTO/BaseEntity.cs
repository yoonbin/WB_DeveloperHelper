using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WB.DTO
{
    public class BaseEntity : ICloneable
    {
        public string Mode { set; get; }

        public string DBGbn { set; get; }

        public string ServiceName { set; get; }

        public string QueryId { set; get; }

        public object Clone() => this.MemberwiseClone();
    }
}
