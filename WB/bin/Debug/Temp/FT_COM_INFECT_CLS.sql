FUNCTION FT_COM_INFECT_CLS( IN_HSP_TP_CD  IN VARCHAR2
                          , IN_PT_NO      IN VARCHAR2
                          , IN_GUBN       IN VARCHAR2  
)                                                    
/**********************************************************************************************
* 서비스이름    : FT_COM_INFECT_CLS
* 최초 작성일   : 2020-07-31
* 최초 작성자   : 김금덕
* Description : 바코드라벨에 감염정보 표기(LIS, 환자라벨, 진료) 공통사용
                 2020-08-06 김성회, 감염정보 우선순위 및 구분자로 표기 분기 (IN_GUBN (1) : FULL (2) : 약어) 
                 2022-06-10 송지혜, IN_GUBN (3) : 알파벳 추가
***********************************************************************************************/
RETURN VARCHAR2  
    
IS
   
V_RETURN            VARCHAR2(100) :='';  --INFECTION
    
BEGIN        
	BEGIN    

		SELECT SUBSTR(LISTAGG(T.INFC_INF || '/') WITHIN GROUP (ORDER BY T.SORT1, T.SORT2), 0, LENGTH(LISTAGG(T.INFC_INF || '/') WITHIN GROUP (ORDER BY T.SORT1, T.SORT2))-1) AS INFC_ALPB_NKNM_LIST
		  INTO V_RETURN
		  FROM ( SELECT DISTINCT CASE WHEN B.INFC_PATH_TP_CD = '1' THEN NVL(DECODE(IN_GUBN, '3', C.DTRL5_NM), NVL(B.INFC_ALPB_NKNM, DECODE(IN_GUBN, '1', C.DTRL3_NM, '2', C.DTRL4_NM)))
                                      WHEN B.INFC_PATH_TP_CD = '3' THEN NVL(DECODE(IN_GUBN, '3', C.DTRL5_NM), NVL(B.INFC_ALPB_NKNM, DECODE('2', '1', C.DTRL3_NM, '2', C.DTRL4_NM)))
                                      ELSE DECODE(IN_GUBN, '1', C.DTRL3_NM, '2', C.DTRL4_NM, '3', NVL(C.DTRL5_NM,C.DTRL4_NM))
                                      END                                                 AS INFC_INF
                      , DECODE(IN_GUBN, '3', TO_NUMBER(C.DTRL6_NM), TO_NUMBER(C.DTRL2_NM))      AS SORT1
                      , DECODE(B.INFC_PATH_TP_CD, '1', B.SCRN_SORT_SEQ)     AS SORT2
                   FROM MOOPTIPD A
                      , MOOPTICC B
                      , CCCCCSTE C
				 WHERE A.PT_NO       = IN_PT_NO
				   AND A.INFC_INF_CD = B.INFC_INF_CD
				   AND B.INFC_PATH_TP_CD <> 'A'
				   AND B.ALERT_INF_ICLS_YN = 'Y'
				   AND B.AVL_END_DT = TO_DATE('99991231','YYYYMMDD')
				   AND A.DEL_YN     = 'N'   
			       AND C.COMN_GRP_CD = 'DR00065'
                   AND C.COMN_CD = B.INFC_PATH_TP_CD
                   AND C.DTRL2_NM IS NOT NULL
		        ) T;		
	
	END;    
	                       
	RETURN V_RETURN ;
  
END;