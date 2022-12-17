using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Data;


namespace HIS.MC.JE.DP.DLKPAT.UI.Converters
{
    public class DLKCommonConverters : IValueConverter
    {
        public Object Convert(object value, Type targetType,
                    object parameter, CultureInfo culture)
        {
            if (value == null) return null;
            if (value.ToString() == parameter.ToString().Split('*')[1].Split(',')[int.Parse(parameter.ToString().Split('*')[0])]) return true;
            return false;
        }

        public Object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            if (value == null) return null;
            if ((bool)value == true) return parameter.ToString().Split('*')[1].Split(',')[int.Parse(parameter.ToString().Split('*')[0])];
            return null;
        }
    }    

    /// <summary>
    /// value가 null이면 defalut값 반환
    /// </summary>
    public class RadioConverters : IValueConverter
    {
        public Object Convert(object value, Type targetType,
                    object parameter, CultureInfo culture)
        {
            string Default = parameter.ToString().Split('*')[0];
            string Index = parameter.ToString().Split('*')[1];
            if (value == null && Default == Index) return true;
            if (value == null) return null;
            else if (value.ToString() == Index) return true;
            return false;
        }

        public Object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {            
            string Index = parameter.ToString().Split('*')[1];

            if (value == null) return null;
            if ((bool)value == true) return Index;
            return null;
        }
    }
    /// <summary>
    /// 넘겨받은 value값중 하나라도 True가 있으면 활성화, 없으면 비활성화
    /// </summary>
    public class VisiblityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (parameter.ToString() == "999") return Visibility.Visible;
            if (value == null)
                return Visibility.Collapsed;
            if (value.ToString() == parameter.ToString()) return Visibility.Visible;

            return Visibility.Collapsed;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }

    /// <summary>
    /// Text ", " 붙여서 반환
    /// </summary>
    public class TextAddComConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null) return string.Empty;
            string str = string.Empty;

            for(int i = 0;i< value.ToString().Length; i++)
            {
                str = str + value.ToString().Substring(i, 1) + ", ";
            }
            str = str.Substring(0, str.Length - 2);
            return str;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }

    /// <summary>
    /// 2012.03.13 선택된 객체의 파라미터값을 구분자를 붙여 넘겨받음 by 임형순
    /// </summary>
    public class CheckedStringWithConverter : IValueConverter
    {
        Hashtable htb_0;
        Hashtable htb_1;
        Hashtable htb_2;
        Hashtable htb_3;
        Hashtable htb_4;
        Hashtable htb_5;
        Hashtable htb_6;
        Hashtable htb_7;
        Hashtable htb_8;
        Hashtable htb_9;
        Hashtable htb_10;
        /// <summary>
        /// 
        /// </summary>
        public CheckedStringWithConverter()
        {            
            htb_0 = new Hashtable();
            htb_1 = new Hashtable();
            htb_2 = new Hashtable();
            htb_3 = new Hashtable();
            htb_4 = new Hashtable();
            htb_5 = new Hashtable();
            htb_6 = new Hashtable();
            htb_7 = new Hashtable();
            htb_8 = new Hashtable();
            htb_9 = new Hashtable();
            htb_10 = new Hashtable();
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
            if ( parameter == null)
                return false;
   
            //Length == 2이면 체크박스 역할 , 체크박스 그룹내용을 각 해쉬테이블에 저장
            if (parameter.ToString().Split('*').Length == 2)
            {
                var hash = parameter.ToString().Split('*')[0];
                var data = parameter.ToString().Split('*')[1];

                if (hash == "0")
                {
                    if (htb_0.Count == 0 || !htb_0.Contains(data))
                        htb_0.Add(data, false);

                    if (value != null)
                    {
                        if (value.ToString().Contains(data.ToString()))
                        {
                            if (htb_0.Contains(data))
                                htb_0[data] = true;

                            return true;
                        }
                    }

                }
                else if (hash == "1")
                {
                    if (htb_1.Count == 0 || !htb_1.Contains(data))
                        htb_1.Add(data, false);

                    if (value != null)
                    {
                        if (value.ToString().Contains(data.ToString()))
                        {
                            if (htb_1.Contains(data))
                                htb_1[data] = true;

                            return true;
                        }
                    }
                }
                else if (hash == "2")
                {
                    if (htb_2.Count == 0 || !htb_2.Contains(data))
                        htb_2.Add(data, false);

                    if (value != null)
                    {
                        if (value.ToString().Contains(data.ToString()))
                        {
                            if (htb_2.Contains(data))
                                htb_2[data] = true;

                            return true;
                        }
                    }
                }
                else if (hash == "3")
                {
                    if (htb_3.Count == 0 || !htb_3.Contains(data))
                        htb_3.Add(data, false);

                    if (value != null)
                    {
                        if (value.ToString().Contains(data.ToString()))
                        {
                            if (htb_3.Contains(data))
                                htb_3[data] = true;

                            return true;
                        }
                    }
                }
                else if (hash == "4")
                {
                    if (htb_4.Count == 0 || !htb_4.Contains(data))
                        htb_4.Add(data, false);

                    if (value != null)
                    {
                        if (value.ToString().Contains(data.ToString()))
                        {
                            if (htb_4.Contains(data))
                                htb_4[data] = true;

                            return true;
                        }
                    }
                }
                else if (hash == "5")
                {
                    if (htb_5.Count == 0 || !htb_5.Contains(data))
                        htb_5.Add(data, false);

                    if (value != null)
                    {
                        if (value.ToString().Contains(data.ToString()))
                        {
                            if (htb_5.Contains(data))
                                htb_5[data] = true;

                            return true;
                        }
                    }
                }
                else if (hash == "6")
                {
                    if (htb_6.Count == 0 || !htb_6.Contains(data))
                        htb_6.Add(data, false);

                    if (value != null)
                    {
                        if (value.ToString().Contains(data.ToString()))
                        {
                            if (htb_6.Contains(data))
                                htb_6[data] = true;

                            return true;
                        }
                    }
                }
                else if (hash == "7")
                {
                    if (htb_7.Count == 0 || !htb_7.Contains(data))
                        htb_7.Add(data, false);

                    if (value != null)
                    {
                        if (value.ToString().Contains(data.ToString()))
                        {
                            if (htb_7.Contains(data))
                                htb_7[data] = true;

                            return true;
                        }
                    }
                }
                else if (hash == "8")
                {
                    if (htb_8.Count == 0 || !htb_8.Contains(data))
                        htb_8.Add(data, false);

                    if (value != null)
                    {
                        if (value.ToString().Contains(data.ToString()))
                        {
                            if (htb_8.Contains(data))
                                htb_8[data] = true;

                            return true;
                        }
                    }
                }
                else if (hash == "9")
                {
                    if (htb_9.Count == 0 || !htb_9.Contains(data))
                        htb_9.Add(data, false);

                    if (value != null)
                    {
                        if (value.ToString().Contains(data.ToString()))
                        {
                            if (htb_9.Contains(data))
                                htb_9[data] = true;

                            return true;
                        }
                    }
                }
                else if (hash == "10")
                {
                    if (htb_10.Count == 0 || !htb_10.Contains(data))
                        htb_10.Add(data, false);

                    if (value != null)
                    {
                        if (value.ToString().Contains(data.ToString()))
                        {
                            if (htb_10.Contains(data))
                                htb_10[data] = true;

                            return true;
                        }
                    }
                }


            }
            //length == 3 이면 라디오버튼 컨버터 역할
            if (parameter.ToString().Split('*').Length == 3)
            {
                var hash = parameter.ToString().Split('*')[0];
                var data = parameter.ToString().Split('*')[1];
                var radioGubn = parameter.ToString().Split('*')[2];

                if (value == null) return null;
                if (value.ToString() == radioGubn) return true;
                return false;

                //if (radioGubn == "Y" || radioGubn == "N")
                //{
                //    if (value == null) return null;
                //    if (value.ToString() == radioGubn) return true;
                //    return false;
                //}
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

            ////Length == 3 이면 라디오버튼 , 라디오버튼 파라미터가 N 이면 해쉬테이블 초기화
            //if (parameter.ToString().Split('*').Length == 3)
            //{
            //    var hash = parameter.ToString().Split('*')[0];
            //    var data = parameter.ToString().Split('*')[1];
            //    var radioGubn = parameter.ToString().Split('*')[2];

                
            //    if (radioGubn == "N")
            //    {
            //        if (hash == "0")
            //            htb_0.Clear();
            //        else if (hash == "1")
            //            htb_1.Clear();
            //        else if (hash == "2")
            //            htb_2.Clear();
            //        else if (hash == "3")
            //            htb_3.Clear();
            //        else if (hash == "4")
            //            htb_4.Clear();
            //        else if (hash == "5")
            //            htb_5.Clear();
            //        else if (hash == "6")
            //            htb_6.Clear();
            //        else if (hash == "7")
            //            htb_7.Clear();
            //        else if (hash == "8")
            //            htb_8.Clear();
            //        else if (hash == "9")
            //            htb_9.Clear();
            //        else if (hash == "10")
            //            htb_10.Clear();

            //        if (value == null) return null;
            //        if ((bool)value == true) return radioGubn;
            //        return null;

            //    }
            //    else
            //    {
            //        if (value == null) return null;
            //        if ((bool)value == true) return radioGubn;
            //        return null;

            //    }
            //}
            //Length == 2 이면 문자열 연결하여 값 반환
            if (parameter.ToString().Split('*').Length == 2)
            {
                var hash = parameter.ToString().Split('*')[0];
                var data = parameter.ToString().Split('*')[1];

                if (hash == "0")
                {
                    if (value != null)
                    {
                        if (htb_0.Count == 0 && (bool)value)
                            htb_0.Add(data, true);
                    }

                    if (htb_0.Contains(data))
                        htb_0[data] = (Boolean)value;

                    SortedList sorter = new SortedList(htb_0);
                    foreach (DictionaryEntry item in sorter)
                    {
                        if ((Boolean)item.Value == true)
                            _str += item.Key;
                    }
                }
                else if (hash == "1")
                {
                    if (value != null)
                    {
                        if (htb_1.Count == 0 && (bool)value)
                            htb_1.Add(data, true);
                    }

                    if (htb_1.Contains(data))
                        htb_1[data] = (Boolean)value;

                    SortedList sorter = new SortedList(htb_1);
                    foreach (DictionaryEntry item in sorter)
                    {
                        if ((Boolean)item.Value == true)
                            _str += item.Key;
                    }
                }
                else if (hash == "2")
                {
                    if (value != null)
                    {
                        if (htb_2.Count == 0 && (bool)value)
                            htb_2.Add(data, true);
                    }

                    if (htb_2.Contains(data))
                        htb_2[data] = (Boolean)value;

                    SortedList sorter = new SortedList(htb_2);
                    foreach (DictionaryEntry item in sorter)
                    {
                        if ((Boolean)item.Value == true)
                            _str += item.Key;
                    }
                }
                else if (hash == "3")
                {
                    if (value != null)
                    {
                        if (htb_3.Count == 0 && (bool)value)
                            htb_3.Add(data, true);
                    }

                    if (htb_3.Contains(data))
                        htb_3[data] = (Boolean)value;

                    SortedList sorter = new SortedList(htb_3);
                    foreach (DictionaryEntry item in sorter)
                    {
                        if ((Boolean)item.Value == true)
                            _str += item.Key;
                    }
                }
                else if (hash == "4")
                {
                    if (value != null)
                    {
                        if (htb_4.Count == 0 && (bool)value)
                            htb_4.Add(data, true);
                    }

                    if (htb_4.Contains(data))
                        htb_4[data] = (Boolean)value;

                    SortedList sorter = new SortedList(htb_4);
                    foreach (DictionaryEntry item in sorter)
                    {
                        if ((Boolean)item.Value == true)
                            _str += item.Key;
                    }
                }
                else if (hash == "5")
                {
                    if (value != null)
                    {
                        if (htb_5.Count == 0 && (bool)value)
                            htb_5.Add(data, true);
                    }

                    if (htb_5.Contains(data))
                        htb_5[data] = (Boolean)value;

                    SortedList sorter = new SortedList(htb_5);
                    foreach (DictionaryEntry item in sorter)
                    {
                        if ((Boolean)item.Value == true)
                            _str += item.Key;
                    }
                }
                else if (hash == "6")
                {
                    if (value != null)
                    {
                        if (htb_6.Count == 0 && (bool)value)
                            htb_6.Add(data, true);
                    }

                    if (htb_6.Contains(data))
                        htb_6[data] = (Boolean)value;

                    SortedList sorter = new SortedList(htb_6);
                    foreach (DictionaryEntry item in sorter)
                    {
                        if ((Boolean)item.Value == true)
                            _str += item.Key;
                    }
                }
                else if (hash == "7")
                {
                    if (value != null)
                    {
                        if (htb_7.Count == 0 && (bool)value)
                            htb_7.Add(data, true);
                    }

                    if (htb_7.Contains(data))
                        htb_7[data] = (Boolean)value;

                    SortedList sorter = new SortedList(htb_7);
                    foreach (DictionaryEntry item in sorter)
                    {
                        if ((Boolean)item.Value == true)
                            _str += item.Key;
                    }
                }
                else if (hash == "8")
                {
                    if (value != null)
                    {
                        if (htb_8.Count == 0 && (bool)value)
                            htb_8.Add(data, true);
                    }

                    if (htb_8.Contains(data))
                        htb_8[data] = (Boolean)value;

                    SortedList sorter = new SortedList(htb_8);
                    foreach (DictionaryEntry item in sorter)
                    {
                        if ((Boolean)item.Value == true)
                            _str += item.Key;
                    }
                }
                else if (hash == "9")
                {
                    if (value != null)
                    {
                        if (htb_9.Count == 0 && (bool)value)
                            htb_9.Add(data, true);
                    }

                    if (htb_9.Contains(data))
                        htb_9[data] = (Boolean)value;

                    SortedList sorter = new SortedList(htb_9);
                    foreach (DictionaryEntry item in sorter)
                    {
                        if ((Boolean)item.Value == true)
                            _str += item.Key;
                    }
                }
                else if (hash == "10")
                {
                    if (value != null)
                    {
                        if (htb_10.Count == 0 && (bool)value)
                            htb_10.Add(data, true);
                    }

                    if (htb_10.Contains(data))
                        htb_10[data] = (Boolean)value;

                    SortedList sorter = new SortedList(htb_10);
                    foreach (DictionaryEntry item in sorter)
                    {
                        if ((Boolean)item.Value == true)
                            _str += item.Key;
                    }
                }
            }
            return _str;

        }
    }
    /// <summary>
    /// 
    /// </summary>
    public class RadioUnCheck : IValueConverter
    {
        Dictionary<string, Dictionary<string,int>> DicCnt;       

        int ClickCnt;
        string Keys;

        public RadioUnCheck()
        {
            DicCnt = new Dictionary<string, Dictionary<string,int>>();         
            for (int i = 0; i < 100; i++)
            {  
                DicCnt.Add(i.ToString(), new Dictionary<string, int>{ });
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
           
            if (DicCnt[hash].Count == 0 || !DicCnt[hash].ContainsKey(data))
                DicCnt[hash].Add(data, 0);
            if (value == null) 
                return null;
            else if (value != null)
            {
                ClickCnt = DicCnt[hash][data] % 2;

                if (value.ToString() == data && DicCnt[hash][data] == 0)
                    return true;
                else if (value.ToString() == data && ClickCnt == 1)
                    return true;
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
            var hash = parameter.ToString().Split('*')[0];
            var data = parameter.ToString().Split('*')[1];          

            if (DicCnt[hash].ContainsKey(data))
            {               
                //이미 클릭되어 있으면 0으로 세팅
                if (DicCnt[hash][data] == 1)
                {
                    DicCnt[hash][data] = 0;
                }
                //클릭되어 있지 않은 상태면 전부 0으로 초기화 후 클릭한 값만 1로 세팅
                else
                {
                    Keys = string.Empty;
                    
                    foreach(var item in DicCnt[hash].Keys)
                    {
                        Keys = string.Concat(Keys, item, "^");
                    }
                    var arrKey = Keys.Split('^');
                    for (int i = 0; i < arrKey.Count()-1; i++)
                    {
                        if (DicCnt[hash].ContainsKey(arrKey[i]))
                            DicCnt[hash][arrKey[i]] = 0;
                    }              
                    DicCnt[hash][data] = 1;

                    if ((bool)value && DicCnt[hash][data] == 1)
                    {
                        return data;
                    }
                }
            }       
            return null;

        }
    }
    /// <summary>
    /// 라디오버튼 체크 해제 컨버터 ver2 (외부 이벤트로 인해 ConvertBack 없이 다른 라디오버튼이 체크되었을 경우 생기는 문제 보완)
    /// </summary>
    public class RadioUnCheck2 : IValueConverter
    {
        Dictionary<string, Dictionary<string, int>> DicCnt;

        int ClickCnt;
        string Keys;

        public RadioUnCheck2()
        {
            DicCnt = new Dictionary<string, Dictionary<string, int>>();
            for (int i = 0; i < 100; i++)
            {
                DicCnt.Add(i.ToString(), new Dictionary<string, int> { });
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

            if (DicCnt[hash].Count == 0 || !DicCnt[hash].ContainsKey(data))
                DicCnt[hash].Add(data, 0);
            if (value == null)
                return null;
            else if (value != null)
            {
                if (value.ToString() == data)
                {
                    foreach (var item in DicCnt[hash].Keys)
                    {
                        Keys = string.Concat(Keys, item, "^");
                    }
                    var arrKey = Keys.Split('^');
                    for (int i = 0; i < arrKey.Count() - 1; i++)
                    {
                        if (DicCnt[hash].ContainsKey(arrKey[i]))
                            DicCnt[hash][arrKey[i]] = 0;
                    }
                }
                    DicCnt[hash][value.ToString()] = 1;

                ClickCnt = DicCnt[hash][data] % 2;
            
                if (value.ToString() == data && ClickCnt == 1)
                    return true;
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
            var hash = parameter.ToString().Split('*')[0];
            var data = parameter.ToString().Split('*')[1];
            int Cnt = 0;
            if (DicCnt[hash].ContainsKey(data))
            {                    
                foreach(var Key in DicCnt[hash].Keys)
                {
                    if (DicCnt[hash][Key] == 1)
                        Cnt++;
                }
                //이미 클릭되어 있으면 0으로 세팅
                if (DicCnt[hash][data] == 1 && Cnt >= 1)
                {
                    DicCnt[hash][data] = 0;
                }
                //클릭되어 있지 않은 상태면 전부 0으로 초기화 후 클릭한 값만 1로 세팅
                else
                {
                    Keys = string.Empty;

                    foreach (var item in DicCnt[hash].Keys)
                    {
                        Keys = string.Concat(Keys, item, "^");
                    }
                    var arrKey = Keys.Split('^');
                    for (int i = 0; i < arrKey.Count() - 1; i++)
                    {
                        if (DicCnt[hash].ContainsKey(arrKey[i]))
                            DicCnt[hash][arrKey[i]] = 0;
                    }
                    DicCnt[hash][data] = 1;

                    if ((bool)value && DicCnt[hash][data] == 1)
                    {
                        return data;
                    }
                }
            }
            return null;

        }
    }
    /// <summary>
    /// 
    /// </summary>
    public class CheckedStringWithConverter2 : IValueConverter
    {      
        Dictionary<string, Hashtable> Dic;       
     
        public CheckedStringWithConverter2()
        {
            Dic = new Dictionary<string, Hashtable>();        
            
            for(int i =0; i<100; i++)
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
                if (value.ToString().Contains(data.ToString()))
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
           
            if (value != null)
            {
                if (Dic[hash].Count == 0 && (bool)value)
                    Dic[hash].Add(data, true);
            }

            if (Dic[hash].Contains(data))
                Dic[hash][data] = (Boolean)value;

            SortedList sorter = new SortedList(Dic[hash]);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }
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
    ///
    /// </summary>
    public class EnableConverters : IValueConverter
    {

        public object Convert(object value, Type targetType,
                    object parameter, CultureInfo culture)
        {
            if (value == null) return false;

            if ((bool)value == true) return true;            

            return false;
        }
        public object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            if (value == null) return null;            
            return null;            
        }
    }
    public class TxtEnableConverters : IValueConverter
    {

        public object Convert(object value, Type targetType,
                    object parameter, CultureInfo culture)
        {
            if (string.IsNullOrEmpty(value.ToString())) return false;

            if (!string.IsNullOrEmpty(value.ToString())) return true;

            return false;
        }
        public object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }
    /// <summary>
    ///
    /// </summary>
    public class RevEnableConverters : IValueConverter
    {

        public object Convert(object value, Type targetType,
                    object parameter, CultureInfo culture)
        {
            if (value == null) return null;

            if ((bool)value == true) return false;

            return true;
        }
        public object ConvertBack(object value, Type targetType,
            object parameter, CultureInfo culture)
        {
            if (value == null) return null;
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
                    _str += item.Key;
            }

            return _str;

        }
    }
    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter: IValueConverter
    {
        Hashtable htb;        
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter()
        {
            htb = new Hashtable();          

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

            var data = parameter.ToString();         
            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }
            
            return _str;

         }
    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter01 : IValueConverter
    {
        Hashtable htb;
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter01()
        {
            htb = new Hashtable();

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

            var data = parameter.ToString();

            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }

            return _str;

        }
    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter02 : IValueConverter
    {
        Hashtable htb;
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter02()
        {
            htb = new Hashtable();

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

            var data = parameter.ToString();

            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }

            return _str;

        }
    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter03 : IValueConverter
    {
        Hashtable htb;
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter03()
        {
            htb = new Hashtable();

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

            var data = parameter.ToString();

            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }

            return _str;

        }
    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter04 : IValueConverter
    {
        Hashtable htb;
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter04()
        {
            htb = new Hashtable();

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

            var data = parameter.ToString();

            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }

            return _str;

        }
    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter05 : IValueConverter
    {
        Hashtable htb;
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter05()
        {
            htb = new Hashtable();

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

            var data = parameter.ToString();

            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }

            return _str;

        }
    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter06 : IValueConverter
    {
        Hashtable htb;
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter06()
        {
            htb = new Hashtable();

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

            var data = parameter.ToString();

            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }

            return _str;

        }
    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter07 : IValueConverter
    {
        Hashtable htb;
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter07()
        {
            htb = new Hashtable();

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

            var data = parameter.ToString();

            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }

            return _str;

        }
    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter08 : IValueConverter
    {
        Hashtable htb;
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter08()
        {
            htb = new Hashtable();

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

            var data = parameter.ToString();

            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }

            return _str;

        }
    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter09 : IValueConverter
    {
        Hashtable htb;
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter09()
        {
            htb = new Hashtable();

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

            var data = parameter.ToString();

            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }

            return _str;

        }
    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter10 : IValueConverter
    {
        Hashtable htb;
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter10()
        {
            htb = new Hashtable();

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

            var data = parameter.ToString();

            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }

            return _str;

        }
    }

    /// <summary>
    /// 선택한 객체의 파라미터가 0이면 0빼고 초기화, 0이 아닐경우 0에 해당하는 객체에 false 반환, 선택한 체크박스들의 파라미터값을 이어서 반환함
    /// </summary>
    public class CheckBoxsNonConverter11 : IValueConverter
    {
        Hashtable htb;
        /// <summary>
        /// 
        /// </summary>
        public CheckBoxsNonConverter11()
        {
            htb = new Hashtable();

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

            var data = parameter.ToString();

            if (htb.Count == 0 || !htb.Contains(data))
                htb.Add(data, false);

            if (value != null)
            {
                if (value.ToString().Contains(data))
                {
                    if (htb.Contains(data))
                        htb[data] = true;

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

            var data = parameter.ToString();

            if (data == "0")
            {
                htb.Clear();
                htb.Add(data, true);
            }
            else
            {
                if (htb.Contains("0"))
                    htb["0"] = false;
            }
            if (htb.Contains(data))
                htb[data] = (Boolean)value;

            SortedList sorter = new SortedList(htb);
            foreach (DictionaryEntry item in sorter)
            {
                if ((Boolean)item.Value == true)
                    _str += item.Key;
            }

            return _str;

        }
    }

    /// <summary>
    /// 지역 사회 자원 연계 진행상태 Radio Value -> Text Converter
    /// </summary>
    public class LNK_STAT_Converter : IValueConverter
    {
        public object Convert(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            string _str = string.Empty;
            if (value == null)
                return null;
            if (value.ToString().Equals("1"))
                _str = "지속";
            else if (value.ToString().Equals("2"))
                _str = "종료";
            else if (value.ToString().Equals("3"))
                _str = "중단";
            else
                return null;

            return _str;
        }
        public object ConvertBack(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            return null;
        }
    }

    /// <summary>
    /// 지역 사회 자원 연계 만족여부 Radio Value -> Text Converter
    /// </summary>
    public class LNK_SATISFY_Converter : IValueConverter
    {
        public object Convert(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            string _str = string.Empty;
            if (value == null)
                return null;
            if (value.ToString().Equals("1"))
                _str = "만족";
            else if (value.ToString().Equals("2"))
                _str = "개선필요";            
            else
                return null;

            return _str;
        }
        public object ConvertBack(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            return null;
        }
    }

    /// <summary>
    /// 뇌혈관 모니터링 기타 단계 컨버터
    /// </summary>
    public class RdoMntTimeConverter : IValueConverter
    {
        public object Convert(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null)
                return null;
            var step = value.ToString() ?? string.Empty;
            if (step != "1" && step != "6" && step != "12")
                return true;
            else if (string.IsNullOrEmpty(step))
                return true;

            return null;
        }
        public object ConvertBack(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            string _str = string.Empty;
            return _str;
        }
    }


    /// <summary>
    /// 뇌혈관 모니터링 기타 단계 텍스트 컨버터
    /// </summary>
    public class RdoMntTimeTextConverter : IValueConverter
    {
        public object Convert(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            string _str = string.Empty;
            if (value == null)
                return null;
            var step = value.ToString();
            if (step != "1" && step != "6" && step != "12")
            {
                _str = value.ToString();
                return _str;
            }
            
            return null;
        }
        public object ConvertBack(object value, System.Type targetType, object parameter, CultureInfo culture)
       {
            string _str = string.Empty;         
            _str = value.ToString();

            return _str;
        }
    }
    /// <summary>
    /// 넘겨받은 value값중 하나라도 True가 있으면 활성화, 없으면 비활성화
    /// </summary>
    public class MultiEnableConverter : IMultiValueConverter
    {
        public object Convert(object[] values ,Type targetType, object parameter,CultureInfo culture)
        {
            return values.Any(v => (v is bool && (bool)v)) ? true : false;
        }
        public object[] ConvertBack(object value,Type[] targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }

    /// <summary>
    /// 넘겨받은 value값중 하나라도 True가 있으면 활성화, 없으면 비활성화
    /// </summary>
    public class MultiTextConverter : IMultiValueConverter
    {
        public object Convert(object[] values, Type targetType, object parameter, CultureInfo culture)
        {
            string _str = string.Empty;
            Hashtable Htb = new Hashtable();
            Htb = (Hashtable)values[0];
            var Key = values[1];
            if(Htb.ContainsKey(Key))
                _str = Htb[Key].ToString();

            return _str;
            
        }
        public object[] ConvertBack(object value, Type[] targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }
    /// <summary>
    /// 넘겨받은 value값중 하나라도 True가 있으면 활성화, 없으면 비활성화
    /// </summary>
    public class TextConverter : IValueConverter
    {
        Dictionary<string, string> Dic;
        public TextConverter()
        {
            Dic = new Dictionary<string, string>();
        }
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            
            Dic = (Dictionary<string,string>)value;
           
            if (!Dic.ContainsKey(parameter.ToString()))
                return false;
            else if (Dic.ContainsKey(parameter.ToString()))
            {
                if(Dic[parameter.ToString()] == "1")
                    return true;
            }
                
            return false;

        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if ((bool)value)
            {
                if (!Dic.ContainsKey(parameter.ToString()))
                    Dic.Add(parameter.ToString(), "1");
                else if(Dic.ContainsKey(parameter.ToString()))
                    Dic[parameter.ToString()] = "1";
            }
            else
            {
                if (!Dic.ContainsKey(parameter.ToString()))
                    Dic.Add(parameter.ToString(), "0");
                else if (Dic.ContainsKey(parameter.ToString()))
                    Dic[parameter.ToString()] = "0";

            }
            return Dic;
        }
    }
}
using HIS.MS.JE.CU.GH.DTO;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Data;

namespace HIS.MS.JE.CU.GH.UI.CommonService
{

    /// <summary>
    /// 넘겨받은 value값중 하나라도 True가 있으면 활성화, 없으면 비활성화
    /// </summary>
    public class VisiblityConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null)
                return Visibility.Collapsed;
            if (value.ToString() == parameter.ToString()) return Visibility.Visible;

            return Visibility.Collapsed;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }
    /// <summary>
    /// 오더취소,예약취소면 배경색 변경
    /// </summary>
    public class BackGroundConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string str = "Transparent";
            
            if (value.ToString() == "05"|| value.ToString() == "12") //예약취소 , 오더 취소
            {
                str = "#FFABB221";
                return str;
            }
            return str;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }
    /// <summary>
    /// 추가패키지 글자색 변경
    /// </summary>
    public class ForeGroundConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string str = "#FFB3BDC7";
            if (value.ToString() == "CUSB000192" || value.ToString() == "CUSB001629" || value.ToString() == "CUSB000190" || value.ToString() == "CUSB001262") //인지, 정신,생활,노인
            {
                str = "#FFE400";
                return str;
            }
            return str;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }
    /// <summary>
    /// 넘겨받은 value값중 하나라도 True가 있으면 활성화, 없으면 비활성화
    /// </summary>
    public class EnableConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null)
                return false;
            if (value.ToString() == parameter.ToString()) return true;

            return false;
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }

    /// <summary>
    /// 넘겨받은 value값중 하나라도 True가 있으면 활성화, 없으면 비활성화
    /// </summary>
    public class DisableConverter : IValueConverter
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

    /// <summary>
    /// 데이터그리드에서 선택하면 활성화 선택 안하면 비활성화
    /// </summary>
    public class TextEnableConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null)
                return false;
            else 
                return true;            
        }
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotSupportedException();
        }
    }

    public class ReplaceEnterToSpaceConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            string str = value as string;
            string result = "";
            if (!string.IsNullOrEmpty(str))
            {
                result = str.Replace("\r\n", " ");
                result = result.Replace("\r\r", " ");
                result = result.Replace("\r", " ");
            }

            return result;
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
    public class CheckBoxConverters : IValueConverter
    {
        public object Convert(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null) return false;
            if (value.ToString() == parameter.ToString()) return true;
            return false;
        }
     
        public object ConvertBack(object value, System.Type targetType, object parameter, CultureInfo culture)
        {
            if (value == null) return null;
            if ((bool)value == true) return parameter.ToString();
            return null;

        }
    }
}

