TRIGGER HSUP.TR_MSERMAMD 
AFTER INSERT OR UPDATE OR DELETE ON HSUP.MSERMAMD FOR EACH ROW

DECLARE

  WK_STF_NM  VARCHAR2(500) := '';
  WK_PGRM_NM VARCHAR2(500) := '';
  WK_IP_ADDR VARCHAR2(50)  := '';
  
BEGIN
    
    /**************************************************************************************************************************************************
    *    서비스이름  : TR_MSERMAMD_HISTORY
    *    최초 작성일 : 
    *    최초 작성자 : 
    *    DESCRIPTION : 진료재료정보 이력 테이블
    **************************************************************************************************************************************************/
    
    --시스템정보 조회..수작업 이력을 보기위함
   BEGIN
     SELECT /*+ XSUP.TR_MSERMRRD_HISTORY */
            SYS_CONTEXT('USERENV','IP_ADDRESS')
          , PROGRAM
          , SYS_CONTEXT('USERENV','HOST')
       INTO WK_IP_ADDR
          , WK_PGRM_NM
          , WK_STF_NM
       FROM V$SESSION
      WHERE AUDSID  = USERENV('SESSIONID')
        AND SID     = (SELECT SID FROM V$MYSTAT WHERE ROWNUM = 1) ;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
           WK_STF_NM  := '';
           WK_PGRM_NM := '';
           WK_IP_ADDR := '';
      WHEN OTHERS THEN
           NULL;
   END;                                                                                                 
   
   IF INSERTING THEN       
        BEGIN
            INSERT 
              INTO HSUP.MSERMAMH 
                 ( HSP_TP_CD                                                    --병원구분코드
                 , ORD_ID                                                       --처방ID
                 , SGL_MIF_CD                                                   --단일수가코드
                 , OAN_TP_CD                                                    --신구구분코드
                 , MIFI_TP_CD                                                   --수가보험구분코드                 
                 , WK_SEQ                                                       --작업순번
                 , CHG_TMST                                                     --변경타임
                 , HDWK_IP_ADDR                                                 --수작업IP주소     
                 , HDWK_PRGM_NM                                                 --수작업프로그램명
                 , HDWK_STF_NM                                                  --수작업직원명
                 , WK_CHG_TP_CD                                                 --작업변경구분코드
                 , RPY_ORD_ID                                                   --수납처방ID
                 , MTRL_MIF_CD                                                  --재료수가코드
                 , USE_QTY                                                      --사용수량
                 , RPY_USE_QTY                                                  --수납사용수량
                 , MED_DEPT_CD                                                  --진료부서코드
                 , ANDR_STF_NO                                                  --주치의직원번호
                 , ORD_DEPT_CD                                                  --처방부서코드
                 , PREQ_YN                                                      --구매요구여부
                 , EXM_IMPL_DT                                                  --검사시행일자
                 , PDA_PBL_YN                                                   --PDA발행여부
                 , ARCL_NO                                                      --물품번호
                 , ANMC_RSN_CD                                                  --임의비급여사유코드
                 , ANMC_RSN_ETC_CNTE                                            --임의비급여사유기타내용
                 , PACT_ID                                                      --원무접수ID
                 , PACT_TP_CD                                                   --원무접수구분코드
                 , RPY_PACT_TP_CD                                               --수납원무접수구분코드
                 , RPY_PACT_ID                                                  --수납원무접수ID
                 , RPY_CLS_SEQ                                                  --수납유형순번
                 , RPY_STS_CD                                                   --수납상태코드
                 , RTM_MED_DT                                                   --실시간진료일자
                 , RTM_MEDR_STF_NO                                              --실시간진료의직원번호
                 , RTM_MEDR_AADP_CD                                             --실시간진료의발령부서코드
                 , RTM_MEDR_WKDP_CD                                             --실시간진료의근무부서코드
                 , RTM_PBL_DTM                                                  --실시간발행일시
                 , RTM_PBL_STF_NO                                               --실시간발행직원번호
                 , RTM_PBR_AADP_CD                                              --실시간발행자발령부서코드
                 , RTM_PBR_WKDP_CD                                              --실시간발행자근무부서코드
                 , RTM_FMT_DTM                                                  --실시간수행일시
                 , RTM_FMT_STF_NO                                               --실시간수행직원번호
                 , RTM_FMPS_COAP_DEPT_CD                                        --실시간수행자비용적용부서코드
                 , RTM_FMPS_WKDP_CD                                             --실시간수행자근무부서코드
                 , RTM_FMCN_STF_NO                                              --실시간수행취소직원번호
                 , RTM_FMCN_DTM                                                 --실시간수행취소일시
                 , RTM_CLSN_STF_NO                                              --실시간마감직원번호
                 , RTM_CLSN_DT                                                  --실시간마감일자
                 , RTM_CLSN_FMT_YN                                              --실시간마감수행여부
                 , RTM_USE_EQUP_CD                                              --실시간사용장비코드
                 , RTM_PDAU_YN                                                  --실시간PDA사용여부
                 , FSR_STF_NO                                                   --최초등록직원번호
                 , FSR_DTM                                                      --최초등록일시
                 , FSR_PRGM_NM                                                  --최초등록프로그램명
                 , FSR_IP_ADDR                                                  --최초등록IP주소
                 , LSH_STF_NO                                                   --최종변경직원번호
                 , LSH_DTM                                                      --최종변경일시
                 , LSH_PRGM_NM                                                  --최종변경프로그램명
                 , LSH_IP_ADDR                                                  --최종변경IP주소
                 , MTRL_PBL_DT                                                  --재료발행일자
                 , LGST_SND_YN                                                  --물류전송여부      
                 , ATPB_YN  													--자동발행 여부 owb 추가
                 , RSV_DT														--검사예약일 owb 추가
                 )
          VALUES (
                   :NEW.HSP_TP_CD                                                   --병원구분코드
			     , :NEW.ORD_ID                                                      --처방ID
                 , :NEW.SGL_MIF_CD                                                  --단일수가코드
                 , :NEW.OAN_TP_CD                                                   --신구구분코드
                 , :NEW.MIFI_TP_CD                                                  --수가보험구분코드
			     , (SELECT NVL(MAX(WK_SEQ),0) + 1 
			          FROM MSERMAMH 
			         WHERE HSP_TP_CD      = :NEW.HSP_TP_CD 
			           AND ORD_ID         = :NEW.ORD_ID)                            --작업순번
			     , SYSDATE                                                          --변경타임
			     , WK_IP_ADDR                                                       --수작업IP주소
			     , WK_PGRM_NM                                                       --수작업프로그램명
			     , WK_STF_NM                                                        --수작업작업자명
			     , 'I'                                                              --작업변경구분코드
                 , :NEW.RPY_ORD_ID                                                  --수납처방ID
                 , :NEW.MTRL_MIF_CD                                                 --재료수가코드
                 , :NEW.USE_QTY                                                     --사용수량
                 , :NEW.RPY_USE_QTY                                                 --수납사용수량
                 , :NEW.MED_DEPT_CD                                                 --진료부서코드
                 , :NEW.ANDR_STF_NO                                                 --주치의직원번호
                 , :NEW.ORD_DEPT_CD                                                 --처방부서코드
                 , :NEW.PREQ_YN                                                     --구매요구여부
                 , :NEW.EXM_IMPL_DT                                                 --검사시행일자
                 , :NEW.PDA_PBL_YN                                                  --PDA발행여부
                 , :NEW.ARCL_NO                                                     --물품번호
                 , :NEW.ANMC_RSN_CD                                                 --임의비급여사유코드
                 , :NEW.ANMC_RSN_ETC_CNTE                                           --임의비급여사유기타내용
                 , :NEW.PACT_ID                                                     --원무접수ID
                 , :NEW.PACT_TP_CD                                                  --원무접수구분코드
                 , :NEW.RPY_PACT_TP_CD                                              --수납원무접수구분코드
                 , :NEW.RPY_PACT_ID                                                 --수납원무접수ID
                 , :NEW.RPY_CLS_SEQ                                                 --수납유형순번
                 , :NEW.RPY_STS_CD                                                  --수납상태코드
                 , :NEW.RTM_MED_DT                                                  --실시간진료일자
                 , :NEW.RTM_MEDR_STF_NO                                             --실시간진료의직원번호
                 , :NEW.RTM_MEDR_AADP_CD                                            --실시간진료의발령부서코드
                 , :NEW.RTM_MEDR_WKDP_CD                                            --실시간진료의근무부서코드
                 , :NEW.RTM_PBL_DTM                                                 --실시간발행일시
                 , :NEW.RTM_PBL_STF_NO                                              --실시간발행직원번호
                 , :NEW.RTM_PBR_AADP_CD                                             --실시간발행자발령부서코드
                 , :NEW.RTM_PBR_WKDP_CD                                             --실시간발행자근무부서코드
                 , :NEW.RTM_FMT_DTM                                                 --실시간수행일시
                 , :NEW.RTM_FMT_STF_NO                                              --실시간수행직원번호
                 , :NEW.RTM_FMPS_COAP_DEPT_CD                                       --실시간수행자비용적용부서코드
                 , :NEW.RTM_FMPS_WKDP_CD                                            --실시간수행자근무부서코드
                 , :NEW.RTM_FMCN_STF_NO                                             --실시간수행취소직원번호
                 , :NEW.RTM_FMCN_DTM                                                --실시간수행취소일시
                 , :NEW.RTM_CLSN_STF_NO                                             --실시간마감직원번호
                 , :NEW.RTM_CLSN_DT                                                 --실시간마감일자
                 , :NEW.RTM_CLSN_FMT_YN                                             --실시간마감수행여부
                 , :NEW.RTM_USE_EQUP_CD                                             --실시간사용장비코드
                 , :NEW.RTM_PDAU_YN                                                 --실시간PDA사용여부
                 , :NEW.FSR_STF_NO                                                  --최초등록직원번호
                 , :NEW.FSR_DTM                                                     --최초등록일시
                 , :NEW.FSR_PRGM_NM                                                 --최초등록프로그램명
                 , :NEW.FSR_IP_ADDR                                                 --최초등록IP주소
                 , :NEW.LSH_STF_NO                                                  --최종변경직원번호
                 , :NEW.LSH_DTM                                                     --최종변경일시
                 , :NEW.LSH_PRGM_NM                                                 --최종변경프로그램명
                 , :NEW.LSH_IP_ADDR                                                 --최종변경IP주소
                 , :NEW.MTRL_PBL_DT                                                 --재료발행일자
                 , :NEW.LGST_SND_YN                                                 --물류전송여부 
                 , :NEW.ATPB_YN  													--자동발행 여부 owb 추가
                 , :NEW.RSV_DT														--검사예약일 owb 추가                 
                 );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20003, 'DUP ERROR : MSERMAMH INSERT(1)'||' '|| :NEW.HSP_TP_CD || ',' || :NEW.ORD_ID || TO_CHAR(SQLCODE));
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20004, 'TRIGGER ERROR : MSERMAMH INSERT(2)'||' '|| :NEW.HSP_TP_CD || ',' || :NEW.ORD_ID|| TO_CHAR(SQLCODE));
        END;

    ELSIF UPDATING THEN
        BEGIN
            INSERT 
              INTO HSUP.MSERMAMH 
                 ( HSP_TP_CD                                                    --병원구분코드
                 , ORD_ID                                                       --처방ID
                 , SGL_MIF_CD                                                   --단일수가코드
                 , OAN_TP_CD                                                    --신구구분코드
                 , MIFI_TP_CD                                                   --수가보험구분코드
                 , WK_SEQ                                                       --작업순번
                 , CHG_TMST                                                     --변경타임
                 , HDWK_IP_ADDR                                                 --수작업IP주소     
                 , HDWK_PRGM_NM                                                 --수작업프로그램명
                 , HDWK_STF_NM                                                  --수작업직원명
                 , WK_CHG_TP_CD                                                 --작업변경구분코드
                 , RPY_ORD_ID                                                   --수납처방ID
                 , MTRL_MIF_CD                                                  --재료수가코드
                 , USE_QTY                                                      --사용수량
                 , RPY_USE_QTY                                                  --수납사용수량
                 , MED_DEPT_CD                                                  --진료부서코드
                 , ANDR_STF_NO                                                  --주치의직원번호
                 , ORD_DEPT_CD                                                  --처방부서코드
                 , PREQ_YN                                                      --구매요구여부
                 , EXM_IMPL_DT                                                  --검사시행일자
                 , PDA_PBL_YN                                                   --PDA발행여부
                 , ARCL_NO                                                      --물품번호
                 , ANMC_RSN_CD                                                  --임의비급여사유코드
                 , ANMC_RSN_ETC_CNTE                                            --임의비급여사유기타내용
                 , PACT_ID                                                      --원무접수ID
                 , PACT_TP_CD                                                   --원무접수구분코드
                 , RPY_PACT_TP_CD                                               --수납원무접수구분코드
                 , RPY_PACT_ID                                                  --수납원무접수ID
                 , RPY_CLS_SEQ                                                  --수납유형순번
                 , RPY_STS_CD                                                   --수납상태코드
                 , RTM_MED_DT                                                   --실시간진료일자
                 , RTM_MEDR_STF_NO                                              --실시간진료의직원번호
                 , RTM_MEDR_AADP_CD                                             --실시간진료의발령부서코드
                 , RTM_MEDR_WKDP_CD                                             --실시간진료의근무부서코드
                 , RTM_PBL_DTM                                                  --실시간발행일시
                 , RTM_PBL_STF_NO                                               --실시간발행직원번호
                 , RTM_PBR_AADP_CD                                              --실시간발행자발령부서코드
                 , RTM_PBR_WKDP_CD                                              --실시간발행자근무부서코드
                 , RTM_FMT_DTM                                                  --실시간수행일시
                 , RTM_FMT_STF_NO                                               --실시간수행직원번호
                 , RTM_FMPS_COAP_DEPT_CD                                        --실시간수행자비용적용부서코드
                 , RTM_FMPS_WKDP_CD                                             --실시간수행자근무부서코드
                 , RTM_FMCN_STF_NO                                              --실시간수행취소직원번호
                 , RTM_FMCN_DTM                                                 --실시간수행취소일시
                 , RTM_CLSN_STF_NO                                              --실시간마감직원번호
                 , RTM_CLSN_DT                                                  --실시간마감일자
                 , RTM_CLSN_FMT_YN                                              --실시간마감수행여부
                 , RTM_USE_EQUP_CD                                              --실시간사용장비코드
                 , RTM_PDAU_YN                                                  --실시간PDA사용여부
                 , FSR_STF_NO                                                   --최초등록직원번호
                 , FSR_DTM                                                      --최초등록일시
                 , FSR_PRGM_NM                                                  --최초등록프로그램명
                 , FSR_IP_ADDR                                                  --최초등록IP주소
                 , LSH_STF_NO                                                   --최종변경직원번호
                 , LSH_DTM                                                      --최종변경일시
                 , LSH_PRGM_NM                                                  --최종변경프로그램명
                 , LSH_IP_ADDR                                                  --최종변경IP주소
                 , MTRL_PBL_DT                                                  --재료발행일자
                 , LGST_SND_YN                                                  --물류전송여부 
                 , ATPB_YN  													--자동발행 여부 owb 추가
                 , RSV_DT														--검사예약일 owb 추가                 
                 )
          VALUES (
                   :NEW.HSP_TP_CD                                                   --병원구분코드
			     , :NEW.ORD_ID                                                      --처방ID
                 , :NEW.SGL_MIF_CD                                                  --단일수가코드
                 , :NEW.OAN_TP_CD                                                   --신구구분코드
                 , :NEW.MIFI_TP_CD                                                  --수가보험구분코드
			     , (SELECT NVL(MAX(WK_SEQ),0) + 1 
			          FROM MSERMAMH 
			         WHERE HSP_TP_CD      = :NEW.HSP_TP_CD 
			           AND ORD_ID         = :NEW.ORD_ID)                            --작업순번                                               
			     , SYSDATE                                                          --변경타임
			     , WK_IP_ADDR                                                       --수작업IP주소
			     , WK_PGRM_NM                                                       --수작업프로그램명
			     , WK_STF_NM                                                        --수작업작업자명
			     , 'U'                                                              --작업변경구분코드
                 , :NEW.RPY_ORD_ID                                                  --수납처방ID
                 , :NEW.MTRL_MIF_CD                                                 --재료수가코드
                 , :NEW.USE_QTY                                                     --사용수량
                 , :NEW.RPY_USE_QTY                                                 --수납사용수량
                 , :NEW.MED_DEPT_CD                                                 --진료부서코드
                 , :NEW.ANDR_STF_NO                                                 --주치의직원번호
                 , :NEW.ORD_DEPT_CD                                                 --처방부서코드
                 , :NEW.PREQ_YN                                                     --구매요구여부
                 , :NEW.EXM_IMPL_DT                                                 --검사시행일자
                 , :NEW.PDA_PBL_YN                                                  --PDA발행여부
                 , :NEW.ARCL_NO                                                     --물품번호
                 , :NEW.ANMC_RSN_CD                                                 --임의비급여사유코드
                 , :NEW.ANMC_RSN_ETC_CNTE                                           --임의비급여사유기타내용
                 , :NEW.PACT_ID                                                     --원무접수ID
                 , :NEW.PACT_TP_CD                                                  --원무접수구분코드
                 , :NEW.RPY_PACT_TP_CD                                              --수납원무접수구분코드
                 , :NEW.RPY_PACT_ID                                                 --수납원무접수ID
                 , :NEW.RPY_CLS_SEQ                                                 --수납유형순번
                 , :NEW.RPY_STS_CD                                                  --수납상태코드
                 , :NEW.RTM_MED_DT                                                  --실시간진료일자
                 , :NEW.RTM_MEDR_STF_NO                                             --실시간진료의직원번호
                 , :NEW.RTM_MEDR_AADP_CD                                            --실시간진료의발령부서코드
                 , :NEW.RTM_MEDR_WKDP_CD                                            --실시간진료의근무부서코드
                 , :NEW.RTM_PBL_DTM                                                 --실시간발행일시
                 , :NEW.RTM_PBL_STF_NO                                              --실시간발행직원번호
                 , :NEW.RTM_PBR_AADP_CD                                             --실시간발행자발령부서코드
                 , :NEW.RTM_PBR_WKDP_CD                                             --실시간발행자근무부서코드
                 , :NEW.RTM_FMT_DTM                                                 --실시간수행일시
                 , :NEW.RTM_FMT_STF_NO                                              --실시간수행직원번호
                 , :NEW.RTM_FMPS_COAP_DEPT_CD                                       --실시간수행자비용적용부서코드
                 , :NEW.RTM_FMPS_WKDP_CD                                            --실시간수행자근무부서코드
                 , :NEW.RTM_FMCN_STF_NO                                             --실시간수행취소직원번호
                 , :NEW.RTM_FMCN_DTM                                                --실시간수행취소일시
                 , :NEW.RTM_CLSN_STF_NO                                             --실시간마감직원번호
                 , :NEW.RTM_CLSN_DT                                                 --실시간마감일자
                 , :NEW.RTM_CLSN_FMT_YN                                             --실시간마감수행여부
                 , :NEW.RTM_USE_EQUP_CD                                             --실시간사용장비코드
                 , :NEW.RTM_PDAU_YN                                                 --실시간PDA사용여부
                 , :NEW.FSR_STF_NO                                                  --최초등록직원번호
                 , :NEW.FSR_DTM                                                     --최초등록일시
                 , :NEW.FSR_PRGM_NM                                                 --최초등록프로그램명
                 , :NEW.FSR_IP_ADDR                                                 --최초등록IP주소
                 , :NEW.LSH_STF_NO                                                  --최종변경직원번호
                 , :NEW.LSH_DTM                                                     --최종변경일시
                 , :NEW.LSH_PRGM_NM                                                 --최종변경프로그램명
                 , :NEW.LSH_IP_ADDR                                                 --최종변경IP주소
                 , :NEW.MTRL_PBL_DT                                                 --재료발행일자
                 , :NEW.LGST_SND_YN                                                 --물류전송여부   
                 , :NEW.ATPB_YN  													--자동발행 여부 owb 추가
                 , :NEW.RSV_DT														--검사예약일 owb 추가                 
                 );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20003, 'DUP ERROR : MSERMAMH UPDATE(1)'||' '|| :NEW.HSP_TP_CD || ',' || :NEW.ORD_ID || TO_CHAR(SQLCODE));
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20004, 'TRIGGER ERROR : MSERMAMH UPDATE(2)'||' '|| :NEW.HSP_TP_CD || ',' || :NEW.ORD_ID|| TO_CHAR(SQLCODE));
        END;


    ELSIF DELETING THEN
        BEGIN
            INSERT 
              INTO HSUP.MSERMAMH 
                 ( HSP_TP_CD                                                    --병원구분코드
                 , ORD_ID                                                       --처방ID
                 , SGL_MIF_CD                                                   --단일수가코드
                 , OAN_TP_CD                                                    --신구구분코드
                 , MIFI_TP_CD                                                   --수가보험구분코드
                 , WK_SEQ                                                       --작업순번
                 , CHG_TMST                                                     --변경타임
                 , HDWK_IP_ADDR                                                 --수작업IP주소     
                 , HDWK_PRGM_NM                                                 --수작업프로그램명
                 , HDWK_STF_NM                                                  --수작업직원명
                 , WK_CHG_TP_CD                                                 --작업변경구분코드
                 , RPY_ORD_ID                                                   --수납처방ID
                 , MTRL_MIF_CD                                                  --재료수가코드
                 , USE_QTY                                                      --사용수량
                 , RPY_USE_QTY                                                  --수납사용수량
                 , MED_DEPT_CD                                                  --진료부서코드
                 , ANDR_STF_NO                                                  --주치의직원번호
                 , ORD_DEPT_CD                                                  --처방부서코드
                 , PREQ_YN                                                      --구매요구여부
                 , EXM_IMPL_DT                                                  --검사시행일자
                 , PDA_PBL_YN                                                   --PDA발행여부
                 , ARCL_NO                                                      --물품번호
                 , ANMC_RSN_CD                                                  --임의비급여사유코드
                 , ANMC_RSN_ETC_CNTE                                            --임의비급여사유기타내용
                 , PACT_ID                                                      --원무접수ID
                 , PACT_TP_CD                                                   --원무접수구분코드
                 , RPY_PACT_TP_CD                                               --수납원무접수구분코드
                 , RPY_PACT_ID                                                  --수납원무접수ID
                 , RPY_CLS_SEQ                                                  --수납유형순번
                 , RPY_STS_CD                                                   --수납상태코드
                 , RTM_MED_DT                                                   --실시간진료일자
                 , RTM_MEDR_STF_NO                                              --실시간진료의직원번호
                 , RTM_MEDR_AADP_CD                                             --실시간진료의발령부서코드
                 , RTM_MEDR_WKDP_CD                                             --실시간진료의근무부서코드
                 , RTM_PBL_DTM                                                  --실시간발행일시
                 , RTM_PBL_STF_NO                                               --실시간발행직원번호
                 , RTM_PBR_AADP_CD                                              --실시간발행자발령부서코드
                 , RTM_PBR_WKDP_CD                                              --실시간발행자근무부서코드
                 , RTM_FMT_DTM                                                  --실시간수행일시
                 , RTM_FMT_STF_NO                                               --실시간수행직원번호
                 , RTM_FMPS_COAP_DEPT_CD                                        --실시간수행자비용적용부서코드
                 , RTM_FMPS_WKDP_CD                                             --실시간수행자근무부서코드
                 , RTM_FMCN_STF_NO                                              --실시간수행취소직원번호
                 , RTM_FMCN_DTM                                                 --실시간수행취소일시
                 , RTM_CLSN_STF_NO                                              --실시간마감직원번호
                 , RTM_CLSN_DT                                                  --실시간마감일자
                 , RTM_CLSN_FMT_YN                                              --실시간마감수행여부
                 , RTM_USE_EQUP_CD                                              --실시간사용장비코드
                 , RTM_PDAU_YN                                                  --실시간PDA사용여부
                 , FSR_STF_NO                                                   --최초등록직원번호
                 , FSR_DTM                                                      --최초등록일시
                 , FSR_PRGM_NM                                                  --최초등록프로그램명
                 , FSR_IP_ADDR                                                  --최초등록IP주소
                 , LSH_STF_NO                                                   --최종변경직원번호
                 , LSH_DTM                                                      --최종변경일시
                 , LSH_PRGM_NM                                                  --최종변경프로그램명
                 , LSH_IP_ADDR                                                  --최종변경IP주소
                 , MTRL_PBL_DT                                                  --재료발행일자
                 , LGST_SND_YN                                                  --물류전송여부
                 , ATPB_YN  													--자동발행 여부 owb 추가
                 , RSV_DT														--검사예약일 owb 추가                 
                 )
          VALUES (
                   :OLD.HSP_TP_CD                                                   --병원구분코드
			     , :OLD.ORD_ID                                                      --처방ID
                 , :OLD.SGL_MIF_CD                                                  --단일수가코드
                 , :OLD.OAN_TP_CD                                                   --신구구분코드
                 , :OLD.MIFI_TP_CD                                                  --수가보험구분코드
			     , (SELECT NVL(MAX(WK_SEQ),0) + 1 
			          FROM MSERMAMH 
			         WHERE HSP_TP_CD      = :OLD.HSP_TP_CD 
			           AND ORD_ID         = :OLD.ORD_ID)                            --작업순번                                               
			     , SYSDATE                                                          --변경타임
			     , WK_IP_ADDR                                                       --수작업IP주소
			     , WK_PGRM_NM                                                       --수작업프로그램명
			     , WK_STF_NM                                                        --수작업작업자명
			     , 'D'                                                              --작업변경구분코드
                 , :OLD.RPY_ORD_ID                                                  --수납처방ID
                 , :OLD.MTRL_MIF_CD                                                 --재료수가코드
                 , :OLD.USE_QTY                                                     --사용수량
                 , :OLD.RPY_USE_QTY                                                 --수납사용수량
                 , :OLD.MED_DEPT_CD                                                 --진료부서코드
                 , :OLD.ANDR_STF_NO                                                 --주치의직원번호
                 , :OLD.ORD_DEPT_CD                                                 --처방부서코드
                 , :OLD.PREQ_YN                                                     --구매요구여부
                 , :OLD.EXM_IMPL_DT                                                 --검사시행일자
                 , :OLD.PDA_PBL_YN                                                  --PDA발행여부
                 , :OLD.ARCL_NO                                                     --물품번호
                 , :OLD.ANMC_RSN_CD                                                 --임의비급여사유코드
                 , :OLD.ANMC_RSN_ETC_CNTE                                           --임의비급여사유기타내용
                 , :OLD.PACT_ID                                                     --원무접수ID
                 , :OLD.PACT_TP_CD                                                  --원무접수구분코드
                 , :OLD.RPY_PACT_TP_CD                                              --수납원무접수구분코드
                 , :OLD.RPY_PACT_ID                                                 --수납원무접수ID
                 , :OLD.RPY_CLS_SEQ                                                 --수납유형순번
                 , :OLD.RPY_STS_CD                                                  --수납상태코드
                 , :OLD.RTM_MED_DT                                                  --실시간진료일자
                 , :OLD.RTM_MEDR_STF_NO                                             --실시간진료의직원번호
                 , :OLD.RTM_MEDR_AADP_CD                                            --실시간진료의발령부서코드
                 , :OLD.RTM_MEDR_WKDP_CD                                            --실시간진료의근무부서코드
                 , :OLD.RTM_PBL_DTM                                                 --실시간발행일시
                 , :OLD.RTM_PBL_STF_NO                                              --실시간발행직원번호
                 , :OLD.RTM_PBR_AADP_CD                                             --실시간발행자발령부서코드
                 , :OLD.RTM_PBR_WKDP_CD                                             --실시간발행자근무부서코드
                 , :OLD.RTM_FMT_DTM                                                 --실시간수행일시
                 , :OLD.RTM_FMT_STF_NO                                              --실시간수행직원번호
                 , :OLD.RTM_FMPS_COAP_DEPT_CD                                       --실시간수행자비용적용부서코드
                 , :OLD.RTM_FMPS_WKDP_CD                                            --실시간수행자근무부서코드
                 , :OLD.RTM_FMCN_STF_NO                                             --실시간수행취소직원번호
                 , :OLD.RTM_FMCN_DTM                                                --실시간수행취소일시
                 , :OLD.RTM_CLSN_STF_NO                                             --실시간마감직원번호
                 , :OLD.RTM_CLSN_DT                                                 --실시간마감일자
                 , :OLD.RTM_CLSN_FMT_YN                                             --실시간마감수행여부
                 , :OLD.RTM_USE_EQUP_CD                                             --실시간사용장비코드
                 , :OLD.RTM_PDAU_YN                                                 --실시간PDA사용여부
                 , :OLD.FSR_STF_NO                                                  --최초등록직원번호
                 , :OLD.FSR_DTM                                                     --최초등록일시
                 , :OLD.FSR_PRGM_NM                                                 --최초등록프로그램명
                 , :OLD.FSR_IP_ADDR                                                 --최초등록IP주소
                 , :OLD.LSH_STF_NO                                                  --최종변경직원번호
                 , :OLD.LSH_DTM                                                     --최종변경일시
                 , :OLD.LSH_PRGM_NM                                                 --최종변경프로그램명
                 , :OLD.LSH_IP_ADDR                                                 --최종변경IP주소
                 , :OLD.MTRL_PBL_DT                                                 --재료발행일자
                 , :OLD.LGST_SND_YN                                                 --물류전송여부         
                 , :OLD.ATPB_YN  													--자동발행 여부 owb 추가
                 , :OLD.RSV_DT														--검사예약일 owb 추가                 
                 );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                RAISE_APPLICATION_ERROR(-20003, 'DUP ERROR : MSERMAMH UPDATE(1)'||' '|| :NEW.HSP_TP_CD || ',' || :NEW.ORD_ID || TO_CHAR(SQLCODE));
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20004, 'TRIGGER ERROR : MSERMAMH UPDATE(2)'||' '|| :NEW.HSP_TP_CD || ',' || :NEW.ORD_ID|| TO_CHAR(SQLCODE));
        END;
   END IF;   
   EXCEPTION
      WHEN OTHERS THEN
           RAISE_APPLICATION_ERROR('-20003','TR_MSERMAMD');
END;