   M S B A M L   `   `   `  ???? O  Kmscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e0891&clr-namespace:System;assembly=mscorlibSystem  = 9WB, Version=1.0.0.0, Culture=neutral, PublicKeyToken=nullclr-namespace:WBWB    WB.MainWindow   \ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     @d2http://schemas.microsoft.com/expression/blend/2008     Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     6sys&clr-namespace:System;assembly=mscorlib     "localclr-namespace:WB     -     ? WindowState$  	Maximized=? ? Title$ WB??$	??450??$	??800?? ? DataContext   WB.ViewModelBase   ? 	Resources ??%    .??? .+??? .@??? $
??META??.???  ? RowDefinitions ?? $??30 ??? $??* ? ? ColumnDefinitions ?? $??* ??? $??6* ?.+??? $??2?? ?? Orientation$ 
Horizontal=?.+??? $??	검색어??$??Center=?$??5,0,0,0q??? -    ??Name$ 	txtSearch??$	??100??$??Center=?$??5,0,0,0q? ?? CharacterCasing$ Upper=????? *META_SEARCH_IN.TEXT+	 ?? UpdateSourceTrigger$	 PropertyChanged=?
 ?? Mode$
 TwoWay=??? -    ??Name$ 	btnSearch??$??조회??$	??100??$??Center=?$??5,0,0,0q?&   System.Windows.Controls.DataGrid  -     Name$ dgrdDataWare??$??2??$??1??   AutoGenerateColumns .     CanUserAddRows .     
IsReadOnly . ???? *
METAGRID+$	 PropertyChanged=?$
 TwoWay=?   Columns 0  *System.Windows.Controls.DataGridTextColumn  ,  &System.Windows.Controls.DataGridColumn   Header$ 구분??1  +System.Windows.Controls.DataGridBoundColumn   Binding ?? *GBN+  $ 구분상세?? ?? *	GBN_DTL+  $ 	논리명?? ?? *
DIC_LOG_NM+  $ 	물리명?? ?? *
DIC_PHY_NM+  $ 내용?? ?? *DIC_PHY_FLL_NM+  $ 설명?? ?? *
DIC_DESC+  $ 데이터타입?? ?? *	DATA_TYPE+  $ 표준여부?? ?? *STANDARD_YN+  $ 도메인그룹?? ?? *
DOM_GRP_NM+?? $??MyQuery??.???  ?? $??30 ??? $??* ? ?? $??* ??? $??6* ?.+??? $??2??$ 
Horizontal=?.+??? $??	검색어??$??Center=?$??5,0,0,0q??? -   $ txtSearchQuery??$	??100??$??Center=?$??5,0,0,0q?  -   $ 	dgrdQuery??$??1??$   HorizontalScrollBarVisibility$ Disabled=? .   .  ???? *	QUERYGRID+$	 PropertyChanged=?$
 TwoWay=?   $ 
QUERY_NAME??   Width5  /System.Windows.Controls.DataGridLengthConverter$ *  ?? *
QUERY_NAME+   	CellStyle ??  ?? 
TargetType*  $System.Windows.Controls.DataGridCell"  .???  ?? Property ?@?ToolTip ?? Value ?? *
QUERY_NAME+??  ?@^?ShowDuration ?? MaxValue# Z ?? -   $ txtQuery??$??1??$??1?? ?? MaxLines$ 9999999?? ?? AcceptsReturn . 