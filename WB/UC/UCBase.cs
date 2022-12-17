using System;
using System.Data.Entity;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Data;
using System.Deployment.Application;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Threading;
using WB.DTO;
using WB.Lib;
using System.Diagnostics;

namespace WB.UC
{
    public class UCBase : UserControl
    {
        public int DB { set; get; }
        private string DEL_DBSOURCE_TXT = "";        
        public UCBase()
        {
            this.DB = -1;            
        }

        public DBSvc DBSvc = new DBSvc();
        public delegate void Delegate();        
        protected bool NumCheck(string strNumber)
        {
            try
            {
                Convert.ToInt32(strNumber);
                return true;
            }
            catch
            {
                return false;
            }
        }

        protected MainWindow OwnerWindow => Window.GetWindow((DependencyObject)this) as MainWindow;
        protected BasicSetting MetaConnection => this.OwnerWindow.OcBasicSetting.Where<BasicSetting>((Func<BasicSetting, bool>)(d => d.CODE == "MetaConnectionString")).FirstOrDefault<BasicSetting>();
        
        protected void ClearSort(DataGrid drid)
        {
            foreach (DataGridColumn column in (Collection<DataGridColumn>)drid.Columns)
                column.SortDirection = new ListSortDirection?();
            ICollectionView defaultView = CollectionViewSource.GetDefaultView((object)drid.ItemsSource);
            defaultView.SortDescriptions.Clear();
            defaultView.Refresh();
        }

        protected void dgdObjList_LoadingRow(object sender, DataGridRowEventArgs e) => e.Row.Header = (object)(e.Row.GetIndex() + 1);

        protected void dgdObjList_AutoGeneratingColumn(
          object sender,
          DataGridAutoGeneratingColumnEventArgs e)
        {
            e.Column.Header = (object)e.Column.Header.ToString().Replace("_", "__");
        }

        protected void TextBoxPreviewKeyDown_RemoveBlank(object sender, KeyEventArgs e)
        {
            if ((Keyboard.Modifiers & ModifierKeys.Control) != ModifierKeys.Control || e.Key != Key.V || !(sender is TextBox textBox))
                return;
            string[] source = Clipboard.GetText().Split(new string[1]
            {
        "\r\n"
            }, StringSplitOptions.RemoveEmptyEntries);
            textBox.Text = string.Join("\r\n", ((IEnumerable<string>)source).Select<string, string>((Func<string, string>)(p => p.Trim())).Where<string>((Func<string, bool>)(w => !string.IsNullOrWhiteSpace(w))));
            textBox.CaretIndex = textBox.Text.Length;
            e.Handled = true;
        }

        protected void ProgressOn()
        {
            if (this.OwnerWindow == null)
                return;
            this.OwnerWindow.ProgressOn();
        }

        protected void ProgressOff()
        {
            if (this.OwnerWindow == null)
                return;
            this.OwnerWindow.ProgressOff();
        }
       

        protected DataTable GetColumnNameInfo(ObservableCollection<ParamInfo> list)
        {
            string str1 = "";
            foreach (ParamInfo paramInfo in (Collection<ParamInfo>)list)
            {
                string str2 = paramInfo.ARGUMENT_NAME.ToUpper();
                if (str2.IndexOf("IN_") == 0 && str2.Length > 2)
                    str2 = str2.Substring(3);
                str1 += string.Format(",'{0}'", (object)str2);
            }
            return string.IsNullOrEmpty(str1) ? (DataTable)null : this.GetColumnNameInfo(str1.Length > 0 ? str1.Substring(1) : "");
        }

        protected DataTable GetColumnNameInfo(ArrayList list)
        {
            string str1 = "";
            foreach (string str2 in list)
            {
                string str3 = str2.ToUpper();
                if (str3.IndexOf("IN_") == 0 && str3.Length > 2)
                    str3 = str3.Substring(3);
                str1 += string.Format(",'{0}'", (object)str3);
            }
            return string.IsNullOrEmpty(str1) ? (DataTable)null : this.GetColumnNameInfo(str1.Length > 0 ? str1.Substring(1) : "");
        }

        protected DataTable GetColumnNameInfo(DataTable dt)
        {
            string str1 = "";
            foreach (DataColumn column in (InternalDataCollectionBase)dt.Columns)
            {
                string str2 = column.ColumnName.IndexOf("IN_") != 0 ? column.ColumnName : column.ColumnName.Length > 2 ? column.ColumnName.Substring(3) : "";
                str1 += string.Format(",'{0}'", (object)str2);
            }
            return string.IsNullOrEmpty(str1) ? (DataTable)null : this.GetColumnNameInfo(str1.Length > 0 ? str1.Substring(1) : "");
        }

        protected DataTable GetColumnNameInfo(string col_name)
        {
            BasicSetting basicSetting = this.OwnerWindow.OcBasicSetting.Where<BasicSetting>((Func<BasicSetting, bool>)(d => d.CODE == "MetaConnectionString")).FirstOrDefault<BasicSetting>();
            if (basicSetting == null)
            {
                this.OwnerWindow.ShowMsgBox("META# ConnectionString이 셋팅되지 않았습니다. Setting 탭에서 설정해주세요.", 3000);
                return (DataTable)null;
            }
            col_name = col_name.ToUpper();
            string connString = basicSetting.VALUE;
            string query = string.Format("SELECT DIC_PHY_NM COL_NAME\r\n                       , DIC_LOG_NM META_COL_NAME\r\n                    FROM UDATAWARE.STD_DIC\r\n                   WHERE DIC_PHY_NM IN ({0}) ", (object)col_name.ToUpper());
            DataTable columnNameInfo = (DataTable)null;
            try
            {
                DataSet dataSet = this.DBSvc.ExecuteQuery(connString, query);
                if (dataSet != null)
                {
                    DataTable table = dataSet.Tables[0];
                    if (table.Rows.Count > 0)
                        columnNameInfo = table;
                }
            }
            catch (Exception ex)
            {
                int num = (int)MessageBox.Show(ex.ToString());
            }
            return columnNameInfo;
        }
        
        protected string GetMetaColumnName(DataTable dt, string col_name)
        {
            if (string.IsNullOrEmpty(col_name))
                return "";
            col_name = col_name.Trim().ToUpper();
            if (col_name.IndexOf("IN_") == 0 && col_name.Length > 2)
                col_name = col_name.Substring(3);
            string metaColumnName = col_name;
            if (dt == null)
                return col_name;
            for (int index = 0; index < dt.Rows.Count; ++index)
            {
                if (dt.Rows[index]["COL_NAME"].ToString() == col_name.ToUpper())
                {
                    metaColumnName = dt.Rows[index]["META_COL_NAME"].ToString();
                    break;
                }
            }
            return metaColumnName;
        }

        protected string NVL(object str, string replace_str) => str == null ? replace_str : str.ToString();

        protected string GetQueryText(string query_id, bool is_sc_replace)
        {
            ObservableCollection<FXQUERYSTORE> observableCollection = new ObservableCollection<FXQUERYSTORE>();
            FXQUERYSTORE entity = DBSvc.CreateEntity<FXQUERYSTORE>();
            entity.QueryId = "DH.SELECT.FXQUERYSTORE.S01";
            entity.QUERY_ID = query_id;
            this.DBSvc.Param.Add((DTOBase)entity);
            this.DBSvc.Result.Add((IList)observableCollection);
            this.DBSvc.Select();
            if (observableCollection.Count == 0)
                return "";
            string queryText = observableCollection[0].QUERYTEXT;
            if (is_sc_replace)
                queryText = queryText.Replace("&gt;", ">").Replace("&lt;", "<");
            return queryText;
        }

        protected string GetDBSourceText(string obj_name)
        {
            ObservableCollection<ALL_SOURCE> observableCollection = new ObservableCollection<ALL_SOURCE>();
            StringBuilder stringBuilder = new StringBuilder();
            ALL_SOURCE entity = DBSvc.CreateEntity<ALL_SOURCE>();
            entity.QueryId = "WB.SELECT.ALL_SOURCE.S02";
            entity.NAME = obj_name;
            this.DBSvc.Param.Add((DTOBase)entity);
            this.DBSvc.Result.Add((IList)observableCollection);
            this.DBSvc.Select();
            if (observableCollection.Count == 0)
                return "";
            foreach (ALL_SOURCE allSource in (Collection<ALL_SOURCE>)observableCollection)
                stringBuilder.Append(allSource.TEXT);
            return stringBuilder.ToString();
        }

        protected string GetViewSourceText(string owner, string obj_name)
        {
            ObservableCollection<ALL_VIEWS> observableCollection = new ObservableCollection<ALL_VIEWS>();
            ALL_VIEWS entity = DBSvc.CreateEntity<ALL_VIEWS>();
            entity.QueryId = "WB.SELECT.ALL_VIEWS.S01";
            entity.NAME = obj_name;
            this.DBSvc.Param.Add((DTOBase)entity);
            this.DBSvc.Result.Add((IList)observableCollection);
            this.DBSvc.Select();
            if (observableCollection.Count == 0)
                return "";
            return string.Format("VIEW {1}.{2} ({3}) AS{0}{4}", (object)Environment.NewLine, (object)owner, (object)obj_name, (object)observableCollection[0].COL_INFO, (object)observableCollection[0].TEXT);
        }

        public string GetTempFilePath(string file_name)
        {
            string path2 = string.Format("Temp\\{0}", (object)file_name);
            string fileName = !ApplicationDeployment.IsNetworkDeployed ? Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), path2) : Path.Combine(ApplicationDeployment.CurrentDeployment.DataDirectory, path2);
            FileInfo fileInfo = new FileInfo(fileName);
            if (!Directory.Exists(fileInfo.Directory.FullName))
                Directory.CreateDirectory(fileInfo.Directory.FullName);
            return fileName;
        }

        protected string SaveTempTextFile(string file_name, string txt)
        {
            string tempFilePath = this.GetTempFilePath(file_name);           
            try
            {
                File.WriteAllText(tempFilePath, txt, Encoding.UTF8);
            }
            catch (Exception ex)
            {
                int num = (int)MessageBox.Show(ex.Message);
            }
            return tempFilePath;
        }

        protected string GetGoldenPath(string key)
        {
            BasicSetting basicSetting = this.OwnerWindow.OcBasicSetting.Where<BasicSetting>((Func<BasicSetting, bool>)(d => d.CODE == key)).FirstOrDefault<BasicSetting>();
            if (basicSetting != null)
                return basicSetting.VALUE;
            this.OwnerWindow.ShowMsgBox(key + "값이 셋팅되지 않았습니다. Setting 탭에서 설정해주세요.", 3000);
            return (string)null;
        }
        protected void StartGoldenCode(string code,string sqlName = "")
        {
            if (string.IsNullOrEmpty(code))
                return;            
            
            string goldenPath = this.GetGoldenPath("GoldenPath");
            sqlName = string.IsNullOrEmpty(sqlName) ? Path.GetRandomFileName() : sqlName;
            if (!File.Exists(goldenPath))
            {
                this.OwnerWindow.ShowMsgBox(" 경로를 확인하세요.\n\n" + goldenPath, 3000);
            }
            else
            {
                this.DEL_DBSOURCE_TXT = this.SaveTempTextFile(sqlName + ".sql", code);                
                using (Process process = new Process())
                {
                    process.StartInfo.FileName = goldenPath;
                    process.StartInfo.Arguments = "\"" + this.DEL_DBSOURCE_TXT + "\"";
                    process.Start();
                    process.Exited += new EventHandler(this.P_Exited);                    
                }
            }
        }
        protected void StartPLEditCode(string code, string sqlName = "")
        {
            if (string.IsNullOrEmpty(code))
                return;

            string plEditPath = this.GetGoldenPath("PLEditPath");
            sqlName = string.IsNullOrEmpty(sqlName) ? Path.GetRandomFileName() : sqlName;
            if (!File.Exists(plEditPath))
            {
                this.OwnerWindow.ShowMsgBox(" 경로를 확인하세요.\n\n" + plEditPath, 3000);
            }
            else
            {
                this.DEL_DBSOURCE_TXT = this.SaveTempTextFile(sqlName + ".sql", code);
                using (Process process = new Process())
                {
                    process.StartInfo.FileName = plEditPath;
                    process.StartInfo.Arguments = "\"" + this.DEL_DBSOURCE_TXT + "\"";
                    process.Start();
                    process.Exited += new EventHandler(this.P_Exited);
                }
            }
        }
        private void P_Exited(object sender, EventArgs e)
        {
            if (!File.Exists(this.DEL_DBSOURCE_TXT))
                return;
            File.Delete(this.DEL_DBSOURCE_TXT);
        }
        protected void DataGridScrollAndFocus(DataGrid dgd, int col_index)
        {
            if (dgd == null || col_index < 0)
                return;
            dgd.Focus();
            dgd.Dispatcher.BeginInvoke(DispatcherPriority.Input, (Delegate)(() =>
            {
                if (dgd.SelectedItem == null)
                    return;
                dgd.ScrollIntoView(dgd.SelectedItem, (DataGridColumn)null);
                dgd.Dispatcher.BeginInvoke(DispatcherPriority.Input, (Delegate)(() =>
                {
                    DataGridCellInfo dataGridCellInfo = new DataGridCellInfo(dgd.SelectedItem, dgd.Columns[col_index]);
                    FrameworkElement cellContent = dataGridCellInfo.Column.GetCellContent(dataGridCellInfo.Item);
                    if (cellContent == null)
                        return;
                    DataGridCell parent = (DataGridCell)cellContent.Parent;
                    if (parent != null)
                    {
                        parent.IsSelected = true;
                        parent.Focus();
                        dgd.BeginEdit();
                    }
                }));
            }));
        }

        public T FindChild<T>(DependencyObject parent, string childName) where T : DependencyObject
        {
            if (parent == null)
                return default(T);
            T child1 = default(T);
            int childrenCount = VisualTreeHelper.GetChildrenCount(parent);
            for (int childIndex = 0; childIndex < childrenCount; ++childIndex)
            {
                DependencyObject child2 = VisualTreeHelper.GetChild(parent, childIndex);
                if ((object)(child2 as T) == null)
                {
                    child1 = this.FindChild<T>(child2, childName);
                    if ((object)child1 != null)
                        break;
                }
                else if (!string.IsNullOrEmpty(childName))
                {
                    if (child2 is FrameworkElement frameworkElement && frameworkElement.Name == childName)
                    {
                        child1 = (T)child2;
                        break;
                    }
                }
                else
                {
                    child1 = (T)child2;
                    break;
                }
            }
            return child1;
        }
        protected void OpenCodeWIndow(string code)
        {
            using (CodeWindow codeWindow = new CodeWindow())
            {
                codeWindow.Owner = this.Parent as Window;                
                codeWindow.WindowStartupLocation = WindowStartupLocation.CenterScreen;
                codeWindow.Show();
                codeWindow.txtCode.Text = code;
            }
        }

        protected string ConvertBindingFormat(string code) => string.IsNullOrEmpty(code) ? "" : code.Replace("[", "{").Replace("]", "}");


    }
}
