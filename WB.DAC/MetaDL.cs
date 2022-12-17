using IBatisNet.DataMapper;
using IBatisNet.DataMapper.Configuration;
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

namespace WB
{
    public class MetaDL : DBSvc
    {
        /// <summary>
        /// 자료 리스트 구하기
        /// </summary>
        /// <returns>자료 리스트</returns>

        public List<TableInfo_INOUT> GetTableList(TableInfo_INOUT dto)
        {
            List<TableInfo_INOUT> list = null;                       
            try
            {
                list = SelectQuery(dto, "MetaDL.GetTableData").Cast<TableInfo_INOUT>().ToList();         
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
        public List<TableInfo_INOUT> SelectTableIndex(TableInfo_INOUT dto)
        {
            List<TableInfo_INOUT> list = null;
            try
            {
                list = SelectQuery(dto, "WB.SELECT.SelectTableIndex").Cast<TableInfo_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
        public List<TableInfo_INOUT> SelectTableRefObj(TableInfo_INOUT dto)
        {
            List<TableInfo_INOUT> list = null;
            try
            {
                list = SelectQuery(dto, "WB.SELECT.GetTableRefObj").Cast<TableInfo_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
        public List<TableInfo_INOUT> GetAllTableList(TableInfo_INOUT dto)
        {
            List<TableInfo_INOUT> list = null;          
            try
            {
                list = SelectQuery(dto, "MetaDL.GetAllTable").Cast<TableInfo_INOUT>().ToList();               
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }

        public List<TableInfo_INOUT> GetAllTableList2(TableInfo_INOUT dto)
        {
            List<TableInfo_INOUT> list = null;                       
            try
            {
                list = SelectQuery(dto, "MetaDL.GetAllTable2").Cast<TableInfo_INOUT>().ToList();                         
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
        public List<TableInfo_INOUT> SelectComnCd(TableInfo_INOUT dto)
        {
            List<TableInfo_INOUT> list = null;
            try
            {
                list = SelectQuery(dto, "WB.SELECT.SelectComnCd").Cast<TableInfo_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }

        public List<Meta_INOUT> GetMetaList(Meta_INOUT dto)
        {
            List<Meta_INOUT> list = null;
            try
            {
                list = SelectMetaQuery(dto, "MetaDL.GetMetaData").Cast<Meta_INOUT>().ToList();
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
    }
}
