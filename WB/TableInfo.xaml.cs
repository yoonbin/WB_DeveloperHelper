using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Deployment.Application;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Threading;
using System.Xml.Serialization;
using WB.Common;
using WB.DTO;
using WB.Interface;
using WB.UC;

namespace WB
{
    /// <summary>
    /// TableInfo.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class TableInfo : UCBase
    {
        private ViewModelBase model;
        private CollectionView view;
        private CollectionView viewDetail;
        private CollectionView viewIndex;
        private CollectionView viewFav;
        private CollectionView viewRef;
        public bool IsSelectWithStart = false;
        private DispatcherTimer timer;
        private string BR = Environment.NewLine;
        private string SUMMARY = string.Format("{0}{0}/// <summary>{1}{0}{0}/// #TITLE#{1}{0}{0}/// </summary>", (object)"    ", (object)Environment.NewLine);
        public TableInfo()
        {
            InitializeComponent();
            this.model = this.DataContext as ViewModelBase;                        
        }
        MetaDL dac = new MetaDL();       

        private void btnSearch_Click(object sender, RoutedEventArgs e)
        {
            Search();
        }        

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            txtSearch.Focus();
            if (this.IsSelectWithStart)
            {
                if (!this.OwnerWindow.IsSettingCompleted)
                    return;
                //this.Search();
                this.IsSelectWithStart = false;
            }
            //this.Loaded -= new RoutedEventHandler(this.UserControl_Loaded);

            string file_path = this.model.GetUserInfoPath();


            if (!File.Exists(file_path)) return;

            XmlSerializer xs = new XmlSerializer(typeof(UserInfo_INOUT));

            using (StreamReader rd = new StreamReader(file_path))
            {
                this.model.USERINFO = xs.Deserialize(rd) as UserInfo_INOUT;
            }
            this.model.CHK_CELL_UNIT = this.model.USERINFO.CHK_CELL_UNIT == "Y" ? true : false;
            this.model.CHK_SC_STOP = this.model.USERINFO.CHK_SC_STOP == "Y" ? true : false;

            if(this.model.USERINFO.FAV_TABLE.Count > 0)
            {
                this.viewFav = (CollectionView)CollectionViewSource.GetDefaultView(this.model.USERINFO.FAV_TABLE);
                this.viewFav.Filter = new Predicate<object>(this.UserFilterFav);
                this.viewFav.GroupDescriptions.Clear(); //GROUP
                this.viewFav.GroupDescriptions.Add(new PropertyGroupDescription("GROUP"));  //GROUP
            }            
        }
        public string GetUserInfoPath() => !ApplicationDeployment.IsNetworkDeployed ? string.Format(".\\UserInfo.xml") : System.IO.Path.Combine(ApplicationDeployment.CurrentDeployment.DataDirectory, string.Format("UserInfo.xml"));
        private void Search()
        {
            //if (OwnerWindow.OcDB1User == null && OwnerWindow.OcDB2User == null) return;
            //if (OwnerWindow.OcDB1User.Count == 0 && OwnerWindow.OcDB2User.Count == 0) return;
            if (this.model.ALLTABLEGRID != null)
                this.model.ALLTABLEGRID.Clear();

            TableInfo_INOUT inObj = new TableInfo_INOUT();
            if (this.model.ALL_CHECK)
                this.model.ALLTABLEGRID = dac.GetAllTableList(inObj);
            else
                this.model.ALLTABLEGRID = dac.GetAllTableList2(inObj);
            if (this.model.ALLTABLEGRID != null)
            {
                this.view = (CollectionView)CollectionViewSource.GetDefaultView(this.model.ALLTABLEGRID);
                this.view.Filter = new Predicate<object>(this.UserFilter);
            }
        }

        private void dgrdAllTab_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            this.model.SEARCH_TEXT_DETAIL = string.Empty;
            this.model.SEARCH_TEXT_INDEX = string.Empty;
            if (this.model.TABLEGRID_IN is null) return;            
            this.model.TABLEGRID.Clear();
            this.model.TABLEGRID = dac.GetTableList(this.model.TABLEGRID_IN);
            if (this.model.TABLEGRID != null && this.model.TABLEGRID.Count() > 0)
            {
                this.viewDetail = (CollectionView)CollectionViewSource.GetDefaultView(this.model.TABLEGRID);
                this.viewDetail.Filter = new Predicate<object>(this.UserFilterDetail);
            }

            this.model.INDEXTABLE_LIST = dac.SelectTableIndex (this.model.TABLEGRID_IN);
            if (this.model.INDEXTABLE_LIST != null && this.model.INDEXTABLE_LIST.Count() > 0)
            {
                this.viewIndex = (CollectionView)CollectionViewSource.GetDefaultView(this.model.INDEXTABLE_LIST);
                this.viewIndex.Filter = new Predicate<object>(this.UserFilterIndex);
            }

            this.model.TABLEREFOBJECT_LIST = dac.SelectTableRefObj(this.model.TABLEGRID_IN);
            if (this.model.TABLEREFOBJECT_LIST != null && this.model.TABLEREFOBJECT_LIST.Count() > 0)
            {
                this.viewRef = (CollectionView)CollectionViewSource.GetDefaultView(this.model.TABLEREFOBJECT_LIST);
                this.viewRef.Filter = new Predicate<object>(this.UserFilterRef);
            }
        }

        private bool UserFilter(object item)
        {
            TableInfo_INOUT table = item as TableInfo_INOUT;
            bool flag = false;
            if (string.IsNullOrEmpty(this.model.SEARCH_TEXT))
                return true;
            string text = this.model.SEARCH_TEXT.Trim();
            string tableNm = table.TABLE_NAME ?? "";
            string tableCm = table.TABLE_COMMENTS ?? "";
            char[] chArray = new char[1] { ',' };
            foreach (string str in text.Split(chArray))
            {
                if (!string.IsNullOrEmpty(str))
                {
                    flag = tableNm.IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0;                    
                    if (!flag)
                    { 
                        flag = tableCm.IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0; 
                    }                    
                    return flag;
                }
            }
            return flag;
        }
        private bool UserFilterFav(object item)
        {
            TableInfo_INOUT table = item as TableInfo_INOUT;
            bool flag = false;
            if (string.IsNullOrEmpty(this.model.SEARCH_FAV_TEXT))
                return true;
            string text = this.model.SEARCH_FAV_TEXT.Trim();
            string tableNm = table.TABLE_NAME ?? "";
            string tableCm = table.TABLE_COMMENTS ?? "";
            string tableGroup = table.GROUP ?? "";
            char[] chArray = new char[1] { ',' };
            foreach (string str in text.Split(chArray))
            {
                if (!string.IsNullOrEmpty(str))
                {
                    if (tableNm.IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0 || tableCm.IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0
                        || tableGroup.IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0)
                        flag = true;
                    else
                        flag = false;                    
                    return flag;
                }
            }
            return flag;
        }
        private bool UserFilterRef(object item)
        {
            TableInfo_INOUT obj = item as TableInfo_INOUT;
            bool flag = false;
            if (string.IsNullOrEmpty(this.model.SEARCH_REF_OBJ))
                return true;
            string text = this.model.SEARCH_REF_OBJ.Trim();
            if (obj.OWNER.IndexOf(text) >= 0 || obj.OBJ_NAME.IndexOf(text) >= 0 || obj.OBJ_TYPE.IndexOf(text) >= 0 || obj.STATUS.IndexOf(text) >= 0)
                flag = true;
            return flag;
        }
        private bool UserFilterDetail(object item)
        {
            TableInfo_INOUT table = item as TableInfo_INOUT;
            bool flag = false;
            if (string.IsNullOrEmpty(this.model.SEARCH_TEXT_DETAIL))
                return true;
            string text = this.model.SEARCH_TEXT_DETAIL;
            string colNm = table.COLUMN_NAME ?? "";
            string comment= table.COMMENTS ?? "";
            char[] chArray = new char[1] { ',' };
            foreach (string str in text.Split(chArray))
            {
                if (!string.IsNullOrEmpty(str))
                {
                    flag = colNm.IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0;
                    if (!flag)
                    {
                        flag = comment.IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0;
                    }
                    return flag;
                }
            }
            return flag;
        }
        private bool UserFilterIndex(object item)
        {
            TableInfo_INOUT table = item as TableInfo_INOUT;
            bool flag = false;
            if (string.IsNullOrEmpty(this.model.SEARCH_TEXT_INDEX))
                return true;
            string text = this.model.SEARCH_TEXT_INDEX;
            string colNm = table.COLUMN ?? "";
            decimal col_posi = table.COLUMN_POSITION;

            if (this.model.FSR_SEQ_YN)
            {
                flag = colNm.IndexOf(text) >= 0 && col_posi == 1;
            }
            else
            {
                string indexName = string.Empty;
                foreach (var idx_nm in this.model.INDEXTABLE_LIST.Where(d => d.COLUMN.IndexOf(text) >= 0))
                {
                    indexName = indexName + ',' + idx_nm.INDEX_NAME;
                }
                if(indexName.Length > 0)
                    indexName = indexName.Substring(1);
                var indexArray = indexName.Split(',');
                foreach (string indexChar in indexArray)
                {
                    if (!string.IsNullOrEmpty(indexChar))
                    {
                        flag = table.INDEX_NAME.Equals(indexChar);
                        if (flag)
                            return flag;
                    }
                }
            }

            return flag;
        }
        private void txtSearch_TextChanged(object sender, TextChangedEventArgs e)
        {
            BindingExpression bindingExpression = ((TextBox)sender).GetBindingExpression(TextBox.TextProperty);
            bindingExpression.UpdateSource();
            if (view != null)
                view.Refresh();
        }

        public string GetCommonGroupCode(string col_name)
        {                                   
            string query = string.Format("SELECT CD_VAL COMN_GRP_CD\n                    FROM STD_CODE\n                   WHERE CD_ENG_NM = '{0}' \n AND SYSDATE BETWEEN TO_DATE(AVAL_ST_DT,'YYYYMMDDHH24MISS') AND TO_DATE(AVAL_END_DT,'YYYYMMDDHH24MISS')", (object)col_name);
            try
            {
                if (!model.USERINFO.EXCN_META)
                {
                    DataTable table = dac.ExecuteQuery(this.MetaConnection.VALUE, query).Tables[0];
                    return table.Rows.Count == 0 ? "" : table.Rows[0]["COMN_GRP_CD"].ToString();
                }
            }
            catch(Exception ex)
            {
                this.OwnerWindow.ShowErrorMsgBox(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요. \n 혹은 Meta정보 제외를 체크해주세요.", ex.ToString()));
            }
            return "";
        }

        private void dgrdDetailTab_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (this.model.TABLEGRID_SEL is null) return;
            
            TableInfo_INOUT inObj = new TableInfo_INOUT();
            inObj.COMN_GRP_CD = GetCommonGroupCode(this.model.TABLEGRID_SEL.COLUMN_NAME);
            this.model.COMNCD_LIST = dac.SelectComnCd(inObj);
        }

        private void txtSearchDetail_TextChanged(object sender, TextChangedEventArgs e)
        {
            BindingExpression bindingExpression = ((TextBox)sender).GetBindingExpression(TextBox.TextProperty);
            bindingExpression.UpdateSource();

            if (timer == null)
            {
                timer = new DispatcherTimer();
                timer.Interval = TimeSpan.FromMilliseconds(300);
                timer.Tick += new EventHandler(handleTypingTimerTimeout);
            }
            timer.Stop();
            timer.Tag = (sender as TextBox).Text;
            timer.Start();      
        }
        private void handleTypingTimerTimeout(object sender, EventArgs e)
        {
            var timer = sender as DispatcherTimer; // WPF
            if (timer == null)
            {
                return;
            }
            //work
            this.model.RefreshView(this.viewDetail);            
            // The timer must be stopped! We want to act only once per keystroke.
            timer.Stop();
        }
        private void txtSearchIndex_TextChanged(object sender, TextChangedEventArgs e)
        {
            try
            {
                BindingExpression bindingExpression = ((TextBox)sender).GetBindingExpression(TextBox.TextProperty);
                bindingExpression.UpdateSource();
                if (viewIndex != null)
                    viewIndex.Refresh();
            }
            catch
            {

            }
        }

        private void CheckBox_Checked(object sender, RoutedEventArgs e)
        {
            if(viewIndex != null)
                viewIndex.Refresh();
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Qeury_Select_Click(object sender, RoutedEventArgs e)
        {
            MenuItem parent = (MenuItem)sender;
            string str0 = "";
            string str1 = "";            
            if (!string.IsNullOrEmpty(this.model.ALIAS))
                str1 = this.model.ALIAS.Trim().ToUpper();
            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault();
            if (selectedItems == null || selectedItem == null)
                return;
            string str2 = "SELECT /* HIS.EQSID */" + BR;
            int num = 0;
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                ++num;
                str2 += "     ";
                str2 = num != 1 ? str2 + ", " : str2 + "  ";
                string txt = this.CheckCol(colInfo, str1);
                str2 = str2 + txt + this.GetBlank(txt,53) + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME, 30) + " /*" + colInfo.COMMENTS + "*/" + BR;
            }
            str0 = this.model.EXEC_CHECK ? GetPkExecParam() + BR : str0;
            this.OpenCodeWIndow(str0 + str2 + "  FROM " + selectedItem.TABLE_NAME + " " + str1 + BR + " WHERE " + this.GetPkCol(str1));
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void PLSQL_Select_Click(object sender, RoutedEventArgs e)
        {
            MenuItem parent = (MenuItem)sender;
            
            string str0 = ""; //SUMMARY
            string str1 = ""; //ALIAS
            string str2 = ""; //BEGIN SELECT QUERY 
            string str3 = ""; // EXCEPTION END            
            if (!string.IsNullOrEmpty(this.model.ALIAS))
                str1 = this.model.ALIAS.Trim().ToUpper();

            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault();

            if (selectedItems == null || selectedItem == null)  return;
            //변수생성 
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                                
                str0 += "V_" + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME, 25) + colInfo.TABLE_NAME + "." + colInfo.COLUMN_NAME + "%TYPE :='';" + BR;
            }

            //SUMMARY
            str0 += WBCommon.PLSQL_SUMMARY + BR;
            //BEGIN
            str0 += "BEGIN" + WBCommon.BR; 
            //SELECT INTO QUERY
            str2 = WBCommon.TAB + "SELECT /* HIS.EQSID */" + BR;
            int num = 0;            
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                ++num;
                str2 += WBCommon.TAB + "     ";
                str2 = num != 1 ? str2 + ", " : str2 + "  ";
                string txt = this.CheckCol(colInfo, str1);
                str2 = str2 + txt + this.GetBlank(txt) + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME, 30) + " /*" + colInfo.COMMENTS + "*/" + BR;
            }
            str2 += WBCommon.TAB + "  INTO";
            num = 0;
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                ++num;
                str2 = num != 1 ? str2 + (WBCommon.TAB + WBCommon.TAB) : str2;
                str2 = num != 1 ? str2 + " , " : str2 + " ";                
                str2 = str2 + "V_" + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME, 78) + " /*" + colInfo.COMMENTS + "*/" + BR;
            }            
            //EXCEPTION
            str3 += WBCommon.TAB + WBCommon.TAB + ";" + WBCommon.BR + "EXCEPTION" + WBCommon.BR;
            str3 += WBCommon.TAB + "WHEN NO_DATA_FOUND THEN" + WBCommon.BR;
            str3 += WBCommon.TAB + WBCommon.TAB + "RAISE_APPLICATION_ERROR(-20001,SQLERRM);" + WBCommon.BR;
            str3 += WBCommon.TAB + "WHEN OTHERS THEN" + WBCommon.BR;
            str3 += WBCommon.TAB + WBCommon.TAB + "RAISE_APPLICATION_ERROR(-20002,SQLERRM);" + WBCommon.BR;
            str3 += "END;";

            this.OpenCodeWIndow(str0 + str2 + WBCommon.TAB + "  FROM " + selectedItem.TABLE_NAME + " " + str1 + BR + WBCommon.TAB + " WHERE " + this.GetPkCol(str1,WBCommon.TAB,"") + str3);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Qeury_Insert_Click(object sender, RoutedEventArgs e)
        {
            IList<TableInfo_INOUT> selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT notNullItem in dgrdDetailTab.Items)
            {
                if (notNullItem.NULLABLE.IndexOf("NOT NULL", StringComparison.OrdinalIgnoreCase) > -1)
                    selectedItems.Add(notNullItem);
            }
            IEnumerable sortedSelectedItems = selectedItems.Distinct().OrderBy(d => d.SEQ);


            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault(); 
            if (selectedItems == null || selectedItem == null) return;

            string str0 = "";
            string str1 = "INSERT /* HIS.EQSID */" + BR + "       INTO " + selectedItem.TABLE_NAME + BR + "     (" + BR;
            string str2 = "";
            string str3 = "";
            string inParameter = "";
            int num = 0;
            foreach (TableInfo_INOUT colInfo in sortedSelectedItems)
            {
                inParameter = this.GetInParameter(colInfo);
                ++num;
                str2 += "     ";
                str3 += "     ";
                if (num == 1)
                {
                    str2 += "  ";
                    str3 += "  ";
                }
                else
                {
                    str2 += ", ";
                    str3 += ", ";
                }
                str2 = str2 + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " /*" + colInfo.COMMENTS + "*/" + BR;
                str3 = str3 + inParameter + BR;
                if (inParameter != "SYSDATE" && str0.IndexOf(GetExecParm(inParameter)) < 0)
                    str0 = str0 + GetExecParm(inParameter);
            }
            str0 = this.model.EXEC_CHECK ? str0 + BR : "";
            this.OpenCodeWIndow(str0 + str1 + str2 + "     )" + BR + "VALUES" + BR + "     (" + BR + str3 + "     )" + BR);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Qeury_InsertV2_Click(object sender, RoutedEventArgs e)
        {
            IList<TableInfo_INOUT> selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT notNullItem in dgrdDetailTab.Items)
            {
                if (notNullItem.NULLABLE.IndexOf("NOT NULL", StringComparison.OrdinalIgnoreCase) > -1)
                    selectedItems.Add(notNullItem);
            }
            IEnumerable sortedSelectedItems = selectedItems.Distinct().OrderBy(d => d.SEQ);

            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault();
            if (selectedItems == null || selectedItem == null) return;

            string str0 = "";
            string str1 = "INSERT /* HIS.EQSID */" + BR + "       INTO " + selectedItem.TABLE_NAME + BR + "     (" + BR;
            string str2 = "";
            string str3 = "";
            string inParameter = "";
            int num = 0;
            foreach (TableInfo_INOUT colInfo in sortedSelectedItems)
            {
                inParameter = Regex.Replace(this.GetInParameter(colInfo),@"IN_",string.Empty);
                ++num;
                str2 += "     ";
                str3 += "     ";
                if (num == 1)
                {
                    str2 += "  ";
                    str3 += "  ";
                }
                else
                {
                    str2 += ", ";
                    str3 += ", ";
                }
                str2 = str2 + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " /*" + colInfo.COMMENTS + "*/" + BR;
                str3 = str3 + inParameter + BR;
                if (inParameter != "SYSDATE" && str0.IndexOf(GetExecParm(inParameter)) < 0)
                    str0 = str0 + GetExecParm(inParameter);
            }
            str0 = this.model.EXEC_CHECK ? str0 + BR : "";
            this.OpenCodeWIndow(str0 + str1 + str2 + "     )" + BR + "VALUES" + BR + "     (" + BR + str3 + "     )" + BR);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Qeury_InsertSelect_Click(object sender, RoutedEventArgs e)
        {
            IList<TableInfo_INOUT> selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT notNullItem in dgrdDetailTab.Items)
            {
                if (notNullItem.NULLABLE.IndexOf("NOT NULL", StringComparison.OrdinalIgnoreCase) > -1)
                    selectedItems.Add(notNullItem);
            }
            IEnumerable sortedSelectedItems = selectedItems.Distinct().OrderBy(d => d.SEQ);
            
            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault();

            if (selectedItems == null || selectedItem == null) return;

            string str0 = "";
            string str1 = "INSERT /* HIS.EQSID */" + BR + "       INTO " + selectedItem.TABLE_NAME + BR + "     (" + BR;
            string str2 = "";
            string str3 = "";
            string inParameter = "";
            int num = 0;            
            foreach (TableInfo_INOUT colInfo in sortedSelectedItems)
            {
                inParameter = Regex.Replace(this.GetInParameter(colInfo), @"IN_", string.Empty);
                ++num;
                str2 += "     ";
               
                if (num == 1)
                {
                    str2 += "  ";
                    str3 += " ";
                }
                else
                {
                    str2 += ", ";
                    str3 += "     , ";
                }                
                str2 = str2 + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " /*" + colInfo.COMMENTS + "*/" + BR;
                str3 += colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME, 50) + " /*" + colInfo.COMMENTS + "*/" + BR;
                //if (inParameter != "SYSDATE" && str0.IndexOf(GetExecParm(inParameter)) < 0)
                //    str0 = str0 + GetExecParm(inParameter);
            }

            str3 += "  FROM " + selectedItem.TABLE_NAME + " " + BR + " WHERE " + this.GetPkCol();            
            str0 = this.model.EXEC_CHECK ? GetPkExecParam() + BR : str0;
            this.OpenCodeWIndow(str0 + str1 + str2 + "     )" + BR + "SELECT" + str3 );
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void PLSQL_Insert_Click(object sender, RoutedEventArgs e)
        {
            IList<TableInfo_INOUT> selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT notNullItem in dgrdDetailTab.Items)
            {
                if (notNullItem.NULLABLE.IndexOf("NOT NULL", StringComparison.OrdinalIgnoreCase) > -1)
                    selectedItems.Add(notNullItem);
            }
            IEnumerable sortedSelectedItems = selectedItems.Distinct().OrderBy(d => d.SEQ);

            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault();

            if (selectedItems == null || selectedItem == null) return;

            string str0 = ""; //변수 + 주석 + BEGIN
            string str1 = WBCommon.TAB + "INSERT INTO " + selectedItem.TABLE_NAME + BR + WBCommon.TAB + "     (" + BR;
            string str2 = ""; //SELECT QUERY 
            string str3 = ""; // EXCEPTION END
            string str4 = "";             
            ////변수생성 
            //foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            //{

            //    str0 += "V_" + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME, 25) + colInfo.TABLE_NAME + "." + colInfo.COLUMN_NAME + "%TYPE :='';" + BR;
            //}

            //SUMMARY
            str0 += WBCommon.PLSQL_SUMMARY + BR;
            //BEGIN
            str0 += "BEGIN" + WBCommon.BR;
            //INSERT INTO QUERY
            string inParameter = "";
            int num = 0;
            foreach (TableInfo_INOUT colInfo in sortedSelectedItems)
            {
                inParameter = this.GetInParameter(colInfo,"");
                ++num;
                str2 += WBCommon.TAB + "     ";
                str3 += WBCommon.TAB + "     ";
                if (num == 1)
                {
                    str2 += "  ";
                    str3 += "  ";
                }
                else
                {
                    str2 += ", ";
                    str3 += ", ";
                }
                str2 += colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " /*" + colInfo.COMMENTS + "*/" + BR;
                str3 += inParameter + this.GetBlank(inParameter) + " /*" + colInfo.COMMENTS + "*/" + BR;                
            }
            //EXCEPTION
            str4 += WBCommon.TAB + WBCommon.TAB + ";" + WBCommon.BR + "EXCEPTION" + WBCommon.BR;
            str4 += WBCommon.TAB + "WHEN DUP_VAL_ON_INDEX THEN" + WBCommon.BR;
            str4 += WBCommon.TAB + WBCommon.TAB + "RAISE_APPLICATION_ERROR(-20001,SQLERRM);" + WBCommon.BR;
            str4 += WBCommon.TAB + "WHEN OTHERS THEN" + WBCommon.BR;
            str4 += WBCommon.TAB + WBCommon.TAB + "RAISE_APPLICATION_ERROR(-20002,SQLERRM);" + WBCommon.BR;
            str4 += "END;" + WBCommon.BR;
            str4 += "IF SQL%ROWCOUNT = 0 THEN" + WBCommon.BR;
            str4 += WBCommon.TAB + "NULL;" + WBCommon.BR;
            str4 += "END IF;";

            this.OpenCodeWIndow(str0 + str1 + str2 + WBCommon.TAB + "     )" + BR + WBCommon.TAB + "VALUES" + BR + WBCommon.TAB + "     (" + BR + str3 + WBCommon.TAB + "     )" + BR + str4);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Qeury_Update_Click(object sender, RoutedEventArgs e)
        {
            IList<TableInfo_INOUT> selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT tableInfo in dgrdDetailTab.Items)
            {
                if (tableInfo.COLUMN_NAME.IndexOf("LSH_DTM",StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_STF_NO", StringComparison.OrdinalIgnoreCase) == 0
                    || tableInfo.COLUMN_NAME.IndexOf("LSH_PRGM_NM", StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_IP_ADDR", StringComparison.OrdinalIgnoreCase) == 0)
                    selectedItems.Add(tableInfo);
            }
            IEnumerable sortedSelectedItems = selectedItems.Distinct().OrderBy(d => d.SEQ);

            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault();
            if (selectedItems == null || selectedItem == null)
                return;
            string str0 = GetPkExecParam();
            string str = "UPDATE /* HIS.EQSID */" + BR + "       " + selectedItem.TABLE_NAME + BR;
            int num = 0;
            foreach (TableInfo_INOUT colInfo in sortedSelectedItems)
            {
                ++num;
                if (num == 1)
                {
                    str += "   ";
                    str += "SET ";
                }
                else
                {
                    str += "     ";
                    str += ", ";
                }
                string inParameter = this.GetInParameter(colInfo);
                str = str + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " = " + inParameter + this.GetBlank(inParameter) + " /*" + colInfo.COMMENTS + "*/" + BR;
                if (inParameter != "SYSDATE" && str0.IndexOf(GetExecParm(inParameter)) < 0)
                    str0 = str0 + GetExecParm(inParameter);
            }
            str0 = this.model.EXEC_CHECK ? str0 + BR : "";
            this.OpenCodeWIndow(str0 + str + " WHERE " + this.GetPkCol());
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Qeury_UpdateV2_Click(object sender, RoutedEventArgs e)
        {
            IList<TableInfo_INOUT> selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT tableInfo in dgrdDetailTab.Items)
            {
                if (tableInfo.COLUMN_NAME.IndexOf("LSH_DTM", StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_STF_NO", StringComparison.OrdinalIgnoreCase) == 0
                    || tableInfo.COLUMN_NAME.IndexOf("LSH_PRGM_NM", StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_IP_ADDR", StringComparison.OrdinalIgnoreCase) == 0)
                    selectedItems.Add(tableInfo);
            }
            IEnumerable sortedSelectedItems = selectedItems.Distinct().OrderBy(d => d.SEQ);

            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault();
            if (selectedItems == null || selectedItem == null)
                return;
            string str0 = GetPkExecParam();
            string str = "UPDATE /* HIS.EQSID */" + BR + "       " + selectedItem.TABLE_NAME + BR;
            int num = 0;
            foreach (TableInfo_INOUT colInfo in sortedSelectedItems)
            {
                ++num;
                if (num == 1)
                {
                    str += "   ";
                    str += "SET ";
                }
                else
                {
                    str += "     ";
                    str += ", ";
                }
                string inParameter = this.GetInParameter(colInfo);
                inParameter = Regex.Replace(this.GetInParameter(colInfo), @"IN_", string.Empty);
                str = str + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " = " + inParameter + this.GetBlank(inParameter) + " /*" + colInfo.COMMENTS + "*/" + BR;
                if (inParameter != "SYSDATE" && str0.IndexOf(GetExecParm(inParameter)) < 0)
                    str0 = str0 + GetExecParm(inParameter);
            }
            str0 = this.model.EXEC_CHECK ? str0 + BR : "";
            this.OpenCodeWIndow(str0 + str + " WHERE " + this.GetPkCol());
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void PLSQL_Update_Click(object sender, RoutedEventArgs e)
        {
            IList<TableInfo_INOUT> selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT tableInfo in dgrdDetailTab.Items)
            {
                if (tableInfo.COLUMN_NAME.IndexOf("LSH_DTM", StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_STF_NO", StringComparison.OrdinalIgnoreCase) == 0
                    || tableInfo.COLUMN_NAME.IndexOf("LSH_PRGM_NM", StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_IP_ADDR", StringComparison.OrdinalIgnoreCase) == 0)
                    selectedItems.Add(tableInfo);
            }
            IEnumerable sortedSelectedItems = selectedItems.Distinct().OrderBy(d => d.SEQ);

            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault();
            if (selectedItems == null || selectedItem == null)
                return;
            string str0 = "";
            //SUMMARY
            str0 += WBCommon.PLSQL_SUMMARY + BR;
            //BEGIN
            str0 += "BEGIN" + WBCommon.BR;

            string str = WBCommon.TAB + "UPDATE " + selectedItem.TABLE_NAME + BR;
            
            string str2 = "";
            
            int num = 0;
            foreach (TableInfo_INOUT colInfo in sortedSelectedItems)
            {
                ++num;
                if (num == 1)
                {
                    str += WBCommon.TAB + "   ";
                    str += "SET ";
                }
                else
                {
                    str += WBCommon.TAB + "     ";
                    str += ", ";
                }
                string inParameter = this.GetInParameter(colInfo,"");
                str += colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " = " + inParameter + this.GetBlank(inParameter) + " /*" + colInfo.COMMENTS + "*/" + BR;             
            }

            //EXCEPTION
            str2 += WBCommon.TAB + WBCommon.TAB + ";" + WBCommon.BR + "EXCEPTION" + WBCommon.BR;            
            str2 += WBCommon.TAB + "WHEN OTHERS THEN" + WBCommon.BR;
            str2 += WBCommon.TAB + WBCommon.TAB + "RAISE_APPLICATION_ERROR(-20001,SQLERRM);" + WBCommon.BR;
            str2 += "END;" + WBCommon.BR;
            str2 += "IF SQL%ROWCOUNT = 0 THEN" + WBCommon.BR;
            str2 += WBCommon.TAB + "NULL;" + WBCommon.BR;
            str2 += "END IF;";
            this.OpenCodeWIndow(str0 + str + WBCommon.TAB +" WHERE " + this.GetPkCol("", WBCommon.TAB,"") + str2);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Qeury_Merge_Click(object sender, RoutedEventArgs e)
        {
            //선택한 Item.
            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            //UPDATE 할 Item
            IList<TableInfo_INOUT> updateItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT tableInfo in dgrdDetailTab.Items)
            {
                if (tableInfo.COLUMN_NAME.IndexOf("LSH_DTM", StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_STF_NO", StringComparison.OrdinalIgnoreCase) == 0
                    || tableInfo.COLUMN_NAME.IndexOf("LSH_PRGM_NM", StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_IP_ADDR", StringComparison.OrdinalIgnoreCase) == 0)
                    updateItems.Add(tableInfo);
            }
            IEnumerable sortedUpdateItems = updateItems.Distinct().OrderBy(d => d.SEQ);

            //INSERT 할 Item
            IList<TableInfo_INOUT> insertItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT notNullItem in dgrdDetailTab.Items)
            {
                if (notNullItem.NULLABLE.IndexOf("NOT NULL", StringComparison.OrdinalIgnoreCase) > -1)
                    insertItems.Add(notNullItem);
            }
            IEnumerable sortedInsertItems = insertItems.Distinct().OrderBy(d => d.SEQ);

            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault();
            if (selectedItems == null || selectedItem == null)
                return;
            string str0 = GetPkExecParam();
            string str1 = "MERGE /* HIS.EQSID */ " + BR + "      INTO " + selectedItem.TABLE_NAME + BR + "USING DUAL" + 
                          BR + "ON (" + BR + "       " + this.GetPkCol() + BR + "   ) " 
                          + BR + "WHEN MATCHED THEN" + BR + "UPDATE" + BR;
            int num1 = 0;
            foreach (TableInfo_INOUT colInfo in sortedUpdateItems)
            {
                if (!this.IsPkCol(colInfo.COLUMN_NAME))
                {
                    ++num1;
                    if (num1 == 1)
                    {
                        str1 += "   ";
                        str1 += "SET ";
                    }
                    else
                    {
                        str1 += "     ";
                        str1 += ", ";
                    }
                    string inParameter = this.GetInParameter(colInfo);
                    str1 = str1 + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " = " + inParameter + this.GetBlank(inParameter) + " /*" + colInfo.COMMENTS + "*/" + BR;
                    if(inParameter != "SYSDATE" && str0.IndexOf(GetExecParm(inParameter)) < 0)
                        str0 = str0 + GetExecParm(inParameter);
                }
            }            
            string str2 = str1 + "WHEN NOT MATCHED THEN" + BR + "INSERT" + BR + "     (" + BR;
            string str3 = "";
            string str4 = "";
            int num2 = 0;
            foreach (TableInfo_INOUT colInfo in sortedInsertItems)
            {
                ++num2;
                str3 += "     ";
                str4 += "     ";
                if (num2 == 1)
                {
                    str3 += "  ";
                    str4 += "  ";
                }
                else
                {
                    str3 += ", ";
                    str4 += ", ";
                }
                str3 = str3 + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " /*" + colInfo.COMMENTS + "*/" + BR;
                string inParameter = this.GetInParameter(colInfo);
                str4 = str4 + inParameter + BR;
            }
            str0 = this.model.EXEC_CHECK ? str0 + BR : "";
            this.OpenCodeWIndow(str0 + str2 + str3 + "     )" + BR + "VALUES" + BR + "     (" + BR + str4 + "     )" + BR);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void PLSQL_Merge_Click(object sender, RoutedEventArgs e)
        {
            //선택한 Item.
            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            //UPDATE 할 Item
            IList<TableInfo_INOUT> updateItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT tableInfo in dgrdDetailTab.Items)
            {
                if (tableInfo.COLUMN_NAME.IndexOf("LSH_DTM", StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_STF_NO", StringComparison.OrdinalIgnoreCase) == 0
                    || tableInfo.COLUMN_NAME.IndexOf("LSH_PRGM_NM", StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_IP_ADDR", StringComparison.OrdinalIgnoreCase) == 0)
                    updateItems.Add(tableInfo);
            }
            IEnumerable sortedUpdateItems = updateItems.Distinct().OrderBy(d => d.SEQ);

            //INSERT 할 Item
            IList<TableInfo_INOUT> insertItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT notNullItem in dgrdDetailTab.Items)
            {
                if (notNullItem.NULLABLE.IndexOf("NOT NULL", StringComparison.OrdinalIgnoreCase) > -1)
                    insertItems.Add(notNullItem);
            }
            IEnumerable sortedInsertItems = insertItems.Distinct().OrderBy(d => d.SEQ);

            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault();
            if (selectedItems == null || selectedItem == null) return;
            
            string str0 = "";
            //SUMMARY
            str0 += WBCommon.PLSQL_SUMMARY + BR;
            //BEGIN
            str0 += "BEGIN" + WBCommon.BR;

            string str1 = WBCommon.TAB + "MERGE INTO " + selectedItem.TABLE_NAME + BR + WBCommon.TAB + "USING DUAL" +
                          BR + WBCommon.TAB + "ON (" + BR + "       " + this.GetPkCol("","","") + WBCommon.TAB + "   ) "
                          + BR + WBCommon.TAB + "WHEN MATCHED THEN" + BR + WBCommon.TAB + "UPDATE" + BR + WBCommon.TAB;
            int num1 = 0;
            foreach (TableInfo_INOUT colInfo in sortedUpdateItems)
            {
                if (!this.IsPkCol(colInfo.COLUMN_NAME))
                {
                    ++num1;
                    if (num1 == 1)
                    {
                        str1 += "   ";
                        str1 += "SET ";
                    }
                    else
                    {
                        str1 += WBCommon.TAB + "     ";
                        str1 += ", ";
                    }
                    string inParameter = this.GetInParameter(colInfo,"");
                    str1 += colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " = " + inParameter + this.GetBlank(inParameter) + " /*" + colInfo.COMMENTS + "*/" + BR;            
                }
            }
            string str2 = str1 + WBCommon.TAB + "WHEN NOT MATCHED THEN" + BR + WBCommon.TAB + "INSERT" + BR + WBCommon.TAB + "     (" + BR;
            string str3 = "";
            string str4 = "";
            string str5 = "";
            int num2 = 0;
            foreach (TableInfo_INOUT colInfo in sortedInsertItems)
            {
                ++num2;
                str3 += WBCommon.TAB + "     ";
                str4 += WBCommon.TAB + "     ";
                if (num2 == 1)
                {
                    str3 += "  ";
                    str4 += "  ";
                }
                else
                {
                    str3 += ", ";
                    str4 += ", ";
                }
                str3 +=colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " /*" + colInfo.COMMENTS + "*/" + BR;
                string inParameter = this.GetInParameter(colInfo,"");
                str4 +=inParameter + BR;
            }            

            //EXCEPTION
            str5 += WBCommon.TAB + WBCommon.TAB + ";" + WBCommon.BR + "EXCEPTION" + WBCommon.BR;
            str5 += WBCommon.TAB + "WHEN DUP_VAL_ON_INDEX THEN" + WBCommon.BR;
            str5 += WBCommon.TAB + WBCommon.TAB + "RAISE_APPLICATION_ERROR(-20001,SQLERRM);" + WBCommon.BR;
            str5 += WBCommon.TAB + "WHEN OTHERS THEN" + WBCommon.BR;
            str5 += WBCommon.TAB + WBCommon.TAB + "RAISE_APPLICATION_ERROR(-20002,SQLERRM);" + WBCommon.BR;
            str5 += "END;" + WBCommon.BR;
            str5 += "IF SQL%ROWCOUNT = 0 THEN" + WBCommon.BR;
            str5 += WBCommon.TAB + "NULL;" + WBCommon.BR;
            str5 += "END IF;";
            this.OpenCodeWIndow(str0 + str2 + str3 + WBCommon.TAB + "     )" + BR + WBCommon.TAB + "VALUES" + BR + WBCommon.TAB + "     (" + BR + str4 + WBCommon.TAB + "     )" + BR + str5);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DTO_Property_Click(object sender, RoutedEventArgs e)
        {
            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            string code = "";
            string col_nm = "";
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                this.GetBlank(colInfo.COLUMN_NAME);
                string dataType = this.GetDataType(colInfo);
                col_nm = colInfo.COLUMN_NAME;
                if (colInfo.COMMENTS == null)
                    colInfo.COMMENTS = "";
                string txt = string.Format("{1}{1}private {2} {3};", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToLower());
                code += string.Format("{1}{1}private {2} {3};{4}{0}", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToLower(), GetBlank(txt,50) + "//" + colInfo.COMMENTS.Trim());
                code += this.SUMMARY.Replace("#TITLE#", colInfo.COMMENTS.Trim());
                code += string.Format("{0}{1}{1}[DataMember]{0}", (object)this.BR, (object)"    ");
                code += string.Format("{1}{1}public {2} {3}{0}", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToUpper());
                code += string.Format("{1}{1}{{ {0}", (object)this.BR, (object)"    ");
                code += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)this.BR, (object)"    ", (object)col_nm.ToLower());
                code += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)this.BR, (object)"    "
                                        , (object)col_nm.ToLower(), (object)col_nm.ToUpper());
                code += string.Format("{1}{1}}} {0}{0}", (object)this.BR, (object)"    ");
            }
            this.OpenCodeWIndow(code);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DTO_IN_Property_Click(object sender, RoutedEventArgs e)
        {
            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            string code = "";
            string col_nm = "";
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                this.GetBlank(colInfo.COLUMN_NAME);
                string dataType = this.GetDataType(colInfo);
                col_nm = "IN_" + colInfo.COLUMN_NAME;
                if (colInfo.COMMENTS == null)
                    colInfo.COMMENTS = "";
                string txt = string.Format("{1}{1}private {2} {3};", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToLower());
                code += string.Format("{1}{1}private {2} {3};{4}{0}", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToLower(), GetBlank(txt, 50) + "//" + colInfo.COMMENTS.Trim());
                code += this.SUMMARY.Replace("#TITLE#", colInfo.COMMENTS.Trim());
                code += string.Format("{0}{1}{1}[DataMember]{0}", (object)this.BR, (object)"    ");
                code += string.Format("{1}{1}public {2} {3}{0}", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToUpper());
                code += string.Format("{1}{1}{{ {0}", (object)this.BR, (object)"    ");
                code += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)this.BR, (object)"    ", (object)col_nm.ToLower());
                code += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)this.BR, (object)"    "
                                        , (object)col_nm.ToLower(), (object)col_nm.ToUpper());
                code += string.Format("{1}{1}}} {0}{0}", (object)this.BR, (object)"    ");
            }
            this.OpenCodeWIndow(code);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DTO_Group_Property_Click(object sender, RoutedEventArgs e)
        {
            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            string code = "";
            string col_nm = "";
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                this.GetBlank(colInfo.COLUMN_NAME);
                string dataType = this.GetDataType(colInfo);
                col_nm = colInfo.COLUMN_NAME;
                if (colInfo.COMMENTS == null)
                    colInfo.COMMENTS = "";
                string txt = string.Format("{1}{1}private {2} {3};", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToLower());
                code += string.Format("{1}{1}private {2} {3};{4}{0}", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToLower(), GetBlank(txt, 50) + "//" + colInfo.COMMENTS.Trim());                
            }
            code += WBCommon.BR;
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                this.GetBlank(colInfo.COLUMN_NAME);
                string dataType = this.GetDataType(colInfo);
                col_nm = colInfo.COLUMN_NAME;
                if (colInfo.COMMENTS == null)
                    colInfo.COMMENTS = "";                
                code += this.SUMMARY.Replace("#TITLE#", colInfo.COMMENTS.Trim());
                code += string.Format("{0}{1}{1}[DataMember]{0}", (object)this.BR, (object)"    ");
                code += string.Format("{1}{1}public {2} {3}{0}", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToUpper());
                code += string.Format("{1}{1}{{ {0}", (object)this.BR, (object)"    ");
                code += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)this.BR, (object)"    ", (object)col_nm.ToLower());
                code += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)this.BR, (object)"    "
                                        , (object)col_nm.ToLower(), (object)col_nm.ToUpper());
                code += string.Format("{1}{1}}} {0}{0}", (object)this.BR, (object)"    ");
            }
            this.OpenCodeWIndow(code);
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DTO_Group_IN_Property_Click(object sender, RoutedEventArgs e)
        {
            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            string code = "";
            string col_nm = "";
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                this.GetBlank(colInfo.COLUMN_NAME);
                string dataType = this.GetDataType(colInfo);
                col_nm = "IN_" + colInfo.COLUMN_NAME;
                if (colInfo.COMMENTS == null)
                    colInfo.COMMENTS = "";
                string txt = string.Format("{1}{1}private {2} {3};", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToLower());
                code += string.Format("{1}{1}private {2} {3};{4}{0}", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToLower(), GetBlank(txt, 50) + "//" + colInfo.COMMENTS.Trim());
            }
            code += WBCommon.BR;
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                this.GetBlank(colInfo.COLUMN_NAME);
                string dataType = this.GetDataType(colInfo);
                col_nm = "IN_" + colInfo.COLUMN_NAME;
                if (colInfo.COMMENTS == null)
                    colInfo.COMMENTS = "";
                code += this.SUMMARY.Replace("#TITLE#", colInfo.COMMENTS.Trim());
                code += string.Format("{0}{1}{1}[DataMember]{0}", (object)this.BR, (object)"    ");
                code += string.Format("{1}{1}public {2} {3}{0}", (object)this.BR, (object)"    ", (object)dataType, (object)col_nm.ToUpper());
                code += string.Format("{1}{1}{{ {0}", (object)this.BR, (object)"    ");
                code += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)this.BR, (object)"    ", (object)col_nm.ToLower());
                code += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)this.BR, (object)"    "
                                        , (object)col_nm.ToLower(), (object)col_nm.ToUpper());
                code += string.Format("{1}{1}}} {0}{0}", (object)this.BR, (object)"    ");
            }
            this.OpenCodeWIndow(code);
        }
        private string GetDataType(TableInfo_INOUT item) => item.DATA_TYPE.IndexOf("NUMBER") > -1 ? "string" : "string";

        private string GetPkCol() => this.GetPkCol("","",":");

        private string GetPkCol(string table_alias, string tab = "",string colon = ":",string preFix = "IN_")
        {
            string pkCol = "";
            try
            {
                if (!string.IsNullOrEmpty(table_alias))
                    table_alias += ".";
                foreach (TableInfo_INOUT indexInfo in (IEnumerable)this.dgrdIndexInfo.Items)
                {
                    if (indexInfo.INDEX_NAME.IndexOf("PK") > -1)
                    {
                        if (pkCol.Length > 0)
                            pkCol += tab + "   AND ";
                        string str = colon + preFix + indexInfo.COLUMN;
                        if (indexInfo.COLUMN.EndsWith("HSP_TP_CD"))
                            str = colon + "HIS_HSP_TP_CD";
                        else if (indexInfo.COLUMN.EndsWith("STF_NO"))
                            str = colon + "HIS_STF_NO";
                        if (indexInfo.COLUMN.EndsWith("DTM"))
                            pkCol = pkCol + table_alias + indexInfo.COLUMN + this.GetBlank(indexInfo.COLUMN, 30) + " = TO_DATE(" + str + ", 'YYYY-MM-DD HH24:MI:SS')" + BR;
                        else if (indexInfo.COLUMN.EndsWith("DT"))
                            pkCol = pkCol + table_alias + indexInfo.COLUMN + this.GetBlank(indexInfo.COLUMN, 30) + " = TO_DATE(" + str + ", 'YYYY-MM-DD')" + BR;
                        else
                            pkCol = pkCol + table_alias + indexInfo.COLUMN + this.GetBlank(indexInfo.COLUMN, 30) + " = " + str + BR;
                    }
                }
            }
            catch
            {
            }
            return pkCol;
        }
        
        private string GetInParameter(TableInfo_INOUT item,string colon = ":", string prefix = "IN_")
        {
            string inParameter = colon + prefix + item.COLUMN_NAME;
            if (item.COLUMN_NAME.EndsWith("HSP_TP_CD"))
                inParameter = colon + "HIS_HSP_TP_CD";
            else if (item.COLUMN_NAME.EndsWith("STF_NO"))
                inParameter = colon + "HIS_STF_NO";
            else if (item.COLUMN_NAME.EndsWith("PRGM_NM"))
                inParameter = colon + "HIS_PRGM_NM";
            else if (item.COLUMN_NAME.EndsWith("IP_ADDR"))
                inParameter = colon + "HIS_IP_ADDR";
            else if (item.COLUMN_NAME.EndsWith("DT") || item.COLUMN_NAME.EndsWith("DTM"))
                inParameter = "SYSDATE";
            return inParameter;
        }
        private string GetBlank(string txt) => this.GetBlank(txt, 50);

        private string GetBlank(string txt, int len)
        {
            int num = len - txt.Length;
            if (num < 1)
                return "";
            string blank = "";
            for (int index = 0; index < num; ++index)
                blank += " ";
            return blank;
        }

        private bool IsPkCol(string col_name)
        {            
            TableInfo_INOUT indexInfo = this.model.INDEXTABLE_LIST.Where(d => d.COLUMN == col_name).FirstOrDefault();
            return indexInfo != null && indexInfo.INDEX_NAME.IndexOf("PK") > -1;
        }

        private string GetExecParm(string col_name)
        {
            string execParm = string.Empty;           
            execParm = "EXEC " + col_name + " :='';" + BR;
            return execParm;
        }
        private string GetPkExecParam()
        {
            string execPkParam = "";
            foreach (TableInfo_INOUT indexInfo in (IEnumerable)this.dgrdIndexInfo.Items)
            {
                if (indexInfo.INDEX_NAME.IndexOf("PK") > -1)
                {
                    string str = ":IN_" + indexInfo.COLUMN;
                    if (indexInfo.COLUMN.EndsWith("HSP_TP_CD"))
                        str = ":HIS_HSP_TP_CD";
                    else if (indexInfo.COLUMN.EndsWith("STF_NO"))
                        str = ":HIS_STF_NO";                                       

                    execPkParam = execPkParam + "EXEC " + str + " :='';" + BR;
                }
            }
            return execPkParam;
        }
        private string CheckCol(TableInfo_INOUT item, string alias)
        {
            if (!string.IsNullOrEmpty(alias))
                alias += ".";
            if (item.DATA_TYPE.IndexOf("NUMBER") > -1)
                return "TO_CHAR(" + alias + item.COLUMN_NAME + ")";
            if (item.DATA_TYPE.IndexOf("DATE") <= -1)
                return alias + item.COLUMN_NAME;
            return item.COLUMN_NAME.EndsWith("DTM") ? "TO_CHAR(" + alias + item.COLUMN_NAME + ", 'YYYY-MM-DD HH24:MI:SS')" : "TO_CHAR(" + alias + item.COLUMN_NAME + ", 'YYYY-MM-DD')";
        }

        private void Column_Copy_Click(object sender, RoutedEventArgs e)
        {
            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            string code = "";            
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                code += colInfo.COLUMN_NAME + WBCommon.BR;                               
            }            
            try
            {
                Clipboard.SetText(code);
                OwnerWindow.tabMain.SelectedIndex = 1;
            }
            catch(Exception)
            {

            }
        }

        private void TextBox_GotFocus(object sender, RoutedEventArgs e)
        {
            System.Windows.Application.Current.Dispatcher.BeginInvoke((Delegate)(() =>
            {
                ((TextBox)sender).SelectAll();
            }), DispatcherPriority.Send);
        }        
        private void chkSelChg_Checked(object sender, RoutedEventArgs e)
        {
            this.dgrdAllTab.SelectionChanged -= dgrdAllTab_SelectionChanged;
            this.model.USERINFO.CHK_SC_STOP = "Y";
            this.model.SaveUserInfo();
        }

        private void chkSelChg_Unchecked(object sender, RoutedEventArgs e)
        {
            this.dgrdAllTab.SelectionChanged += dgrdAllTab_SelectionChanged;
            this.model.USERINFO.CHK_SC_STOP = "N";
            this.model.SaveUserInfo();
        }
                
        private void chkSelUnit_Checked(object sender, RoutedEventArgs e)
        {            
            this.model.UNIT = DataGridSelectionUnit.Cell;
            this.model.USERINFO.CHK_CELL_UNIT = "Y";
            this.model.SaveUserInfo();
        }

        private void chkSelUnit_Unchecked(object sender, RoutedEventArgs e)
        {
            this.model.UNIT = DataGridSelectionUnit.FullRow;
            this.model.USERINFO.CHK_CELL_UNIT = "N";
            this.model.SaveUserInfo();
        }

        private void dgrdAllTab_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {

            DataGrid dataGrid = (DataGrid)sender;
            TableInfo_INOUT inObj = dataGrid.CurrentItem as TableInfo_INOUT;
            this.model.SEARCH_TEXT_DETAIL = string.Empty;
            this.model.SEARCH_TEXT_INDEX = string.Empty;
            if (inObj is null) return;
            this.model.TABLEGRID.Clear();
            this.model.TABLEGRID = dac.GetTableList(inObj);
            if (this.model.TABLEGRID != null && this.model.TABLEGRID.Count() > 0)
            {
                this.viewDetail = (CollectionView)CollectionViewSource.GetDefaultView(this.model.TABLEGRID);
                this.viewDetail.Filter = new Predicate<object>(this.UserFilterDetail);
            }

            this.model.INDEXTABLE_LIST = dac.SelectTableIndex(inObj);
            if (this.model.INDEXTABLE_LIST != null && this.model.INDEXTABLE_LIST.Count() > 0)
            {
                this.viewIndex = (CollectionView)CollectionViewSource.GetDefaultView(this.model.INDEXTABLE_LIST);
                this.viewIndex.Filter = new Predicate<object>(this.UserFilterIndex);
            }

            this.model.TABLEREFOBJECT_LIST = dac.SelectTableRefObj(inObj);
            if (this.model.TABLEREFOBJECT_LIST != null && this.model.TABLEREFOBJECT_LIST.Count() > 0)
            {
                this.viewRef = (CollectionView)CollectionViewSource.GetDefaultView(this.model.TABLEREFOBJECT_LIST);
                this.viewRef.Filter = new Predicate<object>(this.UserFilterRef);
            }
        }

        private void MenuItem_SelQuery_Click(object sender, RoutedEventArgs e)
        {
            if (dgrdAllTab.Items.Count == 0) return;
            string code = "";
            string table_name = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdAllTab.SelectedCells).FirstOrDefault().TABLE_NAME;
            string table_comment = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdAllTab.SelectedCells).FirstOrDefault().TABLE_COMMENTS;
            code += "SELECT A.*" + WBCommon.BR;
            code += "  FROM " + table_name + " A" + " --" + table_comment +  WBCommon.BR;
            code += " WHERE 1=1" + WBCommon.BR;
            code += "   AND HSP_TP_CD = '01'" + WBCommon.BR;
            code += "   AND ROWNUM < 100" + WBCommon.BR;
            code += ";";
            //this.OpenCodeWIndow(code);
            try
            {
                Clipboard.SetText(code);
                OwnerWindow.ShowMsgBox("복사하였습니다.", 1000);
            }
            catch
            {

            }
        }

        private void MenuItem_SelQuery2_Click(object sender, RoutedEventArgs e)
        {
            if (dgrdAllTab.Items.Count == 0) return;
            this.model.SEARCH_TEXT_INDEX = string.Empty;            

            this.model.INDEXTABLE_LIST = dac.SelectTableIndex(this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdAllTab.SelectedCells).FirstOrDefault());
            if (this.model.INDEXTABLE_LIST != null && this.model.INDEXTABLE_LIST.Count() > 0)
            {
                this.viewIndex = (CollectionView)CollectionViewSource.GetDefaultView(this.model.INDEXTABLE_LIST);
                this.viewIndex.Filter = new Predicate<object>(this.UserFilterIndex);
            }

            string code = "";
            string table_name = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdAllTab.SelectedCells).FirstOrDefault().TABLE_NAME;
            string table_comment = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdAllTab.SelectedCells).FirstOrDefault().TABLE_COMMENTS;
            code += GetPkExecParam() + WBCommon.BR; 
            code += "SELECT A.*" + WBCommon.BR;
            code += "  FROM " + table_name + " A" + " --" + table_comment + WBCommon.BR;
            code += " WHERE 1=1" + WBCommon.BR;
            code += "   AND " +this.GetPkCol();
            code += ";";
            //this.OpenCodeWIndow(code);
            try
            {
                Clipboard.SetText(code);
                OwnerWindow.ShowMsgBox("복사하였습니다.", 1000);
            }
            catch
            {

            }
        }

        private void MenuItem_SelQuery3_Click(object sender, RoutedEventArgs e)
        {
            if (dgrdAllTab.Items.Count == 0) return;
            string code = "";
            string table_name = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdAllTab.SelectedCells).FirstOrDefault().TABLE_NAME;
            string table_comment = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdAllTab.SelectedCells).FirstOrDefault().TABLE_COMMENTS;
            code += "SELECT A.*" + WBCommon.BR;
            code += "  FROM " + table_name + " A" + " --" + table_comment + WBCommon.BR;
            code += " WHERE 1=1" + WBCommon.BR;
            code += "   AND HSP_TP_CD = '01'" + WBCommon.BR;
            code += "   AND ROWNUM < 100" + WBCommon.BR;
            code += ";";
            this.StartGoldenCode(code, table_name);
        }

        private void MenuItem2_SelQuery_Click(object sender, RoutedEventArgs e)
        {
            if (dgrdFavTab.Items.Count == 0)
                return;
            string code = "";
            string table_name = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdFavTab.SelectedCells).FirstOrDefault().TABLE_NAME;
            string table_comment = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdFavTab.SelectedCells).FirstOrDefault().TABLE_COMMENTS;
            code += "SELECT A.*" + WBCommon.BR;
            code += "  FROM " + table_name + " A" + " --" + table_comment + WBCommon.BR;
            code += " WHERE 1=1" + WBCommon.BR;
            code += "   AND HSP_TP_CD = '01'" + WBCommon.BR;
            code += "   AND ROWNUM < 100" + WBCommon.BR;
            code += ";";
            //this.OpenCodeWIndow(code);
            try
            {
                Clipboard.SetText(code);
                OwnerWindow.ShowMsgBox("복사하였습니다.", 1000);
            }
            catch
            {

            }
        }

        private void MenuItem2_SelQuery2_Click(object sender, RoutedEventArgs e)
        {
            this.model.SEARCH_TEXT_INDEX = string.Empty;

            this.model.INDEXTABLE_LIST = dac.SelectTableIndex(this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdFavTab.SelectedCells).FirstOrDefault());
            if (this.model.INDEXTABLE_LIST != null && this.model.INDEXTABLE_LIST.Count() > 0)
            {
                this.viewIndex = (CollectionView)CollectionViewSource.GetDefaultView(this.model.INDEXTABLE_LIST);
                this.viewIndex.Filter = new Predicate<object>(this.UserFilterIndex);
            }

            string code = "";
            string table_name = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdFavTab.SelectedCells).FirstOrDefault().TABLE_NAME;
            string table_comment = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdFavTab.SelectedCells).FirstOrDefault().TABLE_COMMENTS;
            code += GetPkExecParam() + WBCommon.BR;
            code += "SELECT A.*" + WBCommon.BR;
            code += "  FROM " + table_name + " A" + " --" + table_comment + WBCommon.BR;
            code += " WHERE 1=1" + WBCommon.BR;
            code += "   AND " + this.GetPkCol();
            code += ";";
            //this.OpenCodeWIndow(code);
            try
            {
                Clipboard.SetText(code);
                OwnerWindow.ShowMsgBox("복사하였습니다.", 1000);
            }
            catch
            {

            }
        }

        private void MenuItem2_SelQuery3_Click(object sender, RoutedEventArgs e)
        {
            if (dgrdFavTab.Items.Count == 0)
                return;
            string code = "";
            string table_name = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdFavTab.SelectedCells).FirstOrDefault().TABLE_NAME;
            string table_comment = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdFavTab.SelectedCells).FirstOrDefault().TABLE_COMMENTS;
            code += "SELECT A.*" + WBCommon.BR;
            code += "  FROM " + table_name + " A" + " --" + table_comment + WBCommon.BR;
            code += " WHERE 1=1" + WBCommon.BR;
            code += "   AND HSP_TP_CD = '01'" + WBCommon.BR;
            code += "   AND ROWNUM < 100" + WBCommon.BR;
            code += ";";
            this.StartGoldenCode(code, table_name);
        }

        private void MenuItem_SelectComnCd_Click(object sender, RoutedEventArgs e)
        {
            string code = "";
            TableInfo_INOUT selectedItem = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdCommonCodeInfo.SelectedCells).FirstOrDefault();

            code += "SELECT '' HSP_TP_CD" + GetBlank("SELECT '' HSP_TP_CD" ,50) + "/*병원구분코드*/"+ WBCommon.BR;
            code += "     , COMN_GRP_CD" + GetBlank("     , COMN_GRP_CD", 50) + "/*공통그룹코드*/" + WBCommon.BR;
            code += "     , COMN_CD" + GetBlank("     , COMN_CD", 50) + "/*공통코드*/" + WBCommon.BR;
            code += "     , COMN_CD_NM" + GetBlank("     , COMN_CD_NM", 50) + "/*공통코드명*/" + WBCommon.BR;
            code += "     , COMN_CD_EXPL" + GetBlank("     , COMN_CD_EXPL", 50) + "/*공통코드설명*/" + WBCommon.BR;
            code += "     , NVL(SCRN_MRK_SEQ, 999) SCRN_MRK_SEQ" + GetBlank("     , NVL(SCRN_MRK_SEQ, 999) SCRN_MRK_SEQ", 50) + "/*화면표시순번*/" + WBCommon.BR;
            code += "     , USE_YN" + GetBlank("     , USE_YN", 50) + "/*사용여부*/" + WBCommon.BR;
            code += "     , DTRL1_NM" + GetBlank("     , DTRL1_NM", 50) + "/*1번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL2_NM" + GetBlank("     , DTRL2_NM", 50) + "/*2번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL3_NM" + GetBlank("     , DTRL3_NM", 50) + "/*3번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL4_NM" + GetBlank("     , DTRL4_NM", 50) + "/*4번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL5_NM" + GetBlank("     , DTRL5_NM", 50) + "/*5번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL6_NM" + GetBlank("     , DTRL6_NM", 50) + "/*6번째업무규칙명*/" + WBCommon.BR;
            code += "     , NEXTG_FMR_COMN_CD" + GetBlank("     , NEXTG_FMR_COMN_CD", 50) + "/**/" + WBCommon.BR;
            code += "  FROM CCCCCSTE" + WBCommon.BR;
            code += " WHERE 1=1" + WBCommon.BR;
            code += "   AND COMN_GRP_CD = " + "'" + selectedItem.COMN_GRP_CD + "'" + WBCommon.BR;
            code += "UNION ALL" + WBCommon.BR + WBCommon.BR;
            code += "SELECT HSP_TP_CD" + GetBlank("SELECT HSP_TP_CD", 50) + "/*병원구분코드*/" + WBCommon.BR;
            code += "     , COMN_GRP_CD" + GetBlank("     , COMN_GRP_CD", 50) + "/*공통그룹코드*/" + WBCommon.BR;
            code += "     , COMN_CD" + GetBlank("     , COMN_CD", 50) + "/*공통코드*/" + WBCommon.BR;
            code += "     , COMN_CD_NM" + GetBlank("     , COMN_CD_NM", 50) + "/*공통코드명*/" + WBCommon.BR;
            code += "     , COMN_CD_EXPL" + GetBlank("     , COMN_CD_EXPL", 50) + "/*공통코드설명*/" + WBCommon.BR;
            code += "     , NVL(SCRN_MRK_SEQ, 999) SCRN_MRK_SEQ" + GetBlank("     , NVL(SCRN_MRK_SEQ, 999) SCRN_MRK_SEQ", 50) + "/*화면표시순번*/" + WBCommon.BR;
            code += "     , USE_YN" + GetBlank("     , USE_YN", 50) + "/*사용여부*/" + WBCommon.BR;
            code += "     , DTRL1_NM" + GetBlank("     , DTRL1_NM", 50) + "/*1번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL2_NM" + GetBlank("     , DTRL2_NM", 50) + "/*2번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL3_NM" + GetBlank("     , DTRL3_NM", 50) + "/*3번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL4_NM" + GetBlank("     , DTRL4_NM", 50) + "/*4번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL5_NM" + GetBlank("     , DTRL5_NM", 50) + "/*5번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL6_NM" + GetBlank("     , DTRL6_NM", 50) + "/*6번째업무규칙명*/" + WBCommon.BR;
            code += "     , NEXTG_FMR_COMN_CD" + GetBlank("     , NEXTG_FMR_COMN_CD", 50) + "/**/" + WBCommon.BR;
            code += "  FROM CCCMCSTE" + WBCommon.BR;
            code += " WHERE 1=1" + WBCommon.BR;
            code += "   AND COMN_GRP_CD = " + "'" + selectedItem.COMN_GRP_CD + "'" + WBCommon.BR;
            code += " ORDER BY SCRN_MRK_SEQ, COMN_CD_NM" + WBCommon.BR;
            code += ";";

            this.OpenCodeWIndow(code);

        }

        private void MenuItem_SelectComnCd2_Click(object sender, RoutedEventArgs e)
        {
            string code = "";
            TableInfo_INOUT selectedItem = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdCommonCodeInfo.SelectedCells).FirstOrDefault();
            string selectedComment = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells).FirstOrDefault().COMMENTS;

            code += "SELECT '' HSP_TP_CD" + GetBlank("SELECT '' HSP_TP_CD", 50) + "/*병원구분코드*/" + WBCommon.BR;
            code += "     , COMN_GRP_CD" + GetBlank("     , COMN_GRP_CD", 50) + "/*공통그룹코드*/" + WBCommon.BR;
            code += "     , COMN_CD" + GetBlank("     , COMN_CD", 50) + "/*공통코드*/" + WBCommon.BR;
            code += "     , COMN_CD_NM" + GetBlank("     , COMN_CD_NM", 50) + "/*공통코드명*/" + WBCommon.BR;
            code += "     , COMN_CD_EXPL" + GetBlank("     , COMN_CD_EXPL", 50) + "/*공통코드설명*/" + WBCommon.BR;
            code += "     , NVL(SCRN_MRK_SEQ, 999) SCRN_MRK_SEQ" + GetBlank("     , NVL(SCRN_MRK_SEQ, 999) SCRN_MRK_SEQ", 50) + "/*화면표시순번*/" + WBCommon.BR;
            code += "     , USE_YN" + GetBlank("     , USE_YN", 50) + "/*사용여부*/" + WBCommon.BR;
            code += "     , DTRL1_NM" + GetBlank("     , DTRL1_NM", 50) + "/*1번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL2_NM" + GetBlank("     , DTRL2_NM", 50) + "/*2번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL3_NM" + GetBlank("     , DTRL3_NM", 50) + "/*3번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL4_NM" + GetBlank("     , DTRL4_NM", 50) + "/*4번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL5_NM" + GetBlank("     , DTRL5_NM", 50) + "/*5번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL6_NM" + GetBlank("     , DTRL6_NM", 50) + "/*6번째업무규칙명*/" + WBCommon.BR;
            code += "     , NEXTG_FMR_COMN_CD" + GetBlank("     , NEXTG_FMR_COMN_CD", 50) + "/**/" + WBCommon.BR;
            code += "  FROM CCCCCSTE" + WBCommon.BR;
            code += " WHERE 1=1" + WBCommon.BR;
            code += "   AND COMN_GRP_CD = " + "'" + selectedItem.COMN_GRP_CD + "'" + WBCommon.BR;
            code += "UNION ALL" + WBCommon.BR + WBCommon.BR;
            code += "SELECT HSP_TP_CD" + GetBlank("SELECT HSP_TP_CD", 50) + "/*병원구분코드*/" + WBCommon.BR;
            code += "     , COMN_GRP_CD" + GetBlank("     , COMN_GRP_CD", 50) + "/*공통그룹코드*/" + WBCommon.BR;
            code += "     , COMN_CD" + GetBlank("     , COMN_CD", 50) + "/*공통코드*/" + WBCommon.BR;
            code += "     , COMN_CD_NM" + GetBlank("     , COMN_CD_NM", 50) + "/*공통코드명*/" + WBCommon.BR;
            code += "     , COMN_CD_EXPL" + GetBlank("     , COMN_CD_EXPL", 50) + "/*공통코드설명*/" + WBCommon.BR;
            code += "     , NVL(SCRN_MRK_SEQ, 999) SCRN_MRK_SEQ" + GetBlank("     , NVL(SCRN_MRK_SEQ, 999) SCRN_MRK_SEQ", 50) + "/*화면표시순번*/" + WBCommon.BR;
            code += "     , USE_YN" + GetBlank("     , USE_YN", 50) + "/*사용여부*/" + WBCommon.BR;
            code += "     , DTRL1_NM" + GetBlank("     , DTRL1_NM", 50) + "/*1번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL2_NM" + GetBlank("     , DTRL2_NM", 50) + "/*2번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL3_NM" + GetBlank("     , DTRL3_NM", 50) + "/*3번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL4_NM" + GetBlank("     , DTRL4_NM", 50) + "/*4번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL5_NM" + GetBlank("     , DTRL5_NM", 50) + "/*5번째업무규칙명*/" + WBCommon.BR;
            code += "     , DTRL6_NM" + GetBlank("     , DTRL6_NM", 50) + "/*6번째업무규칙명*/" + WBCommon.BR;
            code += "     , NEXTG_FMR_COMN_CD" + GetBlank("     , NEXTG_FMR_COMN_CD", 50) + "/**/" + WBCommon.BR;
            code += "  FROM CCCMCSTE" + WBCommon.BR;
            code += " WHERE 1=1" + WBCommon.BR;
            code += "   AND COMN_GRP_CD = " + "'" + selectedItem.COMN_GRP_CD + "'" + WBCommon.BR;
            code += " ORDER BY SCRN_MRK_SEQ, COMN_CD_NM" + WBCommon.BR;
            code += ";";

            this.StartGoldenCode(code,"CCCCCSTE" + selectedComment);
        }

        private void dgrdDetailTab_MouseUp(object sender, MouseButtonEventArgs e)
        {
            if(chkSelUnit.IsChecked == true)
            {
                TableInfo_INOUT selectedItem = (this.dgrdDetailTab.CurrentItem as TableInfo_INOUT);
                if (selectedItem is null) return;

                TableInfo_INOUT inObj = new TableInfo_INOUT();
                inObj.COMN_GRP_CD = GetCommonGroupCode(selectedItem.COLUMN_NAME);
                this.model.COMNCD_LIST = dac.SelectComnCd(inObj);
            }

        }

        private void dgrdAllTab_KeyDown(object sender, KeyEventArgs e)
        {
            try
            {
                string str = Clipboard.GetText().Trim();
                Clipboard.SetText(str);
            }
            catch
            {

            }
        }

        private void CommandBinding_CanExecute(object sender, CanExecuteRoutedEventArgs e)
        {            
            e.CanExecute = (((DataGrid)sender).ItemsSource as IList).Count > 0 && this.model.UNIT == DataGridSelectionUnit.Cell;
        }

        private void CommandBinding_Executed(object sender, ExecutedRoutedEventArgs e)
        {            
            string cpStr = "";            
            foreach (var cellObj in ((DataGrid)sender).SelectedCells)
            {
                cpStr += WBCommon.GetPropertyValue(cellObj.Item, cellObj.Column.SortMemberPath) + WBCommon.BR;                                
            }
            cpStr = cpStr.TrimEnd(new char[] { '\r', '\n' });
            try
            {
                Clipboard.SetText(cpStr);
            }
            catch
            {

            }
        }

        private void GridSplitter_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            try
            {
                grdMain.ColumnDefinitions[0].Width = new GridLength(0.4, GridUnitType.Star);
                grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                grdMain.ColumnDefinitions[2].Width = new GridLength(1, GridUnitType.Star);
            }
            catch(Exception)
            {

            }
        }

        private void Qeury_Trigger_Click(object sender, RoutedEventArgs e)
        {
            IList<TableInfo_INOUT> selectedItems = this.dgrdDetailTab.Items.Cast<TableInfo_INOUT>().ToList();            
            IEnumerable sortedSelectedItems = selectedItems.Distinct().OrderBy(d => d.SEQ);


            TableInfo_INOUT selectedItem = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells).FirstOrDefault();
            if (selectedItems == null || selectedItem == null) return;
            string code = "";
            code += "TRIGGER " + selectedItem.OWNER + ".TR_" + this.model.TR_TABLE + WBCommon.BR;
            code += "AFTER INSERT OR UPDATE OR DELETE ON " + selectedItem.OWNER + "." + this.model.TR_TABLE + " FOR EACH ROW" + WBCommon.BR + WBCommon.BR;
            code += "DECLARE" + WBCommon.BR + WBCommon.BR;
            code += "BEGIN" + WBCommon.BR;
            


            string str0 = WBCommon.TAB + "IF INSERTING THEN" + WBCommon.BR; //IF INSERTING THEN
            string str1 = WBCommon.TAB + WBCommon.TAB + string.Format("INSERT /*{0} */","TR_" + this.model.TR_TABLE) + WBCommon.BR + WBCommon.TAB + WBCommon.TAB + "       INTO " + selectedItem.TABLE_NAME + BR + WBCommon.TAB + WBCommon.TAB + "     (" + BR;
            string str2 = WBCommon.TAB + WBCommon.TAB + ""; //INSERT 부분
            string str3 = WBCommon.TAB + WBCommon.TAB + ""; //VALUES 부분

            string str4 = WBCommon.TAB + "ELSIF UPDATING THEN" + WBCommon.BR;
            string str5 = WBCommon.TAB + WBCommon.TAB + string.Format("INSERT /*{0} */", "TR_" + this.model.TR_TABLE) + WBCommon.BR + WBCommon.TAB + WBCommon.TAB + "       INTO " + selectedItem.TABLE_NAME + BR + WBCommon.TAB + WBCommon.TAB + "     (" + BR;
            string str6 = WBCommon.TAB + WBCommon.TAB +  ""; //INSERT 부분
            string str7 = WBCommon.TAB + WBCommon.TAB + ""; //VALUES 부분

            string str8 = WBCommon.TAB + "ELSIF DELETING THEN" + WBCommon.BR;
            string str9 = WBCommon.TAB + WBCommon.TAB + string.Format("INSERT /*{0} */", "TR_" + this.model.TR_TABLE) + BR + WBCommon.TAB + WBCommon.TAB + "       INTO " + selectedItem.TABLE_NAME + BR + WBCommon.TAB + WBCommon.TAB + "     (" + BR;
            string str10 = WBCommon.TAB + WBCommon.TAB +  ""; //INSERT 부분
            string str11 = WBCommon.TAB + WBCommon.TAB + ""; //VALUES 부분
            string str12 = WBCommon.TAB + "END IF;" + WBCommon.BR;

            string inParameter = "";
            int num = 0;
            //INSERT
            foreach (TableInfo_INOUT colInfo in sortedSelectedItems)
            {
                inParameter = this.GetTriggerParameter(colInfo,"NEW","'I'");
                ++num;
                str2 += "     ";
                str3 += "     ";
                if (num == 1)
                {
                    str2 += "  ";
                    str3 += "  ";
                }
                else
                {
                    str2 += WBCommon.TAB + WBCommon.TAB +", ";
                    str3 += WBCommon.TAB + WBCommon.TAB + ", ";
                }
                str2 += colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " /*" + colInfo.COMMENTS + "*/" + BR;
                str3 += inParameter + this.GetBlank(inParameter) + " /*" + colInfo.COMMENTS + "*/" + BR;                
            }            
            num = 0;
            //UPDATE
            foreach (TableInfo_INOUT colInfo in sortedSelectedItems)
            {
                inParameter = this.GetTriggerParameter(colInfo, "NEW", "'U'");
                ++num;
                str6 += "     ";
                str7 += "     ";
                if (num == 1)
                {
                    str6 += "  ";
                    str7 += "  ";
                }
                else
                {
                    str6 += WBCommon.TAB + WBCommon.TAB + ", ";
                    str7 += WBCommon.TAB + WBCommon.TAB + ", ";
                }
                str6 += colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " /*" + colInfo.COMMENTS + "*/" + BR;
                str7 += inParameter + this.GetBlank(inParameter) + " /*" + colInfo.COMMENTS + "*/" + BR;
            }
            num = 0;
            //DELETE
            foreach (TableInfo_INOUT colInfo in sortedSelectedItems)
            {
                inParameter = this.GetTriggerParameter(colInfo, "OLD", "'D'");
                ++num;
                str10 += "     ";
                str11 += "     ";
                if (num == 1)
                {
                    str10 += "  ";
                    str11 += "  ";
                }
                else
                {
                    str10 += WBCommon.TAB + WBCommon.TAB + ", ";
                    str11 += WBCommon.TAB + WBCommon.TAB + ", ";
                }
                str10 += colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " /*" + colInfo.COMMENTS + "*/" + BR;
                str11 += inParameter + this.GetBlank(inParameter) + " /*" + colInfo.COMMENTS + "*/" + BR;
            }

            code += str0;
            code += str1;
            code += str2;
            code += WBCommon.TAB + WBCommon.TAB + "     )" + WBCommon.BR + WBCommon.TAB + WBCommon.TAB + "VALUES" + WBCommon.BR + WBCommon.TAB + WBCommon.TAB + "     (" + WBCommon.BR;
            code += str3;
            code += WBCommon.TAB + WBCommon.TAB + "     );" + WBCommon.BR;

            code += str4;
            code += str5;
            code += str6;
            code += WBCommon.TAB + WBCommon.TAB + "     )" + WBCommon.BR + WBCommon.TAB + WBCommon.TAB + "VALUES" + WBCommon.BR + WBCommon.TAB + WBCommon.TAB + "     (" + WBCommon.BR;
            code += str7;
            code += WBCommon.TAB + WBCommon.TAB + "     );" + WBCommon.BR;

            code += str8;
            code += str9;
            code += str10;
            code += WBCommon.TAB + WBCommon.TAB + "     )" + WBCommon.BR + WBCommon.TAB + WBCommon.TAB + "VALUES" + WBCommon.BR + WBCommon.TAB + WBCommon.TAB + "     (" + WBCommon.BR;
            code += str11;
            code += WBCommon.TAB + WBCommon.TAB + "     );" + WBCommon.BR;
            code += str12;
            code += "END;";
            this.OpenCodeWIndow(code);
        }

        private string GetTriggerParameter(TableInfo_INOUT item, string prefix, string wk_chg_tp_cd, string colon = ":")
        {
            string inParameter = colon + prefix + "." + item.COLUMN_NAME;
            if (item.COLUMN_NAME.EndsWith("CHG_TMST"))
                inParameter = "SYSTIMESTAMP";
            else if (item.COLUMN_NAME.EndsWith("WK_CHG_TP_CD"))
                inParameter = wk_chg_tp_cd;
            else if (item.COLUMN_NAME.EndsWith("HDWK_STF_NM"))
                inParameter = "SYS_CONTEXT('USERENV','HOST')";
            else if (item.COLUMN_NAME.EndsWith("HDWK_PRGM_NM"))
                inParameter = "SYS_CONTEXT('USERENV','MODULE')";
            else if (item.COLUMN_NAME.EndsWith("HDWK_IP_ADDR"))
                inParameter = "SYS_CONTEXT('USERENV','IP_ADDRESS')";
            return inParameter;
        }

        private void GridSplitter_PreviewMouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            try
            {
                grdAllTab.RowDefinitions[0].Height = new GridLength(1, GridUnitType.Star);
                grdAllTab.RowDefinitions[1].Height = new GridLength(10);
                grdAllTab.RowDefinitions[2].Height = new GridLength(0.3, GridUnitType.Star);                
            }
            catch (Exception)
            {

            }
        }

        private void GridSplitter_PreviewMouseDoubleClick_1(object sender, MouseButtonEventArgs e)
        {
            try
            {
                grdDetailTab.RowDefinitions[0].Height = new GridLength(1, GridUnitType.Star);
                grdDetailTab.RowDefinitions[1].Height = new GridLength(10);
                grdDetailTab.RowDefinitions[2].Height = new GridLength(0.3, GridUnitType.Star);
            }
            catch (Exception)
            {

            }
        }

        private void Qeury_Select2_Click(object sender, RoutedEventArgs e)
        {
            MenuItem parent = (MenuItem)sender;
            string str0 = "";
            string str1 = "";
            if (!string.IsNullOrEmpty(this.model.ALIAS2))
                str1 = this.model.ALIAS2.Trim().ToUpper();
            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            TableInfo_INOUT selectedItem = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells).FirstOrDefault();
            if (selectedItems == null || selectedItem == null)
                return;
            string str2 = "SELECT /* HIS.EQSID */" + BR;
            int num = 0;
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                ++num;
                str2 += "     ";
                str2 = num != 1 ? str2 + ", " : str2 + "  ";
                string txt = this.CheckCol(colInfo, str1);
                str2 = str2 + txt + this.GetBlank(txt) + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME, 30) + " /*" + colInfo.COMMENTS + "*/" + BR;
            }
            str0 = this.model.EXEC_CHECK ? GetPkExecParam() + BR : str0;
            this.OpenCodeWIndow(str0 + str2 + "  FROM " + selectedItem.TABLE_NAME + " " + str1 + BR + " WHERE " + this.GetPkCol(str1,preFix:""));
        }

        private void MenuItem_FavSave_Click(object sender, RoutedEventArgs e)
        {
            if (dgrdAllTab.Items.Count == 0)
                return;
            List<TableInfo_INOUT> selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdAllTab.SelectedCells);
            foreach(TableInfo_INOUT data in selectedItems)
            {
                this.model.USERINFO.FAV_TABLE.Add(data);
            }            
            this.model.USERINFO.FAV_TABLE = this.model.USERINFO.FAV_TABLE.Distinct().ToList();
            this.model.SaveUserInfo();
            if (this.model.USERINFO.FAV_TABLE.Count > 0)
            {
                this.viewFav = (CollectionView)CollectionViewSource.GetDefaultView(this.model.USERINFO.FAV_TABLE);
                this.viewFav.Filter = new Predicate<object>(this.UserFilterFav);
                this.viewFav.GroupDescriptions.Clear(); //GROUP
                this.viewFav.GroupDescriptions.Add(new PropertyGroupDescription("GROUP"));  //GROUP
            }

        }

        private void MenuItem_FavDelete_Click(object sender, RoutedEventArgs e)
        {
            if (dgrdFavTab.Items.Count == 0)
                return;
            List<TableInfo_INOUT> selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdFavTab.SelectedCells);

            selectedItems.ForEach(x => this.model.USERINFO.FAV_TABLE.Remove(x));

            this.model.USERINFO.FAV_TABLE = this.model.USERINFO.FAV_TABLE.Distinct().ToList();
            this.model.SaveUserInfo();
            if (this.model.USERINFO.FAV_TABLE.Count > 0)
            {
                this.viewFav = (CollectionView)CollectionViewSource.GetDefaultView(this.model.USERINFO.FAV_TABLE);
                this.viewFav.Filter = new Predicate<object>(this.UserFilterFav);
                this.viewFav.GroupDescriptions.Clear(); //GROUP
                this.viewFav.GroupDescriptions.Add(new PropertyGroupDescription("GROUP"));  //GROUP
            }
        }

        private void GridSplitter_PreviewMouseDoubleClick_2(object sender, MouseButtonEventArgs e)
        {
            try
            {
                grdFavTable.RowDefinitions[0].Height = new GridLength(1, GridUnitType.Star);
                grdFavTable.RowDefinitions[1].Height = new GridLength(10);
                grdFavTable.RowDefinitions[2].Height = new GridLength(2, GridUnitType.Star);
            }
            catch (Exception)
            {

            }
        }

        private void txtSearch_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
                this.Search();
        }

        private void txtSearchFav_TextChanged(object sender, TextChangedEventArgs e)
        {
            BindingExpression bindingExpression = ((TextBox)sender).GetBindingExpression(TextBox.TextProperty);
            bindingExpression.UpdateSource();
            if (viewFav != null)
                viewFav.Refresh();
        }

        private void Qeury_MergeV2_Click(object sender, RoutedEventArgs e)
        {
            //선택한 Item.
            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            //UPDATE 할 Item
            IList<TableInfo_INOUT> updateItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT tableInfo in dgrdDetailTab.Items)
            {
                if (tableInfo.COLUMN_NAME.IndexOf("LSH_DTM", StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_STF_NO", StringComparison.OrdinalIgnoreCase) == 0
                    || tableInfo.COLUMN_NAME.IndexOf("LSH_PRGM_NM", StringComparison.OrdinalIgnoreCase) == 0 || tableInfo.COLUMN_NAME.IndexOf("LSH_IP_ADDR", StringComparison.OrdinalIgnoreCase) == 0)
                    updateItems.Add(tableInfo);
            }
            IEnumerable sortedUpdateItems = updateItems.Distinct().OrderBy(d => d.SEQ);

            //INSERT 할 Item
            IList<TableInfo_INOUT> insertItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            foreach (TableInfo_INOUT notNullItem in dgrdDetailTab.Items)
            {
                if (notNullItem.NULLABLE.IndexOf("NOT NULL", StringComparison.OrdinalIgnoreCase) > -1)
                    insertItems.Add(notNullItem);
            }
            IEnumerable sortedInsertItems = insertItems.Distinct().OrderBy(d => d.SEQ);

            TableInfo_INOUT selectedItem = selectedItems.Cast<TableInfo_INOUT>().ToList().FirstOrDefault();
            if (selectedItems == null || selectedItem == null)
                return;
            string str0 = GetPkExecParam();
            string str1 = "MERGE /* HIS.EQSID */ " + BR + "      INTO " + selectedItem.TABLE_NAME + BR + "USING DUAL" +
                          BR + "ON (" + BR + "       " + this.GetPkCol("",preFix:"") + BR + "   ) "
                          + BR + "WHEN MATCHED THEN" + BR + "UPDATE" + BR;
            int num1 = 0;
            foreach (TableInfo_INOUT colInfo in sortedUpdateItems)
            {
                if (!this.IsPkCol(colInfo.COLUMN_NAME))
                {
                    ++num1;
                    if (num1 == 1)
                    {
                        str1 += "   ";
                        str1 += "SET ";
                    }
                    else
                    {
                        str1 += "     ";
                        str1 += ", ";
                    }
                    string inParameter = this.GetInParameter(colInfo,prefix:"");
                    str1 = str1 + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " = " + inParameter + this.GetBlank(inParameter) + " /*" + colInfo.COMMENTS + "*/" + BR;
                    if (inParameter != "SYSDATE" && str0.IndexOf(GetExecParm(inParameter)) < 0)
                        str0 = str0 + GetExecParm(inParameter);
                }
            }
            string str2 = str1 + "WHEN NOT MATCHED THEN" + BR + "INSERT" + BR + "     (" + BR;
            string str3 = "";
            string str4 = "";
            int num2 = 0;
            foreach (TableInfo_INOUT colInfo in sortedInsertItems)
            {
                ++num2;
                str3 += "     ";
                str4 += "     ";
                if (num2 == 1)
                {
                    str3 += "  ";
                    str4 += "  ";
                }
                else
                {
                    str3 += ", ";
                    str4 += ", ";
                }
                str3 = str3 + colInfo.COLUMN_NAME + this.GetBlank(colInfo.COLUMN_NAME) + " /*" + colInfo.COMMENTS + "*/" + BR;
                string inParameter = this.GetInParameter(colInfo,prefix:"");
                str4 = str4 + inParameter + BR;
            }
            str0 = this.model.EXEC_CHECK ? str0 + BR : "";
            this.OpenCodeWIndow(str0 + str2 + str3 + "     )" + BR + "VALUES" + BR + "     (" + BR + str4 + "     )" + BR);
        }

        private void Column_CopyComma_Click(object sender, RoutedEventArgs e)
        {
            IList selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdDetailTab.SelectedCells);
            string code = "";
            foreach (TableInfo_INOUT colInfo in (IEnumerable)selectedItems)
            {
                code += "     , " + colInfo.COLUMN_NAME + WBCommon.BR;
            }
            try
            {
                Clipboard.SetText(code);
                OwnerWindow.ShowMsgBox("복사하였습니다.", 1000);
            }
            catch (Exception)
            {

            }
        }

        private void btnPLEdit_Click(object sender, RoutedEventArgs e)
        {
            string code = "";
            string title = "";
            var selectedItem = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdTableDB.SelectedCells).FirstOrDefault();
            code = selectedItem.OBJ_TYPE.ToUpper() != "VIEW" ? this.GetDBSourceText(selectedItem.OBJ_NAME.Trim()) : this.GetViewSourceText(selectedItem.OWNER, selectedItem.OBJ_NAME.Trim());
            title = selectedItem.OBJ_NAME;
            if (!(code != ""))
                return;
            this.StartPLEditCode(code,title);
        }

        private void txtSearchDB_TextChanged(object sender, TextChangedEventArgs e)
        {
            BindingExpression bindingExpression = ((TextBox)sender).GetBindingExpression(TextBox.TextProperty);
            bindingExpression.UpdateSource();
            if (viewRef != null)
                viewRef.Refresh();
        }
        private void MenuItem_AddCategory_Click(object sender, RoutedEventArgs e)
        {
            if (dgrdFavTab.Items.Count == 0)
                return;
            IList<TableInfo_INOUT> selectedItems = this.model.ConvertCellToRow<TableInfo_INOUT>(this.dgrdFavTab.SelectedCells);
            if (selectedItems.Count <= 0) return;

            string cat = this.model.TABLE_CATEGORY;

            foreach (TableInfo_INOUT item in selectedItems)
            {
                item.GROUP = string.IsNullOrEmpty(cat) ? null : cat;
            }
            this.model.USERINFO.FAV_TABLE = this.model.USERINFO.FAV_TABLE.Distinct().ToList();
            this.model.SaveUserInfo();
            if (this.model.USERINFO.FAV_TABLE.Count > 0)
            {
                this.viewFav = (CollectionView)CollectionViewSource.GetDefaultView(this.model.USERINFO.FAV_TABLE);
                this.viewFav.Filter = new Predicate<object>(this.UserFilterFav);
                this.viewFav.GroupDescriptions.Clear(); //GROUP
                this.viewFav.GroupDescriptions.Add(new PropertyGroupDescription("GROUP"));  //GROUP
            }
        }
        private void AddContextMenu(string category)
        {
            MenuItem menuItem = new MenuItem();
            menuItem.Header = category;
            menuItem.Click += MenuItem_AddCategory_Click;

            this.ctcFavTable.Items.Add(menuItem);
        }

        private void TextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            BindingExpression bindingExpression = ((TextBox)sender).GetBindingExpression(TextBox.TextProperty);
            bindingExpression.UpdateSource();
        }
    }
}
