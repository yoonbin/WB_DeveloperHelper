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
    public class SelectEqsDBSourceDL : DBSvc
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
        /// name         : EQS,DB조회
        /// desc         : EQS,DB조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        public List<SelectEqsDBSource_INOUT> SelectEqsDBSource(SelectEqsDBSource_INOUT inObj)
        {
            List<SelectEqsDBSource_INOUT> list = null;
            try
            {
                list = SelectQuery(inObj, "WB.SelectEqsDBSource.SelectEQS").Cast<SelectEqsDBSource_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }

        /// <summary>
        /// name         : EQS,DB조회
        /// desc         : EQS,DB조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        public List<SelectEqsDBSource_INOUT> SelectDBSource(SelectEqsDBSource_INOUT inObj)
        {
            List<SelectEqsDBSource_INOUT> list = null;
            try
            {
                list = SelectQuery(inObj, "WB.SelectEqsDBSource.SelectDB").Cast<SelectEqsDBSource_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }

        /// <summary>
        /// name         : EQS,DB조회
        /// desc         : EQS,DB조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        public List<SelectEqsDBSource_INOUT> SelectEQSSourceLike(SelectEqsDBSource_INOUT inObj)
        {
            List<SelectEqsDBSource_INOUT> list = null;
            try
            {
                list = SelectQuery(inObj, "WB.SelectEqsDBSource.SelectEQSLike").Cast<SelectEqsDBSource_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }

        /// <summary>
        /// name         : EQS,DB조회
        /// desc         : EQS,DB조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-07
        /// update date  : 2022-11-07
        /// </summary>
        public List<SelectEqsDBSource_INOUT> SelectDBSourceLike(SelectEqsDBSource_INOUT inObj)
        {
            List<SelectEqsDBSource_INOUT> list = null;
            try
            {
                list = SelectQuery(inObj, "WB.SelectEqsDBSource.SelectDBLike").Cast<SelectEqsDBSource_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
    }
}
