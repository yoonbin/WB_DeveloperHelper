using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Controls;
using System.Windows.Media;

namespace WB.Common
{
    public class WBCommon
    {
        public static string BR = Environment.NewLine;
        public static string TAB = "    ";
        public static string SUMMARY = string.Format("{0}{0}/// <summary>{1}{0}{0}/// #TITLE#{1}{0}{0}/// </summary>", (object)"    ", (object)Environment.NewLine);
        public static string PLSQL_SUMMARY = string.Format("/*******************************************************************************{0}{0}*******************************************************************************/", Environment.NewLine);
        public static string pattern0 = @"\(.*\)";
        public static string pattern1 = @"(?![^\(]*\))\s*,\s*"; //괄호를 제외한 ,
        public static string pattern2 = @",\s*";
        public static string pattern3 = @"(?![^\(]*\))\s*FROM\s*"; //괄호를 제외한 FROM
        public static string pattern4 = @"(?![^\(]*\))\s*WHERE\s*"; //괄호를 제외한 WHERE
        public static string pattern5 = @"(?![^\(]*\))\s*AND\s*"; //괄호를 제외한 AND
        public static string pattern6 = @"(?![^\(]*\))\s*=\s*"; //괄호를 제외한 = 
        public static string pattern7 = @"--\s*(.*)";
        public static string pattern8 = @"\s*SELECT\s*";
        public static string pattern9 = @"\(\s*SELECT.*?FROM.*?[^\(SELECT)]\)\sWHERE.*?\)|\(\s*SELECT.*?FROM.*?[^\(SELECT)]\)";
        public static string pattern10 = @"\s{2,}";
        public static string pattern11 = @"(\((?:\(??[^\(]*?\)))"; //가장 안쪽 괄호
        public static string pattern12 = @"(?<=\()SELECT.+?(?=\))"; //(SELECT)
        public static string pattern13 = @"\(([^ㅁ]+)\)"; //가장 바깥 괄호
        public static string pattern14 = @"\s*"; //가장 공백
        public static string pattern15 = @"\s*\=\s*"; // '=' 양옆에 모든 공백문자 포함.

        public static List<ColorList> ColorKeywardList = new List<ColorList>();
        WBCommon()
        {
            ColorList item = new ColorList() { KeyWard = "SELECT", Col = Colors.Blue };
            ColorKeywardList.Add(item);
        }

        public static string GetBlank(string txt) => GetBlank(txt, 50);

        public static string GetBlank(string txt, int len)
        {
            int num = len - txt.Length;
            if (num < 1)
                return "";
            string blank = "";
            for (int index = 0; index < num; ++index)
                blank += " ";
            return blank;
        }

        /// <summary>
        /// name         : DTO의 프로퍼티 값 리턴
        /// desc         : DTO의 프로퍼티 값 리턴        
        /// create date  : 2021-08-25
        /// update date  : 2021-08-25
        /// </summary>
        public static string GetPropertyValue(object dto, string propertyName)
        {
            string value = "";

            if (dto.GetType().GetProperty(propertyName) != null)
            {
                if (dto.GetType().GetProperty(propertyName).GetValue(dto) == null)
                    value = "";
                else
                    value = dto.GetType().GetProperty(propertyName).GetValue(dto, (object[])null).ToString();
            }

            return value;
        }
    }

    public class ColorList
    {
        public string KeyWard { get; set;  }
        public Color Col { get; set; }
    }

}
