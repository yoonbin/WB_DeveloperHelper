using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Deployment.Application;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
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
using System.Windows.Threading;
using System.Xml.Serialization;
using WB.DTO;
using WB.UC;

namespace WB
{
    /// <summary>
    /// FavQueryMngV2.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class FavQueryMngV2 : UCBase
    {
        private FavQueryMngV2Data model;
        private DispatcherTimer timer;
        private ICollectionView view;
        public FavQueryMngV2()
        {
            InitializeComponent();
            this.model = DataContext as FavQueryMngV2Data;
            this.model.thisWindow = this;
            this.dgrdQuery.EnableRowVirtualization = true;
            this.dgrdQuery.EnableColumnVirtualization = true;
            InitDataGrid();

        }
        private void InitDataGrid()
        {
            if (this.dgrdQuery.ItemsSource != null)
            {               

                this.view = (CollectionView)CollectionViewSource.GetDefaultView((object)this.dgrdQuery.ItemsSource);
                this.view.Filter = new Predicate<object>(this.UserFilter);

                //그룹
                if (view != null && view.CanGroup == true)
                {
                    this.view.GroupDescriptions.Clear();
                    this.view.GroupDescriptions.Add(new PropertyGroupDescription("GROUP"));
                    //this.view.SortDescriptions.Add(new SortDescription("GROUP", ListSortDirection.Ascending));
                    //this.view.SortDescriptions.Add(new SortDescription("QUERY_NAME", ListSortDirection.Ascending));
                }
                
            }

            //if (this.dgrdQuery.Items.Count == 0)
            //{
            //    this.model.OcFavQuery.Add(new FavQuery()
            //    {
            //        QUERY_NAME = "쿼리명"
            //    });
            //    this.dgrdQuery.SelectedItem = (object)this.model.OcFavQuery.LastOrDefault<FavQuery>();
            //    this.DataGridScrollAndFocus(this.dgrdQuery, 0);
            //}
        }
        public void ReLoad() => LoadFavQueryInfo();


        private void dgrdQuery_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgrdQuery.SelectedItem != null)
            {
                txtQuery.IsEnabled = true;
                txtQuery.Text = (dgrdQuery.SelectedItem as FavQuery).QUERY_TEXT ?? "";
            }
        }

        private void txtSearchQuery_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (timer == null)
            {
                timer = new DispatcherTimer();
                timer.Interval = TimeSpan.FromMilliseconds(300);
                timer.Tick += new EventHandler(handleTypingTimerTimeout);
            }
            timer.Stop();
            timer.Tag = (sender as TextBox).Text;
            timer.Start();
            
        }
        private void handleTypingTimerTimeout(object sender, EventArgs e)
        {
            var timer = sender as DispatcherTimer; // WPF
            if (timer == null)
            {
                return;
            }
            //work
            this.model.RefreshView(this.view);            
            // The timer must be stopped! We want to act only once per keystroke.
            timer.Stop();
        }
        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            this.LoadFavQueryInfo();

            var list = (model.OcFavQuery.Select(d => d.GROUP).ToList()).Distinct();
            foreach (var item in list)
            {
                this.model.SaveCategoryCommand.Execute(item);
            }
            //this.LoadFavQueryTreeInfo();          
            this.Loaded -= new RoutedEventHandler(this.UserControl_Loaded);

        }
        
        private void LoadFavQueryInfo()
        {
            try
            {
                string favQueryFilePath = this.GetFavQueryFilePath();
                if (!File.Exists(favQueryFilePath))
                    return;
                XmlSerializer xmlSerializer = new XmlSerializer(typeof(ObservableCollection<FavQuery>));
                ObservableCollection<FavQuery> observableCollection = (ObservableCollection<FavQuery>)null;
                using (StreamReader streamReader = new StreamReader(favQueryFilePath))
                {
                    //observableCollection = (ObservableCollection<FavQuery>)xmlSerializer.Deserialize(streamReader);
                    observableCollection = xmlSerializer.Deserialize((TextReader)streamReader) as ObservableCollection<FavQuery>;
                }
                if (this.model.OcFavQuery == null)
                    this.model.OcFavQuery = new ObservableCollection<FavQuery>();
                this.model.OcFavQuery.Clear();
                foreach (FavQuery favQuery in (observableCollection.Cast<FavQuery>().ToList().OrderBy(d=>d.QUERY_NAME).OrderBy(d=>d.GROUP)))
                {
                    if (!this.model.OcFavQuery.Contains(favQuery))
                        this.model.OcFavQuery.Add(favQuery);
                }
               

                txtSearchQuery.Focus();
                if (dgrdQuery.SelectedItem == null)
                {
                    txtQuery.IsEnabled = false;
                    txtQuery.Text = "";
                }
                               
            }
            catch(Exception ex)
            {
                this.OwnerWindow.ShowMsgBox(ex.Message,3000);
            }
        }
        
        public string GetFavQueryFilePath() => !ApplicationDeployment.IsNetworkDeployed ? string.Format(".\\FavQuery.xml") : System.IO.Path.Combine(ApplicationDeployment.CurrentDeployment.DataDirectory, string.Format("FavQuery.xml"));
        public string GetFavQueryFilePath2() => !ApplicationDeployment.IsNetworkDeployed ? string.Format(".\\TreeQuery.xml") : System.IO.Path.Combine(ApplicationDeployment.CurrentDeployment.DataDirectory, string.Format("TreeQuery.xml"));        

        private bool UserFilter(object item)
        {
            FavQuery favQuery = item as FavQuery;
            bool flag = false;
            if (string.IsNullOrEmpty(this.txtSearchQuery.Text))
                return true;
            string text = this.txtSearchQuery.Text;
            char[] chArray = new char[1] { ' ' };
            foreach (string str in text.Split(chArray))
            {
                if (!string.IsNullOrEmpty(str))
                {
                    flag = (this.NVL((object)favQuery.QUERY_NAME, "").IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0 || this.NVL((object)favQuery.GROUP, "").IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0);
                    if (!flag)
                        return false;
                }
            }
            return flag;
        }

        private void BtnSave_Click(object sender, RoutedEventArgs e) => this.SaveFavQueryInfo();

        private void SaveFavQueryInfo()
        {
            if (this.model.OcFavQuery.GroupBy<FavQuery, string>((Func<FavQuery, string>)(x => x.QUERY_NAME)).All<IGrouping<string, FavQuery>>((Func<IGrouping<string, FavQuery>, bool>)(g => g.Count<FavQuery>() > 1)))
            {
                int num = (int)MessageBox.Show("중복되는 항목이 있습니다.");
            }
            else
            {
                string favQueryFilePath = this.GetFavQueryFilePath();
                using (StreamWriter streamWriter = new StreamWriter(favQueryFilePath))
                {
                    new XmlSerializer(typeof(ObservableCollection<FavQuery>)).Serialize((TextWriter)streamWriter, (object)this.model.OcFavQuery);
                    streamWriter.Close();
                }
                this.OwnerWindow.ShowMsgBox("저장완료", 1000);
            }
        }
        public void SaveButton() => this.SaveFavQueryInfo();
        private void BtnAdd_Click(object sender, RoutedEventArgs e)
        {
            txtSearchQuery.TextChanged -= txtSearchQuery_TextChanged;
            txtSearchQuery.Text = "";
            txtSearchQuery.TextChanged += txtSearchQuery_TextChanged;
            this.model.OcFavQuery.Add(new FavQuery()
            {
                QUERY_NAME = "쿼리명"
            });
            this.dgrdQuery.SelectedItem = (object)this.model.OcFavQuery.LastOrDefault<FavQuery>();
            this.model.OCFAVQUERY_SEL = this.model.OcFavQuery.LastOrDefault<FavQuery>();
            this.DataGridScrollAndFocus(this.dgrdQuery, 0);
           
        }

        private void BtnDelete_Click(object sender, RoutedEventArgs e)
        {
            if (!(this.dgrdQuery.SelectedItem is FavQuery selectedItem))
                return;
            this.dgrdQuery.SelectedItems.Cast<FavQuery>().ToList().ForEach(x => { model.OcFavQuery.Remove(x); });
            //this.OcFavQuery.Remove(selectedItem);
        }

        private void txtQuery_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (dgrdQuery.SelectedItem != null)
                ((FavQuery)dgrdQuery.SelectedItem).QUERY_TEXT = ((TextBox)sender).Text;
            else if(dgrdQuery.SelectedItem == null && this.model.OCFAVQUERY_SEL != null)
            {
                dgrdQuery.SelectedItem = (object)this.model.OCFAVQUERY_SEL;
                if ((FavQuery)dgrdQuery.SelectedItem != null) 
                    ((FavQuery)dgrdQuery.SelectedItem).QUERY_TEXT = ((TextBox)sender).Text;
            }
        }

        private void BtnUp_Click(object sender, RoutedEventArgs e)
        {
            if (!(this.dgrdQuery.SelectedItem is FavQuery selectedItem) || selectedItem == this.model.OcFavQuery.FirstOrDefault<FavQuery>())
                return;
            FavQuery favQuery = selectedItem.Clone() as FavQuery;
            this.model.OcFavQuery.Insert(this.model.OcFavQuery.IndexOf(selectedItem) - 1, favQuery);
            this.model.OcFavQuery.Remove(selectedItem);
            this.dgrdQuery.SelectedItem = (object)favQuery;
        }

        private void BtnDown_Click(object sender, RoutedEventArgs e)
        {
            if (!(this.dgrdQuery.SelectedItem is FavQuery selectedItem) || selectedItem == this.model.OcFavQuery.LastOrDefault<FavQuery>())
                return;
            FavQuery favQuery = selectedItem.Clone() as FavQuery;
            this.model.OcFavQuery.Insert(this.model.OcFavQuery.IndexOf(selectedItem) + 2, favQuery);
            this.model.OcFavQuery.Remove(selectedItem);
            this.dgrdQuery.SelectedItem = (object)favQuery;
        }
        private void BtnBackupXml_Click(object sender, RoutedEventArgs e)
        {
            string toDay = DateTime.Now.ToString("yyyyMMdd");
            string favQueryFilePath = this.GetFavQueryFilePath();
            if (!File.Exists(favQueryFilePath))
                return;
            SaveFileDialog saveFileDialog = new SaveFileDialog();
            saveFileDialog.Title = "저장경로를 지정하세요.";
            saveFileDialog.OverwritePrompt = true;
            saveFileDialog.Filter = "XML File(*.xml)|*.xml";
            saveFileDialog.FileName = "WB.MyQuery" + "(" + toDay + ")" + ".xml";
            bool? nullable = saveFileDialog.ShowDialog();
            bool flag = true;
            if (!(nullable.GetValueOrDefault() == flag & nullable.HasValue))
                return;
            File.Copy(favQueryFilePath, saveFileDialog.FileName, true);
        }

        private void BtnRestoreXml_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            bool? nullable = openFileDialog.ShowDialog();
            bool flag = true;
            if (!(nullable.GetValueOrDefault() == flag & nullable.HasValue))
                return;
            string fileName = openFileDialog.FileName;
            if (!File.Exists(fileName))
                return;
            XmlSerializer xmlSerializer = new XmlSerializer(typeof(ObservableCollection<FavQuery>));
            ObservableCollection<FavQuery> observableCollection = (ObservableCollection<FavQuery>)null;
            using (StreamReader streamReader = new StreamReader(fileName))
                observableCollection = xmlSerializer.Deserialize((TextReader)streamReader) as ObservableCollection<FavQuery>;
            if (this.model.OcFavQuery == null)
                this.model.OcFavQuery = new ObservableCollection<FavQuery>();
            foreach (FavQuery favQuery in (Collection<FavQuery>)observableCollection)
            {
                if (model.OcFavQuery.Where(d => d.QUERY_NAME == favQuery.QUERY_NAME && d.QUERY_TEXT == favQuery.QUERY_TEXT).Count() < 1)
                    this.model.OcFavQuery.Add(favQuery);
            }
        }

        private void BtnReload_Click(object sender, RoutedEventArgs e)
        {
            txtSearchQuery.Text = "";
            this.LoadFavQueryInfo();
            //this.dgrdQuery.SelectedItem = this.model.OcFavQuery.FirstOrDefault();
            //this.DataGridScrollAndFocus(this.dgrdQuery, 0);
        }

        private void UserControl_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.F5)
                BtnReload_Click(sender, e);
            if (e.Key == Key.F1)
            {
                if (this.grdMain.ColumnDefinitions[4].Width == new GridLength(0, GridUnitType.Star))
                {
                    this.grdMain.ColumnDefinitions[0].Width = new GridLength(2, GridUnitType.Star);
                    this.grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                    this.grdMain.ColumnDefinitions[2].Width = new GridLength(6, GridUnitType.Star);
                    this.grdMain.ColumnDefinitions[3].Width = new GridLength(10);
                    this.grdMain.ColumnDefinitions[4].Width = new GridLength(1, GridUnitType.Star);
                }
                else if (this.grdMain.ColumnDefinitions[4].Width != new GridLength(0, GridUnitType.Star))
                {
                    this.grdMain.ColumnDefinitions[0].Width = new GridLength(1.715, GridUnitType.Star);
                    this.grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                    this.grdMain.ColumnDefinitions[2].Width = new GridLength(6, GridUnitType.Star);
                    this.grdMain.ColumnDefinitions[3].Width = new GridLength(10);
                    this.grdMain.ColumnDefinitions[4].Width = new GridLength(0, GridUnitType.Star);
                }
            }
        }
        
        private void GridSplitter_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            if (sender is null || grdMain is null || grdMain.ColumnDefinitions == null) return;
            try
            {
                if (this.grdMain.ColumnDefinitions[4].Width == new GridLength(0, GridUnitType.Star))
                {
                    this.grdMain.ColumnDefinitions[0].Width = new GridLength(2, GridUnitType.Star);
                    this.grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                    this.grdMain.ColumnDefinitions[2].Width = new GridLength(6, GridUnitType.Star);
                    this.grdMain.ColumnDefinitions[3].Width = new GridLength(10);
                    this.grdMain.ColumnDefinitions[4].Width = new GridLength(1, GridUnitType.Star);
                }
                else if (this.grdMain.ColumnDefinitions[4].Width != new GridLength(0, GridUnitType.Star))
                {
                    this.grdMain.ColumnDefinitions[0].Width = new GridLength(1.715, GridUnitType.Star);
                    this.grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                    this.grdMain.ColumnDefinitions[2].Width = new GridLength(6, GridUnitType.Star);
                    this.grdMain.ColumnDefinitions[3].Width = new GridLength(10);
                    this.grdMain.ColumnDefinitions[4].Width = new GridLength(0, GridUnitType.Star);
                }
            }
            catch
            {

            }
        }

        private void TextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if(e.Key == Key.Enter)
                this.model.SaveCategoryCommand.Execute(null);
        }

        private void dgrdCategory_MouseUp(object sender, MouseButtonEventArgs e)
        {
            if (sender is null || (((DataGrid)sender).SelectedItem == null || string.IsNullOrEmpty((((DataGrid)sender).SelectedItem as Category_INOUT).CATEGORY))) return;
            
            this.txtSearchQuery.Text = (((DataGrid)sender).SelectedItem as Category_INOUT).CATEGORY;
            this.txtSearchQuery.Focus();
            txtSearchQuery.CaretIndex = txtSearchQuery.Text.Length;
        }
        
        private void btnFavDelete_Click(object sender, RoutedEventArgs e)
        {
            List<FavQuery> selectedItems = this.dgrdQuery.SelectedItems.Cast<FavQuery>().ToList();

            selectedItems.ForEach(x => x.GROUP = null);
            InitDataGrid();
        }

        private void btnGolden_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrEmpty(this.txtQuery.Text))
                return;
            string code = "";
            string title = "";
            code = this.txtQuery.Text;
            title = (this.dgrdQuery.SelectedItem as FavQuery).QUERY_NAME ?? "";
            this.StartGoldenCode(code, title);
        }
        private void btnPlEdit_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrEmpty(this.txtQuery.Text))
                return;
            string title = "";
            title = (this.dgrdQuery.SelectedItem as FavQuery).QUERY_NAME ?? "";
            this.StartPLEditCode(txtQuery.Text, title);
        }

        private void dgrdCategory_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (sender is null || (dgrdCategory.SelectedItem == null || string.IsNullOrEmpty((dgrdCategory.SelectedItem as Category_INOUT).CATEGORY))) return;

            this.txtSearchQuery.Text = (dgrdCategory.SelectedItem as Category_INOUT).CATEGORY;
            this.txtSearchQuery.Focus();
            txtSearchQuery.CaretIndex = txtSearchQuery.Text.Length;
        }
        public void ShowMsgBox(string msg,int timeout)
        {
            this.ShowMsgBox(msg, timeout);
        }
    }

}
