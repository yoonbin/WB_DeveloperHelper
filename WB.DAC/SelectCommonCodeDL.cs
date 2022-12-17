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
    public class SelectCommonCodeDL : DBSvc
    {
        //public DataTable ExcuteQuery(string query)
        //{
        //    DataTable dataTable = new DataTable();
        //    string connString = ConfigurationManager.AppSettings["MetaOracleConnectionString"];
        //    dataTable = ExecuteQuery(connString, query).Tables[0];

        //    return dataTable;
        //}
        public List<SelectCommonCode_INOUT> SelectCCCCCLTC(SelectCommonCode_INOUT dto)
        {
            List<SelectCommonCode_INOUT> list = null;
            try
            {
                list = SelectQuery(dto, "WB.SelectCommonCode.SelectCCCCCLTC").Cast<SelectCommonCode_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
        public List<SelectCommonCode_INOUT> SelectCCCCCSTE(SelectCommonCode_INOUT dto)
        {
            List<SelectCommonCode_INOUT> list = null;
            try
            {
                list = SelectQuery(dto, "WB.SelectCommonCode.SelectCCCCCSTE").Cast<SelectCommonCode_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }

        public List<SelectCommonCode_INOUT> SelectCCCMCSTE(SelectCommonCode_INOUT dto)
        {
            List<SelectCommonCode_INOUT> list = null;
            try
            {
                list = SelectQuery(dto, "WB.SelectCommonCode.SelectCCCMCSTE").Cast<SelectCommonCode_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
    }
}
