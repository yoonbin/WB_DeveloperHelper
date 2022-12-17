using System;
using System.CodeDom.Compiler;
using System.Collections;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Markup;
using System.Xml;
using System.Xml.Serialization;
using WB.DTO;
using WB.UC;

namespace WB
{
    /// <summary>
    /// Setting.xaml에 대한 상호 작용 논리
    /// </summary>
    public partial class Setting : UCBase
    {
        public Setting()
        {
            InitializeComponent();

            //this.DataContext = (object)this;
            this.model = this.DataContext as ViewModelBase;
        }

        private ObservableCollection<BasicSetting> ocBasicSetting = new ObservableCollection<BasicSetting>();
        private ObservableCollection<DBUser> ocDBUser1 = new ObservableCollection<DBUser>();
        private ObservableCollection<DBUser> ocDBUser2 = new ObservableCollection<DBUser>();
        private ViewModelBase model;

        public ObservableCollection<BasicSetting> OcBasicSetting
        {
            get => this.ocBasicSetting;
            set => this.ocBasicSetting = value;
        }

        public ObservableCollection<DBUser> OcDBUser1
        {
            get => this.ocDBUser1;
            set => this.ocDBUser1 = value;
        }

        public ObservableCollection<DBUser> OcDBUser2
        {
            get => this.ocDBUser2;
            set => this.ocDBUser2 = value;
        }

        private void UCBase_Loaded(object sender, RoutedEventArgs e)
        {
            this.dgdBasicSetting.ItemsSource = (IEnumerable)this.OcBasicSetting;
            this.dgdDBUser1.ItemsSource = (IEnumerable)this.OcDBUser1;
            this.dgdDBUser2.ItemsSource = (IEnumerable)this.OcDBUser2;
            this.LoadBasicSetting();
            if (this.OcBasicSetting == null || this.OcBasicSetting.Count == 0)
            {
                this.OcBasicSetting = new ObservableCollection<BasicSetting>();
                this.SetDefaultBasicSetting();
                this.SaveBasicSetting(false);
            }
            if (this.OcBasicSetting.Where<BasicSetting>((Func<BasicSetting, bool>)(d => d.CODE == "BESTCareDevPath")).Count<BasicSetting>() == 0)
            {
                this.SetBESTCarePathSetting();
                this.SaveBasicSetting(false);
            }
            if (this.OcBasicSetting.Where<BasicSetting>((Func<BasicSetting, bool>)(d => d.CODE == "GoldenPath")).Count<BasicSetting>() == 0)
            {
                this.SetGoldenPathSetting();
                this.SaveBasicSetting(false);
            }
            this.LoadSettingDBInfo("DEV");
            this.LoadSettingDBInfo("APP");
        }
        private void SaveBasicSetting(bool isShowMsgBox)
        {
            string basicSettingFilePath = this.OwnerWindow.GetBasicSettingFilePath();
            using (StreamWriter streamWriter = new StreamWriter(basicSettingFilePath))
                new XmlSerializer(typeof(ObservableCollection<BasicSetting>)).Serialize((TextWriter)streamWriter, (object)this.OcBasicSetting);
            if (isShowMsgBox)
                this.OwnerWindow.ShowMsgBox("저장완료", 1000);
            this.OwnerWindow.GetBasicSetting();
            try
            {
                SetMetaConnectionString(this.MetaConnection.VALUE);
            }
            catch(Exception ex)
            {
                this.OwnerWindow.ShowErrorMsgBox(ex.ToString());
            }
        }
        private void SetDefaultBasicSetting()
        {
            this.OcBasicSetting.Add(new BasicSetting()
            {
                CODE = "UserName",
                PROPERTY = "사용자이름",
                VALUE = "ezCaretech 오원빈",
                REMARK = "소스코드의 Author"
            });
            this.OcBasicSetting.Add(new BasicSetting()
            {
                CODE = "MetaConnectionString",
                PROPERTY = "Meta# Connection String",
                VALUE = "Data Source=CNUHDEV;User Id=UDATAWARE;Password=dataware;Integrated Security=no",
                REMARK = "Meta#정보 연동을 위해 필요함"
            });
        }

        private void SetBESTCarePathSetting()
        {
            this.OcBasicSetting.Add(new BasicSetting()
            {
                CODE = "BESTCareDevPath",
                PROPERTY = "BESTCare Dev 경로",
                VALUE = "C:\\BESTCare\\CNUH\\HISDEV",
                REMARK = "EAM탭에서 화면보기시 사용"
            });
            this.OcBasicSetting.Add(new BasicSetting()
            {
                CODE = "BESTCareStgPath",
                PROPERTY = "BESTCare Stg 경로",
                VALUE = "C:\\BESTCare\\CNUH\\HISSTG",
                REMARK = "EAM탭에서 화면보기시 사용"
            });
            this.OcBasicSetting.Add(new BasicSetting()
            {
                CODE = "BESTCareProdPath",
                PROPERTY = "BESTCare Prod 경로",
                VALUE = "C:\\BESTCare\\CNUH\\HIS",
                REMARK = "EAM탭에서 화면보기시 사용"
            });
        }

        private void SetGoldenPathSetting()
        {
            this.OcBasicSetting.Add(new BasicSetting()
            {
                CODE = "GoldenPath",
                PROPERTY = "Golden 경로",
                VALUE = "C:\\Program Files (x86)\\Benthic\\Golden6.exe",
                REMARK = "EQS/DB Object 소스보기시 사용"
            });
            this.OcBasicSetting.Add(new BasicSetting()
            {
                CODE = "PLEditPath",
                PROPERTY = "PLEdit 경로",
                VALUE = "C:\\Program Files (x86)\\Benthic\\PLEdit32.exe",
                REMARK = "EQS/DB Object 소스보기시 사용"
            });
        }

        private void LoadSettingDBInfo(string dbGbn)
        {
            string infoSettingFilePath = this.OwnerWindow.GetDBInfoSettingFilePath(dbGbn);
            if (!File.Exists(infoSettingFilePath))
                return;
            XmlSerializer xmlSerializer = new XmlSerializer(typeof(ObservableCollection<DBUser>));
            ObservableCollection<DBUser> observableCollection1 = (ObservableCollection<DBUser>)null;
            using (StreamReader streamReader = new StreamReader(infoSettingFilePath))
                observableCollection1 = xmlSerializer.Deserialize((TextReader)streamReader) as ObservableCollection<DBUser>;
            ObservableCollection<DBUser> observableCollection2 = !(dbGbn == "DEV") ? this.OcDBUser2 : this.OcDBUser1;
            observableCollection2.Clear();
            foreach (DBUser dbUser in (Collection<DBUser>)observableCollection1)
                observableCollection2.Add(dbUser);
        }

        public void LoadBasicSetting()
        {
            string basicSettingFilePath = this.OwnerWindow.GetBasicSettingFilePath();
            if (!File.Exists(basicSettingFilePath))
                return;
            try
            {
                XmlSerializer xmlSerializer = new XmlSerializer(typeof(ObservableCollection<BasicSetting>));

                ObservableCollection<BasicSetting> observableCollection = (ObservableCollection<BasicSetting>)null;

                using (StreamReader streamReader = new StreamReader(basicSettingFilePath))
                    observableCollection = xmlSerializer.Deserialize((TextReader)streamReader) as ObservableCollection<BasicSetting>;

                this.OcBasicSetting.Clear();

                foreach (BasicSetting basicSetting in (Collection<BasicSetting>)observableCollection)
                    this.OcBasicSetting.Add(basicSetting);
            }
            catch(Exception)
            {

            }
        }
        private void BtnSave_Click(object sender, RoutedEventArgs e)
        {
        }

        private void BtnAdd1_Click(object sender, RoutedEventArgs e)
        {
            this.OcDBUser1.Add(new DBUser()
            {                
                CONNECT_STRING = "Data Source=ESMARTPROD;User Id=xsup;Password=!cnsupn2022);Integrated Security=no"
            }) ;         
        }

        private void BtnAdd2_Click(object sender, RoutedEventArgs e)
        {            
            this.OcDBUser2.Add(new DBUser()
            {             
                CONNECT_STRING = "Data Source=CNUHSTG;User Id=xsup;Password=ez123;Integrated Security=no"
            });
        }
        private void BtnAdd_Click(object sender,RoutedEventArgs e)
        {
            this.OcDBUser1.Add(new DBUser()
            {             
                USER_NAME = "PROD",
                CONNECT_STRING = "Data Source=ESMARTPROD;User Id=xsup;Password=!cnsupn2022);Integrated Security=no"
            });
            this.OcDBUser2.Add(new DBUser()
            {
                USER_NAME = "STG",
                CONNECT_STRING = "Data Source=CNUHSTG;User Id=xsup;Password=ez123;Integrated Security=no"
            });
        }
        private void BtnDelete1_Click(object sender, RoutedEventArgs e)
        {
            if (this.dgdDBUser1.SelectedItem == null)
                return;
            this.OcDBUser1.Remove((DBUser)this.dgdDBUser1.SelectedItem);
        }

        private void BtnDelete2_Click(object sender, RoutedEventArgs e)
        {
            if (this.dgdDBUser2.SelectedItem == null)
                return;
            this.OcDBUser2.Remove((DBUser)this.dgdDBUser2.SelectedItem);
        }
        private void BtnDelete_Click(object sender,RoutedEventArgs e)
        {
            if (this.dgdDBUser1.SelectedItem == null)
                return;
            this.OcDBUser1.Remove((DBUser)this.dgdDBUser1.SelectedItem);

            if (this.dgdDBUser2.SelectedItem == null)
                return;
            this.OcDBUser2.Remove((DBUser)this.dgdDBUser2.SelectedItem);
        }
        private void BtnSave0_Click(object sender, RoutedEventArgs e) => this.SaveBasicSetting(true);

        private void BtnSave1_Click(object sender, RoutedEventArgs e) => this.SaveSettingDBInfo("DEV");

        private void BtnSave2_Click(object sender, RoutedEventArgs e) => this.SaveSettingDBInfo("APP");

        private void BtnSaveTotal_Click(object sender,RoutedEventArgs e)
        {
            this.SaveSettingDBInfo("DEV");
            this.SaveSettingDBInfo("APP");
        }
        private void SaveSettingDBInfo(string dbGbn)
        {
            string infoSettingFilePath = this.OwnerWindow.GetDBInfoSettingFilePath(dbGbn);
            XmlSerializer xmlSerializer = new XmlSerializer(typeof(ObservableCollection<DBUser>));
            using (StreamWriter streamWriter = new StreamWriter(infoSettingFilePath))
            {
                if (dbGbn == "DEV")
                    xmlSerializer.Serialize((TextWriter)streamWriter, (object)this.OcDBUser1);
                else
                    xmlSerializer.Serialize((TextWriter)streamWriter, (object)this.OcDBUser2);
                streamWriter.Close();
            }
            if (dbGbn == "DEV")
                this.OwnerWindow.GetDB1User();
            else
                this.OwnerWindow.GetDB2User();
            this.OwnerWindow.ShowMsgBox("저장완료", 1000);
        }

        private void SetMetaConnectionString(string connStr)
        {
            string filename = string.Format(".\\MetaSqlMap.config");
            XmlDocument xmlDocument = new XmlDocument();
            xmlDocument.Load(filename);
            string str = xmlDocument.ChildNodes[1]["database"]["dataSource"].Attributes["connectionString"].Value = connStr;
            xmlDocument.Save(filename);
        }

    }
}
