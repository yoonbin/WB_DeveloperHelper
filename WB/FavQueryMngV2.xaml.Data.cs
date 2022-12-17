using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;
using System.Xml.Serialization;
using WB.Common;
using WB.DAC;
using WB.DTO;

namespace WB
{
    public class FavQueryMngV2Data : ViewModelBase
    {
        #region [dac]
        //FavQueryMngV2DL dac = new FavQueryMngV2DL();
        #endregion
        #region [Constructor]
        public FavQueryMngV2Data()
        {
            if (LicenseManager.UsageMode == LicenseUsageMode.Designtime) return;
            this.Init();
        }
        #endregion
        #region [View Property]
        private string categroy_text;
        /// <summary>
        /// 
        /// </summary>
        public string CATEGROY_TEXT
        {
            get { return this.categroy_text; }
            set { if (this.categroy_text != value) { this.categroy_text = value; OnPropertyChanged("CATEGROY_TEXT", value); } }
        }


        #endregion
        #region [Member Property]
        public FavQueryMngV2 thisWindow;

        private FavQuery ocfavquery_sel;
        /// <summary>
        /// 
        /// </summary>
        public FavQuery OCFAVQUERY_SEL
        {
            get { return this.ocfavquery_sel; }
            set { if (this.ocfavquery_sel != value) { this.ocfavquery_sel = value; OnPropertyChanged("OCFAVQUERY_SEL", value); } }
        }


        private ObservableCollection<FavQuery> ocFavQuery = new ObservableCollection<FavQuery>();       
        /// <summary>
        /// 
        /// </summary>
        public ObservableCollection<FavQuery> OcFavQuery
        {
            get { return this.ocFavQuery; }
            set { if (this.ocFavQuery != value) { this.ocFavQuery = value; OnPropertyChanged("OcFavQuery", value); } }
        }
       
        #endregion
        #region [Command]
        private ICommand onGroupingCommand;
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-15
        /// update date  : 2022-11-15
        /// </summary>
        /// <remarks></remarks>
        public ICommand OnGroupingCommand
        {
            get
            {
                if (onGroupingCommand == null)
                    onGroupingCommand = new RelayCommand(p => this.OnGrouping(p));
                return onGroupingCommand;
            }
        }
        private ICommand saveCategoryCommand;
        /// <summary>
        /// name         : 카테고리 저장
        /// desc         : 카테고리 저장
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-15
        /// update date  : 2022-11-15
        /// </summary>
        /// <remarks></remarks>
        public ICommand SaveCategoryCommand
        {
            get
            {
                if (saveCategoryCommand == null)
                    saveCategoryCommand = new RelayCommand(p => this.SaveCategory(p));
                return saveCategoryCommand;
            }
        }
        private ICommand deleteCategoryCommand;
        /// <summary>
        /// name         : 카테고리 삭제
        /// desc         : 카테고리 삭제
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-15
        /// update date  : 2022-11-15
        /// </summary>
        /// <remarks></remarks>
        public ICommand DeleteCategoryCommand
        {
            get
            {
                if (deleteCategoryCommand == null)
                    deleteCategoryCommand = new RelayCommand(p => this.DeleteCategory(p));
                return deleteCategoryCommand;
            }
        }
        private ICommand updateCategoryCommand;
        /// <summary>
        /// name         : 카테고리 수정
        /// desc         : 카테고리 수정
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-15
        /// update date  : 2022-11-15
        /// </summary>
        /// <remarks></remarks>
        public ICommand UpdateCategoryCommand
        {
            get
            {
                if (updateCategoryCommand == null)
                    updateCategoryCommand = new RelayCommand(p => this.UpdateCategory(p));
                return updateCategoryCommand;
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
        }
        /// <summary>
        /// name         : 
        /// desc         : 
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-15
        /// update date  : 2022-11-15
        /// </summary>
        /// <remarks></remarks>
        private void OnGrouping(object p)
        {
            if (thisWindow.dgrdQuery.SelectedItems.Count <= 0) return;
            if (p is null) return;
            string cat = p.ToString();
            IList<FavQuery> list = thisWindow.dgrdQuery.SelectedItems.Cast<FavQuery>().ToList();

            foreach(FavQuery item in list)
            {
                item.GROUP = cat;
            }
            this.thisWindow.SaveButton();
            this.thisWindow.ReLoad();
        }
        /// <summary>
        /// name         : 카테고리 추가
        /// desc         : 카테고리 추가
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-15
        /// update date  : 2022-11-15
        /// </summary>
        /// <remarks></remarks>
        private void SaveCategory(object p)
        {
            if (string.IsNullOrEmpty(CATEGROY_TEXT) && p is string)
            {
                if (USERINFO.CATEGORY.Where(d => d.CATEGORY == p.ToString()).Count() > 0)
                {
                    //thisWindow.ShowMsgBox("이미 등록된 카테고리입니다.", 1000);
                    return;
                }
                USERINFO.CATEGORY.Add(new Category_INOUT() { CATEGORY = p.ToString() });
                this.USERINFO.CATEGORY = this.USERINFO.CATEGORY.Distinct().ToList();
                this.SaveUserInfo();
                CATEGROY_TEXT = "";
            }
            else if(!string.IsNullOrEmpty(CATEGROY_TEXT))
            {
                if (USERINFO.CATEGORY.Where(d => d.CATEGORY == CATEGROY_TEXT).Count() > 0)
                {
                    thisWindow.ShowMsgBox("이미 등록된 카테고리입니다.", 1000);
                    return;
                }
                USERINFO.CATEGORY.Add(new Category_INOUT() { CATEGORY = CATEGROY_TEXT });
                this.USERINFO.CATEGORY = this.USERINFO.CATEGORY.Distinct().ToList();
                this.SaveUserInfo();
                CATEGROY_TEXT = "";
            }
            else
                return;

            

        }
        /// <summary>
        /// name         : 카테고리 삭제
        /// desc         : 카테고리 삭제
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-15
        /// update date  : 2022-11-15
        /// </summary>
        /// <remarks></remarks>
        private void DeleteCategory(object p)
        {
            if (p is null) return;
            ((DataGrid)p).SelectedItems.Cast<Category_INOUT>().ToList().ForEach(x => { this.USERINFO.CATEGORY.Remove(x); });
            this.USERINFO.CATEGORY = this.USERINFO.CATEGORY.Distinct().ToList();
            this.SaveUserInfo();
        }
        /// <summary>
        /// name         : 카테고리 수정
        /// desc         : 카테고리 수정
        /// author       : ezCaretech 오원빈
        /// create date  : 2022-11-15
        /// update date  : 2022-11-15
        /// </summary>
        /// <remarks></remarks>
        private void UpdateCategory(object p)
        {
            if (p is null) return;
            Category_INOUT selectedItem = (p as DataGrid).SelectedItem as Category_INOUT;
            try
            {
                if(!string.IsNullOrEmpty(this.CATEGROY_TEXT))
                    selectedItem.CATEGORY = this.CATEGROY_TEXT;
                this.USERINFO.CATEGORY.Where(d=>!string.IsNullOrEmpty(d.OLD_CATEGORY)).ToList().ForEach(x => this.OcFavQuery.ToList().ForEach(d => d.GROUP = !string.IsNullOrEmpty(d.GROUP) && d.GROUP.IndexOf(x.OLD_CATEGORY) == 0 ? x.CATEGORY : d.GROUP));
                
                this.SaveUserInfo();
                this.thisWindow.SaveButton();
                this.thisWindow.ReLoad();
                this.thisWindow.txtSearchQuery.Text = CATEGROY_TEXT;
                CATEGROY_TEXT = "";
            }
            catch(Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
        #endregion
    }
}
