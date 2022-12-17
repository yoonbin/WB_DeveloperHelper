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
    public class SourceGeneraterDL : DBSvc
    {
        //public DataTable ExcuteQuery(string query)
        //{
        //    DataTable dataTable = new DataTable();
        //    string connString = ConfigurationManager.AppSettings["MetaOracleConnectionString"];
        //    dataTable = ExecuteQuery(connString, query).Tables[0];

        //    return dataTable;
        //}

        public List<SourceGenerater_INOUT> SelectEQS(SourceGenerater_INOUT dto)
        {
            List<SourceGenerater_INOUT> list = null;
            try
            {
                list = SelectQuery(dto, "WB.SELECT.SelectEQS").Cast<SourceGenerater_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
        public List<SourceGenerater_INOUT> SelectPKG(SourceGenerater_INOUT dto)
        {
            List<SourceGenerater_INOUT> list = null;
            try
            {
                list = SelectQuery(dto, "WB.SELECT.SelectPakage").Cast<SourceGenerater_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }

    }
}
