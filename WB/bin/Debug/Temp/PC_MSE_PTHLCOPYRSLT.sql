PROCEDURE        PC_MSE_PTHLCOPYRSLT(  HIS_HSP_TP_CD          IN      VARCHAR2    
--                                     , IN_EXM_RST_HSP_TP_CD      IN      VARCHAR2                     
--                                     , IN_EXM_CNSG_HSP_TP_CD  IN      VARCHAR2                                        
                                     , IN_PTHL_NO             IN      VARCHAR2     
                                     , IN_HIS_STF_NO          IN      VARCHAR2    --14.작업자
                                     , IN_HIS_PRGM_NM          IN      VARCHAR2
                                     , IN_HIS_IP_ADDR         IN      VARCHAR2                                
                                     , IO_ERR_YN              OUT     VARCHAR2
                                     , IO_ERR_MSG             OUT     VARCHAR2 
                                )

AS

       V_RST_PTHL_NO MSEPMPMD.PTHL_NO%TYPE := '';   
       V_EXM_RST_HSP_TP_CD MSEPMPMD.HSP_TP_CD%TYPE := '';
       V_EXM_CNSG_HSP_TP_CD MSEPMPMD.HSP_TP_CD%TYPE := '';
       
       V_HIDR_CMPL_DTM         MSEPMPMD.HIDR_CMPL_DTM%TYPE ;
       V_HIDR_STF_NO         MSEPMPMD.HIDR_STF_NO%TYPE ;
       V_TH1_IPDR_STF_NO     MSEPMPMD.TH1_IPDR_STF_NO%TYPE ;
       V_TH2_IPDR_STF_NO     MSEPMPMD.TH2_IPDR_STF_NO%TYPE ;
       V_ADD_RSLT_YN         MSEPMPMD.ADD_RSLT_YN%TYPE ;
       V_RMK                 MSEPMPMD.RMK%TYPE; 
       V_PTHL_DGNS_CNTE        MSEPMPMD.PTHL_DGNS_CNTE%TYPE ;
       V_IPTN_MLT_STF_NO     MSEPMPMD.IPTN_MLT_STF_NO%TYPE ;
       V_CNSG_IPPR_ID        MSERMMLD.IPPR_ID%TYPE;        
       
       V_IPPR_SEQ              MSERMMLD.IPPR_SEQ%TYPE;
       V_IPPR_ID            MSERMMLD.IPPR_ID%TYPE;
       V_MDFM_INPT_NOTM     MSERMMLD.MDFM_INPT_NOTM%TYPE;    

         V_MDFM_ID         MSERMMLD.MDFM_ID%TYPE;
         V_MDFM_FOM_SEQ      MSERMMLD.MDFM_FOM_SEQ%TYPE;
         V_DEL_YN          MSERMMLD.DEL_YN%TYPE;       
         V_IPTN_DTM          MSEPMPMD.IPTN_DTM%TYPE;
    
        V_TRSR_INPT_DTM        MSEPMPMD.TRSR_INPT_DTM%TYPE;
        V_TRSR_PRNT_DTM        MSEPMPMD.TRSR_PRNT_DTM%TYPE;
        V_TRSR_STF_NO       MSEPMPMD.TRSR_STF_NO%TYPE;
        V_RTIN_TRSR_STF_NO  MSEPMPMD.RTIN_TRSR_STF_NO%TYPE;
        
            
BEGIN  

--     RAISE_APPLICATION_ERROR(-20001, HIS_HSP_TP_CD || '\' || IN_PTHL_NO ) ;    
     
        
        BEGIN
            SELECT RST_PTHL_NO      
                 , EXM_RST_HSP_TP_CD  
                 , EXM_CNSG_HSP_TP_CD
              INTO V_RST_PTHL_NO
                 , V_EXM_RST_HSP_TP_CD
                 , V_EXM_CNSG_HSP_TP_CD
              FROM MSEPMERD
             WHERE EXM_CNSG_HSP_TP_CD = HIS_HSP_TP_CD
               AND PTHL_NO      = IN_PTHL_NO      
               ;                --                    
        EXCEPTION        
            WHEN NO_DATA_FOUND THEN   --위탁 검사없으면 RETURN 
                   IO_ERR_YN := 'N';
                   RETURN;                             
            WHEN OTHERS  THEN
                  IO_ERR_YN  := 'Y';
                  IO_ERR_MSG := '위탁병리번호 SELECT 오류  = ' || TO_CHAR(SQLCODE);
                  RETURN;        
        END; 
        
--        RAISE_APPLICATION_ERROR(-20001, V_RST_PTHL_NO || '\' || V_EXM_RST_HSP_TP_CD || '\' ||  V_EXM_CNSG_HSP_TP_CD) ;           
        
        BEGIN
            SELECT HIDR_CMPL_DTM
                 , HIDR_STF_NO
                 , TH1_IPDR_STF_NO
                 , TH2_IPDR_STF_NO      
                 , ADD_RSLT_YN       
                 , RMK             
                 , PTHL_DGNS_CNTE
                 , IPTN_MLT_STF_NO
                 , IPTN_DTM      
                 , TRSR_INPT_DTM
                 , TRSR_PRNT_DTM
                 , TRSR_STF_NO
                 , RTIN_TRSR_STF_NO
              INTO V_HIDR_CMPL_DTM   
                   , V_HIDR_STF_NO     
                   , V_TH1_IPDR_STF_NO     
                   , V_TH2_IPDR_STF_NO        
                   , V_ADD_RSLT_YN    
                   , V_RMK           
                   , V_PTHL_DGNS_CNTE
                   , V_IPTN_MLT_STF_NO
                   , V_IPTN_DTM
                   , V_TRSR_INPT_DTM
                 , V_TRSR_PRNT_DTM
                 , V_TRSR_STF_NO
                 , V_RTIN_TRSR_STF_NO
              FROM MSEPMPMD
             WHERE 1=1
               AND HSP_TP_CD = V_EXM_CNSG_HSP_TP_CD
               AND PTHL_NO      = IN_PTHL_NO   
               ;
        EXCEPTION
            WHEN  OTHERS  THEN
                  IO_ERR_YN  := 'Y';
                  IO_ERR_MSG := '수탁병리접수정보 SELECT 오류  = ' || TO_CHAR(SQLERRM);
                  RETURN;
        END;
        
        
        BEGIN
          UPDATE MSEPMPMD
               SET 
                   HIDR_CMPL_DTM     = V_HIDR_CMPL_DTM    /*수기판독의완료일시*/
                 , HIDR_STF_NO         = V_HIDR_STF_NO      /*수기판독의직원번호*/                            
                 , TH1_IPDR_STF_NO     = V_TH1_IPDR_STF_NO  /*1번째판독의직원번호*/
                 , TH2_IPDR_STF_NO     = V_TH2_IPDR_STF_NO  /*2번째판독의직원번호*/             
                 , ADD_RSLT_YN         = V_ADD_RSLT_YN      /*추가결과여부*/  
                 , TRSR_INPT_DTM       = V_TRSR_INPT_DTM
                 , RMK                 = V_RMK              /*비고*/        
                 , PLEX_PRGR_STS_CD = 'D'
                 , LSH_DTM             = SYSDATE          /*최종변경일시*/
                 , LSH_STF_NO         = IN_HIS_STF_NO       /*최종변경직원번호*/
                 , LSH_PRGM_NM         = IN_HIS_PRGM_NM      /*최종변경프로그램명*/
                 , LSH_IP_ADDR         = IN_HIS_IP_ADDR      /*최종변경IP주소*/
                 , PTHL_DGNS_CNTE     = V_PTHL_DGNS_CNTE   /*병리진단내용*/
                 , IPTN_MLT_STF_NO     = V_IPTN_MLT_STF_NO  /*판독병리사직원번호*/
             WHERE HSP_TP_CD     = V_EXM_RST_HSP_TP_CD
               AND PTHL_NO         = V_RST_PTHL_NO
               ;
        EXCEPTION
            WHEN  OTHERS  THEN
                  IO_ERR_YN  := 'Y';
                  IO_ERR_MSG := '수탁 병원 병리접수정보  UPDATE 오류  = ' || TO_CHAR(SQLERRM);
                  RETURN;

        END;       
        
        BEGIN
             UPDATE MSELMCED
                 SET EXM_PRGR_STS_CD  = 'D'
                 , LSH_DTM             = SYSDATE          /*최종변경일시*/
                 , LSH_STF_NO         = IN_HIS_STF_NO       /*최종변경직원번호*/
                 , LSH_PRGM_NM         = IN_HIS_PRGM_NM      /*최종변경프로그램명*/
                 , LSH_IP_ADDR         = IN_HIS_IP_ADDR      /*최종변경IP주소*/
               WHERE  PTHL_NO = V_RST_PTHL_NO
                AND HSP_TP_CD = V_EXM_RST_HSP_TP_CD;
        EXCEPTION
            WHEN OTHERS THEN
                 IO_ERR_YN  := 'Y';
                 IO_ERR_MSG := '검체정보 update 처리 중 에러 발생. ErrCd = ' || TO_CHAR(SQLERRM);
                 RETURN;

        END;

        BEGIN
            UPDATE MOOOREXM
            SET    EXM_PRGR_STS_CD  = 'D'
                 , BRFG_DTM         = V_HIDR_CMPL_DTM
                 , BRFG_STF_NO      = V_TH2_IPDR_STF_NO
                 , TH2_IPDR_STF_NO  = V_TH2_IPDR_STF_NO
                 , LSH_DTM             = SYSDATE          /*최종변경일시*/
                 , LSH_STF_NO         = IN_HIS_STF_NO       /*최종변경직원번호*/
                 , LSH_PRGM_NM         = IN_HIS_PRGM_NM      /*최종변경프로그램명*/
                 , LSH_IP_ADDR         = IN_HIS_IP_ADDR      /*최종변경IP주소*/
            WHERE  SPCM_PTHL_NO     = V_RST_PTHL_NO
              AND HSP_TP_CD         = V_EXM_RST_HSP_TP_CD;
        EXCEPTION
                WHEN OTHERS THEN
                     IO_ERR_YN  := 'Y';
                     IO_ERR_MSG := '오더정보 update 처리 중 에러 발생. ErrCd = ' || TO_CHAR(SQLERRM);
                     RETURN;
        END;
        
--        RAISE_APPLICATION_ERROR(-20001, V_EXM_RST_HSP_TP_CD || '\' || V_RST_PTHL_NO || '\\'  || V_EXM_CNSG_HSP_TP_CD || '\' || IN_PTHL_NO) ;          
        
        BEGIN
          INSERT INTO MSEPMRID    
          SELECT  V_EXM_RST_HSP_TP_CD
                  , V_RST_PTHL_NO
                  , '1'
                  , PLRT_LDAT
                  , NULL 
                  , NULL
                  , NULL
                  , NULL
                  , V_TH1_IPDR_STF_NO
                  , V_TH2_IPDR_STF_NO
                  , SYSDATE
                  , IN_HIS_STF_NO 
                  , IN_HIS_PRGM_NM 
                  , IN_HIS_IP_ADDR   
                  , SYSDATE
                  , IN_HIS_STF_NO 
                  , IN_HIS_PRGM_NM 
                  , IN_HIS_IP_ADDR
                  , NULL
                  , PTHL_OGN_CNTE
                  , MLT_DGNS_CNTE    
                  , PTHL_DR_DGNS_CNTE    
                  , IPTN_MLT_STF_NO    
                  , ADD_IPTN_RSDT_NM    
                  , ADD_IPTN_SPCT_NM    
                  , IPPR_ID                   
            FROM MSEPMRID 
           WHERE 1=1
             AND HSP_TP_CD     = V_EXM_CNSG_HSP_TP_CD
             AND PTHL_NO     = IN_PTHL_NO         
             AND RSLT_SEQ     = (SELECT MAX(RSLT_SEQ)
                                  FROM MSEPMRID
                                 WHERE HSP_TP_CD = V_EXM_CNSG_HSP_TP_CD
                                   AND PTHL_NO    = IN_PTHL_NO)
             ;             
        EXCEPTION
            WHEN  OTHERS  THEN
                  IO_ERR_YN  := 'Y';
                  IO_ERR_MSG := '병리결과판독정보 INSERT 오류 = ' || TO_CHAR(SQLERRM);
                  RETURN;
        END;
        
--        RAISE_APPLICATION_ERROR(-20001, V_COUNT) ;   
        
        BEGIN 
           SELECT IPPR_ID
             INTO V_CNSG_IPPR_ID
             FROM MSEPMRID
            WHERE 1=1
              AND HSP_TP_CD  = V_EXM_CNSG_HSP_TP_CD
              AND PTHL_NO      = IN_PTHL_NO   
              AND RSLT_SEQ     = (SELECT MAX(RSLT_SEQ)
                                  FROM MSEPMRID
                                 WHERE HSP_TP_CD = V_EXM_CNSG_HSP_TP_CD
                                   AND PTHL_NO    = IN_PTHL_NO)
                ;    
        EXCEPTION
            WHEN  OTHERS  THEN
                  IO_ERR_YN  := 'Y';
                  IO_ERR_MSG := 'MSEPMRID SELECT 오류  = ' || TO_CHAR(SQLERRM);
                  RETURN;
        END; 
            
--        RAISE_APPLICATION_ERROR(-20001, V_EXM_RST_HSP_TP_CD || '/' || V_RST_PTHL_NO || '/' || V_EXM_CNSG_HSP_TP_CD || '/' || IN_PTHL_NO) ;   
                
        IF V_CNSG_IPPR_ID IS NOT NULL THEN        --서식결과로 입력되었으면 서식도 복사해서 가져감  
            BEGIN
                SELECT  IPPR_SEQ    
                      , IPPR_ID    
                      , MDFM_ID
                      , MDFM_FOM_SEQ    
                      , MDFM_INPT_NOTM    
                      , DEL_YN  
                  INTO V_IPPR_SEQ                   
                     , V_IPPR_ID    
                     , V_MDFM_ID
                     , V_MDFM_FOM_SEQ    
                     , V_MDFM_INPT_NOTM    
                     , V_DEL_YN  
                  FROM MSERMMLD A
                 WHERE HSP_TP_CD = V_EXM_CNSG_HSP_TP_CD
                   AND IPTN_NO      = IN_PTHL_NO 
                   AND IPPR_SEQ  = (SELECT MAX(IPPR_SEQ)
                                         FROM MSERMMLD 
                                        WHERE HSP_TP_CD = V_EXM_CNSG_HSP_TP_CD
                                          AND IPTN_NO      = IN_PTHL_NO)    
                    ;            
            EXCEPTION
                WHEN  OTHERS  THEN
                     IO_ERR_YN  := 'Y';
                      IO_ERR_MSG := 'MSERMMLD SELECT 오류  = ' || TO_CHAR(SQLERRM);
                      RETURN;                                
                
            END;
            
            --    RAISE_APPLICATION_ERROR(-20001, V_EXM_RST_HSP_TP_CD || '/' || V_RST_PTHL_NO || '/' || V_IPPR_SEQ ) ;         
            
            BEGIN    
                INSERT INTO MSERMMLD
                         (
                           HSP_TP_CD            /*병원구분코드*/
                         , IPTN_NO              /*판독번호*/
                         , IPPR_SEQ             /*판독지순번*/
                         , IPPR_ID              /*판독지ID*/
                         , MDFM_ID              /*진료서식ID*/
                         , MDFM_FOM_SEQ         /*진료서식개정순번*/
                         , MDFM_INPT_NOTM       /*진료서식입력횟수*/
                         , DEL_YN               /*삭제여부*/
                         , FSR_DTM              /*최초등록일시*/
                         , FSR_STF_NO           /*최초등록직원번호*/
                         , FSR_PRGM_NM          /*최초등록프로그램명*/
                         , FSR_IP_ADDR          /*최초등록IP주소*/
                         , LSH_DTM              /*최종변경일시*/
                         , LSH_STF_NO           /*최종변경직원번호*/
                         , LSH_PRGM_NM          /*최종변경프로그램명*/
                         , LSH_IP_ADDR          /*최종변경IP주소*/
                         )
                    VALUES
                         (
                           V_EXM_RST_HSP_TP_CD
                         , V_RST_PTHL_NO
                         , V_IPPR_SEQ
                         , V_IPPR_ID
                         , V_MDFM_ID
                         , V_MDFM_FOM_SEQ
                         , V_MDFM_INPT_NOTM
                         , V_DEL_YN
                         , SYSDATE
                         , IN_HIS_STF_NO
                         , IN_HIS_PRGM_NM
                         , IN_HIS_IP_ADDR
                         , SYSDATE
                         , IN_HIS_STF_NO
                         , IN_HIS_PRGM_NM
                         , IN_HIS_IP_ADDR
                         )     
                         ;
            EXCEPTION
                WHEN  OTHERS  THEN
                      IO_ERR_YN  := 'Y';
                      IO_ERR_MSG := 'MSERMMLD INSERT 오류  = ' || TO_CHAR(SQLERRM);
                      RETURN;                     
            END;
                
            
            BEGIN
                INSERT INTO MSERMDTD
                    SELECT      V_EXM_RST_HSP_TP_CD
                            ,IPPR_ID
                            ,MDFM_FOM_SEQ
                            ,MDFM_CPEM_ID
                            ,IPTN_CNTE
                            ,DCST_LDAT    
                            ,FSRC_DCST_LDAT
                            ,FCHG_DCST_LDAT
                            ,NULL
                            ,NULL
                            ,NULL
                            ,'1'
                            , SYSDATE
                              , IN_HIS_STF_NO 
                              , IN_HIS_PRGM_NM 
                              , IN_HIS_IP_ADDR   
                              , SYSDATE
                              , IN_HIS_STF_NO 
                              , IN_HIS_PRGM_NM 
                              , IN_HIS_IP_ADDR                    
                    FROM MSERMDTD A
                    WHERE 1=1
                    AND HSP_TP_CD     = V_EXM_CNSG_HSP_TP_CD    
                    AND IPPR_ID     = V_IPPR_ID
                    AND MDFM_FOM_SEQ = V_MDFM_INPT_NOTM
                    ;     
            EXCEPTION
                WHEN  OTHERS  THEN
                     IO_ERR_YN  := 'Y';
                      IO_ERR_MSG := 'MSERMDTD INSERT 오류  = ' || TO_CHAR(SQLERRM);
                      RETURN;        
            
            END;
            
        END IF;  -- V_CNSG_IPPR_ID IS NOT NULL THEN
        
        
        
    

END PC_MSE_PTHLCOPYRSLT;