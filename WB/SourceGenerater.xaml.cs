using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
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
    /// SourceGenerater.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class SourceGenerater : UCBase
    {
        private SourceGeneraterData model;
        private DataTable dtColumnNameInfo = (DataTable)null;
        private string HDataGridEx_Code = "";
        private DispatcherTimer timer;
        private string Author = "";
        public SourceGenerater()
        {
            InitializeComponent();
            this.model = DataContext as SourceGeneraterData;

            if (this.OwnerWindow == null || this.OwnerWindow.OcBasicSetting == null)
                return;
            BasicSetting basicSetting = this.OwnerWindow.OcBasicSetting.Where<BasicSetting>((Func<BasicSetting, bool>)(d => d.CODE == "UserName")).FirstOrDefault<BasicSetting>();
            if (basicSetting != null)
                this.Author = basicSetting.VALUE;
        }
        private void UCBase_Loaded(object sender, RoutedEventArgs e)
        {            
            if (this.OwnerWindow == null || this.OwnerWindow.OcBasicSetting == null)
                return;
            BasicSetting basicSetting = this.OwnerWindow.OcBasicSetting.Where<BasicSetting>((Func<BasicSetting, bool>)(d => d.CODE == "UserName")).FirstOrDefault<BasicSetting>();
            if (basicSetting != null)
                this.Author = basicSetting.VALUE;
        }
        private void txtEqs_TextChanged(object sender, TextChangedEventArgs e)
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
            MakeCode();
            // The timer must be stopped! We want to act only once per keystroke.
            timer.Stop();
        }
        private void MakeDTOCodeAndGridCode(string query, string serviceName)
        {
            try
            {
                foreach (Match match in Regex.Matches(query, "(?<!\\w):\\w+"))
                {
                    if (match.Value.Length >= 4)
                        query = query.Replace(match.Value, "''");
                }
                DataSet dataSet = this.DBSvc.ExecuteQueryForMakeDTO2(query);
                if (dataSet == null)
                    return;
                DataTable table = dataSet.Tables[0];
                if(!model.USERINFO.EXCN_META)
                    this.dtColumnNameInfo = this.GetColumnNameInfo(table);
                this.MakeDTOCode(table);
                this.MakeHDataGridExCode(table, serviceName);
            }
            catch (Exception ex)
            {
                this.model.DTO_TEXT = "DTO Property 생성실패!!!" + Environment.NewLine + ex.ToString();
            }
        }

        private void MakeDTOCode(DataTable dt)
        {
            try
            {
                string str1 = "";
                foreach (DataColumn column in (System.Data.InternalDataCollectionBase)dt.Columns)
                {
                    string title = model.USERINFO.EXCN_META == true ? "" : this.GetMetaColumnName(this.dtColumnNameInfo, column.ColumnName);
                    string str2 = "string";
                    if (column.DataType == typeof(byte) || column.DataType == typeof(Decimal) || column.DataType == typeof(short) || column.DataType == typeof(int) || column.DataType == typeof(long) || column.DataType == typeof(sbyte) || column.DataType == typeof(float) || column.DataType == typeof(ushort) || column.DataType == typeof(uint) || column.DataType == typeof(ulong))
                        str2 = "decimal";
                    else if (column.DataType == typeof(double))
                        str2 = "double";
                    str1 += string.Format("{1}{1}private {2} {3};{0}", (object)WBCommon.BR, (object)"    ", (object)str2, (object)column.ColumnName.ToLower());
                    str1 += WBCommon.SUMMARY.Replace("#TITLE#", "name : " + title);
                    str1 += string.Format("{0}{1}{1}[DataMember]{0}", (object)WBCommon.BR, (object)"    ");
                    str1 += string.Format("{1}{1}public {2} {3}{0}", (object)WBCommon.BR, (object)"    ", (object)str2, (object)column.ColumnName.ToUpper());
                    str1 += string.Format("{1}{1}{{ {0}", (object)WBCommon.BR, (object)"    ");
                    str1 += string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)WBCommon.BR, (object)"    ", (object)column.ColumnName.ToLower());
                    str1 += string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)WBCommon.BR, (object)"    ", (object)column.ColumnName.ToLower(), (object)column.ColumnName.ToUpper());
                    str1 += string.Format("{1}{1}}} {0}{0}", (object)WBCommon.BR, (object)"    ");
                }
                this.model.DTO_TEXT = str1;
            }
            catch (Exception ex)
            {
                this.OwnerWindow.ShowErrorMsgBox(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요. \n 혹은 Meta정보 제외를 체크해주세요.", ex.ToString()));
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
                this.OwnerWindow.ShowErrorMsgBox(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요. \n 혹은 Meta정보 제외를 체크해주세요.", ex.ToString()));
            }
        }


        private void MakeDTOPropertyEQSParameterFromQuery(string query)
        {
            try
            {
                query = this.DBSvc.RemoveComment2(query);
                if (string.IsNullOrEmpty(query))
                    return;
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
                if (this.model.DTO_TEXT.Length > 10)
                    this.model.DTO_TEXT += WBCommon.BR + WBCommon.BR + WBCommon.BR + "//매개변수 Property ---------------------------------------------------" + WBCommon.BR + WBCommon.BR + str1;
                else
                    this.model.DTO_TEXT = str1;
            }
            catch (Exception ex)
            {
                this.OwnerWindow.ShowErrorMsgBox(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요. \n 혹은 Meta정보 제외를 체크해주세요.", ex.ToString()));
            }
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
                this.model.DTO_TEXT = str1;
            }
            catch (Exception ex)
            {
                this.OwnerWindow.ShowErrorMsgBox(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요. \n 혹은 Meta정보 제외를 체크해주세요.", ex.ToString()));
            }
        }
        private bool ChkPackageOrProcedure(string query)
        {
            bool pkgYn = false;

            query = this.DBSvc.RemoveComment(query);
            if (query.Length < 6) return pkgYn;
            query = query.Substring(0, query.Length - 6);
            query = query.Trim();
            if (query.IndexOf("SELECT") <= -1 && (query.ToUpper().IndexOf("PKG") > -1 || query.ToUpper().IndexOf("PC_") > -1))
            {
                pkgYn = true;
            }
            return pkgYn;
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

        private string MakeDLCode(
      string svc_mode,
      string queryId,
      string serviceName,
      string dtoName,
      string outDtoName)
        {
            string str1 = "";
            string str2 = "";
            string returnObjType = this.GetReturnObjType(outDtoName);
            bool flag1 = false;
            if (dtoName.IndexOf("HSFDTOCollectionBaseObject") > -1)
                flag1 = true;
            string str3 = str2 + string.Format("{0}{0}/// <summary>", (object)"    ") + string.Format("{0}{1}{1}/// name         : {2}", (object)WBCommon.BR, (object)"    ", (object)this.model.SUMMARY_DESC.Trim()) + string.Format("{0}{1}{1}/// desc         : {2}", (object)WBCommon.BR, (object)"    ", (object)this.model.SUMMARY_DESC.Trim()) + string.Format("{0}{1}{1}/// author       : {2}", (object)WBCommon.BR, (object)"    ", (object)this.Author) + string.Format("{0}{1}{1}/// create date  : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// update date  : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// </summary>", (object)WBCommon.BR, (object)"    ");
            bool? isChecked = this.model.EQS_SEL == null || this.model.EQS_SEL.QUERYTEXT == null ? false : this.ChkPackageOrProcedure(this.model.EQS_SEL.QUERYTEXT);
            bool flag2 = true;
            string str4;
            if (isChecked.GetValueOrDefault() == flag2 & isChecked.HasValue)
            {
                if (svc_mode == "S")
                {
                    string str5 = str1 + string.Format("{0}{1}{1}public {4} {2}({3} inObj)", (object)WBCommon.BR, (object)"    ", (object)serviceName, (object)dtoName, (object)returnObjType) + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"DataItem item = new DataItem();") + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"//조회 프로시저 매개변수");
                    foreach (SourceGenerater_INOUT SourceGenerater_INOUT in this.model.PAKAGE_LIST)
                    {
                        if (SourceGenerater_INOUT.IN_OUT == "IN")
                            str5 += string.Format("{0}{1}{1}{1}item.add(\"{2}\", inObj.{2});", (object)WBCommon.BR, (object)"    ", (object)SourceGenerater_INOUT.ARGUMENT_NAME);
                    }
                    str4 = str5 + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}DataSet ds = this.DacAgent.ExecuteDataSet(CommandType.StoredProcedure, item, \"{2}\", QueryType.QueryStore);", (object)WBCommon.BR, (object)"    ", (object)queryId) + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}{2} result = ds.Tables[0].ToDTO(typeof({2})) as {2};", (object)WBCommon.BR, (object)"    ", (object)returnObjType) + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}return result;", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
                }
                else
                {
                    string str6 = str1 + string.Format("{0}{1}{1}public Result_OUT {2}({3} inObj)", (object)WBCommon.BR, (object)"    ", (object)serviceName, (object)dtoName) + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}Result_OUT result = new Result_OUT();", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"DataItem item = new DataItem();") + string.Format("{0}", (object)WBCommon.BR);
                    string str7;
                    if (flag1)
                    {
                        string str8 = str6 + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"foreach (var param_item in inObj)") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"item.Clear();") + string.Format("{0}", (object)WBCommon.BR);
                        foreach (SourceGenerater_INOUT SourceGenerater_INOUT in this.model.PAKAGE_LIST)
                            str8 = !(SourceGenerater_INOUT.IN_OUT == "IN") ? str8 + string.Format("{0}{1}{1}{1}{1}item.add(\"{2}\", ParameterDirection.Output);", (object)WBCommon.BR, (object)"    ", (object)SourceGenerater_INOUT.ARGUMENT_NAME) : str8 + string.Format("{0}{1}{1}{1}{1}item.add(\"{2}\", param_item.{2});", (object)WBCommon.BR, (object)"    ", (object)SourceGenerater_INOUT.ARGUMENT_NAME);
                        str7 = str8 + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}{1}string query = QueryProvider.GetQuery(\"{2}\");", (object)WBCommon.BR, (object)"    ", (object)queryId) + string.Format("{0}{1}{1}{1}{1}this.DacAgent.ExecuteNonQuery(CommandType.StoredProcedure, query, item);", (object)WBCommon.BR, (object)"    ") + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}{1}if (item[\"IO_ERR_YN\"].data.ToString() == \"Y\")", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{1}{1}result.RESULT = item[\"IO_ERR_YN\"].data.ToString(); // OUT 매개변수 확인 필요!", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}{1}result.MESSAGE = item[\"IO_ERR_MSG\"].data.ToString(); // OUT 매개변수 확인 필요!", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}{1}result.IsSucess = false;", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}") + string.Format("{0}{1}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"else") + string.Format("{0}{1}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{1}{1}result.RESULT = \"N\";", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}{1}result.MESSAGE = item[\"IO_ERR_MSG\"].data.ToString(); // OUT 매개변수 확인 필요!", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}{1}result.IsSucess = true;", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
                    }
                    else
                    {
                        foreach (SourceGenerater_INOUT SourceGenerater_INOUT in this.model.PAKAGE_LIST)
                            str6 = !(SourceGenerater_INOUT.IN_OUT == "IN") ? str6 + string.Format("{0}{1}{1}{1}item.add(\"{2}\", ParameterDirection.Output);", (object)WBCommon.BR, (object)"    ", (object)SourceGenerater_INOUT.ARGUMENT_NAME) : str6 + string.Format("{0}{1}{1}{1}item.add(\"{2}\", inObj.{2});", (object)WBCommon.BR, (object)"    ", (object)SourceGenerater_INOUT.ARGUMENT_NAME);
                        str7 = str6 + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}string query = QueryProvider.GetQuery(\"{2}\");", (object)WBCommon.BR, (object)"    ", (object)queryId) + string.Format("{0}{1}{1}{1}this.DacAgent.ExecuteNonQuery(CommandType.StoredProcedure, query, item);", (object)WBCommon.BR, (object)"    ") + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}if (item[\"IO_ERR_YN\"].data.ToString() == \"Y\")", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{1}result.RESULT = item[\"IO_ERR_YN\"].data.ToString(); // OUT 매개변수 확인 필요!", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}result.MESSAGE = item[\"IO_ERR_MSG\"].data.ToString(); // OUT 매개변수 확인 필요!", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}result.IsSucess = false;", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"else") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{1}result.RESULT = \"N\";", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}result.MESSAGE = item[\"IO_ERR_MSG\"].data.ToString(); // OUT 매개변수 확인 필요!", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}result.IsSucess = true;", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
                    }
                    str4 = str7 + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}return result;", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
                }
            }
            else if (svc_mode == "S")
            {
                str4 = str1 + string.Format("{0}{1}{1}public {4} {2}({3} inObj)", (object)WBCommon.BR, (object)"    ", (object)serviceName, (object)dtoName, (object)returnObjType) + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{2} result =", (object)WBCommon.BR, (object)"    ", (object)returnObjType) + string.Format("{0}{1}{1}{1}{1}({2})this.DacAgent.Fill(\"{3}\", inObj, typeof({2}));", (object)WBCommon.BR, (object)"    ", (object)returnObjType, (object)queryId) + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}return result;", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
            }
            else
            {
                string str9 = str1 + string.Format("{0}{1}{1}public Result_OUT {2}({3} inObj)", (object)WBCommon.BR, (object)"    ", (object)serviceName, (object)dtoName) + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}Result_OUT result = new Result_OUT();", (object)WBCommon.BR, (object)"    ");
                string str10 = (!flag1 ? str9 + string.Format("{0}{1}{1}{1}result.RESULT = Convert.ToInt16(this.DacAgent.ExecuteNonQuery(\"{2}\", inObj));", (object)WBCommon.BR, (object)"    ", (object)queryId) : str9 + string.Format("{0}{1}{1}{1}result.RESULT = this.DacAgent.ExecuteBatch(\"\", inObj, \"{2}\", CommandType.Text, QueryType.QueryStore);", (object)WBCommon.BR, (object)"    ", (object)queryId)) + string.Format("{0}", (object)WBCommon.BR, (object)"    ");
                str4 = (!flag1 ? str10 + string.Format("{0}{1}{1}{1}if (Convert.ToInt16(result.RESULT) > 0)", (object)WBCommon.BR, (object)"    ") : str10 + string.Format("{0}{1}{1}{1}if (Convert.ToInt16(result.RESULT) != 0)", (object)WBCommon.BR, (object)"    ")) + string.Format("{0}{1}{1}{1}{1}result.IsSucess = true;", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}else", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{1}result.IsSucess = false;", (object)WBCommon.BR, (object)"    ") + string.Format("{0}", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}return result;", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
            }
            return str3 + str4;
        }

        private string MakeBLCode(
          string svc_mode,
          string queryId,
          string serviceName,
          string dtoName,
          string outDtoName)
        {
            string str1 = "";
            string str2 = "";
            string returnObjType = this.GetReturnObjType(outDtoName);
            string str3 = str2 + string.Format("{0}{0}/// <summary>", (object)"    ") + string.Format("{0}{1}{1}/// name               : {2}", (object)WBCommon.BR, (object)"    ", (object)this.model.SUMMARY_DESC.Trim()) + string.Format("{0}{1}{1}/// i/f inheritance yn : N", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}/// logic              : {2}", (object)WBCommon.BR, (object)"    ", (object)this.model.SUMMARY_DESC.Trim()) + string.Format("{0}{1}{1}/// desc               : {2}", (object)WBCommon.BR, (object)"    ", (object)this.model.SUMMARY_DESC.Trim()) + string.Format("{0}{1}{1}/// author             : {2}", (object)WBCommon.BR, (object)"    ", (object)this.Author) + string.Format("{0}{1}{1}/// create date        : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// update date        : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// </summary>", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}/// <param name=\"inobj\"></param>", (object)WBCommon.BR, (object)"    ");
            string str4;
            string str5;
            if (svc_mode == "S")
            {
                str4 = str3 + string.Format("{0}{1}{1}[HSFTransaction(HSFTransactionOption.Supported)]", (object)WBCommon.BR, (object)"    ");
                str5 = str1 + string.Format("{0}{1}{1}public {4} {2}({3} inObj)", (object)WBCommon.BR, (object)"    ", (object)serviceName, (object)dtoName, (object)returnObjType) + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}using ({2} com = new {2}())", (object)WBCommon.BR, (object)"    ", this.model.IN_DTO.Replace("_INOUT", "DL")) + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{1}return com.{2}(inObj);", (object)WBCommon.BR, (object)"    ", (object)serviceName) + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}") + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
            }
            else
            {
                str4 = str3 + string.Format("{0}{1}{1}[HSFTransaction(HSFTransactionOption.Required)]", (object)WBCommon.BR, (object)"    ");
                str5 = str1 + string.Format("{0}{1}{1}public Result_OUT {2}({3} inObj)", (object)WBCommon.BR, (object)"    ", (object)serviceName, (object)dtoName) + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}using ({2} com = new {2}())", (object)WBCommon.BR, (object)"    ", this.model.IN_DTO.Replace("_INOUT", "DL")) + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{1}return com.{2}(inObj);", (object)WBCommon.BR, (object)"    ", (object)serviceName) + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}") + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
            }
            return str4 + str5;
        }

        private string MakeIFCode(
          string svc_mode,
          string queryId,
          string serviceName,
          string dtoName,
          string outDtoName)
        {
            string[] strArray = queryId.Split('.');
            string str1 = strArray.Length <= 1 ? queryId : string.Format("AS-MS-{0}-{1}-XX", (object)strArray[strArray.Length - 2], (object)strArray[strArray.Length - 1]);
            string str2 = "";
            string str3 = "";
            string returnObjType = this.GetReturnObjType(outDtoName);
            string str4 = str3 + string.Format("{0}{0}/// <summary>", (object)"    ") + string.Format("{0}{1}{1}/// id          : {2}", (object)WBCommon.BR, (object)"    ", (object)str1) + string.Format("{0}{1}{1}/// name        : {2}", (object)WBCommon.BR, (object)"    ", (object)this.model.SUMMARY_DESC.Trim()) + string.Format("{0}{1}{1}/// external yn : N", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}/// desc        : {2}", (object)WBCommon.BR, (object)"    ", (object)this.model.SUMMARY_DESC.Trim()) + string.Format("{0}{1}{1}/// author      : {2}", (object)WBCommon.BR, (object)"    ", (object)this.Author) + string.Format("{0}{1}{1}/// create date : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// update date : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// </summary>", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}[OperationContract]", (object)WBCommon.BR, (object)"    ");
            string str5;
            if (svc_mode == "S")
                str5 = str2 + string.Format("{0}{1}{1}{4} {2}({3} inObj);", (object)WBCommon.BR, (object)"    ", (object)serviceName, (object)dtoName, (object)returnObjType);
            else
                str5 = str2 + string.Format("{0}{1}{1}Result_OUT {2}({3} inObj);", (object)WBCommon.BR, (object)"    ", (object)serviceName, (object)dtoName);
            return str4 + str5;
        }

        private string MakePropertyCode(
          string svc_mode,
          string queryId,
          string serviceName,
          string dtoName)
        {
            if (svc_mode != "S")
                return "";
            string str1 = "";
            string str2 = "";
            string str3 = serviceName.ToUpper().Replace("SELECT", "");
            bool? isChecked = (bool)this.rdoCollection.IsChecked ? (bool)this.rdoCollection.IsChecked : (bool)this.rdoList.IsChecked ? (bool)this.rdoList.IsChecked : false;
            bool flag = true;
            string str4;
            string str5;
            if (isChecked.GetValueOrDefault() == flag & isChecked.HasValue)
            {
                str4 = str3 + "_LIST";
                str5 = "리스트";
            }
            else
            {
                str4 = str3 + "_ITEM";
                str5 = "항목";
            }
            string returnObjType = this.GetReturnObjType(dtoName);
            string str6 = str2 + string.Format("{0}{0}/// <summary>", (object)"    ") + string.Format("{0}{1}{1}/// name         : {2}", (object)WBCommon.BR, (object)"    ", (object)(this.model.SUMMARY_DESC.Trim() + " " + str5)) + string.Format("{0}{1}{1}/// desc         : {2}", (object)WBCommon.BR, (object)"    ", (object)(this.model.SUMMARY_DESC.Trim() + " " + str5)) + string.Format("{0}{1}{1}/// author       : {2}", (object)WBCommon.BR, (object)"    ", (object)this.Author) + string.Format("{0}{1}{1}/// create date  : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// update date  : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// </summary>", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}/// <remarks></remarks>", (object)WBCommon.BR, (object)"    ");
            return str1 + string.Format("{1}{1}private {2} {3} {4}{2}{5};", (object)WBCommon.BR, (object)"    ", (object)returnObjType, (object)str4.ToLower(), " = new ", "()") + WBCommon.BR + str6 + WBCommon.BR + string.Format("{1}{1}public {2} {3}{0}", (object)WBCommon.BR, (object)"    ", (object)returnObjType, (object)str4) + string.Format("{1}{1}{{ {0}", (object)WBCommon.BR, (object)"    ") + string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)WBCommon.BR, (object)"    ", (object)str4.ToLower()) + string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)WBCommon.BR, (object)"    ", (object)str4.ToLower(), (object)str4) + string.Format("{1}{1}}} {0}{0}", (object)WBCommon.BR, (object)"    ");
        }

        private string MakePropertyCode2(
          string svc_mode,
          string queryId,
          string serviceName,
          string dtoName)
        {
            if (svc_mode != "S")
                return "";
            string str1 = "";
            string str2 = "";
            string str3 = serviceName.ToUpper().Replace("SELECT", "") + "_SEL";
            string str4 = dtoName;
            string str5 = str2 + string.Format("{0}{0}/// <summary>", (object)"    ") + string.Format("{0}{1}{1}/// name         : {2}", (object)WBCommon.BR, (object)"    ", (object)(this.model.SUMMARY_DESC.Trim() + " 선택 DTO")) + string.Format("{0}{1}{1}/// desc         : {2}", (object)WBCommon.BR, (object)"    ", (object)(this.model.SUMMARY_DESC.Trim() + " 선택 DTO")) + string.Format("{0}{1}{1}/// author       : {2}", (object)WBCommon.BR, (object)"    ", (object)this.Author) + string.Format("{0}{1}{1}/// create date  : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// update date  : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// </summary>", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}/// <remarks></remarks>", (object)WBCommon.BR, (object)"    ");
            return str1 + string.Format("{1}{1}private {2} {3};", (object)WBCommon.BR, (object)"    ", (object)str4, (object)str3.ToLower()) + WBCommon.BR + str5 + WBCommon.BR + string.Format("{1}{1}public {2} {3}{0}", (object)WBCommon.BR, (object)"    ", (object)str4, (object)str3) + string.Format("{1}{1}{{ {0}", (object)WBCommon.BR, (object)"    ") + string.Format("{1}{1}{1}get {{ return this.{2}; }}{0}", (object)WBCommon.BR, (object)"    ", (object)str3.ToLower()) + string.Format("{1}{1}{1}set {{ if (this.{2} != value) {{ this.{2} = value; OnPropertyChanged(\"{3}\", value); }} }}{0}", (object)WBCommon.BR, (object)"    ", (object)str3.ToLower(), (object)str3) + string.Format("{1}{1}}} {0}{0}", (object)WBCommon.BR, (object)"    ");
        }

        private string MakeMethodCode(
          string svc_mode,
          string queryId,
          string serviceName,
          string dtoName,
          string outDtoName)
        {
            string str1 = "";
            string str2 = "";
            string returnObjType = this.GetReturnObjType(outDtoName);
            string str3 = str2 + string.Format("{0}{0}/// <summary>", (object)"    ") + string.Format("{0}{1}{1}/// name         : {2}", (object)WBCommon.BR, (object)"    ", (object)this.model.SUMMARY_DESC.Trim()) + string.Format("{0}{1}{1}/// desc         : {2}", (object)WBCommon.BR, (object)"    ", (object)this.model.SUMMARY_DESC.Trim()) + string.Format("{0}{1}{1}/// author       : {2}", (object)WBCommon.BR, (object)"    ", (object)this.Author) + string.Format("{0}{1}{1}/// create date  : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// update date  : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// </summary>", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}/// <remarks></remarks>", (object)WBCommon.BR, (object)"    ");
            string str4;
            if (svc_mode == "S")
            {
                string str5 = serviceName.ToUpper().Replace("SELECT", "");
                string str6 = "this." + str5 + "_SEL";
                bool? isChecked1 = (bool)this.rdoCollection.IsChecked ? (bool)this.rdoCollection.IsChecked : (bool)this.rdoList.IsChecked ? (bool)this.rdoList.IsChecked : false;
                bool flag1 = true;
                string str7 = "this." + (!(isChecked1.GetValueOrDefault() == flag1 & isChecked1.HasValue) ? str5 + "_ITEM" : str5 + "_LIST");
                string str8 = str1 + string.Format("{0}{1}{1}private void {2}(object p)", (object)WBCommon.BR, (object)"    ", (object)serviceName) + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{2} param = new {2}();", (object)WBCommon.BR, (object)"    ", (object)dtoName) + string.Format("{0}{1}{1}{1}{4} = ({3})UIMiddlewareAgent.InvokeBizService(this, BIZ_CLASS, \"{2}\", param);", (object)WBCommon.BR, (object)"    ", (object)serviceName, (object)returnObjType, (object)str7);
                bool? isChecked2 = (bool)this.rdoCollection.IsChecked ? (bool)this.rdoCollection.IsChecked : (bool)this.rdoList.IsChecked ? (bool)this.rdoList.IsChecked : false;
                bool flag2 = true;
                if (isChecked2.GetValueOrDefault() == flag2 & isChecked2.HasValue)
                    str8 = str8 + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}if ({2}.Count > 0)", (object)WBCommon.BR, (object)"    ", (object)str7) + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{1}{2} = {3}.FirstOrDefault();", (object)WBCommon.BR, (object)"    ", (object)str6, (object)str7) + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
                str4 = str8 + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
            }
            else
                str4 = str1 + string.Format("{0}{1}{1}private void {2}(object p)", (object)WBCommon.BR, (object)"    ", (object)serviceName) + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}if (MsgBox.Display(\"저장하겠습니까?\", MessageType.MSG_TYPE_QUESTION, messageButton: MessageBoxButton.YesNo) != MessageBoxResult.Yes) return;", (object)WBCommon.BR, (object)"    ") + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}{2} param = new {2}();", (object)WBCommon.BR, (object)"    ", (object)dtoName) + string.Format("{0}{1}{1}{1}Result_OUT result = (Result_OUT)UIMiddlewareAgent.InvokeBizService(this, BIZ_CLASS, \"{2}\", param);", (object)WBCommon.BR, (object)"    ", (object)serviceName) + string.Format("{0}", (object)WBCommon.BR) + string.Format("{0}{1}{1}{1}if (result.IsSucess)", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{1}MsgBox.Display(\"저장 되었습니다.\", MessageType.MSG_TYPE_INFORMATION, Owner: this.OwnerWindow, TimeSpan: 3000);", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"else") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{1}MsgBox.Display(\"저장에 실패 하였습니다.\", MessageType.MSG_TYPE_ERROR);", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}") + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
            return str3 + str4;
        }

        private string MakeCmdCode(
          string svc_mode,
          string queryId,
          string serviceName,
          string dtoName)
        {
            string str1 = "";
            string str2 = "";
            string str3 = this.FirstLetterToLower(serviceName) + "Command";
            string str4 = str2 + string.Format("{0}{0}/// <summary>", (object)"    ") + string.Format("{0}{1}{1}/// name         : {2}", (object)WBCommon.BR, (object)"    ", (object)this.model.SUMMARY_DESC.Trim()) + string.Format("{0}{1}{1}/// desc         : {2}", (object)WBCommon.BR, (object)"    ", (object)this.model.SUMMARY_DESC.Trim()) + string.Format("{0}{1}{1}/// author       : {2}", (object)WBCommon.BR, (object)"    ", (object)this.Author) + string.Format("{0}{1}{1}/// create date  : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// update date  : {2}", (object)WBCommon.BR, (object)"    ", (object)DateTime.Now.ToString("yyyy-MM-dd")) + string.Format("{0}{1}{1}/// </summary>", (object)WBCommon.BR, (object)"    ") + string.Format("{0}{1}{1}/// <remarks></remarks>", (object)WBCommon.BR, (object)"    ");
            return str1 + string.Format("{1}{1}private ICommand {2};", (object)WBCommon.BR, (object)"    ", (object)str3) + WBCommon.BR + str4 + string.Format("{0}{1}{1}public ICommand {2}Command", (object)WBCommon.BR, (object)"    ", (object)serviceName) + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"get") + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"{") + string.Format("{0}{1}{1}{1}{1}if ({2} == null)", (object)WBCommon.BR, (object)"    ", (object)str3) + string.Format("{0}{1}{1}{1}{1}{1}{2} = new RelayCommand(p => this.{3}(p));", (object)WBCommon.BR, (object)"    ", (object)str3, (object)serviceName) + string.Format("{0}{1}{1}{1}{1}return {2};", (object)WBCommon.BR, (object)"    ", (object)str3) + string.Format("{0}{1}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}") + string.Format("{0}{1}{1}{2}", (object)WBCommon.BR, (object)"    ", (object)"}");
        }

        private string GetReturnObjType(string dtoName)
        {
            bool? isChecked = (bool)this.rdoCollection.IsChecked ? (bool)this.rdoCollection.IsChecked : (bool)this.rdoList.IsChecked ? (bool)this.rdoList.IsChecked : false;
            bool flag = true;
            string classType = "";
            if ((bool)this.rdoCollection.IsChecked)
            {
                classType = "HSFDTOCollectionBaseObject";
            }
            else if ((bool)this.rdoList.IsChecked)
            {
                classType = "List";
            }
            return !(isChecked.GetValueOrDefault() == flag & isChecked.HasValue) ? dtoName : string.Format("{0}<{1}>", (object)classType, (object)dtoName);
        }
        private string FirstLetterToLower(string str)
        {
            if (str == null)
                return (string)null;
            if (str.Length < 1) return (string)null;

            return str.Length > 1 ? char.ToLower(str[0]).ToString() + str.Substring(1) : str.ToLower();
        }
        private string GetQueryText()
        {
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.LoadXml(this.model.EQS_LIST[0].QUERYTEXT);
            string queryText = xmlDocument.SelectNodes("sql")[0].InnerText.Trim();
            queryText.ToUpper();
            string str = "";
            //string str = ((IEnumerable<string>)model.EQS_LIST[0].QUERYTEXT.Split(new string[1]
            //  {
            //    Environment.NewLine
            //  }, StringSplitOptions.None)).ToList().FirstOrDefault((Func<string, bool>)(d => d.Trim().ToUpper().StartsWith("DESC :")));

            foreach (var item in model.EQS_LIST[0].QUERYTEXT.Split(new char[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries))
            {
                if (item.Trim().ToUpper().StartsWith("DESC :"))
                {
                    str = item;
                    break;
                }
            }
            if (!string.IsNullOrEmpty(str))
            {
                if (str.Split(':').Length > 1)
                    this.model.SUMMARY_DESC = str.Split(':')[1].Trim();
            }
           

            return queryText;
        }
        private void MakeCode()
        {
            try
            {
                if (this.model.EQS_ID == null || this.model.IN_DTO == null || string.IsNullOrEmpty(this.model.OUT_DTO))
                    return;
                this.model.PKG_NM = "";
                //this.model.SUMMARY_DESC = "";
                string queryId = this.model.EQS_ID.Trim();
                string[] strArray = queryId.Split('.');
                string serviceName = strArray[strArray.Length - 1];
                string dtoName = this.model.IN_DTO.Trim();
                string str1 = this.model.OUT_DTO.Trim();
                string svc_mode = "S";
                if (serviceName.ToUpper().IndexOf("UPDATE") > -1)
                    svc_mode = "U";
                if (serviceName.ToUpper().IndexOf("INSERT") > -1)
                    svc_mode = "U";
                if (serviceName.ToUpper().IndexOf("SAVE") > -1)
                    svc_mode = "U";
                if (serviceName.ToUpper().IndexOf("DELETE") > -1)
                    svc_mode = "U";

                string query = "";
                this.model.SearchEQSCommand.Execute(null);
                if (this.model.EQS_SEL != null && this.model.EQS_SEL.QUERYTEXT != null)
                    query = GetQueryText();

                this.model.DL_TEXT = this.MakeDLCode(svc_mode, queryId, serviceName, dtoName, str1);
                this.model.BIZ_TEXT = this.MakeBLCode(svc_mode, queryId, serviceName, dtoName, str1);
                this.model.IF_TEXT = this.MakeIFCode(svc_mode, queryId, serviceName, dtoName, str1);
                string str2 = "";
                bool? isChecked = (bool)this.rdoCollection.IsChecked ? (bool)this.rdoCollection.IsChecked : (bool)this.rdoList.IsChecked ? (bool)this.rdoList.IsChecked : false;
                bool flag = true;
                if (isChecked.GetValueOrDefault() == flag & isChecked.HasValue)
                    str2 = this.MakePropertyCode2(svc_mode, queryId, serviceName, str1) + Environment.NewLine + Environment.NewLine;
                this.model.PROPERTY_TEXT = str2 + this.MakePropertyCode(svc_mode, queryId, serviceName, str1);
                this.model.METHOD_TEXT = this.MakeMethodCode(svc_mode, queryId, serviceName, dtoName, str1);
                this.model.COMMAND_TEXT = this.MakeCmdCode(svc_mode, queryId, serviceName, dtoName);


                if ((query.ToUpper().IndexOf("PKG") > -1 || query.ToUpper().IndexOf("PC_") > -1) && query.Length < 300)
                {
                    GetProcedureSourceGenerater_INOUT(query);
                    MakeDTOPropertyEQSParameterFromProc();
                }
                else
                {
                    if (svc_mode == "S")
                        MakeDTOCodeAndGridCode(query, serviceName);
                    MakeDTOPropertyEQSParameterFromQuery(query);
                }
            }
            catch
            {

            }
        }
        private void Button_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                if (this.model.EQS_ID == null || this.model.IN_DTO == null || string.IsNullOrEmpty(this.model.OUT_DTO))
                    return;
                this.model.PKG_NM = "";
                string queryId = this.model.EQS_ID.Trim();
                string[] strArray = queryId.Split('.');
                string serviceName = strArray[strArray.Length - 1];
                string dtoName = this.model.IN_DTO.Trim();
                string str1 = this.model.OUT_DTO.Trim();
                string svc_mode = "S";
                if (serviceName.ToUpper().IndexOf("UPDATE") > -1)
                    svc_mode = "U";
                if (serviceName.ToUpper().IndexOf("INSERT") > -1)
                    svc_mode = "U";
                if (serviceName.ToUpper().IndexOf("SAVE") > -1)
                    svc_mode = "U";
                if (serviceName.ToUpper().IndexOf("DELETE") > -1)
                    svc_mode = "U";

                string query = "";
                this.model.SearchEQSCommand.Execute(null);
                if (this.model.EQS_SEL != null && this.model.EQS_SEL.QUERYTEXT != null)
                    query = GetQueryText();

                this.model.DL_TEXT = this.MakeDLCode(svc_mode, queryId, serviceName, dtoName, str1);
                this.model.BIZ_TEXT = this.MakeBLCode(svc_mode, queryId, serviceName, dtoName, str1);
                this.model.IF_TEXT = this.MakeIFCode(svc_mode, queryId, serviceName, dtoName, str1);
                string str2 = "";
                bool? isChecked = (bool)this.rdoCollection.IsChecked ? (bool)this.rdoCollection.IsChecked : (bool)this.rdoList.IsChecked ? (bool)this.rdoList.IsChecked : false;
                bool flag = true;
                if (isChecked.GetValueOrDefault() == flag & isChecked.HasValue)
                    str2 = this.MakePropertyCode2(svc_mode, queryId, serviceName, str1) + Environment.NewLine + Environment.NewLine;
                this.model.PROPERTY_TEXT = str2 + this.MakePropertyCode(svc_mode, queryId, serviceName, str1);
                this.model.METHOD_TEXT = this.MakeMethodCode(svc_mode, queryId, serviceName, dtoName, str1);
                this.model.COMMAND_TEXT = this.MakeCmdCode(svc_mode, queryId, serviceName, dtoName);

               
                if ((query.ToUpper().IndexOf("PKG") > -1 || query.ToUpper().IndexOf("PC_") > -1) && query.Length < 300)
                {
                    GetProcedureSourceGenerater_INOUT(query);
                    MakeDTOPropertyEQSParameterFromProc();
                }
                else
                {
                    if (svc_mode == "S")
                        MakeDTOCodeAndGridCode(query, serviceName);
                    MakeDTOPropertyEQSParameterFromQuery(query);
                }
            }
            catch
            {

            }
        }

        private void txtEqs_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                Button_Click(sender, e);
            }
        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            this.OpenCodeWIndow(HDataGridEx_Code);
        }

        private void UCBase_Loaded_1(object sender, RoutedEventArgs e)
        {
            if(model != null)
                this.model.LoadUserInfo();
        }
    }
}
