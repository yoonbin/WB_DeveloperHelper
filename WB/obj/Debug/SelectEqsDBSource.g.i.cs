#pragma checksum "..\..\SelectEqsDBSource.xaml" "{8829d00f-11b8-4213-878b-770e8597ac16}" "260FFA1986E8AACB9E8D93F451ADA89C808EE858A57EB63AD21900361B3FC94E"
//------------------------------------------------------------------------------
// <auto-generated>
//     이 코드는 도구를 사용하여 생성되었습니다.
//     런타임 버전:4.0.30319.42000
//
//     파일 내용을 변경하면 잘못된 동작이 발생할 수 있으며, 코드를 다시 생성하면
//     이러한 변경 내용이 손실됩니다.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Diagnostics;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Forms;
using System.Windows.Forms.Integration;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Interactivity;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Effects;
using System.Windows.Media.Imaging;
using System.Windows.Media.Media3D;
using System.Windows.Media.TextFormatting;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Shell;
using WB;
using WB.Common;
using WB.UC;


namespace WB {
    
    
    /// <summary>
    /// SelectEqsDBSource
    /// </summary>
    public partial class SelectEqsDBSource : WB.UC.UCBase, System.Windows.Markup.IComponentConnector {
        
        
        #line 25 "..\..\SelectEqsDBSource.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Grid grdMain;
        
        #line default
        #line hidden
        
        
        #line 39 "..\..\SelectEqsDBSource.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button btnGolden;
        
        #line default
        #line hidden
        
        
        #line 40 "..\..\SelectEqsDBSource.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal System.Windows.Controls.Button btnPlEdit;
        
        #line default
        #line hidden
        
        
        #line 51 "..\..\SelectEqsDBSource.xaml"
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1823:AvoidUnusedPrivateFields")]
        internal WB.SelectMyMemo txtCode;
        
        #line default
        #line hidden
        
        private bool _contentLoaded;
        
        /// <summary>
        /// InitializeComponent
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        public void InitializeComponent() {
            if (_contentLoaded) {
                return;
            }
            _contentLoaded = true;
            System.Uri resourceLocater = new System.Uri("/WB;component/selecteqsdbsource.xaml", System.UriKind.Relative);
            
            #line 1 "..\..\SelectEqsDBSource.xaml"
            System.Windows.Application.LoadComponent(this, resourceLocater);
            
            #line default
            #line hidden
        }
        
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
        internal System.Delegate _CreateDelegate(System.Type delegateType, string handler) {
            return System.Delegate.CreateDelegate(delegateType, this, handler);
        }
        
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.CodeDom.Compiler.GeneratedCodeAttribute("PresentationBuildTasks", "4.0.0.0")]
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Never)]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1800:DoNotCastUnnecessarily")]
        void System.Windows.Markup.IComponentConnector.Connect(int connectionId, object target) {
            switch (connectionId)
            {
            case 1:
            this.grdMain = ((System.Windows.Controls.Grid)(target));
            return;
            case 2:
            
            #line 38 "..\..\SelectEqsDBSource.xaml"
            ((System.Windows.Controls.TextBox)(target)).KeyDown += new System.Windows.Input.KeyEventHandler(this.TextBox_KeyDown);
            
            #line default
            #line hidden
            return;
            case 3:
            this.btnGolden = ((System.Windows.Controls.Button)(target));
            
            #line 39 "..\..\SelectEqsDBSource.xaml"
            this.btnGolden.Click += new System.Windows.RoutedEventHandler(this.btnGolden_Click);
            
            #line default
            #line hidden
            return;
            case 4:
            this.btnPlEdit = ((System.Windows.Controls.Button)(target));
            
            #line 40 "..\..\SelectEqsDBSource.xaml"
            this.btnPlEdit.Click += new System.Windows.RoutedEventHandler(this.btnPlEdit_Click);
            
            #line default
            #line hidden
            return;
            case 5:
            this.txtCode = ((WB.SelectMyMemo)(target));
            return;
            case 6:
            
            #line 54 "..\..\SelectEqsDBSource.xaml"
            ((System.Windows.Controls.GridSplitter)(target)).PreviewMouseDoubleClick += new System.Windows.Input.MouseButtonEventHandler(this.GridSplitter_MouseDoubleClick);
            
            #line default
            #line hidden
            return;
            }
            this._contentLoaded = true;
        }
    }
}

