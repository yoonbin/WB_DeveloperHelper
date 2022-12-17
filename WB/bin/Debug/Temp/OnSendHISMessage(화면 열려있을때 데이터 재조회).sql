//OnSendHISMessage  --메세지를 보내는 부분으로 해당 메뉴가 이미 열려있을 경우 메뉴아이디와 파라미터를 HashTable 형식으로 넘겨준다.
/// <summary>
        /// name         : 검사의뢰서 조회
        /// desc         : 검사의뢰서 조회
        /// author       : 오원빈
        /// create date  : 2021-11-01
        /// update date  : 2021-11-01
        /// </summary>
        /// <remarks></remarks>
        private void PopupExmForm(object p)
        {
            if (SELECTORDERPRESCRIPTION_SEL == null) return;
              
            string menu_id = "RM_POPUP_SelectExaminationReferralForm";
            if (DoYouHaveTheMenu(menu_id) == true)
            {
                List<string> targetList = new List<string>();
                targetList.Add(menu_id);
                Hashtable message = new Hashtable();
                message.Add("MENU_ID", menu_id);                
                message.Add("PT_NO", SELECTORDERPRESCRIPTION_SEL.PT_NO);
                message.Add("ORD_DT", SELECTORDERPRESCRIPTION_SEL.ORD_DT);
                message.Add("ORD_CD", SELECTORDERPRESCRIPTION_SEL.ORD_CD);
                message.Add("MDFM_ID", Convert.ToDecimal(SELECTORDERPRESCRIPTION_SEL.MDFM_ID));
                message.Add("IPPR_ID", SELECTORDERPRESCRIPTION_SEL.IPPR_ID);

                this.OnSendHISMessage(targetList, message);
            }
            else
            {
                PopUpBase pop = this.OnLoadPopupMenu("RM_POPUP_SelectExaminationReferralForm", new object[] { SELECTORDERPRESCRIPTION_SEL.PT_NO, Convert.ToDateTime(SELECTORDERPRESCRIPTION_SEL.ORD_DT),
                    SELECTORDERPRESCRIPTION_SEL.ORD_CD, Convert.ToDecimal(SELECTORDERPRESCRIPTION_SEL.MDFM_ID), SELECTORDERPRESCRIPTION_SEL.IPPR_ID });
                pop.WindowStartupLocation = WindowStartupLocation.CenterScreen;
                pop.Topmost = true; //부모창 항상 위에
                pop.Show();
                pop.ShowInTaskbar = false;
              
            }
           
        }
//OnReceiveHISMessage  --메세지를 받는 부분으로, try,catch를 이용하여 null예외처리를 해준다. 넘겨받은 MENU_ID와 EAM의 MENU_ID가 같은 것이 있다면 조회 이벤트를 태운다. if문 안에는 상황에 맞춰 짤 수 있음.  
public override void OnReceiveHISMessage(Hashtable message)
        {
            foreach (DictionaryEntry entry in message)
            {
                if (string.Equals(entry.Key, this.EAM_INFO.MENU_CD) || string.Equals(entry.Key, "*"))
                {
                    HISMessageAgent agent = entry.Value as HISMessageAgent;
                    if (agent != null) agent.Invoke(this);
                }
            }
            //2022-04-09추가 , 검사의뢰서가 열려있을 때 바뀐 환자정보로 의뢰서 재조회
            try
            {
                if (message.ContainsKey("MENU_ID") && string.Equals(message["MENU_ID"].ToString(),this.EAM_INFO.MENU_CD))
                {
                    PreSetRefFormInfo(message["PT_NO"].ToString(), Convert.ToDateTime(message["ORD_DT"].ToString()), message["ORD_CD"].ToString(), Convert.ToDecimal(message["MDFM_ID"].ToString()), message["IPPR_ID"].ToString());
                    this.model.Search();
                }
            }
            catch { }
        }