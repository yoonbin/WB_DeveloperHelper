PACKAGE BODY      PKG_MSE_SPCMPTHL_BATCH
IS

/**********************************************************************************************
**                            PART : 진단검사의학과/병리과 배치관리                          **
***********************************************************************************************
*    서비스이름  : PC_MSE_LM_ALERT_BATCH
*    최초 작성일 : 2012.09.19   2018-07-17
*    최초 작성자 : 남수현,       이상수 
*    DESCRIPTION : 특정 검사결과가 있는 경우 EMR ALERT에 데이터를 등록한다. [매일 새벽에 한 번 처리한다.]
*    수 정 사 항 : 2016-09-08 김성룡 신규 검사코드 추가. 
*                 2018-07-17 이상수  동산병원 룰에 맞게 생성
**********************************************************************************************/
PROCEDURE PC_MSE_LM_ALERT_BATCH ( HIS_HSP_TP_CD      IN MSBIOBMD.HSP_TP_CD%TYPE
                                , HIS_PRGM_NM        IN MSBIOBMD.LSH_PRGM_NM%TYPE
                                , HIS_IP_ADDR        IN MSBIOBMD.LSH_IP_ADDR%TYPE
                                )

IS
    V_BLOD_RDY_STS_CD    MSBIOBRD.BLOD_RDY_STS_CD%TYPE;
    V_SYSDATE            DATE := TRUNC(SYSDATE) ;  --테스트를 위해 -1 처리함. 테스트후 -1 삭제 해야 함. 이상수 
    V_EXM_CD             MSELMEBM.EXM_CD%TYPE    := '';     
     IN_JOBDATE            VARCHAR2(100)                  :=TO_CHAR(SYSDATE-1,'YYYYMMDD'); 
    V_OR_CHECK_YN       VARCHAR2(1) := 'N';
    I_COUNT_AND         NUMBER      := 0;
    V_COUNT_AND         NUMBER      := 0; 
    
    V_PT_NO     PCTPCPAM_DAMO.PT_NO%TYPE;
    V_TRANS_YN     VARCHAR2(1) := 'N';
BEGIN   
 
 /* PC_DAY_ALL_BATCH_OTHERS 일배치 PROCEDURE 에서 사용 되고 파라메터도 받는 다. 파라메터 수정시 원무팀 문의 필요 [이상수]*/
 
   --검사결과가 POSITIVE,REACTIVE : 공기전파(A)- 결핵(A0040,A0020),수두/파종성대상포진(A0041,A0021),홍역(A0020),풍진(A0025)
   --                           : 혈액전파(B)- HIV(A0006), HBV(A0058), HCV(A0011), 매독(A0048)
   --                           : 접촉전파(C)- Rota Virus(A0032), A형간염(A0038), C.difficile(A0017),중증열성혈소판감소증후군(A0049)
   --                           : 비말전파(D)- Influenza(A0023), 백일해(A0046), 유행선이하선염(A0024), RSV호흡기융합체바이러스(A0043), 중증열성혈소판감소증후군(A0049)
    BEGIN
        FOR REC_TEXT IN
        (
        SELECT DISTINCT PT_NO
                      , HSP_TP_CD
                      , INFC_INF_CD
                      , INFC_NM
                      , ORD_ID
                      , LSH_IP_ADDR
                      , ACPT_DTM
                      , SMP_EXRS_CNTE
                      , EXM_CD
           FROM (
                  SELECT G.PT_NO
                       , C.SMP_EXRS_CNTE
                       , C.EXM_CD
                       , A.SCLS_COMN_CD_NM                               INFC_INF_CD
                       ,(SELECT ALERT_INF_MRK_ABBR_NM
                           FROM MOOPTICC -- 감염임신수유정보코드
                          WHERE 1=1
                            AND HSP_TP_CD= A.HSP_TP_CD
                            AND ALERT_INF_ICLS_YN = 'Y'
                            AND INFC_INF_CD = A.SCLS_COMN_CD_NM)         INFC_NM
                       , C.ORD_ID
                       , A.HSP_TP_CD
                       , C.LSH_IP_ADDR
                       , C.ACPT_DTM                                      ACPT_DTM
                    FROM MSELMSID A
                       , MSELMAID C
                       , PCTPCPAM_DAMO G
                       , MOOOREXM H
                   WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                     AND A.HSP_TP_CD = C.HSP_TP_CD
                     AND A.HSP_TP_CD = H.HSP_TP_CD
                     AND A.USE_YN = 'Y'
                     AND C.RSLT_BRFG_YN = 'Y'
                     AND C.SPCM_NO = H.SPCM_PTHL_NO
                     AND C.PT_NO = G.PT_NO
                     AND C.PT_NO = H.PT_NO
                     AND C.ORD_ID = H.ORD_ID
                     AND A.LCLS_COMN_CD = 'TEXT'        -- SCLS_COMN_CD = 균코드 , SCLS_COMN_CD_NM = ALERT코드 (A0028등), TH1_RMK_CNTE = 항생제분류 , LCLS_COMN_CD = ANTI
                     AND H.ODDSC_TP_CD = 'C'
                     AND C.LST_RSLT_VRFC_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
                     AND REPLACE(UPPER(C.SMP_EXRS_CNTE),' ','') LIKE CASE WHEN A.TH1_RMK_CNTE = 'POSITIVE' THEN '%' ||REPLACE(UPPER(A.TH1_RMK_CNTE),' ','') || '%'
                                                                          ELSE REPLACE(UPPER(A.TH1_RMK_CNTE),' ','') || '%'
                                                                      END
                     AND A.SCLS_COMN_CD = C.ORD_CD
                     AND A.TH2_RMK_CNTE IS NULL --검체코드
                     AND A.TH3_RMK_CNTE IS NULL --판넬 내부검사 
                     UNION ALL

                     SELECT G.PT_NO
                       , C.SMP_EXRS_CNTE
                       , C.EXM_CD
                       , A.SCLS_COMN_CD_NM                               INFC_INF_CD
                       ,(SELECT ALERT_INF_MRK_ABBR_NM
                           FROM MOOPTICC -- 감염임신수유정보코드
                          WHERE 1=1
                            AND HSP_TP_CD= A.HSP_TP_CD
                            AND ALERT_INF_ICLS_YN = 'Y'
                            AND INFC_INF_CD = A.SCLS_COMN_CD_NM)         INFC_NM
                       , C.ORD_ID
                       , A.HSP_TP_CD
                       , C.LSH_IP_ADDR
                       , C.ACPT_DTM                                      ACPT_DTM
                    FROM MSELMSID A
                       , MSELMAID C
                       , PCTPCPAM_DAMO G
                       , MOOOREXM H
                   WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                     AND A.HSP_TP_CD = C.HSP_TP_CD
                     AND A.HSP_TP_CD = H.HSP_TP_CD
                     AND A.USE_YN = 'Y'
                     AND C.RSLT_BRFG_YN = 'Y'
                     AND C.SPCM_NO = H.SPCM_PTHL_NO
                     AND C.PT_NO = G.PT_NO
                     AND C.PT_NO = H.PT_NO
                     AND C.ORD_ID = H.ORD_ID
                     AND A.LCLS_COMN_CD = 'TEXT'        -- SCLS_COMN_CD = 균코드 , SCLS_COMN_CD_NM = ALERT코드 (A0028등), TH1_RMK_CNTE = 항생제분류 , LCLS_COMN_CD = ANTI
                     AND H.ODDSC_TP_CD = 'C'
                     AND C.LST_RSLT_VRFC_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
                     AND REPLACE(UPPER(C.SMP_EXRS_CNTE),' ','') LIKE CASE WHEN A.TH1_RMK_CNTE = 'POSITIVE' THEN '%' ||REPLACE(UPPER(A.TH1_RMK_CNTE),' ','') || '%'
                                                                          ELSE REPLACE(UPPER(A.TH1_RMK_CNTE),' ','') || '%'
                                                                      END
                     AND A.SCLS_COMN_CD = C.ORD_CD
                     AND A.TH2_RMK_CNTE = C.TH1_SPCM_CD
                     AND A.TH2_RMK_CNTE IS NOT NULL   --검체코드       
                     AND A.TH3_RMK_CNTE IS NULL      --판넬 내부 검사
                     
                    UNION ALL      --판넬검사 안에서 특정 검사코드만 양성일때 연동하려면 TH3_RMK_CNTE에 해당 검사코드를 넣음.

                     SELECT G.PT_NO
                       , C.SMP_EXRS_CNTE
                       , C.EXM_CD
                       , A.SCLS_COMN_CD_NM                               INFC_INF_CD
                       ,(SELECT ALERT_INF_MRK_ABBR_NM
                           FROM MOOPTICC -- 감염임신수유정보코드
                          WHERE 1=1
                            AND HSP_TP_CD= A.HSP_TP_CD
                            AND ALERT_INF_ICLS_YN = 'Y'
                            AND INFC_INF_CD = A.SCLS_COMN_CD_NM)         INFC_NM
                       , C.ORD_ID
                       , A.HSP_TP_CD
                       , C.LSH_IP_ADDR
                       , C.ACPT_DTM                                      ACPT_DTM
                    FROM MSELMSID A
                       , MSELMAID C
                       , PCTPCPAM_DAMO G
                       , MOOOREXM H
                   WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                     AND A.HSP_TP_CD = C.HSP_TP_CD
                     AND A.HSP_TP_CD = H.HSP_TP_CD
                     AND A.USE_YN = 'Y'
                     AND C.RSLT_BRFG_YN = 'Y'
                     AND C.SPCM_NO = H.SPCM_PTHL_NO
                     AND C.PT_NO = G.PT_NO
                     AND C.PT_NO = H.PT_NO
                     AND C.ORD_ID = H.ORD_ID
                     AND A.LCLS_COMN_CD = 'TEXT'        -- SCLS_COMN_CD = 균코드 , SCLS_COMN_CD_NM = ALERT코드 (A0028등), TH1_RMK_CNTE = 항생제분류 , LCLS_COMN_CD = ANTI
                     AND H.ODDSC_TP_CD = 'C'
                     AND C.LST_RSLT_VRFC_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
                     AND REPLACE(UPPER(C.SMP_EXRS_CNTE),' ','') LIKE CASE WHEN A.TH1_RMK_CNTE = 'POSITIVE' THEN '%' ||REPLACE(UPPER(A.TH1_RMK_CNTE),' ','') || '%'
                                                                          ELSE REPLACE(UPPER(A.TH1_RMK_CNTE),' ','') || '%'
                                                                      END
                     AND A.SCLS_COMN_CD = C.ORD_CD 
                     AND A.TH3_RMK_CNTE = C.EXM_CD
                     AND A.TH2_RMK_CNTE = C.TH1_SPCM_CD
                     AND A.TH2_RMK_CNTE IS NOT NULL   --검체코드          
                     AND A.TH3_RMK_CNTE IS NOT NULL                                
                )
        )
        LOOP
             BEGIN
                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC_TEXT.PT_NO              -- 01. 환자번호
                                                             , NULL                   -- 02. 환자감염임신수유등록순번
                                                             , REC_TEXT.HSP_TP_CD          -- 03. 병원구분코드
                                                             , REC_TEXT.INFC_INF_CD        -- 04. 감염임신수유코드
                                                             , NULL                   -- 05. 삭제사유내용
                                                             , NULL                   -- 06. 비고내용
                                                             , 'I'                    -- 07. alert작업구분코드
                                                             , 'SSUP04'                -- 08. 작업자직원번호
                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
                                                             , REC_TEXT.LSH_IP_ADDR        -- 10. 작업PC_IP
                                                             , REC_TEXT.ORD_ID             -- 11. 관련처방ID
                                                             , 'R001'                    -- 12. 자동등록구분코드
                                                             , REC_TEXT.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )
                                                             ) ;
             END;
        END LOOP;
    END;  
    --검사결과에 숫자가 포함될 경우 : HIV(A0006), HBV(A0058), HCV(A0011)
    BEGIN
        FOR REC_NUM IN
        (
        SELECT DISTINCT PT_NO
                      , HSP_TP_CD
                      , INFC_INF_CD
                      , INFC_NM
                      , ORD_ID
                      , LSH_IP_ADDR
                      , ACPT_DTM
                      , SMP_EXRS_CNTE
                      , EXM_CD
           FROM (
                  SELECT G.PT_NO
                       , C.SMP_EXRS_CNTE
                       , C.EXM_CD
                       , A.SCLS_COMN_CD_NM                               INFC_INF_CD
                       ,(SELECT ALERT_INF_MRK_ABBR_NM
                           FROM MOOPTICC -- 감염임신수유정보코드
                          WHERE 1=1
                            AND HSP_TP_CD= A.HSP_TP_CD
                            AND ALERT_INF_ICLS_YN = 'Y'
                            AND INFC_INF_CD = A.SCLS_COMN_CD_NM)         INFC_NM
                       , C.ORD_ID
                       , A.HSP_TP_CD
                       , C.LSH_IP_ADDR
                       , C.ACPT_DTM                                      ACPT_DTM
                    FROM MSELMSID A
                       , MSELMAID C
                       , PCTPCPAM_DAMO G
                       , MOOOREXM H
                   WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                     AND A.HSP_TP_CD = C.HSP_TP_CD
                     AND A.HSP_TP_CD = H.HSP_TP_CD
                     AND A.USE_YN = 'Y'
                     AND C.RSLT_BRFG_YN = 'Y'
                     AND C.SPCM_NO = H.SPCM_PTHL_NO
                     AND C.PT_NO = G.PT_NO
                     AND C.PT_NO = H.PT_NO
                     AND C.ORD_ID = H.ORD_ID
                     AND A.LCLS_COMN_CD = 'NUMBER'        -- SCLS_COMN_CD = 균코드 , SCLS_COMN_CD_NM = ALERT코드 (A0028등), TH1_RMK_CNTE = 항생제분류 , LCLS_COMN_CD = ANTI
                     AND H.ODDSC_TP_CD = 'C'
                     AND C.LST_RSLT_VRFC_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
                     AND REGEXP_LIKE(C.SMP_EXRS_CNTE,'[0-9]')
                     AND A.SCLS_COMN_CD = C.EXM_CD
                )
        )
        LOOP
             BEGIN
                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC_NUM.PT_NO              -- 01. 환자번호
                                                             , NULL                   -- 02. 환자감염임신수유등록순번
                                                             , REC_NUM.HSP_TP_CD          -- 03. 병원구분코드
                                                             , REC_NUM.INFC_INF_CD        -- 04. 감염임신수유코드
                                                             , NULL                   -- 05. 삭제사유내용
                                                             , NULL                   -- 06. 비고내용
                                                             , 'I'                    -- 07. alert작업구분코드
                                                             , 'SSUP04'                -- 08. 작업자직원번호
                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
                                                             , REC_NUM.LSH_IP_ADDR        -- 10. 작업PC_IP
                                                             , REC_NUM.ORD_ID             -- 11. 관련처방ID
                                                             , 'R001'                    -- 12. 자동등록구분코드
                                                             , REC_NUM.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )
                                                             ) ;
             END;
        END LOOP;
    END;                  
    --균 : C.difficile(A0017),콜레라(A0033), 장티푸스(A0034),파라티푸스(A0035),세균성이질(A0036),장출혈성대장균 감염증(A0037), 디프테리아(A0054),백일해(A0046)
    BEGIN
        FOR REC_VAC IN
        (
        SELECT DISTINCT PT_NO
                      , HSP_TP_CD
                      , INFC_INF_CD
                      , INFC_NM
                      , ORD_ID
                      , LSH_IP_ADDR
                      , ACPT_DTM
                      , SMP_EXRS_CNTE
                      , EXM_CD
           FROM (
                  SELECT G.PT_NO
                       , C.SMP_EXRS_CNTE
                       , C.EXM_CD
                       , A.SCLS_COMN_CD_NM                               INFC_INF_CD
                       ,(SELECT ALERT_INF_MRK_ABBR_NM
                           FROM MOOPTICC -- 감염임신수유정보코드
                          WHERE 1=1
                            AND HSP_TP_CD= A.HSP_TP_CD
                            AND ALERT_INF_ICLS_YN = 'Y'
                            AND INFC_INF_CD = A.SCLS_COMN_CD_NM)         INFC_NM
                       , C.ORD_ID
                       , A.HSP_TP_CD
                       , C.LSH_IP_ADDR
                       , C.ACPT_DTM                                      ACPT_DTM
                    FROM MSELMSID A
                       , MSELMAID C
                       , MSELMCRD D
                       , PCTPCPAM_DAMO G
                       , MOOOREXM H
                   WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                     AND A.HSP_TP_CD = C.HSP_TP_CD
                     AND A.HSP_TP_CD = H.HSP_TP_CD
                     AND A.HSP_TP_CD = D.HSP_TP_CD
                     AND A.USE_YN = 'Y'
                     AND C.RSLT_BRFG_YN = 'Y'
                     AND C.SPCM_NO = H.SPCM_PTHL_NO
                     AND C.SPCM_NO = D.SPCM_NO
                     AND C.PT_NO = G.PT_NO
                     AND C.PT_NO = H.PT_NO
                     AND C.ORD_ID = H.ORD_ID
                     AND A.LCLS_COMN_CD = 'VAC'        -- SCLS_COMN_CD = 균코드 , SCLS_COMN_CD_NM = ALERT코드 (A0028등), TH1_RMK_CNTE = 항생제분류 , LCLS_COMN_CD = ANTI
                     AND H.ODDSC_TP_CD = 'C'
                     AND A.TH1_RMK_CNTE = D.MVM_CD
                     AND C.LST_RSLT_VRFC_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
                     AND A.SCLS_COMN_CD = C.EXM_CD
                )
        )
        LOOP
             BEGIN
                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC_VAC.PT_NO              -- 01. 환자번호
                                                             , NULL                   -- 02. 환자감염임신수유등록순번
                                                             , REC_VAC.HSP_TP_CD          -- 03. 병원구분코드
                                                             , REC_VAC.INFC_INF_CD        -- 04. 감염임신수유코드
                                                             , NULL                   -- 05. 삭제사유내용
                                                             , NULL                   -- 06. 비고내용
                                                             , 'I'                    -- 07. alert작업구분코드
                                                             , 'SSUP04'                -- 08. 작업자직원번호
                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
                                                             , REC_VAC.LSH_IP_ADDR        -- 10. 작업PC_IP
                                                             , REC_VAC.ORD_ID             -- 11. 관련처방ID
                                                             , 'R001'                    -- 12. 자동등록구분코드
                                                             , REC_VAC.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )
                                                             ) ;
             END;
        END LOOP;
    END;    
   --다제내성균 : MRAB(A0029), MRPA(A0028), MRSA(A0013), VISA(A0059) , VRSA(A0060), VRE(A0014), CRE(A0030), CRAB(A0062), CRPA(A0063)
    BEGIN
    	/*ALERT 연동기준 최초 초기화*/
    	BEGIN
    		UPDATE MSELMSID
    		  SET TH3_RMK_CNTE = 'N'
    		  WHERE HSP_TP_CD = HIS_HSP_TP_CD
    		    AND LCLS_COMN_CD = 'ANTI_LN'
    		    AND USE_YN = 'Y'
    		    AND CRE_SEQ <> 0
    		    ;
    	END;
    	BEGIN
    		FOR REC_ANTI IN
    		(
              SELECT
                   C.HSP_TP_CD,A.SCLS_COMN_CD_NM,G.PT_NO, A.TH1_RMK_CNTE,A.TH2_RMK_CNTE,E.ATBA_SSBT_RSLT_CNTE,C.ACPT_DTM,H.ORD_ID
                 , H.ORD_CD
                 , C.LSH_IP_ADDR
              FROM MSELMAID C
                 , MSELMSID A
                 , MSELMCRD D
                 , MSELMMRD E
                 , MSELMSID F
                 , PCTPCPAM_DAMO G
                 , MOOOREXM H
               WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                 AND A.HSP_TP_CD = C.HSP_TP_CD
                 AND A.HSP_TP_CD = D.HSP_TP_CD
                 AND A.HSP_TP_CD = E.HSP_TP_CD
                 AND A.HSP_TP_CD = F.HSP_TP_CD
                 AND A.HSP_TP_CD = H.HSP_TP_CD
                 AND A.USE_YN = F.USE_YN
                 AND A.USE_YN = 'Y'
                 AND C.RSLT_BRFG_YN = 'Y'
                 AND D.LN_SEQ = E.LN_SEQ
                 AND C.SPCM_NO = D.SPCM_NO
                 AND C.SPCM_NO = E.SPCM_NO
                 AND C.PT_NO = G.PT_NO
                 AND C.SPCM_NO = H.SPCM_PTHL_NO
                 AND C.PT_NO = H.PT_NO
                 AND C.ORD_ID = H.ORD_ID
                 AND D.EXM_CD = C.EXM_CD
                 AND A.LCLS_COMN_CD = 'ANTI'
                 AND F.LCLS_COMN_CD = 'ANTI_GUBN'
                 AND A.LCLS_COMN_CD = F.TH1_RMK_CNTE
                 AND A.TH1_RMK_CNTE = F.SCLS_COMN_CD_NM
                 AND A.SCLS_COMN_CD = D.MVM_CD
                 AND F.SCLS_COMN_CD = E.ATBA_CD
                 AND H.ODDSC_TP_CD = 'C'
                 AND C.LST_RSLT_VRFC_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
                 AND EXISTS(SELECT 1
                              FROM MOOPTICC X
                             WHERE X.HSP_TP_CD = A.HSP_TP_CD
                               AND X.INFC_INF_CD = A.SCLS_COMN_CD_NM)
                               AND E.ATBA_SSBT_RSLT_CNTE IN (SELECT SCLS_COMN_CD
                                                               FROM MSELMSID
                                                              WHERE HSP_TP_CD = A.HSP_TP_CD
                                                                AND LCLS_COMN_CD = 'CULTURE_ATBASSBTJGMT'
                                                                AND USE_YN = 'Y'
                                                                )
               GROUP BY C.HSP_TP_CD,A.SCLS_COMN_CD_NM,G.PT_NO, A.TH1_RMK_CNTE,A.TH2_RMK_CNTE,E.ATBA_SSBT_RSLT_CNTE,C.ACPT_DTM,H.ORD_ID,H.ORD_CD,C.LSH_IP_ADDR
               ORDER BY PT_NO,SCLS_COMN_CD_NM
            )
    		LOOP
			    IF V_PT_NO = '' OR V_PT_NO IS NULL THEN --환자번호 초기화
			    	V_PT_NO := REC_ANTI.PT_NO    ;
			    END IF;  
			    
			    IF V_PT_NO = REC_ANTI.PT_NO THEN --환자번호가 같으면 ALERT와 항생제분류코드와 내성도가 같은지 확인 후 Y처리
    	          UPDATE MSELMSID
    	             SET TH3_RMK_CNTE = 'Y'
    	           WHERE HSP_TP_CD = HIS_HSP_TP_CD
    	             AND LCLS_COMN_CD = 'ANTI_LN'
    	             AND SCLS_COMN_CD = REC_ANTI.SCLS_COMN_CD_NM       --ALERT
    	             AND TH2_RMK_CNTE = REC_ANTI.ATBA_SSBT_RSLT_CNTE   --내성도
    	             AND TH1_RMK_CNTE = REC_ANTI.TH2_RMK_CNTE				  --항생제분류코드   
    	             AND USE_YN = 'Y'
    	             ;
	            ELSIF V_PT_NO <> REC_ANTI.PT_NO THEN
						BEGIN                        --환자번호가 달라지면 연동기준 초기화
							UPDATE MSELMSID
							  SET TH3_RMK_CNTE = 'N'
							  WHERE HSP_TP_CD = HIS_HSP_TP_CD
							    AND LCLS_COMN_CD = 'ANTI_LN'
							    AND USE_YN = 'Y'
							    AND CRE_SEQ <> 0
							    ;
						END;                   
						
						V_PT_NO := REC_ANTI.PT_NO ; --기준환자번호 변경 
						
						UPDATE MSELMSID
        	               SET TH3_RMK_CNTE = 'Y'
        	             WHERE HSP_TP_CD = HIS_HSP_TP_CD
        	               AND LCLS_COMN_CD = 'ANTI_LN'
        	               AND SCLS_COMN_CD = REC_ANTI.SCLS_COMN_CD_NM
        	               AND TH2_RMK_CNTE = REC_ANTI.ATBA_SSBT_RSLT_CNTE
        	               AND TH1_RMK_CNTE = REC_ANTI.TH2_RMK_CNTE      
        	               AND USE_YN = 'Y'
        	              ;
                END IF;
                
    		    BEGIN
        	          SELECT MIN(TH3_RMK_CNTE)                 --해당 ALERT 코드의 연동기준이 전부 Y인지 확인 . Y이면 연동
        	            INTO V_TRANS_YN
                        FROM MSELMSID
                       WHERE HSP_TP_CD = HIS_HSP_TP_CD
                         AND LCLS_COMN_CD = 'ANTI_LN'
                         AND SCLS_COMN_CD = REC_ANTI.SCLS_COMN_CD_NM 
                         AND UPPER(TH4_RMK_CNTE) = 'AND'
                         AND USE_YN = 'Y'
        	                 ;    	   
                END;
              
                IF V_TRANS_YN IS NULL THEN
                    BEGIN
                        SELECT MAX(TH3_RMK_CNTE)                 --해당 ALERT 코드의 연동기준이 하나라도 Y인지 확인 . Y이면 연동
                          INTO V_TRANS_YN
                          FROM MSELMSID
                         WHERE HSP_TP_CD = HIS_HSP_TP_CD
                           AND LCLS_COMN_CD = 'ANTI_LN'
                           AND SCLS_COMN_CD = REC_ANTI.SCLS_COMN_CD_NM
                           AND UPPER(TH4_RMK_CNTE) = 'OR'
                           AND USE_YN = 'Y'
                          ;
                    END;
                END IF; 
                --해당 ALERT코드의 상위 ALERT 코드가 이미 등록되어 있으면 전송 하지 않음 .               
                BEGIN
                      SELECT 'N'
                        INTO V_TRANS_YN
                        FROM(
                              SELECT *
                                FROM MOOPTIPD
                               WHERE HSP_TP_CD = REC_ANTI.HSP_TP_CD
                                 AND PT_NO = REC_ANTI.PT_NO
                                 AND NVL(DEL_YN,'N') = 'N'
                                 AND INFC_INF_CD = (SELECT TH5_RMK_CNTE
                                                      FROM MSELMSID
                                                     WHERE HSP_TP_CD = REC_ANTI.HSP_TP_CD
                                                       AND LCLS_COMN_CD = 'ANTI_LN'
                                                       AND SCLS_COMN_CD = REC_ANTI.SCLS_COMN_CD_NM
                                                       AND USE_YN = 'Y'
                                                       AND ROWNUM = 1)
                                ORDER BY PT_INFC_REG_SEQ DESC
                            )
                       WHERE ROWNUM = 1;
                EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                          NULL;
                END;                
                IF NVL(V_TRANS_YN,'N') = 'Y' THEN    							
				  BEGIN
                    XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC_ANTI.PT_NO              -- 01. 환자번호
                                                                 , NULL                   -- 02. 환자감염임신수유등록순번
                                                                 , REC_ANTI.HSP_TP_CD          -- 03. 병원구분코드
                                                                 , REC_ANTI.SCLS_COMN_CD_NM        -- 04. 감염임신수유코드
                                                                 , NULL                   -- 05. 삭제사유내용
                                                                 , NULL                   -- 06. 비고내용
                                                                 , 'I'                    -- 07. alert작업구분코드
                                                                 , 'SSUP04'                -- 08. 작업자직원번호
                                                                 , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
                                                                 , REC_ANTI.LSH_IP_ADDR        -- 10. 작업PC_IP
                                                                 , REC_ANTI.ORD_ID             -- 11. 관련처방ID
                                                                 , 'R001'                    -- 12. 자동등록구분코드
                                                                 , REC_ANTI.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )
                                                                 ) ;
				  END;
                END IF;
    		END LOOP;
    	END;
    END;
    --1. 혈액주의 : HBV(A0010), HCV(A0011), AIDS/HIV(A0006) , Syphilis(A0048), SFTS(A0046) ALERT 등록     --이상수 완료
--    BEGIN
--        FOR REC1  IN ( SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                             DISTINCT
--                             TRUNC(B.BRFG_DTM)      BRFG_DT
--                           , A.ALERT_CD             INFC_INF_CD
--                           , B.PT_NO                PT_NO
--                           , B.HSP_TP_CD            HSP_TP_CD
--                           , B.LSH_IP_ADDR          LSH_IP_ADDR
--                           , B.ORD_ID               ORD_ID
--                           , B.ACPT_DTM                ACPT_DTM
--                        FROM ( SELECT X.SCLS_COMN_CD    EXM_CD
--                                    , X.SCLS_COMN_CD_NM ALERT_CD
--                                    , UPPER(REPLACE(X.TH1_RMK_CNTE, ' ', ''))  EXRS_CNTE
--                                    , Y.EXRM_EXM_CTG_CD EXRM_EXM_CTG_CD
--                                 FROM MSELMSID X
--                                    , MSELMEBM Y
--                                WHERE X.LCLS_COMN_CD = 'LCLS008'
--                                  AND X.HSP_TP_CD    = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                                  AND X.USE_YN       = 'Y'
--                                  AND X.SORT_SEQ     = 1
--                                  AND Y.EXM_CD       = X.SCLS_COMN_CD
--                                  AND Y.HSP_TP_CD    = X.HSP_TP_CD
--                             ) A
--                           , MSELMCED B
--                           , MSELMAID C
--                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--                         AND C.RSLT_BRFG_YN = 'Y'
--                         AND B.EXRM_EXM_CTG_CD = A.EXRM_EXM_CTG_CD
--                         AND C.SPCM_NO         = B.SPCM_NO
--                         AND C.EXM_CD          = A.EXM_CD
--                         AND B.HSP_TP_CD       = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                         AND C.HSP_TP_CD       = B.HSP_TP_CD  --2017.04.17 LIM ADD
--                         AND UPPER(REPLACE(C.EXRS_CNTE, ' ', '')) LIKE REPLACE(UPPER(A.EXRS_CNTE), ' ', '') || '%'
--                   )
--        LOOP
--            BEGIN          
----    PROCEDURE PC_MOO_SAVE_INFECTIONITEM ( IN_PT_NO               IN VARCHAR2           --환자번호
----                                    , IN_PT_INFC_REG_SEQ     IN NUMBER             --환자감염임신수유등록순번
----                                    , IN_HIS_HSP_TP_CD       IN VARCHAR2           --병원구분코드
----                                    , IN_INFC_INF_CD         IN VARCHAR2           --감염임신수유코드
----                                    , IN_DEL_RSN_CNTE        IN VARCHAR2           --삭제사유내용
----                                    , IN_RMK_CNTE            IN VARCHAR2           --비고내용
----                                    , IN_ALERT_WORK_TYPE     IN VARCHAR2           --alert작업구분코드
----                                    , IN_HIS_STF_NO         IN VARCHAR2            --작업자직원번호
----                                    , IN_HIS_PRGM_NM     IN VARCHAR2               --작업프로그램내용
----                                    , IN_HIS_IP_ADDR     IN VARCHAR2               --작업PC_IP
----                                    , IN_RLV_ORD_ID      IN VARCHAR2                --관련처방ID
----                                    , IN_AUTO_REG_TP_CD    IN VARCHAR2          --자동등록구분코드
----                                    , IN_AUTO_REG_DT        IN DATE                   --자동등록일자
----                                                                        )
--          
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC1.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC1.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC1.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC1.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC1.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC1.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--            END;
--        END LOOP;
--        
--    END;            
--              
--    
--    --2. 공기주의 : 홍역(A0020), 수두(A0021), 결핵(A0002/A0040)  ALERT 등록    --이상수 신규 생성  완료
--    BEGIN
--        FOR REC2  IN ( SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                             DISTINCT
--                             TRUNC(B.BRFG_DTM)      BRFG_DT
--                           , A.ALERT_CD             INFC_INF_CD
--                           , B.PT_NO                PT_NO
--                           , B.HSP_TP_CD            HSP_TP_CD
--                           , B.LSH_IP_ADDR          LSH_IP_ADDR
--                           , B.ORD_ID               ORD_ID
--                           , B.ACPT_DTM                ACPT_DTM                           
--                        FROM ( SELECT X.SCLS_COMN_CD    EXM_CD
--                                    , X.SCLS_COMN_CD_NM ALERT_CD
--                                   -- , X.TH1_RMK_CNTE    EXRS_CNTE
--                                    , UPPER(REPLACE(X.TH1_RMK_CNTE, ' ', ''))  EXRS_CNTE
--                                    , Y.EXRM_EXM_CTG_CD EXRM_EXM_CTG_CD
--                                    , X.TH2_RMK_CNTE    TH1_SPCM_CD
--                                 FROM MSELMSID X
--                                    , MSELMEBM Y
--                                WHERE X.LCLS_COMN_CD = 'LCLS022'
--                                  AND X.HSP_TP_CD    = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                                  AND X.USE_YN       = 'Y'
--                                  AND X.SORT_SEQ     = 1
--                                  AND Y.EXM_CD       = X.SCLS_COMN_CD
--                                  AND Y.HSP_TP_CD    = X.HSP_TP_CD
--                             ) A
--                           , MSELMCED B
--                           , MSELMAID C
--                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--                         AND C.RSLT_BRFG_YN = 'Y'
--                         AND B.EXRM_EXM_CTG_CD = A.EXRM_EXM_CTG_CD
--                         AND B.TH1_SPCM_CD     = NVL(A.TH1_SPCM_CD, B.TH1_SPCM_CD)
--                         AND C.SPCM_NO         = B.SPCM_NO
--                         AND C.EXM_CD          = A.EXM_CD
--                         AND B.HSP_TP_CD       = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                         AND C.HSP_TP_CD       = B.HSP_TP_CD  --2017.04.17 LIM ADD
--                    --     AND INSTR(UPPER(REPLACE(C.EXRS_CNTE, ' ', '')), A.EXRS_CNTE) > 0
--                         AND UPPER(REPLACE(C.EXRS_CNTE, ' ', '')) LIKE  UPPER(A.EXRS_CNTE) || '%'
--                   )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC2.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC2.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC2.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC2.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC2.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC2.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--            END;
--        END LOOP;
--        
--    END;     
--    
--    
--    -- 3. 비말주의 1 (LCLS025) : 유행성이하선염(A0024), 풍진(A0025),  백일해(A0046) , 인플루엔자(A0023)   --이상수 신규 생성  완료
--    
--    BEGIN
--        FOR REC3  IN ( SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                             DISTINCT
--                             TRUNC(B.BRFG_DTM)      BRFG_DT
--                           , A.ALERT_CD             INFC_INF_CD
--                           , B.PT_NO                PT_NO
--                           , B.HSP_TP_CD            HSP_TP_CD
--                           , B.LSH_IP_ADDR          LSH_IP_ADDR
--                           , B.ORD_ID               ORD_ID  
--                           , B.ACPT_DTM                ACPT_DTM                             
--                        FROM ( SELECT X.SCLS_COMN_CD    EXM_CD
--                                    , X.SCLS_COMN_CD_NM ALERT_CD
--                                    --, X.TH1_RMK_CNTE    EXRS_CNTE
--                                    , UPPER(REPLACE(X.TH1_RMK_CNTE, ' ', ''))  EXRS_CNTE
--                                    , Y.EXRM_EXM_CTG_CD EXRM_EXM_CTG_CD
--                                 FROM MSELMSID X
--                                    , MSELMEBM Y
--                                WHERE X.LCLS_COMN_CD = 'LCLS025'
--                                  AND X.HSP_TP_CD    = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                                  AND X.USE_YN       = 'Y'
--                                  AND X.SORT_SEQ     = 1
--                                  AND Y.EXM_CD       = X.SCLS_COMN_CD
--                                  AND Y.HSP_TP_CD    = X.HSP_TP_CD
--                             ) A
--                           , MSELMCED B
--                           , MSELMAID C
--                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--                         AND C.RSLT_BRFG_YN = 'Y'
--                         AND B.EXRM_EXM_CTG_CD = A.EXRM_EXM_CTG_CD
--                         AND C.SPCM_NO         = B.SPCM_NO
--                         AND C.EXM_CD          = A.EXM_CD
--                         AND B.HSP_TP_CD       = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                         AND C.HSP_TP_CD       = B.HSP_TP_CD  --2017.04.17 LIM ADD
--                      --    AND INSTR(UPPER(REPLACE(C.EXRS_CNTE, ' ', '')), A.EXRS_CNTE) > 0
--                          AND UPPER(REPLACE(C.EXRS_CNTE, ' ', '')) LIKE UPPER(A.EXRS_CNTE) || '%'
--                   )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC3.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC3.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC3.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC3.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC3.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC3.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--            END;
--        END LOOP;
--        
--    END;          
--    
--     
--    -- 3. 비밀주의 2 (LCLS026) : 디프테리아(A0054), 성홍열(A0045), 수막구균성수막염(A0055) --이상수 신규 생성   완료
--      
--    BEGIN
--        FOR REC4 IN ( SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                             DISTINCT
--                             B.PT_NO                PT_NO
--                           , B.HSP_TP_CD            HSP_TP_CD
--                           , D.SCLS_COMN_CD_NM      INFC_INF_CD
--                           , B.LSH_IP_ADDR          LSH_IP_ADDR
--                           , B.ORD_ID               ORD_ID
--                           , B.ACPT_DTM                ACPT_DTM                           
--                        FROM  MSELMCED B
--                           , MSELMCRD C
--                           , MSELMSID D
--                           , MSELMAID E
--                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--                         AND E.RSLT_BRFG_YN = 'Y'
--                       --  AND B.EXRM_EXM_CTG_CD = 'L40' 
--                         AND B.TH1_SPCM_CD     = D.TH2_RMK_CNTE
--                         AND C.SPCM_NO         = B.SPCM_NO
--                         AND C.EXM_CD          = D.SCLS_COMN_CD 
--                         AND B.HSP_TP_CD       = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                         AND C.HSP_TP_CD       = B.HSP_TP_CD --2017.04.17 LIM ADD
--                         AND D.LCLS_COMN_CD = 'LCLS026'
--                         AND D.HSP_TP_CD    = C.HSP_TP_CD
--                         AND D.USE_YN       = 'Y'
--                         AND D.SORT_SEQ     = 1
--                         AND C.MVM_CD       = D.TH1_RMK_CNTE                               -- 2018.01.29 동정코드로 정의
--                         AND E.SPCM_NO      = C.SPCM_NO
--                         AND E.EXM_CD       = C.EXM_CD
--                         AND E.HSP_TP_CD    = C.HSP_TP_CD  --2017.04.17 LIM ADD
--                    )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC4.PT_NO              -- 01. 환자번호
--                                                             , NULL                    -- 02. 환자감염임신수유등록순번
--                                                             , REC4.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC4.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                    -- 05. 삭제사유내용
--                                                             , NULL                    -- 06. 비고내용
--                                                             , 'I'                     -- 07. alert작업구분코드
--                                                             , 'SSUP04'                 -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'    -- 09. 작업프로그램내용
--                                                             , REC4.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC4.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC4.ACPT_DTM            -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--            
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--
--            END;
--        END LOOP;
--    END;    
--          
--    -- 4. 기타감염 (LCLS027) : CJD(A0005), MERS(A0057)  --이상수 신규 생성  완료
--    
--    BEGIN
--        FOR REC5  IN ( SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                             DISTINCT
--                             TRUNC(B.BRFG_DTM)      BRFG_DT
--                           , A.ALERT_CD             INFC_INF_CD
--                           , B.PT_NO                PT_NO
--                           , B.HSP_TP_CD            HSP_TP_CD
--                           , B.LSH_IP_ADDR          LSH_IP_ADDR
--                           , B.ORD_ID               ORD_ID   
--                           , B.ACPT_DTM                ACPT_DTM                           
--                        FROM ( SELECT X.SCLS_COMN_CD    EXM_CD
--                                    , X.SCLS_COMN_CD_NM ALERT_CD
--                                    --, X.TH1_RMK_CNTE    EXRS_CNTE
--                                    , UPPER(REPLACE(X.TH1_RMK_CNTE, ' ', ''))  EXRS_CNTE
--                                    , Y.EXRM_EXM_CTG_CD EXRM_EXM_CTG_CD
--                                 FROM MSELMSID X
--                                    , MSELMEBM Y
--                                WHERE X.LCLS_COMN_CD = 'LCLS027'
--                                  AND X.HSP_TP_CD    = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                                  AND X.USE_YN       = 'Y'
--                                  AND X.SORT_SEQ     = 1
--                                  AND Y.EXM_CD       = X.SCLS_COMN_CD
--                                  AND Y.HSP_TP_CD    = X.HSP_TP_CD
--                             ) A
--                           , MSELMCED B
--                           , MSELMAID C
--                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--                         AND C.RSLT_BRFG_YN = 'Y'
--                         AND B.EXRM_EXM_CTG_CD = A.EXRM_EXM_CTG_CD
--                         AND C.SPCM_NO         = B.SPCM_NO
--                         AND C.EXM_CD          = A.EXM_CD
--                         AND B.HSP_TP_CD       = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                         AND C.HSP_TP_CD       = B.HSP_TP_CD  --2017.04.17 LIM ADD
--                         -- AND INSTR(UPPER(REPLACE(C.EXRS_CNTE, ' ', '')), A.EXRS_CNTE) > 0
--                          AND UPPER(REPLACE(C.SMP_EXRS_CNTE, ' ', '')) = UPPER(A.EXRS_CNTE)
--                   )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC5.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC5.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC5.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC5.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC5.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC5.ACPT_DTM            -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--            END;
--        END LOOP;
--        
--    END;      
--   
--   
--   -- 5. 접촉주의 1 (LCLS028) : 콜레라(A0033), 장티푸스(A0034), 파라티푸스(A0035), 세균성이질(A0036),  장출혈성대장균(A0037), HAV(A0038)--이상수 신규 생성   완료
--      
--    BEGIN
--        FOR REC6 IN ( SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                             DISTINCT
--                             B.PT_NO                PT_NO
--                           , B.HSP_TP_CD            HSP_TP_CD
--                           , D.SCLS_COMN_CD_NM      INFC_INF_CD
--                           , B.LSH_IP_ADDR          LSH_IP_ADDR
--                           , B.ORD_ID               ORD_ID
--                           , B.ACPT_DTM                ACPT_DTM                           
--                        FROM  MSELMCED B
--                           , MSELMCRD C
--                           , MSELMSID D
--                           , MSELMAID E
--                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--                         AND E.RSLT_BRFG_YN = 'Y'
--                      --   AND B.EXRM_EXM_CTG_CD = 'L40' 
--                         AND B.TH1_SPCM_CD     = D.TH2_RMK_CNTE
--                         AND C.SPCM_NO         = B.SPCM_NO
--                         AND C.EXM_CD          = D.SCLS_COMN_CD 
--                         AND B.HSP_TP_CD       = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                         AND C.HSP_TP_CD       = B.HSP_TP_CD --2017.04.17 LIM ADD
--                         AND D.LCLS_COMN_CD = 'LCLS028'
--                         AND D.HSP_TP_CD    = C.HSP_TP_CD
--                         AND D.USE_YN       = 'Y'
--                         AND D.SORT_SEQ     = 1
--                         AND C.MVM_CD       = D.TH1_RMK_CNTE                               -- 2018.01.29 동정코드로 정의
--                         AND E.SPCM_NO      = C.SPCM_NO
--                         AND E.EXM_CD       = C.EXM_CD
--                         AND E.HSP_TP_CD    = C.HSP_TP_CD  --2017.04.17 LIM ADD
--                    )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC6.PT_NO              -- 01. 환자번호
--                                                             , NULL                    -- 02. 환자감염임신수유등록순번
--                                                             , REC6.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC6.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                    -- 05. 삭제사유내용
--                                                             , NULL                    -- 06. 비고내용
--                                                             , 'I'                     -- 07. alert작업구분코드
--                                                             , 'SSUP04'                 -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'    -- 09. 작업프로그램내용
--                                                             , REC6.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC6.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC6.ACPT_DTM            -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--            
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--
--            END;
--        END LOOP;
--    END;    
--    
--   -- 5. 접촉주의 2 (LCLS028) : 콜레라(A0033), 장티푸스(A0034), 파라티푸스(A0035), 세균성이질(A0036),  장출혈성대장균(A0037), HAV(A0038)--이상수 신규 생성   완료
--   BEGIN
--        FOR REC7  IN ( SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                             DISTINCT
--                             TRUNC(B.BRFG_DTM)      BRFG_DT
--                           , A.ALERT_CD             INFC_INF_CD
--                           , B.PT_NO                PT_NO
--                           , B.HSP_TP_CD            HSP_TP_CD
--                           , B.LSH_IP_ADDR          LSH_IP_ADDR
--                           , B.ORD_ID               ORD_ID  
--                           , B.ACPT_DTM                ACPT_DTM                             
--                        FROM ( SELECT X.SCLS_COMN_CD    EXM_CD
--                                    , X.SCLS_COMN_CD_NM ALERT_CD
--                                    --, X.TH1_RMK_CNTE    EXRS_CNTE
--                                    , UPPER(REPLACE(X.TH1_RMK_CNTE, ' ', ''))  EXRS_CNTE
--                                    , Y.EXRM_EXM_CTG_CD EXRM_EXM_CTG_CD
--                                 FROM MSELMSID X
--                                    , MSELMEBM Y
--                                WHERE X.LCLS_COMN_CD = 'LCLS029'
--                                  AND X.HSP_TP_CD    = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                                  AND X.USE_YN       = 'Y'
--                                  AND X.SORT_SEQ     = 1
--                                  AND Y.EXM_CD       = X.SCLS_COMN_CD
--                                  AND Y.HSP_TP_CD    = X.HSP_TP_CD
--                             ) A
--                           , MSELMCED B
--                           , MSELMAID C
--                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--                         AND C.RSLT_BRFG_YN = 'Y'
--                         AND B.EXRM_EXM_CTG_CD = A.EXRM_EXM_CTG_CD
--                         AND C.SPCM_NO         = B.SPCM_NO
--                         AND C.EXM_CD          = A.EXM_CD
--                         AND B.HSP_TP_CD       = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                         AND C.HSP_TP_CD       = B.HSP_TP_CD  --2017.04.17 LIM ADD
--                        --  AND INSTR(UPPER(REPLACE(C.EXRS_CNTE, ' ', '')), A.EXRS_CNTE) > 0
--                        AND UPPER(REPLACE(C.EXRS_CNTE, ' ', '')) LIKE  UPPER(A.EXRS_CNTE) || '%'
--                   )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC7.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC7.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC7.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC7.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC7.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC7.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--            END;
--        END LOOP;
--        
--    END;            
    

 --접촉주의  MRPA(A0028), MRAB(A0029) 등록  이상수 완료. 
    /*
    A0029    "Acinetobacter baumannii
             Acinetobacter baumannii complex"
        
    A0028    Pseudomonas aeruginosa
        
    meropenem : R (or)
    imipenem : R (or)
    doripenem :R (or)
          &
    amikacin : R (or)
    gentamycin : R (or)
    Tobramycin : R (or)
          &
    ciprofloxacin :R (or)
    levofloxacin :R (or)
    */
-- 2020.06.29 실시간으로 변경    
--    BEGIN
--        FOR REC8 IN 
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                PT_NO
--                 , B.HSP_TP_CD            HSP_TP_CD
--                 , B.SPCM_NO              SPCM_NO
--                 , C.EXM_CD               EXM_CD
--                 , C.MVRT_CNTE            MVRT_CNTE
--                 , C.LN_SEQ               LN_SEQ
--                 , D.SCLS_COMN_CD         SCLS_COMN_CD
--                 , F.PACT_ID                            PACT_ID
--                 , F.PACT_TP_CD                            PACT_TP_CD
--                 , B.MED_DEPT_CD                        MED_DEPT_CD
--                 , F.PBSO_DEPT_CD                        PBSO_DEPT_CD
--                 , B.BLCL_DTM                            BLCL_DTM
--                 , B.ACPT_DTM                            ACPT_DTM
--                 , B.BRFG_DTM                            BRGF_DTM
--                 , E.TH1_SPCM_CD                        SPCM_CD
--                 , D.SCLS_COMN_CD_NM      INFC_INF_CD
--                 , B.LSH_IP_ADDR          LSH_IP_ADDR
--                 , B.ORD_ID               ORD_ID  
--                 , ( SELECT COUNT(*)
--                       FROM MSELMMRD Y
--                          , MSELMSID Z
--                      WHERE Y.SPCM_NO         = C.SPCM_NO
--                        AND Y.EXM_CD          = C.EXM_CD
--                        AND Y.LN_SEQ          = C.LN_SEQ
--                        AND Z.LCLS_COMN_CD    = D.TH2_RMK_CNTE
--                        AND Z.HSP_TP_CD       = HIS_HSP_TP_CD
--                        AND Z.USE_YN          = 'Y'
--                        AND Z.SCLS_COMN_CD_NM = 'OR1'
--                        AND Z.SCLS_COMN_CD    = Y.ATBA_CD
--                        AND Z.TH1_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                   )  OR1
--                 , ( SELECT COUNT(*)
--                       FROM MSELMMRD Y
--                          , MSELMSID Z
--                      WHERE Y.SPCM_NO         = C.SPCM_NO
--                        AND Y.EXM_CD          = C.EXM_CD
--                        AND Y.LN_SEQ          = C.LN_SEQ
--                        AND Z.LCLS_COMN_CD    = D.TH2_RMK_CNTE
--                        AND Z.HSP_TP_CD       = HIS_HSP_TP_CD
--                        AND Z.USE_YN          = 'Y'
--                        AND Z.SCLS_COMN_CD_NM = 'OR2'
--                        AND Z.SCLS_COMN_CD    = Y.ATBA_CD
--                        AND Z.TH1_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                   )  OR2
--                 , ( SELECT COUNT(*)
--                       FROM MSELMMRD Y
--                          , MSELMSID Z
--                      WHERE Y.SPCM_NO         = C.SPCM_NO
--                        AND Y.EXM_CD          = C.EXM_CD
--                        AND Y.LN_SEQ          = C.LN_SEQ
--                        AND Z.LCLS_COMN_CD    = D.TH2_RMK_CNTE
--                        AND Z.HSP_TP_CD       = HIS_HSP_TP_CD
--                        AND Z.USE_YN          = 'Y'
--                        AND Z.SCLS_COMN_CD_NM = 'OR3'
--                        AND Z.SCLS_COMN_CD    = Y.ATBA_CD
--                        AND Z.TH1_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                   )  OR3
--              FROM ( SELECT X.EXM_CD    EXM_CD
--                       FROM MSELMEBM X
--                      WHERE X.HSP_TP_CD        = HIS_HSP_TP_CD
--                        AND X.EXRM_EXM_CTG_CD  = 'L40'
--                   )        A
--                 , MSELMCED B
--                 , MSELMCRD C
--                 , MSELMSID D
--                 , MSELMAID E
--                 , MOOOREXM F
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--               AND E.RSLT_BRFG_YN = 'Y' 
--               AND E.SPEX_PRGR_STS_CD = '3' -- 2018-10-29 항생제 감수성 결과로 체크하는 결과는 최종보고된 결과로만 체크되도록 수정함. 이상수
--               AND E.EXRM_EXM_CTG_CD = 'L40'
--               AND C.SPCM_NO         = B.SPCM_NO
--               AND C.EXM_CD          = A.EXM_CD
--               AND EXISTS ( SELECT 1
--                              FROM MSELMMRD Z
--                             WHERE Z.SPCM_NO   = C.SPCM_NO
--                               AND Z.EXM_CD    = C.EXM_CD
--                               AND Z.LN_SEQ    = C.LN_SEQ
--                          )
--               AND D.LCLS_COMN_CD = 'LCLS100'
--               AND D.TH2_RMK_CNTE = 'LCLS101'
--               AND D.HSP_TP_CD    = C.HSP_TP_CD
--               AND D.USE_YN       = 'Y'
--               AND D.SORT_SEQ     = 1     
--               AND UPPER(REPLACE(C.MVRT_CNTE, ' ','')) LIKE REPLACE(UPPER(D.TH1_RMK_CNTE), ' ', '') || '%'
--               AND E.SPCM_NO      = C.SPCM_NO
--               AND E.EXM_CD       = C.EXM_CD
--               AND B.PT_NO = F.PT_NO
--               AND B.ORD_ID = F.ORD_ID
--               AND B.HSP_TP_CD = F.HSP_TP_CD  
--               AND B.HSP_TP_CD = HIS_HSP_TP_CD
--
--        )
--        LOOP
--            IF (REC8.OR1 > 0) AND (REC8.OR2 > 0) AND (REC8.OR3 > 0) THEN
--                BEGIN
--
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC8.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC8.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC8.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC8.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC8.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC8.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--              END;
--            END IF;  
--        END LOOP;
--        
--    END;   
    

--접촉주의  CRE(A0030) 등록  이상수 완료.
-- 2020.06.29 실시간으로 변경     
--    BEGIN
--        FOR REC9 IN 
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                PT_NO
--                 , B.HSP_TP_CD            HSP_TP_CD
--                 , B.SPCM_NO              SPCM_NO
--                 , C.EXM_CD               EXM_CD
--                 , C.MVRT_CNTE            MVRT_CNTE
--                 , C.LN_SEQ               LN_SEQ
--                 , D.SCLS_COMN_CD         SCLS_COMN_CD
--                 , F.PACT_ID                            PACT_ID
--                 , F.PACT_TP_CD                            PACT_TP_CD
--                 , B.MED_DEPT_CD                        MED_DEPT_CD
--                 , F.PBSO_DEPT_CD                        PBSO_DEPT_CD
--                 , B.BLCL_DTM                            BLCL_DTM
--                 , B.ACPT_DTM                            ACPT_DTM
--                 , B.BRFG_DTM                            BRGF_DTM
--                 , E.TH1_SPCM_CD                        SPCM_CD
--                 , D.SCLS_COMN_CD_NM      INFC_INF_CD
--                 , B.LSH_IP_ADDR          LSH_IP_ADDR
--                 , B.ORD_ID               ORD_ID  
--                 , ( SELECT COUNT(*)
--                       FROM MSELMMRD Y
--                          , MSELMSID Z
--                      WHERE Y.SPCM_NO         = C.SPCM_NO
--                        AND Y.EXM_CD          = C.EXM_CD
--                        AND Y.LN_SEQ          = C.LN_SEQ
--                        AND Z.LCLS_COMN_CD    = D.TH2_RMK_CNTE
--                        AND Z.HSP_TP_CD       = HIS_HSP_TP_CD
--                        AND Z.USE_YN          = 'Y'
--                        AND Z.SCLS_COMN_CD_NM = 'OR'
--                        AND Z.SCLS_COMN_CD    = Y.ATBA_CD
--                        AND Z.TH1_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                   )  OR1
--              FROM ( SELECT X.EXM_CD    EXM_CD
--                       FROM MSELMEBM X
--                      WHERE X.HSP_TP_CD        = HIS_HSP_TP_CD
--                        AND X.EXRM_EXM_CTG_CD  = 'L40'
--                   )        A
--                 , MSELMCED B
--                 , MSELMCRD C
--                 , MSELMSID D
--                 , MSELMAID E
--                 , MOOOREXM F
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--               AND E.RSLT_BRFG_YN = 'Y'     
--               AND E.SPEX_PRGR_STS_CD = '3' -- 2018-10-29 항생제 감수성 결과로 체크하는 결과는 최종보고된 결과로만 체크되도록 수정함. 이상수
--               AND B.EXRM_EXM_CTG_CD = 'L40'
--               AND C.SPCM_NO         = B.SPCM_NO
--               AND C.EXM_CD          = A.EXM_CD
--               AND EXISTS ( SELECT 1
--                              FROM MSELMMRD Z
--                             WHERE Z.SPCM_NO   = C.SPCM_NO
--                               AND Z.EXM_CD    = C.EXM_CD
--                               AND Z.LN_SEQ    = C.LN_SEQ
--                          )
--               AND D.LCLS_COMN_CD = 'LCLS100'
--               AND D.TH2_RMK_CNTE = 'LCLS103'
--               AND D.HSP_TP_CD    = C.HSP_TP_CD
--               AND D.USE_YN       = 'Y'
--               AND D.SORT_SEQ     = 1     
--              -- AND INSTR(UPPER(C.MVRT_CNTE), UPPER(D.TH1_RMK_CNTE)) > 0     
--               AND UPPER(REPLACE(C.MVRT_CNTE, ' ','')) LIKE REPLACE(UPPER(D.TH1_RMK_CNTE), ' ', '') || '%'
--               AND E.SPCM_NO      = C.SPCM_NO
--               AND E.EXM_CD       = C.EXM_CD
--               AND B.PT_NO = F.PT_NO
--               AND B.ORD_ID = F.ORD_ID
--               AND B.HSP_TP_CD = F.HSP_TP_CD  
--               AND B.HSP_TP_CD = HIS_HSP_TP_CD
--
--        )
--        LOOP
--            IF (REC9.OR1 > 0) THEN
--                BEGIN
--
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC9.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC9.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC9.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC9.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC9.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC9.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--              END;
--            END IF;  
--        END LOOP;
--        
--    END;      

--접촉주의  ESBL(A0051) 등록  이상수 완료.
-- 2020.06.29 실시간으로 변경     
--    BEGIN
--        FOR REC10 IN 
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                PT_NO
--                 , B.HSP_TP_CD            HSP_TP_CD
--                 , B.SPCM_NO              SPCM_NO
--                 , C.EXM_CD               EXM_CD
--                 , C.MVRT_CNTE            MVRT_CNTE
--                 , C.LN_SEQ               LN_SEQ
--                 , D.SCLS_COMN_CD         SCLS_COMN_CD
--                 , F.PACT_ID                            PACT_ID
--                 , F.PACT_TP_CD                            PACT_TP_CD
--                 , B.MED_DEPT_CD                        MED_DEPT_CD
--                 , F.PBSO_DEPT_CD                        PBSO_DEPT_CD
--                 , B.BLCL_DTM                            BLCL_DTM
--                 , B.ACPT_DTM                            ACPT_DTM
--                 , B.BRFG_DTM                            BRGF_DTM
--                 , E.TH1_SPCM_CD                        SPCM_CD
--                 , D.SCLS_COMN_CD_NM      INFC_INF_CD
--                 , B.LSH_IP_ADDR          LSH_IP_ADDR
--                 , B.ORD_ID               ORD_ID  
--                 , ( SELECT COUNT(*)
--                       FROM MSELMMRD Y
--                          , MSELMSID Z
--                      WHERE Y.SPCM_NO         = C.SPCM_NO
--                        AND Y.EXM_CD          = C.EXM_CD
--                        AND Y.LN_SEQ          = C.LN_SEQ
--                        AND Z.LCLS_COMN_CD    = D.TH2_RMK_CNTE
--                        AND Z.HSP_TP_CD       = HIS_HSP_TP_CD
--                        AND Z.USE_YN          = 'Y'
--                        AND Z.SCLS_COMN_CD_NM = 'OR'
--                        AND Z.SCLS_COMN_CD    = Y.ATBA_CD
--                        AND Z.TH1_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                   )  OR1
--              FROM ( SELECT X.EXM_CD    EXM_CD
--                       FROM MSELMEBM X
--                      WHERE X.HSP_TP_CD        = HIS_HSP_TP_CD
--                        AND X.EXRM_EXM_CTG_CD  = 'L40'
--                   )        A
--                 , MSELMCED B
--                 , MSELMCRD C
--                 , MSELMSID D
--                 , MSELMAID E
--                 , MOOOREXM F
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--               AND E.RSLT_BRFG_YN = 'Y' 
--               AND E.SPEX_PRGR_STS_CD = '3' -- 2018-10-29 항생제 감수성 결과로 체크하는 결과는 최종보고된 결과로만 체크되도록 수정함. 이상수
--               AND B.EXRM_EXM_CTG_CD = 'L40'
--               AND C.SPCM_NO         = B.SPCM_NO
--               AND C.EXM_CD          = A.EXM_CD
--               AND EXISTS ( SELECT 1
--                              FROM MSELMMRD Z
--                             WHERE Z.SPCM_NO   = C.SPCM_NO
--                               AND Z.EXM_CD    = C.EXM_CD
--                               AND Z.LN_SEQ    = C.LN_SEQ
--                          )
--               AND D.LCLS_COMN_CD = 'LCLS100'
--               AND D.TH2_RMK_CNTE = 'LCLS106'
--               AND D.HSP_TP_CD    = C.HSP_TP_CD
--               AND D.USE_YN       = 'Y'
--               AND D.SORT_SEQ     = 1     
--              -- AND INSTR(UPPER(C.MVRT_CNTE), UPPER(D.TH1_RMK_CNTE)) > 0
--              AND UPPER(REPLACE(C.MVRT_CNTE, ' ','')) LIKE REPLACE(UPPER(D.TH1_RMK_CNTE), ' ', '') || '%'
--               AND E.SPCM_NO      = C.SPCM_NO
--               AND E.EXM_CD       = C.EXM_CD
--               AND B.PT_NO = F.PT_NO
--               AND B.ORD_ID = F.ORD_ID
--               AND B.HSP_TP_CD = F.HSP_TP_CD  
--               AND B.HSP_TP_CD = HIS_HSP_TP_CD
--
--        )
--        LOOP
--            IF (REC10.OR1 > 0) THEN
--                BEGIN
--
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC10.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC10.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC10.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC10.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC10.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC10.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--              END;
--            END IF;  
--        END LOOP;
--        
--    END;  
               
--접촉주의  VRSA, VISA (A0031) 등록  이상수 완료.
-- 2020.06.29 실시간으로 변경     
--    BEGIN
--        FOR REC11 IN 
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                PT_NO
--                 , B.HSP_TP_CD            HSP_TP_CD
--                 , B.SPCM_NO              SPCM_NO
--                 , C.EXM_CD               EXM_CD
--                 , C.MVRT_CNTE            MVRT_CNTE
--                 , C.LN_SEQ               LN_SEQ
--                 , D.SCLS_COMN_CD         SCLS_COMN_CD
--                 , F.PACT_ID                            PACT_ID
--                 , F.PACT_TP_CD                            PACT_TP_CD
--                 , B.MED_DEPT_CD                        MED_DEPT_CD
--                 , F.PBSO_DEPT_CD                        PBSO_DEPT_CD
--                 , B.BLCL_DTM                            BLCL_DTM
--                 , B.ACPT_DTM                            ACPT_DTM
--                 , B.BRFG_DTM                            BRGF_DTM
--                 , E.TH1_SPCM_CD                        SPCM_CD
--                 , D.SCLS_COMN_CD_NM      INFC_INF_CD
--                 , B.LSH_IP_ADDR          LSH_IP_ADDR
--                 , B.ORD_ID               ORD_ID  
--                 , ( SELECT COUNT(*)
--                       FROM MSELMMRD Y
--                          , MSELMSID Z
--                      WHERE Y.SPCM_NO         = C.SPCM_NO
--                        AND Y.EXM_CD          = C.EXM_CD
--                        AND Y.LN_SEQ          = C.LN_SEQ
--                        AND Z.LCLS_COMN_CD    = D.TH2_RMK_CNTE
--                        AND Z.HSP_TP_CD       = HIS_HSP_TP_CD
--                        AND Z.USE_YN          = 'Y'
--                        AND Z.SCLS_COMN_CD_NM = 'OR'
--                        AND Z.SCLS_COMN_CD    = Y.ATBA_CD
--                        AND Z.TH1_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                   )  OR1
--              FROM ( SELECT X.EXM_CD    EXM_CD
--                       FROM MSELMEBM X
--                      WHERE X.HSP_TP_CD        = HIS_HSP_TP_CD
--                        AND X.EXRM_EXM_CTG_CD  = 'L40'
--                   )        A
--                 , MSELMCED B
--                 , MSELMCRD C
--                 , MSELMSID D
--                 , MSELMAID E
--                 , MOOOREXM F
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----              WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--               AND E.RSLT_BRFG_YN = 'Y'
--               AND B.EXRM_EXM_CTG_CD = 'L40'
--               AND C.SPCM_NO         = B.SPCM_NO
--               AND C.EXM_CD          = A.EXM_CD
--               AND E.SPEX_PRGR_STS_CD = '3' -- 2018-10-29 항생제 감수성 결과로 체크하는 결과는 최종보고된 결과로만 체크되도록 수정함. 이상수
--               AND EXISTS ( SELECT 1
--                              FROM MSELMMRD Z
--                             WHERE Z.SPCM_NO   = C.SPCM_NO
--                               AND Z.EXM_CD    = C.EXM_CD
--                               AND Z.LN_SEQ    = C.LN_SEQ
--                          )
--               AND D.LCLS_COMN_CD = 'LCLS100'
--               AND D.TH2_RMK_CNTE = 'LCLS104'
--               AND D.HSP_TP_CD    = C.HSP_TP_CD
--               AND D.USE_YN       = 'Y'
--               AND D.SORT_SEQ     = 1     
--              -- AND INSTR(UPPER(C.MVRT_CNTE), UPPER(D.TH1_RMK_CNTE)) > 0
--               AND UPPER(REPLACE(C.MVRT_CNTE, ' ','')) LIKE REPLACE(UPPER(D.TH1_RMK_CNTE), ' ', '') || '%'
--               AND E.SPCM_NO      = C.SPCM_NO
--               AND E.EXM_CD       = C.EXM_CD
--               AND B.PT_NO = F.PT_NO
--               AND B.ORD_ID = F.ORD_ID
--               AND B.HSP_TP_CD = F.HSP_TP_CD  
--               AND B.HSP_TP_CD = HIS_HSP_TP_CD
--
--        )
--        LOOP
--            IF (REC11.OR1 > 0) THEN
--                BEGIN
--
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC11.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC11.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC11.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC11.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC11.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC11.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--              END;
--            END IF;  
--        END LOOP;
--        
--    END;     
    
--접촉주의  VRE (A0014) 등록  이상수 완료.
-- 2020.06.29 실시간으로 변경     
--    BEGIN
--        FOR REC12 IN 
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                PT_NO
--                 , B.HSP_TP_CD            HSP_TP_CD
--                 , B.SPCM_NO              SPCM_NO
--                 , C.EXM_CD               EXM_CD
--                 , C.MVRT_CNTE            MVRT_CNTE
--                 , C.LN_SEQ               LN_SEQ
--                 , D.SCLS_COMN_CD         SCLS_COMN_CD
--                 , F.PACT_ID                            PACT_ID
--                 , F.PACT_TP_CD                            PACT_TP_CD
--                 , B.MED_DEPT_CD                        MED_DEPT_CD
--                 , F.PBSO_DEPT_CD                        PBSO_DEPT_CD
--                 , B.BLCL_DTM                            BLCL_DTM
--                 , B.ACPT_DTM                            ACPT_DTM
--                 , B.BRFG_DTM                            BRGF_DTM
--                 , E.TH1_SPCM_CD                        SPCM_CD
--                 , D.SCLS_COMN_CD_NM      INFC_INF_CD
--                 , B.LSH_IP_ADDR          LSH_IP_ADDR
--                 , B.ORD_ID               ORD_ID  
--                 , ( SELECT COUNT(*)
--                       FROM MSELMMRD Y
--                          , MSELMSID Z
--                      WHERE Y.SPCM_NO         = C.SPCM_NO
--                        AND Y.EXM_CD          = C.EXM_CD
--                        AND Y.LN_SEQ          = C.LN_SEQ
--                        AND Z.LCLS_COMN_CD    = D.TH2_RMK_CNTE
--                        AND Z.HSP_TP_CD       = HIS_HSP_TP_CD
--                        AND Z.USE_YN          = 'Y'
--                        AND Z.SCLS_COMN_CD_NM = 'OR'
--                        AND Z.SCLS_COMN_CD    = Y.ATBA_CD
--                        AND Z.TH1_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                   )  OR1
--              FROM ( SELECT X.EXM_CD    EXM_CD
--                       FROM MSELMEBM X
--                      WHERE X.HSP_TP_CD        = HIS_HSP_TP_CD
--                        AND X.EXRM_EXM_CTG_CD  = 'L40'
--                   )        A
--                 , MSELMCED B
--                 , MSELMCRD C
--                 , MSELMSID D
--                 , MSELMAID E
--                 , MOOOREXM F
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--               AND E.RSLT_BRFG_YN = 'Y'
--               AND E.SPEX_PRGR_STS_CD = '3' -- 2018-10-29 항생제 감수성 결과로 체크하는 결과는 최종보고된 결과로만 체크되도록 수정함. 이상수
--               AND B.EXRM_EXM_CTG_CD = 'L40'
--               AND C.SPCM_NO         = B.SPCM_NO
--               AND C.EXM_CD          = A.EXM_CD
--               AND EXISTS ( SELECT 1
--                              FROM MSELMMRD Z
--                             WHERE Z.SPCM_NO   = C.SPCM_NO
--                               AND Z.EXM_CD    = C.EXM_CD
--                               AND Z.LN_SEQ    = C.LN_SEQ
--                          )
--               AND D.LCLS_COMN_CD = 'LCLS100'
--               AND D.TH2_RMK_CNTE = 'LCLS105'
--               AND D.HSP_TP_CD    = C.HSP_TP_CD
--               AND D.USE_YN       = 'Y'
--               AND D.SORT_SEQ     = 1     
--              -- AND INSTR(UPPER(C.MVRT_CNTE), UPPER(D.TH1_RMK_CNTE)) > 0
--              AND UPPER(REPLACE(C.MVRT_CNTE, ' ','')) LIKE REPLACE(UPPER(D.TH1_RMK_CNTE), ' ', '') || '%'
--               AND E.SPCM_NO      = C.SPCM_NO
--               AND E.EXM_CD       = C.EXM_CD
--               AND B.PT_NO  = F.PT_NO
--               AND B.ORD_ID = F.ORD_ID
--               AND B.HSP_TP_CD = F.HSP_TP_CD  
--               AND B.HSP_TP_CD = HIS_HSP_TP_CD
--
--        )
--        LOOP
--            IF (REC12.OR1 > 0) THEN
--                BEGIN
--
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC12.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC12.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC12.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC12.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC12.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC12.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--              END;
--            END IF;  
--        END LOOP;
--        
--    END;  
    
     
--접촉주의  MRSA (A0013) 등록  이상수 완료.
-- 2020.06.29 실시간으로 변경     
--    BEGIN
--        FOR REC13 IN 
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                PT_NO
--                 , B.HSP_TP_CD            HSP_TP_CD
--                 , B.SPCM_NO              SPCM_NO
--                 , C.EXM_CD               EXM_CD
--                 , C.MVRT_CNTE            MVRT_CNTE
--                 , C.LN_SEQ               LN_SEQ
--                 , D.SCLS_COMN_CD         SCLS_COMN_CD
--                 , F.PACT_ID                            PACT_ID
--                 , F.PACT_TP_CD                            PACT_TP_CD
--                 , B.MED_DEPT_CD                        MED_DEPT_CD
--                 , F.PBSO_DEPT_CD                        PBSO_DEPT_CD
--                 , B.BLCL_DTM                            BLCL_DTM
--                 , B.ACPT_DTM                            ACPT_DTM
--                 , B.BRFG_DTM                            BRGF_DTM
--                 , E.TH1_SPCM_CD                        SPCM_CD
--                 , D.SCLS_COMN_CD_NM      INFC_INF_CD
--                 , B.LSH_IP_ADDR          LSH_IP_ADDR
--                 , B.ORD_ID               ORD_ID  
--                 , ( SELECT COUNT(*)
--                       FROM MSELMMRD Y
--                          , MSELMSID Z
--                      WHERE Y.SPCM_NO         = C.SPCM_NO
--                        AND Y.EXM_CD          = C.EXM_CD
--                        AND Y.LN_SEQ          = C.LN_SEQ
--                        AND Z.LCLS_COMN_CD    = D.TH2_RMK_CNTE
--                        AND Z.HSP_TP_CD       = HIS_HSP_TP_CD
--                        AND Z.USE_YN          = 'Y'
--                        AND Z.SCLS_COMN_CD_NM = 'OR'
--                        AND Z.SCLS_COMN_CD    = Y.ATBA_CD
--                        AND Z.TH1_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                   )  OR1
--              FROM ( SELECT X.EXM_CD    EXM_CD
--                       FROM MSELMEBM X
--                      WHERE X.HSP_TP_CD        = HIS_HSP_TP_CD
--                        AND X.EXRM_EXM_CTG_CD  = 'L40'
--                   )        A
--                 , MSELMCED B
--                 , MSELMCRD C
--                 , MSELMSID D
--                 , MSELMAID E
--                 , MOOOREXM F
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--               AND E.RSLT_BRFG_YN = 'Y'  
--               AND E.SPEX_PRGR_STS_CD = '3' -- 2018-10-29 항생제 감수성 결과로 체크하는 결과는 최종보고된 결과로만 체크되도록 수정함. 이상수
--               AND B.EXRM_EXM_CTG_CD = 'L40'
--               AND C.SPCM_NO         = B.SPCM_NO
--               AND C.EXM_CD          = A.EXM_CD
--               AND EXISTS ( SELECT 1
--                              FROM MSELMMRD Z
--                             WHERE Z.SPCM_NO   = C.SPCM_NO
--                               AND Z.EXM_CD    = C.EXM_CD
--                               AND Z.LN_SEQ    = C.LN_SEQ
--                          )
--               AND D.LCLS_COMN_CD = 'LCLS100'
--               AND D.TH2_RMK_CNTE = 'LCLS102'
--               AND D.HSP_TP_CD    = C.HSP_TP_CD
--               AND D.USE_YN       = 'Y'
--               AND D.SORT_SEQ     = 1     
--              -- AND INSTR(UPPER(C.MVRT_CNTE), UPPER(D.TH1_RMK_CNTE)) > 0
--              AND UPPER(REPLACE(C.MVRT_CNTE, ' ','')) LIKE REPLACE(UPPER(D.TH1_RMK_CNTE), ' ','') || '%'
--               AND E.SPCM_NO      = C.SPCM_NO
--               AND E.EXM_CD       = C.EXM_CD
--               AND B.PT_NO = F.PT_NO
--               AND B.ORD_ID = F.ORD_ID
--               AND B.HSP_TP_CD = F.HSP_TP_CD  
--               AND B.HSP_TP_CD = HIS_HSP_TP_CD
--
--        )
--        LOOP
--            IF (REC13.OR1 > 0) THEN
--                BEGIN
--
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC13.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC13.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC13.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC13.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC13.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC13.ACPT_DTM                -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--              END;
--            END IF;  
--        END LOOP;
--        
--    END;   
    
    
    
--접촉주의  : CD(A0017), ROTA(A0032), 호흡기세포융합바이러스(A0043), 노로바이러스(A0052) 등록  이상수 완료.   
-- 2020.06.29 실시간으로 변경   
--    BEGIN
--        FOR REC14  IN ( SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                             DISTINCT
--                             TRUNC(B.BRFG_DTM)      BRFG_DT
--                           , A.ALERT_CD             INFC_INF_CD
--                           , B.PT_NO                PT_NO
--                           , B.HSP_TP_CD            HSP_TP_CD
--                           , B.LSH_IP_ADDR          LSH_IP_ADDR
--                           , B.ORD_ID               ORD_ID   
--                           , B.ACPT_DTM                ACPT_DTM                           
--                        FROM ( SELECT X.SCLS_COMN_CD    EXM_CD
--                                    , X.SCLS_COMN_CD_NM ALERT_CD
--                                    --, X.TH1_RMK_CNTE    EXRS_CNTE
--                                    , UPPER(REPLACE(X.TH1_RMK_CNTE, ' ', ''))  EXRS_CNTE
--                                    , Y.EXRM_EXM_CTG_CD EXRM_EXM_CTG_CD
--                                 FROM MSELMSID X
--                                    , MSELMEBM Y
--                                WHERE X.LCLS_COMN_CD = 'LCLS200'
--                                  AND X.HSP_TP_CD    = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                                  AND X.USE_YN       = 'Y'
--                                  AND X.SORT_SEQ     = 1
--                                  AND Y.EXM_CD       = X.SCLS_COMN_CD
--                                  AND Y.HSP_TP_CD    = X.HSP_TP_CD
--                             ) A
--                           , MSELMCED B
--                           , MSELMAID C
--                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
----                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 20 AND V_SYSDATE  + 0.99999
--                         AND C.RSLT_BRFG_YN = 'Y'
--                         AND B.EXRM_EXM_CTG_CD = A.EXRM_EXM_CTG_CD
--                         AND C.SPCM_NO         = B.SPCM_NO
--                         AND C.EXM_CD          = A.EXM_CD
--                         AND B.HSP_TP_CD       = HIS_HSP_TP_CD --2017.04.17 LIM ADD
--                         AND C.HSP_TP_CD       = B.HSP_TP_CD  --2017.04.17 LIM ADD
--                          AND INSTR(UPPER(REPLACE(C.EXRS_CNTE, ' ', '')), REPLACE(UPPER(A.EXRS_CNTE), ' ', '') ) > 0 
--                      --  AND UPPER(REPLACE(C.EXRS_CNTE, ' ','')) LIKE REPLACE(UPPER(A.EXRS_CNTE), ' ', '') || '%'
--                   )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC14.PT_NO              -- 01. 환자번호
--                                                             , NULL                   -- 02. 환자감염임신수유등록순번
--                                                             , REC14.HSP_TP_CD          -- 03. 병원구분코드
--                                                             , REC14.INFC_INF_CD        -- 04. 감염임신수유코드
--                                                             , NULL                   -- 05. 삭제사유내용
--                                                             , NULL                   -- 06. 비고내용         
--                                                             , 'I'                    -- 07. alert작업구분코드
--                                                             , 'SSUP04'                -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'   -- 09. 작업프로그램내용
--                                                             , REC14.LSH_IP_ADDR        -- 10. 작업PC_IP
--                                                             , REC14.ORD_ID             -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC14.ACPT_DTM            -- 13. 자동등록일자( = 양성검체접수일 )                                                             
--                                                             ) ;
--
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--            END;
--        END LOOP;
--        
--    END;    
               
--    -- VISA, VRSA, MRPA, MRAB, CRE (다제내성균:A0016) 등록
--    BEGIN
--        FOR REC2 IN ( SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                             B.PT_NO                PT_NO
--                           , B.HSP_TP_CD            HSP_TP_CD
--                           , B.SPCM_NO              SPCM_NO
--                           , C.EXM_CD               EXM_CD
--                           , C.MVRT_CNTE            MVRT_CNTE
--                           , C.LN_SEQ               LN_SEQ
--                           , D.SCLS_COMN_CD         SCLS_COMN_CD
--                           , D.SCLS_COMN_CD_NM      INFC_INF_CD
--                           , B.LSH_IP_ADDR          LSH_IP_ADDR
--                           , B.ORD_ID               ORD_ID
--                           , B.ACPT_DTM                ACPT_DTM
--                           , ( SELECT COUNT(*)
--                                 FROM MSELMSID Z
--                                WHERE Z.LCLS_COMN_CD = 'LCLS010'
--                                  AND Z.HSP_TP_CD    = '08'
--                                  AND Z.USE_YN         = 'Y'
--                                  AND Z.SCLS_COMN_CD_NM = D.SCLS_COMN_CD
--                                  AND Z.TH3_RMK_CNTE    = 'AND'
--                             )  AND_ALL_CNT
--                           , ( SELECT COUNT(*)
--                                 FROM MSELMMRD Y
--                                    , MSELMSID Z
--                                WHERE Y.SPCM_NO      = C.SPCM_NO
--                                  AND Y.EXM_CD       = C.EXM_CD
--                                  AND Y.LN_SEQ       = C.LN_SEQ
--                                  AND Z.LCLS_COMN_CD = 'LCLS010'
--                                  AND Z.HSP_TP_CD    = '08'
--                                  AND Z.USE_YN         = 'Y'
--                                  AND Z.SCLS_COMN_CD_NM = D.SCLS_COMN_CD
--                                  AND Z.TH1_RMK_CNTE    = Y.ATBA_CD
--                                  AND Z.TH2_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                                  AND Z.TH3_RMK_CNTE    = 'OR'
--                             )  OR_CNT
--                           , ( SELECT COUNT(*)
--                                 FROM MSELMMRD Y
--                                    , MSELMSID Z
--                                WHERE Y.SPCM_NO      = C.SPCM_NO
--                                  AND Y.EXM_CD       = C.EXM_CD
--                                  AND Y.LN_SEQ       = C.LN_SEQ
--                                  AND Z.LCLS_COMN_CD = 'LCLS010'
--                                  AND Z.HSP_TP_CD    = '08'
--                                  AND Z.USE_YN         = 'Y'
--                                  AND Z.SCLS_COMN_CD_NM = D.SCLS_COMN_CD
--                                  AND Z.TH1_RMK_CNTE    = Y.ATBA_CD
--                                  AND Z.TH2_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                                  AND Z.TH3_RMK_CNTE    = 'AND'
--                             )  AND_CNT
--                        FROM ( SELECT X.SCLS_COMN_CD    EXM_CD
--                                 FROM MSELMSID X
--                                WHERE X.LCLS_COMN_CD = 'LCLS008'
--                                  AND X.HSP_TP_CD    = '08'
--                                  AND X.USE_YN       = 'Y'
--                                  AND X.SORT_SEQ     = 2
--                             )        A
--                           , MSELMCED B
--                           , MSELMCRD C
--                           , MSELMSID D
--                           , MSELMAID E
--                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999
--                         AND B.EXM_PRGR_STS_CD = 'N'
--                         AND B.EXRM_EXM_CTG_CD = 'L40'
--                         AND C.SPCM_NO         = B.SPCM_NO
--                         AND C.EXM_CD          = A.EXM_CD 
--                         AND EXISTS ( SELECT 1
--                                        FROM MSELMMRD Z
--                                       WHERE Z.SPCM_NO   = C.SPCM_NO
--                                         AND Z.EXM_CD    = C.EXM_CD
--                                         AND Z.LN_SEQ    = C.LN_SEQ
--                                    )
--                         AND D.LCLS_COMN_CD = 'LCLS009'
--                         AND D.HSP_TP_CD    = C.HSP_TP_CD
--                         AND D.USE_YN       = 'Y'
--                         AND D.SORT_SEQ     = 2
--                         AND INSTR(UPPER(C.MVRT_CNTE), UPPER(D.TH1_RMK_CNTE)) > 0
--                         AND E.SPCM_NO      = C.SPCM_NO
--                         AND E.EXM_CD       = C.EXM_CD
--                    )
--        LOOP
--            IF REC2.OR_CNT > 0 AND REC2.AND_ALL_CNT = REC2.AND_CNT THEN
--            BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC2.PT_NO               -- 01. 환자번호
--                                                             , NULL                     -- 02. 환자감염임신수유등록순번
--                                                             , REC2.HSP_TP_CD           -- 03. 병원구분코드
--                                                             , REC2.INFC_INF_CD         -- 04. 감염임신수유코드
--                                                             , NULL                     -- 05. 삭제사유내용
--                                                             , NULL                     -- 06. 비고내용
--                                                             , 'I'                      -- 07. alert작업구분코드
--                                                             , 'SSUP04'                  -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'     -- 09. 작업프로그램내용
--                                                             , REC2.LSH_IP_ADDR         -- 10. 작업PC_IP
--                                                             , REC2.ORD_ID                -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC2.ACPT_DTM            -- 13. 자동등록일자( = 양성검체접수일 )
--                                                             ) ;
--        
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--
--            END;
--            END IF;
--        END LOOP;
--    END;   
--    
--    -- 다제내성균(CRE, VRE) surveillance 검사결과 201607-00764 2016-09-08 김성룡 추가
--    BEGIN
--        FOR REC3 IN ( SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                             B.PT_NO                PT_NO
--                           , B.HSP_TP_CD            HSP_TP_CD
--                           , B.SPCM_NO              SPCM_NO
--                           , C.EXM_CD               EXM_CD
--                           , A.TH2_RMK_CNTE         INFC_INF_CD
--                           , B.LSH_IP_ADDR          LSH_IP_ADDR
--                           , B.ORD_ID               ORD_ID
--                           , B.ACPT_DTM                ACPT_DTM
--                        FROM ( SELECT X.SCLS_COMN_CD    EXM_CD 
--                                    , X.TH1_RMK_CNTE    TH1_RMK_CNTE
--                                    , X.TH2_RMK_CNTE    TH2_RMK_CNTE
--                                 FROM MSELMSID X
--                                WHERE X.LCLS_COMN_CD = 'LCLS011'
--                                  AND X.HSP_TP_CD    = '08'
--                                  AND X.USE_YN       = 'Y'                                                             
--                             )        A
--                           , MSELMCED B
----                           , MSELMSID D
--                           , MSELMAID C
--                       WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 AND V_SYSDATE - 1 + 0.99999 --    trunc(SYSDATE) - 1000 AND trunc(SYSDATE) - 1000 + 0.99999
--                         AND B.EXM_PRGR_STS_CD = 'N'
--                         AND B.EXRM_EXM_CTG_CD = 'L40'
--                         AND C.SPCM_NO         = B.SPCM_NO
--                         AND C.EXM_CD          = A.EXM_CD 
----                         AND D.LCLS_COMN_CD = 'LCLS009'
----                         AND D.HSP_TP_CD    = C.HSP_TP_CD
----                         AND D.USE_YN       = 'Y'
----                         AND D.SORT_SEQ     = 2
--                         AND INSTR(UPPER(C.EXRS_CNTE), UPPER(A.TH1_RMK_CNTE)) <= 0
--                    )
--        LOOP
--           BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC3.PT_NO               -- 01. 환자번호
--                                                             , NULL                     -- 02. 환자감염임신수유등록순번
--                                                             , REC3.HSP_TP_CD           -- 03. 병원구분코드
--                                                             , REC3.INFC_INF_CD         -- 04. 감염임신수유코드
--                                                             , NULL                     -- 05. 삭제사유내용
--                                                             , NULL                     -- 06. 비고내용
--                                                             , 'I'                      -- 07. alert작업구분코드
--                                                             , 'SSUP04'                  -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'     -- 09. 작업프로그램내용
--                                                             , REC3.LSH_IP_ADDR         -- 10. 작업PC_IP
--                                                             , REC3.ORD_ID              -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC3.ACPT_DTM            -- 13. 자동등록일자( = 양성검체접수일 )
--                                                             ) ;
--        
--                EXCEPTION
--                    WHEN  OTHERS  THEN
--                        NULL;
--
--            END;
--        END LOOP;
--    END;
--    
--    -- Infection Alert 자동등록 - 2017.12.12 박은기 추가
--    ---------------------- Infection Alert 자동등록 주석 예시 -----------------------
--    -- 감염항목 : 간호 감염코드 (진단검사 공통코드)
--    --  * 검사명 : 컴사코드    (검사실코드)
--    ---------------------------------------------------------------------------------
--    
--    -------------------------------- 전파종류 : 접촉 --------------------------------
--    -- C. difficile : A0017 (LCLS012)
--    --  * C. difficile toxin A, B    : L404421    (L40)
--    ---------------------------------------------------------------------------------    
--    -- 로타바이러스 : A0032 (LCLS013)
--    --  * rotavirus Ag(Stool)                    : L504318    (L50)
--    --  * Acute Diarrhea (Virus 4종) [분자진단]    : L25118    (L25)
--    --  * Acute Diarrhea (Virus 3종) [분자진단]    : L25154    (L25)
--    ---------------------------------------------------------------------------------
--    -- 콜레라            : A0033    (LCLS014)
--    -- 세균성이질        : A0036    (LCLS017)
--    -- 장출혈성대장균    : A0037    (LCLS018)
--    --  * Gastrointestinal specimen culture & susceptibility    : L4023        (L40)
--    --  * Acute Diarrhea (Bacteria 5종) [분자진단]                : L25153    (L25)
--    --  * Acute Diarrhea (Bacteria 12종) [분자진단]                : L25116    (L25)
--    ---------------------------------------------------------------------------------
--    -- 장티푸스 : A0034 (LCLS015)
--    --  * Gastrointestinal specimen culture & susceptibility    : L4023    (L40)
--    --  * Blood culture & susceptibility                        : L4027    (L40)
--    ---------------------------------------------------------------------------------
--    -- A형 간염 : A0038 (LCLS019)
--    --  * HAV Ab IgM (진단검사의학)    : L5152        (L30)
--    --  * HAV Ab IgM (핵의학)        : L76601    (N79)
--    ---------------------------------------------------------------------------------
--    -- Enterovirus : A0039 (LCLS020)
--    --  * Entero (우선판독)    : L26001    (L25)
--    --  * Enterovirus        : L2531        (L25)
--    ---------------------------------------------------------------------------------
--    BEGIN
--        FOR REC4 IN
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                    PT_NO
--                 , B.HSP_TP_CD                HSP_TP_CD
--                 , B.SPCM_NO                SPCM_NO
--                 , C.EXM_CD                    EXM_CD
--                 , D.SCLS_COMN_CD_NM        INFC_INF_CD
--                 , B.LSH_IP_ADDR            LSH_IP_ADDR
--                 , B.ORD_ID                    ORD_ID
--                 , B.ACPT_DTM                ACPT_DTM
--              FROM
--                   MSELMCED B
--                 , MSELMAID C
--                 , MSELMSID D
----             WHERE B.BRFG_DTM BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE + 0.99999) -- 테스트용
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 
--                                  AND V_SYSDATE - 0.00001 -- 기존 : - 1 + 0.99999
--               AND B.EXM_PRGR_STS_CD  = 'N'
--               AND B.EXRM_EXM_CTG_CD IN ('L25','L30','L40','L50','N79')
--               AND C.SPCM_NO          = B.SPCM_NO
--               AND C.EXM_CD           = D.SCLS_COMN_CD
--               AND D.LCLS_COMN_CD    IN ('LCLS012','LCLS013','LCLS014','LCLS015','LCLS017','LCLS018','LCLS019','LCLS020')
--               AND D.USE_YN           = 'Y'
--               AND D.HSP_TP_CD        = HIS_HSP_TP_CD
--               AND D.HSP_TP_CD        = C.HSP_TP_CD
--               AND C.HSP_TP_CD        = B.HSP_TP_CD
--               AND INSTR(UPPER(C.EXRS_CNTE), UPPER(D.TH1_RMK_CNTE)) > 0
--        )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC4.PT_NO               -- 01. 환자번호
--                                                             , NULL                     -- 02. 환자감염임신수유등록순번
--                                                             , REC4.HSP_TP_CD           -- 03. 병원구분코드
--                                                             , REC4.INFC_INF_CD         -- 04. 감염임신수유코드
--                                                             , NULL                     -- 05. 삭제사유내용
--                                                             , NULL                     -- 06. 비고내용
--                                                             , 'I'                      -- 07. alert작업구분코드
--                                                             , 'SSUP04'                  -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'     -- 09. 작업프로그램내용
--                                                             , REC4.LSH_IP_ADDR         -- 10. 작업PC_IP
--                                                             , REC4.ORD_ID              -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC4.ACPT_DTM            -- 13. 자동등록일자( = 양성검체접수일 )
--                                                             ) ;
--            EXCEPTION
--                WHEN OTHERS THEN
--                    NULL;
--            END;
--        END LOOP;
--    END;
--
--    -------------------------------- 전파종류 : 공기 --------------------------------
--    -- 호흡기결핵 : A0040 [의심] / A0002 [확진] (LCLS030)
--    -- AFB stain 의 결과가 Positive(양성) => 결핵의심
--    -- AFB culture 또는 MTB & RIF 약제내성 (우선판독) 의 결과가 Positive(양성) => 결핵확진
--    --  * AFB stain (Indirect)            : L4101        (L41)
--    --  * MTB & RIF 약제내성 (우선판독)    : L26002    (L25)
--    --
--    -- ※ 주의 - 호흡기결핵만 다른 Infection들과 공통코드 컬럼사용이 틀림!!!!
--    ---------------------------------------------------------------------------------
--    BEGIN
--        FOR REC5 IN
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   Z.PT_NO
--                 , Z.HSP_TP_CD
--                 , Z.SPCM_NO
--                 , Z.EXM_CD
--                 , Z.INFC_INF_CD
--                 , Z.LSH_IP_ADDR
--                 , Z.ORD_ID
--                 , Z.ACPT_DTM
--                 , Z.NTM_YN
--              FROM (
--                    SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                           B.PT_NO                                            PT_NO
--                         , B.HSP_TP_CD                                        HSP_TP_CD
--                         , B.SPCM_NO                                          SPCM_NO
--                         , C.EXM_CD                                           EXM_CD
--                         , D.TH1_RMK_CNTE                                      INFC_INF_CD
--                         , B.LSH_IP_ADDR                                      LSH_IP_ADDR
--                         , B.ORD_ID                                           ORD_ID
--                         , B.ACPT_DTM                                        ACPT_DTM
--                         , XMED.FT_NTM_YN(B.HSP_TP_CD, B.PT_NO)                NTM_YN            -- NTM 체크여부
--                         , INSTR(UPPER(C.EXRS_CNTE), UPPER(D.TH2_RMK_CNTE))    STR_CNT
--                      FROM
--                           MSELMCED B
--                         , MSELMAID C
--                         , MSELMSID D
----                     WHERE B.BRFG_DTM BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE + 0.99999) -- 테스트용
--                     WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 
--                                          AND V_SYSDATE - 0.00001 -- 기존 : - 1 + 0.99999
--                       AND B.EXM_PRGR_STS_CD  = 'N'
--                       AND B.EXRM_EXM_CTG_CD IN ('L41','L25')
--                       AND C.SPCM_NO          = B.SPCM_NO
--                       AND C.EXM_CD           = D.SCLS_COMN_CD_NM
--                       AND D.LCLS_COMN_CD     = 'LCLS030'
--                       AND D.USE_YN           = 'Y'
--                       AND D.HSP_TP_CD        = HIS_HSP_TP_CD
--                       AND D.HSP_TP_CD        = C.HSP_TP_CD
--                       AND C.HSP_TP_CD        = B.HSP_TP_CD
----                       AND INSTR(UPPER(C.EXRS_CNTE), UPPER(D.TH2_RMK_CNTE)) <= 0
--                    ) Z
--             GROUP BY Z.PT_NO, Z.HSP_TP_CD, Z.SPCM_NO, Z.EXM_CD, Z.INFC_INF_CD, Z.LSH_IP_ADDR, Z.ORD_ID, Z.ACPT_DTM, Z.NTM_YN
--             HAVING SUM(TO_NUMBER(Z.STR_CNT)) <= 0
--        )
--        LOOP
--            IF REC5.NTM_YN = 'N' THEN
--                BEGIN
--                    XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC5.PT_NO               -- 01. 환자번호
--                                                                 , NULL                     -- 02. 환자감염임신수유등록순번
--                                                                 , REC5.HSP_TP_CD           -- 03. 병원구분코드
--                                                                 , REC5.INFC_INF_CD         -- 04. 감염임신수유코드
--                                                                 , NULL                     -- 05. 삭제사유내용
--                                                                 , NULL                     -- 06. 비고내용
--                                                                 , 'I'                      -- 07. alert작업구분코드
--                                                                 , 'SSUP04'                  -- 08. 작업자직원번호
--                                                                 , 'PC_MSE_ALERT_BATCH'     -- 09. 작업프로그램내용
--                                                                 , REC5.LSH_IP_ADDR         -- 10. 작업PC_IP
--                                                                 , REC5.ORD_ID              -- 11. 관련처방ID
--                                                                 , 'R001'                    -- 12. 자동등록구분코드 
--                                                                 , REC5.ACPT_DTM            -- 13. 자동등록일자( = 양성검체접수일 )
--                                                                 ) ;
--                EXCEPTION
--                    WHEN OTHERS THEN
--                        NULL;
--                END;
--            END IF;
--        END LOOP;
--    END;
--    ---------------------------------------------------------------------------------
--    -- 호흡기결핵 : A0002 [확진] (LCLS031)
--    -- AFB culture 의 결과가 Positive(양성) => 결핵확진
--    --  * AFB culture : L4106        (L41)
--    ---------------------------------------------------------------------------------
--    BEGIN
--        FOR REC5 IN
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                                            PT_NO
--                 , B.HSP_TP_CD                                        HSP_TP_CD
--                 , B.SPCM_NO                                          SPCM_NO
--                 , C.EXM_CD                                           EXM_CD
--                 , D.TH1_RMK_CNTE                                      INFC_INF_CD
--                 , B.LSH_IP_ADDR                                      LSH_IP_ADDR
--                 , B.ORD_ID                                           ORD_ID
--                 , B.ACPT_DTM                                        ACPT_DTM
--                 , XMED.FT_NTM_YN(B.HSP_TP_CD, B.PT_NO)                NTM_YN            -- NTM 체크여부
--              FROM
--                   MSELMCED B
--                 , MSELMAID C
--                 , MSELMSID D
--                 , MSELMCRD E
----             WHERE B.BRFG_DTM BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE + 0.99999) -- 테스트용
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 
--                                  AND V_SYSDATE - 0.00001 -- 기존 : - 1 + 0.99999
--               AND B.EXM_PRGR_STS_CD  = 'N'
--               AND B.EXRM_EXM_CTG_CD  = 'L41'
--               AND C.SPCM_NO          = B.SPCM_NO
--               AND C.EXM_CD           = D.SCLS_COMN_CD_NM
--               AND D.LCLS_COMN_CD     = 'LCLS031'
--               AND D.USE_YN           = 'Y'
--               AND D.HSP_TP_CD        = HIS_HSP_TP_CD
--               AND D.HSP_TP_CD        = C.HSP_TP_CD
--               AND C.HSP_TP_CD        = B.HSP_TP_CD
--               AND C.SPCM_NO          = E.SPCM_NO
--               AND C.EXM_CD           = E.EXM_CD
--               AND (
--                    E.LABM_NEPO_TP_CD = D.TH3_RMK_CNTE
--                    OR
--                    E.LQD_CLMD_MVRT_CNTE = D.TH3_RMK_CNTE
--                   )
--               AND B.HSP_TP_CD        = E.HSP_TP_CD
--        )
--        LOOP
--            IF REC5.NTM_YN = 'N' THEN
--                BEGIN
--                    XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC5.PT_NO               -- 01. 환자번호
--                                                                 , NULL                     -- 02. 환자감염임신수유등록순번
--                                                                 , REC5.HSP_TP_CD           -- 03. 병원구분코드
--                                                                 , REC5.INFC_INF_CD         -- 04. 감염임신수유코드
--                                                                 , NULL                     -- 05. 삭제사유내용
--                                                                 , NULL                     -- 06. 비고내용
--                                                                 , 'I'                      -- 07. alert작업구분코드
--                                                                 , 'SSUP04'                  -- 08. 작업자직원번호
--                                                                 , 'PC_MSE_ALERT_BATCH'     -- 09. 작업프로그램내용
--                                                                 , REC5.LSH_IP_ADDR         -- 10. 작업PC_IP
--                                                                 , REC5.ORD_ID              -- 11. 관련처방ID
--                                                                 , 'R001'                    -- 12. 자동등록구분코드 
--                                                                 , REC5.ACPT_DTM            -- 13. 자동등록일자( = 양성검체접수일 )
--                                                                 ) ;
--                EXCEPTION
--                    WHEN OTHERS THEN
--                        NULL;
--                END;
--            END IF;
--        END LOOP;
--    END;
--    ---------------------------------------------------------------------------------
--    -- 홍역 : A0020 (LCLS021)
--    --  * Measl IgM    : L7240    (L78)
--    ---------------------------------------------------------------------------------
--    -- 수두 : A0021 (LCLS022)
--    --  * VZV Ab IgM    : L4422    (L43)    -- ccoocbac 처방종료 / mselmebm 처방가능 => 수탁?????
--    --  * VZV (culture)    : L4446    (L44)
--    ---------------------------------------------------------------------------------
--    BEGIN
--        FOR REC6 IN
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                    PT_NO
--                 , B.HSP_TP_CD                HSP_TP_CD
--                 , B.SPCM_NO                SPCM_NO
--                 , C.EXM_CD                    EXM_CD
--                 , D.SCLS_COMN_CD_NM        INFC_INF_CD
--                 , B.LSH_IP_ADDR            LSH_IP_ADDR
--                 , B.ORD_ID                    ORD_ID
--                 , B.ACPT_DTM                ACPT_DTM
--              FROM
--                   MSELMCED B
--                 , MSELMAID C
--                 , MSELMSID D
----             WHERE B.BRFG_DTM BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE + 0.99999) -- 테스트용
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 
--                                  AND V_SYSDATE - 0.00001 -- 기존 : - 1 + 0.99999
--               AND B.EXM_PRGR_STS_CD  = 'N'
--               AND B.EXRM_EXM_CTG_CD IN ('L78','L43','L44')
--               AND C.SPCM_NO          = B.SPCM_NO
--               AND C.EXM_CD           = D.SCLS_COMN_CD
--               AND D.LCLS_COMN_CD    IN ('LCLS021','LCLS022')
--               AND D.USE_YN           = 'Y'
--               AND D.HSP_TP_CD        = HIS_HSP_TP_CD
--               AND D.HSP_TP_CD        = C.HSP_TP_CD
--               AND C.HSP_TP_CD        = B.HSP_TP_CD
--               AND INSTR(UPPER(C.EXRS_CNTE), UPPER(D.TH1_RMK_CNTE)) > 0
--        )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC6.PT_NO               -- 01. 환자번호
--                                                             , NULL                     -- 02. 환자감염임신수유등록순번
--                                                             , REC6.HSP_TP_CD           -- 03. 병원구분코드
--                                                             , REC6.INFC_INF_CD         -- 04. 감염임신수유코드
--                                                             , NULL                     -- 05. 삭제사유내용
--                                                             , NULL                     -- 06. 비고내용
--                                                             , 'I'                      -- 07. alert작업구분코드
--                                                             , 'SSUP04'                  -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'     -- 09. 작업프로그램내용
--                                                             , REC6.LSH_IP_ADDR         -- 10. 작업PC_IP
--                                                             , REC6.ORD_ID              -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC6.ACPT_DTM            -- 13. 자동등록일자( = 양성검체접수일 )
--                                                             ) ;
--            EXCEPTION
--                WHEN OTHERS THEN
--                    NULL;
--            END;
--        END LOOP;
--    END;
--    
--    -------------------------------- 전파종류 : 비말 --------------------------------
--    -- Adenovirus : A0042 (LCLS023)
--    --  * Respiratory Infection (Virus 4종)    : L25158    (L25)
--    --  * Respiratory Infection (Virus 7종)    : L25159    (L25)
--    --  * Adeno (culture)                    : L4430        (L44)
--    ---------------------------------------------------------------------------------
--    -- Respiratory syncytial virus : A0043 (LCLS024)
--    --  * RSV-Asp, Wash, Swab, Other        : L44151 ~ L44154    (L80)
--    --  * Respiratory Infection (Virus 4종)    : L25158            (L25)
--    --  * Respiratory Infection (Virus 7종)    : L25159            (L25)
--    --  * RSV (culture)                        : L4438                (L44)
--    ---------------------------------------------------------------------------------
--    -- Influenza virus A,B : A0021 (LCLS025)
--    --  * Influenza A&B Ag                    : L80501    (L80)
--    --  * Respiratory Infection (Virus 4종)    : L25158    (L25)
--    --  * Respiratory Infection (Virus 7종)    : L25159    (L25)
--    --  * Inf (culture)                        : L4431        (L44)
--    ---------------------------------------------------------------------------------
--    -- Parainfluenza virus 1,2,3 : A0021 (LCLS026)
--    --  * Respiratory Infection (Virus 4종)    : L25158    (L25)
--    --  * Respiratory Infection (Virus 7종)    : L25159    (L25)
--    --  * Para (culture)                    : L4434        (L44)
--    ---------------------------------------------------------------------------------
--    -- Mumps (유행성이하선염) : A0021 (LCLS027)
--    --  * Mumps IgM    : L7245    (L78)
--    ---------------------------------------------------------------------------------
--    -- Rubella (풍진) : A0021 (LCLS028)
--    --  * Rube. IgM    : L5143    (L30)
--    ---------------------------------------------------------------------------------
--    -- Pertussis (백일해) : A0021 (LCLS029)
--    --  * Bordetella (우선판독) [특수분자진단]    : L25107    (L25)
--    ---------------------------------------------------------------------------------
--    BEGIN
--        FOR REC7 IN
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                    PT_NO
--                 , B.HSP_TP_CD                HSP_TP_CD
--                 , B.SPCM_NO                SPCM_NO
--                 , C.EXM_CD                    EXM_CD
--                 , D.SCLS_COMN_CD_NM        INFC_INF_CD
--                 , B.LSH_IP_ADDR            LSH_IP_ADDR
--                 , B.ORD_ID                    ORD_ID
--                 , B.ACPT_DTM                ACPT_DTM
--              FROM
--                   MSELMCED B
--                 , MSELMAID C
--                 , MSELMSID D
----             WHERE B.BRFG_DTM BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE + 0.99999) -- 테스트용
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 
--                                  AND V_SYSDATE - 0.00001 -- 기존 : - 1 + 0.99999
--               AND B.EXM_PRGR_STS_CD  = 'N'
--               AND B.EXRM_EXM_CTG_CD IN ('L25','L30','L44','L78','L80')
--               AND C.SPCM_NO          = B.SPCM_NO
--               AND C.EXM_CD           = D.SCLS_COMN_CD
--               AND D.LCLS_COMN_CD    IN ('LCLS023','LCLS024','LCLS025','LCLS026','LCLS027','LCLS028','LCLS029')
--               AND D.USE_YN           = 'Y'
--               AND D.HSP_TP_CD        = HIS_HSP_TP_CD
--               AND D.HSP_TP_CD        = C.HSP_TP_CD
--               AND C.HSP_TP_CD        = B.HSP_TP_CD
--               AND INSTR(UPPER(C.EXRS_CNTE), UPPER(D.TH1_RMK_CNTE)) > 0
--        )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_ALERT.PC_MOO_SAVE_INFECTIONITEM ( REC7.PT_NO               -- 01. 환자번호
--                                                             , NULL                     -- 02. 환자감염임신수유등록순번
--                                                             , REC7.HSP_TP_CD           -- 03. 병원구분코드
--                                                             , REC7.INFC_INF_CD         -- 04. 감염임신수유코드
--                                                             , NULL                     -- 05. 삭제사유내용
--                                                             , NULL                     -- 06. 비고내용
--                                                             , 'I'                      -- 07. alert작업구분코드
--                                                             , 'SSUP04'                  -- 08. 작업자직원번호
--                                                             , 'PC_MSE_ALERT_BATCH'     -- 09. 작업프로그램내용
--                                                             , REC7.LSH_IP_ADDR         -- 10. 작업PC_IP
--                                                             , REC7.ORD_ID              -- 11. 관련처방ID
--                                                             , 'R001'                    -- 12. 자동등록구분코드 
--                                                             , REC7.ACPT_DTM            -- 13. 자동등록일자( = 양성검체접수일 )
--                                                             ) ;
--            EXCEPTION
--                WHEN OTHERS THEN
--                    NULL;
--            END;
--        END LOOP;
--    END;
--    
--    -- 2017.12.14 박은기 추가
--    -- MDRO 환자관리화면에 해당환자 등록 ---------------------------------------------------
--    -- MRSA(A0013), VRE(A0014), CRE(A0030), VISA(A0031), VRSA(A0031) 등록
--    -- ALERT 에서는 VISA, VRSA 를 구분하였지만,
--    -- MDRO 화면에서는 VRSA 하나로만 사용한다고 함. (※ VISA 여도 VRSA로 체크한다고 함)
--    BEGIN
--        FOR REC8 IN 
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   DISTINCT
--                   B.PT_NO                PT_NO
--                 , B.HSP_TP_CD            HSP_TP_CD
--                 -- 2017.12.13 박은기 추가 ---------------------------
--                 , F.PACT_ID                            PACT_ID
--                 , F.PACT_TP_CD                            PACT_TP_CD
--                 , (
--                    SELECT Z.COMN_CD
--                      FROM CCCCCSTE Z
--                     WHERE Z.COMN_GRP_CD  = 'DR00108'
--                       AND Z.DTRL6_NM     = D.SCLS_COMN_CD_NM
--                       AND Z.HSP_TP_CD    = HIS_HSP_TP_CD
--                   )                                    ATBA_TLR_TP_CD
--                 , B.MED_DEPT_CD                        MED_DEPT_CD
--                 , F.PBSO_DEPT_CD                        PBSO_DEPT_CD
--                 , B.BLCL_DTM                            BLCL_DTM
--                 , B.ACPT_DTM                            ACPT_DTM
--                 , B.BRFG_DTM                            BRGF_DTM
--                 , E.TH1_SPCM_CD                        SPCM_CD
--                 , C.MVRT_CNTE                            MVRT_CNTE
--                 -----------------------------------------------------
--                 , D.SCLS_COMN_CD_NM      INFC_INF_CD
--                 , B.LSH_IP_ADDR          LSH_IP_ADDR
--                 , B.ORD_ID               ORD_ID
--              FROM ( SELECT X.SCLS_COMN_CD    EXM_CD
--                       FROM MSELMSID X
--                      WHERE X.LCLS_COMN_CD = 'LCLS008'
--                        AND X.HSP_TP_CD    = '08'
--                        AND X.USE_YN       = 'Y'
--                        AND X.SORT_SEQ     = 2
--                   )        A
--                 , MSELMCED B
--                 , MSELMCRD C
--                 , MSELMSID D
--                 , MSELMAID E
--                 -- 2017.12.13 박은기 추가 -------
--                 , MOOOREXM F 
--                 ---------------------------------
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 
--                                  AND V_SYSDATE - 1 + 0.99999
----             WHERE B.BRFG_DTM BETWEEN TRUNC(SYSDATE) - 6 AND TRUNC(SYSDATE) - 0 + 0.99999    -- 테스트용
--               AND B.EXM_PRGR_STS_CD = 'N'
--               AND B.EXRM_EXM_CTG_CD = 'L40'
--               AND C.SPCM_NO         = B.SPCM_NO
--               AND C.EXM_CD          = A.EXM_CD
--               AND EXISTS ( SELECT 1
--                              FROM MSELMMRD Z
--                             WHERE Z.SPCM_NO   = C.SPCM_NO
--                               AND Z.EXM_CD    = C.EXM_CD
--                               AND Z.LN_SEQ    = C.LN_SEQ
--                               AND Z.ATBA_CD   = D.TH2_RMK_CNTE
--                               AND Z.ATBA_SSBT_RSLT_CNTE = D.TH3_RMK_CNTE
--                          )
--               AND D.LCLS_COMN_CD = 'LCLS009'
--               AND D.HSP_TP_CD    = C.HSP_TP_CD
--               AND D.USE_YN       = 'Y'
--               AND D.SORT_SEQ     = 1
--               AND INSTR(UPPER(C.MVRT_CNTE), UPPER(D.TH1_RMK_CNTE)) > 0
--               AND E.SPCM_NO      = C.SPCM_NO
--               AND E.EXM_CD       = C.EXM_CD
--               -- 2017.12.13 박은기 추가 -------
--               AND B.PT_NO = F.PT_NO
--               AND B.ORD_ID = F.ORD_ID
--               AND B.HSP_TP_CD = F.HSP_TP_CD
----               AND EXISTS(SELECT 1 FROM PCTPCPAM_DAMO Z WHERE Z.PT_NO = F.PT_NO)    -- 테스트용
--               ---------------------------------
--        )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_MDRO_TARGET.PC_SAVE_MDRO_LIST
--                (
--                        REC8.PT_NO                    -- 01. 환자번호
--                      , NULL                        -- 02. 대상환자등록순번
--                      , REC8.HSP_TP_CD                -- 03. 병원구분코드
--                      , TRUNC(SYSDATE - 1)            -- 04. 등록일자
--                      , REC8.PACT_ID                -- 05. 원무접수 ID
--                      , REC8.PACT_TP_CD                -- 06. 원무접수구분코드
--                      , 'N'                            -- 07. 삭제여부
--                      , 'I'                            -- 08. 작업구분코드
--                      , NULL                        -- 09. 입원일자
--                      , NULL                        -- 10. 퇴원일자
--                      , NULL                        -- 11. 진단코드
--                      , NULL                        -- 12. 진단명
--                      , REC8.MED_DEPT_CD            -- 13. 진료부서코드
--                      , NULL                        -- 14. 병동
--                      , NULL                        -- 15. 지정의
--                      , NULL                        -- 16. 주치의
--                      , REC8.PBSO_DEPT_CD            -- 17. 발행처
--                      , REC8.BLCL_DTM                -- 18. 채혈일자
--                      , REC8.ACPT_DTM                -- 19. 접수일자
--                      , REC8.BRGF_DTM                -- 20. 판독일자
--                      
--                      , REC8.SPCM_CD                -- 21. TH1 검체코드
--                      , REC8.MVRT_CNTE                -- 22. TH1 동정결과
--                         , REC8.ATBA_TLR_TP_CD            -- 23. TH1 감염종류(내성구분)
--                         , NULL                        -- 24. TH1 기타검사
--                         
--                      , NULL                        -- 25. TH2 검체코드
--                      , NULL                        -- 26. TH2 동정결과
--                         , NULL                        -- 27. TH2 감염종류(내성구분)
--                         , NULL                        -- 28. TH2 기타검사
--                         
--                         , NULL                        -- 29. TH3 검체코드
--                      , NULL                        -- 30. TH3 동정결과
--                         , NULL                        -- 31. TH3 감염종류(내성구분)
--                         , NULL                        -- 32. TH3 기타검사
--                         
--                      , 'N'                            -- 33. 해제여부
--                      , NULL                        -- 34. 해제일자
--                      , NULL                        -- 35. 해제내용
--                      , NULL                        -- 36. 비고
--                      , NULL                        -- 37. 중요여부
--                      , 'I'                            -- 38. 원내외구분
--                      , 'SSUP04'                        -- 39. 작업자사번
--                      , 'PC_MSE_ALERT_BATCH'        -- 40. 작업프로그램 ID
--                      , REC8.LSH_IP_ADDR            -- 41. 작업PC IP
--                )
--                ;
--            EXCEPTION
--                WHEN OTHERS THEN
--                    NULL;
--            END;
--        END LOOP;
--    END;
--
--    -- MRPA(A0028), MRAB(A0029) 등록
--    BEGIN
--        FOR REC9 IN 
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                PT_NO
--                 , B.HSP_TP_CD            HSP_TP_CD
--                 , B.SPCM_NO              SPCM_NO
--                 , C.EXM_CD               EXM_CD
--                 , C.MVRT_CNTE            MVRT_CNTE
--                 , C.LN_SEQ               LN_SEQ
--                 , D.SCLS_COMN_CD         SCLS_COMN_CD
--                 -- 2017.12.13 박은기 추가 ---------------------------
--                 , F.PACT_ID                            PACT_ID
--                 , F.PACT_TP_CD                            PACT_TP_CD
--                 , (
--                    SELECT Z.COMN_CD
--                      FROM CCCCCSTE Z
--                     WHERE Z.COMN_GRP_CD  = 'DR00108'
--                       AND Z.DTRL6_NM     = D.SCLS_COMN_CD_NM
--                       AND Z.HSP_TP_CD    = HIS_HSP_TP_CD
--                   )                                    ATBA_TLR_TP_CD
--                 , B.MED_DEPT_CD                        MED_DEPT_CD
--                 , F.PBSO_DEPT_CD                        PBSO_DEPT_CD
--                 , B.BLCL_DTM                            BLCL_DTM
--                 , B.ACPT_DTM                            ACPT_DTM
--                 , B.BRFG_DTM                            BRGF_DTM
--                 , E.TH1_SPCM_CD                        SPCM_CD
--                 -----------------------------------------------------
--                 , D.SCLS_COMN_CD_NM      INFC_INF_CD
--                 , B.LSH_IP_ADDR          LSH_IP_ADDR
--                 , B.ORD_ID               ORD_ID
--                 , ( SELECT COUNT(*)
--                       FROM MSELMSID Z
--                      WHERE Z.LCLS_COMN_CD = 'LCLS010'
--                        AND Z.HSP_TP_CD    = '08'
--                        AND Z.USE_YN         = 'Y'
--                        AND Z.SCLS_COMN_CD_NM = D.SCLS_COMN_CD
--                        AND Z.TH3_RMK_CNTE    = 'AND'
--                   )  AND_ALL_CNT
--                 , ( SELECT COUNT(*)
--                       FROM MSELMMRD Y
--                          , MSELMSID Z
--                      WHERE Y.SPCM_NO      = C.SPCM_NO
--                        AND Y.EXM_CD       = C.EXM_CD
--                        AND Y.LN_SEQ       = C.LN_SEQ
--                        AND Z.LCLS_COMN_CD = 'LCLS010'
--                        AND Z.HSP_TP_CD    = '08'
--                        AND Z.USE_YN         = 'Y'
--                        AND Z.SCLS_COMN_CD_NM = D.SCLS_COMN_CD
--                        AND Z.TH1_RMK_CNTE    = Y.ATBA_CD
--                        AND Z.TH2_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                        AND Z.TH3_RMK_CNTE    = 'OR'
--                   )  OR_CNT
--                 , ( SELECT COUNT(*)
--                       FROM MSELMMRD Y
--                          , MSELMSID Z
--                      WHERE Y.SPCM_NO      = C.SPCM_NO
--                        AND Y.EXM_CD       = C.EXM_CD
--                        AND Y.LN_SEQ       = C.LN_SEQ
--                        AND Z.LCLS_COMN_CD = 'LCLS010'
--                        AND Z.HSP_TP_CD    = '08'
--                        AND Z.USE_YN         = 'Y'
--                        AND Z.SCLS_COMN_CD_NM = D.SCLS_COMN_CD
--                        AND Z.TH1_RMK_CNTE    = Y.ATBA_CD
--                        AND Z.TH2_RMK_CNTE    = Y.ATBA_SSBT_RSLT_CNTE
--                        AND Z.TH3_RMK_CNTE    = 'AND'
--                   )  AND_CNT
--              FROM ( SELECT X.SCLS_COMN_CD    EXM_CD
--                       FROM MSELMSID X
--                      WHERE X.LCLS_COMN_CD = 'LCLS008'
--                        AND X.HSP_TP_CD    = '08'
--                        AND X.USE_YN       = 'Y'
--                        AND X.SORT_SEQ     = 2
--                   )        A
--                 , MSELMCED B
--                 , MSELMCRD C
--                 , MSELMSID D
--                 , MSELMAID E
--                 -- 2017.12.13 박은기 추가 -------
--                 , MOOOREXM F
--                 ---------------------------------
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 
--                                  AND V_SYSDATE - 1 + 0.99999
----             WHERE B.BRFG_DTM BETWEEN TRUNC(SYSDATE) - 6 AND TRUNC(SYSDATE) - 0 + 0.99999    -- 테스트용
--               AND B.EXM_PRGR_STS_CD = 'N'
--               AND B.EXRM_EXM_CTG_CD = 'L40'
--               AND C.SPCM_NO         = B.SPCM_NO
--               AND C.EXM_CD          = A.EXM_CD
--               AND EXISTS ( SELECT 1
--                              FROM MSELMMRD Z
--                             WHERE Z.SPCM_NO   = C.SPCM_NO
--                               AND Z.EXM_CD    = C.EXM_CD
--                               AND Z.LN_SEQ    = C.LN_SEQ
--                          )
--               AND D.LCLS_COMN_CD = 'LCLS009'
--               AND D.HSP_TP_CD    = C.HSP_TP_CD
--               AND D.USE_YN       = 'Y'
--               AND D.SORT_SEQ     = 2
--               AND INSTR(UPPER(C.MVRT_CNTE), UPPER(D.TH1_RMK_CNTE)) > 0
--               AND E.SPCM_NO      = C.SPCM_NO
--               AND E.EXM_CD       = C.EXM_CD
--               -- 2017.12.13 박은기 추가 -------
--               AND B.PT_NO = F.PT_NO
--               AND B.ORD_ID = F.ORD_ID
--               AND B.HSP_TP_CD = F.HSP_TP_CD
--               ---------------------------------
--
--        )
--        LOOP
--            IF REC9.OR_CNT > 0 AND REC9.AND_ALL_CNT = REC9.AND_CNT THEN
--                BEGIN
--                    XMED.PKG_MOO_MDRO_TARGET.PC_SAVE_MDRO_LIST
--                    (
--                            REC9.PT_NO                    -- 01. 환자번호
--                          , NULL                        -- 02. 대상환자등록순번
--                          , REC9.HSP_TP_CD                -- 03. 병원구분코드
--                          , TRUNC(SYSDATE - 1)            -- 04. 등록일자
--                          , REC9.PACT_ID                -- 05. 원무접수 ID
--                          , REC9.PACT_TP_CD                -- 06. 원무접수구분코드
--                          , 'N'                            -- 07. 삭제여부
--                          , 'I'                            -- 08. 작업구분코드
--                          , NULL                        -- 09. 입원일자
--                          , NULL                        -- 10. 퇴원일자
--                          , NULL                        -- 11. 진단코드
--                          , NULL                        -- 12. 진단명
--                          , REC9.MED_DEPT_CD            -- 13. 진료부서코드
--                          , NULL                        -- 14. 병동
--                          , NULL                        -- 15. 지정의
--                          , NULL                        -- 16. 주치의
--                          , REC9.PBSO_DEPT_CD            -- 17. 발행처
--                          , REC9.BLCL_DTM                -- 18. 채혈일자
--                          , REC9.ACPT_DTM                -- 19. 접수일자
--                          , REC9.BRGF_DTM                -- 20. 판독일자
--                          
--                          , REC9.SPCM_CD                -- 21. TH1 검체코드
--                          , REC9.MVRT_CNTE                -- 22. TH1 동정결과
--                             , REC9.ATBA_TLR_TP_CD            -- 23. TH1 감염종류(내성구분)
--                             , NULL                        -- 24. TH1 기타검사
--                             
--                          , NULL                        -- 25. TH2 검체코드
--                          , NULL                        -- 26. TH2 동정결과
--                             , NULL                        -- 27. TH2 감염종류(내성구분)
--                             , NULL                        -- 28. TH2 기타검사
--                             
--                             , NULL                        -- 29. TH3 검체코드
--                          , NULL                        -- 30. TH3 동정결과
--                             , NULL                        -- 31. TH3 감염종류(내성구분)
--                             , NULL                        -- 32. TH3 기타검사
--                             
--                          , 'N'                            -- 33. 해제여부
--                          , NULL                        -- 34. 해제일자
--                          , NULL                        -- 35. 해제내용
--                          , NULL                        -- 36. 비고
--                          , NULL                        -- 37. 중요여부
--                          , 'I'                            -- 38. 원내외구분
--                          , 'SSUP04'                        -- 39. 작업자사번
--                          , 'PC_MSE_ALERT_BATCH'        -- 40. 작업프로그램 ID
--                          , REC9.LSH_IP_ADDR            -- 41. 작업PC IP
--                    )
--                    ;
--                    
--                EXCEPTION
--                    WHEN OTHERS THEN
--                        NULL;
--                END;
--            END IF;
--        END LOOP;
--    END;
--    
--    -- 다제내성균(CRE, VRE) surveillance
--    BEGIN
--        FOR REC10 IN
--        (
--            SELECT /*+ RULE PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ALERT_BATCH */
--                   B.PT_NO                PT_NO
--                 , B.HSP_TP_CD            HSP_TP_CD
--                 -- 2017.12.13 박은기 추가 ---------------------------
--                 , F.PACT_ID                            PACT_ID
--                 , F.PACT_TP_CD                            PACT_TP_CD
--                 , (
--                    SELECT Z.COMN_CD
--                      FROM CCCCCSTE Z
--                     WHERE Z.COMN_GRP_CD  = 'DR00108'
--                       AND Z.DTRL6_NM     = A.TH2_RMK_CNTE
--                       AND Z.HSP_TP_CD    = HIS_HSP_TP_CD
--                   )                                    ATBA_TLR_TP_CD
--                 , B.MED_DEPT_CD                        MED_DEPT_CD
--                 , F.PBSO_DEPT_CD                        PBSO_DEPT_CD
--                 , B.BLCL_DTM                            BLCL_DTM
--                 , B.ACPT_DTM                            ACPT_DTM
--                 , B.BRFG_DTM                            BRGF_DTM
--                 , C.TH1_SPCM_CD                        SPCM_CD
--                 , C.EXRS_CNTE                            EXRS_CNTE
--                 -----------------------------------------------------
--                 , B.SPCM_NO              SPCM_NO
--                 , C.EXM_CD               EXM_CD
--                 , A.TH2_RMK_CNTE         INFC_INF_CD
--                 , B.LSH_IP_ADDR          LSH_IP_ADDR
--                 , B.ORD_ID               ORD_ID
--              FROM ( SELECT X.SCLS_COMN_CD    EXM_CD 
--                          , X.TH1_RMK_CNTE    TH1_RMK_CNTE
--                          , X.TH2_RMK_CNTE    TH2_RMK_CNTE
--                       FROM MSELMSID X
--                      WHERE X.LCLS_COMN_CD = 'LCLS011'
--                        AND X.HSP_TP_CD    = '08'
--                        AND X.USE_YN       = 'Y'                                                             
--                   )        A
--                 , MSELMCED B
--                 , MSELMAID C
--                 -- 2017.12.13 박은기 추가 -------
--                 , MOOOREXM F
--                 ---------------------------------
--             WHERE B.BRFG_DTM BETWEEN V_SYSDATE - 1 
--                                  AND V_SYSDATE - 1 + 0.99999
----             WHERE B.BRFG_DTM BETWEEN TRUNC(SYSDATE) - 6 AND TRUNC(SYSDATE) - 0 + 0.99999    -- 테스트용
--               AND B.EXM_PRGR_STS_CD = 'N'
--               AND B.EXRM_EXM_CTG_CD = 'L40'
--               AND C.SPCM_NO         = B.SPCM_NO
--               AND C.EXM_CD          = A.EXM_CD 
----               AND INSTR(UPPER(C.EXRS_CNTE), UPPER(A.TH1_RMK_CNTE)) <= 0 -- 결과에 상관없이 보내주므로, 결과내용 비교 주석
--               -- 2017.12.13 박은기 추가 -------
--               AND B.PT_NO = F.PT_NO
--               AND B.ORD_ID = F.ORD_ID
--               AND B.HSP_TP_CD = F.HSP_TP_CD
--               ---------------------------------
--        )
--        LOOP
--            BEGIN
--                XMED.PKG_MOO_MDRO_TARGET.PC_SAVE_MDRO_LIST
--                (
--                        REC10.PT_NO                    -- 01. 환자번호
--                      , NULL                        -- 02. 대상환자등록순번
--                      , REC10.HSP_TP_CD                -- 03. 병원구분코드
--                      , TRUNC(SYSDATE - 1)            -- 04. 등록일자
--                      , REC10.PACT_ID                -- 05. 원무접수 ID
--                      , REC10.PACT_TP_CD            -- 06. 원무접수구분코드
--                      , 'N'                            -- 07. 삭제여부
--                      , 'I'                            -- 08. 작업구분코드
--                      , NULL                        -- 09. 입원일자
--                      , NULL                        -- 10. 퇴원일자
--                      , NULL                        -- 11. 진단코드
--                      , NULL                        -- 12. 진단명
--                      , REC10.MED_DEPT_CD            -- 13. 진료부서코드
--                      , NULL                        -- 14. 병동
--                      , NULL                        -- 15. 지정의
--                      , NULL                        -- 16. 주치의
--                      , REC10.PBSO_DEPT_CD            -- 17. 발행처
--                      , REC10.BLCL_DTM                -- 18. 채혈일자
--                      , REC10.ACPT_DTM                -- 19. 접수일자
--                      , REC10.BRGF_DTM                -- 20. 판독일자
--                      
--                      , REC10.SPCM_CD                -- 21. TH1 검체코드
--                      , REC10.EXRS_CNTE                -- 22. TH1 동정결과 => MSELMAID 검사결과로 보냄
--                         , REC10.ATBA_TLR_TP_CD        -- 23. TH1 감염종류(내성구분)
--                         , NULL                        -- 24. TH1 기타검사
--                         
--                      , NULL                        -- 25. TH2 검체코드
--                      , NULL                        -- 26. TH2 동정결과
--                         , NULL                        -- 27. TH2 감염종류(내성구분)
--                         , NULL                        -- 28. TH2 기타검사
--                         
--                         , NULL                        -- 29. TH3 검체코드
--                      , NULL                        -- 30. TH3 동정결과
--                         , NULL                        -- 31. TH3 감염종류(내성구분)
--                         , NULL                        -- 32. TH3 기타검사
--                      
--                      , 'N'                            -- 33. 해제여부
--                      , NULL                        -- 34. 해제일자
--                      , NULL                        -- 35. 해제내용
--                      , NULL                        -- 36. 비고
--                      , NULL                        -- 37. 중요여부
--                      , 'I'                            -- 38. 원내외구분
--                      , 'SSUP04'                        -- 39. 작업자사번
--                      , 'PC_MSE_ALERT_BATCH'        -- 40. 작업프로그램 ID
--                      , REC10.LSH_IP_ADDR            -- 41. 작업PC IP
--                )
--                ;
--            EXCEPTION
--                WHEN OTHERS THEN
--                    NULL;
--            END;
--        END LOOP;
--    END;

END PC_MSE_LM_ALERT_BATCH;
                               
/***********************************************************************************************
*    서비스이름  : PC_MSE_PM_OP_BATCH 
*    최초 작성일 : 2012.09.19
*    최초 작성자 : 남수현
*    DESCRIPTION : 수술장검체관련 SMS 전송 [5분간격으로 매번 처리]
*    수 정 사 항 : 
**********************************************************************************************/
PROCEDURE PC_MSE_PM_OP_BATCH ( HIS_HSP_TP_CD      IN MSBIOBMD.HSP_TP_CD%TYPE   --  DEFAULT '01'
                             , HIS_PRGM_NM        IN MSBIOBMD.LSH_PRGM_NM%TYPE -- DEFAULT 'PKG_MSE_SPCMPTHL_BATCH.PC_MSE_PM_OP_BATCH'
                             , HIS_IP_ADDR        IN MSBIOBMD.LSH_IP_ADDR%TYPE -- DEFAULT '127.0.0.1'
                             )

IS                                 
    V_OR_CHECK_YN       VARCHAR2(1) := 'N';
    I_COUNT_AND         NUMBER      := 0;
    V_COUNT_AND         NUMBER      := 0;
BEGIN
     RETURN ; --이상수 전체 막음 처리함.
    -- 현재날짜가 휴일인 경우 문자발송을 하지 않는다.
--    IF XSUP.FT_MSE_GET_HOLDY_YN(TRUNC(SYSDATE), HIS_HSP_TP_CD) = 'Y' THEN
--        RETURN;
--    END IF;
--
--    
--    BEGIN
--        FOR DR IN ( SELECT TO_CHAR(A.OP_EXPT_DT, 'YYYY-MM-DD')    OP_EXPT_DT
--                         , A.PT_NO                                PT_NO
--                         , C.PT_NM                                PT_NM
--                         , A.PFDR_STF_NO                          PFDR_STF_NO
--                         , XCOM.FT_CNL_SELSTFINFO('4', A.PFDR_STF_NO, A.HSP_TP_CD, NULL)            PFDR_STF_NM
--                         , XGAB.FT_RPP_PDESDSTD_INFO(A.PFDR_STF_NO, A.HSP_TP_CD, '08', 'TEL_NO')    PFDR_PHONE_NO
--                         , B.ANDR_STF_NO                                                            ANDR_STF_NO
--                         , XCOM.FT_CNL_SELSTFINFO('4', B.ANDR_STF_NO, A.HSP_TP_CD, NULL)            ANDR_STF_NM
--                         , XGAB.FT_RPP_PDESDSTD_INFO(B.ANDR_STF_NO, B.HSP_TP_CD, '08', 'TEL_NO')    ANDR_PHONE_NO
--                         , '01'                                                                     OP_SPCM_SMS_CD
--                         , A.HSP_TP_CD                                                              HSP_TP_CD
--                         , A.OP_EXPT_REG_ID                                                         OP_EXPT_REG_ID
--                      FROM ( SELECT B.PT_NO
--                                  , A.ORD_ID
--                                  , A.REG_SEQ
--                                  , B.OP_EXPT_REG_ID
--                                  , A.HSP_TP_CD
--                                  , XCOM.FT_CNL_SELSTFINFO('2', B.PFDR_SID, A.HSP_TP_CD, NULL)    PFDR_STF_NO
--                                  , B.OP_EXPT_DT
--                                  , COUNT(*)          SPCM_CNT
--                                  , MAX(A.FSR_DTM)    FSR_DTM
--                                  , MAX(A.FSR_STF_NO) FSR_STF_NO
--                               FROM MOOOROSD A
--                                  , MOOOPPAM B
--                              WHERE A.FSR_DTM BETWEEN TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 08:00', 'YYYY-MM-DD HH24:MI')
--                                                  AND TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' 16:30', 'YYYY-MM-DD HH24:MI')
--                                AND TO_CHAR(SYSDATE, 'D') NOT IN ('1', '7')                    -- 토 / 일요일 제외
--                                AND A.REG_SEQ = ( SELECT MAX(Z.REG_SEQ)
--                                                    FROM MOOOROSD Z
--                                                   WHERE Z.ORD_ID    = A.ORD_ID
--                                                     AND Z.HSP_TP_CD = A.HSP_TP_CD
--                                                )
--                                AND B.OP_EXPT_REG_ID = A.OP_EXPT_REG_ID
--                                AND B.HSP_TP_CD      = A.HSP_TP_CD
--                                AND NOT EXISTS ( SELECT 1
--                                                   FROM MSEPMSMH Z
--                                                  WHERE Z.OP_EXPT_REG_ID = B.OP_EXPT_REG_ID
--                                                    AND Z.HSP_TP_CD      = B.HSP_TP_CD
--                                               )
--                                AND TRUNC((SYSDATE - XMED.FT_MRN_OPNRECTIME (B.OP_EXPT_REG_ID, '08', B.HSP_TP_CD)) * 24 * 60) > 60      -- 수술 나간시간 이후 1시간 이상인 대상
--                             GROUP BY B.PT_NO
--                                    , A.ORD_ID
--                                    , A.REG_SEQ
--                                    , B.OP_EXPT_REG_ID
--                                    , A.HSP_TP_CD
--                                    , B.PFDR_SID
--                                    , B.OP_EXPT_DT
--                             ) A
--                           , MOOOREXM B
--                           , PCTPCPAM_DAMO C
--                     WHERE TRUNC((XMED.FT_MRN_OPNRECTIME (A.OP_EXPT_REG_ID, '08', A.HSP_TP_CD) - A.FSR_DTM) * 24 * 60) < 60              -- 수술실 나간시간  최종확인 시간 1시간 미만인 경우 만
--                       AND B.ORD_ID      = A.ORD_ID
--                       AND B.HSP_TP_CD   = A.HSP_TP_CD
--                       AND B.ORD_CD      = 'L6500'
--                       AND B.ODDSC_TP_CD = 'C'
--                       AND NOT EXISTS ( SELECT 1
--                                          FROM MSEPMSTD Z
--                                         WHERE Z.ORD_ID     = A.ORD_ID
--                                           AND Z.OP_REG_SEQ = A.REG_SEQ
--                                           AND Z.HSP_TP_CD  = A.HSP_TP_CD
--                                      )
--                       AND C.PT_NO     = A.PT_NO
--                       AND C.HSP_TP_CD = A.HSP_TP_CD
--                    
--                    UNION ALL
--                    
--                    SELECT TO_CHAR(A.OP_EXPT_DT, 'YYYY-MM-DD')    OP_EXPT_DT
--                         , A.PT_NO                                PT_NO
--                         , C.PT_NM                                PT_NM
--                         , A.PFDR_STF_NO                          PFDR_STF_NO
--                         , XCOM.FT_CNL_SELSTFINFO('4', A.PFDR_STF_NO, A.HSP_TP_CD, NULL)            PFDR_STF_NM
--                         , XGAB.FT_RPP_PDESDSTD_INFO(A.PFDR_STF_NO, A.HSP_TP_CD, '08', 'TEL_NO')    PFDR_PHONE_NO
--                         , B.ANDR_STF_NO                                                            ANDR_STF_NO
--                         , XCOM.FT_CNL_SELSTFINFO('4', B.ANDR_STF_NO, A.HSP_TP_CD, NULL)            ANDR_STF_NM
--                         , XGAB.FT_RPP_PDESDSTD_INFO(B.ANDR_STF_NO, B.HSP_TP_CD, '08', 'TEL_NO')    ANDR_PHONE_NO
--                         , '02'                                                                     OP_SPCM_SMS_CD
--                         , A.HSP_TP_CD                                                              HSP_TP_CD
--                         , A.OP_EXPT_REG_ID                                                         OP_EXPT_REG_ID
--                      FROM ( SELECT B.PT_NO
--                                  , A.ORD_ID
--                                  , A.REG_SEQ
--                                  , B.OP_EXPT_REG_ID
--                                  , A.HSP_TP_CD
--                                  , XCOM.FT_CNL_SELSTFINFO('2', B.PFDR_SID, A.HSP_TP_CD, NULL)    PFDR_STF_NO
--                                  , B.OP_EXPT_DT
--                                  , COUNT(*)          SPCM_CNT
--                                  , MAX(A.FSR_DTM)    FSR_DTM
--                                  , MAX(A.FSR_STF_NO) FSR_STF_NO
--                               FROM MOOOROSD A
--                                  , MOOOPPAM B
--                              WHERE A.FSR_DTM BETWEEN TO_DATE(TO_CHAR(SYSDATE - 1, 'YYYY-MM-DD') || ' 16:31', 'YYYY-MM-DD HH24:MI')
--                                                  AND TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD')     || ' 08:00', 'YYYY-MM-DD HH24:MI')    -- 당일 16:30 ~ 익일 08:00 까지  미확인 검체
--                                AND TO_CHAR(SYSDATE, 'D') NOT IN ('1')                        -- 일요일 제외
--                                AND A.REG_SEQ = ( SELECT MAX(Z.REG_SEQ)
--                                                    FROM MOOOROSD Z
--                                                   WHERE Z.ORD_ID    = A.ORD_ID
--                                                     AND Z.HSP_TP_CD = A.HSP_TP_CD
--                                                )
--                                AND B.OP_EXPT_REG_ID = A.OP_EXPT_REG_ID
--                                AND B.HSP_TP_CD      = A.HSP_TP_CD
--                                AND NOT EXISTS ( SELECT 1
--                                                   FROM MSEPMSMH Z
--                                                  WHERE Z.OP_EXPT_REG_ID = B.OP_EXPT_REG_ID
--                                                    AND Z.HSP_TP_CD      = B.HSP_TP_CD
--                                               )
--                                AND TRUNC((SYSDATE - XMED.FT_MRN_OPNRECTIME (B.OP_EXPT_REG_ID, '08', B.HSP_TP_CD)) * 24 * 60) > 60    -- 수술 나간시간 이후 1시간 이상인 대상
--                             GROUP BY B.PT_NO
--                                    , A.ORD_ID
--                                    , A.REG_SEQ
--                                    , B.OP_EXPT_REG_ID
--                                    , A.HSP_TP_CD
--                                    , B.PFDR_SID
--                                    , B.OP_EXPT_DT
--                             ) A
--                           , MOOOREXM B
--                           , PCTPCPAM_DAMO C
--                     WHERE B.ORD_ID      = A.ORD_ID
--                       AND B.HSP_TP_CD   = A.HSP_TP_CD
--                       AND B.ORD_CD      = 'L6500'
--                       AND B.ODDSC_TP_CD = 'C'
--                       AND NOT EXISTS ( SELECT 1
--                                          FROM MSEPMSTD Z
--                                         WHERE Z.ORD_ID     = A.ORD_ID
--                                           AND Z.OP_REG_SEQ = A.REG_SEQ
--                                           AND Z.HSP_TP_CD  = A.HSP_TP_CD
--                                      )
--                       AND C.PT_NO     = A.PT_NO
--                       AND C.HSP_TP_CD = A.HSP_TP_CD
--                       AND TO_CHAR(SYSDATE , 'YYYYMMDDHH24MI') BETWEEN TO_CHAR(SYSDATE, 'YYYYMMDD') || '1000'
--                                                                   AND TO_CHAR(SYSDATE, 'YYYYMMDD') || '1010'    -- 5분 간격으로 배치 프로그램이 돌기 때문에...아침 10시 ~ 10시 10분 사이에 있는것만 허용되도록 설정
--                    
--                    UNION ALL
--                    
--                    SELECT TO_CHAR(A.OP_EXPT_DT, 'YYYY-MM-DD')    OP_EXPT_DT
--                         , A.PT_NO                                PT_NO
--                         , C.PT_NM                                PT_NM
--                         , A.PFDR_STF_NO                          PFDR_STF_NO
--                         , XCOM.FT_CNL_SELSTFINFO('4', A.PFDR_STF_NO, A.HSP_TP_CD, NULL)            PFDR_STF_NM
--                         , XGAB.FT_RPP_PDESDSTD_INFO(A.PFDR_STF_NO, A.HSP_TP_CD, '08', 'TEL_NO')    PFDR_PHONE_NO
--                         , B.ANDR_STF_NO                                                            ANDR_STF_NO
--                         , XCOM.FT_CNL_SELSTFINFO('4', B.ANDR_STF_NO, A.HSP_TP_CD, NULL)            ANDR_STF_NM
--                         , XGAB.FT_RPP_PDESDSTD_INFO(B.ANDR_STF_NO, B.HSP_TP_CD, '08', 'TEL_NO')    ANDR_PHONE_NO
--                         , '03'                                                                     OP_SPCM_SMS_CD
--                         , A.HSP_TP_CD                                                              HSP_TP_CD
--                         , A.OP_EXPT_REG_ID                                                         OP_EXPT_REG_ID
--                      FROM ( SELECT B.PT_NO
--                                  , A.ORD_ID
--                                  , A.REG_SEQ
--                                  , B.OP_EXPT_REG_ID
--                                  , A.HSP_TP_CD
--                                  , XCOM.FT_CNL_SELSTFINFO('2', B.PFDR_SID, A.HSP_TP_CD, NULL)    PFDR_STF_NO
--                                  , B.OP_EXPT_DT
--                                  , COUNT(*)          SPCM_CNT
--                                  , MAX(A.FSR_DTM)    FSR_DTM
--                                  , MAX(A.FSR_STF_NO) FSR_STF_NO
--                               FROM MOOOROSD A
--                                  , MOOOPPAM B
--                              WHERE A.FSR_DTM BETWEEN TO_DATE(TO_CHAR(SYSDATE - 2, 'YYYY-MM-DD') || ' 08:01', 'YYYY-MM-DD HH24:MI')
--                                                  AND TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD')     || ' 08:00', 'YYYY-MM-DD HH24:MI')    -- 당일 16:30 ~ 익일 08:00 까지  미확인 검체
--                                AND TO_CHAR(SYSDATE, 'D') IN ('2')                        -- 월요일 조회
--                                AND TO_CHAR(SYSDATE , 'YYYYMMDDHH24MI') > TO_CHAR(sysdate, 'YYYYMMDD') || '1000'
--                                AND A.REG_SEQ = ( SELECT MAX(Z.REG_SEQ)
--                                                    FROM MOOOROSD Z
--                                                   WHERE Z.ORD_ID    = A.ORD_ID
--                                                     AND Z.HSP_TP_CD = A.HSP_TP_CD
--                                                )
--                                AND B.OP_EXPT_REG_ID = A.OP_EXPT_REG_ID
--                                AND B.HSP_TP_CD      = A.HSP_TP_CD
--                                AND NOT EXISTS ( SELECT 1
--                                                   FROM MSEPMSMH Z
--                                                  WHERE Z.OP_EXPT_REG_ID = B.OP_EXPT_REG_ID
--                                                    AND Z.HSP_TP_CD      = B.HSP_TP_CD
--                                               )
--                                AND TRUNC((SYSDATE - XMED.FT_MRN_OPNRECTIME (B.OP_EXPT_REG_ID, '08', B.HSP_TP_CD)) * 24 * 60) > 60    -- 수술 나간시간 이후 1시간 이상인 대상
--                             GROUP BY B.PT_NO
--                                    , A.ORD_ID
--                                    , A.REG_SEQ
--                                    , B.OP_EXPT_REG_ID
--                                    , A.HSP_TP_CD
--                                    , B.PFDR_SID
--                                    , B.OP_EXPT_DT
--                             ) A
--                           , MOOOREXM B
--                           , PCTPCPAM_DAMO C
--                     WHERE B.ORD_ID      = A.ORD_ID
--                       AND B.HSP_TP_CD   = A.HSP_TP_CD
--                       AND B.ORD_CD      = 'L6500'
--                       AND B.ODDSC_TP_CD = 'C'
--                       AND NOT EXISTS ( SELECT 1
--                                          FROM MSEPMSTD Z
--                                         WHERE Z.ORD_ID     = A.ORD_ID
--                                           AND Z.OP_REG_SEQ = A.REG_SEQ
--                                           AND Z.HSP_TP_CD  = A.HSP_TP_CD
--                                      )
--                       AND C.PT_NO     = A.PT_NO
--                       AND C.HSP_TP_CD = A.HSP_TP_CD
--                       AND TO_CHAR(SYSDATE , 'YYYYMMDDHH24MI') BETWEEN TO_CHAR(SYSDATE, 'YYYYMMDD') || '1000'
--                                                                   AND TO_CHAR(SYSDATE, 'YYYYMMDD') || '1010'    -- 5분 간격으로 배치 프로그램이 돌기 때문에...아침 10시 ~ 10시 10분 사이에 있는것만 허용되도록 설정
--
--    
--        )
--        LOOP 
--
--            -- 집도의 시작-----------------------------------------------------------------------------------------------------------------        
--            IF DR.PFDR_PHONE_NO IS NOT NULL THEN
--            BEGIN
--                BEGIN
--                    INSERT 
--                      INTO SDK_SMS_SEND@DL_SMS_GNR ( MSG_ID           --메세지 sequence
--                                                   , SCHEDULE_TYPE    --즉시:0, 예약:1
--                                                   , USER_ID          --발송자ID(사번)
--                                                   , SUBJECT          --환자번호
--                                                   , DEST_INFO        --수신자 전화번호, 수신자 정보 ex:홍길동^0135881902
--                                                   , CALLBACK         --회신번호
--                                                   , SEND_DATE        --발송될 희망시간
--                                                   , SMS_MSG          --발송메세지
--                                                   , NOW_DATE         --DB입력되는시간
--                                                   , DEST_TYPE        --수신자 정보 저장타입(0:TEXT)
--                                                   , DEST_COUNT       --수신자 개수값 default : 1
--                                                   , RESERVED1        --환자번호
--                                                   , RESERVED2        --수술일자    
--                                                   , RESERVED3        -- 01: 1시간 안에  병리과 EMR 도착확인 안됨  //  02 : 익일 10:00까지 병리과 EMR 도착확인 안됨  // 03 : 월요일 10:00까지 병리과 EMR 도착확인 안됨
--                                                   )
--                                            VALUES ( ''                        -- NULL 값을 넣어도 자동으로 시퀀스를 따온다.
--                                                   , 0                         -- 모두 예약발송으로 처리하게 '1'로 코딩
--                                                   , DR.PFDR_STF_NO
--                                                   , ''
--                                                   , DR.PFDR_STF_NM || '^' || DR.PFDR_PHONE_NO -- '^'구분자를 꼭 넣어야함
--                                                   , '031-787-3373'
--                                                   , TO_CHAR(SYSDATE,'YYYYMMDDHH24MI')
--                                                   , DR.PT_NM || '님 수술 병리검체가 도착하지 않았습니다.확인 후 연락바랍니다.-병리과-'
--                                                   , TO_CHAR(SYSDATE,'YYYYMMDDHH24MI')
--                                                   , 0                         -- TEXT 타입은 강제로 '0' 으로 코딩
--                                                   , 1                         -- 수신자 개수값 역시 '1' 로 코딩
--                                                   , DR.PT_NO
--                                                   , DR.OP_EXPT_DT
--                                                   , DR.OP_SPCM_SMS_CD
--                                                   );
--            
--                    IF SQL%ROWCOUNT = 0 THEN
--                        RETURN;
--                    END IF;
--            
--                    EXCEPTION
--                        WHEN OTHERS THEN
--                            RETURN;
--                END;
--            
--                -- OP_SPCM_SMS_CD                               
--                -- 01 : 당일  (08:00~16:00)까지 도착 확인이 안된케이스  sms발송 
--                -- 02 : 전일 (16:01) 당일(08:00)까지 도착 확인이 안된케이스 sms발송 (※ 당일 10:00 ~ 10:10 일때만 허용)
--                -- 03 : 월요일인 경우만 해당  전전일(08:00) 당일(08:00)까지 도착 확인이 안된케이스 sms발송 (※ 당일 10:00 ~ 10:10 일때만 허용)
--                BEGIN
--                    INSERT 
--                      INTO MSEPMSMH ( OP_EXPT_REG_ID
--                                    , SMS_SEQ
--                                    , HSP_TP_CD
--                                    , PT_NO
--                                    , OP_EXPT_DT
--                                    , RCV_STF_NO
--                                    , RCV_MTEL_NO
--                                    , SDLT_STF_NO
--                                    , SDLT_TEL_NO
--                                    , SDLT_DTM
--                                    , OP_SPCM_SMS_CD
--                                    , FSR_DTM
--                                    , FSR_STF_NO
--                                    , FSR_PRGM_NM
--                                    , FSR_IP_ADDR
--                                    , LSH_DTM
--                                    , LSH_STF_NO
--                                    , LSH_PRGM_NM
--                                    , LSH_IP_ADDR
--                                    )
--                             VALUES ( DR.OP_EXPT_REG_ID
--                                    , ( SELECT NVL(MAX(SMS_SEQ), 0) + 1
--                                          FROM MSEPMSMH Z
--                                         WHERE Z.OP_EXPT_REG_ID = DR.OP_EXPT_REG_ID
--                                           AND Z.HSP_TP_CD      = DR.HSP_TP_CD
--                                      )
--                                    , DR.HSP_TP_CD
--                                    , DR.PT_NO
--                                    , DR.OP_EXPT_DT
--                                    , DR.PFDR_STF_NO
--                                    , DR.PFDR_PHONE_NO
--                                    , ''
--                                    , '031-787-3373'
--                                    , SYSDATE
--                                    , DR.OP_SPCM_SMS_CD  
--                                    , SYSDATE
--                                    , 'SSUP04'
--                                    , 'PKG_MSE_SPCMPTHL_BATCH.PC_MSE_PM_OP_BATCH'
--                                    , '172.0.0.1.'
--                                    , SYSDATE
--                                    , 'SSUP04'
--                                    , 'PKG_MSE_SPCMPTHL_BATCH.PC_MSE_PM_OP_BATCH'
--                                    , '172.0.0.1.'
--                                    );
--
--                    IF SQL%ROWCOUNT = 0 THEN
--                        
--                        RETURN;
--                    END IF;
--            
--                    EXCEPTION
--                        WHEN OTHERS THEN
--                            
--                            RETURN;
--                END;
--            END;
--            END IF;
--            
--
--            -- 주치의 시작-----------------------------------------------------------------------------------------------------------------        
--            IF DR.ANDR_PHONE_NO IS NOT NULL THEN
--            BEGIN
--                BEGIN
--                    INSERT 
--                      INTO SDK_SMS_SEND@DL_SMS_GNR ( MSG_ID           --메세지 sequence
--                                                   , SCHEDULE_TYPE    --즉시:0, 예약:1
--                                                   , USER_ID          --발송자ID(사번)
--                                                   , SUBJECT          --환자번호
--                                                   , DEST_INFO        --수신자 전화번호, 수신자 정보 ex:홍길동^0135881902
--                                                   , CALLBACK         --회신번호
--                                                   , SEND_DATE        --발송될 희망시간
--                                                   , SMS_MSG          --발송메세지
--                                                   , NOW_DATE         --DB입력되는시간
--                                                   , DEST_TYPE        --수신자 정보 저장타입(0:TEXT)
--                                                   , DEST_COUNT       --수신자 개수값 default : 1
--                                                   , RESERVED1        --환자번호
--                                                   , RESERVED2           --수술일자    
--                                                   , RESERVED3        -- 1: 1시간 안에  병리과 EMR 도착확인 안됨  //  2 : 익일 10:00까지 병리과 EMR 도착확인 안됨  // 3 : 월요일 10:00까지 병리과 EMR 도착확인 안됨
--                                                   )
--                                            VALUES ( ''                        -- NULL 값을 넣어도 자동으로 시퀀스를 따온다.
--                                                   , 0                         -- 모두 예약발송으로 처리하게 '1'로 코딩
--                                                   , DR.ANDR_STF_NO
--                                                   , ''
--                                                   , DR.ANDR_STF_NM || '^' || DR.ANDR_PHONE_NO -- '^'구분자를 꼭 넣어야함
--                                                   , '031-787-3373'
--                                                   , TO_CHAR(SYSDATE,'YYYYMMDDHH24MI')
--                                                   , DR.PT_NM || '님 수술 병리검체가 도착하지 않았습니다.확인 후 연락바랍니다.-병리과-'
--                                                   , TO_CHAR(SYSDATE,'YYYYMMDDHH24MI')
--                                                   , 0                         -- TEXT 타입은 강제로 '0' 으로 코딩
--                                                   , 1                         -- 수신자 개수값 역시 '1' 로 코딩
--                                                   , DR.PT_NO
--                                                   , DR.OP_EXPT_DT
--                                                   , DR.OP_SPCM_SMS_CD
--                                                   );
--            
--                    IF SQL%ROWCOUNT = 0 THEN
--                        
--                        RETURN;
--                    END IF;
--            
--                    EXCEPTION
--                        WHEN OTHERS THEN
--                            
--                            RETURN;
--                END;
--            
--                -- OP_SPCM_SMS_CD                               
--                -- 01 : 당일  (08:00~16:00)까지 도착 확인이 안된케이스  sms발송 
--                -- 02 : 전일 (16:01) 당일(08:00)까지 도착 확인이 안된케이스 sms발송 (※ 당일 10:00 ~ 10:10 일때만 허용)
--                -- 03 : 월요일인 경우만 해당  전전일(08:00) 당일(08:00)까지 도착 확인이 안된케이스 sms발송 (※ 당일 10:00 ~ 10:10 일때만 허용)
--                BEGIN
--                    INSERT 
--                      INTO MSEPMSMH ( OP_EXPT_REG_ID
--                                    , SMS_SEQ
--                                    , HSP_TP_CD
--                                    , PT_NO
--                                    , OP_EXPT_DT
--                                    , RCV_STF_NO
--                                    , RCV_MTEL_NO
--                                    , SDLT_STF_NO
--                                    , SDLT_TEL_NO
--                                    , SDLT_DTM
--                                    , OP_SPCM_SMS_CD
--                                    , FSR_DTM
--                                    , FSR_STF_NO
--                                    , FSR_PRGM_NM
--                                    , FSR_IP_ADDR
--                                    , LSH_DTM
--                                    , LSH_STF_NO
--                                    , LSH_PRGM_NM
--                                    , LSH_IP_ADDR
--                                    )
--                             VALUES ( DR.OP_EXPT_REG_ID
--                                    , ( SELECT NVL(MAX(SMS_SEQ), 0) + 1
--                                          FROM MSEPMSMH Z
--                                         WHERE Z.OP_EXPT_REG_ID = DR.OP_EXPT_REG_ID
--                                           AND Z.HSP_TP_CD      = DR.HSP_TP_CD
--                                      )
--                                    , DR.HSP_TP_CD
--                                    , DR.PT_NO
--                                    , DR.OP_EXPT_DT
--                                    , DR.PFDR_STF_NO
--                                    , DR.PFDR_PHONE_NO
--                                    , ''
--                                    , '031-787-3373'
--                                    , SYSDATE
--                                    , DR.OP_SPCM_SMS_CD  
--                                    , SYSDATE
--                                    , 'SSUP04'
--                                    , HIS_PRGM_NM
--                                    , HIS_IP_ADDR
--                                    , SYSDATE
--                                    , 'SSUP04'
--                                    , HIS_PRGM_NM
--                                    , HIS_IP_ADDR
--                                   );
--                    IF SQL%ROWCOUNT = 0 THEN
--                        
--                        RETURN;
--                    END IF;
--            
--                    EXCEPTION
--                        WHEN OTHERS THEN
--                            
--                            RETURN;
--                END;
--            END;
--            END IF;
--        END LOOP;
--        
--    END;

END PC_MSE_PM_OP_BATCH;

/***********************************************************************************************
*    서비스이름  : PC_MSE_REAGENT_CLOSING 
*    최초 작성일 : 2012.09.19
*    최초 작성자 : 남수현
*    DESCRIPTION : 핵의학과 시약 마감 처리 (한달에 한 번 처리한다)
*    수 정 사 항 : 
**********************************************************************************************/
PROCEDURE PC_MSE_REAGENT_CLOSING ( IN_WORK_DATE         IN VARCHAR2                     -- 연월만 넘긴다.
                                 , IN_AGAIN_CLOSING_YN  IN VARCHAR2
                                 , HIS_STF_NO           IN MSELMDTD.FSR_STF_NO%TYPE
                                 , HIS_HSP_TP_CD        IN MSBIOBMD.HSP_TP_CD%TYPE
                                 , HIS_PRGM_NM          IN MSBIOBMD.LSH_PRGM_NM%TYPE
                                 , HIS_IP_ADDR          IN MSBIOBMD.LSH_IP_ADDR%TYPE
                                 , IO_ERRYN             IN  OUT VARCHAR2
                                 , IO_ERRMSG            IN  OUT VARCHAR2
                                 )

IS
    
    V_SYSDATE       DATE        := SYSDATE;
    I_COUNT_EXISTS  NUMBER      := 0;
    I_COUNT_IN      NUMBER      := 0;
    I_COUNT_OUT     NUMBER      := 0;
    I_CUR_STK_QTY   MSELMDTD.CUR_STK_QTY%TYPE := 0;
BEGIN
     
    RETURN;  -- 막음 처리 

--    IF IN_AGAIN_CLOSING_YN = 'N' THEN
--    BEGIN
--        BEGIN
--            SELECT COUNT(*)
--              INTO I_COUNT_EXISTS 
--              FROM MSELMDTD A
--             WHERE A.STK_DT BETWEEN TO_DATE(IN_WORK_DATE || '-01', 'YYYY-MM-DD')
--                                AND LAST_DAY(TO_DATE(IN_WORK_DATE, 'YYYY-MM'))
--               AND A.HSP_TP_CD =  HIS_HSP_TP_CD;
--        
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    I_COUNT_EXISTS  := 0;
--        END;
--
--
--        IF I_COUNT_EXISTS  > 0 THEN
--        BEGIN
--            IO_ERRYN  := 'N';
--            IO_ERRMSG := '기 마감처리됨.' ;
--            RETURN;
--        END;
--        END IF;
--    END;
--    END IF;
--
--    BEGIN
--        SELECT COUNT(*)
--          INTO I_COUNT_IN
--          FROM MSELMDID A
--         WHERE A.IW_DT BETWEEN TO_DATE(IN_WORK_DATE || '-01', 'YYYY-MM-DD')
--                           AND LAST_DAY(TO_DATE(IN_WORK_DATE, 'YYYY-MM'))
--           AND A.HSP_TP_CD =  HIS_HSP_TP_CD;
--        
--        EXCEPTION
--            WHEN NO_DATA_FOUND THEN
--                I_COUNT_IN  := 0;
--    END;
--    
--    BEGIN
--        SELECT COUNT(*)
--          INTO I_COUNT_OUT
--          FROM MSELMDSD A
--         WHERE A.USE_DT BETWEEN TO_DATE(IN_WORK_DATE || '-01', 'YYYY-MM-DD')
--                            AND LAST_DAY(TO_DATE(IN_WORK_DATE, 'YYYY-MM'))
--           AND A.HSP_TP_CD =  HIS_HSP_TP_CD;
--        
--        EXCEPTION
--            WHEN NO_DATA_FOUND THEN
--                I_COUNT_OUT  := 0;
--    END;
--
--    IF I_COUNT_IN + I_COUNT_OUT = 0 THEN
--    BEGIN
--        IO_ERRYN  := 'N';
--        IO_ERRMSG := '처리할 데이터가 없음 = ' ;
--        RETURN;
--    END;
--    END IF;
--
--    FOR REC IN (         SELECT STK_DT
--             , EXM_CD
--             , ARCL_NO
--             , SUM(IW_QTY)     IW_QTY
--             , SUM(USE_QTY)    USE_QTY
--             , SUM(DUSE_QTY)   DUSE_QTY  
--          FROM (
--        SELECT A.IW_DT          STK_DT
--             , A.EXM_CD         EXM_CD
--             , A.ARCL_NO        ARCL_NO
--             , A.IW_QTY * 100    IW_QTY
--             , 0                USE_QTY
--             , 0                DUSE_QTY
--          FROM MSELMDID A
--         WHERE A.IW_DT BETWEEN TO_DATE(IN_WORK_DATE || '-01', 'YYYY-MM-DD')
--                           AND LAST_DAY(TO_DATE(IN_WORK_DATE, 'YYYY-MM'))
--           AND A.HSP_TP_CD = HIS_HSP_TP_CD
--
--        UNION ALL
--
--        SELECT A.USE_DT          STK_DT
--             , B.TH2_RMK_CNTE    EXM_CD
--             , A.ARCL_NO         ARCL_NO
--             , 0                 IW_QTY
--             , A.USE_QTY         USE_QTY
--             , A.DUSE_QTY        DUSE_QTY
--          FROM MSELMDSD A
--             , MSELMSID B          
--         WHERE A.USE_DT BETWEEN TO_DATE(IN_WORK_DATE || '-01', 'YYYY-MM-DD')
--                            AND LAST_DAY(TO_DATE(IN_WORK_DATE, 'YYYY-MM'))
--           AND A.HSP_TP_CD    = HIS_HSP_TP_CD
--           AND B.LCLS_COMN_CD = 'REAGENT'
--           AND B.SCLS_COMN_CD = A.ARCL_NO
--           AND B.HSP_TP_CD    = A.HSP_TP_CD           
--
--        )
--        GROUP BY STK_DT
--               , EXM_CD
--               , ARCL_NO
--        ORDER BY STK_DT
--               , ARCL_NO)
--
--        LOOP
--            BEGIN
--                SELECT A.CUR_STK_QTY
--                  INTO I_CUR_STK_QTY
--                  FROM MSELMDTD A
--                 WHERE A.STK_DT    < REC.STK_DT
--                   AND A.EXM_CD    = REC.EXM_CD
--                   AND A.ARCL_NO   = REC.ARCL_NO
--                   AND A.HSP_TP_CD = HIS_HSP_TP_CD
--                   AND A.STK_DT    = ( SELECT /*+ INDEX_DESC (Z MSELMDTD_PK) */
--                                              Z.STK_DT
--                                         FROM MSELMDTD Z
--                                        WHERE Z.STK_DT    < REC.STK_DT
--                                          AND Z.EXM_CD    = REC.EXM_CD
--                                          AND Z.ARCL_NO   = REC.ARCL_NO
--                                          AND ROWNUM      = 1
--                                     );
--                EXCEPTION
--                    WHEN NO_DATA_FOUND THEN
--                        I_CUR_STK_QTY := 0;
--            END;
--
--            BEGIN
--                INSERT 
--                  INTO MSELMDTD ( STK_DT
--                                , EXM_CD
--                                , ARCL_NO
--                                , HSP_TP_CD
--                                , PVDY_STK_QTY
--                                , IW_QTY
--                                , USE_QTY
--                                , DUSE_QTY
--                                , CUR_STK_QTY
--                                , FSR_STF_NO
--                                , FSR_DTM
--                                , FSR_PRGM_NM
--                                , FSR_IP_ADDR
--                                , LSH_STF_NO
--                                , LSH_DTM
--                                , LSH_PRGM_NM
--                                , LSH_IP_ADDR
--                                )
--                         VALUES ( REC.STK_DT
--                                , REC.EXM_CD
--                                , REC.ARCL_NO
--                                , HIS_HSP_TP_CD
--                                , I_CUR_STK_QTY
--                                , REC.IW_QTY
--                                , REC.USE_QTY
--                                , REC.DUSE_QTY
--                                , (I_CUR_STK_QTY + REC.IW_QTY - REC.USE_QTY - REC.DUSE_QTY)
--                                , HIS_STF_NO
--                                , V_SYSDATE
--                                , HIS_PRGM_NM
--                                , HIS_IP_ADDR
--                                , HIS_STF_NO
--                                , V_SYSDATE
--                                , HIS_PRGM_NM
--                                , HIS_IP_ADDR
--                                );
--
--                EXCEPTION
--                    WHEN OTHERS THEN
--                        IO_ERRYN  := 'Y';
--                        IO_ERRMSG := '시약 마감데이터 생성중 ERROR발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                        RETURN;
--            END;
--            
--            BEGIN
--                UPDATE MSELMDID A
--                   SET A.STK_REFL_YN     = 'Y'
--                     , A.STK_REFL_STF_NO = HIS_STF_NO
--                     , A.STK_REFL_DTM    = V_SYSDATE
--                     , A.LSH_STF_NO      = HIS_STF_NO
--                     , A.LSH_DTM         = V_SYSDATE
--                     , A.LSH_PRGM_NM     = HIS_PRGM_NM
--                     , A.LSH_IP_ADDR     = HIS_IP_ADDR
--                 WHERE A.IW_DT           = REC.STK_DT
--                   AND A.EXM_CD          = REC.EXM_CD
--                   AND A.ARCL_NO         = REC.ARCL_NO
--                   AND A.HSP_TP_CD       = HIS_HSP_TP_CD ;
--
--                EXCEPTION
--                    WHEN NO_DATA_FOUND THEN
--                        NULL;
--                    WHEN OTHERS THEN
--                        IO_ERRYN  := 'Y';
--                        IO_ERRMSG := '시약입고 마감여부 업데이트중 ERROR발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                        RETURN;
--            END;
--            
--            BEGIN
--                UPDATE MSELMDSD A
--                   SET A.USE_QTY_APY_YN     = 'Y'
--                     , A.USE_QTY_APY_STF_NO = HIS_STF_NO
--                     , A.USE_QTY_APY_DTM    = V_SYSDATE
--                     , A.LSH_STF_NO         = HIS_STF_NO
--                     , A.LSH_DTM            = V_SYSDATE
--                     , A.LSH_PRGM_NM        = HIS_PRGM_NM
--                     , A.LSH_IP_ADDR        = HIS_IP_ADDR
--                 WHERE A.USE_DT             = REC.STK_DT
----                   AND A.EXM_CD             = REC.EXM_CD
--                   AND A.ARCL_NO            = REC.ARCL_NO
--                   AND A.HSP_TP_CD          = HIS_HSP_TP_CD ;
--
--                EXCEPTION
--                    WHEN NO_DATA_FOUND THEN
--                        NULL;
--                    WHEN OTHERS THEN
--                        IO_ERRYN  := 'Y';
--                        IO_ERRMSG := '시약소모 마감여부 업데이트중 ERROR발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                        RETURN;
--            END;
--        END LOOP;


END PC_MSE_REAGENT_CLOSING;

/***********************************************************************************************
*    서비스이름  : PC_MSE_LM_ODRER_BATCH
*    최초 작성일 : 2014.03.12
*    최초 작성자 : 추윤정
*    DESCRIPTION : 신장내과 자동 타과의뢰 요청.
*    수 정 사 항 : 2014.05.08 같은일자에 데이타가 여러건 발생한 경우(pk중복) 단계가 가장 높은것만 입력 할 수 있도록 수정처리.
**********************************************************************************************/
PROCEDURE PC_MSE_LM_ODRER_BATCH ( IN_DATE            IN DATE
                                , HIS_HSP_TP_CD      IN MSBIOBMD.HSP_TP_CD%TYPE
                                , IO_ERRYN           IN OUT  VARCHAR2          -- ERROR여부
                                , IO_ERRMSG          IN OUT  VARCHAR2
                                )  
IS
  WK_EXM_HOPE_DT       VARCHAR2(10);          
  WK_RSLT_MDF_DTM      VARCHAR2(20);
  WK_EXRS_CNTE         MSELMAID.SMP_EXRS_CNTE%TYPE;
  WK_EXM_CD            MSELMAID.EXM_CD%TYPE;  
  WK_RSLT              VARCHAR2(1)      := NULL; 
  T_INS_FLAG           VARCHAR2(1)      := '';
  T_UPT_FLAG           VARCHAR2(1)      := '';   
  IN_JOBDATE            VARCHAR2(100)                  :=TO_CHAR(SYSDATE-1,'YYYYMMDD');   
BEGIN
      
 /* PC_DAY_ALL_BATCH_OTHERS 일배치 PROCEDURE 에서 사용 되고 파라메터도 받는 다. HIS_HSP_TP_CD 파라메터 수정시 원무팀 문의 필요 [이상수]*/    
    BEGIN
        FOR REC  IN ( SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ODRER_BATCH */
                             A.PT_NO
                           , A.ADS_DT
                           , A.PACT_ID
                        FROM ACPPRAAM A
                           , PCTPCPAM_DAMO B
                       WHERE A.SIHS_YN   = 'Y'
                         AND A.PT_NO     = B.PT_NO
                         AND XBIL.FT_PCT_AGE('AGE', IN_DATE - 1, B.PT_BRDY_DT) >= 18   
                         AND A.HSP_TP_CD = HIS_HSP_TP_CD
                         AND A.APCN_YN = 'N'
                    )
        LOOP
            BEGIN
                BEGIN
                    SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ODRER_BATCH */
                           SUBSTR(EXRS_CNTE, 1, INSTR(UPPER(EXRS_CNTE),'^', 1, 1)-1)                                                                         EXM_HOPE_DT
                         , SUBSTR(EXRS_CNTE, INSTR(UPPER(EXRS_CNTE),'^', 1, 1)+1, INSTR(UPPER(EXRS_CNTE),'^', 1, 2)-INSTR(UPPER(EXRS_CNTE),'^', 1, 1)-1)     RSLT_MDF_DTM
                         , SUBSTR(EXRS_CNTE, INSTR(UPPER(EXRS_CNTE),'^', 1, 2)+1, INSTR(UPPER(EXRS_CNTE),'^', 1, 3)-INSTR(UPPER(EXRS_CNTE),'^', 1, 2)-1)     EXRS_CNTE
                         , SUBSTR(EXRS_CNTE, INSTR(UPPER(EXRS_CNTE),'^', 1, 3)+1)                                                                            EXM_CD
                      INTO WK_EXM_HOPE_DT
                         , WK_RSLT_MDF_DTM
                         , WK_EXRS_CNTE
                         , WK_EXM_CD 
                      FROM ( SELECT XSUP.PKG_MSE_SPCMPTHL_BATCH.FT_MSE_EXRS_CNTE(IN_DATE, REC.PT_NO, REC.PACT_ID, TO_CHAR(REC.ADS_DT,'YYYY-MM-DD'), HIS_HSP_TP_CD) EXRS_CNTE FROM DUAL ); 
                EXCEPTION
                    WHEN OTHERS THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := '기준 검사결과 조회 중 에러 발생 ERRCODE = ' || TO_CHAR(SQLCODE);
                        RETURN;                      
                END;
                  
                BEGIN
                    FOR REC2 IN ( SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ODRER_BATCH */
                                         SEQ
                                       , EXM_HOPE_DT
                                       , RSLT_MDF_DTM     
                                       , SMP_EXRS_CNTE
                                       , EXM_CD    
                                       , HSPI_TP_CD
                                       , PACT_TP_CD
                                    FROM ( SELECT ROW_NUMBER() OVER (PARTITION BY A.PT_NO ORDER BY A.SMP_EXRS_CNTE DESC )             SEQ            --검사결과 높은것 부터....
                                                , TO_CHAR(A.EXM_HOPE_DT,'YYYY-MM-DD')                                             EXM_HOPE_DT
                                                , A.RSLT_MDF_DTM                                                                  RSLT_MDF_DTM
                                                , A.SMP_EXRS_CNTE                                                                 SMP_EXRS_CNTE
                                                , A.EXM_CD                                                                        EXM_CD
                                                , C.HSPI_TP_CD                                                                    HSPI_TP_CD
                                                , C.PACT_TP_CD                                                                    PACT_TP_CD
                                             FROM MSELMAID A
                                                , MSELMCED B
                                                , MOOOREXM C
                                            WHERE A.PT_NO           =  REC.PT_NO
                                              AND A.RSLT_MDF_DTM    >  TO_DATE(WK_RSLT_MDF_DTM,'YYYY-MM-DD HH24:MI:SS') 
                                              AND A.RSLT_MDF_DTM    BETWEEN IN_DATE - 1 AND IN_DATE - 0.00001   
                                              AND A.SPEX_PRGR_STS_CD = '3'
                                              AND A.EXM_CD          IN ('L30410','L30410LS')  --Creatinine
                                              AND A.SPCM_NO         = B.SPCM_NO
                                              AND B.SPCM_NO         = C.SPCM_PTHL_NO
                                              AND B.ORD_ID          = C.ORD_ID
                                              AND C.ODDSC_TP_CD     = 'C'
                                              AND C.PACT_ID         = REC.PACT_ID
                                              AND C.PACT_TP_CD      = 'I'
                                              AND B.HSP_TP_CD =HIS_HSP_TP_CD
                                              AND NOT EXISTS (SELECT '1'
                                                                FROM MSELMAID D
                                                               WHERE A.SPCM_NO = D.SPCM_NO
                                                                 AND D.EXM_CD IN ('L30410','L30410LS')  --Creatinine
                                                                 AND NVL(D.SMP_EXRS_CNTE,'#') <> '#' 
                                                                 AND D.HSP_TP_CD = HIS_HSP_TP_CD
                                                                 AND (ASCII(SUBSTR(D.EXRS_CNTE,1,1)) < 48
                                                                      OR ASCII(SUBSTR(D.EXRS_CNTE,1,1)) > 57
                                                                      OR ASCII(SUBSTR(D.EXRS_CNTE,LENGTH(D.EXRS_CNTE),1)) < 48
                                                                      OR ASCII(SUBSTR(D.EXRS_CNTE,LENGTH(D.EXRS_CNTE),1)) > 57
                                                                      OR INSTR(LOWER(D.EXRS_CNTE),'X') > 0 ))
                                         ) 
                                     ORDER BY SEQ
                                )
                    LOOP
                        SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ODRER_BATCH */
                               CASE WHEN REC2.SMP_EXRS_CNTE >= WK_EXRS_CNTE * 3 THEN '3'
                                    WHEN REC2.SMP_EXRS_CNTE >= WK_EXRS_CNTE * 2 AND REC2.SMP_EXRS_CNTE < WK_EXRS_CNTE * 3 THEN '2'
                                    WHEN REC2.SMP_EXRS_CNTE >= WK_EXRS_CNTE * 1.5 AND REC2.SMP_EXRS_CNTE < WK_EXRS_CNTE * 2 THEN '1'
                                    WHEN REC2.SMP_EXRS_CNTE >= WK_EXRS_CNTE + 0.3 THEN '1'
                                    ELSE NULL
                               END
                          INTO WK_RSLT
                          FROM DUAL;  
                        
                        IF WK_RSLT IS NOT NULL THEN  
                            --타과의뢰급성신손상구분코드에 대한 데이터가 없으면 INSERT처리  
                            --해당일자 이전에 높은 단계의 값이 있을 경우 INSERT 처리 하지 않음.  
                            BEGIN
                                SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ODRER_BATCH */
                                       DECODE(COUNT(*), 0, 'Y', 'N')
                                  INTO T_INS_FLAG
                                  FROM HMED.MRDDRACD B
                                 WHERE B.PT_NO               = REC.PT_NO
                                   AND B.PACT_ID             = REC.PACT_ID
                                   AND B.ODRER_TP_CD         = '8'
                                   AND B.HSP_TP_CD           = HIS_HSP_TP_CD 
                                   AND B.ODRER_ACNEDMG_TP_CD >= WK_RSLT       --해당 단계보다 높은 단계가 없을 경우 Insert
                                   AND B.AUTO_ODRER_DC_TP_CD = 'C';
    
                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    T_INS_FLAG := 'Y';
                                WHEN OTHERS THEN
                                    T_INS_FLAG := 'N';
                            END;                        
                            
                            IF T_INS_FLAG = 'Y' THEN  
                                BEGIN
                                    INSERT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ODRER_BATCH */
                                      INTO HMED.MRDDRACD ( PT_NO
                                                         , PACT_ID
                                                         , ODRER_TP_CD
                                                         , RER_DTM
                                                         , HSP_TP_CD
                                                         , HSPI_TP_CD
                                                         , PACT_TP_CD
                                                         , REQ_CNTE
                                                         , AUTO_ODRER_TP_CD
                                                         , AUTO_ODRER_DC_TP_CD
                                                         , SMSS_YN
                                                         , FSR_STF_NO
                                                         , FSR_DTM
                                                         , FSR_PRGM_NM    
                                                         , FSR_IP_ADDR  
                                                         , LSH_STF_NO
                                                         , LSH_DTM
                                                         , LSH_PRGM_NM   
                                                         , LSH_IP_ADDR
                                                         , ODRER_ACNEDMG_TP_CD
                                                         )
                                                  VALUES ( REC.PT_NO
                                                         , REC.PACT_ID
                                                         , '8' 
                                                         , IN_DATE - 1 --진료팀 요청으로 수정.--REC2.RSLT_MDF_DTM
                                                         , HIS_HSP_TP_CD
                                                         , REC2.HSPI_TP_CD
                                                         , REC2.PACT_TP_CD
                                                         , (SELECT S.SCLS_COMN_CD_NM
                                                              FROM MSELMSID S
                                                             WHERE S.LCLS_COMN_CD = 'ACNEDMG'
                                                               AND S.SCLS_COMN_CD = WK_RSLT
                                                               AND S.HSP_TP_CD    = HIS_HSP_TP_CD
                                                               AND ROWNUM         = 1)
                                                         , 'N'
                                                         , 'C'
                                                         , 'N'
                                                         , 'SSUP04'
                                                         , SYSDATE
                                                         , 'PC_MSE_LM_ODRER_BATCH'    
                                                         , '172.0.0.1'   
                                                         , 'SSUP04'
                                                         , SYSDATE
                                                         , 'PC_MSE_LM_ODRER_BATCH'    
                                                         , '172.0.0.1'   
                                                         , WK_RSLT
                                                         );
                                EXCEPTION
                                    WHEN DUP_VAL_ON_INDEX  THEN
                                        --PK중복시 값 체크하여 높으면 UPDATE 처리.
                                        --현재단계보다 낮은 단계일경우.......같은날 여러번 검사 한 경우....? 
                                        BEGIN
                                            BEGIN
                                                SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.PC_MSE_LM_ODRER_BATCH */
                                                       DECODE(COUNT(*), 0, 'Y', 'N')
                                                  INTO T_UPT_FLAG
                                                  FROM HMED.MRDDRACD B
                                                 WHERE B.PT_NO               = REC.PT_NO
                                                   AND B.PACT_ID             = REC.PACT_ID
                                                   AND B.ODRER_TP_CD         = '8'
                                                   AND B.RER_DTM             = IN_DATE - 1
                                                   AND B.HSP_TP_CD           = HIS_HSP_TP_CD 
                                                   AND B.AUTO_ODRER_DC_TP_CD = 'C'
                                                   AND B.ODRER_ACNEDMG_TP_CD >= WK_RSLT;
                    
                                            EXCEPTION
                                                WHEN NO_DATA_FOUND THEN
                                                    T_UPT_FLAG := 'Y';
                                                WHEN OTHERS THEN
                                                    T_UPT_FLAG := 'N';
                                            END;
                                            
                                            --해당 배치일자에 입력 하려는 단계보다 낮은 단계가 있을 경우 수정처리.
                                            IF T_UPT_FLAG = 'Y' THEN
                                                BEGIN
                                                    UPDATE HMED.MRDDRACD B
                                                       SET B.ODRER_ACNEDMG_TP_CD = WK_RSLT
                                                         , B.REQ_CNTE = (SELECT S.SCLS_COMN_CD_NM
                                                                           FROM MSELMSID S
                                                                          WHERE S.LCLS_COMN_CD = 'ACNEDMG'
                                                                            AND S.SCLS_COMN_CD = WK_RSLT
                                                                            AND S.HSP_TP_CD    = HIS_HSP_TP_CD
                                                                            AND ROWNUM         = 1)
                                                         , B.AUTO_ODRER_DC_TP_CD = 'C'
                                                         , B.LSH_PRGM_NM         = 'PC_MSE_LM_ODRER_BATCH_UPDATE'
                                                     WHERE B.PT_NO               = REC.PT_NO
                                                       AND B.PACT_ID             = REC.PACT_ID
                                                       AND B.ODRER_TP_CD         = '8'
                                                       AND B.RER_DTM             = IN_DATE - 1
                                                       AND B.HSP_TP_CD           = HIS_HSP_TP_CD; 
                                                EXCEPTION
                                                    WHEN OTHERS THEN
                                                        IO_ERRYN  := 'Y';
                                                        IO_ERRMSG := '신장내과 자동타과의뢰 수정 중 오류발생!!!' || 'ERRCODE = '|| TO_CHAR(SQLCODE);
                                                        RETURN;
                                                END;
                                            END IF;
                                        END; 
                                    WHEN OTHERS THEN
                                        IO_ERRYN  := 'Y';
                                        IO_ERRMSG := '신장내과 자동타과의뢰 처리 중 오류발생(1)' || 'ERRCODE = '|| TO_CHAR(SQLCODE);
                                        RETURN;
                                END;
                             END IF;
                        END IF;
                    END LOOP;
                EXCEPTION
                    WHEN OTHERS THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := '신장내과 자동타과의뢰 처리 중 오류발생(2)' || 'ERRCODE = '|| TO_CHAR(SQLCODE);
                        RETURN;    
                END;
            END;
        END LOOP;
        
    END;    
    
                           
END PC_MSE_LM_ODRER_BATCH;          

/***********************************************************************************************
*    서비스이름  : FT_MSE_EXRS_CNTE
*    최초 작성일 : 2014.03.12
*    최초 작성자 : 추윤정
*    DESCRIPTION : 신장내과 자동 타과의뢰 기준값 조회
*    수 정 사 항 : 2015-08-27 김성룡 201507-00574 기준변경
**********************************************************************************************/
FUNCTION FT_MSE_EXRS_CNTE ( IN_DATE            IN DATE
                          , IN_PT_NO         IN VARCHAR2
                          , IN_PACT_ID       IN VARCHAR2
                          , IN_ADS_DT        IN VARCHAR2 
                          , IN_HSP_TP_CD     IN VARCHAR2)
RETURN VARCHAR2
IS
  WK_EXM_HOPE_DT       VARCHAR2(10);
  WK_RSLT_MDF_DTM      VARCHAR2(20);
  WK_EXRS_CNTE         MSELMAID.EXRS_CNTE%TYPE;
  WK_EXM_CD            MSELMAID.EXM_CD%TYPE;
BEGIN
--1)입원14일전 ~ 입원일까지 시행한 검사 중 첫번째시행한 검사결과 기준(모든처방기준) - 5월 26일 이후 데이타 조회.
--  입원전 결과가 없으면 입원 후 첫번째 시행검사.     
--수정사항 2015-08-27 김성룡
--1)입원3개월전 ~ 입원일까지 시행한 검사 중 첫번째시행한 검사결과 기준(모든처방기준) - 5월 26일 이후 데이타 조회.
--  결과가 없으면 입원전 6개월 ~ 입원전 3개월 첫번째 시행검사.     
    BEGIN
            SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.FT_MSE_EXRS_CNTE */
                   MIN(TO_CHAR(A.EXM_HOPE_DT, 'YYYY-MM-DD')) KEEP(DENSE_RANK FIRST ORDER BY A.RSLT_MDF_DTM , A.ACPT_DTM)               EXM_HOPE_DT
                 , MIN(TO_CHAR(A.RSLT_MDF_DTM, 'YYYY-MM-DD HH24:MI:SS')) KEEP(DENSE_RANK FIRST ORDER BY A.RSLT_MDF_DTM , A.ACPT_DTM)   RSLT_MDF_DTM
                 , MIN(A.SMP_EXRS_CNTE) KEEP(DENSE_RANK FIRST ORDER BY A.RSLT_MDF_DTM , A.ACPT_DTM)                                    EXRS_CNTE
                 , MIN(A.EXM_CD) KEEP(DENSE_RANK FIRST ORDER BY A.RSLT_MDF_DTM , A.ACPT_DTM)                                           EXM_CD
              INTO WK_EXM_HOPE_DT
                 , WK_RSLT_MDF_DTM
                 , WK_EXRS_CNTE 
                 , WK_EXM_CD
              FROM MSELMAID A
                 , MSELMCED B
                 , MOOOREXM C
             WHERE A.PT_NO           =  IN_PT_NO
               AND A.RSLT_MDF_DTM    BETWEEN ADD_MONTHS(TO_DATE(IN_ADS_DT,'YYYY-MM-DD'),-3)     --입원14일전 부터 -> 입원3개월로 수정
                                         AND TO_DATE(IN_ADS_DT,'YYYY-MM-DD')          --입원일까지..
               AND A.RSLT_MDF_DTM    >= TO_DATE('2018-08-11','YYYY-MM-DD') 
               AND A.EXM_CD          IN ('L30410','L30410LS')  --Creatinine
               AND A.SPEX_PRGR_STS_CD = '3'                                           --검증완료
               AND A.SPCM_NO          = B.SPCM_NO
               AND B.SPCM_NO          = C.SPCM_PTHL_NO
               AND B.ORD_ID          = C.ORD_ID
               AND C.ODDSC_TP_CD     = 'C'                                            --정상오더
               AND NOT EXISTS (SELECT '1'
                                 FROM MSELMAID D
                                WHERE A.SPCM_NO = D.SPCM_NO
                                  AND D.EXM_CD IN  ('L30410','L30410LS')  --Creatinine
                                  AND NVL(D.SMP_EXRS_CNTE,'#') <> '#'
                                  AND (ASCII(SUBSTR(D.SMP_EXRS_CNTE,1,1)) < 48
                                       OR ASCII(SUBSTR(D.SMP_EXRS_CNTE,1,1)) > 57
                                       OR ASCII(SUBSTR(D.SMP_EXRS_CNTE,LENGTH(D.SMP_EXRS_CNTE),1)) < 48
                                       OR ASCII(SUBSTR(D.SMP_EXRS_CNTE,LENGTH(D.SMP_EXRS_CNTE),1)) > 57
                                       OR INSTR(LOWER(D.SMP_EXRS_CNTE),'X') > 0 ));    
    END;
     
    IF WK_EXM_HOPE_DT IS NULL THEN
        BEGIN
            SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.FT_MSE_EXRS_CNTE */
                   MIN(TO_CHAR(A.EXM_HOPE_DT, 'YYYY-MM-DD')) KEEP(DENSE_RANK FIRST ORDER BY A.RSLT_MDF_DTM , A.ACPT_DTM)               EXM_HOPE_DT
                 , MIN(TO_CHAR(A.RSLT_MDF_DTM, 'YYYY-MM-DD HH24:MI:SS')) KEEP(DENSE_RANK FIRST ORDER BY A.RSLT_MDF_DTM , A.ACPT_DTM)   RSLT_MDF_DTM
                 , MIN(A.SMP_EXRS_CNTE) KEEP(DENSE_RANK FIRST ORDER BY A.RSLT_MDF_DTM , A.ACPT_DTM)                                        EXRS_CNTE
                 , MIN(A.EXM_CD) KEEP(DENSE_RANK FIRST ORDER BY A.RSLT_MDF_DTM , A.ACPT_DTM)                                           EXM_CD
              INTO WK_EXM_HOPE_DT
                 , WK_RSLT_MDF_DTM
                 , WK_EXRS_CNTE 
                 , WK_EXM_CD
              FROM MSELMAID A
                 , MSELMCED B
                 , MOOOREXM C
             WHERE A.PT_NO           =  IN_PT_NO
--               AND A.RSLT_MDF_DTM    >= TO_DATE(IN_ADS_DT,'YYYY-MM-DD')  
               AND A.RSLT_MDF_DTM    BETWEEN ADD_MONTHS(TO_DATE(IN_ADS_DT,'YYYY-MM-DD'),-6)     --입원 6개월로 수정
                                         AND ADD_MONTHS(TO_DATE(IN_ADS_DT,'YYYY-MM-DD'),-3)     --입원 3개월 까지..
               AND A.RSLT_MDF_DTM    >= TO_DATE('2018-08-11','YYYY-MM-DD')  
               AND A.EXM_CD          IN ('L30410','L30410LS')  --Creatinine
               AND A.SPEX_PRGR_STS_CD = '3'
               AND A.SPCM_NO         = B.SPCM_NO
               AND B.SPCM_NO         = C.SPCM_PTHL_NO
               AND B.ORD_ID          = C.ORD_ID
               AND C.ODDSC_TP_CD     = 'C'                                                         
               AND NOT EXISTS (SELECT '1'
                                 FROM MSELMAID D
                                WHERE A.SPCM_NO = D.SPCM_NO
                                  AND D.EXM_CD IN ('L30410','L30410LS')  --Creatinine
                                  AND NVL(D.SMP_EXRS_CNTE,'#') <> '#'
                                  AND (ASCII(SUBSTR(D.SMP_EXRS_CNTE,1,1)) < 48
                                       OR ASCII(SUBSTR(D.SMP_EXRS_CNTE,1,1)) > 57
                                       OR ASCII(SUBSTR(D.SMP_EXRS_CNTE,LENGTH(D.SMP_EXRS_CNTE),1)) < 48
                                       OR ASCII(SUBSTR(D.SMP_EXRS_CNTE,LENGTH(D.SMP_EXRS_CNTE),1)) > 57
                                        OR INSTR(LOWER(D.SMP_EXRS_CNTE),'X') > 0 )); 
        END;
    END IF;   
    
    IF WK_EXM_HOPE_DT IS NULL THEN
        BEGIN
            SELECT /*+ PKG_MSE_SPCMPTHL_BATCH.FT_MSE_EXRS_CNTE */
                   TO_CHAR(TO_DATE(IN_ADS_DT,'YYYY-MM-DD')-1, 'YYYY-MM-DD')                       EXM_HOPE_DT
                 , TO_CHAR(TO_DATE(IN_ADS_DT,'YYYY-MM-DD')-1, 'YYYY-MM-DD HH24:MI:SS')            RSLT_MDF_DTM
                 , TO_CHAR(DECODE(A.SEX_TP_CD, 'M', POWER(75 / 175 / POWER(XBIL.FT_PCT_AGE('AGE', TO_DATE(IN_ADS_DT,'YYYY-MM-DD'), A.PT_BRDY_DT), -0.203), (-1/1.154))
                                             , 'F', POWER(75 / 175 / 0.742 / POWER(XBIL.FT_PCT_AGE('AGE', TO_DATE(IN_ADS_DT,'YYYY-MM-DD'), A.PT_BRDY_DT), -0.203), (-1/1.154))),'fm99999.0')                                      EXRS_CNTE
                 , 'L30410'                                                                          EXM_CD
              INTO WK_EXM_HOPE_DT
                 , WK_RSLT_MDF_DTM
                 , WK_EXRS_CNTE 
                 , WK_EXM_CD
              FROM PCTPCPAM_DAMO A
             WHERE A.PT_NO           =  IN_PT_NO
             ; 
        END;
    END IF; 

    IF WK_RSLT_MDF_DTM IS NULL THEN 
        RETURN(NULL);
    ELSE     
       RETURN (WK_EXM_HOPE_DT || '^' || WK_RSLT_MDF_DTM || '^' || WK_EXRS_CNTE || '^' || WK_EXM_CD);
    END IF;
END FT_MSE_EXRS_CNTE;
                                
END PKG_MSE_SPCMPTHL_BATCH;