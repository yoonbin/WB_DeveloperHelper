PROCEDURE      PC_MSD_BATCH_DRGORDPSBYN ( IN_HSP_TP_CD IN VARCHAR2 )
                               
/*******************************************************************************
**  NAME        : PC_MSD_BATCH_DRGORDPSBYN
**  DESCRIPTION : 약 처방 가능여부 수정
**  TABLES      : BSFSMMHH, MSERMROD  
**  COMMENTS    : 상용약품마스터 기준으로, 처방 시작 일자와 종료예정일자를 확인하여
**                CCOOCBAC 의 처방가능여부를 수정함. 전남대병원 요청사항
**                종료일자는 타파트 영향도가 커서, 종료예정일자 입력하면 해당 종료예정일자에 종료하는것으로 수정함. - 2021.12.19  
                  멀티병원 공통코드로 관리하여 적용함 - 2022-03-18
*******************************************************************************/                                   
IS

BEGIN
 --1. 종료된 약품 닫기
    BEGIN
        FOR REC IN ( SELECT /*+ PC_MSD_BATCH_DRGORDPSBYN */
                            C.MDPR_CD
                          , C.MNF_CMP_CD
                          , C.HSP_TP_CD
                       FROM MSDMDCOE C
                      WHERE C.HSP_TP_CD IN (SELECT X.MDCN_DUTY_SRES_NO 
                                              FROM MSDMDJID X
                                             WHERE X.HSP_TP_CD = IN_HSP_TP_CD
                                               AND X.MDCN_DUTY_CTG_CD = 'PH092'
                                               )

                        AND C.END_ANTC_DT IS NOT NULL
                        AND C.END_DT      IS NULL
                        AND TRUNC(SYSDATE) >= C.END_ANTC_DT
                        AND C.STR_DT      < C.END_ANTC_DT
                        AND EXISTS (SELECT '1'
                                      FROM CCOOCBAC O
                                     WHERE O.ORD_CD               = C.MDPR_CD
                                       AND O.HSP_TP_CD            = C.HSP_TP_CD
                                       AND NVL(O.ORD_PSB_YN, 'N') = 'Y'
                                       AND NVL(O.ORD_END_YN, 'Y') = 'N')
                    )
        LOOP
        
        BEGIN
            UPDATE /* PC_MSD_BATCH_DRGORDPSBYN */
                   CCOOCBAC
               SET CHOP_PSB_YN	= 'N' --소아처방가능여부
                 , ADOP_PSB_YN  = 'N' --성인처방가능여부
                 , ORD_PSB_YN   = 'N' --처방가능여부
                 , ORD_END_YN   = 'Y' --처방종료여부
                 , LSH_DTM      = SYSDATE
                 , LSH_STF_NO   = 'BATCH'
                 , LSH_PRGM_NM  = 'XSUP.PC_MSD_BATCH_DRGORDPSBYN'
                 , LSH_IP_ADDR  = '1.1.1.1'
             WHERE ORD_CD    = REC.MDPR_CD
               AND HSP_TP_CD = REC.HSP_TP_CD
               AND ORD_END_YN = 'N'
               ; 
        EXCEPTION
        	WHEN OTHERS THEN
                RETURN;	
        END;
        
        BEGIN
            UPDATE /* PC_MSD_BATCH_DRGORDPSBYN */
                   MSDMDCOE
               SET END_DT	    = TRUNC(SYSDATE)
                 , END_ANTC_DT  = NULL
                 , LSH_DTM      = SYSDATE
                 , LSH_STF_NO   = 'BATCH_T'
                 , LSH_PRGM_NM  = 'XSUP.PC_MSD_BATCH_DRGORDPSBYN'
                 , LSH_IP_ADDR  = '1.1.1.1'
             WHERE MDPR_CD    = REC.MDPR_CD
               AND HSP_TP_CD  = REC.HSP_TP_CD
               AND END_DT    IS NULL
               AND MNF_CMP_CD = REC.MNF_CMP_CD
               ; 
        EXCEPTION
        	WHEN OTHERS THEN
                RETURN;	
        END;
        
        END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
            RETURN;	
    END;
    --2. 처방 가능 약품 열기
    BEGIN
        FOR REC IN ( SELECT /*+ PC_MSD_BATCH_DRGORDPSBYN */
                            C.MDPR_CD
                          , C.MNF_CMP_CD
                          , C.HSP_TP_CD  
                       FROM MSDMDCOE C
                      WHERE C.HSP_TP_CD IN (SELECT X.MDCN_DUTY_SRES_NO 
                                              FROM MSDMDJID X
                                             WHERE X.HSP_TP_CD = IN_HSP_TP_CD
                                               AND X.MDCN_DUTY_CTG_CD = 'PH092'
                                               )

                        AND TRUNC(SYSDATE) >= C.STR_DT
                        AND C.END_DT  IS NOT NULL
                        AND C.END_ANTC_DT IS NULL
                        AND C.STR_DT       > C.END_DT
                        AND EXISTS (SELECT '1'
                                      FROM CCOOCBAC O
                                     WHERE O.ORD_CD               = C.MDPR_CD
                                       AND O.HSP_TP_CD            = C.HSP_TP_CD
                                       AND NVL(O.ORD_PSB_YN, 'N') = 'N'
                                       AND NVL(O.ORD_END_YN, 'Y') = 'Y')
                    )
        LOOP
        
        BEGIN
            UPDATE /* PC_MSD_BATCH_DRGORDPSBYN */
                   CCOOCBAC
               SET CHOP_PSB_YN	= 'Y' --소아처방가능여부
                 , ADOP_PSB_YN  = 'Y' --성인처방가능여부
                 , ORD_PSB_YN   = 'Y' --처방가능여부
                 , ORD_END_YN   = 'N' --처방종료여부
                 , LSH_DTM      = SYSDATE
                 , LSH_STF_NO   = 'BATCH'
                 , LSH_PRGM_NM  = 'XSUP.PC_MSD_BATCH_DRGORDPSBYN'
                 , LSH_IP_ADDR  = '1.1.1.1'
             WHERE ORD_CD    = REC.MDPR_CD
               AND HSP_TP_CD = REC.HSP_TP_CD
               ;
        EXCEPTION
        	WHEN OTHERS THEN
                RETURN;	
        END;   
        
        BEGIN
            UPDATE /* PC_MSD_BATCH_DRGORDPSBYN */
                   MSDMDCOE
               SET END_DT	    = NULL
                 , HSIN_RTNT_YN = DECODE(NVL(HSIO_ORD_ESSN_TP_CD, '*'), 'I', 'Y', 'S', 'Y', 'N', 'Y', '')
                 , LSH_DTM      = SYSDATE
                 , LSH_STF_NO   = 'BATCH'
                 , LSH_PRGM_NM  = 'XSUP.PC_MSD_BATCH_DRGORDPSBYN'
                 , LSH_IP_ADDR  = '1.1.1.1'
             WHERE MDPR_CD   = REC.MDPR_CD
               AND HSP_TP_CD = REC.HSP_TP_CD
               AND MNF_CMP_CD = REC.MNF_CMP_CD
               ; 
        EXCEPTION
        	WHEN OTHERS THEN
                RETURN;	
        END;
        
        END LOOP;
	EXCEPTION
		WHEN OTHERS THEN 
            RETURN;	
    END;
    
   

END PC_MSD_BATCH_DRGORDPSBYN;