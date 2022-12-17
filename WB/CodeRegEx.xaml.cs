using System;
using System.Collections.Generic;
using System.Data;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;

namespace WB
{
    /// <summary>
    /// CodeWindow.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class CodeRegEx : Window,IDisposable
    {
        private System.Windows.Forms.RichTextBoxFinds matchType = System.Windows.Forms.RichTextBoxFinds.None;
        private Dictionary<int, int> SearchTextLength = new Dictionary<int, int>(); //INDEX - LENGTH
        private Dictionary<int, int> SearchTextIndex = new Dictionary<int, int>(); //CNT - INDEX
        private Dictionary<string, string> HelpDic= new Dictionary<string, string>(); //CNT - INDEX
        private RegexOptions regOptions = RegexOptions.IgnoreCase;
        private DataTable helpDt = new DataTable();
        public CodeRegEx()
        {
            InitializeComponent();
            
        }
        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            this.txtCode.Focus();
            this.KeyDown -= FocusSearchText;
            this.KeyDown += FocusSearchText;
            InputMethod.SetIsInputMethodEnabled(this.txtFontSize, false);
            
            helpDt.Columns.Add("SYM");
            helpDt.Columns.Add("MNNG");

            HelpDic.Add("?", "없거나 or 최대 한개만");
            HelpDic.Add("*", "없거나 or 있거나(여러개)");
            HelpDic.Add("+", "최소 한개 or 여러개");
            HelpDic.Add("*?", "없거나, 있거나 and 없거나, 최대한개 : 없음 ({0}과 동일)");
            HelpDic.Add("+?", "최소한개, 있거나 and 없거나, 최대한개 : 한개 ({1}과 동일)");
            HelpDic.Add("{n}", "n개");
            HelpDic.Add("{n,}", "최소 n개 이상");
            HelpDic.Add("{n,m}", "최소 n개 이상, 최대 m개 이하 n ~ m ({3,5}? == {3} 과 동일) ");
            HelpDic.Add("a-z, A-Z", "영어 알파벳 ( - 으로 범위지정)");
            HelpDic.Add("ㄱ-ㅎ, 가-힣", "한글문자 ( - 으로 범위지정)");
            HelpDic.Add("0-9", "숫자( - 으로 범위지정)");
            HelpDic.Add(".", @"\n(줄바꿈)을 제외한 모든 문자");
            HelpDic.Add(@"\d", "숫자");
            HelpDic.Add(@"\D", "숫자가 아닌것");
            HelpDic.Add(@"\w", "밑줄 문자를 포함한 영숫자 문자 (A-Za -z0-9) 와 동일");
            HelpDic.Add(@"\W", @"\w가 아닌것");
            HelpDic.Add(@"\s", "space 공백문자");
            HelpDic.Add(@"\S", @"\s 의 반대");
            HelpDic.Add(@"\특수기호", @"\이후 오는 특수문자를 그대로 표시해줌.");
            HelpDic.Add(@"\b", @"63개문자가(52개 영문대소문자, 숫자10개, UnderBar(_)) 아닌 나머지 문자에 일치하는 경계");
            HelpDic.Add(@"\B", @"63개문자(52개 영문대소문자, 숫자10개, UnderBar(_))에 일치하는 경계");
            HelpDic.Add(@"\x", @"16진수 문자");
            HelpDic.Add(@"\0", @"8진수 문자");
            HelpDic.Add(@"\u", @"유니코드 문자");
            HelpDic.Add(@"\c", @"Control(제어) 문자에 일치");
            HelpDic.Add(@"\f", @"폼 피드(FF,U+000C) 문자에 일치");
            HelpDic.Add(@"\n", @"줄바꿈 문자에 일치");
            HelpDic.Add(@"\r", @"캐리지 리턴 (CR) 문자에 일치");
            HelpDic.Add(@"\t", @"탭 문자에 일치");
            HelpDic.Add(@" | ", @"정규식 패턴 OR (pattern1 | pattern2 => pattern1을 만족하거나 pattern2를 만족)");
            HelpDic.Add(@"[]", @"괄호안의 문자들 중 하나 [abc] => a나 b 나 c를 찾으면 Match" );
            HelpDic.Add(@"[^문자]", @"괄호안의 문자제외 (대괄호 안에서 쓰면 제외의 뜻, 대괄호 밖에서 쓰면 시작점 뜻)");
            HelpDic.Add(@"^문자열", @"특정 문자열로 시작 (시작점)");
            HelpDic.Add(@"문자열$", @"특정 문자열로 끝남 (종착점)");
            HelpDic.Add(@"()", @"그룹화 및 캡쳐");
            HelpDic.Add(@"(?:패턴)", @"그룹화 (캡쳐하지않음)");
            HelpDic.Add(@"(?= 패턴)", @"앞쪽 일치(Lookahead),/ab(?=c)/");
            HelpDic.Add(@"(?!)", @"부정 앞쪽 일치(Negative Lookahead),/ab(?!c)/");
            HelpDic.Add(@"(?<=)", @"뒤쪽 일치(Lookbehind),/(?<=ab)c/ ");
            HelpDic.Add(@"(?<!)", @"부정 뒤쪽 일치(Negative Lookbehind),/(?<!ab)c/");

            foreach (var key in HelpDic.Keys)
            {
                DataRow dtRow = helpDt.NewRow();
                dtRow["SYM"] = key;
                dtRow["MNNG"] = HelpDic[key];
                helpDt.Rows.Add(dtRow);
            }
            this.dgrdHelp.ItemsSource = helpDt.DefaultView;
        }
        public void Dispose()
        {
            
        }
       
        private void txtCode_GotFocus(object sender, RoutedEventArgs e)
        {
            (sender as TextBox).SelectAll();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            if (txtCode == null) return;

            int iFindStartIndex = 0;
            int cnt = 1;
            MatchCollection matchCollection;
            txtCode.SelectAll();
            string fontSize = string.IsNullOrEmpty(txtFontSize.Text) ? "10" : txtFontSize.Text;
            txtCode.SelectionFont = new System.Drawing.Font("Courier New", Convert.ToInt32(fontSize), System.Drawing.FontStyle.Regular);
            txtCode.SelectionColor = System.Drawing.Color.Black;
            txtCode.SelectionBackColor = System.Drawing.Color.White;
            SearchTextIndex.Clear();
            SearchTextLength.Clear();            
            
            try
            {
                matchCollection = Regex.Matches(txtCode.Text, string.Format(@"{0}", this.searchText.Text), regOptions);
                foreach (var searchText in matchCollection)
                {
                    int iFindLength = this.searchText.Text.Length;
                    iFindStartIndex = FindText(searchText.ToString(), iFindStartIndex, txtCode.Text.Length);
                    if (iFindStartIndex == -1)
                    {
                        iFindStartIndex = 0;
                        //this.txtSearchCnt.Text = SearchTextList.Count.ToString();
                        return;
                    }
                    //문자열 붉은색으로 변경
                    txtCode.SelectionColor = System.Drawing.Color.Black;
                    txtCode.SelectionBackColor = System.Drawing.Color.Yellow;
                    txtCode.Select(iFindStartIndex, iFindLength);

                    //찾은 문자열 위치 저장
                    SearchTextLength.Add(iFindStartIndex, iFindLength);
                    SearchTextIndex.Add(cnt, iFindStartIndex);
                    cnt++;
                    iFindStartIndex += iFindLength;
                }
            }
            catch(Exception)
            {

            }           
            

            //if (SearchTextIndex.Count <= 0) return;
            //this.txtCode.Focus();
            //for (int i = 1; i < SearchTextIndex.Count + 1; i++)
            //{
            //    if (SearchTextIndex.ContainsKey(i))
            //    {
            //        var index = SearchTextIndex[i];
            //        var length = SearchTextLength[index];
            //        this.txtCode.Select(index, length);
            //        searchSwitch = ++searchSwitch;//찾은건수보다 누른 수치가 적으면 증가, 많아지면 1로 초기화
            //    }            
            //}

        }

        private int FindText(string searchText , int searchStart, int searchEnd)
        {
            int returnValue = -1;
            if(searchText.Length > 0 && searchStart >= 0)
            {
                if(searchEnd > searchStart || searchEnd == -1)
                {
                    int indexToText = this.txtCode.Find(searchText, searchStart, searchEnd, matchType);
                    if(indexToText >= 0)
                    {
                        returnValue = indexToText;
                    }
                }
            }
            return returnValue;
        }

        string StringFromRichTextBox(RichTextBox rtb)
        {
            TextRange textRange = new TextRange(
           // TextPointer to the start of content in the RichTextBox.
                   rtb.Document.ContentStart,
           // TextPointer to the end of content in the RichTextBox.
                   rtb.Document.ContentEnd
            );

            // The Text property on a TextRange object returns a string
            // representing the plain text content of the TextRange.
            return textRange.Text;
        }

        private void searchText_KeyDown(object sender, System.Windows.Input.KeyEventArgs e)
        {
            if (e.Key == System.Windows.Input.Key.Enter)
                Button_Click(sender, e);           
        }
        private void FocusSearchText(object sender , RoutedEventArgs e)
        {
            if (Keyboard.IsKeyDown(Key.LeftCtrl) && Keyboard.IsKeyDown(Key.F))
                this.searchText.Focus();
            if (Keyboard.IsKeyDown(Key.F1))
            {
                if (this.grdMain.ColumnDefinitions[0].Width == new GridLength(1, GridUnitType.Star))
                {
                    this.grdMain.ColumnDefinitions[0].Width = new GridLength(0.7, GridUnitType.Star);
                    this.grdMain.ColumnDefinitions[1].Width = new GridLength(0.3, GridUnitType.Star);
                }
                else if (this.grdMain.ColumnDefinitions[0].Width == new GridLength(0.7, GridUnitType.Star))
                {
                    this.grdMain.ColumnDefinitions[0].Width = new GridLength(1, GridUnitType.Star);
                    this.grdMain.ColumnDefinitions[1].Width = new GridLength(0, GridUnitType.Star);
                }
            }
            if (Keyboard.IsKeyDown(Key.Escape))
                this.Close();
        }        

        private void CheckBox_Checked(object sender, RoutedEventArgs e)
        {
            matchType = System.Windows.Forms.RichTextBoxFinds.MatchCase;
        }

        private void CheckBox_Unchecked(object sender, RoutedEventArgs e)
        {
            matchType = System.Windows.Forms.RichTextBoxFinds.None;
        }

        private void searchText_TextChanged(object sender, TextChangedEventArgs e)
        {
            Button_Click(sender, e);
        }

        private void CheckBox_Checked_1(object sender, RoutedEventArgs e)
        {
            if (chkI == null || chkM == null || chkS== null) return;
            regOptions = new RegexOptions();
            if ((bool)this.chkI.IsChecked && (bool)this.chkM.IsChecked && (bool)this.chkS.IsChecked)
                regOptions = RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Singleline;
            else if ((bool)this.chkI.IsChecked && (bool)this.chkM.IsChecked && !(bool)this.chkS.IsChecked)
                regOptions = RegexOptions.IgnoreCase | RegexOptions.Multiline;
            else if ((bool)this.chkI.IsChecked && !(bool)this.chkM.IsChecked && !(bool)this.chkS.IsChecked)
                regOptions = RegexOptions.IgnoreCase;
            else if (!(bool)this.chkI.IsChecked && (bool)this.chkM.IsChecked && (bool)this.chkS.IsChecked)
                regOptions = RegexOptions.Multiline | RegexOptions.Singleline;
            else if (!(bool)this.chkI.IsChecked && !(bool)this.chkM.IsChecked && (bool)this.chkS.IsChecked)
                regOptions = RegexOptions.Singleline;
            else if (!(bool)this.chkI.IsChecked && (bool)this.chkM.IsChecked && !(bool)this.chkS.IsChecked)
                regOptions = RegexOptions.Multiline;
            else if (!(bool)this.chkI.IsChecked && !(bool)this.chkM.IsChecked && !(bool)this.chkS.IsChecked)
                regOptions = RegexOptions.None;

            Button_Click(sender, e);
        }

        private void CheckBox_Unchecked_1(object sender, RoutedEventArgs e)
        {
            if (chkI == null || chkM == null || chkS == null) return;
            regOptions = new RegexOptions();
            if ((bool)this.chkI.IsChecked && (bool)this.chkM.IsChecked && (bool)this.chkS.IsChecked)
                regOptions = RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Singleline;
            else if ((bool)this.chkI.IsChecked && (bool)this.chkM.IsChecked && !(bool)this.chkS.IsChecked)
                regOptions = RegexOptions.IgnoreCase | RegexOptions.Multiline;
            else if ((bool)this.chkI.IsChecked && !(bool)this.chkM.IsChecked && !(bool)this.chkS.IsChecked)
                regOptions = RegexOptions.IgnoreCase;
            else if (!(bool)this.chkI.IsChecked && (bool)this.chkM.IsChecked && (bool)this.chkS.IsChecked)
                regOptions = RegexOptions.Multiline | RegexOptions.Singleline;
            else if (!(bool)this.chkI.IsChecked && !(bool)this.chkM.IsChecked && (bool)this.chkS.IsChecked)
                regOptions = RegexOptions.Singleline;
            else if (!(bool)this.chkI.IsChecked && (bool)this.chkM.IsChecked && !(bool)this.chkS.IsChecked)
                regOptions = RegexOptions.Multiline;
            else if (!(bool)this.chkI.IsChecked && !(bool)this.chkM.IsChecked && !(bool)this.chkS.IsChecked)
                regOptions = RegexOptions.None;

            Button_Click(sender, e);
        }

        private void txtCode_TextChanged(object sender, EventArgs e)
        {
            txtCode.SelectAll();
            txtCode.SelectionFont = new System.Drawing.Font("Courier New", 10, System.Drawing.FontStyle.Regular);
            txtCode.TextChanged -= txtCode_TextChanged;
        }

        private void txtFontSize_TextChanged(object sender, TextChangedEventArgs e)
        {
            Button_Click(sender, e);
        }

        private void txtFontSize_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {            
            e.Handled = Regex.IsMatch(e.Text, @"[^0-9]+");
        }
    }
}
