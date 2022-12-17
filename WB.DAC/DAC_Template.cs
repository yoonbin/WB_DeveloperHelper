using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using WB.Lib;

namespace WB.DAC
{
    public class DAC_Template : DBSvc
    {
        //public DataTable ExcuteQuery(string query)
        //{
        //    DataTable dataTable = new DataTable();
        //    string connString = ConfigurationManager.AppSettings["MetaOracleConnectionString"];
        //    dataTable = ExecuteQuery(connString, query).Tables[0];

        //    return dataTable;
        //}

        //public List<TableInfo_INOUT> SelectComnCd(TableInfo_INOUT dto)
        //{
        //    List<TableInfo_INOUT> list = null;
        //    try
        //    {
        //        list = SelectQuery(dto, "WB.SELECT.SelectComnCd").Cast<TableInfo_INOUT>().ToList();
        //    }

        //    catch (Exception ex)
        //    {
        //        MessageBox.Show(ex.Message);
        //    }

        //    return list;
        //}
    }
}
