FUNCTION      FT_GET_PACS_HISORDERID ( IN_HSP_TP_CD    IN VARCHAR2
                                     , IN_ORD_ID       IN VARCHAR2  )        
    RETURN VARCHAR2
    /**********************************************************************
    작 성 자 : 오원빈 
    작 성 일 : 2021-10-05
    내    용 : ORD_ID 를 받아서 PACS의 HISORDERID를 리턴함.
               
    수정이력 : 인터페이스 중간테이블의 가장 최근 상태값이 CA(캔슬)이라면 조회해오지 않도록 수정 
    **********************************************************************/        
IS
    R_ORD_ID                VARCHAR2(100) :='';                    --PACS ORD_ID
    V_ORD_ID                VARCHAR2(100) := '';    
    V_ACCS_ID               VARCHAR2(100) := '';        
    
    V_DB_LINK    VARCHAR2(4000) := '';
    V_QUERY VARCHAR2(4000) :='';
BEGIN  
    BEGIN                            
        IF IN_HSP_TP_CD = '01' THEN
            V_DB_LINK := '@DL_PACS_HAKDONG';
        ELSIF IN_HSP_TP_CD = '02' THEN
            V_DB_LINK := '@DL_PACS_HWASUN';
        ELSIF IN_HSP_TP_CD = '03' THEN
            V_DB_LINK := '@DL_PACS_BITGOEUL';
        ELSIF IN_HSP_TP_CD = '04' THEN
            V_DB_LINK := '@DL_PACS_DENTAL';                        
        END IF;
    END;                        
                    
    BEGIN
        SELECT ORD_ID
              ,ACCS_ID            
          INTO V_ORD_ID
              ,V_ACCS_ID
          FROM MSERMAAD
         WHERE HSP_TP_CD = IN_HSP_TP_CD
           AND ORD_ID = IN_ORD_ID;                                               
    END;
    BEGIN                                               
        SELECT ORD_ID                  --ORD_ID로 매칭된게 없으면 ACCS_ID 로 조회
          INTO R_ORD_ID
          FROM HINF.MSERMINF_ORU A
                ,MSERMAAD B
                ,(SELECT EVENTTYPE,HISORDERID
                	FROM (
                          SELECT EVENTTYPE,HISORDERID
                        	FROM HINF.MSERMINF_ORR
                           WHERE HISORDERID = V_ORD_ID
                           ORDER BY QUEUEID DESC
                            )
                   WHERE ROWNUM =1
                  )C
         WHERE B.HSP_TP_CD = IN_HSP_TP_CD
           AND B.ORD_ID = A.HISORDERID          
           AND B.ORD_ID = C.HISORDERID
           AND C.EVENTTYPE <> 'CA'
           AND B.ORD_ID = IN_ORD_ID
           AND A.READSTATUS IN ('M','L','C')  
           AND ROWNUM = 1 
           ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            BEGIN
                SELECT ACCS_ID
                  INTO R_ORD_ID
                  FROM HINF.MSERMINF_ORU A
                      ,MSERMAAD B
                      ,(SELECT EVENTTYPE,HISORDERID
                    	  FROM (
                                SELECT EVENTTYPE,HISORDERID
                            	  FROM HINF.MSERMINF_ORR
                                 WHERE HISORDERID = V_ACCS_ID
                                 ORDER BY QUEUEID DESC
                                )
                         WHERE ROWNUM =1
                  )C
                 WHERE B.HSP_TP_CD = IN_HSP_TP_CD
                   AND B.ACCS_ID   = A.HISORDERID             
                   AND B.ACCS_ID   = C.HISORDERID
                   AND C.EVENTTYPE <> 'CA'                        
                   AND B.ORD_ID = IN_ORD_ID                                 
                   AND A.READSTATUS IN ('M','L','C')            
                   AND ROWNUM = 1                    
                   ;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    BEGIN
                        V_QUERY :=  'SELECT HISORDERID FROM DORDER' || V_DB_LINK || ' WHERE HISORDERID = ''' || V_ACCS_ID  || '''';   
                    END; 
                    BEGIN
                        EXECUTE IMMEDIATE V_QUERY
                           INTO R_ORD_ID;
                    EXCEPTION
                        WHEN OTHERS THEN
                            R_ORD_ID := NULL;
                            RETURN R_ORD_ID ;
                    END ;
            END;
    END;

    RETURN R_ORD_ID;
   
END;