PACKAGE BODY           PKG_MSE_LM_ORDER      
IS
                                   
    /**********************************************************************************************
    *    서비스이름  : SAVE_ADDORDER
    *    최초 작성일 : 2022.03.02
    *    최초 작성자 : ezCaretech SCS
    *    DESCRIPTION : 추가처방발행
    *    수 정 사 항 : 
    **********************************************************************************************/
    PROCEDURE SAVE_ADDORDER
    (
      IN_PT_NO               IN      VARCHAR2 
    , IN_SPCM_NO             IN      VARCHAR2
    , IN_ORG_ORD_ID          IN      VARCHAR2 -- 원처방 아이디. 원처방 아이디가 있을경우 그 처방의 검체번호로 처방발행함.

    , IN_ORD_DT              IN      VARCHAR2 
    , IN_ORD_CD              IN      VARCHAR2
    , IN_ORD_RMK_CNTE        IN      VARCHAR2 -- 처방비고
    
    , HIS_HSP_TP_CD          IN      VARCHAR2
    , HIS_STF_NO             IN      VARCHAR2
    , HIS_PRGM_NM            IN      VARCHAR2
    , HIS_IP_ADDR            IN      VARCHAR2

    , IO_ORD_ID              OUT     VARCHAR2
    , IO_ERR_YN              OUT     VARCHAR2
    , IO_ERR_MSG             OUT     VARCHAR2 
    )
    IS
        V_MEDDR_STF_NO       VARCHAR2(20); -- 처방발행의

        V_RPY_PACT_ID        ACPPRODM.RPY_PACT_ID%TYPE;
        V_RPY_CLS_SEQ        ACPPRODM.RPY_CLS_SEQ%TYPE;
        V_PACT_ID            ACPPRODM.PACT_ID%TYPE    ;
        V_RNS_DR_STF_NO      VARCHAR2(20)             ;
        
        
--        V_SEND_HSP_TP_CD     MSELMERD.HSP_TP_CD%TYPE;
        V_CUSTCD             VARCHAR2(20); -- 미수등록을 위한 계약처코드
        V_MED_DEPT           MOOOREXM.PBSO_DEPT_CD%TYPE := 'LM';
        
        V_ORD_CD             MOOOREXM.ORD_CD%TYPE := '';
        V_ORD_NM             CCOOCBAC.ORD_NM%TYPE := '';
        V_MIF_CD             MOOOREXM.MIF_CD%TYPE := '';
        V_ORD_CTG_CD         CCOOCBAC.ORD_CTG_CD%TYPE := '';
        V_TH1_SPCM_CD        CCOOCBAC.TH1_SPCM_CD%TYPE := '';
        V_CHC_EXM_YN         CCOOCBAC.CHC_EXM_YN%TYPE := '';

--        V_TH2_SPCM_CD        CCOOCBAC.TH1_SPCM_CD%TYPE := '';
        V_ORD_SLIP_CTG_CD    CCOOCBAC.ORD_SLIP_CTG_CD%TYPE := '';
        V_MAXSEQ             MOOOREXM.SCRN_SORT_SEQ%TYPE := '';
        V_AOA_WKDP_CD        CNLRRUSD.AOA_WKDP_CD%TYPE := '';
        V_MEDR_AOA_WKDP_CD   CNLRRUSD.AOA_WKDP_CD%TYPE := '';
        V_MEDR_AADP_CD       CNLRRUSD.AADP_CD%TYPE := '';

        --수납관련
        V_REMARK             VARCHAR2(4000);
        V_PAYT_CHK           VARCHAR2(100);
        
        V_EXISTS_CNT         NUMBER;
        
        V_PATH_ORD_CD        MSELMEBM.EXM_CD%TYPE;
        V_PATH_ORD_NM        MSELMEBM.EITM_NM%TYPE;  
        V_PATH_EXM_CTG_CD    MSELMEBM.EXRM_EXM_CTG_CD%TYPE;        

        V_ORG_PACT_TP_CD     MOOOREXM.PACT_TP_CD%TYPE;
        V_ORG_PACT_ID        MOOOREXM.PACT_ID%TYPE;
        V_ORG_MED_DEPT_CD    MOOOREXM.PBSO_DEPT_CD%TYPE;
        V_ORG_SIHS_YN        ACPPRAAM.SIHS_YN%TYPE;
        
        V_PACT_TP_CD         MOOOREXM.PACT_TP_CD%TYPE;
        V_CNSG_ACPT_DTM      MSEPMERD.CNSG_ACPT_DTM%TYPE;
        
        V_RSCH_PRJT_NO       MOOOREXM.RSCH_PRJT_NO%TYPE;
        
        V_BNMR_EXM_ACPT_NO   VARCHAR2(10);
    BEGIN 

        IF SUBSTR(IN_ORD_CD, 1, 1) = 'L' THEN
            V_MED_DEPT := 'LM';     
            --V_MEDDR_STF_NO := 'CP99999'; --일반의        
            V_MEDDR_STF_NO := HIS_STF_NO;
        ELSE
            V_MED_DEPT := 'NM';     
            V_MEDDR_STF_NO := 'NM99999'; --일반의      
        END IF;
          
        IF IN_ORG_ORD_ID IS NOT NULL THEN
            
            BEGIN
                SELECT O.TH1_SPCM_CD
                     , O.PACT_TP_CD
                     , O.PACT_ID
                     , O.RSCH_PRJT_NO
                  INTO V_TH1_SPCM_CD
                     , V_ORG_PACT_TP_CD
                     , V_ORG_PACT_ID
                     , V_RSCH_PRJT_NO
                  FROM MOOOREXM O
                 WHERE O.HSP_TP_CD    = HIS_HSP_TP_CD
                   AND O.SPCM_PTHL_NO = IN_SPCM_NO
                   AND O.ORD_ID       = IN_ORG_ORD_ID
                   
                ;
                EXCEPTION
                    WHEN OTHERS THEN
                         IO_ERR_YN  := 'Y';
                         IO_ERR_MSG := '원처방정보 조회시 에러 발생. Error = ' || TO_CHAR(SQLERRM);
                         RETURN;            
            END;            
            
            BEGIN
                SELECT COUNT(*)
                  INTO V_EXISTS_CNT
                  FROM MSELMPMD
                 WHERE HSP_TP_CD = HIS_HSP_TP_CD
                   AND EXM_CD    = IN_ORD_CD
                   AND SPCM_CD   = V_TH1_SPCM_CD 
                ;
                IF V_EXISTS_CNT = 0 THEN
                    IO_ERR_YN  := 'Y';
                    IO_ERR_MSG := '원처방의 검체정보와 발행하려는 처방의 검체정보가 일치하지 않습니다. 원처방의 검체 : ' || V_TH1_SPCM_CD;
                    RETURN;
                END IF;            
            END; 
            
            
            IF V_ORG_PACT_TP_CD = 'O' THEN
                BEGIN
                    V_PACT_TP_CD := 'O';
                    
                    SELECT MED_DEPT_CD
                      INTO V_ORG_MED_DEPT_CD
                      FROM ACPPRODM
                     WHERE HSP_TP_CD = HIS_HSP_TP_CD
                       AND PACT_ID   = V_ORG_PACT_ID
                    ;   
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL; 
                END;
            ELSIF V_ORG_PACT_TP_CD = 'I' THEN
                BEGIN
                    V_PACT_TP_CD := 'I';      
                                    
                    SELECT PACT_ID
                         , PACT_ID
                         , RPY_CLS_SEQ
                         , MED_DEPT_CD
                         , SIHS_YN
                      INTO V_PACT_ID
                         , V_RPY_PACT_ID
                         , V_RPY_CLS_SEQ
                         , V_ORG_MED_DEPT_CD
                         , V_ORG_SIHS_YN
                      FROM ACPPRAAM
                     WHERE HSP_TP_CD = HIS_HSP_TP_CD
                       AND PACT_ID   = V_ORG_PACT_ID
                    ;
                    

                    --재원중이 아니면 입원 PACT_ID 에 처방연결 못함
                    IF V_ORG_SIHS_YN = 'N' THEN
                        V_PACT_ID := '';
                        V_RPY_PACT_ID := '';
                        V_RPY_CLS_SEQ := '';
                    END IF;
                    
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                END;
            ELSIF V_ORG_PACT_TP_CD = 'E' THEN
                BEGIN
                    V_PACT_TP_CD := 'E';      
                                    
                    SELECT PACT_ID
                         , PACT_ID
                         , RPY_CLS_SEQ
                         , EMRG_MAIN_MED_DEPT_CD
                         , SIHS_YN
                      INTO V_PACT_ID
                         , V_RPY_PACT_ID
                         , V_RPY_CLS_SEQ
                         , V_ORG_MED_DEPT_CD
                         , V_ORG_SIHS_YN
                      FROM ACPPRETM
                     WHERE HSP_TP_CD = HIS_HSP_TP_CD
                       AND PACT_ID   = V_ORG_PACT_ID
                    ;   
                    --재원중이 아니면 입원 PACT_ID 에 처방연결 못함
                    IF V_ORG_SIHS_YN = 'N' THEN
                        V_PACT_ID := '';
                        V_RPY_PACT_ID := '';
                        V_RPY_CLS_SEQ := '';
                    END IF;
                       
  
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                END;                
            END IF;
            
            
            -- 미래수진 찾기. 원처방의 부서로 미래의 외래 수진찾음.
            IF V_PACT_ID IS NULL AND V_ORG_MED_DEPT_CD IS NOT NULL THEN
            
                BEGIN
                    SELECT PACT_ID
                         , RPY_PACT_ID 
                      INTO V_PACT_ID
                         , V_RPY_PACT_ID
                      FROM ACPPRODM A
                     WHERE HSP_TP_CD   = HIS_HSP_TP_CD
                       AND PT_NO       = IN_PT_NO
                       AND PACT_ID    != V_ORG_PACT_ID
                       AND APCN_DTM    IS NULL    --접수취소일자
                       AND MED_DEPT_CD = V_ORG_MED_DEPT_CD
                       AND MED_DT      = (SELECT MIN(MED_DT)
                                            FROM ACPPRODM
                                           WHERE APCN_DTM     IS NULL
                                             AND HSP_TP_CD    = A.HSP_TP_CD
                                             AND PT_NO        = A.PT_NO
                                             AND MED_DEPT_CD  = V_ORG_MED_DEPT_CD
                                             AND MED_DT      >= TRUNC(SYSDATE)
                                          )                    
                    ;
                    
                    V_PACT_TP_CD := 'O';                    
                    EXCEPTION
                        WHEN OTHERS THEN
                            V_PACT_ID := NULL;
                END;
                            
            END IF;
        END IF;
                       
        --계약처코드 셋팅 
        --SELECT *
        --  FROM ACPPRCUM
        -- WHERE HSP_TP_CD = '01'
        --   AND APY_END_DT=  '99991231'
        --   AND CTRC_ORG_CD LIKE 'D%';
    
        --수탁병원이 학동일때... 나머지도 하드코딩 해야함.
--        IF IN_RER_HSP_TP_CD = '01' THEN 
--            IF V_SEND_HSP_TP_CD = '02' THEN
--                V_CUSTCD := 'D003'; --수탁미수(화순병원)
--            ELSIF V_SEND_HSP_TP_CD = '03' THEN
--                V_CUSTCD := 'D001'; --수탁미수(빛고을)        
--            ELSIF V_SEND_HSP_TP_CD = '04' THEN
--                V_CUSTCD := 'D005'; --수탁미수(치과)        
--                                        
--            END IF;
--        END IF;



        -- 미래수진을 못찾았을때 무료수진 생성
        IF V_PACT_ID IS NULL THEN           
        BEGIN 
        
            V_PACT_TP_CD := 'O';
        
            SELECT PACT_ID  
                 , RPY_PACT_ID  
                 , RPY_CLS_SEQ
              INTO V_PACT_ID
                 , V_RPY_PACT_ID 
                 , V_RPY_CLS_SEQ
              FROM ACPPRODM
             WHERE HSP_TP_CD   = HIS_HSP_TP_CD
               AND PT_NO       = IN_PT_NO
               AND MED_DT      = TRUNC(SYSDATE)
               AND MEDR_STF_NO = V_MEDDR_STF_NO
               AND MED_DEPT_CD = V_MED_DEPT
               AND APCN_YN     = 'N'
               AND ROWNUM      = 1 
            ;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- 무료수진 생성
                    BEGIN
                        XBIL.PC_ACP_FREERSV_ACPPRODM   (  HIS_HSP_TP_CD                      --01*병원구분코드(HSPCL)
                                                        , IN_PT_NO                           --03*환자번호(PT_NO)
                                                        , TO_CHAR(SYSDATE,'YYYYMMDD')        --04*진료일자(MEDDATE)
                                                        , V_MED_DEPT                             --05*진료부서코드(MEDDEPT)
                                                        , XCOM.FT_CNL_SELSTFINFO('1', V_MEDDR_STF_NO,HIS_HSP_TP_CD, TO_CHAR(SYSDATE, 'YYYY-MM-DD'))  --06*진료의직원식별ID(MEDDR)
                                                        , TO_CHAR(SYSDATE,'HH24MI')          --07*진료예약일시(MEDTIME,'YYYYMMDDHH24MI')

                                                        -- 2022-05-22 SCS : A(수탁임), 8(2차진료로) 변경
                                                        --, 'A'                                --08*진료예약구분코드(RSVTYPE)
                                                        , '8'                                --08*진료예약구분코드(RSVTYPE)
                                                        
                                                        -- 2022-05-22 SCS : 박성호 책임과 확인 후 NULL로 넘김 (NULL일 경우 이전 수전에서 해당 정보 가져옴)
                                                        --, 'LB'                               --09*환자급종유형코드(PATTYPE)
                                                        , ''                               --09*환자급종유형코드(PATTYPE)
                                                        -- 2022-05-22 SCS : 박성호 책임과 확인 후 NULL로 넘김 (NULL일 경우 이전 수전에서 해당 정보 가져옴)
                                                        --, '000'                              --10*환자보조급종유형코드(TYPECD)
                                                        , ''                                 --10*환자보조급종유형코드(TYPECD)
                                                        
                                                        , V_CUSTCD                           --11*계약기관코드(CUSTCD)
                                                        , ''                                 --12*선택진료여부(SPCDRYN)
                                                        , ''                                 --13*초진재진구분코드(MEDTYPE)
                                                        , ''                                 --14*임상연구번호(LABNO)
                                                        , ''                                 --15원내처방사유코드(INORDCD)
                                                        , ''                                 --16진찰료50%구분코드(RSVTYPE_HALF)
                                                        , ''                                 --17처방총액본인부담사유코드(DDTYPE)
                                                        , ''                                 --18타과의뢰여부(CONSLTYN)
                                                        , ''                                 --19이전원무접수ID()
                                                        -- 2022-05-22 SCS : 03(수탁임), 20(검사로) 변경
                                                        , '03'                               --20예약접수구분코드()
                                                        , ''                                 --21진료유형코드()
                                                        , ''                                 --22*건증접수구분코드(HPCTYPE)
                                                        , ''                                 --23외부기관의뢰여부(OTHERREQUESTYN)
                                                        , ''                                 --24진료의뢰요양기관번호(REQ_HSP_NO)
                                                        , ''                                 --25진찰료수납유형코드()
                                                        , HIS_STF_NO                         --26*최초등록직원식별ID(ENTERID)
                                                        , HIS_PRGM_NM                        --27*최초등록프로그램명()
                                                        , HIS_IP_ADDR                        --28*최초등록IP주소()
                                                        , ''                                 --29병원가산비율()
                                                        , ''                                 --30의료급여본인부담구분코드()
                                                        , ''                                 --31묶음계약기관코드()
                                                        , 'I'                                --32*작업구분('I':입력,'D':취소)
                                                        , ''                                 --33의학연구소 구분(1 :의학연구소 부담, 2 :자비연구 부담)
                                                        , V_RPY_PACT_ID                      --34수납원무접수ID(접수시 발생한..)
                                                        , V_RPY_CLS_SEQ                      --35수납유형순번
                                                        , IO_ERR_YN                          --36에러
                                                        , IO_ERR_MSG                         --37에러메세지
                                                        , V_PACT_ID                          --38수납원무접수ID(접수시 발생한..)..주의 : 예약취소시는 입력값으로 던저줘야한다. 
                                                        , V_RNS_DR_STF_NO                    --39실제의사사번       
                                                );        
                        -- 오류시 리턴                                    
                        IF IO_ERR_YN = 'Y' THEN
                            RETURN;
                        END IF;                                    
                    END;                
        END;
        END IF;
        -- 미래수진을 못찾았을때 무료수진 생성
        
        
            
        BEGIN
            SELECT /*XSUP.PKG_MSE_LM_ORDER.SAVE_ADDORDER*/
                   ORD_CD 
                 , MIF_CD
                 , ORD_CTG_CD
                 , NVL(V_TH1_SPCM_CD, TH1_SPCM_CD)
                 , CHC_EXM_YN
                 , ORD_NM
--                         , (SELECT TH2_SPCM_CD FROM MSELMEBM WHERE EXM_CD = C.ORD_CD AND ROWNUM = 1 AND HSP_TP_CD = HIS_HSP_TP_CD)
                 , ORD_SLIP_CTG_CD
              INTO V_ORD_CD
                 , V_MIF_CD
                 , V_ORD_CTG_CD
                 , V_TH1_SPCM_CD
                 , V_CHC_EXM_YN
                 , V_ORD_NM
--                         , V_TH2_SPCM_CD
                 , V_ORD_SLIP_CTG_CD
              FROM CCOOCBAC C
             WHERE ORD_CD    = IN_ORD_CD
               AND HSP_TP_CD = HIS_HSP_TP_CD
               AND NVL(ORD_END_YN, 'N') = 'N'
            ;
            
            EXCEPTION         
                WHEN OTHERS THEN
                     IO_ERR_YN  := 'Y';
                     IO_ERR_MSG := '처방마스터정보 조회시 에러 발생. Error = ' || TO_CHAR(SQLCODE);
                     RETURN;
        END;

        BEGIN
            SELECT /*XSUP.PKG_MSE_LM_ORDER.SAVE_ADDORDER*/
                   NVL(MAX(SCRN_SORT_SEQ),900)+1   /* 의 최대값+1*/
              INTO V_MAXSEQ
              FROM MOOOREXM
             WHERE PT_NO     = IN_PT_NO
               AND ORD_DT    = TRUNC(SYSDATE)
               AND HSP_TP_CD = HIS_HSP_TP_CD
               AND SCRN_SORT_SEQ > 900;
        END;

        BEGIN
            SELECT /*XSUP.PKG_MSE_LM_ORDER.SAVE_ADDORDER*/
                   AOA_WKDP_CD  --근무부서코드
              INTO V_AOA_WKDP_CD
              FROM CNLRRUSD
             WHERE STF_NO    = V_MEDDR_STF_NO
               AND NVL(RTRM_DT, TRUNC(SYSDATE) + 1) >= TRUNC(SYSDATE) -- RTRM_DT   IS NULL
               AND HSP_TP_CD = HIS_HSP_TP_CD ;

            EXCEPTION
                WHEN  OTHERS  THEN
                    V_AOA_WKDP_CD    := NULL;
        END;

        BEGIN
            SELECT /*XSUP.PKG_MSE_LM_ORDER.SAVE_ADDORDER*/
                   AOA_WKDP_CD  --근무부서코드
                 , AADP_CD      --발령부서코드
              INTO V_MEDR_AOA_WKDP_CD
                 , V_MEDR_AADP_CD
              FROM CNLRRUSD
             WHERE STF_NO    = V_MEDDR_STF_NO
               AND NVL(RTRM_DT, TRUNC(SYSDATE) + 1) >= TRUNC(SYSDATE) -- RTRM_DT   IS NULL
               AND HSP_TP_CD = HIS_HSP_TP_CD ;

            EXCEPTION
                WHEN  OTHERS  THEN
                    V_AOA_WKDP_CD    := NULL;
        END;
                
    
        BEGIN
            SELECT /*XSUP.PKG_MSE_LM_ORDER.SAVE_ADDORDER*/
                   TO_CHAR(XMED.SEQ_ORD_ID.NEXTVAL)
              INTO IO_ORD_ID
              FROM DUAL;
        END;


--V_PACT_ID:='100135';
--V_RPY_PACT_ID:='100135';
--IO_ERR_YN := 'Y';
--IO_ERR_MSG := IO_ORD_ID || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || IN_PT_NO || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_ORD_CD || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_ORD_NM || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_ORD_CTG_CD || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_MED_DEPT || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_MEDDR_STF_NO || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_MAXSEQ || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_MIF_CD || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_PACT_ID || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_RPY_PACT_ID || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_RPY_CLS_SEQ || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_MEDDR_STF_NO || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_MEDR_AOA_WKDP_CD || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_MEDR_AADP_CD || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_AOA_WKDP_CD || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_ORD_SLIP_CTG_CD || CHR(10);
--IO_ERR_MSG := IO_ERR_MSG || V_TH1_SPCM_CD || CHR(10);
--RETURN;


    
        BEGIN        
            PC_MSE_INS_SAVEORDER ( 'I'                                        --    처방저장모드 I:INSERT , U:UPDATE
                                 , IO_ORD_ID                                  --    처방ID
                                 , IN_PT_NO                                   --    환자번호
                                 , TRUNC(SYSDATE)                             --    처방일자
                                 , HIS_HSP_TP_CD                              --    병원구분코드
                                 , V_ORD_CD                                   --    처방코드
                                 , V_ORD_NM                                   --    처방명
                                 , 'C'                                        --    처방중단구분코드
    --                                     , 'A'                                        --    처방표시분류코드 (A:진료지원 - 오더조회 화면에서 조회안됨)
                                 , 'L'                                        --    처방표시분류코드 (A:진료지원 - 오더조회 화면에서 조회안됨)
                                 , V_ORD_CTG_CD                               --    처방분류코드
                                 , '1'                                        --    처방적용목적코드
                                 , V_MED_DEPT                                     --    발행처부서코드
                                 , V_MED_DEPT                                     --    환자수진부서코드
                                 , V_MED_DEPT                                     --    최초등록직원부서코드
                                 , 'Y'                                        --    추가처방여부
                                 , V_MEDDR_STF_NO                             --    주치의직원식별ID
                                 , V_MED_DEPT                                       --    처방발생구분코드 -- 병리는 P2
                                 , NULL                                       --    원처방구분코드
                                 , NULL                                       --    원처방ID
                                 , V_MAXSEQ                                   --    화면정렬순번  [진료지원 추가오더는 임의로 901 이후로 넣음]
                                 , V_MIF_CD                                   --    수가코드
                                 , NULL                                       --    응급여부
                                 , NULL                                       --    PRN처방여부
                                 , ''                                         --    진료수가보험구분코드
                                 , NULL                                       --    임의비급여사유코드
                                 , NULL                                       --    처방비고내용
                                 , NULL                                       --    병동부서코드
                                 , NULL                                       --    병실번호
                                 , V_PACT_TP_CD --'O'                                        --    원무접수구분코드
                                 , V_PACT_ID                                  --    원무접수ID
                                 , V_RPY_PACT_ID                              --    수납원무접수ID
                                 , NVL(V_RPY_CLS_SEQ,1)                       --    수납유형순번
                                 , '01'                                       --    병원내부구분코드
                                 , TRUNC(SYSDATE)                             --    실시간진료일자
                                 , V_MEDDR_STF_NO                             --    실시간진료의직원식별ID
                                 , V_MEDR_AOA_WKDP_CD                         --    실시간진료의발령부서코드
                                 , V_MEDR_AADP_CD                             --    실시간진료의근무부서코드
                                 , TRUNC(SYSDATE)                             --    실시간발행일시
                                 , V_MEDDR_STF_NO                             --    실시간발행직원식별ID
                                 , V_MED_DEPT                                     --    실시간발행자발령부서코드
                                 , V_AOA_WKDP_CD                              --    실시간발행자근무부서코드
                                 , NULL                                       --    실시간수행일시
                                 , NULL                                       --    실시간수행직원식별ID
                                 , NULL                                       --    실시간수행자비용적용부서코드
                                 , NULL                                       --    실시간수행자근무부서코드
                                 , NULL                                       --    실시간사용장비코드
                                 , NULL                                       --    실시간수행취소직원식별ID
                                 , NULL                                       --    실시간수행취소일시
                                 , NULL                                       --    실시간마감직원식별ID
                                 , NULL                                       --    실시간마감일자
                                 , NULL                                       --    실시간마감수행여부
                                 , NULL                                       --    실시간PDA사용여부
                                 , '03'                                       --    처방그룹코드
                                 , NULL                                       --    CP적용ID
                                 , NULL                                       --    CP일정순번
                                 , NULL                                       --    CP변경사유순번
                                 , NULL                                       --    환자CP처방순번
                                 , NULL                                       --    서명키번호
                                 , NULL                                       --    서명직원번호
                                 , NULL                                       --    세트처방등록ID
                                 , NULL                                       --    세트처방상세순번
                                 , NULL                                       --    묶음정렬처방ID
                                 , NULL                                       --    묶음정렬순번
                                 , NULL                                       --    선택검사여부
                                 , NULL                                       --    선택진료창구방문여부
                                 , NULL                                       --    비선택여부
                                 , NULL                                       --    진료용위임구분코드
                                 , V_ORD_SLIP_CTG_CD                          --    처방전표분류코드
                                 , V_TH1_SPCM_CD                              --    1번째검체코드
                                 , ''                                         --    2번째검체코드
                                 , 'COLL'                                     --    환자이동장소
                                 , NULL                                       --    장비휴대가능여부
                                 , NULL                                       --    디지털여부
                                 , NULL                                       --    외부병원필름판독여부
                                 , 'N'                                        --    상담여부
                                 , NULL                                       --    정액대상여부
                                 , NULL                                       --    주조영술여부
                                 , NULL                                       --    CR검사여부
                                 , NULL                                       --    항생제투여여부
                                 , 1                                          --    검사횟수
                                 , 1                                          --    동시검사묶음순번
                                 , NULL                                       --    임상소견내용
                                 , TRUNC(SYSDATE)                             --    예약일시
                                 , NULL                                       --    예약처리직원식별ID
                                 , NULL                                       --    임의비급여기타사유내용
                                 , NULL                                       --    심야가산적용여부
                                 , NULL                                       --    비보험사유코드
                                 , NULL                                       --    비보험시점기타사유내용
                                 , V_MEDDR_STF_NO                             --    등록, 변경자 ID
                                 , HIS_PRGM_NM                                --    등록, 변경 프로그램명
                                 , HIS_IP_ADDR                                --    등록 변경 IP ADDRESS
                                 , IN_SPCM_NO                                 --    검체병리번호
                                 , NULL                                       --    비보험시점기타사유내용
                                 , V_MEDDR_STF_NO                             --    실명제의사직원번호(IN_V_RNS_DR_STF_NO)--수정해야함
                                 , IO_ERR_YN                                  --    에러여부
                                 , IO_ERR_MSG
                                 );

                    BEGIN    
                        UPDATE MOOOREXM
                           SET RSCH_PRJT_NO = V_RSCH_PRJT_NO
                         WHERE ORD_ID    = IO_ORD_ID
                           AND HSP_TP_CD = HIS_HSP_TP_CD;
                    END;
                                                   
                --검체접수를 위해서 수납 Y 업데이트 
                --접수 후 다시 N으로 업데이트 함
--                IF V_PACT_TP_CD = 'O' THEN
--                    BEGIN
--                        UPDATE MOOOREXM
--                           SET RPY_STS_CD = 'Y'
--                         WHERE ORD_ID    = IO_ORD_ID
--                           AND HSP_TP_CD = HIS_HSP_TP_CD;
--                    END;
--                END IF;
                
                EXCEPTION
                    WHEN OTHERS  THEN
--                        IO_ERR_YN  := 'Y';
--                        IO_ERR_MSG := '오더발행 중 에러 발생. Error = ' || TO_CHAR(SQLERRM) || ' > ' || IO_ERR_MSG;
                        RAISE_APPLICATION_ERROR(-20001, 'ERROR = ' || TO_CHAR(SQLCODE) || CHR(13) || CHR(10) || SQLERRM || CHR(13) || CHR(10) || V_PACT_ID || CHR(13) || CHR(10) || ' : ' || IN_SPCM_NO) ;
                        RETURN;
    
        END;        
    
        IF IO_ERR_YN = 'Y' THEN
            RETURN;
        END IF;
        
        /*************************************************************************
         * 4.수납         : PC_ACP_AUTO_RECEIPT_CALC ( AS-IS : pc_auto_receipt_calc)
         *************************************************************************/
--        BEGIN
--            XBIL.PC_ACP_AUTO_RECEIPT_CALC ( HIS_HSP_TP_CD                                                         /* 01 IN_HSP_TP_CD                             */
--                                          , V_RPY_PACT_ID                                                         /* 02 IN_RPY_PACT_ID                           */
--                                          , V_RPY_CLS_SEQ                                                         /* 03 IN_RPY_CLS_SEQ                           */
--                                          , TO_CHAR(TRUNC(SYSDATE),'YYYYMMDD')                                    /* 04 IN_APY_STR_DT                            */
--                                          , IN_PT_NO                                                              /* 05 IN_PT_NO                                 */
--                                          , TRUNC(SYSDATE)                                                        /* 06 IN_MEDDATE                               */
--                                          , V_MED_DEPT                                                                /* 07 IN_MEDDEPT                               */
--                                          , XCOM.FT_CNL_SELSTFINFO('1', V_MEDDR_STF_NO, HIS_HSP_TP_CD, TO_CHAR(SYSDATE, 'YYYY-MM-DD')) /* 08 IN_MEDDR                                 */
--                                          , 'O'                                                                   /* 09 IN_PATSITE                               */
--                                          , 'AUTO009'                                                               /* 10 IN_RCPID                                 */
--                                          , 'Y'                                                                   /* 11 IN_RECALCYN                              */
--                                          , HIS_PRGM_NM                                                           /* 12 IN_FSR_PRGM_NM                           */
--                                          , HIS_IP_ADDR                                                           /* 13 IN_FSR_IP_ADDR                           */
--                                          , ''
--                                          , V_REMARK                                                              /* 14 IO_REMARK                                */
--                                          , IO_ERR_YN                                                             /* 15 IO_ERRYN                                 */
--                                          , IO_ERR_MSG                                                            /* 16 IO_ERRMSG                                */
--                                          );
--            EXCEPTION
--                WHEN  OTHERS  THEN
--                    IO_ERR_YN  := 'Y';
--                    IO_ERR_MSG := '수납처리 중 에러 발생. ERRCD = ' || IO_ERR_MSG || TO_CHAR(SQLCODE);
--                    RETURN;
--        END;
--       
--        /* 수납여부 다시 체크 해본다. */
--        BEGIN
--            SELECT /*+ XSUP.PC_MSE_INS_SUTAK_AUTO */
--                   'Y'
--              INTO V_PAYT_CHK
--              FROM ACPPEOPD
--             WHERE PT_NO       = IN_PT_NO
--               AND RPY_PACT_ID = V_RPY_PACT_ID
--               AND RPY_CLS_SEQ = NVL(V_RPY_CLS_SEQ, 1)
--               AND APY_STR_DT  = TRUNC(SYSDATE)
--               AND MED_DEPT_CD = V_MED_DEPT
--               AND RPY_STF_NO  = 'AUTO009'
--               AND RPY_DT      = TRUNC(SYSDATE)
--               AND CNCL_DTM    IS NULL
--               AND HSP_TP_CD   = HIS_HSP_TP_CD
--               AND ROWNUM  = 1
--               ;
--               
--            EXCEPTION
--                WHEN OTHERS THEN
--                     IO_ERR_YN  := 'Y';
--                     IO_ERR_MSG := '수납정보조회 중 에러 발생. ERRCD = ' || ' V_RPY_PACT_ID : ' || V_RPY_PACT_ID || ' V_RPY_CLS_SEQ : ' || V_RPY_CLS_SEQ || ' V_PTNO_OUT : ' || IN_PT_NO || ' V_MED_DEPT : ' || V_MED_DEPT ||  ' IN_DOC_JUCDR : ' || V_MEDDR_STF_NO || ' ' ||  TO_CHAR(SQLERRM);
--                     RETURN;
--    
--            IF (V_PAYT_CHK != 'Y')THEN
--                BEGIN
--                    IO_ERR_YN  := 'Y';
--                    IO_ERR_MSG := '수납여부 재확인 중 에러 발생. 수납데이터 생성안됨';
--                    RETURN;
--                END;
--            END IF;
--        END; 
        
        
        BEGIN

            BEGIN        
                SELECT A.TH3_RMK_CNTE
                     , M.EITM_NM
                     , M.EXRM_EXM_CTG_CD
                  INTO V_PATH_ORD_CD
                     , V_PATH_ORD_NM    
                     , V_PATH_EXM_CTG_CD
                  FROM MSELMSID A
                     , MSELMEBM M
                 WHERE A.HSP_TP_CD     = HIS_HSP_TP_CD
                   AND A.LCLS_COMN_CD  = 'BM_SECTIONBX'
                   AND A.SCLS_COMN_CD  = V_ORD_CD 
                   AND M.HSP_TP_CD     = A.HSP_TP_CD
                   AND M.EXM_CD        = A.TH3_RMK_CNTE
                ;
                EXCEPTION
                    WHEN OTHERS THEN
                        RETURN;                
            END;
            
            BEGIN
                SELECT CNSG_ACPT_DTM
                  INTO V_CNSG_ACPT_DTM
                  FROM MSEPMERD
                 WHERE HSP_TP_CD          = HIS_HSP_TP_CD
                   AND EXM_RST_HSP_TP_CD  = HIS_HSP_TP_CD
                   AND EXM_CNSG_HSP_TP_CD = HIS_HSP_TP_CD
                   AND PT_NO              = IN_PT_NO
                   AND RST_PTHL_NO        = IN_SPCM_NO
                   AND EXM_CTG_CD         = V_PATH_EXM_CTG_CD
                   AND EXM_CD             = V_PATH_ORD_CD            
                ;
                
                -- 이미 위탁등록이 되어 있고 병리에서 수탁접수했다면 리턴                
                IF V_CNSG_ACPT_DTM IS NOT NULL THEN
                    RETURN;
                ELSE
                    -- 수탁접수가 되어 있지 않다면 삭제 후 INSERT함
                    DELETE FROM MSEPMERD
                     WHERE HSP_TP_CD          = HIS_HSP_TP_CD
                       AND EXM_RST_HSP_TP_CD  = HIS_HSP_TP_CD
                       AND EXM_CNSG_HSP_TP_CD = HIS_HSP_TP_CD
                       AND PT_NO              = IN_PT_NO
                       AND RST_PTHL_NO        = IN_SPCM_NO
                       AND EXM_CTG_CD         = V_PATH_EXM_CTG_CD
                       AND EXM_CD             = V_PATH_ORD_CD            
                   ;
                END IF;
                                  
                EXCEPTION
                    WHEN OTHERS THEN  
                        NULL;
            END; 

            --골수번호 조회            
            BEGIN
                SELECT CASE WHEN A.BNMR_EXM_ACPT_NO IS NULL THEN '' 
                            ELSE A.BNMR_EXM_ACPT_NO || '-' || TO_CHAR(A.ACPT_DTM, 'YY')
                       END
                  INTO V_BNMR_EXM_ACPT_NO
                  FROM MSELMAID A
                 WHERE HSP_TP_CD = HIS_HSP_TP_CD
                   AND SPCM_NO   = IN_SPCM_NO
                   --AND ORD_ID    = IN_ORG_ORD_ID
                   AND BNMR_EXM_ACPT_NO IS NOT NULL 
                   AND ROWNUM    = 1
                ;
                    
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
            END ;          
        
            XSUP.PKG_MSE_PM_RSTEXAM.SAVE_RSTEXAM_FROM_ASIS        
            (
              HIS_HSP_TP_CD           -- 위탁병원
            , HIS_HSP_TP_CD           -- 수탁병원 
        
            , IN_PT_NO                -- 환자번호
            , V_PATH_ORD_CD           -- 검사코드     
            , V_PATH_ORD_NM           -- 검사명
            , V_PATH_EXM_CTG_CD       -- 검사분류    
            , IN_SPCM_NO              -- IN_RST_PTHL_NO -- 위탁병리번호 -> 진검에서 등록하는거라 검체번호 저장해 줌.
            
            , TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') -- 위탁등록일자
            , HIS_STF_NO              -- 위탁등록접원번호
            , V_BNMR_EXM_ACPT_NO      -- 위탁의뢰비고내용 (골수번호)
            
            , IN_SPCM_NO              -- 위탁병리번호의 연결병리번호
            , ''                      --서브번호 (블록번호)
            
            , HIS_HSP_TP_CD
            , HIS_STF_NO
            , HIS_PRGM_NM
            , HIS_IP_ADDR
                                        
            , IO_ERR_YN
            , IO_ERR_MSG
            );
        END;
                                                           
    END SAVE_ADDORDER;   


    /**********************************************************************************************
    *    서비스이름  : SAVE_BLCLACPT
    *    최초 작성일 : 2022.03.02
    *    최초 작성자 : ezCaretech SCS
    *    DESCRIPTION : 채혈 및 검체접수 일괄시행
    *    수 정 사 항 : 
    **********************************************************************************************/
    PROCEDURE SAVE_BLCLACPT
    ( 
      IN_PT_NO             IN          VARCHAR2
    , IN_SPCM_NO           IN          VARCHAR2
    , IN_ORG_ORD_ID        IN          VARCHAR2 -- 원처방 아이디. 원처방 아이디가 있을경우 그 처방의 검체번호로 처방발행함.    
    
    , IN_ORD_ID            IN          VARCHAR2
    
    , IN_ACPT_DT           IN          VARCHAR2
    , IN_EXM_CTG_CD        IN          VARCHAR2
       
    , HIS_HSP_TP_CD        IN          VARCHAR2
    , HIS_STF_NO           IN          VARCHAR2
    , HIS_PRGM_NM          IN          VARCHAR2
    , HIS_IP_ADDR          IN          VARCHAR2
     
    , IO_ERR_YN            IN OUT      VARCHAR2
    , IO_ERR_MSG           IN OUT      VARCHAR2
    )
    IS
        V_SPCM_NO          MSELMCED.SPCM_NO%TYPE := IN_SPCM_NO;
        V_TH1_SPCM_CD      MOOOREXM.TH1_SPCM_CD%TYPE;        
        V_BNMR_EXM_ACPT_NO MSELMAID.BNMR_EXM_ACPT_NO%TYPE;
    BEGIN
    
        BEGIN
            SELECT O.TH1_SPCM_CD
                 , (SELECT BNMR_EXM_ACPT_NO
                      FROM MSELMAID A
                     WHERE A.HSP_TP_CD = O.HSP_TP_CD
                       AND A.SPCM_NO   = O.SPCM_PTHL_NO
                       AND A.ORD_ID    = O.ORD_ID
                       AND A.BNMR_EXM_ACPT_NO IS NOT NULL
                       AND ROWNUM = 1
                   )     
              INTO V_TH1_SPCM_CD
                 , V_BNMR_EXM_ACPT_NO -- 골수번호
              FROM MOOOREXM O
             WHERE O.HSP_TP_CD    = HIS_HSP_TP_CD
               AND O.ORD_ID       = IN_ORG_ORD_ID
            ;
            EXCEPTION
                WHEN OTHERS THEN
                     IO_ERR_YN  := 'Y';
                     IO_ERR_MSG := '원처방정보 조회시 에러 발생. Error = ' || TO_CHAR(SQLERRM);
                     RETURN;            
        END;   


        --검체접수를 위해서 수납 Y 업데이트 
        --접수 후 다시 N으로 업데이트 함
        BEGIN
            UPDATE MOOOREXM O
               SET RPY_STS_CD = 'Y'
             WHERE O.HSP_TP_CD = HIS_HSP_TP_CD
               AND O.ORD_ID IN ( SELECT REGEXP_SUBSTR ( IN_ORD_ID, '[^,]+', 1, LEVEL )
                                   FROM DUAL
                                CONNECT BY LEVEL <= REGEXP_COUNT ( IN_ORD_ID, ',' ) + 1
                               )

            ;
            EXCEPTION
                WHEN OTHERS THEN
                     IO_ERR_YN  := 'Y';
                     IO_ERR_MSG := '처방 수납정보 Y 업데이트시 에러 발생. Error = ' || TO_CHAR(SQLERRM);
                     RETURN; 
        END;  
                

        -- 채혈
        BEGIN
        
            XSUP.PKG_MSE_LM_BLCL.BLCL( 
                                       IN_PT_NO                --IN      VARCHAR2
                                     , IN_ORD_ID               --IN      VARCHAR2 -- ,로 구분하여 멀티로 처리 가능함. 예 : 150029260,150029263,150029262,150029261,150029258,150029256,150029259,150029257,150029267
                        
                                     , HIS_HSP_TP_CD           --IN      VARCHAR2
                                     , HIS_STF_NO              --IN      VARCHAR2
                                     , HIS_PRGM_NM             --IN      VARCHAR2
                                     , HIS_IP_ADDR             --IN      VARCHAR2
                                     -- 새로운 검체번호를 채번하지 않고, 넘어온 검체번호로 채혈함.
                                     , V_SPCM_NO               --IN OUT  VARCHAR2
                                     , IO_ERR_YN               --OUT     VARCHAR2
                                     , IO_ERR_MSG              --OUT     VARCHAR2 
                                     );
    
            IF IO_ERR_YN = 'Y' THEN
            
                UPDATE MOOOREXM O
                   SET RPY_STS_CD = 'N'
                 WHERE O.HSP_TP_CD = HIS_HSP_TP_CD
                   AND O.ORD_ID IN ( SELECT REGEXP_SUBSTR ( IN_ORD_ID, '[^,]+', 1, LEVEL )
                                       FROM DUAL
                                    CONNECT BY LEVEL <= REGEXP_COUNT ( IN_ORD_ID, ',' ) + 1
                                   );
            
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := 'XSUP.PKG_MSE_LM_BLCL.BLCL 에러 발생. Error = ' || IO_ERR_MSG;
                RETURN;
            END IF;
    
        END;   
        
        -- 접수
        BEGIN
            XSUP.PKG_MSE_LM_SPCMACPT.ACPT( IN_SPCM_NO -- !!!! V_SPCM_NO 를 사용할 수 없음. 기존 검체번호로 채혈할 경우 채혈 후 빈값으로 초기화됨(버그)
                                         , IN_PT_NO 
    
                                         , IN_ACPT_DT
                                         , IN_EXM_CTG_CD
                                         , V_TH1_SPCM_CD
                                                                 
                                         -- 2022.03.14 SCS : 기존 접수된 접수번호가 있다면 새로 채번하지 않고 MERGE함.
                                         , 'EXM_ACP_NO_MERGE' -- IN_RMK_CNTE          IN          VARCHAR2
                                         
                                         , HIS_HSP_TP_CD
                                         , HIS_STF_NO
                                         , HIS_PRGM_NM
                                         , HIS_IP_ADDR
                                         
                                         , IO_ERR_YN
                                         , IO_ERR_MSG
                                         );
                                     
            IF IO_ERR_YN = 'Y' THEN

                UPDATE MOOOREXM O
                   SET RPY_STS_CD = 'N'
                 WHERE O.HSP_TP_CD = HIS_HSP_TP_CD
                   AND O.ORD_ID IN ( SELECT REGEXP_SUBSTR ( IN_ORD_ID, '[^,]+', 1, LEVEL )
                                       FROM DUAL
                                    CONNECT BY LEVEL <= REGEXP_COUNT ( IN_ORD_ID, ',' ) + 1
                                   );
            
                IO_ERR_YN  := 'Y';
                IO_ERR_MSG := 'XSUP.PKG_MSE_LM_SPCMACPT.ACPT 에러 발생. Error = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERR_MSG;
                RETURN;
            END IF;
        END;

        --검체접수를 위해서 수납 Y 업데이트 
        --접수 후 다시 N으로 업데이트 함
        BEGIN
            UPDATE MOOOREXM O
               SET RPY_STS_CD = 'N'
             WHERE O.HSP_TP_CD = HIS_HSP_TP_CD
               AND O.ORD_ID IN ( SELECT REGEXP_SUBSTR ( IN_ORD_ID, '[^,]+', 1, LEVEL )
                                   FROM DUAL
                                CONNECT BY LEVEL <= REGEXP_COUNT ( IN_ORD_ID, ',' ) + 1
                               )

            ;
            EXCEPTION
                WHEN OTHERS THEN
                     IO_ERR_YN  := 'Y';
                     IO_ERR_MSG := '처방 수납정보 N 업데이트시 에러 발생. Error = ' || TO_CHAR(SQLERRM);
                     RETURN; 
        END;        
        
        -- 골수접수번호 업데이트
        IF V_BNMR_EXM_ACPT_NO IS NOT NULL THEN
        BEGIN
        
            UPDATE MSELMAID A
               SET A.BNMR_EXM_ACPT_NO = V_BNMR_EXM_ACPT_NO
             WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
               AND A.SPCM_NO   = IN_SPCM_NO
               AND INSTR(',' || IN_ORD_ID, ',' || A.ORD_ID) > 0
            ;
            EXCEPTION
                WHEN OTHERS THEN
                     IO_ERR_YN  := 'Y';
                     IO_ERR_MSG := '골수접수번호 업데이트시 에러 발생. Error = ' || TO_CHAR(SQLERRM);
                     RETURN;                 
        END;          
        END IF;
         
    END SAVE_BLCLACPT;                


    /**********************************************************************************************
    *    서비스이름  : SAVE_ORDERDC
    *    최초 작성일 : 2022.03.06
    *    최초 작성자 : ezCaretech SCS
    *    DESCRIPTION : 처방D/C
    *    수 정 사 항 : 
    **********************************************************************************************/
    PROCEDURE SAVE_ORDERDC
    (
      IN_PT_NO               IN      VARCHAR2 
    , IN_SPCM_NO             IN      VARCHAR2
    , IN_ORD_ID              IN      VARCHAR2

    , HIS_HSP_TP_CD          IN      VARCHAR2
    , HIS_STF_NO             IN      VARCHAR2
    , HIS_PRGM_NM            IN      VARCHAR2
    , HIS_IP_ADDR            IN      VARCHAR2

    , IO_ERR_YN              OUT     VARCHAR2
    , IO_ERR_MSG             OUT     VARCHAR2 
    )
    IS
--        V_EXM_PRGR_STS_CD    MOOOREXM.EXM_PRGR_STS_CD%TYPE;
--        V_WK_UNIT_CD         MSELMAID.WK_UNIT_CD%TYPE;
        --수납관련
--        V_REMARK             VARCHAR2(4000);
--        V_PAYT_CHK           VARCHAR2(100);   

        V_ORD_CD               MOOOREXM.ORD_CD%TYPE;        
        V_ORD_NM               MOOOREXM.ORD_NM%TYPE;
        V_RPY_STS_CD           MOOOREXM.RPY_STS_CD%TYPE;
    BEGIN

        BEGIN
            SELECT O.ORD_CD
                 , O.ORD_NM
                 , O.RPY_STS_CD
              INTO V_ORD_CD
                 , V_ORD_NM 
                 , V_RPY_STS_CD
              FROM MOOOREXM O
             WHERE O.HSP_TP_CD    = HIS_HSP_TP_CD
               AND O.ORD_ID       = IN_ORD_ID     
            ;  

            IF V_RPY_STS_CD = 'Y' THEN
                IO_ERR_YN := 'Y';
                IO_ERR_MSG      := '수납된 처방은 D/C할 수 없습니다. [' || V_ORD_CD || ' : ' || V_ORD_NM || ']';
                RETURN;                                              
            END IF;
            
            EXCEPTION
                WHEN OTHERS THEN
                    IO_ERR_YN := 'Y';
                    IO_ERR_MSG      := '처방 수납여부 조회시 Error  ' || SQLERRM || ' >> IN_ORD_ID :' || IN_ORD_ID;
                    RETURN;                                  
        END;

-- 현재 처방ID로 접수취소하는 기능은 없음.
-- 아래로직은 전체 슬롯의 처방을 초기화시킴. 사용하면 안됨.
--        BEGIN
--            SELECT O.EXM_PRGR_STS_CD
--                 , R.WK_UNIT_CD
--              INTO V_EXM_PRGR_STS_CD
--                 , V_WK_UNIT_CD
--              FROM MOOOREXM O
--                 , MSELMAID R
--             WHERE O.HSP_TP_CD    = HIS_HSP_TP_CD
--               AND O.ORD_ID       = IN_ORD_ID 
--               AND O.SPCM_PTHL_NO = R.SPCM_NO(+)
--               AND O.PT_NO        = R.PT_NO  (+)
--               AND O.ORD_ID       = R.ORD_ID (+)
--            ;  
--
--            EXCEPTION
--                WHEN OTHERS THEN
--                    IO_ERR_YN := 'Y';
--                    IO_ERR_MSG      := '처방상태 조회시 Error  ' || SQLERRM || ' >> IN_ORD_ID :' || IN_ORD_ID;
--                    RETURN;                                  
--        END;
--    
--        -- 처방상태로 취소   
--        IF V_EXM_PRGR_STS_CD NOT IN ('X', 'B') THEN
--            BEGIN
--                PKG_MSE_LM_SPCMACPT.CANCEL 
--                ( 'X'
--                , IN_SPCM_NO
--                , V_WK_UNIT_CD
--               
--               , HIS_HSP_TP_CD
--               , HIS_STF_NO   
--               , HIS_PRGM_NM  
--               , HIS_IP_ADDR  
--    
--               , IO_ERR_YN 
--               , IO_ERR_MSG
--               );
--    
--                IF IO_ERR_YN = 'Y' THEN
--                    RETURN;
--                END IF;    
--        
--            END;
--        END IF;
        
        -- D/C처리
        BEGIN
            XMED.PKG_MOO_SAVEORDERS.PC_SAVEORDER_DC(
                                                     IN_ORD_ID                                                                             -- 공통             처방ID
                                                   , 'N'                                                                                   -- 공통             처방중단구분코드
                                                   , HIS_HSP_TP_CD                                                                         -- 공통             병원구분코드
                                                   , HIS_STF_NO                                                                            -- 기타             등록, 변경자 ID
                                                   , HIS_PRGM_NM                                                                           -- 기타             등록, 변경 프로그램명
                                                   , HIS_IP_ADDR                                                                           -- 기타             등록 변경 IP ADDRESS
                                                   , IO_ERR_YN                                                                             -- 기타             에러여부
                                                   , IO_ERR_MSG                                                                            -- 기타
                                                   );

            IF IO_ERR_YN = 'Y' THEN
                RETURN;
            END IF;
        
            EXCEPTION
                WHEN OTHERS THEN
                    IO_ERR_YN := 'Y';
                    IO_ERR_MSG := 'XMED.PKG_MOO_SAVEORDERS.PC_SAVEORDER_DC 에러 발생. Error = ' || IO_ERR_MSG;
                    RETURN;
        END;

               
        BEGIN

            UPDATE MOOOREXM
               SET RTM_FMT_DTM            = NULL
                 , RTM_CLSN_DT            = NULL
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND RPY_STS_CD = 'N'
               AND ORD_ID    = IN_ORD_ID;

            EXCEPTION
                WHEN OTHERS THEN
                    IO_ERR_YN := 'Y';
                    IO_ERR_MSG := '처방 시행일자 초기화 중 에러 발생. Error = ' || SQLERRM;
                    RETURN;                     
        END;               
               
               
        BEGIN

            DELETE FROM MSELMAID
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND SPCM_NO   = SPCM_NO
               AND PT_NO     = IN_PT_NO
               AND ORD_ID    = IN_ORD_ID;

            EXCEPTION
                WHEN OTHERS THEN
                    IO_ERR_YN := 'Y';
                    IO_ERR_MSG := '처방 D/C후 검사결과 항목 삭제 중 에러 발생. Error = ' || SQLERRM;
                    RETURN;                     
        END;
                
     

    
--        BEGIN
--            FOR DR IN
--            (
--                SELECT DISTINCT 
--                       O.ORD_ID
--                     , O.PT_NO
--                     , O.PBSO_DEPT_CD
--                     , O.ANDR_STF_NO
--                     , O.RPY_PACT_ID
--                     , O.RPY_CLS_SEQ
--                     , O.EXM_HOPE_DT
--                  FROM MOOOREXM O
--                 WHERE O.HSP_TP_CD      = HIS_HSP_TP_CD
--                   AND O.ORD_ID         = IN_ORD_ID
--            ) LOOP
--
--
--                BEGIN
--                    XMED.PKG_MOO_SAVEORDERS.PC_SAVEORDER_DC(
--                                                             DR.ORD_ID                                                                             -- 공통             처방ID
--                                                           , 'N'                                                                                   -- 공통             처방중단구분코드
--                                                           , HIS_HSP_TP_CD                                                                         -- 공통             병원구분코드
--                                                           , HIS_STF_NO                                                                            -- 기타             등록, 변경자 ID
--                                                           , HIS_PRGM_NM                                                                           -- 기타             등록, 변경 프로그램명
--                                                           , HIS_IP_ADDR                                                                           -- 기타             등록 변경 IP ADDRESS
--                                                           , IO_ERR_YN                                                                             -- 기타             에러여부
--                                                           , IO_ERR_MSG                                                                            -- 기타
--                                                           );
--        
--                    EXCEPTION
--                        WHEN OTHERS THEN
--                            IO_ERR_YN  := 'Y';
--                            IO_ERR_MSG := 'XMED.PKG_MOO_SAVEORDERS.PC_SAVEORDER_DC 에러 발생. Error = ' || IO_ERR_MSG;
--                            RETURN;
--                END;
--
--                IF IO_ERR_YN = 'Y' THEN
--                    RETURN;
--                END IF;


                /*************************************************************************
                 * 수납         : PC_ACP_AUTO_RECEIPT_CALC ( AS-IS : pc_auto_receipt_calc)
                 *************************************************************************/
--                BEGIN
--                    XBIL.PC_ACP_AUTO_RECEIPT_CALC ( HIS_HSP_TP_CD                                                         /* 01 IN_HSP_TP_CD                             */
--                                                  , DR.RPY_PACT_ID                                                        /* 02 IN_RPY_PACT_ID                           */
--                                                  , DR.RPY_CLS_SEQ                                                        /* 03 IN_RPY_CLS_SEQ                           */
--                                                  , TO_CHAR(TRUNC(DR.EXM_HOPE_DT),'YYYYMMDD')                             /* 04 IN_APY_STR_DT                            */
--                                                  , DR.PT_NO                                                              /* 05 IN_PT_NO                                 */
--                                                  , DR.EXM_HOPE_DT                                                        /* 06 IN_MEDDATE                               */
--                                                  , DR.PBSO_DEPT_CD                                                       /* 07 IN_MEDDEPT                               */
--                                                  , XCOM.FT_CNL_SELSTFINFO('1', DR.ANDR_STF_NO, HIS_HSP_TP_CD, TO_CHAR(SYSDATE, 'YYYY-MM-DD')) /* 08 IN_MEDDR                                 */
--                                                  , 'O'                                                                   /* 09 IN_PATSITE                               */
--                                                  , 'AUTO009'                                                               /* 10 IN_RCPID                                 */
--                                                  , 'Y'                                                                   /* 11 IN_RECALCYN                              */
--                                                  , HIS_PRGM_NM                                                           /* 12 IN_FSR_PRGM_NM                           */
--                                                  , HIS_IP_ADDR                                                           /* 13 IN_FSR_IP_ADDR                           */
--                                                  , ''
--                                                  , V_REMARK                                                              /* 14 IO_REMARK                                */
--                                                  , IO_ERR_YN                                                             /* 15 IO_ERRYN                                 */
--                                                  , IO_ERR_MSG                                                            /* 16 IO_ERRMSG                                */
--                                                  );
--                    EXCEPTION
--                        WHEN  OTHERS  THEN
--                            IO_ERR_YN  := 'Y';
--                            IO_ERR_MSG := 'XBIL.PC_ACP_AUTO_RECEIPT_CALC 수납취소 중 에러 발생. Error = ' || IO_ERR_MSG;
--                            RETURN;
--                END;
--               
--                /* 수납여부 다시 체크 해본다. */
--                BEGIN
--                    SELECT /*+ XSUP.PC_MSE_INS_SUTAK_AUTO */
--                           'Y'
--                      INTO V_PAYT_CHK
--                      FROM ACPPEOPD
--                     WHERE PT_NO       = DR.PT_NO
--                       AND RPY_PACT_ID = DR.RPY_PACT_ID
--                       AND RPY_CLS_SEQ = NVL(DR.RPY_CLS_SEQ, 1)
--                       AND APY_STR_DT  = TRUNC(DR.EXM_HOPE_DT)
--                       AND MED_DEPT_CD = DR.PBSO_DEPT_CD
--                       AND RPY_STF_NO  = 'AUTO009'
--                       AND RPY_DT      = TRUNC(DR.EXM_HOPE_DT)
--                       AND CNCL_DTM    IS NOT NULL
--                       AND HSP_TP_CD   = HIS_HSP_TP_CD
--                       AND ROWNUM  = 1
--                       ;
--                       
--                    EXCEPTION
--                        WHEN OTHERS THEN
--                             IO_ERR_YN  := 'Y';
--                             IO_ERR_MSG := '수납정보조회 중 에러 발생. Error = ' || ' RPY_PACT_ID : ' || DR.RPY_PACT_ID || ' RPY_CLS_SEQ : ' || DR.RPY_CLS_SEQ || ' V_PTNO_OUT : ' || DR.PT_NO || ' PBSO_DEPT_CD : ' || DR.PBSO_DEPT_CD ||  ' IN_DOC_JUCDR : ' || DR.ANDR_STF_NO || ' ' ||  TO_CHAR(SQLERRM);
--                             RETURN;
--        
--                    IF (V_PAYT_CHK != 'Y')THEN
--                        BEGIN
--                            IO_ERR_YN  := 'Y';
--                            IO_ERR_MSG := '수납여부 재확인 중 에러 발생';
--                            RETURN;
--                        END;
--                    END IF;
--                END;     
            
--            END LOOP;
--        END;

    END SAVE_ORDERDC;


    /**********************************************************************************************
    *    서비스이름  : SAVE_SECTIONBX_RSTEXAM
    *    최초 작성일 : 2022.03.28
    *    최초 작성자 : ezCaretech SCS
    *    DESCRIPTION : SECTION BX 병리위탁등록
    *    수 정 사 항 : 
    **********************************************************************************************/
    PROCEDURE SAVE_SECTIONBX_RSTEXAM
    ( 
      IN_PT_NO               IN      VARCHAR2 --등록번호
    , IN_SPCM_NO             IN      VARCHAR2 --검체번호 
    , IN_ORD_CD              IN      VARCHAR2 --처방코드 (사용안함)
    , IN_ORD_ID              IN      VARCHAR2 --처방ID
    
    , HIS_HSP_TP_CD          IN      VARCHAR2 -- 병원구분
    , HIS_STF_NO             IN      VARCHAR2 -- 작업자직원번호
    , HIS_PRGM_NM            IN      VARCHAR2 -- 프로그램명
    , HIS_IP_ADDR            IN      VARCHAR2 -- IP
                                
    , IO_ERR_YN              OUT     VARCHAR2
    , IO_ERR_MSG             OUT     VARCHAR2 
    )
    IS  
        V_EXIST_CNT          NUMBER;        
        V_BNMR_EXM_ACPT_NO   VARCHAR2(20);
    BEGIN
        --골수번호 조회            
        BEGIN
            SELECT CASE WHEN A.BNMR_EXM_ACPT_NO IS NULL THEN '' 
                        ELSE A.BNMR_EXM_ACPT_NO || '-' || TO_CHAR(A.ACPT_DTM, 'YY')
                   END
              INTO V_BNMR_EXM_ACPT_NO
              FROM MSELMAID A
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND SPCM_NO   = IN_SPCM_NO
               --AND ORD_ID    = IN_ORD_ID
               AND BNMR_EXM_ACPT_NO IS NOT NULL 
               AND ROWNUM    = 1
            ;
                
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
        END ; 
            
        BEGIN

            FOR DR IN
            (        
                SELECT A.TH3_RMK_CNTE     PATH_ORD_CD_LIST
                  FROM MSELMSID A
                 WHERE A.HSP_TP_CD     = HIS_HSP_TP_CD
                   AND A.LCLS_COMN_CD  = 'BM_ASP'
                   AND A.SCLS_COMN_CD IN (SELECT R.EXM_CD
                                            FROM MSELMAID R
                                           WHERE R.HSP_TP_CD = HIS_HSP_TP_CD
                                             AND R.SPCM_NO   = IN_SPCM_NO
                                             AND R.ORD_ID    = IN_ORD_ID
                                          )
            ) LOOP

                FOR DR_PATH IN
                ( 
                    SELECT A.PATH_ORD_CD
                         , M.EITM_NM         PATH_ORD_NM
                         , M.EXRM_EXM_CTG_CD PATH_EXM_CTG_CD
                      FROM (SELECT REGEXP_SUBSTR ( DR.PATH_ORD_CD_LIST, '[^,]+', 1, LEVEL ) PATH_ORD_CD
                              FROM DUAL
                           CONNECT BY LEVEL <= REGEXP_COUNT ( DR.PATH_ORD_CD_LIST, ',' ) + 1
                           ) A
                         , MSELMEBM M
                     WHERE M.HSP_TP_CD     = HIS_HSP_TP_CD
                       AND M.EXM_CD        = A.PATH_ORD_CD
                ) LOOP
                   
                    IF DR_PATH.PATH_ORD_CD IS NOT NULL THEN
                    
                        BEGIN                
                            SELECT COUNT(*)
                              INTO V_EXIST_CNT
                              FROM MSEPMERD
                             WHERE HSP_TP_CD   = HIS_HSP_TP_CD
                               AND PT_NO       = IN_PT_NO
                               AND RST_PTHL_NO = IN_SPCM_NO
                               AND EXM_CD      = DR_PATH.PATH_ORD_CD
                            ;
                        END;
                        
                        IF V_EXIST_CNT = 0 THEN
            
                            XSUP.PKG_MSE_PM_RSTEXAM.SAVE_RSTEXAM_FROM_ASIS        
                            (
                              HIS_HSP_TP_CD           -- 위탁병원
                            , HIS_HSP_TP_CD           -- 수탁병원 
                        
                            , IN_PT_NO                -- 환자번호
                            , DR_PATH.PATH_ORD_CD           -- 검사코드     
                            , DR_PATH.PATH_ORD_NM           -- 검사명
                            , DR_PATH.PATH_EXM_CTG_CD       -- 검사분류    
                            , IN_SPCM_NO              -- IN_RST_PTHL_NO -- 위탁병리번호 -> 진검에서 등록하는거라 검체번호 저장해 줌.
                            
                            , TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') -- 위탁등록일자
                            , HIS_STF_NO              -- 위탁등록접원번호
                            , V_BNMR_EXM_ACPT_NO      -- 위탁의뢰비고내용 : 골수번호
                            
                            , IN_SPCM_NO              -- 위탁병리번호의 연결병리번호
                            , ''                      --서브번호 (블록번호)
                            
                            , HIS_HSP_TP_CD
                            , HIS_STF_NO
                            , HIS_PRGM_NM
                            , HIS_IP_ADDR
                                                        
                            , IO_ERR_YN
                            , IO_ERR_MSG
                            ); 
                            
                        ELSE
                            IO_ERR_YN := 'Y';
                            IO_ERR_MSG := '이미 병리과에 위탁등록된 검사입니다.';
                            RETURN;
                        END IF;
                                                
                          
                    END IF;
                END LOOP;
            END LOOP;
        END;
        
    END SAVE_SECTIONBX_RSTEXAM;  
END PKG_MSE_LM_ORDER;