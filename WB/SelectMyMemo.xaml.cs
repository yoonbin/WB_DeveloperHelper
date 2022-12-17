using System;
using System.Collections.Generic;
using System.ComponentModel;
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
using WB.UC;

namespace WB
{
    /// <summary>
    /// SelectMyMemo.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class SelectMyMemo : UCBase
    {
        private SelectMyMemoData model;

        private Dictionary<int, TextRange> SearchTextList = new Dictionary<int, TextRange>();

        private int searchSwitch = 1;
        private int findIndex = 0;
        private bool AutoSaveYn = false;
        #region [eventHandler]
        public event TextChangedEventHandler TextChanged;
        public event RoutedEventHandler LostFocused;
        
        #endregion
        #region[DependencyProperty]



        public static readonly DependencyProperty TextProperty = DependencyProperty.Register("Text",
                                                   typeof(string), typeof(SelectMyMemo), new FrameworkPropertyMetadata(OnTextPropertyChanged) { BindsTwoWayByDefault = true });

        public static readonly DependencyProperty AutoSaveProperty = DependencyProperty.Register("AutoSave",
                                                  typeof(bool), typeof(SelectMyMemo), new FrameworkPropertyMetadata(OnAutoSavePropertyChanged));

        public static readonly DependencyProperty FocusPosition_Property = DependencyProperty.Register("FocusPosition",
                                                  typeof(FocusGubn), typeof(SelectMyMemo), new UIPropertyMetadata(FocusGubn.TextBox));

        

        public FocusGubn FocusPosition
        {
            get
            {
                return (FocusGubn)GetValue(FocusPosition_Property);
            }
            set
            {
                SetValue(FocusPosition_Property, value);
            }
        }
        [Bindable(true)]
        public bool AutoSave
        {
            get
            {
                return (bool)GetValue(AutoSaveProperty);
            }
            set
            {
                SetValue(AutoSaveProperty, value);
            }
        }

        [Bindable(true)]
        public string Text
        {
            get
            {
                return (string)GetValue(TextProperty);
            }
            set
            {
                SetValue(TextProperty, value);
            }
        }
        private static void OnTextPropertyChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            var me = ((SelectMyMemo)d);

            me.txtTextCode.Text = e.NewValue == null || string.IsNullOrEmpty(e.NewValue.ToString()) ? "" : e.NewValue.ToString();
            me.model.EDIT_READ = "EDIT";
            if (me.FocusPosition == FocusGubn.SearchTextBox)
            {
                me.searchText.Focus();
                me.SetFocusGubn(0);
            }
            else if (me.FocusPosition == FocusGubn.TextBox)
            {

            }
            //me.txtCode.Document.Blocks.Clear();
            //Paragraph para = new Paragraph();
            //para.Inlines.Add(new Run(e.NewValue.ToString()));
            //me.txtCode.Document.Blocks.Add(para);
            //me.txtCode.Focus();


        }

        private static void OnAutoSavePropertyChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            var me = ((SelectMyMemo)d);
            if (e.NewValue != null)
            {
                me.AutoSaveYn = (bool)e.NewValue;
            }
        }
        #endregion
        public SelectMyMemo()
        {
            InitializeComponent();
            this.model = DataContext as SelectMyMemoData;
            this.KeyDown -= FocusSearchText;
            this.KeyDown += FocusSearchText;

            if (this.AutoSave)
            {
                if (this.model.USERINFO != null && this.model.EDIT_READ == "READ")
                {
                    this.txtCode.Focus();
                    this.txtCode.Document.Blocks.Clear();
                    Paragraph para = new Paragraph();
                    para.Inlines.Add(new Run(this.model.USERINFO.MY_MEMO));
                    this.txtCode.Document.Blocks.Add(para);
                }
                else if (this.model.USERINFO != null && this.model.EDIT_READ == "EDIT")
                {
                    this.txtTextCode.Text = this.model.USERINFO.MY_MEMO;
                }
            }
        }
        public SelectMyMemo(bool AutoSaveYn)
        {
            InitializeComponent();
            this.model = DataContext as SelectMyMemoData;
            this.KeyDown -= FocusSearchText;
            this.KeyDown += FocusSearchText;

            if (AutoSaveYn)
            {
                if (this.model.USERINFO != null && this.model.EDIT_READ == "READ")
                {
                    this.txtCode.Focus();
                    this.txtCode.Document.Blocks.Clear();
                    Paragraph para = new Paragraph();
                    para.Inlines.Add(new Run(this.model.USERINFO.MY_MEMO));
                    this.txtCode.Document.Blocks.Add(para);
                }
                else if (this.model.USERINFO != null && this.model.EDIT_READ == "EDIT")
                {
                    this.txtTextCode.Text = this.model.USERINFO.MY_MEMO;
                }
            }
        }
        private void FocusSearchText(object sender, RoutedEventArgs e)
        {
            if (Keyboard.IsKeyDown(Key.LeftCtrl) && Keyboard.IsKeyDown(Key.F))
                this.searchText.Focus();
            if (Keyboard.IsKeyDown(Key.F3))
            {
                if (SearchTextList.Count <= 0) return;
                this.txtCode.Focus();
                if (SearchTextList.ContainsKey(searchSwitch))
                {
                    this.txtCode.Selection.Select(SearchTextList[searchSwitch].Start, SearchTextList[searchSwitch].End);
                    searchSwitch = ++searchSwitch;//찾은건수보다 누른 수치가 적으면 증가, 많아지면 1로 초기화
                }
                else if (searchSwitch >= SearchTextList.Count)
                {
                    searchSwitch = 1;
                    this.txtCode.Selection.Select(SearchTextList[searchSwitch].Start, SearchTextList[searchSwitch].End);
                    searchSwitch = ++searchSwitch;//찾은건수보다 누른 수치가 적으면 증가, 많아지면 1로 초기화
                }
            }
        }

        private void txtCode_LostFocus(object sender, RoutedEventArgs e)
        {
            if (this.AutoSave)
            {
                if (this.model.EDIT_READ == "READ")
                {
                    TextRange textRange = new TextRange(this.txtCode.Document.ContentStart, this.txtCode.Document.ContentEnd);
                    if (textRange.Text.Equals("\r\n"))
                        this.model.USERINFO.MY_MEMO = string.Empty;
                    else
                        this.model.USERINFO.MY_MEMO = textRange.Text;
                }
                else if (this.model.EDIT_READ == "EDIT")
                {
                    this.model.USERINFO.MY_MEMO = this.txtTextCode.Text;
                }
                this.model.SaveUserInfo();

            }
            if(LostFocused != null)
            {
                LostFocused(sender, e);
            }
        }


        public TextRange FindTextInRange(TextRange searchRange, string searchText)
        {
            findIndex = searchRange.Text.IndexOf(searchText, findIndex, StringComparison.OrdinalIgnoreCase);
            if (findIndex < 0)
                return null;  // Not found

            var start = GetTextPositionAtOffset(searchRange.Start, findIndex);
            TextRange result = new TextRange(start, GetTextPositionAtOffset(start, searchText.Length));

            return result;
        }

        private TextPointer GetTextPositionAtOffset(TextPointer position, int characterCount)
        {
            while (position != null)
            {
                if (position.GetPointerContext(LogicalDirection.Forward) == TextPointerContext.Text)
                {
                    int count = position.GetTextRunLength(LogicalDirection.Forward);
                    if (characterCount <= count)
                    {
                        return position.GetPositionAtOffset(characterCount);
                    }

                    characterCount -= count;
                }

                TextPointer nextContextPosition = position.GetNextContextPosition(LogicalDirection.Forward);
                if (nextContextPosition == null)
                    return position;

                position = nextContextPosition;
            }

            return position;
        }


        private void TextSearch(object sender, RoutedEventArgs e)
        {
            if (this.model.EDIT_READ == "EDIT")
            {
                this.model.EDIT_READ = "READ";
                CopyTextToRichTextBox();
            }
            if (string.IsNullOrEmpty(searchText.Text)) return;
            this.txtCode.ScrollToHome();
            findIndex = 0;
            int cnt = 1;
            SearchTextList.Clear();
            searchSwitch = 1; //초기화

            

            TextRange searchRange = new TextRange(txtCode.Document.ContentStart, txtCode.Document.ContentEnd);
            searchRange.ApplyPropertyValue(TextElement.ForegroundProperty, new SolidColorBrush(Colors.Black));
            while (true)
            {
                TextRange foundRange = FindTextInRange(searchRange, searchText.Text);
                if (findIndex < 0)
                {
                    this.txtSearchCnt.Text = SearchTextList.Count.ToString();
                    return;
                }
                foundRange.ApplyPropertyValue(TextElement.ForegroundProperty, new SolidColorBrush(Colors.Red));
                //찾은 문자열 위치 저장
                SearchTextList.Add(cnt, foundRange);
                cnt++;
                findIndex += searchText.Text.Length;
            }
        }

        private void searchText_KeyDown_1(object sender, System.Windows.Input.KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
                TextSearch(sender, e);
        }

        private void CommandBinding_CanExecute(object sender, CanExecuteRoutedEventArgs e)
        {
            e.CanExecute = false;
        }
        private void CopyTextToRichTextBox()
        {
            this.txtCode.Focus();
            this.txtCode.Document.Blocks.Clear();
            Paragraph para = new Paragraph();
            para.Inlines.Add(new Run(this.txtTextCode.Text));
            this.txtCode.Document.Blocks.Add(para);
        }
        private void CommandBinding_Executed(object sender, ExecutedRoutedEventArgs e)
        {
            string cpStr = "";
            try
            {
                cpStr = Clipboard.GetText();
                this.txtCode.Focus();
                this.txtCode.Document.Blocks.Clear();
                Paragraph para = new Paragraph();
                para.Inlines.Add(new Run(cpStr));
                this.txtCode.Document.Blocks.Add(para);
            }
            catch
            {

            }
        }

        private void txtCode_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {

        }

        private void txtCode_MouseRightClick(object sender, MouseButtonEventArgs e)
        {
            if (this.model.EDIT_READ == "READ")
            {
                this.model.EDIT_READ = "EDIT";

                TextRange textRange = new TextRange(this.txtCode.Document.ContentStart, this.txtCode.Document.ContentEnd);
                if (textRange.Text.Equals("\r\n"))
                    this.txtTextCode.Text = string.Empty;
                else
                    this.txtTextCode.Text = textRange.Text;

                this.txtTextCode.ScrollToHome();
            }
        }

        private void txtTextCode_TextChanged(object sender, TextChangedEventArgs e)
        {
           
            if (TextChanged != null)
            {
                TextChanged(sender, e);
            }
        }
        #region[Method]
        public void FocusTextBox()
        {
            this.txtTextCode.Focus();
        }       
        /// <summary>
        /// i = 0 : TextBox, 1 : SearchTextBox
        /// </summary>
        /// <param name="i"></param>
        public void SetFocusGubn(int i)
        {
            this.FocusPosition = (FocusGubn)i;
        }
        #endregion        
    }

    public enum FocusGubn
    {
        TextBox = 0
       ,SearchTextBox = 1
    }
}
