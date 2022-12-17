PACKAGE BODY      PKG_MSE_LM_INTERFACE
IS

    /**********************************************************************************************
    SELECT 조회            SEL
    UPDATE 수정          UPT
    SAVE   입력 수정     SAV
    DELETE 삭제          DEL
    **********************************************************************************************/       

    /**********************************************************************************************
    *    서비스이름      : PC_MSE_ORDER_SELECT
    *    최초 작성일     : 2017.08.08
    *    최초 작성자     : 전산과 김현식 
    *    DESCRIPTION   : 오더조회  인터페이스 
    *                  : 2021.12.01 홍승표 - 접수된 검체번호의 검사 리스트 조회
    *
    *                    VAR OUT_CURSOR REFCURSOR;
    *                    EXEC XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_ORDER_SELECT (  '001'
    *                                                                        , '211201022742'   -- 211202022832
    *                                                                        , '01'
    *                                                                        , :OUT_CURSOR
    *                                                                        );
    *
    *                                       
    
    **   (IN_EQUIPTYPE : 001)  :
    **   (IN_EQUIPTYPE : 002)  :
    **   (IN_EQUIPTYPE : 003)  :
    **   (IN_EQUIPTYPE : 004)  :
    **   (IN_EQUIPTYPE : 005)  :
    **   (IN_EQUIPTYPE : 006)  :
    **   (IN_EQUIPTYPE : 007)  :
    **   (IN_EQUIPTYPE : 008)  :
    **   (IN_EQUIPTYPE : 009)  :
    **   (IN_EQUIPTYPE : 010)  :
    **   (IN_EQUIPTYPE : 011)  :
    **********************************************************************************************/ 
    PROCEDURE PC_MSE_ORDER_SELECT (  IN_EQUIPTYPE   IN   VARCHAR2           -- 장비코드     : 001  002  003  004 
                                   , IN_SPCM_NO     IN   VARCHAR2           -- 검체번호
                                   , IN_HSP_TP_CD   IN   VARCHAR2           -- 병원코드     :
                                   , OUT_CURSOR     OUT  RETURNCURSOR )
    IS
        --변수선언
        WK_CURSOR                 RETURNCURSOR ; 

        V_LTS_CODE_YN             VARCHAR2(20);
        V_EXRM_EXM_CTG_CD         VARCHAR2(20);
        V_EXM_CD                  VARCHAR2(20);
    
        BEGIN       
                                      
            -- 현장검사-혈당검사(POCT-Blood gulucose test)        
            -- 혈당검사일 경우에는 최종검증이 완료된 이후에도 다시 전송하거나 사용자가 결과수정하여 저장하여도, 결과 저장되도록 변경함. 아래 3가지 로직 참고
            -- 1. 장비 인터페이스 전송 : PKG_MSE_LM_INTERFACE.SAVE
            -- 2. 간호 Patient 리스트 - 혈당검사 : PKG_MSE_LM_EXAMRSLT
            -- 3. 환자별 검사시행관리 - 혈당검사 결과등록 : PKG_MSE_LM_EXAMRSLT        
            
            -- 혈당검사는 단독검체로 설정해놓았으며, 해당 검체번호에는 혈당검사코드만 존재함. 
            BEGIN
                SELECT A.EXRM_EXM_CTG_CD
                     , A.EXM_CD
                  INTO V_EXRM_EXM_CTG_CD
                     , V_EXM_CD
                  FROM MSELMAID A
                 WHERE A.HSP_TP_CD = IN_HSP_TP_CD
                   AND A.SPCM_NO   = IN_SPCM_NO
                   AND ROWNUM      = 1
                   ;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN  
                        GOTO NEXT_CHECK;
                    WHEN OTHERS THEN         
                        GOTO NEXT_CHECK;
            END; 
            
            IF V_EXRM_EXM_CTG_CD = 'LT' AND V_EXM_CD = 'LTS001' THEN
                V_LTS_CODE_YN := 'Y';
            ELSE                        
                V_LTS_CODE_YN := 'N';
            END IF;
                 
            << NEXT_CHECK >>
            
                             
            BEGIN
                --BODY
                OPEN WK_CURSOR FOR
                                                      
                        SELECT TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD HH24:MI:SS') ACPT_DTM
                             , A.EXM_ACPT_NO
                             , A.PT_NO
                             , B.PT_NM
                             , B.SEX_TP_CD
                             , TO_CHAR(B.PT_BRDY_DT, 'YYYY-MM-DD') PT_BRDY_DT
                             , (SELECT PT_HME_DEPT_CD FROM MOOOREXM WHERE HSP_TP_CD = A.HSP_TP_CD AND SPCM_PTHL_NO = A.SPCM_NO AND ORD_ID = A.ORD_ID) PT_HME_DEPT_CD
                             , (SELECT WD_DEPT_CD     FROM MOOOREXM WHERE HSP_TP_CD = A.HSP_TP_CD AND SPCM_PTHL_NO = A.SPCM_NO AND ORD_ID = A.ORD_ID) WD_DEPT_CD
                             , A.EXM_CD
                             , A.TH1_SPCM_CD
                             , D.HR24_URN_EXM_TM
                             , D.HR24_URN_EXM_VLM_CNTE
                             , (SELECT ORD_CD FROM MOOOREXM WHERE HSP_TP_CD = A.HSP_TP_CD AND SPCM_PTHL_NO = A.SPCM_NO AND ORD_ID = A.ORD_ID) ORD_CD
--                             , DECODE(A.SPEX_PRGR_STS_CD, '1', 'C', D.EXM_PRGR_STS_CD)  EXM_PRGR_STS_CD
                             , DECODE(A.SMP_EXRS_CNTE, NULL, 'C', 'D')                  EXM_PRGR_STS_CD
                             , D.LBL_PRNT_EQUP_CD  WORK_NO
                             , A.EXRM_EXM_CTG_CD
                             , A.SMP_EXRS_CNTE                                          EXRS_CNTE
                             , A.RCN_SMP_EXRS_CNTE                                      RCN_EXRS_CNTE
                             , TO_CHAR(A.RCN_EXM_DTM, 'YYYY-MM-DD HH24:MI:SS')          RCN_EXM_DTM
                             , A.SPEX_PRGR_STS_CD                                       SPEX_PRGR_STS_CD
                             , A.EXRS_VRFC_STS_CD                                       EXRS_VRFC_STS_CD 
                          FROM MSELMAID A
                             , PCTPCPAM_DAMO B
                             , MSELMCED D
                        WHERE 1=1
                          AND A.HSP_TP_CD  = IN_HSP_TP_CD
                          AND A.SPCM_NO    = IN_SPCM_NO
                          AND A.PT_NO      = B.PT_NO
                          AND A.HSP_TP_CD  = D.HSP_TP_CD
                          AND A.SPCM_NO    = D.SPCM_NO
                          AND A.SPEX_PRGR_STS_CD IN ( '-', DECODE(V_LTS_CODE_YN, 'Y', '3', '-'), DECODE(IN_EQUIPTYPE, '검체보관', '3', '-') , DECODE(IN_EQUIPTYPE, '전체조회', '3', '-') ) -- 검체보관용 조회시에는 모든 결과 조회허용
--                          AND D.EXM_PRGR_STS_CD IN ('B', 'C', 'D', DECODE(V_LTS_CODE_YN, 'Y', 'N', 'D')) --검사진행상태코드(혈당검사일 경우에는 검증완료된 처방도 재전송 허용)
                          ;
                        
    
                                       
    --                SELECT
    --                       DISTINCT D.SPCM_NO,
    --                       TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD HH24:MI:SS') ACPT_DTM ,
    --                       A.EXM_ACPT_NO ,
    --                       C.PT_NO ,
    --                       C.PT_NM ,
    --                       C.SEX_TP_CD ,
    --                       TO_CHAR(C.PT_BRDY_DT, 'YYYY-MM-DD') PT_BRDY_DT ,
    --                       B.PT_HME_DEPT_CD ,
    --                       B.WD_DEPT_CD ,
    --                       A.EXM_CD ,
    --                       A.TH1_SPCM_CD ,
    --                       D.HR24_URN_EXM_TM ,
    --                       D.HR24_URN_EXM_VLM_CNTE ,
    --                       E.RPRN_EXM_CD ,
    --                       --D.EXM_PRGR_STS_CD
    --                       DECODE(A.SPEX_PRGR_STS_CD, '1', 'C', D.EXM_PRGR_STS_CD)  EXM_PRGR_STS_CD,
    --                       D.LBL_PRNT_EQUP_CD  WORK_NO,
    --                       D.EXRM_EXM_CTG_CD
    --                FROM   MSELMCED D ,
    --                       MSELMAID A ,
    --                       MOOOREXM B ,
    --                       PCTPCPAM_DAMO C,
    --                       (
    --                                    SELECT A.PT_NO
    --                                         , A.ORD_DT
    --                                         , A.SPCM_NO
    --                                         , A.EXM_CD
    --                                         , A.HSP_TP_CD
    --                                         , NVL(BB.RPRN_EXM_CD, A.EXM_CD) RPRN_EXM_CD
    --                                         , ROW_NUMBER()  OVER (PARTITION BY A.PT_NO
    --                                                                          , A.ORD_DT
    --                                                                          , A.SPCM_NO
    --                                                                          , A.EXM_CD
    --                                                                          , A.HSP_TP_CD
    --                                                                   ORDER BY NVL(BB.RPRN_EXM_CD, A.EXM_CD)) ROW_NUM
    --                                      FROM (
    --                                            SELECT DISTINCT
    --                                                   C.PT_NO
    --                                                 , D.ORD_DT
    --                                                 , D.SPCM_NO
    --                                                 , NVL(A.EXM_CD, B.ORD_CD) EXM_CD
    --                                                 , D.HSP_TP_CD
    --                                              FROM MSELMAID A ,
    --                                                   MOOOREXM B ,
    --                                                   PCTPCPAM_DAMO C ,
    --                                                   MSELMCED D
    --                                            WHERE D.SPCM_NO        = B.SPCM_PTHL_NO
    --                                              AND D.HSP_TP_CD      = B.HSP_TP_CD
    --                                              AND D.SPCM_NO        = IN_SPCM_NO
    --                                              AND D.HSP_TP_CD      = IN_HSP_TP_CD
    --                                              AND B.PT_NO          = C.PT_NO
    --                                              AND A.SPCM_NO(+)   = D.SPCM_NO
    --                                              AND A.HSP_TP_CD(+) = D.HSP_TP_CD
    ----                                              AND D.EXM_PRGR_STS_CD IN ('B', 'C', 'D')                                              --검사진행상태코드           'D' ACK 혈액배양으로 추가요청
    --                                           )        A
    --                                         , MOOOREXM AA
    --                                         , MSELMEBV BB
    --                                     WHERE AA.ORD_DT       = A.ORD_DT
    --                                       AND AA.PT_NO        = A.PT_NO
    --                                       AND AA.SPCM_PTHL_NO = A.SPCM_NO
    --                                       AND AA.HSP_TP_CD    = A.HSP_TP_CD
    ----                                      AND BB.EXM_CD       = A.EXM_CD        -- '2020-03-24' 05-26
    --                                      AND AA.ORD_CD       = BB.RPRN_EXM_CD
    --                                      AND AA.HSP_TP_CD    = BB.HSP_TP_CD
    --                      ) E
    --                WHERE 1=1
    --                  AND D.SPCM_NO         = B.SPCM_PTHL_NO
    --                  AND D.HSP_TP_CD         = B.HSP_TP_CD
    --                  AND D.SPCM_NO         = IN_SPCM_NO
    --                  AND D.HSP_TP_CD         = IN_HSP_TP_CD
    --                  AND B.PT_NO             = C.PT_NO
    --                  AND A.SPCM_NO(+)         = D.SPCM_NO
    --                  AND A.HSP_TP_CD(+)    = D.HSP_TP_CD
    --                  AND C.PT_NO             = E.PT_NO
    --                  AND D.ORD_DT             = E.ORD_DT
    --                  AND D.SPCM_NO         = E.SPCM_NO
    --                  AND A.EXM_CD(+)         = E.EXM_CD
    --                  AND D.HSP_TP_CD         = E.HSP_TP_CD
    --                  AND E.ROW_NUM = 1
    --                ORDER BY A.EXM_CD
    --                ;
    
                                       
                                       
                    -- 2017.12.12 튜닝반영
    --                SELECT DISTINCT A.SPCM_NO ,
    --                       TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD HH24:MI:SS') ACPT_DTM ,
    --                       A.EXM_ACPT_NO ,
    --                       C.PT_NO ,
    --                       C.PT_NM ,
    --                       C.SEX_TP_CD ,
    --                       TO_CHAR(C.PT_BRDY_DT, 'YYYY-MM-DD') PT_BRDY_DT ,
    --                       B.PT_HME_DEPT_CD ,
    --                       B.WD_DEPT_CD ,
    --                       A.EXM_CD ,
    --                       A.TH1_SPCM_CD ,
    --                       D.HR24_URN_EXM_TM ,
    --                       D.HR24_URN_EXM_VLM_CNTE ,
    --                       E.RPRN_EXM_CD ,
    --                       --D.EXM_PRGR_STS_CD
    --                       DECODE(A.SPEX_PRGR_STS_CD, '1', 'C', D.EXM_PRGR_STS_CD)  EXM_PRGR_STS_CD
    --                FROM   MSELMAID A ,
    --                       MOOOREXM B ,
    --                       PCTPCPAM_DAMO C ,
    --                       MSELMCED D ,
    --                       (
    --                               SELECT A.PT_NO
    --                                 , A.ORD_DT
    --                                 , A.SPCM_NO
    --                                 , A.EXM_CD
    --                                 , A.HSP_TP_CD
    --                                 , NVL(BB.RPRN_EXM_CD, A.EXM_CD) RPRN_EXM_CD
    --                                 , ROW_NUMBER()  OVER (PARTITION BY A.PT_NO
    --                                                                  , A.ORD_DT
    --                                                                  , A.SPCM_NO
    --                                                                  , A.EXM_CD
    --                                                                  , A.HSP_TP_CD
    --                                                           ORDER BY NVL(BB.RPRN_EXM_CD, A.EXM_CD)) ROW_NUM
    --                              FROM (
    --                                    SELECT DISTINCT
    --                                           C.PT_NO
    --                                         , D.ORD_DT
    --                                         , A.SPCM_NO
    --                                         , A.EXM_CD
    --                                         , A.HSP_TP_CD
    --                                      FROM MSELMAID A ,
    --                                           MOOOREXM B ,
    --                                           PCTPCPAM_DAMO C ,
    --                                           MSELMCED D
    --                                    WHERE A.SPCM_NO  = B.SPCM_PTHL_NO
    --                                      AND A.HSP_TP_CD = B.HSP_TP_CD
    --                                      AND A.SPCM_NO   = IN_SPCM_NO
    --                                      AND A.HSP_TP_CD = IN_HSP_TP_CD
    --                                      AND B.PT_NO     = C.PT_NO
    --                                      AND A.SPCM_NO   = D.SPCM_NO
    --                                      AND A.HSP_TP_CD = D.HSP_TP_CD
    --                                   )        A
    --                                 , MOOOREXM AA
    --                                 , MSELMEBV BB
    --                 WHERE AA.ORD_DT       = A.ORD_DT
    --                   AND AA.PT_NO        = A.PT_NO
    --                   AND AA.SPCM_PTHL_NO = A.SPCM_NO
    --                   AND AA.HSP_TP_CD    = A.HSP_TP_CD
    --                   AND BB.EXM_CD       = A.EXM_CD
    --                   AND AA.ORD_CD       = BB.RPRN_EXM_CD
    --                   AND AA.HSP_TP_CD    = BB.HSP_TP_CD
    --                       ) E
    --                WHERE  A.SPCM_NO = B.SPCM_PTHL_NO
    --                  AND A.HSP_TP_CD = B.HSP_TP_CD
    --                  AND A.SPCM_NO = IN_SPCM_NO
    --                  AND A.HSP_TP_CD = IN_HSP_TP_CD
    --                  AND B.PT_NO = C.PT_NO
    --                  AND A.SPCM_NO = D.SPCM_NO
    --                  AND A.HSP_TP_CD = D.HSP_TP_CD
    --                  AND C.PT_NO = E.PT_NO
    --                  AND D.ORD_DT = E.ORD_DT
    --                  AND A.SPCM_NO = E.SPCM_NO
    --                  AND A.EXM_CD = E.EXM_CD
    --                  AND A.HSP_TP_CD = E.HSP_TP_CD
    --                  AND E.ROW_NUM = 1
    --                ORDER BY A.EXM_CD  
    --                ;            
                
                
                
    --                    SELECT DISTINCT
    --                           A.SPCM_NO                        -- 검체번호
    --                         , TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD HH24:MI:SS')    ACPT_DTM                    -- 접수일자
    --                         , A.EXM_ACPT_NO                    -- 작업번호
    --                         , C.PT_NO                          -- 환자번호
    --                         , C.PT_NM                          -- 환자이름
    --                         , C.SEX_TP_CD                      -- 성별
    --                         , TO_CHAR(C.PT_BRDY_DT, 'YYYY-MM-DD')    PT_BRDY_DT                             -- 생년월일
    --                         , B.PT_HME_DEPT_CD                 -- 진료과
    --                         , B.WD_DEPT_CD                     -- 병동
    --                         , A.EXM_CD                            -- 검사코드
    --                         , A.TH1_SPCM_CD                    -- 검체코드
    ----                         , (SELECT NVL(HR24_URN_EXM_VLM_CNTE, '') FROM MSELMCED WHERE SPCM_NO = A.SPCM_NO) VOL --    볼륨(일반화학쪽 사용)
    --                         , D.HR24_URN_EXM_TM
    --                         , D.HR24_URN_EXM_VLM_CNTE 
    --                         , FT_MSE_LM_RPRN_EXM_CD(C.PT_NO, D.ORD_DT, A.SPCM_NO, A.EXM_CD, A.HSP_TP_CD) RPRN_EXM_CD
    --                         , D.EXM_PRGR_STS_CD
    --                      FROM MSELMAID A
    --                         , MOOOREXM B
    --                         , PCTPCPAM_DAMO C
    --                         , MSELMCED D
    --                     WHERE A.SPCM_NO     = B.SPCM_PTHL_NO
    --                       AND A.HSP_TP_CD     = B.HSP_TP_CD
    --                       AND A.SPCM_NO     = IN_SPCM_NO        -- 검체번호
    --                       AND A.HSP_TP_CD     = IN_HSP_TP_CD        -- 병원구분
    --                       AND B.PT_NO         = C.PT_NO
    --                       AND A.SPCM_NO  = D.SPCM_NO
    --                       AND A.HSP_TP_CD = D.HSP_TP_CD
    --                     ORDER BY A.EXM_CD ;
                        
                      OUT_CURSOR := WK_CURSOR ;
    
                --예외처리
              EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_ORDER_SELECT-MSELMAID' || '접수된 검체정보가 조회되지 않습니다.' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END ; 
       
    END PC_MSE_ORDER_SELECT;   



    /**********************************************************************************************
    *    서비스이름      : PC_MSE_ORDER_SELECT_STAT
    *    최초 작성일     : 2020.07.17
    *    최초 작성자     : 이지케어텍
    *    DESCRIPTION   : 오더조회 상태값 조회기능 
    **********************************************************************************************/ 
    PROCEDURE PC_MSE_ORDER_SELECT_STAT (  IN_SPCM_NO     IN   VARCHAR2                 -- 검체번호
                                        , IN_HSP_TP_CD   IN   VARCHAR2               -- 병원코드
                                        , IN_EXM_CD      IN   VARCHAR2              -- 검사코드
                                        , OUT_CURSOR     OUT  RETURNCURSOR )
    IS
        --변수선언
         WK_CURSOR                 RETURNCURSOR ; 
    
        BEGIN       
            BEGIN
                --BODY
                OPEN WK_CURSOR FOR
                                        
                                       
                    SELECT
                           DISTINCT D.SPCM_NO,
                           TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD HH24:MI:SS') ACPT_DTM ,
                           A.EXM_ACPT_NO ,
                           C.PT_NO ,
                           C.PT_NM ,
                           C.SEX_TP_CD ,
                           TO_CHAR(C.PT_BRDY_DT, 'YYYY-MM-DD') PT_BRDY_DT ,
                           B.PT_HME_DEPT_CD ,
                           B.WD_DEPT_CD ,
                           A.EXM_CD ,
                           A.TH1_SPCM_CD ,
                           D.HR24_URN_EXM_TM ,
                           D.HR24_URN_EXM_VLM_CNTE ,
                           E.RPRN_EXM_CD ,
                           --D.EXM_PRGR_STS_CD
                           DECODE(A.SPEX_PRGR_STS_CD, '1', 'C', D.EXM_PRGR_STS_CD)  EXM_PRGR_STS_CD,
                           D.LBL_PRNT_EQUP_CD  WORK_NO,
                           D.EXRM_EXM_CTG_CD,
                           D.EXM_PRGR_STS_CD
                    FROM   MSELMCED D ,
                           MSELMAID A ,
                           MOOOREXM B ,
                           PCTPCPAM_DAMO C,
                                   (
                                           SELECT A.PT_NO
                                             , A.ORD_DT
                                             , A.SPCM_NO
                                             , A.EXM_CD
                                             , A.HSP_TP_CD
                                             , A.EXM_PRGR_STS_CD
                                             , NVL(BB.RPRN_EXM_CD, A.EXM_CD) RPRN_EXM_CD
                                             , ROW_NUMBER()  OVER (PARTITION BY A.PT_NO
                                                                              , A.ORD_DT
                                                                              , A.SPCM_NO
                                                                              , A.EXM_CD
                                                                              , A.HSP_TP_CD
                                                                       ORDER BY NVL(BB.RPRN_EXM_CD, A.EXM_CD)) ROW_NUM
                                          FROM (
                                                SELECT DISTINCT
                                                       C.PT_NO
                                                     , D.ORD_DT
                                                     , D.SPCM_NO
                                                     , NVL(A.EXM_CD, B.ORD_CD) EXM_CD
                                                     , D.HSP_TP_CD
                                                     , D.EXM_PRGR_STS_CD
                                                  FROM MSELMAID A ,
                                                       MOOOREXM B ,
                                                       PCTPCPAM_DAMO C ,
                                                       MSELMCED D
                                                WHERE D.SPCM_NO        = B.SPCM_PTHL_NO
                                                  AND D.HSP_TP_CD      = B.HSP_TP_CD
                                                  AND D.SPCM_NO        = IN_SPCM_NO
                                                  AND D.HSP_TP_CD      = IN_HSP_TP_CD
                                                  AND B.PT_NO          = C.PT_NO
                                                  AND A.SPCM_NO(+)   = D.SPCM_NO
                                                  AND A.HSP_TP_CD(+) = D.HSP_TP_CD
                                                  AND D.EXM_PRGR_STS_CD IN ('B', 'C', 'D', 'N')                                              --검사진행상태코드
                                               )        A
                                             , MOOOREXM AA
                                             , MSELMEBV BB
                             WHERE AA.ORD_DT       = A.ORD_DT
                               AND AA.PT_NO        = A.PT_NO
                               AND AA.SPCM_PTHL_NO = A.SPCM_NO
                               AND AA.HSP_TP_CD    = A.HSP_TP_CD
    --                           AND BB.EXM_CD       = A.EXM_CD        -- '2020-03-24' 05-26
                               AND AA.ORD_CD       = BB.RPRN_EXM_CD
                               AND AA.HSP_TP_CD    = BB.HSP_TP_CD
                                   ) E
                    WHERE 1=1
                      AND D.SPCM_NO         = B.SPCM_PTHL_NO
                      AND D.HSP_TP_CD         = B.HSP_TP_CD
                      AND D.SPCM_NO         = IN_SPCM_NO
                      AND D.HSP_TP_CD         = IN_HSP_TP_CD
                      AND B.PT_NO             = C.PT_NO
                      AND A.SPCM_NO(+)         = D.SPCM_NO
                      AND A.HSP_TP_CD(+)    = D.HSP_TP_CD
                      AND C.PT_NO             = E.PT_NO
                      AND D.ORD_DT             = E.ORD_DT
                      AND D.SPCM_NO         = E.SPCM_NO
                      AND A.EXM_CD(+)         = E.EXM_CD
                      AND D.HSP_TP_CD         = E.HSP_TP_CD
                      AND E.ROW_NUM = 1
                    ORDER BY A.EXM_CD
                    ;
                        
                      OUT_CURSOR := WK_CURSOR ;
    
                --예외처리
              EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_ORDER_SELECT_STAT' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END ; 
       
    END PC_MSE_ORDER_SELECT_STAT;



    /**********************************************************************************************
    *    서비스이름      : PC_MSE_ORDER_ACPTSEL
    *    최초 작성일     : 2020.04.03
    *    최초 작성자     : 김금덕 
    *    DESCRIPTION   : 오더조회 (접수일자,검사분류)  인터페이스 
    *    DESCRIPTION   : 오더조회  인터페이스 
    *                  : 2021.12.01 홍승표 -- 기간내 특정 검사실의 접수된 검사 리스트 조회
    *
    *                    VAR OUT_CURSOR REFCURSOR;
    *                    EXEC XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_ORDER_ACPTSEL(  '01'
    *                                                                        , '20211201000000'
    *                                                                        , '20211202235959'
    *                                                                        , 'LS'
    *                                                                        , :OUT_CURSOR
    *                                                                        );
    *                                       
    **********************************************************************************************/
    PROCEDURE PC_MSE_ORDER_ACPTSEL (  IN_HSP_TP_CD           IN   VARCHAR2           -- 병원구분
                                    , IN_SDTE                IN   VARCHAR2           -- 시작일자
                                    , IN_EDTE                IN   VARCHAR2           -- 종료일자
                                    , IN_EXRM_EXM_CTG_CD     IN   VARCHAR2           -- 검사분류
                                    , OUT_CURSOR             OUT  RETURNCURSOR )
    IS
        --변수선언
         WK_CURSOR                 RETURNCURSOR ; 
    
        BEGIN       

            -- SET검사코드 : LMTX01
            -- LMT04 (TB Culture PCR) 검사는 LMT01, LMT99에서 Abnormal한 결과인 경우 시행하므로, Abnormal한 검사의 정보를 ACK로 제공한다.
            -- 검증안된 8주 전 까지만 Abnormal한 검체만 조회            
            IF IN_EXRM_EXM_CTG_CD = 'LM_ABNORMAL' THEN    
                BEGIN
                    OPEN WK_CURSOR FOR
                                                                
                         SELECT /*+ INDEX(A MSELMAID_SI01) */
                                A.SPCM_NO
                              , TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD HH24:MI:SS') ACPT_DTM
                              , A.EXM_ACPT_NO
                              , A.PT_NO
                              , B.PT_NM
                              , B.SEX_TP_CD
                              , TO_CHAR(B.PT_BRDY_DT, 'YYYY-MM-DD') PT_BRDY_DT
                              , (SELECT PT_HME_DEPT_CD FROM MOOOREXM WHERE HSP_TP_CD = A.HSP_TP_CD AND SPCM_PTHL_NO = A.SPCM_NO AND ORD_ID = A.ORD_ID) PT_HME_DEPT_CD
                              , (SELECT WD_DEPT_CD     FROM MOOOREXM WHERE HSP_TP_CD = A.HSP_TP_CD AND SPCM_PTHL_NO = A.SPCM_NO AND ORD_ID = A.ORD_ID) WD_DEPT_CD
                              , A.EXM_CD
                              , A.TH1_SPCM_CD
                              , D.HR24_URN_EXM_TM
                              , D.HR24_URN_EXM_VLM_CNTE
                              , DECODE(A.SPEX_PRGR_STS_CD, '1', 'C', D.EXM_PRGR_STS_CD)  EXM_PRGR_STS_CD
                           FROM MSELMAID A
                              , PCTPCPAM_DAMO B
                              , MSELMCED D
                         WHERE 1=1
                           AND A.HSP_TP_CD       = IN_HSP_TP_CD
                           AND A.EXRM_EXM_CTG_CD =  'LM'
                           AND A.ACPT_DTM BETWEEN TO_DATE(IN_SDTE, 'YYYYMMDDHH24MISS') AND TO_DATE(IN_EDTE, 'YYYYMMDDHH24MISS')
                           AND A.EXM_CD           IN ('LMT01', 'LMT99')
                           AND A.RSLT_BRFG_YN   != 'Y'
                           AND A.ABNR_YN         = 'Y'
                           AND A.PT_NO           = B.PT_NO
                           AND A.HSP_TP_CD       = D.HSP_TP_CD
                           AND A.SPCM_NO         = D.SPCM_NO                
                           ;
                
                          OUT_CURSOR := WK_CURSOR ;
        
                    --예외처리
                  EXCEPTION
                        WHEN OTHERS THEN
                             RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_ORDER_ACPTSEL-LM_ABNORMAL' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
                END ; 
                
                RETURN;
            END IF;
                    
                    
            -- 기간내 특정 검사실의 접수된 검사 리스트 조회
            BEGIN
                OPEN WK_CURSOR FOR
                                        
                         SELECT A.SPCM_NO
                              , TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD HH24:MI:SS') ACPT_DTM 
                              , A.EXM_ACPT_NO
                              , A.PT_NO
                              , B.PT_NM
                              , B.SEX_TP_CD
                              , TO_CHAR(B.PT_BRDY_DT, 'YYYY-MM-DD') PT_BRDY_DT
                              , (SELECT PT_HME_DEPT_CD FROM MOOOREXM WHERE HSP_TP_CD = A.HSP_TP_CD AND SPCM_PTHL_NO = A.SPCM_NO AND ORD_ID = A.ORD_ID) PT_HME_DEPT_CD
                              , (SELECT WD_DEPT_CD     FROM MOOOREXM WHERE HSP_TP_CD = A.HSP_TP_CD AND SPCM_PTHL_NO = A.SPCM_NO AND ORD_ID = A.ORD_ID) WD_DEPT_CD                          
                              , A.EXM_CD
                              , A.TH1_SPCM_CD
                              , D.HR24_URN_EXM_TM
                              , D.HR24_URN_EXM_VLM_CNTE
--                              , DECODE(A.SPEX_PRGR_STS_CD, '1', 'C', D.EXM_PRGR_STS_CD)  EXM_PRGR_STS_CD
                              , DECODE(A.SMP_EXRS_CNTE, NULL, 'C', 'D')                  EXM_PRGR_STS_CD
                              
                           FROM MSELMAID A
                              , PCTPCPAM_DAMO B
                              , MSELMCED D
                         WHERE 1=1
                           AND A.HSP_TP_CD       = IN_HSP_TP_CD
                           AND A.EXRM_EXM_CTG_CD = IN_EXRM_EXM_CTG_CD
                           AND A.ACPT_DTM BETWEEN TO_DATE(IN_SDTE, 'YYYYMMDDHH24MISS') AND TO_DATE(IN_EDTE, 'YYYYMMDDHH24MISS')
                           AND A.RSLT_BRFG_YN   != 'Y'
                           AND A.PT_NO           = B.PT_NO
                           AND A.HSP_TP_CD       = D.HSP_TP_CD
                           AND A.SPCM_NO         = D.SPCM_NO
                         ORDER BY A.ACPT_DTM, A.SPCM_NO, A.WK_UNIT_CD
                           ;
                                                           
    --                SELECT
    --                       DISTINCT D.SPCM_NO
    --                     , TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD HH24:MI:SS') ACPT_DTM 
    --                     , A.EXM_ACPT_NO
    --                     , C.PT_NO
    --                     , C.PT_NM
    --                     , C.SEX_TP_CD
    --                     , TO_CHAR(C.PT_BRDY_DT, 'YYYY-MM-DD') PT_BRDY_DT
    --                     , B.PT_HME_DEPT_CD
    --                     , B.WD_DEPT_CD
    --                     , A.EXM_CD
    --                     , A.TH1_SPCM_CD
    --                     , D.HR24_URN_EXM_TM
    --                     , D.HR24_URN_EXM_VLM_CNTE
    --                     , E.RPRN_EXM_CD
    --                     , DECODE(A.SPEX_PRGR_STS_CD, '1', 'C', D.EXM_PRGR_STS_CD)  EXM_PRGR_STS_CD
    --                  FROM MSELMCED D
    --                     , MSELMAID A
    --                     , MOOOREXM B 
    --                     , PCTPCPAM_DAMO C
    --                     ,           (
    --                                       SELECT A.PT_NO
    --                                         , A.ORD_DT
    --                                         , A.SPCM_NO
    --                                         , A.EXM_CD
    --                                         , A.HSP_TP_CD
    --                                         , NVL(BB.RPRN_EXM_CD, A.EXM_CD) RPRN_EXM_CD
    --                                         , ROW_NUMBER()  OVER (PARTITION BY A.PT_NO
    --                                                                          , A.ORD_DT
    --                                                                          , A.SPCM_NO
    --                                                                          , A.EXM_CD
    --                                                                          , A.HSP_TP_CD
    --                                                                   ORDER BY NVL(BB.RPRN_EXM_CD, A.EXM_CD)) ROW_NUM
    --                                      FROM (
    --                                            SELECT DISTINCT
    --                                                   C.PT_NO
    --                                                 , D.ORD_DT
    --                                                 , D.SPCM_NO
    --                                                 , NVL(A.EXM_CD, B.ORD_CD) EXM_CD
    --                                                 , D.HSP_TP_CD
    --                                              FROM MSELMAID A
    --                                                 , MOOOREXM B
    --                                                 , PCTPCPAM_DAMO C
    --                                                 , MSELMCED D
    --                                             WHERE D.SPCM_NO                = B.SPCM_PTHL_NO
    --                                               AND D.HSP_TP_CD              = B.HSP_TP_CD
    --                                               AND D.EXRM_EXM_CTG_CD     = IN_EXRM_EXM_CTG_CD
    --                                               AND D.ACPT_DTM BETWEEN TO_DATE(IN_SDTE, 'YYYYMMDDHH24MISS') AND TO_DATE(IN_EDTE, 'YYYYMMDDHH24MISS')
    --                                               AND A.EXRM_EXM_CTG_CD(+) = D.EXRM_EXM_CTG_CD
    --                                               AND D.HSP_TP_CD              = IN_HSP_TP_CD
    --                                               AND B.PT_NO                  = C.PT_NO
    --                                               AND A.SPCM_NO(+)           = D.SPCM_NO
    --                                               AND A.HSP_TP_CD(+)         = D.HSP_TP_CD
    --                                           )        A
    --                                         , MOOOREXM AA
    --                                         , MSELMEBV BB
    --                         WHERE AA.ORD_DT       = A.ORD_DT
    --                           AND AA.PT_NO        = A.PT_NO
    --                           AND AA.SPCM_PTHL_NO = A.SPCM_NO
    --                           AND AA.HSP_TP_CD    = A.HSP_TP_CD
    --                           AND BB.EXM_CD       = A.EXM_CD        -- '2020-03-24'
    --                           AND AA.ORD_CD       = BB.RPRN_EXM_CD
    --                           AND AA.HSP_TP_CD    = BB.HSP_TP_CD
    --                               ) E
    --                WHERE 1=1
    --                  AND D.SPCM_NO         = B.SPCM_PTHL_NO
    --                  AND D.HSP_TP_CD         = B.HSP_TP_CD
    ----                  AND D.SPCM_NO         = IN_SPCM_NO
    --                  AND D.HSP_TP_CD         = IN_HSP_TP_CD
    --                  AND B.PT_NO             = C.PT_NO
    --                  AND A.SPCM_NO(+)         = D.SPCM_NO
    --                  AND A.HSP_TP_CD(+)    = D.HSP_TP_CD
    --                  AND C.PT_NO             = E.PT_NO
    --                  AND D.ORD_DT             = E.ORD_DT
    --                  AND D.SPCM_NO         = E.SPCM_NO
    --                  AND A.EXM_CD(+)         = E.EXM_CD
    --                  AND D.HSP_TP_CD         = E.HSP_TP_CD
    --                  AND E.ROW_NUM = 1
    --                ORDER BY D.SPCM_NO, A.EXM_CD
    --                ;
        
                      OUT_CURSOR := WK_CURSOR ;
    
                --예외처리
              EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_ORDER_ACPTSEL' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END ; 
       
    END PC_MSE_ORDER_ACPTSEL;
    


    /**********************************************************************************************
    **   서비스이름      : PC_MSE_RSLT_SAVE
    **   최초 작성일     : 2017.08.02
    **   최초 작성자     : 이대목동병원 전산과 김현식 
    **    DESCRIPTION  : 인터페이스 결과 전송 
    *                  : 2021.12.01 홍승표 - 인터페이스 결과 전송
    *
    *                    VAR OUT_CURSOR REFCURSOR;
    *                    EXEC XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_INTERFACE_SAVE(  '01'                  -- < P0>병원구분
    *                                                                        , '805'                  -- < P1>장비코드         : 001  002  003  004
    *                                                                        , ''                     -- < P2>FLAG 7 자리     : ABGA유무//////      YNYYYNN
    *                                                                        , 'CCC0EMR'              -- < P3>최초입력자       : (직번) - 70131
    *                                                                        , 'OSMO2430'             -- < P4>장비명           : 동일장비구분등을 위하여 사용함.
    *                                                                        , ''                     -- < P5>모검체           : TLA SUSTEM의 모검체 RACK NO. 를 확인하기 위하여 전송.
    *                                                                        , '20211203111027'       -- < P6>검사일시         : 시간이 없을 경우 "000000" 으로 보낸다.
    *                                                                        , '211203022895'         -- < P7>검체번호         : 바코드번호 12자리
    *                                                                        , '    qwerty    '       -- < P8>REMARK          : REMARK 내용  --> 장비비고 - MSELMCED(LMQC_RMK_CNTE)와 MSELMAID(EQUP_RMK_CNTE)에 업데이트
    *                                                                        , '1'                    -- < P9>처방개수         : 결과전송 처방 개수
    *                                                                        , '    LUO01    '        -- <P10>검사코드         : 처방코드(배열)
    *                                                                        , '        '             -- <P11>결과FLAG         : 수치결과,TEXT결과1,TEXT결과2 저장유형선택(배열)
    *                                                                        , '    280    '          -- <P12>검사결과내용      : 수치결과(배열
    *                                                                        , ''                     -- <P13>검사결과내용      : 텍스트결과(배열)
    *                                                                        , '        '             -- <P14>검사결과내용      : 수치결과 + 텍스트결과(배열)
    *                                                                        , '        '             -- <P15>결과비고          : 결과비고(배열)
    *                                                                        , '20211203111027'       -- <P16>소요시간          : 검사장비 시작시간 + 장비별 소요시간
    *                                                                        , '        '             -- <P17>일반화학체액      : 기기결과 결과값
    *                                                                        , '    '                 -- <P18>항목검사결과내용   : 항목검사결과내용
    *                                                                        , :IO_ERRYN
    *                                                                        , :IO_ERRMSG
    *                                                                        );
    *                    
    *                    COMMIT;
    *                    
    *                    PRINT :IO_ERRYN;
    *                    PRINT :IO_ERRMSG;
    *
    **   (IN_EQUIPTYPE : 001)  :    ADVIAS    ADVIA2120i
    **   (IN_EQUIPTYPE : 002)  :    XN10
    **   (IN_EQUIPTYPE : 003)  :    XN20-1
    **   (IN_EQUIPTYPE : 004)  :    TEST1
    **   (IN_EQUIPTYPE : 005)  :    CS5100-1
    **   (IN_EQUIPTYPE : 006)  :    CS51002
    **   (IN_EQUIPTYPE : 007)  :    PFA100
    **   (IN_EQUIPTYPE : 008)  :    Hitachi7600-1
    **   (IN_EQUIPTYPE : 009)  :    Hitachi7600-2
    **   (IN_EQUIPTYPE : 010)  :    E170
    **   (IN_EQUIPTYPE : 011)  :    Architect
    **********************************************************************************************/
    
    
    PROCEDURE PC_MSE_INTERFACE_SAVE( IN_HSP_TP_CD      IN      VARCHAR2   -- < P0>병원구분                                                                
                                   , IN_EQUIPTYPE      IN      VARCHAR2   -- < P1>장비코드         : 001  002  003  004                                        
                                   , IN_FLAG           IN      VARCHAR2   -- < P2>FLAG 7 자리     : ABGA유무//////      YNYYYNN       
                                   , IN_SPCID          IN      VARCHAR2   -- < P3>최초입력자       : (직번) - 70131                                            
                                   , IN_EQUP           IN      VARCHAR2   -- < P4>장비명           : 동일장비구분등을 위하여 사용함.                               
                                   , IN_RACK           IN      VARCHAR2   -- < P5>모검체           : TLA SUSTEM의 모검체 RACK NO. 를 확인하기 위하여 전송.            
                                   , IN_EXM_DT         IN      VARCHAR2   -- < P6>검사일시         : 시간이 없을 경우 "000000" 으로 보낸다.                        
                                   , IN_SPCM_NO        IN      VARCHAR2   -- < P7>검체번호         : 바코드번호 12자리                                            
                                   , IN_REMK           IN      VARCHAR2   -- < P8>REMARK          : REMARK 내용  --> 장비비고 - MSELMCED(LMQC_RMK_CNTE)와 MSELMAID(EQUP_RMK_CNTE)에 업데이트
                                   , IN_CNT            IN      VARCHAR2   -- < P9>처방개수         : 결과전송 처방 개수                                            
                                   , IN_TST_CD         IN      VARCHAR2   -- <P10>검사코드         : 처방코드(배열)                                                  
                                   , IN_RSLT_FLAG      IN      VARCHAR2   -- <P11>결과FLAG         : 수치결과,TEXT결과1,TEXT결과2 저장유형선택(배열)                     
                                   , IN_RSLT_FGR       IN      VARCHAR2   -- <P12>검사결과내용      : 수치결과(배열)                                                  
                                   , IN_RSLT_TXT       IN      VARCHAR2   -- <P13>검사결과내용      : 텍스트결과(배열)                                                
                                   , IN_RESULT         IN      VARCHAR2   -- <P14>검사결과내용      : 수치결과 + 텍스트결과(배열)
                                   , IN_RESULT_BIGO    IN      VARCHAR2   -- <P15>결과비고          : 결과비고(배열)                             
                                   , IN_ANTC_REQR_DTM  IN      VARCHAR2   -- <P16>소요시간          : 검사장비 시작시간 + 장비별 소요시간 
                                   , IN_HNWR_EXRS_CNTE IN      VARCHAR2   -- <P17>일반화학체액      : 기기결과 결과값
                                   , IN_ITEM_EXRS_CNTE IN      VARCHAR2   -- <P18>항목검사결과내용   : 항목검사결과내용                         -- 2018.09.27
                                   , IO_ERRYN          IN OUT  VARCHAR2
                                   , IO_ERRMSG         IN OUT  VARCHAR2 )
    IS
            T_ERROR_YN            VARCHAR2(0020)  :=  '';
            T_MSG                 VARCHAR2(0020)  :=  '';
                    
            T_PANICOUT            VARCHAR2(100)   := '';        -- 패닉 OUTPUT
            T_DELTAOUT            VARCHAR2(100)   := '';        -- 델타 OUTPUT
            T_CVROUT              VARCHAR2(100)   := '';        -- CVR OUTPUT
            
            TT_PANICOUT           T_VC2ARRAY10;                 -- 패닉 배열        
            TT_DELTAOUT           T_VC2ARRAY10;                 -- 델타 배열
            TT_CVROUT             T_VC2ARRAY10;                 -- CVR 배열            
            
            L_FLAG                NUMBER(10)      := TO_NUMBER(NVL(IN_CNT,'0'));   -- 처방갯수을   L_FLAG 에 담아서  FOR 문으로 돌림 
            L_UPDATE_CNT          NUMBER(10)      := 0;                            -- 업데이트 건수    
            
            T_WRKDT               VARCHAR2(0020)  :=  '';
            T_WRKDTM              DATE;  
            
            T_FLAG1               VARCHAR2(0001)  :=  '';      --  (FLAG) : 전송유무 - 결과를 전송하는지 않하는지 판단        
            T_FLAG2               VARCHAR2(0001)  :=  '';      --  (FLAG) : REMARK유무 - REMARK를 전송하는지 않하는지 판단        
            T_FLAG3               VARCHAR2(0001)  :=  '';      --  (FLAG) : 델타CHECK방법 - 수치결과,TEXT결과,DELTA CHECK 하지않음으로 구분                
            T_FLAG4               VARCHAR2(0001)  :=  '';      --  (FLAG) : 패닉CHECK방법 - 수치결과,TEXT결과,PANIC CHECK 하지않음으로 구분                
            T_FLAG5               VARCHAR2(0001)  :=  '';      --  (FLAG) : 검사일시 적용여부 - POCT 장비에서 결과보고시간을 UPDATE 여부                
            T_FLAG6               VARCHAR2(0001)  :=  '';      --  (FLAG) : 여유FLAG(1개)    
            T_FLAG7               VARCHAR2(0001)  :=  '';      --  (FLAG) : 여유FLAG(1개)    
                    
    
            TT_SPCID              T_VC2ARRAY100; 
            
            TT_TST_CD             T_VC2ARRAY4000;
            TT_RSLT_FLAG          T_VC2ARRAY4000; 
--            TT_RSLT_FGR           T_VC2ARRAY4000; 
            TT_RSLT_FGR           T_VC2ARRAY32767;  -- CLOB
            
            TT_RSLT_TXT           T_VC2ARRAY4000;
            TT_REMK               T_VC2ARRAY4000;
            TT_RESULT             T_VC2ARRAY4000;
            TT_RESULT_BIGO        T_VC2ARRAY4000;
            TT_HNWR_EXRS_CNTE     T_VC2ARRAY4000;  
            TT_ITEM_EXRS_CNTE     T_VC2ARRAY4000;    -- 2018.09.27
                
            T_MSBIOBAD_CNT        NUMBER(10);        -- 혈액형 결과정보 입력갯수
            T_EXM_ACPT_NO         VARCHAR2(0010); -- 혈액형 결과정보 입력된 접수번호
            
            T_PANI_YN             VARCHAR2(1)    := 'N';     -- 패닉체크  2018.11.01
            T_DELT_YN             VARCHAR2(1)    := 'N';     -- 델타체크  2018.11.01 
            S_SPCM_CNT            VARCHAR2(3)    := '0';     -- 검체갯수    2018.11.01 
            L30_REMK_YN           VARCHAR2(1)    := 'N';     -- L30 장비 비고 체크    
            T_MED_EXM_CTG_CD      VARCHAR2(3)    := '';      -- 검사분류코드  2018.11.13 
            
            V_QC_YN               VARCHAR2(1);       
            T_PT_NO               VARCHAR2(20);
            T_EXRM_EXM_CTG_CD     VARCHAR2(20);
            T_WK_UNIT_CD          VARCHAR2(20);
            T_RSLT_BRFG_YN        VARCHAR2(1);
            T_DFLT_EXRS_CNTE      VARCHAR2(4000);            
            T_NO_DATA_FOUND       VARCHAR2(1);
            
            T_HISTORY_REG_SEQ     NUMBER;
            
            T_SPCM_NO             VARCHAR2(50)   := IN_SPCM_NO;
            T_SPCM_NO_EXIST_YN    VARCHAR2(1)    := 'Y';
            T_DOCTOR_YN           VARCHAR2(1)    := 'N';
                      
            T_SAVEFLAG            VARCHAR2(1)    := 'T'; 
            
            T_EQUIP_NAME          VARCHAR2(4000);
            T_EQUIP_USE_DEPT      VARCHAR2(4000);
            T_EQUIP_RMK_CNTE      VARCHAR2(4000);
            
            --커스텀결과 검사코드
            T_EXM_GRP_CD          VARCHAR2(100);
            T_EXRS_CNTE           MSELMRID.EXRS_CNTE%TYPE;
            T_EXM_CD              VARCHAR2(100);
            T_RSLT_ITEM_CD        VARCHAR2(100);
            T_RSLT_CNTE           MSELMRID.EXRS_CNTE%TYPE;
            
            
        BEGIN
    
    --        IO_ERRMSG := 'TEST : ' || IN_ANTC_REQR_DTM || ' 갯수 : ' || L_FLAG;
    --        IO_ERRYN := 'Y';
    --        RETURN;
    
        
            BEGIN
                SELECT TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')
                     , SYSDATE
                  INTO T_WRKDT
                     , T_WRKDTM
                  FROM DUAL;
            END;


            BEGIN       
                SELECT NVL(SCLS_COMN_CD_NM, 'X')
                     , NVL(TH1_RMK_CNTE, 'X')
                     , NVL(TH2_RMK_CNTE, 'X')
                  INTO T_EQUIP_NAME
                     , T_EQUIP_USE_DEPT
                     , T_EQUIP_RMK_CNTE
                  FROM MSELMSID
                 WHERE HSP_TP_CD    = IN_HSP_TP_CD
                   AND SCLS_COMN_CD = IN_EQUIPTYPE
                   AND LCLS_COMN_CD = 'EQU'
                   AND USE_YN = 'Y'  
                 ;  
                EXCEPTION    
                    WHEN  OTHERS  THEN
                    T_EQUIP_NAME     := 'X';
                    T_EQUIP_USE_DEPT := 'X';
                    T_EQUIP_RMK_CNTE := 'X';
                    
                    -- 장비코드 없어도 결과는 진행되도록 함.
--                    IO_ERRYN  := 'Y';
--                    IO_ERRMSG := '등록된 장비코드가 없습니다.' || IN_EQUIPTYPE || ' ERROR : ' || SQLERRM;
--                    RETURN;  
            END; 
                                                                                                

                       
              T_FLAG1 := SUBSTR( IN_FLAG,1,1) ;         -- ABGA 유무(Y/N) 2019.01.15             
          
    --        T_FLAG2 := SUBSTR( IN_FLAG,2,1) ;        -- Remark유무
    --        T_FLAG3 := SUBSTR( IN_FLAG,3,1) ;       -- 델타
    --        T_FLAG4 := SUBSTR( IN_FLAG,4,1) ;       -- 패닉
    --        T_FLAG5 := SUBSTR( IN_FLAG,5,1) ;       -- 일시
    --        T_FLAG6 := SUBSTR( IN_FLAG,6,1) ;       -- etc
    --        T_FLAG7 := SUBSTR( IN_FLAG,7,1) ;       -- etc
            
    --        IO_ERRMSG := 'IN_EQUIPTYPE : ' || IN_EQUIPTYPE || CHR(10) 
    --                  || 'IN_FLAG : ' || IN_FLAG ||  CHR(10) 
    --                  || 'IN_SPCID : ' || IN_SPCID || CHR(10) 
    --                  || 'IN_EQUP : ' || IN_EQUP || CHR(10) 
    --                  || 'IN_RACK : ' || IN_RACK || CHR(10) 
    --                  || 'IN_EXM_DT : ' || IN_EXM_DT || CHR(10) 
    --                  || 'IN_SPCM_NO : ' || IN_SPCM_NO ||  CHR(10) 
    --                  || 'IN_REMK :' || IN_REMK ||  CHR(10) 
    --                  || 'IN_CNT :' || IN_CNT ||  CHR(10) 
    --                  || 'IN_TST_CD : ' || IN_TST_CD ||  CHR(10) 
    --                  || 'IN_RSLT_FLAG : ' || IN_RSLT_FLAG ||  CHR(10) 
    --                  || 'IN_RSLT_FGR :' || IN_RSLT_FGR ||  CHR(10) 
    --                  || 'IN_RSLT_TXT' || IN_RSLT_TXT ||  CHR(10) 
    --                  || 'IN_RESULT : ' || IN_RESULT ||  CHR(10) 
    --                  || 'IN_ANTC_REQR_DTM : ' || IN_ANTC_REQR_DTM || CHR(10) 
    --                  || 'IN_HNWR_EXRS_CNTE : ' || IN_HNWR_EXRS_CNTE  ||  CHR(10)
    --                  || 'IN_ITEM_EXRS_CNTE : ' || IN_ITEM_EXRS_CNTE
    --                  ;
    --        IO_ERRYN := 'Y';
    --        RETURN;
                       

            

            -- 이력순번 조회            
            BEGIN
                
                SELECT NVL(MAX(REG_SEQ), 0) + 1
                  INTO T_HISTORY_REG_SEQ
                  FROM MSELMIFD 
                 WHERE HSP_TP_CD = IN_HSP_TP_CD
                   AND SPCM_NO = T_SPCM_NO
                 ;
            
            END;
                    
                     
            IF  L_FLAG > 0 THEN    --  처방갯수만큼 FOR 문을 돌림 

                FOR I IN 1 .. L_FLAG
                LOOP                   
    
    --                IO_ERRMSG := '오류확인 : ' || IN_TST_CD || ' 갯수 : ' || L_FLAG;
    --                IO_ERRYN := 'Y';
    --                RETURN;
                ---------------------------------------------------------------------------------------------------------
                --- 닷넷 클라이언트에서 배열로 던질수 없어서 스트링으로 받아서 구분자로 잘라서 배열에 SET한다.  
                --- TAB + 결과값 1 + TAB + 결과값2 + TAB + 결과값3 + TAB   --> 이런 방식으로 보내야한다 
                ---------------------------------------------------------------------------------------------------------
                
--              장비비고는 배열이 아닌, 파이프라인(|)을 구분자로 조합한 일반 문자로 해당 검체번호에 대해 모두 저장한다.
--                TT_REMK          (I) := NVL( SUBSTR(IN_REMK            , INSTR(IN_REMK            , CHR(9),1,I) + 1  , INSTR(IN_REMK            , CHR(9),1,I + 1) - (INSTR(IN_REMK            , CHR(9),1,I) + 1)), '');        -- P8
                TT_REMK          (I) := IN_REMK;

                TT_TST_CD        (I) := NVL( SUBSTR(IN_TST_CD          , INSTR(IN_TST_CD          , CHR(9),1,I) + 1  , INSTR(IN_TST_CD          , CHR(9),1,I + 1) - (INSTR(IN_TST_CD          , CHR(9),1,I) + 1)), '');        -- P10
                TT_RSLT_FLAG     (I) := NVL( SUBSTR(IN_RSLT_FLAG       , INSTR(IN_RSLT_FLAG       , CHR(9),1,I) + 1  , INSTR(IN_RSLT_FLAG       , CHR(9),1,I + 1) - (INSTR(IN_RSLT_FLAG       , CHR(9),1,I) + 1)), '');        -- P11
                TT_RSLT_FGR      (I) := NVL( SUBSTR(IN_RSLT_FGR        , INSTR(IN_RSLT_FGR        , CHR(9),1,I) + 1  , INSTR(IN_RSLT_FGR        , CHR(9),1,I + 1) - (INSTR(IN_RSLT_FGR        , CHR(9),1,I) + 1)), '');        -- P12
                TT_RSLT_TXT      (I) := NVL( SUBSTR(IN_RSLT_TXT        , INSTR(IN_RSLT_TXT        , CHR(9),1,I) + 1  , INSTR(IN_RSLT_TXT        , CHR(9),1,I + 1) - (INSTR(IN_RSLT_TXT        , CHR(9),1,I) + 1)), '');        -- P13
                TT_RESULT        (I) := NVL( SUBSTR(IN_RESULT          , INSTR(IN_RESULT          , CHR(9),1,I) + 1  , INSTR(IN_RESULT          , CHR(9),1,I + 1) - (INSTR(IN_RESULT          , CHR(9),1,I) + 1)), '');        -- P14
                TT_RESULT_BIGO   (I) := NVL( SUBSTR(IN_RESULT_BIGO     , INSTR(IN_RESULT_BIGO     , CHR(9),1,I) + 1  , INSTR(IN_RESULT_BIGO     , CHR(9),1,I + 1) - (INSTR(IN_RESULT_BIGO     , CHR(9),1,I) + 1)), '');        -- P15  
                TT_HNWR_EXRS_CNTE(I) := NVL( SUBSTR(IN_HNWR_EXRS_CNTE  , INSTR(IN_HNWR_EXRS_CNTE  , CHR(9),1,I) + 1  , INSTR(IN_HNWR_EXRS_CNTE  , CHR(9),1,I + 1) - (INSTR(IN_HNWR_EXRS_CNTE  , CHR(9),1,I) + 1)), '');        -- P15     
                TT_ITEM_EXRS_CNTE(I) := NVL( SUBSTR(IN_ITEM_EXRS_CNTE  , INSTR(IN_ITEM_EXRS_CNTE  , CHR(9),1,I) + 1  , INSTR(IN_ITEM_EXRS_CNTE  , CHR(9),1,I + 1) - (INSTR(IN_ITEM_EXRS_CNTE  , CHR(9),1,I) + 1)), '');        -- P18

--                RAISE_APPLICATION_ERROR(-20001, TT_TST_CD        (I) || '\' ) ;
                
                IO_ERRYN :=  I ;
                
                END LOOP;   
                
            END IF; 
            

            
            -----------------------------------------------------------------------------------------------------
            -- ABGA 처방발행, 채혈, 접수처리 : 장비 마스터 테이블에서 TH2_RMK_CNTE 현장검사 사용
            -----------------------------------------------------------------------------------------------------
            IF IN_EQUIPTYPE IN (  'E-PA1', 'E-PA2', 'E-PA3', 'E-PA4' -- 1동수술실
                                , 'E-8-3' -- 8동수술실
                                , 'E-RRS' -- 신속대응팀
                                , 'E-7-8' -- 7동8층
                                , 'E-5A'  -- 1동5층
                               )  
               OR
               T_EQUIP_RMK_CNTE = '현장검사' 
               
               THEN         

                
                -- 검체번호로 연동시는 정상적인 인터페이스 저장 로직으로 진행하고, 환자번호만으로 연동할 경우에는 PC_MSE_ABGA_ORDER_AUTO 저장한다.
                IF LENGTH(IN_SPCM_NO) = 12 THEN
                    GOTO NEXT_IF_SAVE;
                END IF;
            

                -- 검체번호 없음 Y                
                T_SPCM_NO_EXIST_YN := 'N';
                                
                
--                -- 현장검사 자동처방발행 : 장비로그인 아이디가 의사가 아니면 자동발행불가
--                BEGIN
--                    SELECT DECODE(COUNT(*), 0, 'N', 'Y')
--                      INTO T_DOCTOR_YN
--                      FROM XGAB.PDESMSAV A
--                     WHERE A.HSP_TP_CD = IN_HSP_TP_CD
--                       AND A.STF_NO    = IN_SPCID
--                       AND A.LCNS_NO   IS NOT NULL                       
--                     ;
--                     
--                    IF T_DOCTOR_YN = 0 THEN
--                        IO_ERRYN  := 'Y';
--                        IO_ERRMSG := '현장검사 자동처방발행 : 장비로그인 아이디가 의사가 아니면 자동발행불가. 의사아이디 및 의사면허번호를 확인해주세요! ' 
--                                     || CHR(13) || '검체번호-' || IN_SPCM_NO || CHR(13) || SQLERRM;
--                        RETURN;                       
--                    END IF; 
--                END;

                                
                IF L_FLAG > 0 THEN
                    FOR I IN 1 .. 1
                    LOOP
                        T_PT_NO := IN_SPCM_NO;
                        
                        PC_MSE_ABGA_ORDER_AUTO
                        ( T_PT_NO   -- ABGA는 검체번호에 환자 등록번호 넘어옴.
                        , T_SPCM_NO -- IN OUT
                       
                        , IN_SPCID --'IF'
                        , IN_HSP_TP_CD
                        , 'INTERFACE'
                        , SYS_CONTEXT('USERENV','IP_ADDRESS')
                         
                        , IO_ERRYN
                        , IO_ERRMSG
                        );                    

                        IF IO_ERRYN = 'Y' THEN
                            RETURN;
                        END IF;
                    END LOOP;   
                    
                END IF; 
            END IF;
                   
            <<NEXT_IF_SAVE>>                                     

            -- 검체번호 있을때 (일반적인 경우) 결과테이블에서 접수번호 체크함.
            IF T_SPCM_NO_EXIST_YN = 'Y' THEN

                BEGIN     -- 2018-03-02      결과저장시  접수안하고 넘기기는 경우발생
                    SELECT EXM_ACPT_NO
                      INTO T_EXM_ACPT_NO 
                      FROM MSELMAID 
                     WHERE SPCM_NO = T_SPCM_NO
                       AND HSP_TP_CD = IN_HSP_TP_CD
                       AND ROWNUM = 1
                     ;
                     
                    IF T_EXM_ACPT_NO = 0 THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := '검체접수가 누락되었습니다. 확인해주세요! ' || TO_CHAR(SQLCODE);
                        RETURN;                       
                    END IF; 
                END;
            END IF;

            
            -----------------------------------------------------------------------------------------------------
            -- 델타/패닉 구문
            -----------------------------------------------------------------------------------------------------
            IF L_FLAG > 0 THEN
                FOR I IN 1 .. L_FLAG
                LOOP
    --                IF TT_SPCID(I) IS NOT NULL THEN
    --                    IF IN_EQUIPTYPE = 'G' AND SUBSTR(TT_TST_CD(I),1,3) = 'L31' THEN
    --                        BEGIN
    --                        
    --                            UPDATE MSELMAID --접수검사항목결과정보
    --                               SET HNWR_EXRS_CNTE = TT_RESULT(I)
    --                                 , LSH_DTM        = SYSDATE     --2015-06-24 곽수미 추가
    --                             WHERE SPCM_NO = TT_SPCID(I)
    --                               AND EXM_CD = TT_TST_CD(I)
    --                               AND HSP_TP_CD = IN_HSP_TP_CD --병원구분
    --                                 ;
    --                        
    --                        END;                                  
    --                    
    --                        TT_PANICOUT(I) := '';
    --                        TT_DELTAOUT(I) := '';  
    --                    
    --                    ELSE 
                        
                            BEGIN
                            
                                    PC_MSE_DELTAPANIC_CHKMAIN(T_SPCM_NO --TT_SPCID(I)
                                                            , TT_TST_CD(I)
                                                            , TT_RSLT_FGR(I)
                                                            , IN_HSP_TP_CD
                                                            , T_PANICOUT
                                                            , T_DELTAOUT
                                                            , T_CVROUT
                                                            , T_ERROR_YN
                                                            , T_MSG);
                                    
                                    EXCEPTION
                                    WHEN  OTHERS  THEN
                                        T_PANICOUT := 'N';
                                        T_DELTAOUT := 'N';
                                        T_CVROUT   := 'N';
                            END;
                        
                            TT_PANICOUT(I) := T_PANICOUT;
                            TT_DELTAOUT(I) := T_DELTAOUT;
                            TT_CVROUT  (I) := T_CVROUT;
                        
                            T_PANICOUT := '';
                            T_DELTAOUT := '';          
                            T_CVROUT   := '';          

                        
    --                    END IF;
    --                END IF;
                END LOOP;
            END IF;
            
    --        IF IN_EQUIPTYPE = '001' OR IN_EQUIPTYPE = '002' OR IN_EQUIPTYPE ='003' OR IN_EQUIPTYPE ='004' THEN    -- 일반혈액
    --               T_MED_EXM_CTG_CD := 'L20';               
    --        ELSIF IN_EQUIPTYPE = '021' OR IN_EQUIPTYPE = '022' THEN                                                -- 자동화학면역
    --            T_MED_EXM_CTG_CD := 'L80';
    --        ELSIF IN_EQUIPTYPE = '014' OR IN_EQUIPTYPE = '015' OR IN_EQUIPTYPE = '016' THEN                        -- 응급실검사실
    --            T_MED_EXM_CTG_CD := 'L80';
    --        ELSIF IN_EQUIPTYPE = '028' OR IN_EQUIPTYPE = '029' THEN                                                -- 일반면역
    --            T_MED_EXM_CTG_CD := 'L33';
    --        ELSIF IN_EQUIPTYPE = '005' OR IN_EQUIPTYPE = '006' THEN                                                -- 혈액응고
    --            T_MED_EXM_CTG_CD := 'L22';
    --        ELSE
    --            T_MED_EXM_CTG_CD := '';
    --        END IF;
            
            
            ---------------------------------------------------------------------------------------------------------
            --- 결과 입력 구문 
            ---------------------------------------------------------------------------------------------------------      
--            IF 1 = 1
--                OR IN_EQUIPTYPE = '001' OR IN_EQUIPTYPE = '002' OR IN_EQUIPTYPE = '003' OR IN_EQUIPTYPE = '004' OR IN_EQUIPTYPE = '005' OR IN_EQUIPTYPE = '006' OR IN_EQUIPTYPE = '007' 
--                OR IN_EQUIPTYPE = '008' OR IN_EQUIPTYPE = '009' OR IN_EQUIPTYPE = '010' OR IN_EQUIPTYPE = '011' OR IN_EQUIPTYPE = '012' OR IN_EQUIPTYPE = '013' OR IN_EQUIPTYPE = '014' OR IN_EQUIPTYPE = '015' 
--                OR IN_EQUIPTYPE = '016' OR IN_EQUIPTYPE = '017' OR IN_EQUIPTYPE = '018' OR IN_EQUIPTYPE = '019' OR IN_EQUIPTYPE = '020' OR IN_EQUIPTYPE = '021' OR IN_EQUIPTYPE = '022' OR IN_EQUIPTYPE = '023' 
--                OR IN_EQUIPTYPE = '024' OR IN_EQUIPTYPE = '025' OR IN_EQUIPTYPE = '026' OR IN_EQUIPTYPE = '027' OR IN_EQUIPTYPE = '028' OR IN_EQUIPTYPE = '029' OR IN_EQUIPTYPE = '030' OR IN_EQUIPTYPE = '031' 
--                OR IN_EQUIPTYPE = '032' OR IN_EQUIPTYPE = '033' OR IN_EQUIPTYPE = '034' OR IN_EQUIPTYPE = '035' OR IN_EQUIPTYPE = '037' OR IN_EQUIPTYPE = '038' OR IN_EQUIPTYPE = '039'                          -- OR IN_EQUIPTYPE = '036'
--                OR IN_EQUIPTYPE = '040' OR IN_EQUIPTYPE = '041' OR IN_EQUIPTYPE = '042' OR IN_EQUIPTYPE = '043' OR IN_EQUIPTYPE = '044' OR IN_EQUIPTYPE = '045' OR IN_EQUIPTYPE = '046' OR IN_EQUIPTYPE = '047' OR IN_EQUIPTYPE = '048' OR IN_EQUIPTYPE = '049'
--                OR IN_EQUIPTYPE = '050' OR IN_EQUIPTYPE = '051' OR IN_EQUIPTYPE = '052' OR IN_EQUIPTYPE = '053' OR IN_EQUIPTYPE = '054' OR IN_EQUIPTYPE = '055' OR IN_EQUIPTYPE = '057' OR IN_EQUIPTYPE = '058'
--                OR IN_EQUIPTYPE = '059' OR IN_EQUIPTYPE = '060' OR IN_EQUIPTYPE = '061' OR IN_EQUIPTYPE = '062' OR IN_EQUIPTYPE = '063' OR IN_EQUIPTYPE = '064' OR IN_EQUIPTYPE = '065' OR IN_EQUIPTYPE = '066' OR IN_EQUIPTYPE = '067'
--                OR IN_EQUIPTYPE = '068' THEN                              --    결과 UPDATE  장비    001  START     
                             



            -- 검사결과저장
            -- 혈액은행 제외 : 혈액은행은 아랫쪽의 IN_EQUIPTYPE = '951' 사용
            -- 혈액은행 제외 : 장비 마스터 테이블에서 TH2_RMK_CNTE 혈액은행 아닌 장비 사용
--            IF IN_EQUIPTYPE != '951' THEN            
            IF T_EQUIP_RMK_CNTE != '혈액은행' THEN
            
            
                         
    --          IO_ERRYN  := 'Y';
    --            IO_ERRMSG := '결과업데이트전 오류 발생. ERRCD = ' || L_FLAG;
    --            RETURN;
              
                IF  L_FLAG > 0 THEN             
                    FOR I IN 1 .. L_FLAG
                    LOOP
    --                    IF IN_EQUIPTYPE = '001' OR IN_EQUIPTYPE = 'F' THEN                      
                            BEGIN
                                         
    --                            IO_ERRMSG := '병원구분:' || IN_HSP_TP_CD || ' 장비코드 : ' || IN_EQUIPTYPE || ' 처방갯수:' || L_FLAG || ' 검체번호 : ' || T_SPCM_NO || ' 검사명 :' || TT_TST_CD(I) || ' IN_TST_CD : ' || IN_TST_CD || ' IN_RSLT_FGR 결과값: ' || TT_RSLT_FGR(I);
    --                            IO_ERRYN := 'Y';
    --                            RETURN;
                             
    --                            UPDATE MSELMAID  -- 접수검사항목결과정보
    --                               SET EXRS_CNTE             = TT_RSLT_FGR(I) --DECODE(TT_RSLT_FGR(I), '-', '- ', TT_RSLT_FGR(I))                        -- 검사결과내용
    --                                --,RSLT_MDF_DTM      = TO_CHAR(T_WRKDTM, 'YYYYMMDDHH24MI')
    --                                 , RSLT_MDF_DTM          = T_WRKDTM                              -- 결과수정일시
    --                              --    ,EQUP_SND_CNTE     = SUBSTR(TT_ERRFLAG(I), 1, 10)
    --
    --                              --    ,SPEX_PRGR_STS_CD   = DECODE(FT_SL_EQU_TSTCD_STAT(TT_TST_CD(I)), 'Y', '2', DECODE(TT_PANICOUT(I) || TT_DELTAOUT(I), 'NN', '3', '2')) --2011.09.20 방수석 특정검사 자동검증 해제기능 신설
    --
    --                                 , DEXM_MDSC_EQUP_CD     = IN_EQUP--TT_EQUIPCD(I)                        -- 진단검사의학장비코드
    --                                 , DLT_YN                = TT_DELTAOUT(I)                        -- 델타여부
    --                                 , PNC_YN                = TT_PANICOUT(I)                         -- 패닉여부
    --                                 , AMR_YN                = 'N'                                    -- AMR여부
    ----                                 , EQUP_RMK_CNTE          = DECODE(IN_EQUIPTYPE, 'F', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUIPTYPE || TT_RESULT(I), EQUP_RMK_CNTE)  --2009.04.10 방수석 추가 장비인터페이스시 로그를 남긴다.  
    ----                                 , EQUP_RMK_CNTE          = DECODE(TT_RSLT_FLAG(I), 'R', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUP || TT_RSLT_FGR(I), EQUP_RMK_CNTE
    ----                                                                                , 'N', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUP || TT_RSLT_FGR(I), EQUP_RMK_CNTE)  --2017.09.05 김금덕 재검증 장비인터페이스시 로그를 남긴다.  R 재검증, N 최초전송 
    --                                 , EQUP_RMK_CNTE          = DECODE(DECODE(DEXM_MDSC_EQUP_CD, '', 'N', 'R'), 'R', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUP || TT_RSLT_FGR(I), EQUP_RMK_CNTE
    --                                                                                                        , 'N', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUP || TT_RSLT_FGR(I), EQUP_RMK_CNTE)  --2017.12.06 김금덕 재검증필드확인해서 처리한다  R 재검증, N 최초전송 
    --                                 , EXRS_RMK_CNTE         = TT_RESULT_BIGO(I)
    --                                 , ANTC_REQR_DTM        = TO_DATE(IN_ANTC_REQR_DTM, 'YYYY-MM-DD HH24:MI:SS') --DECODE(IN_ANTC_REQR_DTM, '', NULL, TO_DATE(IN_ANTC_REQR_DTM, 'YYYYMMDDHH24MISS')) --IN_ANTC_REQR_DTM                       -- 소요시간
    --                                 
    --                                 , HNWR_EXRS_CNTE       = TT_HNWR_EXRS_CNTE(I)
    --                                 , LSH_DTM                 = SYSDATE     --2015-06-24 곽수미 추가
    --                                 , LSH_PRGM_NM             = 'INTERFACE'
    --                                 , LSH_IP_ADDR             = SYS_CONTEXT('USERENV','IP_ADDRESS') 
    --                                 , SPEX_PRGR_STS_CD     = '2'                                     -- 미검증상태   2018.02.07 처리
    --                             WHERE SPCM_NO              = T_SPCM_NO
    --                               AND EXM_CD                = TT_TST_CD(I)
    --                               AND HSP_TP_CD             = IN_HSP_TP_CD --병원구분
    --                               AND SPEX_PRGR_STS_CD <> '3'                                        -- 최종검증 아닌것만
    --                               ;  
                                   
    --                            IF SQL%ROWCOUNT = 0 THEN
    --                                IO_ERRYN  := 'Y';
    --                                 IO_ERRMSG := 'PC_MSE_INTERFACE_SAVE 결과업데이트중 0건 발생. ERRCD = ' || TO_CHAR(SQLCODE);  
    --                                 RETURN;
    --                            END IF;  
                                
                                 BEGIN
                                    SELECT A.PT_NO
                                         , A.EXRM_EXM_CTG_CD
                                         , A.WK_UNIT_CD    
                                         , NVL(A.RSLT_BRFG_YN, 'N')
                                         , B.DFLT_EXRS_CNTE
                                      INTO T_PT_NO
                                         , T_EXRM_EXM_CTG_CD
                                         , T_WK_UNIT_CD
                                         , T_RSLT_BRFG_YN
                                         , T_DFLT_EXRS_CNTE
                                      FROM MSELMAID A
                                         , MSELMEBM B
                                     WHERE A.HSP_TP_CD = IN_HSP_TP_CD
                                       AND A.SPCM_NO   = T_SPCM_NO
                                       AND A.EXM_CD    = TT_TST_CD(I)
                                       AND A.HSP_TP_CD = B.HSP_TP_CD
                                       AND A.EXM_CD    = B.EXM_CD
                                       AND ROWNUM = 1;   
    
                                    T_NO_DATA_FOUND := 'N';
                                    
                                    EXCEPTION
                                        WHEN NO_DATA_FOUND THEN  
                                            --저장되어 있는 검사결과가 없을수도 있음
                                            --장비에서 검체번호에 해당하지 않는 코드도 추가로 넘겨줌.
                                            T_NO_DATA_FOUND := 'Y';
                                        WHEN OTHERS THEN
                                            IO_ERRYN  := 'Y';
                                            IO_ERRMSG := '검사결과 정보 조회중 오류가 발생했습니다. [' || T_SPCM_NO || ' : ' || TT_TST_CD(I) || ']' || ' ERROR : ' || SQLERRM;
                                            RETURN;  
                                     
                                 END; 
                                         
                                 
                                -- 현장검사-혈당검사(POCT-Blood gulucose test)        
                                -- 혈당검사일 경우에는 최종검증이 완료된 이후에도 다시 전송하거나 사용자가 결과수정하여 저장하여도, 결과 저장되도록 변경함. 아래 3가지 로직 참고
                                -- 1. 장비 인터페이스 전송 : PKG_MSE_LM_INTERFACE.SAVE
                                -- 2. 간호 Patient 리스트 - 혈당검사 : PKG_MSE_LM_EXAMRSLT
                                -- 3. 환자별 검사시행관리 - 혈당검사 결과등록 : PKG_MSE_LM_EXAMRSLT        
                                 IF TT_TST_CD(I) = 'LTS001' THEN
                                     T_NO_DATA_FOUND := 'N';
                                     T_RSLT_BRFG_YN  := 'N';    
                                 END IF;
                                 
    
                                 -- 이력저장
                                 -- 이력저장은 장비에서 검체번호에 해당하지 않는 코드도 추가로 넘겨주기 때문에 결과와 무관하게 이력에 저장함.
                                 PC_MSE_HISTORY_SAVE
                                                 ( IN_EQUIPTYPE       -- IN_EQUP 
                                                 , T_HISTORY_REG_SEQ
                                                 , TT_TST_CD(I)
                                                 , T_PT_NO
                                                 , T_SPCM_NO            
                                                 
                                                 , TT_RSLT_FGR(I)     -- 검사결과
                                                 , TT_REMK(I)         -- 검체비고내용
                                                 , TT_RESULT_BIGO(I)  -- 인터페이스비고                                                      
                                                                  
                                                 , IN_SPCID --'IF'
                                                 , IN_HSP_TP_CD
                                                 , 'INTERFACE'
                                                 , SYS_CONTEXT('USERENV','IP_ADDRESS')
                                                 
                                                 , IO_ERRYN
                                                 , IO_ERRMSG
                                                 );
                                 
                                 
                                 IF IO_ERRYN = 'Y' THEN
                                     RETURN;
                                 END IF;
    
--                                 RAISE_APPLICATION_ERROR(-20001, T_NO_DATA_FOUND || '\' || T_RSLT_BRFG_YN || '\' || T_SPCM_NO || '\' || TT_TST_CD(I) || '\' || TT_RSLT_FGR(I)) ;                                                                    
                                
                                 IF T_NO_DATA_FOUND = 'N' AND T_RSLT_BRFG_YN != 'Y' THEN

                                    -- QC 환자인지 체크함
                                    BEGIN
                                        SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                                          INTO V_QC_YN
                                          FROM MSELMSID
                                         WHERE HSP_TP_CD    = IN_HSP_TP_CD
                                           AND LCLS_COMN_CD = 'QC_PT_NO'
                                           AND SCLS_COMN_CD = T_PT_NO 
                                         ;                                
                                    END;                                     
                                 
                                    --최종검증 : 현장검사 전송시, QC 환자 전송시
--                                     IF T_EXRM_EXM_CTG_CD = 'LT' OR V_QC_YN = 'Y' THEN
                                    IF T_EXRM_EXM_CTG_CD = 'LT' THEN
                                        T_SAVEFLAG := 'C';
                                    END IF; 
                                    
                                    -- LMH01 - Blood culture  
                                    -- 아래 조건일때 자동 중간보고 되도록 함.
                                    IF TT_TST_CD(I) = 'LMH01' THEN
                                        IF INSTR(UPPER(REPLACE(TT_RSLT_FGR(I), ' ', '')), '2DAYS') > 0 THEN
                                            T_SAVEFLAG := 'P';
                                        ELSIF INSTR(UPPER(REPLACE(TT_RSLT_FGR(I), ' ', '')), 'NOGROWTH') > 0 THEN
                                            T_SAVEFLAG := 'P';                                            
                                        END IF;
                                    END IF;                                   
                                    
                                    XSUP.PKG_MSE_LM_EXAMRSLT.SAVE
                                                 (  T_SAVEFLAG -- 'T'  -- 임시, 현장검사는 전송시 최종검증)
                                                  , T_PT_NO                                   -- 환자번호
                                                  , T_SPCM_NO
                                                  , T_EXRM_EXM_CTG_CD                         -- IN_EXM_CTG_CD       IN      MSELMAID.EXRM_EXM_CTG_CD%TYPE
                                                  , T_WK_UNIT_CD                              -- IN_WK_UNIT_CD       IN      MSELMAID.WK_UNIT_CD%TYPE
                                                  , TT_TST_CD(I)                              -- IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                                                  , ''                                        -- IN_MIDL_BRFG_CNTE   IN      MSELMAID.MIDL_BRFG_CNTE%TYPE
                                                  
                                                  -- 장비결과값이 NULL이면, Default검사결과 저장
                                                  , NVL(TT_RSLT_FGR(I), T_DFLT_EXRS_CNTE)     -- IN_EXRS_CNTE        IN      MSELMAID.EXRS_CNTE%TYPE
                                
                                                  , ''                                        -- IN_RMK_CNTE         IN      MSELMCED.RMK_CNTE%TYPE
                                                  , '' --TT_REMK(I)                                -- IN_LMQC_RMK_CNTE    IN      MSELMCED.LMQC_RMK_CNTE%TYPE
                                                  , '' --TT_RESULT_BIGO(I)                         -- IN_EXRS_RMK_CNTE    IN      MSELMAID.EXRS_RMK_CNTE%TYPE
                                                  , ''                                        -- IN_EXRM_RMK_CNTE    IN      MSELMAID.EXRM_RMK_CNTE%TYPE
                                                 
                                                  , TT_DELTAOUT(I)                            -- IN      MSELMAID.DLT_YN%TYPE
                                                  , TT_PANICOUT(I)                            -- IN      MSELMAID.PNC_YN%TYPE
                                                  , TT_CVROUT  (I)                            -- IN      MSELMAID.CVR_YN%TYPE
                                                 
                                                  , IN_SPCID --'IF'                                      -- HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                                                  , IN_HSP_TP_CD                              -- HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                                                  , 'INTERFACE'                               -- HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                                                  , SYS_CONTEXT('USERENV','IP_ADDRESS')       -- HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE

                                                  , ''                                        -- IN_RSLT_BRFG_CNTE   IN      MSELMAID.RSLT_BRFG_CNTE%TYPE
                                                 
                                                  , IO_ERRYN -- IO_ERR_YN           IN OUT  VARCHAR2
                                                  , IO_ERRMSG --IO_ERR_MSG          IN OUT  VARCHAR2 
                                                 );
                         
                                     IF IO_ERRYN = 'Y' THEN
                                         RETURN;
                                     END IF;
                                                                  
                                                                                                               
                                                                  
                                    -- 장비결과저장 관련 컬럼(DEXM_MDSC_EQUP_CD, EQUP_RMK_CNTE, EQUP_RSLT_SND_DTM)
                                    -- 장비결과저장 항목들은, 현재의 인터페이스 검사결과 저장시점(PKG_MSE_LM_INTERFACE.PC_MSE_INTERFACE_SAVE)에서 저장하며, 검사결과저장 패키지(PKG_MSE_LM_EXAMRSLT.SAVE)에서는 저장하지 않는다.
                                    
                                    PC_MSE_UPDATE_EQUP_INFO
                                    (
                                      T_SPCM_NO 
                                    , TT_TST_CD(I)
                                    , TT_RSLT_FGR(I) 
                                    
                                    , IN_EQUIPTYPE -- IN_EQUP
                                    , TT_RESULT_BIGO(I)
                                    , TO_DATE(IN_ANTC_REQR_DTM, 'YYYYMMDDHH24MISS')
                                    , '' --TT_HNWR_EXRS_CNTE(I)
                                    
                                    , IN_SPCID --'IF'                                      
                                    , IN_HSP_TP_CD                              
                                    , 'INTERFACE'                               
                                    , SYS_CONTEXT('USERENV','IP_ADDRESS') 
                                    , IO_ERRYN
                                    , IO_ERRMSG      
                                    );                                                                           
--                                   IF IO_ERRYN = 'Y' THEN
--                                        IO_ERRYN  := 'Y';
--                                        IO_ERRMSG := IO_ERRMSG;  
--                                        RETURN;
--                                   END IF;     
                                                           
                                    
                                    -- 이미지결과인터페이스
                                    -- 결과에 '이미지 참조' 문자열이 넘어옴(ACK)
                                    -- 이미지 결과 테이블에 검체번호와 검사코드 조합으로 이미지 경로 생성해줌.
                                    IF INSTR(REPLACE(TT_RSLT_FGR(I), ' ', ''), '이미지') > 0 THEN
                                        PC_MSE_IMGRSLT_SIMPLE_SAVE
                                        (
                                          T_SPCM_NO 
                                        , TT_TST_CD(I)
                                        , '' -- FILE_SEQ 
                                        
                                        , IN_SPCID --'IF'                                      
                                        , IN_HSP_TP_CD                              
                                        , 'INTERFACE'                               
                                        , SYS_CONTEXT('USERENV','IP_ADDRESS') 
                                        , IO_ERRYN
                                        , IO_ERRMSG      
                                        );
                                    END IF;
                                    
                                                                  
                                                                               
                                    IF IO_ERRYN <> 'Y' THEN
                                        L_UPDATE_CNT := L_UPDATE_CNT + 1;
                                    END IF;         
    
                                 END IF; -- IF T_RSLT_BRFG_YN != 'Y' THEN    
                            
                            END;
                            
                            
                       END LOOP;  
                                       
--                       RAISE_APPLICATION_ERROR(-20001, T_SPCM_NO || '\' || '\' || SQL%ROWCOUNT || '\' || L_UPDATE_CNT) ;
    
                       IF L_UPDATE_CNT = 0 THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := 'PC_MSE_INTERFACE_SAVE 결과업데이트중 0건 발생. ERRCD = ' || TO_CHAR(SQLERRM);  
                       END IF;
                       
                   END IF;           
                                       
                   
    --        ELSIF IN_EQUIPTYPE = '069' OR IN_EQUIPTYPE = '070' OR IN_EQUIPTYPE = '071' OR IN_EQUIPTYPE = '072' OR IN_EQUIPTYPE = '073' OR IN_EQUIPTYPE = '074' OR IN_EQUIPTYPE = '075' THEN        -- 자동검증 로직
    --            
    --            IF  L_FLAG > 0 THEN             
    --                  FOR I IN 1 .. L_FLAG
    --                LOOP
    --                         BEGIN
    --                   
    --                            UPDATE MSELMAID              -- 접수검사항목결과정보
    --                               SET EXRS_CNTE             = TT_RSLT_FGR(I)                        -- 검사결과내용
    --                                 , RSLT_MDF_DTM          = T_WRKDTM                              -- 결과수정일시                              
    --                                 , DEXM_MDSC_EQUP_CD     = IN_EQUP--TT_EQUIPCD(I)                -- 진단검사의학장비코드
    --                                 , DLT_YN                = TT_DELTAOUT(I)                        -- 델타여부
    --                                 , PNC_YN                = TT_PANICOUT(I)                         -- 패닉여부
    --                                 , EQUP_RMK_CNTE          = DECODE(DECODE(DEXM_MDSC_EQUP_CD, '', 'N', 'R'), 'R', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUP || TT_RSLT_FGR(I), EQUP_RMK_CNTE
    --                                                                                                        , 'N', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUP || TT_RSLT_FGR(I), EQUP_RMK_CNTE)  --2017.12.06 김금덕 재검증필드확인해서 처리한다  R 재검증, N 최초전송 
    --                                 , EXRS_RMK_CNTE         = TT_RESULT_BIGO(I)
    --                                 , ANTC_REQR_DTM        = TO_DATE(IN_ANTC_REQR_DTM, 'YYYY-MM-DD HH24:MI:SS')       -- 소요시간
    --                                 , HNWR_EXRS_CNTE       = TT_HNWR_EXRS_CNTE(I)
    --                                 , LSH_DTM                 = SYSDATE     
    --                                 , LSH_PRGM_NM             = 'INTERFACE'
    --                                 , LSH_IP_ADDR             = SYS_CONTEXT('USERENV','IP_ADDRESS') 
    --                                 , SPEX_PRGR_STS_CD     = '2'                                                     -- 미검증상태   2018.02.07 처리
    --                             WHERE SPCM_NO              = T_SPCM_NO
    --                               AND EXM_CD                = TT_TST_CD(I)
    --                               AND HSP_TP_CD             = IN_HSP_TP_CD --병원구분
    --                               AND SPEX_PRGR_STS_CD <> '3'                                                        -- 최종검증
    --                               ;  
    --                                                                      
    --                             IF SQL%ROWCOUNT > 0 THEN
    --                                L_UPDATE_CNT := L_UPDATE_CNT + 1;
    --                            END IF;         
    --                        END; 
    --                           
    --                           -- 2018-11-01 
    --                        IF T_PANI_YN ='Y' OR TT_PANICOUT(I) ='Y' THEN
    --                            T_PANI_YN := 'Y';
    --                        END IF;
    --                        
    --                        IF T_DELT_YN ='Y' OR TT_DELTAOUT(I) ='Y' THEN
    --                            T_DELT_YN := 'Y';
    --                        END IF;
    --                             
    --                   END LOOP;  
    --                   
    --                   IF L_UPDATE_CNT = 0 THEN
    --                    IO_ERRYN  := 'Y';
    --                    IO_ERRMSG := 'PC_MSE_INTERFACE_SAVE 결과업데이트중 0건 발생. ERRCD = ' || TO_CHAR(SQLCODE);  
    --                   END IF;
    --                   
    --               END IF;
    --                     
    --               IF (IN_EQUIPTYPE = '021' OR IN_EQUIPTYPE = '022') THEN 
    --                   BEGIN -- 검체갯수 체크
    --                
    --                    SELECT COUNT(*)
    --                      INTO S_SPCM_CNT
    --                      FROM MSELMAID
    --                     WHERE SPCM_NO         = T_SPCM_NO
    --                       AND HSP_TP_CD    = IN_HSP_TP_CD
    --                       AND EXRS_CNTE IS NOT NULL                                        -- 2018.11.29 검사결과가 없는거는 제외   
    --                       ;      
    --                       
    --                    EXCEPTION
    --                          WHEN NO_DATA_FOUND THEN
    --                            IO_ERRYN  := 'Y';
    --                            IO_ERRMSG := '검체가 없습니다. = ' || TO_CHAR(SQLCODE);
    --                            RETURN;  
    --                END; 
    --            ELSE
    --                BEGIN -- 검체갯수 체크
    --                
    --                    SELECT COUNT(*)
    --                      INTO S_SPCM_CNT
    --                      FROM MSELMAID
    --                     WHERE SPCM_NO         = T_SPCM_NO
    --                       AND HSP_TP_CD    = IN_HSP_TP_CD
    --                       ;      
    --                       
    --                    EXCEPTION
    --                          WHEN NO_DATA_FOUND THEN
    --                            IO_ERRYN  := 'Y';
    --                            IO_ERRMSG := '검체가 없습니다. = ' || TO_CHAR(SQLCODE);
    --                            RETURN;  
    --                END; 
    --            END IF;
    --               
    --               -- 2018.11.01   
    --               IF (T_PANI_YN ='N' AND T_DELT_YN ='N' AND L_UPDATE_CNT = S_SPCM_CNT) THEN 
    --                   
    --                   BEGIN
    --                    UPDATE MSELMAID              -- 접수검사항목결과정보
    --                       SET SPEX_PRGR_STS_CD     = '3'                                                     
    --                     WHERE SPCM_NO              = T_SPCM_NO
    --                       AND HSP_TP_CD             = IN_HSP_TP_CD --병원구분
    --                       AND MED_EXM_CTG_CD         = T_MED_EXM_CTG_CD --'L20'
    --                       ;                                               
    --                END;
    --                                      
    --                   BEGIN
    --                        PC_MSE_STATUS( T_SPCM_NO 
    --                                      , T_MED_EXM_CTG_CD
    --                                      , T_MED_EXM_CTG_CD
    --                                      , NVL(IN_SPCID, 'HISMS')              -- HIS_STF_NO
    --                                      , T_WRKDTM
    --                                      , 'INTERFACE'                            -- HIS_PRGM_NM
    --                                      , SYS_CONTEXT('USERENV','IP_ADDRESS')    -- HIS_IP_ADDR
    --                                      , IN_HSP_TP_CD                        -- HIS_HSP_TP_CD
    --                                      , IO_ERRYN
    --                                      , IO_ERRMSG );
    --                
    --                    EXCEPTION
    --                         WHEN OTHERS THEN
    --                             IO_ERRYN  := 'Y';
    --                              IO_ERRMSG := '결과 저장중 상태 변경하는 함수(PC_MSE_STATUS) 호출... 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);
    --                               RETURN;
    --                   
    --                   END;
    --               END IF;                    -- 자동검증 로직 끝
                   
            
    --        ELSIF IN_EQUIPTYPE = '008' OR IN_EQUIPTYPE = '009' THEN        -- Hitachi7600 장비 L30분류
    --            IF  L_FLAG > 0 THEN             
    --                  FOR I IN 1 .. L_FLAG
    --                LOOP
    --                         BEGIN
    --                   
    --                            UPDATE MSELMAID              -- 접수검사항목결과정보
    --                               SET EXRS_CNTE             = TT_RSLT_FGR(I)                        -- 검사결과내용
    --                                 , RSLT_MDF_DTM          = T_WRKDTM                              -- 결과수정일시                              
    --                                 , DEXM_MDSC_EQUP_CD     = IN_EQUP--TT_EQUIPCD(I)                -- 진단검사의학장비코드
    --                                 , DLT_YN                = TT_DELTAOUT(I)                        -- 델타여부
    --                                 , PNC_YN                = TT_PANICOUT(I)                         -- 패닉여부
    --                                 , EQUP_RMK_CNTE          = DECODE(DECODE(DEXM_MDSC_EQUP_CD, '', 'N', 'R'), 'R', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUP || TT_RSLT_FGR(I), EQUP_RMK_CNTE
    --                                                                                                        , 'N', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUP || TT_RSLT_FGR(I), EQUP_RMK_CNTE)  --2017.12.06 김금덕 재검증필드확인해서 처리한다  R 재검증, N 최초전송 
    --                                 , EXRS_RMK_CNTE         = TT_RESULT_BIGO(I)
    --                                 , ANTC_REQR_DTM        = TO_DATE(IN_ANTC_REQR_DTM, 'YYYY-MM-DD HH24:MI:SS')       -- 소요시간
    --                                 , HNWR_EXRS_CNTE       = TT_HNWR_EXRS_CNTE(I)
    --                                 , LSH_DTM                 = SYSDATE     
    --                                 , LSH_PRGM_NM             = 'INTERFACE'
    --                                 , LSH_IP_ADDR             = SYS_CONTEXT('USERENV','IP_ADDRESS') 
    --                                 , SPEX_PRGR_STS_CD     = '2'                                                     -- 미검증상태   2018.02.07 처리
    --                             WHERE SPCM_NO              = T_SPCM_NO
    --                               AND EXM_CD                = TT_TST_CD(I)
    --                               AND HSP_TP_CD             = IN_HSP_TP_CD --병원구분
    --                               AND SPEX_PRGR_STS_CD <> '3'                                                        -- 최종검증
    --                               ;  
    --                                                                      
    --                             IF SQL%ROWCOUNT > 0 THEN
    --                                L_UPDATE_CNT := L_UPDATE_CNT + 1;
    --                            END IF;         
    --                        END; 
    --                           
    --                           -- 2018-11-01 
    --                        IF T_PANI_YN ='Y' OR TT_PANICOUT(I) ='Y' THEN
    --                            T_PANI_YN := 'Y';
    --                        END IF;
    --                        
    --                        IF T_DELT_YN ='Y' OR TT_DELTAOUT(I) ='Y' THEN
    --                            T_DELT_YN := 'Y';
    --                        END IF;
    --                             
    --                   END LOOP;  
    --                   
    --                   IF L_UPDATE_CNT = 0 THEN
    --                    IO_ERRYN  := 'Y';
    --                    IO_ERRMSG := 'PC_MSE_INTERFACE_SAVE 결과업데이트중 0건 발생. ERRCD = ' || TO_CHAR(SQLCODE);  
    --                   END IF;
    --                   
    --               END IF;
    --                  
    --               BEGIN -- 검체갯수 체크
    --            
    --                SELECT COUNT(*)
    --                  INTO S_SPCM_CNT
    --                  FROM MSELMAID
    --                 WHERE SPCM_NO                 = T_SPCM_NO
    --                   AND HSP_TP_CD            = IN_HSP_TP_CD 
    --                   AND MED_EXM_CTG_CD         = 'L30'  
    --                   ;      
    --                   
    --                EXCEPTION
    --                      WHEN NO_DATA_FOUND THEN
    --                        IO_ERRYN  := 'Y';
    --                        IO_ERRMSG := '검체가 없습니다. = ' || TO_CHAR(SQLCODE);
    --                        RETURN;  
    --            END;
    --                   
    --               -- L30 해당비고가 있을경우 자동검증 제외 2018.11.09         
    --               IF (INSTR(IN_REMK, '332') > 0) OR (INSTR(IN_REMK, '333') > 0) OR (INSTR(IN_REMK, '334') > 0) THEN
    --                   L30_REMK_YN := 'Y';    
    --               END IF;
    --                                                        
    --               -- 2018.11.01   
    --               IF (T_PANI_YN ='N' AND T_DELT_YN ='N' AND L_UPDATE_CNT = S_SPCM_CNT AND L30_REMK_YN = 'N') THEN 
    --                   
    --                   BEGIN
    --                    UPDATE MSELMAID              -- 접수검사항목결과정보
    --                       SET SPEX_PRGR_STS_CD     = '3'                                                     -- 미검증상태   2018.02.07 처리
    --                     WHERE SPCM_NO              = T_SPCM_NO
    --                       AND HSP_TP_CD             = IN_HSP_TP_CD --병원구분
    --                       AND MED_EXM_CTG_CD         = 'L30'
    --                       ;                                               
    --                END;
    --                                      
    --                   -- TLA 없음
    ----                   BEGIN
    ----                    PC_MSE_STATUS_TLA( T_SPCM_NO 
    ----                                      , 'L30'
    ----                                      , NVL(IN_SPCID, 'HISMS')              -- HIS_STF_NO
    ----                                      , T_WRKDTM
    ----                                      , 'INTERFACE'                            -- HIS_PRGM_NM
    ----                                      , SYS_CONTEXT('USERENV','IP_ADDRESS')    -- HIS_IP_ADDR
    ----                                      , IN_HSP_TP_CD                        -- HIS_HSP_TP_CD
    ----                                      , IO_ERRYN
    ----                                      , IO_ERRMSG );
    ----                
    ----                    EXCEPTION
    ----                         WHEN OTHERS THEN
    ----                             IO_ERRYN  := 'Y';
    ----                              IO_ERRMSG := '결과 저장중 상태 변경하는 함수(PC_MSE_STATUS_TLA) 호출... 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);
    ----                               RETURN;
    ----                   
    ----                   END;
    --               END IF;
                   
                        
--            ELSIF IN_EQUIPTYPE = '069' OR IN_EQUIPTYPE = '070'  OR IN_EQUIPTYPE = '071' OR IN_EQUIPTYPE = '072' OR IN_EQUIPTYPE = '073'  OR IN_EQUIPTYPE = '074'
--               OR IN_EQUIPTYPE = '075' THEN
--               IF  L_FLAG > 0 THEN             
--                      FOR I IN 1 .. L_FLAG
--                    LOOP
--                             BEGIN
--                             
--                                UPDATE MSELMAID  -- 접수검사항목결과정보
--                                   SET EXRS_CNTE             = TT_RSLT_FGR(I)                    -- 검사결과내용
--                                     , RSLT_MDF_DTM          = DECODE(T_FLAG1, 'Y', TO_DATE(IN_EXM_DT, 'YYYY-MM-DD HH24:MI:SS'),  T_WRKDTM)                          -- 결과수정일시
--                                     , LST_RSLT_VRFC_DTM    = DECODE(T_FLAG1, 'Y', TO_DATE(IN_EXM_DT, 'YYYY-MM-DD HH24:MI:SS'),  T_WRKDTM)                          -- 최종결과검증일시    2018.04.25
--                                     , SPEX_PRGR_STS_CD       = '3'
--                                     , RSLT_BRFG_YN          = 'Y'                               -- 결과보고여부
--                                     , DEXM_MDSC_EQUP_CD     = IN_EQUP--TT_EQUIPCD(I)            -- 진단검사의학장비코드
--                                     , DLT_YN                = TT_DELTAOUT(I)                    -- 델타여부
--                                     , PNC_YN                = TT_PANICOUT(I)                    -- 패닉여부
--                                     , CVR_YN                = TT_CVROUT  (I)                    -- CVR여부
--                                     
--                                     , EQUP_RMK_CNTE          = DECODE(DECODE(DEXM_MDSC_EQUP_CD, '', 'N', 'R'), 'R', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUP || TT_RSLT_FGR(I), EQUP_RMK_CNTE
--                                                                                                            , 'N', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUP || TT_RSLT_FGR(I), EQUP_RMK_CNTE)  --2017.12.06 김금덕 재검증필드확인해서 처리한다  R 재검증, N 최초전송 
--                                     , EXRS_RMK_CNTE         = TT_RESULT_BIGO(I)
--                                     , ANTC_REQR_DTM        = TO_DATE(IN_ANTC_REQR_DTM, 'YYYY-MM-DD HH24:MI:SS') --DECODE(IN_ANTC_REQR_DTM, '', NULL, TO_DATE(IN_ANTC_REQR_DTM, 'YYYYMMDDHH24MISS')) --IN_ANTC_REQR_DTM   --  , ANTC_REQR_DTM        = DECODE(IN_ANTC_REQR_DTM, '', NULL, IN_ANTC_REQR_DTM) --IN_ANTC_REQR_DTM                       -- 소요시간
--                                     
--                                     , HNWR_EXRS_CNTE       = TT_HNWR_EXRS_CNTE(I)
--                                     , LSH_DTM                 = SYSDATE     --2015-06-24 곽수미 추가
--                                     , LSH_PRGM_NM             = 'INTERFACE'
--                                     , LSH_IP_ADDR             = SYS_CONTEXT('USERENV','IP_ADDRESS') 
--                                 WHERE SPCM_NO              = T_SPCM_NO
--                                   AND EXM_CD                = TT_TST_CD(I)
--                                   AND HSP_TP_CD             = IN_HSP_TP_CD     -- 병원구분
--                                   AND SPEX_PRGR_STS_CD    <> '3'            -- 최종검증 안된것만
--                                   ;  
--    
--                                 IF SQL%ROWCOUNT > 0 THEN
--                                    L_UPDATE_CNT := L_UPDATE_CNT + 1;
--                                END IF;
--                                         
--                            END;       
--                            
--                            BEGIN
--                                
--                                UPDATE MSELMCED
--                                   SET EXM_PRGR_STS_CD      = 'N'
--                                     , BRFG_DTM             = DECODE(T_FLAG1, 'Y', TO_DATE(IN_EXM_DT, 'YYYY-MM-DD HH24:MI:SS'),  SYSDATE) -- ABGA 인경우 
--                                     , LSH_DTM                 = DECODE(T_FLAG1, 'Y', TO_DATE(IN_EXM_DT, 'YYYY-MM-DD HH24:MI:SS'),  SYSDATE) -- ABGA 인경우     
--                                     , LSH_PRGM_NM             = 'INTERFACE' 
--                                     , LSH_IP_ADDR             = SYS_CONTEXT('USERENV','IP_ADDRESS') 
--                                 WHERE SPCM_NO              = T_SPCM_NO
--                                   AND HSP_TP_CD             = IN_HSP_TP_CD     -- 병원구분 
--                                   AND EXM_PRGR_STS_CD      <> 'N'          -- 결과보고 안된것만    
--                                   ;
--                            END;
--                            
--                            -- 처방테이블 저장
--                            BEGIN
--                              UPDATE /*+ XSUP.PC_MSE_EXM_RESULTUPDATE */
--                                     MOOOREXM
--                                 SET EXM_PRGR_STS_CD = 'N'
--                                   , BRFG_DTM        = DECODE(T_FLAG1, 'Y', TO_DATE(IN_EXM_DT, 'YYYY-MM-DD HH24:MI:SS'),  SYSDATE)        -- ABGA 인경우 
--                                   , BRFG_STF_NO     = NVL(IN_SPCID, 'SSSUP07')
--                                   , LSH_STF_NO      = NVL(IN_SPCID, 'SSSUP07')
--                                   , LSH_DTM         = SYSDATE
--                                   , LSH_PRGM_NM     = 'INTERFACE'
--                                   , LSH_IP_ADDR     = SYS_CONTEXT('USERENV','IP_ADDRESS')  
--                               WHERE SPCM_PTHL_NO = T_SPCM_NO
--                                 AND ODDSC_TP_CD  = 'C'  
--                                 AND HSP_TP_CD    = IN_HSP_TP_CD
--                                 AND EXM_PRGR_STS_CD <> 'N'                    -- 결과보고 안된것만
--                                 ;
--                        
--                              EXCEPTION
--                                  WHEN OTHERS THEN
--                                       IO_ERRYN  := 'Y';
--                                       IO_ERRMSG := '오더내역 UPDATE 중 에러 발생 ERRCODE = ' || TO_CHAR(T_SPCM_NO);
--                                       RETURN;
--                           END;
--    
--                       END LOOP;  
--                       
--                       IF L_UPDATE_CNT = 0 THEN
--                        IO_ERRYN  := 'Y';
--                        IO_ERRMSG := 'PC_MSE_INTERFACE_SAVE 결과업데이트중 -- IN_EQUIPTYPE = 069 -- 0건 발생. ERRCD = ' || TO_CHAR(SQLCODE);  
--                       END IF;
--                       
--                   END IF;

               
            -- 혈액은행 검사결과 
            -- 혈액은행 : 장비 마스터 테이블에서 TH2_RMK_CNTE 혈액은행 장비 사용
            
            -- 2021.12.13 홍승표 --> 아래 IN_EQUIPTYPE = '056' 라인은 주석처리함.
            --                      별도로 장비코드 951 결과로직으로 변경한다.
            
--            ELSIF IN_EQUIPTYPE = '951'  THEN
            ELSIF T_EQUIP_RMK_CNTE = '혈액은행' THEN           
                
                IF  L_FLAG > 0 THEN     
                                    
                    FOR I IN 1 .. L_FLAG
                    LOOP
                         
                             BEGIN                             
                                
                                 BEGIN
                                    SELECT A.PT_NO
                                         , A.EXRM_EXM_CTG_CD
                                         , A.WK_UNIT_CD    
                                         , NVL(A.RSLT_BRFG_YN, 'N')
                                         , B.DFLT_EXRS_CNTE
                                      INTO T_PT_NO
                                         , T_EXRM_EXM_CTG_CD
                                         , T_WK_UNIT_CD
                                         , T_RSLT_BRFG_YN
                                         , T_DFLT_EXRS_CNTE
                                      FROM MSELMAID A
                                         , MSELMEBM B
                                     WHERE A.HSP_TP_CD = IN_HSP_TP_CD
                                       AND A.SPCM_NO   = T_SPCM_NO
                                       AND A.EXM_CD    = TT_TST_CD(I)
                                       AND A.HSP_TP_CD = B.HSP_TP_CD
                                       AND A.EXM_CD    = B.EXM_CD
                                       AND ROWNUM = 1;   
    
                                    T_NO_DATA_FOUND := 'N';
                                    
                                    EXCEPTION
                                        WHEN NO_DATA_FOUND THEN  
                                            --저장되어 있는 검사결과가 없을수도 있음
                                            --장비에서 검체번호에 해당하지 않는 코드도 추가로 넘겨줌.
                                            T_NO_DATA_FOUND := 'Y';
                                        WHEN OTHERS THEN
                                            IO_ERRYN  := 'Y';
                                            IO_ERRMSG := '검사결과 정보 조회중 오류가 발생했습니다. [' || T_SPCM_NO || ' : ' || TT_TST_CD(I) || ']' || ' ERROR : ' || SQLERRM;
                                            RETURN;  
                                     
                                 END;                                        
                                    
--                                         RAISE_APPLICATION_ERROR(-20001, '\' ||  TT_TST_CD(I) || '\' ) ;  
    
                                 -- 이력저장
                                 -- 이력저장은 장비에서 검체번호에 해당하지 않는 코드도 추가로 넘겨주기 때문에 결과와 무관하게 이력에 저장함.
                                 PC_MSE_HISTORY_SAVE
                                                 ( IN_EQUIPTYPE -- IN_EQUP 
                                                 , T_HISTORY_REG_SEQ
                                                 , TT_TST_CD(I)
                                                 , T_PT_NO
                                                 , T_SPCM_NO            
                                                 
                                                 , TT_RSLT_FGR(I)     -- 검사결과
                                                 , TT_REMK(I)         -- 검체비고내용
                                                 , TT_RESULT_BIGO(I)  -- 인터페이스비고                                                      
                                                                  
                                                 , IN_SPCID--'IF'
                                                 , IN_HSP_TP_CD
                                                 , 'INTERFACE'
                                                 , SYS_CONTEXT('USERENV','IP_ADDRESS')
                                                 
                                                 , IO_ERRYN
                                                 , IO_ERRMSG
                                                 );
                                 
                                 
                                 IF IO_ERRYN = 'Y' THEN
                                     RETURN;
                                 END IF;

                                 IF T_NO_DATA_FOUND = 'N' AND T_RSLT_BRFG_YN != 'Y' THEN
                                       
                                       IF TT_TST_CD(I) = 'BBG06' THEN          --ANTIBODY 경우 1차임시   
                                       
                                               PC_MSE_BLOOD_RSLT_SAVE
                                                         ( 'T'                                        -- 임시
                                                          , T_PT_NO                                   -- 환자번호
                                                          , T_SPCM_NO
                                                          , T_EXRM_EXM_CTG_CD                         -- IN_EXM_CTG_CD       IN      MSELMAID.EXRM_EXM_CTG_CD%TYPE
                                                          , T_WK_UNIT_CD                              -- IN_WK_UNIT_CD       IN      MSELMAID.WK_UNIT_CD%TYPE
                                                          , TT_TST_CD(I)                              -- IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                                                          , ''                                        -- IN_MIDL_BRFG_CNTE   IN      MSELMAID.MIDL_BRFG_CNTE%TYPE
                                                          
                                                          -- 장비결과값이 NULL이면, Default검사결과 저장
                                                          , NVL(TT_RSLT_FGR(I), T_DFLT_EXRS_CNTE)     -- IN_EXRS_CNTE        IN      MSELMAID.EXRS_CNTE%TYPE
                                        
                                                          , ''                                        -- IN_RMK_CNTE         IN      MSELMCED.RMK_CNTE%TYPE
                                                          , TT_REMK(I)                                -- IN_LMQC_RMK_CNTE    IN      MSELMCED.LMQC_RMK_CNTE%TYPE
                                                          , TT_RESULT_BIGO(I)                         -- IN_EXRS_RMK_CNTE    IN      MSELMAID.EXRS_RMK_CNTE%TYPE
                                                          , ''                                        -- IN_EXRM_RMK_CNTE    IN      MSELMAID.EXRM_RMK_CNTE%TYPE
                                                         
                                                          , TT_DELTAOUT(I)                            -- IN      MSELMAID.DLT_YN%TYPE
                                                          , TT_PANICOUT(I)                            -- IN      MSELMAID.PNC_YN%TYPE
                                                          , TT_CVROUT  (I)                            -- IN      MSELMAID.CVR_YN%TYPE
                                                          
                                                          -- 장비정보
                                                          , IN_EQUIPTYPE -- IN_EQUP 
                                                          , T_HISTORY_REG_SEQ
                                                         
                                                          , IN_SPCID--'IF'                                      -- HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                                                          , IN_HSP_TP_CD                              -- HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                                                          , 'INTERFACE'                               -- HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                                                          , SYS_CONTEXT('USERENV','IP_ADDRESS')       -- HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE
                                                         
                                                          , IO_ERRYN -- IO_ERR_YN           IN OUT  VARCHAR2
                                                          , IO_ERRMSG --IO_ERR_MSG          IN OUT  VARCHAR2 
                                                         );
                                 
                                            IF IO_ERRYN = 'Y' THEN
                                                RETURN;
                                            END IF;    
                                            
                                            -- 장비정보업데이트
                                            PC_MSE_UPDATE_EQUP_INFO
                                            (
                                              T_SPCM_NO 
                                            , TT_TST_CD(I)
                                            , TT_RSLT_FGR(I) 
                                            
                                            , IN_EQUIPTYPE -- IN_EQUP
                                            , TT_RESULT_BIGO(I)
                                            , TO_DATE(IN_ANTC_REQR_DTM, 'YYYYMMDDHH24MISS')
                                            , '' --TT_HNWR_EXRS_CNTE(I)
                                            
                                            , IN_SPCID --'IF'                                      
                                            , IN_HSP_TP_CD                              
                                            , 'INTERFACE'                               
                                            , SYS_CONTEXT('USERENV','IP_ADDRESS') 
                                            , IO_ERRYN
                                            , IO_ERRMSG      
                                            );         
                                                                                          
                                            
                                       ELSE 
                                                                                       
                                            --결과 초기화
                                            IF TT_TST_CD(I) = 'BBG01' THEN
                                                XSUP.PKG_MSE_LM_EXAMRSLT.INIT
                                                         (  T_SPCM_NO
                                                          , 'BBG01'                                   -- IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                                                          , IN_SPCID --'IF'                                      -- HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                                                          , IN_HSP_TP_CD                             -- HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                                                          , 'INTERFACE'                               -- HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                                                          , SYS_CONTEXT('USERENV','IP_ADDRESS')       -- HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE
                                                         
                                                          , IO_ERRYN -- IO_ERR_YN           IN OUT  VARCHAR2
                                                          , IO_ERRMSG --IO_ERR_MSG          IN OUT  VARCHAR2 
                                                         );
                                    
                                                IF IO_ERRYN = 'Y' THEN
                                                    RETURN;
                                                END IF;    
                                
                                                XSUP.PKG_MSE_LM_EXAMRSLT.INIT
                                                         (  T_SPCM_NO
                                                          , 'BBG02'                                   -- IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                                                          , IN_SPCID --'IF'                                      -- HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                                                          , IN_HSP_TP_CD                             -- HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                                                          , 'INTERFACE'                               -- HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                                                          , SYS_CONTEXT('USERENV','IP_ADDRESS')       -- HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE
                                                         
                                                          , IO_ERRYN -- IO_ERR_YN           IN OUT  VARCHAR2
                                                          , IO_ERRMSG --IO_ERR_MSG          IN OUT  VARCHAR2 
                                                         );
                                    
                                                IF IO_ERRYN = 'Y' THEN
                                                    RETURN;
                                                END IF;                                                                                                   
                                            END IF;                            
                                            
                                            -- 혈액결과 저장 - 1차 확정
                                            PC_MSE_BLOOD_RSLT_SAVE
                                                         ( 'C'                                        -- 임시
                                                          , T_PT_NO                                   -- 환자번호
                                                          , T_SPCM_NO
                                                          , T_EXRM_EXM_CTG_CD                         -- IN_EXM_CTG_CD       IN      MSELMAID.EXRM_EXM_CTG_CD%TYPE
                                                          , T_WK_UNIT_CD                              -- IN_WK_UNIT_CD       IN      MSELMAID.WK_UNIT_CD%TYPE
                                                          , TT_TST_CD(I)                              -- IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                                                          , ''                                        -- IN_MIDL_BRFG_CNTE   IN      MSELMAID.MIDL_BRFG_CNTE%TYPE
                                                          
                                                          -- 장비결과값이 NULL이면, Default검사결과 저장
                                                          , NVL(TT_RSLT_FGR(I), T_DFLT_EXRS_CNTE)     -- IN_EXRS_CNTE        IN      MSELMAID.EXRS_CNTE%TYPE
                                        
                                                          , ''                                        -- IN_RMK_CNTE         IN      MSELMCED.RMK_CNTE%TYPE
                                                          , TT_REMK(I)                                -- IN_LMQC_RMK_CNTE    IN      MSELMCED.LMQC_RMK_CNTE%TYPE
                                                          , TT_RESULT_BIGO(I)                         -- IN_EXRS_RMK_CNTE    IN      MSELMAID.EXRS_RMK_CNTE%TYPE
                                                          , ''                                        -- IN_EXRM_RMK_CNTE    IN      MSELMAID.EXRM_RMK_CNTE%TYPE
                                                         
                                                          , TT_DELTAOUT(I)                            -- IN      MSELMAID.DLT_YN%TYPE
                                                          , TT_PANICOUT(I)                            -- IN      MSELMAID.PNC_YN%TYPE
                                                          , TT_CVROUT  (I)                            -- IN      MSELMAID.CVR_YN%TYPE
                                                          
                                                          -- 장비정보
                                                          , IN_EQUIPTYPE -- IN_EQUP 
                                                          , T_HISTORY_REG_SEQ
                                                         
                                                          , IN_SPCID --'IF'                                      -- HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                                                          , IN_HSP_TP_CD                              -- HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                                                          , 'INTERFACE'                               -- HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                                                          , SYS_CONTEXT('USERENV','IP_ADDRESS')       -- HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE
                                                         
                                                          , IO_ERRYN -- IO_ERR_YN           IN OUT  VARCHAR2
                                                          , IO_ERRMSG --IO_ERR_MSG          IN OUT  VARCHAR2 
                                                         );
                                 
                                            IF IO_ERRYN = 'Y' THEN
                                                RETURN;
                                            END IF;
                                                                                   
    
                                            -- 혈액결과 저장 - 2차 임시
                                            PC_MSE_BLOOD_RSLT_SAVE
                                                         ( 'T'                                        -- 임시
                                                          , T_PT_NO                                   -- 환자번호
                                                          , T_SPCM_NO
                                                          , T_EXRM_EXM_CTG_CD                         -- IN_EXM_CTG_CD       IN      MSELMAID.EXRM_EXM_CTG_CD%TYPE
                                                          , T_WK_UNIT_CD                              -- IN_WK_UNIT_CD       IN      MSELMAID.WK_UNIT_CD%TYPE
                                                          , TT_TST_CD(I)                              -- IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                                                          , ''                                        -- IN_MIDL_BRFG_CNTE   IN      MSELMAID.MIDL_BRFG_CNTE%TYPE
                                                          
                                                          -- 장비결과값이 NULL이면, Default검사결과 저장
                                                          , NVL(TT_RSLT_FGR(I), T_DFLT_EXRS_CNTE)     -- IN_EXRS_CNTE        IN      MSELMAID.EXRS_CNTE%TYPE
                                        
                                                          , ''                                        -- IN_RMK_CNTE         IN      MSELMCED.RMK_CNTE%TYPE
                                                          , TT_REMK(I)                                -- IN_LMQC_RMK_CNTE    IN      MSELMCED.LMQC_RMK_CNTE%TYPE
                                                          , TT_RESULT_BIGO(I)                         -- IN_EXRS_RMK_CNTE    IN      MSELMAID.EXRS_RMK_CNTE%TYPE
                                                          , ''                                        -- IN_EXRM_RMK_CNTE    IN      MSELMAID.EXRM_RMK_CNTE%TYPE
                                                         
                                                          , TT_DELTAOUT(I)                            -- IN      MSELMAID.DLT_YN%TYPE
                                                          , TT_PANICOUT(I)                            -- IN      MSELMAID.PNC_YN%TYPE
                                                          , TT_CVROUT  (I)                            -- IN      MSELMAID.CVR_YN%TYPE
                                                          
                                                          -- 장비정보
                                                          , IN_EQUIPTYPE -- IN_EQUP 
                                                          , T_HISTORY_REG_SEQ
                                                         
                                                          , IN_SPCID --'IF'                                      -- HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                                                          , IN_HSP_TP_CD                              -- HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                                                          , 'INTERFACE'                               -- HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                                                          , SYS_CONTEXT('USERENV','IP_ADDRESS')       -- HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE
                                                         
                                                          , IO_ERRYN -- IO_ERR_YN           IN OUT  VARCHAR2
                                                          , IO_ERRMSG --IO_ERR_MSG          IN OUT  VARCHAR2 
                                                         );
                                 
                                            IF IO_ERRYN = 'Y' THEN
                                                RETURN;
                                            END IF;  
                                            
                                            -- 장비정보업데이트
                                            PC_MSE_UPDATE_EQUP_INFO
                                            (
                                              T_SPCM_NO 
                                            , TT_TST_CD(I)
                                            , TT_RSLT_FGR(I) 
                                            
                                            , IN_EQUIPTYPE -- IN_EQUP
                                            , TT_RESULT_BIGO(I)
                                            , TO_DATE(IN_ANTC_REQR_DTM, 'YYYYMMDDHH24MISS')
                                            , '' --TT_HNWR_EXRS_CNTE(I)
                                            
                                            , IN_SPCID --'IF'                                      
                                            , IN_HSP_TP_CD                              
                                            , 'INTERFACE'                               
                                            , SYS_CONTEXT('USERENV','IP_ADDRESS') 
                                            , IO_ERRYN
                                            , IO_ERRMSG      
                                            );                                            
                                       
                                       END IF;   --TT_TST_CD(I) = 'BBG06' THEN                                                                                                                            
                                         
                                 END IF; -- IF T_RSLT_BRFG_YN != 'Y' THEN    
                            
                            END;
                            

                       END LOOP;
                   END IF;
    
            
   
                       
--            ELSE IF IN_EQUIPTYPE = '9999' THEN                     --    결과 UPDATE  장비    002  START   
--                 IF  L_FLAG > 0 THEN             
--                      FOR I IN 1 .. L_FLAG
--                        LOOP
--                             IF IN_EQUIPTYPE = '003' OR IN_EQUIPTYPE = 'F' THEN                      
--                                BEGIN
--            
--                                    UPDATE MSELMAID  -- 접수검사항목결과정보
--                                       SET EXRS_CNTE         = TT_RSLT_FGR(I)
--                                        --,RSLT_MDF_DTM      = TO_CHAR(T_WRKDTM, 'YYYYMMDDHH24MI')
--                                         , RSLT_MDF_DTM      = T_WRKDTM
--                                      --    ,EQUP_SND_CNTE     = SUBSTR(TT_ERRFLAG(I), 1, 10)
--            
--                                      --    ,SPEX_PRGR_STS_CD   = DECODE(FT_SL_EQU_TSTCD_STAT(TT_TST_CD(I)), 'Y', '2', DECODE(TT_PANICOUT(I) || TT_DELTAOUT(I), 'NN', '3', '2')) --2011.09.20 방수석 특정검사 자동검증 해제기능 신설
--            
--                                      --    ,DEXM_MDSC_EQUP_CD = TT_EQUIPCD(I)
--                                      --    ,DLT_YN            = TT_DELTAOUT(I)
--                                      --    ,PNC_YN            = TT_PANICOUT(I)
--                                         , EQUP_RMK_CNTE  = DECODE(IN_EQUIPTYPE, 'F', EQUP_RMK_CNTE || ',' || TO_CHAR(T_WRKDTM,'MMDDHH24MI') || IN_EQUIPTYPE || TT_RESULT(I), EQUP_RMK_CNTE)  --2009.04.10 방수석 추가 장비인터페이스시 로그를 남긴다.  
--                                         , LSH_DTM         = SYSDATE     --2015-06-24 곽수미 추가   
--                                         , LSH_PRGM_NM     = 'INTERFACE'
--                                         , LSH_IP_ADDR     = SYS_CONTEXT('USERENV','IP_ADDRESS')
--                                     WHERE SPCM_NO  =  T_SPCM_NO
--                                       AND EXM_CD    = TT_TST_CD(I)
--                                       AND HSP_TP_CD = IN_HSP_TP_CD --병원구분
--                                       ;      
--                                       
--                                    EXCEPTION
--                                          WHEN OTHERS THEN
--                                             IO_ERRYN  := 'Y';
--                                             IO_ERRMSG := 'PC_MSE_INTERFACE_SAVE -- IN_EQUIPTYPE = 9999 -- 결과업데이트중 오류 발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                                             RETURN;
--                                END;      
--                            END IF;
--                        END LOOP;
--                       END IF;     
--                                         
--                END IF;                                                     --    결과 UPDATE  장비    002 END 
           
            END IF;                                                        --    결과 UPDATE  장비    001 END 

            
            ---------------------------------------------------------------------------------------------------------------------------------------
            -- 2022-04-27 SCS : 커스텀 결과 저장        
            ---------------------------------------------------------------------------------------------------------------------------------------
            FOR I IN 1 .. L_FLAG
            LOOP                                                                                               
                                
                BEGIN
                    SELECT TH1_RMK_CNTE
                      INTO T_EXM_GRP_CD
                      FROM MSELMSID
                     WHERE HSP_TP_CD    = IN_HSP_TP_CD
                       AND LCLS_COMN_CD = 'IF_CUSTOM_RSLT'
                       AND SCLS_COMN_CD = TT_TST_CD(I) 
                    ;                    
                    EXCEPTION
                        WHEN OTHERS THEN
                            T_EXM_GRP_CD := '';                       
                END;
                
                IF T_EXM_GRP_CD IS NOT NULL THEN
                
                    -- LSG43
                    -- RI800040:QWERTYUU|RI800070:123456789Q|
                    FOR RSLT IN
                    (   
                        SELECT NVL(TRIM(REGEXP_SUBSTR( TT_RSLT_FGR(I), '[^|]+', 1, LEVEL) ), 'X') RSLT_ITEM
                          FROM DUAL
                       CONNECT BY LEVEL <= REGEXP_COUNT ( TT_RSLT_FGR(I), '|' ) + 1 
                       
                    ) LOOP                    
                    
                            IF RSLT.RSLT_ITEM != 'X' THEN
                            
                                T_RSLT_ITEM_CD := SUBSTR(RSLT.RSLT_ITEM, 1, INSTR(RSLT.RSLT_ITEM, ':') - 1);
                                T_RSLT_CNTE    := SUBSTR(RSLT.RSLT_ITEM, INSTR(RSLT.RSLT_ITEM, ':') + 1);
                                
--                                RAISE_APPLICATION_ERROR(-20553, TT_TST_CD(I) || '-' || RSLT.RSLT_ITEM || '<--->' || CHR(10) || T_RSLT_ITEM_CD ||  '/' || T_RSLT_CNTE ) ;

                                FOR DR IN
                                (   
                                    SELECT TH5_RMK_CNTE IF_TARGET
                                         , EXM_GRP_CD
                                         , RSLT_ITEM_CD
                                         , FOM_SEQ
                                      FROM MSELMRSM M
                                     WHERE HSP_TP_CD  = IN_HSP_TP_CD 
                                       AND EXM_GRP_CD = T_EXM_GRP_CD
                                       AND TH5_RMK_CNTE IS NOT NULL  
                                       AND FOM_SEQ = (SELECT MAX(FOM_SEQ)
                                                        FROM MSELMRSM
                                                       WHERE HSP_TP_CD  = M.HSP_TP_CD
                                                         AND EXM_GRP_CD = M.EXM_GRP_CD
                                                     )                           
                                       AND RSLT_ITEM_CD = T_RSLT_ITEM_CD
                                       
                                ) LOOP                                    
                                    
--                                    IF DR.IF_TARGET = 'IF_EXRS_CNTE' THEN -- 결과
--                                        T_EXRS_CNTE := TT_RSLT_FGR(I);          
--                                    ELSIF DR.IF_TARGET = 'IF_EXRS_RMK_CNTE' THEN -- 결과비고
--                                        T_EXRS_CNTE := TT_RESULT_BIGO(I);          
--                                    END IF;
                                    
--                                    RAISE_APPLICATION_ERROR(-20553, T_SPCM_NO || '-' || TT_TST_CD(I)|| '/////////////' || CHR(10) || DR.EXM_GRP_CD ||  '/' || DR.RSLT_ITEM_CD ||  '/' || T_RSLT_CNTE ) ;
                                    
                                    
                                    PKG_MSE_LM_EXAMRSLT.SAVE_CUSTOMRSLT
                                    ( 
                                      T_SPCM_NO
                                    , TT_TST_CD(I)
                                    
                                    , DR.EXM_GRP_CD
                                    , DR.RSLT_ITEM_CD
                                    , T_RSLT_CNTE -- T_EXRS_CNTE
                                    
                                    , '1'            
                                    , DR.FOM_SEQ
                                    , IN_SPCID
                                    , IN_HSP_TP_CD
                                    , 'INTERFACE'
                                    , SYS_CONTEXT('USERENV','IP_ADDRESS')
                                    
                                    , IO_ERRYN
                                    , IO_ERRMSG
                                    );
                                               
--                                    IF IO_ERRYN = 'Y' THEN
--                                        IO_ERRYN  := 'Y';
--                                        IO_ERRMSG := 'PKG_MSE_LM_EXAMRSLT.SAVE_CUSTOMRSLT -- ERRCD = ' || TO_CHAR(SQLCODE) || CHR(13) || IO_ERRMSG;
--                                        RETURN;
--                                    END IF;
                                    
                                END LOOP;      
                            
                            END IF;
                            
                    END LOOP;                                
                                    
                END IF;

            END LOOP;
                                                                                                     
                   
            ---------------------------------------------------------------------------------------------------------------------------------------
            --- 장비비고내용 
            ---------------------------------------------------------------------------------------------------------------------------------------  
            BEGIN      
                 
                -- 장비비고내용(다른장비로 저장시 비고내용누락방지)
                UPDATE MSELMCED
                   SET LMQC_RMK_CNTE = DECODE(TRIM(IN_REMK), '', LMQC_RMK_CNTE, TRIM(IN_REMK))
    --               SET LMQC_RMK_CNTE = IN_REMK
    --               SET LMQC_RMK_CNTE = DECODE(LMQC_RMK_CNTE, '', IN_REMK, LMQC_RMK_CNTE || IN_REMK)            
                 WHERE SPCM_NO = T_SPCM_NO
                   AND HSP_TP_CD = IN_HSP_TP_CD 
                   ;                 
                 EXCEPTION
                     WHEN OTHERS THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'PC_MSE_INTERFACE_SAVE 장비비고내용 업데이트중 오류 발생. ERRCD = ' || TO_CHAR(SQLCODE);
                        RETURN;
            END;                 


            
            ---------------------------------------------------------------------------------------------------------------------------------------
            --- 혈액학검사실 일반혈액검사(CBC) 자동검증
            -- Description : 혈액학검사실 일반혈액검사(CBC) 자동검증
            --               1. 자동검증 코드
            --                  LHGX1 CBC & D/C
            --                  LHGX2 CBC & D/C & Reticulocyte count
            --                  LHGX5 CBC (혈구수계산)
            --               2. 자동검증 기준 
            --                   LHG10, LHG11을 제외한 모든 항목의 검사결과에 Flag(Delta, Panic, Critical, AMR, Range) 없음
            ---------------------------------------------------------------------------------------------------------------------------------------  
            BEGIN      
                    PC_MSE_HMTY_CBC_AUTO_VRFC
                    ( 'C' -- T:임시, C:확정
                    ,  IN_SPCM_NO   
                    
                    , 'IF'
                    , SYSDATE
                    , IN_HSP_TP_CD
                    , 'INTERFACE' 
                    , SYS_CONTEXT('USERENV','IP_ADDRESS') 
                     
                    , IO_ERRYN
                    , IO_ERRMSG 
                    );                              
            END;       
                        


--
--                                  
--        -- Osmolarity 자동계산 추가
--        BEGIN      
--             PC_MSE_OSMOLARITY_AUTO_RSLT_SAVE
--                             ( T_SPCM_NO            
--                             , 'IF'
--                             , IN_HSP_TP_CD
--                             , 'INTERFACE'
--                             , SYS_CONTEXT('USERENV','IP_ADDRESS')                                 
--                             , IO_ERRYN
--                             , IO_ERRMSG
--                             );                 
--             
--             IF IO_ERRYN = 'Y' THEN
--                IO_ERRYN  := 'Y';
--                IO_ERRMSG := 'PC_MSE_OSMOLARITY_AUTO_RSLT_SAVE 자동계산 업데이트중 오류 발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                RETURN;
--             END IF;
--        END;       
        


                 
        -- 정도관리결과저장 (충북대 사용안함)
    --    IF  L_FLAG > 0 AND SUBSTR(T_SPCM_NO, 7, 1) = '9' THEN    --  처방갯수만큼 FOR 문을 돌림   정도관리는 검체번호 7번째가 9로시작
    --        FOR I IN 1 .. L_FLAG
    --        LOOP                   
    --             BEGIN
    --                 UPDATE MSELMQRD  -- 접수검사항목결과정보
    --                    SET EXRS_CNTE       = TT_RSLT_FGR(I)
    --                      , LSH_DTM         = SYSDATE     --2015-06-24 곽수미 추가   
    --                      , LSH_PRGM_NM     = 'INTERFACE'
    --                      , LSH_IP_ADDR     = SYS_CONTEXT('USERENV','IP_ADDRESS')
    --                  WHERE BRCD_SPCM_NO     = IN_SPCM_NO
    --                    AND EXM_CD            = TT_TST_CD(I)
    --                    AND HSP_TP_CD        = IN_HSP_TP_CD --병원구분
    --                    ;      
    --                    
    --                 EXCEPTION
    --                       WHEN OTHERS THEN
    --                          IO_ERRYN  := 'Y';
    --                          IO_ERRMSG := 'PC_MSE_INTERFACE_SAVE 정도관리 결과업데이트중 오류 발생. ERRCD = ' || TO_CHAR(SQLCODE);
    --                          RETURN;
    --            END;      
    --        END LOOP;               
    --    END IF;
        
             --  (ABGA) 자동 내부정도관리
    --    IF IN_EQUIPTYPE = '001' THEN                              --  자동 내부정도관리    001  START         
    --            IF SUBSTR(IN_SPCID,1,5) = '99999' THEN
    --                IF  L_FLAG > 0 THEN
    --                    FOR I IN 1 .. L_FLAG
    --                    LOOP
    --                         BEGIN
    --
    --                             INSERT INTO MSELMQRD --정도관리결과정보
    --                             (
    --                                   DEXM_MDSC_EQUP_CD
    --                                 , LOT_NO
    --                                 , FSR_DTM
    --                                 , EXM_CD
    --                                 , EXRS_CNTE
    --                                 , USE_YN
    --                                 , BRCD_SPCM_NO
    --                                 , HSP_TP_CD
    --                                 , FSR_STF_NO
    --                                 , FSR_PRGM_NM
    --                                 , FSR_IP_ADDR
    --                                 , LSH_STF_NO
    --                                 , LSH_DTM
    --                                 , LSH_PRGM_NM
    --                                 , LSH_IP_ADDR
    --                             )
    --                             SELECT DISTINCT
    --                                    IN_EQUIPTYPE
    --                                  , A.LOT_NO
    --                                  , T_WRKDTM
    --                                  , TT_TST_CD(I)
    --                                  , TT_RESULT(I)
    --                                  , 'Y'
    --                                  , IN_SPCM_NO
    --                                  --, '8' --HSP_TP_CD
    ----                                  , '08' -- 2013.01.14. 동서시스템 이희승 - 병원구분코드 8 -> 08로 변경
    --                                  , IN_HSP_TP_CD                                  --병원구분
    --                                  , 'EWHA'
    --                                  , 'INTERFACE'
    --                                  , SYS_CONTEXT('USERENV','IP_ADDRESS')
    --                                  , 'EWHA'
    --                                  , SYSDATE
    --                                  , 'INTERFACE'
    --                                  , SYS_CONTEXT('USERENV','IP_ADDRESS')
    --                              FROM  MSELMQBM A --정도관리물질기본
    --                             WHERE A.DEXM_MDSC_EQUP_CD = IN_EQUIPTYPE
    --                               AND A.BRCD_SPCM_NO      = IN_SPCID
    --                               AND A.USE_STR_DT       <= TO_CHAR(SYSDATE, 'YYYYMMDD')
    --                               AND NVL(A.USE_END_DT, A.AVL_END_DT) >= TO_CHAR(SYSDATE, 'YYYYMMDD') --2011.09.15 방수석 현재 유효한 LOTTNO가져오도록 수정
    --                               AND HSP_TP_CD = IN_HSP_TP_CD--병원구분
    --                               AND ROWNUM = 1;
    --
    --                             EXCEPTION
    --                                  WHEN OTHERS THEN
    --                                     IO_ERRYN  := 'Y';
    --                                     IO_ERRMSG := 'PC_MSE_QC_INTERFACE_SAVE INSERT 중 오류 발생(5). ERRCD = ' || TO_CHAR(SQLCODE)|| SQLERRM;
    --                                     RETURN;
    --                         END;
    --                    END LOOP;
    --                    --작업성공후 종료루틴 타기
    --                    GOTO ENDPROC;
    --                END IF;
    --            END IF;    
    --        
    --     ELSE IF IN_EQUIPTYPE = '002' THEN                                               --  자동 내부정도관리    002 START     
    --         IF SUBSTR(IN_SPCID,1,5) = '99999' THEN
    --                IF  L_FLAG > 0 THEN
    --                    FOR I IN 1 .. L_FLAG
    --                    LOOP
    --                         BEGIN
    --
    --                             INSERT INTO MSELMQRD --정도관리결과정보
    --                             (
    --                                   DEXM_MDSC_EQUP_CD
    --                                 , LOT_NO
    --                                 , FSR_DTM
    --                                 , EXM_CD
    --                                 , EXRS_CNTE
    --                                 , USE_YN
    --                                 , BRCD_SPCM_NO
    --                                 , HSP_TP_CD
    --                                 , FSR_STF_NO
    --                                 , FSR_PRGM_NM
    --                                 , FSR_IP_ADDR
    --                                 , LSH_STF_NO
    --                                 , LSH_DTM
    --                                 , LSH_PRGM_NM
    --                                 , LSH_IP_ADDR
    --                             )
    --                             SELECT DISTINCT
    --                                    IN_EQUIPTYPE
    --                                  , A.LOT_NO
    --                                  , T_WRKDTM
    --                                  , TT_TST_CD(I)
    --                                  , TT_RESULT(I)
    --                                  , 'Y'
    --                                  , IN_SPCM_NO
    --                                  --, '8' --HSP_TP_CD
    ----                                  , '08' -- 2013.01.14. 동서시스템 이희승 - 병원구분코드 8 -> 08로 변경
    --                                  , IN_HSP_TP_CD                          --병원구분
    --                                  , IN_SPCID
    --                                  , 'INFO'
    --                                  , SYS_CONTEXT('USERENV','IP_ADDRESS')
    --                                  , IN_SPCID
    --                                  , SYSDATE
    --                                  , 'INFO'
    --                                  , SYS_CONTEXT('USERENV','IP_ADDRESS')
    --                              FROM  MSELMQBM A --정도관리물질기본
    --                             WHERE A.DEXM_MDSC_EQUP_CD = IN_EQUIPTYPE
    --                               AND A.BRCD_SPCM_NO      = IN_SPCID
    --                               AND A.USE_STR_DT       <= TO_CHAR(SYSDATE, 'YYYYMMDD')
    --                               AND NVL(A.USE_END_DT, A.AVL_END_DT) >= TO_CHAR(SYSDATE, 'YYYYMMDD') --2011.09.15 방수석 현재 유효한 LOTTNO가져오도록 수정
    --                               AND HSP_TP_CD = IN_HSP_TP_CD
    --                               AND ROWNUM = 1;
    --
    --                             EXCEPTION
    --                                  WHEN OTHERS THEN
    --                                     IO_ERRYN  := 'Y';
    --                                     IO_ERRMSG := 'PC_MSE_QC_INTERFACE_SAVE INSERT 중 오류 발생(5). ERRCD = ' || TO_CHAR(SQLCODE)|| SQLERRM;
    --                                     RETURN;
    --                         END;
    --                    END LOOP;
    --                    --작업성공후 종료루틴 타기
    --                    GOTO ENDPROC;
    --                END IF;
    --            END IF;    
    --            
    --           END IF;                                                                    --  자동 내부정도관리    002 END 
    --   
    --     END IF;                                                                         --  자동 내부정도관리    001 END 
                          
           
   
   
        <<ENDPROC>>
       IO_ERRYN := 'N';  
                                   
    END PC_MSE_INTERFACE_SAVE ;                      
    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_INS_ACPT_SPNO 검체접수
    *    최초 작성일 : 2017.11.14
    *    최초 작성자 : ezCaretech 
    *    Description : 인터페이스 진단검사
    **********************************************************************************************/
    PROCEDURE PC_MSE_INS_ACPT_SPNO ( IN_HSP_TP_CD         IN      VARCHAR2   -- 병원구분
                                   , IN_SPCM_NO            IN      VARCHAR2   -- 검체번호
                                   , IN_EXM_DT             IN      VARCHAR2   -- 검사일자
                                   , IN_SPCID              IN      VARCHAR2   -- < P3>최초입력자        : (직번) - 70131                                            
                                   , IN_TIME            IN      VARCHAR2   -- TIME 
                                   , IN_VOL                IN      VARCHAR2   -- VOLUME
                                   , IO_ERRYN              IN OUT  VARCHAR2   -- 오류여부
                                   , IO_ERRMSG             IN OUT  VARCHAR2   -- 오류메세지
                                 )                               
    IS           
    
    EXT_CNT    NUMBER  :=  0;
           
    S_TH1_SPCM_CD           MSELMCED.TH1_SPCM_CD%TYPE          := '';   
    S_WK_UNIT_CD            MSELMAID.WK_UNIT_CD%TYPE           := '';
    S_EXRM_EXM_CTG_CD       MSELMCED.EXRM_EXM_CTG_CD%TYPE      := '';
    S_PT_NO                 PCTPCPAM_DAMO.PT_NO%TYPE           := '';
                  
    S_PRGM_NM                  MSELMCED.LSH_PRGM_NM%TYPE       := 'PC_MSE_INS_ACPT_SPNO';
    S_IP_ADDR                  MSELMCED.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');
              
    IO_TOTNO     NUMBER         := '';
    IO_ACPTNO     NUMBER        := '';
    
    BEGIN
               
        
        BEGIN 
            
            SELECT DISTINCT
                   A.TH1_SPCM_CD
--                 ,  A.EXRM_EXM_CTG_CD
                 , DECODE(A.TLA_ORD_SND_FLAG_CNTE, 'TLA', 'TLA', A.EXRM_EXM_CTG_CD) EXRM_EXM_CTG_CD
                 , B.PT_NO     
                 , (SELECT WK_UNIT_CD
                      FROM MSELMWDE
                     WHERE HSP_TP_CD = A.HSP_TP_CD
                       AND WCTG_TP_CD = '10'
                       AND EXM_CD = B.ORD_CD 
                       AND EXRM_EXM_CTG_CD = A.EXRM_EXM_CTG_CD
                   ) WK_UNIT_CD
              INTO S_TH1_SPCM_CD
                 , S_EXRM_EXM_CTG_CD
                 , S_PT_NO  
                 , S_WK_UNIT_CD
              FROM MSELMCED A
                 , MOOOREXM B
                 , PCTPCPAM_DAMO C
             WHERE A.SPCM_NO         = IN_SPCM_NO
               AND A.HSP_TP_CD         = IN_HSP_TP_CD
               AND A.SPCM_NO         = B.SPCM_PTHL_NO
               AND A.HSP_TP_CD         = B.HSP_TP_CD  
--               AND B.RPY_STS_CD     = 'Y'
               AND B.ODDSC_TP_CD     = 'C'
               AND B.PT_NO             = C.PT_NO
               AND ROWNUM=1
               ;      
               
            EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    IO_ERRYN  := 'Y';
                    IO_ERRMSG := '접수할 검체가 없습니다. = ' || TO_CHAR(SQLCODE);
                    RETURN;  

        END;
        
        -- 2022-01-10 SCS :
        -- 현장검사 외 인터페이스를 통해 접수처리 할수 없도록 함. SLIP : LHP는 허용
--        IF S_EXRM_EXM_CTG_CD NOT IN ('LT') AND S_WK_UNIT_CD NOT IN ('LHP') THEN
--            IO_ERRYN  := 'Y';
--            IO_ERRMSG := '현장검사만 접수할 수 있습니다.';
--            RETURN;
--        END IF;
        

        XSUP.PKG_MSE_LM_SPCMACPT.ACPT( IN_SPCM_NO
                                     , S_PT_NO 

                                     , IN_EXM_DT
                                     , S_EXRM_EXM_CTG_CD
                                     , S_TH1_SPCM_CD
                        
                                     , '' --IN_RMK_CNTE          IN          VARCHAR2
                                     
                                     , IN_HSP_TP_CD
                                     , IN_SPCID
                                     , S_PRGM_NM
                                     , S_IP_ADDR
                                     
                                     , IO_ERRYN
                                     , IO_ERRMSG
                                     );
               
--        PC_MSE_SPCMACPT02_NEW  ( IN_SPCM_NO                --     검체번호          
--                               , IN_EXM_DT               --  검사일자         
--                               , IN_HSP_TP_CD            --  병원구분             
--                               , S_EXRM_EXM_CTG_CD       --    검사분류
--                               , S_TH1_SPCM_CD           --  검체코드
--                               , S_PT_NO                 --     환자번호
--                               , IN_TIME                  -- 
--                               , IN_VOL                   --     
--                               , IN_SPCID               --     등록자
--                               , 'N'                     --    IN_MICRO             
--                               , ''    --IN_RMK_CNTE              --     
--                               , 'Y'                     --    IN_ACPTNOYN        
--                               , 'N'                     --    IN_EMRG_YN         
--                               , S_PRGM_NM                 --    HIS_PRGM_NM          
--                               , S_IP_ADDR              --    HIS_IP_ADDR          
--                               , IO_TOTNO             
--                               , IO_ACPTNO                
--                               , IO_ERRYN            
--                               , IO_ERRMSG           
--                             );
                                 
        IF IO_ERRYN = 'Y' THEN
            IO_ERRYN  := 'Y';
            IO_ERRMSG := '검체접수 오류 발생 ' || IO_ERRMSG;
            RETURN;
        END IF; 
        
        IF IO_ACPTNO = 0 THEN
            IO_ERRYN  := 'Y';
            IO_ERRMSG := '검체접수 오류 발생 접수번호 오류' || IO_ERRMSG;
            RETURN;
        END IF;
        
    END PC_MSE_INS_ACPT_SPNO;          
                                    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_INS_GLUCOSE 혈당인터페이스
    *    최초 작성일 : 2017.11.09
    *    최초 작성자 : ezCaretech 
    *    Description : 김금덕
    **********************************************************************************************/
    PROCEDURE PC_MSE_INS_GLUCOSE ( IN_HSP_TP_CD      IN      VARCHAR2   -- < P0> 병원구분                                                                
                                 , IN_SPCM_NO        IN      VARCHAR2   -- < P1> 검체번호
                                 , IN_PT_NO          IN      VARCHAR2   -- < P2> 환자번호                                        
                                 , IN_EXM_CD           IN      VARCHAR2   -- < P3> 검사코드                                          
                                 , IN_ACPT_DTM      IN      VARCHAR2   -- < P4> 접수시간                                            
                                 , IN_PACT_TP_CD    IN      VARCHAR2   -- < P5> 외래/입원
                                 , IN_DEPT_CD       IN      VARCHAR2   -- < P6> 진료과
                                 , IN_EXRS_CNTE     IN      VARCHAR2   -- < P7> 검사결과
                                 , IN_STF_NO        IN      VARCHAR2   -- < P8> 입력자
                                 , IN_MEDR_STF_NO   IN      VARCHAR2   -- < P9> 진료의 사번             -- 사용안함
                                 , IN_EQUP_CD       IN      VARCHAR2   -- <P10> 장비코드
                                 , IN_EQUP_YN       IN      VARCHAR2   -- <P11> 장비여부
                                 , IN_EQUP_MODE     IN      VARCHAR2   -- <P12> 장비모드     
                                 , IO_ERRYN          IN OUT  VARCHAR2
                                 , IO_ERRMSG         IN OUT  VARCHAR2
                                 )
    
    is
        --변수선언
--        WK_CURSOR                 RETURNCURSOR;
    RSV_CNT         NUMBER(5)                         := 0;        -- 외래예약 건수
              
    WK_STF_NO       CNLRRUSD.STF_NO%TYPE             := '';         -- 검사자ID
    WK_DR_SID       CNLRRUSD.SID%TYPE                 := '';         -- 의사 SID
          
                                                                                                
    WK_PRGM_NM      MSELMEBM.LSH_PRGM_NM%TYPE       := 'PC_MSE_INS_GLUCOSE';
    WK_IP_ADDR      MSELMEBM.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');
        
    IO_SPCM_NO      MSELMCED.SPCM_NO%TYPE           := '';
    IO_RPY_PACT_ID  ACPPRODM.RPY_PACT_ID%TYPE       := '';
    
    BEGIN        
    
        IO_ERRYN  := 'N';
        IO_ERRMSG := '';
                                                
        BEGIN
            SELECT STF_NO
              INTO WK_STF_NO
              FROM CNLRRUSD
             WHERE STF_NO    = IN_STF_NO 
               AND HSP_TP_CD = IN_HSP_TP_CD 
               AND RTRM_DT IS NULL
             ; 
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 IO_ERRYN  := 'Y';
                 IO_ERRMSG := '입력자 정보가 없습니다. ERRCD = ' || TO_CHAR(SQLCODE);
                 RETURN;
        END;         
        
        /************************************************************************************************************************************************
        ** 외래일 경우에 예약정보가 존재하는지 체크를 위한 부분...
        *************************************************************************************************************************************************/
        IF IN_PACT_TP_CD = 'O' AND IN_SPCM_NO IS NULL THEN    
        
--            BEGIN
--                SELECT SID
--                  INTO WK_DR_SID
--                  FROM CNLRRUSD
--                 WHERE STF_NO    = IN_MEDR_STF_NO 
--                   AND HSP_TP_CD = IN_HSP_TP_CD 
--                   AND RTRM_DT IS NULL
--                 ; 
--                EXCEPTION
--                    WHEN NO_DATA_FOUND THEN
--                         IO_ERRYN  := 'Y';
--                         IO_ERRMSG := '의사정보가 없습니다. ERRCD = ' || TO_CHAR(SQLCODE);
--                         RETURN;
--            
--            END;  
        
            BEGIN
                SELECT /*+ XSUP.PC_MSE_INS_ACPPRODM */
                       COUNT(A.PT_NO)
                  INTO RSV_CNT 
                  FROM ACPPRODM A
                 WHERE A.PT_NO       = IN_PT_NO
                   AND A.MED_DT      = TRUNC(SYSDATE)
                   AND A.MED_DEPT_CD = IN_DEPT_CD
                   AND A.HSP_TP_CD   = IN_HSP_TP_CD
                   AND A.APCN_DTM    IS NULL
                   ;
                
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         IO_ERRYN  := 'Y';
                         IO_ERRMSG := '해당진료과에 예약정보가 없습니다. ERRCD = ' || TO_CHAR(SQLCODE);
                         RETURN;
        
                    WHEN OTHERS THEN
                         IO_ERRYN  := 'Y';
                         IO_ERRMSG := '예약정보 체크시 오류 발생. ERRCD = ' || TO_CHAR(SQLCODE);
                         RETURN;
            END;   
            
--            IF RSV_CNT > 0 THEN
--                IO_ERRYN  := 'Y';
--                  IO_ERRMSG := '금일 해당 진료과에 예약정보가 있습니다. ERRCD = ' || TO_CHAR(SQLCODE);
--                RETURN;
--            END IF;   
--            
--            BEGIN
--                PC_MSE_INS_ACPPRODM ( IN_PT_NO               --IN      ACPPRODM.PT_NO%TYPE                     --01*환자번호(PT_NO)
--                                    , ''                       --IN      MSELMEBM.EXRM_EXM_CTG_CD%TYPE           --02*검사분류
--                                    , IN_DEPT_CD             --IN      ACPPRODM.MED_DEPT_CD%TYPE               --03*진료과()
--                                    , WK_DR_SID              --IN      ACPPRODM.MEDR_SID%TYPE                  --04*직원식별ID()
--                                    , IN_HSP_TP_CD           --IN      ACPPRODM.HSP_TP_CD%TYPE                 --05*병원구분코드(HSPCL)
--                                    , WK_PRGM_NM             --IN      ACPPRODM.FSR_PRGM_NM%TYPE               --06*최초등록프로그램명()
--                                    , WK_IP_ADDR             --IN      ACPPRODM.FSR_IP_ADDR%TYPE               --07*최초등록IP주소()
--                                    , IN_STF_NO              --IN      ACPPRODM.FSR_STF_NO%TYPE                --08*최초등록IP주소()
--                                    , IO_RPY_PACT_ID         --IN OUT  ACPPRODM.RPY_PACT_ID%TYPE               --09수납원무접수ID(접수시 발생한..)
--                                    , IO_ERRYN               --IN OUT  VARCHAR2                                --10에러
--                                    , IO_ERRMSG              --IN OUT  VARCHAR2                                --11에러메세지
--                                   ) ;
--                EXCEPTION
--                        WHEN OTHERS THEN
--                            RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_INS_ACPPRODM 외래예약생성시 오류' || ' ERRCODE = ' || IN_PT_NO || ' ' || SQLERRM || ' ' || IO_ERRMSG) ;
--                            RETURN;
--            
--            END;
            
        END IF;

        BEGIN                
            BEGIN           
                -----------------------------------------------------------
                -- 자동오더발생 및 진료지원 검사 결과저장 및 간호기록 저장
                -----------------------------------------------------------
                BEGIN
                    PC_MSE_BST_ORDER_AUTO ( IN_PT_NO       -- 환자번호
                                          , WK_STF_NO      -- 사용자ID
                                          , IN_EXM_CD      -- 검사코드
                                          , IN_EXRS_CNTE   -- 검사결과
                                          , IN_EQUP_CD     -- 혈당기 장비코드
                                          , IN_EQUP_YN     -- 혈당기 정도관리는 환자ID('LM000001','LM000002')를 사용하지 않도록 설계
                                          , IN_EQUP_MODE   -- 혈당기 정도관리 L,M,H 구분
                                          , IN_ACPT_DTM    -- 검사일자 
                                          , IN_PACT_TP_CD  -- 외래/입원/응급구분                                    
                                          , IN_DEPT_CD       -- 진료과
                                          , IN_HSP_TP_CD   -- 병원구분
                                          , WK_PRGM_NM
                                          , WK_IP_ADDR
                                          , IO_SPCM_NO
                                          , IO_ERRYN
                                          , IO_ERRMSG
                                          ); 
                    EXCEPTION
                        WHEN OTHERS THEN
                            RAISE_APPLICATION_ERROR(-20553, 'PKG_MSE_LM_INTERFACE1.PC_MSE_BST_ORDER_AUTO ' || ' ERRCODE = ' || IN_PT_NO || ' ' || SQLERRM || ' ' || IO_ERRMSG) ;
                            RETURN;
                END;
                       
                IF IO_ERRYN = 'Y' THEN
                    IO_ERRYN  := 'Y';
                    IO_ERRMSG := IO_ERRMSG;
                END IF;
            END;
        END ;

    END PC_MSE_INS_GLUCOSE;   
    
    
    
    /**********************************************************************************************
    *    서비스이름  : 진단검사의학과 현장검사 혈당기 오더 자동발행 및 최종검증(패키지내 프로시져)
    *    최초 작성일 : 2017.11.10
    *    최초 작성자 : ezCaretech 
    *    Description : 사용자
    **********************************************************************************************/
    PROCEDURE PC_MSE_BST_ORDER_AUTO ( IN_PT_NO          IN   VARCHAR2     -- 환자번호
                                    , IN_STF_NO         IN   VARCHAR2     -- 입력사번
                                    , IN_EXM_CD         IN   VARCHAR2     -- 검사코드
                                    , IN_EXRS_CNTE      IN   VARCHAR2     -- 결과내용
                                    , IN_EQUP_CD        IN   VARCHAR2     -- 장비코드
                                    , IN_EQUP_YN        IN   VARCHAR2     -- 장비여부
                                    , IN_EQUP_MODE      IN   VARCHAR2     -- 장비모드
                                    , IN_ACPT_DTM       IN   VARCHAR2     -- 접수시간
                                    , IN_PACT_TP_CD     IN   VARCHAR2     -- 외래/입원/응급구분 
                                    , IN_DEPT_CD        IN   VARCHAR2     -- 진료과
                                    , IN_HSP_TP_CD      IN   VARCHAR2     -- 병원구분
                                    , IN_PRGM_NM        IN   VARCHAR2     -- 
                                    , IN_IP_ADDR        IN   VARCHAR2     --
                                    , IO_SPCM_NO        IN   OUT VARCHAR2 --
                                    , IO_ERRYN          IN   OUT VARCHAR2 --
                                    , IO_ERRMSG         IN   OUT VARCHAR2 --
                                 )
    
    IS
        --변수선언
        wk_cursor                 returncursor;
        
        S_SPCM_NO           MSELMCED.SPCM_NO%TYPE   := '';
        S_USE_YN            MSELMQRD.USE_YN%TYPE    := '';
        S_IN_PT_NO          MSELMCED.PT_NO%TYPE     := '';
        S_OUT_PT_NO         MSELMCED.PT_NO%TYPE     := '';
        S_AER_PT_NO         MSELMCED.PT_NO%TYPE     := '';
        S_ORD_STF_NO        CNLRRUSD.STF_NO%TYPE    := '';
        
        S_PACT_ID           ACPPRAAM.PACT_ID%TYPE       := '';
        S_ADS_DT            ACPPRAAM.ADS_DT%TYPE        := '';
        S_MED_DEPT_CD       ACPPRAAM.MED_DEPT_CD%TYPE   := '';
        S_WD_DEPT_CD        ACPPRAAM.WD_DEPT_CD%TYPE    := '';
        S_CHDR_STF_NO       ACPPRAAM.CHDR_STF_NO%TYPE   := '';
        S_ANDR_STF_NO       ACPPRAAM.ANDR_STF_NO%TYPE   := '';
        S_CLCTN_WD_DEPT_CD  ACPPRAAM.CLCTN_WD_DEPT_CD%TYPE  := '';
        S_EXM_CD            MSELMEBM.EXM_CD%TYPE            := '';
        S_PACT_TP_CD        MOOOREXM.PACT_TP_CD%TYPE        := '';
        S_MED_EXM_CTG_CD    MSELMEBM.MED_EXM_CTG_CD%TYPE    := '';

        S_COMN_GRP_CD       CCCCCSTE.COMN_GRP_CD%TYPE       := '966';

        S_ACPT_DTM          DATE    := TO_DATE(IN_ACPT_DTM, 'YYYYMMDDHH24MISS');

    BEGIN       
                    
        S_PACT_TP_CD := IN_PACT_TP_CD;
    
        IF IN_EQUP_YN = 'Y' THEN
                        
        BEGIN
            BEGIN    
                -- 혈당기 정도관리 처리 로직
                -- 각 혈당기별로 사용할 검체번호를 지정한다. MSELMEMC에 셋팅
                SELECT /* PKG_MSE_INTERFACE4.PC_MSE_BST_ORDER_AUTO */
                       DECODE(IN_EQUP_MODE, '1', LW_BRCD_SPCM_NO
                                          , '', MID_BRCD_SPCM_NO
                                          , '2', UP_BRCD_SPCM_NO )  SPCM_NO
                  INTO S_SPCM_NO
                  FROM MSELMEMC
                 WHERE EXM_DEPT_CD       = 'LM'
                   AND DEXM_MDSC_EQUP_CD = IN_EQUP_CD
                   AND HSP_TP_CD         = IN_HSP_TP_CD
                   AND ROWNUM            = 1;
              
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := '정도관리 마스터 확인 필요. Error발생. ErrCd = ' || TO_CHAR(SQLCODE);
                        RETURN;  
--                    WHEN OTHERS  THEN
--                        IO_ERRYN  := 'Y';
--                        IO_ERRMSG := '정도관리 마스터 확인 필요. Error발생. ErrCd = ' || TO_CHAR(SQLCODE);
--                        RETURN;  
            END;
            IF SUBSTR(IN_EXRS_CNTE, 1, 1) < '0' OR SUBSTR(IN_EXRS_CNTE, 1, 1) > '9' THEN
            BEGIN
                S_USE_YN := 'N';
            END;
            ELSE
            BEGIN
                S_USE_YN := 'Y';
              
            END;
            END IF;
           
            BEGIN    
                
                INSERT -- 정도관리
                  INTO MSELMQRD ( LOT_NO
                                , EXM_CD
                                , FSR_DTM
                                , HSP_TP_CD
                                , DEXM_MDSC_EQUP_CD
                                , BRCD_SPCM_NO
                                , EXRS_CNTE
                                , USE_YN
                                , FSR_STF_NO
                                , FSR_PRGM_NM
                                , FSR_IP_ADDR
                                , LSH_STF_NO
                                , LSH_DTM
                                , LSH_PRGM_NM
                                , LSH_IP_ADDR
                                )
                           SELECT A.LOT_NO
                                , IN_EXM_CD
                                , S_ACPT_DTM
                                , A.HSP_TP_CD
                                , IN_EQUP_CD
                                , S_SPCM_NO
                                , IN_EXRS_CNTE
                                , S_USE_YN
                                , IN_STF_NO
                                , IN_PRGM_NM
                                , IN_IP_ADDR
                                , IN_STF_NO
                                , SYSDATE
                                , IN_PRGM_NM
                                , IN_IP_ADDR
                             FROM MSELMQBM A
                            WHERE A.DEXM_MDSC_EQUP_CD = IN_EQUP_CD
                              AND A.BRCD_SPCM_NO      = S_SPCM_NO
                              AND A.HSP_TP_CD         = IN_HSP_TP_CD
                              AND A.USE_STR_DT       <= TRUNC(SYSDATE)
                              AND NVL(A.USE_END_DT, A.AVL_END_DT) >= TRUNC(SYSDATE)
                              AND ROWNUM              = 1 ;


                EXCEPTION
                    WHEN OTHERS THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := '정도관리 데이터 insert 중 오류 발생. ErrCd = ' || TO_CHAR(SQLCODE);
                        RETURN;
            END;
        END;
        ELSE
        BEGIN
            IF IN_PACT_TP_CD = 'O' THEN
                BEGIN
                    SELECT /*+ XSUP.PC_MSE_INS_ACPPRODM */
                           A.PT_NO
                           , 'O'
                      INTO S_IN_PT_NO 
                         , S_PACT_TP_CD
                      FROM ACPPRODM A
                     WHERE A.PT_NO       = IN_PT_NO
                       AND A.MED_DT      = TRUNC(SYSDATE)
                       AND A.MED_DEPT_CD = IN_DEPT_CD
                       AND A.HSP_TP_CD   = IN_HSP_TP_CD
                       AND A.APCN_DTM IS NULL; 
                     
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '외래 상태 확인 필요. Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;  
                            RETURN;
                        WHEN  OTHERS  THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '외래환자정보 조회중 Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                            RETURN;
                END;
            ELSE
            
                -- 1.1 현재환자가 입원환지인지 여부 확인
                BEGIN
                      --2013.12.16 응급추가. 2014-09-02 응급을 먼저 체크
                      SELECT /* PKG_MSE_INTERFACE4.PC_MSE_BST_ORDER_AUTO */
                             A.PT_NO
                           , 'E'
                        INTO S_IN_PT_NO 
                           , S_PACT_TP_CD
                        FROM ACPPRETM A
                       WHERE A.PT_NO      = IN_PT_NO
                         AND A.HSP_TP_CD  = IN_HSP_TP_CD
                         AND A.SIHS_YN    = 'Y'
                         AND XSUP.FT_MSE_E_PTNO_1(A.PACT_ID, A.RPY_CLS_SEQ, A.HSP_TP_CD) = 'N'
                         AND ROWNUM       = 1;   
    
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            BEGIN  
                                SELECT /* PKG_MSE_INTERFACE4.PC_MSE_BST_ORDER_AUTO */
                                       A.PT_NO
                                     , 'I'
                                  INTO S_IN_PT_NO
                                     , S_PACT_TP_CD
                                  FROM ACPPRAAM A                   -- 입원접수
                                 WHERE A.PT_NO      = IN_PT_NO
                                   AND A.HSP_TP_CD  = IN_HSP_TP_CD
                                   AND A.SIHS_YN    = 'Y'
                                   AND XSUP.FT_MSE_I_PTNO_1(A.PACT_ID, A.HSP_TP_CD) = 'N'
                                   AND ROWNUM       = 1;   
                
                                EXCEPTION
                                    WHEN NO_DATA_FOUND THEN
                                        IO_ERRYN  := 'Y';
                                        IO_ERRMSG := '입원(응급)상태 확인 필요. Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;  
                                        RETURN;
                                    WHEN  OTHERS  THEN
                                        IO_ERRYN  := 'Y';
                                        IO_ERRMSG := '입원환자정보 조회중 Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                                        RETURN;
                            END;                        
                        WHEN  OTHERS  THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '입원환자정보 조회중 Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                            RETURN;
                 
                END;
            END IF;

            IF S_IN_PT_NO IS NOT NULL THEN
            BEGIN                          
                IF S_PACT_TP_CD = 'I' THEN
                BEGIN
                    SELECT /* PKG_MSE_INTERFACE4.PC_MSE_BST_ORDER_AUTO */
                           A.PACT_ID
                         , A.ADS_DT
                         , A.MED_DEPT_CD
                         , A.WD_DEPT_CD
                         , A.CHDR_STF_NO
                         , A.ANDR_STF_NO
                          , NVL(A.ANDR_STF_NO,'PPPPP')
                          , NVL(IN_EXM_CD, ( SELECT Z.COMN_CD_NM
                                               FROM CCCCCSTE Z
                                              WHERE Z.COMN_GRP_CD = S_COMN_GRP_CD
                                                AND Z.DTRL3_NM    = 'BST_INTERFACE'
--                                                AND Z.HSP_TP_CD   = IN_HSP_TP_CD       --병원구분 제외
                                                AND ROWNUM        = 1
                                           ))               EXM_CD
                         , A.CLCTN_WD_DEPT_CD               CLCTN_WD_DEPT_CD
                      INTO S_PACT_ID
                         , S_ADS_DT
                         , S_MED_DEPT_CD
                         , S_WD_DEPT_CD
                         , S_CHDR_STF_NO
                         , S_ANDR_STF_NO
                         , S_ORD_STF_NO
                         , S_EXM_CD
                         , S_CLCTN_WD_DEPT_CD
                      FROM ACPPRAAM A
                     WHERE A.PT_NO      = IN_PT_NO
                       AND A.HSP_TP_CD  = IN_HSP_TP_CD
                       AND A.SIHS_YN    = 'Y'
                       AND XSUP.FT_MSE_I_PTNO_1(A.PACT_ID, A.HSP_TP_CD) = 'N'
                       AND ROWNUM       = 1;
    
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN   
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '환자 재원상태 확인 필요. Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                        WHEN  OTHERS  THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '환자정보 조회중 Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                            RETURN;
                END;
                ELSIF S_PACT_TP_CD = 'E' THEN
                BEGIN
                    SELECT /* PKG_MSE_INTERFACE4.PC_MSE_BST_ORDER_AUTO */
                           A.PACT_ID
                         , A.EMRM_ARVL_DTM
                         , A.MED_DEPT_CD
                         , NULL
                         , A.CHDR_STF_NO
                         , A.MEDR_STF_NO
                         , NVL(NVL(CTH_ITHD_MEDR_STF_NO, MEDR_STF_NO),'PPPPP')
                         , NVL(IN_EXM_CD, ( SELECT Z.COMN_CD_NM
                                               FROM CCCCCSTE Z
                                              WHERE Z.COMN_GRP_CD = S_COMN_GRP_CD
                                                AND Z.DTRL3_NM    = 'BST_INTERFACE'
                                                AND ROWNUM        = 1
                                           ))               EXM_CD
                         , 'AER'                             CLCTN_WD_DEPT_CD
                      INTO S_PACT_ID
                         , S_ADS_DT
                         , S_MED_DEPT_CD
                         , S_WD_DEPT_CD
                         , S_CHDR_STF_NO
                         , S_ANDR_STF_NO
                         , S_ORD_STF_NO
                         , S_EXM_CD
                         , S_CLCTN_WD_DEPT_CD
                      FROM ACPPRETM A
                     WHERE A.PT_NO      = IN_PT_NO
                       AND A.HSP_TP_CD  = IN_HSP_TP_CD
                       AND A.SIHS_YN    = 'Y'
                       AND XSUP.FT_MSE_E_PTNO_1(A.PACT_ID, A.RPY_CLS_SEQ, A.HSP_TP_CD) = 'N'
                       AND ROWNUM       = 1;
    
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '환자 재원상태 확인 필요. Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                        WHEN  OTHERS  THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '환자정보 조회중 Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                            RETURN;
                END;
                ELSIF S_PACT_TP_CD = 'O' THEN
                BEGIN
                    SELECT /* PKG_MSE_INTERFACE4.PC_MSE_BST_ORDER_AUTO */
                           A.PACT_ID                                                    -- 원무접수 ID
                         , A.MTM_ARVL_DTM                                                -- 도착일시
                         , A.MED_DEPT_CD                                                -- 진료과
                         , NULL
                         , NULL
                         , A.MEDR_STF_NO                                                -- 진료의
                         , IN_EXM_CD                                                     -- 검사코드
                         , A.MEDR_STF_NO 
                      INTO S_PACT_ID
                         , S_ADS_DT
                         , S_MED_DEPT_CD
                         , S_WD_DEPT_CD
                         , S_CHDR_STF_NO
                         , S_ANDR_STF_NO
                         , S_EXM_CD 
                         , S_ORD_STF_NO
                      FROM ACPPRODM A
                     WHERE A.PT_NO      = IN_PT_NO
                       AND A.MED_DT     = TRUNC(SYSDATE)
                       AND A.HSP_TP_CD  = IN_HSP_TP_CD
                       AND A.APCN_DTM IS NULL
                       AND A.MED_DEPT_CD = IN_DEPT_CD
                       AND ROWNUM       = 1;
    
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN   
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '환자 외래진료예약 확인 필요. Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                        WHEN  OTHERS  THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '환자정보 조회중 Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                            RETURN;
                END; 
                END IF;
            END;
            END IF;

            -- 2.1 검사분류조회
            BEGIN
                SELECT /* PKG_MSE_INTERFACE4.PC_MSE_BST_ORDER_AUTO */
                       MED_EXM_CTG_CD
                  INTO S_MED_EXM_CTG_CD
                  FROM MSELMEBM
                 WHERE EXM_CD    = S_EXM_CD
                   AND HSP_TP_CD = IN_HSP_TP_CD ;
            END;

            -- 2.2 오더발행
            BEGIN
                PC_MSE_INS_ADD_ORD ( IN_PT_NO
                                   , TO_CHAR(S_ACPT_DTM, 'YYYYMMDD')
                                   , IN_HSP_TP_CD
                                   , S_PACT_TP_CD
                                   , S_MED_EXM_CTG_CD
                                   , S_EXM_CD
                                   , S_MED_DEPT_CD
                                   , S_ORD_STF_NO
                                   , ''
                                   , 'Y'
                                   , ''
                                   , IN_IP_ADDR
                                   , IN_PRGM_NM
                                   , IO_ERRYN
                                   , IO_ERRMSG
                                   ) ;
            
                IF IO_ERRYN = 'Y' THEN
                    IO_ERRYN  := 'Y';
                    IO_ERRMSG := 'PC_MSE_INS_ADD_ORD 에러 발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERRMSG;
                    RETURN;
                END IF;
            END;
            

            -- 3 채혈
            BEGIN
                FOR REC IN ( SELECT /* PKG_MSE_INTERFACE4.PC_MSE_BST_ORDER_AUTO */
                                    DISTINCT
                                    B.EXRM_EXM_CTG_CD                                                          EXM_CTG_CD
                                  , A.TH1_SPCM_CD                                                              TH1_SPCM_CD
                                  , TO_CHAR(A.EXM_HOPE_DT, 'YYYY-MM-DD')                                       EXM_HOPE_DT
                                  , A.HSP_TP_CD                                                                HSP_TP_CD
                                  , NVL(A.PBSO_DEPT_CD, '-')                                                   PBSO_DEPT_CD
                                  , NVL(A.PT_HME_DEPT_CD, '-')                                                 PT_HME_DEPT_CD
                                  , TO_CHAR(A.ORD_DT, 'YYYY-MM-DD')                                            ORD_DT
                                  , NVL(A.STM_EXM_BNDL_SEQ, 0)                                                 STM_EXM_BNDL_SEQ
                                  , DECODE(A.ODAPL_POP_CD,'3','3','9','9','7','7','1')                         ODAPL_POP_CD
                                  , ''                                                                         RMK_CNTE
                                  , XSUP.FT_MSE_VRE_CHK(A.ORD_RMK_CNTE, A.HSP_TP_CD)                           VRE_CHK
                                  , DECODE(B.EXRM_EXM_CTG_CD,'L79',B.MED_EXM_CTG_CD,B.EXRM_EXM_CTG_CD)         EXM_CTG_CD_EXTRA
                                  , A.PACT_TP_CD                                                               PACT_TP_CD
                               FROM MOOOREXM A
                                  , MSELMEBM B
                                  , CCOOCBAC C
                              WHERE A.PT_NO             = IN_PT_NO
                                AND A.ORD_DT            = TRUNC(S_ACPT_DTM)
                                AND A.EXM_PRGR_STS_CD   = 'X'
                                AND A.ORD_CTG_CD        = 'CP'
                                AND A.ODDSC_TP_CD       = 'C'
                                AND A.ORD_OCUR_TP_CD    = 'L1'
                                AND A.PACT_TP_CD        = S_PACT_TP_CD
                                AND A.ORD_CD            = S_EXM_CD
                                AND A.HSP_TP_CD         = IN_HSP_TP_CD
                                AND NVL(A.RPY_STS_CD, 'N') <> 'R'
                                AND B.EXM_CD            = A.ORD_CD
                                AND B.HSP_TP_CD         = A.HSP_TP_CD
                                AND C.ORD_CD            = A.ORD_CD
                                AND C.HSP_TP_CD         = A.HSP_TP_CD
                              GROUP BY A.ORD_DT
                                     , A.EXM_HOPE_DT
                                     , B.EXRM_EXM_CTG_CD
                                     , DECODE(B.EXRM_EXM_CTG_CD,'L79',B.MED_EXM_CTG_CD,B.EXRM_EXM_CTG_CD)
                                     , A.TH1_SPCM_CD
                                     , A.HSP_TP_CD
                                     , A.PBSO_DEPT_CD
                                     , A.PT_HME_DEPT_CD
                                     , A.STM_EXM_BNDL_SEQ
                                     , DECODE(A.ODAPL_POP_CD,'3','3','9','9','7','7','1')
                                     , A.PT_NO
                                     , A.ORD_RMK_CNTE
                                     , A.PACT_TP_CD
                           )
                LOOP
                    -- 3.1 검체번호 채번
                    BEGIN
                        PC_MSE_CREATESPCMNO ( IN_HSP_TP_CD                                        -- 2018.11.19 병원구분추가
--                                            , SUBSTR(TO_CHAR(TRUNC(SYSDATE),'YYYYMMDD'), 3 )     -- 2020.03.20 사용안함
                                            , S_SPCM_NO
                                            , IO_ERRYN
                                            , IO_ERRMSG
                                            );

                        IF IO_ERRYN = 'Y' THEN
                           RETURN;
                        END IF;

                        EXCEPTION
                            WHEN  OTHERS  THEN
                                IO_ERRYN  := 'Y';
                                IO_ERRMSG := '검체번호 생성함수 호출 시 에러 발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERRMSG;
                                 RETURN;
                    END;
                    
                    -- 3.2 채혈
                    BEGIN
                        PC_MSE_SPCMROUTINE ( IN_PT_NO
                                           , TO_CHAR(S_ACPT_DTM, 'YYYY-MM-DD')
                                           , IN_HSP_TP_CD
                                           , REC.EXM_CTG_CD
                                           , REC.EXM_CTG_CD_EXTRA
                                           , REC.TH1_SPCM_CD
                                           , REC.STM_EXM_BNDL_SEQ
                                           , REC.PBSO_DEPT_CD
                                           , REC.PT_HME_DEPT_CD
                                           , REC.EXM_HOPE_DT
                                           , REC.PACT_TP_CD
                                           , REC.ODAPL_POP_CD
                                           , ''
                                           , ''
                                           , 'N'                            -- 2017.09.13 응급여부 
                                           , IN_STF_NO
                                           , '0'
                                           , IN_PRGM_NM
                                           , IN_IP_ADDR
                                           , 'N'                               -- 2017.10.20 TLA
                                           , 'N'                            -- 2017.10.30 바코드구분
                                           , 'N'                            -- 2017.12.05 채혈팀채혈여부
                                           , 'N'                            -- 2018.11.19 위탁수탁여부
                                           , S_SPCM_NO
                                           , IO_ERRYN
                                           , IO_ERRMSG
                                           );
                    
                        IF IO_ERRYN = 'Y' THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '채혈 함수 호출 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERRMSG;
                            RETURN;
                        END IF;
                    END;
                    
                    -- 3.3 접수
                    --검체번호를 가지고 자동접수처리
                    BEGIN      
                       PC_MSE_SPCMRANGE01(  IN_PT_NO
                                          , TO_CHAR(S_ACPT_DTM, 'YYYY-MM-DD')
                                          , IN_HSP_TP_CD
                                          , REC.EXM_CTG_CD_EXTRA
                                          , REC.TH1_SPCM_CD
                                          , IN_STF_NO
                                          , '0' 
                                          , TO_CHAR(TRUNC(SYSDATE),'YYYYMMDD') 
                                          , S_SPCM_NO    
                                          , IN_STF_NO
                                          , IN_PRGM_NM
                                          , IN_IP_ADDR
                                          , IO_ERRYN
                                          , IO_ERRMSG
                                          );
                    
                        IF IO_ERRYN = 'Y' THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '검체접수 함수 호출 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERRMSG;
                        END IF;
                    END;
                    
                    --검체번호를 이용하여 결과입력 대상정보 조회
                    FOR RECBLD2 IN ( SELECT /*+ PKG_MSE_INTERFACE4.PC_MSE_BST_ORDER_AUTO */
                                            EXRM_EXM_CTG_CD     EXRM_EXM_CTG_CD
                                          , EXM_CD              EXM_CD
                                          , IN_EXRS_CNTE        EXRS_CNTE
                                       FROM MSELMAID
                                      WHERE SPCM_NO   = S_SPCM_NO
                                        AND HSP_TP_CD = IN_HSP_TP_CD
                                   )
                    LOOP
                        --결과정보 입력 프로시저 호출
                        BEGIN
                            PC_MSE_EXMRSLTSAVE_1( S_SPCM_NO
                                                , RECBLD2.EXRM_EXM_CTG_CD
                                                , RECBLD2.EXM_CD
                                                , RECBLD2.EXRS_CNTE
                                                , ''
                                                , '3' 
                                                , IN_PT_NO
                                                , ''
                                                , ''
                                                  , ''
                                                  , 'N'
                                                , 'N'
                                                , 'N'
                                                , IN_STF_NO
                                                , IN_HSP_TP_CD
                                                , IN_PRGM_NM
                                                , IN_IP_ADDR
                                                , IO_ERRYN
                                                , IO_ERRMSG );
                        
                            IF IO_ERRYN = 'Y' THEN
                                IO_ERRYN  := 'Y';
                                IO_ERRMSG := '결과등록중 에러 발생. ERRCD = ' ||  SQLERRM || ' ' || IO_ERRMSG;
                                RETURN;
                            END IF;
                        END;
                    END LOOP;
                END LOOP;
            END;
            
            -- 2012.11.21 송준택 보고시간 검사시간으로 update 추가  
            BEGIN
                UPDATE
                       MSELMAID
                   SET ACPT_DTM     = S_ACPT_DTM   --2013.10.23 . [오더시간, 접수시간, 보고시간 : 실제검사시간(기계에 저장된 BST를 시행한 시간)]
                     , LST_RSLT_VRFC_DTM = S_ACPT_DTM   --2013.10.23 . [오더시간, 접수시간, 보고시간 : 실제검사시간(기계에 저장된 BST를 시행한 시간)]
                     , FSR_DTM      = S_ACPT_DTM   --2013.10.23 . [오더시간, 접수시간, 보고시간 : 실제검사시간(기계에 저장된 BST를 시행한 시간)]
                     , RSLT_MDF_DTM = S_ACPT_DTM
                     , LSH_DTM      = SYSDATE
                     , LSH_STF_NO   = IN_STF_NO
                     , LSH_PRGM_NM  = IN_PRGM_NM
                     , LSH_IP_ADDR  = IN_IP_ADDR
                 WHERE SPCM_NO      = S_SPCM_NO
                   AND EXM_CD       = S_EXM_CD
                   AND HSP_TP_CD    = IN_HSP_TP_CD;

                EXCEPTION
                    WHEN OTHERS THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := '결과시간 수정 시 에러 발생(1). ErrCd = '  || SQLERRM || ' ' || IO_ERRMSG;
                        RETURN;
            END;

            BEGIN
                UPDATE 
                       MSELMCED
                   SET ACPT_DTM     = S_ACPT_DTM   --2013.10.23 . [오더시간, 접수시간, 보고시간 : 실제검사시간(기계에 저장된 BST를 시행한 시간)]
                     , BLCL_DTM     = S_ACPT_DTM   --2013.10.23 . [오더시간, 접수시간, 보고시간 : 실제검사시간(기계에 저장된 BST를 시행한 시간)]
                     , FSR_DTM      = S_ACPT_DTM   --2013.10.23 . [오더시간, 접수시간, 보고시간 : 실제검사시간(기계에 저장된 BST를 시행한 시간)]
                     , BRFG_DTM     = S_ACPT_DTM
                     , LSH_DTM      = SYSDATE
                     , LSH_STF_NO   = IN_STF_NO
                     , LSH_PRGM_NM  = IN_PRGM_NM
                     , LSH_IP_ADDR  = IN_IP_ADDR
                 WHERE SPCM_NO      = S_SPCM_NO
                   AND HSP_TP_CD    = IN_HSP_TP_CD;

                EXCEPTION
                    WHEN OTHERS THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := '결과시간 수정 시 에러 발생(2). ErrCd = '  || SQLERRM || ' ' || IO_ERRMSG;
                        RETURN;
            END;

            BEGIN
                UPDATE 
                       MOOOREXM M
                   SET M.FSR_DTM      = S_ACPT_DTM   --2013.10.23 . [오더시간, 접수시간, 보고시간 : 실제검사시간(기계에 저장된 BST를 시행한 시간)]
                     , M.BLCL_DTM     = S_ACPT_DTM   --2013.10.23 . [오더시간, 접수시간, 보고시간 : 실제검사시간(기계에 저장된 BST를 시행한 시간)]
                     , M.ACPT_DTM     = S_ACPT_DTM   --2013.10.23 . [오더시간, 접수시간, 보고시간 : 실제검사시간(기계에 저장된 BST를 시행한 시간)]
                     , M.EXRM_HH_DTM  = S_ACPT_DTM   --2013.10.23 . [오더시간, 접수시간, 보고시간 : 실제검사시간(기계에 저장된 BST를 시행한 시간)]
                     , M.FSR_STF_DEPT_CD = (SELECT C.AOA_WKDP_CD FROM CNLRRUSD C WHERE C.STF_NO = M.FSR_STF_NO) 
                     , M.BRFG_DTM     = S_ACPT_DTM
                     , M.LSH_DTM      = SYSDATE
                     , M.LSH_STF_NO   = IN_STF_NO
                     , M.LSH_PRGM_NM  = IN_PRGM_NM
                     , M.LSH_IP_ADDR  = IN_IP_ADDR
                     , M.RPY_STS_CD   = DECODE(S_PACT_TP_CD , 'O', 'N',  M.RPY_STS_CD)                   -- 외래 일때만 수납여부 'N' 변경     
                     , M.RTM_FMT_DTM  =    S_ACPT_DTM                                                        -- 2018.03.22 반영     
                 WHERE M.SPCM_PTHL_NO = S_SPCM_NO
                   AND M.ODDSC_TP_CD  = 'C'
                   AND M.ORD_CD       = S_EXM_CD
                   AND M.HSP_TP_CD    = IN_HSP_TP_CD;

                EXCEPTION
                    WHEN OTHERS THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := '결과시간 수정 시 에러 발생(3). ErrCd = '  || SQLERRM || ' ' || IO_ERRMSG;
                        RETURN;
            END;
            
            
            -- 간호기록지에 결과를 입력한다. 차세대에서는 간호기록지에 데이터 넣는 부분에 대한 정제는 간호팀에서 하기로 했으므로, 무조건 간호기록관련 프로시저를 호출한다.
            BEGIN
                XMED.PKG_MRN_CLCOREC.PC_MRN_SAVE_CLCOREC_INTERFACE ( IN_PT_NO
                                                                   , IN_HSP_TP_CD
                                                                   , 'BST'
                                                                   , S_ACPT_DTM
                                                                   , IN_EXRS_CNTE
                                                                   , S_PACT_ID
                                                                   , S_PACT_TP_CD
                                                                   , NULL
                                                                   , S_CLCTN_WD_DEPT_CD
                                                                   , S_MED_DEPT_CD
                                                                   , NULL
                                                                   , 'PPPPP'
                                                                   , IN_PRGM_NM
                                                                   , IN_IP_ADDR
                                                                   , NULL
                                                                   );
            END;
            
        END;
        END IF;

        IO_SPCM_NO := S_SPCM_NO;  
        IO_ERRYN  := 'N';
        IO_ERRMSG := '';
    END PC_MSE_BST_ORDER_AUTO;
                           
    
                              
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_PATINFO_SELECT 
    *    최초 작성일 : 2017.11.16
    *    최초 작성자 : 김금덕
    *    DESCRIPTION : 환자정보 조회 
    **********************************************************************************************/
    PROCEDURE PC_MSE_PATINFO_SELECT ( IN_PT_NO             IN   VARCHAR2                 -- 환자정보
                                    , OUT_CURSOR         OUT  RETURNCURSOR )
    IS
        --변수선언
         WK_CURSOR                 RETURNCURSOR ; 
    
        BEGIN       
        
            BEGIN
                OPEN WK_CURSOR FOR
    
                    SELECT DISTINCT
                           PT_NO                          -- 환자번호
                         , PT_NM                          -- 환자이름
                         , SEX_TP_CD                      -- 성별
                         , TO_CHAR(C.PT_BRDY_DT, 'YYYY-MM-DD')    PT_BRDY_DT                             -- 생년월일
                      FROM PCTPCPAM_DAMO C                         
                     WHERE PT_NO = IN_PT_NO
                         ;    

                  OUT_CURSOR := WK_CURSOR ;
    
                --예외처리
              EXCEPTION   
                      WHEN NO_DATA_FOUND THEN
                           RAISE_APPLICATION_ERROR(-20553, '환자정보 없습니다.') ;
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR(-20553, '환자정보 조회중 Error발생 PC_MSE_PATINFO_SELECT' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END ; 
       
    END PC_MSE_PATINFO_SELECT;             
    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_BST_ORDER_SPCMNO
    *    최초 작성일 : 2017.11.18
    *    최초 작성자 : 김금덕
    *    DESCRIPTION : 진단검사의학과 현장검사 오더 채혈처리까지 검체번호 리턴
    **********************************************************************************************/
    PROCEDURE PC_MSE_INS_ORDER_SPCMNO ( IN_HSP_TP_CD          IN       VARCHAR2    -- 병원구분
                                      , IN_PT_NO              IN       VARCHAR2    -- 환자번호
                                      , IN_EXM_DT             IN      VARCHAR2       -- < P6>검사일시          : YYYYMMDDHH24MISS
                                      , IN_SPCID              IN      VARCHAR2       -- < P3>최초입력자        : (직번) - 70131                                                                           
                                      , IN_CNT                IN      VARCHAR2       -- < P9>처방개수           : 결과전송 처방 개수     
                                      , IN_TST_CD             IN      VARCHAR2       -- <P10>검사코드            : 처방코드(배열)       
                                      , IN_PACT_TP_CD         IN       VARCHAR2    -- 외래/입원/응급구분   
                                      , IN_DEPT_CD             IN       VARCHAR2    -- <P7>진료과                                 --2018.04.10 추가
                                      , OUT_CURSOR             OUT  RETURNCURSOR
                                 )
    IS
        WK_CURSOR                 RETURNCURSOR ;
        
        L_FLAG                    NUMBER(10)      := TO_NUMBER(NVL(IN_CNT,'0'));           -- 처방갯수을   L_FLAG 에 담아서  FOR 문으로 돌림  
        
        TT_TST_CD                 T_VC2ARRAY4000;

        S_ORD_STF_NO        CNLRRUSD.STF_NO%TYPE    := '';
        S_PACT_ID           ACPPRAAM.PACT_ID%TYPE       := '';
        S_ADS_DT            ACPPRAAM.ADS_DT%TYPE        := '';
        S_MED_DEPT_CD       ACPPRAAM.MED_DEPT_CD%TYPE   := '';
        S_WD_DEPT_CD        ACPPRAAM.WD_DEPT_CD%TYPE    := '';
        S_CHDR_STF_NO       ACPPRAAM.CHDR_STF_NO%TYPE   := '';
        S_ANDR_STF_NO       ACPPRAAM.ANDR_STF_NO%TYPE   := '';
        S_CLCTN_WD_DEPT_CD  ACPPRAAM.CLCTN_WD_DEPT_CD%TYPE  := '';
        S_EXM_CD            MSELMEBM.EXM_CD%TYPE            := '';
        S_MED_EXM_CTG_CD    MSELMEBM.MED_EXM_CTG_CD%TYPE    := '';
        S_SPCM_NO            VARCHAR2(100) := '';
        S_EXM_DT              DATE    := TO_DATE(IN_EXM_DT, 'YYYYMMDDHH24MISS');                                           
        
        
        IN_PRGM_NM            VARCHAR2(50) := 'ACK PC_MSE_BST_ORDER_SPCMNO';
        IN_IP_ADDR            VARCHAR2(50) := SYS_CONTEXT('USERENV','IP_ADDRESS');
        IO_ERRYN            VARCHAR(1) := '';
        IO_ERRMSG            VARCHAR(4000) := '';

    BEGIN
        

--    WK_CURSOR := 'test';
--    RETURN;    
        
    IF L_FLAG > 0 THEN
        FOR I IN 1 .. L_FLAG
               LOOP

            TT_TST_CD    (I) := NVL( SUBSTR(IN_TST_CD    , INSTR(IN_TST_CD    ,CHR(9),1,I) + 1   , INSTR(IN_TST_CD    ,CHR(9),1,I + 1) - (INSTR(IN_TST_CD    ,CHR(9),1,I) + 1)), '');        -- P10

               END LOOP; 
    END IF;    
 

    
    IF IN_PACT_TP_CD = 'I' THEN          -- 입원확인  
        BEGIN  
            SELECT A.PACT_ID
                 , A.ADS_DT
                 , A.MED_DEPT_CD
                 , A.WD_DEPT_CD
                 , A.CHDR_STF_NO
                 , A.ANDR_STF_NO
                 , NVL(A.ANDR_STF_NO,'PPPPP')
                 , ''
                 , A.CLCTN_WD_DEPT_CD               CLCTN_WD_DEPT_CD
             INTO S_PACT_ID
                , S_ADS_DT
                , S_MED_DEPT_CD
                , S_WD_DEPT_CD
                , S_CHDR_STF_NO
                , S_ANDR_STF_NO
                , S_ORD_STF_NO
                , S_EXM_CD
                , S_CLCTN_WD_DEPT_CD            
             FROM ACPPRAAM A
            WHERE A.PT_NO      = IN_PT_NO
              AND A.HSP_TP_CD  = IN_HSP_TP_CD
              AND A.SIHS_YN    = 'Y'
              AND XSUP.FT_MSE_I_PTNO_1(A.PACT_ID, A.HSP_TP_CD) = 'N'
              AND ROWNUM = 1
              ;
              
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20553, '환자 재원상태 확인 필요.') ;
                WHEN  OTHERS  THEN
                    RAISE_APPLICATION_ERROR(-20553, '환자정보 조회중 Error발생.') ;
                RETURN;    
        END;    
    
    ELSIF IN_PACT_TP_CD = 'O' THEN        -- 외래확인
        BEGIN
            SELECT A.PACT_ID                                                -- 원무접수 ID
                , A.MTM_ARVL_DTM                                            -- 도착일시
                , A.MED_DEPT_CD                                             -- 진료과
                , NULL
                , NULL
                , A.MEDR_STF_NO                                                -- 진료의
             INTO S_PACT_ID
                , S_ADS_DT
                , S_MED_DEPT_CD
                , S_WD_DEPT_CD
                , S_CHDR_STF_NO
                , S_ANDR_STF_NO
             FROM ACPPRODM A
            WHERE A.PT_NO          = IN_PT_NO
              AND A.MED_DT         = TRUNC(SYSDATE)
              AND A.HSP_TP_CD      = IN_HSP_TP_CD 
              AND A.MED_DEPT_CD    = IN_DEPT_CD        -- 'IME'
              AND A.APCN_DTM IS NULL
              AND ROWNUM       = 1;  
              
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    BEGIN                                    
                       SELECT A.PACT_ID                                                    -- 원무접수 ID
                            , A.MTM_ARVL_DTM                                            -- 도착일시
                            , A.MED_DEPT_CD                                             -- 진료과
                            , NULL
                            , NULL
                            , A.MEDR_STF_NO                                                -- 진료의
                         INTO S_PACT_ID
                            , S_ADS_DT
                            , S_MED_DEPT_CD
                            , S_WD_DEPT_CD
                            , S_CHDR_STF_NO
                            , S_ANDR_STF_NO
                         FROM ACPPRODM A
                        WHERE A.PT_NO      = IN_PT_NO
                          AND A.MED_DT     = TRUNC(SYSDATE)
                          AND A.HSP_TP_CD  = IN_HSP_TP_CD
                          AND A.APCN_DTM IS NULL
                          AND ROWNUM       = 1;
                       
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                RAISE_APPLICATION_ERROR(-20553, '환자 외래진료예약 확인 필요.') ;
                            WHEN  OTHERS  THEN
                                RAISE_APPLICATION_ERROR(-20553, '환자정보 조회중 Error발생.') ;
                            RETURN; 
                       END; 
                    
                WHEN  OTHERS  THEN
                    RAISE_APPLICATION_ERROR(-20553, '환자정보 조회중 Error발생.') ;
                RETURN; 
        END;
--        BEGIN
--           SELECT A.PACT_ID                                                    -- 원무접수 ID
--                , A.MTM_ARVL_DTM                                            -- 도착일시
--                , A.MED_DEPT_CD                                             -- 진료과
--                , NULL
--                , NULL
--                , A.MEDR_STF_NO                                                -- 진료의
----                , ''                                                         -- 검사코드
--                
--             INTO S_PACT_ID
--                , S_ADS_DT
--                , S_MED_DEPT_CD
--                , S_WD_DEPT_CD
--                , S_CHDR_STF_NO
--                , S_ANDR_STF_NO
----                , S_EXM_CD
--             FROM ACPPRODM A
--            WHERE A.PT_NO      = IN_PT_NO
--              AND A.MED_DT     = TRUNC(SYSDATE)
--              AND A.HSP_TP_CD  = IN_HSP_TP_CD
--              AND A.APCN_DTM IS NULL
--              AND ROWNUM       = 1;
--           
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                    RAISE_APPLICATION_ERROR(-20553, '환자 외래진료예약 확인 필요.') ;
--                WHEN  OTHERS  THEN
--                    RAISE_APPLICATION_ERROR(-20553, '환자정보 조회중 Error발생.') ;
--                RETURN; 
--           END; 

    ELSIF IN_PACT_TP_CD = 'E' THEN        -- 응급확인
        BEGIN
           SELECT A.PACT_ID                                                    -- 원무접수 ID
                , A.EMRM_ARVL_DTM                                            -- 도착일시
                , A.MED_DEPT_CD                                             -- 진료과
                , NULL
                , NULL
                , A.MEDR_STF_NO                                                -- 진료의
             INTO S_PACT_ID
                , S_ADS_DT
                , S_MED_DEPT_CD
                , S_WD_DEPT_CD
                , S_CHDR_STF_NO
                , S_ANDR_STF_NO
             FROM ACPPRETM A
            WHERE A.PT_NO      = IN_PT_NO
--              AND A.EMRM_ARVL_DTM  >= TRUNC(SYSDATE)
--              AND A.EMRM_ARVL_DTM BETWEEN SYSDATE - 6/24 AND SYSDATE                  -- 2018.04.24 23:59 이전에 접수되어서 다음날 00:00 이후에 혈당검사 전송시 처리되는 경우발생 현시간에서 -6시까지 조회
              AND A.HSP_TP_CD  = IN_HSP_TP_CD
              AND A.APCN_DTM IS NULL
              AND A.SIHS_YN ='Y'
              AND ROWNUM       = 1;
           
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(-20553, '환자 응급재원여부 확인 필요.') ;
                WHEN  OTHERS  THEN
                    RAISE_APPLICATION_ERROR(-20553, '환자정보 조회중 Error발생.') ;
                RETURN; 
           END;

    END IF;
             
    -- 2018.02.26 주치의 입력여부 확인
    IF S_ANDR_STF_NO = '' OR S_ANDR_STF_NO IS NULL THEN
    BEGIN
        RAISE_APPLICATION_ERROR(-20553,  IN_PACT_TP_CD || '입원/외래/응급 접수정보에 주치의가 누락되었습니다. 확인 필요.');
        RETURN;
    END;
    END IF;
    
    
    IF L_FLAG > 0 THEN
    BEGIN
    
        FOR I IN 1 .. L_FLAG
               LOOP
                   BEGIN
                -- 오더발행
                PC_MSE_INS_ADD_ORD ( IN_PT_NO                              -- 차트번호
                                   , TO_CHAR(S_EXM_DT, 'YYYYMMDD')       -- 검사일자
                                   , IN_HSP_TP_CD                       -- 병원구분
                                   , IN_PACT_TP_CD                      -- 외래/입원
                                   , 'L84'                                -- S_MED_EXM_CTG_CD                
                                   , TT_TST_CD(I)                        -- 검사코드
                                   , S_MED_DEPT_CD                        -- 진료과
                                   , S_ANDR_STF_NO        --S_ORD_STF_NO                       -- 진료의사
                                   , ''
                                   , 'Y'
                                   , ''
                                   , IN_IP_ADDR
                                   , IN_PRGM_NM                            
                                   , IO_ERRYN
                                   , IO_ERRMSG
                                   ) ;
            
                IF IO_ERRYN = 'Y' THEN
                    RAISE_APPLICATION_ERROR(-20553, TT_TST_CD(I) || ' 검사코드 BST 현장검사 오더 발행 중 에러 발생.' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERRMSG) ;
                    RETURN;
                END IF;
                END;

               END LOOP;
    END; 
    END IF;
           
    BEGIN
        FOR REC IN ( SELECT /* PKG_MSE_INTERFACE4.PC_MSE_BST_ORDER_AUTO */
                            DISTINCT
                            B.EXRM_EXM_CTG_CD                                                          EXM_CTG_CD
                          , A.TH1_SPCM_CD                                                              TH1_SPCM_CD
                          , TO_CHAR(A.EXM_HOPE_DT, 'YYYY-MM-DD')                                       EXM_HOPE_DT
                          , A.HSP_TP_CD                                                                HSP_TP_CD
                          , NVL(A.PBSO_DEPT_CD, '-')                                                   PBSO_DEPT_CD
                          , NVL(A.PT_HME_DEPT_CD, '-')                                                 PT_HME_DEPT_CD
                          , TO_CHAR(A.ORD_DT, 'YYYY-MM-DD')                                            ORD_DT
                          , NVL(A.STM_EXM_BNDL_SEQ, 0)                                                 STM_EXM_BNDL_SEQ
                          , DECODE(A.ODAPL_POP_CD,'3','3','9','9','7','7','1')                         ODAPL_POP_CD
                          , ''                                                                         RMK_CNTE
                          , XSUP.FT_MSE_VRE_CHK(A.ORD_RMK_CNTE, A.HSP_TP_CD)                           VRE_CHK
                          , DECODE(B.EXRM_EXM_CTG_CD,'L79',B.MED_EXM_CTG_CD,B.EXRM_EXM_CTG_CD)         EXM_CTG_CD_EXTRA
                          , A.PACT_TP_CD                                                               PACT_TP_CD
                       FROM MOOOREXM A
                          , MSELMEBM B
                          , CCOOCBAC C
                      WHERE A.PT_NO             = IN_PT_NO
                        AND A.ORD_DT            = TRUNC(S_EXM_DT)
                        AND A.EXM_PRGR_STS_CD   = 'X'
                        AND A.ORD_CTG_CD        = 'CP'
                        AND A.ODDSC_TP_CD       = 'C'
                        AND A.ORD_OCUR_TP_CD    = 'L1'
                        AND A.PACT_TP_CD        = IN_PACT_TP_CD
--                        AND A.ORD_CD            = S_EXM_CD
                        AND A.HSP_TP_CD         = IN_HSP_TP_CD
                        AND NVL(A.RPY_STS_CD, 'N') <> 'R'
                        AND B.EXM_CD            = A.ORD_CD
                        AND B.HSP_TP_CD         = A.HSP_TP_CD
                        AND C.ORD_CD            = A.ORD_CD
                        AND C.HSP_TP_CD         = A.HSP_TP_CD
                        AND B.EXRM_EXM_CTG_CD    = 'L84'                                                   --검사실검사분류코드
                      GROUP BY A.ORD_DT
                             , A.EXM_HOPE_DT
                             , B.EXRM_EXM_CTG_CD
                             , DECODE(B.EXRM_EXM_CTG_CD,'L79',B.MED_EXM_CTG_CD,B.EXRM_EXM_CTG_CD)
                             , A.TH1_SPCM_CD
                             , A.HSP_TP_CD
                             , A.PBSO_DEPT_CD
                             , A.PT_HME_DEPT_CD
                             , A.STM_EXM_BNDL_SEQ
                             , DECODE(A.ODAPL_POP_CD,'3','3','9','9','7','7','1')
                             , A.PT_NO
                             , A.ORD_RMK_CNTE
                             , A.PACT_TP_CD
                   )
        LOOP                           
            -- 3.1 검체번호 채번
            BEGIN
                PC_MSE_CREATESPCMNO ( IN_HSP_TP_CD                                        -- 2018.11.19 병원구분추가 
--                                    , SUBSTR(TO_CHAR(TRUNC(SYSDATE),'YYYYMMDD'), 3 )    -- 2020.03.20 사용안함
                                    , S_SPCM_NO
                                    , IO_ERRYN
                                    , IO_ERRMSG
                                    );

                IF IO_ERRYN = 'Y' THEN
                    RAISE_APPLICATION_ERROR(-20553, ' 검사코드 BST 현장검사 채번 발행 중 에러 발생.' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERRMSG) ;
                       RETURN;
                END IF;

                EXCEPTION
                    WHEN  OTHERS  THEN 
                        RAISE_APPLICATION_ERROR(-20553, ' 검체번호 BST 생성함수 호출 시 에러 발생.' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERRMSG) ;
                        RETURN;
            END;        
            

            
            
            -- 3.2 채혈
            BEGIN
                PC_MSE_SPCMROUTINE ( IN_PT_NO
                                   , TO_CHAR(S_EXM_DT, 'YYYY-MM-DD')
                                   , IN_HSP_TP_CD
                                   , REC.EXM_CTG_CD
                                   , REC.EXM_CTG_CD_EXTRA
                                   , REC.TH1_SPCM_CD
                                   , REC.STM_EXM_BNDL_SEQ
                                   , REC.PBSO_DEPT_CD
                                   , REC.PT_HME_DEPT_CD
                                   , REC.EXM_HOPE_DT
                                   , REC.PACT_TP_CD
                                   , REC.ODAPL_POP_CD
                                   , ''
                                   , ''
                                   , 'N'                            -- 2017.09.13 응급여부 
                                   , IN_SPCID
                                   , '0'
                                   , IN_PRGM_NM
                                   , IN_IP_ADDR
                                   , 'N'                               -- 2017.10.20 TLA
                                   , 'N'                            -- 2017.10.30 바코드구분
                                   , 'N'                            -- 2017.12.05 채혈팀채혈여부
                                   , 'N'                            -- 2018.11.19 위탁수탁여부
                                   , S_SPCM_NO
                                   , IO_ERRYN
                                   , IO_ERRMSG
                                   );
            
                IF IO_ERRYN = 'Y' THEN
                    RAISE_APPLICATION_ERROR(-20553, ' BST 채혈함수 호출 시 에러 발생.' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERRMSG) ;
                    RETURN;
                END IF;
            END;
            
        END LOOP;
    END;
         
    BEGIN    
        UPDATE MOOOREXM 
           SET RPY_STS_CD       = 'N'            
         WHERE SPCM_PTHL_NO     = S_SPCM_NO
           AND PT_NO               = IN_PT_NO
           AND HSP_TP_CD         = IN_HSP_TP_CD
           AND ORD_SLIP_CTG_CD     = 'L84'
           AND ORD_CD            IN ('L8434','L8435', 'L8436', 'L8437', 'L8438', 'L8440') -- 2018-06-05 방정섭   'L8440'
           ;
    END;
    
    BEGIN
          OPEN WK_CURSOR FOR

            SELECT S_SPCM_NO
              FROM DUAL
             ;

            OUT_CURSOR := WK_CURSOR ;

          --예외처리
        EXCEPTION
              WHEN OTHERS THEN
                   RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_ORDER_SELECT' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
      END ;
    
    --OUT_SPCM_NO := S_SPCM_NO;
    
    END PC_MSE_INS_ORDER_SPCMNO;        


    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_SAVE_CULTRESULT
    *    최초 작성일 : 2017.11.27
    *    최초 작성자 : 김금덕 
    *    Description : 염색화면에서 배양결과 Negative처리 (결핵, 진균, 일반의 혈액만 처리)
    **********************************************************************************************/
    procedure PC_MSE_SAVE_CULTRESULT  ( IN_HSP_TP_CD    IN      VARCHAR2   -- <P0> 병원구분
                                      , IN_EQUIPTYPE    IN      VARCHAR2   -- <P1> 장비코드
                                      , IN_EQUP         IN      VARCHAR2   -- <P2> 장비명
                                      , IN_SPCM_NO      IN      VARCHAR2   -- <P3> 검체번호
                                      , IN_SPCID        IN      VARCHAR2   -- <P4> 사용자ID
                                      , IN_TST_CD       IN      VARCHAR2   -- <P5> 검사코드
                                      , IN_EXRS_CNTE    IN      VARCHAR2   -- <P6> 검사결과내용
                                      , IN_POSYN        IN      VARCHAR2   -- <P7> 검사진행상태코드에 상태를 'T'나 'P'로 전달(T:임시저장, P:검증)
                                      , IO_ERRYN        IN OUT  VARCHAR2
                                      , IO_ERRMSG       IN OUT  VARCHAR2 )
    is
        T_ACPTNO        VARCHAR2(0020)  :=  '';
        T_SPCNO2        VARCHAR2(0020)  :=  '';
        T_TSTCD         VARCHAR2(0020)  :=  '';
        T_RSLT          VARCHAR2(2000)  :=  '';         
        

        --2010.06.21 방수석 BLOOD CULTURE 양성인 경우 인터페이스에서 음성 결과 등록시 SKIP처리하도록 기능보완
        T_BC_TST_YN     VARCHAR2(0001)  :=  'N';
        T_BC_POSI_YN    VARCHAR2(0001)  :=  'N';

        --2010.08.10 방수석 BLOOD CULTURE INTERFACE시 중간, 최종보고 여부 체크
        T_BC_TST_STAT   VARCHAR2(0001)  :=  '';

        T_SPEX_PRGR_STS_CD          VARCHAR2(0001)  :=  '1';
        T_RSLT_BRFG_YN              VARCHAR2(0001)  :=  'N';
        T_CNT                       VARCHAR2(0001)  :=    '';     -- L41062 검사존재카운트
        V_EXRS_CNTE                 VARCHAR2(4000)  :=  '';                             
        V_EXRS_RMK_CNTE             VARCHAR2(4000)  :=  '';                             
        V_EXRM_RMK_CNTE             VARCHAR2(4000)  :=  '';                             
                                                                          
        S_EXRS_CNTE                 VARCHAR2(4000)  :=  '';                             
        S_EXRS_RMK_CNTE             VARCHAR2(4000)  :=  '';                             
        
        L_EXRS_CNTE                 VARCHAR2(4000)  :=  '';         
        L_EXRS_RMK_CNTE             VARCHAR2(4000)  :=  '';                                     
        L_EXRM_RMK_CNTE             VARCHAR2(4000)  :=  '';                                     
        L_PT_NO                     VARCHAR2(2000)  :=  '';                 
        L_EXRM_EXM_CTG_CD           VARCHAR2(2000)  :=  '';         
        L_WK_UNIT_CD                VARCHAR2(2000)  :=  '';   

        T_HISTORY_REG_SEQ           NUMBER;        
        V_SAVEFLAG                  VARCHAR2(0001)  :=  '';
        V_CULTURE_CNT_YN            VARCHAR2(0001)  :=  '';
        
    BEGIN
    
        IO_ERRYN  := '';
        IO_ERRMSG := '';        
    
        /**********************************************************************************************************
        ** 미생물 배양 결과 저장
        ** 미생물은 델타 페닉을 하지 않으므로 무조건 'N'를 입력한다.
        ** 결핵은 L4106에 'No Acid Fast Bacilli isolated'        -- Client에서 던져준값
        ** 진균은 L4503에 'No fungus isolated'                   -- Client에서 던져준값
        ** 일반미생믈의 혈액배양은 L4002에 'No WBC, No Organism' -- Client에서 던져준값
        **                         L4017에 'No aerobic or anaerobic bacteria isolated after 7 days' -- 자체작업
        ** 일반미생물의 Positive 처리시는 L4002에 'P' 입력       -- Client에서 던져준값
        **                                Hd_tst_rslt에 날자 입력       -- Client에서 던져준값
        **
        ** posyn = 'X' 이면 그냥 저장
        ** posyn = 'N' 이면 Negative 처리
        ** posyn = 'P' 이면 Positive 처리
        ***********************************************************************************************************/
                   
        /**********************************************************************************************************
        ** 혈액배양 NEGATIVE시에만
        ***********************************************************************************************************/                  
        
        BEGIN
            SELECT SPEX_PRGR_STS_CD
                 , RSLT_BRFG_YN 
                 , SMP_EXRS_CNTE
                 , EXRS_RMK_CNTE
                 , EXRM_RMK_CNTE
                 , PT_NO
                 , EXRM_EXM_CTG_CD
                 , WK_UNIT_CD
              INTO T_SPEX_PRGR_STS_CD
                 , T_RSLT_BRFG_YN
                 , L_EXRS_CNTE
                 , L_EXRS_RMK_CNTE
                 , L_EXRM_RMK_CNTE
                 , L_PT_NO
                 , L_EXRM_EXM_CTG_CD
                 , L_WK_UNIT_CD
              FROM MSELMAID
             WHERE SPCM_NO   = IN_SPCM_NO
               AND EXM_CD    = IN_TST_CD
               AND HSP_TP_CD = IN_HSP_TP_CD  --병원구분
               ;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     IO_ERRYN  := 'Y';
                     IO_ERRMSG := '저장할 배양결과 내역이 없습니다. ' || SQLERRM;
                     RETURN;
    
                WHEN OTHERS  THEN
                     IO_ERRYN  := 'Y';
                     IO_ERRMSG := '배양결과 조회시 에러 발생. ' || SQLERRM;
                     RETURN;
        END;                                         
        
        IF (T_SPEX_PRGR_STS_CD = '3' AND T_RSLT_BRFG_YN = 'Y') THEN
            IO_ERRYN  := 'Y';
            IO_ERRMSG := '배양결과 저장 - 이미 검증 완료된 검체입니다. ' || SQLERRM;
            RETURN;
        END IF; 
        

        BEGIN        
            BEGIN
                -- Blood culture 인터페이스시 양성결과 입력 후 음성으로 대체되지 않도록 체크하기 위한 대상 코드
                SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                  INTO T_BC_TST_YN
                  FROM CCCCCSTE --공통그룹코드상세
                 WHERE COMN_GRP_CD = '966'
                   AND USE_YN      = 'Y'
                   AND DTRL3_NM    = 'BLOOD_CULTURE'
                   AND COMN_CD_NM  = IN_TST_CD;
    
                EXCEPTION
                    WHEN OTHERS  THEN
                        NULL;
            END;
    
            IF T_BC_TST_YN = 'Y' AND IN_POSYN = 'N' AND IN_SPCID = 'SSSSACK' THEN
                BEGIN
    
                    SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                      INTO T_BC_POSI_YN
                      FROM MSELMAID A --접수검사항목결과정보
                     WHERE A.SPCM_NO     = IN_SPCM_NO
                       AND A.EXM_CD      = IN_TST_CD
                       AND SUBSTR(A.HNWR_EXRS_CNTE, LENGTH(A.HNWR_EXRS_CNTE), 1) = 'P'
                       AND A.HSP_TP_CD = IN_HSP_TP_CD  --병원구분
                       ;
    
                EXCEPTION
                    WHEN OTHERS  THEN
                        NULL;
                END;
    
                IF T_BC_POSI_YN = 'Y' THEN
                    RETURN;
                END IF;
            END IF;
        END;
                              
        
        -- 미생물 검사 시작시 검사시작장비정보 업데이트 
        IF IN_POSYN = 'EQUP_CD_UPDATE' THEN
            BEGIN                
                UPDATE MSELMAID
                   SET EXM_STR_DEXM_MDSC_EQUP_CD = IN_EQUIPTYPE
                 WHERE HSP_TP_CD                 = IN_HSP_TP_CD
                   AND SPCM_NO                   = IN_SPCM_NO
                   AND EXM_CD                    = IN_TST_CD
                   ;                           
               EXCEPTION
                   WHEN OTHERS THEN
                        IO_ERRYN  := 'Y';        
                        IO_ERRMSG := '검사 전 장비정보 UPDATE 처리 중 에러 발생. ERRCD = ' || SQLERRM;
                        RETURN;
            END;               

            RETURN;
        END IF;
                              
        

        -- 검사결과 저장
        -- 2021.12.29 HSP : 저장 프로시저 호출로 변경함 -- XSUP.PKG_MSE_LM_EXAMRSLT.SAVE
        
        -- 장비로부터 넘어온 결과값이 파이프라인(|)이 포함되어 있다면 || 이전은 결과에 저장, 이후는 결과비고에 저장한다.        
        IF INSTR(IN_EXRS_CNTE, '|') > 0 THEN
            S_EXRS_CNTE      := SUBSTR(IN_EXRS_CNTE, 1, INSTR(IN_EXRS_CNTE, '|') - 1);
            S_EXRS_RMK_CNTE  := REPLACE(SUBSTR(IN_EXRS_CNTE, INSTR(IN_EXRS_CNTE, '|')), '|', '') ;
        ELSE
            S_EXRS_CNTE      := IN_EXRS_CNTE;
            S_EXRS_RMK_CNTE  := '';
        END IF;
                
        -- 검사결과테이블에 이미 저장된 결과값이 없다면, 장비에서 전송되는 결과 그대로 저장하고, 
        --                          결과값이 있다면, 저장된 결과값 + 장비에서 전송되는 결과값을 저장
        
        -- 검사결과
        IF L_EXRS_CNTE = '' OR L_EXRS_CNTE IS NULL THEN                                                                              
            V_EXRS_CNTE := S_EXRS_CNTE;
        ELSE
            V_EXRS_CNTE := L_EXRS_CNTE || CHR(13) || CHR(10) || S_EXRS_CNTE;
        END IF;        
        
        -- 검사결과비고
--        V_EXRS_RMK_CNTE := S_EXRS_RMK_CNTE;        
        IF L_EXRS_RMK_CNTE = '' OR L_EXRS_RMK_CNTE IS NULL THEN                                                                              
            V_EXRS_RMK_CNTE := S_EXRS_RMK_CNTE;
        ELSE                                      
            IF S_EXRS_RMK_CNTE IS NULL OR S_EXRS_RMK_CNTE = '' THEN
                V_EXRS_RMK_CNTE := L_EXRS_RMK_CNTE;
            ELSE
                V_EXRS_RMK_CNTE := L_EXRS_RMK_CNTE || CHR(13) || CHR(10) || S_EXRS_RMK_CNTE;
            END IF;
        END IF;        
        
        -- 검사실비고
        V_EXRM_RMK_CNTE := L_EXRM_RMK_CNTE;
                          
        
                
        ------------------------------------------------------------------------------------------------------
        -- 이력순번 조회            
        BEGIN
            
            SELECT NVL(MAX(REG_SEQ), 0) + 1
              INTO T_HISTORY_REG_SEQ
              FROM MSELMIFD 
             WHERE HSP_TP_CD = IN_HSP_TP_CD
               AND SPCM_NO = IN_SPCM_NO
             ;
        
        END;
        
        -- 이력저장
        -- 이력저장은 장비에서 검체번호에 해당하지 않는 코드도 추가로 넘겨주기 때문에 결과와 무관하게 이력에 저장함.
        PC_MSE_HISTORY_SAVE
                     ( IN_EQUIPTYPE       -- IN_EQUP 
                     , T_HISTORY_REG_SEQ
                     , IN_TST_CD
                     , L_PT_NO
                     , IN_SPCM_NO            
                     
                     , V_EXRS_CNTE           -- 검사결과
                     , ''                    -- 검체비고내용
                     , V_EXRS_RMK_CNTE       -- 인터페이스비고                                                      
                                      
                     , IN_SPCID --'IF'
                     , IN_HSP_TP_CD
                     , 'INTERFACE'
                     , SYS_CONTEXT('USERENV','IP_ADDRESS')
                     
                     , IO_ERRYN
                     , IO_ERRMSG
                     );        
                            
        -- 장비에서 P(검증)으로 넘어오면, 결과저장시 C(검증)으로 저장하고, P가 아니면 임시(T)로 저장함.
        IF IN_POSYN = 'P' THEN
            V_SAVEFLAG := 'C';
        ELSE
            V_SAVEFLAG := 'T';
            
            -- LMH01 - Blood culture  
            -- 아래 조건일때 자동 중간보고 되도록 함.
            IF IN_TST_CD = 'LMH01' THEN
                IF INSTR(UPPER(REPLACE(V_EXRS_CNTE, ' ', '')), '2DAYS') > 0 THEN
                    V_SAVEFLAG := 'P';
                ELSIF INSTR(UPPER(REPLACE(V_EXRS_CNTE, ' ', '')), 'NOGROWTH') > 0 THEN
                    V_SAVEFLAG := 'P';                                            
                END IF;                
            END IF;                           
        END IF;
                                  

        -- 중간보고로 저장할때, 배양정보가 있다면 임시저장으로 변경
        -- 배양정보가 있다는 것은, 이상이 있는것이니 결과가 나가면 안됨.
        IF IN_TST_CD = 'LMH01' THEN
            IF (    INSTR(UPPER(REPLACE(V_EXRS_CNTE, ' ', '')), '2DAYS') > 0 
                 OR INSTR(UPPER(REPLACE(V_EXRS_CNTE, ' ', '')), '5DAYS') > 0 
                 OR INSTR(UPPER(REPLACE(V_EXRS_CNTE, ' ', '')), 'NOGROWTH') > 0 
               ) 
            THEN
                BEGIN
                    SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                      INTO V_CULTURE_CNT_YN
                      FROM MSELMCRD
                     WHERE HSP_TP_CD = IN_HSP_TP_CD
                       AND SPCM_NO   = IN_SPCM_NO
                       ;        
                    EXCEPTION
                        WHEN OTHERS  THEN     
                            V_CULTURE_CNT_YN := 'Y';
                            V_SAVEFLAG := 'T';
                END;                                
                    
                IF V_CULTURE_CNT_YN = 'Y' THEN
                    V_SAVEFLAG := 'T';
                END IF;
            END IF;                                                                                       
        END IF;                           
        
            
        XSUP.PKG_MSE_LM_EXAMRSLT.SAVE
                     (  V_SAVEFLAG  --'T'                         -- T:임시저장, P:중간, C:검증
                      , L_PT_NO                                   -- 환자번호
                      , IN_SPCM_NO
                      , L_EXRM_EXM_CTG_CD                         -- IN_EXM_CTG_CD       IN      MSELMAID.EXRM_EXM_CTG_CD%TYPE
                      , L_WK_UNIT_CD                              -- IN_WK_UNIT_CD       IN      MSELMAID.WK_UNIT_CD%TYPE
                      , IN_TST_CD                                 -- IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                      , ''                                        -- IN_MIDL_BRFG_CNTE   IN      MSELMAID.MIDL_BRFG_CNTE%TYPE
                      
                      , V_EXRS_CNTE                               -- IN_EXRS_CNTE        IN      MSELMAID.EXRS_CNTE%TYPE
    
                      , ''                                         -- IN_RMK_CNTE         IN      MSELMCED.RMK_CNTE%TYPE
                      , ''                                         -- IN_LMQC_RMK_CNTE    IN      MSELMCED.LMQC_RMK_CNTE%TYPE
                      , V_EXRS_RMK_CNTE                            -- IN_EXRS_RMK_CNTE    IN      MSELMAID.EXRS_RMK_CNTE%TYPE
                      , V_EXRM_RMK_CNTE                            -- IN_EXRM_RMK_CNTE    IN      MSELMAID.EXRM_RMK_CNTE%TYPE
                     
                      , ''                                         -- IN      MSELMAID.DLT_YN%TYPE
                      , ''                                         -- IN      MSELMAID.PNC_YN%TYPE
                      , ''                                         -- IN_CVR_YN         --  IN      MSELMAID.CVR_YN%TYPE
                     
                      , 'IF'                                       -- HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                      , IN_HSP_TP_CD                               -- HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                      , 'INTERFACE'                                -- HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                      , SYS_CONTEXT('USERENV','IP_ADDRESS')        -- HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE

                      , ''                                        -- IN_RSLT_BRFG_CNTE   IN      MSELMAID.RSLT_BRFG_CNTE%TYPE
                     
                      , IO_ERRYN -- IO_ERR_YN           IN OUT  VARCHAR2
                      , IO_ERRMSG --IO_ERR_MSG          IN OUT  VARCHAR2 
                     );

        IF IO_ERRYN = 'Y' THEN
            RETURN;
        END IF;
        


        -- 장비결과저장 관련 컬럼(DEXM_MDSC_EQUP_CD, EQUP_RMK_CNTE, EQUP_RSLT_SND_DTM)
        -- 장비결과저장 항목들은, 현재의 인터페이스 검사결과 저장시점(PKG_MSE_LM_INTERFACE.PC_MSE_INTERFACE_SAVE)에서 저장하며, 검사결과저장 패키지(PKG_MSE_LM_EXAMRSLT.SAVE)에서는 저장하지 않는다.
        
        PC_MSE_UPDATE_EQUP_INFO
        (
          IN_SPCM_NO 
        , IN_TST_CD
        , V_EXRS_CNTE
        
        , IN_EQUIPTYPE -- IN_EQUP
        , ''
        , '' --TO_DATE(IN_ANTC_REQR_DTM, 'YYYY-MM-DD HH24:MI:SS')
        , '' --TT_HNWR_EXRS_CNTE(I)
        
        , 'IF'                                      
        , IN_HSP_TP_CD                              
        , 'INTERFACE'                               
        , SYS_CONTEXT('USERENV','IP_ADDRESS') 
        , IO_ERRYN
        , IO_ERRMSG      
        );
        
        -------------------------------------------------------------------------------------------------------------------
        -- 2022.01.10 SCS :                     
        -- Description : Osmolarity 자동계산
        XSUP.PKG_MSE_LM_EXAMRSLT.SAVE_CALC_OSMO
        ( 'T' -- T:임시, C:확정
        ,  IN_SPCM_NO   
        
        , 'IF'
        , IN_HSP_TP_CD
        , 'INTERFACE' 
        , SYS_CONTEXT('USERENV','IP_ADDRESS') 
         
        , IO_ERRYN
        , IO_ERRMSG 
        );
        -------------------------------------------------------------------------------------------------------------------        
        
        
--
--        BEGIN
--
--            UPDATE MSELMAID --접수검사항목결과정보
--               SET SMP_EXRS_CNTE         = DECODE(SMP_EXRS_CNTE, '', IN_EXRS_CNTE, SMP_EXRS_CNTE || CHR(13) || CHR(10) || IN_EXRS_CNTE)
--                 , SPEX_PRGR_STS_CD      = DECODE(IN_POSYN, 'P', '2', '3')
--                 , RSLT_BRFG_YN          = DECODE(IN_POSYN, 'P', 'N', 'Y')
--                 , DEXM_MDSC_EQUP_CD     = IN_EQUP                            
--                 , DLT_YN   = 'N'
--                 , PNC_YN   = 'N'
--                 , INPT_STF_NO           = IN_SPCID
--                 , RSLT_MDF_DTM          = SYSDATE  
--                 , HNWR_EXRS_CNTE        = DECODE(IN_POSYN, 'P', TO_CHAR(SYSDATE, 'YYYYMMDD') || IN_POSYN,
--                                                            'N', TO_CHAR(SYSDATE, 'YYYYMMDD') || IN_POSYN, HNWR_EXRS_CNTE)     
--                 , LSH_DTM               = SYSDATE
--                 , LSH_PRGM_NM           = 'INTERFACE'
--                 , LSH_IP_ADDR           = SYS_CONTEXT('USERENV','IP_ADDRESS')
--             WHERE SPCM_NO = IN_SPCM_NO
--               AND EXM_CD  = IN_TST_CD  
--               AND HSP_TP_CD = IN_HSP_TP_CD  --병원구분
--            ;
--
--            IF SQL%ROWCOUNT = 0 THEN
--               IO_ERRYN  := 'Y';
--               IO_ERRMSG := '저장할 염색화면에서 배양결과 내역이 없습니다(1). ERRCD = ' || TO_CHAR(SQLCODE);
--               RETURN;
--            END IF;
--            
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                     IO_ERRYN  := 'Y';
--                     IO_ERRMSG := '저장할 염색화면에서 배양결과 내역이 없습니다. ERRCD = ' || TO_CHAR(SQLCODE);
--                     RETURN;
--    
--                WHEN OTHERS  THEN
--                     IO_ERRYN  := 'Y';
--                     IO_ERRMSG := '염색화면에서 배양결과 NEGATIVE 저장 시 에러 발생. #1 ERRCD = ' || TO_CHAR(SQLCODE);                 
--                     RETURN;
--        END;
--        
--
--        IF ( IN_TST_CD != 'L4002') AND (IN_POSYN = 'N') THEN
--            /* 혈액배양 NEGATIVE시에만 */
----             T_TSTCD := 'L4017';
----             T_RSLT  := 'NO AEROBIC OR ANAEROBIC BACTERIA ISOLATED AFTER 7 DAYS';
--
--            BEGIN
--
--              UPDATE MSELMAID --접수검사항목결과정보
--                 SET EXRS_CNTE         = T_RSLT
--                   , SPEX_PRGR_STS_CD  = DECODE(IN_POSYN, 'P', '2', '3')
--                   , RSLT_BRFG_YN      = DECODE(IN_POSYN, 'P', 'N', 'Y')
--                   , DLT_YN   = 'N'
--                   , PNC_YN   = 'N'
--                   , INPT_STF_NO       = IN_SPCID
--                   , RSLT_MDF_DTM      = SYSDATE --TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI')
--                   , HNWR_EXRS_CNTE    = DECODE(IN_POSYN, 'P', TO_CHAR(SYSDATE, 'YYYYMMDD') || IN_POSYN,
--                                                          'N', TO_CHAR(SYSDATE, 'YYYYMMDD') || IN_POSYN, HNWR_EXRS_CNTE)      
--                   , LSH_DTM           = SYSDATE    --2015-06-24 곽수미 추가
--              WHERE SPCM_NO = IN_SPCM_NO
--                AND EXM_CD  = T_TSTCD  
--                AND HSP_TP_CD = IN_HSP_TP_CD  --병원구분
--                ;
--
----            IF SQL%ROWCOUNT = 0 THEN
----                IO_ERRYN  := 'Y';
----                IO_ERRMSG := '저장할 염색화면에서 배양결과 내역이 없습니다(2). ERRCD = ' || TO_CHAR(SQLCODE);
----                RETURN;
----            END IF;
--        
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                     IO_ERRYN  := 'Y';
--                     IO_ERRMSG := '저장할 염색화면에서 배양결과 내역이 없습니다(2). ERRCD = ' || TO_CHAR(SQLCODE);
--                     RETURN;
--
--                WHEN OTHERS  THEN
--                     IO_ERRYN  := 'Y';
--                     IO_ERRMSG := '염색화면에서 배양결과 NEGATIVE 저장 시 에러 발생. #2 ERRCD = ' || TO_CHAR(SQLCODE);
--                     RETURN;
--           END;
--        END IF;
--
--

--        --2010.08.10 방수석 추가 미생물 BLOOD CULTURE장비인터페이스인 경우 중간보고, 최종보고를 가른다.
--        IF T_BC_TST_YN = 'Y' AND IN_POSYN = 'N' AND IN_SPCID = 'PPPPP' THEN
--            IF INSTR(IN_EXRS_CNTE, '최종보고') > 0 THEN
--                T_BC_TST_STAT := '3';
--            ELSE
--                T_BC_TST_STAT := '-';
--            END IF;
--
--            BEGIN
--
--                UPDATE MSELMAID --접수검사항목결과정보
--                   SET SPEX_PRGR_STS_CD = T_BC_TST_STAT
--                     , RSLT_BRFG_YN     = 'Y' 
--                     , LSH_DTM          = SYSDATE      --2015-06-24 곽수미 추가
--                 WHERE SPCM_NO          = IN_SPCM_NO  
--                   AND HSP_TP_CD        = IN_HSP_TP_CD  --병원구분 
--                   AND EXM_CD           = T_TSTCD
--                   ;
--
--            IF SQL%ROWCOUNT = 0 THEN
--                IO_ERRYN  := 'Y';
--                IO_ERRMSG := '혈액배양 검사 결과 내역이 없습니다. ERRCD = ' || TO_CHAR(SQLCODE);
--                RETURN;
--            END IF;
--            
--            EXCEPTION
--                 WHEN NO_DATA_FOUND THEN
--                      IO_ERRYN  := 'Y';
--                      IO_ERRMSG := '혈액배양 검사 결과 내역이 없습니다. ERRCD = ' || TO_CHAR(SQLCODE);
--                      RETURN;
--
--                 WHEN OTHERS  THEN
--                      IO_ERRYN  := 'Y';
--                      IO_ERRMSG := '혈액배양결과 NEGATIVE 저장 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                      RETURN;
--            END;
--        ELSE
--            /*************************************************************************************************************
--            ** 일반미생물의 POSITIVE 처리시는 혈액배양까지 보고되지는 않는다.
--            ** 따라서 L4002이면서 결과가 'P' 이면 다음 UPDATE 는 무시
--            ** 결핵,진균의 L4106,L4503의 POSITIVE 처리시는 혈액배양과 동일하게 한다.
--            **************************************************************************************************************/
--            IF ((IN_TST_CD != 'L4002') AND (IN_TST_CD != 'L4106') AND (IN_TST_CD = 'L4503')) OR (IN_POSYN != 'P') THEN
--               BEGIN
--
--                    UPDATE MSELMAID --접수검사항목결과정보
--                       SET SPEX_PRGR_STS_CD = '3'
--                         , RSLT_BRFG_YN     = 'Y'
--                         , LSH_DTM          = SYSDATE    --2015-06-24 곽수미 추가
--                     WHERE SPCM_NO          = IN_SPCM_NO  
--                       AND EXM_CD           = IN_TST_CD             -- 2018.07.19 
--                       AND HSP_TP_CD        = IN_HSP_TP_CD      -- 병원구분
--                       ;
--
--               IF SQL%ROWCOUNT = 0 THEN
--                   IO_ERRYN  := 'Y';
--                   IO_ERRMSG := '저장할 염색화면에서 배양결과 내역이 없습니다. ERRCD = ' || TO_CHAR(SQLCODE);
--                   RETURN;
--               END IF;
--            
--               EXCEPTION
--                    WHEN NO_DATA_FOUND THEN
--                         IO_ERRYN  := 'Y';
--                         IO_ERRMSG := '저장할 염색화면에서 배양결과 내역이 없습니다. ERRCD = ' || TO_CHAR(SQLCODE);
--                         RETURN;
--
--                    WHEN OTHERS  THEN
--                         IO_ERRYN  := 'Y';
--                         IO_ERRMSG := '염색화면에서 배양결과 NEGATIVE 저장 시 에러 발생. #3 ERRCD = ' || TO_CHAR(SQLCODE);
--                         RETURN;
--               END;
--            END IF;
--        END IF;
--               
        
        
--        ---2018.01.24 결핵에 액체일경우에서 생성요청 반영
--        IF (IN_TST_CD = 'L41062') THEN
--        BEGIN          
--                   
--            BEGIN    
--                UPDATE MSELMCRD
--                   SET LN_SEQ           = '1'                                                       --줄순번
--                     , LABM_NEPO_TP_CD  = '1'                                              --진단검사의학음성양성구분코드
--                     , NEPO_SEQ         = '1'                                                    --음성양성순번
--                     , CLMD_CD          = '01'
--                     , MVM_CD           = '00'
--                     , MVRT_CNTE        = 'No growth of Mycobacterium after 6wks'
--                 WHERE SPCM_NO          = IN_SPCM_NO
--                   AND EXM_CD           = IN_TST_CD
--                   AND HSP_TP_CD        = IN_HSP_TP_CD
--                   ;
----              SELECT COUNT(*) CNT
----                INTO T_CNT    
----                FROM MSELMCRD
----               WHERE SPCM_NO     = IN_SPCM_NO
----                 AND HSP_TP_CD     = IN_HSP_TP_CD
----                 AND EXM_CD     = IN_TST_CD
----                ;                       
--            IF SQL%ROWCOUNT = 0 THEN   --IF (T_CNT = '0') THEN
--                BEGIN 
--                    INSERT INTO MSELMCRD ( 
--                               HSP_TP_CD                                                    --병원구분코드
--                             , SPCM_NO                                                      --검체번호
--                             , EXM_CD                                                       --검사코드
--                             , LN_SEQ                                                       --줄순번
--                             , LABM_NEPO_TP_CD                                              --진단검사의학음성양성구분코드
--                             , NEPO_SEQ                                                     --음성양성순번
--                             , ACPT_DT                                                      --접수일자
--                             , EXM_ACPT_NO                                                  --검사접수번호
--                             , CLMD_CD                                                      --배지코드
--                             , MCB_EQUP_SEQ                                                 --미생물장비순번
--                             , PRCC_RSLT_CNTE                                               --성상결과내용
--                             , MVM_CD                                                       --동정코드
--                             , MVRT_CNTE                                                    --동정결과내용
--                             , SRUM_CLS_CNTE                                                --혈청유형내용
--                             , STRG_CNTE                                                    --보관내용
--                             , CLY_CNT_CNTE                                                 --집락수내용
--                             , ADD_EITM_CNTE                                                --추가검사항목내용
--                             , REF_CLMD_CD                                                  --참고배지코드
--                             , REF_LABM_NEPO_TP_CD                                          --참고진단검사의학음성양성구분코드
--                             , REF_NEPO_SEQ                                                 --참고음성양성순번
--                             , CLY_SEQ                                                      --집락순번
--                             , CLMD_ANTN_CNTE                                               --배지주석내용
--                             , TB_CLMD_KND_CNTE                                             --결핵배지종류내용
--                             , LQD_CLMD_MVRT_CNTE                                           --액체배지동정결과내용
--                             , LQD_CLMD_RSLT_CNTE                                           --액체배지결과내용
--                             , MVRT_SLD_CLMD_INPT_CNTE                                      --동정결과고체배지입력내용
--                             , MVRT_LQD_CLMD_INPT_CNTE                                      --동정결과액체배지입력내용
--                             , PURT_INCB_YN                                                 --순수배양여부
--                             , FSR_DTM                                                      --최초등록일시
--                             , FSR_STF_NO                                                   --최초등록직원번호
--                             , FSR_PRGM_NM                                                  --최초등록프로그램명
--                             , FSR_IP_ADDR                                                  --최초등록IP주소
--                             , LSH_DTM                                                      --최종변경일시
--                             , LSH_STF_NO                                                   --최종변경직원번호
--                             , LSH_PRGM_NM                                                  --최종변경프로그램명
--                             , LSH_IP_ADDR                                                  --최종변경IP주소  
--                             )
--                        SELECT IN_HSP_TP_CD 
--                             , SPCM_NO 
--                             , EXM_CD
--                             , '1'
--                             , '1'
--                             , '1'
--                             , TO_CHAR(ACPT_DTM, 'YYYY-MM-DD')
--                             , EXM_ACPT_NO
--                             , '01'
--                             , ''                     -- MCB_EQUP_SEQ
--                             , ''                    -- PRCC_RSLT_CNTE
--                             , '00'
--                             , 'No growth of Mycobacterium after 6wks'
--                             , ''                    -- SRUM_CLS_CNTE
--                             , ''                    -- STRG_CNTE
--                             , ''                   -- CLY_CNT_CNTE
--                             , ''                    -- ADD_EITM_CNTE
--                             , ''                    -- REF_CLMD_CD
--                             , ''                     -- REF_LABM_NEPO_TP_CD
--                             , ''                    -- REF_NEPO_SEQ
--                             , ''                    -- CLY_SEQ
--                             , ''                      -- CLMD_ANTN_CNTE
--                             , ''                    -- TB_CLMD_KND_CNTE
--                             , ''                    -- LQD_CLMD_MVRT_CNTE
--                             , ''                    -- LQD_CLMD_RSLT_CNTE
--                             , ''                   -- MVRT_SLD_CLMD_INPT_CNTE
--                             , ''                    -- MVRT_LQD_CLMD_INPT_CNTE
--                             , ''                    -- PURT_INCB_YN
--                             , SYSDATE
--                             , IN_SPCID
--                             , 'ACK PC_MSE_SAVE_CULTRESULT'
--                             , SYS_CONTEXT('USERENV','IP_ADDRESS')  
--                             , SYSDATE
--                             , IN_SPCID
--                             , 'ACK PC_MSE_SAVE_CULTRESULT'
--                             , SYS_CONTEXT('USERENV','IP_ADDRESS')
--                          FROM MSELMAID
--                         WHERE SPCM_NO         = IN_SPCM_NO
--                           AND HSP_TP_CD     = IN_HSP_TP_CD
--                           AND EXM_CD         = IN_TST_CD
--                           ;   
--                    EXCEPTION
--                        WHEN OTHERS THEN
--                            IO_ERRYN  := 'Y';
--                            IO_ERRMSG := 'PC_MSE_SAVE_CULTRESULT insert MSELMCRD L41062 코드 생성중 오류 발생. ErrCd = ' || TO_CHAR(SQLCODE);
--                            RETURN;
--                END;
--            END IF;   
--            END;
--        END; 
--        END IF;
--        

--        /*************************************************************************************************************
--        ** 양성인 경우 양성리스트에 저장한다.
--        **************************************************************************************************************/
--        IF (IN_POSYN = 'P' OR IN_POSYN = 'N') THEN
--           /**********************************************************************************************************
--           ** 양성인 경우 양성리스트에 생성전 조회한다.
--           ***********************************************************************************************************/
--           BEGIN
--
--                SELECT /*+ FIRST_ROWS */
--                       SUBSTR(TO_CHAR(SYSDATE,'YYYYMMDD') || LPAD(NVL(MAX(TO_NUMBER(A.PSTV_ACPT_NO)) + 1,'1'),3,'0'),9,3)
--                  INTO T_ACPTNO
--                  FROM MSELMPLD A --미생물양성리스트정보
--                     , MSELMCED B --채취검체정보
--                 WHERE A.ACPT_DT         = TRUNC(SYSDATE)
--                   AND A.HSP_TP_CD       = B.HSP_TP_CD
--                   AND A.EXM_CD          = IN_TST_CD
--                   AND A.LABM_NEPO_TP_CD = IN_POSYN
--                   AND B.SPCM_NO         = IN_SPCM_NO  
--                   AND A.HSP_TP_CD = IN_HSP_TP_CD  --병원구분
--                   AND B.HSP_TP_CD = IN_HSP_TP_CD  --병원구분
--                   ;
--
--           EXCEPTION
--                WHEN OTHERS  THEN
--                     IO_ERRYN  := 'Y';
--                     IO_ERRMSG := '1 - 양성리스트 조회 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                     RETURN;
--           END;
--
--           BEGIN
--
--                SELECT SPCM_NO
--                  INTO T_SPCNO2
--                  FROM MSELMPLD --미생물양성리스트정보
--                 WHERE SPCM_NO = IN_SPCM_NO 
--                   AND HSP_TP_CD = IN_HSP_TP_CD  --병원구분
--                 ;
--
--    ------------------------------------------------------------------------------------------------------------------------
--    --       exception
--    --            when others  then
--    --                 io_erryn  := 'Y';
--    --                 io_errmsg := '2 - 양성리스트내역 조회 시 에러 발생. ErrCd = ' || to_char(sqlcode);
--    --                 return;
--    ------------------------------------------------------------------------------------------------------------------------
--                      
--             EXCEPTION
--                  WHEN  NO_DATA_FOUND THEN
--             /******************************************************************************************************
--             ** 양성인 경우 양성리스트에 생성한다.
--             *******************************************************************************************************/
--                     BEGIN
--
--                        INSERT INTO MSELMPLD --미생물양성리스트정보
--                          (
--                            SPCM_NO
--                          , EXM_CD
--                          , INPT_SEQ
--                          , HSP_TP_CD
--                          , ACPT_DT
--                          , PSTV_ACPT_NO
--                          , LABM_NEPO_TP_CD
--                          , FSR_STF_NO
--                          , FSR_DTM
--                          , FSR_PRGM_NM
--                          , FSR_IP_ADDR
--                          , LSH_STF_NO
--                          , LSH_DTM
--                          , LSH_PRGM_NM
--                          , LSH_IP_ADDR
--                          )
--                            SELECT /*+ FIRST_ROWS */
--                              A.SPCM_NO
--                            , IN_TST_CD
--                            , '1'
--                            , A.HSP_TP_CD
--                            , TRUNC(SYSDATE)
--                            , T_ACPTNO
--                            , IN_POSYN
--                            , 'SNUBH' FSR_STF_NO
--                            , SYSDATE FSR_DTM
--                            , 'FSR'   FSR_PRGM_NM
--                            , SYS_CONTEXT('USERENV','IP_ADDRESS')  FSR_IP_ADDR
--                            , 'SNUBH' LSH_STF_NO
--                            , SYSDATE LSH_DTM
--                            , 'LSH' LSH_PRGM_NM
--                            , SYS_CONTEXT('USERENV','IP_ADDRESS')  LSH_IP_ADDR
--                         FROM MSELMCED A --채취검체정보
--                        WHERE A.SPCM_NO = IN_SPCM_NO  
--                          AND A.HSP_TP_CD = IN_HSP_TP_CD  --병원구분
--                          ;
--
--                     EXCEPTION
--                          WHEN DUP_VAL_ON_INDEX  THEN
--                               IO_ERRYN  := 'Y';
--                               IO_ERRMSG := '양성리스트 생성시 중복오류 발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                               RETURN;
--
--                          WHEN OTHERS  THEN
--                               IO_ERRYN  := 'Y';
--                               IO_ERRMSG := '양성리스트 생성시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                               RETURN;
--                     END;
--           END;
--        END IF;             


        --2010.08.10 방수석 추가 미생물 Blood Culture장비인터페이스인 경우 중간보고, 최종보고를 가른다.   
-- 2018.01.26
--        if t_bc_tst_yn = 'Y' and in_posyn = 'N' and IN_SPCID = 'PPPPP' then
--            if t_bc_tst_stat = '3' then
--                begin
--                    PC_MSE_STATUS( IN_SPCM_NO
--                                 , IN_SPCID
--                                 , SYSDATE
--                                 , 'INTERFACE'
--                                 , SYS_CONTEXT('USERENV','IP_ADDRESS')
--                                 , IN_HSP_TP_CD  --병원구분
--                                 , io_erryn
--                                 , io_errmsg ) ;
--                    if io_erryn = 'Y' then
--                       io_erryn  := 'Y';
--                       io_errmsg := '결과 저장중 상태 변경하는 함수(PC_MSE_STATUS) 호출1... 시 에러 발생. ErrCd = ' || to_char(sqlcode);
--                       return;
--                    end if;
--                end;
--            else
--                begin                    
--                    PC_MSE_STATUS_CULT( IN_SPCM_NO
--                                      , '2'
--                                      , 'PPPPP'                              -- 2013.01.21 동서시스템 이희승 - HIS_STF_NO                                      
----                                      , '08'                                 -- 2013.01.21 동서시스템 이희승 - HIS_HSP_TP_CD
--                                      , IN_HSP_TP_CD
--                                      , 'LSH'                                -- 2013.01.21 동서시스템 이희승 - HIS_PRGM_NM
--                                      , SYS_CONTEXT('USERENV','IP_ADDRESS')  -- 2013.01.21 동서시스템 이희승 - HIS_IP_ADDR
--                                      , io_erryn
--                                      , io_errmsg ) ;
--                                   
--                    if io_erryn = 'Y' then
--                       io_erryn  := 'Y';
--                       io_errmsg := '결과 저장중 상태 변경하는 함수(PC_MSE_STATUS_CULT) 호출... 시 에러 발생. #1 ErrDesc = ' || io_errmsg ;
--                       return;
--                    end if;
--                end;
--            end if;
--        else
--            /*********************************************************************************************************
--            ** 상태를 변경한다. SL_STATUS.PC의 Source
--            **********************************************************************************************************/
--            if ((IN_TST_CD != 'L4002') and (IN_TST_CD != 'L4106') and (IN_TST_CD = 'L4503')) or (in_posyn != 'P') then
--                begin
--                    PC_MSE_STATUS( IN_SPCM_NO
--                                 , IN_SPCID
--                                 , SYSDATE
--                                 , 'INTERFACE'
--                                 , SYS_CONTEXT('USERENV','IP_ADDRESS')
--                                 , IN_HSP_TP_CD 
--                                  , io_erryn
--                                  , io_errmsg ) ;
--                    if io_erryn = 'Y' then
--                       io_erryn  := 'Y';
--                       io_errmsg := '결과 저장중 상태 변경하는 함수(PC_MSE_STATUS) 호출2... 시 에러 발생. ErrCd = ' || to_char(sqlcode);
--                       return;
--                    end if;
--                end;
--            end if;
--        end if;
--
--        /*********************************************************************************************************
--        ** 상태를 변경한다. 2007.12.10 방수석 추가  Blood Culture시 중간보고 상태변경 처리건
--        **********************************************************************************************************/
--        if ((IN_TST_CD = 'L4027') and (in_posyn = 'P')) then
--            begin
--                PC_MSE_STATUS_CULT( IN_SPCM_NO
--                                  , '2'
--                                  , 'PPPPP'                              -- 2013.01.21 동서시스템 이희승 - HIS_STF_NO                                      
----                                  , '08'                                 -- 2013.01.21 동서시스템 이희승 - HIS_HSP_TP_CD
--                                  , IN_HSP_TP_CD
--                                  , 'LSH'                                -- 2013.01.21 동서시스템 이희승 - HIS_PRGM_NM
--                                  , SYS_CONTEXT('USERENV','IP_ADDRESS')  -- 2013.01.21 동서시스템 이희승 - HIS_IP_ADDR
--                                  , io_erryn
--                                  , io_errmsg ) ;
--                
--                if io_erryn = 'Y' then
--                   io_erryn  := 'Y';
--                   --io_errmsg := '결과 저장중 상태 변경하는 함수(PC_MSE_STATUS_CULT) 호출... 시 에러 발생. ErrCd = ' || SUBSTR(SQLERRM,10,100);
--                   io_errmsg := '결과 저장중 상태 변경하는 함수(PC_MSE_STATUS_CULT) 호출... 시 에러 발생. #2 ErrDesc = ' || io_errmsg ;
--                   return;
--                end if;
--            end;
--        end if;

        --2009.05.15 방수석 추가 검사결과 이력관리 모듈 추가
        BEGIN
            PC_MSE_MCBTXTBRFGHST( IN_SPCM_NO
                                , IN_TST_CD
                                 , 'PPPPP'                               -- 2013.01.21 동서시스템 이희승 - HIS_STF_NO
                                 , IN_HSP_TP_CD
                                 , 'LSH'                                 -- 2013.01.21 동서시스템 이희승 - HIS_PRGM_NM
                                 , SYS_CONTEXT('USERENV','IP_ADDRESS')   -- 2013.01.21 동서시스템 이희승 - HIS_IP_ADDR
                                , IO_ERRYN
                                , IO_ERRMSG );
        EXCEPTION
            WHEN  OTHERS  THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := '결과 이력 관리 함수(PC_MSE_MCBTXTBRFGHST) 호출... 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);
                RETURN;
        END;
        
        
--        BEGIN
--            
--            -- 2018.02.09 미생물 (L40, L41) 인터페이스 전송시 중간보고이면서 검사결과관리에 보기에 요청
--            UPDATE MSELMAID
--               SET SPEX_PRGR_STS_CD = '2'
--                 , RSLT_BRFG_YN     = 'Y'
--             WHERE SPCM_NO          = IN_SPCM_NO
--               AND HSP_TP_CD        = IN_HSP_TP_CD
--               AND EXM_CD           = IN_TST_CD
--               AND MED_EXM_CTG_CD IN ('L40','L41')
--               AND SPEX_PRGR_STS_CD <> '3'
--               AND RSLT_BRFG_YN <> 'Y'
--               ;
--                       
--        END;
--                
--        -- 2018.04.19 'L4017' 결과보고반영하기
--        IF ( IN_TST_CD = 'L4017') AND (IN_POSYN = 'N') THEN   
--        BEGIN
--            BEGIN
--            
--                UPDATE MSELMCED
--                   SET EXM_PRGR_STS_CD      = 'N'
--                     , BRFG_DTM             = SYSDATE  
--                     , LSH_DTM              = SYSDATE     
--                     , LSH_PRGM_NM          = 'ACK PC_MSE_SAVE_CULTRESULT' 
--                     , LSH_IP_ADDR          = SYS_CONTEXT('USERENV','IP_ADDRESS') 
--                 WHERE SPCM_NO              = IN_SPCM_NO
--                   AND HSP_TP_CD            = IN_HSP_TP_CD     -- 병원구분    
--                   AND EXM_PRGR_STS_CD      <> 'N'          -- 결과보고 안된것만
--                  ;
--            END;
--                        
--            -- 처방테이블 저장
--            BEGIN
--                UPDATE /*+ XSUP.PC_MSE_EXM_RESULTUPDATE */
--                       MOOOREXM
--                   SET EXM_PRGR_STS_CD     = 'N'
--                     , BRFG_DTM            = SYSDATE
--                     , BRFG_STF_NO         = NVL(IN_SPCID, 'HISMS')
--                     , LSH_STF_NO          = NVL(IN_SPCID, 'HISMS')
--                     , LSH_DTM             = SYSDATE
--                     , LSH_PRGM_NM         = 'ACK PC_MSE_SAVE_CULTRESULT'
--                     , LSH_IP_ADDR         = SYS_CONTEXT('USERENV','IP_ADDRESS')  
--                 WHERE SPCM_PTHL_NO     = IN_SPCM_NO
--                   AND ODDSC_TP_CD      = 'C'  
--                   AND HSP_TP_CD        = IN_HSP_TP_CD
--                   AND ORD_CD           = IN_TST_CD
--                   AND EXM_PRGR_STS_CD <> 'N'                    -- 결과보고 안된것만
--                ;
--                
--                EXCEPTION
--                    WHEN OTHERS THEN
--                        IO_ERRYN  := 'Y';
--                        IO_ERRMSG := '오더내역 UPDATE 중 에러 발생 ERRCODE = ' || TO_CHAR(IN_SPCM_NO);
--                    RETURN;
--            END;
--            
--        END;
--        END IF;
--                        

        /***************2019-04-04 예강이법 추가.********************/     
--        IF XSUP.FT_MSE_B_NAME('ERR', '013', IN_HSP_TP_CD) = 'Y' THEN
--            BEGIN
--                 XSUP.PC_MSE_RSLT_HISTORY_SAVE( IN_SPCM_NO
--                                              , IN_SPCID
--                                              , 'ACK PC_MSE_SAVE_CULTRESULT'
--                                                 , SYS_CONTEXT('USERENV','IP_ADDRESS') 
--                                              , IN_HSP_TP_CD
--                                                 , IO_ERRYN
--                                              , IO_ERRMSG );
--            
--            EXCEPTION
--                 WHEN  OTHERS  THEN
--                       IO_ERRYN  := 'Y';
--                       IO_ERRMSG := '결과 저장중 이력 저장시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                       RETURN;
--               END;
--        END IF;
        
    END PC_MSE_SAVE_CULTRESULT;
                
    
    
    /**********************************************************************************************
    *    서비스이름  : 
    *    최초 작성일 : 2017.12.02
    *    최초 작성자 :  
    *    DESCRIPTION : 사용자조회 
    **********************************************************************************************/
    PROCEDURE PC_MSE_USER_SELECT (   IN_STF_NO          IN   VARCHAR2           -- 사번
                                   , IN_PWD             IN   VARCHAR2            -- 패스워드
                                   , IN_HSP_TP_CD       IN   VARCHAR2           -- 병원구분
                                   , OUT_CURSOR         OUT  RETURNCURSOR   )
    IS
    
    --변수선언
    WK_CURSOR            RETURNCURSOR ; 
    V_PWD                VARCHAR2(4000):= IN_PWD;      
            
    BEGIN       
    
            IF V_PWD = '' OR V_PWD IS NULL THEN
                BEGIN         
                    OPEN WK_CURSOR FOR
                    
                            SELECT STF_NO
                                 , KOR_SRNM_NM 
                              FROM CNLRRUSD
                             WHERE STF_NO            = IN_STF_NO
                               AND HSP_TP_CD         = IN_HSP_TP_CD        -- 병원구분
                             ;  
                                  
                        OUT_CURSOR := WK_CURSOR ;
                    --예외처리
                  EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_USER_SELECT 사용자 조회 오류발생' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
                END ; 
                
                RETURN;
            END IF;
    
            BEGIN         
                OPEN WK_CURSOR FOR
                
                        SELECT DECODE(IN_STF_NO, STF_NO, 'TRUE', 'FASLE') STF_NO
                             , KOR_SRNM_NM 
                          FROM CNLRRUSD
                         WHERE STF_NO            = IN_STF_NO
                           AND SEC_LGIN_PWD      = DAMO.HASH_STR_DATA(IN_PWD)
                           AND HSP_TP_CD         = IN_HSP_TP_CD        -- 병원구분
                         ;  
                              
                    OUT_CURSOR := WK_CURSOR ;
                --예외처리
              EXCEPTION
                WHEN OTHERS THEN
                     RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_USER_SELECT 사용자 조회 오류발생' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END ; 
        
        
    END PC_MSE_USER_SELECT;

    /**********************************************************************************************
    *    서비스이름  : 
    *    최초 작성일 : 2017.12.05
    *    최초 작성자 :  
    *    DESCRIPTION : 인터페이스 검사장비 조회  
    **********************************************************************************************/
    PROCEDURE PC_MSE_LM_EQU_SELECT ( IN_HSP_TP_CD       IN   VARCHAR2           -- 병원구분
                                   , IN_SCLS_COMN_CD      IN   VARCHAR2            -- 장비코드
                                   , OUT_CURSOR         OUT  RETURNCURSOR   )
    IS
--         CNT         NUMBER(5)                         := 0;        -- 외래예약 건수
    --변수선언
     WK_CURSOR                 RETURNCURSOR ; 
            
        BEGIN       
            BEGIN         
                OPEN WK_CURSOR FOR
                                  
                        SELECT SCLS_COMN_CD
                             , SCLS_COMN_CD_NM
                             , TH1_RMK_CNTE
                             , TH2_RMK_CNTE 
                             , TH3_RMK_CNTE 
                             , HSP_TP_CD
                          FROM MSELMSID
                         WHERE LCLS_COMN_CD = 'EQU'
                           AND USE_YN = 'Y'  
                           AND SCLS_COMN_CD = IN_SCLS_COMN_CD
                           AND HSP_TP_CD = IN_HSP_TP_CD        -- 병원구분
                         ;  
                              
                    OUT_CURSOR := WK_CURSOR ;
                --예외처리
              EXCEPTION
                WHEN OTHERS THEN
                     RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_LM_EQU_SELECT 검사장비 조회 오류발생' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END ; 
        
        
    END PC_MSE_LM_EQU_SELECT;   
    
                                

    /**********************************************************************************************
    *    서비스이름  : PC_MSE_CULTURE_INTERFACE
    *    최초 작성일 : 2017.12.12
    *    최초 작성자 : ezCaretech
    *    Description : 미생물 동정장비인터페이스(날짜 조회)
    **********************************************************************************************/
    PROCEDURE PC_MSE_MICROBE_SELECT ( IN_SDTE        IN   VARCHAR2              -- 시작일자
                                    , IN_EDTE        IN   VARCHAR2           -- 종료일자
                                    , IN_HSP_TP_CD   IN   VARCHAR2           -- 병원구분
                                    , OUT_CURSOR     OUT  RETURNCURSOR )
    IS
        --변수선언
        WK_CURSOR                 RETURNCURSOR ;
    BEGIN
        BEGIN
            --BODY
            OPEN WK_CURSOR FOR

                 SELECT /*+ INDEX(A MSELMAID_SI03) PC_MSE_CULTURE_INTERFACE */
                        V.PT_NO                                        PT_NO
                      , FT_MSE_NAME_P(A.PT_NO,A.HSP_TP_CD)             PT_NM
--                      , TO_CHAR(I.ACPT_DT, 'YYMMDD')                   ACPT_DT
                      , I.ACPT_DT                                      ACPT_DT
                      , I.EXM_ACPT_NO                                  EXM_ACPT_NO
                      , I.SPCM_NO                                      SPCM_NO
                      , I.EXM_CD                                       EXM_CD
                      , FT_MSE_NAME_C(I.EXM_CD, I.HSP_TP_CD)           EXM_NM
                      , I.LN_SEQ                                       LN_SEQ
                      , I.CLMD_CD                                      CLMD_CD
                      , I.LABM_NEPO_TP_CD                              LABM_NEPO_TP_CD
                      , I.CLY_SEQ                                      CLY_SEQ
                      , I.MCB_EQUP_SEQ                                 MCB_EQUP_SEQ
                      , I.PRCC_RSLT_CNTE                               PRCC_RSLT_CNTE
                      , I.MVM_CD                                       MVM_CD
                      , I.MVRT_CNTE                                    MVRT_CNTE
                      , I.CLY_CNT_CNTE                                 CLY_CNT_CNTE
                      , I.ADD_EITM_CNTE                                ADD_EITM_CNTE
                      , A.TH1_SPCM_CD                                  TH1_SPCM_CD
                      , V.MED_DEPT_CD                                  MED_DEPT_CD
                      , V.PBSO_DEPT_CD                                 PBSO_DEPT_CD  
                      , P.PT_BRDY_DT                                   PT_BRDY_DT
                      , P.SEX_TP_CD                                    SEX_TP_CD
                   FROM MSELMAID A --접수검사항목결과정보
                      , MSELMCRD I --배지별배양결과정보
                      , MSELMCED V --채취검체정보
                      , PCTPCPAM_DAMO P -- 환자기본
                  WHERE I.ACPT_DT BETWEEN TO_DATE(REPLACE(IN_SDTE, '-', ''),'YYYYMMDD') AND TO_DATE(REPLACE(IN_EDTE, '-', ''),'YYYYMMDD') + 0.99999 
                    AND A.EXRM_EXM_CTG_CD  IN ('LM')
                    AND I.SPCM_NO         = A.SPCM_NO
                    AND V.SPCM_NO         = A.SPCM_NO
                    AND A.HSP_TP_CD       = IN_HSP_TP_CD
                    AND I.HSP_TP_CD       = A.HSP_TP_CD
                    AND V.HSP_TP_CD       = A.HSP_TP_CD
                    AND V.PT_NO           = P.PT_NO
                  ORDER BY I.SPCM_NO, I.LN_SEQ
                  ;

                  OUT_CURSOR := WK_CURSOR ;

            --예외처리
          EXCEPTION
                WHEN OTHERS THEN
                     RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_CULTURE_INTERFACE' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
        END ;
    END PC_MSE_MICROBE_SELECT;



    /**********************************************************************************************
    *    서비스이름  : PC_MSE_CULTURE_INTERFACE2
    *    최초 작성일 : 2017.12.12
    *    최초 작성자 : ezCaretech
    *    Description : 미생물 장비인터페이스 - 배양결과정보 조회 (접수번호로 조회)
    *                  : 2021.12.01 홍승표 - 전남대 : 검사실에서 무조건 배양상태, 배지종류, NO를 무조건 입력 후 인터페이스 진행함.
    *                                       전남대 : 파라메터 IN_ACPT_NO  정보 변경 기존의 년월일+접수번호 방식에서 처방슬립+년도+접수번호로 변경함.
    *
    *                    VAR OUT_CURSOR REFCURSOR;
    *                    EXEC XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_MICROBE_SELECT2 (  '202112150013'
    *                                                                          ,  '1'
    *                                                                          , '01'
    *                                                                          , :OUT_CURSOR
    *                                                                          );
    *
    *                                       
    **********************************************************************************************/
    PROCEDURE PC_MSE_MICROBE_SELECT2 ( IN_ACPT_NO     IN   VARCHAR2         -- 접수번호  -- 202112150013(년월일+접수번호) --> LMH2021-000001(LMH+년도++'_'+접수번호)
                                     , IN_LN_SEQ      IN   VARCHAR2         -- 줄번호    
                                     , IN_HSP_TP_CD   IN   VARCHAR2         -- 병원구분
                                     , OUT_CURSOR     OUT  RETURNCURSOR )
    IS
        --변수선언
        WK_CURSOR                 RETURNCURSOR ;

--        L_EXM_ACPT_NO     VARCHAR2(20)    := '';    
--        L_ACPT_DTM        VARCHAR2(20)    := '';    

        L_ACPT_DTM          VARCHAR2(20)    := '';    
        L_WK_UNIT_CD        VARCHAR2(20)    := '';    
        L_EXM_ACPT_NO       NUMBER          := '';    


    BEGIN    
    
--        L_ACPT_DTM    := SUBSTR(IN_ACPT_NO, 1, 8);            
--        L_EXM_ACPT_NO := SUBSTR(IN_ACPT_NO, 9, 4);

        L_WK_UNIT_CD    := SUBSTR(IN_ACPT_NO, 1, 3);            
        L_ACPT_DTM      := SUBSTR(IN_ACPT_NO, 4, 4);
        L_EXM_ACPT_NO   := TO_NUMBER(SUBSTR(IN_ACPT_NO, 9));
        
--        RAISE_APPLICATION_ERROR(-20553, IN_ACPT_NO || '-' || L_ACPT_DTM ||  ' ' || L_EXM_ACPT_NO || ' ' || L_WK_UNIT_CD || ' ERRCODE = ' || SQLCODE || SQLERRM) ;        
               
--
--        IF IN_HSP_TP_CD = '02' THEN            
--            BEGIN
----                --BODY
----                OPEN WK_CURSOR FOR
----                    
----                    WITH W_EXM_ACPT_NO AS 
----                        (SELECT * 
----                           FROM MSELMCRD I 
----                          WHERE 1=1
----                            AND I.HSP_TP_CD   = IN_HSP_TP_CD
----                            AND I.EXM_ACPT_NO = L_EXM_ACPT_NO
----                        )
----                          SELECT /*+ LEADING(I) PC_MSE_CULTURE_INTERFACE-PC_MSE_MICROBE_SELECT2_0 */ 
----                                 DISTINCT P.PT_NM                                 PT_NM
----                                        , A.SPCM_NO                               SPCM_NO
----                                        , I.LN_SEQ                                LN_SEQ
----                                        , A.EXM_CD                                EXM_CD
----                                        , FT_MSE_NAME_C(A.EXM_CD, A.HSP_TP_CD)    EXM_NM
----                                        , TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD')       ACPT_DT
----                                        , A.EXM_ACPT_NO                           EXM_ACPT_NO
----                                        , I.CLMD_CD                               CLMD_CD
----                                        , I.LABM_NEPO_TP_CD                       LABM_NEPO_TP_CD
----                                        , I.MCB_EQUP_SEQ                          MCB_EQUP_SEQ
----                                        , I.PRCC_RSLT_CNTE                        PRCC_RSLT_CNTE
----                                        , I.MVM_CD                                MVM_CD
----                                        , I.MVRT_CNTE                             MVRT_CNTE
----                                        , I.CLY_CNT_CNTE                          CLY_CNT_CNTE
----                                        , I.ADD_EITM_CNTE                         ADD_EITM_CNTE
----                                        , A.TH1_SPCM_CD                           TH1_SPCM_CD
----                                        , A.PT_NO                                 PT_NO
----                                        , P.PT_BRDY_DT                            PT_BRDY_DT
----                                        , P.SEX_TP_CD                             SEX_TP_CD
----                                        , (SELECT SPCM_NM
----                                             FROM MSELMCCC
----                                            WHERE SPCM_CD   = A.TH1_SPCM_CD
----                                              AND HSP_TP_CD = A.HSP_TP_CD)        SPCM_NM
----                                        , I.CLY_SEQ                               CLY_SEQ
----                            FROM MSELMAID A,  W_EXM_ACPT_NO I, PCTPCPAM_DAMO P
----                           WHERE 1=1
----                             AND A.HSP_TP_CD = IN_HSP_TP_CD
----                             AND A.ACPT_DTM BETWEEN TO_DATE( L_ACPT_DTM || '0101') AND TO_DATE( L_ACPT_DTM || '1231') + 0.99999
----                             --AND .EXM_ACPT_NO = :B2
------                             AND A.WK_UNIT_CD = L_WK_UNIT_CD
----                             AND (A.WK_UNIT_CD = L_WK_UNIT_CD OR L_WK_UNIT_CD  IS  NOT NULL)
----                             AND I.HSP_TP_CD = A.HSP_TP_CD
----                             AND I.SPCM_NO = A.SPCM_NO
----                             AND I.EXM_ACPT_NO = A.EXM_ACPT_NO
----                             AND A.PT_NO = P.PT_NO
----                             AND (SELECT COUNT(*) FROM W_EXM_ACPT_NO) >= 1
----                             
----                        UNION ALL
----                        
----                          SELECT   
----                                 DISTINCT P.PT_NM                                 PT_NM
----                                        , A.SPCM_NO                               SPCM_NO
----                                        , I.LN_SEQ                                LN_SEQ
----                                        , A.EXM_CD                                EXM_CD
----                                        , FT_MSE_NAME_C(A.EXM_CD, A.HSP_TP_CD)    EXM_NM
----                                        , TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD')       ACPT_DT
----                                        , A.EXM_ACPT_NO                           EXM_ACPT_NO
----                                        , I.CLMD_CD                               CLMD_CD
----                                        , I.LABM_NEPO_TP_CD                       LABM_NEPO_TP_CD
----                                        , I.MCB_EQUP_SEQ                          MCB_EQUP_SEQ
----                                        , I.PRCC_RSLT_CNTE                        PRCC_RSLT_CNTE
----                                        , I.MVM_CD                                MVM_CD
----                                        , I.MVRT_CNTE                             MVRT_CNTE
----                                        , I.CLY_CNT_CNTE                          CLY_CNT_CNTE
----                                        , I.ADD_EITM_CNTE                         ADD_EITM_CNTE
----                                        , A.TH1_SPCM_CD                           TH1_SPCM_CD
----                                        , A.PT_NO                                 PT_NO
----                                        , P.PT_BRDY_DT                            PT_BRDY_DT
----                                        , P.SEX_TP_CD                             SEX_TP_CD
----                                        , (SELECT SPCM_NM
----                                             FROM MSELMCCC
----                                            WHERE SPCM_CD   = A.TH1_SPCM_CD
----                                              AND HSP_TP_CD = A.HSP_TP_CD)        SPCM_NM
----                                        , I.CLY_SEQ                               CLY_SEQ
----                            FROM MSELMAID A,  W_EXM_ACPT_NO I, PCTPCPAM_DAMO P
----                           WHERE 1=1
----                             AND A.HSP_TP_CD = IN_HSP_TP_CD
----                             AND A.ACPT_DTM BETWEEN TO_DATE( L_ACPT_DTM || '0101') AND TO_DATE( L_ACPT_DTM || '1231') + 0.99999
----                             AND A.EXM_ACPT_NO    = L_EXM_ACPT_NO
------                             AND A.WK_UNIT_CD     = L_WK_UNIT_CD 
----                             AND (A.WK_UNIT_CD = L_WK_UNIT_CD OR L_WK_UNIT_CD  IS  NOT NULL)
----                             AND I.HSP_TP_CD(+)   = A.HSP_TP_CD
----                             AND I.SPCM_NO(+)     = A.SPCM_NO
----                             AND I.EXM_ACPT_NO(+) = A.EXM_ACPT_NO
----                             AND A.PT_NO          = P.PT_NO
----                             AND (SELECT COUNT(*) FROM W_EXM_ACPT_NO) = 0    
----                        ORDER BY SPCM_NO, LN_SEQ
----                        ;                    
----                                             
--                --BODY
--                OPEN WK_CURSOR FOR
--
--                     SELECT /*+ INDEX(A MSELMAID_SI03) PC_MSE_CULTURE_INTERFACE-PC_MSE_MICROBE_SELECT2_01 */
--                            DISTINCT
--                            P.PT_NM                                        PT_NM
--                          , A.SPCM_NO                                      SPCM_NO
--                          , I.LN_SEQ                                       LN_SEQ
--                          , A.EXM_CD                                       EXM_CD
--                          , FT_MSE_NAME_C(A.EXM_CD, A.HSP_TP_CD)           EXM_NM
--                          , TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD')               ACPT_DT
--                          , A.EXM_ACPT_NO                                  EXM_ACPT_NO
--                          , I.CLMD_CD                                      CLMD_CD
--                          , I.LABM_NEPO_TP_CD                              LABM_NEPO_TP_CD
--                          , I.MCB_EQUP_SEQ                                 MCB_EQUP_SEQ
--                          , I.PRCC_RSLT_CNTE                               PRCC_RSLT_CNTE
--                          , I.MVM_CD                                       MVM_CD
--                          , I.MVRT_CNTE                                    MVRT_CNTE 
--                          , I.CLY_CNT_CNTE                                 CLY_CNT_CNTE
--                          , I.ADD_EITM_CNTE                                ADD_EITM_CNTE
--                          , A.TH1_SPCM_CD                                  TH1_SPCM_CD
----                          , V.MED_DEPT_CD                                  MED_DEPT_CD
----                          , V.PBSO_DEPT_CD                                 PBSO_DEPT_CD 
--                          , A.PT_NO                                        PT_NO
--                          , P.PT_BRDY_DT                                   PT_BRDY_DT
--                          , P.SEX_TP_CD                                    SEX_TP_CD  
--                          , (SELECT SPCM_NM FROM MSELMCCC WHERE SPCM_CD = A.TH1_SPCM_CD AND HSP_TP_CD = A.HSP_TP_CD) SPCM_NM
--                          , I.CLY_SEQ                                      CLY_SEQ
--                       FROM MSELMAID A --접수검사항목결과정보
--                          , MSELMCRD I --배지별배양결과정보
--                          , PCTPCPAM_DAMO P -- 환자기본
--                      WHERE 1=1                                            
--                        AND A.HSP_TP_CD   = IN_HSP_TP_CD
----                        AND TO_CHAR(A.ACPT_DTM, 'YYYY')   = L_ACPT_DTM
--                        AND A.ACPT_DTM BETWEEN TO_DATE(L_ACPT_DTM || '0101') AND TO_DATE(L_ACPT_DTM || '1231')  + 0.99999
--                        AND A.EXM_ACPT_NO                 = L_EXM_ACPT_NO
--                        AND A.WK_UNIT_CD                  = L_WK_UNIT_CD
--                        
--                        AND I.HSP_TP_CD  (+) = A.HSP_TP_CD
--                        AND I.SPCM_NO    (+) = A.SPCM_NO                  
--                        AND I.EXM_ACPT_NO(+) = A.EXM_ACPT_NO
--                        AND A.PT_NO          = P.PT_NO
--                      ORDER BY A.SPCM_NO, I.LN_SEQ        
--                      ;
----    
--                      OUT_CURSOR := WK_CURSOR ;
--    
--                --예외처리
--              EXCEPTION
--                    WHEN OTHERS THEN
--                         RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_CULTURE_INTERFACE2' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
--            END ;
--        
--            RETURN;
--        END IF;

        
        -- 미생물 배지없이 결과만 조회함.
        IF UPPER(IN_LN_SEQ) = 'RESULT' THEN
        
            BEGIN        
                --BODY
                OPEN WK_CURSOR FOR
    
                     SELECT /* PC_MSE_CULTURE_INTERFACE-PC_MSE_MICROBE_SELECT2_02 */
                            DISTINCT
                            P.PT_NM                                        PT_NM
                          , A.SPCM_NO                                      SPCM_NO
                          , ''                                             LN_SEQ
                          , A.EXM_CD                                       EXM_CD
                          , FT_MSE_NAME_C(A.EXM_CD, A.HSP_TP_CD)           EXM_NM
                          , TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD')              ACPT_DT
                          , A.EXM_ACPT_NO                                  EXM_ACPT_NO
                          , ''                                             CLMD_CD
                          , ''                                             LABM_NEPO_TP_CD
                          , ''                                             MCB_EQUP_SEQ
                          , ''                                             PRCC_RSLT_CNTE
                          , ''                                             MVM_CD
                          , ''                                             MVRT_CNTE 
                          , ''                                             CLY_CNT_CNTE
                          , ''                                             ADD_EITM_CNTE
                          , A.TH1_SPCM_CD                                  TH1_SPCM_CD
                          , ''                                             MED_DEPT_CD
                          , ''                                             PBSO_DEPT_CD 
                          , A.PT_NO                                        PT_NO
                          , P.PT_BRDY_DT                                   PT_BRDY_DT
                          , P.SEX_TP_CD                                    SEX_TP_CD  
                          , (SELECT SPCM_NM FROM MSELMCCC WHERE SPCM_CD = A.TH1_SPCM_CD AND HSP_TP_CD = A.HSP_TP_CD) SPCM_NM
                          , ''                                             CLY_SEQ
                       FROM MSELMAID A --접수검사항목결과정보
                          , PCTPCPAM_DAMO P -- 환자기본
                      WHERE 1=1                                            
                        AND A.HSP_TP_CD   = IN_HSP_TP_CD
--                        AND A.ACPT_DTM BETWEEN TO_DATE(L_ACPT_DTM || '0101') AND TO_DATE(L_ACPT_DTM || '1231')  + 0.99999
                        AND A.ACPT_DTM BETWEEN TO_DATE(SYSDATE - 10) AND TO_DATE(L_ACPT_DTM || '1231')  + 0.99999
                        AND A.EXM_ACPT_NO = L_EXM_ACPT_NO
                        AND A.WK_UNIT_CD  = L_WK_UNIT_CD
                        AND A.PT_NO       = P.PT_NO
                      ORDER BY A.SPCM_NO, A.EXM_CD
                      ;
    
                      OUT_CURSOR := WK_CURSOR ;
        
                --예외처리
              EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_CULTURE_INTERFACE2-RESULT' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END ;
            
            RETURN;
        END IF;        


        BEGIN
            --BODY
            OPEN WK_CURSOR FOR

                 SELECT /* PC_MSE_CULTURE_INTERFACE-PC_MSE_MICROBE_SELECT2_02 */
                        DISTINCT
                        P.PT_NM                                        PT_NM
                      , A.SPCM_NO                                      SPCM_NO
                      , I.LN_SEQ                                       LN_SEQ
                      , I.EXM_CD                                       EXM_CD
                      , FT_MSE_NAME_C(I.EXM_CD, I.HSP_TP_CD)           EXM_NM
                      , TO_CHAR(I.ACPT_DT, 'YYYY-MM-DD')               ACPT_DT
                      , I.EXM_ACPT_NO                                  EXM_ACPT_NO
                      , I.CLMD_CD                                      CLMD_CD
                      , I.LABM_NEPO_TP_CD                              LABM_NEPO_TP_CD
                      , I.MCB_EQUP_SEQ                                 MCB_EQUP_SEQ
                      , I.PRCC_RSLT_CNTE                               PRCC_RSLT_CNTE
                      , I.MVM_CD                                       MVM_CD
                      , I.MVRT_CNTE                                    MVRT_CNTE 
                      , I.CLY_CNT_CNTE                                 CLY_CNT_CNTE
                      , I.ADD_EITM_CNTE                                ADD_EITM_CNTE
                      , A.TH1_SPCM_CD                                  TH1_SPCM_CD
--                      , V.MED_DEPT_CD                                  MED_DEPT_CD
--                      , V.PBSO_DEPT_CD                                 PBSO_DEPT_CD 
                      , ''                                             MED_DEPT_CD
                      , ''                                             PBSO_DEPT_CD 
                      , A.PT_NO                                        PT_NO
                      , P.PT_BRDY_DT                                   PT_BRDY_DT
                      , P.SEX_TP_CD                                    SEX_TP_CD  
                      , (SELECT SPCM_NM FROM MSELMCCC WHERE SPCM_CD = A.TH1_SPCM_CD AND HSP_TP_CD = A.HSP_TP_CD) SPCM_NM
                      , I.CLY_SEQ                                      CLY_SEQ
                   FROM MSELMAID A --접수검사항목결과정보
                      , MSELMCRD I --배지별배양결과정보
--                      , MSELMCED V --채취검체정보 
                      , PCTPCPAM_DAMO P -- 환자기본
                  WHERE 1=1                                            
                    AND A.HSP_TP_CD   = IN_HSP_TP_CD
                    AND A.ACPT_DTM BETWEEN TO_DATE(L_ACPT_DTM || '0101') AND TO_DATE(L_ACPT_DTM || '1231')  + 0.99999
                    AND I.EXM_ACPT_NO                 = L_EXM_ACPT_NO
                    AND A.WK_UNIT_CD                  = L_WK_UNIT_CD
                    
                    AND I.HSP_TP_CD    = A.HSP_TP_CD
                    AND I.SPCM_NO      = A.SPCM_NO
                    AND I.EXM_ACPT_NO  = A.EXM_ACPT_NO
                    AND A.PT_NO        = P.PT_NO
                  ORDER BY A.SPCM_NO, I.LN_SEQ        
 
--                    AND TO_CHAR(I.ACPT_DT, 'YYYYMMDD')   = L_ACPT_DTM
--                    AND LPAD(I.EXM_ACPT_NO, 4, '0')        = L_EXM_ACPT_NO
--                    AND I.CLY_SEQ     = DECODE(IN_LN_SEQ, '', I.CLY_SEQ, IN_LN_SEQ)  
----                    AND I.LN_SEQ      = DECODE(IN_LN_SEQ, '', I.LN_SEQ, IN_LN_SEQ) 
--                    AND I.SPCM_NO     = A.SPCM_NO
--                    AND I.HSP_TP_CD   = A.HSP_TP_CD
--                    AND V.HSP_TP_CD   = A.HSP_TP_CD
--                    AND V.PT_NO       = P.PT_NO
--                    AND V.SPCM_NO     = A.SPCM_NO  
--                  ORDER BY I.SPCM_NO, I.LN_SEQ        
                  ;

                  OUT_CURSOR := WK_CURSOR ;

            --예외처리
          EXCEPTION
                WHEN OTHERS THEN
                     RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_CULTURE_INTERFACE2' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
        END ;
    END PC_MSE_MICROBE_SELECT2;    
    
                                      
    
    
    
    /***********************************************************************************************
    *    서비스이름  : PC_MSE_MVM_RESULT_UPDATE
    *    최초 작성일 : 2017.12.12
    *    최초 작성자 : ezCaretech
    *    Description : 동정결과입력
    **********************************************************************************************/    
    PROCEDURE PC_MSE_MVM_RESULT_UPDATE ( IN_SPCM_NO                     IN      VARCHAR2        -- <P0> 검체번호
                                       , IN_CNT                         IN      VARCHAR2        -- <P1> MSELMCRD 갯수
                                       , IN_CNT_ANTI                    IN      VARCHAR2        -- <P2> MSELMMRD 갯수
                                       , IN_ACPT_DT                     IN      VARCHAR2        -- <P3> MSELMCRD.접수일자
                                       , IN_EXM_ACPT_NO                 IN      VARCHAR2        -- <P4> MSELMCRD.접수번호
                                       , IN_HIS_STF_NO                  IN      VARCHAR2        -- <P5> MSELMCRD.수정자
                                       
                                       , IN_CLMD_CD                     IN      VARCHAR2        -- <P6> MSELMCRD.배지코드
                                       , IN_LABM_NEPO_TP_CD             IN      VARCHAR2        -- <P7> MSELMCRD.진단검사의학음성양성구분코드
                                       , IN_LN_SEQ                      IN      VARCHAR2        -- <P8> MSELMCRD.줄순번
                                       , IN_MCB_EQUP_SEQ                IN      VARCHAR2        -- <P9> MSELMCRD.미생물장비순번
                                       , IN_MVM_CD                      IN      VARCHAR2        -- <P10>MSELMCRD.동정코드
                                       , IN_MVRT_CNTE                   IN      VARCHAR2        -- <P11>MSELMCRD.검사결과내용
                                       , IN_SRUM_CLS_CNTE               IN      VARCHAR2        -- <P12>MSELMCRD.혈청유형내용
                                       , IN_STRG_CNTE                   IN      VARCHAR2        -- <P13>MSELMCRD.보관내용
                                       , IN_CLMD_ANTN_CNTE              IN      VARCHAR2        -- <P14>MSELMCRD.배지주석내용(COMMNET)
                                       
                                       , IN_MM_CLMD_CD                  IN      VARCHAR2        -- <P15>MSELMMRD.미생물항생제감수성결과정보.배지코드                    
                                       , IN_MM_LABM_NEPO_TP_CD          IN      VARCHAR2        -- <P16>MSELMMRD.미생물항생제감수성결과정보.진단검사의학음성양성구분코드
                                       , IN_MM_LN_SEQ                   IN      VARCHAR2        -- <P17>MSELMMRD.미생물항생제감수성결과정보.줄순번
                                       , IN_MM_SSBT_CTG_CD              IN      VARCHAR2        -- <P18>MSELMMRD.미생물항생제감수성결과정보.감수성분류코드
                                       , IN_MM_ATBA_CD                  IN      VARCHAR2        -- <P19>MSELMMRD.미생물항생제감수성결과정보.항생제코드
                                       , IN_MM_ATBA_DMTR_CNTE           IN      VARCHAR2        -- <P20>MSELMMRD.미생물항생제감수성결과정보.항생제지름내용
                                       , IN_MM_ATBA_SSBT_RSLT_CNTE      IN      VARCHAR2        -- <P21>MSELMMRD.미생물항생제감수성결과정보.항생제감수성결과내용
                                       , IN_HSP_TP_CD                   IN      VARCHAR2        -- <P22>병원구분
                                       , IN_EXRS_CNTE                   IN      VARCHAR2        -- <P23>결과내용
                                       , IN_SPEX_PRGR_STS_CD            IN      VARCHAR2        -- <P24>검체검사진행상태코드
                                       , IN_EQUP                        IN      VARCHAR2        -- <P25>장비명
                                       , IO_ERRYN                       IN OUT  VARCHAR2
                                       , IO_ERRMSG                      IN OUT  VARCHAR2 )
    IS

        TT_CLMD_CD                  T_VC2ARRAY1000;
        TT_LABM_NEPO_TP_CD          T_VC2ARRAY1000;
        TT_LN_SEQ                   T_VC2ARRAY1000;
        TT_MCB_EQUP_SEQ             T_VC2ARRAY1000;
        TT_MVM_CD                   T_VC2ARRAY1000;
        TT_MVRT_CNTE                T_VC2ARRAY1000;
        TT_SRUM_CLS_CNTE            T_VC2ARRAY1000;
        TT_STRG_CNTE                T_VC2ARRAY1000;
        TT_MM_CLMD_CD               T_VC2ARRAY1000;
        TT_MM_LABM_NEPO_TP_CD       T_VC2ARRAY1000;
        TT_MM_LN_SEQ                T_VC2ARRAY1000;
        TT_MM_SSBT_CTG_CD           T_VC2ARRAY1000;
        TT_MM_ATBA_CD               T_VC2ARRAY1000;
        TT_MM_ATBA_DMTR_CNTE        T_VC2ARRAY1000;
        TT_MM_ATBA_SSBT_RSLT_CNTE   T_VC2ARRAY1000;
        TT_CLMD_ANTN_CNTE           T_VC2ARRAY1000;

        L_CLMD_CD                   VARCHAR2(1000)  := NULL;
        L_LABM_NEPO_TP_CD           VARCHAR2(1000)  := NULL;
        L_LN_SEQ                    VARCHAR2(1000)  := NULL;
        L_MCB_EQUP_SEQ              VARCHAR2(1000)  := NULL;
        L_MVM_CD                    VARCHAR2(1000)  := NULL;
        L_MVRT_CNTE                 VARCHAR2(1000)  := NULL;
        L_SRUM_CLS_CNTE             VARCHAR2(1000)  := NULL;
        L_STRG_CNTE                 VARCHAR2(1000)  := NULL;
        L_MM_CLMD_CD                VARCHAR2(1000)  := NULL;
        L_MM_LABM_NEPO_TP_CD        VARCHAR2(1000)  := NULL;
        L_MM_LN_SEQ                 VARCHAR2(1000)  := NULL;
        L_MM_SSBT_CTG_CD            VARCHAR2(1000)  := NULL;
        L_MM_ATBA_CD                VARCHAR2(1000)  := NULL;
        L_MM_ATBA_DMTR_CNTE         VARCHAR2(1000)  := NULL;
        L_MM_ATBA_SSBT_RSLT_CNTE    VARCHAR2(1000)  := NULL;
        L_CLMD_ANTN_CNTE            VARCHAR2(1000)  := NULL;

        L_FLAG            NUMBER(10)      := TO_NUMBER(NVL(IN_CNT,'0'));
        L_ANTI_FLAG       NUMBER(10)      := TO_NUMBER(NVL(IN_CNT_ANTI,'0'));

        TT_ORDCHK         VARCHAR2(1)     := NULL;
        T_EXMCD           VARCHAR2(1000)  ;
        T_MVRT_CNTE       VARCHAR2(4000)  ;
        
        L_EXM_ACPT_NO     VARCHAR2(20)    := '';    
        L_ACPT_DTM        VARCHAR2(20)    := '';    
        V_LN_SEQ          VARCHAR2(20)    := ''; 
        V_CLY_SEQ         VARCHAR2(20)    := ''; 
           
        L_PT_NO           MSELMCED.PT_NO%TYPE;
        L_EXRM_EXM_CTG_CD MSELMCED.EXRM_EXM_CTG_CD%TYPE;
        L_WK_UNIT_CD      MSELMAID.WK_UNIT_CD%TYPE;
        L_EXRS_RMK_CNTE   VARCHAR2(32767); -- 결과비고
        L_EXRM_RMK_CNTE   VARCHAR2(32767); -- 검사실비고
        
    BEGIN                   

            
        L_ACPT_DTM    := SUBSTR(IN_EXM_ACPT_NO, 1, 8);            
        L_EXM_ACPT_NO := SUBSTR(IN_EXM_ACPT_NO, 9, 6);
--        L_EXM_ACPT_NO := SUBSTR(IN_EXM_ACPT_NO, 9, 4);
                                                         
--        RAISE_APPLICATION_ERROR(-20001, IN_EXM_ACPT_NO || '\' || L_ACPT_DTM || '\' || L_EXM_ACPT_NO  || '\' || IN_EQUP) ;

    
        --ICNT       := TO_NUMBER(IN_CNT);
        --ICNT_ANTI  := TO_NUMBER(IN_CNT_ANTI);

        --------------------------------------------------------------------------------------------------------------
        --- 2010.07.15 방수석 추가 장비인터페이스(VITEK, MICROSCAN)에서 동정결과 및 항생제감수성 결과 전송시 오더
        ---            상태를 추가로 체크하여 최종검증시에는 결과를 덮어쓰지 못하도록 수정
        --------------------------------------------------------------------------------------------------------------
        BEGIN

            SELECT DECODE(EXM_PRGR_STS_CD,'N','Y','N')
                 , PT_NO       
                 , EXRM_EXM_CTG_CD
              INTO TT_ORDCHK
                 , L_PT_NO          
                 , L_EXRM_EXM_CTG_CD
              FROM MSELMCED --채취검체정보
             WHERE SPCM_NO   = IN_SPCM_NO
               AND HSP_TP_CD = IN_HSP_TP_CD --병원구분
               ;

        EXCEPTION
            WHEN OTHERS THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := '오더상태 체크 중 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);
                RETURN;
        END;

        IF TT_ORDCHK = 'Y' THEN
            RETURN;
        END IF;
        --------------------------------------------------------------------------------------------------------------

        IF  L_ANTI_FLAG > 0 THEN
            FOR I IN 1 .. L_ANTI_FLAG
            LOOP
               ---------------------------------------------------------------------------------------------------------
               --- 닷넷 클라이언트에서 배열로 던질수 없어서 스트링으로 받아서 구분자로 잘라서 배열에 SET한다.
               --- 예) '/AGH/BCDKKK/7009000088/L010190000/47/'
               ---------------------------------------------------------------------------------------------------------
               TT_MM_ATBA_DMTR_CNTE         (I) := SUBSTR(IN_MM_ATBA_DMTR_CNTE      , INSTR(IN_MM_ATBA_DMTR_CNTE        ,CHR(9),1,I) + 1   , INSTR(IN_MM_ATBA_DMTR_CNTE            ,CHR(9),1,I + 1)     - (INSTR(IN_MM_ATBA_DMTR_CNTE           ,CHR(9),1,I) + 1));
               TT_MM_ATBA_SSBT_RSLT_CNTE    (I) := SUBSTR(IN_MM_ATBA_SSBT_RSLT_CNTE    , INSTR(IN_MM_ATBA_SSBT_RSLT_CNTE    ,CHR(9),1,I) + 1   , INSTR(IN_MM_ATBA_SSBT_RSLT_CNTE       ,CHR(9),1,I + 1)     - (INSTR(IN_MM_ATBA_SSBT_RSLT_CNTE      ,CHR(9),1,I) + 1));


--              배지, 집락, 감수성분류는 배열이 아닌 일반 문자를 저장한다.
--               TT_MM_CLMD_CD                (I) := SUBSTR(IN_MM_CLMD_CD                , INSTR(IN_MM_CLMD_CD               ,CHR(9),1,I) + 1   , INSTR(IN_MM_CLMD_CD          ,CHR(9),1,I + 1)     - (INSTR(IN_MM_CLMD_CD         ,CHR(9),1,I) + 1));
--               TT_MM_LABM_NEPO_TP_CD        (I) := SUBSTR(IN_MM_LABM_NEPO_TP_CD        , INSTR(IN_MM_LABM_NEPO_TP_CD       ,CHR(9),1,I) + 1   , INSTR(IN_MM_LABM_NEPO_TP_CD          ,CHR(9),1,I + 1)     - (INSTR(IN_MM_LABM_NEPO_TP_CD         ,CHR(9),1,I) + 1));
--               TT_MM_SSBT_CTG_CD            (I) := SUBSTR(IN_MM_SSBT_CTG_CD           , INSTR(IN_MM_SSBT_CTG_CD              ,CHR(9),1,I) + 1   , INSTR(IN_MM_SSBT_CTG_CD     ,CHR(9),1,I + 1)     - (INSTR(IN_MM_SSBT_CTG_CD    ,CHR(9),1,I) + 1));
               TT_MM_CLMD_CD                (I) := IN_MM_CLMD_CD;
               TT_MM_LABM_NEPO_TP_CD        (I) := IN_MM_LABM_NEPO_TP_CD;
               TT_MM_SSBT_CTG_CD            (I) := IN_MM_SSBT_CTG_CD;
               
               TT_MM_LN_SEQ                 (I) := SUBSTR(IN_MM_LN_SEQ                , INSTR(IN_MM_LN_SEQ                   ,CHR(9),1,I) + 1   , INSTR(IN_MM_LN_SEQ          ,CHR(9),1,I + 1)     - (INSTR(IN_MM_LN_SEQ         ,CHR(9),1,I) + 1));
               TT_MM_ATBA_CD                (I) := SUBSTR(IN_MM_ATBA_CD               , INSTR(IN_MM_ATBA_CD                  ,CHR(9),1,I) + 1   , INSTR(IN_MM_ATBA_CD         ,CHR(9),1,I + 1)     - (INSTR(IN_MM_ATBA_CD        ,CHR(9),1,I) + 1));
               END LOOP;
        END IF;

        IF  L_FLAG > 0 THEN
            FOR I IN 1 .. L_FLAG
            LOOP
               ---------------------------------------------------------------------------------------------------------
               --- 닷넷 클라이언트에서 배열로 던질수 없어서 스트링으로 받아서 구분자로 잘라서 배열에 SET한다.
               --- 예) '/AGH/BCDKKK/7009000088/L010190000/47/'
               ---------------------------------------------------------------------------------------------------------
               TT_MCB_EQUP_SEQ       (I) := SUBSTR(IN_MCB_EQUP_SEQ          , INSTR(IN_MCB_EQUP_SEQ        ,CHR(9),1,I) + 1   , INSTR(IN_MCB_EQUP_SEQ           ,CHR(9),1,I + 1)     - (INSTR(IN_MCB_EQUP_SEQ         ,CHR(9),1,I) + 1));
               TT_SRUM_CLS_CNTE      (I) := SUBSTR(IN_SRUM_CLS_CNTE      , INSTR(IN_SRUM_CLS_CNTE    ,CHR(9),1,I) + 1   , INSTR(IN_SRUM_CLS_CNTE       ,CHR(9),1,I + 1)     - (INSTR(IN_SRUM_CLS_CNTE     ,CHR(9),1,I) + 1));
               TT_STRG_CNTE          (I) := SUBSTR(IN_STRG_CNTE          , INSTR(IN_STRG_CNTE        ,CHR(9),1,I) + 1   , INSTR(IN_STRG_CNTE         ,CHR(9),1,I + 1)     - (INSTR(IN_STRG_CNTE       ,CHR(9),1,I) + 1));
--               TT_CLMD_ANTN_CNTE     (I) := SUBSTR(IN_CLMD_ANTN_CNTE     , INSTR(IN_CLMD_ANTN_CNTE   ,CHR(9),1,I) + 1   , INSTR(IN_CLMD_ANTN_CNTE         ,CHR(9),1,I + 1)     - (INSTR(IN_CLMD_ANTN_CNTE       ,CHR(9),1,I) + 1));

--              배지, 집락, 줄순번, 균코드,균코드명은 배열이 아닌 일반 문자를 저장한다.
--               TT_CLMD_CD            (I) := SUBSTR(IN_CLMD_CD            , INSTR(IN_CLMD_CD          ,CHR(9),1,I) + 1   , INSTR(IN_CLMD_CD           ,CHR(9),1,I + 1)     - (INSTR(IN_CLMD_CD         ,CHR(9),1,I) + 1));
--               TT_LABM_NEPO_TP_CD    (I) := SUBSTR(IN_LABM_NEPO_TP_CD    , INSTR(IN_LABM_NEPO_TP_CD    ,CHR(9),1,I) + 1   , INSTR(IN_LABM_NEPO_TP_CD           ,CHR(9),1,I + 1)     - (INSTR(IN_LABM_NEPO_TP_CD         ,CHR(9),1,I) + 1));
--               TT_LN_SEQ             (I) := SUBSTR(IN_LN_SEQ             , INSTR(IN_LN_SEQ           ,CHR(9),1,I) + 1   , INSTR(IN_LN_SEQ           ,CHR(9),1,I + 1)     - (INSTR(IN_LN_SEQ         ,CHR(9),1,I) + 1));
--               TT_MVM_CD             (I) := SUBSTR(IN_MVM_CD                , INSTR(IN_MVM_CD              ,CHR(9),1,I) + 1   , INSTR(IN_MVM_CD          ,CHR(9),1,I + 1)     - (INSTR(IN_MVM_CD        ,CHR(9),1,I) + 1));
--               TT_MVRT_CNTE          (I) := SUBSTR(IN_MVRT_CNTE          , INSTR(IN_MVRT_CNTE        ,CHR(9),1,I) + 1   , INSTR(IN_MVRT_CNTE             ,CHR(9),1,I + 1)     - (INSTR(IN_MVRT_CNTE           ,CHR(9),1,I) + 1));
               TT_CLMD_CD            (I) := IN_CLMD_CD;
               TT_LABM_NEPO_TP_CD    (I) := IN_LABM_NEPO_TP_CD;
               TT_LN_SEQ             (I) := IN_LN_SEQ;
               TT_MVM_CD             (I) := IN_MVM_CD;
               TT_MVRT_CNTE          (I) := IN_MVRT_CNTE;

    --------------------------------------------------------------------------------------------------------------------
    --                                 IO_ERRYN  := 'Y';
    --                                 IO_ERRMSG := IN_CLMD_CD ||'***'||TT_CLMD_CD(I) || '***'||IN_LABM_NEPO_TP_CD ||'***'|| TT_LABM_NEPO_TP_CD(I) || '***'||IN_LN_SEQ ||'***'|| TT_LN_SEQ(I);
    --                                 RETURN;
    --------------------------------------------------------------------------------------------------------------------
               END LOOP;
        END IF;
                                  


--        RAISE_APPLICATION_ERROR(-20001, L_ACPT_DTM || '\' || L_EXM_ACPT_NO || '\' || L_LN_SEQ || '\' || L_MVM_CD  || '\' || L_MVRT_CNTE
--                              || '\' || L_FLAG  
--                               ) ;

        
        IF  L_FLAG > 0 THEN
            FOR I IN 1 .. L_FLAG
            LOOP

                --L_DEL_SEQ       := TT_DEL_SEQ(I);
                L_MCB_EQUP_SEQ        :=  TT_MCB_EQUP_SEQ     (I);
                L_MVM_CD              :=  TT_MVM_CD    (I);
                L_MVRT_CNTE           :=  TT_MVRT_CNTE       (I);
                L_SRUM_CLS_CNTE       :=  TT_SRUM_CLS_CNTE (I);
                L_STRG_CNTE           :=  TT_STRG_CNTE   (I);
--                L_CLMD_ANTN_CNTE    :=  TT_CLMD_ANTN_CNTE   (I);
                L_CLMD_CD              :=  TT_CLMD_CD     (I);
                L_LABM_NEPO_TP_CD      :=  TT_LABM_NEPO_TP_CD     (I);
                L_LN_SEQ               :=  TT_LN_SEQ     (I);


--
--                RAISE_APPLICATION_ERROR(-20001, L_ACPT_DTM || '\' || L_EXM_ACPT_NO || '\' || L_LN_SEQ || '\' || L_MVM_CD  || '\' || L_MVRT_CNTE
--                                      || '\' || IN_EQUP  
--                                       ) ;


                BEGIN
                       UPDATE MSELMCRD --배지별배양결과정보
                          SET MCB_EQUP_SEQ      = TO_NUMBER(L_MCB_EQUP_SEQ)
                            , MVM_CD            = L_MVM_CD
                            , MVRT_CNTE         = L_MVRT_CNTE
                            , SRUM_CLS_CNTE     = L_SRUM_CLS_CNTE
                            , STRG_CNTE         = L_STRG_CNTE
                            , CLMD_ANTN_CNTE    = IN_CLMD_ANTN_CNTE
                            , DEXM_MDSC_EQUP_CD = IN_EQUP
                            , FSR_DTM           = SYSDATE
                            , FSR_STF_NO        = IN_HIS_STF_NO
                            , LSH_DTM           = SYSDATE
                        WHERE SPCM_NO                        = IN_SPCM_NO
                          AND TO_CHAR(ACPT_DT, 'YYYYMMDD')   = L_ACPT_DTM
                          AND LPAD(EXM_ACPT_NO, 6, '0')      = TO_NUMBER(L_EXM_ACPT_NO)
--                          AND CLY_SEQ                        = L_LN_SEQ     
                          AND LN_SEQ                         = L_LN_SEQ
                          AND HSP_TP_CD                      = IN_HSP_TP_CD
--                          AND CLMD_CD           = L_CLMD_CD
--                          AND LABM_NEPO_TP_CD   = IN_LABM_NEPO_TP_CD    --L_LABM_NEPO_TP_CD
--                          AND LN_SEQ            = L_LN_SEQ
                          ;
                                         
                       IF SQL%ROWCOUNT > 0 THEN
                           BEGIN

                               DELETE FROM MSELMMRD --미생물항생제감수성결과정보
                                WHERE SPCM_NO   = IN_SPCM_NO
                                  AND LN_SEQ    = L_LN_SEQ 
                                  AND HSP_TP_CD = IN_HSP_TP_CD --병원구분
                                  ;

                           EXCEPTION
                               WHEN  OTHERS  THEN
                                     IO_ERRYN  := 'Y';
                                     IO_ERRMSG := '미생물 항생제 감수성결과 삭제 시 에러 발생. ERRCD = ' || SQLERRM;
                                     RETURN;

                           END;
                       END IF;

                   EXCEPTION
                       WHEN OTHERS THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := '배양결과 UPDATE 처리 중 에러 발생. ERRCD = ' || SQLERRM;
                            RETURN;
                END;
               
 
--
--                --------------------------------------------------------------------------------------
--                        IO_ERRYN   := 'Y';
--                        IO_ERRMSG  := 'IN_SPCM_NO : '         || IN_SPCM_NO || CHR(10)  
--                                   || 'IN_ACPT_DT : '         || IN_ACPT_DT || CHR(10)    
--                                   || 'L_ACPT_DTM : '         || L_ACPT_DTM || CHR(10)    
--                                   || 'L_EXM_ACPT_NO : '      || L_EXM_ACPT_NO || CHR(10)    
--                                   || 'L_CLMD_CD : '          || L_CLMD_CD || CHR(10)    
--                                   || 'IN_LABM_NEPO_TP_CD : ' || IN_LABM_NEPO_TP_CD || CHR(10)    
--                                   || 'L_LN_SEQ : '           || L_LN_SEQ || CHR(10)    
--                                   || 'IN_HSP_TP_CD : '       || IN_HSP_TP_CD || CHR(10)    
--                                   
--                                       
--                                   ;
--                          RETURN;                   
--                --------------------------------------------------------------------------------------
                                          

--                RAISE_APPLICATION_ERROR(-20001, L_ACPT_DTM || '\' || L_EXM_ACPT_NO || '\' || L_LN_SEQ || '\' || IN_EXRS_CNTE 
--                                       ) ;


                
                IO_ERRYN   := '';
                IO_ERRMSG   := '';              

--                -- TEXT결과 존재시 TEXT 결과값 입력
--                IF IN_EXRS_CNTE IS NOT NULL THEN
--                
                    BEGIN                 
                         SELECT EXM_CD
                           INTO T_EXMCD
                           FROM MSELMCRD
                          WHERE SPCM_NO                        = IN_SPCM_NO
                            AND TO_CHAR(ACPT_DT, 'YYYYMMDD')   = L_ACPT_DTM
                            AND LPAD(EXM_ACPT_NO, 6, '0')      = TO_NUMBER(L_EXM_ACPT_NO)
--                            AND CLY_SEQ                        = L_LN_SEQ           
                            AND LN_SEQ                         = L_LN_SEQ
                            AND HSP_TP_CD                      = IN_HSP_TP_CD
--                            AND CLMD_CD                      = L_CLMD_CD
--                            AND LABM_NEPO_TP_CD              = IN_LABM_NEPO_TP_CD    --L_MM_LABM_NEPO_TP_CD
--                            AND LN_SEQ                       = TO_NUMBER(L_LN_SEQ)
                            ;
                            
                        EXCEPTION
                                WHEN OTHERS THEN
                                   IO_ERRYN  := 'Y';
                                   IO_ERRMSG := '미생물 TEXT결과 존재여부 조회시 에러 발생. ERRDESC = ' || SQLERRM;
                                   RETURN;      
                    END; 

                    BEGIN
                        SELECT WK_UNIT_CD
                             , EXRM_RMK_CNTE
                          INTO L_WK_UNIT_CD
                             , L_EXRM_RMK_CNTE
                          FROM MSELMAID
                         WHERE SPCM_NO   = IN_SPCM_NO
                           AND EXM_CD    = T_EXMCD
                           AND HSP_TP_CD = IN_HSP_TP_CD
                        ; 
                        
                        EXCEPTION
                                WHEN OTHERS THEN
                                   IO_ERRYN  := 'Y';
                                   IO_ERRMSG := '검사결과에서 SLIP정보 조회시 에러 발생. ERRDESC = ' || SQLERRM;
                                   RETURN;                               
                    END; 


--                RAISE_APPLICATION_ERROR(-20001, L_ACPT_DTM || '\' || L_EXM_ACPT_NO || '\' || IN_EQUP || '\' || T_EXMCD ) ;


--                    BEGIN       
--                         UPDATE MSELMAID 
--                            SET EXRS_CNTE            = IN_EXRS_CNTE
--                              , SMP_EXRS_CNTE        = IN_EXRS_CNTE
--                              , SPEX_PRGR_STS_CD     = IN_SPEX_PRGR_STS_CD                                           -- 검사결과상태값
--                              , RSLT_BRFG_YN         = DECODE(IN_SPEX_PRGR_STS_CD, '2', 'Y', 'N')                    -- 결과보고여부
--                              , DEXM_MDSC_EQUP_CD    = IN_EQUP                                                       -- 진단검사의학장비코드
--                              , LSH_DTM              = SYSDATE
--                              , LSH_PRGM_NM          = 'INTERFACE.PC_MSE_MVM_RESULT_UPDATE'  
--                          WHERE SPCM_NO              = IN_SPCM_NO
--                            AND EXM_CD               = T_EXMCD
--                            AND HSP_TP_CD            = IN_HSP_TP_CD
--                            ;
--                           
--                        EXCEPTION
--                            WHEN OTHERS THEN
--                               IO_ERRYN  := 'Y';
--                               IO_ERRMSG := '미생물 TEXT결과 저장시 에러 발생. ERRDESC = ' || SQLERRM;
--                               RETURN;
--                       END;    

                    -- 검사결과 저장
                    -- 2021.12.29 SCS : 저장 프로시저 호출로 변경함
                    XSUP.PKG_MSE_LM_EXAMRSLT.SAVE
                                 (  'T'                                        -- 임시
                                  , L_PT_NO                                    -- 환자번호
                                  , IN_SPCM_NO
                                  , L_EXRM_EXM_CTG_CD                          -- IN_EXM_CTG_CD       IN      MSELMAID.EXRM_EXM_CTG_CD%TYPE
                                  , L_WK_UNIT_CD                               -- IN_WK_UNIT_CD       IN      MSELMAID.WK_UNIT_CD%TYPE
                                  , T_EXMCD                                    -- IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                                  , ''                                         -- IN_MIDL_BRFG_CNTE   IN      MSELMAID.MIDL_BRFG_CNTE%TYPE
                                                                               
                                  , ''                                         -- IN_EXRS_CNTE        IN      MSELMAID.EXRS_CNTE%TYPE
                
                                  , ''                                         -- IN_RMK_CNTE         IN      MSELMCED.RMK_CNTE%TYPE
                                  , ''                                         -- IN_LMQC_RMK_CNTE    IN      MSELMCED.LMQC_RMK_CNTE%TYPE
                                  , ''                                         -- IN_EXRS_RMK_CNTE    IN      MSELMAID.EXRS_RMK_CNTE%TYPE
                                  , L_EXRM_RMK_CNTE                            -- IN_EXRM_RMK_CNTE    IN      MSELMAID.EXRM_RMK_CNTE%TYPE
                                 
                                  , ''                                         -- IN      MSELMAID.DLT_YN%TYPE
                                  , ''                                         -- IN      MSELMAID.PNC_YN%TYPE
                                  , ''                                         -- IN_CVR_YN         --  IN      MSELMAID.CVR_YN%TYPE
                                 
                                  , IN_EQUP                                    -- HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                                  , IN_HSP_TP_CD                               -- HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                                  , 'INTERFACE'                                -- HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                                  , SYS_CONTEXT('USERENV','IP_ADDRESS')        -- HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE

                                  , ''                                        -- IN_RSLT_BRFG_CNTE   IN      MSELMAID.RSLT_BRFG_CNTE%TYPE
                                 
                                  , IO_ERRYN -- IO_ERR_YN           IN OUT  VARCHAR2
                                  , IO_ERRMSG --IO_ERR_MSG          IN OUT  VARCHAR2 
                                 );
                   
                    IF IO_ERRYN = 'Y' THEN
                        RETURN;
                    END IF;
                    
                      
            
                    -- 장비결과저장 관련 컬럼(DEXM_MDSC_EQUP_CD, EQUP_RMK_CNTE, EQUP_RSLT_SND_DTM)
                    -- 장비결과저장 항목들은, 현재의 인터페이스 검사결과 저장시점(PKG_MSE_LM_INTERFACE.PC_MSE_INTERFACE_SAVE)에서 저장하며, 검사결과저장 패키지(PKG_MSE_LM_EXAMRSLT.SAVE)에서는 저장하지 않는다.
                    
                    PC_MSE_UPDATE_EQUP_INFO
                    (
                      IN_SPCM_NO 
                    , T_EXMCD
                    , ''
                    
                    , IN_EQUP
                    , ''
                    , '' --TO_DATE(IN_ANTC_REQR_DTM, 'YYYY-MM-DD HH24:MI:SS')
                    , '' --TT_HNWR_EXRS_CNTE(I)
                    
                    , 'IF'                                      
                    , IN_HSP_TP_CD                              
                    , 'INTERFACE'                               
                    , SYS_CONTEXT('USERENV','IP_ADDRESS') 
                    , IO_ERRYN
                    , IO_ERRMSG      
                    );
                                  


--                END IF;
               
               
            END LOOP;

            IF  IO_ERRYN = 'Y' THEN
                RETURN;
            END IF;
        END IF;
                    
  
--        RAISE_APPLICATION_ERROR(-20001, L_ACPT_DTM || '\' || L_ANTI_FLAG || '\' || SQL%ROWCOUNT ) ;                       
                  

        IF  L_ANTI_FLAG > 0 THEN
        
            FOR I IN 1 .. L_ANTI_FLAG
            LOOP

                L_MM_ATBA_DMTR_CNTE         := TT_MM_ATBA_DMTR_CNTE        (I);
                L_MM_ATBA_SSBT_RSLT_CNTE    := TT_MM_ATBA_SSBT_RSLT_CNTE   (I);
                L_MM_CLMD_CD                := TT_MM_CLMD_CD               (I);
                L_MM_LABM_NEPO_TP_CD        := TT_MM_LABM_NEPO_TP_CD       (I);
                L_MM_LN_SEQ                 := TT_MM_LN_SEQ                (I);
                L_MM_SSBT_CTG_CD            := TT_MM_SSBT_CTG_CD           (I);
                L_MM_ATBA_CD                := TT_MM_ATBA_CD               (I);


                BEGIN                                                                        


--
--        RAISE_APPLICATION_ERROR(-20001, L_ACPT_DTM || '\' || L_EXM_ACPT_NO || '\' || L_MM_CLMD_CD  || '\' || L_MM_LABM_NEPO_TP_CD
--                               ) ;                       
--                                       
                            

                    BEGIN                 
                        SELECT LN_SEQ
                             , CLY_SEQ
                          INTO V_LN_SEQ
                             , V_CLY_SEQ
                          FROM MSELMCRD
                         WHERE SPCM_NO                        = IN_SPCM_NO
--                           AND TO_CHAR(ACPT_DT, 'YYYYMMDD')   = L_ACPT_DTM
--                           AND LPAD(EXM_ACPT_NO, 4, '0')      = L_EXM_ACPT_NO
                           AND LN_SEQ                         = L_LN_SEQ
--                           AND CLY_SEQ                        = L_LN_SEQ
                           AND HSP_TP_CD                      = IN_HSP_TP_CD
                           ;
                                          
                        EXCEPTION
                                WHEN OTHERS THEN
                                   IO_ERRYN  := 'Y';
                                   IO_ERRMSG := '미생물 항생제 결과 존재여부 조회시 에러 발생. ERRDESC = ' || SQLERRM;
                                   RETURN;      
                    END; 

                    UPDATE MSELMMRD --미생물항생제감수성결과정보
                       SET ATBA_DMTR_CNTE          = L_MM_ATBA_DMTR_CNTE,
                           ATBA_SSBT_RSLT_CNTE     = L_MM_ATBA_SSBT_RSLT_CNTE,
                           FSR_DTM                 = SYSDATE,
                           FSR_STF_NO              = IN_HIS_STF_NO,
                           LSH_DTM                 = SYSDATE
                         , LSH_PRGM_NM             = 'INTERFACE.PC_MSE_MVM_RESULT_UPDATE'
                     WHERE SPCM_NO                 = IN_SPCM_NO
                       AND LN_SEQ                         = L_LN_SEQ
                       AND INPT_SEQ                       = L_MM_LN_SEQ                           
                       AND HSP_TP_CD                      = IN_HSP_TP_CD
                       ;
                     
--                       AND TO_CHAR(ACPT_DT, 'YYYYMMDD')   = L_ACPT_DTM
--                       AND LPAD(EXM_ACPT_NO, 4, '0')      = L_EXM_ACPT_NO
--                     WHERE SPCM_NO                 = IN_SPCM_NO
--                       AND CLMD_CD                 = L_MM_CLMD_CD
--                       AND LABM_NEPO_TP_CD         = IN_LABM_NEPO_TP_CD
--                       AND LN_SEQ                  = TO_NUMBER(L_MM_LN_SEQ)      EQUP_NO
--                       AND ATBA_CD                 = L_MM_ATBA_CD 
--                       AND HSP_TP_CD               = IN_HSP_TP_CD
--                       ;                                                    

--                    RAISE_APPLICATION_ERROR(-20001, L_ACPT_DTM || '\' || L_EXM_ACPT_NO || '\' || L_MM_CLMD_CD  || '\' || L_MM_LABM_NEPO_TP_CD
--                                                     || '\' || L_MM_SSBT_CTG_CD
--                                           ) ;                       
--                                                  
                    IF SQL%ROWCOUNT = 0 THEN
                        BEGIN
                            T_EXMCD := '';
                            
                             SELECT EXM_CD
                               INTO T_EXMCD
                               FROM MSELMCRD
                              WHERE SPCM_NO                        = IN_SPCM_NO
--                                AND TO_CHAR(ACPT_DT, 'YYYYMMDD')   = L_ACPT_DTM
--                                AND LPAD(EXM_ACPT_NO, 4, '0')      = L_EXM_ACPT_NO
--                                AND CLY_SEQ                        = L_LN_SEQ     
                                AND LN_SEQ                         = L_LN_SEQ
                                AND HSP_TP_CD                      = IN_HSP_TP_CD
                                ;
                                    
    --                         WHERE SPCM_NO             = IN_SPCM_NO
    --                           AND ACPT_DT             = IN_ACPT_DT
    --                           AND EXM_ACPT_NO         = L_EXM_ACPT_NO
    --                           AND CLMD_CD             = L_MM_CLMD_CD
    --                           AND LABM_NEPO_TP_CD     = IN_LABM_NEPO_TP_CD
    ----                           AND LN_SEQ              = TO_NUMBER(L_MM_LN_SEQ
    --                           AND LN_SEQ              = TO_NUMBER(V_LN_SEQ)
    --                           AND HSP_TP_CD           = IN_HSP_TP_CD
    --                           ;                    
                                
                           
                                INSERT INTO MSELMMRD --미생물항생제감수성결과정보
                                                 ( SPCM_NO
                                                 , ACPT_DT
                                                 , EXM_ACPT_NO
                                                 
                                                 , CLMD_CD
                                                 , LABM_NEPO_TP_CD                                                 
                                                 
                                                 , LN_SEQ
                                                 , CLY_SEQ
                                                 
                                                 , ATBA_CD
                                                 , ATBA_DMTR_CNTE
                                                 , ATBA_SSBT_RSLT_CNTE
        
                                                 , FSR_STF_NO  
                                                 , FSR_DTM     
                                                 , FSR_PRGM_NM 
                                                 , FSR_IP_ADDR 
                                                 , LSH_STF_NO  
                                                 , LSH_DTM     
                                                 , LSH_PRGM_NM 
                                                 , LSH_IP_ADDR 
                                                 
                                                 , EXM_CD      
                                                 , INPT_SEQ    
                                                 , HSP_TP_CD   
                                                 , SSBT_CTG_CD 
                                                 )
                                         VALUES  ( IN_SPCM_NO
                                                 , IN_ACPT_DT
                                                 , TO_NUMBER(L_EXM_ACPT_NO)
                                                 
                                                 , L_MM_CLMD_CD
                                                 , 'P' --L_MM_LABM_NEPO_TP_CD
                                                 
                                                 , V_LN_SEQ
                                                 , V_CLY_SEQ
                                                 
                                                 , L_MM_ATBA_CD
                                                 , L_MM_ATBA_DMTR_CNTE
                                                 , L_MM_ATBA_SSBT_RSLT_CNTE
        
                                                 , IN_HIS_STF_NO         
                                                 , SYSDATE            
                                                 , 'INFO'
                                                 , SYS_CONTEXT('USERENV','IP_ADDRESS')
                                                 , IN_HIS_STF_NO         
                                                 , SYSDATE            
                                                 , 'INFO'
                                                 , SYS_CONTEXT('USERENV','IP_ADDRESS')
                                                 
                                                 , T_EXMCD                -- EXM_CD
                                                 , I                      -- INPT_SEQ
                                                 , IN_HSP_TP_CD           -- 병원구분
                                                 , L_MM_SSBT_CTG_CD       -- SSBT_CTG_CD
                                                 );
                                                        
                                           
        
--RAISE_APPLICATION_ERROR(-20001, L_ACPT_DTM || '\' || L_EXM_ACPT_NO || '\' || L_MM_CLMD_CD  || '\' || L_MM_LABM_NEPO_TP_CD
--                                                     || '\' || SQL%ROWCOUNT
--                                           ) ;                             
                                           
                                           
                                EXCEPTION
                                      WHEN OTHERS THEN
                                         IO_ERRYN  := 'Y';
                                         IO_ERRMSG := '미생물감수성결과 추가 시 에러 발생. ERRDESC = ' || SUBSTR(SQLERRM, 10, 100);
                                         RETURN;
                        END;
                    END IF;

--                EXCEPTION
--                        WHEN OTHERS THEN
--                           IO_ERRYN  := 'Y';
--                           IO_ERRMSG := '미생물감수성결과 UPDATE 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                           RETURN;
                END;


            END LOOP;

            IF  IO_ERRYN = 'Y' THEN
                RETURN;
            END IF;
        END IF;
        
        
        IF  L_FLAG > 0 THEN
            FOR I IN 1 .. L_FLAG
            LOOP

                --L_DEL_SEQ       := TT_DEL_SEQ(I);
                L_MCB_EQUP_SEQ        :=  TT_MCB_EQUP_SEQ     (I);
                L_MVM_CD              :=  TT_MVM_CD    (I);
                L_MVRT_CNTE           :=  TT_MVRT_CNTE       (I);
                L_SRUM_CLS_CNTE       :=  TT_SRUM_CLS_CNTE (I);
                L_STRG_CNTE           :=  TT_STRG_CNTE   (I);
--                L_CLMD_ANTN_CNTE    :=  TT_CLMD_ANTN_CNTE   (I);
                L_CLMD_CD              :=  TT_CLMD_CD     (I);
                L_LABM_NEPO_TP_CD      :=  TT_LABM_NEPO_TP_CD     (I);
                L_LN_SEQ               :=  TT_LN_SEQ     (I);

                               
                IO_ERRYN   := '';
                IO_ERRMSG   := '';              

                    BEGIN                 
                         SELECT EXM_CD
                              , MVRT_CNTE
                           INTO T_EXMCD
                              , T_MVRT_CNTE
                           FROM MSELMCRD
                          WHERE SPCM_NO                        = IN_SPCM_NO
                            AND TO_CHAR(ACPT_DT, 'YYYYMMDD')   = L_ACPT_DTM
                            AND LPAD(EXM_ACPT_NO, 6, '0')      = TO_NUMBER(L_EXM_ACPT_NO)
--                            AND CLY_SEQ                        = L_LN_SEQ           
                            AND LN_SEQ                         = L_LN_SEQ
                            AND HSP_TP_CD                      = IN_HSP_TP_CD
--                            AND CLMD_CD                      = L_CLMD_CD
--                            AND LABM_NEPO_TP_CD              = IN_LABM_NEPO_TP_CD    --L_MM_LABM_NEPO_TP_CD
--                            AND LN_SEQ                       = TO_NUMBER(L_LN_SEQ)
                            ;
                            
                        EXCEPTION
                                WHEN OTHERS THEN
                                   IO_ERRYN  := 'Y';
                                   IO_ERRMSG := '미생물 TEXT결과 존재여부 조회시 에러 발생. ERRDESC = ' || SQLERRM;
                                   RETURN;      
                    END; 

                    BEGIN
                        SELECT WK_UNIT_CD
                             , EXRS_RMK_CNTE
                             , EXRM_RMK_CNTE
                          INTO L_WK_UNIT_CD
                             , L_EXRS_RMK_CNTE
                             , L_EXRM_RMK_CNTE
                          FROM MSELMAID
                         WHERE SPCM_NO   = IN_SPCM_NO
                           AND EXM_CD    = T_EXMCD
                           AND HSP_TP_CD = IN_HSP_TP_CD
                        ; 
                        
                        -- 결과비고 - 기존 결과비고 + 미생물 균결과(ID결과) 조합하여 결과비고에 적용
                        IF L_EXRS_RMK_CNTE = '' OR L_EXRS_RMK_CNTE IS NULL THEN
                            L_EXRS_RMK_CNTE := T_MVRT_CNTE;
                        ELSE
                            L_EXRS_RMK_CNTE := L_EXRS_RMK_CNTE || CHR(13) || T_MVRT_CNTE;
                        END IF;  
                        
                        
                        EXCEPTION
                                WHEN OTHERS THEN
                                   IO_ERRYN  := 'Y';
                                   IO_ERRMSG := '검사결과에서 SLIP정보 조회시 에러 발생. ERRDESC = ' || SQLERRM;
                                   RETURN;                               
                    END; 

                    -- 검사결과 저장
                    -- 2021.12.29 SCS : 저장 프로시저 호출로 변경함
                    XSUP.PKG_MSE_LM_EXAMRSLT.SAVE
                                 (  'T'                                        -- 임시
                                  , L_PT_NO                                    -- 환자번호
                                  , IN_SPCM_NO
                                  , L_EXRM_EXM_CTG_CD                          -- IN_EXM_CTG_CD       IN      MSELMAID.EXRM_EXM_CTG_CD%TYPE
                                  , L_WK_UNIT_CD                               -- IN_WK_UNIT_CD       IN      MSELMAID.WK_UNIT_CD%TYPE
                                  , T_EXMCD                                    -- IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                                  , ''                                         -- IN_MIDL_BRFG_CNTE   IN      MSELMAID.MIDL_BRFG_CNTE%TYPE
                                                                               
                                  , ''                                         -- IN_EXRS_CNTE        IN      MSELMAID.EXRS_CNTE%TYPE
                
                                  , ''                                         -- IN_RMK_CNTE         IN      MSELMCED.RMK_CNTE%TYPE
                                  , ''                                         -- IN_LMQC_RMK_CNTE    IN      MSELMCED.LMQC_RMK_CNTE%TYPE
                                  , L_EXRS_RMK_CNTE                            -- IN_EXRS_RMK_CNTE    IN      MSELMAID.EXRM_RMK_CNTE%TYPE
                                  , L_EXRM_RMK_CNTE                            -- IN_EXRM_RMK_CNTE    IN      MSELMAID.EXRM_RMK_CNTE%TYPE
                                 
                                  , ''                                         -- IN      MSELMAID.DLT_YN%TYPE
                                  , ''                                         -- IN      MSELMAID.PNC_YN%TYPE
                                  , ''                                         -- IN_CVR_YN         --  IN      MSELMAID.CVR_YN%TYPE
                                 
                                  , IN_EQUP                                    -- HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                                  , IN_HSP_TP_CD                               -- HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                                  , 'INTERFACE'                                -- HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                                  , SYS_CONTEXT('USERENV','IP_ADDRESS')        -- HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE

                                  , ''                                        -- IN_RSLT_BRFG_CNTE   IN      MSELMAID.RSLT_BRFG_CNTE%TYPE
                                 
                                  , IO_ERRYN -- IO_ERR_YN           IN OUT  VARCHAR2
                                  , IO_ERRMSG --IO_ERR_MSG          IN OUT  VARCHAR2 
                                 );
                   
                    IF IO_ERRYN = 'Y' THEN
                        RETURN;
                    END IF;
               
            END LOOP;

            IF  IO_ERRYN = 'Y' THEN
                RETURN;
            END IF;           

        END IF;



        /***************2019-04-04 예강이법 추가.********************/     
--        IF XSUP.FT_MSE_B_NAME('ERR', '013', IN_HSP_TP_CD) = 'Y' THEN
--            BEGIN
--                 XSUP.PC_MSE_RSLT_HISTORY_SAVE( IN_SPCM_NO
--                                              , IN_HIS_STF_NO
--                                              , 'INTERFACE.PC_MSE_MVM_RESULT_UPDATE'
--                                                 , SYS_CONTEXT('USERENV','IP_ADDRESS')
--                                              , IN_HSP_TP_CD
--                                                 , IO_ERRYN
--                                              , IO_ERRMSG );
--            
--            EXCEPTION
--                 WHEN  OTHERS  THEN
--                       IO_ERRYN  := 'Y';
--                       IO_ERRMSG := '결과 저장중 이력 저장시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE);
--                       RETURN;
--               END;
--        END IF; 
        
                       
        -- 배양 TEXT결과 존재시 TEXT 결과값 입력    2018.01.04  
--        IF IN_EXRS_CNTE IS NOT NULL THEN   
--            BEGIN
--                 SELECT DISTINCT EXM_CD
--                   INTO T_EXMCD
--                   FROM MSELMCRD
--                  WHERE SPCM_NO               = IN_SPCM_NO
--                    AND ACPT_DT             = IN_ACPT_DT           --TO_DATE('20' || IN_ACPT_DT, 'YYYYMMDD')
--                    AND EXM_ACPT_NO         = L_EXM_ACPT_NO
--                    AND CLMD_CD             = L_MM_CLMD_CD
--                    AND LABM_NEPO_TP_CD     = IN_LABM_NEPO_TP_CD    --L_MM_LABM_NEPO_TP_CD
--                    AND LN_SEQ              = TO_NUMBER(L_MM_LN_SEQ)
--                    AND HSP_TP_CD             = IN_HSP_TP_CD --병원구분
--                    ;
--
--                BEGIN
--                    
--                    UPDATE MSELMAID 
--                       SET EXRS_CNTE             = IN_EXRS_CNTE
--                         , SPEX_PRGR_STS_CD     = IN_SPEX_PRGR_STS_CD                                              -- 검사결과상태값
--                         , RSLT_BRFG_YN         = DECODE(IN_SPEX_PRGR_STS_CD, '2', 'Y', 'N')                       -- 결과보고여부 
--                     WHERE SPCM_NO                 = IN_SPCM_NO
--                       AND EXM_CD                = T_EXMCD
--                       AND HSP_TP_CD             = IN_HSP_TP_CD --병원구분 
--                       ;
--                       
--                       EXCEPTION
--                        WHEN OTHERS THEN
--                           IO_ERRYN  := 'Y';
--                           IO_ERRMSG := '배양TEXT결과 저장시 에러 발생. ERRDESC = ' || TO_CHAR(SQLCODE);
--                           RETURN;
--                   END;    
--            END;
--        END IF;
        

    END PC_MSE_MVM_RESULT_UPDATE;
    

                               
    /***********************************************************************************************
    *    서비스이름      : PC_MSE_ORDER_ACPTNO_SELECT
    *    최초 작성일     : 2018.01.23
    *    최초 작성자     : ezCaretech
    *    DESCRIPTION   : 접수번호로 오더정보 조회(접수번호(검사일자 년월일 8자리+접수번호) 202112070001, 202112080001)
    *    
    *                    VAR OUT_CURSOR REFCURSOR;
    *                    EXEC XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_ORDER_ACPTNO_SELECT(  '2112080001' 
    *                                                                               , 'LHG02' -- 검사코드 없이 조회시는 '' 으로 전달
    *                                                                               , '01'
    *                                                                               , :OUT_CURSOR
    *                                                                               );    
    *
    *                  : 검사코드별 환자 오더정보 조회
    *                  : 접수번호 파라메터 : 검사일자 년월일 8자리+XXXX+환자번호 : 20211213XXXX512322574
    *                  : 처방코드 파라메터 : 검사코드 조합(검사코드,검사코드,검사코드,검사코드,....... )               
    *                    VAR OUT_CURSOR REFCURSOR;
    *                    EXEC XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_ORDER_ACPTNO_SELECT(  '20220314XXXX23583367'
   *                                                                               , 'LHS14,LHC03,LHC06,LCF11,LCG57,LCG74,LHG49,LCG03'
   *                                                                               , '02'
   *                                                                               , :OUT_CURSOR
   *                                                                               );    
    *
    **********************************************************************************************/        
    PROCEDURE PC_MSE_ORDER_ACPTNO_SELECT (   IN_EXM_ACPT_NO IN   VARCHAR2           -- <P1> 접수번호(검사일자 년월일 8자리+접수번호) 202112070001, 202112080001
                                           , IN_EXM_CD      IN   VARCHAR2           -- <P2> 검사코드
                                           , IN_HSP_TP_CD   IN   VARCHAR2           -- <P3> 병원코드
                                           , OUT_CURSOR     OUT  RETURNCURSOR )
    IS
        --변수선언
        WK_CURSOR                 RETURNCURSOR ;    
         
        L_EXM_ACPT_NO             VARCHAR2(20)  := '';    
        L_ACPT_DTM                VARCHAR2(20)  := '';    
        L_PT_NO                   VARCHAR2(20)  := '';    
            
        BEGIN  
         
--            L_ACPT_DTM    := '20' || SUBSTR(IN_EXM_ACPT_NO, 1, 6);
            L_ACPT_DTM    := SUBSTR(IN_EXM_ACPT_NO, 1, 8);            
            L_EXM_ACPT_NO := SUBSTR(IN_EXM_ACPT_NO, 9, 4);
                       
--            RAISE_APPLICATION_ERROR(-20001, L_ACPT_DTM || '\' || L_EXM_ACPT_NO) ;                       
                       

            
            -- 검사코드별 환자 오더정보 조회(접수번호-검사일자 년월일 8자리+XXXX+환자번호) 20211207XXXX19828276)
            --                          (검사코드-LCF11,LCF06,LCG57,LCG74,LHG49,LCG03)                  
            IF L_EXM_ACPT_NO = 'XXXX' THEN    
                L_PT_NO := SUBSTR(IN_EXM_ACPT_NO, 13, 8);
                
                BEGIN
                    OPEN WK_CURSOR FOR
                    
                        WITH ORDERLIST AS
                        ( SELECT /*+ INDEX(A MSELMAID_SI07) */
                                   A.HSP_TP_CD
                                 , A.PT_NO
                                 , B.PT_NM
                                 , TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD') ACPT_DTM
                                 , A.EXM_CD
                             FROM MSELMAID A
                                , PCTPCPAM_DAMO B
                            WHERE 1=1
                              AND A.HSP_TP_CD       = IN_HSP_TP_CD
                              AND A.PT_NO           = L_PT_NO
                              AND A.ACPT_DTM BETWEEN TO_DATE(L_ACPT_DTM, 'YYYYMMDD')
                                                 AND TO_DATE(L_ACPT_DTM, 'YYYYMMDD') + 0.99999
                              AND A.EXM_CD IN ( SELECT REGEXP_SUBSTR ( IN_EXM_CD, '[^,]+', 1, LEVEL )
                                                  FROM DUAL
                                                CONNECT BY LEVEL <= REGEXP_COUNT ( IN_EXM_CD, ',' ) + 1
                                              )
                        
                              AND A.PT_NO           = B.PT_NO
                            GROUP BY A.HSP_TP_CD, A.PT_NO, B.PT_NM, TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD'), A.EXM_CD
                        )
                        SELECT A.PT_NO, A.PT_NM, A.ACPT_DTM, A.EXM_CD
                             , (SELECT TO_CHAR(AA.ACPT_DTM, 'YYYYMMDD') || ' ' || SMP_EXRS_CNTE
                                  FROM MSELMAID AA
                                 WHERE AA.HSP_TP_CD = A.HSP_TP_CD
                                   AND AA.PT_NO     = A.PT_NO
                                   AND AA.EXM_CD    = A.EXM_CD
                                   AND AA.ACPT_DTM = (SELECT MAX(ACPT_DTM)
                                                        FROM MSELMAID
                                                       WHERE HSP_TP_CD       = AA.HSP_TP_CD
                                                         AND PT_NO           = AA.PT_NO
                                                         AND EXM_CD          = AA.EXM_CD
                                                         AND TRUNC(ACPT_DTM) = TO_DATE(L_ACPT_DTM, 'YYYY-MM-DD')
                                                         AND RSLT_BRFG_YN    = 'Y'
                                                     )
                               ) EXRS_CNTE
                        
                             , (SELECT TO_CHAR(AA.ACPT_DTM, 'YYYYMMDD') || ' ' || NVL(SMP_EXRS_CNTE,EXRS_CNTE)
                                  FROM MSELMAID AA
                                 WHERE AA.HSP_TP_CD = A.HSP_TP_CD
                                   AND AA.PT_NO     = A.PT_NO
                                   AND AA.EXM_CD    = A.EXM_CD
                                   AND AA.ACPT_DTM = (SELECT MAX(ACPT_DTM)
                                                        FROM MSELMAID
                                                       WHERE HSP_TP_CD       = AA.HSP_TP_CD
                                                         AND PT_NO           = AA.PT_NO
                                                         AND EXM_CD          = AA.EXM_CD
                                                         AND TRUNC(ACPT_DTM) < TO_DATE(L_ACPT_DTM, 'YYYY-MM-DD')
                                                         AND RSLT_BRFG_YN    = 'Y'
                                                     )
                               ) RCN_EXRS_CNTE
                        
                          FROM ORDERLIST A
                         WHERE 1=1                
                          ;
                      
                     OUT_CURSOR := WK_CURSOR ;
                
                     --예외처리
                     EXCEPTION
                         WHEN OTHERS THEN
                             RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_ORDER_ACPTNO_SELECT-검사코드별 환자조회' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
                END ; 
                
                RETURN;
            END IF;
            
                                   
                          
            BEGIN                        
                            
                --BODY
                OPEN WK_CURSOR FOR
                                        
                    SELECT DISTINCT D.SPCM_NO
                         , TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD HH24:MI:SS') ACPT_DTM 
                         , A.EXM_ACPT_NO 
                         , C.PT_NO 
                         , C.PT_NM 
                         , C.SEX_TP_CD 
                         , TO_CHAR(C.PT_BRDY_DT, 'YYYY-MM-DD') PT_BRDY_DT
                         , B.PT_HME_DEPT_CD 
                         , B.WD_DEPT_CD 
                         , A.EXM_CD
                         , A.TH1_SPCM_CD
                         , D.HR24_URN_EXM_TM
                         , D.HR24_URN_EXM_VLM_CNTE
                         , E.RPRN_EXM_CD
--                         , DECODE(A.SPEX_PRGR_STS_CD, '1', 'C', D.EXM_PRGR_STS_CD)  EXM_PRGR_STS_CD                         
                         , DECODE(A.SMP_EXRS_CNTE, NULL, 'C', 'D')                  EXM_PRGR_STS_CD
                         , A.SMP_EXRS_CNTE
                      FROM MSELMCED D 
                         , MSELMAID A
                         , MOOOREXM B
                         , PCTPCPAM_DAMO C
                         , (
                             SELECT A.PT_NO
                                  , A.ORD_DT
                                  , A.SPCM_NO
                                  , A.EXM_CD
                                  , A.HSP_TP_CD
                                  , NVL(BB.RPRN_EXM_CD, A.EXM_CD) RPRN_EXM_CD
                                  , ROW_NUMBER()  OVER (PARTITION BY A.PT_NO
                                                                  , A.ORD_DT
                                                                  , A.SPCM_NO
                                                                  , A.EXM_CD
                                                                  , A.HSP_TP_CD
                                                           ORDER BY NVL(BB.RPRN_EXM_CD, A.EXM_CD)) ROW_NUM
                               FROM (   SELECT /*+ INDEX(A MSELMAID_SI03) */ -- 힌트추가 2018.03.16 
                                               DISTINCT
                                               C.PT_NO
                                             , D.ORD_DT
                                             , D.SPCM_NO
                                             , NVL(A.EXM_CD, B.ORD_CD) EXM_CD
                                             , D.HSP_TP_CD
                                          FROM MSELMAID A
                                             , MOOOREXM B
                                             , PCTPCPAM_DAMO C
                                             , MSELMCED D
                                         WHERE D.SPCM_NO                       = B.SPCM_PTHL_NO
                                           AND D.HSP_TP_CD                     = B.HSP_TP_CD
                                           AND LPAD(A.EXM_ACPT_NO, 4, '0')     = L_EXM_ACPT_NO
                                           AND D.HSP_TP_CD                     = IN_HSP_TP_CD               
                                           AND A.ACPT_DTM BETWEEN TO_DATE(L_ACPT_DTM, 'YYYY-MM-DD') 
                                                              AND TO_DATE(L_ACPT_DTM, 'YYYY-MM-DD') + 0.99999
                                           AND B.PT_NO                        = C.PT_NO
                                           AND A.SPCM_NO(+)                   = D.SPCM_NO
                                           AND A.HSP_TP_CD(+)                 = D.HSP_TP_CD
                                           AND A.EXM_CD                       = DECODE(IN_EXM_CD, NULL, A.EXM_CD, IN_EXM_CD)
                                    ) A
                                    , MOOOREXM AA
                                    , MSELMEBV BB
                                WHERE AA.ORD_DT       = A.ORD_DT
                                  AND AA.PT_NO        = A.PT_NO
                                  AND AA.SPCM_PTHL_NO = A.SPCM_NO
                                  AND AA.HSP_TP_CD    = A.HSP_TP_CD
                                  AND BB.EXM_CD       = A.EXM_CD
                                  AND AA.ORD_CD       = BB.RPRN_EXM_CD
                                  AND AA.HSP_TP_CD    = BB.HSP_TP_CD
                        ) E
                    WHERE 1=1
                      AND D.SPCM_NO           = B.SPCM_PTHL_NO
                      AND D.HSP_TP_CD         = B.HSP_TP_CD
                      AND D.SPCM_NO           = E.SPCM_NO            -- IN_SPCM_NO
                      AND D.HSP_TP_CD         = E.HSP_TP_CD -- IN_HSP_TP_CD
                      AND B.PT_NO             = C.PT_NO
                      AND A.SPCM_NO(+)        = D.SPCM_NO
                      AND A.HSP_TP_CD(+)      = D.HSP_TP_CD
                      AND C.PT_NO             = E.PT_NO
                      AND D.ORD_DT            = E.ORD_DT
                      AND D.SPCM_NO           = E.SPCM_NO
                      AND A.EXM_CD(+)         = E.EXM_CD
                      AND D.HSP_TP_CD         = E.HSP_TP_CD
                      AND E.ROW_NUM = 1
                    ORDER BY A.EXM_CD
                    ;                   
                        
                    OUT_CURSOR := WK_CURSOR ;
    
                --예외처리
              EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_ORDER_ACPTNO_SELECT' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END ; 
       
    END PC_MSE_ORDER_ACPTNO_SELECT;   
    


    /**********************************************************************************************
    *    서비스이름  : PC_MSE_INS_MSSIRSRD
    *    최초 작성일 : 2018.01.23
    *    최초 작성자 : 김금덕
    *    DESCRIPTION : 진단검사의학과 인터페이스 연결시 이력남기기
    **********************************************************************************************/
    PROCEDURE PC_MSE_INS_MSSIRSRD ( IN_HSP_TP_CD        IN      VARCHAR2    -- 병원구분
                                  , IN_SPCM_NO          IN      VARCHAR2    -- 환자번호
                                  , IN_RMK_CNTE         IN      VARCHAR2    -- XML 내용 
                                  , IN_PT_NO            IN      VARCHAR2    -- 차트번호  
                                  , IO_ERRYN            IN OUT  VARCHAR2
                                  , IO_ERRMSG           IN OUT  VARCHAR2
                                  )
    IS


    BEGIN
        
            INSERT INTO MSSIRSRD --인터페이스장비연동정보
                     ( HSP_TP_CD                                                    --병원구분코드  *
                     , EQUP_CD                                                      --장비코드     *
                     , EXM_DT                                                       --검사일자     *
                     , SV_SEQ                                                       --저장순번     * 시퀀스
                     , EQUP_EXM_CD                                                  --장비검사코드  * 장비코드
                     
                     , PT_NO                                                        --환자번호
                     , SPCM_NO                                                      --검체번호
                     , CMPL_YN                                                      --완료여부
                     , EXRS_CNTE                                                    --검사결과내용
                     , RMK_CNTE                                                     --비고내용(XML 내용)
                     
                     , EQUP_CNTE                                                    --장비내용
                     , FSR_DTM                                                      --최초등록일시
                     , FSR_SID                                                      --최초등록직원식별ID
                     , FSR_PRGM_NM                                                  --최초등록프로그램명
                     , FSR_IP_ADDR                                                  --최초등록IP주소
                     
                     , LSH_DTM                                                      --최종변경일시
                     , LSH_SID                                                      --최종변경직원식별ID
                     , LSH_PRGM_NM                                                  --최종변경프로그램명   
                     , LSH_IP_ADDR                                                  --최종변경IP주소 
                      )
              VALUES  ( IN_HSP_TP_CD
--                      , DECODE(IN_SPCM_NO, '', IN_PT_NO, IN_SPCM_NO)      
                      , DECODE(IN_SPCM_NO, '', NVL(NVL(IN_PT_NO,IN_SPCM_NO), 'ACK'), IN_SPCM_NO)      
                      , SYSDATE
                      , XSUP.SEQ_SV_NO.NEXTVAL
                      , 'ACK'      
                      
                      , DECODE(IN_PT_NO, '', '12345678', IN_PT_NO)
                      , IN_SPCM_NO
                      , ''
                      , IN_RMK_CNTE                                                    -- 비고내용(XML 내용)                                         
                      , ''
                      
                      , ''            
                      , SYSDATE
                      , 'ACK01'
                      , 'ACK인터페이스'         
                      , SYS_CONTEXT('USERENV','IP_ADDRESS')            
                      
                      , SYSDATE 
                      , 'ACK01'
                      , 'ACK인터페이스'
                      , SYS_CONTEXT('USERENV','IP_ADDRESS')
                      );

                EXCEPTION
                     WHEN OTHERS THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'PC_MSE_INS_MSSIRSRD-인터페이스장비연동정보 추가 시 에러 발생. ERRDESC = ' || SUBSTR(SQLERRM, 10, 100);
                        RETURN;

        IO_ERRYN  := 'N';
        IO_ERRMSG := '';
    
    END PC_MSE_INS_MSSIRSRD;    

    /**********************************************************************************************
        *    서비스이름  : PC_MSE_BLCL_ATS_SELECT
        *    최초 작성일 : 2018.03.07
        *    최초 작성자 : 김금덕 
        *    DESCRIPTION : ATS2000 장비 인터페이스 검체번호로 채혈상태조회
    **********************************************************************************************/ 
    PROCEDURE PC_MSE_BLCL_ATS_SELECT (  IN_SPCM_NO     IN   VARCHAR2                 -- 검체번호
                                      , IN_HSP_TP_CD   IN   VARCHAR2               -- 병원코드     : 01 목동 02 서울
                                      , OUT_CURSOR     OUT  RETURNCURSOR )
    IS
        --변수선언
         WK_CURSOR                 RETURNCURSOR ; 
    
        BEGIN       
            BEGIN
                --BODY
                OPEN WK_CURSOR FOR
                       
                        SELECT DISTINCT
                               A.PT_NO                                                                                          -- 환자번호
                             , C.PT_NM                                                                                          -- 환자이름
                             , A.BLCL_DTM                                                                                       -- 채혈일시
                             , A.PACT_TP_CD                                                                                     -- 원무접수구분코드
                             , B.PT_HME_DEPT_CD                                                                                 -- 진료과
                             , B.PBSO_DEPT_CD                                                                                   -- 발행처
                             , A.EXRM_EXM_CTG_CD                                                                                -- 검사실검사분류코드
                             , D.EXM_CTG_NM                                                                                     -- 검사분류명
                             , NVL(A.EMRG_YN, 'N')   EMRG_YN                                                                    -- 응급여부
--                             , DECODE(A.EXM_PRGR_STS_CD, 'B', 'N', 'Y') ACPT_YN                                                 -- 접수여부              
--                             , DECODE(NVL(A.SPCM_HDOV_STF_NO, 'N'), A.SPCM_HDOV_STF_NO, 'Y', 'N') G_ACPT_YN                     -- 가접수여부     
--                             , NVL(A.ODY_YN, 'N')    EXRS_TDY_REQ_YN                                                            -- 당일여부
--                             , NVL(A.RST_CNSG_YN, 'N')        RST_CNSG_YN                                                     -- 양병원 수탁여부
--                             , A.RST_CNSG_HDOV_DTM                                                                            -- 위수탁 가접수시간
--                             , A.RST_CNSG_HDOV_STF_NO                                                                         -- 위수탁 가접수자
                          FROM MSELMCED A
                             , MOOOREXM B
                             , PCTPCPAM_DAMO C                            
                             , MSELMCTC D
                         WHERE A.HSP_TP_CD       = IN_HSP_TP_CD
                           AND A.SPCM_NO         = IN_SPCM_NO
                           AND A.HSP_TP_CD       = B.HSP_TP_CD
                           AND A.SPCM_NO         = B.SPCM_PTHL_NO
                           AND A.PT_NO           = C.PT_NO
                           AND A.HSP_TP_CD       = D.HSP_TP_CD  (+)
                           AND A.EXRM_EXM_CTG_CD = D.EXM_CTG_CD (+)
                           ;                       
                        
                      OUT_CURSOR := WK_CURSOR ;
    
                --예외처리
              EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_BLCL_ATS_SEL' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END ; 
       
    END PC_MSE_BLCL_ATS_SELECT;    

    /**********************************************************************************************
    *    서비스이름  : PC_MSE_INS_ATS_SPNO 검체접수
    *    최초 작성일 : 2018.03.08
    *    최초 작성자 : 김금덕 
    *    Description : 인터페이스 진단검사
    **********************************************************************************************/
    PROCEDURE PC_MSE_INS_ATS_SPNO (  IN_HSP_TP_CD         IN      VARCHAR2   --<P0> 병원구분
                                   , IN_SPCM_NO            IN      VARCHAR2   --<P1> 검체번호
                                   , IN_EXM_DT             IN      VARCHAR2   --<P2> 검사일자
                                   , IN_SPCID              IN      VARCHAR2   --<P3> 최초입력자        : (직번) - 70131                                            
                                   , IN_TIME            IN      VARCHAR2   --<P4> TIME 
                                   , IN_VOL                IN      VARCHAR2   --<P5> VOLUME
                                   , IN_EQUP            IN      VARCHAR2   --<P6> 장비명
                                   , IO_ERRYN              IN OUT  VARCHAR2   -- 오류여부
                                   , IO_ERRMSG             IN OUT  VARCHAR2   -- 오류메세지
                                 )                               
    IS           
    
    EXT_CNT    NUMBER  :=  0;
           
    S_TH1_SPCM_CD           MSELMCED.TH1_SPCM_CD%TYPE       := '';
     S_EXRM_EXM_CTG_CD       MSELMCED.EXRM_EXM_CTG_CD%TYPE   := '';
    S_PT_NO                   PCTPCPAM_DAMO.PT_NO%TYPE           := '';
                  
    S_PRGM_NM                  MSELMCED.LSH_PRGM_NM%TYPE       := 'PC_MSE_INS_ATS_SPNO';
    S_IP_ADDR                  MSELMCED.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');
              
    IO_TOTNO     NUMBER         := '';
    IO_ACPTNO     NUMBER        := '';
    
    BEGIN
               
        
        BEGIN 
            
            SELECT DISTINCT
                   A.TH1_SPCM_CD
--                 ,  A.EXRM_EXM_CTG_CD
                 , DECODE(A.TLA_ORD_SND_FLAG_CNTE, 'TLA', 'TLA', A.EXRM_EXM_CTG_CD) EXRM_EXM_CTG_CD
                 , B.PT_NO  
              INTO S_TH1_SPCM_CD
                 , S_EXRM_EXM_CTG_CD
                 , S_PT_NO
              FROM MSELMCED A
                 , MOOOREXM B
                 , PCTPCPAM_DAMO C
             WHERE A.SPCM_NO         = IN_SPCM_NO
               AND A.HSP_TP_CD       = IN_HSP_TP_CD
               AND A.SPCM_NO         = B.SPCM_PTHL_NO
               AND A.HSP_TP_CD       = B.HSP_TP_CD  
--               AND B.RPY_STS_CD     = 'Y'
               AND B.ODDSC_TP_CD     = 'C'
               AND B.PT_NO           = C.PT_NO
               ;      
               
            EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    IO_ERRYN  := 'Y';
                    IO_ERRMSG := '접수할 검체가 없습니다. = ' || TO_CHAR(SQLCODE);
                    RETURN;  

        END;

        XSUP.PKG_MSE_LM_SPCMACPT.ACPT( IN_SPCM_NO
                                     , S_PT_NO 

                                     , IN_EXM_DT
                                     , S_EXRM_EXM_CTG_CD
                                     , S_TH1_SPCM_CD
                        
                                     , '' --IN_RMK_CNTE          IN          VARCHAR2
                                     
                                     , IN_HSP_TP_CD
                                     , IN_SPCID
                                     , S_PRGM_NM
                                     , S_IP_ADDR
                                     
                                     , IO_ERRYN
                                     , IO_ERRMSG
                                     );
                                                    
--        PC_MSE_SPCMACPT02_NEW  ( IN_SPCM_NO                --     검체번호          
--                               , IN_EXM_DT               --  검사일자         
--                               , IN_HSP_TP_CD            --  병원구분             
--                               , S_EXRM_EXM_CTG_CD       --    검사분류
--                               , S_TH1_SPCM_CD           --  검체코드
--                               , S_PT_NO                 --     환자번호
--                               , IN_TIME                  -- 
--                               , IN_VOL                   --     
--                               , IN_SPCID               --     등록자
--                               , 'N'                     --    IN_MICRO             
--                               , ''    --IN_RMK_CNTE              --     
--                               , 'Y'                     --    IN_ACPTNOYN        
--                               , 'N'                     --    IN_EMRG_YN         
--                               , S_PRGM_NM                 --    HIS_PRGM_NM          
--                               , S_IP_ADDR              --    HIS_IP_ADDR          
--                               , IO_TOTNO             
--                               , IO_ACPTNO                
--                               , IO_ERRYN            
--                               , IO_ERRMSG           
--                             );
                                 
        IF IO_ERRYN = 'Y' THEN
            IO_ERRYN  := 'Y';
            IO_ERRMSG := '검체접수 오류 발생 ' || IO_ERRMSG;
            RETURN;
        END IF; 
        
        IF IO_ACPTNO = 0 THEN
            IO_ERRYN  := 'Y';
            IO_ERRMSG := '검체접수 오류 발생 접수번호 오류' || IO_ERRMSG;
            RETURN;
        END IF;     
        
        BEGIN
        
            UPDATE MSELMCED
               SET DEXM_MDSC_EQUP_CD     = IN_EQUP            -- 장비코드
                 , EQUP_CFMT_DTM         = SYSDATE            -- 장비확인일시  
                 , LSH_DTM               = SYSDATE           -- 최종변경일시 
                 , LSH_PRGM_NM           = S_PRGM_NM         -- 최종변경프로그램명
             WHERE HSP_TP_CD             = IN_HSP_TP_CD
               AND SPCM_NO               = IN_SPCM_NO
               ;  
        
        END;
        
    END PC_MSE_INS_ATS_SPNO;
    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_UPT_GA_ACPT 검체가접수
    *    최초 작성일 : 2018.03.13
    *    최초 작성자 : 김금덕 
    *    Description : 인터페이스 진단검사
    **********************************************************************************************/
    PROCEDURE PC_MSE_UPT_GA_ACPT   ( IN_HSP_TP_CD         IN      VARCHAR2   -- <P0>병원구분
                                   , IN_SPCM_NO            IN      VARCHAR2   -- <P1>검체번호
                                   , IN_SPCID            IN      VARCHAR2   -- <P2>사용자
                                   , IN_EQUP            IN      VARCHAR2   -- <P3>장비명
                                   , IO_ERRYN              IN OUT  VARCHAR2   -- 오류여부
                                   , IO_ERRMSG             IN OUT  VARCHAR2   -- 오류메세지
                                 )                               
    IS           
                      
    S_PRGM_NM                  MSELMCED.LSH_PRGM_NM%TYPE       := 'PC_MSE_UPT_GA_SPCMNO';
    S_IP_ADDR                  MSELMCED.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');
              
    BEGIN
    
        BEGIN 
                     
            UPDATE MSELMCED 
               SET SPCM_HDOV_DTM        = SYSDATE
                 , SPCM_HDOV_STF_NO     = IN_SPCID
                 , SPCM_RECV_STF_NO     = 'PPPPP'
                 , DEXM_MDSC_EQUP_CD    = IN_EQUP                -- MUT_M
                 , LSH_STF_NO           = IN_SPCID
                 , LSH_DTM              = SYSDATE
                 , LSH_PRGM_NM          = S_PRGM_NM
                 , LSH_IP_ADDR          = S_IP_ADDR
             WHERE SPCM_NO              = IN_SPCM_NO
               AND HSP_TP_CD            = IN_HSP_TP_CD   
               AND EXRM_EXM_CTG_CD      LIKE 'L%'
            ;
                  
            IF SQL%ROWCOUNT = 0 THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := '가접수 처리가 실패 되었습니다.';
                RETURN;
              END IF;  
              
              EXCEPTION
              WHEN OTHERS THEN
                   IO_ERRYN  := 'Y';
                   IO_ERRMSG := '가접수 UPDATE 중 에러 발생 ERRCODE = ' || TO_CHAR(SQLCODE);
                   RETURN;
               
        END;
        
    -- 응급일 경우 실시일시 반영(수납때문에)     2018.06.14
        BEGIN
              
            UPDATE MOOOREXM
               SET EXRM_HH_DTM  = SYSDATE
             WHERE SPCM_PTHL_NO = IN_SPCM_NO
               AND HSP_TP_CD    = IN_HSP_TP_CD
               AND ODDSC_TP_CD  = 'C'
               AND PACT_TP_CD   = 'E'             -- 응급 
               AND BLCL_YN ='Y'                 -- 채혈상태
             ;
                 
--             IF SQL%ROWCOUNT = 0 THEN
--                IO_ERRYN  := 'Y';
--                IO_ERRMSG := '응급실 검사실시일시 처리가 실패 되었습니다.';
--                RETURN;
--              END IF;  
              -- 2018-06-16 방정섭 막음.
--              EXCEPTION
--              WHEN OTHERS THEN
--                   IO_ERRYN  := 'Y';
--                   IO_ERRMSG := '응급실 검사실시일시 UPDATE 중 에러 발생 ERRCODE = ' || TO_CHAR(SQLCODE);
                   RETURN;
        END;
               
             
    END PC_MSE_UPT_GA_ACPT;
    

    /**********************************************************************************************
    *    서비스이름  : PC_MSE_BLCL_AUTOB_SELECT
    *    최초 작성일 : 2018.04.11
    *    최초 작성자 : 김금덕 
    *    DESCRIPTION : 자동채혈대 채혈대상자 조회
                       GNT 공 바코드 조회 조건 추가 - 2020.6.16
    **********************************************************************************************/ 
        PROCEDURE PC_MSE_BLCL_AUTOB_SELECT ( IN_HSP_TP_CD       IN   VARCHAR2        -- 병원구분
                                           , IN_SDTE            IN   VARCHAR2        -- 채혈시작일자
                                           , IN_EDTE            IN   VARCHAR2        -- 채혈종료일자
                                           , OUT_CURSOR         OUT  RETURNCURSOR )
    IS
        --변수선언
        WK_CURSOR                 RETURNCURSOR; 
        V_PT_NO                   VARCHAR2(1000); 
        V_SDTE                    VARCHAR2(1000); 
        V_EQUP                    VARCHAR2(1000); 
    
        BEGIN       

            IF SUBSTR(IN_SDTE,1,1) = '_' THEN    
                V_PT_NO := SUBSTR(IN_SDTE,2,8);
                V_PT_NO := UPPER(V_PT_NO);
                IF V_PT_NO = '' OR V_PT_NO IS NULL THEN
                    V_PT_NO := 'XXXXXXXX';
                END IF;
                                          
                BEGIN
                    OPEN WK_CURSOR FOR
                                                                
                        SELECT /*+ INDEX(A MSELMCED_SI02) */
                               A.*
                          FROM MSELMCED A
                         WHERE 1=1
                           AND A.HSP_TP_CD       = IN_HSP_TP_CD
                           AND A.BLCL_DTM BETWEEN TO_DATE(IN_EDTE, 'YYYY-MM-DD') 
                                              AND TO_DATE(IN_EDTE, 'YYYY-MM-DD') + 0.99999
                           AND A.PT_NO           = DECODE(V_PT_NO, 'XXXXXXXX', A.PT_NO, V_PT_NO)
                           AND A.BLCL_PLC_CD     = 'AUTOB'
                           ;
                
                          OUT_CURSOR := WK_CURSOR ;
        
                    --예외처리
                  EXCEPTION
                        WHEN OTHERS THEN
                             RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_BLCL_AUTOB_SELECT-개별조회 오류' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
                END ; 
                
                RETURN;
            END IF;
                    

            BEGIN
                SELECT LISTAGG(A.SCLS_COMN_CD, ',') WITHIN GROUP( ORDER BY A.SCLS_COMN_CD)
                  INTO V_EQUP
                  FROM MSELMSID A
                 WHERE 1=1
                   AND A.HSP_TP_CD    = IN_HSP_TP_CD
                   AND A.LCLS_COMN_CD = '800'
                   AND A.TH3_RMK_CNTE = 'Y' 
--                   AND USE_YN = 'Y'
                   ;
                    --예외처리
                  EXCEPTION
                        WHEN OTHERS THEN
                             RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_BLCL_AUTOB_SELECT-진단검사 채혈처 정보가 없습니다.' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END; 
            
            
            -- 수동채혈시 특정장비만 조회할 경우에 사용
            V_SDTE := IN_SDTE;
            V_EQUP := V_EQUP;            
            IF SUBSTR(V_SDTE,1,1) = '@' THEN                                                      
                IF INSTR(V_SDTE, '_') > 0 THEN
                    V_EQUP := SUBSTR(IN_SDTE, 2, INSTR(IN_SDTE, '_') - 2);
                    V_SDTE := SUBSTR(IN_SDTE, INSTR(IN_SDTE, '_') + 1);
                END IF;
            END IF;        

            
--            RAISE_APPLICATION_ERROR(-20001, IN_SDTE || '\' || V_EQUP || '\' || V_SDTE ) ;       


            BEGIN
                --BODY
                OPEN WK_CURSOR FOR       
                
                
                        SELECT DATA.*
                             , (SELECT EQUP_ID FROM MSELMCNN WHERE HSP_TP_CD = DATA.HSP_TP_CD AND PT_NO = DATA.PT_NO AND ACPT_DT = TRUNC(SYSDATE) AND WK_UNIT_CD = TO_CHAR(DATA.OTPT_BLCL_WAIT_NO)) EQUP_ID
                             , DECODE(DATA.HSP_TP_CD, '01', XSUP.FT_MSD_DEPT(DATA.HSP_TP_CD, DATA.PACT_TP_NM1)
                                                    , '02', DATA.PACT_TP_NM1
                                                    ,       XSUP.FT_MSD_DEPT(DATA.HSP_TP_CD, DATA.PACT_TP_NM1)      
                                      )                                                                                                                                                             PACT_TP_NM3
                             , DECODE(DATA.HSP_TP_CD,  '01', '학동'
                                                     , '02', '화순'
                                                     , '03', '빛고을'
                                                     , '04', '치과'                         
                                     )                                                                                                                                 HOSP_NM
                             , (SELECT ABOB_TP_CD || RHB_TP_CD FROM PCTPCPAM_DAMO WHERE PT_NO = DATA.PT_NO)                                                            ABOB_TP_CD
                             , (SELECT SUBSTR(PT_DTL_INF_CNTE,1,240)
                                  FROM MSELMPSD D
                                 WHERE 1=1  
                                   AND HSP_TP_CD     = DATA.HSP_TP_CD 
                                   AND PT_PCPN_TP_CD = '4'
                                   AND PT_NO         = DATA.PT_NO                                  
                                   AND INPT_SEQ      = (SELECT MAX(INPT_SEQ)
                                                          FROM MSELMPSD
                                                         WHERE 1=1 
                                                           AND HSP_TP_CD     = D.HSP_TP_CD
                                                           AND PT_PCPN_TP_CD = D.PT_PCPN_TP_CD
                                                           AND PT_NO         = D.PT_NO                                 
                                                       )
                               )                                                                                                                                      ACPT_CMT
                             , XBIL.FT_PCT_AGE('AGEMONTH', SYSDATE, BIRTHDAY)                                                                                         AGEMONTH  

            
                          FROM (
                          
                            
                                    SELECT /* PKG_MSE_LM_INTERFACE-PC_MSE_BLCL_AUTOB_SELECT */
                                           DISTINCT
                                           IN_HSP_TP_CD HSP_TP_CD
                                         , Z.EXM_CTG_ABBR_NM
                                         , Z.PT_NO
                                         , Z.PT_NM
            --                             , DECODE(FT_MSE_LM_KIOSK_TRANSYN(IN_HSP_TP_CD, Z.PT_NO, MAX(Z.OTPT_BLCL_WAIT_NO)), 'Y', '*' || Z.PT_NM || '*', Z.PT_NM) PT_NM          -- 2018.09.14 키오스크에서 자동채혈대로 바로 전송시 *홍길동* '*' 표기 2020.03.20 사용안함
                                         , Z.DAY_GUBN
                                         , Z.TH2_SPCM_NM
                                         , Z.TH3_SPCM_NM
                                         , Z.BIRTHDAY
                                         , Z.SPCM_NO
            --                             , Z.PACT_TP_NM1 -- 검사항목이 많은 검사실  
                                         , XSUP.FT_MSE_KIOSK_BUSEO_INFO(IN_HSP_TP_CD, Z.SPCM_NO) PACT_TP_NM1
                                         , Z.PACT_TP_NM2
                                         , DECODE(Z.PACT_TP_CD, 'O', DECODE(Z.DAY_GUBN, '당일', DECODE((SELECT TH1_RMK_CNTE
                                                                                                         FROM MSELMSID
                                                                                                        WHERE LCLS_COMN_CD = 'PST'
                                                                                                          AND USE_YN = 'Y'
                                                                                                          AND HSP_TP_CD = IN_HSP_TP_CD), 'Y', DECODE(XSUP.FT_MSE_TH1_SPCM_CD_INFO( Z.PT_NO
                                                                                                                                                                                    ,Z.EXRM_EXM_CTG_CD
                                                                                                                                                                                    ,TO_CHAR(Z.EXM_HOPE_DT, 'YYYYMMDD')
                                                                                                                                                                                    ,Z.EXM_PRGR_STS_CD
                                                                                                                                                                                    ,Z.SPCM_NO
                                                                                                                                                                                    ,Z.TH1_SPCM_CD
                                                                                                                                                                                    ,Z.PACT_TP_CD
                                                                                                                                                                                    ,Z.STM_EXM_BNDL_SEQ
                                                                                                                                                                                    ,Z.PT_HME_DEPT_CD
                                                                                                                                                                                    ,TO_CHAR(Z.EXM_HOPE_DT, 'YYYYMMDD')
                                                                                                                                                                                    ,DECODE(Z.ODAPL_POP_CD,'3','3','9','9','7','7','1')
                                                                                                                                                                                    ,Z.MED_EXM_CTG_CD
                                                                                                                                                                                    ,IN_HSP_TP_CD
                                                                                                                                                                                    , 'N'
                                                                                                                                                                                    ), 'YNY', 'PST', Z.TH1_SPCM_NM), Z.TH1_SPCM_NM), Z.TH1_SPCM_NM), Z.TH1_SPCM_NM)     TH1_SPCM_NM    --2016.02.02 곽수미 수정
                                         , Z.ODAPL_POP_NM
                                         , Z.EXRM_EXM_CTG_CD
                                         , Z.HSPCL,EXM_ACPT_NO
                                         , Z.LABELCNT1
                                         , Z.PTLABELCNT
                                         , Z.LABELCNT2
                                         , Z.LABELCNT3
                                         , Z.MEDDATE
                                         , Z.LABELCNT4
                                         , Z.SPC_CD_1
                                         , Z.SPC_CD_2
                                         , Z.SPC_CD_3
                                         , Z.INFECT_CLS
                                         , MAX(Z.EXM_RFFM_IPTN_NO)            EXM_RFFM_IPTN_NO
            --                             , Z.ORD_CD
                                         , XSUP.FT_MSE_KIOSK_SLIP_INFO(IN_HSP_TP_CD, Z.SPCM_NO) ORD_CD
                                         , Z.LABELCNT5
                                         , Z.LABELCNT6                        -- 2016-12-16 김성룡 추가
                                         , Z.LABELCNT7                        -- 2016-12-16 김성룡 추가
                                         , Z.PKRG_NM                          -- 2017.01.09 김성룡 추가
                                         , Z.TLA_ORD_SND_FLAG_CNTE
                                         , Z.BRCD_CNTE
                                         , DECODE(Z.EXRM_EXM_CTG_CD, 'L80', 'Y', Z.EMRG_YN) EMRG_YN
                                         , MAX(Z.SPCM_CTNR_NM)  SPCM_CTNR_NM
                                         , MAX(Z.SPCM_CTNR_NM1) SPCM_CTNR_NM1
                                         , MAX(Z.SPCM_CTNR_NM2) SPCM_CTNR_NM2
                                         , MAX(Z.RMK_CNTE) RMK_CNTE
                                         , TO_CHAR(MAX(ACPT_DTM), 'YYYYMMDD') TO_DATE            -- 접수일자
                                         , MAX(Z.BRCD_CTG_LIST) BRCD_CTG_LIST
                                         , MAX(Z.ORD_ID) ORD_ID
                                         , MAX(Z.BRCD_PRNT_YN) BRCD_PRNT_YN 
                                         , MAX(Z.ORD_NM_LIST) ORD_NM_LIST              
                                         , MAX(Z.SPCM_NUM) SPCM_NUM
                                         , MAX(Z.OTPT_BLCL_WAIT_NO) OTPT_BLCL_WAIT_NO            -- 외래채혈접수번호
                                         , TO_CHAR(MAX(Z.EXM_HOPE_DT), 'YYYY-MM-DD') EXM_HOPE_DT                       -- 예약일자
                                         , TO_CHAR(MAX(Z.EXM_HOPE_DT), 'YYYY-MM-DD') ORD_DT
                                         , MAX(DECODE(Z.PACT_TP_CD, 'O', '', Z.PBSO_DEPT_CD)) PBSO_DEPT_CD                        -- 의뢰처
                                         , MAX(Z.NREXM_EPST_TM_CNTE) NREXM_EPST_TM_CNTE          -- 공복
                                          , MAX(Z.EITM_CAPN_CNTE)    EITM_CAPN_CNTE                 -- 주의사항
            --                              , MAX(Z.RST_CNSG_YN)        RST_CNSG_YN                    -- 2018.11.19 양병원 2020.03.20 사용안함  
                                         , MAX(Z.PACT_TP_CD) PACT_TP_CD   
                                         , MAX(Z.FSR_IP_ADDR) IP
                                         , FT_MSE_LM_BLOOD_TEXT(    Z.PT_NO
                                                                  , MAX(Z.EXM_HOPE_DT)
                                                                  , MAX(Z.EXM_PRGR_STS_CD)
                                                                  , MAX(Z.SPCM_NO)
                                                                  , MAX(Z.TH1_SPCM_CD)
                                                                  , MAX(Z.STM_EXM_BNDL_SEQ)
                                                                  , MAX(Z.PT_HME_DEPT_CD)
                                                                  , MAX(Z.EXM_HOPE_DT)
                                                                  , MAX(Z.ODAPL_POP_CD)
                                                                  , MAX(Z.MED_EXM_CTG_CD)
                                                                  , MAX(Z.PACT_TP_CD)
                                                                  , IN_HSP_TP_CD
                                                                  , MAX(Z.PBSO_DEPT_CD)
                                                                  , NVL(Z.BRCD_CNTE, 'N')
                                                                  , NVL(Z.TLA_ORD_SND_FLAG_CNTE, 'N')) BLOODTEXT  -- 2020.06.13 GNT에 채혈확인용
                                        , MAX(DECODE(Z.BLOOD, '1', 'Y', 'N'))         BLOOD                       -- 2020.06.16 추가
                                        , MAX(DECODE(Z.RM_CHEST, '1', 'Y', 'N'))      RM_CHEST                    -- 2020.06.16 추가
                                        , MAX(DECODE(Z.RM_ECG, '1', 'Y', 'N'))        RM_ECG                      -- 2020.06.16 추가
                                        , MAX(DECODE(Z.BRFLOOR, '1', 'Y', 'N'))       BRFLOOR                     -- 2020.06.16 추가
                                        , FT_MSE_LM_INFECT_CLS(IN_HSP_TP_CD, Z.PT_NO) INFECT                      -- 2020.06.18 추가
                                        , MAX(KOSK_TP_CD)                             KOSK_TP_CD                  -- 키오스크구분코드(UI:U, 키오스트:K)
                                        , MAX(SPCM_CTNR_CD)                           SPCM_CTNR_CD                -- 검체용기
                                       FROM
                                                (
                                                             SELECT   /*+ index(a MSELMCED_SI02) leading(a c) index(c MOOOREXM_SI03)*/  
                                                                      DISTINCT
                                                                      DECODE(NVL(A.TLA_ORD_SND_FLAG_CNTE, 'N'), 'TLA', 'TLA', B.EXM_CTG_ABBR_NM)  EXM_CTG_ABBR_NM         -- 2017.10.20
                                                                    , A.PT_NO
                                                                    , XSUP.FT_MSE_NAME_P(A.PT_NO,A.HSP_TP_CD) || '-' || (SELECT SEX_TP_CD FROM PCTPCPAM_DAMO WHERE PT_NO = A.PT_NO) PT_NM
                                                                    , MAX(A.ODY_YN) DAY_GUBN
                                                
                                                                    ,XSUP.FT_MSE_NAME_S(MAX(A.TH2_SPCM_CD), C.HSP_TP_CD)          TH2_SPCM_NM
                                                                    ,XSUP.FT_MSE_NAME_S(MAX(A.TH3_SPCM_CD), C.HSP_TP_CD)          TH3_SPCM_NM
                                                                    ,(SELECT TO_CHAR(PT_BRDY_DT, 'YYYY-MM-DD')
                                                                         FROM PCTPCPAM_DAMO
                                                                        WHERE PT_NO = A.PT_NO)                  BIRTHDAY
                                                                    , A.SPCM_NO                                 SPCM_NO
                                                                    
--                                                                    , DECODE(A.PACT_TP_CD, 'I', XSUP.FT_MSE_WARD_S(C.PT_NO, XBIL.FT_ACP_ACPT_DTE(IN_HSP_TP_CD,   C.PACT_ID  , C.PACT_TP_CD ), 1, C.HSP_TP_CD), NVL(A.PBSO_DEPT_CD, '    '))   PACT_TP_NM1
--                                                                    , DECODE(A.PACT_TP_CD, 'I', XSUP.FT_MSE_WARD_S(C.PT_NO, XBIL.FT_ACP_ACPT_DTE(IN_HSP_TP_CD,   C.PACT_ID  , C.PACT_TP_CD ), 2, C.HSP_TP_CD), '    ')                        PACT_TP_NM2
                                                                    
                                                                    , DECODE(A.PACT_TP_CD, 'I', XSUP.FT_MSE_CLCTN_WARD(C.PT_NO, XBIL.FT_ACP_ACPT_DTE(IN_HSP_TP_CD,   C.PACT_ID  , C.PACT_TP_CD ), 1, C.HSP_TP_CD, C.PACT_ID), NVL(A.PBSO_DEPT_CD, '    '))   PACT_TP_NM1 
                                                                    , DECODE(A.PACT_TP_CD, 'I', XSUP.FT_MSE_CLCTN_WARD(C.PT_NO, XBIL.FT_ACP_ACPT_DTE(IN_HSP_TP_CD,   C.PACT_ID  , C.PACT_TP_CD ), 2, C.HSP_TP_CD, C.PACT_ID), '    ')                        PACT_TP_NM2
                                                                                                        
                                                
                                                                    , DECODE(A.EXRM_EXM_CTG_CD, 'P12', XSUP.FT_MSE_NAME_S(A.TH1_SPCM_CD, C.HSP_TP_CD) ,SUBSTR(XSUP.FT_MSE_NAME_S(A.TH1_SPCM_CD, C.HSP_TP_CD), 1, 12))    TH1_SPCM_NM
                                                                    , DECODE(C.ODAPL_POP_CD,  '9', '퇴원', '3', 'POST', '7', 'INOP', '    ')                                                       ODAPL_POP_NM
                                                                    , DECODE(A.TLA_ORD_SND_FLAG_CNTE, 'TLA', 'TLA',  A.EXRM_EXM_CTG_CD) EXRM_EXM_CTG_CD                                                                                                                               -- 2017.10.20
                                                                    , DECODE(MAX(C.PRN_ORD_YN), 'Y', 'PRN', '') || DECODE(NVL(C.STM_EXM_BNDL_SEQ, '0'), '0', '', '@' || C.STM_EXM_BNDL_SEQ)        HSPCL
                                                                    , A.EXM_ACPT_NO                                           EXM_ACPT_NO
                                                                    , XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_NO, '2', C.HSP_TP_CD)    LABELCNT1
                                                                    , XSUP.FT_MSE_PTLABELCHK(A.PT_NO, A.SPCM_NO, C.HSP_TP_CD)      PTLABELCNT
                                                                    , XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_NO, '3', C.HSP_TP_CD)    LABELCNT2
                                                                    , XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_NO, '4', C.HSP_TP_CD)    LABELCNT3
                                                                    --, DECODE(C.PACT_TP_CD, 'O', XSUP.FT_MSE_P_RSVT_MEDDATE(C.PT_NO,C.PT_HME_DEPT_CD,(SELECT F.MEDR_STF_NO FROM ACPPRODM F WHERE C.PACT_ID = F.PACT_ID AND C.HSP_TP_CD = F.HSP_TP_CD),'', C.HSP_TP_CD), '') MEDDATE
                                                                    , '' MEDDATE
                                                                    , XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_NO, '4', C.HSP_TP_CD)    LABELCNT4
                                                                    , XSUP.FT_MSE_SPC_TYPE_TRNS('1', A.SPCM_NO, A.EXRM_EXM_CTG_CD, MAX(A.TH1_SPCM_CD), C.HSP_TP_CD) SPC_CD_1
                                                                    , XSUP.FT_MSE_SPC_TYPE_TRNS('2', A.SPCM_NO, A.EXRM_EXM_CTG_CD, MAX(A.TH2_SPCM_CD), C.HSP_TP_CD) SPC_CD_2
                                                                    , XSUP.FT_MSE_SPC_TYPE_TRNS('3', A.SPCM_NO, A.EXRM_EXM_CTG_CD, MAX(A.TH3_SPCM_CD), C.HSP_TP_CD) SPC_CD_3
                                                                    , XCOM.FT_COM_INFECT_CLS(A.HSP_TP_CD, A.PT_NO, '3')                                             INFECT_CLS
--                                                                    , XMED.FT_MOO_INFECT_CLS(A.PT_NO,NULL, A.HSP_TP_CD,'0')                                         INFECT_CLS
                                                --                    , MAX(E.ORD_CTRL_CD)                 ORD_KIND
                                                                    , MAX(DECODE(C.EXM_RFFM_IPTN_NO, NULL, DECODE((SELECT 'Y'
                                                                                                                     FROM MSELMSID
                                                                                                                    WHERE LCLS_COMN_CD = 'RFFM'
                                                                                                                      AND HSP_TP_CD = IN_HSP_TP_CD
                                                                                                                      AND SCLS_COMN_CD IN (C.ORD_CD) ), 'Y', 'Y', ''),
                                                                                                     DECODE((SELECT 'YY'
                                                                                                               FROM MSELMSID
                                                                                                              WHERE LCLS_COMN_CD = 'RFFM_ID'
                                                                                                                AND HSP_TP_CD = IN_HSP_TP_CD
                                                                                                                AND SCLS_COMN_CD IN (D.MDFM_ID)), 'YY', 'YY', 'Y')))                                 EXM_RFFM_IPTN_NO
                                                                    ,(SELECT MAX(Z.ORD_CD) FROM MOOOREXM Z WHERE Z.SPCM_PTHL_NO = C.SPCM_PTHL_NO AND Z.ODDSC_TP_CD = 'C' AND HSP_TP_CD = IN_HSP_TP_CD)                      ORD_CD
                                                                    , NVL(XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_NO, '5', C.HSP_TP_CD),0)    LABELCNT5
                                                                    , NVL(XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_NO, '6', C.HSP_TP_CD),0)    LABELCNT6 -- 2016-12-16 김성룡 당일, 유린바코드 갯수 추가
                                                                    , NVL(XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_NO, '7', C.HSP_TP_CD),0)    LABELCNT7 -- 2016-12-16 김성룡 당일, 유린바코드 갯수 추가
                                                                    , C.PACT_TP_CD            PACT_TP_CD    --2015.12.10 곽수미 추가
                                                                    , C.EXM_HOPE_DT           ORD_DT        --2016.01.28 곽수미 추가
                                                                    , C.EXM_PRGR_STS_CD       EXM_PRGR_STS_CD  --2016.01.28 곽수미 추가
                                                                    , C.TH1_SPCM_CD           TH1_SPCM_CD     --2016.01.28 곽수미 추가
                                                                    , C.STM_EXM_BNDL_SEQ      STM_EXM_BNDL_SEQ    --2016.01.28 곽수미 추가
                                                                    , C.EXM_HOPE_DT           EXM_HOPE_DT       --2016.01.28 곽수미 추가
                                                                    , C.ODAPL_POP_CD          ODAPL_POP_CD      --2016.01.28 곽수미 추가
                                                                    , DECODE(NVL(D.TLA_ORD_SND_FLAG_CNTE, 'N'), 'TLA', 'TLA',  D.EXRM_EXM_CTG_CD)       MED_EXM_CTG_CD      --2016.01.28 곽수미 추가
                                                                    , C.PT_HME_DEPT_CD        PT_HME_DEPT_CD      --2016.01.28 곽수미 추가
                                                                    , ( SELECT DTRL3_NM FROM CCCCCSTE WHERE COMN_GRP_CD = 'SPC' AND USE_YN     = 'Y' AND  COMN_CD_NM = C.ORD_CD AND ROWNUM = 1 ) PKRG_NM  -- 2017.01.09 김성룡 추가
                                                                    , A.TLA_ORD_SND_FLAG_CNTE
                                                                    , D.BRCD_CNTE
                                                                    , DECODE(C.EMRG_YN, 'Y', 'Y' ,'N') EMRG_YN
                                                                                        , FT_MSE_SPCM_CTNR(MAX(A.TH1_SPCM_CD), C.HSP_TP_CD) SPCM_CTNR_NM
                                                                    , FT_MSE_SPCM_CTNR(MAX(A.TH2_SPCM_CD), C.HSP_TP_CD) SPCM_CTNR_NM1
                                                                    , FT_MSE_SPCM_CTNR(MAX(A.TH3_SPCM_CD), C.HSP_TP_CD) SPCM_CTNR_NM2
                                                                    , MAX((SELECT LISTAGG(AA.ORD_RMK_CNTE, ', ') WITHIN GROUP( ORDER BY AA.ORD_SEQ)
                                                                                                  FROM MOOOREXM AA
                                                                                                 WHERE AA.SPCM_PTHL_NO = A.SPCM_NO
                                                                                                   AND AA.HSP_TP_CD = A.HSP_TP_CD
                                                                                                  )) RMK_CNTE
                                                                    , MAX(A.ACPT_DTM) ACPT_DTM
                                                                                        , MAX((
                                                                                                        SELECT LISTAGG(BRCD_CTG_CNTE, ',') WITHIN GROUP (ORDER BY BRCD_CTG_CNTE)
                                                                                                          FROM (
                                                                                                                 SELECT DISTINCT BB.BRCD_CTG_CNTE
                                                                                                                  FROM MOOOREXM AA
                                                                                                                     , MSELMEBM BB
                                                                                                                 WHERE BB.EXM_CD         =    AA.ORD_CD
                                                                                                                   AND AA.ORD_CTG_CD        IN      ('CP', 'NM','PA')
                                                                                                                   AND AA.SPCM_PTHL_NO        =  A.SPCM_NO
                                                                                                                   AND AA.HSP_TP_CD      =    A.HSP_TP_CD
                                                                                                                   AND AA.HSP_TP_CD      =    BB.HSP_TP_CD
                                                                                                                )
                                                                                                )) BRCD_CTG_LIST
                                                                    , MAX(A.ORD_ID) ORD_ID
                                                                    , MAX(A.BRCD_PRNT_YN) BRCD_PRNT_YN
                                                                    , MAX(FT_MSE_LM_ABBR_LIST(A.SPCM_NO, C.HSP_TP_CD)) ORD_NM_LIST      
                                                                    , MAX(A.SPCM_NUM)    SPCM_NUM
                                                                    , MAX(A.OTPT_BLCL_WAIT_NO) OTPT_BLCL_WAIT_NO
                                                                    
--                                                                    , MAX(A.PBSO_DEPT_CD) PBSO_DEPT_CD  
                                                                    , DECODE(A.PACT_TP_CD, 'I', XSUP.FT_MSE_CLCTN_WARD(C.PT_NO, XBIL.FT_ACP_ACPT_DTE(IN_HSP_TP_CD,   C.PACT_ID  , C.PACT_TP_CD ), 1, C.HSP_TP_CD, C.PACT_ID), MAX(A.PBSO_DEPT_CD)) PBSO_DEPT_CD
                                                                    
            --                                                        , MAX(D.NREXM_EPST_TM_CNTE) NREXM_EPST_TM_CNTE
                                                                    , ''                       NREXM_EPST_TM_CNTE
            --                                                        , MAX(D.EITM_CAPN_CNTE)    EITM_CAPN_CNTE
                                                                    , ''                       EITM_CAPN_CNTE
                        --                                            , MAX(A.RST_CNSG_YN) RST_CNSG_YN                            -- 2018.11.19 양병원 사용안함 
                                                                    , A.FSR_IP_ADDR
                                                                    , MAX(SUBSTR(E.EXCT_EXRM_CD, 1, 1)) BLOOD                    -- 2020.06.16 추가
                                                                    , MAX(SUBSTR(E.EXCT_EXRM_CD, 2, 1)) RM_CHEST            -- 2020.06.16 추가
                                                                    , MAX(SUBSTR(E.EXCT_EXRM_CD, 3, 1)) RM_ECG        -- 2020.06.16 추가
                                                                    , MAX(SUBSTR(E.EXCT_EXRM_CD, 4, 1)) BRFLOOR       -- 2020.06.16 추가
                                                                    , MAX(E.KOSK_TP_CD)                 KOSK_TP_CD
                                                                    , MAX(S.SPCM_CTNR_CD)               SPCM_CTNR_CD
                                                             FROM   MSELMCED A
                                                                  , MSELMCTC B
                                                                  , MOOOREXM C
                                                                  , MSELMEBM D
                                                                  , MSELMCNN E
                                                                  , MSELMPMD S
                                                             WHERE A.EXRM_EXM_CTG_CD         =  B.EXM_CTG_CD
                                                               AND A.SPCM_NO                 =  C.SPCM_PTHL_NO
                        --                                       AND B.ORD_CTG_CD              = 'CP'
                        --                                       AND ((C.ORD_CTG_CD IN ('CP', 'NM')) OR (C.ORD_CTG_CD ='PA' AND C.ORD_SLIP_CTG_CD IN ('P12','P13') AND ((C.ORD_CD = 'L6507' and C.TH1_SPCM_CD = 'SPUM') or ( C.ORD_CD = 'L65071' and C.TH1_SPCM_CD = 'VOUR' ) or ( C.ORD_CD = 'L6522' and  C.TH1_SPCM_CD = 'SPUM') or ( C.ORD_CD = 'L65211' and  A.TH1_SPCM_CD = 'VOUR'))))  --2018.11.08
                                                               AND C.ORD_CTG_CD IN ('CP', 'NM', 'PA')
                                                               AND A.BLCL_DTM BETWEEN TO_DATE(V_SDTE, 'YYYY-MM-DD') 
                                                                                  AND TO_DATE(IN_EDTE, 'YYYY-MM-DD') + 0.99999
                                                               AND A.BRCD_PRNT_YN            = 'N'                                                                              -- 바코드 출력여부
                                                               AND A.BLCL_PLC_CD             = 'AUTOB'                                                                          -- 자동채혈대확인
            --                                                   AND A.EXM_PRGR_STS_CD         = 'B'                                                                            -- 채혈상태값 --> GNT에서 AUTOB 조회할때 SPCM_NO값과 조회된 ROW카운트를 비교하여 동일한 경우에 가져감, 채혈 후 먼저 결과입력하는 경우때문에 무조건 조회되도록 함.
                                                               AND C.ORD_CD  = D.EXM_CD
                                                               AND C.ODDSC_TP_CD             = 'C' 
                                                               AND C.EXM_RTN_REQ_DTM         IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                                                               AND NVL(C.PRN_ORD_YN, 'N')    = 'N'
                                                               AND A.HSP_TP_CD = IN_HSP_TP_CD
                                                               AND B.HSP_TP_CD = A.HSP_TP_CD
                                                               AND C.HSP_TP_CD = A.HSP_TP_CD
                                                               AND D.HSP_TP_CD = A.HSP_TP_CD
                                                               AND A.PT_NO = E.PT_NO                    -- 2020.06.16 추가
                                                               AND TRUNC(A.BLCL_DTM) = E.ACPT_DT        -- 2020.06.16 추가
                                                               AND E.EXRM_EXM_CTG_CD ='GNTWAITNO'       -- 2020.06.16 추가
                        --                                       AND A.OTPT_BLCL_WAIT_NO = E.WK_UNIT_CD   -- 2020.06.16 추가
                                                               AND A.HSP_TP_CD = E.HSP_TP_CD            -- 2020.06.16 추가
                                                               AND A.SPCM_NUM > 0
                                                               AND C.ORD_CD      = S.EXM_CD
                                                               AND C.TH1_SPCM_CD = S.SPCM_CD
                                                               AND S.SPCM_CTNR_CD IS NOT NULL -- 검체용기가 없는 검사는 제외함.
                                                               AND S.HSP_TP_CD   = A.HSP_TP_CD
                                                             GROUP BY A.TLA_ORD_SND_FLAG_CNTE
                                                                    , D.BRCD_CNTE
                                                                    , B.EXM_CTG_ABBR_NM
                                                                    , A.EXRM_EXM_CTG_CD, A.PT_NO, XSUP.FT_MSE_NAME_P(A.PT_NO,A.HSP_TP_CD), D.TDY_EXM_PSB_YN, A.SPCM_NO
                                                                    
--                                                                    , DECODE(A.PACT_TP_CD, 'I', XSUP.FT_MSE_WARD_S(C.PT_NO, XBIL.FT_ACP_ACPT_DTE(IN_HSP_TP_CD,   C.PACT_ID  , C.PACT_TP_CD ), 1, C.HSP_TP_CD), NVL(A.PBSO_DEPT_CD, '    '))
--                                                                    , DECODE(A.PACT_TP_CD, 'I', XSUP.FT_MSE_WARD_S(C.PT_NO, XBIL.FT_ACP_ACPT_DTE(IN_HSP_TP_CD,   C.PACT_ID  , C.PACT_TP_CD ), 2, C.HSP_TP_CD), '    ')

                                                                    , DECODE(A.PACT_TP_CD, 'I', XSUP.FT_MSE_CLCTN_WARD(C.PT_NO, XBIL.FT_ACP_ACPT_DTE(IN_HSP_TP_CD,   C.PACT_ID  , C.PACT_TP_CD ), 1, C.HSP_TP_CD, C.PACT_ID), NVL(A.PBSO_DEPT_CD, '    '))
                                                                    , DECODE(A.PACT_TP_CD, 'I', XSUP.FT_MSE_CLCTN_WARD(C.PT_NO, XBIL.FT_ACP_ACPT_DTE(IN_HSP_TP_CD,   C.PACT_ID  , C.PACT_TP_CD ), 2, C.HSP_TP_CD, C.PACT_ID), '    ')

                                                                    , A.TH1_SPCM_CD, A.PACT_TP_CD, C.PBSO_DEPT_CD, A.WD_DEPT_CD
                                                                    
                                                                    , DECODE(C.ODAPL_POP_CD,  '9', '퇴원', '3', 'POST', '7', 'INOP', '    ') , A.HSP_TP_CD, NVL(EXM_ACPT_NO, 0), C.STM_EXM_BNDL_SEQ
                                                                    , C.PACT_TP_CD
                                                                    , D.EXRM_EXM_CTG_CD
                                                                    , DECODE(NVL(D.TLA_ORD_SND_FLAG_CNTE, 'N'), 'TLA', 'TLA',  D.EXRM_EXM_CTG_CD)
                                                                    , C.EXM_PRGR_STS_CD, C.PT_NO, C.PT_HME_DEPT_CD, C.ANDR_STF_NO, C.SPCM_PTHL_NO, XBIL.FT_ACP_ACPT_DTE('08',   C.PACT_ID  , C.PACT_TP_CD )
                                                                    , C.PACT_TP_CD, C.HSP_TP_CD, A.EXM_ACPT_NO
                                                                    , XSUP.FT_MSE_ALERT_CHK(C.PT_NO, D.EXRM_EXM_CTG_CD, TO_CHAR(C.EXM_HOPE_DT,'YYYYMMDD'), C.EXM_PRGR_STS_CD, C.SPCM_PTHL_NO, C.TH1_SPCM_CD
                                                                                     ,C.PACT_TP_CD, NVL(C.STM_EXM_BNDL_SEQ , ''),  C.PT_HME_DEPT_CD
                                                                                     ,TO_CHAR(C.EXM_HOPE_DT, 'YYYY-MM-DD'),DECODE(C.ODAPL_POP_CD,'3','3','9','9','7','7','1')
                                                                                     ,DECODE(D.EXRM_EXM_CTG_CD,'L79',D.MED_EXM_CTG_CD,D.EXRM_EXM_CTG_CD), '2',C.HSP_TP_CD), C.ORD_CD

                                                                    , DECODE(A.TLA_ORD_SND_FLAG_CNTE, 'TLA', 'TLA', 'N')                                                                                     
--                                                                    , DECODE(A.TLA_ORD_SND_FLAG_CNTE, 'TLA', 'TLA', XSUP.FT_MSE_LM_DAYLABELCHK(    C.PT_NO
--                                                                                            , C.EXM_HOPE_DT
--                                                                                            , C.EXM_PRGR_STS_CD
--                                                                                            , C.SPCM_PTHL_NO
--                                                                                            , C.TH1_SPCM_CD
--                                                                                            , C.STM_EXM_BNDL_SEQ
--                                                                                            , C.PT_HME_DEPT_CD
--                                                                                            , C.EXM_HOPE_DT
--                                                                                            , DECODE(C.ODAPL_POP_CD,'3','3','9','9','7','7','1')
--                                                                                            , DECODE(D.EXRM_EXM_CTG_CD,'L79',D.MED_EXM_CTG_CD,D.EXRM_EXM_CTG_CD)
--                                                                                            , C.HSP_TP_CD
--                                                                                            , XBIL.FT_ACP_ACPT_DTE(IN_HSP_TP_CD,   C.PACT_ID  , C.PACT_TP_CD )
--                                                                                            , C.ANDR_STF_NO ))
                                                                                            
                                                                    , C.PACT_ID
                                                                    , C.EXM_HOPE_DT     --2016.01.28 곽수미 추가
                                                                    , C.TH1_SPCM_CD
                                                                    , S.SPCM_CTNR_CD 
                                                                    , C.EXM_HOPE_DT
                                                                    , C.ODAPL_POP_CD
                                                                    , D.EXRM_EXM_CTG_CD
                                                                    , C.EMRG_YN
                        --                                            , D.RST_CNSG_YN                        -- 2018.11.19 양병원 사용안함
                                                                    , A.FSR_IP_ADDR
                                                ) Z
                                                GROUP BY Z.TLA_ORD_SND_FLAG_CNTE
                                                         , Z.BRCD_CNTE
                                                         , Z.EXM_CTG_ABBR_NM
                                                         , Z.PT_NO,PT_NM
                                                         , Z.DAY_GUBN
                                                         , Z.TH2_SPCM_NM
                                                         , Z.TH3_SPCM_NM
                                                         , Z.BIRTHDAY
                                                         , Z.SPCM_NO
                                                         , Z.PACT_TP_NM1
                                                         , Z.PACT_TP_NM2
                                                         , Z.TH1_SPCM_NM
                                                         , Z.ODAPL_POP_NM
                                                         , Z.EXRM_EXM_CTG_CD
                                                         , Z.HSPCL,EXM_ACPT_NO
                                                         , Z.LABELCNT1
                                                         , Z.PTLABELCNT
                                                         , Z.LABELCNT2
                                                         , Z.LABELCNT3
                                                         , Z.MEDDATE
                                                         , Z.LABELCNT4
                                                         , Z.SPC_CD_1
                                                         , Z.SPC_CD_2
                                                         , Z.SPC_CD_3
                                                         , Z.INFECT_CLS
                                                         , Z.ORD_CD
                                                         , Z.LABELCNT5
                                                         , Z.LABELCNT6      --2016-12-16 김성룡 추가
                                                         , Z.LABELCNT7      --2016-12-16 김성룡 추가
                                                         , Z.PACT_TP_CD     --2015.12.10 곽수미 추가
                                                         , Z.ORD_DT         --2016.01.28 곽수미 추가
                                                         , Z.EXM_PRGR_STS_CD
                                                         , Z.TH1_SPCM_CD
                                                         , Z.STM_EXM_BNDL_SEQ
                                                         , Z.EXM_HOPE_DT
                                                         , Z.ODAPL_POP_CD
                                                         , Z.MED_EXM_CTG_CD
                                                         , Z.PT_HME_DEPT_CD
                                                         , Z.PKRG_NM                               -- 2017.01.09 김성룡 추가
                                                         , Z.EMRG_YN
                                                         , Z.SPCM_CTNR_NM  
            
                                            UNION
                                            
                                            SELECT /*+leading (A,C,B) USE_NL(B,C)*/
                                                     A.HSP_TP_CD HSP_TP_CD
                                                  , '공바코드' EXM_CTG_ABBR_NM
                                                  , A.PT_NO
                                                  , B.PT_NM || '-' || B.SEX_TP_CD PT_NM
                                                  , '' DAY_GUBN
                                                  , '' TH2_SPCM_NM
                                                  , '' TH3_SPCM_NM
                                                  , TO_CHAR(B.PT_BRDY_DT, 'YYYY-MM-DD') BIRTHDAY
                                                  , A.SPCM_NO
                                                  , '' PACT_TP_NM1
                                                  , '' PACT_TP_NM2
                                                  , '' TH1_SPCM_NM
                                                  , '' ODAPL_POP_NM
                                                  , A.EXRM_EXM_CTG_CD
                                                  , '' HSPCL
                                                  , '' EXM_ACPT_NO
                                                  , TO_CHAR(A.SPCM_NUM) LABELCNT1 -- 공바코드 라벨건수
                                                  , '' PTLABELCNT
                                                  , '' LABELCNT2
                                                  , '' LABELCNT3
                                                  , '' MEDDATE
                                                  , '' LABELCNT4
                                                  , '' SPC_CD_1
                                                  , '' SPC_CD_2
                                                  , '' SPC_CD_3
                                                  , '' INFECT_CLS
                                                  , '' EXM_RFFM_IPTN_NO
                                                  , '' ORD_CD
                                                  , '' LABELCNT5
                                                  , '' LABELCNT6
                                                  , '' LABELCNT7
                                                  , '' PKRG_NM
                                                  , '' TLA_ORD_SND_FLAG_CNTE
                                                  , '' BRCD_CNTE
                                                  , '' EMRG_YN
                                                  , '' SPCM_CTNR_NM
                                                  , '' SPCM_CTNR_NM1
                                                  , '' SPCM_CTNR_NM2
                                                  , '' RMK_CNTE
                                                  , '' TO_DATE
                                                  , '' BRCD_CTG_LIST
                                                  , '' ORD_ID
                                                  , A.BRCD_PRNT_YN
                                                  , '' ORD_NM_LIST
                                                  , 1 SPCM_NUM                     -- 공바코드 검체수 1건
                                                  , A.OTPT_BLCL_WAIT_NO
                                                  , '' EXM_HOPE_DT
                                                  , '' ORD_DT
                                                  , '' PBSO_DEPT_CD
                                                  , '' NREXM_EPST_TM_CNTE
                                                  , '' EITM_CAPN_CNTE
                                                  , '' PACT_TP_CD
                                                  , A.FSR_IP_ADDR IP
                                                  , '' BLOODTEXT
                                                  , DECODE(SUBSTR(C.EXCT_EXRM_CD, 1, 1), '1', 'Y','N') BLOOD
                                                  , DECODE(SUBSTR(C.EXCT_EXRM_CD, 2, 1), '1', 'Y','N') RM_CHEST
                                                  , DECODE(SUBSTR(C.EXCT_EXRM_CD, 3, 1), '1', 'Y','N') RM_ECG
                                                  , DECODE(SUBSTR(C.EXCT_EXRM_CD, 4, 1), '1', 'Y','N') BRFLOOR
                                                  , ''                                                 INFECT
                                                  , ''                                                 KOSK_TP_CD
                                                  , ''                                                 SPCM_CTNR_CD
                                             FROM MSELMCED A
                                                , PCTPCPAM_DAMO B
                                                , MSELMCNN C
                                            WHERE A.HSP_TP_CD         = IN_HSP_TP_CD
                                              AND A.BLCL_PLC_CD        = 'AUTOB'
                                              AND A.EXM_PRGR_STS_CD    = 'B'
                                              AND A.BRCD_PRNT_YN    = 'N'
                                              AND A.EXRM_EXM_CTG_CD = 'XXX'
                                              AND A.PT_NO = B.PT_NO
                                              AND A.PT_NO = C.PT_NO
                                              AND TRUNC(A.BLCL_DTM) = C.ACPT_DT
                                              AND C.EXRM_EXM_CTG_CD ='GNTWAITNO'
                                              AND A.OTPT_BLCL_WAIT_NO = C.WK_UNIT_CD
                                              AND A.HSP_TP_CD = C.HSP_TP_CD
                                              AND A.BLCL_DTM BETWEEN TO_DATE(V_SDTE, 'YYYY-MM-DD') AND TO_DATE(IN_EDTE, 'YYYY-MM-DD') + 0.99999
                                            ORDER BY PBSO_DEPT_CD, PACT_TP_NM2, PT_NO
                                                               
                               ) DATA
                           WHERE 1=1
                             AND (SELECT EQUP_ID FROM MSELMCNN WHERE HSP_TP_CD = DATA.HSP_TP_CD AND PT_NO = DATA.PT_NO AND ACPT_DT = TRUNC(SYSDATE) AND WK_UNIT_CD = TO_CHAR(DATA.OTPT_BLCL_WAIT_NO)) 
                                 IN 
                                 (SELECT REGEXP_SUBSTR ( V_EQUP, '[^,]+', 1, LEVEL )
                                    FROM DUAL
                                 CONNECT BY LEVEL <= REGEXP_COUNT ( V_EQUP, ',' ) + 1
                                 )  
                           ORDER BY DATA.OTPT_BLCL_WAIT_NO, DATA.SPCM_NO
                               ;
                                
                      OUT_CURSOR := WK_CURSOR ;
    
                --예외처리
              EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_BLCL_AUTOB_SELECT' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END ; 
       
    END PC_MSE_BLCL_AUTOB_SELECT;   
    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_BLCL_AUTOB_UPDATE 
    *    최초 작성일 : 2018.04.11
    *    최초 작성자 : 김금덕 
    *    Description : 자동채혈대 바코드출력 상태 'Y' 변경
    **********************************************************************************************/
    PROCEDURE PC_MSE_BLCL_AUTOB_UPDATE    ( IN_SPCM_NO             IN   VARCHAR2        -- 환자번호
                                           , IN_HSP_TP_CD           IN   VARCHAR2       -- 병원구분
                                           , IO_ERRYN              IN OUT  VARCHAR2       -- 오류여부
                                           , IO_ERRMSG             IN OUT  VARCHAR2       -- 오류메세지
                                 )                               
    IS           
                      
    S_PRGM_NM                  MSELMCED.LSH_PRGM_NM%TYPE       := 'PC_MSE_BLCL_AUTOB_UPDATE';
    S_IP_ADDR                  MSELMCED.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');
              
    BEGIN
    
        BEGIN 
                     
            UPDATE MSELMCED 
               SET BRCD_PRNT_YN        = 'Y'
                 , LSH_DTM             = SYSDATE
                 , LSH_PRGM_NM         = S_PRGM_NM
                 , LSH_IP_ADDR         = S_IP_ADDR
             WHERE SPCM_NO             = IN_SPCM_NO
               AND HSP_TP_CD           = IN_HSP_TP_CD   
               AND BLCL_PLC_CD         = 'AUTOB' 
               AND BRCD_PRNT_YN        = 'N'
            ;
                  
            IF SQL%ROWCOUNT = 0 THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := '자동채혈대 바코드출력 상태값 변경할 데이터가 없습니다.';
                RETURN;
              END IF;  
              
              EXCEPTION
              WHEN OTHERS THEN
                   IO_ERRYN  := 'Y';
                   IO_ERRMSG := '자동채혈대 UPDATE 중 에러 발생 ERRCODE = ' || TO_CHAR(SQLCODE);
                   RETURN;
               
        END;
               

        BEGIN 
            IO_ERRYN  := '';
            IO_ERRMSG := '';
        
            INSERT 
                 INTO MSELMTPD (      HSP_TP_CD
                                    , WK_DTM
                                    , WK_TP_NM
                                    , SPCM_NO
                                    , TH1_TMPR_CNTE
                                    , CRE_SEQ
                                    
                                    , FSR_DTM
                                    , FSR_STF_NO
                                    , FSR_PRGM_NM
                                    , FSR_IP_ADDR
                                    , LSH_DTM
                                    , LSH_STF_NO
                                    , LSH_PRGM_NM
                                    , LSH_IP_ADDR
                               )
                             
                 VALUES
                               (
                                      IN_HSP_TP_CD
                                    , SYSDATE
                                    , 'BLCL_AUTOB_LOG'
                                    , IN_SPCM_NO
                                    , '자동채혈대 바코드출력 업데이트 성공'
                                    , XSUP.SEQ_LOG_HST_SEQ.NEXTVAL
                                    
                                    , SYSDATE
                                    , 'CCC0EMR'
                                    , S_PRGM_NM
                                    , S_IP_ADDR
                                    , SYSDATE
                                    , 'CCC0EMR'
                                    , S_PRGM_NM
                                    , S_IP_ADDR
                               )
                               ;   
                                 
            IF SQL%ROWCOUNT = 0 THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := '자동채혈대 바코드출력 상태값 이력 저장이 실패 되었습니다.';
                RETURN;
              END IF;  
              
              EXCEPTION
              WHEN OTHERS THEN
                   IO_ERRYN  := '';
                   IO_ERRMSG := '자동채혈대 상태값 이력 저장 중 에러 발생 ERRCODE = ' || SQLERRM;
                   RETURN;

        END;
             
                
    END PC_MSE_BLCL_AUTOB_UPDATE;

    /**********************************************************************************************
    *    서비스이름  : PC_MSE_BLCL_KIOSK_SELECT
    *    최초 작성일 : 2018.05.21
    *    최초 작성자 : 김금덕 
    *    DESCRIPTION : 키오스크 환자번호로 조회
    **********************************************************************************************/ 
    PROCEDURE PC_MSE_BLCL_KIOSK_SELECT ( IN_PT_NO           IN   VARCHAR2       -- 환자번호
                                         , IN_HSP_TP_CD        IN   VARCHAR2        -- 병원구분
                                       , OUT_CURSOR         OUT  RETURNCURSOR )
    IS
        --변수선언
         WK_CURSOR                 RETURNCURSOR ; 
    
        BEGIN       
            BEGIN
                --BODY
                OPEN WK_CURSOR FOR       
                
                    SELECT A.PT_NO
                         , B.PT_NM
                         , A.PBSO_DEPT_CD
                         , C.DEPT_NM
                         , TO_CHAR(A.ORD_DT, 'YYYY-MM-DD') ORD_DT                        -- 처방일자
                         , TO_CHAR(A.EXM_HOPE_DT, 'YYYY-MM-DD') EXM_HOPE_DT               -- 검사희망일자
                         , MIN(A.RPY_STS_CD) RPY_STS_CD                                 -- 수납상태코드
--                         , LISTAGG(A.ORD_ID, '||') WITHIN GROUP(ORDER BY A.ORD_SEQ) ORD_ID_LIST
--                         , LISTAGG(A.ORD_CD, '||') WITHIN GROUP(ORDER BY A.ORD_SEQ) ORD_CD_LIST
                         , A.PACT_TP_CD
                         , MAX((SELECT KOR_SRNM_NM
                                  FROM CNLRRUSD
                                 WHERE HSP_TP_CD = A.HSP_TP_CD
                                   AND STF_NO      = A.ANDR_STF_NO)) ANDR_STF_NM            -- 주치의 의사명
                      FROM MOOOREXM A                                    --처방
                         , PCTPCPAM_DAMO B            --환자기본
                         , PDEDBMSM C                        --부서기본
                     WHERE A.HSP_TP_CD = IN_HSP_TP_CD
                       AND A.EXM_HOPE_DT BETWEEN TRUNC(SYSDATE) AND SYSDATE   -- 희망일자   +-7
                       AND A.ORD_CTG_CD ='CP'
                       AND A.PT_NO = IN_PT_NO
                       AND A.PT_NO = B.PT_NO
                       AND A.HSP_TP_CD = C.HSP_TP_CD
                       AND A.PBSO_DEPT_CD = C.DEPT_CD
                       AND A.EXM_PRGR_STS_CD = 'X'              -- 초기
                       AND A.PACT_TP_CD      = 'O'              -- 외래
                       AND A.ODDSC_TP_CD     = 'C'              -- 처방상태
                     GROUP BY  A.PT_NO
                             , B.PT_NM
                             , A.PBSO_DEPT_CD
                             , C.DEPT_NM
                             , A.ORD_DT
                             , A.EXM_HOPE_DT
                             , A.RPY_STS_CD
                             , A.PACT_TP_CD
--                    UNION
--                  --- 오더일자 기준으로 데이터만 검증
--                  SELECT A.PT_NO
--                       , B.PT_NM
--                       , A.PBSO_DEPT_CD
--                       , C.DEPT_NM
--                       , TO_CHAR(A.ORD_DT, 'YYYY-MM-DD') ORD_DT                  -- 처방일자
--                       , TO_CHAR(A.EXM_HOPE_DT, 'YYYY-MM-DD') EXM_HOPE_DT             -- 검사희망일자
--                       , MIN(A.RPY_STS_CD) RPY_STS_CD                       -- 수납상태코드
--                       , A.PACT_TP_CD
--                       , MAX((SELECT KOR_SRNM_NM
--                                FROM CNLRRUSD
--                               WHERE HSP_TP_CD = A.HSP_TP_CD
--                                 AND STF_NO    = A.ANDR_STF_NO)) ANDR_STF_NM      -- 주치의 의사명
--                    FROM MOOOREXM A            -- 처방
--                       , PCTPCPAM_DAMO B                -- 환자기본
--                       , PDEDBMSM C                  -- 부서기본
--                   WHERE A.HSP_TP_CD = IN_HSP_TP_CD
--                     AND A.ORD_CTG_CD ='CP'               -- 진단검사
--                     AND A.PT_NO = IN_PT_NO
--                     AND A.PT_NO = B.PT_NO
--                     AND A.HSP_TP_CD = C.HSP_TP_CD
--                     AND A.PBSO_DEPT_CD = C.DEPT_CD
--                     AND A.EXM_PRGR_STS_CD ='X'           -- 초기
--                     AND A.PACT_TP_CD ='O'         -- 외래
--                     AND A.ODDSC_TP_CD = 'C'
--                     AND A.ORD_DT =
--                     (
--                       SELECT ORD_DT
--                        FROM
--                        (
--                        SELECT
--                               DISTINCT TO_CHAR(A.ORD_DT, 'YYYY-MM-DD') ORD_DT                  -- 처방일자
--                              , TO_CHAR(A.EXM_HOPE_DT, 'YYYY-MM-DD') EXM_HOPE_DT
--                          FROM MOOOREXM A            -- 처방
--                             , PCTPCPAM_DAMO B                -- 환자기본
--                             , PDEDBMSM C                  -- 부서기본
--                          WHERE A.HSP_TP_CD = IN_HSP_TP_CD
--                           AND A.EXM_HOPE_DT BETWEEN TRUNC(SYSDATE) AND SYSDATE   -- 희망일자  +-7
--                           AND A.ORD_CTG_CD ='CP'               -- 진단검사
--                           AND A.PT_NO = IN_PT_NO
--                           AND A.PT_NO = B.PT_NO
--                           AND A.HSP_TP_CD = C.HSP_TP_CD
--                           AND A.PBSO_DEPT_CD = C.DEPT_CD
--                           AND A.EXM_PRGR_STS_CD ='X'           -- 초기
--                           AND A.PACT_TP_CD ='O'         -- 외래
--                           AND A.ODDSC_TP_CD = 'C'
--                         GROUP BY  A.PT_NO
--                               , B.PT_NM
--                               , A.PBSO_DEPT_CD
--                               , C.DEPT_NM
--                               , A.ORD_DT
--                               , A.EXM_HOPE_DT
--                               , A.RPY_STS_CD
--                               , A.PACT_TP_CD                        
--                        ) 
--                        WHERE ROWNUM = 1
--                        GROUP BY ORD_DT                              
--                         )
--                       GROUP BY  A.PT_NO
--                               , B.PT_NM
--                               , A.PBSO_DEPT_CD
--                               , C.DEPT_NM
--                               , A.ORD_DT
--                               , A.EXM_HOPE_DT
--                               , A.RPY_STS_CD
--                               , A.PACT_TP_CD    
                       ;                             
                        
                      OUT_CURSOR := WK_CURSOR ;
    
                --예외처리
              EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_BLCL_KIOSK_SELECT' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
            END ; 
       
    END PC_MSE_BLCL_KIOSK_SELECT;  
    
    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_BLCL_KIOSK_UPDATE 
    *    최초 작성일 : 2018.05.21
    *    최초 작성자 : 김금덕 
    *    Description : 키오스크 처방테이블에 접수번호 업데이트
    **********************************************************************************************/
    PROCEDURE PC_MSE_BLCL_KIOSK_UPDATE    ( IN_PT_NO                 IN   VARCHAR2        -- 환자번호
                                           , IN_HSP_TP_CD           IN   VARCHAR2       -- 병원구분
                                           , IN_DEXM_KOSK_ACPT_NO  IN   VARCHAR2       -- 진단검사키오스크접수번호
                                           , IO_ERRYN              IN OUT  VARCHAR2       -- 오류여부
                                           , IO_ERRMSG             IN OUT  VARCHAR2       -- 오류메세지
                                 )                               
    IS           
                      
    S_PRGM_NM                  MSELMCED.LSH_PRGM_NM%TYPE       := 'PC_MSE_BLCL_KIOSK_UPDATE';
    S_IP_ADDR                  MSELMCED.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');
              
    BEGIN
    
        BEGIN 
                     
            UPDATE MOOOREXM 
               SET 
                 --DEXM_KOSK_ACPT_NO    = IN_DEXM_KOSK_ACPT_NO        -- 2020.03.02 사용안함
                   LSH_DTM                 = SYSDATE
                 , LSH_PRGM_NM             = S_PRGM_NM
                 , LSH_IP_ADDR             = S_IP_ADDR
             WHERE PT_NO                  = IN_PT_NO
               AND HSP_TP_CD              = IN_HSP_TP_CD   
               AND EXM_PRGR_STS_CD ='X'
--                  AND RPY_STS_CD ='Y'
               AND ODDSC_TP_CD ='C'
               AND ORD_CTG_CD ='CP'
               AND EXM_HOPE_DT BETWEEN SYSDATE - 180 AND SYSDATE + 180
            ;
                  
            IF SQL%ROWCOUNT = 0 THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := '해당환자 KIOSK 접수번호 UPDATE 변경 건수가 없습니다.';
                RETURN;
            END IF;  
              
            EXCEPTION
              WHEN OTHERS THEN
                   IO_ERRYN  := 'Y';
                   IO_ERRMSG := 'KIOSK 접수번호 UPDATE 중 에러 발생 ERRCODE = ' || TO_CHAR(SQLCODE);
                   RETURN;
               
        END;

    END PC_MSE_BLCL_KIOSK_UPDATE; 
                   
    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_BLCL_STFNO_UPDATE
    *    최초 작성일 : 2018.06.29
    *    최초 작성자 : 김금덕 
    *    DESCRIPTION : 채혈자정보 업데이트
    **********************************************************************************************/
    PROCEDURE PC_MSE_BLCL_STFNO_UPDATE    ( IN_HSP_TP_CD           IN   VARCHAR2       -- 병원구분
                                           , IN_SPCM_NO            IN   VARCHAR2       -- 검체번호
                                           , IN_SPCID              IN   VARCHAR2       -- 사용자정보
                                           , IO_ERRYN              IN OUT  VARCHAR2       -- 오류여부
                                           , IO_ERRMSG             IN OUT  VARCHAR2       -- 오류메세지
                                 )                               
    IS           
                      
    S_PRGM_NM                  MSELMCED.LSH_PRGM_NM%TYPE       := 'PC_MSE_BLCL_AUTOB_UPDATE';
    S_IP_ADDR                  MSELMCED.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');
              
    BEGIN
    
        BEGIN 
                     
            UPDATE MSELMCED 
               SET BLCL_STF_NO          = IN_SPCID  
                 , BLCL_DTM             = SYSDATE                                                    --채혈일시                                           
                 , LSH_PRGM_NM          = '자동채혈대채혈자정보수정'
             WHERE SPCM_NO              = IN_SPCM_NO
               AND HSP_TP_CD            = IN_HSP_TP_CD   
               AND BLCL_PLC_CD          = 'AUTOB' 
            ;
              
            UPDATE MOOOREXM 
               SET BLCL_STF_NO          = IN_SPCID   
                 , BLCL_DTM             = SYSDATE                                                    --채혈일시                                     
                 , LSH_PRGM_NM          = '자동채혈대채혈자정보수정'
             WHERE SPCM_PTHL_NO         = IN_SPCM_NO
               AND HSP_TP_CD            = IN_HSP_TP_CD    
            ;
               
        END;

    END PC_MSE_BLCL_STFNO_UPDATE; 

    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_PAT_KIOSK_SELECT
    *    최초 작성일 : 2018.07.12
    *    최초 작성자 : 김금덕 
    *    DESCRIPTION : KIOSK 환자정보 조회(차트번호, 주민번호)
    **********************************************************************************************/
    PROCEDURE PC_MSE_PAT_KIOSK_SELECT    ( IN_HSP_TP_CD           IN   VARCHAR2       -- 병원구분
                                           , IN_GUBUN              IN   VARCHAR2       -- 구분(1.차트번호, 2.주민번호)
                                           , IN_PT_NO              IN   VARCHAR2       -- 차트번호
                                           , IN_SEC_RRN              IN   VARCHAR2       -- 주민번호
                                           , OUT_CURSOR             OUT  RETURNCURSOR
                                          ) 
    IS
    -- 변수선언
    WK_CURSOR                 RETURNCURSOR ; 
    
    BEGIN       
               
        -- 1.차트번호
        IF IN_GUBUN = '1' THEN
            BEGIN      
                OPEN WK_CURSOR FOR       
                    
                       SELECT PT_NO
                         , PT_NM
                         , TO_CHAR(PT_BRDY_DT, 'YYYY-MM-DD') PT_BRDY_DT
                         , DECODE(SEX_TP_CD, 'M', '남', 'F', '여') SEX_TP_NM
                      FROM PCTPCPAM_DAMO                                         --환자기본
                     WHERE PT_NO = IN_PT_NO
                       ;                             
                           
                     OUT_CURSOR := WK_CURSOR ;
        
                    --예외처리
                  EXCEPTION
                        WHEN OTHERS THEN
                             RAISE_APPLICATION_ERROR(-20553, '해당 차트번호가 없습니다. ' || SQLCODE || SQLERRM) ;    
            END;          
        -- 2.주민번호
        ELSIF IN_GUBUN ='2' THEN
            BEGIN
                 OPEN WK_CURSOR FOR       
                    
                       SELECT PT_NO
                         , PT_NM
                         , TO_CHAR(PT_BRDY_DT, 'YYYY-MM-DD') PT_BRDY_DT
                         , DECODE(SEX_TP_CD, 'M', '남', 'F', '여') SEX_TP_NM
                      FROM PCTPCPAM_DAMO                                         --환자기본
                     WHERE SEC_RRN = IN_SEC_RRN
                       ;                             
                           
                     OUT_CURSOR := WK_CURSOR ;
        
                    --예외처리
                  EXCEPTION
                        WHEN OTHERS THEN
                             RAISE_APPLICATION_ERROR(-20553, '해당 주민번호가 없습니다. ' || SQLCODE || SQLERRM) ;    
            END;
        END IF;
    
    
    END PC_MSE_PAT_KIOSK_SELECT; 



    /**********************************************************************************************
    *    서비스이름  : PC_MSE_INS_KIOSK_ACCEPT
    *    최초 작성일 : 2018.07.19
    *    최초 작성자 : 김금덕 
    *    DESCRIPTION : KIOSK 채혈처리 (자동채혈대로전송)
    **********************************************************************************************/
--    PROCEDURE PC_MSE_INS_KIOSK_ACCEPT    ( IN_HSP_TP_CD           IN    VARCHAR2           -- 병원구분
--                                           , IN_PT_NO                IN     VARCHAR2        -- 차트번호
--                                           , IN_EXM_HOPE_DT        IN  VARCHAR2        -- 희망일자
--                                           , IO_WAITNO              IN OUT  VARCHAR2       -- 대기번호
--                                           , IO_ERRYN              IN OUT  VARCHAR2       -- 오류여부
--                                           , IO_ERRMSG             IN OUT  VARCHAR2       -- 오류메세지
--                                           ) 
--
--    IS
--         
--    S_PRGM_NM              VARCHAR2(30)     := 'PC_MSE_INS_KIOSK_ACCEPT';
--    S_IP_ADDR              VARCHAR2(30)     := SYS_CONTEXT('USERENV','IP_ADDRESS');
--    S_TLA_SPCM_NO         VARCHAR2(20)     := '0';   
--    S_TLA_SPCM_NO1         VARCHAR2(20)     := '0';   
--    S_SPCM_NO           VARCHAR2(20)     := '';
--    S_WAITNO            VARCHAR2(4)      := '';
--    S_PT_HME_DEPT_CD    VARCHAR2(10)     := '';
--    S_EMRG_YN            VARCHAR2(1)      := '';
--    S_STM_EXM_BNDL_SEQ  VARCHAR2(5)      := '';
--    S_BRCD_CNTE            VARCHAR2(50)     := '';
--    S_EXM_HOPE_DT        VARCHAR2(10)     := '';    
--    S_SPCMCNT            NUMBER          := '0';
--    S_SPCM_NO_LIST        VARCHAR2(200)   := ' ';        -- 공백띄움
--    S_SPCM_NO_TEST        VARCHAR2(200)   := '';
--    S_RST_CNSG_YN        VARCHAR2(1)     := '';        -- 2018.11.19 양병원 위수탁    
--    S_TH1_SPCM_CD        VARCHAR2(5)     := '';      -- 2019.03
--    
--    BEGIN
--                           
--        BEGIN
--            -- 채혈대상 리스트 조회 
--            -- (조건 진료과 1개이면서 예약일자가 +-7일 예약일자존재 수납완료대상자만 키오스크에서 넘어온다.)
--            FOR REC IN ( 
--                        SELECT DISTINCT
--                               Z.PACT_TP_CD                                                                                     PACT_TP_CD
--                             , Z.EXRM_EXM_CTG_CD                                                                                EXRM_EXM_CTG_CD
--                             , Z.TH1_SPCM_CD                                                                                    TH1_SPCM_CD
--                             , TO_CHAR(Z.EXM_HOPE_DT, 'YYYY-MM-DD')                                                             EXM_HOPE_DT
--                             , DECODE(MAX(Z.RSVP_YN),'Y','Y','')                                                                RSVP_YN
--                             , DECODE(MAX(Z.EXRS_TDY_REQ_YN), 'Y', 'Y', '' )                                                    TODAYYN
--                             , TO_CHAR(TRUNC(MAX(DECODE(LENGTH(Z.NREXM_EPST_TM_CNTE),1, '0' || Z.NREXM_EPST_TM_CNTE
--                                                                                      , Z.NREXM_EPST_TM_CNTE))))                NREXM_EPST_TM_CNTE --2009.11.02 방수석 공복여부 수정
--                             , NVL(Z.PBSO_DEPT_CD, '-')                                                                         PBSO_DEPT_CD
--                             , NVL(Z.PT_HME_DEPT_CD, '-')                                                                       PT_HME_DEPT_CD
--                             , TO_CHAR(Z.ORD_DT, 'YYYY-MM-DD')                                                                  ORD_DT
--                             , XBIL.FT_ACP_GET_ASDRNM( Z.HSP_TP_CD, Z.PACT_TP_CD, Z.PACT_ID)                                    DOC_ID
--                             , ''                                                                                               REMK
--                             , XBIL.FT_ACP_GET_RPY_YN(Z.HSP_TP_CD, Z.RPY_PACT_ID,
--                               DECODE(SUBSTR(Z.IMGN_PT_CTG_CD,1,1), 'I' ,'Y'
--                                                         , 'E', 'Y'
--                                                         , (REPLACE(NVL(DECODE(Z.PACT_TP_CD,'E', DECODE(XSUP.FT_MSE_ESTAYINROOMYN_NEW(Z.PT_NO, Z.RPY_PACT_ID, Z.HSP_TP_CD),'N','Y','N')
--                                                                                           ,'I', DECODE(XSUP.FT_MSE_ISTAYINROOMYN_NEW(Z.PT_NO, Z.RPY_PACT_ID, Z.HSP_TP_CD),'N','Y','N')
--                                                                                               , DECODE(DECODE((SELECT RSV_ACPT_TP_CD
--                                                                                                                  FROM ACPPRODM
--                                                                                                                 WHERE PACT_ID = Z.PACT_ID AND HSP_TP_CD = IN_HSP_TP_CD),'99','Y'
--                                                                                                                                                ,'N'),'Y', 'Y'
--                                                                                                                                                         , (SELECT XSUP.FT_MSE_GET_MISUINFO ( Z.PT_NO
--                                                                                                                                                                                            , Z.ORD_DT
--                                                                                                                                                                                            , Z.EXM_PRGR_STS_CD
--                                                                                                                                                                                            , Z.SPCM_PTHL_NO
--                                                                                                                                                                                            , Z.TH1_SPCM_CD
--                                                                                                                                                                                            , Z.PACT_TP_CD
--                                                                                                                                                                                            , Z.STM_EXM_BNDL_SEQ
--                                                                                                                                                                                            , Z.PT_HME_DEPT_CD
--                                                                                                                                                                                            , Z.EXM_HOPE_DT
--                                                                                                                                                                                            , Z.PBSO_DEPT_CD
--                                                                                                                                                                                            , DECODE(Z.ODAPL_POP_CD,'3','3','9','9','7','7','1')
--                                                                                                                                                                                            , Z.EXRM_EXM_CTG_CD
--                                                                                                                                                                                            , 'O'
--                                                                                                                                                                                            , IN_HSP_TP_CD
--                                                                                                                                                                                            , 'N')
--                                                                                                                                                              FROM DUAL))),'X'),'N','X'))), Z.PACT_TP_CD) CALTYPE
--                             , DECODE(Z.EXM_PRGR_STS_CD, 'F', '오더', 'X', '오더', 'B', '채혈', 'C', '접수', 'D', '입력', 'N', '보고' , EXM_PRGR_STS_CD)                       EXM_PRGR_STS_CD
--                             , Z.SPCM_PTHL_NO                                                                                   SPCM_PTHL_NO
--                             , DECODE(MAX(Z.ORD_CTRL_CD), 'CP1', '유전자', MAX(Z.ORD_CTRL_CD))                                      ORD_KIND
--                             , ''                                                                                               BLCL_HH_RMK_CNTE
--                             , Z.MED_EXM_CTG_CD                                                                                 MED_EXM_CTG_CD
--                             , NVL(Z.STM_EXM_BNDL_SEQ, '0')                                                                     STM_EXM_BNDL_SEQ
--                             , DECODE(Z.ODAPL_POP_CD,'3','3','9','9','7','7','1')                                               ODAPL_POP_CD
--                             , ( SELECT EXM_CTG_NM
--                                   FROM MSELMCTC
--                                  WHERE EXM_CTG_CD = Z.EXRM_EXM_CTG_CD
--                                    AND HSP_TP_CD = IN_HSP_TP_CD)                                                               EXM_CTG_NM
--                             , ( SELECT SPCM_NM
--                                   FROM MSELMCCC
--                                  WHERE SPCM_CD = Z.TH1_SPCM_CD
--                                    AND HSP_TP_CD = IN_HSP_TP_CD)                                                               TH1_SPCM_NM
--                             , DECODE(TO_CHAR(Z.EXM_HOPE_DT,'YYYY'), TO_CHAR(SYSDATE,'YYYY'), 'N','Y')                          HOPE_DT_CHK  --이광우 선생님 요청으로 수정 [ 희망일과 오더일자 비교에서 희망년도가 해당년도와 같을 경우 체크]
--                             , ( SELECT XSUP.FT_MSE_LM_ORD_ID_LIST( Z.PT_NO
--                                                                  , Z.ORD_DT
--                                                                  , Z.EXM_PRGR_STS_CD
--                                                                  , Z.SPCM_PTHL_NO
--                                                                  , Z.TH1_SPCM_CD
--                                                                  , Z.STM_EXM_BNDL_SEQ
--                                                                  , Z.PT_HME_DEPT_CD
--                                                                  , Z.EXM_HOPE_DT
--                                                                  , DECODE(Z.ODAPL_POP_CD,'3','3','9','9','7','7','1')
--                                                                  , Z.MED_EXM_CTG_CD
--                                                                  , Z.PACT_TP_CD
--                                                                  , Z.HSP_TP_CD
--                                                                  , Z.PBSO_DEPT_CD
--                                                                  , Z.BRCD_CNTE
--                                                                  , 'N' --Z.RST_CNSG_YN                                                -- 2018.11.19 위탁수탁여부
--                                                                  , 'N'
--                                                                  , 'N'
--                                                                  )
--                                   FROM DUAL)                                                                                   ORD_ID_LIST -- 2012-09-07 김석천 추가
--                             , ( SELECT XSUP.FT_MSE_LM_ORD_RMK_LIST( Z.PT_NO
--                                                                   , Z.ORD_DT
--                                                                   , Z.EXM_PRGR_STS_CD
--                                                                   , Z.SPCM_PTHL_NO
--                                                                   , Z.TH1_SPCM_CD
--                                                                   , Z.STM_EXM_BNDL_SEQ
--                                                                   , Z.PT_HME_DEPT_CD
--                                                                   , Z.EXM_HOPE_DT
--                                                                   , DECODE(Z.ODAPL_POP_CD,'3','3','9','9','7','7','1')
--                                                                   , Z.MED_EXM_CTG_CD
--                                                                   , Z.PACT_TP_CD
--                                                                   , Z.HSP_TP_CD
--                                                                   , Z.PBSO_DEPT_CD
----                                                                   , Z.EMRG_YN
--                                                                   , Z.BRCD_CNTE
--                                                                   , 'N' --Z.RST_CNSG_YN                                                -- 2018.11.19 위탁수탁여부
--                                                                   , 'N'
--                                                                   , 'N'
--                                                                   )
--                                   FROM DUAL)                                                                                   ORD_RMK_LIST
--                             , MAX((SELECT DECODE(RSV_ACPT_TP_CD,'04','Y','N')
--                                      FROM ACPPRODM
--                                     WHERE PACT_ID = Z.PACT_ID
--                                       AND HSP_TP_CD = IN_HSP_TP_CD))                                                                RSV_ACPT_TP_CD
--                             , MIN(Z.PACT_ID)                                                                                   PACT_ID
--                             , ( SELECT 'Tel) ' || D.DTRL2_NM || CHR(13) || CHR(10) ||'[의뢰처: ' || D.DTRL3_NM || ']'
--                                   FROM CCCCCSTE D
--                                  WHERE D.COMN_GRP_CD = 'TEL'
--                                    AND D.COMN_CD_NM  = Z.PBSO_DEPT_CD
--                                    AND ROWNUM        = 1
--                               )                                                                                                TEL
--                             , ( SELECT DECODE(SUBSTR(EXRM_EXM_CTG_CD, 1, 1),'N',TH1_RMK_CNTE ,SCLS_COMN_CD_NM)
--                                   FROM MSELMSID
--                                  WHERE LCLS_COMN_CD = 'SPCM_CD'
--                                    AND SCLS_COMN_CD = DECODE(EXRM_EXM_CTG_CD,'L25',DECODE(SUBSTR(Z.TH1_SPCM_CD,2), 'EDT','ED6', SUBSTR(Z.TH1_SPCM_CD,2))
--                                                                                                                               , SUBSTR(Z.TH1_SPCM_CD,2))
--                                    AND HSP_TP_CD    = Z.HSP_TP_CD
--                                    AND ROWNUM = 1)                                                                             SPCM_ABBR
--                             , XSUP.FT_MSE_SPCM_INFO( Z.PT_NO
--                                                    , Z.EXRM_EXM_CTG_CD
--                                                    , TO_CHAR(Z.ORD_DT,'YYYYMMDD')
--                                                    , Z.EXM_PRGR_STS_CD
--                                                    , Z.SPCM_PTHL_NO
--                                                    , Z.TH1_SPCM_CD
--                                                    , Z.PACT_TP_CD
--                                                    , Z.STM_EXM_BNDL_SEQ
--                                                    , Z.PT_HME_DEPT_CD
--                                                    , TO_CHAR(Z.EXM_HOPE_DT,'YYYYMMDD')
--                                                    , DECODE(Z.ODAPL_POP_CD,'3','3','9','9','7','7','1')
--                                                    , Z.MED_EXM_CTG_CD
--                                                    , Z.HSP_TP_CD
--                                                    ,'N')                                                              SPCM_INFO
--                             , Z.SPCM_BANGBUJE
--                             , MAX(Z.EXRS_TDY_REQ_YN)    EXRS_TDY_REQ_YN
--                             , XSUP.FT_MSE_TH1_SPCM_CD_INFO ( Z.PT_NO
--                                                            , Z.EXRM_EXM_CTG_CD
--                                                            , TO_CHAR(Z.ORD_DT,'YYYYMMDD')
--                                                            , Z.EXM_PRGR_STS_CD
--                                                            , Z.SPCM_PTHL_NO
--                                                            , Z.TH1_SPCM_CD
--                                                            , Z.PACT_TP_CD
--                                                            , Z.STM_EXM_BNDL_SEQ
--                                                            , Z.PT_HME_DEPT_CD
--                                                            , TO_CHAR(Z.EXM_HOPE_DT,'YYYYMMDD')
--                                                            , DECODE(Z.ODAPL_POP_CD,'3','3','9','9','7','7','1')
--                                                            , Z.MED_EXM_CTG_CD
--                                                            , Z.HSP_TP_CD
--                                                            , 'N')                                                              WK_UNIT_CD    --2016.01.28 곽수미 추가
--                             , MAX(Z.EITM_CAPN_CNTE)                                                                                    EITM_CAPN_CNTE -- 2017.01.05 김성룡 주의사항 추가
--                             , ( SELECT XSUP.FT_MSE_LM_ORD_CAPN_LIST( Z.PT_NO
--                                                                   , Z.ORD_DT
--                                                                   , Z.EXM_PRGR_STS_CD
--                                                                   , Z.SPCM_PTHL_NO
--                                                                   , Z.TH1_SPCM_CD
--                                                                   , Z.STM_EXM_BNDL_SEQ
--                                                                   , Z.PT_HME_DEPT_CD
--                                                                   , Z.EXM_HOPE_DT
--                                                                   , DECODE(Z.ODAPL_POP_CD,'3','3','9','9','7','7','1')
--                                                                   , Z.MED_EXM_CTG_CD
--                                                                   , Z.PACT_TP_CD
--                                                                   , Z.HSP_TP_CD
--                                                                   , Z.PBSO_DEPT_CD)
--                                   FROM DUAL)                                                                                   EITM_CAPN_CNTE_LIST
--                        
--                        
--                             , XSUP.FT_MSE_SPCLM_DUP_CHK('3', LISTAGG(Z.ORD_CD,'|') WITHIN GROUP(ORDER BY Z.ORD_CD), z.HSP_TP_CD) DUP_ORD_CD -- 2017.01.16 김성룡 중복검사 체크 추가
--                             , Z.EMRG_YN
--                             , Z.BRCD_CNTE
--                             , Z.TLA_ORD_SND_FLAG_CNTE
--                             , 'N' ORD_CD_OVER_YN                             -- 2018-01-25 중복처방코드 확인
----                             , Z.PACT_ID
----                             , FT_MSE_DEPT(Z.HSP_TP_CD, Z.PBSO_DEPT_CD) PBSO_DEPT_NM
----                             , MAX(Z.RST_CNSG_YN) RST_CNSG_YN                 -- 2018.11.19 위탁수탁여부 2020.03.20 사용안함
--                         FROM ( SELECT  A.PACT_TP_CD                                                               PACT_TP_CD
--                                      , B.EXRM_EXM_CTG_CD                                                          EXRM_EXM_CTG_CD
--                                      , A.TH1_SPCM_CD                                                              TH1_SPCM_CD
--                                      , A.EXM_HOPE_DT                                                              EXM_HOPE_DT
--                                      , B.RSVP_YN                                                                  RSVP_YN
--                                      , A.PT_NO                                                                    PT_NO
--                                      , A.ORD_DT                                                                   ORD_DT
--                                      , A.EXM_PRGR_STS_CD                                                          EXM_PRGR_STS_CD
--                                      , A.SPCM_PTHL_NO                                                             SPCM_PTHL_NO
--                                      , A.STM_EXM_BNDL_SEQ                                                         STM_EXM_BNDL_SEQ
--                                      , A.ODAPL_POP_CD                                                             ODAPL_POP_CD
--                                      , DECODE(B.EXRM_EXM_CTG_CD,'L79',B.MED_EXM_CTG_CD,B.EXRM_EXM_CTG_CD)         MED_EXM_CTG_CD
--                                      , A.HSP_TP_CD                                                                HSP_TP_CD
--                                      , A.ANDR_STF_NO                                                              ANDR_STF_NO
--                                      , B.NREXM_EPST_TM_CNTE                                                       NREXM_EPST_TM_CNTE
--                                      , A.PBSO_DEPT_CD                                                             PBSO_DEPT_CD
--                                      , A.PT_HME_DEPT_CD                                                           PT_HME_DEPT_CD
--                                      , C.ORD_CTRL_CD                                                              ORD_CTRL_CD
--                                      , XSUP.FT_MSE_LM_PACT_ID( A.PT_NO
--                                                              , A.ORD_DT
--                                                              , A.EXM_PRGR_STS_CD
--                                                              , A.SPCM_PTHL_NO
--                                                              , A.TH1_SPCM_CD
--                                                              , A.STM_EXM_BNDL_SEQ
--                                                              , A.PT_HME_DEPT_CD
--                                                              , A.EXM_HOPE_DT
--                                                              , DECODE(A.ODAPL_POP_CD,'3','3','9','9','7','7','1')
--                                                              , DECODE(B.EXRM_EXM_CTG_CD,'L79',B.MED_EXM_CTG_CD,B.EXRM_EXM_CTG_CD)
--                                                              , A.PACT_TP_CD
--                                                              , A.HSP_TP_CD
--                                                              , A.PBSO_DEPT_CD
--                                                              , 'PACT_ID'
--                                                              , 'N')           PACT_ID
--                                      , XSUP.FT_MSE_LM_PACT_ID( A.PT_NO
--                                                              , A.ORD_DT
--                                                              , A.EXM_PRGR_STS_CD
--                                                              , A.SPCM_PTHL_NO
--                                                              , A.TH1_SPCM_CD
--                                                              , A.STM_EXM_BNDL_SEQ
--                                                              , A.PT_HME_DEPT_CD
--                                                              , A.EXM_HOPE_DT
--                                                              , DECODE(A.ODAPL_POP_CD,'3','3','9','9','7','7','1')
--                                                              , DECODE(B.EXRM_EXM_CTG_CD,'L79',B.MED_EXM_CTG_CD,B.EXRM_EXM_CTG_CD)
--                                                              , A.PACT_TP_CD
--                                                              , A.HSP_TP_CD
--                                                              , A.PBSO_DEPT_CD
--                                                              , 'RPY_PACT_ID'
--                                                              , 'N')           RPY_PACT_ID
--                                      , D.IMGN_PT_CTG_CD
--                                      , A.ORD_CD         --2015.03.23 곽수미 추가
--                                      , ( SELECT DECODE(NVL(SCLS_COMN_CD, 'N'), 'N', 'N', 'Y')
--                                            FROM MSELMSID
--                                           WHERE LCLS_COMN_CD = '997'
--                                             AND SCLS_COMN_CD = A.ORD_CD
--                                             AND HSP_TP_CD = A.HSP_TP_CD
--                                             AND USE_YN = 'Y'
--                                             AND ROWNUM = 1
--                                         )                                                                                               SPCM_BANGBUJE
--                                      , A.EXRS_TDY_REQ_YN               EXRS_TDY_REQ_YN
--                                      , B.EITM_CAPN_CNTE                EITM_CAPN_CNTE
--                                      , NVL(A.EMRG_YN, 'N') EMRG_YN
--                                      , NVL(B.BRCD_CNTE, 'N')                BRCD_CNTE                                                                     --바코드내용
--                                      , NVL(B.TLA_ORD_SND_FLAG_CNTE, 'N') TLA_ORD_SND_FLAG_CNTE
----                                      , NVL(B.RST_CNSG_YN, 'N') RST_CNSG_YN                                                                    -- 2018.11.19 위탁수탁여부 2020.03.20 사용안함
--                                   FROM MOOOREXM A
--                                      , MSELMEBM B
--                                      , CCOOCBAC C
--                                      , PCTPCPAM_DAMO D
--                                  WHERE B.EXM_CD     = A.ORD_CD
--                                    AND C.ORD_CD      = A.ORD_CD
--                                    AND A.PT_NO     = IN_PT_NO
--                                    AND ((A.ORD_CTG_CD IN ('CP', 'NM')) OR
--                                        (A.ORD_CTG_CD ='PA' AND A.ORD_SLIP_CTG_CD IN ('P12','P13') AND ((A.ORD_CD = 'L6507' and A.TH1_SPCM_CD = 'SPUM') or ( A.ORD_CD = 'L65071' and A.TH1_SPCM_CD = 'VOUR' ) or ( A.ORD_CD = 'L6522' and  A.TH1_SPCM_CD = 'SPUM'))))
--                                    AND A.EXM_HOPE_DT         = IN_EXM_HOPE_DT
--                                    AND A.EXM_PRGR_STS_CD     = 'X'
--                                    AND A.ODDSC_TP_CD         = 'C'
----                                    AND A.RPY_STS_CD         = 'Y'
--                                    AND A.HSP_TP_CD         = IN_HSP_TP_CD
--                                    AND A.ORD_CD NOT IN(SELECT DTRL2_NM
--                                                         FROM CCCCCSTE
--                                                        WHERE COMN_GRP_CD = '966'
--                                                          AND COMN_CD      = '002'
--                                                          AND USE_YN       = 'Y'
--                                                        UNION
--                                                       SELECT DTRL3_NM
--                                                         FROM CCCCCSTE
--                                                        WHERE COMN_GRP_CD = '966'
--                                                          AND COMN_CD      = '002'
--                                                          AND USE_YN       = 'Y')
--                                    AND A.HSP_TP_CD = IN_HSP_TP_CD
--                                    AND B.HSP_TP_CD = A.HSP_TP_CD
--                                    AND C.HSP_TP_CD = A.HSP_TP_CD
--                                    AND A.PT_NO     = D.PT_NO
--                                    AND (B.MED_EXM_CTG_CD <> 'L84' OR A.ORD_CD = 'L8451')
--                               ) Z
--                           GROUP BY Z.ORD_DT
--                                  , Z.EXM_HOPE_DT
--                                  , Z.EXRM_EXM_CTG_CD
--                                  , Z.MED_EXM_CTG_CD
--                                  , Z.TH1_SPCM_CD
--                                  , Z.HSP_TP_CD
--                                  , Z.PBSO_DEPT_CD
--                                  , Z.PT_HME_DEPT_CD
--                                  , Z.SPCM_PTHL_NO
--                                  , Z.EXM_PRGR_STS_CD
--                                  , Z.STM_EXM_BNDL_SEQ
--                                  , Z.PACT_TP_CD
--                                  , DECODE(Z.ODAPL_POP_CD,'3','3','9','9','7','7','1')
--                                  , Z.PT_NO
--                                  , Z.ODAPL_POP_CD
--                                  , Z.PACT_ID
--                                  , Z.RPY_PACT_ID
--                                  , Z.IMGN_PT_CTG_CD
--                                  , Z.SPCM_BANGBUJE
--                                  , Z.EMRG_YN
--                                  , Z.BRCD_CNTE
--                                  , Z.TLA_ORD_SND_FLAG_CNTE 
----                                  , Z.RST_CNSG_YN                    -- 2018.11.19 위탁수탁여부    2020.03.20 사용안함    
--                            ORDER BY ORD_DT      DESC
--                                   , PT_HME_DEPT_CD                -- 부서   순서바뀌면 안됨  -- 2019.04.01
--                                   , TLA_ORD_SND_FLAG_CNTE      -- TLA
--                                   , EXM_HOPE_DT DESC
--                                   , TH1_SPCM_CD                -- 검체
--                                   , EXRM_EXM_CTG_CD
--                                   , DOC_ID
--                                   , EMRG_YN                    -- 응급
--                                   , STM_EXM_BNDL_SEQ           -- 묶음번호
--                                   , BRCD_CNTE
----                                   , RST_CNSG_YN                -- 위수탁여부  2020.03.20 사용안함              
--                           )
--             LOOP             
--             
--                 -- TLA, 부서, 응급여부 확인해서 처리
--                 IF (REC.TLA_ORD_SND_FLAG_CNTE = 'TLA' AND REC.PT_HME_DEPT_CD = S_PT_HME_DEPT_CD AND REC.EMRG_YN = S_EMRG_YN AND REC.STM_EXM_BNDL_SEQ = S_STM_EXM_BNDL_SEQ AND REC.BRCD_CNTE = S_BRCD_CNTE AND REC.EXM_HOPE_DT = S_EXM_HOPE_DT AND REC.RST_CNSG_YN = S_RST_CNSG_YN AND REC.TH1_SPCM_CD = S_TH1_SPCM_CD) THEN
--                     S_TLA_SPCM_NO := S_TLA_SPCM_NO1;
--                 ELSE   
--                     S_TLA_SPCM_NO := '0';
--                 END IF;
--                 
--                 BEGIN
--                         PC_MSE_SPCMNO ( IN_PT_NO               
--                                      , REC.ORD_DT              
--                                      , IN_HSP_TP_CD
--                                      , REC.EXRM_EXM_CTG_CD
--                                      , REC.EXRM_EXM_CTG_CD              -- 2019.04.01
--                                      , REC.TH1_SPCM_CD        
--                                      , REC.STM_EXM_BNDL_SEQ    
--                                      , REC.PBSO_DEPT_CD        
--                                      , REC.PT_HME_DEPT_CD     
--                                      , REC.EXM_HOPE_DT         
--                                      , REC.PACT_TP_CD                  -- IN      VARCHAR2
--                                      , ''                                -- IN_ORD_RMK_CNTE        IN      VARCHAR2
--                                      , REC.ODAPL_POP_CD                -- IN_ODAPL_POP_CD        IN      VARCHAR2
--                                      , REC.TODAYYN                        -- IN_TODAYYN             IN      VARCHAR2
--                                      , 'ACK01'                            -- HIS_USER_ID            IN      VARCHAR2
--                                      , 'AUTOB'                            -- IN_BL_PLACE            IN      VARCHAR2
--                                      , '1'                                -- IN_BLDGUBN             IN      VARCHAR2   -- 2012.05.12 lbw추가  gubn : 1 - 일반채혈 , gubn : 2 - 개별채혈  
--                                      , ''                                 -- IN_ORD_ID              IN      VARCHAR2   -- 2012.10.17 IN_ORD_SEQ 에서 IN_ORD_ID 로 변경 by KSC 
--                                      , REC.EMRG_YN                        -- IN_EMRG_YN             IN      VARCHAR2   -- 2017.09.13 응급여부  
--                                      , 'KIOSK'                            -- IN_HIS_PRGM_NM         IN      VARCHAR2
--                                      , S_IP_ADDR                        -- IN_HIS_IP_ADDR         IN      VARCHAR2
--                                      , REC.TLA_ORD_SND_FLAG_CNTE        -- IN_TLA_ORD_SND_FLAG_CNTE IN    VARCHAR2   -- 2017.10.20 TLA 구분
--                                      , S_TLA_SPCM_NO                    -- IN_TLA_SPCM_NO          IN      VARCHAR2   -- 2017.10.20 TLA 구분 검체번호 동일
--                                      , REC.BRCD_CNTE                    -- IN_BRCD_CNTE           IN      VARCHAR2   -- 2017.10.30 바코드 구분
--                                      , 'N'                                -- IN_BLCL_TEAM_BLCL_YN   IN      VARCHAR2   -- 2017.12.05 채혈팀 채혈여부
--                                      , REC.RST_CNSG_YN                                                                 -- 2018.11.19 위탁수탁여부
--                                      , S_SPCM_NO                         -- IN OUT  VARCHAR2
--                                      , IO_ERRYN                          -- OUT     VARCHAR2
--                                      , IO_ERRMSG                        -- OUT     VARCHAR2
--                                       );
--                           
--                           IF IO_ERRYN = 'Y' THEN
--                            IO_ERRYN  := 'Y';
--                            IO_ERRMSG := '채혈 함수 호출 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERRMSG;
--                            RETURN;
--                        END IF;
--                 
--                 
--                 END;  
--                 
--                 IF INSTR(S_SPCM_NO_LIST, S_SPCM_NO) = 0 OR INSTR(S_SPCM_NO_LIST, S_SPCM_NO) = '' THEN
--                      
--                     S_SPCM_NO_LIST := S_SPCM_NO_LIST || ',' || S_SPCM_NO;
--                     
--                     S_SPCMCNT := S_SPCMCNT + 1;   
--                     
--                 END IF;             
--                 
--                 IF REC.TLA_ORD_SND_FLAG_CNTE = 'TLA' THEN
--                     S_TLA_SPCM_NO1 := S_SPCM_NO;
--                 ELSE   
--                     S_TLA_SPCM_NO1 := '0';
--                 END IF;     
--                 
--                 S_PT_HME_DEPT_CD     := REC.PT_HME_DEPT_CD;
--                S_EMRG_YN             := REC.EMRG_YN;
--                S_STM_EXM_BNDL_SEQ     := REC.STM_EXM_BNDL_SEQ;
--                S_BRCD_CNTE         := REC.BRCD_CNTE;
--                S_EXM_HOPE_DT         := REC.EXM_HOPE_DT; 
--                S_RST_CNSG_YN         := REC.RST_CNSG_YN; 
--                S_TH1_SPCM_CD         := REC.TH1_SPCM_CD; 
--                  
--                
--            END LOOP;  
--            
--                 
--            BEGIN
--                 -- 대기번호 생성
--                 XSUP.PC_MSE_INS_KIOSK_WAITNO ( IN_HSP_TP_CD         -- 병원구분
--                                             , IN_PT_NO            -- 차트번호
--                                                , 'KIOSK'                -- 채혈장소 
--                                                 , ''                 -- 접수대기번호 존재여부확인 2018.08.30
--                                                , S_WAITNO          -- 대기번호
--                                               , IO_ERRYN          -- 오류여부
--                                                , IO_ERRMSG         -- 오류메세지    
--                                              );
--                IF IO_ERRYN = 'Y' THEN
--                       IO_WAITNO := '';
--                       IO_ERRYN  := 'Y';
--                    IO_ERRMSG := '대기번호 생성시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERRMSG;
--                    RETURN;
--                END IF; 
--
--             END;   
--                 
--            
--            -- 대기번호 및 검체건수 업데이트
--             BEGIN
--                 
--                 FOR REC1 IN (
--                                 SELECT SUBSTR(SPCM_NO_LIST, INSTR(SPCM_NO_LIST, ',', 1, LEVEL) + 1, INSTR(SPCM_NO_LIST, ',', 1, LEVEL + 1) - INSTR(SPCM_NO_LIST, ',', 1, LEVEL) - 1) SPCM_NO_LIST
--                                  FROM   (
--                                              SELECT ',' || REPLACE(S_SPCM_NO_LIST, ',', ',') || ',' SPCM_NO_LIST
--                                              FROM  DUAL
--                                 )
--                                 CONNECT BY LEVEL <= LENGTH(SPCM_NO_LIST) - LENGTH(REPLACE(SPCM_NO_LIST, ',')) - 1    
--                             )
--                 LOOP
--                         BEGIN
--                             
--                             UPDATE MSELMCED
--                               SET SPCM_NUM             = S_SPCMCNT
--                                 , OTPT_BLCL_WAIT_NO     = S_WAITNO   
--                                 , LSH_PRGM_NM          = 'KIOSK'
--                                 , LSH_DTM                = SYSDATE
--                             WHERE HSP_TP_CD             = IN_HSP_TP_CD 
--                               AND SPCM_NO                 = TRIM(REC1.SPCM_NO_LIST)
--                               AND PT_NO                 = IN_PT_NO
--                            ;                     
--                         END;
--                         
--                         S_SPCM_NO_TEST := S_SPCM_NO_TEST || ',' || REC1.SPCM_NO_LIST; 
--                         
--                 END LOOP;
--             
--             END; 
--             
--            
--        END;
--         
--        IO_WAITNO := S_WAITNO;
--        IO_ERRYN  := 'N';
--        IO_ERRMSG := '';
----        IO_ERRMSG := '검체번호 : ' || S_SPCM_NO_LIST || ' 검체갯수 : ' ||  S_SPCMCNT || ' 업데이트 값 : '  ||  S_SPCM_NO_TEST ;
--    END;        
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_KIOSK_TOTAL_SELECT
    *    최초 작성일 : 2018.07.23
    *    최초 작성자 : 김금덕 
    *    DESCRIPTION : KIOSK 대기자 인원수 조회
    **********************************************************************************************/
    PROCEDURE PC_MSE_KIOSK_TOTALWAIT_SELECT    ( IN_HSP_TP_CD           IN       VARCHAR2       -- 병원구분   
                                              , OUT_CURSOR             OUT  RETURNCURSOR
                                              ) 
    IS
    
    WK_CURSOR                 RETURNCURSOR ; 
    
    BEGIN       
               

        BEGIN      
            OPEN WK_CURSOR FOR    
                   SELECT COUNT(DISTINCT PT_NO) CNT
                  FROM MSELMSID A
                     , PCTPCPAM_DAMO B
                 WHERE A.HSP_TP_CD     = IN_HSP_TP_CD
                   AND A.TH1_RMK_CNTE ='KIOSKWAITNO'
                   AND A.LCLS_COMN_CD = TO_CHAR(SYSDATE, 'YYYY-MM-DD')
                   AND A.TH3_RMK_CNTE = B.PT_NO
                   AND A.USE_YN ='N'
                ;
                OUT_CURSOR := WK_CURSOR ;
                    
                EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR('0', '0' || SQLCODE || SQLERRM) ;                             
                                               
        END;          
            
    END PC_MSE_KIOSK_TOTALWAIT_SELECT; 


    /**********************************************************************************************
    *    서비스이름  : PC_MSE_BLOOD_INCUBATION_SELECT
    *    최초 작성일 : 2018.08.29
    *    최초 작성자 : 김금덕 
    *    DESCRIPTION : 혈액배양 채혈단계 조회리스트
    **********************************************************************************************/
    PROCEDURE PC_MSE_BLOOD_INCUBATION_SELECT (    IN_HSP_TP_CD           IN   VARCHAR2       -- 병원구분
                                                , IN_SDTE                IN   VARCHAR2       -- 채혈시작일자
                                                , IN_EDTE                IN   VARCHAR2       -- 채혈종료일자
                                                , IN_SPCM_NO             IN   VARCHAR2       -- 검체번호
                                                , OUT_CURSOR             OUT  RETURNCURSOR
                                              )
    IS
        
    WK_CURSOR                 RETURNCURSOR ; 
    
    BEGIN               
            OPEN WK_CURSOR FOR    
                SELECT *
                  FROM DUAL
                  ;            
           

--            OPEN WK_CURSOR FOR    
--                  SELECT /*+ LEADING(A) INDEX(A MSELMCED_PK)  USE_NL(A B C) */
--                         A.SPCM_NO
--                       , B.PACT_TP_CD
--                       , C.PT_NO
--                       , C.PT_NM
--                       , C.SEX_TP_CD
--                       , TO_CHAR(C.PT_BRDY_DT, 'YYYY-MM-DD')              PT_BRDY_DT
--                       , B.ORD_CD
--                       , A.TH1_SPCM_CD
--                       , B.PT_HME_DEPT_CD
--                       , B.WD_DEPT_CD
--                       , B.EXM_PRGR_STS_CD
--                       , TO_CHAR(A.BLCL_DTM, 'YYYY-MM-DD HH24:MI:SS')     BLCL_DTM
--                    FROM MSELMCED A, MOOOREXM B, PCTPCPAM_DAMO C
--                   WHERE     A.HSP_TP_CD = IN_HSP_TP_CD
--                         AND A.BLCL_DTM BETWEEN TO_DATE( IN_SDTE, 'YYYYMMDDHH24MISS') AND TO_DATE( IN_EDTE, 'YYYYMMDDHH24MISS')
--                         AND A.HSP_TP_CD = B.HSP_TP_CD
--                         AND A.SPCM_NO = B.SPCM_PTHL_NO
--                         AND B.EXM_PRGR_STS_CD IN ('B', 'C')
--                         AND B.ORD_CD = 'L4008'
--                         AND B.ODDSC_TP_CD = 'C'
--                         AND DECODE(B.PACT_TP_CD,  'I', 'Y',  'E', 'Y',  'O', B.RPY_STS_CD) = 'Y'
--                         AND IN_SPCM_NO IS NOT NULL
--                         AND A.SPCM_NO = IN_SPCM_NO
--                         --AND A.SPCM_NO = DECODE( IN_SPCM_NO, '', A.SPCM_NO, IN_SPCM_NO )
--                         AND B.PT_NO = C.PT_NO
--                UNION ALL   
--                  SELECT /*+ LEADING(A) INDEX(A MSELMCED_SI02)  USE_NL(A B C)  */
--                         A.SPCM_NO
--                       , B.PACT_TP_CD
--                       , C.PT_NO
--                       , C.PT_NM
--                       , C.SEX_TP_CD
--                       , TO_CHAR(C.PT_BRDY_DT, 'YYYY-MM-DD')              PT_BRDY_DT
--                       , B.ORD_CD
--                       , A.TH1_SPCM_CD
--                       , B.PT_HME_DEPT_CD
--                       , B.WD_DEPT_CD
--                       , B.EXM_PRGR_STS_CD
--                       , TO_CHAR(A.BLCL_DTM, 'YYYY-MM-DD HH24:MI:SS')     BLCL_DTM
--                    FROM MSELMCED A, MOOOREXM B, PCTPCPAM_DAMO C
--                   WHERE     A.HSP_TP_CD = IN_HSP_TP_CD
--                         AND A.BLCL_DTM BETWEEN TO_DATE( IN_SDTE, 'YYYYMMDDHH24MISS') AND TO_DATE( IN_EDTE, 'YYYYMMDDHH24MISS')
--                         AND A.HSP_TP_CD = B.HSP_TP_CD
--                         AND A.SPCM_NO = B.SPCM_PTHL_NO
--                         AND B.EXM_PRGR_STS_CD IN ('B', 'C')
--                         AND B.ORD_CD = 'L4008'
--                         AND B.ODDSC_TP_CD = 'C'
--                         AND DECODE(B.PACT_TP_CD,  'I', 'Y',  'E', 'Y',  'O', B.RPY_STS_CD) = 'Y'
--                         --AND A.SPCM_NO = DECODE( IN_SPCM_NO, '', A.SPCM_NO, IN_SPCM_NO )
--                         AND IN_SPCM_NO IS NULL
--                         AND B.PT_NO = C.PT_NO
--                ORDER BY PT_NO, SPCM_NO
--                ;
--                
           
--        OPEN WK_CURSOR FOR
--            SELECT /*+ NO_EXPAND INDEX(A MSELMCED_SI02) */ 
--                   A.SPCM_NO                                                    -- 검체번호
--                 , B.PACT_TP_CD                                                    -- O 외래 , I 입원 , E 응급
--                 , C.PT_NO                                                        -- 환자번호
--                  , C.PT_NM                                                      -- 환자이름
--                  , C.SEX_TP_CD                                                  -- 성별
--                  , TO_CHAR(C.PT_BRDY_DT, 'YYYY-MM-DD') PT_BRDY_DT                -- 생년월일
--                 , B.ORD_CD                                                        -- 처방코드
--                 , A.TH1_SPCM_CD                                                -- 검체코드
--                 , B.PT_HME_DEPT_CD                                                  -- 진료과코드
--                  , B.WD_DEPT_CD                                                 -- 병동코드
--                 , B.EXM_PRGR_STS_CD                                            -- 처방상태
----                 , B.STM_EXM_BNDL_SEQ                                            -- 묶음번호
--                 , TO_CHAR(A.BLCL_DTM, 'YYYY-MM-DD HH24:MI:SS') BLCL_DTM        -- 채혈시간
--              FROM MSELMCED A
--                 , MOOOREXM B
--                 , PCTPCPAM_DAMO C
--             WHERE A.HSP_TP_CD               = IN_HSP_TP_CD
----               AND A.BLCL_DTM BETWEEN TO_DATE(IN_SDTE, 'YYYY-MM-DD') AND TO_DATE(IN_EDTE, 'YYYY-MM-DD') + 0.9999                        -- 일자
--               AND A.BLCL_DTM BETWEEN TO_DATE(IN_SDTE, 'YYYYMMDDHH24MISS') AND TO_DATE(IN_EDTE, 'YYYYMMDDHH24MISS')                        -- 시분초
--               AND A.HSP_TP_CD               = B.HSP_TP_CD
--               AND A.SPCM_NO                 = B.SPCM_PTHL_NO
--               AND B.EXM_PRGR_STS_CD         IN ('B', 'C')                    -- 채혈, 접수상태
--               AND B.ORD_CD                  = 'L4008'     -- 혈액배양검사코드
--               AND B.ODDSC_TP_CD             = 'C'            -- 처방상태
--               AND DECODE(B.PACT_TP_CD, 'I', 'Y', 'E', 'Y', 'O', B.RPY_STS_CD) = 'Y'      -- 입원/응급은 수납여부상관없이 외래만 체크
--               AND A.SPCM_NO = DECODE(IN_SPCM_NO, '', A.SPCM_NO , IN_SPCM_NO)
--               AND B.PT_NO                     = C.PT_NO
--             ORDER BY PT_NO, SPCM_NO
--             ;
                
        OUT_CURSOR := WK_CURSOR ;
                    
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
--                         RAISE_APPLICATION_ERROR('0', '0' || SQLCODE || SQLERRM) ;
    
    END PC_MSE_BLOOD_INCUBATION_SELECT;   
    

    /**********************************************************************************************
    *    서비스이름  : PC_MSE_UPT_RST_GA_ACPT 양병원 위수탁 검체가접수
    *    최초 작성일 : 2019.01.04
    *    최초 작성자 : 김금덕 
    *    Description : 인터페이스 진단검사
    **********************************************************************************************/  
--    PROCEDURE PC_MSE_UPT_RST_GA_ACPT   ( IN_HSP_TP_CD         IN      VARCHAR2   -- <P0>병원구분
--                                       , IN_SPCM_NO            IN      VARCHAR2   -- <P1>검체번호
--                                       , IN_SPCID            IN      VARCHAR2   -- <P2>사용자
--                                       , IO_ERRYN              IN OUT  VARCHAR2   -- 오류여부
--                                       , IO_ERRMSG             IN OUT  VARCHAR2   -- 오류메세지
--                                       )                               
--    IS           
--                      
--    S_PRGM_NM                  MSELMCED.LSH_PRGM_NM%TYPE       := 'PC_MSE_UPT_RST_GA_ACPT';
--    S_IP_ADDR                  MSELMCED.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');
--              
--    BEGIN
--    
--        BEGIN 
--                     
--            UPDATE MSELMCED 
--               SET RST_CNSG_HDOV_DTM        = SYSDATE
--                 , RST_CNSG_HDOV_STF_NO     = IN_SPCID                 
--                 , LSH_STF_NO               = IN_SPCID
--                 , LSH_DTM                  = SYSDATE
--             WHERE SPCM_NO                  = IN_SPCM_NO
--               AND HSP_TP_CD                = IN_HSP_TP_CD   
--               AND EXRM_EXM_CTG_CD      LIKE 'L%'
--               AND RST_CNSG_YN                 = 'Y'
--            ;
--                  
--            IF SQL%ROWCOUNT = 0 THEN
--                IO_ERRYN  := 'Y';
--                IO_ERRMSG := '양병원 가접수 처리가 실패 되었습니다.';
--                RETURN;
--              END IF;  
--              
--              EXCEPTION
--              WHEN OTHERS THEN
--                   IO_ERRYN  := 'Y';
--                   IO_ERRMSG := '양병원 가접수 UPDATE 중 에러 발생 ERRCODE = ' || TO_CHAR(SQLCODE);
--                   RETURN;
--               
--        END;                      
--        
--    END PC_MSE_UPT_RST_GA_ACPT;
                                   
    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_QC_IFCODE_SAVEORDER
    *    최초 작성일 : 2019.04.10
    *    최초 작성자 : 김금덕 
    *    DESCRIPTION : 정도관리용 자동처방 인터페이스 
    **********************************************************************************************/
    PROCEDURE PC_MSE_QC_IFCODE_SAVEORDER( IN_HSP_TP_CD          IN       VARCHAR2       -- <P0>병원구분
                                        , IN_PT_NO              IN       VARCHAR2    -- <P1>환자정보
                                        , IN_SPCM_NO            IN       VARCHAR2    -- <P2>정도관리 장비인터페이스용 검체번호
                                        , IN_SPCID              IN      VARCHAR2       -- <P3>사용자
                                        , IO_SPCMNO             IN OUT  VARCHAR2       -- 검체번호
                                        , IO_ERRYN              IN OUT  VARCHAR2       -- 오류여부
                                        , IO_ERRMSG             IN OUT  VARCHAR2       -- 오류메세지
                                         )
        IS
         
        S_SPCM_NO            VARCHAR2(1000)      := '';
    
        BEGIN
                
--        XSUP.PC_MSE_INS_QC_SAVEORDER01_TEST(IN_HSP_TP_CD                  -- <P0>병원구분
--                                         , IN_PT_NO                  -- <P1>환자정보
--                                         , IN_SPCM_NO                -- <P2>정도관리 장비인터페이스용 검체번호
--                                         , IN_SPCID                       -- <P3>사용자
--                                        , S_SPCM_NO                     -- 검체번호
--                                        , IO_ERRYN                     -- 오류여부
--                                        , IO_ERRMSG                    -- 오류메세지
--                                       );    
--        
--        IF IO_ERRYN = 'Y' THEN
--              IO_SPCMNO := '';
--              IO_ERRYN  := 'Y';
--               IO_ERRMSG := 'PC_MSE_QC_IFCODE_SAVEORDER 인터페이스' || IO_ERRMSG;
--            RETURN;
--        END IF; 
 
 
        IO_SPCMNO  := S_SPCM_NO;
        IO_ERRYN   := 'N';
        IO_ERRMSG  := '';
        RETURN;

    END PC_MSE_QC_IFCODE_SAVEORDER;      
           
       
       
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_KIOSK_HDY_YN
    *    최초 작성일 : 2019.04.12
    *    최초 작성자 : 김금덕 
    *    DESCRIPTION : KIOSK 인터페이스 병원공휴일정보 
    **********************************************************************************************/
    PROCEDURE PC_MSE_KIOSK_HDY_SELECT    ( IN_HSP_TP_CD           IN   VARCHAR2       -- <P1>병원구분
                                          , IN_HDY_DT                IN   VARCHAR2       -- <P2>날짜
                                         , OUT_CURSOR             OUT  RETURNCURSOR
                                              ) 
    IS
    
    WK_CURSOR                 RETURNCURSOR ; 
    
    BEGIN       
               

        BEGIN      
            OPEN WK_CURSOR FOR    
                   SELECT HDY_YN
                  FROM CCCCCHOD
                 WHERE HSP_TP_CD     = IN_HSP_TP_CD
                   AND HDY_YN         = 'Y'
                   AND HDY_DT         = IN_HDY_DT --'2018-01-01'--TO_DATE(IN_HDY_DT, 'YYYY-MM-DD')
                    ;
                OUT_CURSOR := WK_CURSOR ;
                    
                EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR('PC_MSE_KIOSK_HDY_SELECT 조회시 오류발생', '0' || SQLCODE || SQLERRM) ;                             
                                               
        END;          
            
    END PC_MSE_KIOSK_HDY_SELECT; 
    
                  
    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_WORKNO_UPDATE 
    *    최초 작성일 : 2020.04.27
    *    최초 작성자 : 김금덕 
    *    Description : 장비별 WORK_NO 업데이트
    **********************************************************************************************/
    PROCEDURE PC_MSE_WORKNO_UPDATE    ( IN_HSP_TP_CD          IN   VARCHAR2       -- 병원구분
                                      , IN_SPCM_NO            IN   VARCHAR2        -- 환자번호
                                      , IN_WORK_NO            IN   VARCHAR2       -- WORK_NO
                                      , IO_ERRYN              IN OUT  VARCHAR2       -- 오류여부
                                      , IO_ERRMSG             IN OUT  VARCHAR2       -- 오류메세지
                                      )                               
    IS           
                      
    S_PRGM_NM                  MSELMCED.LSH_PRGM_NM%TYPE       := 'PC_MSE_WORKNO_UPDATE';
    S_IP_ADDR                  MSELMCED.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');
              
    BEGIN
    
        BEGIN 
                     
            UPDATE MSELMCED 
               SET LBL_PRNT_EQUP_CD     = IN_WORK_NO
                 , LSH_DTM                 = SYSDATE
                 , LSH_PRGM_NM             = S_PRGM_NM
                 , LSH_IP_ADDR             = S_IP_ADDR
             WHERE SPCM_NO              = IN_SPCM_NO
               AND HSP_TP_CD            = IN_HSP_TP_CD   
            ;
                  
            IF SQL%ROWCOUNT = 0 THEN
                IO_ERRYN  := 'Y';
                IO_ERRMSG := '장비별 WORK_NO UPDATE 상태값 변경이 실패 되었습니다.';
                RETURN;
              END IF;  
              
              EXCEPTION
              WHEN OTHERS THEN
                   IO_ERRYN  := 'Y';
                   IO_ERRMSG := '장비별 WORK_NO UPDATE 중 에러 발생 ERRCODE = ' || TO_CHAR(SQLCODE);
                   RETURN;
               
        END;
               
             
        
    END PC_MSE_WORKNO_UPDATE;       
    
    
    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_GNT_RSV_SELECT
    *    최초 작성일 : 2020.05.28
    *    최초 작성자 : 김금덕 
    *    DESCRIPTION : GNT 예약현황 조회
    **********************************************************************************************/
    PROCEDURE PC_MSE_GNT_RSV_SELECT    ( IN_HSP_TP_CD           IN   VARCHAR2       -- <P1>병원구분
                                      , IN_PT_NO                IN   VARCHAR2       -- <P2>환자번호
                                       , OUT_CURSOR             OUT  RETURNCURSOR
                                              ) 
    IS
    
    WK_CURSOR                 RETURNCURSOR ; 
    
    BEGIN       
               

        BEGIN      
            OPEN WK_CURSOR FOR    
                   
                    SELECT /* HIS.MS.IT.LM.PR.InsertPatientBloodCollection.SelectPtMedInfor */
                            TO_CHAR(A.MED_DT)                               MED_DT
                          , A.MED_DEPT_CD                                   MED_DEPT_CD
                          , A.MEF_RPY_STS_CD                                MEF_RPY_STS_CD
                          , RPAD(B.KOR_SRNM_NM, 8)                          MEDR_SID
                          , A.MED_YN                                        MED_YN
                          , '0000'                                             TEL
                       FROM
                            CCCCCSTE D
                          , CNLRRUSD E
                          , CNLRRUSD C
                          , CNLRRUSD B
                          , (  SELECT TO_CHAR(A.MED_DT,'YYYY-MM-DD') ||  TO_CHAR(A.MED_RSV_DTM,' HH24:MI') MED_DT
                                   , A.MED_WAIT_SEQ                                                        MED_WAIT_SEQ
                                   , A.MED_DEPT_CD                                                         MED_DEPT_CD
                                   , A.FRVS_RMDE_TP_CD                                                     FRVS_RMDE_TP_CD
                                   , A.MEDR_STF_NO                                                         MEDR_STF_NO
                                   , A.CMED_YN                                                             CMED_YN
                                   , A.PME_CLS_CD                                                          PME_CLS_CD
                                   , A.PSE_CLS_CD                                                          PSE_CLS_CD
                                   , A.CORG_CD                                                             CORG_CD
                                   , TO_CHAR(NVL(A.FSR_DTM,A.RSV_APLC_DT),'YYYY-MM-DD')                    EMRM_ARVL_DTM
                                   , A.MED_YN                                                              MED_YN
                                   , decode(A.MEF_RPY_CLS_CD, '1', '무료', 'N', '후불', 'R', '환불', 'S', '계산중', 'Y', '수납','A','부분환불')     MEF_RPY_STS_CD
                                   , A.LSH_STF_NO                                                          LSH_STF_NO
                                   , TO_CHAR(A.LSH_DTM, 'YYYY-MM-DD')                                      LSH_DTM
                                   , NVL(A.FSR_STF_NO, A.LSH_STF_NO)                                       FSR_STF_NO
                                   , A.MED_RSV_TP_CD
                                FROM ACPPRODM A
                               WHERE A.PT_NO   =      IN_PT_NO
                                 AND A.APCN_YN  = 'N'
                                 AND A.MED_DT  BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -12))
                                                   AND TRUNC(ADD_MONTHS(SYSDATE, 1)) + 0.99999
                                                                                             AND A.HSP_TP_CD = IN_HSP_TP_CD
                                UNION  ALL
        
                              SELECT TO_CHAR(A.EMRM_ARVL_DTM,'YYYY-MM-DD HH24:MI')     MED_DT
                                   , TO_NUMBER('0')                                    MED_WAIT_SEQ
                                   , A.MED_DEPT_CD                                   MED_DEPT_CD
                                   , A.FRVS_RMDE_TP_CD                               FRVS_RMDE_TP_CD
                                   , A.MEDR_STF_NO                                   MEDR_STF_NO
                                   , A.CMED_YN                                       CMED_YN
                                   , A.PME_CLS_CD                                    PME_CLS_CD
                                   , A.PSE_CLS_CD                                    PSE_CLS_CD
                                   , A.CORG_CD                                       CORG_CD
                                   , TO_CHAR(A.EMRM_ARVL_DTM,'YYYY-MM-DD')           EMRM_ARVL_DTM
                                   , decode(A.MEF_RPY_CLS_CD, 'R', 'N', 'Y')         MED_YN
                                   , decode(A.MEF_RPY_CLS_CD, '1', '무료', 'N', '후불', 'R', '환불', 'S', '계산중', 'Y', '수납','A','부분환불')     MEF_RPY_STS_CD
                                   , A.LSH_STF_NO                                    LSH_STF_NO
                                   , TO_CHAR(A.LSH_DTM, 'YYYY-MM-DD')                LSH_DTM
                                   , A.LSH_STF_NO                                    FSR_STF_NO
                                   , A.MED_RSV_TP_CD
                                FROM ACPPRETM A
                               WHERE A.PT_NO    =  IN_PT_NO
                                 AND A.APCN_YN  = 'N'
                                 AND A.HSP_TP_CD = IN_HSP_TP_CD
                                 AND A.EMRM_ARVL_DTM  BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -12))
                                                    AND TRUNC(ADD_MONTHS(SYSDATE, 1)) + 0.99999 ) A
                      WHERE B.STF_NO    =  A.MEDR_STF_NO
                        AND C.STF_NO(+) =  A.LSH_STF_NO
                        AND E.STF_NO(+) =  A.FSR_STF_NO
                        AND D.COMN_GRP_CD = '364'
                        AND COMN_CD = MED_RSV_TP_CD
                        AND E.HSP_TP_CD = IN_HSP_TP_CD
                        AND C.HSP_TP_CD = E.HSP_TP_CD
                        AND B.HSP_TP_CD = E.HSP_TP_CD
                      ORDER  BY  1 DESC                   
                       ;                 
                    
                OUT_CURSOR := WK_CURSOR ;
                    
                EXCEPTION
                    WHEN OTHERS THEN
                         RAISE_APPLICATION_ERROR('PC_MSE_KIOSK_HDY_SELECT 조회시 오류발생', '0' || SQLCODE || SQLERRM) ;                             
                                               
        END;          
            
    END PC_MSE_GNT_RSV_SELECT;  
    
    
    
    /**********************************************************************************************
     *    서비스이름  : PC_MSE_HISTORY_SAVE
     *    최초 작성일 : 2021.10.21
     *    최초 작성자 : ezCaretech SCS
     *    Description : 이력저장
     **********************************************************************************************/
    PROCEDURE PC_MSE_HISTORY_SAVE
                 ( IN_EQUP_CD          IN      VARCHAR2
                 , IN_REG_SEQ          IN      VARCHAR2
                 , IN_EXM_CD           IN      VARCHAR2
                 , IN_PT_NO            IN      VARCHAR2
                 , IN_SPCM_NO          IN      VARCHAR2
                 
                 , IN_EXRS_CNTE        IN      VARCHAR2
                 , IN_EXM_RMK_CNTE     IN      VARCHAR2
                 , IN_EQUP_RMK_CNTE    IN      VARCHAR2                
                                  
                 , HIS_STF_NO          IN      MSELMIFD.FSR_STF_NO%TYPE
                 , HIS_HSP_TP_CD       IN      MSELMIFD.HSP_TP_CD%TYPE
                 , HIS_PRGM_NM         IN      MSELMIFD.LSH_PRGM_NM%TYPE
                 , HIS_IP_ADDR         IN      MSELMIFD.LSH_IP_ADDR%TYPE
                 
                 , IO_ERR_YN           IN OUT  VARCHAR2
                 , IO_ERR_MSG          IN OUT  VARCHAR2 
                 )
    AS
        V_REG_SEQ    VARCHAR2(10);
    BEGIN

        IF IN_REG_SEQ IS NULL THEN
            SELECT NVL(MAX(REG_SEQ), 0) + 1
              INTO V_REG_SEQ
              FROM MSELMIFD
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND EQUP_CD   = IN_EQUP_CD
               AND SPCM_NO   = IN_SPCM_NO
               AND EXM_CD    = IN_EXM_CD;
        ELSE
            V_REG_SEQ := IN_REG_SEQ;
        END IF;
        
        BEGIN

            DELETE /* XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_HISTORY_SAVE */
              FROM MSELMIFD
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND SPCM_NO   = IN_SPCM_NO
               AND EQUP_CD   = IN_EQUP_CD
               AND REG_SEQ   = V_REG_SEQ
               AND EXM_CD    = IN_EXM_CD
               ;
--              RAISE_APPLICATION_ERROR(-20001, 'IN_EXM_CD : ' ||  IN_EXM_CD || '\' ) ;  
            INSERT /* XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_HISTORY_SAVE */
              INTO MSELMIFD
                 (
                   HSP_TP_CD            /*병원구분코드*/
                 , EQUP_CD              /*장비코드*/
                 , REG_DT               /*등록일자*/
                 , REG_SEQ              /*등록순번*/
                 , EXM_CD               /*검사코드*/
                 , PT_NO                /*환자번호*/
                 , SPCM_NO              /*검체번호*/
                 , CMPL_YN              /*완료여부*/
                 , EXRS_CNTE            /*검사결과내용*/
                 , EXM_RMK_CNTE         /*검사비고내용*/
                 , EQUP_RMK_CNTE        /*장비비고내용*/
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
                   HIS_HSP_TP_CD
                 , IN_EQUP_CD
                 , SYSDATE
                 , V_REG_SEQ -- IN_REG_SEQ
                 , IN_EXM_CD
                 , IN_PT_NO
                 , IN_SPCM_NO
                 , 'Y'
                 , IN_EXRS_CNTE
                 , IN_EXM_RMK_CNTE
                 , IN_EQUP_RMK_CNTE
                 , SYSDATE
                 , HIS_STF_NO
                 , HIS_PRGM_NM
                 , HIS_IP_ADDR
                 , SYSDATE
                 , HIS_STF_NO
                 , HIS_PRGM_NM
                 , HIS_IP_ADDR

                 );
                  
            EXCEPTION           
                WHEN DUP_VAL_ON_INDEX THEN
                    UPDATE MSELMIFD
                       SET EXRS_CNTE = IN_EXRS_CNTE
                         , EXM_RMK_CNTE = IN_EXM_RMK_CNTE
                         , EQUP_RMK_CNTE = IN_EQUP_RMK_CNTE
                         , LSH_DTM = SYSDATE
                         , LSH_STF_NO = HIS_STF_NO
                         , LSH_PRGM_NM = HIS_PRGM_NM
                         , LSH_IP_ADDR = HIS_IP_ADDR
                     WHERE HSP_TP_CD = HIS_HSP_TP_CD
                       AND SPCM_NO   = IN_SPCM_NO
                       AND EQUP_CD   = IN_EQUP_CD
                       AND REG_SEQ   = V_REG_SEQ
                       AND EXM_CD    = IN_EXM_CD
                       ;
                                           
                WHEN OTHERS THEN
                    IO_ERR_YN  := 'Y';
                    IO_ERR_MSG := '검사결과 인터페이스 이력정보 저장 중 에러 발생 ERROR = ' || SQLERRM || ' IN_EXM_CD : ' || IN_EXM_CD || ' IN_EQUP_CD : ' || IN_EQUP_CD || ' IN_REG_SEQ : ' || IN_REG_SEQ;
                    RETURN;                        
        END;
                         
    END PC_MSE_HISTORY_SAVE;     



    /**********************************************************************************************
    *    서비스이름  : PC_MSE_KIOSK_PATINFO_SELECT 
    *    최초 작성일 : 2021.11.29
    *    최초 작성자 : ezCaretech 홍승표
    *    DESCRIPTION : KIOSK 환자정보 조회      
    *                  전남대 학동 - GNT/HEMM : 에너지움
    
    -----------------------------------------------------------------------------------------------
                       * 정보구분 프로토콜 설명--> P로 시작하는 구분자에 해당하는 정보만 전달하며, 없는 정보는 전달하지 않음.
                       * 환자정보    ^PI    등록번호(환자번호)
                                ^PN    환자명
                                ^PS    성별
                                ^PA    나이
                                ^PB    BA 장비 ID (Default : A)
                                ^P1    생년월일
                                ^P2    장비번호
                                ^P3    접수담당자ID
                                ^P4    접수담당자명
                                ^P5    감염코드
                                ^PC    접수코멘트
                                ^PL    키오스크 연동 여부(K : 연동, L : 비연동) 
    **********************************************************************************************/
    PROCEDURE PC_MSE_KIOSK_PATINFO_SELECT ( IN_HSP_TP_CD        IN   VARCHAR2                 -- 병원코드
                                          , IN_KIOSK_ID         IN   VARCHAR2                 -- 키오스크 ID
                                          , IN_PT_NO            IN   VARCHAR2                 -- 환자번호
                                          , OUT_CURSOR         OUT  RETURNCURSOR )
    IS
        --변수선언
        WK_CURSOR                 RETURNCURSOR ; 
        V_COUNT                   VARCHAR2(100)  :=  '0';
        V_PT_NO_YN                VARCHAR2(100)  :=  '';
        V_RSTR                    VARCHAR2(100)  :=  '';
        V_STF_NO                  VARCHAR2(0020) :=  '';
        V_ORD_DT                  VARCHAR2(0020) :=  '';
        V_PT_NO                   VARCHAR2(0020) :=  '';

        -- 키오스크 번호에 따른 근무자 확인 후 근무자정보 리턴 필요한가?
            
        BEGIN       
            BEGIN   
                    
                BEGIN
                    SELECT TO_CHAR(SYSDATE,'YYYYMMDD')
                      INTO V_ORD_DT
                      FROM DUAL;
                END;   
                
                -- 특정 KOISK 장비의 마지막 채혈자 정보
                BEGIN
                   SELECT A.FSR_STF_NO
                     INTO V_STF_NO
                     FROM MSELMCNN  A
                        , CNLRRUSD  B 
                    WHERE 1=1
                      AND B.HSP_TP_CD = A.HSP_TP_CD
                      AND B.STF_NO    = A.FSR_STF_NO
                      AND A.HSP_TP_CD = IN_HSP_TP_CD
                      AND A.ACPT_DT   <= V_ORD_DT
                      AND A.FSR_DTM = (SELECT MAX(FSR_DTM)
                                         FROM MSELMCNN
                                        WHERE HSP_TP_CD = A.HSP_TP_CD
--                                        AND EQUP_ID   = IN_KIOSK_ID --> 컬럼 반영 후 추가할 것
                                       )
                                       ;

                   EXCEPTION
                       WHEN OTHERS THEN
                       V_STF_NO := 'CCC0EMR';
                END;   
                
                BEGIN
                    IF LENGTH(IN_PT_NO) = 13 THEN                    
                        BEGIN
                            SELECT PT_NO
                              INTO V_PT_NO
                              FROM PCTPCPAM_DAMO A
                             WHERE DAMO.DEC_VARCHAR('HBIL', 'PCTPCPAM', 'RRN', SEC_RRN) = IN_PT_NO
                             ;                                                                    
                             EXCEPTION
                                 WHEN OTHERS THEN
                                     V_PT_NO := '';
                        END ; 
                    ELSE
                        BEGIN
                            SELECT PT_NO
                              INTO V_PT_NO
                              FROM PCTPCPAM_DAMO A
                             WHERE PT_NO = IN_PT_NO
                             ;                            
                             EXCEPTION
                                 WHEN OTHERS THEN
                                     V_PT_NO := '';
                        END ; 
                    END IF;
                     
                    IF V_PT_NO = '' OR  V_PT_NO IS NULL THEN
                        V_PT_NO_YN := 'NO';
                    ELSE
                        V_PT_NO_YN := 'YES';
                    END IF;
                END ; 

                        
                IF V_PT_NO_YN = 'NO' THEN                
                    BEGIN   
                        OPEN WK_CURSOR FOR
                            SELECT '#KR0P#KR1N#KR2환자확인실패#KR3' 
                                   KIOSK_PATINFO
                              FROM DUAL
                              ;                             

                            OUT_CURSOR :=  WK_CURSOR ;
                    END ; 
                
                ELSE
                
                    BEGIN   
                        OPEN WK_CURSOR FOR
                            SELECT '#KR0P#KR1Y#KR2환자확인성공#KR3'
                                || '^^^P' 
                                || '^PI' || A.PT_NO                                                      -- 환자번호
                                || '^PN' || A.PT_NM                                                      -- 환자이름
                                || '^PS' || A.SEX_TP_CD                                                  -- 성별
                                || '^PA' || XBIL.FT_PCT_AGE('AGEMONTH', SYSDATE, A.PT_BRDY_DT)           -- 나이
                                || '^P1' || SUBSTR(TO_CHAR(A.PT_BRDY_DT, 'YYYYMMDD'),3)                  -- 생년월일
                                || '^PB' || 'A'                                                          -- BA 장비 ID
                                || '^P3' || B.STF_NO                                                     -- 접수자ID
                                || '^P4' || B.KOR_SRNM_NM                                                -- 접수자명
                                || '^P5' || ''                                                           -- 감염코드 
                                
--                                || '^P6' || ''                                                           -- 금식여부       

                                || '^P6' || ( SELECT DECODE(COUNT(*), 0, '', '금식')
                                                FROM MOOOREXM
                                               WHERE 1=1  
                                                 AND HSP_TP_CD     = IN_HSP_TP_CD 
                                                 AND PT_NO         = V_PT_NO                                 
                                                 AND EXM_HOPE_DT   = V_ORD_DT
                                                 AND ORD_CD IN ('LCG09', 'LCG40', 'LCG28' )
                                            )                                                            -- 금식여부
                                    
                                || '^PC' || ( SELECT SUBSTR(PT_DTL_INF_CNTE,1,240)
                                                FROM MSELMPSD D
                                               WHERE 1=1  
                                                 AND HSP_TP_CD     = IN_HSP_TP_CD 
                                                 AND PT_PCPN_TP_CD = '4'
                                                 AND PT_NO         = IN_PT_NO                                 
                                                 AND INPT_SEQ      = (SELECT MAX(INPT_SEQ)
                                                                        FROM MSELMPSD
                                                                       WHERE 1=1 
                                                                         AND HSP_TP_CD     = D.HSP_TP_CD
                                                                         AND PT_PCPN_TP_CD = D.PT_PCPN_TP_CD
                                                                         AND PT_NO         = D.PT_NO                                 
                                                                     )
                                            )                                                            -- 접수코멘트

                                || '^PD' || DECODE(IN_HSP_TP_CD, '01', '학동'
                                                               , '02', '화순'
                                                               , '03', '빛고을'
                                                               , '04', '치과'                         
                                                  )
                                                 
                                  
                                --> 화순전남대일 경우에 특정 키오스트장비에서 전송될때 당일 환자에게 부여되는 번호 전달필요함.
                                --> 화순 2층의 특정 키오스트 번호 필요함 : 공통코드로  P^SW100 정보가 필요한 장비를 관리할 것.
--                                || 'P^SW100^' 

                                
                                || '^^^_P' 
                                KIOSK_PATINFO
                                 
                              FROM PCTPCPAM_DAMO A
                                 , CNLRRUSD      B 
                             WHERE A.PT_NO       = V_PT_NO
                               AND B.HSP_TP_CD   = IN_HSP_TP_CD
                               AND B.STF_NO      = V_STF_NO    
                               ;                             
                                 
                            OUT_CURSOR :=  WK_CURSOR;                            
            
                          --예외처리
                        EXCEPTION   
                             WHEN NO_DATA_FOUND THEN
                                  RAISE_APPLICATION_ERROR(-20553, 'PC_MSE_KIOSK_PATINFO_SELECT-환자정보 없습니다.') ;
                             WHEN OTHERS THEN
                                  RAISE_APPLICATION_ERROR(-20553, '환자정보 조회중 Error발생 PC_MSE_GNT_PATINFO_SELECT' || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
                    END ; 
                END IF; 

            END ; 
       
    END PC_MSE_KIOSK_PATINFO_SELECT;             
    
    
      

    /**********************************************************************************************
    *    서비스이름  : PC_MSE_KIOSK_SPCMINFO_SELECT
    *    최초 작성일 : 2021.11.29
    *    최초 작성자 : ezCaretech 홍승표
    *    DESCRIPTION : KOISK 검체정보 조회      
    *                  전남대 학동 - GNT/HEMM : 에너지움
    
    -----------------------------------------------------------------------------------------------
                       * 정보구분 프로토콜 설명--> T로 시작하는 구분자에 해당하는 정보만 전달하며, 없는 정보는 전달하지 않음.
                       * 검체정보     ^TS    Specimen
                                 ^TC    튜브코드
                                 ^TP     동일튜브출력갯수 (Default : 1)
                                 ^PF    TTT 출력 여부
                                 ^FC    MWT Tube Row 색상 변경 여부
                                 ^T1    처방부서
                                 ^T2    병동
                                 ^T3    튜브명칭(Slip)
                                 ^T4    검체번호
                                 ^T5    검사실명
                                  ^T6    검체코드
                                 ^T7    응급코드
                                 ^T8    감염코드
                                 ^T9    음영처리
                                 ^T10    병실
        
                                
    **********************************************************************************************/
    PROCEDURE PC_MSE_KIOSK_SPCMINFO_SELECT ( IN_HSP_TP_CD        IN      VARCHAR2                 -- 병원코드
                                           , IN_KIOSK_ID         IN      VARCHAR2                 -- 키오스크 ID
                                           , IN_PT_NO            IN      VARCHAR2                 -- 환자번호
                                           , OUT_CURSOR          OUT  RETURNCURSOR )
    IS
        --변수선언
        WK_CURSOR                 RETURNCURSOR ; 
        V_COUNT                   VARCHAR2(0100)  :=  '0';
        V_PT_NO_YN                VARCHAR2(0100)  :=  '';
        V_RPY_STS_CD              VARCHAR2(0100)  :=  '';
        V_ORD_ID_LIST             VARCHAR2(4000)  :=  '';
        
        V_KIOSK_PATINFO           VARCHAR2(1000)  :=  '';
        V_SPCM_LIST               VARCHAR2(4000)  :=  '';
        V_RET_SPCM_LIST           VARCHAR2(4000)  :=  '';

        V_STF_NO                  VARCHAR2(0020)  :=  '';
        V_ORD_DT                  VARCHAR2(0020)  :=  '';
        V_SPCM_NO                 VARCHAR2(0400)  :=  '';
        V_WAITNO                  VARCHAR2(0400)  :=  '';
        
        IO_ERR_YN                 VARCHAR(1)      := '';
        IO_ERR_MSG                VARCHAR(4000)   := '';
    
        V_PRGM_NM                 MSELMCED.LSH_PRGM_NM%TYPE       := 'PC_MSE_KIOSK_SPCMINFO_SELECT';
        V_IP_ADDR                 MSELMCED.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');

        BEGIN       
            BEGIN   
                    
                BEGIN
                    SELECT TO_CHAR(SYSDATE,'YYYYMMDD')
                      INTO V_ORD_DT
                      FROM DUAL;
                END;   
                
                -- 특정 KOISK 장비의 마지막 채혈자 정보
                BEGIN
                   SELECT FSR_STF_NO
                     INTO V_STF_NO
                     FROM MSELMCNN  A
                    WHERE 1=1
                      AND HSP_TP_CD = IN_HSP_TP_CD
                      AND ACPT_DT  <= V_ORD_DT
                      AND FSR_DTM = (SELECT MAX(FSR_DTM)
                                       FROM MSELMCNN
                                      WHERE HSP_TP_CD = A.HSP_TP_CD
--                                        AND EQUP_ID   = IN_KIOSK_ID --> 컬럼 반영 후 추가할 것
                                    )
                                    ;
                END;   
                                
                -- 환자번호 확인
                BEGIN   
                    SELECT COUNT(*)
                      INTO V_COUNT
                      FROM PCTPCPAM_DAMO A
                         , CNLRRUSD      B 
                     WHERE PT_NO       = IN_PT_NO
                       AND B.HSP_TP_CD = IN_HSP_TP_CD 
                       AND B.STF_NO    = V_STF_NO    
                     ;   
                    
                    IF V_COUNT = '0' THEN
                        V_PT_NO_YN := 'NO';
                    ELSE
                        V_PT_NO_YN := 'YES';
                    END IF;
                
                    IF V_PT_NO_YN = 'NO' THEN                
                        OPEN WK_CURSOR FOR
                            SELECT '#KR0R#KR1N#KR2자동채혈접수실패-환자정보및채혈자확인실패' 
                                   GNT_PATINFO
                              FROM DUAL
                              ;                             
    
                            OUT_CURSOR :=  WK_CURSOR ;
                        
                        RETURN;
                    END IF;
                    
                    BEGIN
                        SELECT '^^^P' 
                            || '^PI' || A.PT_NO                                                      -- 환자번호
                            || '^PN' || A.PT_NM                                                      -- 환자이름
                            || '^PS' || A.SEX_TP_CD                                                  -- 성별
                            || '^PA' || XBIL.FT_PCT_AGE('AGEMONTH', SYSDATE, A.PT_BRDY_DT)           -- 나이
                            || '^P1' || SUBSTR(TO_CHAR(A.PT_BRDY_DT, 'YYYYMMDD'),3)                  -- 생년월일
                            || '^PB' || 'A'                                                          -- BA 장비 ID
                            || '^P3' || B.STF_NO                                                     -- 접수자ID
                            || '^P4' || B.KOR_SRNM_NM                                                -- 접수자명
                            || '^P5' || ' ' 
                            || '^^^_P' 
                          INTO V_KIOSK_PATINFO                         
                          FROM PCTPCPAM_DAMO A
                             , CNLRRUSD      B 
                         WHERE PT_NO       = IN_PT_NO
                           AND B.HSP_TP_CD = IN_HSP_TP_CD 
                           AND B.STF_NO    = V_STF_NO    
                           ;                                                                               
                    END;                    
                END; 

                -- 수납 여부 확인
                BEGIN   
                    SELECT DECODE(COUNT(*), 0, 'Y', 'N')
                      INTO V_RPY_STS_CD
                      FROM MOOOREXM A
                     WHERE 1=1
                       AND A.HSP_TP_CD                   = IN_HSP_TP_CD
                       AND A.PT_NO                       = IN_PT_NO
                       AND TO_CHAR(A.ORD_DT, 'YYYYMMDD') = V_ORD_DT
                       AND A.EXM_PRGR_STS_CD             = 'X'
                       AND A.ORD_CTG_CD                  = 'CP'
                       AND A.ODDSC_TP_CD                 = 'C'
--                       AND A.PACT_TP_CD                  = 'O' 
                       AND A.RPY_STS_CD                  = 'N'
                       ;                        
                       
                    IF V_RPY_STS_CD = 'N' THEN                
                        OPEN WK_CURSOR FOR
                            SELECT '#KR0R#KR1R#KR2미수납#KR3' 
                                   KIOSK_SPCMINFO
                              FROM DUAL
                              ;                             
                              
                            OUT_CURSOR :=  WK_CURSOR ;
                            RETURN;
                    END IF; 
                END;                     
                
                -- 처방조회 확인
                BEGIN   
                    SELECT RTRIM(XMLAGG ( XMLELEMENT(A, ORD_ID || ',') ORDER BY A.ORD_ID).EXTRACT('//text()'), ',')
                      INTO V_ORD_ID_LIST
                      FROM MOOOREXM A
                     WHERE 1=1
                       AND A.HSP_TP_CD                   = IN_HSP_TP_CD
                       AND A.PT_NO                       = IN_PT_NO
                       AND TO_CHAR(A.ORD_DT, 'YYYYMMDD') = V_ORD_DT
                       AND A.EXM_PRGR_STS_CD             = 'X'
                       AND A.ORD_CTG_CD                  = 'CP'
                       AND A.ODDSC_TP_CD                 = 'C' 
                       AND A.EXM_RTN_REQ_DTM             IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                       AND NVL(A.PRN_ORD_YN, 'N')        = 'N'
                       
--                       AND A.PACT_TP_CD                  = 'O' 
                       AND A.RPY_STS_CD                  = 'Y'
                       ;                        
                       
                    IF V_ORD_ID_LIST = '' THEN                
                        OPEN WK_CURSOR FOR
                            SELECT '#KR0R#KR1R#KR2처방없음#KR3' 
                                   KIOSK_SPCMINFO
                              FROM DUAL
                              ;                             
                              
                            OUT_CURSOR :=  WK_CURSOR ;
                            RETURN;
                    END IF; 
                END;                     
                
--                RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || V_ORD_ID_LIST || '\' || V_SPCM_NO ) ;       

--                -- 채혈
--                BEGIN
--
--                    XSUP.PKG_MSE_LM_BLCL.KIOSK_BLCL( 
--                                                       IN_PT_NO                           --IN      VARCHAR2
--                                                     , V_ORD_ID_LIST                      --IN      VARCHAR2 -- ,로 구분하여 멀티로 처리 가능함. 예 : 150029260,150029263,150029262,150029261,150029258,150029256,150029259,150029257,150029267
--                                                     , 'AUTOB'                            --IN      VARCHAR2
--                                                     , IN_KIOSK_ID                        --IN      VARCHAR2
--                                                     , 'N'                                --IN      VARCHAR2
--                                                     
--                                                     , IN_HSP_TP_CD                       --IN      VARCHAR2
--                                                     , V_STF_NO                           --IN      VARCHAR2
--                                                     , V_PRGM_NM                          --IN      VARCHAR2
--                                                     , V_IP_ADDR                          --IN      VARCHAR2
--                                                                                
--                                                     , V_SPCM_NO                          --IN OUT  VARCHAR2
--                                                     , IO_ERR_YN                          --OUT     VARCHAR2
--                                                     , IO_ERR_MSG                         --OUT     VARCHAR2 
--                                                   );
--                               
--                    IF V_SPCM_NO IS NULL OR IO_ERR_YN = 'Y' THEN
--                        OPEN WK_CURSOR FOR
--                            SELECT '#KR0R#KR1R#KR2채혈실패#KR3' 
--                                   KIOSK_SPCMINFO
--                              FROM DUAL
--                              ;                             
--                              
--                            OUT_CURSOR :=  WK_CURSOR ;
--                            RETURN;
--                    END IF;
--    
--                END;                      
--                  
--                
--                -- Kiosk 대기번호 생성
--                BEGIN
--
--                    XSUP.PC_MSE_INS_KIOSK_WAITNO(      IN_HSP_TP_CD
--                                                     , IN_PT_NO   
--                                                     , 'AUTOB'
--                                                     , IN_KIOSK_ID
--                                                     , 'K'
--                                                     , 'N'
--                                                     , ''                                                     
--                                                     
--                                                     , '1'                                                     
--                                                     
--                                                     , V_STF_NO
--                                                     , V_PRGM_NM
--                                                     , V_IP_ADDR
--                                                                                
--                                                     , V_WAITNO
--                                                     , IO_ERR_YN
--                                                     , IO_ERR_MSG
--                                                   );
--                   
--                   
--                    IF V_WAITNO IS NULL OR IO_ERR_YN = 'Y' THEN
--                        OPEN WK_CURSOR FOR
--                            SELECT '#KR0R#KR1R#KR2처방없음-Kiosk대기번호#KR3' 
--                                   KIOSK_SPCMINFO
--                              FROM DUAL
--                              ;                             
--                              
--                            OUT_CURSOR :=  WK_CURSOR ;
--                            RETURN;
--                    END IF;
--                                                                                                                     
----                    RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID
----                                                   || '\' 
----                                                   || V_ORD_ID_LIST 
----                                                   || '\' 
----                                                   || V_SPCM_NO
----                                                   || '\' 
----                                                   || V_WAITNO
----                                                   || '\' 
----                                                   || INSTR(V_WAITNO, '/')
----                                                   || '\' 
----                                                   || SUBSTR(V_WAITNO, 1, INSTR(V_WAITNO, '/') -1)
----                                           ) ;        
--                                                   
----                    SUBSTR(IN_EXRS_CNTE, INSTR(IN_EXRS_CNTE, '/', 1, 5) + 1, INSTR(IN_EXRS_CNTE, '/', 1, 5) - 1)      
--                    
--                    UPDATE MSELMCED
--                       SET SPCM_NUM          = 1
--                         , OTPT_BLCL_WAIT_NO = SUBSTR(V_WAITNO, 1, INSTR(V_WAITNO, '/') -1)
--                     WHERE HSP_TP_CD         = IN_HSP_TP_CD 
--                       AND SPCM_NO           = V_SPCM_NO
--                       AND PT_NO             = IN_PT_NO
--                       ;    
--                               
--                END;                      
                
                

--                RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || V_ORD_ID_LIST || '\' || V_SPCM_NO ) ;        
                                         
                
                -- KIOSK 채혈정보 생성                                           
                BEGIN 
                    V_SPCM_LIST := '';
                    
                    FOR REC IN
                    (                               

                           SELECT    A.SPCM_PTHL_NO                                          TS                                                   
                                   , S.SPCM_CTNR_CD                                          TC
                                   , '1'                                                     TP
                                   , ''                                                      PF
                                   , ''                                                      FC
                                   , A.PT_HME_DEPT_CD                                        T1
                                   , A.PBSO_DEPT_CD                                          T2
                                   , D.WK_UNIT_CD                                            T3
                                   , ''                                                      T4
                                   , B.EXRM_EXM_CTG_CD                                       T5
                                   , A.TH1_SPCM_CD                                           T6
                                   , 'N'                                                     T7
                                   , ' '                                                     T8
                                   , (SELECT PRM_NO
                                          FROM ACPPRAAM
                                         WHERE HSP_TP_CD = A.HSP_TP_CD
                                           AND PT_NO = A.PT_NO AND SIHS_YN = 'Y'
                                       )                                                       T9
    
                                   , S.SPCM_CTNR_CD
                                     || ','
                                     || A.TH1_SPCM_CD
                                     || ','
                                     || D.WK_UNIT_CD                                         T10
    
                                   FROM MOOOREXM A
                                      , MSELMEBM B
                                      , MSELMPMD S
                                      , MSELMWDE D
                                  WHERE 1=1
                                    AND A.HSP_TP_CD                     = IN_HSP_TP_CD
                                    AND A.PT_NO                         = IN_PT_NO
                                    AND TO_CHAR(A.ORD_DT, 'YYYYMMDD')   = V_ORD_DT
                                    AND A.ORD_ID IN (
                                                    SELECT REGEXP_SUBSTR ( V_ORD_ID_LIST, '[^,]+', 1, LEVEL )
                                                      FROM DUAL
                                                   CONNECT BY LEVEL <= REGEXP_COUNT ( V_ORD_ID_LIST, ',' ) + 1
                                                   )
                                    
                                    AND A.EXM_PRGR_STS_CD               = 'X'
                                    AND A.ORD_CTG_CD                    = 'CP'
                                    AND A.ODDSC_TP_CD                   = 'C'
                                    AND A.EXM_RTN_REQ_DTM               IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                                    AND NVL(A.PRN_ORD_YN, 'N')          = 'N'
                                    
                                    AND A.ORD_CD                        = B.EXM_CD
                                    AND A.HSP_TP_CD                     = B.HSP_TP_CD
                                    AND A.ORD_CD      = S.EXM_CD
                                    AND A.TH1_SPCM_CD = S.SPCM_CD
                                    AND S.SPCM_CTNR_CD IS NOT NULL -- 검체용기가 없는 검사는 제외함.
    
                                    AND A.HSP_TP_CD  = D.HSP_TP_CD
                                    AND A.ORD_CD     = D.EXM_CD
                                    AND D.WCTG_TP_CD = '10'
    
                                  GROUP BY A.HSP_TP_CD
                                         , A.PT_NO
                                         , A.ORD_DT
                                         , B.EXRM_EXM_CTG_CD
                                         , A.SPCM_PTHL_NO
                                         , D.WK_UNIT_CD
                                         , A.TH1_SPCM_CD
                                         , S.SPCM_CTNR_CD
                                         , A.PBSO_DEPT_CD
                                         , A.PT_HME_DEPT_CD
                                         , A.PACT_TP_CD
                                             
    
    
    
                    
--                        SELECT   ''                                                      TS
--                               ,(SELECT SPCM_CTNR_CD 
--                                              FROM MSELMPMD 
--                                             WHERE HSP_TP_CD = A.HSP_TP_CD 
--                                               AND EXM_CD = A.ORD_CD)                    TC
--                               , '1'                                                     TP
--                               , ''                                                      PF
--                               , ''                                                      FC
--                               , A.PT_HME_DEPT_CD                                        T1
--                               , A.PBSO_DEPT_CD                                          T2
--                               , (SELECT WK_UNIT_CD 
--                                              FROM MSELMWDE 
--                                             WHERE HSP_TP_CD = A.HSP_TP_CD 
--                                               AND EXM_CD = A.ORD_CD 
--                                               AND WCTG_TP_CD = '10')                    T3
--                               , ''                                                      T4
--                               , (SELECT EXRM_EXM_CTG_CD 
--                                              FROM MSELMWDE 
--                                             WHERE HSP_TP_CD = A.HSP_TP_CD 
--                                               AND EXM_CD = A.ORD_CD 
--                                               AND WCTG_TP_CD = '10')                    T5 
--                               , A.TH1_SPCM_CD                                           T6 
--                               , 'N'                                                     T7
--                               , ' '                                                     T8
--                               , (SELECT PRM_NO 
--                                              FROM ACPPRAAM 
--                                             WHERE HSP_TP_CD = A.HSP_TP_CD 
--                                               AND PT_NO = A.PT_NO AND SIHS_YN = 'Y')    T9
--                               , (SELECT SPCM_CTNR_CD 
--                                              FROM MSELMPMD 
--                                             WHERE HSP_TP_CD = A.HSP_TP_CD 
--                                               AND EXM_CD = A.ORD_CD)                    
--                                         || ','      
--                                         || A.TH1_SPCM_CD                                
--                                         || ','      
--                                         || (SELECT WK_UNIT_CD 
--                                               FROM MSELMWDE 
--                                              WHERE HSP_TP_CD = A.HSP_TP_CD 
--                                                AND EXM_CD = A.ORD_CD 
--                                                AND WCTG_TP_CD = '10')                   T10
--                          FROM MOOOREXM A
--                         WHERE 1=1
--                           AND A.HSP_TP_CD                     = IN_HSP_TP_CD
--                           AND A.PT_NO                         = IN_PT_NO
--                           AND TO_CHAR(A.ORD_DT, 'YYYYMMDD')   = V_ORD_DT
--                           AND A.EXM_PRGR_STS_CD               = 'X'
--                           AND A.ORD_CTG_CD                    = 'CP'
--                           AND A.ODDSC_TP_CD                   = 'C'                           


                    )
                    LOOP

--                        -- 검체번호 채번
--                        BEGIN
--                            PC_MSE_CREATESPCMNO ( IN_HSP_TP_CD
--                                                , V_SPCM_NO
--                                                , IO_ERR_YN
--                                                , IO_ERR_MSG
--                                                );
--    
--                            IF IO_ERR_YN = 'Y' THEN
--                               RETURN;
--                            END IF;
--    
--                            EXCEPTION
--                                WHEN  OTHERS  THEN
--                                    IO_ERR_YN  := 'Y';
--                                    IO_ERR_MSG := '검체번호 생성함수 호출 시 에러 발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERR_MSG;
--                                     RETURN;
--                        END;                     



--                        RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || V_ORD_ID_LIST || '\' || V_SPCM_LIST  ) ;        
                   
                                           
                        -- KIOSK 채혈정보 조합                    
                        V_SPCM_LIST := V_SPCM_LIST 
                                       || '^SS' 
                                       || '^TS'  || REC.TS -- V_SPCM_NO -- REC.TS
                                       || '^TC'  || REC.TC
                                       || '^TP'  || REC.TP
                                       || '^PF'  || REC.PF
                                       || '^FC'  || REC.FC
                                       || '^T1'  || REC.T1
                                       || '^T2'  || REC.T2
                                       || '^T3'  || REC.T3
                                       || '^T4'  || REC.TS --  V_SPCM_NO -- REC.T4
                                       || '^T5'  || REC.T5
                                       || '^T6'  || REC.T6
                                       || '^T7'  || REC.T7
                                       || '^T8'  || REC.T8
                                       || '^T9'  || REC.T9
                                       || '^T10' || REC.T10
                                       || '^_SS'
                                           ;
                    END LOOP;
                    
                    BEGIN
                        V_RET_SPCM_LIST := '#KR0R#KR1Y#KR2자동채혈접수성공#KR3'
                                           || V_KIOSK_PATINFO
                                           || '^^^S'
                                           
                                           || V_SPCM_LIST
                                           
                                           || '^^^_S'
                                           ;
                                                
                        OPEN WK_CURSOR FOR
                            SELECT V_RET_SPCM_LIST
                                   KIOSK_SPCMINFO
                              FROM DUAL
                              ;                             
                              
                            OUT_CURSOR :=  WK_CURSOR ;
                    END ; 

                END ; 
                                                  

            END ;        
    END PC_MSE_KIOSK_SPCMINFO_SELECT;             

                                              
    



    
    /**********************************************************************************************
    *    서비스이름  : PC_MSE_KIOSK_AUTO_BLCL_CHECK
    *    최초 작성일 : 2021.11.29
    *    최초 작성자 : ezCaretech 홍승표
    *    DESCRIPTION : KOISK 자동채혈대 사용가능정보 체크
        **********************************************************************************************/
    PROCEDURE PC_MSE_KIOSK_AUTO_BLCL_CHECK ( IN_HSP_TP_CD         IN      VARCHAR2
                                           , IN_PT_NO             IN      VARCHAR2
                                           , IN_ORD_DT            IN      VARCHAR2    
                                           , IO_RESULT            IN OUT  VARCHAR2
                                           , IO_ERR_YN            IN OUT  VARCHAR2
                                           , IO_ERR_MSG           IN OUT  VARCHAR2
                                           ) 
                                           
    IS
                                                 
        V_PT_NO             VARCHAR2(4000) := '';
        V_SYSDATE           VARCHAR2(0050) := '';
        V_HH24MI            VARCHAR2(0050) := '';
        V_PRE_HOLDY_YN      VARCHAR2(0001) := '';
        V_HOLDY_YN          VARCHAR2(0001) := '';
        V_ORD_CD            VARCHAR2(4000) := '';  
        V_SPCM_CTNR_CD      VARCHAR2(4000) := '';  
        
        V_CSFM_CNT          NUMBER(0010)   := 0;  
        V_ORDR_CNT          NUMBER(0010)   := 0;  
        V_ORDR_CNT1         NUMBER(0010)   := 0;  
        V_ORDR_CNT2         NUMBER(0010)   := 0;  
                                               
    BEGIN       

        IO_RESULT        := '';
        
        BEGIN
            SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_01 */
                   TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                 , TO_CHAR(SYSDATE, 'HH24MI')
                 , (SELECT 'Y'
                      FROM CCCCCHOD
                     WHERE HDY_DT = TRUNC(SYSDATE) + 1
                       AND HSP_TP_CD = IN_HSP_TP_CD
                   )  -- 휴일전날구분                 
                 , XSUP.FT_MSE_GET_HOLDY_YN(SYSDATE, IN_HSP_TP_CD) -- 휴일구분
              INTO V_SYSDATE
                 , V_HH24MI
                 , V_PRE_HOLDY_YN
                 , V_HOLDY_YN
              FROM DUAL;

            EXCEPTION
                WHEN OTHERS THEN
                    IO_ERR_YN  := 'Y';
                    IO_ERR_MSG := '시스템 날자 조회 중 에러발생 ERRCODE = ' || SQLERRM;
                    IO_RESULT  := IO_ERR_MSG;
                    RETURN;
        END;              
        
     
                      
        -- 자동채혈 불가 항목 점검 - 검사항목 중복 발행
        BEGIN                                                            
            SELECT COUNT(*)                       
              INTO V_ORDR_CNT
              FROM (
                    SELECT A.ORD_CD, A.TH1_SPCM_CD
                         , COUNT(*)                      
                      FROM MOOOREXM A
                     WHERE 1=1
                       AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                       AND A.PT_NO                            = IN_PT_NO
                       AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
                       AND A.EXM_PRGR_STS_CD                  = 'X'
                       AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                       AND A.ODDSC_TP_CD                      = 'C'
                       AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                       AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                       AND (     A.RPY_STS_CD                 = 'Y'
                              OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                              OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                           )                                              
                       AND A.PACT_TP_CD                       = 'O'
                     GROUP BY A.ORD_CD, A.TH1_SPCM_CD
                     HAVING COUNT(*) > 1
                   )  
             ;

--            EXCEPTION
--                  WHEN NO_DATA_FOUND THEN
--                      GOTO NEXT_CHECEK_ORDER;
--                      
----                    IO_ERR_YN  := 'N';
----                    IO_ERR_MSG := '';
----                    IO_RESULT := IO_ERR_MSG;
--                    RETURN;  
                       
            IF V_ORDR_CNT > 0 THEN                    
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := '자동채혈불가항목점검-검사항목중복발행';     
                IO_RESULT  := IO_ERR_MSG;
                RETURN;   
            END IF;                    
        END;                  
        
        
        << NEXT_CHECEK_ORDER >>     
        
--        RAISE_APPLICATION_ERROR(-20001, '-----' || V_ORDR_CNT ) ;       
        
     
        -- 자동채혈 불가 항목 점검 - 유전자동의서 검사항목 확인
        BEGIN                                                                       
            SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_02 */
                   COUNT(*)
              INTO V_CSFM_CNT
              FROM MSELMEBV A
                 , MSELMEBM B
             WHERE A.RPRN_EXM_CD IN (   SELECT ORD_CD
                                          FROM MOOOREXM A
                                         WHERE 1=1
                                           AND A.HSP_TP_CD                        = DECODE(IN_HSP_TP_CD, '02', 'XX', IN_HSP_TP_CD) -- 2022.04.17 홍승표 : 화순은 유전자동의서 검사항목이라도 자동채혈 가능하도록 설정
                                           AND A.PT_NO                            = IN_PT_NO
                                           AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
                                           AND A.EXM_PRGR_STS_CD                  = 'X'
                                           AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                                           AND A.ODDSC_TP_CD                      = 'C'
                                           AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                                           AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                                           AND (     A.RPY_STS_CD                 = 'Y'
                                                  OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                                                  OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                                               )                                                                                         
                                           AND A.PACT_TP_CD                       = 'O' 
                                    )
               AND A.RPRN_EXM_CD  = B.EXM_CD
               AND A.HSP_TP_CD    = IN_HSP_TP_CD
               AND A.HSP_TP_CD    = B.HSP_TP_CD
               AND A.ORD_CTRL_CD IS NOT NULL
               AND 'Y' = (SELECT USE_YN FROM MSELMSID WHERE HSP_TP_CD = IN_HSP_TP_CD AND LCLS_COMN_CD = 'GENE' AND SCLS_COMN_CD = '001')             -- 유전자동의서 사용여부 체크기능
               ;
               
--            EXCEPTION
--                  WHEN NO_DATA_FOUND THEN
--                      GOTO NEXT_CHECEK_700_V_CSFM_CNT;
--                      
----                    IO_ERR_YN  := 'N';
----                    IO_ERR_MSG := '';
----                    IO_RESULT := IO_ERR_MSG;
--                    RETURN;  

            IF V_CSFM_CNT > 0 THEN                    
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := '자동채혈불가항목점검-유전자동의서검사항목존재';     
                IO_RESULT  := IO_ERR_MSG;
                RETURN;   
            END IF;                
        END;                                            
                                                                                       
    
        << NEXT_CHECEK_700_V_CSFM_CNT >>     
    

        -- 자동채혈 불가 항목 점검 - 자동채혈 가능시간대 체크
        BEGIN                        
        
            -- 평일2시이후채혈금지                
            IF V_HOLDY_YN != 'Y' AND V_HH24MI >= '1400' THEN      
                BEGIN                                                                  
                    SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_03 */
                           COUNT(*)
                      INTO V_ORDR_CNT                   
                      FROM MOOOREXM A
                     WHERE 1=1
                       AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                       AND A.PT_NO                            = IN_PT_NO
                       AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
                       AND A.EXM_PRGR_STS_CD                  = 'X'
                       AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                       AND A.ODDSC_TP_CD                      = 'C'
                       AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                       AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                       AND (     A.RPY_STS_CD                 = 'Y'
                              OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                              OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                           )                                              
                       AND A.PACT_TP_CD                       = 'O'             
                       AND A.ORD_CD IN ( SELECT SCLS_COMN_CD 
                                           FROM MSELMSID 
                                          WHERE HSP_TP_CD    = A.HSP_TP_CD 
                                            AND LCLS_COMN_CD = '700' 
                                            AND USE_YN       = 'Y'
                                            AND TH1_RMK_CNTE = '평일2시이후채혈금지'
                                        )
                       ;
                                        
--                    EXCEPTION
--                          WHEN NO_DATA_FOUND THEN
--                              GOTO NEXT_CHECEK_700_1400;
--                              
----                            IO_ERR_YN  := 'N';
----                            IO_ERR_MSG := '';
----                            IO_RESULT := IO_ERR_MSG;
--                            RETURN;  

                    IF V_ORDR_CNT > 0 THEN                    
                        IO_ERR_YN  := 'Y';
                        IO_ERR_MSG := '자동채혈불가항목점검-평일2시이후채혈금지';     
                        IO_RESULT  := IO_ERR_MSG;
                        RETURN;   
                    END IF;                    
                END;                                                            
            END IF;
            
               
            << NEXT_CHECEK_700_1400 >>                
            
                                           
            -- 평일4시이후채혈금지                
            IF V_HOLDY_YN != 'Y' AND V_HH24MI >= '1600' THEN      
                BEGIN                                                                  
                    SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_04 */                               
                           COUNT(*)
                      INTO V_ORDR_CNT                   
                      FROM MOOOREXM A
                     WHERE 1=1
                       AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                       AND A.PT_NO                            = IN_PT_NO
                       AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
                       AND A.EXM_PRGR_STS_CD                  = 'X'
                       AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                       AND A.ODDSC_TP_CD                      = 'C'
                       AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                       AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                       AND (     A.RPY_STS_CD                 = 'Y'
                              OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                              OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                           )                                              
                       AND A.PACT_TP_CD                       = 'O'             
                       AND A.ORD_CD IN ( SELECT SCLS_COMN_CD 
                                           FROM MSELMSID 
                                          WHERE HSP_TP_CD    = A.HSP_TP_CD 
                                            AND LCLS_COMN_CD = '700' 
                                            AND USE_YN       = 'Y'
                                            AND TH1_RMK_CNTE = '평일4시이후채혈금지'
                                        )
                       ;
                       
--                    EXCEPTION
--                          WHEN NO_DATA_FOUND THEN
--                              GOTO NEXT_CHECEK_700_1600;
--                              
----                            IO_ERR_YN  := 'N';
----                            IO_ERR_MSG := '';
----                            IO_RESULT := IO_ERR_MSG;
--                            RETURN;  

                    IF V_ORDR_CNT > 0 THEN                    
                        IO_ERR_YN  := 'Y';
                        IO_ERR_MSG := '자동채혈불가항목점검-평일4시이후채혈금지';     
                        IO_RESULT  := IO_ERR_MSG;
                        RETURN;   
                    END IF;                    
                END;                 
            END IF;
            

            << NEXT_CHECEK_700_1600 >>
        

           -- 휴일전날채혈금지
           IF V_PRE_HOLDY_YN = 'Y' THEN
                BEGIN                                                                  
                    SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_05 */                               
                           COUNT(*)
                      INTO V_ORDR_CNT                   
                      FROM MOOOREXM A
                     WHERE 1=1
                       AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                       AND A.PT_NO                            = IN_PT_NO
                       AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
                       AND A.EXM_PRGR_STS_CD                  = 'X'
                       AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                       AND A.ODDSC_TP_CD                      = 'C'
                       AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                       AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                       AND (     A.RPY_STS_CD                 = 'Y'
                              OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                              OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                           )                                              
                       AND A.PACT_TP_CD                       = 'O'             
                       AND A.ORD_CD IN ( SELECT SCLS_COMN_CD 
                                           FROM MSELMSID 
                                          WHERE HSP_TP_CD    = A.HSP_TP_CD 
                                            AND LCLS_COMN_CD = '700' 
                                            AND USE_YN       = 'Y'
                                            AND TH1_RMK_CNTE = '휴일전날채혈금지'
                                        )
                       ;

--                    EXCEPTION
--                          WHEN NO_DATA_FOUND THEN
--                              GOTO NEXT_CHECEK_700_HOLY;
--                              
----                            IO_ERR_YN  := 'N';
----                            IO_ERR_MSG := '';
----                            IO_RESULT := IO_ERR_MSG;
--                            RETURN;  

                    IF V_ORDR_CNT > 0 THEN                    
                        IO_ERR_YN  := 'Y';
                        IO_ERR_MSG := '자동채혈불가항목점검-휴일전날채혈금지';     
                        IO_RESULT  := IO_ERR_MSG;
                        RETURN;   
                    END IF;                    
                END;                 
           END IF;           
        END;                                            
    

        << NEXT_CHECEK_700_HOLY >>
                                   
    
        -- 자동채혈 불가 항목 점검 - 검체코드
        BEGIN                                                                  
            SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_06 */                               
                   COUNT(*)
              INTO V_ORDR_CNT                   
              FROM MOOOREXM A
             WHERE 1=1
               AND A.HSP_TP_CD                        = IN_HSP_TP_CD
               AND A.PT_NO                            = IN_PT_NO
               AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
               AND A.EXM_PRGR_STS_CD                  = 'X'
               AND A.ORD_CTG_CD                      IN ('CP', 'NM')
               AND A.ODDSC_TP_CD                      = 'C'
               AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
               AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
               AND (     A.RPY_STS_CD                 = 'Y'
                      OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                      OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                   )                                              
               AND A.PACT_TP_CD                       = 'O'             
               AND A.TH1_SPCM_CD IN ( SELECT SCLS_COMN_CD 
                                        FROM MSELMSID 
                                       WHERE HSP_TP_CD    = A.HSP_TP_CD 
                                         AND LCLS_COMN_CD = '701' 
                                         AND USE_YN       = 'Y'
                                    )
               ;
                                    
--            EXCEPTION
--                  WHEN NO_DATA_FOUND THEN
--                      GOTO NEXT_CHECEK_701;
--                      
----                    IO_ERR_YN  := 'N';
----                    IO_ERR_MSG := '';
----                    IO_RESULT := IO_ERR_MSG;
--                    RETURN;  

            IF V_ORDR_CNT > 0 THEN                    
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := '자동채혈불가항목점검-검체코드';     
                IO_RESULT  := IO_ERR_MSG;
                RETURN;   
            END IF;                    
        END;                 

        
        << NEXT_CHECEK_701 >>
             
        
        -- 자동채혈 불가 항목 점검 - 검체용기
        BEGIN     
           
            -- 702    자동채혈 불가항목-검체용기만 있다면 수동채혈(URINE...등 702에 해당하는 특정검체일 경우는 채혈실에서 채혈할 필요가 없기 때문에 자동채혈대로 올 필요가 없다.)
            SELECT COUNT(*)
              INTO V_ORDR_CNT
              FROM (    SELECT S.SPCM_CTNR_CD
                          FROM MOOOREXM A
                             , MSELMPMD S
                         WHERE 1=1
                           AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                           AND A.PT_NO                            = IN_PT_NO
                           AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
                           AND A.EXM_PRGR_STS_CD                  = 'X'
                           AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                           AND A.ODDSC_TP_CD                      = 'C'
                           AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                           AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                           AND (     A.RPY_STS_CD                 = 'Y'
                                  OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                                  OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                               )                                              
                           AND A.PACT_TP_CD                       = 'O'
                           AND A.HSP_TP_CD                        = S.HSP_TP_CD
                           AND A.ORD_CD                           = S.EXM_CD
                           AND A.TH1_SPCM_CD                      = S.SPCM_CD
                           AND S.SPCM_CTNR_CD NOT IN ( SELECT SCLS_COMN_CD
                                                         FROM MSELMSID
                                                        WHERE HSP_TP_CD    = A.HSP_TP_CD
                                                          AND LCLS_COMN_CD = '702'
                                                          AND USE_YN       = 'Y'
                                                     )
                         GROUP BY S.SPCM_CTNR_CD
                   )
              WHERE 1=1                      
             ;
                       
            IF V_ORDR_CNT = 0 THEN 
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := '자동채혈불가항목점검-검체용기';                -- 환자의 처방이 검체용기가 단독으로만(그것들끼라만이라도 수동)  발행되었을대만 수동접수, 다른 용기와 함께라면 자동으로 ..
                IO_RESULT  := IO_ERR_MSG;
                RETURN;   
            END IF;                    
        END;                 
          

        << NEXT_CHECEK >>
            
    
        -- 자동채혈 불가 항목 점검 - 핵의학검사/진단검사
        BEGIN
            SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_06 */                               
                   COUNT(*)
              INTO V_ORDR_CNT                   
              FROM MOOOREXM A
             WHERE 1=1
               AND A.HSP_TP_CD                        = IN_HSP_TP_CD
               AND A.PT_NO                            = IN_PT_NO
               AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
               AND A.EXM_PRGR_STS_CD                  = 'X'
               AND A.ORD_CTG_CD                      IN ('CP', 'NM')
               AND A.ODDSC_TP_CD                      = 'C'
               AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
               AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
               AND (     A.RPY_STS_CD                 = 'Y'
                      OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                      OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                   )                                              
               AND A.PACT_TP_CD                       = 'O'             
               AND A.ORD_CD IN      ( SELECT SCLS_COMN_CD 
                                        FROM MSELMSID 
                                       WHERE HSP_TP_CD    = A.HSP_TP_CD 
                                         AND LCLS_COMN_CD = '703' 
                                         AND USE_YN       = 'Y'
                                    )
               ;
               
--            EXCEPTION
--                  WHEN NO_DATA_FOUND THEN
--                    GOTO NEXT_CHECEK_703;
----                  
----                    IO_ERR_YN  := 'N';
----                    IO_ERR_MSG := '';
----                    IO_RESULT := IO_ERR_MSG;
--                    RETURN;  

            IF V_ORDR_CNT > 0 THEN                    
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := '자동채혈불가항목점검-핵의학검사/진단검사';     
                IO_RESULT  := IO_ERR_MSG;
                RETURN;   
            END IF;                    
        END;             


        << NEXT_CHECEK_703 >>

                           
        -- 자동채혈 불가 항목 점검 - CTC연구검체용기
        BEGIN
            SELECT S.SPCM_CTNR_CD
                 , COUNT(*)                       
              INTO V_SPCM_CTNR_CD
                 , V_ORDR_CNT
              FROM MOOOREXM A
                 , MSELMPMD S
             WHERE 1=1
               AND A.HSP_TP_CD                        = IN_HSP_TP_CD
               AND A.PT_NO                            = IN_PT_NO
               AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
               AND A.EXM_PRGR_STS_CD                  = 'X'
               AND A.ORD_CTG_CD                     IN ('CP', 'NM')
               AND A.ODDSC_TP_CD                      = 'C'
               AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
               AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
               AND (     A.RPY_STS_CD                 = 'Y'
                      OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                      OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                   )                                              
               AND A.PACT_TP_CD                       = 'O'
               AND A.ORD_SLIP_CTG_CD                  = 'CTC'
               AND A.HSP_TP_CD                        = S.HSP_TP_CD
               AND A.ORD_CD                           = S.EXM_CD
               AND A.TH1_SPCM_CD                      = S.SPCM_CD
               AND S.SPCM_CTNR_CD IN ( SELECT SCLS_COMN_CD
                                         FROM MSELMSID
                                        WHERE HSP_TP_CD    = A.HSP_TP_CD
                                          AND LCLS_COMN_CD = '704'
                                          AND USE_YN       = 'Y'
                                     )
             GROUP BY S.SPCM_CTNR_CD
             HAVING COUNT(*) > 1
             ;
             
            EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    GOTO NEXT_CHECEK_704;
                    
--                    IO_ERR_YN  := 'N';
--                    IO_ERR_MSG := '';
--                    IO_RESULT := IO_ERR_MSG;
                    RETURN;  

            IF V_ORDR_CNT > 0 THEN                    
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := '자동채혈불가항목점검-CTC연구검체용기';     
                IO_RESULT  := IO_ERR_MSG;
                RETURN;   
            END IF;                    
        END;                 
                             
                             
        << NEXT_CHECEK_704 >>
        

        -- 자동채혈 불가 항목 점검 - 진검검체용기
        BEGIN
            SELECT COUNT(*)                       
              INTO V_ORDR_CNT
              FROM MOOOREXM A
                 , MSELMPMD S
             WHERE 1=1
               AND A.HSP_TP_CD                        = IN_HSP_TP_CD
               AND A.PT_NO                            = IN_PT_NO
               AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
               AND A.EXM_PRGR_STS_CD                  = 'X'
               AND A.ORD_CTG_CD                      IN ('CP', 'NM')
               AND A.ODDSC_TP_CD                      = 'C'
               AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
               AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
               AND (     A.RPY_STS_CD                 = 'Y'
                      OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                      OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                   )                                              
               AND A.PACT_TP_CD                       = 'O'
               AND A.HSP_TP_CD                        = S.HSP_TP_CD
               AND A.ORD_CD                           = S.EXM_CD
               AND A.TH1_SPCM_CD                      = S.SPCM_CD
               AND S.SPCM_CTNR_CD IN ( SELECT SCLS_COMN_CD
                                         FROM MSELMSID
                                        WHERE HSP_TP_CD    = A.HSP_TP_CD
                                          AND LCLS_COMN_CD = '705'
                                          AND USE_YN       = 'Y'
                                     )
               ;
             
--            EXCEPTION
--                  WHEN NO_DATA_FOUND THEN
--                    GOTO NEXT_CHECEK_705;
--                    
----                    IO_ERR_YN  := 'N';
----                    IO_ERR_MSG := '';
----                    IO_RESULT := IO_ERR_MSG;
--                    RETURN;  

            IF V_ORDR_CNT > 0 THEN                    
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := '자동채혈불가항목점검-진검검체용기';     
                IO_RESULT  := IO_ERR_MSG;
                RETURN;   
            END IF;                    
        END;                 
                               

        << NEXT_CHECEK_705 >>

                 
        -- 자동채혈 불가 항목 점검 - 당일 기채혈내역 존재
        BEGIN                                          
                BEGIN                                                                  
                    SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_08 */                               
                           COUNT(*)
                      INTO V_ORDR_CNT                   
                      FROM MSELMCED A
                     WHERE 1=1
                       AND A.HSP_TP_CD                     = IN_HSP_TP_CD
                       AND A.PT_NO                         = IN_PT_NO    
                       AND TO_CHAR(A.BLCL_DTM, 'YYYYMMDD') = IN_ORD_DT
                       AND A.EXM_PRGR_STS_CD              IN ('B', 'C', 'D', 'E', 'N') 
                       ;                  
--
--                    EXCEPTION
--                            WHEN NO_DATA_FOUND THEN
--                                GOTO NEXT_CHECEK_EXIST;
--                                
----                            IO_ERR_YN  := 'N';
----                            IO_ERR_MSG := '';
----                            IO_RESULT := IO_ERR_MSG;
--                            RETURN;  

                    IF V_ORDR_CNT > 0 THEN                    
                        IO_ERR_YN  := 'Y';
                        IO_ERR_MSG := '자동채혈가능점검-당일기채혈내역존재';     
                        IO_RESULT  := IO_ERR_MSG;
                        RETURN;   
                    END IF;                    
                END;                 

        END;                                            
                   
            
        << NEXT_CHECEK_EXIST >>
                  
        
        -- 자동채혈 불가 항목 점검 - 주의사항 - 1.채혈실 검사주의사항, 2.환자주의사항
        BEGIN                                          
            -- 1.채혈실 검사주의사항
                BEGIN                                                                  
                    SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_09*/                               
                           COUNT(*)
                      INTO V_ORDR_CNT                   
                      FROM MOOOREXM A
                     WHERE 1=1
                       AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                       AND A.PT_NO                            = IN_PT_NO
                       AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
                       AND A.EXM_PRGR_STS_CD                  = 'X'
                       AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                       AND A.ODDSC_TP_CD                      = 'C'
                       AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                       AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                       AND (     A.RPY_STS_CD                 = 'Y'
                              OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                              OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                           )                                              
                       AND A.PACT_TP_CD                       = 'O'             
                       AND A.ORD_CD IN ( SELECT EXM_CD
                                           FROM MSELMEBM 
                                          WHERE HSP_TP_CD    = A.HSP_TP_CD 
                                            AND (EITM_CAPN_CNTE IS NOT NULL)
                                        )
                       ;
                                        
--                    EXCEPTION
--                          WHEN NO_DATA_FOUND THEN
--                              GOTO NEXT_CHECEK_EITM_CAPN_CNTE;
--                              
----                            IO_ERR_YN  := 'N';
----                            IO_ERR_MSG := '';
----                            IO_RESULT := IO_ERR_MSG;
--                            RETURN;  

                    IF V_ORDR_CNT > 0 THEN                    
                        IO_ERR_YN  := 'Y';
                        IO_ERR_MSG := '자동채혈가능점검-검사주의사항';     
                        IO_RESULT  := IO_ERR_MSG;
                        RETURN;   
                    END IF;                    
                END;                 

--                << NEXT_CHECEK_EITM_CAPN_CNTE >>
                

            -- 2.환자 주의사항
--                BEGIN                                                                  
--                    SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_10 */                               
--                           COUNT(*)
--                      INTO V_ORDR_CNT                   
--                      FROM MSELMPSD A
--                     WHERE 1=1
--                       AND A.HSP_TP_CD       = IN_HSP_TP_CD
--                       AND A.PT_NO           = IN_PT_NO
--                       AND A.PT_DTL_INF_CNTE IS NOT NULL
--                       ;
--                       
----                    EXCEPTION
----                          WHEN NO_DATA_FOUND THEN
----                              GOTO NEXT_CHECEK_MSELMPSD;
----                              
------                            IO_ERR_YN  := 'N';
------                            IO_ERR_MSG := '';
------                            IO_RESULT := IO_ERR_MSG;
----                            RETURN;  
--
--                    IF V_ORDR_CNT > 0 THEN                    
--                        IO_ERR_YN  := 'Y';
--                        IO_ERR_MSG := '자동채혈가능점검-환자주의사항';     
--                        IO_RESULT  := IO_ERR_MSG;
--                        RETURN;   
--                    END IF;                    
--                END;                 
        END;                                            

        
        << NEXT_CHECEK_MSELMPSD >>
                   
                   
        -- 자동채혈 불가 항목 점검 - 처방비고
        BEGIN                                          
                                                              
                SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_09*/                               
                       COUNT(*)
                  INTO V_ORDR_CNT                   
                  FROM MOOOREXM A
                 WHERE 1=1
                   AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                   AND A.PT_NO                            = IN_PT_NO
                   AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = IN_ORD_DT
                   AND A.EXM_PRGR_STS_CD                  = 'X'
                   AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                   AND A.ODDSC_TP_CD                      = 'C'
                   AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                   AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                   AND (     A.RPY_STS_CD                 = 'Y'
                          OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                          OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                       )                                              
                   AND A.PACT_TP_CD                       = 'O'             
                   AND A.ORD_RMK_CNTE IS NOT NULL
                   ;
                                    
--                    EXCEPTION
--                          WHEN NO_DATA_FOUND THEN
--                              GOTO NEXT_CHECEK_EITM_CAPN_CNTE;
--                              
----                            IO_ERR_YN  := 'N';
----                            IO_ERR_MSG := '';
----                            IO_RESULT := IO_ERR_MSG;
--                            RETURN;  

                IF V_ORDR_CNT > 0 THEN                    
                    IO_ERR_YN  := 'Y';
                    IO_ERR_MSG := '자동채혈가능점검-처방비고';     
                    IO_RESULT  := IO_ERR_MSG;
                    RETURN;   
                END IF;                    
 
        END;                                            
        
--                      
--        -- 자동채혈 불가 항목 점검 - 2개과 이상 진료과
--        BEGIN                                       
--            SELECT /*+ PC_MSE_KIOSK_AUTO_BLCL_CHECK_06 */                               
--                   COUNT(*)
--              INTO V_ORDR_CNT                   
--              FROM (  SELECT A.PT_HME_DEPT_CD
--                           , COUNT(*)
--                        FROM MOOOREXM A
--                       WHERE 1=1
--                         AND A.HSP_TP_CD                   = IN_HSP_TP_CD
--                         AND A.PT_NO                       = IN_PT_NO
--                         AND TO_CHAR(A.ORD_DT, 'YYYYMMDD') = IN_ORD_DT
--                          AND A.EXM_PRGR_STS_CD             = 'X'
--                         AND A.ORD_CTG_CD                  = 'CP'
--                         AND A.ODDSC_TP_CD                 = 'C' 
--                         AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
--                         AND A.PACT_TP_CD                  = 'O'
--                       GROUP BY A.PT_HME_DEPT_CD
--                   )
--                   ;
--                   
--            EXCEPTION
--                  WHEN NO_DATA_FOUND THEN
--                      GOTO NEXT_CHECEK_PT_HME_DEPT_CD;
--                      
----                    IO_ERR_YN  := 'N';
----                    IO_ERR_MSG := '';
----                    IO_RESULT := IO_ERR_MSG;
--                    RETURN;  
--
--            IF V_ORDR_CNT > 1 THEN                    
--                IO_ERR_YN  := 'Y';
--                IO_ERR_MSG := '자동채혈불가항목점검-2개과 이상 진료과';     
--                IO_RESULT  := IO_ERR_MSG;
--                RETURN;   
--            END IF;                    
--        END;             
--
--        
--        << NEXT_CHECEK_PT_HME_DEPT_CD >>
                          
                         
        IO_ERR_YN  := 'N';
        IO_ERR_MSG := '';     
        IO_RESULT  := '';
                       
    END PC_MSE_KIOSK_AUTO_BLCL_CHECK;             
    
    
    
            

    /**********************************************************************************************
    *    서비스이름  : PC_MSE_KIOSK_SPCMINFO_SELECT_UPDATE(더이상 사용하지 않고, 아래 PC_MSE_KIOSK_AUTO_BLCL 이거 사용함.) 
    *    최초 작성일 : 2021.11.29
    *    최초 작성자 : ezCaretech 홍승표
    *    DESCRIPTION : KOISK 검체정보 조회                                                  
    *                  전남대 학동 - GNT/HEMM : 에너지움
    
    -----------------------------------------------------------------------------------------------
                       * 정보구분 프로토콜 설명--> T로 시작하는 구분자에 해당하는 정보만 전달하며, 없는 정보는 전달하지 않음.
                       * 검체정보     ^TS    Specimen
                                 ^TC    튜브코드
                                 ^TP    동일튜브출력갯수 (Default : 1)
                                 ^PF    TTT 출력 여부
                                 ^FC    MWT Tube Row 색상 변경 여부
                                 ^T1    처방부서
                                 ^T2    병동
                                 ^T3    튜브명칭(Slip)
                                 ^T4    검체번호
                                 ^T5    검사실명
                                 ^T6    검체코드
                                 ^T7    응급코드
                                 ^T8    감염코드
                                 ^T9    음영처리
                                 ^T10   병실
        
                                
    **********************************************************************************************/
    PROCEDURE PC_MSE_KIOSK_SPCMINFO_SELECT_UPDATE (  IN_HSP_TP_CD          IN      VARCHAR2       -- 병원코드       -------> 더이상 사용하지 않고, 아래 PC_MSE_KIOSK_AUTO_BLCL 이거 사용함.) 
                                                   , IN_KIOSK_ID           IN      VARCHAR2       -- 키오스크 ID    -------> 더이상 사용하지 않고, 아래 PC_MSE_KIOSK_AUTO_BLCL 이거 사용함.) 
                                                   , IN_PT_NO              IN      VARCHAR2       -- 환자번호       -------> 더이상 사용하지 않고, 아래 PC_MSE_KIOSK_AUTO_BLCL 이거 사용함.) 
                                                   , IO_RESULT             IN OUT  VARCHAR2       -- 결과          -------> 더이상 사용하지 않고, 아래 PC_MSE_KIOSK_AUTO_BLCL 이거 사용함.) 
                                                   , IO_ERRYN              IN OUT  VARCHAR2       -- 오류여부       -------> 더이상 사용하지 않고, 아래 PC_MSE_KIOSK_AUTO_BLCL 이거 사용함.) 
                                                   , IO_ERRMSG             IN OUT  VARCHAR2       -- 오류메세지     -------> 더이상 사용하지 않고, 아래 PC_MSE_KIOSK_AUTO_BLCL 이거 사용함.) 
                                                  )                  
    IS    

        --변수선언
        V_EXCEPT_LHGX_CODE        VARCHAR2(0100)  :=  '';
        V_LHGX1                   VARCHAR2(0100)  :=  '';
        V_LHGX2                   VARCHAR2(0100)  :=  '';

        V_EXCEPT_LUGX_CODE        VARCHAR2(0100)  :=  '';
        V_LUGX1                   VARCHAR2(0100)  :=  '';
        V_LUGX2                   VARCHAR2(0100)  :=  '';
        
        V_COUNT                   VARCHAR2(0100)  :=  '0';
        V_PT_NO_YN                VARCHAR2(0100)  :=  '';
        V_RPY_STS_CD              VARCHAR2(0100)  :=  '';
        V_ORD_ID_LIST             VARCHAR2(4000)  :=  '';
        
        V_KIOSK_PATINFO           VARCHAR2(1000)  :=  '';
        V_SPCM_LIST               VARCHAR2(4000)  :=  '';
        V_SPCM_LIST_STR           VARCHAR2(4000)  :=  '';
        V_CNT                     NUMBER ;
        V_RET_SPCM_LIST           VARCHAR2(4000)  :=  '';

        V_STF_NO                  VARCHAR2(0020)  :=  '';
        V_ORD_DT                  VARCHAR2(0020)  :=  '';
        V_SPCM_NO                 VARCHAR2(0400)  :=  '';
        V_WAITNO                  VARCHAR2(0400)  :=  '';
        V_SPCMCNT                 NUMBER          := '0';
        
        IO_ERR_YN                 VARCHAR(1)      := '';
        IO_ERR_MSG                VARCHAR(4000)   := '';      
    
        V_PRGM_NM                 MSELMCED.LSH_PRGM_NM%TYPE       := 'PC_MSE_KIOSK_SPCMINFO_SELECT';
        V_IP_ADDR                 MSELMCED.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');


        BEGIN       
            BEGIN   

                IO_RESULT        := '';
                IO_ERRYN         := 'N';
                IO_ERRMSG        := '';
                    
                BEGIN
                    SELECT TO_CHAR(SYSDATE,'YYYYMMDD')
                      INTO V_ORD_DT
                      FROM DUAL;
                END;   
                

                -- 특정 KOISK 장비의 마지막 채혈자 정보
                BEGIN
                   SELECT A.FSR_STF_NO
                     INTO V_STF_NO
                     FROM MSELMCNN  A
                        , CNLRRUSD  B 
                    WHERE 1=1
                      AND B.HSP_TP_CD = A.HSP_TP_CD
                      AND B.STF_NO    = A.FSR_STF_NO
                      AND A.HSP_TP_CD = IN_HSP_TP_CD
                      AND A.ACPT_DT   <= V_ORD_DT
                      AND A.FSR_DTM = (SELECT MAX(FSR_DTM)
                                         FROM MSELMCNN
                                        WHERE HSP_TP_CD = A.HSP_TP_CD
--                                        AND EQUP_ID   = IN_KIOSK_ID --> 컬럼 반영 후 추가할 것
                                       )
                                       ;

                   EXCEPTION
                       WHEN OTHERS THEN
                       V_STF_NO := 'CCC0EMR';
                END;   
                                
                -- 환자번호 확인
                BEGIN   
                    SELECT COUNT(*)
                      INTO V_COUNT
                      FROM PCTPCPAM_DAMO A
                         , CNLRRUSD      B 
                     WHERE PT_NO       = IN_PT_NO
                       AND B.HSP_TP_CD = IN_HSP_TP_CD 
                       AND B.STF_NO    = V_STF_NO    
                     ;   
                    
                    IF V_COUNT = '0' THEN
                        V_PT_NO_YN := 'NO';
                    ELSE
                        V_PT_NO_YN := 'YES';
                    END IF;
                
                    IF V_PT_NO_YN = 'NO' THEN                
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2환자정보확인실패' || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF;
                    
                    BEGIN
                        SELECT '^^^P'
--                            || (SELECT TRIM(TH3_RMK_CNTE) -- 화순 외래 ROBO KIOSK장비 연동을 위한 특정값 셋팅 --> KIOSK 웹서비스용(사용 및 수정금지) 
--                                  FROM MSELMSID
--                                 WHERE HSP_TP_CD    = IN_HSP_TP_CD 
--                                   AND LCLS_COMN_CD = '802' 
--                                   AND SCLS_COMN_CD = IN_KIOSK_ID 
--                                   AND USE_YN       = 'Y'
--                               )
                            || '^PI' || A.PT_NO                                                      -- 환자번호
                            || '^PN' || A.PT_NM                                                      -- 환자이름
                            || '^PS' || A.SEX_TP_CD                                                  -- 성별
                            || '^PA' || XBIL.FT_PCT_AGE('AGEMONTH', SYSDATE, A.PT_BRDY_DT)           -- 나이
                            || '^P1' || SUBSTR(TO_CHAR(A.PT_BRDY_DT, 'YYYYMMDD'),3)                  -- 생년월일
                            || '^PB' || ''                                                           -- BA 장비 ID
                            || '^P3' || B.STF_NO                                                     -- 접수자ID
                            || '^P4' || B.KOR_SRNM_NM                                                -- 접수자명
                            || '^P5' || XSUP.FT_MSE_LM_INFECT_CLS(IN_HSP_TP_CD, IN_PT_NO)            -- 감염코드
                            || '^P7' || ''                                                           -- 진료과
                            || '^P8' || ''                                                           -- 진료일시
                            || '^P9' || ''                                                           -- 처방의사                            

                            || '^P6' || ( SELECT DECODE(COUNT(*), 0, '', '금식')
                                            FROM MOOOREXM
                                           WHERE 1=1  
                                             AND HSP_TP_CD     = IN_HSP_TP_CD 
                                             AND PT_NO         = IN_PT_NO                                 
                                             AND EXM_HOPE_DT   = V_ORD_DT
                                             AND ODDSC_TP_CD   = 'C'
                                             AND ORD_CD IN ('LCG09', 'LCG40', 'LCG28' )
                                        )                                                            -- 금식여부
                             
                            || '^PC' || ( SELECT SUBSTR(PT_DTL_INF_CNTE,1,240)
                                            FROM MSELMPSD D
                                           WHERE 1=1  
                                             AND HSP_TP_CD     = IN_HSP_TP_CD 
                                             AND PT_PCPN_TP_CD = '4'
                                             AND PT_NO         = IN_PT_NO                                 
                                             AND INPT_SEQ      = (SELECT MAX(INPT_SEQ)
                                                                    FROM MSELMPSD
                                                                   WHERE 1=1 
                                                                     AND HSP_TP_CD     = D.HSP_TP_CD
                                                                     AND PT_PCPN_TP_CD = D.PT_PCPN_TP_CD
                                                                     AND PT_NO         = D.PT_NO                                 
                                                                 )
                                        )                                                            -- 접수코멘트

                            || '^PD' || DECODE(IN_HSP_TP_CD, '01', '학동'
                                                           , '02', '화순'
                                                           , '03', '빛고을'
                                                           , '04', '치과'                         
                                              )
                            || '^PE' || A.ABOB_TP_CD || A.RHB_TP_CD                                  -- 혈액형
                            || '^PL' || 'K'                                                          -- 키오스크 연동 여부(K : 연동, L : 비연동) 
                            
                            || '^^^_P' 
                          INTO V_KIOSK_PATINFO                         
                          FROM PCTPCPAM_DAMO A
                             , CNLRRUSD      B 
                         WHERE PT_NO       = IN_PT_NO
                           AND B.HSP_TP_CD = IN_HSP_TP_CD 
                           AND B.STF_NO    = V_STF_NO    
                           ;                                                                               
                    END;                    
                END; 


--                RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || V_KIOSK_PATINFO || '\' || V_ORD_ID_LIST || '\' || V_RPY_STS_CD ) ;       
--
--                -- 외래 오더 확인
--                BEGIN   
--                    SELECT DECODE(COUNT(*), 0, 'N', 'Y')
--                      INTO V_RPY_STS_CD
--                      FROM MOOOREXM A
--                     WHERE 1=1
--                       AND A.HSP_TP_CD                   = IN_HSP_TP_CD
--                       AND A.PT_NO                       = IN_PT_NO
--                       AND TO_CHAR(A.ORD_DT, 'YYYYMMDD') = V_ORD_DT
--                       AND A.EXM_PRGR_STS_CD             = 'X'
--                       AND A.ORD_CTG_CD                  IN ('CP', 'NM')
--                       AND A.ODDSC_TP_CD                 = 'C'
--                       AND A.PACT_TP_CD                  = 'O' 
--                       AND XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) != 'Y'
--                       ;                        
--                       
--                    IF V_RPY_STS_CD != 'Y' THEN                
--                        IO_ERRYN  := 'Y';
--                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1R#KR2발행된외래처방이없습니다.-운영기' || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
--                        IO_RESULT := IO_ERRMSG;
--                        RETURN;
--                    END IF; 
--                END;                     
--                         

                -- 수납 여부 확인
                BEGIN   
                    SELECT DECODE(COUNT(*), 0, 'Y', 'N')
                      INTO V_RPY_STS_CD
                      FROM MOOOREXM A
                     WHERE 1=1
                       AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                       AND A.PT_NO                            = IN_PT_NO
                       AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                       AND A.EXM_PRGR_STS_CD                  = 'X'
                       AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                       AND A.ODDSC_TP_CD                      = 'C'
                       AND A.PACT_TP_CD                       = 'O' 
                       AND (     A.RPY_STS_CD                != 'Y'
                             AND A.RPY_STS_CD                != 'R'  
                             AND XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) != 'Y'
                             AND XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) != 'Y'
                           )
                       ;                        
                       
                    IF V_RPY_STS_CD != 'Y' THEN                
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1R#KR2미수납처방정보가존재합니다.-운영기' || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF; 
                END;                     
                         

                ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                --------------- V_ORD_ID_LIST 조합
                
                -- LHGX1, LHGX2 : 다음 2개 코드가 모두 처방이 발생하면, LHGX1은 제외한다.
                -- LUGX1, LUGX2 : 다음 2개 코드가 모두 처방이 발생하면, LUGX1은 제외한다.                
                BEGIN                                                                                    
                    V_EXCEPT_LHGX_CODE := 'XXXXX';                
                    BEGIN   
                        SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                          INTO V_LHGX1
                          FROM MOOOREXM A
                         WHERE 1=1
                           AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                           AND A.PT_NO                            = IN_PT_NO
                           AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                           AND A.EXM_PRGR_STS_CD                  = 'X'
                           AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                           AND A.ODDSC_TP_CD                      = 'C'
                           AND A.PACT_TP_CD                       = 'O' 
                           AND A.ORD_CD                           = 'LHGX1'                       
                           AND (     A.RPY_STS_CD                 = 'Y'
                                  OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                                  OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                               )
                           ;                                                   
                    END;                     

                    BEGIN   
                        SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                          INTO V_LHGX2
                          FROM MOOOREXM A
                         WHERE 1=1
                           AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                           AND A.PT_NO                            = IN_PT_NO
                           AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                           AND A.EXM_PRGR_STS_CD                  = 'X'
                           AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                           AND A.ODDSC_TP_CD                      = 'C'
                           AND A.PACT_TP_CD                       = 'O' 
                           AND A.ORD_CD                           = 'LHGX2'                       
                           AND (     A.RPY_STS_CD                 = 'Y'
                                  OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                                  OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                               )
                           ;                        
                    END;                     

                    IF V_LHGX1 = 'Y' AND V_LHGX2 = 'Y' THEN                
                        V_EXCEPT_LHGX_CODE := 'LHGX1';
                    END IF;     
                    
                    -------------------------------------------------------------------------------------------
                    V_EXCEPT_LUGX_CODE := 'XXXXX';                
                    BEGIN   
                        SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                          INTO V_LUGX1
                          FROM MOOOREXM A
                         WHERE 1=1
                           AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                           AND A.PT_NO                            = IN_PT_NO
                           AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                           AND A.EXM_PRGR_STS_CD                  = 'X'
                           AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                           AND A.ODDSC_TP_CD                      = 'C'
                           AND A.PACT_TP_CD                       = 'O' 
                           AND A.ORD_CD                           = 'LUGX1'                       
                           AND (     A.RPY_STS_CD                 = 'Y'
                                  OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                                  OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                               )
                           ;                                                   
                    END;                     

                    BEGIN   
                        SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                          INTO V_LUGX2
                          FROM MOOOREXM A
                         WHERE 1=1
                           AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                           AND A.PT_NO                            = IN_PT_NO
                           AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                           AND A.EXM_PRGR_STS_CD                  = 'X'
                           AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                           AND A.ODDSC_TP_CD                      = 'C'
                           AND A.PACT_TP_CD                       = 'O' 
                           AND A.ORD_CD                           = 'LUGX2'                       
                           AND (     A.RPY_STS_CD                 = 'Y'
                                  OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                                  OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                               )
                           ;                        
                    END;                     

                    IF V_LUGX1 = 'Y' AND V_LUGX2 = 'Y' THEN                
                        V_EXCEPT_LUGX_CODE := 'LUGX1';
                    END IF;                                           
                END;                                     


                -- 처방 수납여부 조회
                V_COUNT := 0;
                BEGIN   
                    SELECT RTRIM(XMLAGG ( XMLELEMENT(A, ORD_ID || ',') ORDER BY A.ORD_ID).EXTRACT('//text()'), ',')
                         , COUNT(*)
                      INTO V_ORD_ID_LIST
                         , V_COUNT
                      FROM MOOOREXM A
                     WHERE 1=1
                       AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                       AND A.PT_NO                            = IN_PT_NO
                       AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                       AND A.EXM_PRGR_STS_CD                  = 'X'
                       AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                       AND A.ODDSC_TP_CD                      = 'C'
                       AND A.PACT_TP_CD                       = 'O'
--                       AND A.ORD_SLIP_CTG_CD                 != 'LT'                                               
                       AND NOT (     (A.HSP_TP_CD = '01' AND A.ORD_SLIP_CTG_CD = 'LT')  -- 학동 : 현장검사 제외
                                  OR (A.HSP_TP_CD = '01' AND A.ORD_SLIP_CTG_CD = 'LT') 
                               )                               
                       AND (     A.RPY_STS_CD                 = 'Y'
                              OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                              OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                           )
                       AND A.ORD_CD                      != V_EXCEPT_LHGX_CODE
                       AND A.ORD_CD                      != V_EXCEPT_LUGX_CODE
                       ;                        
                     
                    IF V_ORD_ID_LIST = '' OR V_COUNT = 0 THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2자동채혈할수납된외래처방이존재하지않습니다.' || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF; 
                END;                                                                                                                                                                                                          
                                     
                --------------- V_ORD_ID_LIST 조합
                ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--                RAISE_APPLICATION_ERROR(-20001,  V_ORD_ID_LIST ) ;       


                -- 자동채혈가능여부 점검 - 각 항목별 점검
                BEGIN
                    PC_MSE_KIOSK_AUTO_BLCL_CHECK(   IN_HSP_TP_CD
                                                  , IN_PT_NO
                                                  , V_ORD_DT
                                                  , IO_RESULT
                                                  , IO_ERR_YN
                                                  , IO_ERR_MSG
                                                );
                                                   
                    IF IO_ERR_YN = 'Y' THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2' || IO_RESULT || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF;
                END;                      



--                RAISE_APPLICATION_ERROR(-20001, '자동채혈가능여부 점검 - 각 항목별 점검- 이후 ' || '---' ||  IO_RESULT ||  '---' ||  IO_ERR_MSG) ;       


                                          
                -- 채혈
                BEGIN

                    XSUP.PKG_MSE_LM_BLCL.KIOSK_BLCL( 
                                                       IN_PT_NO                           --IN      VARCHAR2
                                                     , V_ORD_ID_LIST                      --IN      VARCHAR2 -- ,로 구분하여 멀티로 처리 가능함. 예 : 150029260,150029263,150029262,150029261,150029258,150029256,150029259,150029257,150029267
                                                     , 'AUTOB'                            --IN      VARCHAR2
                                                     , V_STF_NO                           --IN      VARCHAR2
                                                     , 'N'                                --IN      VARCHAR2
                                                     
                                                     , IN_HSP_TP_CD                       --IN      VARCHAR2
                                                     , V_STF_NO                           --IN      VARCHAR2
                                                     , V_PRGM_NM                          --IN      VARCHAR2
                                                     , V_IP_ADDR                          --IN      VARCHAR2
                                                                                
                                                     , V_SPCM_NO                          --IN OUT  VARCHAR2
                                                     , IO_ERR_YN                          --OUT     VARCHAR2
                                                     , IO_ERR_MSG                         --OUT     VARCHAR2 
                                                   );

--                    RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || IO_ERR_YN ) ;       
                
                    IF V_SPCM_NO IS NULL OR IO_ERR_YN = 'Y' THEN
                        IF TO_CHAR(SQLCODE) = '0' THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2채혈완료된처방입니다.-' || V_SPCM_NO || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                            IO_RESULT := IO_ERRMSG;
                            RETURN;
                        END IF;
                                   
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2채혈실패' || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF;
    
                END;                      

                

--                RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || V_KIOSK_PATINFO || '\' || V_ORD_ID_LIST || '\' || V_SPCM_NO ) ;       
                
                
                -- Kiosk 대기번호 생성 --> 키오스크에서는 사용하지 않음.
                BEGIN

                    XSUP.PC_MSE_INS_KIOSK_WAITNO(      IN_HSP_TP_CD
                                                     , IN_PT_NO   
                                                     , 'AUTOB'
                                                     , V_STF_NO
                                                     , 'K'
                                                     , 'N'
                                                     , ''                                                     
                                                     
                                                     , '1'                                                     
                                                     
                                                     , V_STF_NO
                                                     , V_PRGM_NM
                                                     , V_IP_ADDR
                                                                                
                                                     , V_WAITNO
                                                     , IO_ERR_YN
                                                     , IO_ERR_MSG
                                                   );
                   
                   
                    IF V_WAITNO IS NULL OR IO_ERR_YN = 'Y' THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2Kiosk대기번호생성실패' || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF;
                                                                                                                     
--
--                    RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID
--                                                   || '\' 
--                                                   || V_ORD_ID_LIST 
--                                                   || '\' 
--                                                   || V_SPCM_NO
--                                                   || '\' 
--                                                   || V_WAITNO
--                                                   || '\' 
--                                                   || INSTR(V_WAITNO, '/')
--                                                   || '\' 
--                                                   || SUBSTR(V_WAITNO, 1, INSTR(V_WAITNO, '/') -1)
--                                           ) ;        
--                                                   

--                    SUBSTR(IN_EXRS_CNTE, INSTR(IN_EXRS_CNTE, '/', 1, 5) + 1, INSTR(IN_EXRS_CNTE, '/', 1, 5) - 1)      
                                                       

                    BEGIN
                
                            FOR REC IN ( SELECT /* PKG_MSE_LM_BLCL.KIOSK_BLCL */
                                                A.SPCM_NO  SPCM_NO
                                           FROM MSELMCED A
                                          WHERE 1=1
                                            AND A.HSP_TP_CD = IN_HSP_TP_CD
                                            AND A.SPCM_NO IN (SELECT REGEXP_SUBSTR ( V_SPCM_NO, '[^,]+', 1, LEVEL )
                                                               FROM DUAL
                                                            CONNECT BY LEVEL <= REGEXP_COUNT ( V_SPCM_NO, ',' ) + 1
                                                            )   
                                          ORDER BY A.SPCM_NO 
                                       )
                            LOOP
            
                                BEGIN

                                    UPDATE MSELMCED
                                       SET SPCM_NUM          = 1
                                         , OTPT_BLCL_WAIT_NO = SUBSTR(V_WAITNO, 1, INSTR(V_WAITNO, '/') -1)
                                                                                                           
                                         , BRCD_PRNT_YN      = 'Y'         -- 바코드 출력여부 --> 키오스크
                                         , BLCL_PLC_CD       = 'AUTOK'     -- 자동채혈대확인  --> 키오스크

                                         , LSH_DTM           = SYSDATE
                                         , LSH_PRGM_NM       = 'KIOSK_AUTO_BLCL' 
                                         , LSH_IP_ADDR       = SYS_CONTEXT('USERENV','IP_ADDRESS') 
                                     WHERE HSP_TP_CD         = IN_HSP_TP_CD 
                                       AND SPCM_NO           = REC.SPCM_NO
                                       AND PT_NO             = IN_PT_NO
                                       ;    
                                               
--                                    
--                                    UPDATE MSELMCED
--                                       SET BRCD_PRNT_YN      = 'N'
--                        --                 , EXRM_EXM_CTG_CD   = 'XXX'
--                                         , BLCL_PLC_CD       = IN_BL_PLACE
--                                         , SPCM_NUM          = 1
--                                         , LSH_DTM           = SYSDATE
--                                         , LSH_PRGM_NM       = 'KIOSK_BLCL' 
--                                         , LSH_IP_ADDR       = SYS_CONTEXT('USERENV','IP_ADDRESS') 
--                                     WHERE SPCM_NO           = REC.SPCM_NO
--                                       AND HSP_TP_CD         = IN_HSP_TP_CD
--                                       ;
                                END;        
            
            
                            END LOOP;
                                    
                    END;        
                END;                      
                                          
                                  
                -- KIOSK 채혈정보 생성                                           
                BEGIN 

                    V_SPCM_LIST        := '';
                    V_SPCM_LIST_STR    := '';
                    V_CNT              := 0;
                                           
                                                                                                    
                    FOR REC IN (   SELECT    A.SPCM_PTHL_NO                                                                                                 TS -- 211227028876
                                           , S.SPCM_CTNR_CD                                                                                                 TC
                                           , XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_PTHL_NO, '2', A.HSP_TP_CD)                                                TP -- 검사정보관리-채혈라벨수 
                                           , ''                                                                                                             PF
                                           , ''                                                                                                             FC
                                           , SUBSTR(XMED.FT_MOO_DEPTNM(XSUP.FT_MSE_KIOSK_BUSEO_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO), '', A.HSP_TP_CD),1,5)     T1
--                                           , XSUP.FT_MSE_KIOSK_BUSEO_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO)                                                      T2  -- 병동
--                                           -- 입원이면 병동, 외래이면 처방 많은 부서
                                           , DECODE(A.PACT_TP_CD
                                                      , 'I', XSUP.FT_MSE_WARD_S(A.PT_NO, XBIL.FT_ACP_ACPT_DTE(A.HSP_TP_CD, A.PACT_ID, A.PACT_TP_CD ), 1, A.HSP_TP_CD)
                                                      ,      XSUP.FT_MSE_KIOSK_BUSEO_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO)
                                                   )                                                                                                        T2  -- 병동
                                           , XSUP.FT_MSE_KIOSK_SLIP_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO)                                                       T3
                                           , TO_NUMBER(SUBSTR(A.SPCM_PTHL_NO,7))                                                                            T4
                                           , C.EXM_CTG_ABBR_NM                                                                                              T5
                                           , A.TH1_SPCM_CD                                                                                                  T6
                                           , 'N'                                                                                                            T7
                                           , XSUP.FT_MSE_LM_INFECT_CLS(A.HSP_TP_CD, A.PT_NO)                                                                T8
                                           , S.SPCM_CTNR_CD
                                             || ','
                                             || A.TH1_SPCM_CD
                                             || ','
                                             || XSUP.FT_MSE_KIOSK_SLIP_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO)                                                    T9

--                                           , (SELECT PRM_NO
--                                                  FROM ACPPRAAM
--                                                 WHERE HSP_TP_CD = A.HSP_TP_CD
--                                                   AND PT_NO     = A.PT_NO 
--                                                   AND SIHS_YN   = 'Y'
--                                             )                                                                                                              T10
                                           , XSUP.FT_MSE_WARD_S(A.PT_NO, XBIL.FT_ACP_ACPT_DTE(A.HSP_TP_CD, A.PACT_ID, A.PACT_TP_CD ), 2, A.HSP_TP_CD)       T10 -- 병실

                                           FROM MOOOREXM A
                                              , MSELMEBM B
                                              , MSELMPMD S
                                              , MSELMWDE D
                                              , MSELMCTC C
                                          WHERE 1=1        
                                            AND A.HSP_TP_CD                     = IN_HSP_TP_CD
                                            AND A.PT_NO                         = IN_PT_NO
                                            AND A.ORD_ID IN (
                                                            SELECT REGEXP_SUBSTR ( V_ORD_ID_LIST, '[^,]+', 1, LEVEL )
                                                              FROM DUAL
                                                           CONNECT BY LEVEL <= REGEXP_COUNT ( V_ORD_ID_LIST, ',' ) + 1
                                                           )
                                            
                                            AND A.EXM_PRGR_STS_CD               = 'B'
                                            AND A.ORD_CTG_CD                   IN ('CP', 'NM')
                                            AND A.ODDSC_TP_CD                   = 'C'
                                            
                                            AND A.HSP_TP_CD                     = B.HSP_TP_CD
                                            AND A.ORD_CD                        = B.EXM_CD
                                            AND A.HSP_TP_CD                     = S.HSP_TP_CD
                                            AND A.ORD_CD                        = S.EXM_CD
                                            AND A.TH1_SPCM_CD                   = S.SPCM_CD
                                            AND S.SPCM_CTNR_CD IS NOT NULL -- 검체용기가 없는 검사는 제외함.
            
                                            AND A.HSP_TP_CD                     = D.HSP_TP_CD
                                            AND A.ORD_CD                        = D.EXM_CD
                                            AND D.WCTG_TP_CD                    = '10'
            
                                            AND A.HSP_TP_CD                     = C.HSP_TP_CD
                                            AND B.EXRM_EXM_CTG_CD               = C.EXM_CTG_CD

                                          GROUP BY A.HSP_TP_CD
                                                 , A.PT_NO
                                                 , A.EXM_HOPE_DT
                                                 , C.EXM_CTG_ABBR_NM
                                                 , A.SPCM_PTHL_NO
                                                 , A.TH1_SPCM_CD
                                                 , S.SPCM_CTNR_CD
                                                 , A.PACT_TP_CD
                                                 , A.PACT_ID
                                                                                
                                         
                                         
                               )
                    LOOP
                        
--                        BEGIN
                            
                        
--    
--    
--    --                        -- 검체번호 채번
--    --                        BEGIN
--    --                            PC_MSE_CREATESPCMNO ( IN_HSP_TP_CD
--    --                                                , V_SPCM_NO
--    --                                                , IO_ERR_YN
--    --                                                , IO_ERR_MSG
--    --                                                );
--    --    
--    --                            IF IO_ERR_YN = 'Y' THEN
--    --                               RETURN;
--    --                            END IF;
--    --    
--    --                            EXCEPTION
--    --                                WHEN  OTHERS  THEN
--    --                                    IO_ERR_YN  := 'Y';
--    --                                    IO_ERR_MSG := '검체번호 생성함수 호출 시 에러 발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERR_MSG;
--    --                                     RETURN;
--    --                        END;
--    --                        
--    
--    
--                         RAISE_APPLICATION_ERROR(-20001, 'DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD') ;       
--    
--    --                        RAISE_APPLICATION_ERROR(-20001, 
--    --                                    V_SPCM_LIST 
--    --                                       || '^SS' 
--    --                                       || '^TS'  || REC.TS -- V_SPCM_NO -- REC.TS
--    --                                       || '^TC'  || REC.TC
--    --                                       || '^TP'  || REC.TP
--    --                                       || '^PF'  || REC.PF
--    --                                       || '^FC'  || REC.FC
--    --                                       || '^T1'  || REC.T1
--    --                                       || '^T2'  || REC.T2
--    --                                       || '^T3'  || REC.T3
--    --                                       || '^T4'  || REC.TS --  V_SPCM_NO -- REC.T4
--    --                                       || '^T5'  || REC.T5
--    --                                       || '^T6'  || REC.T6
--    --                                       || '^T7'  || REC.T7
--    --                                       || '^T8'  || REC.T8
--    --                                       || '^T9'  || REC.T9
--    --                                       || '^T10' || REC.T10
--    --                                       || '^_SS'                        
--    --                                                ) ;       
--                                            
                                            
                            -- KIOSK 채혈정보 조합                    
                            V_SPCM_LIST := V_SPCM_LIST 
                                           || '^SS' 
                                           || '^TS'  || REC.TS -- V_SPCM_NO -- REC.TS
                                           || '^TC'  || REC.TC
                                           || '^TP'  || REC.TP
                                           || '^PF'  || REC.PF
                                           || '^FC'  || REC.FC
                                           || '^T1'  || REC.T1
                                           || '^T2'  || REC.T2
                                           || '^T3'  || REC.T3
                                           || '^T4'  || REC.T4 --  V_SPCM_NO -- REC.T4
                                           || '^T5'  || REC.T5
                                           || '^T6'  || REC.T6
                                           || '^T7'  || REC.T7
                                           || '^T8'  || REC.T8
                                           || '^T9'  || REC.T9
                                           || '^T10' || REC.T10
                                           || '^_SS'
                                            ;
                                            
--                        END;                      
                    
                        V_CNT := V_CNT + 1;
                    
                    END LOOP;               
                       

                    
                    BEGIN                    
                        
                        V_RET_SPCM_LIST :=    '#KR0R#KR1Y#KR2자동채혈접수성공#KR3'
                                           || V_KIOSK_PATINFO
                                           || '^^^S'
                                           
                                           || V_SPCM_LIST
                                           
                                           || '^^^_S'                                           
                                             
                                           ;
                                           
--                        RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || '' || '\' || V_CNT || '\' || V_RET_SPCM_LIST ) ;       
                                           
                        IO_ERRYN  := 'N';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || V_RET_SPCM_LIST || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END ; 

                END ; 
                                                  

            END ;        


    END PC_MSE_KIOSK_SPCMINFO_SELECT_UPDATE;             




    /**********************************************************************************************
    *    서비스이름  : PC_MSE_KIOSK_AUTO_BLCL
    *    최초 작성일 : 2022.01.20
    *    최초 작성자 : ezCaretech 홍승표
    *    DESCRIPTION : KOISK 검체정보 조회      
    *                  전남대 학동 - GNT/HEMM : 에너지움
    
    -----------------------------------------------------------------------------------------------
                       * 정보구분 프로토콜 설명--> T로 시작하는 구분자에 해당하는 정보만 전달하며, 없는 정보는 전달하지 않음.
                       * 검체정보     ^TS    Specimen
                                 ^TC    튜브코드
                                 ^TP    동일튜브출력갯수 (Default : 1)
                                 ^PF    TTT 출력 여부
                                 ^FC    MWT Tube Row 색상 변경 여부
                                 ^T1    처방부서
                                 ^T2    병동
                                 ^T3    튜브명칭(Slip)
                                 ^T4    검체번호
                                 ^T5    검사실명
                                 ^T6    검체코드
                                 ^T7    응급코드
                                 ^T8    감염코드
                                 ^T9    음영처리
                                 ^T10   병실
        
                                
    **********************************************************************************************/
    PROCEDURE PC_MSE_KIOSK_AUTO_BLCL (   IN_HSP_TP_CD          IN      VARCHAR2       -- 병원코드
                                       , IN_EQUP_CD            IN      VARCHAR2       -- 키오스크 ID
                                       , IN_PT_NO              IN      VARCHAR2       -- 환자번호
                                       , IO_RESULT             IN OUT  VARCHAR2       -- 결과
                                       , IO_ERRYN              IN OUT  VARCHAR2       -- 오류여부
                                       , IO_ERRMSG             IN OUT  VARCHAR2       -- 오류메세지
                                      )                  
    IS    

        --변수선언
        V_EXCEPT_LHGX_CODE        VARCHAR2(0100)  :=  '';
        V_LHGX1                   VARCHAR2(0100)  :=  '';
        V_LHGX2                   VARCHAR2(0100)  :=  '';

        V_EXCEPT_LUGX_CODE        VARCHAR2(0100)  :=  '';
        V_LUGX1                   VARCHAR2(0100)  :=  '';
        V_LUGX2                   VARCHAR2(0100)  :=  '';
        
        V_COUNT                   VARCHAR2(0100)  :=  '0';
        V_PT_NO_YN                VARCHAR2(0100)  :=  '';
        V_RPY_STS_CD              VARCHAR2(0100)  :=  '';
        V_ORD_ID_LIST             VARCHAR2(4000)  :=  '';
        
        V_TLA_YN                  VARCHAR2(0001)  :=  'N';                 
        V_KIOSK_PATINFO           VARCHAR2(1000)  :=  '';
        V_SPCM_LIST               VARCHAR2(4000)  :=  '';
        V_SPCM_LIST_STR           VARCHAR2(4000)  :=  '';
        V_CNT                     NUMBER ;
        V_RET_SPCM_LIST           VARCHAR2(4000)  :=  '';

        V_STF_NO                  VARCHAR2(0020)  :=  '';
        V_ORD_DT                  VARCHAR2(0020)  :=  '';
        V_SPCM_NO                 VARCHAR2(0400)  :=  '';
        V_WAITNO                  VARCHAR2(0400)  :=  '';
        V_SPCMCNT                 NUMBER          := '0';
        
        IO_ERR_YN                 VARCHAR(1)      := '';
        IO_ERR_MSG                VARCHAR(4000)   := '';      
    
        V_PRGM_NM                 MSELMCED.LSH_PRGM_NM%TYPE       := 'PC_MSE_KIOSK_AUTO_BLCL';
        V_IP_ADDR                 MSELMCED.LSH_IP_ADDR%TYPE       := SYS_CONTEXT('USERENV','IP_ADDRESS');

        -- KIOSK 장비별 ID
        IN_KIOSK_ID               VARCHAR2(50)   := IN_EQUP_CD;     
        
        BEGIN       
            BEGIN   

                IO_RESULT        := '';
                IO_ERRYN         := 'N';
                IO_ERRMSG        := '';
                    
                BEGIN
                    SELECT TO_CHAR(SYSDATE,'YYYYMMDD')
                      INTO V_ORD_DT
                      FROM DUAL;
                END;   
                
--                RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || V_KIOSK_PATINFO || '\' || V_ORD_ID_LIST || '\' || V_RPY_STS_CD ) ;       
--
--                -- 외래 오더 확인
--                BEGIN   
--                    SELECT DECODE(COUNT(*), 0, 'N', 'Y')
--                      INTO V_RPY_STS_CD
--                      FROM MOOOREXM A
--                     WHERE 1=1
--                       AND A.HSP_TP_CD                        = IN_HSP_TP_CD
--                       AND A.PT_NO                            = IN_PT_NO
--                       AND TO_CHAR(A.ORD_DT, 'YYYYMMDD')      = V_ORD_DT
--                       AND A.EXM_PRGR_STS_CD                  = 'X'
--                       AND A.ORD_CTG_CD                       IN ('CP', 'NM')
--                       AND A.ODDSC_TP_CD                      = 'C'
--                       AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
--                       AND A.PACT_TP_CD                       = 'O' 
--                       AND XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) != 'Y'
--                       ;                        
--                       
--                    IF V_RPY_STS_CD != 'Y' THEN                
--                        IO_ERRYN  := 'Y';
--                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1R#KR2발행된외래처방이없습니다.-운영기' || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
--                        IO_RESULT := IO_ERRMSG;
--                        RETURN;
--                    END IF; 
--                END;                     
--                         

                -- 수납 여부 확인
                BEGIN   
                    SELECT DECODE(COUNT(*), 0, 'Y', 'N')
                      INTO V_RPY_STS_CD
                      FROM MOOOREXM A
                     WHERE 1=1
                       AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                       AND A.PT_NO                            = IN_PT_NO
                       AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                       AND A.EXM_PRGR_STS_CD                  = 'X'
                       AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                       AND A.ODDSC_TP_CD                      = 'C'
                       AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                       AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                       AND A.PACT_TP_CD                       = 'O' 
                       AND (     A.RPY_STS_CD                != 'Y'
                             AND A.RPY_STS_CD                != 'R'   
                             AND XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) != 'Y'
                             AND XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) != 'Y'
                           )
                       ;                        
                       
                    IF V_RPY_STS_CD != 'Y' THEN                
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1R#KR2미수납처방정보가존재합니다.-운영기' || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF; 
                END;                     
                         

                ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                --------------- V_ORD_ID_LIST 조합
                
                -- LHGX1, LHGX2 : 다음 2개 코드가 모두 처방이 발생하면, LHGX1은 제외한다.
                -- LUGX1, LUGX2 : 다음 2개 코드가 모두 처방이 발생하면, LUGX1은 제외한다.                
                BEGIN                                                                                    
                    V_EXCEPT_LHGX_CODE := 'XXXXX';                
                    BEGIN   
                        SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                          INTO V_LHGX1
                          FROM MOOOREXM A
                         WHERE 1=1
                           AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                           AND A.PT_NO                            = IN_PT_NO
                           AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                           AND A.EXM_PRGR_STS_CD                  = 'X'
                           AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                           AND A.ODDSC_TP_CD                      = 'C'
                           AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                           AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                           AND A.PACT_TP_CD                       = 'O' 
                           AND A.ORD_CD                           = 'LHGX1'                       
                           ;                                                   
                    END;                     

                    BEGIN   
                        SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                          INTO V_LHGX2
                          FROM MOOOREXM A
                         WHERE 1=1
                           AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                           AND A.PT_NO                            = IN_PT_NO
                           AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                           AND A.EXM_PRGR_STS_CD                  = 'X'
                           AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                           AND A.ODDSC_TP_CD                      = 'C'
                           AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                           AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                           AND A.PACT_TP_CD                       = 'O' 
                           AND A.ORD_CD                           = 'LHGX2'                       
                           ;                        
                    END;                     

                    IF V_LHGX1 = 'Y' AND V_LHGX2 = 'Y' THEN                
                        V_EXCEPT_LHGX_CODE := 'LHGX1';
                    END IF;     
                    
                    -------------------------------------------------------------------------------------------
                    V_EXCEPT_LUGX_CODE := 'XXXXX';                
                    BEGIN   
                        SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                          INTO V_LUGX1
                          FROM MOOOREXM A
                         WHERE 1=1
                           AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                           AND A.PT_NO                            = IN_PT_NO
                           AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                           AND A.EXM_PRGR_STS_CD                  = 'X'
                           AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                           AND A.ODDSC_TP_CD                      = 'C'
                           AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                           AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                           AND A.PACT_TP_CD                       = 'O' 
                           AND A.ORD_CD                           = 'LUGX1'                       
                           ;                                                   
                    END;                     

                    BEGIN   
                        SELECT DECODE(COUNT(*), 0, 'N', 'Y')
                          INTO V_LUGX2
                          FROM MOOOREXM A
                         WHERE 1=1
                           AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                           AND A.PT_NO                            = IN_PT_NO
                           AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                           AND A.EXM_PRGR_STS_CD                  = 'X'
                           AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                           AND A.ODDSC_TP_CD                      = 'C'
                           AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                           AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                           AND A.PACT_TP_CD                       = 'O' 
                           AND A.ORD_CD                           = 'LUGX2'                       
                           ;                        
                    END;                     

                    IF V_LUGX1 = 'Y' AND V_LUGX2 = 'Y' THEN                
                        V_EXCEPT_LUGX_CODE := 'LUGX1';
                    END IF;                                           
                END;                     
                


                -- 처방 수납여부 조회
                V_COUNT := 0;
                BEGIN   
                    SELECT RTRIM(XMLAGG ( XMLELEMENT(A, ORD_ID || ',') ORDER BY A.ORD_ID).EXTRACT('//text()'), ',')
                         , COUNT(*)
                      INTO V_ORD_ID_LIST
                         , V_COUNT
                      FROM MOOOREXM A
                     WHERE 1=1
                       AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                       AND A.PT_NO                            = IN_PT_NO
                       AND TO_CHAR(A.EXM_HOPE_DT, 'YYYYMMDD') = V_ORD_DT
                       AND A.EXM_PRGR_STS_CD                  = 'X'
                       AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                       AND A.ODDSC_TP_CD                      = 'C'
                       AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                       AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                       AND A.PACT_TP_CD                       = 'O'
--                       AND A.ORD_SLIP_CTG_CD                 != 'LT'                                               
                       AND NOT (     (A.HSP_TP_CD = '01' AND A.ORD_SLIP_CTG_CD = 'LT')  -- 학동 : 현장검사 제외
                                  OR (A.HSP_TP_CD = '01' AND A.ORD_SLIP_CTG_CD = 'LT') 
                               )                               
                       AND (    A.RPY_STS_CD                  = 'Y' 
                             OR A.RPY_STS_CD                  = 'R' 
                             OR XBIL.FT_HIPASS_YN(A.PT_NO, A.HSP_TP_CD, SYSDATE, A.PACT_ID) = 'Y'
                             OR XMED.FT_MOO_DAY_WARD_YN(A.PT_NO, A.PACT_ID, A.HSP_TP_CD) = 'Y'
                           )
                       AND A.ORD_CD                      != V_EXCEPT_LHGX_CODE
                       AND A.ORD_CD                      != V_EXCEPT_LUGX_CODE
                       ;                        
                                            
                    IF V_ORD_ID_LIST = '' OR V_COUNT = 0 THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2자동채혈할수납된외래처방이존재하지않습니다.' || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF; 
                END;                                                                                                                                                                                                          
                       
                
                --------------- V_ORD_ID_LIST 조합
                ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                
                

--                RAISE_APPLICATION_ERROR(-20001,  V_ORD_ID_LIST ) ;       



                -- 자동채혈가능여부 점검 - 각 항목별 점검
                BEGIN
                    PC_MSE_KIOSK_AUTO_BLCL_CHECK(   IN_HSP_TP_CD
                                                  , IN_PT_NO
                                                  , V_ORD_DT
                                                  , IO_RESULT
                                                  , IO_ERR_YN
                                                  , IO_ERR_MSG
                                                );
                                                   
                    IF IO_ERR_YN = 'Y' THEN
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2' || IO_RESULT || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF;
                END;                      



--                RAISE_APPLICATION_ERROR(-20001, '자동채혈가능여부 점검 - 각 항목별 점검- 이후 ' || '---' ||  IO_RESULT ||  '---' ||  IO_ERR_MSG) ;       


                -- 특정 KOISK 장비의 마지막 채혈자 정보
                BEGIN
                   SELECT A.FSR_STF_NO
                     INTO V_STF_NO
                     FROM MSELMCNN  A
                        , CNLRRUSD  B 
                    WHERE 1=1
                      AND B.HSP_TP_CD = A.HSP_TP_CD
                      AND B.STF_NO    = A.FSR_STF_NO
                      AND A.HSP_TP_CD = IN_HSP_TP_CD
                      AND A.ACPT_DT  <= V_ORD_DT
                      AND A.FSR_DTM = (SELECT MAX(FSR_DTM)
                                         FROM MSELMCNN
                                        WHERE HSP_TP_CD = IN_HSP_TP_CD
                                          AND EQUP_ID   = IN_KIOSK_ID
                                          AND ROWNUM    = 1
                                      )
                                      ;

                   EXCEPTION
                       WHEN OTHERS THEN
                       V_STF_NO := 'CCC0EMR';
                END;   
                                
                -- 환자번호 확인
                BEGIN   
                    SELECT COUNT(*)
                      INTO V_COUNT
                      FROM PCTPCPAM_DAMO A
                         , CNLRRUSD      B 
                     WHERE PT_NO       = IN_PT_NO
                       AND B.HSP_TP_CD = IN_HSP_TP_CD 
                       AND B.STF_NO    = V_STF_NO    
                     ;   
                    
                    IF V_COUNT = '0' THEN
                        V_PT_NO_YN := 'NO';
                    ELSE
                        V_PT_NO_YN := 'YES';
                    END IF;
                
                    IF V_PT_NO_YN = 'NO' THEN                
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2환자정보확인실패' || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF;                         


                    -- Kiosk 대기번호 생성
                    XSUP.PC_MSE_INS_KIOSK_WAITNO(      IN_HSP_TP_CD
                                                     , IN_PT_NO   
                                                     , 'AUTOB'
                                                     , IN_KIOSK_ID
                                                     , 'K'
                                                     , 'N'
                                                     , ''                                                     
                                                     
                                                     , '1'                                                     
                                                     
                                                     , V_STF_NO
                                                     , V_PRGM_NM
                                                     , V_IP_ADDR
                                                                                
                                                     , V_WAITNO
                                                     , IO_ERR_YN
                                                     , IO_ERR_MSG
                                                   );
                   
                   
                    IF V_WAITNO IS NULL OR IO_ERR_YN = 'Y' THEN
                        IO_ERRYN  := 'Y';
--                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2Kiosk대기번호생성실패' || '-' || SQLERRM || '-' ||  '#KR3' || '/KIOSK_SPCMINFO';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2Kiosk대기번호생성실패' || '-' || IO_ERR_MSG || '-' || SQLERRM || '-' ||  '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF;
                    -- V_WAITNO : SUBSTR(V_WAITNO, 1, INSTR(V_WAITNO, '/') -1)
                    
                                                                                      
                    BEGIN
                        SELECT '^^^P' 
                            -- 화순 2층 로보만 SW 사용해야됨...........................................................................................
                            || DECODE( (SELECT TRIM(TH3_RMK_CNTE) -- 화순 외래 ROBO KIOSK장비 연동을 위한 특정값 셋팅 --> KIOSK 웹서비스용(사용 및 수정금지) 
                                          FROM MSELMSID
                                         WHERE HSP_TP_CD    = IN_HSP_TP_CD
                                           AND LCLS_COMN_CD = '802'
                                           AND SCLS_COMN_CD = IN_KIOSK_ID
                                           AND USE_YN       = 'Y'
                                        )
                                       , NULL, NULL
                                       , (SELECT '^SW'
                                                 || TO_NUMBER(SUBSTR(V_WAITNO, 1, INSTR(V_WAITNO, '/') -1)) --> 외래 키오스트는 7000번대로 사용함. 
--                                                 || TO_NUMBER(NVL(MAX(TO_NUMBER(WK_UNIT_CD)), 7000) + 1) --> 외래 키오스트는 7000번대로 사용함.
                                            FROM MSELMCNN 
                                           WHERE HSP_TP_CD  = IN_HSP_TP_CD
                                             AND ACPT_DT    = V_ORD_DT
                                             AND PT_NO      = IN_PT_NO
                                             AND WK_UNIT_CD > 7000 
                                             AND WK_UNIT_CD < 10000
                                               --AND EQUP_ID    = IN_KIOSK_ID
                                          ) 
                                     )

                            || '^PI' || A.PT_NO                                                      -- 환자번호
                            || '^PN' || A.PT_NM                                                      -- 환자이름
                            || '^PS' || A.SEX_TP_CD                                                  -- 성별
                            || '^PA' || XBIL.FT_PCT_AGE('AGEMONTH', SYSDATE, A.PT_BRDY_DT)           -- 나이
                            || '^P1' || SUBSTR(TO_CHAR(A.PT_BRDY_DT, 'YYYYMMDD'),3)                  -- 생년월일
                            || '^PB' || ''                                                           -- BA 장비 ID
                            || '^P3' || B.STF_NO                                                     -- 접수자ID
                            || '^P4' || B.KOR_SRNM_NM                                                -- 접수자명
                            || '^P5' || XSUP.FT_MSE_LM_INFECT_CLS(IN_HSP_TP_CD, IN_PT_NO)            -- 감염코드
                            || '^P7' || ''                                                           -- 진료과
                            || '^P8' || ''                                                           -- 진료일시
                            || '^P9' || ''                                                           -- 처방의사                            

                            || '^P6' || ( SELECT DECODE(COUNT(*), 0, '', '금식')
                                            FROM MOOOREXM
                                           WHERE 1=1  
                                             AND HSP_TP_CD                        = IN_HSP_TP_CD 
                                             AND PT_NO                            = IN_PT_NO                                 
                                             AND EXM_HOPE_DT                      = V_ORD_DT
                                             AND ODDSC_TP_CD                      = 'C'
                                             AND EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                                             AND NVL(PRN_ORD_YN, 'N')             = 'N'
                                             AND ORD_CD IN ('LCG09', 'LCG40', 'LCG28' )
                                        )                                                            -- 금식여부
                             
                            || '^PC' || ( SELECT SUBSTR(PT_DTL_INF_CNTE,1,240)
                                            FROM MSELMPSD D
                                           WHERE 1=1  
                                             AND HSP_TP_CD     = IN_HSP_TP_CD 
                                             AND PT_PCPN_TP_CD = '4'
                                             AND PT_NO         = IN_PT_NO                                 
                                             AND INPT_SEQ      = (SELECT MAX(INPT_SEQ)
                                                                    FROM MSELMPSD
                                                                   WHERE 1=1 
                                                                     AND HSP_TP_CD     = D.HSP_TP_CD
                                                                     AND PT_PCPN_TP_CD = D.PT_PCPN_TP_CD
                                                                     AND PT_NO         = D.PT_NO                                 
                                                                 )
                                        )                                                            -- 접수코멘트

                            || '^PD' || DECODE(IN_HSP_TP_CD, '01', '학동'
                                                           , '02', '화순'
                                                           , '03', '빛고을'
                                                           , '04', '치과'                         
                                              )
                            || '^PE' || A.ABOB_TP_CD || A.RHB_TP_CD                                  -- 혈액형
                            || '^PL' || 'K'                                                          -- 키오스크 연동 여부(K : 연동, L : 비연동) 
                            
                            || '^^^_P' 
                          INTO V_KIOSK_PATINFO                         
                          FROM PCTPCPAM_DAMO A
                             , CNLRRUSD      B 
                         WHERE PT_NO       = IN_PT_NO
                           AND B.HSP_TP_CD = IN_HSP_TP_CD 
                           AND B.STF_NO    = V_STF_NO    
                           ;                                                                               
                    END;                    
                END; 

                                          
                -- 채혈
                BEGIN

                    XSUP.PKG_MSE_LM_BLCL.KIOSK_BLCL( 
                                                       IN_PT_NO                           --IN      VARCHAR2
                                                     , V_ORD_ID_LIST                      --IN      VARCHAR2 -- ,로 구분하여 멀티로 처리 가능함. 예 : 150029260,150029263,150029262,150029261,150029258,150029256,150029259,150029257,150029267
                                                     , 'AUTOB'                            --IN      VARCHAR2
                                                     , IN_KIOSK_ID                        --IN      VARCHAR2
                                                     , 'N'                                --IN      VARCHAR2
                                                     
                                                     , IN_HSP_TP_CD                       --IN      VARCHAR2
                                                     , IN_KIOSK_ID                        --IN      VARCHAR2
                                                     , V_PRGM_NM                          --IN      VARCHAR2
                                                     , V_IP_ADDR                          --IN      VARCHAR2
                                                                                
                                                     , V_SPCM_NO                          --IN OUT  VARCHAR2
                                                     , IO_ERR_YN                          --OUT     VARCHAR2
                                                     , IO_ERR_MSG                         --OUT     VARCHAR2 
                                                   );

--                    RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || IO_ERR_YN ) ;       
                
                    IF V_SPCM_NO IS NULL OR IO_ERR_YN = 'Y' THEN
                        IF TO_CHAR(SQLCODE) = '0' THEN
                            IO_ERRYN  := 'Y';
                            IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2채혈완료된처방입니다.-' || V_SPCM_NO || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                            IO_RESULT := IO_ERRMSG;
                            RETURN;
                        END IF;
                                   
                        IO_ERRYN  := 'Y';
                        IO_ERRMSG := 'KIOSK_SPCMINFO' || '#KR0R#KR1N#KR2채혈실패' || '-' || SQLERRM || '-' || '#KR3' || '/KIOSK_SPCMINFO';
                        IO_RESULT := IO_ERRMSG;
                        RETURN;
                    END IF;
    
                END;                      

                

--                RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || V_KIOSK_PATINFO || '\' || V_ORD_ID_LIST || '\' || V_SPCM_NO ) ;       
                
                
                -- Kiosk 대기번호 업데이트
                BEGIN
--
--                    RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID
--                                                   || '\' 
--                                                   || V_ORD_ID_LIST 
--                                                   || '\' 
--                                                   || V_SPCM_NO
--                                                   || '\' 
--                                                   || V_WAITNO
--                                                   || '\' 
--                                                   || INSTR(V_WAITNO, '/')
--                                                   || '\' 
--                                                   || SUBSTR(V_WAITNO, 1, INSTR(V_WAITNO, '/') -1)
--                                           ) ;        
--                                                   

--                    SUBSTR(IN_EXRS_CNTE, INSTR(IN_EXRS_CNTE, '/', 1, 5) + 1, INSTR(IN_EXRS_CNTE, '/', 1, 5) - 1)      
                                                       

                    BEGIN
                
                            FOR REC IN ( SELECT /* PKG_MSE_LM_BLCL.KIOSK_BLCL */
                                                A.SPCM_NO  SPCM_NO
                                           FROM MSELMCED A
                                          WHERE 1=1
                                            AND A.HSP_TP_CD = IN_HSP_TP_CD
                                            AND A.SPCM_NO IN (SELECT REGEXP_SUBSTR ( V_SPCM_NO, '[^,]+', 1, LEVEL )
                                                               FROM DUAL
                                                            CONNECT BY LEVEL <= REGEXP_COUNT ( V_SPCM_NO, ',' ) + 1
                                                            )   
                                          ORDER BY A.SPCM_NO 
                                       )
                            LOOP
            
                                BEGIN

                                    UPDATE MSELMCED
                                       SET SPCM_NUM          = 1
                                         , OTPT_BLCL_WAIT_NO = SUBSTR(V_WAITNO, 1, INSTR(V_WAITNO, '/') -1)
                                                                                                           
                                         , BRCD_PRNT_YN      = 'Y'         -- 바코드 출력여부 --> 키오스크
                                         , BLCL_PLC_CD       = 'AUTOK'     -- 자동채혈대확인  --> 키오스크

                                         , LSH_DTM           = SYSDATE
                                         , LSH_PRGM_NM       = 'KIOSK_BLCL' 
                                         , LSH_IP_ADDR       = SYS_CONTEXT('USERENV','IP_ADDRESS') 
                                     WHERE HSP_TP_CD         = IN_HSP_TP_CD 
                                       AND SPCM_NO           = REC.SPCM_NO
                                       AND PT_NO             = IN_PT_NO
                                       ;    
                                               
--                                    
--                                    UPDATE MSELMCED
--                                       SET BRCD_PRNT_YN      = 'N'
--                        --                 , EXRM_EXM_CTG_CD   = 'XXX'
--                                         , BLCL_PLC_CD       = IN_BL_PLACE
--                                         , SPCM_NUM          = 1
--                                         , LSH_DTM           = SYSDATE
--                                         , LSH_PRGM_NM       = 'KIOSK_BLCL' 
--                                         , LSH_IP_ADDR       = SYS_CONTEXT('USERENV','IP_ADDRESS') 
--                                     WHERE SPCM_NO           = REC.SPCM_NO
--                                       AND HSP_TP_CD         = IN_HSP_TP_CD
--                                       ;
                                END;        
            
            
                            END LOOP;
                                    
                    END;        
                END;                                                                
                
                
--                RAISE_APPLICATION_ERROR(-20553, IN_HSP_TP_CD || ' - ' || V_SPCM_NO || ' - ' || V_TLA_YN || ' ERRCODE = ' || SQLCODE || SQLERRM) ;
                
                -- 2022.04.07 홍승표 : LCT통합검사실 기능 구현 관련 시작
                --                    우선 화순만 우선적용하여 테스트함. 학동에는 없는 프로세스여서, 추후 화순에서 문제없다고 판단되면 학동도 동일하게 아래 쿼리를 통합할 예정.
                IF IN_HSP_TP_CD = '02' THEN
                
                        -- KIOSK 채혈정보 생성                                           
                        BEGIN 
            
                                V_SPCM_LIST        := '';
                                V_SPCM_LIST_STR    := '';
                                V_CNT              := 0;                                               
                                                                                                            
                                FOR REC IN (
                                               SELECT    DISTINCT
                                                         A.SPCM_PTHL_NO                                                                                                                             TS -- 211227028876
                                                       , S.SPCM_CTNR_CD                                                                                                                             TC
                                                       , XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_PTHL_NO, '2', A.HSP_TP_CD)                                                                            TP -- 검사정보관리-채혈라벨수
                                                       , ''                                                                                                                                         PF
                                                       , ''                                                                                                                                         FC
                                                       , SUBSTR(XMED.FT_MOO_DEPTNM(XSUP.FT_MSE_KIOSK_BUSEO_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO), '', A.HSP_TP_CD),1,5)                                 T1
                                                       -- 입원이면 병동, 외래이면 처방 많은 부서
                                                       , DECODE(A.PACT_TP_CD
--                                                                  , 'I', XSUP.FT_MSE_WARD_S(A.PT_NO, XBIL.FT_ACP_ACPT_DTE(A.HSP_TP_CD, A.PACT_ID, A.PACT_TP_CD ), 1, A.HSP_TP_CD)
                                                                  , 'I', XSUP.FT_MSE_CLCTN_WARD(A.PT_NO, XBIL.FT_ACP_ACPT_DTE(A.HSP_TP_CD, A.PACT_ID, A.PACT_TP_CD ), 1, A.HSP_TP_CD, A.PACT_ID)
--                                                                  ,      XSUP.FT_MSE_KIOSK_BUSEO_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO)
                                                                  ,      '' -- 병동정보로 사용하기 때문에, 입원 이외는 빈값으로 사용한다.                                                                  
                                                               )                                                                                                                                    T2  -- 병동(현위치)
                                                       , DECODE(XSUP.FT_MSE_KIOSK_SLIP_LCT_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO), 'Y', 'LCT'
                                                                                                                                 , XSUP.FT_MSE_KIOSK_SLIP_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO))        T3
                                                       , TO_NUMBER(SUBSTR(A.SPCM_PTHL_NO,7))                                                                                                        T4
        --                                               , C.EXM_CTG_ABBR_NM                                                                                                                          T5 -- 검사실
                                                       , DECODE(XSUP.FT_MSE_KIOSK_SLIP_LCT_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO), 'Y', '통합검사'
                                                                                                                                 , C.EXM_CTG_ABBR_NM)                                               T5 -- 검사실
                                                       , A.TH1_SPCM_CD                                                                                                                              T6
                                                       , 'N'                                                                                                                                        T7
                                                       , XSUP.FT_MSE_LM_INFECT_CLS(A.HSP_TP_CD, A.PT_NO)                                                                                            T8
                                                       , S.SPCM_CTNR_CD
                                                         || ','
                                                         || A.TH1_SPCM_CD
                                                         || ','
                                                         || DECODE(XSUP.FT_MSE_KIOSK_SLIP_LCT_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO), 'Y', 'LCT'
                                                                                                                                    , XSUP.FT_MSE_KIOSK_SLIP_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO))      T9
--                                                       , XSUP.FT_MSE_WARD_S(A.PT_NO, XBIL.FT_ACP_ACPT_DTE(A.HSP_TP_CD, A.PACT_ID, A.PACT_TP_CD ), 2, A.HSP_TP_CD)                                    T10 -- 병실
                                                       , XSUP.FT_MSE_CLCTN_WARD(A.PT_NO, XBIL.FT_ACP_ACPT_DTE(A.HSP_TP_CD, A.PACT_ID, A.PACT_TP_CD ), 2, A.HSP_TP_CD, A.PACT_ID)                     T10 -- 병실(현위치)
                                                       , XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_PTHL_NO, '2', A.HSP_TP_CD)                                                                             T11 -- 검사정보관리-채혈라벨수(Robo 전용으로 요청함.)
        --                                               , C.EXM_CTG_CD                                                                                                                                T12 -- 검사분류(Robo 전용으로 요청함.)
                                                       , DECODE(XSUP.FT_MSE_KIOSK_SLIP_LCT_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO), 'Y', 'LCT'
                                                                                                                                 , C.EXM_CTG_CD)                                                     T12 -- 검사분류(Robo 전용으로 요청함.)
                                                       , XSUP.FT_MSE_KIOSK_BUSEO_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO)                                                                                   T13 -- T1의 진료과코드 
        
                                                   FROM MOOOREXM A
                                                      , MSELMEBM B
                                                      , MSELMPMD S
                                                      , MSELMWDE D
                                                      , MSELMCTC C
                                                  WHERE 1=1        
                                                    AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                                                    AND A.PT_NO                            = IN_PT_NO
                                                    AND A.ORD_ID IN (
                                                                    SELECT REGEXP_SUBSTR ( V_ORD_ID_LIST, '[^,]+', 1, LEVEL )
                                                                      FROM DUAL
                                                                   CONNECT BY LEVEL <= REGEXP_COUNT ( V_ORD_ID_LIST, ',' ) + 1
                                                                   )
                                                    
                                                    AND A.EXM_PRGR_STS_CD                  = 'B'
                                                    AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                                                    AND A.ODDSC_TP_CD                      = 'C'
                                                    AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                                                    AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                                                    
                                                    AND A.HSP_TP_CD                        = B.HSP_TP_CD
                                                    AND A.ORD_CD                           = B.EXM_CD
                                                    AND A.HSP_TP_CD                        = S.HSP_TP_CD
                                                    AND A.ORD_CD                           = S.EXM_CD
                                                    AND A.TH1_SPCM_CD                      = S.SPCM_CD
                                                    AND S.SPCM_CTNR_CD IS NOT NULL -- 검체용기가 없는 검사는 제외함.
                    
                                                    AND A.HSP_TP_CD                        = D.HSP_TP_CD
                                                    AND A.ORD_CD                           = D.EXM_CD
                                                    AND D.WCTG_TP_CD                       = '10'
                    
                                                    AND A.HSP_TP_CD                        = C.HSP_TP_CD
                                                    AND B.EXRM_EXM_CTG_CD                  = C.EXM_CTG_CD
        
                                                  GROUP BY A.HSP_TP_CD
                                                         , A.PT_NO
                                                         , A.EXM_HOPE_DT
        --                                                 , C.EXM_CTG_CD
        --                                                 , C.EXM_CTG_ABBR_NM
                                                         , DECODE(XSUP.FT_MSE_KIOSK_SLIP_LCT_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO), 'Y', 'LCT', C.EXM_CTG_CD)
                                                         , DECODE(XSUP.FT_MSE_KIOSK_SLIP_LCT_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO), 'Y', '통합검사', C.EXM_CTG_ABBR_NM)                                                 
                                                         , A.SPCM_PTHL_NO
                                                         , A.TH1_SPCM_CD
                                                         , S.SPCM_CTNR_CD
                                                         , A.PACT_TP_CD
                                                         , A.PACT_ID
                                                                                        
                                                 
                                                 
                                       )
                            LOOP
                                
                                    -- KIOSK 채혈정보 조합                    
                                    V_SPCM_LIST := V_SPCM_LIST 
                                                   || '^SS' 
                                                   || '^TS'  || REC.TS -- V_SPCM_NO -- REC.TS
                                                   || '^TC'  || REC.TC
                                                   || '^TP'  || REC.TP
                                                   || '^PF'  || REC.PF
                                                   || '^FC'  || REC.FC
                                                   || '^T1'  || REC.T1
                                                   || '^T2'  || REC.T2
                                                   || '^T3'  || REC.T3
                                                   || '^T4'  || REC.T4 --  V_SPCM_NO -- REC.T4
                                                   || '^T5'  || REC.T5
                                                   || '^T6'  || REC.T6
                                                   || '^T7'  || REC.T7
                                                   || '^T8'  || REC.T8
                                                   || '^T9'  || REC.T9
                                                   || '^T10' || REC.T10
                                                   || '^T11' || REC.T11
                                                   || '^T12' || REC.T12
                                                   || '^T13' || REC.T13                                           
                                                   || '^_SS'
                                                    ;
                                                    
                                V_CNT := V_CNT + 1;
                            
                            END LOOP;               
                               
        
                            
                            BEGIN                    
                                
                                V_RET_SPCM_LIST :=    '#KR0R#KR1Y#KR2자동채혈접수성공#KR3'
                                                   || V_KIOSK_PATINFO
                                                   || '^^^S'
                                                   
                                                   || V_SPCM_LIST
                                                   
                                                   || '^^^_S'                                           
                                                     
                                                   ;
                                                   
        --                        RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || '' || '\' || V_CNT || '\' || V_RET_SPCM_LIST ) ;       
                                                   
                                IO_ERRYN  := 'N';
                                IO_ERRMSG := 'KIOSK_SPCMINFO' || V_RET_SPCM_LIST || '/KIOSK_SPCMINFO';
                                IO_RESULT := IO_ERRMSG;
                                RETURN;
                            END ; 
        
                        END ; 
                        
                        
                                
                ELSE
                        
                                                          
                        -- KIOSK 채혈정보 생성                                           
                        BEGIN 
            
                                V_SPCM_LIST        := '';
                                V_SPCM_LIST_STR    := '';
                                V_CNT              := 0;                                                       
                                                                                                            
                                FOR REC IN (   SELECT    DISTINCT
                                                         A.SPCM_PTHL_NO                                                                                                                              TS -- 211227028876
                                                       , S.SPCM_CTNR_CD                                                                                                                              TC
                                                       , XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_PTHL_NO, '2', A.HSP_TP_CD)                                                                             TP -- 검사정보관리-채혈라벨수
                                                       , ''                                                                                                                                          PF
                                                       , ''                                                                                                                                          FC
                                                       , SUBSTR(XMED.FT_MOO_DEPTNM(XSUP.FT_MSE_KIOSK_BUSEO_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO), '', A.HSP_TP_CD),1,5)                                  T1
                                                       -- 입원이면 병동, 외래이면 처방 많은 부서
                                                       , DECODE(A.PACT_TP_CD
--                                                                  , 'I', XSUP.FT_MSE_WARD_S(A.PT_NO, XBIL.FT_ACP_ACPT_DTE(A.HSP_TP_CD, A.PACT_ID, A.PACT_TP_CD ), 1, A.HSP_TP_CD)
                                                                  , 'I', XSUP.FT_MSE_CLCTN_WARD(A.PT_NO, XBIL.FT_ACP_ACPT_DTE(A.HSP_TP_CD, A.PACT_ID, A.PACT_TP_CD ), 1, A.HSP_TP_CD, A.PACT_ID)
--                                                                  ,      XSUP.FT_MSE_KIOSK_BUSEO_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO)
                                                                  ,      '' -- 병동정보로 사용하기 때문에, 입원 이외는 빈값으로 사용한다.
                                                               )                                                                                                                                     T2  -- 병동
                                                       , XSUP.FT_MSE_KIOSK_SLIP_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO)                                                                                    T3
                                                       , TO_NUMBER(SUBSTR(A.SPCM_PTHL_NO,7))                                                                                                         T4
                                                       , C.EXM_CTG_ABBR_NM                                                                                                                           T5
                                                       , A.TH1_SPCM_CD                                                                                                                               T6
                                                       , 'N'                                                                                                                                         T7
                                                       , XSUP.FT_MSE_LM_INFECT_CLS(A.HSP_TP_CD, A.PT_NO)                                                                                             T8
                                                       , S.SPCM_CTNR_CD
                                                         || ','
                                                         || A.TH1_SPCM_CD
                                                         || ','
                                                         || XSUP.FT_MSE_KIOSK_SLIP_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO)                                                                                 T9
--                                                       , XSUP.FT_MSE_WARD_S(A.PT_NO, XBIL.FT_ACP_ACPT_DTE(A.HSP_TP_CD, A.PACT_ID, A.PACT_TP_CD ), 2, A.HSP_TP_CD)                                    T10 -- 병실
                                                       , XSUP.FT_MSE_CLCTN_WARD(A.PT_NO, XBIL.FT_ACP_ACPT_DTE(A.HSP_TP_CD, A.PACT_ID, A.PACT_TP_CD ), 2, A.HSP_TP_CD, A.PACT_ID)                     T10 -- 병실(현위치)
                                                       , XSUP.FT_MSE_LABELCNT(A.PT_NO, A.SPCM_PTHL_NO, '2', A.HSP_TP_CD)                                                                             T11 -- 검사정보관리-채혈라벨수(Robo 전용으로 요청함.)
                                                       , C.EXM_CTG_CD                                                                                                                                T12 -- 검사분류(Robo 전용으로 요청함.)
                                                       , XSUP.FT_MSE_KIOSK_BUSEO_INFO(A.HSP_TP_CD, A.SPCM_PTHL_NO)                                                                                   T13 -- T1의 진료과코드 
        
                                                   FROM MOOOREXM A
                                                      , MSELMEBM B
                                                      , MSELMPMD S
                                                      , MSELMWDE D
                                                      , MSELMCTC C
                                                  WHERE 1=1        
                                                    AND A.HSP_TP_CD                        = IN_HSP_TP_CD
                                                    AND A.PT_NO                            = IN_PT_NO
                                                    AND A.ORD_ID IN (
                                                                    SELECT REGEXP_SUBSTR ( V_ORD_ID_LIST, '[^,]+', 1, LEVEL )
                                                                      FROM DUAL
                                                                   CONNECT BY LEVEL <= REGEXP_COUNT ( V_ORD_ID_LIST, ',' ) + 1
                                                                   )
                                                    
                                                    AND A.EXM_PRGR_STS_CD                  = 'B'
                                                    AND A.ORD_CTG_CD                      IN ('CP', 'NM')
                                                    AND A.ODDSC_TP_CD                      = 'C'
                                                    AND A.EXM_RTN_REQ_DTM                 IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                                                    AND NVL(A.PRN_ORD_YN, 'N')             = 'N'
                                                    
                                                    AND A.HSP_TP_CD                        = B.HSP_TP_CD
                                                    AND A.ORD_CD                           = B.EXM_CD
                                                    AND A.HSP_TP_CD                        = S.HSP_TP_CD
                                                    AND A.ORD_CD                           = S.EXM_CD
                                                    AND A.TH1_SPCM_CD                      = S.SPCM_CD
                                                    AND S.SPCM_CTNR_CD IS NOT NULL -- 검체용기가 없는 검사는 제외함.
                    
                                                    AND A.HSP_TP_CD                        = D.HSP_TP_CD
                                                    AND A.ORD_CD                           = D.EXM_CD
                                                    AND D.WCTG_TP_CD                       = '10'
                    
                                                    AND A.HSP_TP_CD                        = C.HSP_TP_CD
                                                    AND B.EXRM_EXM_CTG_CD                  = C.EXM_CTG_CD
        
                                                  GROUP BY A.HSP_TP_CD
                                                         , A.PT_NO
                                                         , A.EXM_HOPE_DT
                                                         , C.EXM_CTG_CD
                                                         , C.EXM_CTG_ABBR_NM
                                                         , A.SPCM_PTHL_NO
                                                         , A.TH1_SPCM_CD
                                                         , S.SPCM_CTNR_CD
                                                         , A.PACT_TP_CD
                                                         , A.PACT_ID
                                                                                        
                                                 
                                                 
                                       )
                            LOOP
                                
                                    -- KIOSK 채혈정보 조합                    
                                    V_SPCM_LIST := V_SPCM_LIST 
                                                   || '^SS' 
                                                   || '^TS'  || REC.TS -- V_SPCM_NO -- REC.TS
                                                   || '^TC'  || REC.TC
                                                   || '^TP'  || REC.TP
                                                   || '^PF'  || REC.PF
                                                   || '^FC'  || REC.FC
                                                   || '^T1'  || REC.T1
                                                   || '^T2'  || REC.T2
                                                   || '^T3'  || REC.T3
                                                   || '^T4'  || REC.T4 --  V_SPCM_NO -- REC.T4
                                                   || '^T5'  || REC.T5
                                                   || '^T6'  || REC.T6
                                                   || '^T7'  || REC.T7
                                                   || '^T8'  || REC.T8
                                                   || '^T9'  || REC.T9
                                                   || '^T10' || REC.T10
                                                   || '^T11' || REC.T11
                                                   || '^T12' || REC.T12
                                                   || '^T13' || REC.T13                                           
                                                   || '^_SS'
                                                    ;
                                                    
                                V_CNT := V_CNT + 1;
                            
                            END LOOP;               
                               
        
                            
                            BEGIN                    
                                
                                V_RET_SPCM_LIST :=    '#KR0R#KR1Y#KR2자동채혈접수성공#KR3'
                                                   || V_KIOSK_PATINFO
                                                   || '^^^S'
                                                   
                                                   || V_SPCM_LIST
                                                   
                                                   || '^^^_S'                                           
                                                     
                                                   ;
                                                   
        --                        RAISE_APPLICATION_ERROR(-20001, IN_KIOSK_ID || '\' || '' || '\' || V_CNT || '\' || V_RET_SPCM_LIST ) ;       
                                                   
                                IO_ERRYN  := 'N';
                                IO_ERRMSG := 'KIOSK_SPCMINFO' || V_RET_SPCM_LIST || '/KIOSK_SPCMINFO';
                                IO_RESULT := IO_ERRMSG;
                                RETURN;
                            END ; 
        
                        END ; 
                                                  


                
                END IF;
                -- 2022.04.07 홍승표 : LCT통합검사실 기능 구현 관련 끝
                
                                                  

            END ;        


    END PC_MSE_KIOSK_AUTO_BLCL;             





    /**********************************************************************************************
     *    서비스이름  : PC_MSE_BLOOD_RSLT_SAVE
     *    최초 작성일 : 2021.10.21
     *    최초 작성자 : ezCaretech 홍승표
     *    Description : 혈액검사결과 저장
     **********************************************************************************************/
    PROCEDURE PC_MSE_BLOOD_RSLT_SAVE
                 ( IN_SAVEFLAG         IN      VARCHAR2
                 , IN_PT_NO            IN      MSELMAID.PT_NO%TYPE
                 , IN_SPCM_NO          IN      MSELMAID.SPCM_NO%TYPE
                 , IN_EXM_CTG_CD       IN      MSELMAID.EXRM_EXM_CTG_CD%TYPE
                 , IN_WK_UNIT_CD       IN      MSELMAID.WK_UNIT_CD%TYPE
                 , IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                 , IN_MIDL_BRFG_CNTE   IN      MSELMAID.MIDL_BRFG_CNTE%TYPE
                 , IN_EXRS_CNTE        IN      MSELMAID.EXRS_CNTE%TYPE

                 , IN_RMK_CNTE         IN      MSELMCED.RMK_CNTE%TYPE
                 , IN_LMQC_RMK_CNTE    IN      MSELMCED.LMQC_RMK_CNTE%TYPE
                 , IN_EXRS_RMK_CNTE    IN      MSELMAID.EXRS_RMK_CNTE%TYPE
                 , IN_EXRM_RMK_CNTE    IN      MSELMAID.EXRM_RMK_CNTE%TYPE
                 
                 , IN_DLT_YN           IN      MSELMAID.DLT_YN%TYPE
                 , IN_PNC_YN           IN      MSELMAID.PNC_YN%TYPE
                 , IN_CVR_YN           IN      MSELMAID.CVR_YN%TYPE
                      
                 , IN_EQUP_CD          IN      VARCHAR2
                 , IN_REG_SEQ          IN      VARCHAR2
                 
                 , HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                 , HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                 , HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                 , HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE
                 
                 , IO_ERR_YN           IN OUT  VARCHAR2
                 , IO_ERR_MSG          IN OUT  VARCHAR2 
                 )
    AS
    
        T_MSBIOBAD_CNT        NUMBER(10);        -- 혈액형 결과정보 입력갯수
        T_EXM_ACPT_NO         VARCHAR2(0010);    -- 혈액형 결과정보 입력된 접수번호
        V_EXRM_RSLT_EXCN_EXM_CD_YN MSELMEBM.EXRM_RSLT_EXCN_EXM_CD_YN%TYPE;
        
    BEGIN                   
    
        BEGIN                         

            -- 혈액형 검사결과
            PC_MSE_BLOOD_RSLT_BIO_SAVE
                             ( IN_EQUP_CD 
                             , IN_REG_SEQ
                             , IN_EXM_CD
                             , IN_PT_NO
                             , IN_SPCM_NO            
                             
                             , IN_EXRS_CNTE        -- 검사결과
                             , IN_EXRS_RMK_CNTE    -- 결과비고                                            
                             , IN_LMQC_RMK_CNTE    -- 장비비고내용
                                              
                             , IN_EQUP_CD
                             , HIS_HSP_TP_CD
                             , 'INTERFACE'
                             , SYS_CONTEXT('USERENV','IP_ADDRESS')
                             
                             , IO_ERR_YN
                             , IO_ERR_MSG
                             );
             
            IF IO_ERR_YN = 'Y' THEN
                RETURN;
            END IF;                                                                                                        
            
            BEGIN
                SELECT NVL(EXRM_RSLT_EXCN_EXM_CD_YN, 'N')
                  INTO V_EXRM_RSLT_EXCN_EXM_CD_YN
                  FROM MSELMEBM
                 WHERE HSP_TP_CD = HIS_HSP_TP_CD
                   AND EXM_CD    = IN_EXM_CD
                   ;
             EXCEPTION
                WHEN OTHERS THEN
                    IO_ERR_YN  := 'Y';
                    IO_ERR_MSG := '혈액은행 검사결과제외 여부 조회시 에러 ERROR = ' || SQLERRM;
                    RETURN;                        
            END; 
            
            IF V_EXRM_RSLT_EXCN_EXM_CD_YN = 'N' THEN
                 -- 검사결과 저장
                XSUP.PKG_MSE_LM_EXAMRSLT.SAVE
                             (  IN_SAVEFLAG                                -- 임시
                              , IN_PT_NO                                   -- 환자번호
                              , IN_SPCM_NO
                              , IN_EXM_CTG_CD                              -- IN_EXM_CTG_CD       IN      MSELMAID.EXRM_EXM_CTG_CD%TYPE
                              , IN_WK_UNIT_CD                              -- IN_WK_UNIT_CD       IN      MSELMAID.WK_UNIT_CD%TYPE
                              , IN_EXM_CD                                  -- IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                              , ''                                         -- IN_MIDL_BRFG_CNTE   IN      MSELMAID.MIDL_BRFG_CNTE%TYPE
                              
                              -- 장비결과값이 NULL이면, Default검사결과 저장
                              , IN_EXRS_CNTE                               -- IN_EXRS_CNTE        IN      MSELMAID.EXRS_CNTE%TYPE
            
                              , ''                                         -- IN_RMK_CNTE         IN      MSELMCED.RMK_CNTE%TYPE
                              , IN_RMK_CNTE                                -- IN_LMQC_RMK_CNTE    IN      MSELMCED.LMQC_RMK_CNTE%TYPE
                              , IN_EXRS_RMK_CNTE                           -- IN_EXRS_RMK_CNTE    IN      MSELMAID.EXRS_RMK_CNTE%TYPE
                              , ''                                         -- IN_EXRM_RMK_CNTE    IN      MSELMAID.EXRM_RMK_CNTE%TYPE
                             
                              , IN_DLT_YN                                  -- IN      MSELMAID.DLT_YN%TYPE
                              , IN_PNC_YN                                  -- IN      MSELMAID.PNC_YN%TYPE
                              , ''                                         -- IN_CVR_YN         --  IN      MSELMAID.CVR_YN%TYPE
                             
                              , IN_EQUP_CD                                 -- HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                              , HIS_HSP_TP_CD                              -- HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                              , 'INTERFACE'                                -- HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                              , SYS_CONTEXT('USERENV','IP_ADDRESS')        -- HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE

                              , ''                                        -- IN_RSLT_BRFG_CNTE   IN      MSELMAID.RSLT_BRFG_CNTE%TYPE
                             
                              , IO_ERR_YN -- IO_ERR_YN           IN OUT  VARCHAR2
                              , IO_ERR_MSG --IO_ERR_MSG          IN OUT  VARCHAR2 
                             );
     
                IF IO_ERR_YN = 'Y' THEN
                    RETURN;
                END IF;                
            END IF ;                      
                    
        END;
                         
    END PC_MSE_BLOOD_RSLT_SAVE;     




    
    
    /**********************************************************************************************
     *    서비스이름  : PC_MSE_BLOOD_RSLT_BIO_SAVE
     *    최초 작성일 : 2021.10.21
     *    최초 작성자 : ezCaretech 홍승표
     *    Description : 혈액형 검사결과 저장
     **********************************************************************************************/
    PROCEDURE PC_MSE_BLOOD_RSLT_BIO_SAVE
                 ( IN_EQUP_CD          IN      VARCHAR2
                 , IN_REG_SEQ          IN      VARCHAR2
                 , IN_EXM_CD           IN      VARCHAR2
                 , IN_PT_NO            IN      VARCHAR2
                 , IN_SPCM_NO          IN      VARCHAR2
                 
                 , IN_EXRS_CNTE        IN      VARCHAR2
                 , IN_EXM_RMK_CNTE     IN      VARCHAR2
                 , IN_EQUP_RMK_CNTE    IN      VARCHAR2                
                                  
                 , HIS_STF_NO          IN      MSELMIFD.FSR_STF_NO%TYPE
                 , HIS_HSP_TP_CD       IN      MSELMIFD.HSP_TP_CD%TYPE
                 , HIS_PRGM_NM         IN      MSELMIFD.LSH_PRGM_NM%TYPE
                 , HIS_IP_ADDR         IN      MSELMIFD.LSH_IP_ADDR%TYPE
                 
                 , IO_ERR_YN           IN OUT  VARCHAR2
                 , IO_ERR_MSG          IN OUT  VARCHAR2 
                 )
    AS
    
        T_MSBIOBAD_CNT        NUMBER(10);        -- 혈액형 결과정보 입력갯수
        T_EXM_ACPT_NO         VARCHAR2(0010);    -- 혈액형 결과정보 입력된 접수번호
        
    BEGIN

        BEGIN
            
            SELECT COUNT(*) 
                 , MAX(B.EXM_ACPT_NO)
              INTO T_MSBIOBAD_CNT
                 , T_EXM_ACPT_NO
              FROM MSBIOBAD A
                 , MSELMAID B
             WHERE A.SPCM_NO        = B.SPCM_NO
               AND A.HSP_TP_CD      = B.HSP_TP_CD
               AND A.SPCM_NO        = IN_SPCM_NO
               AND A.HSP_TP_CD      = HIS_HSP_TP_CD
               AND A.EXM_ACPT_NO    = B.EXM_ACPT_NO
               AND B.EXM_CD         = 'BBG01' -- ABO cell typing
               ;                       
               
            
--            RAISE_APPLICATION_ERROR(-20001, IN_SPCM_NO || '\' || T_MSBIOBAD_CNT || '\' || T_EXM_ACPT_NO) ;
             

            --혈액형 결과정보 생성
            IF T_MSBIOBAD_CNT = '0' THEN
                BEGIN
                    INSERT INTO MSBIOBAD ( HSP_TP_CD
                                         , EXM_DT
                                         , EXM_ACPT_NO
                                         , PT_NO
                                         , SPCM_NO     
                                         
                                         , TH1_ABOB_TP_CD
                                         , TH1_RHB_TP_CD
                                         
                                         , ATBD_TH1_CHR_VAL                                             --항체1번째문자값
                                         , ATBD_TH2_CHR_VAL                                             --항체2번째문자값
                                         , ATGN_TH1_CHR_VAL                                             --항원1번째문자값
                                         , ATGN_TH2_CHR_VAL                                             --항원2번째문자값
                                         , ATGN_RH_CHR_VAL                                              --항원RH문자값
                                         
                                         , FSR_DTM
                                         , FSR_STF_NO
                                         , FSR_PRGM_NM
                                         , FSR_IP_ADDR
                                         , LSH_DTM
                                         , LSH_STF_NO
                                         , LSH_PRGM_NM
                                         , LSH_IP_ADDR
                                         )
                                ( 
                                  SELECT   A.HSP_TP_CD
                                         , TO_CHAR(A.ACPT_DTM, 'YYYY-MM-DD')
                                         , A.EXM_ACPT_NO
                                         , A.PT_NO
                                         , A.SPCM_NO
                                         
                                         , ''
                                         , ''
                                         
                                         , ''
                                         , ''
                                         , ''
                                         , ''
                                         , ''
                                         
                                         , SYSDATE
                                         , HIS_STF_NO
                                         , 'INTERFACE'
                                         , SYS_CONTEXT('USERENV','IP_ADDRESS')
                                         , SYSDATE
                                         , HIS_STF_NO
                                         , 'INTERFACE'
                                         , SYS_CONTEXT('USERENV','IP_ADDRESS')
                                    FROM MSELMAID A
                                   WHERE 1=1
                                     AND A.HSP_TP_CD           = HIS_HSP_TP_CD
                                     AND A.SPCM_NO             = IN_SPCM_NO
                                     AND A.EXM_CD              = 'BBG01'  
                                ); 
                  
                    EXCEPTION
                        WHEN OTHERS THEN
                            IO_ERR_YN  := 'Y';
                            IO_ERR_MSG := '혈액 검사결과 정보 저장 중 에러 발생 ERROR = ' || SQLERRM;
                            RETURN;                        

                END;
            END IF;


            --** 검사결과저장시 아래 참고할 것 ** 
            -- 
            --혈액형검사처럼 1,2차 검증을 하는 검사일 경우
            --최종검증이 아닐때는 검사결과를 MSELMAID에 저장하지 않도록 함.
            --ex) 혈액검사결과 장비 인터페이스 전송시에는 MSELMAID-EXRS_CNTE 에 업데이트하지 않는다.
           
           
--        RAISE_APPLICATION_ERROR(-20001, IN_EXM_CD || '\' || IN_EXRS_CNTE  || '\' ) ;
                                    
            IF IN_EXM_CD = 'BBG01' THEN         -- ABO cell typing
                          
                UPDATE MSBIOBAD                                                                                                            --혈액형
                   SET EQUP_INPT_STF_NO  = IN_EQUP_CD                                                                                                                                                                 --장비입력직원번호
                     , EQUP_ABOB_TP_CD   = IN_EXRS_CNTE                                                                                                                                                               --혈액형 
                     , TH1_ABOB_TP_CD    = IN_EXRS_CNTE                                                                                                                                                               --1번째ABO식혈액형구분코드
                     , TH2_ABOB_TP_CD    = IN_EXRS_CNTE                                                                                                                                                               --2번째ABO식혈액형구분코드
                     , TH1_INPT_STF_NO   = IN_EQUP_CD                                                                                                                                                                 --1번째입력직원번호
                 WHERE SPCM_NO           = IN_SPCM_NO
                   AND HSP_TP_CD         = HIS_HSP_TP_CD 
                   ; 
                   
            ELSIF IN_EXM_CD = 'BBG02' THEN    -- Rh typing
                UPDATE MSBIOBAD
                   SET EQUP_RHB_TP_CD  = IN_EXRS_CNTE                                                                                                                                                               --장비RH식혈액형구분코드
                     , TH1_RHB_TP_CD   = IN_EXRS_CNTE                                                                                                                                                               --1번째RH식혈액형구분코드
                     , TH2_RHB_TP_CD   = IN_EXRS_CNTE                                                                                                                                                               --2번째RH식혈액형구분코드
                     , TH1_INPT_STF_NO = IN_EQUP_CD                                                                                                                                                                 --1번째입력자
                 WHERE SPCM_NO         = IN_SPCM_NO
                   AND HSP_TP_CD       = HIS_HSP_TP_CD 
                   ;    
             ELSIF IN_EXM_CD = 'BBG015' THEN
                  UPDATE MSBIOBAD
                     SET EQUP_ATBD_TH1_CHR_VAL = IN_EXRS_CNTE                               /*항체1번째문자값*/
                   WHERE SPCM_NO          = IN_SPCM_NO
                     AND HSP_TP_CD        = HIS_HSP_TP_CD 
                     ;      
            ELSIF IN_EXM_CD = 'BBG016' THEN
                  UPDATE MSBIOBAD
                     SET EQUP_ATBD_TH2_CHR_VAL = IN_EXRS_CNTE                               /*항체1번째문자값*/
                   WHERE SPCM_NO          = IN_SPCM_NO
                     AND HSP_TP_CD        = HIS_HSP_TP_CD 
                     ;
            ELSIF IN_EXM_CD = 'BBG017' THEN
                  UPDATE MSBIOBAD
                     SET EQUP_ATGN_TH1_CHR_VAL = IN_EXRS_CNTE                               /*항체1번째문자값*/
                   WHERE SPCM_NO          = IN_SPCM_NO
                     AND HSP_TP_CD        = HIS_HSP_TP_CD 
                     ;
            ELSIF IN_EXM_CD = 'BBG018' THEN
                  UPDATE MSBIOBAD
                     SET EQUP_ATGN_TH2_CHR_VAL = IN_EXRS_CNTE                               /*항체1번째문자값*/  
                   WHERE SPCM_NO          = IN_SPCM_NO
                     AND HSP_TP_CD        = HIS_HSP_TP_CD 
                     ;
            ELSIF IN_EXM_CD = 'BBG025' THEN
                  UPDATE MSBIOBAD
                     SET EQUP_ATGN_RH_CHR_VAL  = IN_EXRS_CNTE                               /*항체1번째문자값*/
                   WHERE SPCM_NO          = IN_SPCM_NO
                     AND HSP_TP_CD        = HIS_HSP_TP_CD 
                     ;        
            END IF;    
            
            
        END;
                         
    END PC_MSE_BLOOD_RSLT_BIO_SAVE;     


    /**********************************************************************************************
     *    서비스이름  : PC_MSE_UPDATE_EQUP_INFO
     *    최초 작성일 : 2021.12.20
     *    최초 작성자 : ezCaretech SCS
     *    Description : PC_MSE_UPDATE_EQUP_INFO
     **********************************************************************************************/        
    PROCEDURE PC_MSE_UPDATE_EQUP_INFO
    (
      IN_SPCM_NO          IN      MSELMAID.SPCM_NO%TYPE
    , IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
    , IN_EXRS_CNTE        IN      MSELMAID.EXRS_CNTE%TYPE
    
    , IN_DEXM_MDSC_EQUP_CD IN     MSELMAID.DEXM_MDSC_EQUP_CD%TYPE
    , IN_EQUP_RMK_CNTE    IN      MSELMAID.EQUP_RMK_CNTE%TYPE
    
    , IN_ANTC_REQR_DTM    IN      MSELMAID.ANTC_REQR_DTM%TYPE
    , IN_HNWR_EXRS_CNTE   IN      MSELMAID.HNWR_EXRS_CNTE%TYPE
    
    , HIS_STF_NO          IN      MSELMIFD.FSR_STF_NO%TYPE
    , HIS_HSP_TP_CD       IN      MSELMIFD.HSP_TP_CD%TYPE
    , HIS_PRGM_NM         IN      MSELMIFD.LSH_PRGM_NM%TYPE
    , HIS_IP_ADDR         IN      MSELMIFD.LSH_IP_ADDR%TYPE
    
    , IO_ERR_YN           IN OUT  VARCHAR2
    , IO_ERR_MSG          IN OUT  VARCHAR2  
    )
    AS
        V_RESULT             VARCHAR2(1)    := 'N';

--        V_STR_EXRS_CNTE      VARCHAR2(4000) := IN_EXRS_CNTE;
        V_STR_EXRS_CNTE      VARCHAR2(32767) := IN_EXRS_CNTE; -- CLOB
        
        V_EXRS_CNTE          VARCHAR2(4000)  := '';          
        V_EXRS_RMK_CNTE      VARCHAR2(4000)  := ''; --결과비고
        V_EQUP_RMK_CNTE      VARCHAR2(4000)  := IN_EQUP_RMK_CNTE; --인터페이스 비고
        
        V_DLTN_FMR_EXRS_CNTE VARCHAR2(4000)  := ''; --희석전 결과
        V_EXRM_RMK_CNTE      VARCHAR2(4000)  := '';
        V_NUM_EXRS_CNTE      NUMBER;
        
        V_AMR_CNT            NUMBER;
        
        V_RFVL_L             NUMBER;
        V_RFVL_H             NUMBER;  
        
        --UPDATE 용
        V_AMR_YN             VARCHAR2(1) := 'N';
        V_AMR_CFMT_YN        VARCHAR2(1) := '';
        V_AMR_CFMT_CD        VARCHAR2(10);
--        V_AMR_CFMT_CNTE      VARCHAR2(4000);
    BEGIN
        

        --장비비고(인터페이스 비고)
        V_EQUP_RMK_CNTE := IN_EQUP_RMK_CNTE;
        
        V_STR_EXRS_CNTE := REPLACE(V_STR_EXRS_CNTE, '<', '');
        V_STR_EXRS_CNTE := REPLACE(V_STR_EXRS_CNTE, '>', '');
        
        IF INSTR(V_STR_EXRS_CNTE, '희석') > 0 THEN
            V_STR_EXRS_CNTE := REGEXP_REPLACE(V_STR_EXRS_CNTE, '[^0-9|.]+');
        END IF;                   
        
        
        BEGIN
        
            -- ***.** 넘어옴.
            --> 상한값 + 0.1 OR 0.001 로 설정할지 논의 중.
        
            V_NUM_EXRS_CNTE := TO_NUMBER(V_STR_EXRS_CNTE);  
            
            EXCEPTION
                WHEN OTHERS THEN
                    V_AMR_YN := 'N';
                    V_AMR_CFMT_YN := '';                
                    GOTO AFTER_AMR_CHECK;
        END;
        
        
        -- AMR 참고치 조회
        -- AMR 참고치 없으면
        BEGIN

            SELECT FT_MSE_TONUMBER(RFVL_LWLM_CNTE)
                 , FT_MSE_TONUMBER(RFVL_HGLM_CNTE)
              INTO V_RFVL_L
                 , V_RFVL_H
              FROM MSELMRRD R
             WHERE HSP_TP_CD          = HIS_HSP_TP_CD
               AND RFVL_TP_CD         = 'A'
               AND EXM_CD             = IN_EXM_CD
               AND SYSDATE      BETWEEN AVL_STR_DT AND AVL_END_DT
               --2022-04-05 SCS : 기간내 중복이 있어서 시작일자가 가장 최근인것만 조회함.
               AND AVL_STR_DT = (SELECT MAX(AVL_STR_DT)
                                   FROM MSELMRRD RR
                                  WHERE RR.HSP_TP_CD = R.HSP_TP_CD
                                    AND RR.RFVL_TP_CD = R.RFVL_TP_CD
                                    AND RR.EXM_CD     = R.EXM_CD)               
               
               AND ROWNUM = 1
            ;
            EXCEPTION
                WHEN OTHERS THEN
                    V_AMR_YN := 'N';
                    V_AMR_CFMT_YN := '';       
                    V_AMR_CFMT_CD := '';
                    
                    V_DLTN_FMR_EXRS_CNTE := '';
                    V_EXRS_CNTE := '';
                    V_EXRM_RMK_CNTE := '';
                    
                    GOTO AFTER_AMR_CHECK;
        END;
        
        
                
        -- < 기호가 붙거나 AMR 하한값보다 결과가 낫다면 희석 불필요함.
        -- AMR_YN : Y, AMR_CFMT_YN : Y 로 리턴함.
        -- 사용자가 ARM_YN : Y임을 인지할수 있고 조치완료한 상태로 결과를 업데이트함.
        IF INSTR(IN_EXRS_CNTE, '<') > 0 OR V_NUM_EXRS_CNTE < V_RFVL_L THEN
            V_AMR_YN := 'Y';
            V_AMR_CFMT_YN := 'Y';
            V_AMR_CFMT_CD := '20'; -- AMR이하 -> 희석전 결과 , 최종결과는 동일
            
            V_DLTN_FMR_EXRS_CNTE := IN_EXRS_CNTE;
            V_EXRS_CNTE := IN_EXRS_CNTE;
            V_EXRM_RMK_CNTE := IN_EQUP_RMK_CNTE;            
            V_EQUP_RMK_CNTE := ''; --인터페이스 비고는 업데이트 안함            
            --GOTO UPDATE_AID;
        
        ELSIF INSTR(REPLACE(IN_EQUP_RMK_CNTE, ' ', ''), '희석결과') > 0 THEN
            V_AMR_YN := 'Y';
            V_AMR_CFMT_YN := 'Y'; -- 조치완료됐다는 뜻.
            V_AMR_CFMT_CD := ''; -- AMR 조치내용 -- MSELMSID.LCLS_COMN_CD = 'AMR_CFMT_CD'

            V_DLTN_FMR_EXRS_CNTE := '';  -- NULL일때 업데이트 안됨.
            V_EXRS_CNTE := IN_EXRS_CNTE;
            V_EXRM_RMK_CNTE := IN_EQUP_RMK_CNTE;
            V_EQUP_RMK_CNTE := ''; --인터페이스 비고는 업데이트 안함            
               
        -- > 기호가 붙거나 AMR 상한값보다 결과가 크다면 희석해야 함.        
        ELSIF INSTR(IN_EXRS_CNTE, '>') > 0 OR V_NUM_EXRS_CNTE > V_RFVL_H THEN
            V_AMR_YN := 'Y';
            V_AMR_CFMT_YN := '';                   
            V_AMR_CFMT_CD := '';
            
            V_DLTN_FMR_EXRS_CNTE := IN_EXRS_CNTE;  -- 희석전 결과
            V_EXRS_CNTE := IN_EXRS_CNTE;
            V_EXRM_RMK_CNTE := IN_EQUP_RMK_CNTE;
            V_EQUP_RMK_CNTE := ''; --인터페이스 비고는 업데이트 안함
                        
            --GOTO UPDATE_AID;
            
        END IF;
        
        IF INSTR(REPLACE(IN_EQUP_RMK_CNTE, ' ', ''), '희석중') > 0 THEN
            V_AMR_YN := 'Y';
            -- 장비비고로 '희석중'이란 값이 넘어왔을경우
            -- 장비에서 자동희석되는 경우이고, 재검 후 2차 결과가 넘어옴.
            -- 별다른 조치없이 재검 결과가 보고됨.
            -- 사용자가 AMR_YN : Y임을 인지할수 있고 더이상 조치를 취하지 않음
            V_AMR_CFMT_YN := '';
            V_AMR_CFMT_CD := ''; -- AMR 조치내용 -- MSELMSID.LCLS_COMN_CD = 'AMR_CFMT_CD'
            
            V_DLTN_FMR_EXRS_CNTE := IN_EXRS_CNTE;  -- 희석전 결과
            V_EXRS_CNTE := IN_EXRS_CNTE;
            V_EXRM_RMK_CNTE := IN_EQUP_RMK_CNTE;
            V_EQUP_RMK_CNTE := ''; --인터페이스 비고는 업데이트 안함                                    
                
            
            --GOTO UPDATE_AID;
                        
        END IF;

        -- 희석전결과에 희석중 텍스트가 있을때
        IF INSTR(REPLACE(V_DLTN_FMR_EXRS_CNTE, ' ', ''), '희석중') > 0 THEN 
            V_AMR_CFMT_CD := '10'; -- AMR 조치내용 : '장비내 희석' 으로 업데이트 -- MSELMSID.LCLS_COMN_CD = 'AMR_CFMT_CD'
        END IF;


        <<AFTER_AMR_CHECK>>

        
        -- '2+이상의 Hemolysis/Icteric/Lipemic으로 결과에 영향을 줄 수 있습니다.' 장비비고가 넘어왔을때
        -- 결과비고에도 업데이트 함
        IF INSTR(REPLACE(IN_EQUP_RMK_CNTE, ' ', ''), 'H(') > 0 OR INSTR(REPLACE(IN_EQUP_RMK_CNTE, ' ', ''), 'I(') > 0  OR INSTR(REPLACE(IN_EQUP_RMK_CNTE, ' ', ''), 'L(') > 0 THEN
            
            V_EXRS_RMK_CNTE := IN_EQUP_RMK_CNTE; --결과비고에 업데이트 함
            V_EXRM_RMK_CNTE := ''; -- 검사실비고는 업데이트 안함
            V_EQUP_RMK_CNTE := ''; --인터페이스 비고는 업데이트 안함            
        END IF;     
        
        IF INSTR(REPLACE(IN_EQUP_RMK_CNTE, ' ', ''), 'H:') > 0 OR INSTR(REPLACE(IN_EQUP_RMK_CNTE, ' ', ''), 'I:') > 0  OR INSTR(REPLACE(IN_EQUP_RMK_CNTE, ' ', ''), 'L:') > 0 THEN
            
            V_EXRS_RMK_CNTE := IN_EQUP_RMK_CNTE; --결과비고 업데이트
            V_EXRM_RMK_CNTE := ''; -- 검사실비고는 업데이트 안함
            V_EQUP_RMK_CNTE := ''; --인터페이스 비고는 업데이트 안함
            
        END IF;        

        ------------------------------------------------------------------------------
        -- 화면에서 V_AMR_YN : Y , V_AMR_CFMT_YN : N (NULL) 일때 녹색 Y로 표시됨.
        --        V_AMR_YN : Y , V_AMR_CFMT_YN : Y 일때 그냥 Y로 표시됨. (배경색 없는)
        ------------------------------------------------------------------------------
        

                      
--        RAISE_APPLICATION_ERROR(-20001, IN_SPCM_NO || '\' || IN_EXM_CD || '\' || IN_DEXM_MDSC_EQUP_CD   ) ;
--        
        BEGIN        
            UPDATE MSELMAID A
               SET AMR_YN = V_AMR_YN
                 , AMR_CFMT_YN = V_AMR_CFMT_YN

                 -- V_AMR_CFMT_CD 값이 NULL이 아닐때만 업데이트 함.
                 , AMR_CFMT_CD = DECODE(V_AMR_CFMT_CD, NULL, AMR_CFMT_CD, V_AMR_CFMT_CD)
                 --, AMR_CFMT_CNTE = V_AMR_CFMT_CNTE -- 화면에서 기타를 선택했을때 입력한 내용. 인터페이스시에는 업데이트 불필요
                 

                 -- V_DLTN_FMR_EXRS_CNTE 값이 NULL이 아닐때만 업데이트 함.
                 , DLTN_FMR_EXRS_CNTE = DECODE(V_DLTN_FMR_EXRS_CNTE, NULL, DLTN_FMR_EXRS_CNTE, V_DLTN_FMR_EXRS_CNTE)

                 -- AMR_YN 이 Y 인 경우에만 결과저장                 
                 -- V_EXRS_CNTE 값이 NULL이 아닐때 결과 업데이트함.
                 , EXRS_CNTE     = DECODE(V_EXRS_CNTE, NULL, EXRS_CNTE, V_EXRS_CNTE)
                 , SMP_EXRS_CNTE = TO_CHAR(DECODE(V_EXRS_CNTE, NULL, SMP_EXRS_CNTE, V_EXRS_CNTE))
                 -- AMR_YN 이 Y 인 경우에만 결과저장
                 
                 , EXRS_RMK_CNTE = DECODE(V_EXRS_RMK_CNTE, NULL, EXRS_RMK_CNTE, V_EXRS_RMK_CNTE) -- 결과비고
                 
                 , DEXM_MDSC_EQUP_CD = IN_DEXM_MDSC_EQUP_CD -- 장비코드

--                 , EQUP_RMK_CNTE = IN_EQUP_RMK_CNTE         -- 장비비고 (인터페이스 비고)

                 -- AMR_YN 이 Y 인 경우에 비고내용을 검사실비고에 저장
                 -- 검사실비고 내용이 있으면 기존내용에 붙임. 없으면 바로 업데이트
                 , EXRM_RMK_CNTE = CASE WHEN V_EXRM_RMK_CNTE IS NULL THEN EXRM_RMK_CNTE -- 내용이 없으면 업데이트 안함
                                   ELSE DECODE(A.EXRM_RMK_CNTE, NULL, V_EXRM_RMK_CNTE, A.EXRM_RMK_CNTE || CHR(10) || V_EXRM_RMK_CNTE) -- 검사실비고
                                   END
                                   
                 -- AMR_YN 이 Y 인 경우에 인터페이스 비고 내용은 업데이트 안함
                 --          N 인 경우에 인터페이스 비고 내용 저장함.
                 , EQUP_RMK_CNTE = CASE WHEN V_EQUP_RMK_CNTE IS NULL THEN EQUP_RMK_CNTE -- 내용이 없으면 업데이트 안함
                                   ELSE V_EQUP_RMK_CNTE            
                                   END
                 
                 , EQUP_RSLT_SND_DTM = SYSDATE
--                 , ANTC_REQR_DTM = TO_DATE(IN_ANTC_REQR_DTM, 'YYYYMMDDHH24MISS')
                 , ANTC_REQR_DTM = IN_ANTC_REQR_DTM
                 
--                 , HNWR_EXRS_CNTE = IN_HNWR_EXRS_CNTE

                 , EXM_STR_DTM = CASE WHEN (INSTR(IN_EXRS_CNTE, '/[') > 0 OR INSTR(IN_EXRS_CNTE, '#[') > 0 ) AND FT_MSE_TONUMBER(SUBSTR(IN_EXRS_CNTE, 3, 1)) IS NOT NULL THEN SYSDATE
                                 ELSE EXM_STR_DTM
                                 END    

                 -- 2022-04-20 SCS : 인터페이스 전송여부 'Y'로 업데이트 함. (검사결과관리에서 Y인것은 세모 표시함)
                 , INTF_SND_YN = CASE WHEN (INSTR(IN_EXRS_CNTE, '/[') > 0 OR INSTR(IN_EXRS_CNTE, '#[') > 0 ) THEN INTF_SND_YN
                                 ELSE 'Y'
                                 END
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND SPCM_NO   = IN_SPCM_NO
               AND EXM_CD    = IN_EXM_CD
            ;           
            EXCEPTION            
                WHEN OTHERS THEN
                    IO_ERR_YN := 'Y';
                    IO_ERR_MSG := 'AMR 및 인터페이스(장비) 정보 저장 중 에러 발생 ERROR = ' || SQLERRM;
        END;


    END PC_MSE_UPDATE_EQUP_INFO;

    /**********************************************************************************************
     *    서비스이름  : FT_MSE_TONUMBER
     *    최초 작성일 : 2021.12.21
     *    최초 작성자 : ezCaretech SCS
     *    Description : 문자를 숫자형으로 리턴함.
     **********************************************************************************************/    
    FUNCTION FT_MSE_TONUMBER(IN_PARAM VARCHAR2)
    RETURN NUMBER 
    IS
        V_RSLT NUMBER(11,4);
    BEGIN
    
        V_RSLT := '' ;
        
        IF IN_PARAM IS NULL THEN
            V_RSLT := 0;
        END IF;
        
        BEGIN
            SELECT TO_NUMBER(IN_PARAM)
            INTO V_RSLT
            FROM DUAL ;
        
            EXCEPTION
                WHEN OTHERS THEN
                    V_RSLT := '' ;
        END;
        
        RETURN(V_RSLT);

    END;



    /**********************************************************************************************
     *    서비스이름  : PC_MSE_OSMOLARITY_AUTO_RSLT_SAVE
     *    최초 작성일 : 2021.10.21
     *    최초 작성자 : ezCaretech 홍승표
     *    Description : Osmolarity 자동계산
     **********************************************************************************************/
    PROCEDURE PC_MSE_OSMOLARITY_AUTO_RSLT_SAVE
                 ( IN_SPCM_NO          IN      MSELMAID.SPCM_NO%TYPE
                 
                 , HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                 , HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                 , HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                 , HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE
                 
                 , IO_ERR_YN           IN OUT  VARCHAR2
                 , IO_ERR_MSG          IN OUT  VARCHAR2 
                 )
    AS

    -- Osmolarity 자동계산
    V_RELT                NUMBER(10)      := 0;
    V_LCG13_RELT          NUMBER(10)      := 0;
    V_LCG17_RELT          NUMBER(10)      := 0;  
    V_LCG11_RELT          NUMBER(10)      := 0;
    V_LCS11_RELT          NUMBER(10)      := 0;  
    V_EXRS_CNTE           NUMBER(10)      := 0;
    V_CNT                 NUMBER(10)      := 0;
    
        
    BEGIN                   
        IO_ERR_YN  := 'N';    
        IO_ERR_MSG := '';    
                                                
        --  LCO02 Osmolarity 자동계산 추가
        --> 장비에서 결과가 모두 저장된 후 저장된 결과값을 기준으로 LCO02 값을 계산함.
        --    case "LCG13": sSodium = Convert.ToDouble(item.EXRS_CNTE); break;
        --    case "LCG17": sGlucose = Convert.ToDouble(item.EXRS_CNTE); break;
        --    case "LCG11": sBUN = Convert.ToDouble(item.EXRS_CNTE); break;
        --    case "LCS11": sEthanol = Convert.ToDouble(item.EXRS_CNTE); break;
        -- sRslt1 = sSodium * 2;
        -- sRslt2 = sGlucose / 18;
        -- sRslt3 = sBUN / 2.8;
        -- sRslt4 = sEthanol / 3.8;
        -- sRslt = sRslt1 + sRslt2 + sRslt3 + sRslt4;
                 
--        RAISE_APPLICATION_ERROR(-20553, V_LCG13_RELT ) ;
            
        BEGIN                   
            SELECT COUNT(*)
              INTO V_CNT
              FROM MSELMAID A
             WHERE SPCM_NO   = IN_SPCM_NO
               AND HSP_TP_CD = HIS_HSP_TP_CD 
               AND EXM_CD    = 'LCG13'
               ;
            IF V_CNT > 0 THEN
                SELECT SMP_EXRS_CNTE
                  INTO V_RELT
                  FROM MSELMAID A
                 WHERE SPCM_NO   = IN_SPCM_NO
                   AND HSP_TP_CD = HIS_HSP_TP_CD 
                   AND EXM_CD    = 'LCG13'
                   ;
            
                V_LCG13_RELT := V_RELT * 2;

            END IF;                                       
        END;                 
           
        BEGIN                   
            SELECT COUNT(*)
              INTO V_CNT
              FROM MSELMAID A
             WHERE SPCM_NO   = IN_SPCM_NO
               AND HSP_TP_CD = HIS_HSP_TP_CD 
               AND EXM_CD    = 'LCG17'
               ;
            IF V_CNT > 0 THEN
                SELECT FT_MSE_TONUMBER(SMP_EXRS_CNTE)
                  INTO V_RELT
                  FROM MSELMAID A
                 WHERE SPCM_NO   = IN_SPCM_NO
                   AND HSP_TP_CD = HIS_HSP_TP_CD 
                   AND EXM_CD    = 'LCG17'
                   ;
            
                V_LCG17_RELT := V_RELT / 18;

            END IF;                                       
        END;                 
                      
        BEGIN                   
            SELECT COUNT(*)
              INTO V_CNT
              FROM MSELMAID A
             WHERE SPCM_NO   = IN_SPCM_NO
               AND HSP_TP_CD = HIS_HSP_TP_CD 
               AND EXM_CD    = 'LCG11'
               ;               
            IF V_CNT > 0 THEN
                SELECT FT_MSE_TONUMBER(SMP_EXRS_CNTE)
                  INTO V_RELT
                  FROM MSELMAID A
                 WHERE SPCM_NO   = IN_SPCM_NO
                   AND HSP_TP_CD = HIS_HSP_TP_CD 
                   AND EXM_CD    = 'LCG11'
                   ;
            
                V_LCG11_RELT := V_RELT / 2.8;

            END IF;                                       
        END;                 

        BEGIN                   
            SELECT COUNT(*)
              INTO V_CNT
              FROM MSELMAID A
             WHERE SPCM_NO   = IN_SPCM_NO
               AND HSP_TP_CD = HIS_HSP_TP_CD 
               AND EXM_CD    = 'LCS11'
               ;
            IF V_CNT > 0 THEN
                SELECT FT_MSE_TONUMBER(SMP_EXRS_CNTE)
                  INTO V_RELT
                  FROM MSELMAID A
                 WHERE SPCM_NO   = IN_SPCM_NO
                   AND HSP_TP_CD = HIS_HSP_TP_CD 
                   AND EXM_CD    = 'LCS11'
                   ;
            
                V_LCS11_RELT := V_RELT  / 3.8;

            END IF;                                       
        END;                 

        BEGIN
            V_EXRS_CNTE := ROUND(V_LCG13_RELT + V_LCG17_RELT + V_LCG11_RELT + V_LCS11_RELT, 2);        
             
            UPDATE MSELMAID
               SET EXRS_CNTE     = V_EXRS_CNTE
                 , SMP_EXRS_CNTE = V_EXRS_CNTE
             WHERE SPCM_NO       = IN_SPCM_NO
               AND HSP_TP_CD     = HIS_HSP_TP_CD 
               AND EXM_CD        = 'LCO02'
               ;
             
             EXCEPTION
                 WHEN OTHERS THEN
                    IO_ERR_YN  := 'Y';
                    IO_ERR_MSG := 'Osmolarity 자동계산 업데이트중 오류 발생. ERRCD = ' || SQLERRM;
                    RETURN;
        END;                 
        
        IO_ERR_YN  := 'N';    
        IO_ERR_MSG := '';    
        
            
                         
    END PC_MSE_OSMOLARITY_AUTO_RSLT_SAVE;     

    /**********************************************************************************************
     *    서비스이름  : PC_MSE_IMGRSLT_SIMPLE_SAVE
     *    최초 작성일 : 2021.10.21
     *    최초 작성자 : ezCaretech SCS
     *    Description : 이미지결과 저장
     **********************************************************************************************/
    PROCEDURE PC_MSE_IMGRSLT_SIMPLE_SAVE
                 ( 
                   IN_SPCM_NO          IN      VARCHAR2
                 , IN_EXM_CD           IN      VARCHAR2
                 , IN_FILE_SEQ         IN      VARCHAR2

                 , HIS_STF_NO          IN      MSELMIFD.FSR_STF_NO%TYPE
                 , HIS_HSP_TP_CD       IN      MSELMIFD.HSP_TP_CD%TYPE
                 , HIS_PRGM_NM         IN      MSELMIFD.LSH_PRGM_NM%TYPE
                 , HIS_IP_ADDR         IN      MSELMIFD.LSH_IP_ADDR%TYPE
                 
                 , IO_ERR_YN           IN OUT  VARCHAR2
                 , IO_ERR_MSG          IN OUT  VARCHAR2 
                 )
    AS
        V_ORD_CTG_CD VARCHAR2(2) := 'CP';
    BEGIN

        BEGIN

            DELETE /* XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_IMGRSLT_SIMPLE_SAVE */
              FROM MSELMFID
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND ORD_CTG_CD = V_ORD_CTG_CD
               AND SPCM_PTHL_NO   = IN_SPCM_NO
               AND EXM_CD    = IN_EXM_CD

               ;
        
            INSERT INTO /* XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_IMGRSLT_SIMPLE_SAVE */
            MSELMFID ( ORD_CTG_CD                                                   --처방분류코드
                     , SPCM_PTHL_NO                                                 --검체병리번호
                     , FILE_SEQ                                                     --파일순번
                     , HSP_TP_CD                                                    --병원구분코드
                     , EXM_CD                                                       --검사코드
                     , SCRN_SORT_SEQ                                                --화면정렬순번
                     , FILE_CTG_CD                                                  --파일분류코드
                     , FILE_SV_PATH_NM                                              --파일저장경로명
                     , FILE_TP_CD                                                   --파일구분 R:보고용 I:내부용
                     , FILE_NM                                                      --실제파일명
                     , FSR_STF_NO                                                   --최초등록직원번호
                     , FSR_DTM                                                      --최초등록일시
                     , FSR_PRGM_NM                                                  --최초등록프로그램명
                     , FSR_IP_ADDR                                                  --최초등록IP주소
                     , LSH_STF_NO                                                   --최종변경직원번호
                     , LSH_DTM                                                      --최종변경일시
                     , LSH_PRGM_NM                                                  --최종변경프로그램명
                     , LSH_IP_ADDR                                                  --최종변경IP주소
                     
                     )
              VALUES ( V_ORD_CTG_CD
                     , IN_SPCM_NO
                     , (SELECT NVL(MAX(FILE_SEQ), 0) + 1
                          FROM MSELMFID
                         WHERE ORD_CTG_CD   = V_ORD_CTG_CD
                           AND SPCM_PTHL_NO = IN_SPCM_NO
                           AND HSP_TP_CD    = HIS_HSP_TP_CD)
                     , HIS_HSP_TP_CD
                     , IN_EXM_CD
                     , (SELECT NVL(MAX(SCRN_SORT_SEQ), 0) + 1
                          FROM MSELMFID
                         WHERE ORD_CTG_CD   = V_ORD_CTG_CD
                           AND SPCM_PTHL_NO = IN_SPCM_NO
                           AND HSP_TP_CD    = HIS_HSP_TP_CD)
                     , 'Image'
                     , '/SYSINF' || HIS_HSP_TP_CD || '/LM/INF/' || IN_SPCM_NO || '/' || IN_EXM_CD || '.jpg'

                     --2022-01-12 SCS :
                     --임상화학 PROTEIN EP이미지는 내부용으로 저장함. 결과관리화면에서 이미지와 판독결과 합성하여 업로드함
                     --그 외는 보고용으로 저장함.
--                     , 'R' --FILE_TP_CD
                     , DECODE(SUBSTR(IN_EXM_CD, 1, 3), 'LCE', 'I', 'R')
                     , IN_EXM_CD || '.jpg' --FILE_NM
                     , HIS_STF_NO
                     , SYSDATE
                     , HIS_PRGM_NM
                     , HIS_IP_ADDR
                     , HIS_STF_NO
                     , SYSDATE
                     , HIS_PRGM_NM
                     , HIS_IP_ADDR
                     );
                  
            EXCEPTION
                WHEN OTHERS THEN
                    IO_ERR_YN  := 'Y';
                    IO_ERR_MSG := '이미지결과 저장 중 에러 발생 ERROR = ' || SQLERRM || ' IN_SPCM_NO : ' || IN_SPCM_NO || ' IN_EXM_CD : ' || IN_EXM_CD;
                    RETURN;                        
        END;
                         
    END PC_MSE_IMGRSLT_SIMPLE_SAVE; 


    /**********************************************************************************************
    *    서비스이름  : PC_MSE_ABGA_ORDER_AUTO 진단검사의학과 현장검사(ABGA) 오더 자동발행 및 최종검증
    *    최초 작성일 : 2021.12.30
    *    최초 작성자 : ezCaretech 
    *    Description : SCS
    **********************************************************************************************/
    PROCEDURE PC_MSE_ABGA_ORDER_AUTO
                ( IN_PT_NO            IN   VARCHAR2     --  1.환자번호

                , IO_SPCM_NO          IN   OUT VARCHAR2 --  2.검체번호
               
                , HIS_STF_NO          IN      MSELMIFD.FSR_STF_NO%TYPE
                , HIS_HSP_TP_CD       IN      MSELMIFD.HSP_TP_CD%TYPE
                , HIS_PRGM_NM         IN      MSELMIFD.LSH_PRGM_NM%TYPE
                , HIS_IP_ADDR         IN      MSELMIFD.LSH_IP_ADDR%TYPE
                 
                , IO_ERR_YN           IN OUT  VARCHAR2
                , IO_ERR_MSG          IN OUT  VARCHAR2 
                )
    
    IS
        S_ORD_ID            MOOOREXM.ORD_ID%TYPE    := '';
        S_SPCM_NO           MSELMCED.SPCM_NO%TYPE   := '';

        S_ORD_STF_NO        CNLRRUSD.STF_NO%TYPE    := '';
        
        S_PACT_ID           ACPPRAAM.PACT_ID%TYPE       := '';
        S_ADS_DT            ACPPRAAM.ADS_DT%TYPE        := '';
        S_MED_DEPT_CD       ACPPRAAM.MED_DEPT_CD%TYPE   := '';
        S_WD_DEPT_CD        ACPPRAAM.WD_DEPT_CD%TYPE    := '';
        S_CHDR_STF_NO       ACPPRAAM.CHDR_STF_NO%TYPE   := '';
        S_ANDR_STF_NO       ACPPRAAM.ANDR_STF_NO%TYPE   := '';
        S_CLCTN_WD_DEPT_CD  ACPPRAAM.CLCTN_WD_DEPT_CD%TYPE  := '';
        S_EXM_CD            MSELMEBM.EXM_CD%TYPE            := '';
        S_TH1_SPCM_CD       MOOOREXM.TH1_SPCM_CD%TYPE       := '';
        S_PACT_TP_CD        MOOOREXM.PACT_TP_CD%TYPE        := '';
        S_MED_EXM_CTG_CD    MSELMEBM.MED_EXM_CTG_CD%TYPE    := '';

--        S_COMN_GRP_CD       CCCCCSTE.COMN_GRP_CD%TYPE       := '966';

        S_ACPT_DTM          DATE    := SYSDATE; -- 20211124001759
      
    BEGIN       
                                               
        S_EXM_CD := 'LTGX04'; -- (POCT) ABG & Na, K, Ca++, Lac, Glu
                
        -- 현재환자가 응급/입원/외래 환지인지 여부 확인
        BEGIN
            --2013.12.16 응급추가. 2014-09-02 응급을 먼저 체크
            SELECT /* XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_ABGA_ORDER_AUTO */
                   A.PACT_ID
                 , A.EMRM_ARVL_DTM
                 , A.MED_DEPT_CD
                 , NULL
                 , A.CHDR_STF_NO
                 , A.MEDR_STF_NO
                 , NVL(NVL(CTH_ITHD_MEDR_STF_NO, MEDR_STF_NO),'PPPPP')
--                 , NVL(IN_EXM_CD, ( SELECT Z.COMN_CD_NM
--                                       FROM CCCCCSTE Z
--                                      WHERE Z.COMN_GRP_CD = S_COMN_GRP_CD
--                                        AND Z.DTRL3_NM    = 'BST_INTERFACE'
--                                        AND ROWNUM        = 1
--                                   ))                EXM_CD
                 , 'AER'                             CLCTN_WD_DEPT_CD
                 , 'E'
              INTO S_PACT_ID
                 , S_ADS_DT
                 , S_MED_DEPT_CD
                 , S_WD_DEPT_CD
                 , S_CHDR_STF_NO
                 , S_ANDR_STF_NO
                 , S_ORD_STF_NO
--                 , S_EXM_CD
                 , S_CLCTN_WD_DEPT_CD
                 , S_PACT_TP_CD
              FROM ACPPRETM A
             WHERE A.PT_NO      = IN_PT_NO
               AND A.HSP_TP_CD  = HIS_HSP_TP_CD
               AND A.SIHS_YN    = 'Y'
               AND XSUP.FT_MSE_E_PTNO_1(A.PACT_ID, A.RPY_CLS_SEQ, A.HSP_TP_CD) = 'N'
               AND ROWNUM       = 1;                 

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    BEGIN  
                        SELECT /* XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_ABGA_ORDER_AUTO */
                               A.PACT_ID
                             , A.ADS_DT
                             , A.MED_DEPT_CD
                             , A.WD_DEPT_CD
                             , A.CHDR_STF_NO
                             , A.ANDR_STF_NO
                             , NVL(A.ANDR_STF_NO, 'CP00208') --전검 과장님 사번
                             , A.CLCTN_WD_DEPT_CD               CLCTN_WD_DEPT_CD
                             , 'I'
                          INTO S_PACT_ID
                             , S_ADS_DT
                             , S_MED_DEPT_CD
                             , S_WD_DEPT_CD
                             , S_CHDR_STF_NO
                             , S_ANDR_STF_NO
                             , S_ORD_STF_NO
                             , S_CLCTN_WD_DEPT_CD
                             , S_PACT_TP_CD
                          FROM ACPPRAAM A
                         WHERE A.PT_NO      = IN_PT_NO
                           AND A.HSP_TP_CD  = HIS_HSP_TP_CD
                           AND A.SIHS_YN    = 'Y'
                           AND XSUP.FT_MSE_I_PTNO_1(A.PACT_ID, A.HSP_TP_CD) = 'N'
                           AND ROWNUM       = 1;
                           
                                   
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                BEGIN
                                    SELECT /* XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_ABGA_ORDER_AUTO */
                                           A.PACT_ID                                                    -- 원무접수 ID
                                         , A.MTM_ARVL_DTM                                                -- 도착일시
                                         , A.MED_DEPT_CD                                                -- 진료과
                                         , NULL
                                         , NULL
                                         , A.MEDR_STF_NO                                                -- 진료의
                                         , A.MEDR_STF_NO 
                                         , 'O'
                                      INTO S_PACT_ID
                                         , S_ADS_DT
                                         , S_MED_DEPT_CD
                                         , S_WD_DEPT_CD
                                         , S_CHDR_STF_NO
                                         , S_ANDR_STF_NO
                                         , S_ORD_STF_NO
                                         , S_PACT_TP_CD
                                      FROM ACPPRODM A
                                     WHERE A.PT_NO      = IN_PT_NO
                                       AND A.MED_DT     = TRUNC(S_ACPT_DTM)
                                       AND A.HSP_TP_CD  = HIS_HSP_TP_CD
                                       AND A.APCN_DTM IS NULL
--                                       AND A.MED_DEPT_CD = IN_DEPT_CD
                                       AND ROWNUM       = 1;
                                       
                                     
                                     EXCEPTION
                                        WHEN NO_DATA_FOUND THEN
                                            S_PACT_TP_CD := '';
                                            
                                        WHEN  OTHERS  THEN
                                            IO_ERR_YN  := 'Y';
                                            IO_ERR_MSG := '외래환자정보 조회중 Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                                            RETURN;
                                END;

                                
                            WHEN OTHERS THEN
                                IO_ERR_YN  := 'Y';
                                IO_ERR_MSG := '입원환자정보 조회중 Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                                RETURN;
                    END;                        
                WHEN OTHERS THEN
                    IO_ERR_YN  := 'Y';
                    IO_ERR_MSG := '입원환자정보 조회중 Error발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM;
                    RETURN;
        END;


       
                    
        -- 2.1 검사분류조회
        BEGIN
            SELECT /* XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_ABGA_ORDER_AUTO */
                   MED_EXM_CTG_CD
              INTO S_MED_EXM_CTG_CD
              FROM MSELMEBM
             WHERE EXM_CD    = S_EXM_CD
               AND HSP_TP_CD = HIS_HSP_TP_CD ;
        END;   
        
        -- 2.2 오더발행
        BEGIN
            PC_MSE_INS_ADD_ORD ( IN_PT_NO
                               , TO_CHAR(S_ACPT_DTM, 'YYYYMMDD')
                               , HIS_HSP_TP_CD
                               , S_PACT_TP_CD
                               , S_MED_EXM_CTG_CD
                               , S_EXM_CD
                               , S_MED_DEPT_CD
                               , S_ORD_STF_NO
                               , ''
                               , 'Y'
                               , ''
                               , HIS_IP_ADDR
                               , HIS_PRGM_NM
                               , IO_ERR_YN
                               , IO_ERR_MSG
                               ) ;
        
            IF IO_ERR_YN = 'Y' THEN
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := 'PC_MSE_INS_ADD_ORD 에러 발생. ErrorMsg = ' || IO_ERR_MSG;
                RETURN;
            END IF;
            
            S_ORD_ID := IO_ERR_MSG;
        END;
            
        -- 3 채혈
        BEGIN
        
            XSUP.PKG_MSE_LM_BLCL.BLCL( 
                                       IN_PT_NO               --IN      VARCHAR2
                                     , S_ORD_ID               --IN      VARCHAR2 -- ,로 구분하여 멀티로 처리 가능함. 예 : 150029260,150029263,150029262,150029261,150029258,150029256,150029259,150029257,150029267
                        
                                     , HIS_HSP_TP_CD           --IN      VARCHAR2
                                     , HIS_STF_NO              --IN      VARCHAR2
                                     , HIS_PRGM_NM             --IN      VARCHAR2
                                     , HIS_IP_ADDR             --IN      VARCHAR2
                                                                
                                     , S_SPCM_NO              --IN OUT  VARCHAR2
                                     , IO_ERR_YN               --OUT     VARCHAR2
                                     , IO_ERR_MSG              --OUT     VARCHAR2 
                                     );

            IF IO_ERR_YN = 'Y' THEN
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := 'XSUP.PKG_MSE_LM_BLCL.BLCL 에러 발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERR_MSG;
                RETURN;
            END IF;

        END;                      
        
        -- 4 접수
        BEGIN
        
            BEGIN
                SELECT TH1_SPCM_CD
                  INTO S_TH1_SPCM_CD
                  FROM MOOOREXM
                 WHERE HSP_TP_CD = HIS_HSP_TP_CD
                   AND ORD_ID    = S_ORD_ID;                 
            END;
        
            XSUP.PKG_MSE_LM_SPCMACPT.ACPT( S_SPCM_NO       
                                         , IN_PT_NO        
                                         
                                         , TO_CHAR(S_ACPT_DTM, 'YYYYMMDD')
                                         , S_MED_EXM_CTG_CD
                                         , S_TH1_SPCM_CD
                            
                                         , '' --검체접수 비고
                                         
                                         , HIS_HSP_TP_CD
                                         , HIS_STF_NO   
                                         , HIS_PRGM_NM  
                                         , HIS_IP_ADDR  
                                         
                                         , IO_ERR_YN    
                                         , IO_ERR_MSG   
                                         );
            IF IO_ERR_YN = 'Y' THEN
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := 'XSUP.PKG_MSE_LM_SPCMACPT.ACPT 에러 발생. ErrCd = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERR_MSG;
                RETURN;
            END IF;

        END;
        


        IO_SPCM_NO := S_SPCM_NO;  
        IO_ERR_YN  := 'N';
        IO_ERR_MSG := '';
    END PC_MSE_ABGA_ORDER_AUTO; 
    


    /**********************************************************************************************
     *    서비스이름  : SAVE_CALC_HMTY_CBC_AUTO_VRFC
     *    최초 작성일 : 2022.04.18
     *    최초 작성자 : ezCaretech 홍승표
     *    Description : 혈액학검사실 일반혈액검사(CBC) 자동검증
     **********************************************************************************************/
    PROCEDURE PC_MSE_HMTY_CBC_AUTO_VRFC
                 ( IN_SAVEFLAG         IN      VARCHAR2
                 , IN_SPCM_NO          IN      MSELMAID.SPCM_NO%TYPE
                 
                 , HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                 , HIS_LSH_DTM         IN      MSELMAID.LSH_DTM%TYPE
                 , HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                 , HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                 , HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE
                 
                 , IO_ERR_YN           IN OUT  VARCHAR2
                 , IO_ERR_MSG          IN OUT  VARCHAR2 
                 )
                 
    AS
    
        V_EXRS_CNTE           VARCHAR2(32767) :=  '';                             
        V_MIDL_BRFG_CNTE      VARCHAR2(4000)  :=  '';      
        V_RSLT_BRFG_CNTE      VARCHAR2(4000)  :=  '';      
        
        V_EXRS_RMK_CNTE       VARCHAR2(4000)  :=  '';                             
        V_EXRM_RMK_CNTE       VARCHAR2(4000)  :=  '';      
            
        V_USE_YN              VARCHAR2(0001) := '';
        V_ORDCD_YN            VARCHAR2(0001) := '';
        V_CNT_YN              VARCHAR2(0001) := '';
        V_RSLT_NULL_CNT_YN    VARCHAR2(0001) := '';
                                                   
        V_SYSDATE             DATE;  
        V_AUTO_VRFC_YN        VARCHAR2(0001) := '';
        V_FLAG_CNT            NUMBER;  
        V_FLAG                VARCHAR2(0100) := '';
        
    BEGIN    
    
        BEGIN                
           SELECT DECODE(COUNT(*), 0, 'N', 'Y')
             INTO V_USE_YN
             FROM MSELMSID
            WHERE HSP_TP_CD    = HIS_HSP_TP_CD
              AND LCLS_COMN_CD = 'CALC_CBC_AUTO_VRFC'       
              AND SCLS_COMN_CD = 'USE_YN'
              AND USE_YN       = 'Y'
             ;                           
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
        END;

        IF V_USE_YN != 'Y' THEN
            RETURN;
        END IF;              
                                                                          

        -- 자동검증할 기준 처방코드 유무 확인
        BEGIN                
           SELECT DECODE(COUNT(*), 0, 'N', 'Y')
             INTO V_ORDCD_YN
             FROM MOOOREXM
            WHERE HSP_TP_CD    = HIS_HSP_TP_CD
              AND SPCM_PTHL_NO = IN_SPCM_NO
              AND ORD_CD    IN (SELECT DISTINCT SCLS_COMN_CD_NM
                                  FROM MSELMSID
                                 WHERE HSP_TP_CD    = HIS_HSP_TP_CD
                                   AND LCLS_COMN_CD = 'CALC_CBC_AUTO_VRFC'       
                                   AND USE_YN       = 'Y'
                               )
              AND ODDSC_TP_CD          = 'C'
              AND EXM_RTN_REQ_DTM IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
              AND NVL(PRN_ORD_YN, 'N') = 'N'
             ;                           
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
        END;
        
        IF V_ORDCD_YN != 'Y' THEN
            RETURN;
        END IF;                     
                          

        -- 자동검증 처방코드는 해당 검체번호에 하나만 존재해야함.
        BEGIN                
           SELECT DECODE(COUNT(*), 1, 'Y', 'N')
             INTO V_CNT_YN
             FROM MOOOREXM
            WHERE HSP_TP_CD    = HIS_HSP_TP_CD
              AND SPCM_PTHL_NO = IN_SPCM_NO
              AND ODDSC_TP_CD          = 'C'
              AND EXM_RTN_REQ_DTM IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
              AND NVL(PRN_ORD_YN, 'N') = 'N'
             ;                           
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
        END;
                                             
        IF V_CNT_YN != 'Y' THEN
            RETURN;
        END IF;                     
                          

        -- 자동검증 처방코드 조회한 후, 결과값이 공란이면 안되는 검사코드를 비교한다.
        BEGIN                
            SELECT DECODE(COUNT(*), 0, 'Y', 'N')
              INTO V_RSLT_NULL_CNT_YN
              FROM MSELMAID
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND SPCM_NO   = IN_SPCM_NO
               AND ORD_CD    = (SELECT ORD_CD
                                  FROM MOOOREXM
                                 WHERE HSP_TP_CD    = HIS_HSP_TP_CD
                                   AND SPCM_PTHL_NO = IN_SPCM_NO
                                   AND ODDSC_TP_CD          = 'C'
                                   AND EXM_RTN_REQ_DTM IS NULL -- 환불요청된 처방은 ODDSC_TP_CD는 C 이지만 EXM_RTN_REQ_DTM 에 환불요청 일시가 저장됨.
                                   AND NVL(PRN_ORD_YN, 'N') = 'N'
                               ) 
               AND EXM_CD   IN (SELECT DISTINCT TH1_RMK_CNTE
                                  FROM MSELMSID
                                 WHERE HSP_TP_CD    = HIS_HSP_TP_CD
                                   AND LCLS_COMN_CD = 'CALC_CBC_AUTO_VRFC'       
                                   AND USE_YN       = 'Y'
                               )
               AND TRIM(SMP_EXRS_CNTE) IS NULL
               ;                         
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
        END;                            

        IF V_RSLT_NULL_CNT_YN != 'Y' THEN
            RETURN;
        END IF;                     
                          
          
        -- FLAG : 1개의 NNNNN 만 나와야 정상결과임. 모든 검사코드가 YYYYY이면 정상결과는 아님.(참고치 H/L 적용하면서, YYYYY는 발생하지 않음.)
        BEGIN                        
            BEGIN
                SELECT COUNT(*)
                  INTO V_FLAG_CNT
                  FROM (    SELECT NVL(A.DLT_YN,'N')
                                || NVL(A.PNC_YN,'N')
                                || NVL(A.CVR_YN,'N')
                                || NVL(A.AMR_YN,'N') 
                                || NVL(XSUP.FT_MSE_RFVL_CHECK(A.PT_NO, A.EXM_CD, A.SMP_EXRS_CNTE, A.EXM_HOPE_DT, P.SEX_TP_CD, P.PT_BRDY_DT, 'C1', A.HSP_TP_CD), 'N')
                                FLAG
                              FROM MSELMAID A
                                 , PCTPCPAM_DAMO P
                             WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                               AND A.SPCM_NO   = IN_SPCM_NO
                               AND A.PT_NO     = P.PT_NO
                             GROUP BY  NVL(A.DLT_YN,'N')
                                     , NVL(A.PNC_YN,'N')
                                     , NVL(A.CVR_YN,'N')
                                     , NVL(A.AMR_YN,'N')
                                     , NVL(XSUP.FT_MSE_RFVL_CHECK(A.PT_NO, A.EXM_CD, A.SMP_EXRS_CNTE, A.EXM_HOPE_DT, P.SEX_TP_CD, P.PT_BRDY_DT, 'C1', A.HSP_TP_CD), 'N')
                        )
                 ;
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
            END;                                                     
                                                         
            -- NNNNN OR YYYYY이거나 무조건 1개만 나와야 됨.        
            IF V_FLAG_CNT != 1 THEN
                RETURN;
            END IF;
            
            BEGIN
                SELECT NVL(A.DLT_YN,'N')
                    || NVL(A.PNC_YN,'N')
                    || NVL(A.CVR_YN,'N')
                    || NVL(A.AMR_YN,'N')
                    || NVL(XSUP.FT_MSE_RFVL_CHECK(A.PT_NO, A.EXM_CD, A.SMP_EXRS_CNTE, A.EXM_HOPE_DT, P.SEX_TP_CD, P.PT_BRDY_DT, 'C1', A.HSP_TP_CD), 'N')
                  INTO V_FLAG
                  FROM MSELMAID A                 
                     , PCTPCPAM_DAMO P 
                 WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                   AND A.SPCM_NO   = IN_SPCM_NO           
                   AND A.PT_NO     = P.PT_NO
                 GROUP BY  NVL(A.DLT_YN,'N')
                         , NVL(A.PNC_YN,'N')
                         , NVL(A.CVR_YN,'N')
                         , NVL(A.AMR_YN,'N')
                         , NVL(XSUP.FT_MSE_RFVL_CHECK(A.PT_NO, A.EXM_CD, A.SMP_EXRS_CNTE, A.EXM_HOPE_DT, P.SEX_TP_CD, P.PT_BRDY_DT, 'C1', A.HSP_TP_CD), 'N')
                 ;
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
            END;            

            -- NNNNN 가 아니면 모두 비정상결과
            IF V_FLAG != 'NNNNN' THEN
                RETURN;
            END IF;
        END;


        BEGIN    
        
            BEGIN
                SELECT SYSDATE
                  INTO V_SYSDATE
                  FROM DUAL;
            END;

        
            FOR REC IN ( SELECT A.HSP_TP_CD
                              , A.PT_NO
                              , A.SPCM_NO
                              , A.EXRM_EXM_CTG_CD
                              , A.WK_UNIT_CD
                              , A.EXM_CD
                           FROM MSELMAID A
                          WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                            AND A.SPCM_NO   = IN_SPCM_NO
                            AND A.ORD_CD   IN (SELECT AA.EXM_CD
                                                 FROM MSELMEBM AA
                                                WHERE AA.HSP_TP_CD              = HIS_HSP_TP_CD
                                                  AND NVL(AA.AUTO_VRFC_YN, 'N') = 'Y'
                                                  AND NVL(AA.MGMT_EXCN_YN, 'N') = 'N'
                                              )
                          GROUP BY A.HSP_TP_CD, A.PT_NO, A.SPCM_NO, A.EXRM_EXM_CTG_CD, A.WK_UNIT_CD, A.EXM_CD
                          ORDER BY A.HSP_TP_CD, A.PT_NO, A.SPCM_NO, A.EXRM_EXM_CTG_CD, A.WK_UNIT_CD, A.EXM_CD
                       )
            LOOP    

                    -- DB에 저장된 결과를 다시 조회하여 XSUP.PKG_MSE_LM_EXAMRSLT.SAVE 로 저장한다.
                    BEGIN
                        SELECT EXRS_CNTE
                             , MIDL_BRFG_CNTE
                             , RSLT_BRFG_CNTE
                             , EXRS_RMK_CNTE
                             , EXRM_RMK_CNTE
                          INTO V_EXRS_CNTE
                             , V_MIDL_BRFG_CNTE
                             , V_RSLT_BRFG_CNTE
                             , V_EXRS_RMK_CNTE
                             , V_EXRM_RMK_CNTE
                          FROM MSELMAID
                         WHERE HSP_TP_CD = HIS_HSP_TP_CD
                           AND SPCM_NO   = REC.SPCM_NO
                           AND EXM_CD    = REC.EXM_CD
                           ;            
                    END;
                                
            
                    -- 자동검증 업데이트
                    ---> ORD_CD 로 LOOP 돌려서 다시 EXM_CD 찾아서 XSUP.PKG_MSE_LM_EXAMRSLT.SAVE 로 저장한다.
                    XSUP.PKG_MSE_LM_EXAMRSLT.SAVE
                                 (  'C'                                        -- T:임시저장, P:중간, C:검증
                                  , REC.PT_NO                                  -- 환자번호
                                  , REC.SPCM_NO
                                  , REC.EXRM_EXM_CTG_CD                        -- IN_EXM_CTG_CD       IN      MSELMAID.EXRM_EXM_CTG_CD%TYPE
                                  , REC.WK_UNIT_CD                             -- IN_WK_UNIT_CD       IN      MSELMAID.WK_UNIT_CD%TYPE
                                  , REC.EXM_CD                                 -- IN_EXM_CD           IN      MSELMAID.EXM_CD%TYPE
                                  
                                  , V_MIDL_BRFG_CNTE                           -- IN_MIDL_BRFG_CNTE   IN      MSELMAID.MIDL_BRFG_CNTE%TYPE                                  
                                  , V_EXRS_CNTE                                -- IN_EXRS_CNTE        IN      MSELMAID.EXRS_CNTE%TYPE
                
                                  , ''                                         -- IN_RMK_CNTE         IN      MSELMCED.RMK_CNTE%TYPE
                                  , ''                                         -- IN_LMQC_RMK_CNTE    IN      MSELMCED.LMQC_RMK_CNTE%TYPE
                                  , V_EXRS_RMK_CNTE                            -- IN_EXRS_RMK_CNTE    IN      MSELMAID.EXRS_RMK_CNTE%TYPE
                                  , V_EXRM_RMK_CNTE                            -- IN_EXRM_RMK_CNTE    IN      MSELMAID.EXRM_RMK_CNTE%TYPE
                                 
                                  , ''                                         -- IN      MSELMAID.DLT_YN%TYPE
                                  , ''                                         -- IN      MSELMAID.PNC_YN%TYPE
                                  , ''                                         -- IN_CVR_YN         --  IN      MSELMAID.CVR_YN%TYPE
                                 
                                  , HIS_STF_NO                                 -- HIS_STF_NO          IN      MSELMAID.FSR_STF_NO%TYPE
                                  , HIS_HSP_TP_CD                              -- HIS_HSP_TP_CD       IN      MSELMAID.HSP_TP_CD%TYPE
                                  , HIS_PRGM_NM                                -- HIS_PRGM_NM         IN      MSELMAID.LSH_PRGM_NM%TYPE
                                  , HIS_IP_ADDR                                -- HIS_IP_ADDR         IN      MSELMAID.LSH_IP_ADDR%TYPE

                                  , V_RSLT_BRFG_CNTE                           -- IN_RSLT_BRFG_CNTE   IN      MSELMAID.RSLT_BRFG_CNTE%TYPE
                                 
                                  , IO_ERR_YN -- IO_ERR_YN           IN OUT  VARCHAR2
                                  , IO_ERR_MSG --IO_ERR_MSG          IN OUT  VARCHAR2 
                                 );
                 
                    IF IO_ERR_YN = 'Y' THEN
                        RETURN;
                    END IF;
                    

                    BEGIN
                        UPDATE MSELMAID
                           SET AUTO_VRFC_YN      = 'Y'
                             , LST_RSLT_VRFC_DTM = V_SYSDATE
                             
                             , LSH_DTM           = V_SYSDATE
                             , LSH_STF_NO        = HIS_STF_NO
                             , LSH_PRGM_NM       = HIS_PRGM_NM || ' 혈액학검사실 일반혈액검사(CBC) 자동검증'
                             , LSH_IP_ADDR       = HIS_IP_ADDR
                         WHERE HSP_TP_CD         = HIS_HSP_TP_CD
                           AND SPCM_NO           = REC.SPCM_NO
                           AND EXM_CD            = REC.EXM_CD 
                           ;
                        EXCEPTION
                            WHEN OTHERS THEN
                                RETURN;
                    END;
                    
                    BEGIN            
                        UPDATE MSELMVID
                           SET LSH_STF_NO        = HIS_STF_NO
                             , LSH_DTM           = V_SYSDATE
                             , LSH_PRGM_NM       = HIS_PRGM_NM || ' 혈액학검사실 일반혈액검사(CBC) 자동검증'
                             , LSH_IP_ADDR       = HIS_IP_ADDR                   
                         WHERE HSP_TP_CD         = HIS_HSP_TP_CD
                           AND SPCM_NO           = REC.SPCM_NO
                           AND EXM_CD            = REC.EXM_CD 
                           AND EXRS_VRFC_STS_CD  = 'C'
                           ;
                        EXCEPTION
                            WHEN OTHERS THEN
                                NULL;
                    END;             
                    
                         
                                        
                    
            END LOOP;                        
        END;        

                                                                                                    
        

--        -- 자동검증 업데이트 --> 아래의 최종검증 후 업데이트할 컬럼 방식은 사용하지 않기로 함. 추가적으로 변경이 필요할 경우가 발생한다면 관리의 어려움 있음.
--        -- 자동검증 업데이트


--
--                    -- FLAG : 1개의 NNNN 만 나와야 정상결과임. 모든 검사코드가 YYYY이면 정상결과는 아님.
--                    BEGIN                
--                    
--                        BEGIN
--                            SELECT COUNT(*)
--                              INTO V_FLAG_CNT
--                              FROM (    SELECT NVL(A.DLT_YN,'N')
--                                            || NVL(A.PNC_YN,'N')
--                                            || NVL(A.CVR_YN,'N')
--                                            || NVL(A.AMR_YN,'N') FLAG
--                                          FROM MSELMAID A
--                                         WHERE HSP_TP_CD = REC.HSP_TP_CD
--                                           AND SPCM_NO   = REC.SPCM_NO
--                                           AND ORD_CD    = REC.EXM_CD
--                                         GROUP BY  NVL(A.DLT_YN,'N')
--                                                 , NVL(A.PNC_YN,'N')
--                                                 , NVL(A.CVR_YN,'N')
--                                                 , NVL(A.AMR_YN,'N')
--                                    )
--                             ;
--                            EXCEPTION
--                                WHEN OTHERS THEN
--                                    NULL;
--                        END;                                                     
--                                   
--                        -- NNNN OR YYYY이거나 무조건 1개만 나와야 됨.        
--                        CONTINUE WHEN V_FLAG_CNT != 1;            
--                        
--                        BEGIN
--                             SELECT NVL(A.DLT_YN,'N')
--                                || NVL(A.PNC_YN,'N')
--                                || NVL(A.CVR_YN,'N')
--                                || NVL(A.AMR_YN,'N') FLAG
--                                 INTO V_FLAG
--                              FROM MSELMAID A
--                             WHERE HSP_TP_CD = REC.HSP_TP_CD
--                               AND SPCM_NO   = REC.SPCM_NO
--                               AND ORD_CD    = REC.ORD_CD
--                             GROUP BY  NVL(A.DLT_YN,'N')
--                                     , NVL(A.PNC_YN,'N')
--                                     , NVL(A.CVR_YN,'N')
--                                     , NVL(A.AMR_YN,'N')
--                             ;
--                            EXCEPTION
--                                WHEN OTHERS THEN
--                                    NULL;
--                        END;            
--            
--                        -- NNNN 가 아니면 모두 비정상결과
--                        CONTINUE WHEN V_FLAG != 'NNNN';
--
--                    END;
--            

                    
--        BEGIN            
--
--            BEGIN            
--                UPDATE MSELMCED
--                   SET EXM_PRGR_STS_CD = 'N'
--                     , BRFG_DTM        = HIS_LSH_DTM
--                       
--                     , LSH_STF_NO      = HIS_STF_NO
--                     , LSH_DTM         = HIS_LSH_DTM
--                     , LSH_PRGM_NM     = HIS_PRGM_NM || ' 혈액학검사실 일반혈액검사(CBC) 자동검증'
--                     , LSH_IP_ADDR     = HIS_IP_ADDR                   
--                 WHERE HSP_TP_CD       = HIS_HSP_TP_CD
--                   AND SPCM_NO         = IN_SPCM_NO  
--                ;                   
--                EXCEPTION
--                    WHEN OTHERS THEN
--                        NULL;
--            END;                                           
--        
--            BEGIN            
--                UPDATE MSELMAID
--                   SET INTF_SND_YN       = 'N'           -- 인터페이스전송여부
--                     , LST_EXM_YN        = 'Y'           -- 최종검사여부
--                     , RSLT_BRFG_YN      = 'Y'           -- 결과보고여부
--                     , SPEX_PRGR_STS_CD  = '3'           -- 검체검사진행상태코드
--                     , EXRS_VRFC_STS_CD  = 'C'           -- 검사결과검증상태코드
--                     , LST_RSLT_VRFC_DTM = HIS_LSH_DTM   -- 최종결과검증일시
--                       
--                     , LSH_STF_NO        = HIS_STF_NO
--                     , LSH_DTM           = HIS_LSH_DTM
--                     , LSH_PRGM_NM       = HIS_PRGM_NM || ' 혈액학검사실 일반혈액검사(CBC) 자동검증'
--                     , LSH_IP_ADDR       = HIS_IP_ADDR                   
--                 WHERE HSP_TP_CD         = HIS_HSP_TP_CD
--                   AND SPCM_NO           = IN_SPCM_NO  
--                ;                   
--                EXCEPTION
--                    WHEN OTHERS THEN
--                        NULL;
--            END;                                           
--                             
--            BEGIN            
--                UPDATE MOOOREXM U
--                   SET EXM_PRGR_STS_CD = 'N'
--                     , BRFG_DTM        = HIS_LSH_DTM
--                     , BRFG_STF_NO     = HIS_STF_NO
--                     
--                     , LSH_STF_NO      = HIS_STF_NO
--                     , LSH_DTM         = HIS_LSH_DTM
--                     , LSH_PRGM_NM     = HIS_PRGM_NM || ' 혈액학검사실 일반혈액검사(CBC) 자동검증'
--                     , LSH_IP_ADDR     = HIS_IP_ADDR                   
--                 WHERE HSP_TP_CD       = HIS_HSP_TP_CD  
--                   AND SPCM_PTHL_NO    = IN_SPCM_NO
--                   ;
--                EXCEPTION
--                    WHEN OTHERS THEN
--                        NULL;
--            END;                         
--
--            BEGIN            
--                UPDATE MSELMVID U
--                   SET EXRS_VRFC_STS_CD = 'C'           
--                     , LST_VRFC_YN      = 'Y'
--                     , FSR_DTM          = HIS_LSH_DTM 
--                     
--                     , LSH_STF_NO       = HIS_STF_NO
--                     , LSH_DTM          = HIS_LSH_DTM 
--                     , LSH_PRGM_NM      = HIS_PRGM_NM || ' 혈액학검사실 일반혈액검사(CBC) 자동검증'
--                     , LSH_IP_ADDR      = HIS_IP_ADDR                   
--                 WHERE HSP_TP_CD        = HIS_HSP_TP_CD  
--                   AND SPCM_NO          = IN_SPCM_NO
--                   AND EXRS_VRFC_STS_CD = 'T'
--                   ;
--                EXCEPTION
--                    WHEN OTHERS THEN
--                        NULL;
--            END;             
--        END;             
            
    END PC_MSE_HMTY_CBC_AUTO_VRFC;    

                     
    
    
    /**********************************************************************************************
     *    서비스이름  : PC_MSE_SPCD_STRG_INFO_SAVE
     *    최초 작성일 : 2022.04.30
     *    최초 작성자 : ezCaretech 홍승표
     *    Description : 검체보관정보 저장(ACK 검체보관정보 프로그램에서 HIS로 저장)
     **********************************************************************************************/
    PROCEDURE PC_MSE_SPCD_STRG_INFO_SAVE(    IN_HSP_TP_CD      IN      VARCHAR2   -- < P0>병원구분                                                                
                                           , IN_KEEPIDNO       IN      VARCHAR2   -- < P1>등록번호
                                           , IN_KEEPLBDT       IN      VARCHAR2   -- < P2>접수일자
                                           , IN_KEEPLBNO       IN      VARCHAR2   -- < P3>검사번호
                                           , IN_KEEPITEM       IN      VARCHAR2   -- < P4>SLIP 코드
                                           , IN_KEEPACDT       IN      VARCHAR2   -- < P5>바코드 출력일자
                                           , IN_KEEPSPNO       IN      VARCHAR2   -- < P6>검체번호
                                           , IN_KEEPKPDT       IN      VARCHAR2   -- < P7>검체 보관일자
                                           , IN_KEEPRACK       IN      VARCHAR2   -- < P8>검체 보관RACK
                                           , IN_KEEPPOSX       IN      VARCHAR2   -- < P9>검체 보관RACK X Position
                                           , IN_KEEPPOSY       IN      VARCHAR2   -- <P10>검체 보관RACK Y Position
                                           , IN_KEEPUSER       IN      VARCHAR2   -- <P11>검체 보관자 ID
                                           , IN_KEEPDESC       IN      VARCHAR2   -- <P12>기타 기재사항 
                                           , IN_KEEPUPDT       IN      VARCHAR2   -- <P13>최종 Update 일시
                                           , IN_KEEPETC1       IN      VARCHAR2   -- <P14>여유1
                                           , IN_KEEPETC2       IN      VARCHAR2   -- <P15>여유2
                                           , IO_RESULT         IN OUT  VARCHAR2   -- 결과
                                           , IO_ERRYN          IN OUT  VARCHAR2   -- 오류여부
                                           , IO_ERRMSG         IN OUT  VARCHAR2   -- 오류메세지
                                        )
     
    AS
        
    BEGIN
                   
        IO_RESULT        := '';
        IO_ERRYN         := 'N';
        IO_ERRMSG        := '';
        
        BEGIN     

                    
            DELETE /* XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_SPCD_STRG_INFO_SAVE */
              FROM HINF.OSSKEEPM
             WHERE HSP_TP_CD  = IN_HSP_TP_CD
               AND KEEPLBDT   = IN_KEEPLBDT
               AND KEEPSPNO   = IN_KEEPSPNO 
--               AND KEEPLBNO   = IN_KEEPLBNO               
--               AND KEEPITEM   = IN_KEEPITEM
               ;

            INSERT /* XSUP.PKG_MSE_LM_INTERFACE.PC_MSE_SPCD_STRG_INFO_SAVE */
              INTO HINF.OSSKEEPM
                 (
                   HSP_TP_CD
                 , KEEPIDNO
                 , KEEPLBDT
                 , KEEPLBNO
                 , KEEPITEM
                 , KEEPACDT
                 , KEEPSPNO
                 , KEEPKPDT
                 , KEEPRACK
                 , KEEPPOSX
                 , KEEPPOSY
                 , KEEPUSER
                 , KEEPDESC
                 , KEEPUPDT
                 , KEEPETC1
                 , KEEPETC2
                 )
            VALUES
                 (
                   IN_HSP_TP_CD
                 , IN_KEEPIDNO
                 , TO_DATE(IN_KEEPLBDT, 'YYYY-MM-DD')
                 , IN_KEEPLBNO
                 , IN_KEEPITEM
                 , TO_DATE(IN_KEEPACDT, 'YYYY-MM-DD HH24:MI:SS')
                 , IN_KEEPSPNO
                 , TO_DATE(IN_KEEPKPDT, 'YYYY-MM-DD HH24:MI:SS')
                 , IN_KEEPRACK
                 , IN_KEEPPOSX
                 , IN_KEEPPOSY
                 , IN_KEEPUSER
                 , IN_KEEPDESC
                 , DECODE(IN_KEEPUPDT, NULL, SYSDATE,  TO_DATE(IN_KEEPUPDT, 'YYYY-MM-DD HH24:MI:SS'))
                 , IN_KEEPETC1
                 , IN_KEEPETC2
                 );      
            EXCEPTION           
                WHEN OTHERS THEN
                    IO_ERRYN  := 'Y';
                    IO_ERRMSG := '검체보관정보 인터페이스 저장 중 에러 발생 ERROR = ' 
                                || SQLERRM 
                                || ' IN_KEEPLBDT : ' || IN_KEEPLBDT || CHR(13)
                                || ' IN_KEEPSPNO : ' || IN_KEEPSPNO || CHR(13)
                                || ' IN_KEEPITEM : ' || IN_KEEPITEM || CHR(13)
                                ;
                    IO_RESULT := IO_ERRMSG;
                    RETURN;                                         
        END;

        IO_RESULT        := '검체보관정보 저장성공';
        IO_ERRYN         := 'N';
        IO_ERRMSG        := '';

                                 
    END PC_MSE_SPCD_STRG_INFO_SAVE;     





END PKG_MSE_LM_INTERFACE;