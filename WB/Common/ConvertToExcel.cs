//using HIS.Core.Global.DTO.CommonLogging;
//using HIS.UI.Base;
//using HIS.UI.Controls.Extension;
//using HIS.UI.Core;
//using HIS.UI.Utility.Behaviors;
//using HIS.UI.Utility.Extension;
//using HIS.UI.Utility.Office;
//using HSF.Controls.WPF;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using Excel = Microsoft.Office.Interop.Excel;
using SaveFileDialog = Microsoft.Win32.SaveFileDialog;
namespace WB.Common
{
    public class ConvertToExcel
    {

        static Excel.Application excelApp = null;
        static Excel.Workbook workBook = null;
        static Excel.Worksheet workSheet = null;
        static string LastCallStack;
        public static string Folder;
        private string fileName;
        //#region[ExcelLog]
        ///// <summary>        
        ///// <para>1.his_prgm_id = ViewModelBase 혹은 HIS_PRGM_ID (EAM의 MENU_CD를 넘겨야함.) ViewModelBase를 상속받았으면 this를 넘기면 됨. </para>
        ///// <para>2.DataTable로 넘길경우에는 데이터의 첫번째 환자번호와 환자이름을 pt_no,pt_nm 파라미터에 넘겨줘야함. EX) pt_no: 01234567 , pt_nm:"테스트환자명"</para>
        ///// <para>3.HDataGridEx로 넘길경우에는 Binding된 컬럼중에 PT_NO, PT_NM 이 바인딩 되어 있어야 환자정보가 로그에 쌓임. 없을 경우 첫번쨰 환자에 해당하는 환자번호와 환자명을 
        /////   pt_no,pt_nm 파라미터에 넘겨줘야함. </para>
        /////   <para>EX) pt_no: 01234567 , pt_nm:"테스트환자명"</para>
        ///// </summary>
        ///// <param name="grid"> 엑셀 출력할 DataGridEx 혹은 DataTable</param>
        ///// <param name="his_prgm_id"> ViewModelBase 혹은 HIS_PRGM_ID (EAM의 MENU_CD를 넘겨야함.) ViewModelBase를 상속받았으면 this를 넘기면 됨.</param>
        ///// <param name="sheetName"></param>
        ///// <param name="rowHeight"></param>
        ///// <param name="fontSize"></param>
        ///// <param name="fstRowFreezeYn">첫행 고정여부</param>
        ///// <param name="red">첫행 색상</param>
        ///// <param name="green">첫행 색상</param>
        ///// <param name="blue">첫행 색상</param>
        ///// <param name="startRowIndex">시작 ROW 위치</param>
        ///// <param name="startColIndex">시작 COL 위치</param>
        ///// <param name="Alignment">정렬 CENTER ,LEFT , RIGHT </param>
        ///// <param name="downExcelYn">다운여부</param>
        ///// <param name="exportYn">출력여부</param>
        ///// <param name="isEncrypt">암호화여부</param>
        ///// <param name="FileName"></param>
        ///// <param name="autoFilter">첫행 필터여부 (Header Merge일 경우 적용 안됨.)</param>
        //public static void ExportExcelLog(object grid, object his_prgm_id, string sheetName = null, int rowHeight = -1, int fontSize = 9, bool fstRowFreezeYn = true,
        //                                       int red = 255, int green = 255, int blue = 255, int startRowIndex = 1, int startColIndex = 1, string Alignment = null
        //                                      , bool downExcelYn = false, bool exportYn = true, bool isEncrypt = false, string FileName = "", string pt_no = "", string pt_nm = "", bool autoFilter = false)
        //{
        //    HDataGridEx hdataGridEx = new HDataGridEx();
        //    DataTable dt = new DataTable();
        //    int dataCount = 0; //데이터 건수
        //    string menu_cd = string.Empty;


        //    if (grid is HDataGridEx)
        //    {
        //        hdataGridEx = grid as HDataGridEx;
        //        dataCount = (hdataGridEx.ItemsSource as IList).Count;
        //    }
        //    else if (grid is DataTable)
        //    {
        //        dt = grid as DataTable;
        //        dataCount = dt.Rows.Count;
        //    }
        //    else
        //        return;


        //    if (dataCount == 0) return;

        //    string mergeYn = GetMergeHeaderYn(hdataGridEx); //MergeHeader 여부 체크
        //    if (dt.Rows.Count == 0)
        //        dt = GetDataGridViewAsDataTable(hdataGridEx); //HDataGridEx를 DataTable로 변환

        //    //Excel LogInsert
        //    try
        //    {
        //        if (string.IsNullOrEmpty(pt_no))
        //        {
        //            foreach (DataColumn item in dt.Columns)
        //            {
        //                if (item.Caption.ToString().ToUpper().Contains("PT_NO") || item.ColumnName.ToString().ToUpper().Contains("PT_NO"))
        //                {
        //                    //pt_no = dt.Columns[item.ColumnName].DefaultValue.ToString();
        //                    pt_no = dt.Select().Select(x => x[item.ColumnName]).FirstOrDefault().ToString();
        //                    break;
        //                }
        //            }
        //        }
        //        if (string.IsNullOrEmpty(pt_nm))
        //        {
        //            foreach (DataColumn item in dt.Columns)
        //            {
        //                if (item.Caption.ToString().ToUpper().Contains("PT_NM") || item.ColumnName.ToString().ToUpper().Contains("PT_NM"))
        //                {
        //                    pt_nm = dt.Select().Select(x => x[item.ColumnName]).FirstOrDefault().ToString();
        //                    break;
        //                }
        //            }
        //        }
        //        GetStackTrace(1);
        //        if (his_prgm_id is string && !string.IsNullOrEmpty(his_prgm_id.ToString()))
        //            menu_cd = his_prgm_id.ToString();
        //        else if (his_prgm_id is ViewModelBase && his_prgm_id != null)
        //            menu_cd = (his_prgm_id as ViewModelBase).HIS_PRGM_ID;
        //        else
        //            menu_cd = LastCallStack;
        //        if (!LogInsert(sheetName, true, menu_cd, dataCount, pt_no, pt_nm)) return;


        //    }
        //    catch
        //    {

        //    }
        //    //암호화
        //    if (isEncrypt)
        //    {
        //        string str1 = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Personal), "Temp");
        //        if (!Directory.Exists(str1))
        //            Directory.CreateDirectory(str1);
        //        string empty = string.Empty;
        //        string str2 = Interlop.Excel.Version < 12 ? ".xls" : ".xlsx";
        //        FileName = string.IsNullOrEmpty(FileName) ? Path.Combine(str1, Path.GetRandomFileName() + str2) : FileName;
        //    }

        //    int str_range_row = startRowIndex;
        //    int str_range_col = startColIndex;
        //    int end_range_row = dt.Rows.Count + 1 + (startRowIndex - 1);
        //    int end_range_col = dt.Columns.Count + (startColIndex - 1);

        //    int str_merge_row = startRowIndex;

        //    int dateTypeCol = 1; //날짜 타입의 컬럼 CELL 인덱스 

        //    excelApp = new Excel.Application();
        //    workBook = excelApp.Workbooks.Add();
        //    workSheet = workBook.Worksheets.get_Item(1) as Excel.Worksheet;
        //    //해당범위 텍스트 포맷
        //    Excel.Range range = workSheet.get_Range(workSheet.Cells[str_range_row, str_range_col] as object, workSheet.Cells[end_range_row, end_range_col] as object);
        //    range.NumberFormat = "@";

        //    //RowHeight 강제설정
        //    if (rowHeight != -1)
        //        range.RowHeight = rowHeight;

        //    //fontSize
        //    range.Font.Size = fontSize;

        //    //첫행 배경색
        //    if (red != 255 || green != 255 || blue != 255)
        //        GetFreezeRange(workSheet, fstRowFreezeYn, str_range_row, str_range_col, str_range_row, str_range_col).EntireRow.Interior.Color = Color.FromArgb(red, green, blue);

        //    //MergeHeader가 없는 경우 
        //    if (mergeYn == "N")
        //    {
        //        //첫행고정 및 Bold처리.
        //        if (fstRowFreezeYn)
        //            //1,1 ~ 1,1 
        //            GetFreezeRange(workSheet, fstRowFreezeYn, str_range_row, str_range_col, str_range_row, str_range_col).EntireRow.Font.Bold = true;

        //        if (autoFilter)
        //            GetRange(workSheet, str_range_row, str_range_col, str_range_row, str_range_col).EntireRow.AutoFilter(1, Type.Missing, Excel.XlAutoFilterOperator.xlAnd, Type.Missing, true);
        //        //DateTime의 컬럼은 날짜로 포맷.
        //        foreach (DataColumn col in dt.Columns)
        //        {

        //            if (col.DataType.Name == "DateTime")
        //            {
        //                Excel.Range dateRange = workSheet.get_Range(workSheet.Cells[str_range_row + 1, dateTypeCol] as object, workSheet.Cells[end_range_row, dateTypeCol] as object);
        //                dateRange.NumberFormat = "yyyy-mm-dd h:mm";
        //            }
        //            dateTypeCol++;
        //        }

        //        //데이터가 있는 범위에 데이터를 한번에 밀어넣음.
        //        var writeRange = range;
        //        writeRange.Value2 = SetData(dt);
        //    }
        //    //MergeHeader가 있는 경우 Merge된 컬럼만 Merge후 가운데 정렬함. Merge되지않은 컬럼은 2번째 열에 뿌려지도록 함.
        //    else if (mergeYn == "Y" && (hdataGridEx.ItemsSource as IList).Count > 0)
        //    {
        //        range = workSheet.get_Range(workSheet.Cells[str_range_row, str_range_col] as object, workSheet.Cells[end_range_row + 1, end_range_col] as object); //Merge일경우 재정의
        //        range.NumberFormat = "@";

        //        //RowHeight 강제설정
        //        if (rowHeight != -1)
        //            range.RowHeight = rowHeight;

        //        //fontSize
        //        range.Font.Size = fontSize;

        //        //첫행 배경색
        //        if (red != 255 || green != 255 || blue != 255)
        //            GetFreezeRange(workSheet, fstRowFreezeYn, str_range_row, str_range_col, str_range_row + 1, str_range_col).EntireRow.Interior.Color = Color.FromArgb(red, green, blue);

        //        //첫행고정 및 Bold처리.
        //        if (fstRowFreezeYn)
        //            //1,1 ~ 2,1 
        //            GetFreezeRange(workSheet, fstRowFreezeYn, str_range_row, str_range_col, str_range_row + 1, str_range_col).EntireRow.Font.Bold = true;

        //        int str_cell = str_range_col;
        //        int stop_cell = str_range_col;
        //        foreach (DataGridColumn col in hdataGridEx.Columns.Where(d => d.Visibility == Visibility.Visible))
        //        {
        //            var mergeHeader = HDataGridColumnHeaderManager.GetMergeHeader(col);
        //            var mergeSpan = HDataGridColumnHeaderManager.GetMergeSpan(col);
        //            var isMerge = (bool)col.GetValue(HDataGridColumnHeaderManager.IsMergedProperty);
        //            if (str_cell == stop_cell)
        //            {
        //                str_merge_row = isMerge ? str_range_row : str_range_row + 1;
        //                Excel.Range mergeRange = workSheet.get_Range(workSheet.Cells[str_range_row, str_cell] as object, workSheet.Cells[str_merge_row, str_cell + mergeSpan - 1] as object); //Merge일경우 재정의
        //                mergeRange.Merge(isMerge);
        //                mergeRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignCenter;
        //                stop_cell = str_cell + mergeSpan;
        //            }
        //            str_cell++;
        //        }

        //        var writeRange = range;
        //        writeRange.Value2 = SetDataMerge(hdataGridEx, dt);
        //    }



        //    workSheet.Columns.AutoFit();
        //    //Sheet이름을 파라미터로 받을경우 Sheet명을 지정.
        //    if (!string.IsNullOrEmpty(sheetName))
        //        workSheet.Name = sheetName;

        //    //정렬 파라미터가 있을경우 왼쪽,오른쪽,가운데정렬을 해줌.
        //    if (!string.IsNullOrEmpty(Alignment))
        //    {
        //        if (Alignment.ToUpper().Equals("LEFT"))
        //        {
        //            range.HorizontalAlignment = Excel.XlHAlign.xlHAlignLeft;
        //        }
        //        else if (Alignment.ToUpper().Equals("RIGHT"))
        //        {
        //            range.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight;
        //        }
        //        else if (Alignment.ToUpper().Equals("CENTER"))
        //        {
        //            range.HorizontalAlignment = Excel.XlHAlign.xlHAlignCenter;
        //        }
        //    }
        //    if (isEncrypt)
        //    {
        //        Save(workBook, FileName, isEncrypt);
        //        Cursor.Current = Cursors.Default;
        //        if (range != null)
        //            Marshal.ReleaseComObject((object)range);
        //        if (workSheet != null)
        //            Marshal.ReleaseComObject((object)workSheet);
        //        if (!exportYn && workBook != null)
        //            workBook.Close((object)false, System.Type.Missing, System.Type.Missing);
        //        if (!exportYn && excelApp != null)
        //            excelApp.Quit();
        //        if (workBook != null)
        //            Marshal.ReleaseComObject((object)workBook);
        //        if (excelApp != null)
        //            Marshal.ReleaseComObject((object)excelApp);
        //        range = (Excel.Range)null;
        //        workSheet = (Excel.Worksheet)null;
        //        workBook = (Excel.Workbook)null;
        //        excelApp = (Microsoft.Office.Interop.Excel.Application)null;
        //        GC.Collect();
        //        MsgBox.Display("저장하였습니다.\n" + "경로 : " + FileName, MessageType.MSG_TYPE_INFORMATION);
        //    }
        //    else
        //    {
        //        //엑셀 다운로드
        //        if (downExcelYn)
        //        {
        //            try
        //            {

        //                FileDownLoad();
        //                var path = Folder + ".xlsx";
        //                //기존의 파일이 존재하면 지움
        //                if (File.Exists(path))
        //                { File.Delete(path); }
        //                workBook.SaveAs(path, Excel.XlFileFormat.xlWorkbookDefault);
        //                workBook.Close(true);
        //                excelApp.Quit();
        //                MsgBox.Display("저장하였습니다.\n" + "경로 : " + path, MessageType.MSG_TYPE_INFORMATION);
        //            }
        //            catch (Exception ex)
        //            {
        //                //MsgBox.Display(ex.ToString(), MessageType.MSG_TYPE_ERROR);
        //            }
        //            finally
        //            {
        //                ReleaseObject(workSheet);
        //                ReleaseObject(workBook);
        //                ReleaseObject(excelApp);
        //            }
        //        }
        //        else
        //            //엑셀 출력 
        //            excelApp.Visible = exportYn;
        //    }
        //}
        //#endregion        
        //#region[Excel]
        ///// <summary>
        ///// LogInsertYn 을 true로 넘길경우 his_prgm_id 파라미터에 반드시 this 나 this.HIS_PRGM_ID를 넘겨줘야 함. (EAM 의 MENU_CD를 담아야 하기 때문)
        ///// </summary>
        ///// <param name="hdataGridEx"> 엑셀 출력하고자 하는 데이터그리드 </param>
        ///// <param name="sheetName"></param>
        ///// <param name="rowHeight"> 행 높이 강제설정 기본은 자동 너비 </param>
        ///// <param name="fontSize"> 데이터 FontSize 기본은 9 Size </param>
        ///// <param name="fstRowFreezeYn"> 첫행 고정 여부 , 기본값은 첫행 고정 및 Bold처리 , false로 넘기면 고정하지 않음. </param>
        ///// <param name="red"> 첫행 배경 rgb </param>
        ///// <param name="green">첫행 배경 rgb </param>
        ///// <param name="blue">첫행 배경 rgb </param>
        ///// <param name="startRowIndex"> 엑셀 출력 시작 Row Index 1부터 시작 </param>
        ///// <param name="startColIndex">엑셀 출력 시작 Column Index 1부터 시작 </param>
        ///// <param name="Alignment">모든 데이터의 정렬 여부 LEFT , RIGHT , CENTER 입력시 모든 데이터를 각각 왼쪽,오른쪽,가운데 정렬 함.</param>
        ///// <param name="logInsertYn">기본값: true, false일 경우에 로그 insert하지 않음.</param>
        ///// <param name="downExcelYn">기본값: false, true일 경우에 엑셀 다운로드 </param>
        ///// <param name="exportYn">기본값: true, true일 경우에 엑셀 출력 </param>
        //public static void ExportExcel(object grid, string sheetName = null, int rowHeight = -1, int fontSize = 9, bool fstRowFreezeYn = true,
        //                               int red = 255, int green = 255, int blue = 255, int startRowIndex = 1, int startColIndex = 1, string Alignment = null
        //                              , bool logInsertYn = false, bool downExcelYn = false, bool exportYn = true)
        //{
        //    HDataGridEx hdataGridEx = new HDataGridEx();
        //    DataTable dt = new DataTable();
        //    int dataCount = 0; //데이터 건수    

        //    if (grid is HDataGridEx)
        //    {
        //        hdataGridEx = grid as HDataGridEx;
        //        dataCount = (hdataGridEx.ItemsSource as IList).Count;
        //    }
        //    else if (grid is DataTable)
        //    {
        //        dt = grid as DataTable;
        //        dataCount = dt.Rows.Count;
        //    }
        //    else
        //        return;


        //    if (dataCount == 0) return;

        //    string mergeYn = GetMergeHeaderYn(hdataGridEx); //MergeHeader 여부 체크
        //    if (dt.Rows.Count == 0)
        //        dt = GetDataGridViewAsDataTable(hdataGridEx); //HDataGridEx를 DataTable로 변환

        //    //Excel LogInsert
        //    try
        //    {
        //        if (logInsertYn)
        //        {
        //            GetStackTrace(1);
        //            var menu_cd = LastCallStack;
        //            if (!CommonHelper.LogInsert(sheetName, true, menu_cd, dataCount)) return;

        //        }
        //    }
        //    catch
        //    {

        //    }

        //    int str_range_row = startRowIndex;
        //    int str_range_col = startColIndex;
        //    int end_range_row = dt.Rows.Count + 1 + (startRowIndex - 1);
        //    int end_range_col = dt.Columns.Count + (startColIndex - 1);

        //    int str_merge_row = startRowIndex;

        //    int dateTypeCol = 1; //날짜 타입의 컬럼 CELL 인덱스 

        //    excelApp = new Excel.Application();
        //    workBook = excelApp.Workbooks.Add();
        //    workSheet = workBook.Worksheets.get_Item(1) as Excel.Worksheet;
        //    //해당범위 텍스트 포맷
        //    Excel.Range range = workSheet.get_Range(workSheet.Cells[str_range_row, str_range_col] as object, workSheet.Cells[end_range_row, end_range_col] as object);
        //    range.NumberFormat = "@";

        //    //RowHeight 강제설정
        //    if (rowHeight != -1)
        //        range.RowHeight = rowHeight;

        //    //fontSize
        //    range.Font.Size = fontSize;

        //    //첫행 배경색
        //    if (red != 255 || green != 255 || blue != 255)
        //        GetFreezeRange(workSheet, fstRowFreezeYn, str_range_row, str_range_col, str_range_row, str_range_col).EntireRow.Interior.Color = Color.FromArgb(red, green, blue);

        //    //MergeHeader가 없는 경우 
        //    if (mergeYn == "N")
        //    {
        //        //첫행고정 및 Bold처리.
        //        if (fstRowFreezeYn)
        //            //1,1 ~ 1,1 
        //            GetFreezeRange(workSheet, fstRowFreezeYn, str_range_row, str_range_col, str_range_row, str_range_col).EntireRow.Font.Bold = true;

        //        //DateTime의 컬럼은 날짜로 포맷.
        //        foreach (DataColumn col in dt.Columns)
        //        {

        //            if (col.DataType.Name == "DateTime")
        //            {
        //                Excel.Range dateRange = workSheet.get_Range(workSheet.Cells[str_range_row + 1, dateTypeCol] as object, workSheet.Cells[end_range_row, dateTypeCol] as object);
        //                dateRange.NumberFormat = "yyyy-mm-dd h:mm";
        //            }
        //            dateTypeCol++;
        //        }

        //        //데이터가 있는 범위에 데이터를 한번에 밀어넣음.
        //        var writeRange = range;
        //        writeRange.Value2 = SetData(dt);
        //    }
        //    //MergeHeader가 있는 경우 Merge된 컬럼만 Merge후 가운데 정렬함. Merge되지않은 컬럼은 2번째 열에 뿌려지도록 함.
        //    else if (mergeYn == "Y" && (hdataGridEx.ItemsSource as IList).Count > 0)
        //    {
        //        range = workSheet.get_Range(workSheet.Cells[str_range_row, str_range_col] as object, workSheet.Cells[end_range_row + 1, end_range_col] as object); //Merge일경우 재정의
        //        range.NumberFormat = "@";

        //        //RowHeight 강제설정
        //        if (rowHeight != -1)
        //            range.RowHeight = rowHeight;

        //        //fontSize
        //        range.Font.Size = fontSize;

        //        //첫행 배경색
        //        if (red != 255 || green != 255 || blue != 255)
        //            GetFreezeRange(workSheet, fstRowFreezeYn, str_range_row, str_range_col, str_range_row + 1, str_range_col).EntireRow.Interior.Color = Color.FromArgb(red, green, blue);

        //        //첫행고정 및 Bold처리.
        //        if (fstRowFreezeYn)
        //            //1,1 ~ 2,1 
        //            GetFreezeRange(workSheet, fstRowFreezeYn, str_range_row, str_range_col, str_range_row + 1, str_range_col).EntireRow.Font.Bold = true;

        //        int str_cell = str_range_col;
        //        int stop_cell = str_range_col;
        //        foreach (DataGridColumn col in hdataGridEx.Columns.Where(d => d.Visibility == Visibility.Visible))
        //        {
        //            var mergeHeader = HDataGridColumnHeaderManager.GetMergeHeader(col);
        //            var mergeSpan = HDataGridColumnHeaderManager.GetMergeSpan(col);
        //            var isMerge = (bool)col.GetValue(HDataGridColumnHeaderManager.IsMergedProperty);
        //            if (str_cell == stop_cell)
        //            {
        //                str_merge_row = isMerge ? str_range_row : str_range_row + 1;
        //                Excel.Range mergeRange = workSheet.get_Range(workSheet.Cells[str_range_row, str_cell] as object, workSheet.Cells[str_merge_row, str_cell + mergeSpan - 1] as object); //Merge일경우 재정의
        //                mergeRange.Merge(isMerge);
        //                mergeRange.HorizontalAlignment = Excel.XlHAlign.xlHAlignCenter;
        //                stop_cell = str_cell + mergeSpan;
        //            }
        //            str_cell++;
        //        }

        //        var writeRange = range;
        //        writeRange.Value2 = SetDataMerge(hdataGridEx, dt);
        //    }



        //    workSheet.Columns.AutoFit();
        //    //Sheet이름을 파라미터로 받을경우 Sheet명을 지정.
        //    if (!string.IsNullOrEmpty(sheetName))
        //        workSheet.Name = sheetName;

        //    //정렬 파라미터가 있을경우 왼쪽,오른쪽,가운데정렬을 해줌.
        //    if (!string.IsNullOrEmpty(Alignment))
        //    {
        //        if (Alignment.ToUpper().Equals("LEFT"))
        //        {
        //            range.HorizontalAlignment = Excel.XlHAlign.xlHAlignLeft;
        //        }
        //        else if (Alignment.ToUpper().Equals("RIGHT"))
        //        {
        //            range.HorizontalAlignment = Excel.XlHAlign.xlHAlignRight;
        //        }
        //        else if (Alignment.ToUpper().Equals("CENTER"))
        //        {
        //            range.HorizontalAlignment = Excel.XlHAlign.xlHAlignCenter;
        //        }
        //    }
        //    //엑셀 다운로드
        //    if (downExcelYn)
        //    {
        //        try
        //        {

        //            FileDownLoad();
        //            var path = Folder + ".xlsx";
        //            //기존의 파일이 존재하면 지움
        //            if (File.Exists(path))
        //            { File.Delete(path); }
        //            workBook.SaveAs(path, Excel.XlFileFormat.xlWorkbookDefault);
        //            workBook.Close(true);
        //            excelApp.Quit();
        //            MsgBox.Display("저장하였습니다.\n" + "경로 : " + path, MessageType.MSG_TYPE_INFORMATION);
        //        }
        //        catch (Exception ex)
        //        {
        //            //MsgBox.Display(ex.ToString(), MessageType.MSG_TYPE_ERROR);
        //        }
        //        finally
        //        {
        //            ReleaseObject(workSheet);
        //            ReleaseObject(workBook);
        //            ReleaseObject(excelApp);
        //        }
        //    }
        //    else
        //        //엑셀 출력 
        //        excelApp.Visible = exportYn;

        //}

        ///// <summary>
        ///// name         : DTO의 프로퍼티 값 리턴
        ///// desc         : DTO의 프로퍼티 값 리턴
        ///// author       : ezCaretech 송창수
        ///// create date  : 2021-08-25
        ///// update date  : 2021-08-25
        ///// </summary>
        //private static string GetPropertyValue(object dto, string propertyName)
        //{
        //    string value = "";

        //    if (dto.GetType().GetProperty(propertyName) != null)
        //    {
        //        if (dto.GetType().GetProperty(propertyName).GetValue(dto) == null)
        //            value = "";
        //        else
        //            value = dto.GetType().GetProperty(propertyName).GetValue(dto, (object[])null).ToString();
        //    }

        //    return value;
        //}
        //public static DataTable GetDataGridViewAsDataTable(HDataGridEx _DataGridView)
        //{
        //    try
        //    {
        //        if (_DataGridView.Columns.Count == 0)
        //            return null;
        //        DataTable dtSource = new DataTable();
        //        //////create columns
        //        int cnt = 1;
        //        string col_header = string.Empty;
        //        string caption = string.Empty;
        //        foreach (DataGridColumn col in _DataGridView.Columns.Where(d => d.Visibility == Visibility.Visible))
        //        {
        //            col_header = string.IsNullOrEmpty(col.Header.ToString()) ? " " : col.Header.ToString();

        //            //DataTable은 같은 이름의 ColumnName을 가질 수 없기때문에 동일한  ColumnName  있을경우 SortMemberPath가 저장된 Caption을 컬럼명으로 저장 후 해당 Caption의 ColumnName을 가져오도록 함.
        //            if (dtSource.Columns.Cast<DataColumn>().Any(d => d.ColumnName == col_header))
        //            {
        //                dtSource.Columns.Add(dtSource.Columns.Cast<DataColumn>().Where(d => d.ColumnName == col_header).Select(d => d.Caption).FirstOrDefault() + "@" + cnt.ToString(), typeof(string));
        //                dtSource.Columns[dtSource.Columns.Cast<DataColumn>().Where(d => d.ColumnName == col_header).Select(d => d.Caption).FirstOrDefault() + "@" + cnt.ToString()].Caption = col.SortMemberPath;
        //                cnt++;
        //            }
        //            else
        //            {
        //                dtSource.Columns.Add(col_header, typeof(string));
        //                dtSource.Columns[col_header].Caption = col.SortMemberPath;
        //            }
        //        }

        //        //create Rows
        //        if (_DataGridView.BindableColumns != null && (_DataGridView.BindableColumns as IList).Count > 0) //동적 데이터그리드일 경우
        //        {
        //            foreach (object obj1 in (IEnumerable)_DataGridView.Items)
        //            {
        //                DataRow dtRow = dtSource.NewRow();
        //                int idx = 0;
        //                foreach (DataGridColumn column in (Collection<DataGridColumn>)_DataGridView.Columns)
        //                {
        //                    if (column.Visibility == Visibility.Visible || (bool)column.GetValue(DataGridColumnBehavior.ExportToExcelProperty))
        //                    {
        //                        object obj2 = (object)null;

        //                        if (column.GetValue(DataGridColumnBehavior.ExportMemberPathProperty) != null && !column.GetValue(DataGridColumnBehavior.ExportMemberPathProperty).ToString().Equals(""))
        //                        {
        //                            //obj2 = obj1.GetType().GetProperty(column.GetValue(DataGridColumnBehavior.ExportMemberPathProperty).ToString()).GetValue(obj1, (object[])null);
        //                            obj2 = GetPropertyValue(obj1, column.GetValue(DataGridColumnBehavior.ExportMemberPathProperty).ToString());
        //                        }
        //                        else if (column is HDataGridTemplateColumn && ((HDataGridTemplateColumn)column).ExportValueBinding != null)
        //                        {
        //                            if (((HDataGridTemplateColumn)column).ExportValueBinding is MultiBinding)
        //                            {
        //                                HDataGridRow depObj = (HDataGridRow)_DataGridView.ItemContainerGenerator.ContainerFromItem(obj1);
        //                                int index = _DataGridView.Columns.IndexOf(column);
        //                                if (depObj != null && index >= 0)
        //                                {
        //                                    HDataGridCellsPresenter visualChild = VisualTree.FindVisualChild<HDataGridCellsPresenter>((DependencyObject)depObj);
        //                                    if (visualChild != null)
        //                                    {
        //                                        if (visualChild.ItemContainerGenerator.ContainerFromIndex(index) == null)
        //                                            throw new NullReferenceException(depObj.RowIndex.ToString() + " 행의" + index.ToString() + " 열을 찾을 수 없습니다.");
        //                                        obj2 = (visualChild.ItemContainerGenerator.ContainerFromIndex(index) as HDataGridCell).ExportValue;
        //                                    }
        //                                }
        //                            }
        //                            else
        //                            {
        //                                string path = ((System.Windows.Data.Binding)((HDataGridTemplateColumn)column).ExportValueBinding).Path.Path;
        //                                if (!string.IsNullOrEmpty(path))
        //                                    obj2 = obj1.GetType().GetProperty(path).GetValue(obj1, (object[])null);
        //                            }
        //                        }
        //                        else if (column is HDataGridTextColumn)
        //                        {
        //                            _DataGridView.UpdateLayout();
        //                            _DataGridView.ScrollIntoView(obj1);
        //                            HDataGridRow depObj = (HDataGridRow)_DataGridView.ItemContainerGenerator.ContainerFromItem(obj1);
        //                            int index = _DataGridView.Columns.IndexOf(column);
        //                            if (depObj != null && index >= 0)
        //                            {
        //                                HDataGridCellsPresenter visualChild = VisualTree.FindVisualChild<HDataGridCellsPresenter>((DependencyObject)depObj);
        //                                if (visualChild != null)
        //                                {
        //                                    if (visualChild.ItemContainerGenerator.ContainerFromIndex(index) == null)
        //                                        throw new NullReferenceException(depObj.RowIndex.ToString() + " 행의" + (object)index + " 열을 찾을 수 없습니다.");
        //                                    try
        //                                    {
        //                                        obj2 = (object)((TextBlock)(visualChild.ItemContainerGenerator.ContainerFromIndex(index) as HDataGridCell).Content).Text;
        //                                    }
        //                                    catch
        //                                    {
        //                                        obj2 = (visualChild.ItemContainerGenerator.ContainerFromIndex(index) as HDataGridCell).ExportValue;
        //                                    }
        //                                }
        //                            }
        //                        }
        //                        else if (!string.IsNullOrEmpty(column.SortMemberPath))
        //                            obj2 = GetPropertyValue(obj1, column.SortMemberPath);


        //                        dtRow[dtSource.Columns[idx].ColumnName] = obj2 ?? "";
        //                        idx++;
        //                    }
        //                }
        //                dtSource.Rows.Add(dtRow);
        //            }
        //        }
        //        else //동적 데이터그리드가 아닐 경우 (SortMemberPath가 없으면 데이터가 안보임)
        //        {
        //            IList list = _DataGridView.ItemsSource as IList;
        //            for (int i = 0; i < list.Count; i++)
        //            {
        //                DataRow dtRow = dtSource.NewRow();
        //                foreach (DataColumn col in dtSource.Columns)
        //                {
        //                    dtRow[col.ColumnName] = GetPropertyValue(list[i], col.Caption);
        //                }
        //                dtSource.Rows.Add(dtRow);
        //            }
        //        }
        //        return dtSource;
        //    }
        //    catch (Exception e)
        //    {
        //        MsgBox.Display(e.ToString(), MessageType.MSG_TYPE_ERROR);
        //        return null;
        //    }
        //}
        //public static object SetData(DataTable dt)
        //{
        //    var data = new object[dt.Rows.Count + 1, dt.Columns.Count];

        //    for (int i = 0; i < dt.Columns.Count; i++)
        //    {
        //        //ColumnName이 Caption에 있을 경우 동일한 ColumnName이라는 의미이기 때문에 해당 Caption의 컬럼명을 가져옴. 추가:동일한 이름의 컬럼이 여러개 일 수 있어서 '@' 구분자로 Split해서 가져오도록 수정.
        //        if (dt.Columns.Cast<DataColumn>().Any(d => d.Caption == dt.Columns[i].ColumnName.Split('@')[0]))
        //            data[0, i] = dt.Columns.Cast<DataColumn>().Where(d => d.Caption == dt.Columns[i].ColumnName).Select(d => d.ColumnName).FirstOrDefault();
        //        else
        //            data[0, i] = dt.Columns[i].ColumnName;
        //    }

        //    for (int i = 0; i < dt.Rows.Count; i++)
        //    {
        //        for (int j = 0; j < dt.Columns.Count; j++)
        //        {
        //            data[i + 1, j] = dt.Rows[i][j];
        //        }
        //    }
        //    return data;
        //}
        //public static object SetDataMerge(HDataGridEx hdataGridEx, DataTable dt)
        //{
        //    var data = new object[dt.Rows.Count + 2, dt.Columns.Count];
        //    int colIdx = 0;
        //    foreach (DataGridColumn col in hdataGridEx.Columns.Where(d => d.Visibility == Visibility.Visible))
        //    {
        //        if ((bool)col.GetValue(HDataGridColumnHeaderManager.IsMergedProperty))
        //        {
        //            var mergeHeader = HDataGridColumnHeaderManager.GetMergeHeader(col) ?? "";
        //            data[0, colIdx] = mergeHeader.ToString();
        //        }
        //        else
        //        {
        //            //ColumnName이 Caption에 있을 경우 동일한 ColumnName이라는 의미이기 때문에 해당 Caption의 컬럼명을 가져옴. 추가:동일한 이름의 컬럼이 여러개 일 수 있어서 '@' 구분자로 Split해서 가져오도록 수정.
        //            if (dt.Columns.Cast<DataColumn>().Any(d => d.Caption == dt.Columns[colIdx].ColumnName.Split('@')[0]))
        //                data[0, colIdx] = dt.Columns.Cast<DataColumn>().Where(d => d.Caption == dt.Columns[colIdx].ColumnName.Split('@')[0]).Select(d => d.ColumnName).FirstOrDefault();
        //            else
        //                data[0, colIdx] = dt.Columns[colIdx].ColumnName;
        //        }
        //        colIdx++;
        //    }
        //    for (int i = 0; i < dt.Columns.Count; i++)
        //    {
        //        //ColumnName이 Caption에 있을 경우 동일한 ColumnName이라는 의미이기 때문에 해당 Caption의 컬럼명을 가져옴. 추가:동일한 이름의 컬럼이 여러개 일 수 있어서 '@' 구분자로 Split해서 가져오도록 수정.
        //        if (dt.Columns.Cast<DataColumn>().Any(d => d.Caption == dt.Columns[i].ColumnName.Split('@')[0]))
        //            data[1, i] = dt.Columns.Cast<DataColumn>().Where(d => d.Caption == dt.Columns[i].ColumnName.Split('@')[0]).Select(d => d.ColumnName).FirstOrDefault();
        //        else
        //            data[1, i] = dt.Columns[i].ColumnName;
        //    }

        //    for (int i = 0; i < dt.Rows.Count; i++)
        //    {
        //        for (int j = 0; j < dt.Columns.Count; j++)
        //        {
        //            data[i + 2, j] = dt.Rows[i][j];
        //        }
        //    }
        //    return data;
        //}
        //public static string GetMergeHeaderYn(HDataGridEx _DataGridView)
        //{
        //    string mergeYn = "N";
        //    try
        //    {
        //        if (_DataGridView.Columns.Count == 0)
        //            return mergeYn;
        //        foreach (DataGridColumn col in _DataGridView.Columns.Where(d => d.Visibility == Visibility.Visible))
        //        {
        //            bool isMerge = (bool)col.GetValue(HDataGridColumnHeaderManager.IsMergedProperty);
        //            if (isMerge)
        //            {
        //                mergeYn = "Y";
        //                break;
        //            }
        //        }
        //    }
        //    catch (Exception e)
        //    {
        //        MsgBox.Display(e.ToString(), MessageType.MSG_TYPE_ERROR);
        //        return null;
        //    }
        //    return mergeYn;
        //}

        ///// <summary>
        ///// name         : 파일다운로드
        ///// desc         : 선택된 파일을 다운로드함        
        ///// create date  : 2012-08-07 오전 9:26:34
        ///// update date  : 2012-08-07 오전 9:26:34, 수정자, 수정개요
        ///// </summary>
        //private static void FileDownLoad()
        //{
        //    //해당 경로에 저장. 
        //    //System.Windows.Forms.FolderBrowserDialog dlg = new System.Windows.Forms.FolderBrowserDialog();
        //    //FileInfomation downloadFiles = new FileInfomation();
        //    //dlg.ShowDialog();
        //    //downloadFiles.FilePath = dlg.SelectedPath;
        //    //Folder = @dlg.SelectedPath;

        //    //다른이름으로 저장
        //    SaveFileDialog dlg = new SaveFileDialog();
        //    if (dlg.ShowDialog() == true)
        //    {
        //        Folder = dlg.FileName;
        //    }
        //}

        ///// <summary>
        ///// 액셀 객체 해제
        ///// </summary>
        ///// <param name="obj"></param>
        //static void ReleaseObject(object obj)
        //{
        //    try
        //    {
        //        if (obj != null)
        //        {
        //            Marshal.ReleaseComObject(obj);
        //            obj = null;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        obj = null;
        //        throw ex;
        //    }
        //    finally
        //    {
        //        GC.Collect();   //가비지 수집
        //    }
        //}
        /////StackTrace를 통해 메뉴의 Xaml을 가져옴
        //public static void GetStackTrace(int tempStack)
        //{
        //    //if (!string.IsNullOrEmpty(LastCallStack))
        //    //    return;
        //    LastCallStack = GetMenuID(new StackTrace(), tempStack);
        //}
        /////StackTrace를 통해 메뉴의 Data부분을 가져옴
        //public static string GetMenuID(StackTrace stackTrace, int tempStack)
        //{
        //    int num = 0;
        //    string menuId = string.Empty;
        //    List<string> list = new List<string>();
        //    foreach (StackFrame frame in stackTrace.GetFrames())
        //    {
        //        //Type declaringType = frame.GetMethod().DeclaringType;
        //        //list.Add(declaringType.FullName);
        //        if (num++ > tempStack)
        //        {
        //            Type declaringType = frame.GetMethod().DeclaringType;
        //            if (declaringType.FullName.StartsWith("HIS"))
        //            {
        //                menuId = declaringType.FullName;
        //                break;
        //            }
        //        }
        //    }
        //    return menuId;
        //}
        ///// <summary>
        ///// 특정 범위의 RANGE를 구함.
        ///// </summary>
        ///// <param name="workSheet"></param>
        ///// <param name="fstRowFreezeYn"></param>
        ///// <param name="str_row"></param>
        ///// <param name="str_col"></param>
        ///// <param name="end_row"></param>
        ///// <param name="end_col"></param>
        ///// <returns></returns>
        //public static Excel.Range GetFreezeRange(Excel.Worksheet workSheet, bool fstRowFreezeYn, int str_row, int str_col, int end_row, int end_col)
        //{
        //    if (fstRowFreezeYn)
        //    {
        //        workSheet.Application.ActiveWindow.SplitRow = end_row;
        //        workSheet.Application.ActiveWindow.FreezePanes = true;
        //    }
        //    return workSheet.get_Range(workSheet.Cells[str_row, str_col] as object, workSheet.Cells[end_row, end_col] as object);
        //}

        ///// <summary>
        ///// 특정 범위의 RANGE를 구함.
        ///// </summary>
        ///// <param name="workSheet"></param>
        ///// <param name="fstRowFreezeYn"></param>
        ///// <param name="str_row"></param>
        ///// <param name="str_col"></param>
        ///// <param name="end_row"></param>
        ///// <param name="end_col"></param>
        ///// <returns></returns>
        //public static Excel.Range GetRange(Excel.Worksheet workSheet, int str_row, int str_col, int end_row, int end_col) => workSheet.get_Range(workSheet.Cells[str_row, str_col] as object, workSheet.Cells[end_row, end_col] as object);
        ///// <summary>
        ///// 
        ///// </summary>
        ///// <param name="sheetName"></param>
        ///// <param name="isOpenPopup"></param>
        ///// <param name="MenuCd"></param>
        ///// <param name="dataCount"></param>
        ///// <returns></returns>
        //public static bool LogInsert(string sheetName, bool isOpenPopup, string MenuCd, int dataCount, string pt_no, string pt_nm)
        //{
        //    //CommonHelper.IsOpenPopup = isOpenPopup;
        //    //string str1 = string.Empty;
        //    //if (CommonHelper.IsOpenPopup)
        //    //{
        //    //    if (CommonHelper.CheckMultiJob)
        //    //    {
        //    //        str1 = "multi sheets";
        //    //    }
        //    //    else
        //    //    {
        //    //        str1 = CallResonPopup();
        //    //        if (string.IsNullOrEmpty(str1))
        //    //        {
        //    //            int num = (int)MsgBox.Display("출력물 확인시 사유를 반드시 입력해야합니다.", MessageType.MSG_TYPE_EXCLAMATION);
        //    //            return false;
        //    //        }
        //    //    }
        //    //    CommonHelper.CheckMultiJob = false;
        //    //    CommonHelper.IsOpenPopup = false;
        //    //}
        //    //string str2 = string.Empty;
        //    //string str3 = string.Empty;
        //    //if (!string.IsNullOrEmpty(pt_no) && dataCount > 1)
        //    //    str2 = pt_no + " 외 " + (dataCount - 1).ToString() + "명";
        //    //else if (!string.IsNullOrEmpty(pt_no) && dataCount == 1)
        //    //    str2 = pt_no;

        //    //if (!string.IsNullOrEmpty(pt_nm) && dataCount > 1)
        //    //    str3 = pt_nm + " 외 " + (dataCount - 1).ToString() + "명";
        //    //else if (!string.IsNullOrEmpty(pt_nm) && dataCount == 1)
        //    //    str3 = pt_nm;

        //    //DownloadPrint_IN p = new DownloadPrint_IN();
        //    //p.EmployeeID = SessionManager.UserInfo.STF_NO;
        //    //p.ClientIP = SessionManager.SystemInfo.User_IP_Address;
        //    //p.MenuID = MenuCd;
        //    //p.PrintTime = CommonServiceAgent.SelectSysDateTime();
        //    //p.PatientID = str2;
        //    //p.PatientName = str3;
        //    //p.PDType = "DWONLOAD";
        //    //p.DataCount = dataCount;
        //    //p.Contents = string.Format("{0}({1})", (object)sheetName, (object)str1);
        //    //CommonHelper.LastCallStack = string.Empty;
        //    //LoggingServiceAgent.DownloadPrint(p);
        //    //return true;
        //}

        //private static string CallResonPopup()
        //{
        //    //bool flag = true;
        //    //if (((IEnumerable<string>)ConfigurationManager.AppSettings.AllKeys).Contains<string>("REASON_POPUP"))
        //    //    flag = Convert.ToBoolean(ConfigurationManager.AppSettings.Get("REASON_POPUP"));
        //    //if (!flag)
        //    //    return "사유입력 팝업 미사용";
        //    //ReasonPopup reasonPopup = new ReasonPopup();
        //    //ReasonPopupViewModel reasonPopupViewModel = new ReasonPopupViewModel();
        //    //reasonPopup.DataContext = (object)reasonPopupViewModel;
        //    //reasonPopup.ShowDialog();
        //    //return reasonPopupViewModel.Reason;
        //}

        //public static void Save(Excel.Workbook workbook, string fileName, bool isEncrypt = false)
        //{
        //    //if (!isEncrypt)
        //    //{
        //    //}
        //    //else
        //    //{
        //    //    SecurityInfo();
        //    //    SaveAsRun(workbook, fileName, "HIS" + HIS.UI.Base.Global.SessionManager.UserInfo.STF_NO.ToUpper());
        //    //}
        //}

        //private static void SecurityInfo()
        //{
        //    int num = (int)MsgBox.Display("개인정보보호법(고유식별정보처리기준 제24조)에 의거하여, \n고유식별정보(ex.주민번호등)가 포함된 파일은 암호화되어 저장되며, \n기본암호는 HIS+사원번호(대문자) 조합입니다.", MessageType.MSG_TYPE_INFORMATION, "다운로드 및 이용에 관한 안내");
        //}


        ///// <summary>통합 문서를 저장후 실행 합니다.</summary>

        //public static void SaveAsRun(Excel.Workbook workbook, string fileName, string password = null)
        //{
        //    if (string.IsNullOrEmpty(fileName))
        //        return;
        //    if (fileName.EndsWith(".csv", StringComparison.InvariantCultureIgnoreCase))
        //        workbook.SaveAs((object)fileName, (object)Excel.XlFileFormat.xlCSV, (object)password, ReadOnlyRecommended: ((object)false), CreateBackup: ((object)false), AccessMode: Excel.XlSaveAsAccessMode.xlExclusive, ConflictResolution: ((object)false), AddToMru: ((object)false), TextCodepage: ((object)false));
        //    else if (fileName.EndsWith(".xlsx", StringComparison.InvariantCultureIgnoreCase))
        //        workbook.SaveAs((object)fileName, (object)Excel.XlFileFormat.xlOpenXMLWorkbook, (object)password, ReadOnlyRecommended: ((object)false), CreateBackup: ((object)false), AccessMode: Excel.XlSaveAsAccessMode.xlExclusive, ConflictResolution: ((object)false), AddToMru: ((object)false), TextCodepage: ((object)false));
        //    else
        //        workbook.SaveAs((object)fileName, (object)Excel.XlFileFormat.xlWorkbookNormal, (object)password, ReadOnlyRecommended: ((object)false), CreateBackup: ((object)false), AccessMode: Excel.XlSaveAsAccessMode.xlExclusive, ConflictResolution: ((object)false), AddToMru: ((object)false), TextCodepage: ((object)false));
        //    workbook.Close(true);
        //    Process.Start("excel.exe", "\"" + fileName + "\"");

        //}

        //#endregion
    }
}
