using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Media;

namespace WB.Common
{
    public class CommonConverter
    {
    }
    /// <summary>
    /// 일요일 글자색 변경
    /// </summary>
    public class SelectionUnitConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            DataGridSelectionUnit unit = DataGridSelectionUnit.FullRow;
            if (value == null)
                return unit;
            if ((bool)value) return unit = DataGridSelectionUnit.Cell;

            return unit;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            DataGridSelectionUnit unit = DataGridSelectionUnit.FullRow;
            if (value == null)
                return unit;
            if ((bool)value) return unit = DataGridSelectionUnit.Cell;

            return unit;
        }
    }
    /// <summary>
    /// 날짜 String으로 변경 ('yyyy-MM-dd') 타입
    /// </summary>
    public class SelectDateToString : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string str = "";
            if (value == null)
                return null; ;
            str = value.ToString();

            return str;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string str = "";
            if (value == null)
                return null; ;
            if (value is DateTime)
            {
                str = ((DateTime)value).ToString("yyyy-MM-dd");
            }

            return str;
        }
    }
    /// <summary>
    /// Parameter가 True면 Collapsed
    /// </summary>
    public class VisibleConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {            
            if (value == null)
                return Visibility.Visible;
            if ((bool)value) return Visibility.Collapsed;

            return Visibility.Visible;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }
    /// <summary>
    /// Parameter가 True면 Visible
    /// </summary>
    public class VisibleConverterV2 : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null)
                return Visibility.Collapsed;
            if ((bool)value) return Visibility.Visible;

            return Visibility.Collapsed;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }
    /// <summary>
    /// Parameter와 Value가 같으면 Visible
    /// </summary>
    public class VisibleConverterV3 : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null)
                return Visibility.Collapsed;
            if ((string)value == (string)parameter) return Visibility.Visible;

            return Visibility.Collapsed;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }
    /// <summary>
    /// Parameter가 True면 Visible
    /// </summary>
    public class RadioConverter : IValueConverter
    {
        public Object Convert(object value, Type targetType,
                   object parameter, CultureInfo culture)
        {
            if (value == null) return false;
            if (value.ToString() == parameter.ToString()) return true;
            return false;
        }

        public Object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {            
            if (value == null) return null;
            if ((bool)value == true) return parameter.ToString();
            return null;
        }

    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    ///파라미터를 '*'로 split하여 앞부분의 값에 따라 체크박스 항목 그룹핑 하여 저장
    /// </summary>
    public class MultiChkNonConverter : IValueConverter
    {
        Dictionary<string, Hashtable> Dic;
        /// <summary>
        /// 
        /// </summary>
        public MultiChkNonConverter()
        {
            Dic = new Dictionary<string, Hashtable>();

            for (int i = 0; i < 100; i++)
            {
                Dic.Add(i.ToString(), new Hashtable { });
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <param name="targetType"></param>
        /// <param name="parameter"></param>
        /// <param name="culture"></param>
        /// <returns></returns>
        public object Convert(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            if (parameter == null)
                return false;
            var hash = parameter.ToString().Split('*')[0];
            var data = parameter.ToString().Split('*')[1];

            if (Dic[hash].Count == 0 || !Dic[hash].Contains(data))
                Dic[hash].Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (Dic[hash].Contains(data))
                        Dic[hash][data] = true;

                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <param name="targetType"></param>
        /// <param name="parameter"></param>
        /// <param name="culture"></param>
        /// <returns></returns>
        public object ConvertBack(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            string _str = string.Empty;

            var hash = parameter.ToString().Split('*')[0];
            var data = parameter.ToString().Split('*')[1];

            if (data == "0")
            {
                Dic[hash].Clear();
                Dic[hash].Add(data, true);
            }
            else
            {
                if (Dic[hash].Contains("0"))
                    Dic[hash]["0"] = false;
            }
            if (Dic[hash].Contains(data))
                Dic[hash][data] = (Boolean)value;

            SortedList sorter = new SortedList(Dic[hash]);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key + ",";
            }
            if (_str.Length > 0) 
                _str = _str.Substring(0, _str.Length - 1);
            return _str;

        }
    }
    public class CheckBoxConverters : IValueConverter
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <param name="targetType"></param>
        /// <param name="parameter"></param>
        /// <param name="culture"></param>
        /// <returns></returns>
        public object Convert(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null) return false;
            if (value.ToString() == parameter.ToString()) return true;
            return false;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <param name="targetType"></param>
        /// <param name="parameter"></param>
        /// <param name="culture"></param>
        /// <returns></returns>
        public object ConvertBack(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null) return null;
            if ((bool)value == true) return parameter.ToString();
            return null;

        }
    }

    /// <summary>
    /// 넘겨받은 value값중 하나라도 True가 있으면 활성화, 없으면 비활성화
    /// </summary>
    public class ReverseEnableConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null)
                return true;
            if (value.ToString() == parameter.ToString()) return false;

            return true;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }
    
}
