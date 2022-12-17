using System;
using System.Collections.Generic;
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
    public partial class CodeWindow : Window,IDisposable
    {
        private System.Windows.Forms.RichTextBoxFinds matchType = System.Windows.Forms.RichTextBoxFinds.None;
        private Dictionary<int, int> SearchTextList = new Dictionary<int, int>();
        private int searchSwitch = 1;
        public CodeWindow()
        {
            InitializeComponent();
            
        }

        public void Dispose()
        {
            
        }
       
        private void txtCode_GotFocus(object sender, RoutedEventArgs e)
        {
            (sender as TextBox).SelectAll();
        }

        //private void Button_Click(object sender, RoutedEventArgs e)
        //{
        //    int iFindStartIndex = 0;
        //    int cnt = 1;
        //    txtCode.SelectAll();
        //    txtCode.SelectionColor = System.Drawing.Color.Black;
        //    SearchTextList.Clear();
        //    searchSwitch = 1; //초기화
        //    while (true)
        //    {
        //        int iFindLength = this.searchText.Text.Length;
        //        iFindStartIndex = FindText(this.searchText.Text, iFindStartIndex, txtCode.Text.Length);
        //        if (iFindStartIndex == -1)
        //        {
        //            iFindStartIndex = 0;
        //            this.txtSearchCnt.Text = SearchTextList.Count.ToString();
        //            return;
        //        }
        //        //문자열 붉은색으로 변경
        //        txtCode.SelectionColor = System.Drawing.Color.Red;
        //        txtCode.Select(iFindStartIndex, iFindLength);

        //        //찾은 문자열 위치 저장
        //        SearchTextList.Add(cnt, iFindStartIndex);
        //        cnt++;
        //        iFindStartIndex += iFindLength;
        //    }
            
        //}

        //private int FindText(string searchText , int searchStart, int searchEnd)
        //{
        //    int returnValue = -1;
        //    if(searchText.Length > 0 && searchStart >= 0)
        //    {
        //        if(searchEnd > searchStart || searchEnd == -1)
        //        {
        //            int indexToText = this.txtCode.Find(searchText, searchStart, searchEnd, matchType);
        //            if(indexToText >= 0)
        //            {
        //                returnValue = indexToText;
        //            }
        //        }
        //    }
        //    return returnValue;
        //}

        //string StringFromRichTextBox(RichTextBox rtb)
        //{
        //    TextRange textRange = new TextRange(
        //   // TextPointer to the start of content in the RichTextBox.
        //           rtb.Document.ContentStart,
        //   // TextPointer to the end of content in the RichTextBox.
        //           rtb.Document.ContentEnd
        //    );

        //    // The Text property on a TextRange object returns a string
        //    // representing the plain text content of the TextRange.
        //    return textRange.Text;
        //}

        //private void searchText_KeyDown(object sender, System.Windows.Input.KeyEventArgs e)
        //{
        //    if (e.Key == System.Windows.Input.Key.Enter)
        //        Button_Click(sender, e);           
        //}
        //private void FocusSearchText(object sender , RoutedEventArgs e)
        //{
        //    if (Keyboard.IsKeyDown(Key.LeftCtrl) && Keyboard.IsKeyDown(Key.F))
        //        this.searchText.Focus();
        //    if (Keyboard.IsKeyDown(Key.F3))
        //    {
        //        if (SearchTextList.Count <= 0) return;
        //        this.txtCode.Focus();
        //        if (SearchTextList.ContainsKey(searchSwitch))
        //        {
        //            this.txtCode.Select(SearchTextList[searchSwitch], this.searchText.Text.Length);
        //            searchSwitch = ++searchSwitch;//찾은건수보다 누른 수치가 적으면 증가, 많아지면 1로 초기화
        //        }
        //        else if(searchSwitch >= SearchTextList.Count)
        //        {
        //            searchSwitch = 1;
        //            this.txtCode.Select(SearchTextList[searchSwitch], this.searchText.Text.Length);
        //            searchSwitch = ++searchSwitch;//찾은건수보다 누른 수치가 적으면 증가, 많아지면 1로 초기화
        //        }
        //    }
        //    if (Keyboard.IsKeyDown(Key.Escape))
        //        this.Close();
        //}

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            this.txtCode.Focus();
            //this.KeyDown -= FocusSearchText;
            //this.KeyDown += FocusSearchText;
        }

        private void CheckBox_Checked(object sender, RoutedEventArgs e)
        {
            matchType = System.Windows.Forms.RichTextBoxFinds.MatchCase;
        }

        private void CheckBox_Unchecked(object sender, RoutedEventArgs e)
        {
            matchType = System.Windows.Forms.RichTextBoxFinds.None;
        }
        
    }
}
