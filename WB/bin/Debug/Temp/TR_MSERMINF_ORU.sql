TRIGGER HINF.TR_MSERMINF_ORU
AFTER INSERT ON "HINF"."MSERMINF_ORU" FOR EACH ROW
/* PACS Report Receive Data Trgger
1. READSTATUS 가 M일 경우 : 촬영일시 Update
2. MSERMDDD INSERT
3. MSERMDDD UPDATE
*/    

/*운영기 빌드는 IPACS 계정에서 해야함*/
DECLARE   
   WK_IPTN_NO            MSERMAAD.IPTN_NO%TYPE         := NULL;  
   WK_ORD_CTG_CD         MSERMAAD.ORD_CTG_CD%TYPE      := NULL;  
   WK_ORD_ID             MSERMAAD.ORD_ID%TYPE          := NULL;    
   WK_PT_NO              MSERMAAD.PT_NO%TYPE           := NULL;      
   WK_ORD_DT             VARCHAR2(10)                  := NULL;    
   WK_ORD_SEQ            MSERMAAD.ORD_SEQ%TYPE         := NULL;
   WK_ORD_CD             MSERMAAD.ORD_CD%TYPE          := NULL;      
   WK_EXM_PRGR_STS_CD    MSERMAAD.EXM_PRGR_STS_CD%TYPE := NULL; 
   WK_PHTG_DTM           MSERMAAD.PHTG_DTM%TYPE        := NULL;  
   
   WK_IPTN_NO_NEW        VARCHAR2(30) := '';  
   WK_LSH_DTM            VARCHAR2(14) := NULL;  
   WK_HSP_TP_CD          VARCHAR2(2)  := NVL(:NEW.COOPHOSPID,'01');
   
   WK_ACCS_ID            MSERMAAD.ACCS_ID%TYPE := NULL;     
   WK_ETNL_IPTN_YN       MSERMAAD.ETNL_IPTN_YN%TYPE := NULL;
   
   WK_OTSR_BZET_NM       MSERMDDD.OTSR_BZET_NM%TYPE := NULL;
   WK_OTSR_BZET_TEL_NO   MSERMDDD.OTSR_BZET_TEL_NO%TYPE := NULL;   
   
   IO_ERRYN              VARCHAR2(20) := 'N';  
   IO_ERRMSG             VARCHAR2(100):= NULL;  
   
   V_CNT                 NUMBER       := 0;    

BEGIN  
    IF INSERTING THEN            
        BEGIN
            SELECT IPTN_NO  
                 , ORD_CTG_CD    
                 , ORD_ID
                 , PT_NO   
                 , TO_CHAR(ORD_DT, 'YYYY-MM-DD') 
                 , ORD_SEQ                         
                 , ORD_CD    
                 , EXM_PRGR_STS_CD 
                 , PHTG_DTM
                 , ACCS_ID
                 , ETNL_IPTN_YN
              INTO WK_IPTN_NO                                              
                 , WK_ORD_CTG_CD 
                 , WK_ORD_ID 
                 , WK_PT_NO    
                 , WK_ORD_DT
                 , WK_ORD_SEQ          
                 , WK_ORD_CD 
                 , WK_EXM_PRGR_STS_CD  
                 , WK_PHTG_DTM
                 , WK_ACCS_ID
                 , WK_ETNL_IPTN_YN
              FROM MSERMAAD
             WHERE ORD_ID    = :NEW.HISORDERID
               AND HSP_TP_CD = WK_HSP_TP_CD ;
             
            EXCEPTION                                              
                WHEN NO_DATA_FOUND THEN
                    BEGIN
                        SELECT IPTN_NO  
                             , ORD_CTG_CD    
                             , ORD_ID
                             , PT_NO   
                             , TO_CHAR(ORD_DT, 'YYYY-MM-DD') 
                             , ORD_SEQ                         
                             , ORD_CD    
                             , EXM_PRGR_STS_CD 
                             , PHTG_DTM
                             , ACCS_ID
                             , ETNL_IPTN_YN
                          INTO WK_IPTN_NO  
                             , WK_ORD_CTG_CD 
                             , WK_ORD_ID 
                             , WK_PT_NO    
                             , WK_ORD_DT
                             , WK_ORD_SEQ          
                             , WK_ORD_CD 
                             , WK_EXM_PRGR_STS_CD  
                             , WK_PHTG_DTM
                             , WK_ACCS_ID
                             , WK_ETNL_IPTN_YN
                          FROM MSERMAAD
                         WHERE ACCS_ID    = :NEW.HISORDERID
                           AND HSP_TP_CD = WK_HSP_TP_CD ;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN                                      
                            BEGIN   
                                INSERT 
                                  INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                  SELECT '처방정보없음 (접수정보없음)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                  FROM DUAL;
                        
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        NULL;
                            END;
                            RETURN;
        --                    RAISE_APPLICATION_ERROR('-20001', '오더정보없음');  
                        WHEN OTHERS THEN     
                            BEGIN   
                                INSERT 
                                  INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                  SELECT '처방정보 조회 에러',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                  FROM DUAL;
                        
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        NULL;
                            END;   
                            RETURN;               
--                    RAISE_APPLICATION_ERROR('-20001', '오더 정보 조회중 에러발생 '); 
                    END;
        END;
        --타외래에서 외주판독 문의하기 위한 외주업체 연락처정보 조회 2022.06.10
        BEGIN                 
            SELECT EXM_GRP_DTL_CD_NM
                 , TH1_ASST_GRP_NM      
              INTO WK_OTSR_BZET_NM       --외주업체명
                 , WK_OTSR_BZET_TEL_NO   --외주업체 연락처정보                 
              FROM
              (        
                SELECT EXM_GRP_DTL_CD_NM
                     , TH1_ASST_GRP_NM
                  FROM MSERMCCC
                 WHERE HSP_TP_CD = WK_HSP_TP_CD
                   AND EXM_GRP_CD = 'OUTO_CPAD'
                   AND EXM_GRP_DTL_CD <> 'ALL'
                   AND EXM_GRP_DTL_CD = (SELECT UPPER(TH1_ASST_GRP_NM)
                                           FROM MSERMCCC
                                          WHERE HSP_TP_CD = WK_HSP_TP_CD
                                            AND EXM_GRP_CD  = 'HEXM'
                                            AND EXM_GRP_DTL_CD = WK_ORD_CD
                                            AND ROWNUM = 1)
                UNION ALL 
                SELECT EXM_GRP_DTL_CD_NM
                     , TH1_ASST_GRP_NM
                  FROM MSERMCCC
                 WHERE HSP_TP_CD = WK_HSP_TP_CD
                   AND EXM_GRP_CD = 'OUTO_CPAD'                                                     
                   AND EXM_GRP_DTL_CD = 'ALL'               
               )
            ;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;                                                     
        END;           
        -- 2018.11.16 팍스 결과인터페이스시 영상,핵의학,방종에 해당하는 검사의 경우에만 인터페이스 함.
        IF WK_ORD_CTG_CD NOT IN ('BR1','BN1','RT4') THEN  
            BEGIN   
                INSERT 
                  INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                  SELECT '영상,핵의학,방종에 해당하지 않은 검사임',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                  FROM DUAL;
        
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
            END;   
            RETURN;        
        END IF;          
        
        IF WK_EXM_PRGR_STS_CD = 'F' THEN  
            BEGIN   
                INSERT 
                  INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                  SELECT '취소상태의 검사이므로 인터페이스 하지 않음',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                  FROM DUAL;
        
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
            END;   
            RETURN;        
        END IF;        
        
        /* PACS에서 이미지 Matching & 검사시행완료 */
        IF :NEW.READSTATUS = 'M' THEN
            IF WK_EXM_PRGR_STS_CD IN ('E','C') THEN
                BEGIN
                    UPDATE MSERMAAD
                       SET EQUP_IMPL_DTM    = :NEW.WORKTIME
                         , LSH_STF_NO       = 'INTERF'
                         , LSH_DTM          = SYSDATE
                         , LSH_PRGM_NM      = 'PACS'
                         , LSH_IP_ADDR      = '127.0.0.1'
                     WHERE 1=1
--                       AND ORD_ID    = :NEW.HISORDERID   
                       AND ORD_ID    = WK_ORD_ID    -- ORD_ID가 길면 ACCS_ID가 중간테이블로 넘어갔기 때문에 위에서 받은 ORD_ID로 조회
                       AND HSP_TP_CD = WK_HSP_TP_CD ; 

                    IF (SQL%ROWCOUNT = 0) THEN
                        BEGIN   
                            INSERT 
                              INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                              SELECT '촬영일시 업데이트 에러(데이타 존재하지 않음)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                              FROM DUAL;
                    
                            EXCEPTION
                                WHEN OTHERS THEN
                                    NULL;
                        END;   
                        RETURN;
--                        RAISE_APPLICATION_ERROR('-20001', '촬영일시 업데이트중 에러발생(데이타 존재하지 않음)');    
                    END IF;
                    EXCEPTION
                        WHEN OTHERS THEN    
                            BEGIN   
                                INSERT 
                                  INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                  SELECT '촬영일시 업데이트 에러',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                  FROM DUAL;
                        
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        NULL;
                            END;   
                            RETURN;                         
--                            RAISE_APPLICATION_ERROR('-20001', '촬영일시 업데이트중 에러발생');                   
                END;
            ELSE
                BEGIN   
                    INSERT 
                      INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                      SELECT '검사상태 오류(검사 상태가 접수,시행상태 아님)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                      FROM DUAL;
            
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                END;   
                
                RETURN;
            END IF;          
            

        /* PACS에서 외부판독여부 */
        ELSIF :NEW.READSTATUS = 'I' THEN
            IF WK_EXM_PRGR_STS_CD IN ('E','C') THEN
                BEGIN
                    UPDATE MSERMAAD
                       SET ETNL_IPTN_YN     = NVL(:NEW.REFIMGCENTER, 'N')
                         , LSH_STF_NO       = 'INTERF'
                         , LSH_DTM          = SYSDATE
                         , LSH_PRGM_NM      = 'PACS'
                         , LSH_IP_ADDR      = '127.0.0.1'
                     WHERE ORD_ID    = :NEW.HISORDERID   
                       AND HSP_TP_CD = WK_HSP_TP_CD ; 

                    IF (SQL%ROWCOUNT = 0) THEN
                        BEGIN   
                            INSERT 
                              INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                              SELECT '외부판독여부 업데이트 에러(데이타 존재하지 않음)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                              FROM DUAL;
                    
                            EXCEPTION
                                WHEN OTHERS THEN
                                    NULL;
                        END;   
                        RETURN;
--                        RAISE_APPLICATION_ERROR('-20001', '촬영일시 업데이트중 에러발생(데이타 존재하지 않음)');    
                    END IF;
                    EXCEPTION
                        WHEN OTHERS THEN    
                            BEGIN   
                                INSERT 
                                  INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                  SELECT '외부판독여부 업데이트 에러',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                  FROM DUAL;
                        
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        NULL;
                            END;   
                            RETURN;                         
--                            RAISE_APPLICATION_ERROR('-20001', '촬영일시 업데이트중 에러발생');                   
                END;
            ELSE
                BEGIN   
                    INSERT 
                      INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                      SELECT '검사상태 오류(검사 상태가 접수,시행상태 아님_외부판독여부관련)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                      FROM DUAL;
            
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                END;   
                
                RETURN;
            END IF;                          

        /* C : Confirm(정식판독)
           L : Preliminary (임시판독) */
        ELSIF :NEW.READSTATUS IN ('C', 'L') THEN
            BEGIN
               IF WK_EXM_PRGR_STS_CD = 'C' THEN 
                   BEGIN      -- 2018.08.14 JEJ 접수상태 검사(시행 전 상태 검사에 대해 판독이 들어올 경우, J로 Flag를 남기고 에러처리함.)
                       INSERT 
                         INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                         SELECT '접수상태 검사이므로 판독입력 되지 않음',:NEW.QUEUEID, 'J', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                         FROM DUAL;
               
                       EXCEPTION
                           WHEN OTHERS THEN
                               NULL;
                   END;   
                   RETURN;
               ELSIF WK_EXM_PRGR_STS_CD = 'F' THEN 
                   BEGIN      -- 2018.08.14 JEJ 접수상태 검사(시행 전 상태 검사에 대해 판독이 들어올 경우, J로 Flag를 남기고 에러처리함.)
                       INSERT 
                         INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                         SELECT '취소상태 검사이므로 판독입력 되지 않음',:NEW.QUEUEID, 'J', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                         FROM DUAL;
               
                       EXCEPTION
                           WHEN OTHERS THEN
                               NULL;
                   END;   
                   RETURN;
               END IF;   
            END;  
    
            --- 2018.10.30 예외처리 추가함.
            BEGIN
               IF TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS') IS NULL THEN
                   BEGIN   
                       INSERT 
                         INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                         SELECT '판독정보 업데이트 에러 (CONFDATE, CONFTIME 존재하지 않음)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                         FROM DUAL;
               
                       EXCEPTION
                           WHEN OTHERS THEN
                               NULL;
                   END;   
                   RETURN;
--                                RAISE_APPLICATION_ERROR('-20001', '판독정보 업데이트중 에러발생 1(데이타 존재하지 않음)');    
               END IF;                    
            END; 
                       
            BEGIN
                IF :NEW.READSTATUS = 'L' THEN
                    BEGIN
                        INSERT
                            INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                 SELECT '임시판독은 가판독으로 변경하지 않음.',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                 FROM DUAL;
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;                                 
                    END;               
                    RETURN;
                END IF;
            END;
            
            BEGIN
                SELECT COUNT(*)
                  INTO V_CNT
                  FROM MSERMDDD
                 WHERE IPTN_NO   = WK_IPTN_NO
                   AND HSP_TP_CD = WK_HSP_TP_CD ;       
            END;
              
            --판독완료 되었을 경우 트리거 태우지 않는다.   
            --외부판독일 경우 판독완료된 상태에서도 수정가능함.       
            IF (WK_EXM_PRGR_STS_CD != 'N' OR (WK_ETNL_IPTN_YN = 'Y' AND WK_EXM_PRGR_STS_CD = 'N')) THEN
                --판독 수정시..  
                IF V_CNT > 0 THEN  
                --시간 체크           
                --2018.10.29 기존의 시간비교를 위한 체크로직 주석처리함. 무조건 큐잉된 데이터에 대해서 UPDATE하기로 함.
--                    BEGIN
--                        SELECT /*+ FIRST_ROWS */
--                               TO_CHAR(LSH_DTM,'YYYYMMDDHH24MISS')  
--                          INTO WK_LSH_DTM
--                          FROM MSERMDDD
--                         WHERE IPTN_NO   = WK_IPTN_NO
--                           AND HSP_TP_CD = WK_HSP_TP_CD ;   
--                       
--                        EXCEPTION
--                            WHEN OTHERS THEN   
--                                BEGIN   
--                                    INSERT 
--                                      INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
--                                                      SELECT '판독시간 조회 에러',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
--                                      FROM DUAL;
--                            
--                                    EXCEPTION
--                                        WHEN OTHERS THEN
--                                            NULL;
--                                END;   
--                                RETURN;                               
----                                RAISE_APPLICATION_ERROR('-20001', '판독시간 비교중 에러발생');
--                    END;   
                   
                    --EMR의 데이터가 최근판독이 아닐경우 update 한다.
                    --IF WK_LSH_DTM < :NEW.CRE_YMDH THEN
--                    IF WK_LSH_DTM < TO_CHAR(:NEW.WORKTIME,'YYYYMMDDHH24MISS') THEN
                        BEGIN
                            UPDATE MSERMDDD
                                SET TH2_IPDR_STF_NO      = UPPER(:NEW.READDR1)
                                  , TH3_IPDR_STF_NO      = UPPER(:NEW.READDR2)
                                  , TH4_IPDR_STF_NO      = UPPER(:NEW.CONFDR1)
                                  , TH5_IPDR_STF_NO      = UPPER(:NEW.CONFDR2)
                                  , TH6_IPDR_STF_NO      = UPPER(:NEW.CONFDR3)
                                  , TH1_IPTN_EXPL        = REPLACE(:NEW.READTEXT,'',' ')   -- 2018.08.21 특수문자 REPLACE
                                  , IPTN_CNCS_CNTE       = REPLACE(:NEW.CONCLUSION,'',' ') -- 2018.08.21 특수문자 REPLACE
                                  , REF_CNTE             = :NEW.RECOMMEND
                                  , IPTN_TP_CD           = DECODE(:NEW.READSTATUS, 'C', '1', '2')
                                  , IPTN_MDF_DTM         = DECODE(:NEW.READSTATUS, 'C', TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS')
                                                                                      , IPTN_MDF_DTM) -- C일경우에는 TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS')가 계속 UPDATE됨.
                                  , CFMT_DTM             = DECODE(:NEW.READSTATUS, 'C', NVL(CFMT_DTM, TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS'))
                                                                                      , CFMT_DTM) -- C일경우에는 TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS')가 최초 입력 후, UPDATE 되지 않음.
                                  , OTSR_BZET_NM         = DECODE(WK_ETNL_IPTN_YN,'Y',WK_OTSR_BZET_NM,NULL)  --외주판독이면 외주판독연락처 정보 넣어줌 . 2022.06.10
                                  , OTSR_BZET_TEL_NO     = DECODE(WK_ETNL_IPTN_YN,'Y',WK_OTSR_BZET_TEL_NO,NULL)
                                  , LSH_IP_ADDR         = '127.0.0.1'
                                  , LSH_STF_NO           ='INTERF'
                                  , LSH_DTM              = SYSDATE 
                                  , LSH_PRGM_NM          ='PACS'
--                                  , IPTN_DTM             = NVL(IPTN_DTM, :NEW.WORKTIME ) -- 2018.10.30 주석처리함. 최초 insert후 업데이트 하지 않음.
                              WHERE IPTN_NO              = WK_IPTN_NO
                                AND HSP_TP_CD            = WK_HSP_TP_CD ;

                            IF (SQL%ROWCOUNT = 0) THEN
                                BEGIN   
                                    INSERT 
                                      INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                      SELECT '판독정보 업데이트 에러 1(데이타 존재하지 않음)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                      FROM DUAL;
                            
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            NULL;
                                END;   
                                RETURN;
--                                RAISE_APPLICATION_ERROR('-20001', '판독정보 업데이트중 에러발생 1(데이타 존재하지 않음)');    
                            END IF;
                                                 
                            EXCEPTION
                                WHEN OTHERS THEN
                                    BEGIN   
                                        INSERT 
                                          INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                          SELECT '판독정보 업데이트 에러 1',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                          FROM DUAL;
                                
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                NULL;
                                    END;   
                                    RETURN;     
--                                    RAISE_APPLICATION_ERROR('-20001', '판독정보 업데이트중 에러발생');
                        END;  
                        
                        
                        BEGIN
                            UPDATE MSERMAAD
                               SET EXM_PRGR_STS_CD   = DECODE(WK_ETNL_IPTN_YN,'Y',DECODE(:NEW.READSTATUS, 'C', 'N','D'),'D') -- 외부판독의 경우, 무조건 판독상태로 받음. --> 2019.04.03 외부판독이면서,:NEW.READSTATUS = 'C'인 경우에만 판독상태로 받음.
                                 , IPTN_NO           = WK_IPTN_NO
                                 , IMG_NO            = WK_ACCS_ID
                                 , IPDR_STF_NO       = DECODE(WK_ETNL_IPTN_YN,'Y',UPPER(:NEW.CONFDR1)
                                                                                 ,DECODE(:NEW.READSTATUS, 'C', UPPER(:NEW.CONFDR1), IPDR_STF_NO))
                                 , FST_IPTN_STF_NO   = NVL(FST_IPTN_STF_NO ,UPPER(NVL2(:NEW.READDR1, :NEW.CONFDR1, :NEW.TYPISTID)))         -- 2013-12-18 김세용  최초 판독일 PACS에서 수정시 UPDATE 방지
                                 , FST_IPTN_DT       = NVL(FST_IPTN_DT, TO_DATE(:NEW.CONFDATE,'YYYYMMDD'))            -- 2013-12-18 김세용  최초 판독일 PACS에서 수정시 UPDATE 방지
                                 , FST_IPTN_DTM      = NVL(FST_IPTN_DTM, TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS') )                 -- 2013-12-18 김세용  최초 판독일 PACS에서 수정시 UPDATE 방지
                                 , LST_IPTN_DTM      = TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS')
                                 , SHR_YN            = 'Y'  --임상공유여부
                                 , INTF_SND_YN       = 'Y'  --인터페이스 전송여부
                                 , LSH_DTM           = SYSDATE 
                                 , LSH_STF_NO        = 'INTERF'
                                 , LSH_IP_ADDR       = '127.0.0.1'
                                 , LSH_PRGM_NM       = 'PACS'
                             WHERE ORD_ID    = WK_ORD_ID
                               AND HSP_TP_CD = WK_HSP_TP_CD ;

                            IF (SQL%ROWCOUNT = 0) THEN
                                BEGIN   
                                    INSERT 
                                      INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                      SELECT '접수정보 업데이트 에러 1(데이타 존재하지 않음)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                      FROM DUAL;
                            
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            NULL;
                                END;   
                                RETURN;
--                                RAISE_APPLICATION_ERROR('-20001', '판독정보 업데이트중 에러발생 3(데이타 존재하지 않음)');    
                            END IF;   
                                                     
                            EXCEPTION
                                WHEN OTHERS THEN
                                    BEGIN   
                                        INSERT 
                                          INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                          SELECT '접수정보 업데이트 에러 1',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                          FROM DUAL;
                                
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                NULL;
                                    END;   
                                    RETURN;                                
--                                    RAISE_APPLICATION_ERROR('-20001', '판독정보 업데이트중 에러발생');
                        END;      
                                           
                        BEGIN     
                            UPDATE MOOOREXM
                               SET EXM_PRGR_STS_CD   = DECODE(WK_ETNL_IPTN_YN,'Y',DECODE(:NEW.READSTATUS, 'C', 'N','D'),'D') -- 외부판독의 경우, 무조건 판독상태로 받음. --> 2019.04.03 외부판독이면서,:NEW.READSTATUS = 'C'인 경우에만 판독상태로 받음.
                                 , BRFG_STF_NO       = NVL(:NEW.CHIEFDR, NVL(:NEW.CONFDR1, :NEW.READDR1))
                                 , SPCM_PTHL_NO      = WK_IPTN_NO
                                 , TH2_IPDR_STF_NO   = UPPER(:NEW.READDR1)
                                 , TH3_IPDR_STF_NO   = UPPER(:NEW.READDR2)
                                 , TH4_IPDR_STF_NO   = UPPER(:NEW.CONFDR1)
                                 , TH5_IPDR_STF_NO   = UPPER(:NEW.CONFDR2)
                                 , TH6_IPDR_STF_NO   = UPPER(:NEW.CONFDR3)                                                                                                   
                                 , LSH_DTM           = SYSDATE
                                 , LSH_STF_NO        = 'INTERF'
                                 , LSH_IP_ADDR       = '127.0.0.1'
                                 , LSH_PRGM_NM       = 'PACS'
                             WHERE ORD_ID    =  WK_ORD_ID
                               AND HSP_TP_CD = WK_HSP_TP_CD ;

                            IF (SQL%ROWCOUNT = 0) THEN
                                BEGIN   
                                    INSERT 
                                      INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                      SELECT '처방정보 업데이트 에러 1(데이타 존재하지 않음)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                      FROM DUAL;
                            
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            NULL;
                                END;   
                                RETURN;
--                                RAISE_APPLICATION_ERROR('-20001', '판독정보 업데이트중 에러발생 2(데이타 존재하지 않음)');    
                            END IF;   
                                                  
                            EXCEPTION
                                WHEN OTHERS THEN
                                    BEGIN   
                                        INSERT 
                                          INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                          SELECT '처방정보 업데이트 에러 1',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                          FROM DUAL;
                                
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                NULL;
                                    END;   
                                    RETURN;    
--                                    RAISE_APPLICATION_ERROR('-20001', '판독정보 업데이트중 에러발생');
                        END;
              
  
                   
--                        -- 2010.03.08 혈관조영 그룹판독 로직 추가_김성회수정   
--                        IF SUBSTR(WK_ORD_CD, 1, 2) = 'RA' THEN     
--                            XSUP.PC_MSE_MSERMPDF_UPDATE( WK_PT_NO                             -- 01.환자번호
--                                                       , WK_ORD_DT                            -- 02.오더일자
--                                                       , WK_IPTN_NO                           -- 03.판독번호
--                                                       , NVL(:NEW.CHIEFDR,:NEW.TYPISTID)      -- 04.판독의
--                                                       , WK_HSP_TP_CD
--                                                       , 'INTERF'
--                                                       , 'PACS'
--                                                       , '127.0.0.1'  );              
--                          
--                        END IF; 
--                    END IF;
                --최초 판독시
                ELSE
                    BEGIN
                        SELECT TO_CHAR(SYSDATE, 'YYYY') || LPAD(XSUP.SEQ_IPPR_NO.NEXTVAL, 7, '0')
                          INTO WK_IPTN_NO_NEW
                          FROM DUAL;
                              
                        EXCEPTION
                            WHEN  OTHERS  THEN 
                                BEGIN   
                                    INSERT 
                                      INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                      SELECT '판독번호 채번 에러',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                      FROM DUAL;
                            
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            NULL;
                                END;   
                                RETURN;   
--                               RAISE_APPLICATION_ERROR('-20001', '판독번호 채번중 에러발생');
                    END;
                   
                    BEGIN
                        INSERT
                          INTO MSERMDDD ( IPTN_NO
                                        , IPTN_DTM  
                                        , HSP_TP_CD
                                        , PT_NO
                                        , ORD_CD
                                        , ORD_CTG_CD
                                        , EXM_DT
--                                        , TH1_IPDR_STF_NO
                                        , TH2_IPDR_STF_NO
                                        , TH3_IPDR_STF_NO
                                        , TH4_IPDR_STF_NO
                                        , TH5_IPDR_STF_NO
                                        , TH6_IPDR_STF_NO
                                        , CFMT_DTM
                                        , IPTN_MDF_DTM
                                        , TRSR_STF_NO
                                        , TH1_IPTN_EXPL
--                                        , TH2_IPTN_EXPL
                                        , IPTN_CNCS_CNTE     
                                        , REF_CNTE
                                        , IPTN_TP_CD
                                        , IPTN_CTN_TP_CD
                                        , ACCS_ID
                                        , TRSR_IPTN_CMPL_DTM 
                                        , OTSR_BZET_TEL_NO     /*외주업체전화번호*/
                                        , OTSR_BZET_NM         /*외주업체명*/                                        
                                        , FSR_STF_NO
                                        , FSR_DTM
                                        , FSR_PRGM_NM
                                        , FSR_IP_ADDR     
                                        , LSH_STF_NO
                                        , LSH_DTM 
                                        , LSH_PRGM_NM
                                        , LSH_IP_ADDR
                                        )
                                 VALUES ( WK_IPTN_NO_NEW
                                        , TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS') --:NEW.WORKTIME
                                        , WK_HSP_TP_CD
                                        , WK_PT_NO
                                        , WK_ORD_CD
                                        , WK_ORD_CTG_CD
                                        , TRUNC(WK_PHTG_DTM)
--                                        , :NEW.TH1_IPDR_STF_NO
                                        , UPPER(:NEW.READDR1)
                                        , UPPER(:NEW.READDR2)
                                        , UPPER(:NEW.CONFDR1)
                                        , UPPER(:NEW.CONFDR2)
                                        , UPPER(:NEW.CONFDR3)
--                                        , :NEW.TH4_IPDR_STF_NO
--                                        , :NEW.TH5_IPDR_STF_NO
--                                        , :NEW.TH6_IPDR_STF_NO
                                        , DECODE(:NEW.READSTATUS, 'C', TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS'), NULL)
                                        , DECODE(:NEW.READSTATUS, 'C', TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS'), NULL)
                                        , UPPER(:NEW.TYPISTID)
                                        , REPLACE(:NEW.READTEXT,'',' ')   -- 2018.08.21 특수문자 REPLACE
--                                        , :NEW.TH2_RPRT_CNTE
                                        , REPLACE(:NEW.CONCLUSION,'',' ')   -- 2018.08.21 특수문자 REPLACE
                                        , :NEW.RECOMMEND
                                        , '2'
                                        , '1'
                                        , WK_ACCS_ID
                                        , SYSDATE 
                                        , DECODE(WK_ETNL_IPTN_YN,'Y',WK_OTSR_BZET_NM,NULL)  --외주판독이면 외주판독연락처 정보 넣어줌 . 2022.06.10
                                        , DECODE(WK_ETNL_IPTN_YN,'Y',WK_OTSR_BZET_TEL_NO,NULL)                                      
                                        , 'INTERF'
                                        , SYSDATE    
                                        , 'PACS'
                                        , '127.0.0.1'
                                        , 'INTERF'
                                        , SYSDATE
                                        , 'PACS'
                                        , '127.0.0.1'
                                        );
                        EXCEPTION
                            WHEN DUP_VAL_ON_INDEX THEN
                                BEGIN   
                                    INSERT 
                                      INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                     SELECT '판독정보 입력 에러 1(중복데이타 존재)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                      FROM DUAL;
                                     
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            NULL;
                               END;   
                               RETURN;  
                           WHEN OTHERS THEN       
                               BEGIN   
                                   INSERT 
                                     INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                     SELECT '판독정보 입력 에러 1',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                     FROM DUAL;
                            
                                   EXCEPTION
                                       WHEN OTHERS THEN
                                           NULL;
                               END;   
                               RETURN;                              
--                              RAISE_APPLICATION_ERROR('-20001', '판독정보 입력중 에러발생');
                    END; 
                   
                    BEGIN
                       UPDATE MSERMAAD
                          SET EXM_PRGR_STS_CD   = DECODE(WK_ETNL_IPTN_YN,'Y',DECODE(:NEW.READSTATUS, 'C', 'N','D'),'D') -- 외부판독의 경우, 무조건 판독상태로 받음. --> 2019.04.03 외부판독이면서,:NEW.READSTATUS = 'C'인 경우에만 판독상태로 받음.
                            , IPTN_NO           = WK_IPTN_NO_NEW
                            , IMG_NO            = WK_ACCS_ID              
                            , IPDR_STF_NO       = DECODE(:NEW.REFIMGCENTER,'1',UPPER(:NEW.CONFDR1)
                                                                              ,DECODE(:NEW.READSTATUS, 'C', UPPER(:NEW.CONFDR1), IPDR_STF_NO))
                            , FST_IPTN_STF_NO   = NVL(FST_IPTN_STF_NO ,UPPER(NVL2(:NEW.READDR1, :NEW.CONFDR1, :NEW.TYPISTID)))         -- 2013-12-18 김세용  최초 판독일 PACS에서 수정시 UPDATE 방지
                            , FST_IPTN_DT       = NVL(FST_IPTN_DT, TO_DATE(:NEW.CONFDATE,'YYYYMMDD'))            -- 2013-12-18 김세용  최초 판독일 PACS에서 수정시 UPDATE 방지
                            , FST_IPTN_DTM      = NVL(FST_IPTN_DTM, TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS') )                 -- 2013-12-18 김세용  최초 판독일 PACS에서 수정시 UPDATE 방지
                            , LST_IPTN_DTM      = TO_DATE(:NEW.CONFDATE||:NEW.CONFTIME,'YYYYMMDDHH24MISS')                            
--                            , IPDR_STF_NO       = DECODE(:NEW.REFIMGCENTER,'Y',UPPER(:NEW.TYPISTID),IPDR_STF_NO)
--                            , FST_IPTN_STF_NO   = NVL(FST_IPTN_STF_NO ,UPPER(:NEW.TYPISTID))         -- 2013-12-18 김세용  최초 판독일 PACS에서 수정시 UPDATE 방지
--                            , FST_IPTN_DT       = NVL(FST_IPTN_DT, TRUNC(SYSDATE))            -- 2013-12-18 김세용  최초 판독일 PACS에서 수정시 UPDATE 방지
--                            , FST_IPTN_DTM      = NVL(FST_IPTN_DTM, SYSDATE )                 -- 2013-12-18 김세용  최초 판독일 PACS에서 수정시 UPDATE 방지
--                            , LST_IPTN_DTM      = SYSDATE
                            , SHR_YN            = 'Y'  --임상공유여부
                            , INTF_SND_YN       = 'Y'  --인터페이스 전송여부
                            , LSH_DTM           = SYSDATE 
                            , LSH_STF_NO        = 'INTERF'
                            , LSH_IP_ADDR       = '127.0.0.1'
                            , LSH_PRGM_NM       = 'PACS'
                        WHERE ORD_ID    = WK_ORD_ID
                          AND HSP_TP_CD = WK_HSP_TP_CD ;

                       IF (SQL%ROWCOUNT = 0) THEN
                           BEGIN   
                               INSERT 
                                 INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                 SELECT '접수정보 업데이트 에러 2(데이타 존재하지 않음)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                 FROM DUAL;
                       
                               EXCEPTION
                                   WHEN OTHERS THEN
                                       NULL;
                           END;   
                           RETURN;  
                       END IF;
                                                
                       EXCEPTION
                           WHEN OTHERS THEN   
                                BEGIN   
                                    INSERT 
                                      INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                      SELECT '접수정보 업데이트 에러 2',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                      FROM DUAL;
                            
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            NULL;
                                END;   
                                RETURN; 
--                               RAISE_APPLICATION_ERROR('-20001', '판독정보 업데이트중 에러발생');
                    END;   
                                  
                    BEGIN     
                       UPDATE MOOOREXM
                          SET EXM_PRGR_STS_CD   = DECODE(WK_ETNL_IPTN_YN,'Y',DECODE(:NEW.READSTATUS, 'C', 'N','D'),'D') -- 외부판독의 경우, 무조건 판독상태로 받음. --> 2019.04.03 외부판독이면서,:NEW.READSTATUS = 'C'인 경우에만 판독상태로 받음.
                            , BRFG_STF_NO       = NVL(UPPER(:NEW.CHIEFDR), NVL(UPPER(:NEW.CONFDR1), UPPER(:NEW.READDR1)))
                            , SPCM_PTHL_NO      = DECODE(WK_IPTN_NO_NEW, '', WK_IPTN_NO, WK_IPTN_NO_NEW)
                            , TH2_IPDR_STF_NO   = UPPER(:NEW.READDR1)
                            , TH3_IPDR_STF_NO   = UPPER(:NEW.READDR2)
                            , TH4_IPDR_STF_NO   = UPPER(:NEW.CONFDR1)
                            , TH5_IPDR_STF_NO   = UPPER(:NEW.CONFDR2)
                            , TH6_IPDR_STF_NO   = UPPER(:NEW.CONFDR3)
                            , LSH_DTM           = SYSDATE
                            , LSH_STF_NO        = 'INTERF'
                            , LSH_IP_ADDR       = '127.0.0.1'
                            , LSH_PRGM_NM       = 'PACS'
                        WHERE ORD_ID     = WK_ORD_ID 
                          AND HSP_TP_CD  = WK_HSP_TP_CD ;


                       IF (SQL%ROWCOUNT = 0) THEN
                           BEGIN   
                               INSERT 
                                 INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                 SELECT '처방정보 업데이트 에러 2(데이타 존재하지 않음)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                 FROM DUAL;
                       
                               EXCEPTION
                                   WHEN OTHERS THEN
                                       NULL;
                           END;   
                           RETURN;  
                       END IF;
                                            
                       EXCEPTION
                          WHEN OTHERS THEN
                               BEGIN   
                                   INSERT 
                                     INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                                     SELECT '처방정보 업데이트 에러 2',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                                     FROM DUAL;
                           
                                   EXCEPTION
                                       WHEN OTHERS THEN
                                           NULL;
                               END;   
                               RETURN;   
--                              RAISE_APPLICATION_ERROR('-20001', '판독정보 입력중 에러발생');
                    END;

--                    /* PACS 미전송 검사에 대한 일괄 판독처리. */                        
--                    IF SUBSTR(WK_ORD_CD, 1, 2) = 'RA' THEN     
--                        XSUP.PC_MSE_MSERMPDF_UPDATE( WK_PT_NO                            -- 01.환자번호
--                                                   , WK_ORD_DT                           -- 02.오더일자
--                                                   , WK_IPTN_NO_NEW                      -- 03.판독번호
--                                                   , NVL(:NEW.CHIEFDR,:NEW.TYPISTID)     -- 04.판독의 
--                                                   , WK_HSP_TP_CD
--                                                   , 'INTERF'
--                                                   , 'PACS'
--                                                   , '127.0.0.1' );  
--                    END IF; 
                END IF;    

            /* 판독 완료된 검사인데 PACS에서 결과가 넘어온 경우 */
            ELSE
                BEGIN   
                    INSERT 
                      INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                                      SELECT '검사상태값 오류(판독완료된 검사)',:NEW.QUEUEID, 'E', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
                      FROM DUAL;
            
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                END;   
                RETURN; 
            END IF;        
        END IF;
        
        /* 완료 후 완료 FLAG 입력*/
        BEGIN   
            INSERT 
              INTO MSERMINF_ORU_TEMP ( ERR_MSG,QUEUEID,FLAG,WORKTIME,READSTATUS,HISORDERID,PATID,CONCLUSION,READTEXT,ADDENDUM,RECOMMEND,CONFDATE,CONFTIME,CONFDR1,CONFDR2,CONFDR3,CONFDR4,READDR1,READDR2,READDR3,READDR4,TYPISTID,CHIEFDR,EXTEND1,EXTEND2,EXTEND3,EXTEND4,EXTEND5,SUITABLE,ERRCOUNT,REFIMGCENTER,MODALITY,SECTION,EXAMDATE,EXAMTIME,COOPHOSPID)
                              SELECT '완료',:NEW.QUEUEID, 'Y', :NEW.WORKTIME,:NEW.READSTATUS,:NEW.HISORDERID,:NEW.PATID,:NEW.CONCLUSION,:NEW.READTEXT,:NEW.ADDENDUM,:NEW.RECOMMEND,:NEW.CONFDATE,:NEW.CONFTIME,:NEW.CONFDR1,:NEW.CONFDR2,:NEW.CONFDR3,:NEW.CONFDR4,:NEW.READDR1,:NEW.READDR2,:NEW.READDR3,:NEW.READDR4,:NEW.TYPISTID,:NEW.CHIEFDR,:NEW.EXTEND1,:NEW.EXTEND2,:NEW.EXTEND3,:NEW.EXTEND4,:NEW.EXTEND5,:NEW.SUITABLE,:NEW.ERRCOUNT,:NEW.REFIMGCENTER,:NEW.MODALITY,:NEW.SECTION,:NEW.EXAMDATE,:NEW.EXAMTIME,:NEW.COOPHOSPID
              FROM DUAL;
    
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
        END;        
    END IF;
END TR_MSERMINF_ORU ;