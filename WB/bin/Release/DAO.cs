using IBatisNet.DataMapper;
using IBatisNet.DataMapper.Configuration;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace WB
{
    public class DAO
    {
        /// <summary>
        /// 자료 리스트 구하기
        /// </summary>
        /// <returns>자료 리스트</returns>
        public List<DTO> GetDataList(DTO dto)
        {
            List<DTO> list = null;

            try
            {
                ISqlMapper mapper = Mapper.Instance();
                mapper.DataSource.ConnectionString = ConfigurationManager.AppSettings["MetaOracleConnectionString"];  //"Data Source=(local);Initial Catalog=web;Integrated Security=True";                                  
                                                                                                                     //mapper.DataSource.ConnectionString = "Data Source=CNUHSTG;User Id=XSUP;Password=ez123";  //"Data Source=(local);Initial Catalog=web;Integrated Security=True";      
                                                                                                                     //IList<DataModel> list = mapper.QueryForList<DataModel>("DataDAO.GetDataList", null);           

                list = (List<DTO>)mapper.QueryForList<DTO>("DAO.GetMetaData", dto);
            }

            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }

            return list;
        }
    }
}
