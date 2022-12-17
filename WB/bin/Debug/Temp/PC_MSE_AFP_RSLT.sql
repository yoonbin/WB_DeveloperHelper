PROCEDURE      PC_MSE_AFP_RSLT   (  IN_POSYN        IN      VARCHAR2
	                                , IN_SPCNO        IN      VARCHAR2
	                                , IN_TSTCD        IN      VARCHAR2
	                                , IN_USERID       IN      VARCHAR2
	                                , IN_MDA_KIND     IN      VARCHAR2 
	                                , IN_HIS_HSP_TP_CD IN     VARCHAR2
	                                , IN_HIS_IP_ADDR   IN     VARCHAR2
	                                , IN_HIS_PRGM_ID   IN     VARCHAR2
	                                , IN_HIS_PRGM_NM   IN     VARCHAR2
	                                , IO_ERRYN        OUT     VARCHAR2
	                                , IO_ERRMSG       OUT     VARCHAR2 )

IS
    T_ACPTNO        VARCHAR2(0020)  :=  '';
    T_SPCNO2        VARCHAR2(0020)  :=  '';
    T_TSTCD         VARCHAR2(0020)  :=  '';
    
    T_LASTFLAG      VARCHAR2(1)     :=  'N'; --최종보고시에만 검사상태를 변경한다. 
    T_POSYN         VARCHAR2(1)     :=  '';  --양성시 또는 음성의 결과가 모두 들어온경우 수행한다.
    T_POSLSTYN      VARCHAR2(1)     :=  'N'; --양성시 또는 음성의 결과가 모두 들어온경우 수행한다.
    T_CHK_LIQ1      VARCHAR2(1)     :=  '';
    T_CHK_LIQ2      VARCHAR2(1)     :=  '';
    T_CHK_SOL1      VARCHAR2(1)     :=  '';
    T_CHK_SOL2      VARCHAR2(1)     :=  '';
    T_REPLACEYN     VARCHAR2(1)     :=  '';
    
    T_DELFLAG       VARCHAR2(1)     :=  'N';
    T_ALL_DELFLAG   VARCHAR2(1)     :=  'N';
    
    T_SERUM_TYPE    VARCHAR2(500)   :=  '';  --SERUM_TYPE : SOL의 배양성상  
    T_PN_CLS        VARCHAR2(1)     :=  '';  --PN_CLS : SOL의 동정결과
    T_RSLT          VARCHAR2(20)    :=  '';  --RSLT : SOL의 배양일수 DAY
    T_ISO_RSLT      VARCHAR2(200)   :=  '';  --ISO_RSLT : SOL,LIQ 동정방법
    T_MDA_KIND      VARCHAR2(10)    :=  '';  --MDA_KIND : SOL,LIQ 배지종류
    T_PN_CLS_LIQ    VARCHAR2(1)     :=  '';  --PN_CLS_LIQ : LIQ의 동정결과
    T_RSLT_LIQ      VARCHAR2(20)    :=  '';  --RSLT_LIQ : LIQ의 배양일수 DAY
    T_ISO_RSLT_ETC  VARCHAR2(250)   :=  '';  --ISO_RSLT_ETC : 결핵동정결과 SOL배지
    T_ISO_RSLT_ETC_LIQ VARCHAR2(250) := '';  --ISO_RSLT_ETC_LIQ : 결핵동정결과 LIQ배지

    T_UPDTETM_1     VARCHAR2(12)    :=  '';
    T_UPDTETM_0     VARCHAR2(12)    :=  '';
    T_BOTTLE        VARCHAR2(10)    :=  '';
    T_TST_DTE       VARCHAR2(8)     :=  '';
    T_HST_FLAG      VARCHAR2(1)     :=  'N';
    
    T_REPORTTYPE    VARCHAR2(1)     :=  '';
    T_RSLT_STR      VARCHAR2(2000)  :=  '';

    T_TMP_STR       VARCHAR2(1000)  :=  '';
    
    T_REPORT_STR    VARCHAR2(1000)  :=  '';
    
    V_EEXM_YN VARCHAR2(1) := 'N'; -- 2019-05-09 지성원 : 수탁여부 추가   

BEGIN           
         
   BEGIN
--        SELECT /*+ XSUP.PC_MSE_AFP_RSLT */
--               TH1_RMK_CNTE
--          INTO T_TMP_STR
--          FROM MSELMSID
--         WHERE LCLS_COMN_CD      = '969'
--           AND SCLS_COMN_CD_NM   = 'pc_sl_p_04_main_AFP'
--           AND USE_YN            = 'Y'
--           AND TH3_RMK_CNTE      = 'STR'     
--           AND HSP_TP_CD         = IN_HIS_HSP_TP_CD
--           AND ROWNUM            = 1;

		SELECT /*+ XSUP.PC_MSE_AFP_RSLT */
               TH1_RMK_CNTE
          INTO T_TMP_STR
          FROM MSELMSID
         WHERE LCLS_COMN_CD      = 'TUBERCULOSIS'
           AND SCLS_COMN_CD_NM   = SUBSTR(IN_MDA_KIND, 1, 1)
           AND USE_YN            = 'Y'
           AND HSP_TP_CD   = IN_HIS_HSP_TP_CD --병원구분
           AND ROWNUM            = 1;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            T_TMP_STR :=  CHR(13) || CHR(10) || '* 두 가지 종류의 배지(Solid and Liquid)를 사용하여 6주간 배양을 실시' || CHR(13) || CHR(10);
            T_TMP_STR := T_TMP_STR || '  하고 있으므로  반드시 최종결과를 확인하시기 바랍니다.' || CHR(13) || CHR(10);
            --2010.08.09 방수석 수정 문구변경
            --T_TMP_STR := T_TMP_STR || CHR(13) || CHR(10) || '* NTM의 추가 동정결과는 NTM (NONTUBERCULOUS MYCOBACTERIA) 동정' || CHR(13) || CHR(10);
            --T_TMP_STR := T_TMP_STR || '  [분자진단] 을 참조하십시오.' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
            T_TMP_STR := T_TMP_STR || CHR(13) || CHR(10) || '* NTM의 추가 동정을 원하시면' || CHR(13) || CHR(10);
            T_TMP_STR := T_TMP_STR || '  L2518 NTM (NonTuberculous Mycobacteria) 동정 [분자진단]을 오더 해 주십시요.' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
        WHEN OTHERS  THEN
            IO_ERRYN  := 'Y';
            IO_ERRMSG := 'AFP CULTURE 결과 저장 시 에러 발생1. ERRCD = ' || TO_CHAR(SQLCODE);
            RETURN;
   END; 
   
    IF IN_MDA_KIND = 'LASTCERT' THEN
        GOTO lastcert;
    END IF;
    
    IF IN_MDA_KIND = 'CS' OR IN_MDA_KIND = 'CL' THEN
        T_DELFLAG := 'Y';        
    END IF;
   
    BEGIN
        SELECT /*+ XSUP.PC_MSE_AFP_RSLT */
               SRUM_CLS_CNTE
             , LABM_NEPO_TP_CD
             , PRCC_RSLT_CNTE
             , MVRT_CNTE
             , TB_CLMD_KND_CNTE
             , LQD_CLMD_MVRT_CNTE
             , LQD_CLMD_RSLT_CNTE
             , MVRT_SLD_CLMD_INPT_CNTE
             , MVRT_LQD_CLMD_INPT_CNTE
          INTO T_SERUM_TYPE
             , T_PN_CLS
             , T_RSLT
             , T_ISO_RSLT
             , T_MDA_KIND
             , T_PN_CLS_LIQ
             , T_RSLT_LIQ
             , T_ISO_RSLT_ETC
             , T_ISO_RSLT_ETC_LIQ
          FROM MSELMCRD
         WHERE SPCM_NO = IN_SPCNO
           AND EXM_CD = IN_TSTCD 
           AND HSP_TP_CD         = IN_HIS_HSP_TP_CD;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
           T_SERUM_TYPE    :=  '';  --SERUM_TYPE : SOL의 배양성상  
           T_PN_CLS        :=  '';  --PN_CLS : SOL의 동정결과
           T_RSLT          :=  '';  --RSLT : SOL의 배양일수 DAY
           T_ISO_RSLT      :=  '';  --ISO_RSLT : SOL,LIQ 동정방법
           T_MDA_KIND      :=  '';  --MDA_KIND : SOL,LIQ 배지종류
           T_PN_CLS_LIQ    :=  '';  --PN_CLS_LIQ : LIQ의 동정결과
           T_RSLT_LIQ      :=  '';  --RSLT_LIQ : LIQ의 배양일수 DAY    
       WHEN OTHERS  THEN
           IO_ERRYN  := 'Y';
           IO_ERRMSG := 'AFP CULTURE 결과 저장 시 에러 발생2. ERRCD = ' || TO_CHAR(SQLCODE);
           RETURN;
    END;
	 
	
    BEGIN
        SELECT /*+ XSUP.PC_MSE_AFP_RSLT */
               TO_CHAR(TH2_MDF_DTM, 'YYYYMMDDHH24MI')
             , TO_CHAR(TH1_MDF_DTM, 'YYYYMMDDHH24MI')
             , BLOD_INCB_CTNR_NM 
             , TO_CHAR(EXM_HOPE_DT, 'YYYYMMDD')
             --, EXM_HOPE_DT
          INTO T_UPDTETM_1
             , T_UPDTETM_0
             , T_BOTTLE
             , T_TST_DTE
          FROM MSELMAID
         WHERE SPCM_NO = IN_SPCNO
           AND EXM_CD = IN_TSTCD 
           AND HSP_TP_CD = IN_HIS_HSP_TP_CD;
       
       EXCEPTION
       WHEN OTHERS  THEN
           IO_ERRYN  := 'Y';
           IO_ERRMSG := 'AFP CULTURE 결과 저장 시 에러 발생3. ERRCD = ' || TO_CHAR(SQLCODE);
           RETURN;
    END;
	
    BEGIN
        SELECT /*+ XSUP.PC_MSE_AFP_RSLT */
               TH1_RMK_CNTE
          INTO T_REPORT_STR
          FROM MSELMSID
         WHERE LCLS_COMN_CD      = '969'
           AND SCLS_COMN_CD_NM   = 'PKG_SUP_SL_P_04'
           AND USE_YN            = 'Y'
           AND TH3_RMK_CNTE      = 'STR' 
           AND HSP_TP_CD         = IN_HIS_HSP_TP_CD
           AND ROWNUM            = 1;
       
       EXCEPTION
       WHEN OTHERS  THEN
           T_REPORT_STR := '보고의사: 송상훈/박경운/송정한 M.D.';
    END; 
	
   IF T_TST_DTE < '20081001' THEN  
       T_HST_FLAG := 'Y';
   END IF;
	
   IF T_UPDTETM_1 IS NULL AND T_BOTTLE IS NULL THEN  
       T_REPORTTYPE := '1';  
   ELSIF T_UPDTETM_1 IS NOT NULL AND SUBSTR(T_BOTTLE,1,1) = 'L' THEN 
       IF T_MDA_KIND IS NULL OR SUBSTR(T_MDA_KIND,2,1) = '0' THEN
           T_REPORTTYPE := '2'; 
       ELSE
           T_REPORTTYPE := '3'; 
       END IF;
       
       IF IN_MDA_KIND = 'CL' AND T_UPDTETM_0 IS NOT NULL THEN
           IF T_MDA_KIND IS NULL OR SUBSTR(T_MDA_KIND,1,1) = '0' THEN
               T_REPORTTYPE := '8';
           ELSE
               T_REPORTTYPE := '9';
           END IF;
       END IF;    
       
   ELSIF T_UPDTETM_1 IS NOT NULL AND SUBSTR(T_BOTTLE,1,1) = 'S' THEN 
       IF T_MDA_KIND IS NULL OR SUBSTR(T_MDA_KIND,1,1) = '0' THEN
           T_REPORTTYPE := '4'; 
       ELSE
           T_REPORTTYPE := '5'; 
       END IF;
       
       IF IN_MDA_KIND = 'CS' AND T_UPDTETM_0 IS NOT NULL THEN
           IF T_MDA_KIND IS NULL OR SUBSTR(T_MDA_KIND,2,1) = '0' THEN
               T_REPORTTYPE := '6';
           ELSE
               T_REPORTTYPE := '7';
           END IF;
       END IF;  
       
   END IF;
   
   IF T_DELFLAG = 'Y' THEN
       IF SUBSTR(T_BOTTLE,1,1) = 'L' AND IN_MDA_KIND = 'CL' THEN
           IF T_UPDTETM_0 IS NULL THEN
               T_ALL_DELFLAG := 'Y';
           ELSE
               T_ALL_DELFLAG := 'P';
           END IF;
       ELSIF SUBSTR(T_BOTTLE,1,1) = 'S' AND IN_MDA_KIND = 'CS' THEN
           IF T_UPDTETM_0 IS NULL THEN
               T_ALL_DELFLAG := 'Y';
           ELSE
               T_ALL_DELFLAG := 'P';
           END IF;
       ELSE
           T_ALL_DELFLAG := 'N';
       END IF;
   END IF; 
            
   --Liquid media 결과보고서 생성
   IF SUBSTR(IN_MDA_KIND,1,1) = 'L' THEN
       IF T_HST_FLAG = 'Y' THEN
           T_RSLT_STR := 'Liquid media 결과    보고시간:' || TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI') || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
       ELSE
           T_RSLT_STR := '1. Liquid media 결과    보고시간:' || TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI') || CHR(13) || CHR(10) || CHR(13) || CHR(10);
       END IF;
       IF IN_POSYN = 'N' THEN
           IF SUBSTR(IN_MDA_KIND,2,1) = '1' THEN 
               T_RSLT_STR :=  T_RSLT_STR || 'No acid fast bacilli isolated after 6 weeks (Liquid media 1)' || CHR(13) || CHR(10);
           ELSIF SUBSTR(IN_MDA_KIND,2,1) = '2' THEN 
               T_RSLT_STR :=  T_RSLT_STR || 'No acid fast bacilli isolated after 6 weeks (Liquid media 2)' || CHR(13) || CHR(10);
           ELSE 
               T_RSLT_STR :=  T_RSLT_STR || 'No acid fast bacilli isolated after 6 weeks (Liquid media 3)' || CHR(13) || CHR(10);
           END IF;
           T_CHK_LIQ1 := 'Y';
           IF T_REPORTTYPE = '2' THEN            
               T_REPLACEYN := 'Y';
           END IF;
       ELSE
           --<<LIQ_RSLT>>
           T_RSLT_STR := T_RSLT_STR || '[배지종류]' || CHR(13) || CHR(10);
           IF SUBSTR(T_MDA_KIND,2,1) = '1' THEN
               T_RSLT_STR := T_RSLT_STR || 'Liquid media 1' || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
           ELSIF SUBSTR(T_MDA_KIND,2,1) = '2' THEN
               T_RSLT_STR := T_RSLT_STR || 'Liquid media 2' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
           ELSIF SUBSTR(T_MDA_KIND,2,1) = '3' THEN
               T_RSLT_STR := T_RSLT_STR || 'Liquid media 3' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
           ELSE
               T_RSLT_STR := T_RSLT_STR || CHR(13) || CHR(10) || CHR(13) || CHR(10);
           END IF;
           
           T_RSLT_STR := T_RSLT_STR || '[동정방법]' || CHR(13) || CHR(10);
           T_RSLT_STR := T_RSLT_STR || T_ISO_RSLT || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
           
           T_RSLT_STR := T_RSLT_STR || '[동정결과]' || CHR(13) || CHR(10);
           IF T_PN_CLS_LIQ = '0' THEN
               T_RSLT_STR := T_RSLT_STR || 'Mycobacterium spp. isolated after';
           ELSIF T_PN_CLS_LIQ = '1' THEN
               T_RSLT_STR := T_RSLT_STR || 'M. tuberculosis complex isolated after';
           ELSIF T_PN_CLS_LIQ = '2' THEN
               T_RSLT_STR := T_RSLT_STR || 'Nontuberculous mycobacteria (ntm) isolated after';
           ELSIF T_PN_CLS_LIQ = '3' THEN
               T_RSLT_STR := T_RSLT_STR || 'Contamination';           
           ELSIF T_PN_CLS_LIQ = '6' THEN
               T_RSLT_STR := T_RSLT_STR || 'M. tuberculosis complex & Non Tuberculous Mycobacteria isolated after';
           ELSIF T_PN_CLS_LIQ = '5' THEN
               T_RSLT_STR := T_RSLT_STR || T_ISO_RSLT_ETC_LIQ; --수기입력 컬럼
           END IF;
           
           T_RSLT_STR := T_RSLT_STR || ' ' ||  T_RSLT_LIQ || ' Days' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
           
           T_POSYN := 'P';
           T_POSLSTYN := 'Y';
           T_CHK_LIQ2 := 'Y'; 
           
           IF T_REPORTTYPE = '3' THEN            
               T_REPLACEYN := 'Y';
           END IF;   
       END IF;
       
       IF T_HST_FLAG = 'Y' THEN
           GOTO HST_PROC;
       ELSE
           T_RSLT_STR := T_RSLT_STR || T_TMP_STR;
       END IF;                                
   ELSE
       IF T_REPORTTYPE = '2' OR T_REPORTTYPE = '3' OR T_REPORTTYPE = '6' OR T_REPORTTYPE = '7' THEN
           IF T_REPORTTYPE = '6' OR T_REPORTTYPE = '7' THEN
               T_RSLT_STR := '1. Liquid media 결과    보고시간:' || TO_CHAR(TO_DATE(T_UPDTETM_0,'YYYYMMDDHH24MI'), 'YYYY/MM/DD HH24:MI') || CHR(13) || CHR(10) || CHR(13) || CHR(10);                
           ELSE
               T_RSLT_STR := '1. Liquid media 결과    보고시간:' || TO_CHAR(TO_DATE(T_UPDTETM_1,'YYYYMMDDHH24MI'), 'YYYY/MM/DD HH24:MI') || CHR(13) || CHR(10) || CHR(13) || CHR(10);
           END IF;
           
           IF T_REPORTTYPE = '2' OR T_REPORTTYPE = '6' THEN
               IF SUBSTR(T_BOTTLE,2,1) = '1' THEN 
                   T_RSLT_STR :=  T_RSLT_STR || 'No acid fast bacilli isolated after 6 weeks (Liquid media 1)' || CHR(13) || CHR(10);
               ELSIF SUBSTR(T_BOTTLE,2,1) = '2' THEN 
                   T_RSLT_STR :=  T_RSLT_STR || 'No acid fast bacilli isolated after 6 weeks (Liquid media 2)' || CHR(13) || CHR(10);
               ELSE
                   T_RSLT_STR :=  T_RSLT_STR || 'No acid fast bacilli isolated after 6 weeks (Liquid media 3)' || CHR(13) || CHR(10);
               END IF;
               T_CHK_LIQ1 := 'Y';
           ELSE
               --GOTO LIQ_RSLT;
               T_RSLT_STR := T_RSLT_STR || '[배지종류]' || CHR(13) || CHR(10);
               IF SUBSTR(T_MDA_KIND,2,1) = '1' THEN
                   T_RSLT_STR := T_RSLT_STR || 'Liquid media 1' || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
               ELSIF SUBSTR(T_MDA_KIND,2,1) = '2' THEN
                   T_RSLT_STR := T_RSLT_STR || 'Liquid media 2' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
               ELSIF SUBSTR(T_MDA_KIND,2,1) = '3' THEN
                   T_RSLT_STR := T_RSLT_STR || 'Liquid media 3' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
               ELSE
                   T_RSLT_STR := T_RSLT_STR || CHR(13) || CHR(10) || CHR(13) || CHR(10);
               END IF;
               
               T_RSLT_STR := T_RSLT_STR || '[동정방법]' || CHR(13) || CHR(10);
               T_RSLT_STR := T_RSLT_STR || T_ISO_RSLT || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
               
               T_RSLT_STR := T_RSLT_STR || '[동정결과]' || CHR(13) || CHR(10);
               IF T_PN_CLS_LIQ = '0' THEN
                   T_RSLT_STR := T_RSLT_STR || 'Mycobacterium spp. isolated after';
               ELSIF T_PN_CLS_LIQ = '1' THEN
                   T_RSLT_STR := T_RSLT_STR || 'M. tuberculosis complex isolated after';
               ELSIF T_PN_CLS_LIQ = '2' THEN
                   T_RSLT_STR := T_RSLT_STR || 'NonTuberculous Mycobacteria (NTM) isolated after';
               ELSIF T_PN_CLS_LIQ = '3' THEN
                   T_RSLT_STR := T_RSLT_STR || 'Contamination';       
	           ELSIF T_PN_CLS_LIQ = '6' THEN
         	       T_RSLT_STR := T_RSLT_STR || 'M. tuberculosis complex & Non Tuberculous Mycobacteria isolated after';                   
               ELSIF T_PN_CLS_LIQ = '5' THEN
                   T_RSLT_STR := T_RSLT_STR || T_ISO_RSLT_ETC_LIQ; --수기입력 컬럼
               END IF;
               
               T_RSLT_STR := T_RSLT_STR || ' ' ||  T_RSLT_LIQ || ' DAYS' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
               
               T_POSYN := 'P';
               T_POSLSTYN := 'Y';
               T_CHK_LIQ2 := 'Y';
           END IF;
           
           T_RSLT_STR := T_RSLT_STR || T_TMP_STR;
           
       ELSE
           T_RSLT_STR := '1. Liquid media 결과    검사진행중' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
       END IF;     
       
   END IF;
   
   IF T_DELFLAG = 'Y' AND IN_MDA_KIND = 'CL' THEN
       T_RSLT_STR := '1. Liquid media 결과    검사진행중' || CHR(13) || CHR(10) || CHR(13) || CHR(10);     
   END IF;
  
   T_RSLT_STR := T_RSLT_STR || '---------------------------------------------------------------------' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
	
   --SOLID MEDIA 결과보고 생성
   IF SUBSTR(IN_MDA_KIND,1,1) = 'S' THEN
       IF T_HST_FLAG = 'Y' THEN
           T_RSLT_STR := 'Solid media  결과    보고시간:' || TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI') || CHR(13) || CHR(10) || CHR(13) || CHR(10);
       ELSE
           T_RSLT_STR := T_RSLT_STR || '2. Solid media  결과    보고시간:' || TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI') || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
       END IF;
       
       IF IN_POSYN = 'N' THEN
           T_RSLT_STR :=  T_RSLT_STR || 'No acid fast bacilli isolated after 6 weeks (solid media)' || CHR(13) || CHR(10);
           T_CHK_SOL1 := 'Y';
           IF T_REPORTTYPE = '4' THEN            
               T_REPLACEYN := 'Y';
           END IF;
       ELSE
           --<<SOL_RSLT>>
           T_RSLT_STR := T_RSLT_STR || '[배지종류]' || CHR(13) || CHR(10);
           IF SUBSTR(T_MDA_KIND,1,1) = '1' THEN
               T_RSLT_STR := T_RSLT_STR || 'Solid media' || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
           ELSIF SUBSTR(T_MDA_KIND,1,1) = '2' THEN
               --T_RSLT_STR := T_RSLT_STR || 'MIDDLEBROOK 7H11 AGAR' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
               T_RSLT_STR := T_RSLT_STR || 'Solid media' || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
           ELSE
               T_RSLT_STR := T_RSLT_STR || CHR(13) || CHR(10) || CHR(13) || CHR(10);
           END IF;
                      
           IF TRIM(T_SERUM_TYPE) <> '' THEN
	           T_RSLT_STR := T_RSLT_STR || '[배양성상]' || CHR(13) || CHR(10);
	           T_RSLT_STR := T_RSLT_STR || T_SERUM_TYPE || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
           END IF;
           
           T_RSLT_STR := T_RSLT_STR || '[동정방법]' || CHR(13) || CHR(10);
           T_RSLT_STR := T_RSLT_STR || T_ISO_RSLT || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
           
           T_RSLT_STR := T_RSLT_STR || '[동정결과]' || CHR(13) || CHR(10);
           IF T_PN_CLS = '0' THEN
               T_RSLT_STR := T_RSLT_STR || 'Mycobacterium spp. isolated after';
           ELSIF T_PN_CLS = '1' THEN
               T_RSLT_STR := T_RSLT_STR || 'M. tuberculosis complex isolated after';
           ELSIF T_PN_CLS = '2' THEN
               T_RSLT_STR := T_RSLT_STR || 'NonTuberculous Mycobacteria (NTM) isolated after';
           ELSIF T_PN_CLS = '3' THEN
               T_RSLT_STR := T_RSLT_STR || 'Contamination';              
           ELSIF T_PN_CLS = '6' THEN
               T_RSLT_STR := T_RSLT_STR || 'M. tuberculosis complex & Non Tuberculous Mycobacteria isolated after';               
           ELSIF T_PN_CLS = '5' THEN
               T_RSLT_STR := T_RSLT_STR || T_ISO_RSLT_ETC; --수기입력 컬럼
           END IF;
           
           T_RSLT_STR := T_RSLT_STR || ' ' ||  T_RSLT || ' Days' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
           
           T_POSYN := 'P';
           T_POSLSTYN := 'Y';
           T_CHK_SOL2 := 'Y';
           IF T_REPORTTYPE = '5' THEN            
               T_REPLACEYN := 'Y';
           END IF;
                   
       END IF;
       
       IF T_HST_FLAG = 'Y' THEN
           GOTO HST_PROC;
       ELSE
           T_RSLT_STR := T_RSLT_STR || T_TMP_STR;
       END IF;
            
   ELSE
       IF T_REPORTTYPE = '4' OR T_REPORTTYPE = '5' OR T_REPORTTYPE = '8' OR T_REPORTTYPE = '9' THEN
           IF T_REPORTTYPE = '8' OR T_REPORTTYPE = '9' THEN
               T_RSLT_STR := T_RSLT_STR || '2. Solid media 결과    보고시간:' || TO_CHAR(TO_DATE(T_UPDTETM_0,'YYYYMMDDHH24MI'), 'YYYY/MM/DD HH24:MI') || CHR(13) || CHR(10) || CHR(13) || CHR(10);
           ELSE
               T_RSLT_STR := T_RSLT_STR || '2. Solid media 결과    보고시간:' || TO_CHAR(TO_DATE(T_UPDTETM_1,'YYYYMMDDHH24MI'), 'YYYY/MM/DD HH24:MI') || CHR(13) || CHR(10) || CHR(13) || CHR(10);           
           END IF;    
           IF T_REPORTTYPE = '4' OR T_REPORTTYPE = '8' THEN
               T_RSLT_STR :=  T_RSLT_STR || 'No acid fast bacilli isolated after 6 weeks (solid media)' || CHR(13) || CHR(10);
               T_CHK_SOL1 := 'Y';
           ELSE
               --GOTO SOL_RSLT;
               T_RSLT_STR := T_RSLT_STR || '[배지종류]' || CHR(13) || CHR(10);
               IF SUBSTR(T_MDA_KIND,1,1) = '1' THEN
                   T_RSLT_STR := T_RSLT_STR || 'Solid media' || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
               ELSIF SUBSTR(T_MDA_KIND,1,1) = '2' THEN
                   T_RSLT_STR := T_RSLT_STR || 'Middlebrook 7H11 agar' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
               ELSE
                   T_RSLT_STR := T_RSLT_STR || CHR(13) || CHR(10) || CHR(13) || CHR(10);
               END IF;
               
               IF TRIM(T_SERUM_TYPE) <> '' THEN
	               T_RSLT_STR := T_RSLT_STR || '[배양성상]' || CHR(13) || CHR(10);
	               T_RSLT_STR := T_RSLT_STR || T_SERUM_TYPE || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
               END IF;
               
               T_RSLT_STR := T_RSLT_STR || '[동정방법]' || CHR(13) || CHR(10);
               T_RSLT_STR := T_RSLT_STR || T_ISO_RSLT || CHR(13) || CHR(10) || CHR(13) || CHR(10);        
               
               T_RSLT_STR := T_RSLT_STR || '[동정결과]' || CHR(13) || CHR(10);
               IF T_PN_CLS = '0' THEN
                   T_RSLT_STR := T_RSLT_STR || 'Mycobacterium spp. isolated after';
               ELSIF T_PN_CLS = '1' THEN
                   T_RSLT_STR := T_RSLT_STR || 'M. tuberculosis complex isolated after';
               ELSIF T_PN_CLS = '2' THEN
                   T_RSLT_STR := T_RSLT_STR || 'NonTuberculous Mycobacteria (NTM) isolated after';
               ELSIF T_PN_CLS = '3' THEN
                   T_RSLT_STR := T_RSLT_STR || 'Contamination';
               ELSIF T_PN_CLS = '6' THEN
	               T_RSLT_STR := T_RSLT_STR || 'M. tuberculosis complex & Non Tuberculous Mycobacteria isolated after';   
               ELSIF T_PN_CLS = '5' THEN
                   T_RSLT_STR := T_RSLT_STR || T_ISO_RSLT_ETC; --수기입력 컬럼
               END IF;
               
               T_RSLT_STR := T_RSLT_STR || ' ' ||  T_RSLT || ' Days' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
               
               T_POSYN := 'P';
               T_POSLSTYN := 'Y';
               T_CHK_SOL2 := 'Y';
           END IF;
           
           T_RSLT_STR := T_RSLT_STR || T_TMP_STR;
           
       ELSE
           T_RSLT_STR := T_RSLT_STR || '2. Solid media 결과    검사진행중' || CHR(13) || CHR(10) || CHR(13) || CHR(10);
       END IF;     
   END IF;
       
   -- 2017.10.31 일괄적용  No growth of, 별지보고 
	IF IN_MDA_KIND = 'AA' THEN
        T_RSLT_STR := 'No growth of Mycobacterium after 8wks';   -- Mycobacterium after
   	ELSIF IN_MDA_KIND = 'AB' THEN
        T_RSLT_STR := 'No growth of Mycobacterium after 6wks';   -- Mycobacterium after
    ELSIF IN_MDA_KIND = 'BB' THEN
        T_RSLT_STR := '별지보고';
	END IF;
   
   	IF (T_CHK_LIQ1 = 'Y' OR T_CHK_LIQ2 = 'Y') AND (T_CHK_SOL1 = 'Y' OR T_CHK_SOL2 = 'Y') THEN
		T_LASTFLAG := 'Y';
       	IF T_CHK_LIQ1 = 'Y' AND T_CHK_SOL1 = 'Y' THEN
        	T_POSYN := 'N';
       	END IF;
   	END IF;
   	
   <<hst_proc>>
   IF T_HST_FLAG = 'Y' THEN
       T_LASTFLAG := 'Y';
       IF T_CHK_LIQ1 = 'Y' OR T_CHK_SOL1 = 'Y' THEN
           T_POSYN := 'N';
       ELSE
           T_POSYN := 'P';
       END IF;
   END IF;
   
   IF T_DELFLAG = 'Y' THEN
       GOTO DELGUBN;
   END IF;
   
   IF T_LASTFLAG = 'Y' THEN   
       T_RSLT_STR := T_RSLT_STR || '---------------------------------------------------------------------' || CHR(13) || CHR(10);
       T_RSLT_STR := T_RSLT_STR || T_REPORT_STR; -- '보고의사: 송상훈/박경운/송정한 M.D.';
   END IF;
   
   --결과보고 생성 종료
   BEGIN
       UPDATE /*+ XSUP.PC_MSE_AFP_RSLT */
              MSELMAID
          SET EXRS_CNTE    = T_RSLT_STR
            , SPEX_PRGR_STS_CD    = DECODE(T_LASTFLAG||IN_POSYN, 'YN', '3', DECODE(IN_MDA_KIND, 'AA','3', 'AB', '3', 'BB', '3', '2'))
            , RSLT_BRFG_YN     = 'Y'
            , DLT_YN   = 'N'
            , PNC_YN   = 'N'
            , INPT_STF_NO       = IN_USERID
            , RSLT_MDF_DTM   = SYSDATE
--            , LSH_DTM     = SYSDATE
         	, LSH_STF_NO 		= IN_USERID
 			, LSH_DTM    		= SYSDATE
			, LSH_PRGM_NM		= IN_HIS_PRGM_NM
			, LSH_IP_ADDR		= IN_HIS_IP_ADDR
			
            , TH2_MDF_DTM   = DECODE(T_HST_FLAG, 'N', DECODE(T_REPLACEYN, 'Y', SYSDATE,
                                                     DECODE(T_REPORTTYPE, '1', SYSDATE, TH2_MDF_DTM)), '')
            , TH1_MDF_DTM   = DECODE(T_HST_FLAG, 'N',DECODE(T_LASTFLAG, 'Y',SYSDATE,TH1_MDF_DTM), '') 
            , BLOD_INCB_CTNR_NM      = DECODE(T_HST_FLAG, 'N',DECODE(T_UPDTETM_1, '', IN_MDA_KIND, BLOD_INCB_CTNR_NM), '')
            , HNWR_EXRS_CNTE = DECODE(T_LASTFLAG,'Y', DECODE(T_POSYN, 'P', TO_CHAR(SYSDATE, 'YYYYMMDD') || T_POSYN,
                                                                   'N', TO_CHAR(SYSDATE, 'YYYYMMDD') || T_POSYN, HNWR_EXRS_CNTE), HNWR_EXRS_CNTE)
       WHERE  SPCM_NO = IN_SPCNO
       AND    EXM_CD = IN_TSTCD  
       AND    HSP_TP_CD = IN_HIS_HSP_TP_CD;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := 'AFP CULTURE 내역이 없습니다. ERRCD = ' || TO_CHAR(SQLCODE); 
                RETURN;

           WHEN OTHERS  THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := 'AFP CULTURE 결과 저장 시 에러 발생4. ERRCD = ' || TO_CHAR(SQLCODE) || '   T_HST_FLAG  :    ' || T_HST_FLAG || '   T_REPLACEYN  :    ' || T_REPLACEYN || '   T_LASTFLAG  :    ' || T_LASTFLAG || '   IN_POSYN  :    ' || IN_POSYN || '   T_UPDTETM_1  :    ' || T_UPDTETM_1 || '   IN_MDA_KIND  :    ' || IN_MDA_KIND || '   T_REPORTTYPE  :    ' || T_REPORTTYPE ||'   T_RSLT_STR  :    ' ||  T_RSLT_STR;  
                RETURN;
   END;
   
   /**********************************************************************************************************
   ** 양성인 경우 양성리스트에 생성전 조회한다.
   ***********************************************************************************************************/
   BEGIN
        SELECT /*+ XSUP.PC_MSE_AFP_RSLT */
               /*+ FIRST_ROWS */
               SUBSTR(TO_CHAR(SYSDATE,'YYYYMMDD') || LPAD(NVL(MAX(TO_NUMBER(PSTV_ACPT_NO)) + 1,'1'),3,'0'),9,3)
          INTO T_ACPTNO
          FROM MSELMPLD A
             , MSELMCED B
         WHERE A.ACPT_DT    = TO_CHAR(SYSDATE,'YYYYMMDD')
           AND A.SPCM_NO    = B.SPCM_NO
           AND A.LABM_NEPO_TP_CD = IN_POSYN
           AND B.SPCM_NO      = IN_SPCNO  
           AND A.HSP_TP_CD    = IN_HIS_HSP_TP_CD
           AND B.HSP_TP_CD    = IN_HIS_HSP_TP_CD
         ;

   EXCEPTION
        WHEN OTHERS  THEN
             IO_ERRYN  := 'Y';
             IO_ERRMSG := '1 - 양성리스트 조회 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);
             RETURN;
   END;
   
   BEGIN
        SELECT /*+ XSUP.PC_MSE_AFP_RSLT */
               SPCM_NO
          INTO T_SPCNO2
          FROM MSELMPLD
         WHERE SPCM_NO  = IN_SPCNO 
           AND LABM_NEPO_TP_CD = IN_POSYN
           AND HSP_TP_CD       = IN_HIS_HSP_TP_CD;    
           
        EXCEPTION
        WHEN NO_DATA_FOUND THEN     
     /******************************************************************************************************
     ** 양성인 경우 양성리스트에 생성한다.
     *******************************************************************************************************/
               BEGIN
					INSERT /*+ XSUP.PC_MSE_AFP_RSLT */
					  INTO MSELMPLD 
					(
					 SPCM_NO
					,EXM_CD
					,INPT_SEQ
					,HSP_TP_CD
					,ACPT_DT
					,PSTV_ACPT_NO
					,LABM_NEPO_TP_CD
					,FSR_STF_NO
					,FSR_DTM
					,FSR_PRGM_NM
					,FSR_IP_ADDR
					,LSH_STF_NO
					,LSH_DTM
					,LSH_PRGM_NM
					,LSH_IP_ADDR    
					)

					SELECT A.SPCM_NO
					      ,B.EXM_CD
					      , (SELECT NVL(MAX(INPT_SEQ),0) + 1 FROM MSELMPLD WHERE SPCM_NO = IN_SPCNO AND EXM_CD = IN_TSTCD AND HSP_TP_CD = IN_HIS_HSP_TP_CD)
					      ,A.HSP_TP_CD
					      ,TRUNC(SYSDATE)
					      ,T_ACPTNO
					      ,IN_POSYN   
					      ,IN_USERID
					      ,sysdate
					      ,IN_HIS_PRGM_NM
					      ,IN_HIS_IP_ADDR
					      ,IN_USERID
					      ,sysdate
					      ,IN_HIS_PRGM_NM
					      ,IN_HIS_IP_ADDR
					  FROM MSELMCED A
					      ,MSELMAID B
					 WHERE A.SPCM_NO = B.SPCM_NO
					   AND B.EXM_CD  = IN_TSTCD
					   AND A.SPCM_NO = IN_SPCNO 
                       AND A.HSP_TP_CD = IN_HIS_HSP_TP_CD
                       AND B.HSP_TP_CD = IN_HIS_HSP_TP_CD;

               
               END;
              
   END;  
   
   /*********************************************************************************************************
   ** 상태를 변경한다. SL_STATUS.PC의 Source
   **********************************************************************************************************/
   IF T_LASTFLAG = 'Y' AND IN_POSYN = 'N' THEN
       BEGIN       
         
           PC_MSE_STATUS(  IN_SPCNO
                         , NULL -- 2019-05-09 지성원: 컴파일시 해당 프로시져 태울때 파라미터 정보 넘겨주지 않아 컴파일 오류발생하여 NULL로 던짐
                         , NULL -- 2019-05-09 지성원: 컴파일시 해당 프로시져 태울때 파라미터 정보 넘겨주지 않아 컴파일 오류발생하여 NULL로 던짐
                         , IN_USERID
                         , SYSDATE  
                         , IN_HIS_PRGM_NM  
                         , IN_HIS_IP_ADDR  
                         , IN_HIS_HSP_TP_CD
                         , IO_ERRYN
                         , IO_ERRMSG ) ;
           IF IO_ERRYN = 'Y' THEN
              IO_ERRYN  := 'Y';
              IO_ERRMSG := '결과 저장중 상태 변경하는 함수(PC_SL_STATUS) 호출... 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);  
              RETURN;
           END IF;
   
       END;
   ELSE
       BEGIN
           UPDATE /*+ XSUP.PC_MSE_AFP_RSLT */
                  MSELMCED
              SET EXM_PRGR_STS_CD = 'D'
                , BRFG_DTM        = SYSDATE 

      	        , LSH_STF_NO 		= IN_USERID
	 			, LSH_DTM    		= SYSDATE
				, LSH_PRGM_NM		= IN_HIS_PRGM_NM
				, LSH_IP_ADDR		= IN_HIS_IP_ADDR                
            WHERE SPCM_NO         = IN_SPCNO
              AND HSP_TP_CD       = IN_HIS_HSP_TP_CD;
   
       EXCEPTION
           WHEN  OTHERS  THEN
                 IO_ERRYN  := 'Y';
                 IO_ERRMSG := '검체상태정보 수정 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);   
                 RETURN;
       END;
       BEGIN
           UPDATE /*+ XSUP.PC_MSE_AFP_RSLT */
                  MOOOREXM
              SET EXM_PRGR_STS_CD = 'D'
                , BRFG_DTM = SYSDATE
                , LSH_DTM  = SYSDATE
				, LSH_STF_NO  = IN_USERID
				, LSH_PRGM_NM = IN_HIS_PRGM_NM
				, LSH_IP_ADDR = IN_HIS_IP_ADDR
            WHERE SPCM_PTHL_NO = IN_SPCNO
              AND ODDSC_TP_CD  = 'C'
              AND HSP_TP_CD    = IN_HIS_HSP_TP_CD;
   
       EXCEPTION
           WHEN  OTHERS  THEN
                 IO_ERRYN  := 'Y';
                 IO_ERRMSG := '해당 검체에 대한 처방정보 수정 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);     
                 RETURN;
       END;
   END IF;
   
   GOTO endproc; 
   
   <<delgubn>> 
   IF T_ALL_DELFLAG = 'Y' THEN
       BEGIN 
           DELETE /*+ XSUP.PC_MSE_AFP_RSLT */
                  MSELMCRD
            WHERE SPCM_NO = IN_SPCNO
              AND EXM_CD  = IN_TSTCD 
              AND HSP_TP_CD = IN_HIS_HSP_TP_CD; 
       END;
       
       BEGIN
          DELETE /*+ XSUP.PC_MSE_AFP_RSLT */
                 MSELMPLD
           WHERE SPCM_NO = IN_SPCNO 
             AND HSP_TP_CD = IN_HIS_HSP_TP_CD;
       END;
       
       BEGIN -- 2019-05-09 지성원 추가
            SELECT 'Y'
              INTO V_EEXM_YN -- 수탁여부(Y,N)
              FROM MSELMCED X
             WHERE X.HSP_TP_CD = IN_HIS_HSP_TP_CD
               AND X.SPCM_NO = IN_SPCNO
               AND NVL(X.EEXM_TP_CD, 'X') = 'S'
               AND ROWNUM = 1;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_EEXM_YN := 'N';
        END;
        
        --  2019-05-09 지성원 추가
        -- 수탁검사이면 
        IF NVL(V_EEXM_YN, 'N') = 'Y' THEN
            BEGIN
                DELETE /*+ XSUP.PC_MSE_AFP_RSLT */
                  FROM MSELMCRD
                WHERE SPCM_NO = IN_SPCNO
                  AND EXM_CD  = IN_TSTCD 
                  AND HSP_TP_CD = CASE IN_HIS_HSP_TP_CD WHEN '01' THEN '02' WHEN '02' THEN '01' ELSE IN_HIS_HSP_TP_CD END; 
            END;
        END IF;
       
       BEGIN
           UPDATE /*+ XSUP.PC_MSE_AFP_RSLT */
                  MSELMAID
              SET EXRS_CNTE    = ''   
                , SPEX_PRGR_STS_CD    = '1'
                , RSLT_BRFG_YN     = 'N'
                , DLT_YN      = 'N'
                , PNC_YN      = 'N'
                , INPT_STF_NO    = IN_USERID
                , RSLT_MDF_DTM     = ''
                , TH2_MDF_DTM   = ''
                , TH1_MDF_DTM   = ''
                , BLOD_INCB_CTNR_NM      = ''
                , HNWR_EXRS_CNTE = ''
                , TH2_EXRS_CNTE = ''        

       	        , LSH_STF_NO 		= IN_USERID
	 			, LSH_DTM    		= SYSDATE
				, LSH_PRGM_NM		= IN_HIS_PRGM_NM
				, LSH_IP_ADDR		= IN_HIS_IP_ADDR                
           WHERE  SPCM_NO = IN_SPCNO
           AND    EXM_CD = IN_TSTCD  
           AND    HSP_TP_CD = IN_HIS_HSP_TP_CD;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := 'AFP CULTURE 내역이 없습니다. ERRCD = ' || TO_CHAR(SQLCODE);
                RETURN;

           WHEN OTHERS  THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := 'AFP CULTURE 결과 저장 시 에러 발생5. ERRCD = ' || TO_CHAR(SQLCODE);
                RETURN;
       END;
   ELSE
       
       IF T_CHK_LIQ1 = 'Y' OR T_CHK_SOL1 = 'Y' THEN
           BEGIN
              DELETE /*+ XSUP.PC_MSE_AFP_RSLT */
                     MSELMPLD
               WHERE SPCM_NO = IN_SPCNO
                 AND LABM_NEPO_TP_CD = 'N' 
                 AND HSP_TP_CD = IN_HIS_HSP_TP_CD ;
           END;
       END IF;
       
       BEGIN
           UPDATE /*+ XSUP.PC_MSE_AFP_RSLT */
                  MSELMAID
              SET EXRS_CNTE        = T_RSLT_STR
                , SPEX_PRGR_STS_CD  = '2'
                , RSLT_BRFG_YN     = 'Y'
                , DLT_YN   = 'N'
                , PNC_YN   = 'N'
                , INPT_STF_NO       = IN_USERID
                , TH2_MDF_DTM   = DECODE(T_ALL_DELFLAG, 'P', TH1_MDF_DTM, TH2_MDF_DTM)
                , TH1_MDF_DTM   = ''
                , BLOD_INCB_CTNR_NM = DECODE(T_ALL_DELFLAG, 'N', BLOD_INCB_CTNR_NM, DECODE(IN_MDA_KIND,'CL','S'||SUBSTR(T_MDA_KIND,1,1),'CS','L'||SUBSTR(T_MDA_KIND,2,1),''))

       	        , LSH_STF_NO 		= IN_USERID
	 			, LSH_DTM    		= SYSDATE
				, LSH_PRGM_NM		= IN_HIS_PRGM_NM
				, LSH_IP_ADDR		= IN_HIS_IP_ADDR                
            WHERE SPCM_NO = IN_SPCNO
              AND EXM_CD  = IN_TSTCD  
              AND HSP_TP_CD  = IN_HIS_HSP_TP_CD;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := 'AFP CULTURE 내역이 없습니다. ERRCD = ' || TO_CHAR(SQLCODE);
                RETURN;

           WHEN OTHERS  THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := 'AFP CULTURE 결과 저장 시 에러 발생6. ERRCD = ' || TO_CHAR(SQLCODE);
                RETURN;
       END;
   END IF;
   
   BEGIN
       PC_MSE_STATUS(  IN_SPCNO
                     , NULL -- 2019-05-09 지성원: 컴파일시 해당 프로시져 태울때 파라미터 정보 넘겨주지 않아 컴파일 오류발생하여 NULL로 던짐
                     , NULL -- 2019-05-09 지성원: 컴파일시 해당 프로시져 태울때 파라미터 정보 넘겨주지 않아 컴파일 오류발생하여 NULL로 던짐
                     , IN_USERID
                     , SYSDATE  
                     , IN_HIS_PRGM_NM  
                     , IN_HIS_IP_ADDR  
                     , IN_HIS_HSP_TP_CD       
                     , IO_ERRYN
                     , IO_ERRMSG ) ;
       IF IO_ERRYN = 'Y' THEN
          IO_ERRYN  := 'Y';
          IO_ERRMSG := '결과 저장중 상태 변경하는 함수(PC_SL_STATUS) 호출... 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);   
          RETURN;
       END IF;
   END;
   
   GOTO endproc;
   
   
   <<lastcert>>
   BEGIN
       UPDATE /*+ XSUP.PC_MSE_AFP_RSLT */
              MSELMAID
          SET SPEX_PRGR_STS_CD    = '3'
            , INPT_STF_NO       = IN_USERID    
            
   	        , LSH_STF_NO 		= IN_USERID
			, LSH_DTM    		= SYSDATE
			, LSH_PRGM_NM		= IN_HIS_PRGM_NM
			, LSH_IP_ADDR		= IN_HIS_IP_ADDR             
       WHERE  SPCM_NO = IN_SPCNO
       AND    EXM_CD  = IN_TSTCD  
       AND HSP_TP_CD  = IN_HIS_HSP_TP_CD;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := 'AFP CULTURE 내역이 없습니다. ERRCD = ' || TO_CHAR(SQLCODE);
                RETURN;

           WHEN OTHERS  THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := 'AFP CULTURE 결과 저장 시 에러 발생7. ERRCD = ' || TO_CHAR(SQLCODE);
                RETURN;
   END;
   BEGIN
       PC_MSE_STATUS(  IN_SPCNO
                     , NULL -- 2019-05-09 지성원: 컴파일시 해당 프로시져 태울때 파라미터 정보 넘겨주지 않아 컴파일 오류발생하여 NULL로 던짐
                     , NULL -- 2019-05-09 지성원: 컴파일시 해당 프로시져 태울때 파라미터 정보 넘겨주지 않아 컴파일 오류발생하여 NULL로 던짐
                     , IN_USERID
                     , SYSDATE  
                     , IN_HIS_PRGM_NM  
                     , IN_HIS_IP_ADDR  
                     , IN_HIS_HSP_TP_CD
                     , IO_ERRYN
                     , IO_ERRMSG ) ;
       IF IO_ERRYN = 'Y' THEN
          IO_ERRYN  := 'Y';
          IO_ERRMSG := '결과 저장중 상태 변경하는 함수(PC_SL_STATUS) 호출... 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);    
          RETURN;
       END IF;
   END;      
   
   <<endproc>>        
   IO_ERRYN := 'N';

END PC_MSE_AFP_RSLT;