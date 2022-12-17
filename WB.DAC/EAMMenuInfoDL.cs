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
    public class EAMMenuInfoDL : DBSvc
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
        /// <summary>
        /// name         : EAM조회
        /// desc         : EAM조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-03
        /// update date  : 2022-11-03
        /// </summary>
        public List<EAMMenuInfo_INOUT> EAMMenuInfo(EAMMenuInfo_INOUT inObj)
        {
            List<EAMMenuInfo_INOUT> list = null;
            try
            {
                list = SelectQuery(inObj, "WB.SELECT.SelectEamInfo").Cast<EAMMenuInfo_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
    }
}
