using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using WB.DTO;
using WB.Lib;

namespace WB.DAC
{
    public class SelectDBSourceFinderDL : DBSvc
    {
        //public DataTable ExcuteQuery(string query)
        //{
        //    DataTable dataTable = new DataTable();
        //    string connString = ConfigurationManager.AppSettings["MetaOracleConnectionString"];
        //    dataTable = ExecuteQuery(connString, query).Tables[0];

        //    return dataTable;
        //}

        public List<SelectDBSourceFinder_INOUT> SelectDBSource(SelectDBSourceFinder_INOUT dto)
        {
            List<SelectDBSourceFinder_INOUT> list = null;
            list = SelectQuery(dto, "WB.SelectDBSourceFinder.SelectDBSource").Cast<SelectDBSourceFinder_INOUT>().ToList();

            return list;
        }
        public List<SelectDBSourceFinder_INOUT> SelectDBSource2(SelectDBSourceFinder_INOUT dto)
        {
            List<SelectDBSourceFinder_INOUT> list = null;
            try
            {
                list = SelectQuery(dto, "WB.SelectDBSourceFinder.SelectDBSource2").Cast<SelectDBSourceFinder_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }

        public List<SelectDBSourceFinder_INOUT> SelectEQSSource(SelectDBSourceFinder_INOUT dto)
        {
            List<SelectDBSourceFinder_INOUT> list = null;
            try
            {
                list = SelectQuery(dto, "WB.SelectDBSourceFinder.SelectEQSSource").Cast<SelectDBSourceFinder_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
    }
}
