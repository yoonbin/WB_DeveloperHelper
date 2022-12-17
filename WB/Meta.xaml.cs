using System;
using System.Collections.Generic;
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
using WB.Common;
using WB.DTO;
using WB.UC;

namespace WB
{
    /// <summary>
    /// Meta.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class Meta : UCBase
    {
        private ViewModelBase model;        
        WB.MetaDL dac = new WB.MetaDL();
        public Meta()
        {
            InitializeComponent();
            
            this.model = this.DataContext as ViewModelBase;
        }

        private void btnSearch_Click(object sender, RoutedEventArgs e)
        {
            Meta_Loaded(sender, e);
        }

        private void btnSearch_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
                Meta_Loaded(sender, e);           
        }

        private void Meta_Loaded(object sender, RoutedEventArgs e)
        {
            try
            {
                txtSearch.Focus();
                if (this.model.METAGRID == null)
                    this.model.METAGRID = new List<Meta_INOUT>(); //다시 초기화
                else
                    this.model.METAGRID.Clear();
                if (this.model.META_SEARCH_IN == null || string.IsNullOrEmpty(this.model.META_SEARCH_IN.TEXT)) return;
                Meta_INOUT inObj = new Meta_INOUT();
                inObj.TEXT = Regex.Replace(this.model.META_SEARCH_IN.TEXT, @"\s+", ",");

                this.model.METAGRID = dac.GetMetaList(inObj);
            }
            catch (Exception ex)
            {
                this.OwnerWindow.ShowErrorMsgBox(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요.", ex.ToString()));
            }
            //SearchDicList(inObj.TEXT);
        }
        private void SearchDicList(string text)
        {
            string query = this.model.GetMetaQuery(text);            
            try
            {
                DataTable dt = dac.ExecuteQuery(this.MetaConnection.VALUE, query).Tables[0];
                if (dt.Rows.Count > 0)
                {                    
                    this.model.METAGRID = model.ConvertToList<Meta_INOUT>(dt);
                }
                else
                {
                    this.model.METAGRID = model.ConvertToList<Meta_INOUT>(dt);
                }
            }
            catch (Exception ex)
            {
                this.OwnerWindow.ShowErrorMsgBox(string.Format("{0}\n{1}", "META# ConnectionString 확인필요. Setting 탭에서 설정해주세요.", ex.ToString()));
            }
        }
        private void chkSelUnit_Checked(object sender, RoutedEventArgs e)
        {
            this.model.UNIT = DataGridSelectionUnit.Cell;
        }

        private void chkSelUnit_Unchecked(object sender, RoutedEventArgs e)
        {
            this.model.UNIT = DataGridSelectionUnit.FullRow;
        }
    }
}
