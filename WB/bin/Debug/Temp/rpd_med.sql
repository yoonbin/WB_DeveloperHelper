FUNCTION      FT_GET_RPD_MED_INF	 ( IN_HSP_TP_CD         IN VARCHAR2
                                     , IN_PT_NO             IN VARCHAR2	
                                     , IN_PACT_ID           IN VARCHAR2    
                                     , IN_PACT_TP_CD		IN VARCHAR2
                                     , IN_DTE               IN VARCHAR2
                                     , IN_FLAG				IN VARCHAR2)  
    RETURN VARCHAR2
    /**********************************************************************
    작 성 자 : 오원빈 
    작 성 일 : 2022-11-24
    내    용 : 입원/응급 범례모음 (신속진료정보)
    IN_FLAG : S  - Strok_CP -> S OR ''
    	    : A	 - AMI      -> A OR ''
    	    : T	 - Trauma   -> Y OR ''
    EX )   
    SELECT NVL(STROKE_CP,AMI_YN) SRK_OCUR_TP_CD 
         , TRAUMA_OCUR_YN
      FROM(                      
        SELECT FT_GET_RPD_MED_INF(A.HSP_TP_CD,A.PT_NO,A.RPY_PACT_ID,A.PACT_TP_CD,'','S') STROKE_CP
             , FT_GET_RPD_MED_INF(A.HSP_TP_CD,A.PT_NO,A.RPY_PACT_ID,A.PACT_TP_CD,'','A') AMI_YN
             , FT_GET_RPD_MED_INF(A.HSP_TP_CD,A.PT_NO,A.RPY_PACT_ID,A.PACT_TP_CD,'','T') TRAUMA_OCUR_YN                     
             ,A.* 
         FROM MOOOREXM A
         )
    수정이력 : 
    **********************************************************************/        
IS
    V_STROKE_CP       VARCHAR2(5) :='';
    V_AMI             VARCHAR2(5) :='';
    V_TRAUMA          VARCHAR2(5) :='';
    
    V_PACT_ID         ACPPRAAM.PACT_ID%TYPE := '';    
    V_DTE             DATE := '';
BEGIN
    --YYYY-MM-DD 형식으로 변경                        
    BEGIN
        V_DTE := NVL(TO_DATE(SUBSTR(REGEXP_REPLACE(IN_DTE,'-*',''),0,8),'YYYY-MM-DD'),TRUNC(SYSDATE));
    EXCEPTION                                                                                         
        WHEN OTHERS THEN
            V_DTE := TRUNC(SYSDATE);
    END;
    IF IN_PACT_ID IS NOT NULL AND IN_PACT_ID != '' THEN
        V_PACT_ID := IN_PACT_ID;                                                           
    ELSIF IN_PACT_TP_CD IS NOT NULL AND (IN_PACT_ID IS NULL OR IN_PACT_ID = '') THEN   
        BEGIN
            IF IN_PACT_TP_CD = 'E' THEN            
                SELECT PACT_ID
                  INTO V_PACT_ID
                  FROM (
                        SELECT PACT_ID
                             , ROW_NUMBER() OVER(PARTITION BY PT_NO ORDER BY EMRM_ARVL_DTM DESC)     SEQ
                          FROM ACPPRETM
                         WHERE HSP_TP_CD = IN_HSP_TP_CD
                           AND PT_NO = IN_PT_NO
                           AND EMRM_ARVL_DTM < V_DTE + 1          --IN_DTE를 포함한 날 이전중 가장 최근 PACT_ID        
                           AND NVL(APCN_YN,'N') = 'N' 
                       )
                 WHERE SEQ = 1 ;     
            ELSIF IN_PACT_TP_CD = 'I' THEN
                SELECT PACT_ID
                  INTO V_PACT_ID
                  FROM (
                        SELECT PACT_ID
                             , ROW_NUMBER() OVER(PARTITION BY PT_NO ORDER BY ADS_DTM DESC)     SEQ
                          FROM ACPPRAAM
                         WHERE HSP_TP_CD = IN_HSP_TP_CD
                           AND PT_NO = IN_PT_NO  
                           AND ADS_DTM < V_DTE + 1                 --IN_DTE를 포함한 날 이전중 가장 최근 PACT_ID
                           AND NVL(APCN_YN,'N') = 'N' 
                       )
                 WHERE SEQ = 1 ;               
            ELSE   
                RETURN '';
            END IF;                
        END;
    ELSE
        RETURN '';
    END IF;                          
    
    BEGIN
    --Stroke_CP
        SELECT DECODE(XMED.FT_MOO_SRK_CP_YN(V_PACT_ID,IN_HSP_TP_CD),'Y','S','')
          INTO V_STROKE_CP
          FROM DUAL;
    --AMI                                                                                
        SELECT DECODE(XMED.FT_MOO_AMI_YN(IN_PT_NO,IN_HSP_TP_CD),'Y','A','')
          INTO V_AMI
          FROM DUAL;                                                  
    --Trauma          
        SELECT DECODE(XMED.PKG_MOO_TRAUMACENTER.FT_TRAUMACENTER_CALL_YN(IN_PT_NO, V_PACT_ID, IN_HSP_TP_CD),'Y','Y','')
          INTO V_TRAUMA
          FROM DUAL;       
    EXCEPTION     
        WHEN OTHERS THEN
            RETURN '';          
    END;
    	
	IF IN_FLAG = 'S' THEN
		RETURN V_STROKE_CP;
	ELSIF IN_FLAG = 'A' THEN
		RETURN V_AMI;         
	ELSIF IN_FLAG = 'T' THEN	
        RETURN V_TRAUMA;	
    ELSE
        RETURN '';                      
	END IF;   
END;