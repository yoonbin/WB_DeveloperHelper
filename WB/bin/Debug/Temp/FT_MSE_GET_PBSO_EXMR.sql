FUNCTION      FT_MSE_GET_PBSO_EXMR ( IN_HSP_TP_CD    IN VARCHAR2
                                   , IN_ORD_ID       IN VARCHAR2 
                                   , IN_FLAG         IN VARCHAR2 )        
    RETURN VARCHAR2
    /**********************************************************************
    작 성 자 : wboh
    작 성 일 : 2021-10-05
    내    용 : ORD_ID를 받아 해당 처방의 발행처별 가야할 곳을 FLAG에 따라 RETURN 해줌.
              FLAG 1:  발행처별 가야할 곳 코드 (데이터가 없으면 검사코드 마스터의 기본 가야할 곳을 보여줌 )
              FLAG 2:  발행처별 가야할 곳 대표명  (데이터가 없으면 검사코드 마스터의 기본 가야할 곳을 보여줌 ) -->오늘 가야할 곳  
              FLAG 3:  검사 기본 가야할 곳 코드
              FLAG 4:  검사 기본 가야할 곳 이름
              FLAG 5:  발행처별 가야할 곳 위치정보  --> 오늘 가야할 곳
              FLAG 6:  발행처별 가야할 곳 대표명 (예약일이 오늘보다 미래인 경우에만 조회)          
              FLAG 7:  발행처별 가야할 곳 위치정보 (예약일이 오늘보다 미래인 경우에만 조회)
              FLAG 8:  검사 기본 가야할 곳 장소명              
               
    수정이력 : 
    **********************************************************************/        
IS
    V_EXRM                VARCHAR2(100) :='';                    --가야할 곳
    V_PLC_CD              VARCHAR2(100) := '';                   --가야할곳 코드
    V_PLC_CD_NM              MSERMZMD.PT_GUID_PLC_NM%TYPE;          --가야할곳 대표명
    V_PLC_PSTN_NM          MSERMZMD.GUID_PSTN_NM%TYPE;         --가야할곳 위치상세
    
    V_RSEX_YN              CCOOCBAC.RSEX_YN%TYPE;    --예약검사 여부
    V_ORD_CD              MOOOREXM.ORD_CD%TYPE;
    V_ORD_CTG_CD          MOOOREXM.ORD_CTG_CD%TYPE;
    V_EXRM_TP_CD          MSERMRRD.EXRM_TP_CD%TYPE;
    V_EXM_PRGR_STS_CD      MOOOREXM.EXM_PRGR_STS_CD%TYPE;
    
    G_MTM_IMPL_PSB_YN        MSERMMMC.MTM_IMPL_PSB_YN%TYPE;
    G_RSEX_YN                MSERMMMC.RSEX_YN%TYPE;
    G_INTG_RSV_YN             MSERMMMC.INTG_RSV_YN%TYPE;

BEGIN 
    BEGIN                                                        
        SELECT 'Y'
          INTO V_RSEX_YN
          FROM MOOOREXM
         WHERE HSP_TP_CD = IN_HSP_TP_CD
           AND ORD_ID    = IN_ORD_ID
           AND RSV_DTM    IS NOT NULL;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_RSEX_YN := 'N';
    END;                            
    BEGIN
        SELECT B.RSEX_YN
              ,B.MTM_IMPL_PSB_YN
              ,B.INTG_RSV_YN
              ,A.EXM_PRGR_STS_CD
          INTO G_RSEX_YN
              ,G_MTM_IMPL_PSB_YN
              ,G_INTG_RSV_YN
              ,V_EXM_PRGR_STS_CD
          FROM MOOOREXM A
             , MSERMMMC B
         WHERE A.HSP_TP_CD = IN_HSP_TP_CD
           AND A.HSP_TP_CD = B.HSP_TP_CD
           AND A.ORD_ID = IN_ORD_ID
           AND A.ORD_CD = B.EXM_CD;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            G_RSEX_YN := '';
            G_MTM_IMPL_PSB_YN := '';            
    END;                           
    --비예약검사면서 진료실시행 가능하면 안보여야 했지만 영수증에서 안나온다는 문의가 와서 해당 검사의 기본 가야할곳이 나오게 수정함.2022.01.10
--    IF G_RSEX_YN = 'N' AND G_MTM_IMPL_PSB_YN = 'Y' THEN
--        V_EXRM := '';
--        RETURN V_EXRM;
--    END IF;
    
    /*발행처별 가야할 곳 코드 */
    IF IN_FLAG = '1' OR IN_FLAG = '2' OR IN_FLAG = '5' THEN      --1. 발행처별 가야할곳 조회
        IF G_RSEX_YN = 'Y' AND G_INTG_RSV_YN = 'Y' AND V_EXM_PRGR_STS_CD ='X' THEN    --통합예약  
        DBMS_OUTPUT.PUT_LINE('위치 : '  || '통합예약');
            SELECT '진료협력센터(검사예약)'
                 , DECODE(IN_HSP_TP_CD,'01','1동1층'
                                      ,'02','1,2층'
                                      ,'03','1층')
              INTO V_PLC_CD_NM     
                 , V_PLC_PSTN_NM
              FROM MOOOREXM A
             WHERE HSP_TP_CD = IN_HSP_TP_CD
               AND ORD_ID    = IN_ORD_ID
               AND EXM_PRGR_STS_CD = 'X' 
--               AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(A.RSV_DTM)
--                                                ELSE TRUNC(A.EXM_HOPE_DT)
--                   END = TRUNC(SYSDATE)  
                     ;           
        ELSE
            BEGIN       
                    DBMS_OUTPUT.PUT_LINE('위치 : '  || '코드별 발행처별');
               SELECT (CASE WHEN C.RSEX_YN = 'Y' AND A.EXM_PRGR_STS_CD = 'X' THEN B.PT_GUID_PLC_CD
                             WHEN C.RSEX_YN = 'Y' AND A.EXM_PRGR_STS_CD <> 'X' THEN (SELECT NVL(PT_GUID_PLC_CD,(SELECT PT_GUID_PLC_CD FROM MSERMMMC WHERE HSP_TP_CD = A.HSP_TP_CD AND EXM_CD = A.ORD_CD)) 
                                                                                          FROM MSERMMRD 
                                                                                         WHERE HSP_TP_CD = A.HSP_TP_CD 
                                                                                           AND EXRM_TP_CD = (SELECT EXRM_TP_CD 
                                                                                                               FROM MSERMRRD 
                                                                                                              WHERE HSP_TP_CD = A.HSP_TP_CD 
                                                                                                                AND ORD_ID = A.ORD_ID
                                                                                                              ))
                                                                                    
                             ELSE B.PT_GUID_PLC_CD
                         END ) as PLC_CD                  
                 INTO V_PLC_CD
                 FROM MOOOREXM A
                    , MSERMPLD B
                    , CCOOCBAC C
                WHERE B.HSP_TP_CD = IN_HSP_TP_CD
                  AND A.ORD_ID = IN_ORD_ID
                  AND DECODE(ODAPL_POP_CD,'9' ,A.PT_HME_DEPT_CD, A.PBSO_DEPT_CD) = B.PBSO_DEPT_CD
    --              AND A.PBSO_DEPT_CD = DECODE(B.PBSO_DEPT_CD,'XXX',A.PBSO_DEPT_CD,B.PBSO_DEPT_CD) --발행처가 미지정(XXX)이면 발행처 조건 걸지 않도록 수정
                  AND A.HSP_TP_CD = B.HSP_TP_CD
                  AND A.HSP_TP_CD = C.HSP_TP_CD
                  AND A.PACT_TP_CD = B.PACT_TP_CD
                  AND A.ORD_CD = B.EXM_CD      
                  AND A.ORD_CD = C.ORD_CD
                  AND A.ODDSC_TP_CD = 'C'
                  AND NVL(TO_CHAR(A.RSV_DTM,'D'),TO_CHAR(A.EXM_HOPE_DT,'D')) = B.DOW_KND_CD
                  AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(A.RSV_DTM)
                                                   ELSE TRUNC(A.EXM_HOPE_DT)
                      END = TRUNC(SYSDATE)
                      ;                                              
    --              AND A.RSV_DTM IS NOT NULL                    --예약검사 처방이면 예약일기준, 비예약검사면 처방일 기준으로 발행처별 요일 비교해야 된다는 요청으로 수정
    --              AND TO_CHAR(A.RSV_DTM, 'D') = B.DOW_KND_CD;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN                            --2. 미지정 발행처별 가야할곳 조회
                     BEGIN                                                             
                              DBMS_OUTPUT.PUT_LINE('위치 : '  || '코드별 :' || V_PLC_CD);                     
                        SELECT (CASE WHEN C.RSEX_YN = 'Y' AND A.EXM_PRGR_STS_CD = 'X' THEN B.PT_GUID_PLC_CD
                                     WHEN C.RSEX_YN = 'Y' AND A.EXM_PRGR_STS_CD <> 'X' THEN (SELECT NVL(PT_GUID_PLC_CD,(SELECT PT_GUID_PLC_CD FROM MSERMMMC WHERE HSP_TP_CD = A.HSP_TP_CD AND EXM_CD = A.ORD_CD))
                                                                                                  FROM MSERMMRD 
                                                                                                 WHERE HSP_TP_CD = A.HSP_TP_CD 
                                                                                                   AND EXRM_TP_CD = (SELECT EXRM_TP_CD 
                                                                                                                       FROM MSERMRRD 
                                                                                                                      WHERE HSP_TP_CD = A.HSP_TP_CD 
                                                                                                                        AND ORD_ID = A.ORD_ID
                                                                                                                      )
                                                                                                 )
                                     ELSE B.PT_GUID_PLC_CD
                                 END ) as PLC_CD                  
                         INTO V_PLC_CD
                         FROM MOOOREXM A
                            , MSERMPLD B
                            , CCOOCBAC C
                        WHERE B.HSP_TP_CD = IN_HSP_TP_CD
                          AND A.ORD_ID = IN_ORD_ID                   
                          AND A.HSP_TP_CD = B.HSP_TP_CD
                          AND A.HSP_TP_CD = C.HSP_TP_CD
                          AND A.PACT_TP_CD = B.PACT_TP_CD
                          AND A.ORD_CD = B.EXM_CD      
                          AND A.ORD_CD = C.ORD_CD
                          AND A.ODDSC_TP_CD = 'C'
                          AND B.PBSO_DEPT_CD = 'XXX' --미지정                      
                          AND NVL(TO_CHAR(A.RSV_DTM,'D'),TO_CHAR(A.EXM_HOPE_DT,'D')) = B.DOW_KND_CD 
                          AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(A.RSV_DTM)
                                                           ELSE TRUNC(A.EXM_HOPE_DT)
                              END = TRUNC(SYSDATE)                      
                              ;                                       
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN                           --3. 처방분류의 발행처별 가야할곳     
                                                                 DBMS_OUTPUT.PUT_LINE('위치 : '  || '처방분류별 발행처별');
                            BEGIN
                                SELECT PT_GUID_PLC_CD
                                  INTO V_PLC_CD
                                  FROM MSERMPCD A
                                        ,MOOOREXM B
                                        ,CCOOCBAC C                             
                                 WHERE A.HSP_TP_CD = IN_HSP_TP_CD
                                   AND A.HSP_TP_CD = B.HSP_TP_CD
                                   AND A.HSP_TP_CD = C.HSP_TP_CD
                                   AND A.PBSO_DEPT_CD <> 'XXX' 
                                   AND A.ORD_CTG_CD = B.ORD_CTG_CD
                                   AND A.ORD_CTG_CD = C.ORD_CTG_CD
                                   AND B.ORD_CD = C.ORD_CD
                                   AND B.ORD_ID = IN_ORD_ID
                                   AND DECODE(ODAPL_POP_CD,'9' ,B.PT_HME_DEPT_CD, B.PBSO_DEPT_CD) = A.PBSO_DEPT_CD --퇴원오더는 진료과로 비교해야 한다고 해서 수정 2022.06.29
                                   AND NVL(TO_CHAR(B.RSV_DTM,'D'),TO_CHAR(B.EXM_HOPE_DT,'D')) = A.DOW_KND_CD
                                   AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(B.RSV_DTM)
                                                                   ELSE TRUNC(B.EXM_HOPE_DT)
                                       END = TRUNC(SYSDATE)
                                   AND ROWNUM = 1 ; 
                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN                       --4. 처방분류 발행처 상관없이 가야할곳     
                                                                                                 DBMS_OUTPUT.PUT_LINE('위치 : '  || '처방분류별');
                                    BEGIN
                                        SELECT PT_GUID_PLC_CD
                                          INTO V_PLC_CD
                                          FROM MSERMPCD A
                                                ,MOOOREXM B
                                                ,CCOOCBAC C                             
                                         WHERE A.HSP_TP_CD = IN_HSP_TP_CD
                                           AND A.HSP_TP_CD = B.HSP_TP_CD
                                           AND A.HSP_TP_CD = C.HSP_TP_CD
                                           AND A.PBSO_DEPT_CD = 'XXX' 
                                           AND A.ORD_CTG_CD = B.ORD_CTG_CD
                                           AND A.ORD_CTG_CD = C.ORD_CTG_CD
                                           AND B.ORD_CD = C.ORD_CD
                                           AND B.ORD_ID = IN_ORD_ID
                                           AND NVL(TO_CHAR(B.RSV_DTM,'D'),TO_CHAR(B.EXM_HOPE_DT,'D')) = A.DOW_KND_CD 
                                           AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(B.RSV_DTM)
                                                                           ELSE TRUNC(B.EXM_HOPE_DT)
                                               END = TRUNC(SYSDATE)
                                           AND ROWNUM = 1 ; 
                                     EXCEPTION
                                         WHEN NO_DATA_FOUND THEN                             
                                                    DBMS_OUTPUT.PUT_LINE('위치 : '  || '기본검사마스터의 가야할곳');
                                             BEGIN                          --예약했으면 검사실의 가야할곳 우선 체크하도록 수정
                                                  SELECT (CASE WHEN B.RSEX_YN = 'Y' AND A.EXM_PRGR_STS_CD <> 'X' THEN (SELECT NVL(PT_GUID_PLC_CD,(SELECT PT_GUID_PLC_CD FROM MSERMMMC WHERE HSP_TP_CD = A.HSP_TP_CD AND EXM_CD = A.ORD_CD))
                                                                                                                          FROM MSERMMRD 
                                                                                                                         WHERE HSP_TP_CD = A.HSP_TP_CD 
                                                                                                                           AND EXRM_TP_CD = (SELECT EXRM_TP_CD 
                                                                                                                                               FROM MSERMRRD 
                                                                                                                                              WHERE HSP_TP_CD = A.HSP_TP_CD 
                                                                                                                                                AND ORD_ID = A.ORD_ID
                                                                                                                                              )
                                                                                                                      )
                                                               ELSE B.PT_GUID_PLC_CD
                                                          END) PT_GID_PLC_CD
                                                    INTO V_PLC_CD
                                                    FROM MOOOREXM A
                                                        ,MSERMMMC B
                                                   WHERE A.HSP_TP_CD = IN_HSP_TP_CD
                                                     AND A.HSP_TP_CD = B.HSP_TP_CD
                                                     AND A.ORD_ID  = IN_ORD_ID
                                                     AND A.ODDSC_TP_CD = 'C'
                                                     AND B.EXM_CD  = A.ORD_CD
                                                     AND (B.END_DT IS NULL OR B.END_DTM IS NULL)
                                                     AND B.ORD_SLIP_CTG_CD <> 'MIG'
--                                                   AND CASE WHEN B.RSEX_YN = 'Y' THEN TRUNC(A.EXM_HOPE_DT)             --비예약검사가 예약일이 있을 수 있어서 주석처리
--                                                                                   ELSE TRUNC(SYSDATE)
--                                                       END = TRUNC(SYSDATE)      
                                                     --AND TRUNC(A.EXM_HOPE_DT) = TRUNC(SYSDATE)    --검사희망일이 오늘이면                                                       
                                                   AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(A.RSV_DTM)
                                                                                    ELSE TRUNC(A.EXM_HOPE_DT)
                                                       END = TRUNC(SYSDATE)        
                                                     ;
                                            EXCEPTION
                                                WHEN NO_DATA_FOUND THEN                       
                                                                                                    DBMS_OUTPUT.PUT_LINE('위치 : '  || '기본검체마스터의 가야할곳');
                                                    BEGIN                                                                                    
                                                        SELECT B.TOS_PT_POP_PLC
                                                          INTO V_PLC_CD
                                                          FROM MOOOREXM A
                                                              ,MSELMEBM B
                                                         WHERE A.ORD_ID = IN_ORD_ID
                                                           AND A.HSP_TP_CD = B.HSP_TP_CD
                                                           AND A.HSP_TP_CD = IN_HSP_TP_CD
                                                           AND A.ORD_CD = B.EXM_CD
                                                           AND A.ODDSC_TP_CD = 'C'
                                                           AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(A.RSV_DTM)
                                                                                            ELSE TRUNC(A.EXM_HOPE_DT)
                                                               END = TRUNC(SYSDATE) --예약일이 오늘이 아니라면 NULL                                           
                                                           ;                                                                
                                                    EXCEPTION
                                                        WHEN NO_DATA_FOUND THEN
                                                            V_PLC_CD := '';
                                                    END;                            
                                            END;
                                    END;
    --                        BEGIN          --기본 가야할곳은 안나오게 해달라는 요청으로 주석처리 2021.12.29(신지민)             
    ----                              BEGIN
    ----                                  SELECT ORD_CD
    ----                                    INTO V_ORD_CD
    ----                                    FROM MOOOREXM
    ----                                   WHERE HSP_TP_CD = IN_HSP_TP_CD
    ----                                     AND ORD_ID    = IN_ORD_ID
    ----                                     AND ODDSC_TP_CD = 'C';
    ----                              END;
    --                              BEGIN
    --                                  SELECT B.PT_GUID_PLC_CD
    --                                    INTO V_PLC_CD
    --                                    FROM MOOOREXM A
    --                                          ,MSERMMMC B
    --                                   WHERE A.HSP_TP_CD = IN_HSP_TP_CD
    --                                     AND A.HSP_TP_CD = B.HSP_TP_CD
    --                                     AND A.ORD_ID  = IN_ORD_ID
    --                                     AND A.ODDSC_TP_CD = 'C'
    --                                     AND B.EXM_CD  = A.ORD_CD
    --                                     AND (B.END_DT IS NULL OR B.END_DTM IS NULL)
    --                                     AND B.ORD_SLIP_CTG_CD <> 'MIG'
    ----                                   AND CASE WHEN B.RSEX_YN = 'Y' THEN TRUNC(A.EXM_HOPE_DT)             --비예약검사가 예약일이 있을 수 있어서 주석처리
    ----                                                                   ELSE TRUNC(A.ORD_DT)
    ----                                       END = TRUNC(SYSDATE)
    --                                   AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(A.RSV_DTM)
    --                                                                    ELSE TRUNC(SYSDATE)
    --                                       END = TRUNC(SYSDATE)        
    --                                     ;
    --                            EXCEPTION
    --                                WHEN NO_DATA_FOUND THEN                        --4. 검체검사항목기본의 가야할곳 조회
    --                                    BEGIN                                                                                    
    --                                        SELECT B.TOS_PT_POP_PLC
    --                                          INTO V_PLC_CD
    --                                          FROM MOOOREXM A
    --                                              ,MSELMEBM B
    --                                         WHERE A.ORD_ID = IN_ORD_ID
    --                                           AND A.HSP_TP_CD = B.HSP_TP_CD
    --                                           AND A.HSP_TP_CD = IN_HSP_TP_CD
    --                                           AND A.ORD_CD = B.EXM_CD
    --                                           AND A.ODDSC_TP_CD = 'C'
    --                                           AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(A.RSV_DTM)
    --                                                                            ELSE TRUNC(SYSDATE)
    --                                               END = TRUNC(SYSDATE) --예약일이 오늘이 아니라면 NULL                                           
    --                                           ;                                                                
    --                                    EXCEPTION
    --                                        WHEN NO_DATA_FOUND THEN
    --                                            V_PLC_CD := '';
    --                                    END;                                     
    --                              END;
                              END;                              
                     END;
             END;
         END IF;
    /*검사코드의 기본 가야할 곳 코드*/ 
     ELSIF IN_FLAG = '3' OR IN_FLAG = '4' OR IN_FLAG = '8' THEN           
        BEGIN                       
            BEGIN
              SELECT ORD_CD
                      ,ORD_CTG_CD
                INTO V_ORD_CD   
                    ,V_ORD_CTG_CD
                FROM MOOOREXM
               WHERE HSP_TP_CD = IN_HSP_TP_CD
                 AND ORD_ID    = IN_ORD_ID
                 AND ODDSC_TP_CD = 'C';
            END;         
            BEGIN
                SELECT EXRM_TP_CD
                  INTO V_EXRM_TP_CD
                  FROM MSERMRRD
                 WHERE HSP_TP_CD = IN_HSP_TP_CD
                   AND ORD_ID    = IN_ORD_ID;
            END;                            
            IF V_EXRM_TP_CD IS NOT NULL THEN             --예약된 검사실이 있을경우.
                BEGIN                                     --해당 검사실의 가야할 곳 출력
                    SELECT PT_GUID_PLC_CD
                      INTO V_PLC_CD
                      FROM MSERMMRD
                     WHERE HSP_TP_CD = IN_HSP_TP_CD
                       AND EXRM_TP_CD = V_EXRM_TP_CD;                
                END;     
            END IF;
            IF V_PLC_CD IS NULL THEN                    
                BEGIN
                  SELECT PT_GUID_PLC_CD
                    INTO V_PLC_CD
                    FROM MSERMMMC
                   WHERE HSP_TP_CD = IN_HSP_TP_CD
                     AND EXM_CD  = V_ORD_CD
                     AND END_DT IS NULL
                     AND END_DTM IS NULL;
                END;                     
            END IF;
        END; 
     ELSIF IN_FLAG = '6' OR IN_FLAG = '7' THEN      
     --다음 가야할 곳에는 진협이 안나와야 한다고 해서 주석처리 2022-03-02 신지민 요청 
--        IF G_RSEX_YN = 'Y' AND G_INTG_RSV_YN = 'Y' AND V_EXM_PRGR_STS_CD ='X' THEN    --통합예약
--            SELECT '진료협력센터(검사예약)'
--                 , '1동1층'
--              INTO V_PLC_CD_NM     
--                 , V_PLC_PSTN_NM
--              FROM MOOOREXM A
--             WHERE HSP_TP_CD = IN_HSP_TP_CD
--               AND ORD_ID    = IN_ORD_ID 
--               AND EXM_PRGR_STS_CD = 'X'               
----               AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(A.RSV_DTM)
----                                                ELSE TRUNC(A.EXM_HOPE_DT)
----                   END > TRUNC(SYSDATE)    
--                   ;
--        ELSE     
            BEGIN   
               SELECT (CASE WHEN C.RSEX_YN = 'Y' AND A.EXM_PRGR_STS_CD = 'X' THEN B.PT_GUID_PLC_CD
                             WHEN C.RSEX_YN = 'Y' AND A.EXM_PRGR_STS_CD <> 'X' THEN (SELECT NVL(PT_GUID_PLC_CD,(SELECT PT_GUID_PLC_CD FROM MSERMMMC WHERE HSP_TP_CD = A.HSP_TP_CD AND EXM_CD = A.ORD_CD))
                                                                                          FROM MSERMMRD 
                                                                                         WHERE HSP_TP_CD = A.HSP_TP_CD 
                                                                                           AND EXRM_TP_CD = (SELECT EXRM_TP_CD 
                                                                                                               FROM MSERMRRD 
                                                                                                              WHERE HSP_TP_CD = A.HSP_TP_CD 
                                                                                                                AND ORD_ID = A.ORD_ID
                                                                                                              )
                                                                                         )
                             ELSE B.PT_GUID_PLC_CD
                         END ) as PLC_CD                  
                 INTO V_PLC_CD
                 FROM MOOOREXM A
                    , MSERMPLD B
                    , CCOOCBAC C
                WHERE B.HSP_TP_CD = IN_HSP_TP_CD
                  AND A.ORD_ID = IN_ORD_ID
                  AND DECODE(ODAPL_POP_CD,'9' ,A.PT_HME_DEPT_CD, A.PBSO_DEPT_CD) = B.PBSO_DEPT_CD --퇴원오더는 진료과로 비교해야 한다고 해서 수정 2022.06.29
    --              AND A.PBSO_DEPT_CD = DECODE(B.PBSO_DEPT_CD,'XXX',A.PBSO_DEPT_CD,B.PBSO_DEPT_CD) --발행처가 미지정(XXX)이면 발행처 조건 걸지 않도록 수정
                  AND A.HSP_TP_CD = B.HSP_TP_CD
                  AND A.HSP_TP_CD = C.HSP_TP_CD
                  AND A.PACT_TP_CD = B.PACT_TP_CD
                  AND A.ORD_CD = B.EXM_CD      
                  AND A.ORD_CD = C.ORD_CD
                  AND A.ODDSC_TP_CD = 'C'
                  AND NVL(TO_CHAR(A.RSV_DTM,'D'),TO_CHAR(A.EXM_HOPE_DT,'D')) = B.DOW_KND_CD
                  AND CASE WHEN V_RSEX_YN = 'Y' AND G_RSEX_YN = 'N' THEN TRUNC(A.RSV_DTM)
                           WHEN V_RSEX_YN = 'N' AND G_RSEX_YN = 'N' THEN TRUNC(A.EXM_HOPE_DT)
                           ELSE TRUNC(A.RSV_DTM)
                      END > TRUNC(SYSDATE)
                      ;                                              
    --              AND A.RSV_DTM IS NOT NULL                    --예약검사 처방이면 예약일기준, 비예약검사면 처방일 기준으로 발행처별 요일 비교해야 된다는 요청으로 수정
    --              AND TO_CHAR(A.RSV_DTM, 'D') = B.DOW_KND_CD;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN                            --2. 미지정 발행처별 가야할곳 조회
                     BEGIN
                        SELECT (CASE WHEN C.RSEX_YN = 'Y' AND A.EXM_PRGR_STS_CD = 'X' THEN B.PT_GUID_PLC_CD
                                     WHEN C.RSEX_YN = 'Y' AND A.EXM_PRGR_STS_CD <> 'X' THEN (SELECT NVL(PT_GUID_PLC_CD,(SELECT PT_GUID_PLC_CD FROM MSERMMMC WHERE HSP_TP_CD = A.HSP_TP_CD AND EXM_CD = A.ORD_CD)) 
                                                                                                  FROM MSERMMRD 
                                                                                                 WHERE HSP_TP_CD = A.HSP_TP_CD 
                                                                                                   AND EXRM_TP_CD = (SELECT EXRM_TP_CD 
                                                                                                                       FROM MSERMRRD 
                                                                                                                      WHERE HSP_TP_CD = A.HSP_TP_CD 
                                                                                                                        AND ORD_ID = A.ORD_ID
                                                                                                                      )
                                                                                                 )
                                     ELSE B.PT_GUID_PLC_CD
                                 END ) as PLC_CD                  
                         INTO V_PLC_CD
                         FROM MOOOREXM A
                            , MSERMPLD B
                            , CCOOCBAC C
                        WHERE B.HSP_TP_CD = IN_HSP_TP_CD
                          AND A.ORD_ID = IN_ORD_ID                   
                          AND A.HSP_TP_CD = B.HSP_TP_CD
                          AND A.HSP_TP_CD = C.HSP_TP_CD
                          AND A.PACT_TP_CD = B.PACT_TP_CD
                          AND A.ORD_CD = B.EXM_CD      
                          AND A.ORD_CD = C.ORD_CD
                          AND A.ODDSC_TP_CD = 'C'
                          AND B.PBSO_DEPT_CD = 'XXX' --미지정                      
                          AND NVL(TO_CHAR(A.RSV_DTM,'D'),TO_CHAR(A.EXM_HOPE_DT,'D')) = B.DOW_KND_CD 
                          AND CASE WHEN V_RSEX_YN = 'Y' AND G_RSEX_YN = 'N' THEN TRUNC(A.RSV_DTM)
                                   WHEN V_RSEX_YN = 'N' AND G_RSEX_YN = 'N' THEN TRUNC(A.EXM_HOPE_DT)
                                   ELSE TRUNC(A.RSV_DTM)
                              END > TRUNC(SYSDATE)                      
                              ;                                       
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN                           --3. 처방분류의 발행처별 가야할곳           
                            BEGIN
                                SELECT PT_GUID_PLC_CD
                                  INTO V_PLC_CD
                                  FROM  MOOOREXM A
                                        ,MSERMPCD B
                                        ,CCOOCBAC C                             
                                 WHERE A.HSP_TP_CD = IN_HSP_TP_CD
                                   AND A.HSP_TP_CD = B.HSP_TP_CD
                                   AND A.HSP_TP_CD = C.HSP_TP_CD
                                   AND B.PBSO_DEPT_CD <> 'XXX' 
                                   AND A.ORD_CTG_CD = B.ORD_CTG_CD
                                   AND A.ORD_CTG_CD = C.ORD_CTG_CD
                                   AND A.ORD_CD = C.ORD_CD
                                   AND A.ORD_ID = IN_ORD_ID
                                   AND DECODE(ODAPL_POP_CD,'9' ,A.PT_HME_DEPT_CD, A.PBSO_DEPT_CD) = B.PBSO_DEPT_CD --퇴원오더는 진료과로 비교해야 한다고 해서 수정 2022.06.29
                                   AND NVL(TO_CHAR(A.RSV_DTM,'D'),TO_CHAR(A.EXM_HOPE_DT,'D')) = B.DOW_KND_CD 
                                   AND CASE WHEN V_RSEX_YN = 'Y' AND G_RSEX_YN = 'N' THEN TRUNC(A.RSV_DTM)
                                            WHEN V_RSEX_YN = 'N' AND G_RSEX_YN = 'N' THEN TRUNC(A.EXM_HOPE_DT)
                                            ELSE TRUNC(A.RSV_DTM)
                                       END > TRUNC(SYSDATE)
                                   AND ROWNUM =1 ;
                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN                       --4. 처방분류 발행처 상관없이 가야할곳 
                                    BEGIN
                                        SELECT PT_GUID_PLC_CD
                                          INTO V_PLC_CD
                                          FROM MOOOREXM A
                                              ,MSERMPCD B
                                              ,CCOOCBAC C                             
                                         WHERE A.HSP_TP_CD = IN_HSP_TP_CD
                                           AND A.HSP_TP_CD = B.HSP_TP_CD
                                           AND A.HSP_TP_CD = C.HSP_TP_CD
                                           AND B.PBSO_DEPT_CD = 'XXX' 
                                           AND A.ORD_CTG_CD = B.ORD_CTG_CD
                                           AND A.ORD_CTG_CD = C.ORD_CTG_CD
                                           AND A.ORD_CD = C.ORD_CD
                                           AND A.ORD_ID = IN_ORD_ID
                                           AND TO_CHAR(A.EXM_HOPE_DT,'D') = B.DOW_KND_CD 
                                           AND CASE WHEN V_RSEX_YN = 'Y' AND G_RSEX_YN = 'N' THEN TRUNC(A.RSV_DTM)
                                                    WHEN V_RSEX_YN = 'N' AND G_RSEX_YN = 'N' THEN TRUNC(A.EXM_HOPE_DT)
                                                    ELSE TRUNC(A.RSV_DTM)
                                               END > TRUNC(SYSDATE)
                                           AND ROWNUM =1  ; 
                                     EXCEPTION
                                         WHEN NO_DATA_FOUND THEN
                                             BEGIN
                                                  SELECT B.PT_GUID_PLC_CD
                                                    INTO V_PLC_CD
                                                    FROM MOOOREXM A
                                                        ,MSERMMMC B
                                                   WHERE A.HSP_TP_CD = IN_HSP_TP_CD
                                                     AND A.HSP_TP_CD = B.HSP_TP_CD
                                                     AND A.ORD_ID  = IN_ORD_ID
                                                     AND A.ODDSC_TP_CD = 'C'
                                                     AND B.EXM_CD  = A.ORD_CD
                                                     AND (B.END_DT IS NULL OR B.END_DTM IS NULL)
                                                     AND B.ORD_SLIP_CTG_CD <> 'MIG'
--                                                   AND CASE WHEN B.RSEX_YN = 'Y' THEN TRUNC(A.EXM_HOPE_DT)             --비예약검사가 예약일이 있을 수 있어서 주석처리
--                                                                                   ELSE TRUNC(SYSDATE)
--                                                       END = TRUNC(SYSDATE)
--                                                     AND TRUNC(A.EXM_HOPE_DT) = TRUNC(SYSDATE)    --검사희망일이 오늘이후면
                                                      AND CASE WHEN V_RSEX_YN = 'Y' AND G_RSEX_YN = 'N' THEN TRUNC(A.RSV_DTM)
                                                               WHEN V_RSEX_YN = 'N' AND G_RSEX_YN = 'N' THEN TRUNC(A.EXM_HOPE_DT)
                                                               ELSE TRUNC(A.RSV_DTM)
                                                          END > TRUNC(SYSDATE)       
                                                     ;
                                            EXCEPTION
                                                WHEN NO_DATA_FOUND THEN
                                                    BEGIN
                                                        SELECT B.TOS_PT_POP_PLC
                                                          INTO V_PLC_CD
                                                          FROM MOOOREXM A
                                                              ,MSELMEBM B
                                                         WHERE A.ORD_ID = IN_ORD_ID
                                                           AND A.HSP_TP_CD = B.HSP_TP_CD
                                                           AND A.HSP_TP_CD = IN_HSP_TP_CD
                                                           AND A.ORD_CD = B.EXM_CD
                                                           AND A.ODDSC_TP_CD = 'C'
                                                           AND CASE WHEN V_RSEX_YN = 'Y' AND G_RSEX_YN = 'N' THEN TRUNC(A.RSV_DTM)
                                                                    WHEN V_RSEX_YN = 'N' AND G_RSEX_YN = 'N' THEN TRUNC(A.EXM_HOPE_DT)
                                                                    ELSE TRUNC(A.RSV_DTM)
                                                               END > TRUNC(SYSDATE) --예약일이 오늘 이후일 때만 조회                                    
                                                           ;                                                                
                                                    EXCEPTION
                                                        WHEN NO_DATA_FOUND THEN
                                                            V_PLC_CD := '';
                                                    END;                                                                 
                                            END;                            
                                     END;
                             END;         
                                                            
    --                        BEGIN                       --기본 가야할곳은 안나오게 해달라는 요청으로 수정 2021.12.29 (신지민)
    ----                              BEGIN
    ----                                  SELECT ORD_CD
    ----                                    INTO V_ORD_CD
    ----                                    FROM MOOOREXM
    ----                                   WHERE HSP_TP_CD = IN_HSP_TP_CD
    ----                                     AND ORD_ID    = IN_ORD_ID
    ----                                     AND ODDSC_TP_CD = 'C';
    ----                              END;
    --                              BEGIN
    --                                  SELECT B.PT_GUID_PLC_CD
    --                                    INTO V_PLC_CD
    --                                    FROM MOOOREXM A
    --                                          ,MSERMMMC B
    --                                   WHERE A.HSP_TP_CD = IN_HSP_TP_CD
    --                                     AND A.HSP_TP_CD = B.HSP_TP_CD
    --                                     AND A.ORD_ID  = IN_ORD_ID
    --                                     AND A.ODDSC_TP_CD = 'C'
    --                                     AND B.EXM_CD  = A.ORD_CD
    --                                     AND (B.END_DT IS NULL OR B.END_DTM IS NULL)
    --                                     AND B.ORD_SLIP_CTG_CD <> 'MIG'
    ----                                   AND CASE WHEN B.RSEX_YN = 'Y' THEN TRUNC(A.EXM_HOPE_DT)    --비예약검사가 예약일이 있을 수 있어서 주석처리
    ----                                                                   ELSE TRUNC(A.ORD_DT)
    ----                                       END = TRUNC(SYSDATE)
    --                                   AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(A.RSV_DTM)
    --                                                                    ELSE TRUNC(SYSDATE)
    --                                       END > TRUNC(SYSDATE)                                       
    --                                     ;
    --                            EXCEPTION
    --                                WHEN NO_DATA_FOUND THEN                        --4. 검체검사항목기본의 가야할곳 조회
--                                    BEGIN
--                                        SELECT B.TOS_PT_POP_PLC
--                                          INTO V_PLC_CD
--                                          FROM MOOOREXM A
--                                              ,MSELMEBM B
--                                         WHERE A.ORD_ID = IN_ORD_ID
--                                           AND A.HSP_TP_CD = B.HSP_TP_CD
--                                           AND A.HSP_TP_CD = IN_HSP_TP_CD
--                                           AND A.ORD_CD = B.EXM_CD
--                                           AND A.ODDSC_TP_CD = 'C'
--                                           AND CASE WHEN V_RSEX_YN = 'Y' THEN TRUNC(A.RSV_DTM)
--                                                                            ELSE TRUNC(SYSDATE)
--                                               END > TRUNC(SYSDATE) --예약일이 오늘 이후일 때만 조회                                    
--                                           ;                                                                
--                                    EXCEPTION
--                                        WHEN NO_DATA_FOUND THEN
--                                            V_PLC_CD := '';
--                                    END;                                     
    --                              END;
    --                          END;                              
                     END;
             END;
--         END IF;         
     END IF;                    
     
     IF V_PLC_CD_NM IS NULL THEN
        /*가야할 검사실 명 조회*/     
         BEGIN
             SELECT PT_GUID_PLC_NM
                   ,REPLACE(GUID_PSTN_NM,' ','')
               INTO V_PLC_CD_NM
                    , V_PLC_PSTN_NM
               FROM MSERMZMD        --환자안내장소정보
              WHERE HSP_TP_CD = IN_HSP_TP_CD
                AND PT_GUID_PLC_CD = V_PLC_CD
                AND USE_YN = 'Y'
                ;         
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 V_PLC_CD_NM := ''; --해당 가야할 곳의 데이터가 없음             
         END;                    
     END IF; 
         
     BEGIN
         IF IN_FLAG = '1' OR IN_FLAG = '3' THEN
             V_EXRM := V_PLC_CD;
         ELSIF IN_FLAG = '2' OR IN_FLAG = '4' OR IN_FLAG = '6' THEN
             V_EXRM := V_PLC_CD_NM;    
        ELSIF IN_FLAG = '5' OR IN_FLAG = '7' OR IN_FLAG = '8' THEN       
            V_EXRM := V_PLC_PSTN_NM;   
        END IF;       
     END;
   RETURN V_EXRM;
   
END;