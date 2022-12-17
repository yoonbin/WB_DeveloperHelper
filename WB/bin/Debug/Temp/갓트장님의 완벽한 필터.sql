CollectionView view;  --생성자 위에 작성 (아무곳에 적어도 됨)

--생성자 안에 작성
this.dgdFavQuery.ItemsSource = this.OcFavQuery;
            view = (CollectionView)CollectionViewSource.GetDefaultView(dgdFavQuery.ItemsSource);
            view.Filter = UserFilter;




--메서드
private bool UserFilter(object item)
        {
            var data = item as FavQuery;
            bool result = false;


            if (String.IsNullOrEmpty(txtKeyword.Text))
                return true;
            else
            {

                string[] arrKeyword = txtKeyword.Text.Split(',');

                foreach (var str in arrKeyword)
                {
                    if (string.IsNullOrEmpty(str)) continue;

                    result =
                        (
                               (this.NVL(data.QUERY_NAME, "").IndexOf(str, StringComparison.OrdinalIgnoreCase) >= 0)
                       );


                    if (result == false) return false; //&& 조건으로 모두 충족해야 true 리턴함.
                }
            }


            return result;
        }


--텍스트 체인지 이벤트 
private void TxtKeyword_TextChanged(object sender, TextChangedEventArgs e)
        {
            CollectionViewSource.GetDefaultView(dgdFavQuery.ItemsSource).Refresh();
        }