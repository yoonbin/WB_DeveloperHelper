using PoorMansTSqlFormatterLib.Formatters;
using PoorMansTSqlFormatterLib.Interfaces;
using System;
using System.Collections.Generic;
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
using System.Xml;
using WB.Common;
using WB.UC;

namespace WB
{
    /// <summary>
    /// CodeReOrder.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class CodeReOrder : UCBase
    {
        private CodeReOrderData model;

        public CodeReOrder()
        {
            InitializeComponent();
            this.model = DataContext as CodeReOrderData;
        }
        private void UCBase_Loaded(object sender, RoutedEventArgs e)
        {
            this.OwnerWindow.KeyDown -= TextBox_KeyDown;
            this.OwnerWindow.KeyDown += TextBox_KeyDown;
        }
        private void TextBox_KeyDown(object sender, KeyEventArgs e)
        {

            if (e.Key == Key.F5)                
                ConvertCode();
        }
        private void ConvertCode()
        {
            try
            {
                if (string.IsNullOrEmpty(this.model.TARGET_CODE)) return;
                //간격종류
                string commaTab = "     ";
                string fromTab = "  ";
                string whereTab = " ";
                string andTab = "   ";
                string orderByTab = " ";

                int galhoCnt = 0; // () 카운트. (를 만나면 1증가 )를 만나면 1 감소 . 0이되면 괄호를 다 찾았다는 의미.
                int scalaGalhoCnt = 0; //ScalaQuery안에서 괄호를 만나면 체크.
                bool scalaQueryOn = false; //ScalaQuery를 만나면 true , 빠져나오면 false
                bool mainFromOn = false; //Main From절 만나면 true, Where절 진입하면 false;
                bool mainWhereOn = false; //Main Where절 만나면 true; Order by ,Group by 만나면 false;
                bool orderByOn = false; //Order by를 만나면 true
                bool betweenOn = false; //BETWEEN 만나면 true
                bool betweenAndOn = false; //BETWEEN 안에서 AND 만나면 true            

                var searchText1 = string.Format("SELECT*{0}*FROM*WHERE*AND", @"\" + ")").Split('*'); //뒤쪽에 공백 (엔터 후 뒤에 공백추가할 단어)
                var searchText2 = "FROM*WHERE*AND".Split('*'); //양쪽에 공백
                var searchText3 = string.Format("ORDERBY*FROM*WHERE*AND*DECODE*TO_CHAR*TO_DATE*{0}", @"\" + "(SELECT").Split('*'); //단어 앞쪽에 공백 (엔터할 단어 추가)
                string code = this.model.TARGET_CODE;
                code = Regex.Replace(code, WBCommon.pattern7, string.Empty); //주석제거
                code = code.ToUpper().Replace("\n", " ").Replace("\r", " "); //엔터 제거                        
                code = Regex.Replace(code, WBCommon.pattern10, " "); //SELECT이후 빈칸 2개이상 1개로 수정
                                                                     //code = Regex.Replace(code, @"\s*", string.Empty); //SELECT이후 빈칸 2개이상 1개로 수정

                //foreach (var searchWord in searchText2)
                //{
                //    code = Regex.Replace(code, @searchWord, " " + searchWord + " ");
                //}
                //단어 앞쪽에 공백을 주고 엔터로 치환
                foreach (var searchWord in searchText3)
                {
                    code = Regex.Replace(code, @searchWord, "엔터" + searchWord);
                }
                code = Regex.Replace(code, @"엔터", "\n");

                //치환 후 단어 뒤쪽에 공백 추가
                //foreach (var searchWord in searchText1)
                //{
                //    code = Regex.Replace(code, searchWord, searchWord + " ");
                //}
                //'\' 제거
                code = Regex.Replace(code, @"\\", string.Empty);

                // '()' 밖의 ','를 엔터하고 ','로 수정
                code = Regex.Replace(code, WBCommon.pattern1, "\n" + ",");

                // 테이블과 Alias 분리
                code = Regex.Replace(code, @"(?<=FROM )[^\n]*", new MatchEvaluator(GetTableName));

                // '=' 양옆에 공백 추가
                code = Regex.Replace(code, WBCommon.pattern15, " = ");

                // ',' 뒤에 공백추가
                code = Regex.Replace(code, WBCommon.pattern2, ", ");
                //코드 한줄씩 읽기위해 텍스트로 저장
                string savePath = @".\code.txt";
                StreamWriter writer;
                writer = File.CreateText(savePath);
                writer.Write(code);
                writer.Close();
                //Line 앞에 공백 추가
                string strLine = "";
                code = "";
                using (StreamReader srFile = new StreamReader(savePath))
                {
                    while ((strLine = srFile.ReadLine()) != null)
                    {
                        if (strLine.IndexOf("SELECT") == 0)
                        {
                            string column = "";
                            var column_name = "";
                            Regex.Replace(strLine, @"(SELECT).+\s", new MatchEvaluator(m => column = m.Value));
                            Regex.Replace(strLine, @"(?<=(SELECT).+\s).*", new MatchEvaluator(m => column_name = m.Value));
                            if (!string.IsNullOrEmpty(column))
                                code += column + WBCommon.GetBlank(column, this.model.COLUMN_NAME_SPACED) + commaTab + column_name + WBCommon.BR;
                            else
                                code += strLine + WBCommon.BR;
                        }
                        else if (strLine.IndexOf("(SELECT") > -1)
                        {
                            commaTab = "     "; //초기화
                            scalaQueryOn = true;
                            galhoCnt++;
                            code += commaTab + strLine + WBCommon.BR;
                        }
                        else if (scalaQueryOn)
                        {

                            if (strLine.IndexOf("FROM") > -1)
                                code += WBCommon.GetBlank("", 8 * galhoCnt) + fromTab + strLine + WBCommon.BR;
                            else if (strLine.IndexOf("WHERE") > -1)
                            {
                                if (Regex.IsMatch(strLine, @"BETWEEN"))
                                {
                                    betweenOn = true;
                                    code += WBCommon.GetBlank("", 8 * galhoCnt) + whereTab + strLine;
                                }
                                else
                                    code += WBCommon.GetBlank("", 8 * galhoCnt) + whereTab + strLine + WBCommon.BR;
                            }
                            else if (betweenOn)
                            {
                                //AND 뒤에단어가 붙어있을 경우
                                if (Regex.IsMatch(strLine, @"(?<=AND).\w+"))
                                {
                                    betweenAndOn = false;
                                    betweenOn = false;
                                    code += strLine + WBCommon.BR;
                                }
                                //AND 단독으로 있을경우
                                else if (Regex.IsMatch(strLine, @"AND"))
                                {
                                    betweenAndOn = true;
                                    code += strLine;
                                }
                                //AND 이후 단어가 있으면 
                                else if (Regex.IsMatch(strLine, @"\w+") && betweenAndOn)
                                {
                                    betweenAndOn = false;
                                    betweenOn = false;
                                    code += strLine + WBCommon.BR;
                                }
                                //BETWEEN ~ AND 사이
                                else
                                    code += strLine;
                            }
                            else if (strLine.IndexOf("AND") > -1)
                            {
                                scalaGalhoCnt = GetGalhoCnt(scalaGalhoCnt, strLine);

                                if (Regex.IsMatch(strLine, @"(NOT).*(?=(IN.*\())"))
                                    code += WBCommon.GetBlank("", 8 * galhoCnt) + andTab + Regex.Replace(strLine, @"(NOT).*(?=(IN.*\())", new MatchEvaluator(m => " " + m.Value + " ")) + WBCommon.BR;
                                else if (Regex.IsMatch(strLine, @"(IN).*(?=\()"))
                                    code += WBCommon.GetBlank("", 8 * galhoCnt) + andTab + Regex.Replace(strLine, @"(IN).*(?=\()", new MatchEvaluator(m => " " + m.Value + " ")) + WBCommon.BR;
                                else if (Regex.IsMatch(strLine, @"BETWEEN"))
                                {
                                    betweenOn = true;
                                    code += WBCommon.GetBlank("", 8 * galhoCnt) + andTab + strLine;
                                }
                                else
                                    code += WBCommon.GetBlank("", 8 * galhoCnt) + andTab + strLine + (scalaGalhoCnt > 0 ? "" : WBCommon.BR);
                            }
                            else if (scalaGalhoCnt > 0)
                            {
                                scalaGalhoCnt = GetGalhoCnt(scalaGalhoCnt, strLine);
                                code += strLine + (scalaGalhoCnt > 0 ? "" : WBCommon.BR);
                            }

                            galhoCnt = GetGalhoCnt(galhoCnt, strLine);

                            //괄호를 다찾으면 스칼라쿼리 빠져나옴.
                            if (galhoCnt == 0)
                                scalaQueryOn = false;

                        }
                        else if (strLine.IndexOf("FROM") > -1)
                        {
                            mainFromOn = true;
                            code += fromTab + strLine + WBCommon.BR;
                        }
                        else if (strLine.IndexOf("WHERE") > -1)
                        {
                            mainWhereOn = true;
                            mainFromOn = false;
                            code += whereTab + strLine + WBCommon.BR;
                        }
                        else if (betweenOn)
                        {
                            //AND
                            if (Regex.IsMatch(strLine, @"AND"))
                            {
                                betweenAndOn = true;
                                code += strLine;
                            }
                            //AND 이후 단어가 있으면 
                            else if (Regex.IsMatch(strLine, @"\w+") && betweenAndOn)
                            {
                                betweenAndOn = false;
                                betweenOn = false;
                                code += strLine + WBCommon.BR;
                            }
                            //BETWEEN ~ AND 사이
                            else
                                code += strLine;
                        }
                        else if (strLine.IndexOf("AND") > -1)
                        {
                            galhoCnt = GetGalhoCnt(galhoCnt, strLine);
                            //andTab = galhoCnt == 0 ? "   " : "";
                            if (Regex.IsMatch(strLine, @"(NOT).*(?=(IN.*\())"))
                                code += andTab + Regex.Replace(strLine, @"(NOT).*(?=(IN.*\())", new MatchEvaluator(m => " " + m.Value + " ")) + WBCommon.BR;
                            else if (Regex.IsMatch(strLine, @"(IN).*(?=\()"))
                                code += andTab + Regex.Replace(strLine, @"(IN).*(?=\()", new MatchEvaluator(m => " " + m.Value + " ")) + WBCommon.BR;
                            else if (Regex.IsMatch(strLine, @"BETWEEN"))
                            {
                                betweenOn = true;
                                code += andTab + strLine;
                            }
                            else
                                code += andTab + strLine + (galhoCnt > 0 ? "" : WBCommon.BR); //괄호가 열려있으면 엔터하지 않음.
                        }
                        else if (strLine.IndexOf("ORDERBY") > -1)
                        {
                            orderByOn = true;
                            mainWhereOn = false;
                            code += orderByTab + Regex.Replace(strLine, @"ORDER|BY", new MatchEvaluator(m => m.Value + " "));
                        }
                        else if (mainFromOn)
                        {
                            code += commaTab + Regex.Replace(strLine, @"(?<=\,)[^,]*", new MatchEvaluator(m => " " + m.Value.Trim().Substring(0, 8) + " " + m.Value.Trim().Substring(8))) + WBCommon.BR;
                        }
                        else if (orderByOn)
                        {
                            code += strLine;
                        }
                        //,뒤에 ,와 (가 아닌 어떠한 문자가 들어오면 true
                        else if (Regex.IsMatch(strLine, @"^,[^,(]*\w"))
                        {
                            var column = "";
                            if (Regex.IsMatch(strLine, @"\("))
                            {
                                galhoCnt += Regex.Matches(strLine, @"\(").Count;
                                galhoCnt -= Regex.Matches(strLine, @"\)").Count;
                                column += strLine.Substring(0, strLine.LastIndexOf(")") + 1);
                            }
                            else if (Regex.IsMatch(strLine, @"\)"))
                            {
                                galhoCnt += Regex.Matches(strLine, @"\(").Count;
                                galhoCnt -= Regex.Matches(strLine, @"\)").Count;
                                column += strLine.Substring(0, strLine.LastIndexOf(")") + 1);
                            }
                            else
                            {
                                var str = Regex.Replace(strLine, @"\s{2,}", " ");
                                //Regex.Replace(str, @".*\s", new MatchEvaluator(m => column = m.Value));
                                Regex.Replace(str, @".*\s(?=[^\/])", new MatchEvaluator(m => column = m.Value));
                            }

                            if (mainWhereOn)
                                commaTab = "";
                            else if (!mainWhereOn && galhoCnt == 1)
                                commaTab = "     ";
                            else if (!mainWhereOn && galhoCnt <= 0)
                                commaTab = "     ";
                            else
                                commaTab = "";

                            // ')' 뒤에 공백이 있는경우
                            if (Regex.IsMatch(strLine, @"(?<=\))\s+(?=\w)"))
                            {
                                code += commaTab + Regex.Replace(strLine, @"(?<=\))\s+(?=\w)", new MatchEvaluator(m => WBCommon.GetBlank(column, this.model.COLUMN_NAME_SPACED))) + WBCommon.BR;

                            }
                            // ')' 뒤에 공백이 없는경우
                            else if (Regex.IsMatch(strLine, @"(?<=\)).+(?=\w)"))
                            {
                                //WHERE절
                                if (mainWhereOn)
                                    code += commaTab + strLine + WBCommon.BR;
                                //컬럼 부분
                                else
                                    code += commaTab + Regex.Replace(strLine, @"(?<=\)).+(?=\w)", new MatchEvaluator(m => WBCommon.GetBlank(column, this.model.COLUMN_NAME_SPACED) + m.Value)) + WBCommon.BR;

                            }
                            // ()없이 일반 컬럼과 컬럼명 사이에 공백이 있는 경우
                            else if (Regex.IsMatch(strLine, @"(?<=\w)\s+(?=\w)"))
                            {
                                code += commaTab + Regex.Replace(strLine, @"(?<=\w)\s+(?=\w)", new MatchEvaluator(m => WBCommon.GetBlank(column, this.model.COLUMN_NAME_SPACED + 1))) + WBCommon.BR;

                            }
                            else
                                code += commaTab + strLine + (galhoCnt > 0 ? "" : WBCommon.BR); //괄호가 열려있으면 엔터하지 않음.
                        }
                        else if (Regex.IsMatch(strLine, @"(NOT).*(?=(IN.*\())"))
                            code += commaTab + Regex.Replace(strLine, @"(NOT).*(?=(IN.*\())", new MatchEvaluator(m => " " + m.Value + " ")) + WBCommon.BR;
                        else if (Regex.IsMatch(strLine, @"(IN).*(?=\()"))
                            code += commaTab + Regex.Replace(strLine, @"(IN).*(?=\()", new MatchEvaluator(m => " " + m.Value + " ")) + WBCommon.BR;
                        else
                        {
                            galhoCnt = GetGalhoCnt(galhoCnt, strLine);
                            commaTab = galhoCnt == 1 ? "     " : "";
                            code += commaTab + strLine + (galhoCnt > 0 ? "" : WBCommon.BR); //괄호가 열려있으면 엔터하지 않음.
                        }
                    }
                }

                this.model.RESULT_CODE = code;
            }
            catch
            {

            }            
        }
        private int GetGalhoCnt(int galhoCnt,string strLine)
        {
            if (Regex.IsMatch(strLine, @"\("))
            {
                galhoCnt += Regex.Matches(strLine, @"\(").Count;
                galhoCnt -= Regex.Matches(strLine, @"\)").Count;
            }
            else if (Regex.IsMatch(strLine, @"\)"))
            {
                galhoCnt += Regex.Matches(strLine, @"\(").Count;
                galhoCnt -= Regex.Matches(strLine, @"\)").Count;
            }
            return galhoCnt;
        }
        private string GetTableName(Match m)
        {
            string code = m.Value.Trim();
            if(code.Length > 8)
                code = code.Substring(0, 8) + " " + code.Substring(8);
            return code;
        }
        //private void SelectWord()
        //{
        //    int iFindStartIndex = 0;
        //    int cnt = 1;
        //    txtCode.SelectAll();
        //    txtCode.SelectionColor = System.Drawing.Color.Black;
        //    var searchText = "SELECT*FROM*WHERE*AND".Split('*');
        //    foreach (var searchWord in searchText)
        //    {
        //        this.txtCode.Text = Regex.Replace(this.txtCode.Text, @searchWord, " " + searchWord + " ");
        //    }
        //    foreach (var searchWord in searchText)
        //    {            
        //        while (true)
        //        {
        //            int iFindLength = searchText.Length;
        //            iFindStartIndex = FindText(searchWord, iFindStartIndex, txtCode.Text.Length);
        //            if (iFindStartIndex == -1)
        //            {
        //                iFindStartIndex = 0;
        //                break;
        //            }
        //            //문자열 붉은색으로 변경
        //            txtCode.SelectionColor = System.Drawing.Color.Red;
        //            txtCode.Select(iFindStartIndex, iFindLength);

        //            //찾은 문자열 위치 저장                
        //            cnt++;
        //            iFindStartIndex += iFindLength;
        //        }
        //    }
        //}
        //private int FindText(string searchText, int searchStart, int searchEnd)
        //{
        //    int returnValue = -1;
        //    if (searchText.Length > 0 && searchStart >= 0)
        //    {
        //        if (searchEnd > searchStart || searchEnd == -1)
        //        {
        //            int indexToText = this.txtCode.Find(searchText, searchStart, searchEnd, System.Windows.Forms.RichTextBoxFinds.MatchCase);
        //            if (indexToText >= 0)
        //            {
        //                returnValue = indexToText;
        //            }
        //        }
        //    }
        //    return returnValue;
        //}

        private void Convert_Click(object sender, RoutedEventArgs e)
        {
            ConvertCode();
            //MatchEvaluator matchEvaluator = new MatchEvaluator(this.ReturnSpace);
            //string code = this.model.TARGET_CODE;
            //code = SelectQueryConvert(code);  

            //this.model.RESULT_CODE = code;
        }

        private string ReturnSpace(Match m)
        {            
            string match = m.Value;            
            if (match.IndexOf("SELECT") < 0) return string.Empty;
            match = Regex.Replace(match, WBCommon.pattern7, string.Empty); //주석제거
            match = match.ToUpper().Replace("\n", " ").Replace("\r", " "); //엔터 제거            
            match = Regex.Replace(match, WBCommon.pattern8, "SELECT "); //SELECT이후 공백 제거            
            match = Regex.Replace(match, WBCommon.pattern1, string.Format("{0}{1}{2}", (object)"\n", WBCommon.GetBlank("", 6), (object)", "));
            match = Regex.Replace(match, WBCommon.pattern2, ", ");
            match = Regex.Replace(match, WBCommon.pattern3, "\n" + WBCommon.GetBlank("", 7)+"   FROM ");
            match = Regex.Replace(match, WBCommon.pattern4, "\n" + WBCommon.GetBlank("", 7) + "  WHERE");
            match = Regex.Replace(match, WBCommon.pattern5, "\n" + WBCommon.GetBlank("", 7) + "    AND ");
            match = Regex.Replace(match, WBCommon.pattern6, " = ");
            this.model.TAB_NUMBER++;
            return match;
        }
        private string SelectQueryConvert(string code)
        {                  
            code = Regex.Replace(code, WBCommon.pattern7, string.Empty); //주석제거
            code = code.ToUpper().Replace("\n", " ").Replace("\r", " "); //엔터 제거            
            code = Regex.Replace(code, WBCommon.pattern8, "SELECT "); //SELECT이후 공백 제거
            code = Regex.Replace(code, WBCommon.pattern10, " "); //SELECT이후 빈칸 2개이상 1개로 수정
            code = Regex.Replace(code, WBCommon.pattern13, new MatchEvaluator(this.CheckGalho)); //SELECT이후 빈칸 2개이상 1개로 수정                                                             
            code = Regex.Replace(code, WBCommon.pattern1, string.Format("{0}{1}{2}", (object)"\n", WBCommon.GetBlank("", 5), (object)", ")); //COMMA로 엔터
            code = Regex.Replace(code, WBCommon.pattern2, ", ");
            code = Regex.Replace(code, WBCommon.pattern3, "\n" + "  FROM ");
            code = Regex.Replace(code, WBCommon.pattern4, "\n" + " WHERE ");
            code = Regex.Replace(code, WBCommon.pattern5, "\n" + "   AND ");
            code = Regex.Replace(code, WBCommon.pattern6, " = ");
            code = Regex.Replace(code, WBCommon.pattern13, new MatchEvaluator(GetSpaceGalho));
            return code;
        }

        private string CheckGalho(Match m)
        {
            string match = m.Value;           
            match = Regex.Replace(match, WBCommon.pattern7, string.Empty); //주석제거
            match = match.ToUpper().Replace("\n", " ").Replace("\r", " "); //엔터 제거            
            match = Regex.Replace(match, WBCommon.pattern8, "SELECT "); //SELECT이후 공백 제거
            match = Regex.Replace(match, WBCommon.pattern10, " "); //SELECT이후 빈칸 2개이상 1개로 수정
                                                                         
            match = Regex.Replace(match, WBCommon.pattern1, string.Format("{0}{2}", (object)"\n", WBCommon.GetBlank("", 5), (object)", ")); //COMMA로 엔터
            match = Regex.Replace(match, WBCommon.pattern2, ", ");
            match = Regex.Replace(match, WBCommon.pattern3, "\n" + "  FROM ");
            match = Regex.Replace(match, WBCommon.pattern4, "\n" + " WHERE");
            match = Regex.Replace(match, WBCommon.pattern5, "\n" + "   AND ");
            match = Regex.Replace(match, WBCommon.pattern6, " = ");
            match = "\n" + match;
            return match;
        }
        private string GetSpaceGalho(Match m)
        {
            //string code = "(" + WBCommon.BR;
            string code = "" ;
            string match = m.Value.Substring(1, m.Value.Length - 2);
            foreach(var word in m.Value.Split('\n'))
            {    
               if(word.Trim().IndexOf(",") == 0)
                    code += word + WBCommon.BR;
               else if (word.Trim().IndexOf("(") == 0)
                    code += word + WBCommon.BR;  
                else
                    code += WBCommon.TAB + WBCommon.TAB + word + WBCommon.BR;
            }            
                code = code.TrimEnd(new char[] { '\r', '\n' });
            return code;
        }       
        private void TextBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Regex regex = new Regex("[^0-9]+");
            e.Handled = regex.IsMatch(e.Text);        
        }

       
    }
}

