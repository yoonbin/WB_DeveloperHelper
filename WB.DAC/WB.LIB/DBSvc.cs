using IBatisNet.DataMapper;
using IBatisNet.DataMapper.Configuration;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.OracleClient;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Windows;
using System.Xml;
using WB.DTO;

namespace WB.Lib
{
    public class DBSvc
    {
        private List<DTOBase> param = new List<DTOBase>();
        private List<IList> result = new List<IList>();
        private List<int> updateResult = new List<int>();
        private Dictionary<string, ISqlMapper> lstMapper = new Dictionary<string, ISqlMapper>();

        public bool IsBusy { get; set; }

        public List<DTOBase> Param => this.param;

        public List<IList> Result => this.result;

        public List<int> UpdateResult => this.updateResult;

        public void Select()
        {
            if (this.IsBusy)
                return;
            this.IsBusy = true;
            try
            {
                List<IList> dataSet = this.SelectMulti(this.param.ToArray()).Cast<IList>().ToList();
                int tableIdx = 0;
                foreach (IList il in this.Result)
                {
                    DBSvc.ConvertObservableCollection(il, (IList)dataSet, tableIdx);
                    ++tableIdx;
                }
            }
            catch (Exception ex)
            {
                int num = (int)MessageBox.Show("DB 조회 오류 : " + ex.ToString());
            }
            this.IsBusy = false;
            this.Param.Clear();
            this.Result.Clear();
        }

        public List<IList> Select(DTOBase[] arrQuery) => this.SelectMulti(arrQuery).Cast<IList>().ToList();

        public List<object> SelectMulti(DTOBase[] arrEntity)
        {
            DomSqlMapBuilder domSqlMapBuilder = new DomSqlMapBuilder();
            List<object> listList = new List<object>();
            IList list1 = (IList)null;
            foreach (DTOBase parameterObject in arrEntity)
            {
                if (parameterObject != null)
                {
                    ISqlMapper mapper = this.GetMapper(parameterObject.DBGbn, parameterObject.ServiceName);
                    IList list2;
                    try
                    {
                        list2 = mapper.QueryForList(parameterObject.QueryId, (object)parameterObject);
                    }
                    catch (Exception ex)
                    {
                        list1 = (IList)null;
                        this.IsBusy = false;
                        throw ex;
                    }
                    listList.Add(list2);
                }
            }
            var type = listList.GetType().Name;
            return listList;
        }
        public IList SelectQuery(DTOBase dto,string Queryid)
        {
            CreateBase(dto);
            DomSqlMapBuilder domSqlMapBuilder = new DomSqlMapBuilder();
            IList list2 = (IList)null;

            if (dto != null)
            {
                ISqlMapper mapper = this.GetMapper(dto.DBGbn, dto.ServiceName);
                try
                {
                    list2 = mapper.QueryForList(Queryid, (object)dto);
                }
                catch (Exception ex)
                {
                    this.IsBusy = false;
                    throw ex;
                }
            }
            return list2;
        }
        public IList SelectMetaQuery(DTOBase dto, string Queryid)
        {
            CreateBase(dto);
            DomSqlMapBuilder domSqlMapBuilder = new DomSqlMapBuilder();
            IList list2 = (IList)null;

            if (dto != null)
            {
                ISqlMapper mapper = this.GetMetaMapper(dto.DBGbn, dto.ServiceName);
                try
                {
                    list2 = mapper.QueryForList(Queryid, (object)dto);
                }
                catch (Exception ex)
                {
                    this.IsBusy = false;
                    throw ex;
                }
            }
            return list2;
        }
        public int SelectCnt(DTOBase param)
        {
            if (this.IsBusy)
                return -1;
            this.IsBusy = true;
            DomSqlMapBuilder domSqlMapBuilder = new DomSqlMapBuilder();
            if (param == null)
                return -1;
            int num = this.GetMapper(param.DBGbn, param.ServiceName).QueryForObject<int>(param.QueryId, (object)param);
            this.IsBusy = false;
            return num;
        }

        private ISqlMapper GetMapper(string DBGbn, string ServiceName)
        {
            ISqlMapper mapper;
            if (this.lstMapper.ContainsKey(ServiceName))
            {
                mapper = this.lstMapper[ServiceName];
            }
            else
            {
                DomSqlMapBuilder domSqlMapBuilder = new DomSqlMapBuilder();
                string str = string.Format(".\\SqlMap.config", (object)DBGbn.ToUpper(), (object)ServiceName.ToUpper());
                mapper = File.Exists(str) ? domSqlMapBuilder.Configure(str) : throw new Exception("config 파일 로드 실패!");
            }
            return mapper;
        }
        private ISqlMapper GetMetaMapper(string DBGbn, string ServiceName)
        {
            ISqlMapper mapper;
            if (this.lstMapper.ContainsKey(ServiceName))
            {
                mapper = this.lstMapper[ServiceName];
            }
            else
            {
                DomSqlMapBuilder domSqlMapBuilder = new DomSqlMapBuilder();
                string str = string.Format(".\\MetaSqlMap.config", (object)DBGbn.ToUpper(), (object)ServiceName.ToUpper());
                mapper = File.Exists(str) ? domSqlMapBuilder.Configure(str) : throw new Exception("config 파일 로드 실패!");
            }
            return mapper;
        }
        public DataSet ExecuteQueryForMakeDTO(string query) => this.ExecuteQueryForMakeDTO(this.GetConnectionString(), query);

        public DataSet ExecuteQueryForMakeDTO(string connString, string query)
        {
            query = this.RemoveComment(query);
            if (string.IsNullOrEmpty(query))
                return (DataSet)null;
            DataSet dataSet = new DataSet();
            string connectionString = connString;
            if (string.IsNullOrEmpty(connectionString))
                return (DataSet)null;
            using (OracleConnection connection = new OracleConnection(connectionString))
            {
                OracleCommand selectCommand = new OracleCommand(query, connection);
                
                selectCommand.CommandType = CommandType.Text;
                
                foreach (Group match in Regex.Matches(query, ":\\w+"))
                {
                    foreach (Capture capture in match.Captures)
                    {
                        if (capture.Value.Length >= 4 && !int.TryParse(capture.Value.Substring(1, 1), out int _))
                            selectCommand.Parameters.Add(new OracleParameter(capture.Value, (object)""));
                    }
                }
                new OracleDataAdapter(selectCommand).Fill(dataSet);
            }
            return dataSet;
        }

        public DataSet ExecuteQueryForMakeDTO2(string query) => this.ExecuteQueryForMakeDTO2(this.GetConnectionString(), query);

        public DataSet ExecuteQueryForMakeDTO2(string connString, string query)
        {
            query = this.RemoveComment2(query);
            if (string.IsNullOrEmpty(query))
                return (DataSet)null;
            DataSet dataSet = new DataSet();
            string connectionString = connString;
            if (string.IsNullOrEmpty(connectionString))
                return (DataSet)null;
            using (OracleConnection connection = new OracleConnection(connectionString))
            {
                OracleCommand selectCommand = new OracleCommand(query, connection);
                selectCommand.CommandType = CommandType.Text;
                foreach (Group match in Regex.Matches(query, @"\:\w+"))
                {
                    foreach (Capture capture in match.Captures)
                    {
                        if (capture.Value.Length >= 4 && !int.TryParse(capture.Value.Substring(1, 1), out int _))
                            selectCommand.Parameters.Add(new OracleParameter(capture.Value, (object)""));
                    }
                }
                new OracleDataAdapter(selectCommand).Fill(dataSet);
            }
            return dataSet;
        }

        public DataSet ExecuteQuery(string query) => this.ExecuteQuery(this.GetConnectionString(), query);

        public DataSet ExecuteQuery(string connString, string query)
        {
            query = this.RemoveComment(query);
            if (string.IsNullOrEmpty(query))
                return (DataSet)null;
            DataSet dataSet = new DataSet();
            string connectionString = connString;
            if (string.IsNullOrEmpty(connectionString))
                return (DataSet)null;
            using (OracleConnection connection = new OracleConnection(connectionString))
            {
                OracleCommand selectCommand = new OracleCommand(query, connection);
                selectCommand.CommandType = CommandType.Text;
                new OracleDataAdapter(selectCommand).Fill(dataSet);
            }
            return dataSet;
        }

        private string GetConnectionString()
        {
            string filename = string.Format(".\\SqlMap.config");
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.Load(filename);
            string connectionString = "";
            try
            {
                connectionString = xmlDocument.ChildNodes[1]["database"]["dataSource"].Attributes["connectionString"].Value;
            }
            catch
            {
            }
            return connectionString;
        }

        public string RemoveComment(string sql)
        {
            string str1 = "/\\*(.*?)\\*/";
            string str2 = "--(.*?)\\r?\\n";
            string str3 = "\"((\\\\[^\\n]|[^\"\\n])*)\"";
            string str4 = "@(\"[^\"]*\")+";
            return Regex.Replace(sql, str1 + "|" + str2 + "|" + str3 + "|" + str4, (MatchEvaluator)(me => me.Value.StartsWith("/*") || me.Value.StartsWith("--") ? (me.Value.StartsWith("--") ? Environment.NewLine : "") : me.Value), RegexOptions.Singleline);
        }
        public string RemoveComment2(string queryText)
        {
            if (string.IsNullOrEmpty(queryText))
                return string.Empty;
            string str1 = "/\\*(.*?)\\*/";
            string str2 = "--(.*?)\\n";
            string str3 = "\"((\\\\[^\\n]|[^\"\\n])*)\"";
            string str4 = "@(\"[^\"]*\")+";
            return Regex.Replace(queryText, str1 + "|" + str2 + "|" + str3 + "|" + str4, (MatchEvaluator)(query => !query.Value.StartsWith("/*+") && (query.Value.StartsWith("/*") || query.Value.StartsWith("--")) ? (query.Value.StartsWith("--") ? Environment.NewLine : string.Empty) : query.Value), RegexOptions.Singleline);
            //string str1 = @"\<([^\<\>]+)\>";            
            //var data = Regex.Matches(query,  str1);
            //foreach (Match match in Regex.Matches(query, str1))
            //{                
            //    query = query.Replace(match.Value, string.Empty);
            //}
            //while (query.IndexOf("-->") > -1)
            //    query = query.Substring(query.IndexOf("-->") + 3);
            //return query;
            
        }
        public static void ConvertObservableCollection(IList il, IList dataSet, int tableIdx)
        {
            if (il == null || dataSet.Count <= tableIdx)
                return;
            foreach (object obj in (IEnumerable)dataSet[tableIdx])
                il.Add(obj);
        }

        public static T CreateEntity<T>() where T : new()
        {
            T entity = new T();
            if (entity is DTOBase baseEntity)
            {
                baseEntity.Mode = "S";
                baseEntity.ServiceName = Application.Current.Properties[(object)"ServiceName"] != null ? Application.Current.Properties[(object)"ServiceName"].ToString() : "WB";
                baseEntity.DBGbn = Application.Current.Properties[(object)"DBGbn"] != null ? Application.Current.Properties[(object)"DBGbn"].ToString() : "APP";
            }
            return entity;
        }

        public static void CreateBase(DTOBase dto)
        {
            if (dto is DTOBase baseEntity)
            {
                dto.Mode = "S";
                dto.ServiceName = Application.Current.Properties[(object)"ServiceName"] != null ? Application.Current.Properties[(object)"ServiceName"].ToString() : "WB";
                dto.DBGbn = Application.Current.Properties[(object)"DBGbn"] != null ? Application.Current.Properties[(object)"DBGbn"].ToString() : "APP";
            }
        }
    }
}
