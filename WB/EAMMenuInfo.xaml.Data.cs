using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using WB.Common;
using WB.DAC;
using WB.DTO;
using System.IO;
using System.Xml.Serialization;
using System.Diagnostics;
using System.Collections.ObjectModel;
using System.Windows.Controls;
using System.Collections;
using System.Windows;
using System.Windows.Data;

namespace WB
{
    public class EAMMenuInfoData : ViewModelBase
    {
        #region [dac]
        EAMMenuInfoDL dac = new EAMMenuInfoDL();
        #endregion
        #region [Constructor]
        public EAMMenuInfoData()
        {
            if (LicenseManager.UsageMode == LicenseUsageMode.Designtime) return;
            this.Init();
        }
        #endregion
        
        public EAMMenuInfo thisWindow;
        #region [View Property]
        private DataGridSelectionUnit selection_unit;
        /// <summary>
        /// 
        /// </summary>
        public DataGridSelectionUnit SELECTION_UNIT
        {
            get { return this.selection_unit; }
            set { if (this.selection_unit != value) { this.selection_unit = value; OnPropertyChanged("SELECTION_UNIT", value); } }
        }




        private ICollectionView view;
        /// <summary>
        /// 
        /// </summary>
        public ICollectionView VIEW
        {
            get { return this.view; }
            set { if (this.view != value) { this.view = value; OnPropertyChanged("VIEW", value); } }
        }


        private string menu_search_text;
        /// <summary>
        /// 
        /// </summary>
        public string MENU_SEARCH_TEXT
        {
            get { return this.menu_search_text; }
            set { if (this.menu_search_text != value) { this.menu_search_text = value; OnPropertyChanged("MENU_SEARCH_TEXT", value); } }
        }


        private string assembly_nm;
        /// <summary>
        /// 
        /// </summary>
        public string ASSEMBLY_NM
        {
            get { return this.assembly_nm; }
            set { if (this.assembly_nm != value) { this.assembly_nm = value; OnPropertyChanged("ASSEMBLY_NM", value); } }
        }

        private string app_url;
        /// <summary>
        /// 
        /// </summary>
        public string APP_URL
        {
            get { return this.app_url; }
            set { if (this.app_url != value) { this.app_url = value; OnPropertyChanged("APP_URL", value); } }
        }

        private string menu_nm;
        /// <summary>
        /// 메뉴명
        /// </summary>
        public string MENU_NM
        {
            get { return this.menu_nm; }
            set { if (this.menu_nm != value) { this.menu_nm = value; OnPropertyChanged("MENU_NM", value); } }
        }


        private string sel_hsp_tp_cd_radio;
        /// <summary>
        /// 
        /// </summary>
        public string SEL_HSP_TP_CD_RADIO
        {
            get { return this.sel_hsp_tp_cd_radio; }
            set { if (this.sel_hsp_tp_cd_radio != value) { this.sel_hsp_tp_cd_radio = value; OnPropertyChanged("SEL_HSP_TP_CD_RADIO", value); } }
        }


        private string serach_menu_text;
        /// <summary>
        /// 
        /// </summary>
        public string SERACH_MENU_TEXT
        {
            get { return this.serach_menu_text; }
            set { if (this.serach_menu_text != value) { this.serach_menu_text = value; OnPropertyChanged("SERACH_MENU_TEXT", value); } }
        }
        private string user_id = "CCC0EMR";
        /// <summary>
        /// 
        /// </summary>
        public string USER_ID
        {
            get { return this.user_id; }
            set { if (this.user_id != value) { this.user_id = value; OnPropertyChanged("USER_ID", value); } }
        }

        private string pt_no = "";
        /// <summary>
        /// 환자번호
        /// </summary>
        public string PT_NO
        {
            get { return this.pt_no; }
            set { if (this.pt_no != value) { this.pt_no = value; OnPropertyChanged("PT_NO", value); } }
        }

        private string sel_db_gubn;
        /// <summary>
        /// 
        /// </summary>
        public string SEL_DB_GUBN
        {
            get { return this.sel_db_gubn; }
            set { if (this.sel_db_gubn != value) { this.sel_db_gubn = value; OnPropertyChanged("SEL_DB_GUBN", value); } }
        }



        #endregion
        #region [Member Property]
        private EAMMenuInfo_INOUT faveam_sel;
        /// <summary>
        /// name         :  선택 DTO
        /// desc         :  선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-04
        /// update date  : 2022-11-04
        /// </summary>
        /// <remarks></remarks>
        public EAMMenuInfo_INOUT FAVEAM_SEL
        {
            get { return this.faveam_sel; }
            set { if (this.faveam_sel != value) { this.faveam_sel = value; OnPropertyChanged("FAVEAM_SEL", value); } }
        }



        private List<EAMMenuInfo_INOUT> faveam_list;
        /// <summary>
        /// name         :  리스트
        /// desc         :  리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-04
        /// update date  : 2022-11-04
        /// </summary>
        /// <remarks></remarks>
        public List<EAMMenuInfo_INOUT> FAVEAM_LIST
        {
            get { return this.faveam_list; }
            set { if (this.faveam_list != value) { this.faveam_list = value; OnPropertyChanged("FAVEAM_LIST", value); } }
        }


        

        private EAMMenuInfo_INOUT eammenuinfo_sel;
        /// <summary>
        /// name         : EAM조회 선택 DTO
        /// desc         : EAM조회 선택 DTO
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-03
        /// update date  : 2022-11-03
        /// </summary>
        /// <remarks></remarks>
        public EAMMenuInfo_INOUT EAMMENUINFO_SEL
        {
            get { return this.eammenuinfo_sel; }
            set { if (this.eammenuinfo_sel != value) { this.eammenuinfo_sel = value; OnPropertyChanged("EAMMENUINFO_SEL", value); } }
        }



        private List<EAMMenuInfo_INOUT> eammenuinfo_list;
        /// <summary>
        /// name         : EAM조회 리스트
        /// desc         : EAM조회 리스트
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-03
        /// update date  : 2022-11-03
        /// </summary>
        /// <remarks></remarks>
        public List<EAMMenuInfo_INOUT> EAMMENUINFO_LIST
        {
            get { return this.eammenuinfo_list; }
            set { if (this.eammenuinfo_list != value) { this.eammenuinfo_list = value; OnPropertyChanged("EAMMENUINFO_LIST", value); } }
        }

        private ObservableCollection<BasicSetting> setting_list;
        /// <summary>
        /// 
        /// </summary>
        public ObservableCollection<BasicSetting> SETTING_LIST
        {
            get { return this.setting_list; }
            set { if (this.setting_list != value) { this.setting_list = value; OnPropertyChanged("SETTING_LIST", value); } }
        }


        #endregion
        #region [Command]
        private ICommand reFreshCommand;
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-14
        /// update date  : 2022-11-14
        /// </summary>
        /// <remarks></remarks>
        public ICommand ReFreshCommand
        {
            get
            {
                if (reFreshCommand == null)
                    reFreshCommand = new RelayCommand(p => this.ReFresh(p));
                return reFreshCommand;
            }
        }
        private ICommand dgrdSelectionChangedCommand;
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-08
        /// update date  : 2022-11-08
        /// </summary>
        /// <remarks></remarks>
        public ICommand DgrdSelectionChangedCommand
        {
            get
            {
                if (dgrdSelectionChangedCommand == null)
                    dgrdSelectionChangedCommand = new RelayCommand(p => this.DgrdSelectionChanged(p));
                return dgrdSelectionChangedCommand;
            }
        }
        private ICommand eAMMenuInfoCommand;
        /// <summary>
        /// name         : EAM조회
        /// desc         : EAM조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-03
        /// update date  : 2022-11-03
        /// </summary>
        /// <remarks></remarks>
        public ICommand EAMMenuInfoCommand
        {
            get
            {
                if (eAMMenuInfoCommand == null)
                    eAMMenuInfoCommand = new RelayCommand(p => this.EAMMenuInfo(p));
                return eAMMenuInfoCommand;
            }
        }
        private ICommand lostFocusCommand;
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-03
        /// update date  : 2022-11-03
        /// </summary>
        /// <remarks></remarks>
        public ICommand LostFocusCommand
        {
            get
            {
                if (lostFocusCommand == null)
                    lostFocusCommand = new RelayCommand(p => this.LostFocus(p));
                return lostFocusCommand;
            }
        }
        private ICommand hISCONNECTCommand;
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-03
        /// update date  : 2022-11-03
        /// </summary>
        /// <remarks></remarks>
        public ICommand HISCONNECTCommand
        {
            get
            {
                if (hISCONNECTCommand == null)
                    hISCONNECTCommand = new RelayCommand(p => this.HISCONNECT());
                return hISCONNECTCommand;
            }
        }
        private ICommand dB_SAVECommand;
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-04
        /// update date  : 2022-11-04
        /// </summary>
        /// <remarks></remarks>
        public ICommand DB_SAVECommand
        {
            get
            {
                if (dB_SAVECommand == null)
                    dB_SAVECommand = new RelayCommand(p => this.DB_SAVE(p));
                return dB_SAVECommand;
            }
        }
        private ICommand favEamSaveCommand;
        /// <summary>
        /// name         : 즐겨찾기 등록
        /// desc         : 즐겨찾기 등록
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-08
        /// update date  : 2022-11-08
        /// </summary>
        /// <remarks></remarks>
        public ICommand FavEamSaveCommand
        {
            get
            {
                if (favEamSaveCommand == null)
                    favEamSaveCommand = new RelayCommand(p => this.FavEamSave(p));
                return favEamSaveCommand;
            }
        }
        private ICommand favEamDeleteCommand;
        /// <summary>
        /// name         : 즐겨찾기 해제
        /// desc         : 즐겨찾기 해제
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-08
        /// update date  : 2022-11-08
        /// </summary>
        /// <remarks></remarks>
        public ICommand FavEamDeleteCommand
        {
            get
            {
                if (favEamDeleteCommand == null)
                    favEamDeleteCommand = new RelayCommand(p => this.FavEamDelete(p));
                return favEamDeleteCommand;
            }
        }

        private ICommand favSaveCommand;
        /// <summary>
        /// name         : EAM약어저장
        /// desc         : EAM약어저장
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-15
        /// update date  : 2022-11-15
        /// </summary>
        /// <remarks></remarks>
        public ICommand FavSaveCommand
        {
            get
            {
                if (favSaveCommand == null)
                    favSaveCommand = new RelayCommand(p => this.FavSave(p));
                return favSaveCommand;
            }
        }
        #endregion
        #region [Method]
        /// <summary>
        /// name         : ViewModel 초기화
        /// desc         : ViewModel을 초기화함
        /// author       : ohwonbin 
        /// create date  : 2022-07-11 오전 8:44:06
        /// update date  : 최종 수정 일자, 수정자, 수정개요 
        /// </summary>
        private void Init()
        {
            this.LoadUserInfo();

            this.USER_ID = string.IsNullOrEmpty(this.USERINFO.STF_NO) ? "CCC0EMR" : this.USERINFO.STF_NO;
            this.SEL_HSP_TP_CD_RADIO = string.IsNullOrEmpty(this.USERINFO.HSP_TP_CD) ? "01" : this.USERINFO.HSP_TP_CD;
            this.SEL_DB_GUBN = string.IsNullOrEmpty(this.USERINFO.DB_INFO) ? "DEV" : this.USERINFO.DB_INFO;

            if(USERINFO.FAVEAMINFO_LIST.Count > 0)
            {
                //데이터 필터부분.
                view = CollectionViewSource.GetDefaultView(USERINFO.FAVEAMINFO_LIST);
                view.Filter = CustomerFilter;
                this.view.GroupDescriptions.Clear(); //GROUP
                this.view.GroupDescriptions.Add(new PropertyGroupDescription("ABBR_NM"));  //GROUP
            }
         
        }
        /// <summary>
        /// 검색
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        private bool CustomerFilter(object item)
        {
            bool filter = true;
            if (string.IsNullOrEmpty(MENU_SEARCH_TEXT)) return filter;

            EAMMenuInfo_INOUT code_list = item as EAMMenuInfo_INOUT;
            code_list.ABBR_NM = string.IsNullOrEmpty(code_list.ABBR_NM) ? "" : code_list.ABBR_NM;
            if (!string.IsNullOrEmpty(MENU_SEARCH_TEXT) && !code_list.MENU_CD.ToUpper().Contains(MENU_SEARCH_TEXT.ToUpper()) && !code_list.MENU_NM.ToUpper().Contains(MENU_SEARCH_TEXT.ToUpper()) && !code_list.ASSEMBLY_NM.ToUpper().Contains(MENU_SEARCH_TEXT.ToUpper())
                && !code_list.ABBR_NM.ToUpper().Contains(MENU_SEARCH_TEXT.ToUpper()))
                filter = false;
            return filter;

        }
        public string GetFavEamPath()
        {
            string file_path = string.Format(@".\FavEam.xml");

            return file_path;
        }
        /// <summary>
        /// name         : EAM조회
        /// desc         : EAM조회
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-03
        /// update date  : 2022-11-03
        /// </summary>
        /// <remarks></remarks>
        private void EAMMenuInfo(object p)
        {
            EAMMenuInfo_INOUT param = new EAMMenuInfo_INOUT();
            param.MENU_CD = SERACH_MENU_TEXT;
            this.EAMMENUINFO_LIST = dac.EAMMenuInfo(param);
        }
       
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-03
        /// update date  : 2022-11-03
        /// </summary>
        /// <remarks></remarks>
        private void LostFocus(object p)
        {
            this.USERINFO.STF_NO = this.USER_ID.Trim();           
            SaveUserInfo();
        }

        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-03
        /// update date  : 2022-11-03
        /// </summary>
        /// <remarks></remarks>
        private void HISCONNECT()
        {            
            //var eam = this.EamInfo.Where(d => d.MENU_NO == btn.Tag.ToString()).FirstOrDefault();            
            if (EAMMENUINFO_SEL == null || string.IsNullOrEmpty(EAMMENUINFO_SEL.ASSEMBLY_NM)) return;
            if(string.IsNullOrWhiteSpace(USER_ID))
            {
                MessageBox.Show("ID를 입력해주세요.");
                return;
            }
            string pt_no =  string.IsNullOrEmpty(this.PT_NO) || this.PT_NO.Length < 8 ? "00000000" : this.PT_NO;

            if (thisWindow != null)
                SETTING_LIST = thisWindow.GetBasicSetting();
            string path = string.Empty;
            if (SETTING_LIST.Count > 0)
            {
                if (this.USERINFO.DB_INFO.Equals("PROD"))
                    path += this.SETTING_LIST.Where(d => d.CODE == "BESTCareProdPath").Select(d => d.VALUE).FirstOrDefault();
                else if (USERINFO.DB_INFO.Equals("STG"))
                    path += this.SETTING_LIST.Where(d => d.CODE == "BESTCareStgPath").Select(d => d.VALUE).FirstOrDefault();
                else if (USERINFO.DB_INFO.Equals("DEV"))
                    path += this.SETTING_LIST.Where(d => d.CODE == "BESTCareDevPath").Select(d => d.VALUE).FirstOrDefault();

                path += @"\BESTCareConnect.Start.exe";

            }
            else
            {             
                if (this.USERINFO.DB_INFO.Equals("PROD"))
                    path = @"C:\eSMART\HIS\BESTCareConnect.Start.exe";
                else if (USERINFO.DB_INFO.Equals("STG"))
                    path = @"C:\eSMART\HISSTG\BESTCareConnect.Start.exe";
                else if (USERINFO.DB_INFO.Equals("DEV"))
                    path = @"C:\eSMART\HISDEV\BESTCareConnect.Start.exe";
            }
            try
            {
                using (Process p = new Process())
                {
                    p.StartInfo.FileName = path;
                    p.StartInfo.Arguments = string.Format("{0} {1} {2} {3} {4} \"{5}[{6}][{7}]\"", USER_ID.Trim(), this.SEL_HSP_TP_CD_RADIO, pt_no, this.ASSEMBLY_NM, this.APP_URL.Replace("/", ""), this.MENU_NM.ToString(), SEL_HSP_TP_CD_RADIO, USERINFO.DB_INFO);
                    p.Start();
                }
            }
            catch(Exception ex)
            {
                thisWindow.ShowMsgBox("Setting 탭에서 BestCare경로를 확인해주세요.",3000);
            }
        }
        public string GetHspTpNm()
        {
            string str = "";
            switch (SEL_HSP_TP_CD_RADIO)
            {
                case "01": str = "학동";
                    break;
                case "02":
                    str = "화순";
                    break;
                case "03":
                    str = "빛고을";
                    break;
                case "04":
                    str = "치과";
                    break;

            }        
            return str;
        }
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-04
        /// update date  : 2022-11-04
        /// </summary>
        /// <remarks></remarks>
        private void DB_SAVE(object p)
        {
            this.USERINFO.DB_INFO = SEL_DB_GUBN;
            this.USERINFO.HSP_TP_CD = SEL_HSP_TP_CD_RADIO;
            this.SaveUserInfo();
        }

        private void LoadFavEamInfo()
        {
            string favQueryFilePath = this.GetFavEamPath();
            if (!File.Exists(favQueryFilePath))
                return;
            XmlSerializer xmlSerializer = new XmlSerializer(typeof(List<EAMMenuInfo_INOUT>));
            List<EAMMenuInfo_INOUT> observableCollection = (List<EAMMenuInfo_INOUT>)null;
            using (StreamReader streamReader = new StreamReader(favQueryFilePath))
            {
                //observableCollection = (ObservableCollection<FavQuery>)xmlSerializer.Deserialize(streamReader);
                observableCollection = xmlSerializer.Deserialize((TextReader)streamReader) as List<EAMMenuInfo_INOUT>;
            }
            if (this.FAVEAM_LIST == null)
                this.FAVEAM_LIST = new List<EAMMenuInfo_INOUT>();
            this.FAVEAM_LIST.Clear();
            foreach (EAMMenuInfo_INOUT favQuery in (List<EAMMenuInfo_INOUT>)observableCollection)
            {
                if (!this.FAVEAM_LIST.Contains(favQuery))
                    this.FAVEAM_LIST.Add(favQuery);
            }            
        }
        /// <summary>
        /// name         : 즐겨찾기 등록
        /// desc         : 즐겨찾기 등록
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-08
        /// update date  : 2022-11-08
        /// </summary>
        /// <remarks></remarks>
        private void FavEamSave(object p)
        {
            if (p is null) return;
            //List<EAMMenuInfo_INOUT> selectedItems = ((DataGrid)p).SelectedItems.Cast<EAMMenuInfo_INOUT>().ToList();
            IList selectedItems = this.ConvertCellToRow<EAMMenuInfo_INOUT>(((DataGrid)p).SelectedCells);
            if (selectedItems.Count <= 0) return;

            selectedItems.Cast<EAMMenuInfo_INOUT>().ToList().ForEach(x => { this.USERINFO.FAVEAMINFO_LIST.Add(x); });
            this.USERINFO.FAVEAMINFO_LIST = this.USERINFO.FAVEAMINFO_LIST.Distinct().ToList();
            this.SaveUserInfo();
            this.thisWindow.ShowMsgBox("저장되었습니다.", 1000);
            Init();
        }
        /// <summary>
        /// name         : 즐겨찾기 해제
        /// desc         : 즐겨찾기 해제
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-08
        /// update date  : 2022-11-08
        /// </summary>
        /// <remarks></remarks>
        private void FavEamDelete(object p)
        {
            if (p is null) return;
            //List<EAMMenuInfo_INOUT> selectedItems = ((DataGrid)p).SelectedItems.Cast<EAMMenuInfo_INOUT>().ToList();
            IList selectedItems = this.ConvertCellToRow<EAMMenuInfo_INOUT>(((DataGrid)p).SelectedCells);
            if (selectedItems.Count <= 0) return;
         
            selectedItems.Cast<EAMMenuInfo_INOUT>().ToList().ForEach(x => { this.USERINFO.FAVEAMINFO_LIST.Remove(x); });
            this.USERINFO.FAVEAMINFO_LIST = this.USERINFO.FAVEAMINFO_LIST.Distinct().ToList();
            this.SaveUserInfo();
            this.thisWindow.ShowMsgBox("저장되었습니다.", 1000);
            Init();
        }

        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-08
        /// update date  : 2022-11-08
        /// </summary>
        /// <remarks></remarks>
        private void DgrdSelectionChanged(object p)
        {
            EAMMenuInfo_INOUT selectedItem = this.ConvertCellToRow<EAMMenuInfo_INOUT>(((DataGrid)p).SelectedCells).FirstOrDefault();
            if (selectedItem == null) return;
            EAMMENUINFO_SEL = selectedItem;
            this.ASSEMBLY_NM = selectedItem.ASSEMBLY_NM;
            this.APP_URL = selectedItem.APP_URL;
            this.MENU_NM = selectedItem.MENU_NM;
        }

        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-14
        /// update date  : 2022-11-14
        /// </summary>
        /// <remarks></remarks>
        private void ReFresh(object p)
        {
            view.Refresh();
        }

        /// <summary>
        /// name         : EAM약어저장
        /// desc         : EAM약어저장
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-15
        /// update date  : 2022-11-15
        /// </summary>
        /// <remarks></remarks>
        private void FavSave(object p)
        {
            if (p is null) return;
            MENU_SEARCH_TEXT = "";
            List<EAMMenuInfo_INOUT> allItems = ((DataGrid)p).Items.Cast<EAMMenuInfo_INOUT>().ToList();
            if (allItems.Count <= 0) return;

            this.USERINFO.FAVEAMINFO_LIST.Clear();
            allItems.ForEach(x => x.ABBR_NM = string.IsNullOrEmpty(x.ABBR_NM) ? null : x.ABBR_NM);
            allItems.ForEach(x => {  this.USERINFO.FAVEAMINFO_LIST.Add(x); });
            this.USERINFO.FAVEAMINFO_LIST = this.USERINFO.FAVEAMINFO_LIST.Distinct().ToList();
            this.SaveUserInfo();
            Init();
            this.thisWindow.txtSearch2.Focus();

            this.thisWindow.ShowMsgBox("저장되었습니다.",1000);


        }
        #endregion
    }
}
