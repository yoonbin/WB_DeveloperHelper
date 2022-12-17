using Microsoft.Win32;
using System;
using System.CodeDom.Compiler;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Deployment.Application;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Input;
using System.Windows.Markup;
using System.Xml;
using System.Xml.Serialization;
using WB.DTO;
using WB.UC;

namespace WB
{
    /// <summary>
    /// FavQuery.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class FavQueryMng : UCBase
    {
        private ObservableCollection<FavQuery> ocFavQuery = new ObservableCollection<FavQuery>();
        private CollectionView view;
        private UserInfo_INOUT UserInfo = new UserInfo_INOUT();
        /// <summary>
        /// name         : USERINFO
        /// desc         : USERINFO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-03
        /// update date  : 2022-11-03
        /// </summary>
        /// <remarks></remarks>
        public UserInfo_INOUT USERINFO
        {
            get => this.UserInfo;
            set => this.UserInfo = value;
        }

        public FavQueryMng()
        {
            InitializeComponent();
            this.DataContext = (object)this;
            dgrdQuery.ItemsSource = (IEnumerable)this.OcFavQuery;
            
            if (this.dgrdQuery.ItemsSource != null)
            {
                this.view = (CollectionView)CollectionViewSource.GetDefaultView((object)this.dgrdQuery.ItemsSource);
                this.view.Filter = new Predicate<object>(this.UserFilter);
            }
        }

        public ObservableCollection<FavQuery> OcFavQuery
        {
            get => this.ocFavQuery;
            set => this.ocFavQuery = value;
        }
        private void dgrdQuery_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (dgrdQuery.SelectedItem != null)
            {
                txtQuery.IsEnabled = true;
                txtQuery.Text = (dgrdQuery.SelectedItem as FavQuery).QUERY_TEXT;
            }
        }

        private void txtSearchQuery_TextChanged(object sender, TextChangedEventArgs e)
        {
            view.Refresh();
        }

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            this.LoadFavQueryInfo();            
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
                if (this.OcFavQuery == null)
                    this.OcFavQuery = new ObservableCollection<FavQuery>();
                this.OcFavQuery.Clear();
                foreach (FavQuery favQuery in (Collection<FavQuery>)observableCollection)
                {
                    if (!this.OcFavQuery.Contains(favQuery))
                        this.OcFavQuery.Add(favQuery);
                }
                txtSearchQuery.Focus();
                if (dgrdQuery.SelectedItem == null)
                {
                    txtQuery.IsEnabled = false;
                    txtQuery.Text = "";
                }
            }
            catch
            {

            }
        }
        private void LoadFavQueryTreeInfo()
        {
            string favQueryFilePath = this.GetFavQueryFilePath2();
            if (!File.Exists(favQueryFilePath))
                return;
            XmlDataProvider dataProvider = this.FindResource("xmlDataProvider") as XmlDataProvider;
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.Load(favQueryFilePath);
            dataProvider.Document = xmlDocument;
        }
        public string GetFavQueryFilePath() => !ApplicationDeployment.IsNetworkDeployed ? string.Format(".\\FavQuery.xml") : Path.Combine(ApplicationDeployment.CurrentDeployment.DataDirectory, string.Format("FavQuery.xml"));
        public string GetFavQueryFilePath2() => !ApplicationDeployment.IsNetworkDeployed ? string.Format(".\\TreeQuery.xml") : Path.Combine(ApplicationDeployment.CurrentDeployment.DataDirectory, string.Format("TreeQuery.xml"));

     

        private bool UserFilter(object item)
        {
            FavQuery favQuery = item as FavQuery;
            bool flag = false;
            if (string.IsNullOrEmpty(this.txtSearchQuery.Text))
                return true;
            string text = this.txtSearchQuery.Text;
            char[] chArray = new char[1] { ',' };
            foreach (string str in text.Split(chArray))
            {
                if (!string.IsNullOrEmpty(str))
                {
                    flag = this.NVL((object)favQuery.QUERY_NAME, "").IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0;
                    if (!flag)
                        return false;
                }
            }
            return flag;
        }        

        private void BtnSave_Click(object sender, RoutedEventArgs e) => this.SaveFavQueryInfo();

        private void SaveFavQueryInfo()
        {
            if (this.OcFavQuery.GroupBy<FavQuery, string>((Func<FavQuery, string>)(x => x.QUERY_NAME)).All<IGrouping<string, FavQuery>>((Func<IGrouping<string, FavQuery>, bool>)(g => g.Count<FavQuery>() > 1)))
            {
                int num = (int)MessageBox.Show("중복되는 항목이 있습니다.");
            }
            else
            {
                string favQueryFilePath = this.GetFavQueryFilePath();
                using (StreamWriter streamWriter = new StreamWriter(favQueryFilePath))
                {
                    new XmlSerializer(typeof(ObservableCollection<FavQuery>)).Serialize((TextWriter)streamWriter, (object)this.OcFavQuery);
                    streamWriter.Close();
                }
                this.OwnerWindow.ShowMsgBox("저장완료", 1000);
            }
        }
        private void BtnAdd_Click(object sender, RoutedEventArgs e)
        {
            this.OcFavQuery.Add(new FavQuery()
            {
                QUERY_NAME = "쿼리명"
            });
            this.dgrdQuery.SelectedItem = (object)this.OcFavQuery.LastOrDefault<FavQuery>();
            this.DataGridScrollAndFocus(this.dgrdQuery, 0);
        }

        private void BtnDelete_Click(object sender, RoutedEventArgs e)
        {
            if (!(this.dgrdQuery.SelectedItem is FavQuery selectedItem))
                return;
            this.dgrdQuery.SelectedItems.Cast<FavQuery>().ToList().ForEach(x => { OcFavQuery.Remove(x); });
            //this.OcFavQuery.Remove(selectedItem);
        }

        private void txtQuery_TextChanged(object sender, TextChangedEventArgs e)
        {
            if (dgrdQuery.SelectedItem != null)
                ((FavQuery)dgrdQuery.SelectedItem).QUERY_TEXT = ((TextBox)sender).Text;
        }

        private void BtnUp_Click(object sender, RoutedEventArgs e)
        {
            if (!(this.dgrdQuery.SelectedItem is FavQuery selectedItem) || selectedItem == this.OcFavQuery.FirstOrDefault<FavQuery>())
                return;
            FavQuery favQuery = selectedItem.Clone() as FavQuery;
            this.OcFavQuery.Insert(this.OcFavQuery.IndexOf(selectedItem) - 1, favQuery);
            this.OcFavQuery.Remove(selectedItem);
            this.dgrdQuery.SelectedItem = (object)favQuery;
        }

        private void BtnDown_Click(object sender, RoutedEventArgs e)
        {
            if (!(this.dgrdQuery.SelectedItem is FavQuery selectedItem) || selectedItem == this.OcFavQuery.LastOrDefault<FavQuery>())
                return;
            FavQuery favQuery = selectedItem.Clone() as FavQuery;
            this.OcFavQuery.Insert(this.OcFavQuery.IndexOf(selectedItem) + 2, favQuery);
            this.OcFavQuery.Remove(selectedItem);
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
            saveFileDialog.FileName = "WB.MyQuery"+"("+ toDay +")"+".xml";
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
            if (this.OcFavQuery == null)
                this.OcFavQuery = new ObservableCollection<FavQuery>();
            foreach (FavQuery favQuery in (Collection<FavQuery>)observableCollection)
            {
                if (OcFavQuery.Where(d => d.QUERY_NAME == favQuery.QUERY_NAME && d.QUERY_TEXT == favQuery.QUERY_TEXT).Count() < 1)
                    this.OcFavQuery.Add(favQuery);
            }
        }

        private void BtnReload_Click(object sender, RoutedEventArgs e)
        {
            txtSearchQuery.Text = "";
            this.LoadFavQueryInfo(); 
        }

        private void UserControl_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.F5)
                BtnReload_Click(sender,e);
        }
        private void ChangeText(string[] strArr)
        {

        }
        private void GridSplitter_MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            try
            {
                grdMain.ColumnDefinitions[0].Width = new GridLength(1, GridUnitType.Star);
                grdMain.ColumnDefinitions[1].Width = new GridLength(10);
                grdMain.ColumnDefinitions[2].Width = new GridLength(6, GridUnitType.Star);
            }
            catch (Exception)
            {

            }
        }
    }
}
