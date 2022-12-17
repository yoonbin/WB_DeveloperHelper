using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;

namespace WB.Common
{
    public class DPTextBox : TextBox
    {
        public static readonly DependencyProperty SelectAllTextOnFocusProperty =
            DependencyProperty.Register(
                "SelectAllTextOnFocus",
                typeof(bool),
                typeof(DPTextBox),
                new PropertyMetadata(new PropertyChangedCallback(OnSelectAllTextOnFocusChanged)));

        public bool SelectAllTextOnFocus
        {
            get { return (bool)GetValue(SelectAllTextOnFocusProperty); }
            set { SetValue(SelectAllTextOnFocusProperty, value); }
        }

        private static void OnSelectAllTextOnFocusChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            var textBox = d as TextBox;
            if (textBox == null) return;

            if (e.NewValue is bool == false) return;

            if ((bool)e.NewValue)
            {
                textBox.GotFocus += SelectAll;
                textBox.PreviewMouseDown += IgnoreMouseButton;
                textBox.PreviewKeyDown += RedoText;
                textBox.MouseDoubleClick += SelectTextWord;
                textBox.TextChanged += BindingExpression_TextChanged;
            }
            else
            {
                textBox.GotFocus -= SelectAll;
                textBox.PreviewMouseDown -= IgnoreMouseButton;
                textBox.PreviewKeyDown -= RedoText;
                textBox.MouseDoubleClick -= SelectTextWord;
                textBox.TextChanged -= BindingExpression_TextChanged;
            }
        }

        private static void SelectAll(object sender, RoutedEventArgs e)
        {
            var textBox = e.OriginalSource as TextBox;
            if (textBox == null) return;
            textBox.SelectAll();
        }

        private static void IgnoreMouseButton(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            var textBox = sender as TextBox;
            if (textBox == null || (!textBox.IsReadOnly && textBox.IsKeyboardFocusWithin)) return;

            e.Handled = true;
            textBox.Focus();
        }
        private static void RedoText(object sender, KeyEventArgs e)
        {
            var textBox = sender as TextBox;
            if (textBox == null) return;
            if (Keyboard.IsKeyDown(Key.LeftCtrl) && Keyboard.IsKeyDown(Key.LeftShift) && Keyboard.IsKeyDown(Key.Z))
                textBox.Redo();
        }
        private static void SelectTextWord(object sender, RoutedEventArgs e)
        {
            var textBox = sender as TextBox;
            if (textBox == null) return;

            if (!textBox.AutoWordSelection)
            {
                int selection_index = textBox.SelectionStart;
                int line = textBox.GetLineIndexFromCharacterIndex(selection_index);
                int line_idx = textBox.GetCharacterIndexFromLineIndex(line);
                var line_text = textBox.GetLineText(line);
                int search_index = 0;
                int str_index = 0;
                var sel_Text = textBox.SelectedText;
                var sel_word = "";
                string[] separator = new string[14]
                {
                "\r\n",
                "\r",
                "\n",
                " ",
                ".",
                ";",
                "\'",
                "\"",
                "\\",
                "\t",
                "(",
                ")",
                "{",
                "}"
                };
                foreach (string word_Item in line_text.Split(separator, StringSplitOptions.RemoveEmptyEntries))
                {
                    if (word_Item.IndexOf(sel_Text.Trim()) > -1)
                    {
                        sel_word = word_Item;
                        break;
                    }
                }
                if ((selection_index - line_idx - sel_word.Length) > 0)
                    search_index = (selection_index - line_idx - sel_word.Length);
                else if ((selection_index - line_idx) < sel_word.Length)
                    search_index = 0;
                else
                    search_index = (selection_index - line_idx);
                try
                {
                    str_index = line_text.IndexOf(sel_word, search_index);
                }
                catch (Exception)
                {

                }
                if (str_index == -1) return;
                textBox.Select(str_index + line_idx, sel_word.Length);
            }
        }
        private static void BindingExpression_TextChanged(object sender, TextChangedEventArgs e)
        {
            BindingExpression bindingExpression = ((TextBox)sender).GetBindingExpression(TextBox.TextProperty);
            bindingExpression.UpdateSource();
        }
    }
    
}
