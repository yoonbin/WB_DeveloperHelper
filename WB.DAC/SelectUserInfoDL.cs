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
    public class SelectUserInfoDL : DBSvc
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
        /// name         : 사용자정보 조회
        /// desc         : 사용자정보 조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-27
        /// update date  : 2022-10-27
        /// </summary>
        public List<SelectUserInfo_INOUT> SelectUserInfo(SelectUserInfo_INOUT inObj)
        {
            List<SelectUserInfo_INOUT> list = null;
            try
            {
                list = SelectQuery(inObj, "WB.SELECT.SelectUserInfo").Cast<SelectUserInfo_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
    }
}
