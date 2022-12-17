using System;
using System.Collections.Generic;
using System.Data;
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
using System.Xml;
using WB.Common;
using WB.DTO;
using WB.UC;

namespace WB
{
    /// <summary>
    /// CodeGenerater.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class CodeGenerater : UCBase
    {
        private CodeGeneraterData model;
        private DataTable dtColumnNameInfo = (DataTable)null;
        private string HDataGridEx_Code = "";
        private DispatcherTimer timer;
        private DispatcherTimer timer2;
        private DispatcherTimer timer3;

        public CodeGenerater()
        {
            InitializeComponent();
            this.model = DataContext as CodeGeneraterData;
            this.model.LoadUserInfo();
            model.thisWindow = this;
        }

        private void txtCode_GotFocus(object sender, RoutedEventArgs e)
        {
            
        }

        private void CheckBox_Checked(object sender, RoutedEventArgs e)
        {
            if (txtView is null) return;
            txtView.Focus();
            this.model.USERINFO.SYNC = "Y";
            this.model.SYNC_TEXT = "";
            this.model.SyncText("");
            this.model.SaveUserInfo();
        }
        private void txtQueryDTO_TextChanged(object sender, TextChangedEventArgs e)
        {
            BindingExpression bindingExpression = ((TextBox)sender).GetBindingExpression(TextBox.TextProperty);
            bindingExpression.UpdateSource();
            AutoQueryDTOText();
        }
        /// <summary>
        /// name         : QUERY->DTO 자동변환
        /// desc         : QUERY->DTO 자동변환
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-10-27
        /// update date  : 2022-10-27
        /// </summary>
        /// <remarks></remarks>
        private void AutoQueryDTOText()
        {
            try
            {
                if (this.model is null || this.model.QUERY_TEXT == null || string.IsNullOrWhiteSpace(this.model.QUERY_TEXT))
                    return;

                string query = this.model.QUERY_TEXT;
                //query = Regex.Replace(query, @"<", "&lt;");
                //query = Regex.Replace(query, @">", "&gt;");            
                query = "<sql>" + WBCommon.BR + WBCommon.TAB + "<![CDATA[ " + WBCommon.BR + query + WBCommon.BR + "]]> " + WBCommon.BR + "</sql>";

                string svc_mode = "S";
                if (query.ToUpper().IndexOf("UPDATE") > -1)
                    svc_mode = "U";
                if (query.ToUpper().IndexOf("INSERT") > -1)
                    svc_mode = "U";
                if (query.ToUpper().IndexOf("DELETE") > -1)
                    svc_mode = "U";

                query = GetQueryText(query);
                if ((query.ToUpper().IndexOf("PKG") > -1 || query.ToUpper().IndexOf("PC_") > -1) && query.Length < 300)
                {
                    GetProcedureSourceGenerater_INOUT(query);
                    MakeDTOPropertyEQSParameterFromProc();
                }
                else
                {
                    if (svc_mode == "S")
                        MakeDTOCodeAndGridCode(query);
                    MakeDTOPropertyEQSParameterFromQuery(query);
                }
            }
            catch(Exception)
            {

            }
        }
        private string GetQueryText(string query)
        {                     
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.LoadXml(query);
            string queryText = xmlDocument.SelectNodes("sql")[0].InnerText.Trim();
            queryText.ToUpper();
            return queryText;
        }

        private void GetProcedureSourceGenerater_INOUT(string query)
        {
            this.model.PAKAGE_LIST.Clear();
            string str1 = "";
            string str2 = this.model.PKG_NM.Trim();
            string str3 = query;
            string[] separator = new string[3]
            {
        "\r\n",
        "\r",
        "\n"
            };
            foreach (string str4 in str3.Split(separator, StringSplitOptions.None))
            {
                string str5 = str4.Trim();
                if (str5.IndexOf("/*") <= -1 && str5.IndexOf("*/") <= -1 && !str5.Trim().StartsWith("--") && (str5.ToUpper().IndexOf("PKG") > -1 || str5.ToUpper().IndexOf("PC_") > -1))
                {
                    string[] strArray = str5.Split('.');
                    if (strArray.Length == 3)
                    {
                        str1 = strArray[1];
                        str2 = strArray[2];
                    }
                    else if (strArray.Length == 2)
                    {
                        if (str5.ToUpper().IndexOf("PKG") > -1)
                        {
                            str1 = strArray[0];
                            str2 = strArray[1];
                        }
                        else
                        {
                            str1 = "";
                            str2 = strArray[1];
                        }
                    }
                    else if (strArray.Length == 1)
                    {
                        str1 = "";
                        str2 = strArray[0];
                    }
                    this.model.PKG_NM = str5;
                }
            }
            SourceGenerater_INOUT inObj = new SourceGenerater_INOUT();
            inObj.PKG_NAME = str1;
            inObj.PROC_NAME = str2;
            this.model.PAKAGECommand.Execute(inObj);
        }

        private void MakeDTOPropertyEQSParameterFromProc()
        {
            try
            {
                string str1 = "";
                string str2 = "";
                foreach (SourceGenerater_INOUT SourceGenerater_INOUT in (List<SourceGenerater_INOUT>)this.model.PAKAGE_LIST)
                {
                    if (SourceGenerater_INOUT.DATA_TYPE == "DATE")
                        str2 = "DateTime";
                    else if (SourceGenerater_INOUT.DATA_TYPE == "NUMBER")
                        str2 = "decimal";
                    else
                        str2 = "string";
                    string argumentName = SourceGenerater_INOUT.ARGUMENT_NAME;
                    string metaColName = model.USERINFO.EXCN_META == true ? "" : this.GetMetaColumnName(this.dtColumnNameInfo, argumentName.Trim());
                    str1 += string.Format("{1}{1}private {2} {3};{0}", (object)WBCommon.BR, (object)"    ", (object)str2, (object)argumentName.ToLower());
                    str1 += WBCommon.SUMMARY.Replace("#TITLE#", "name : " + metaColName);
                    str1 += string.Format("{0}{1}{1}[DataMember]{0}", (object)WBCommon.BR, (object)"    ");
                    str1 += string.Format("{1}{1}public {2} {3}{0}", (object)WBCommon.BR, (object)"    ", (object)str2, (object)argumentName.ToUpper());
                    str1 += string.Format("{1}{1}{{ {0}", (object)WBCommon.BR, (object)"    ");
                    str1 += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)WBCommon.BR, (object)"    ", (object)argumentName.ToLower());
                    str1 += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)WBCommon.BR, (object)"    ", (object)argumentName.ToLower(), (object)argumentName.ToUpper());
                    str1 += string.Format("{1}{1}}} {0}{0}", (object)WBCommon.BR, (object)"    ");
                }
                this.model.QUERY_DTO_TEXT = str1;
            }
            catch (Exception ex)
            {
                this.ErrorMsg(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요. \n 혹은 Meta정보 제외를 체크해주세요.", ex.ToString()));
            }
        }

        private void MakeDTOCodeAndGridCode(string query)
        {
            try
            {               
                DataSet dataSet = this.DBSvc.ExecuteQueryForMakeDTO2(query);
                if (dataSet == null)
                    return;
                DataTable table = dataSet.Tables[0];
                if(!model.USERINFO.EXCN_META)
                    this.dtColumnNameInfo = this.GetColumnNameInfo(table);
                if(this.model.QUERY_DTO_DRTN_SEL.DATA_TYPE_CD == "1")
                    this.MakeDTOCode(table);
                else //private 따로 public 따로
                    this.MakeDTOCodeV2(table);

                this.MakeHDataGridExCode(table, "SELECT");
            }
            catch (Exception ex)
            {
                this.model.QUERY_DTO_TEXT = "DTO Property 생성실패!!!" + Environment.NewLine + ex.ToString();
            }
        }

        private void MakeDTOPropertyEQSParameterFromQuery(string query)
        {
            try
            {
                query = this.DBSvc.RemoveComment2(query);
                if (string.IsNullOrEmpty(query))
                    return;
                if (this.model.QUERY_DTO_TEXT is null) return;
                string str1 = "";
                MatchCollection matchList = Regex.Matches(query, ":\\w+");
                List<string> source = new List<string>();
                foreach (Group group in matchList)
                {
                    foreach (Capture capture in group.Captures)
                    {
                        if (capture.Value.Length >= 4)
                        {
                            string str2 = capture.Value.Replace(":", "");
                            source.Add(str2);
                        }
                    }
                }
                foreach (string str3 in source.Distinct<string>().ToList<string>())
                {
                    if (str3.ToUpper().IndexOf("HIS") != 0)
                    {
                        string metaColName = model.USERINFO.EXCN_META == true ? "" : this.GetMetaColumnName(this.dtColumnNameInfo, str3.Trim());
                        string str4 = "string";
                        str1 += string.Format("{1}{1}private {2} {3};{0}", (object)WBCommon.BR, (object)"    ", (object)str4, (object)str3.ToLower());
                        str1 += WBCommon.SUMMARY.Replace("#TITLE#", "name : " + metaColName);
                        str1 += string.Format("{0}{1}{1}[DataMember]{0}", (object)WBCommon.BR, (object)"    ");
                        str1 += string.Format("{1}{1}public {2} {3}{0}", (object)WBCommon.BR, (object)"    ", (object)str4, (object)str3.ToUpper());
                        str1 += string.Format("{1}{1}{{ {0}", (object)WBCommon.BR, (object)"    ");
                        str1 += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)WBCommon.BR, (object)"    ", (object)str3.ToLower());
                        str1 += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)WBCommon.BR, (object)"    ", (object)str3.ToLower(), (object)str3.ToUpper());
                        str1 += string.Format("{1}{1}}} {0}{0}", (object)WBCommon.BR, (object)"    ");
                    }
                }
                if (this.model.QUERY_DTO_TEXT.Length > 10)
                    this.model.QUERY_DTO_TEXT += WBCommon.BR + WBCommon.BR + WBCommon.BR + "//매개변수 Property ---------------------------------------------------" + WBCommon.BR + WBCommon.BR + str1;
                else
                    this.model.QUERY_DTO_TEXT = str1;
            }
            catch (Exception ex)
            {
                this.ErrorMsg(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요. \n 혹은 Meta정보 제외를 체크해주세요.", ex.ToString()));
            }
        }

        private void MakeDTOCode(DataTable dt)
        {
            try
            {
                string str1 = "";
                foreach (DataColumn column in (System.Data.InternalDataCollectionBase)dt.Columns)
                {
                    string metaColName = model.USERINFO.EXCN_META == true ? "" : this.GetMetaColumnName(this.dtColumnNameInfo, column.ColumnName);
                    string str2 = "string";
                    if (column.DataType == typeof(byte) || column.DataType == typeof(Decimal) || column.DataType == typeof(short) || column.DataType == typeof(int) || column.DataType == typeof(long) || column.DataType == typeof(sbyte) || column.DataType == typeof(float) || column.DataType == typeof(ushort) || column.DataType == typeof(uint) || column.DataType == typeof(ulong))
                        str2 = "decimal";
                    else if (column.DataType == typeof(double))
                        str2 = "double";
                    str1 += string.Format("{1}{1}private {2} {3};{0}", (object)WBCommon.BR, (object)"    ", (object)str2, (object)column.ColumnName.ToLower());
                    str1 += WBCommon.SUMMARY.Replace("#TITLE#", "name : " + metaColName);
                    str1 += string.Format("{0}{1}{1}[DataMember]{0}", (object)WBCommon.BR, (object)"    ");
                    str1 += string.Format("{1}{1}public {2} {3}{0}", (object)WBCommon.BR, (object)"    ", (object)str2, (object)column.ColumnName.ToUpper());
                    str1 += string.Format("{1}{1}{{ {0}", (object)WBCommon.BR, (object)"    ");
                    str1 += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)WBCommon.BR, (object)"    ", (object)column.ColumnName.ToLower());
                    str1 += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)WBCommon.BR, (object)"    ", (object)column.ColumnName.ToLower(), (object)column.ColumnName.ToUpper());
                    str1 += string.Format("{1}{1}}} {0}{0}", (object)WBCommon.BR, (object)"    ");
                }
                this.model.QUERY_DTO_TEXT = str1;
            }
            catch (Exception ex)
            {
                this.ErrorMsg(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요. \n 혹은 Meta정보 제외를 체크해주세요.", ex.ToString()));
            }
        }
        private void MakeDTOCodeV2(DataTable dt)
        {
            try
            {
                string str1 = "";
                foreach (DataColumn column in (System.Data.InternalDataCollectionBase)dt.Columns)
                {
                    string str2 = "string";
                    if (column.DataType == typeof(byte) || column.DataType == typeof(Decimal) || column.DataType == typeof(short) || column.DataType == typeof(int) || column.DataType == typeof(long) || column.DataType == typeof(sbyte) || column.DataType == typeof(float) || column.DataType == typeof(ushort) || column.DataType == typeof(uint) || column.DataType == typeof(ulong))
                        str2 = "decimal";
                    else if (column.DataType == typeof(double))
                        str2 = "double";
                    str1 += string.Format("{1}{1}private {2} {3};{0}", (object)WBCommon.BR, (object)"    ", (object)str2, (object)column.ColumnName.ToLower());
                }
                str1 += WBCommon.BR;
                foreach (DataColumn column in (System.Data.InternalDataCollectionBase)dt.Columns)
                {
                    string metaColName = model.USERINFO.EXCN_META == true ? "" : this.GetMetaColumnName(this.dtColumnNameInfo, column.ColumnName);
                    string str2 = "string";
                    if (column.DataType == typeof(byte) || column.DataType == typeof(Decimal) || column.DataType == typeof(short) || column.DataType == typeof(int) || column.DataType == typeof(long) || column.DataType == typeof(sbyte) || column.DataType == typeof(float) || column.DataType == typeof(ushort) || column.DataType == typeof(uint) || column.DataType == typeof(ulong))
                        str2 = "decimal";
                    else if (column.DataType == typeof(double))
                        str2 = "double";
                    str1 += WBCommon.SUMMARY.Replace("#TITLE#", "name : " + metaColName);
                    str1 += string.Format("{0}{1}{1}[DataMember]{0}", (object)WBCommon.BR, (object)"    ");
                    str1 += string.Format("{1}{1}public {2} {3}{0}", (object)WBCommon.BR, (object)"    ", (object)str2, (object)column.ColumnName.ToUpper());
                    str1 += string.Format("{1}{1}{{ {0}", (object)WBCommon.BR, (object)"    ");
                    str1 += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)WBCommon.BR, (object)"    ", (object)column.ColumnName.ToLower());
                    str1 += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)WBCommon.BR, (object)"    ", (object)column.ColumnName.ToLower(), (object)column.ColumnName.ToUpper());
                    str1 += string.Format("{1}{1}}} {0}{0}", (object)WBCommon.BR, (object)"    ");
                }
                this.model.QUERY_DTO_TEXT = str1;
            }
            catch (Exception ex)
            {
                this.ErrorMsg(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요. \n 혹은 Meta정보 제외를 체크해주세요.", ex.ToString()));
            }
        }
        private void MakeHDataGridExCode(DataTable dt, string serviceName)
        {
            try
            {
                string str1 = "";
                string str2 = "";
                string str3 = "";
                string str4 = "";
                string str5 = "";
                string str6 = "";
                string str7 = serviceName.ToUpper().Replace("SELECT", "");
                string str8 = str7 + "_LIST";
                string str9 = str7 + "_SEL";
                string str10 = str1 + string.Format("<HDataGridEx Grid.Row=\"0\" Margin=\"0,5,0,0\" HeadersVisibility=\"All\" ShowRowIndex=\"True\" SelectionMode=\"Single\"{0}", (object)WBCommon.BR) + string.Format("             CanUserReorderRows=\"True\" CanUserSelectRowHeader=\"True\" CanUserSortColumns=\"False\"{0}", (object)WBCommon.BR) + string.Format("             ItemsSource=\"[Binding {1}]\" SelectedItem=\"[Binding {2}, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged]\">{0}", (object)WBCommon.BR, (object)str8, (object)str9) + string.Format("             <i:Interaction.Triggers>{0}", (object)WBCommon.BR) + string.Format("                 <i:EventTrigger EventName=\"SelectionChanged\">{0}", (object)WBCommon.BR) + string.Format("                     <i:InvokeCommandAction Command=\"[Binding DgrdSelectionChangedCommand]\" CommandParameter=\"[Binding RelativeSource=[RelativeSource AncestorType=[x:Type HDataGridEx], Mode=FindAncestor]]\" />{0}", (object)WBCommon.BR) + string.Format("                 </i:EventTrigger>{0}", (object)WBCommon.BR) + string.Format("             </i:Interaction.Triggers>{0}", (object)WBCommon.BR) + string.Format("             <!--컬럼 시작-->{0}", (object)WBCommon.BR) + string.Format("             <HDataGridEx.Columns>{0}", (object)WBCommon.BR);
                string format1 = str5 + "                 <HDataGridTextColumn Header=\"{3}\" Width=\"80\" Binding=\"[Binding {2}, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged]\" HorizontalAlignment=\"Center\" />{0}";
                string format2 = str6 + "                 <HDataGridTemplateColumn Header=\"{3}\" Width=\"80\" SortMemberPath=\"{2}\">{0}" + "                     <HDataGridTemplateColumn.CellTemplate>{0}" + "                         <DataTemplate>{0}" + "                             <Grid>{0}" + "                                 <HTextBlock Text=\"[Binding {2}]\" VerticalAlignment=\"Center\" HorizontalAlignment=\"Center\" Tag=\"[Binding '']\">{0}" + "                                     <HTextBlock.ToolTip>{0}" + "                                         <ToolTip DataContext=\"[Binding PlacementTarget.Tag, RelativeSource=[RelativeSource Mode=Self]]\">{0}" + "                                             <Run Text=\"[Binding {2}]\"/>{0}" + "                                         </ToolTip>{0}" + "                                     </HTextBlock.ToolTip>{0}" + "                                 </HTextBlock>{0}" + "                             </Grid>{0}" + "                         </DataTemplate>{0}" + "                     </HDataGridTemplateColumn.CellTemplate>{0}" + "                 </HDataGridTemplateColumn>{0}";
                foreach (DataColumn column in (System.Data.InternalDataCollectionBase)dt.Columns)
                {
                    string metaColName = model.USERINFO.EXCN_META == true ? "" : this.GetMetaColumnName(this.dtColumnNameInfo, column.ColumnName);
                    str2 += string.Format(format1, (object)WBCommon.BR, (object)"    ", (object)column.ColumnName, (object)metaColName);
                    str3 += string.Format(format2, (object)WBCommon.BR, (object)"    ", (object)column.ColumnName, (object)metaColName);
                }
                string str11 = str4 + string.Format("             </HDataGridEx.Columns>{0}", (object)WBCommon.BR) + string.Format("             <!--컬럼 끝-->{0}", (object)WBCommon.BR) + string.Format("</HDataGridEx>{0}", (object)WBCommon.BR);
                this.HDataGridEx_Code = "";
                this.HDataGridEx_Code = this.HDataGridEx_Code + "<!--컬럼타입 I : HDataGridTextColumn-->" + WBCommon.BR;
                this.HDataGridEx_Code += this.ConvertBindingFormat(str10 + str2 + str11);
                this.HDataGridEx_Code = this.HDataGridEx_Code + "<!--컬럼타입 I : HDataGridTextColumn-->" + WBCommon.BR + WBCommon.BR;
                this.HDataGridEx_Code = this.HDataGridEx_Code + "<!--컬럼타입 II : HDataGridTemplateColumn-->" + WBCommon.BR;
                this.HDataGridEx_Code += this.ConvertBindingFormat(str10 + str3 + str11);
                this.HDataGridEx_Code = this.HDataGridEx_Code + "<!--컬럼타입 II : HDataGridTemplateColumn-->" + WBCommon.BR;
            }
            catch (Exception ex)
            {
                this.ErrorMsg(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요. \n 혹은 Meta정보 제외를 체크해주세요.", ex.ToString()));
            }
        }

        private void miHDataGrid_Click(object sender, RoutedEventArgs e)
        {
            OpenCodeWIndow(this.HDataGridEx_Code);
        }

        private void miDataGrid_Click(object sender, RoutedEventArgs e)
        {
            string DataGridCode = Regex.Replace(this.HDataGridEx_Code, @"HDataGridEx|HDataGrid", "DataGrid");
            DataGridCode = Regex.Replace(DataGridCode, @"HText", "Text");
            DataGridCode = Regex.Replace(DataGridCode, @"ShowRowIndex[^\s]+|CanUserReorderRows[^\s]+ |CanUserSelectRowHeader[^\s]+|HorizontalAlignment[^\s]+", string.Empty);            
            OpenCodeWIndow(DataGridCode);
        }

        private void GridSplitter_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            try
            {
                grdMain.ColumnDefinitions[0].Width = new GridLength(0.4, GridUnitType.Star);
                grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                grdMain.ColumnDefinitions[2].Width = new GridLength(0.6, GridUnitType.Star);
            }
            catch (Exception)
            {

            }
        }

        private void ComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            AutoQueryDTOText();
        }

        private void CheckBox_Unchecked(object sender, RoutedEventArgs e)
        {
            this.model.USERINFO.SYNC = "N";
            this.model.SYNC_TEXT = "";
            this.model.SyncText("");
            this.model.SaveUserInfo();
        }

        private void TextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            BindingExpression bindingExpression = ((TextBox)sender).GetBindingExpression(TextBox.TextProperty);
            bindingExpression.UpdateSource();
            
            Binding myBinding = BindingOperations.GetBinding((TextBox)sender, TextBox.TextProperty);
            if(myBinding != null && myBinding.Path.Path == "SYNC_TEXT")
            {
                if (timer == null)
                {
                    timer = new DispatcherTimer();
                    timer.Interval = TimeSpan.FromMilliseconds(500);
                    timer.Tick += new EventHandler(handleTypingTimerTimeout);
                }
                timer.Stop();                
                timer.Start();               
            }
            else if (myBinding != null && myBinding.Path.Path == "DTO_TEXT")
            {
                if (timer2 == null)
                {
                    timer2 = new DispatcherTimer();
                    timer2.Interval = TimeSpan.FromMilliseconds(500);
                    timer2.Tick += new EventHandler(handleTypingTimerTimeout2);
                }
                timer2.Stop();                
                timer2.Start();
            }
            else if (myBinding != null && myBinding.Path.Path == "VIEW_TEXT")
            {
                if (timer3 == null)
                {
                    timer3 = new DispatcherTimer();
                    timer3.Interval = TimeSpan.FromMilliseconds(500);
                    timer3.Tick += new EventHandler(handleTypingTimerTimeout3);
                }
                timer3.Stop();                
                timer3.Start();
            }
        }
        private void handleTypingTimerTimeout(object sender, EventArgs e)
        {
            var timer = sender as DispatcherTimer; // WPF
            if (timer == null)
            {
                return;
            }
            //work
            this.model.SyncAutoText();
            // The timer must be stopped! We want to act only once per keystroke.
            timer.Stop();
        }
        private void handleTypingTimerTimeout2(object sender, EventArgs e)
        {
            var timer = sender as DispatcherTimer; // WPF
            if (timer == null)
            {
                return;
            }
            //work
            this.model.AutoChgText("2");
            // The timer must be stopped! We want to act only once per keystroke.
            timer.Stop();
        }
        private void handleTypingTimerTimeout3(object sender, EventArgs e)
        {
            var timer = sender as DispatcherTimer; // WPF
            if (timer == null)
            {
                return;
            }
            //work
            this.model.AutoChgText("4");
            // The timer must be stopped! We want to act only once per keystroke.
            timer.Stop();
        }
        private void ComboBox_DataContextChanged(object sender, DependencyPropertyChangedEventArgs e)
        {

        }        

        private void cboDataType_TextChanged(object sender, TextChangedEventArgs e)
        {           
            this.model.DATA_TYPE_NM = (e.OriginalSource as TextBox).Text;
        }

        private void UCBase_Loaded(object sender, RoutedEventArgs e)
        {
            if (model != null)
                this.model.LoadUserInfo();
        }
        public void ErrorMsg(string msg) => this.OwnerWindow.ShowErrorMsgBox(msg);
    }
}
