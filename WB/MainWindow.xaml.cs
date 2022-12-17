using IBatisNet.DataMapper;
using Microsoft.Win32;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.OracleClient;
using System.Deployment.Application;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Timers;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Threading;
using System.Xml;
using System.Xml.Serialization;
using WB.DTO;
using WB.Interface;
using WB.UC;

namespace WB
{
    /// <summary>
    /// MainWindow.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class MainWindow : Window ,IDisposable
    {
        public MainWindow()
        {
            InitializeComponent();

            this.model = this.DataContext as ViewModelBase;
            this.chkAutoBak.Checked -= CheckBox_Checked;
            grdLoading.Visibility = Visibility.Collapsed;
            LoadingAnimation();
            this.model.POPUP_YN = "N";
            
            
        }
        public MainWindow(string type_name,string title)
        {
            InitializeComponent();

            this.model = this.DataContext as ViewModelBase;
            this.chkAutoBak.Checked -= CheckBox_Checked;
            grdLoading.Visibility = Visibility.Collapsed;
            LoadingAnimation();

            Type t = Type.GetType(type_name);

            if (t == null) return;

            object uc = Activator.CreateInstance(t);            

            ctcTabPopup.Content = uc;
            this.model.POPUP_YN = "Y";

            this.Title = title;

        }
        EAMMenuInfo eam = new EAMMenuInfo();
        MetaDL dac = new MetaDL();                   
        private ViewModelBase model;
        public delegate void Delegate();
        private ObservableCollection<BasicSetting> ocBasicSetting = new ObservableCollection<BasicSetting>();
        private ObservableCollection<DBUser> ocDB1User = new ObservableCollection<DBUser>();
        private ObservableCollection<DBUser> ocDB2User = new ObservableCollection<DBUser>();
        private string YES_NO = "";
        private TabItem PREV_TAB;
        private ISynchronizeInvoke synchronizeInvoke;
        private System.Timers.Timer bakTimer;
        private int hours = 0;
        public ObservableCollection<BasicSetting> OcBasicSetting
        {
            get => this.ocBasicSetting;
            set => this.ocBasicSetting = value;
        }

        public ObservableCollection<DBUser> OcDB1User
        {
            get => this.ocDB1User;
            set => this.ocDB1User = value;
        }

        public ObservableCollection<DBUser> OcDB2User
        {
            get => this.ocDB2User;
            set => this.ocDB2User = value;
        }
        private bool isSettingCompleted = false;
        public bool IsSettingCompleted
        {
            get => this.isSettingCompleted;
            set => this.isSettingCompleted = value;
        }             

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            InitData();
            ControlInit();
            this.rdoDev.IsChecked = new bool?(true);
            this.rdoDev.Checked += new RoutedEventHandler(this.rdoDev_Checked);
            this.rdoApp.Checked += new RoutedEventHandler(this.rdoApp_Checked);
            this.cboDB1.SelectionChanged += new SelectionChangedEventHandler(this.cboDB1_SelectionChanged);
            this.cboDB2.SelectionChanged += new SelectionChangedEventHandler(this.cboDB2_SelectionChanged);
            InputMethod.SetIsInputMethodEnabled(this.txtBakInterval, false);
            this.model.LoadUserInfo();

            if(this.model.USERINFO != null && this.model.USERINFO.AUTO_BACKUP_YN == "Y" && this.model.POPUP_YN == "N")//팝업이 아닐때만.
                AutoBackUp();
            if (this.model.USERINFO.TAB_INFO_LIST != null && this.model.USERINFO.TAB_INFO_LIST.Count > 0)
            {
                foreach(var tabItem in this.model.USERINFO.TAB_INFO_LIST.OrderBy(d=>d.SEQ))
                {
                    this.AddTab(tabItem.TAB_NAME);
                }
            }
            else
            {
                this.AddTab("tiTableInfo");
                this.AddTab("tiCodeGenerater");
                this.AddTab("tiSourceGenerater");
                this.AddTab("tiEqsDbSource");
                this.AddTab("tiDBSourceFinder");
                this.AddTab("tiCommonCode");
                this.AddTab("tiCodeReOrder");
                this.AddTab("tiMeta");
                this.AddTab("tiFavQuery");
                this.AddTab("tiFavMemo");
                this.AddTab("tiEamInfo");
                this.AddTab("tiUserInfo");
                this.AddTab("tiCalMemo");
                this.AddTab("tiSetting");
            }
            this.chkAutoBak.Checked -= CheckBox_Checked;
            this.chkAutoBak.Checked += CheckBox_Checked;
            var btn = this.tabMain.Template.FindName("tabClose", this.tabMain);
        }
        private void AutoBackUp()
        {
            try
            {
                if (string.IsNullOrEmpty(this.model.USERINFO.BAK_INTERVAL))
                    this.model.USERINFO.BAK_INTERVAL = "60";

                int interval = Convert.ToInt32(this.model.USERINFO.BAK_INTERVAL) * 60 * 1000;

                if (string.IsNullOrEmpty(this.model.USERINFO.BAK_PATH))
                {
                    using (System.Windows.Forms.FolderBrowserDialog dialog = new System.Windows.Forms.FolderBrowserDialog())
                    {
                        if (dialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                        {
                            this.model.USERINFO.BAK_PATH = @dialog.SelectedPath;

                        }
                        else
                        {
                            this.model.USERINFO.AUTO_BACKUP_YN = null;
                            this.model.SaveUserInfo();
                        }
                    }
                }
                else
                {
                    DirectoryInfo di = new DirectoryInfo(this.model.USERINFO.BAK_PATH);
                    if (!di.Exists)
                    {
                        this.ShowErrorMsgBox("해당 폴더가 경로에 존재하지 않습니다.");
                        this.chkAutoBak.IsChecked = false;
                        return;
                    }
                }
                SaveMyQueryUserInfo();

                bakTimer = new System.Timers.Timer();
                bakTimer.SynchronizingObject = synchronizeInvoke;
                bakTimer.Interval = interval;
                bakTimer.Elapsed += (ElapsedEventHandler)((_param1, _param2) => System.Windows.Application.Current.Dispatcher.BeginInvoke((Delegate)(() =>
                {
                    SaveMyQueryUserInfo();
                }), DispatcherPriority.Send));
                bakTimer.Enabled = true;
            }
            catch
            {
                this.ShowMsgBox("백업에 실패했습니다.",3000);
            }
            
        }
        private void SaveMyQueryUserInfo()
        {
            try
            {
                bool isSuccess = false;
                //MyQuery
                string toDay = DateTime.Now.ToString("yyyyMMdd");
                string favQueryFilePath = this.GetFavQueryFilePath();                                    

                if (!string.IsNullOrEmpty(this.model.USERINFO.BAK_PATH))
                {
                    if (File.Exists(favQueryFilePath))
                    {
                        File.Copy(favQueryFilePath, this.model.USERINFO.BAK_PATH + @"\WB.MyQuery(" + toDay + ").xml", true);
                        isSuccess = true;
                    }
                }
                else
                {
                    return;
                }

                //UserInfo
                string userInfoFilePath = this.model.GetUserInfoPath();                
                if (!string.IsNullOrEmpty(this.model.USERINFO.BAK_PATH))
                {
                    if (File.Exists(userInfoFilePath))
                    {
                        File.Copy(userInfoFilePath, this.model.USERINFO.BAK_PATH + @"\WB.UserInfo(" + toDay + ").xml", true);
                        isSuccess = true;
                    }                    
                }
                else
                {
                    return;
                }                

                if(isSuccess)
                    this.ShowMsgBox("백업되었습니다.", 1000);
                else
                    this.ShowMsgBox("백업할 사용자세팅이 없습니다.", 1000);
            }
            catch
            {

            }
        }
        /// <summary>
        /// 데이터 초기화
        /// </summary>
        private void InitData()
        {
            this.GetBasicSetting();
            this.GetDB1User();
            this.GetDB2User();
        }
        private void ControlInit()
        {
            if (ocDB1User != null && ocDB1User.Count > 0)
            {
                this.cboDB1.ItemsSource = (IEnumerable)this.ocDB1User;
                this.cboDB1.DisplayMemberPath = "USER_NAME";
                this.cboDB1.SelectedValuePath = "USER_NAME";
                this.cboDB1.SelectedIndex = 0;
            }
            if (ocDB2User != null && ocDB2User.Count > 0)
            {
                this.cboDB2.ItemsSource = (IEnumerable)this.ocDB2User;
                this.cboDB2.DisplayMemberPath = "USER_NAME";
                this.cboDB2.SelectedValuePath = "USER_NAME";
                this.cboDB2.SelectedIndex = 0;
            }
        }

        private void btnAddTab_Click(object sender, RoutedEventArgs e)
        {
            this.AddTab((this.tabMain.SelectedItem as TabItem).Name, this.tabMain.SelectedIndex + 1);
            SaveTabInfo(this.tabMain.Items);
        }

        private void AddTab(string tabItemName) => this.AddTab(tabItemName, -1);
        private void AddTab(string tabItemName, int tab_index)
        {
            TabItem tabItem = new TabItem();
            //tabItem.Style = this.TryFindResource("tabHeaderStyle") as Style;            
            tabItem.Name = tabItemName;
            if (tabItemName == "tiTableInfo")
            {
                tabItem.Content = (object)new TableInfo()
                {
                    IsSelectWithStart = true
                };
                tabItem.Header = "Table";                
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiCodeGenerater")
            {
                CodeGenerater codeGenerator = new CodeGenerater();
                tabItem.Content = (object)codeGenerator;
                tabItem.Header = "CodeGenerater";
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiSourceGenerater")
            {
                SourceGenerater sourceGenerater = new SourceGenerater();
                tabItem.Content = (object)sourceGenerater;
                tabItem.Header = "SourceGenerater";
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiEqsDbSource")
            {
                SelectEqsDBSource selectEqsDBSource = new SelectEqsDBSource();
                tabItem.Content = (object)selectEqsDBSource;
                tabItem.Header = "EQS/DBSource";
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiDBSourceFinder")
            {
                SelectDBSourceFinder selectDBSourceFinder= new SelectDBSourceFinder();
                tabItem.Content = (object)selectDBSourceFinder;
                tabItem.Header = "DBSourceFinder";
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiCommonCode")
            {
                SelectCommonCode selectCommon = new SelectCommonCode();
                tabItem.Content = (object)selectCommon;
                tabItem.Header = "Common Code";
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiMeta")
            {
                Meta selectQuery = new Meta();
                tabItem.Content = (object)selectQuery;
                tabItem.Header = "Meta";
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiFavQuery")
            {
                FavQueryMngV2 favQueryManagement = new FavQueryMngV2();
                tabItem.Content = (object)favQueryManagement;
                tabItem.Header = "MyQuery";
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiFavMemo")
            {
                SelectMyMemo selectMyMemo = new SelectMyMemo(true) { AutoSave = true };                
                tabItem.Content = (object)selectMyMemo;
                tabItem.Header = "MyMemo";
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiCodeReOrder")
            {
                CodeReOrder codeReOrder = new CodeReOrder();
                tabItem.Content = (object)codeReOrder;
                tabItem.Header = "CodeReorder";
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiEamInfo")
            {
                EAMMenuInfo eamMenuInfo= new EAMMenuInfo();
                tabItem.Content = (object)eamMenuInfo;
                tabItem.Header = "EAM";
               
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiUserInfo")
            {
                SelectUserInfo selectUserInfo = new SelectUserInfo();
                tabItem.Content = (object)selectUserInfo;
                tabItem.Header = "User";
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiCalMemo")
            {
                SelectCalMemo selectCalMemo = new SelectCalMemo();
                tabItem.Content = (object)selectCalMemo;
                tabItem.Header = "MyCalender";
                tabItem.Tag = tabItemName;
            }
            else if (tabItemName == "tiSetting")
            {
                Setting setting = new Setting();
                tabItem.Content = (object)setting;
                tabItem.Header = "Setting";
                tabItem.Tag = tabItemName;
            }
            
            if (tab_index > -1)
            {
                this.tabMain.Items.Insert(tab_index, (object)tabItem);
                this.tabMain.SelectedItem = (object)tabItem;
            }
            else
                this.tabMain.Items.Add((object)tabItem);
        }
        private void btnCloseTab_Click(object sender, RoutedEventArgs e)
        {
            TabItem selectedItem = this.tabMain.SelectedItem as TabItem;
            if (selectedItem == null) return;
            //Tab 1개
            if (this.GetTabCount(selectedItem.Name) == 1)
            {
                if (!ShowYesNoMsgBox("정말 삭제하시겠습니까?"))
                    return;
            }
            var idx = this.tabMain.SelectedIndex;
            this.tabMain.Items.Remove((object)selectedItem);
            SaveTabInfo(this.tabMain.Items);
            this.tabMain.SelectedIndex = idx == 0 ? idx  : idx - 1 ;
        }
        private int GetTabCount(string tabName)
        {
            int tabCount = 0;
            foreach (FrameworkElement frameworkElement in (IEnumerable)this.tabMain.Items)
            {
                if (frameworkElement.Name == tabName)
                    ++tabCount;
            }
            return tabCount;
        }
        public string GetBasicSettingFilePath() => !ApplicationDeployment.IsNetworkDeployed ? string.Format(".\\Setting.xml") : System.IO.Path.Combine(ApplicationDeployment.CurrentDeployment.DataDirectory, string.Format("Setting.xml"));

        public string GetDBInfoSettingFilePath(string dbGbn) => !ApplicationDeployment.IsNetworkDeployed ? string.Format(".\\Setting{0}.xml", (object)dbGbn) : System.IO.Path.Combine(ApplicationDeployment.CurrentDeployment.DataDirectory, string.Format("Setting{0}.xml", (object)dbGbn));
        public void GetBasicSetting()
        {
            string sMetaConnection = "";
            this.OcBasicSetting = this.GetBasicSettingFromSettingFile();
            if (this.OcBasicSetting == null || this.OcBasicSetting.Count == 0)
                return;

            sMetaConnection = this.OcBasicSetting.Where<BasicSetting>((Func<BasicSetting, bool>)(d => d.CODE == "MetaConnectionString")).FirstOrDefault<BasicSetting>().VALUE;
            if (!string.IsNullOrEmpty(sMetaConnection))
                SetMetaConnectionString(sMetaConnection);
        }
        public ObservableCollection<BasicSetting> GetBasicSettingFromSettingFile()
        {
            string basicSettingFilePath = this.GetBasicSettingFilePath();

            if (!File.Exists(basicSettingFilePath))
                return (ObservableCollection<BasicSetting>)null;

            XmlSerializer xmlSerializer = new XmlSerializer(typeof(ObservableCollection<BasicSetting>));

            ObservableCollection<BasicSetting> observableCollection = (ObservableCollection<BasicSetting>)null;
           
            using (StreamReader streamReader = new StreamReader(basicSettingFilePath))
                observableCollection = xmlSerializer.Deserialize((TextReader)streamReader) as ObservableCollection<BasicSetting>;
            
            ObservableCollection<BasicSetting> settingFromSettingFile = new ObservableCollection<BasicSetting>();
           
            foreach (BasicSetting basicSetting in (Collection<BasicSetting>)observableCollection)
                settingFromSettingFile.Add(basicSetting);
           
            return settingFromSettingFile;
        }


        public void GetDB1User()
        {
            this.OcDB1User.Clear();
            try
            {
                string infoSettingFilePath = this.GetDBInfoSettingFilePath("DEV");
                if (!File.Exists(infoSettingFilePath))
                    return;
                XmlSerializer xmlSerializer = new XmlSerializer(typeof(ObservableCollection<DBUser>));
                ObservableCollection<DBUser> observableCollection = (ObservableCollection<DBUser>)null;
                using (StreamReader streamReader = new StreamReader(infoSettingFilePath))
                {
                    observableCollection = xmlSerializer.Deserialize((TextReader)streamReader) as ObservableCollection<DBUser>;
                    streamReader.Close();
                }
                foreach (DBUser dbUser in (Collection<DBUser>)observableCollection)
                    this.OcDB1User.Add(dbUser);
                if (this.OcDB1User.Count == 0)
                {
                    this.ShowMsgBox("Setting 탭에서 DB1 Connection 정보를 설정하세요.", 3000);
                }
                else
                {
                    this.IsSettingCompleted = true;
                    if (this.cboDB1 != null && this.cboDB1.SelectedIndex == -1)
                        this.cboDB1.SelectedIndex = 0;
                }
            }
            catch(Exception)
            {

            }
        }

        public void GetDB2User()
        {
            this.OcDB2User.Clear();
            try
            {
                string infoSettingFilePath = this.GetDBInfoSettingFilePath("APP");
                if (!File.Exists(infoSettingFilePath))
                    return;
                XmlSerializer xmlSerializer = new XmlSerializer(typeof(ObservableCollection<DBUser>));
                ObservableCollection<DBUser> observableCollection = (ObservableCollection<DBUser>)null;
                using (StreamReader streamReader = new StreamReader(infoSettingFilePath))
                {
                    observableCollection = xmlSerializer.Deserialize((TextReader)streamReader) as ObservableCollection<DBUser>;
                    streamReader.Close();
                }
                foreach (DBUser dbUser in (Collection<DBUser>)observableCollection)
                    this.OcDB2User.Add(dbUser);
                if (this.OcDB2User.Count == 0)
                {
                    this.ShowMsgBox("Setting 탭에서 DB2 Connection 정보를 설정하세요.", 3000);
                }
                else
                {
                    this.IsSettingCompleted = true;
                    if (this.cboDB2 != null && this.cboDB2.SelectedIndex == -1)
                        this.cboDB2.SelectedIndex = 0;
                }
            }
            catch(Exception)
            {

            }
        }

        private void LoadingAnimation()
        {
            // 애니메이션 설정
            DoubleAnimation dba1 = new DoubleAnimation();  // 애니메이션 생성
            dba1.From = 0;   // start 값
            dba1.To = 360;   // end 값
            dba1.Duration = new Duration(TimeSpan.FromSeconds(3));  // 1.5초 동안 실행
            dba1.RepeatBehavior = RepeatBehavior.Forever;  // 무한 반복

            RotateTransform rt = new RotateTransform();
            imgLoading.RenderTransform = rt;
            rt.CenterX += imgLoading.Width / 2;
            rt.CenterY += imgLoading.Height / 2;

            rt.BeginAnimation(RotateTransform.AngleProperty, dba1);   // 변경할 속성값, 대상애니매이션
        }
        public void ProgressOn()
        {
            grdLoading.Visibility = Visibility.Visible;
            //LoadingAnimation();
        }

        public void ProgressOff()
        {
            grdLoading.Visibility = Visibility.Collapsed;
        }

        public void ShowMsgBox(string msg, int timeout)
        {
            //MessageBox.Show(msg);

            System.Timers.Timer timer = new System.Timers.Timer((double)timeout)
            {
                AutoReset = false
            };
            timer.Elapsed += (ElapsedEventHandler)((_param1, _param2) => System.Windows.Application.Current.Dispatcher.BeginInvoke((Delegate)(() =>
            {
                this.tbMsgBox.Text = "";
                this.grdMsgBox.Visibility = Visibility.Collapsed;
            }), DispatcherPriority.Send));
            timer.Enabled = true;
            System.Windows.Application.Current.Dispatcher.BeginInvoke((Delegate)(() =>
            {
                this.tbMsgBox.Text = msg;
                this.grdMsgBox.Visibility = Visibility.Visible;
            }), DispatcherPriority.Send);
        }
        public bool ShowYesNoMsgBox(string msg)
        {
            bool msgResult = false;
            using (WBMsgBox msgBox = new WBMsgBox(msg))
            {
                msgBox.Owner = this.Parent as Window;
                msgBox.WindowStartupLocation = WindowStartupLocation.CenterScreen;
                msgBox.ShowDialog();
                msgResult = msgBox.YesOrNo;
            }
            return msgResult;
        }
        public void ShowErrorMsgBox(string msg)
        {            
            using (WBMsgErrorBox msgBox = new WBMsgErrorBox(msg))
            {
                msgBox.Owner = this.Parent as Window;
                msgBox.WindowStartupLocation = WindowStartupLocation.CenterScreen;
                msgBox.ShowDialog();                
            }         
        }
        private void rdoDev_Checked(object sender, RoutedEventArgs e)
        {
            if (this.cboDB1 == null || this.cboDB2 == null)
                return;
            this.cboDB1.Visibility = Visibility.Visible;
            this.cboDB2.Visibility = Visibility.Collapsed;
            this.cboDB1_SelectionChanged((object)null, (SelectionChangedEventArgs)null);
        }

        private void rdoApp_Checked(object sender, RoutedEventArgs e)
        {
            if (this.cboDB1 == null || this.cboDB2 == null)
                return;
            this.cboDB1.Visibility = Visibility.Collapsed;
            this.cboDB2.Visibility = Visibility.Visible;
            this.cboDB2_SelectionChanged((object)null, (SelectionChangedEventArgs)null);
        }

        private void cboDB1_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (!(this.cboDB1.SelectedItem is DBUser selectedItem))
                return;
            this.SetConnectionString(selectedItem.CONNECT_STRING);
        }

        private void cboDB2_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (!(this.cboDB2.SelectedItem is DBUser selectedItem))
                return;
            this.SetConnectionString(selectedItem.CONNECT_STRING);
        }
        private void SetConnectionString(string connStr)
        {
            string filename = string.Format(".\\SqlMap.config");
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.Load(filename);
            string str = xmlDocument.ChildNodes[1]["database"]["dataSource"].Attributes["connectionString"].Value = connStr;
            xmlDocument.Save(filename);
        }
        private void SetMetaConnectionString(string connStr)
        {
            string filename = string.Format(".\\MetaSqlMap.config");
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.Load(filename);
            string str = xmlDocument.ChildNodes[1]["database"]["dataSource"].Attributes["connectionString"].Value = connStr;
            xmlDocument.Save(filename);
        }
        private void btnMemo_Click(object sender, RoutedEventArgs e)
        {
            using (CodeWindow codeWindow = new CodeWindow())
            {
                codeWindow.Owner = this.Parent as Window;
                codeWindow.WindowStartupLocation = WindowStartupLocation.CenterScreen;
                codeWindow.Show();
                //codeWindow.txtCode.Text = "";
            }
        }

        private void btnRegEx_Click(object sender, RoutedEventArgs e)
        {
            using (CodeRegEx codeRegEx = new CodeRegEx())
            {
                codeRegEx.Owner = this.Parent as Window;
                codeRegEx.WindowStartupLocation = WindowStartupLocation.CenterScreen;
                codeRegEx.Show();
                //codeWindow.txtCode.Text = "";
            }

        }

        private void btnBackUp_Click(object sender, RoutedEventArgs e)
        {
            //MyQuery
            string toDay = DateTime.Now.ToString("yyyyMMdd");
            string favQueryFilePath = this.GetFavQueryFilePath();
            if (!File.Exists(favQueryFilePath))
                return;
            
            if (!string.IsNullOrEmpty(this.model.USERINFO.BAK_PATH))
            {
               
                File.Copy(favQueryFilePath, this.model.USERINFO.BAK_PATH + @"\WB.MyQuery(" + toDay + ").xml", true);
                this.ShowMsgBox("백업되었습니다.", 1000);
            }
            else
            {
                System.Windows.Forms.FolderBrowserDialog dialog = new System.Windows.Forms.FolderBrowserDialog();
                if (dialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                {
                    this.model.USERINFO.BAK_PATH = @dialog.SelectedPath;
                   
                    File.Copy(favQueryFilePath, this.model.USERINFO.BAK_PATH + @"\WB.MyQuery(" + toDay + ").xml", true);
                    this.ShowMsgBox("백업되었습니다.", 1000);
                }
            }

            //UserInfo
            string userInfoFilePath = this.model.GetUserInfoPath();
            if (!File.Exists(userInfoFilePath))
                return;
            if (!string.IsNullOrEmpty(this.model.USERINFO.BAK_PATH))
            {
               
                File.Copy(userInfoFilePath, this.model.USERINFO.BAK_PATH + @"\WB.UserInfo(" + toDay + ").xml", true);
                this.ShowMsgBox("백업되었습니다.", 1000);
            }
            else
            {
                System.Windows.Forms.FolderBrowserDialog dialog = new System.Windows.Forms.FolderBrowserDialog();
                if (dialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                {
                    this.model.USERINFO.BAK_PATH = @dialog.SelectedPath;
                   
                    File.Copy(userInfoFilePath, this.model.USERINFO.BAK_PATH + @"\WB.UserInfo(" + toDay + ").xml", true);
                    this.ShowMsgBox("백업되었습니다.", 1000);
                }
            }
            //this.model.SaveUserInfo();
        }

        public string GetFavQueryFilePath() => !ApplicationDeployment.IsNetworkDeployed ? string.Format(".\\FavQuery.xml") : System.IO.Path.Combine(ApplicationDeployment.CurrentDeployment.DataDirectory, string.Format("FavQuery.xml"));

        private void btnReStore_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                OpenFileDialog openFileDialog = new OpenFileDialog();
                bool? nullable = openFileDialog.ShowDialog();
                bool flag = true;
                if (!(nullable.GetValueOrDefault() == flag & nullable.HasValue))
                    return;
                string fileName = openFileDialog.FileName;
                if (!File.Exists(fileName))
                    return;
                XmlSerializer xmlSerializer = new XmlSerializer(typeof(UserInfo_INOUT));
                UserInfo_INOUT userInfo = (UserInfo_INOUT)null;
                using (StreamReader streamReader = new StreamReader(fileName))
                    userInfo = xmlSerializer.Deserialize((TextReader)streamReader) as UserInfo_INOUT;
                if (this.model.USERINFO == null)
                    this.model.USERINFO = new UserInfo_INOUT();
                this.model.USERINFO = userInfo;
                this.model.SaveUserInfo();
                this.ShowMsgBox("UserInfo를 불러왔습니다. 프로그램을 재실행 해주세요.", 1000);                
            }
            catch
            {
                this.ShowMsgBox("ERROR : UserInfo의 XML을 불러와주세요.", 3000);
            }
        }

        private void CheckBox_Checked(object sender, RoutedEventArgs e)
        {
           
            this.model.SaveUserInfo();
            if (this.model.USERINFO != null && this.model.USERINFO.AUTO_BACKUP_YN == "Y")
            {
                AutoBackUp();                
            }
        }

        private void CheckBox_Unchecked(object sender, RoutedEventArgs e)
        {
            if (this.bakTimer != null)
            {
                this.bakTimer.Enabled = false;
                this.bakTimer.Dispose();
            }
            this.model.SaveUserInfo();
        }

        
        private void TextBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            Regex regex = new Regex("[^0-9]+");
            e.Handled = regex.IsMatch(e.Text);
        }

        private void txtBakInterval_LostFocus(object sender, RoutedEventArgs e)
        {
            if (this.model.USERINFO != null && this.model.USERINFO.AUTO_BACKUP_YN == null)
                this.model.SaveUserInfo();           
        }

        private void TabItem_PreviewMouseMove(object sender, MouseEventArgs e)
        {
            if (!(e.Source is TabItem source) || Mouse.PrimaryDevice.LeftButton != MouseButtonState.Pressed)
                return;
            int num = (int)DragDrop.DoDragDrop((DependencyObject)source, (object)source, DragDropEffects.All);
        }

        private void TabItem_Drop(object sender, DragEventArgs e)
        {
            if (!(e.Source is TabItem source) || !(e.Data.GetData(typeof(TabItem)) is TabItem data) || source.Equals((object)data))
                return;
            TabControl parent = source.Parent as TabControl;
            parent.Items.IndexOf((object)data);
            int insertIndex = parent.Items.IndexOf((object)source);
            parent.Items.Remove((object)data);
            parent.Items.Insert(insertIndex, (object)data);
            parent.SelectedItem = (object)data;


            SaveTabInfo(parent.Items);
            //초기화
            //this.model.USERINFO.TAB_INFO_LIST.Clear();
            //int seq = 0;
            //foreach(TabItem item in parent.Items)
            //{
            //    this.model.USERINFO.TAB_INFO_LIST.Add(new TabInfo_INOUT() { TAB_NAME = item.Tag.ToString(), SEQ = seq }) ;
            //    seq++;
            //}
            //this.model.SaveUserInfo();
        }

        private void tabMain_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (!(e.Source is TabControl) || !(this.tabMain.SelectedItem is TabItem selectedItem))
                return;
           
            if (e.RemovedItems.Count > 0 && e.RemovedItems[0] is TabItem)
            {
                this.PREV_TAB = (TabItem)e.RemovedItems[0];
                //if (((ContentControl)e.RemovedItems[0]).Content is UCBase content)
                //{
                //    bool? isChecked = this.rdoDev.IsChecked;
                //    bool flag = true;
                //    content.DB = !(isChecked.GetValueOrDefault() == flag & isChecked.HasValue) ? 2 : 1;
                //}
            }
            //if (!(selectedItem.Content is UCBase content1))
            //    return;
            //if (content1.DB == 0)
            //    content1.DB = 1;
            //if (content1.DB == 1)
            //    this.rdoDev.IsChecked = new bool?(true);
            //else if (content1.DB == 2)
            //    this.rdoApp.IsChecked = new bool?(true);
        }
        private void SaveTabInfo(ItemCollection Items)
        {
            //초기화
            this.model.USERINFO.TAB_INFO_LIST.Clear();
            int seq = 0;
            foreach (TabItem item in Items)
            {
                this.model.USERINFO.TAB_INFO_LIST.Add(new TabInfo_INOUT() { TAB_NAME = item.Tag.ToString(), SEQ = seq });
                seq++;
            }
            this.model.SaveUserInfo();
        }
        private void Window_PreviewMouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.ChangedButton != MouseButton.XButton1 || this.PREV_TAB == null)
                return;
            this.tabMain.SelectedItem = (object)this.PREV_TAB;
        }
        private TabItem GetTargetTabItem(object originalSource)
        {
            var current = originalSource as DependencyObject;

            while (current != null)
            {
                var tabItem = current as TabItem;
                if (tabItem != null)
                {
                    return tabItem;
                }

                current = VisualTreeHelper.GetParent(current);
            }

            return null;
        }

        private void btnDefault_Click(object sender, RoutedEventArgs e)
        {
            tabMain.Items.Cast<TabItem>().ToList().ForEach(x => tabMain.Items.Remove(x));
            this.AddTab("tiTableInfo");
            this.AddTab("tiCodeGenerater");
            this.AddTab("tiSourceGenerater");
            this.AddTab("tiEqsDbSource");
            this.AddTab("tiDBSourceFinder");
            this.AddTab("tiCommonCode");
            this.AddTab("tiCodeReOrder");
            this.AddTab("tiMeta");
            this.AddTab("tiFavQuery");
            this.AddTab("tiFavMemo");
            this.AddTab("tiEamInfo");
            this.AddTab("tiUserInfo");
            this.AddTab("tiCalMemo");
            this.AddTab("tiSetting");
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            this.YES_NO = "Y";
        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            this.YES_NO = "N";
        }

        private void btnPopup_Click(object sender, RoutedEventArgs e)
        {

            TabItem item = tabMain.SelectedItem as TabItem;
            OpenTabPopup(item);
        }
        private void OpenTabPopup(TabItem item)
        {
            using (MainWindow pop = new MainWindow(item.Content.ToString(), item.Header.ToString()))
            {
                pop.Owner = this.Parent as Window;
                pop.WindowStartupLocation = WindowStartupLocation.CenterScreen;
                pop.Show();                
            }
        }
        public void Dispose()
        {            
        }

        private void tabMain_MouseRightButtonUp(object sender, MouseButtonEventArgs e)
        {
            try
            {
                if ((e.OriginalSource as TextBlock) == null)
                    return;
                TabItem tab = (e.OriginalSource as TextBlock).TemplatedParent as TabItem;
                if (tab == null)
                    return;

                OpenTabPopup(tab);
            }
            catch (Exception ex)
            {
                this.ShowErrorMsgBox(ex.ToString());
            }
        }
     
    }
}
