PROCEDURE      PC_MSE_SIDEAUTOPBL ( IN_ORD_ID             IN        VARCHAR2          -- CT,MRI 검사오더의 ORD_ID
                                  , IN_ORD_CD             IN        VARCHAR2          -- CT,MRI 오더 코드
                                  , IN_RSV_DTM            IN         VARCHAR2          -- 예약일 ('yyyyMMdd')
                                  , IN_PT_NO              IN        VARCHAR2          --                         
                                  , IN_FLAG               IN        VARCHAR2           -- I :INSERT , U: UPDATE (D/C)
                                  , HIS_HSP_TP_CD         IN        VARCHAR2
                                  , HIS_STF_NO            IN        VARCHAR2
                                  , HIS_PRGM_NM           IN        VARCHAR2
                                  , HIS_IP_ADDR           IN        VARCHAR2
                                  , IO_ERRYN              IN OUT    VARCHAR2          -- ERROR여부
                                  , IO_ERRMSG             IN OUT    VARCHAR2 )        -- ERROR MESSAGE

AS                                   
/**************************************************************************************
              -- NAME         : 조영제 자동발행
            -- DESC         : 조영제 자동발행 조건을 체크한 후 추가처방 프로시저(PC_MSE_EXECDATA_UPDATE)를 호출한다.
                              조영제 자동발행 조건 : 1. 예약하는 검사가 조영제가 자동 발행되야 하는 오더인지 체크 
                                                  2. 조영제가 자동발행되는 오더가 예약된 건수에 따라 처방되는 조영제가 다름 ( 2건 이하 : 1처방 , 3건 이상 : 2처방 2번)
                                                  3. 단 조영제부작용이 있는 환자일 경우에는 1처방대신 Side 1처방 , 2처방대신 Side 2처방이 발행되야함.
                                                  4. 환자 나이에 따라 2건 이하면 소아1,소아2,소아3 에 해당되는 조영제를 1번 발행함. 3건 이상일 경우 2번 발행.       
                                                  5. 조영제는 하루 최대 200 ML까지만 발행 가능함.
                                                  6. CT오더중 NECK CT ,  CHEST CT 오더 2건이 예약될 경우에는 2건 이하임에도 2처방 조영제를 2번 발행해야함 (예외케이스)
                            : 영상공통코드 EXM_GRP_CD : RC,RM = 조영제 자동발행 되야하는 오더목록 , SK = 조영제 처방종류  ,SDEX = 조영제 자동발행 예외조건에 해당되는 오더목록 (해당 오더들이 2건 발행될 경우 150ml 1회 처방)  
                            : 재료 자동발행 : 1. ORD_CD = 재료 처방코드
                                            2. TRTM_QTY = 재료 발행수량
                                            3. SV_TBL_NM = 재료 발행 테이블  - MSERMAMD : 검사에 발행하는 2차처방 , MOOORFED - 진료간호의 처치관리 테이블 
                                            4. PACT_TP_CD = 조영제 자동발행되는 검사의 수진이 외래,입원,응급 에 따라 재료를 자동발행 할지 말지 정함. I,O,E
                                            5. DUP_PBL_YN = 중복발행여부 - Y면 해당 재료는 한 환자한테 계속 발행 가능, N이면 이미 나와있을경우 발행하지 않음.
                                            6. UPR_ORD_SLIP_CTG_CD = 검사의 상위처방슬립(CT : RC, MRI : RM)
                                            7. ORD_SLIP_CTG_CD = 검사의 상세처방슬립
                                            8. EXM_CD = 조영제 자동발행하는 검사코드 (ALL이면 UPR_ORD_SLIP_CTG_CD의 모든 자동발행 가능한 검사)
                                            9. EXCN_EXRM_TP_CD(VARCHAR2(5) = 예외검사실. MSERMCCC의 EXM_GRP_CD : EXCN_EXRM으로 가서 제외할 검사실을 EXM_GRP_DTL_CD에 넣고 EXM_GRP_DTL_CD_NM에 연결할 코드를 넣는다.
                                               EXCN_EXRM_TP_CD와 MSERMCCC의 EXM_GRP_DTL_CD_NM이 조인 조건이며 MSERMCCC의 EXM_GRL_DTL_CD에 들어있는 실제 검사실 코드가 해당 검사실에 예약시 재료를 자동발행 하지 않는 조건이다.
                                            
                            : IN_FLAG I: 조영제 자동발행 , 기존 발행된 조영제 취소 후 변경된 검사 예약일 기준으로 조영제 발행
                            : IN_FLAG U: 조영제 취소, 예약취소시 기존 예약일에 발행되어 있는 조영제 취소처리 
            -- AUTHOR       : 오원빈  
            -- CREATE DATE  : 2021-09-03
            -- UPDATE DATE  : 최종 수정일자 , 수정자, 수정개요                            
**************************************************************************************/            
     V_SIDE_CHK  VARCHAR2(1) := 'N';
     V_AGE       NUMBER;       
     V_ORD_COUNT NUMBER;                          
     V_SIDE_GUBN VARCHAR2(2) := ''; /* 1: 1처방 , 2: 2처방 , 3: Side 1처방 , 4: Side 2처방 , 5: 소아1 , 6: 소아2 , 7: 소아3 */
     V_EXCP_COUNT    NUMBER;    /*예외오더 건수*/
     V_EXCP_CHK1    VARCHAR2(1) := 'N';    /*예외 1오더가 예약되어 있으면  Y처리하여 예외체크 1,2가 둘다 Y면 오더카운트 -1*/     
     V_EXCP_CHK2    VARCHAR2(1) := 'N';    /*예외 2오더가 예약되어 있으면  Y처리하여 예외체크 1,2가 둘다 Y면 오더카운트 -1*/          
     V_CHL_GUBN  VARCHAR2(1); /*소아구분*/
     V_SIDEREACTION_YN VARCHAR2(1) := 'N'; /*조영제부작용 여부*/
     V_SIDE_ORD  CCOOCBAC.MIF_CD%TYPE := ''; /*발행할 조영제오더*/
     V_QTY       VARCHAR2(1) := '';    /*조영제 발행 횟수*/  
     --V_RSV_DTM   DATE := TO_DATE(IN_RSV_DTM, 'YYYY-MM-DD HH24:MI:SS');
     V_ORD_NM     CCOOCBAC.ORD_NM%TYPE := '';                                                        
     V_ORD_ID     MOOOREXM.ORD_ID%TYPE := ''; /*조영제 ORD_ID*/      
     V_RSV_DTM    MOOOREXM.RSV_DTM%TYPE;  
     V_EXM_PRGR_STS_CD     MOOOREXM.EXM_PRGR_STS_CD%TYPE;     
     V_MED_MIFI_TP_CD     MOOOREXM.MED_MIFI_TP_CD%TYPE;
     V_SIDE_MIFI_TP_CD     VARCHAR2(1);
     /*자동발행되는 재료의 원처방 정보*/
     V_MTL_PBL_YN     VARCHAR2(1) := 'N';    /*재료 발행여부*/   
     V_ORD_CD        MOOOREXM.ORD_CD%TYPE;    /*자동 재료발행 오더코드*/
     G_ORD_ID            MOOOREXM.ORD_ID%TYPE;
     G_PACT_ID            MOOOREXM.PACT_ID%TYPE := '';
     G_PACT_TP_CD        MOOOREXM.PACT_TP_CD%TYPE := '';
     G_RPY_PACT_TP_CD     MOOOREXM.RPY_PACT_TP_CD%TYPE := '';
     G_RPY_PACT_ID         MOOOREXM.RPY_PACT_ID%TYPE := '';           
     G_RPY_CLS_SEQ        MOOOREXM.RPY_CLS_SEQ%TYPE := ''; 
          
     V_PACT_ID        MOOOREXM.PACT_ID%TYPE := '';
     V_PACT_TP_CD    MOOOREXM.PACT_TP_CD%TYPE := '';
     V_RPY_PACT_TP_CD     MOOOREXM.RPY_PACT_TP_CD%TYPE := '';
     V_RPY_PACT_ID         MOOOREXM.RPY_PACT_ID%TYPE := '';           
     V_RPY_CLS_SEQ        MOOOREXM.RPY_CLS_SEQ%TYPE := '';   
     
     V_CT_SLIP    VARCHAR2(10) := 'RC';
     V_MRI_SLIP    VARCHAR2(10) := 'RM';    
     V_ORD_SLIP    VARCHAR2(10) := '';     
     
     V_SIDE_ORD_ID        MSERMRRD.ORD_ID%TYPE;
     V_RRD_RSV_DTM        MSERMRRD.RSV_DTM%TYPE;
     V_RRD_EXRM_TP_CD     MSERMRRD.EXRM_TP_CD%TYPE;
---------------------------------MOOOFRED(TRM)-----     
     V_INS_MIFI_TP_CD    MOOORFED.MED_MIFI_TP_CD%TYPE;   
     V_CURRENT_RSV_DTM     VARCHAR2(20) :=''; --해당 오더의 현재 예약일
     V_AFTER_RSV_DTM     VARCHAR2(20) :='';
     V_BEFORE_RSV_DTM    VARCHAR2(20) :='';
    
    V_DATA_YN VARCHAR2(1) := 'N';  
    V_LOOP_CNT NUMBER := 0;
BEGIN

/*조영제 자동발행 */
    IF IN_FLAG = 'I' THEN  
        /*해당 오더의 예약일이 없으면 리턴 , 예약일이 오늘 이전이면 리턴*/
        BEGIN
            SELECT RSV_DTM         
                 , EXRM_TP_CD
              INTO V_RRD_RSV_DTM
                 , V_RRD_EXRM_TP_CD
              FROM MSERMRRD
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND ORD_ID = IN_ORD_ID
               ;
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN  
                RETURN; 
        END;                    
        IF TRUNC(V_RRD_RSV_DTM) < TRUNC(SYSDATE) THEN
            RETURN;
        END IF;
    /*예약한 오더 검사실처방 슬립 확인*/
        BEGIN
            SELECT B.UPR_ORD_SLIP_CTG_CD
              INTO V_ORD_SLIP
              FROM MSERMMMC A
                  ,CCOOCCSC B
             WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
               AND A.HSP_TP_CD = B.HSP_TP_CD
               AND A.EXM_CD = IN_ORD_CD
               AND A.ORD_SLIP_CTG_CD = B.ORD_SLIP_CTG_CD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN;            
        END;                         
    /*발행된 오더의 PACT_ID  */             
        BEGIN
            SELECT PACT_ID
                  ,PACT_TP_CD
                  ,RPY_PACT_ID
                  ,RPY_PACT_TP_CD
                  ,RPY_CLS_SEQ
                  ,MED_MIFI_TP_CD           
              INTO V_PACT_ID
                    ,V_PACT_TP_CD
                    ,V_RPY_PACT_ID
                    ,V_RPY_PACT_TP_CD
                    ,V_RPY_CLS_SEQ 
                    ,V_MED_MIFI_TP_CD
              FROM MOOOREXM
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND ORD_ID    = IN_ORD_ID;  
        END;                          
    /*예약한 오더가 조영제가 자동발행되야 하는 오더인지 체크*/
        BEGIN
            SELECT 'Y'
               INTO V_SIDE_CHK
               FROM MSERMCCC
             WHERE HSP_TP_CD = HIS_HSP_TP_CD  
               AND EXM_GRP_CD = V_ORD_SLIP
               AND EXM_GRP_DTL_CD = IN_ORD_CD;
        EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 RETURN;      
        END;                                                
    /*나이체크*/
        BEGIN
            SELECT XBIL.FT_PCT_AGE('AGE',SYSDATE,PT_BRDY_DT)
              INTO V_AGE    
              FROM PCTPCPAM_DAMO
             WHERE PT_NO = IN_PT_NO;
        EXCEPTION
            WHEN OTHERS THEN
                IO_ERRYN := 'Y';
                IO_ERRMSG := '환자의 나이정보가 없습니다.' || 'PC_MSE_SIDEAUTOPBL';            
                RETURN;                               
        END;     
        IF HIS_HSP_TP_CD = '01' THEN                        
            /*소아구분 1: 소아1, 2:소아2 ,3:소아3 */
            BEGIN
                IF V_AGE BETWEEN 0 AND 5 THEN
                    V_CHL_GUBN := '1';
                ELSIF V_AGE BETWEEN 6 AND 10 THEN
                    V_CHL_GUBN := '2';
                ELSIF V_AGE BETWEEN 11 AND 15 THEN
                    V_CHL_GUBN := '3';
                ELSE V_CHL_GUBN := '';
                END IF;                     
            END;                        
        ELSIF HIS_HSP_TP_CD = '02' THEN 
            /*소아구분 1: 소아1, 2:소아2 ,3:소아3 */
            BEGIN
                IF V_AGE BETWEEN 0 AND 4 THEN
                    V_CHL_GUBN := '1';
                ELSIF V_AGE BETWEEN 5 AND 8 THEN
                    V_CHL_GUBN := '2';
                ELSIF V_AGE BETWEEN 9 AND 12 THEN
                    V_CHL_GUBN := '3';
                ELSE V_CHL_GUBN := '';
                END IF;                     
            END;          
        ELSIF HIS_HSP_TP_CD = '03' THEN 
            /*빛고을은 소아조영제 처방 나가지 않아야 한다고 함. */
            BEGIN
                V_CHL_GUBN := '';          
            END;                      
        END IF;       
        
    /* 해당 환자 검사예약일에 조영제가 자동발행되는 오더 건수 조회 */
        BEGIN
            SELECT COUNT(*)      
              INTO V_ORD_COUNT
              FROM MSERMRRD A
                  ,MSERMCCC B
             WHERE 1=1
               AND A.HSP_TP_CD = B.HSP_TP_CD
               AND A.HSP_TP_CD = HIS_HSP_TP_CD
               AND A.PT_NO = IN_PT_NO
               --AND TRUNC(A.RSV_DTM) = IN_RSV_DTM   --해당 예약일 확인
               AND A.RSV_DTM BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999               
               AND A.ORD_CD = B.EXM_GRP_DTL_CD
               AND B.EXM_GRP_CD = V_ORD_SLIP; 
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN
                V_ORD_COUNT := 0;           
        END;
        IF V_ORD_COUNT = 0 THEN 
            RETURN;                    
        ELSE                     
        /*예약일이 없으면 예약취소, 있으면 예약 변경*/
            BEGIN
                SELECT RSV_DTM
                  INTO V_RSV_DTM
                  FROM MOOOREXM
                 WHERE HSP_TP_CD = HIS_HSP_TP_CD
                   AND ORD_ID    = IN_ORD_ID ;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_RSV_DTM := '';
            END;                    
        /*예약을 취소한 케이스면 해당 예약일에 자동발행 가능한 오더 하나 선택해서 해당 검사에 조영제 발행 */            
            IF V_RSV_DTM IS NULL OR TRUNC(V_RSV_DTM) <> IN_RSV_DTM THEN             
                SELECT A.ORD_ID
                  INTO V_ORD_ID
                  FROM MSERMRRD A
                      ,MSERMCCC B
                 WHERE 1=1
                   AND A.HSP_TP_CD = B.HSP_TP_CD
                   AND A.HSP_TP_CD = HIS_HSP_TP_CD
                   AND A.PT_NO = IN_PT_NO
--                   AND TRUNC(A.RSV_DTM) = IN_RSV_DTM   --해당 예약일 확인
                   AND A.RSV_DTM BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999
                   AND A.ORD_CD = B.EXM_GRP_DTL_CD
                   AND B.EXM_GRP_CD = V_ORD_SLIP
                   AND ROWNUM = 1
                   ;
            ELSE
                V_ORD_ID := IN_ORD_ID;
            END IF;        
        END IF;      
        /*예외 오더 체크*/          
        FOR REC IN (SELECT DISTINCT RMK_CNTE
                      FROM MSERMCCC
                     WHERE HSP_TP_CD = HIS_HSP_TP_CD
                       AND EXM_GRP_CD = 'SDEX'    
                       ORDER BY RMK_CNTE ASC                       
                    )
        LOOP         
--        dbms_output.put_line('V_EXCP_CHK1: '|| V_EXCP_CHK1 ||', '|| 'V_EXCP_CHK2: ' || V_EXCP_CHK2 || ',' ||'그룹 : ' || REC.RMK_CNTE);
        --반복 그룹의 코드1이 예약되어 있으면 Y 없으면 N           
            BEGIN
                SELECT DISTINCT 'Y'
                  INTO V_EXCP_CHK1
                  FROM MSERMRRD A
                 WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                   AND A.PT_NO = IN_PT_NO
--                   AND TRUNC(A.RSV_DTM) = IN_RSV_DTM     
                   AND A.RSV_DTM BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999                   
                   AND A.ORD_CD IN (SELECT TH1_ASST_GRP_NM                                      
                                         FROM MSERMCCC
                                     WHERE HSP_TP_CD = HIS_HSP_TP_CD
                                       AND EXM_GRP_CD = 'SDEX'
                                       AND RMK_CNTE  = REC.RMK_CNTE);              
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_EXCP_CHK1 := 'N';
            END;         
        --반복 그룹의 코드2가 예약되어 있으면 Y 없으면 N            
            BEGIN
                SELECT DISTINCT 'Y'
                  INTO V_EXCP_CHK2
                  FROM MSERMRRD A
                 WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                   AND A.PT_NO = IN_PT_NO
--                   AND TRUNC(A.RSV_DTM) = IN_RSV_DTM
                   AND A.RSV_DTM BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999
                   AND A.ORD_CD IN (SELECT TH2_ASST_GRP_NM                                      
                                         FROM MSERMCCC
                                     WHERE HSP_TP_CD = HIS_HSP_TP_CD
                                       AND EXM_GRP_CD = 'SDEX'
                                       AND RMK_CNTE  = REC.RMK_CNTE);              
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_EXCP_CHK2 := 'N';
            END;            
            dbms_output.put_line('V_EXCP_CHK1: '|| V_EXCP_CHK1 ||', '|| 'V_EXCP_CHK2: ' || V_EXCP_CHK2 || ',' ||'그룹 : ' || REC.RMK_CNTE);
            --예외 있으면 반복 탈출        
            EXIT WHEN V_EXCP_CHK1 = 'Y' AND V_EXCP_CHK2 = 'Y';            
        END LOOP;                   
        --예외오더 동일그룹의 값1,값2가 예약되어 있으면 150ML 추가 
        BEGIN            
            IF V_EXCP_CHK1 = 'Y' AND V_EXCP_CHK2 = 'Y' THEN --예외 오더 2개 이외에도 자동발행 오더가 예약되어서 3건이 되면 처방취소하고 100ml 2회 처방하기 위해 카운트 -1
                V_ORD_COUNT := V_ORD_COUNT - 1;                        
            END IF;                    
        END;    
        /*해당환자 조영제 부작용이 4개 병원중 한 곳에서라도 있었는지 확인*/
        BEGIN
            SELECT 'Y'
              INTO V_SIDEREACTION_YN
               FROM MSERMMSD         
             WHERE 1=1
               AND PT_NO =  IN_PT_NO
               AND CNMD_SDEF_TP_CD = 'S'
               AND ROWNUM =1 ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_SIDEREACTION_YN := 'N';        
--                BEGIN
--                    SELECT 'Y'
--                      INTO V_SIDEREACTION_YN
--                      FROM MSERMMSE A
--                          ,PCTPCPAM_DAMO B
--                     WHERE A.PT_NO = B.PT_NO
--                       AND A.PT_NO = IN_PT_NO      
--                       AND REPLACE(A.CNMD_SDEF_CNTE,'-','') IS NOT NULL --조영제부작용 내용
--                       AND A.USE_YN = 'Y'
--                       AND ROWNUM = 1;
--                EXCEPTION
--                    WHEN NO_DATA_FOUND THEN
--                        V_SIDEREACTION_YN := 'N';           
--                END;
        END;    
        IF HIS_HSP_TP_CD = '01' THEN
            /*조건에 따른 조영제 처방 종류 선택*/
            BEGIN                    
                /*오더가 1건 이하면서 나이가 0~5세면 소아1, 1회 처방 */
                IF (V_ORD_COUNT < 2) AND (V_CHL_GUBN = '1') THEN 
                    V_SIDE_GUBN := '5';
                    V_QTY := '1';
                /*오더가 1건 이하면서 나이가 6~10세면 소아2, 1회 처방 */            
                ELSIF (V_ORD_COUNT <2) AND (V_CHL_GUBN = '2') THEN
                    V_SIDE_GUBN := '6';        
                    V_QTY := '1';            
                /*오더가 1건 이하면서 나이가 11~15세면 소아3, 1회 처방 */        
                ELSIF (V_ORD_COUNT <2) AND (V_CHL_GUBN = '3') THEN                                                               
                    V_SIDE_GUBN := '7';        
                    V_QTY := '1';            
                /*오더가 2건 이상이면서 나이가 0~5세면 소아1, 2회 처방 */                
                ELSIF (V_ORD_COUNT >= 2) AND (V_CHL_GUBN = '1') THEN
                    V_SIDE_GUBN := '5';        
                    V_QTY := '2';            
                /*오더가 2건 이상이면서 나이가 6~10세면 소아2, 2회 처방 */                        
                ELSIF (V_ORD_COUNT >= 2) AND (V_CHL_GUBN = '2') THEN             
                    V_SIDE_GUBN := '6';        
                    V_QTY := '2';            
                /*오더가 2건 이상이면서 나이가 11~15세면 소아3, 2회 처방 */                        
                ELSIF (V_ORD_COUNT >= 2) AND (V_CHL_GUBN = '3') THEN                            
                    V_SIDE_GUBN := '7';        
                    V_QTY := '2';            
                /*오더가 1건 이하이면서 조영제 부작용이 있으면 Side 1처방을 1회 처방 */                        
                ELSIF (V_ORD_COUNT <2) AND (V_SIDEREACTION_YN = 'Y') THEN
                    V_SIDE_GUBN := '3';        
                    V_QTY := '1';            
                /*오더가 2건 이상이면서 조영제 부작용이 있으면 Side 2처방을 2회 처방 */                                
                ELSIF (V_ORD_COUNT >= 2) AND (V_SIDEREACTION_YN = 'Y') THEN        
                    V_SIDE_GUBN := '4';        
                    V_QTY := '2';            
                /*오더가 1건 이하이면 1처방을 1회 처방 */                                        
                ELSIF (V_ORD_COUNT <2) THEN                                                                
                    V_SIDE_GUBN := '1';        
                    V_QTY := '1';            
                /*오더가 2건 이상이면 2처방을 2회 처방 */                                        
                ELSIF (V_ORD_COUNT >= 2) THEN                
                    V_SIDE_GUBN := '2';        
                    V_QTY := '2';                    
                END IF;
            END;   
        ELSIF HIS_HSP_TP_CD = '02' THEN
            /*조건에 따른 조영제 처방 종류 선택*/
            BEGIN                    
                /*오더가 2건 이하면서 나이가 0~5세면 소아1, 1회 처방 */
                IF (V_ORD_COUNT < 3) AND (V_CHL_GUBN = '1') THEN 
                    V_SIDE_GUBN := '5';
                    V_QTY := '1';
                /*오더가 2건 이하면서 나이가 6~10세면 소아2, 1회 처방 */            
                ELSIF (V_ORD_COUNT <3) AND (V_CHL_GUBN = '2') THEN
                    V_SIDE_GUBN := '6';        
                    V_QTY := '1';            
                /*오더가 2건 이하면서 나이가 11~15세면 소아3, 1회 처방 */        
                ELSIF (V_ORD_COUNT <3) AND (V_CHL_GUBN = '3') THEN                                                               
                    V_SIDE_GUBN := '7';        
                    V_QTY := '1';            
                /*오더가 3건 이상이면서 나이가 0~5세면 소아1, 2회 처방 */                
                ELSIF (V_ORD_COUNT >= 3) AND (V_CHL_GUBN = '1') THEN
                    V_SIDE_GUBN := '5';        
                    V_QTY := '2';            
                /*오더가 3건 이상이면서 나이가 6~10세면 소아2, 2회 처방 */                        
                ELSIF (V_ORD_COUNT >= 3) AND (V_CHL_GUBN = '2') THEN             
                    V_SIDE_GUBN := '6';        
                    V_QTY := '2';            
                /*오더가 3건 이상이면서 나이가 11~15세면 소아3, 2회 처방 */                        
                ELSIF (V_ORD_COUNT >= 3) AND (V_CHL_GUBN = '3') THEN                            
                    V_SIDE_GUBN := '7';        
                    V_QTY := '2';            
                /*오더가 2건 이하이면서 조영제 부작용이 있으면 Side 1처방을 1회 처방 */                        
                ELSIF (V_ORD_COUNT <3) AND (V_SIDEREACTION_YN = 'Y') THEN
                    V_SIDE_GUBN := '3';        
                    V_QTY := '1';            
                /*오더가 3건 이상이면서 조영제 부작용이 있으면 Side 2처방을 2회 처방 */                                
                ELSIF (V_ORD_COUNT >= 3) AND (V_SIDEREACTION_YN = 'Y') THEN        
                    V_SIDE_GUBN := '4';        
                    V_QTY := '2';            
                /*오더가 2건 이하이면 1처방을 1회 처방 */                                        
                ELSIF (V_ORD_COUNT <3) THEN                                                                
                    V_SIDE_GUBN := '1';        
                    V_QTY := '1';            
                /*오더가 3건 이상이면 2처방을 2회 처방 */                                        
                ELSIF (V_ORD_COUNT >= 3) THEN                
                    V_SIDE_GUBN := '2';        
                    V_QTY := '2';                    
                END IF;
            END;       
        ELSIF HIS_HSP_TP_CD = '03' THEN
            /*조건에 따른 조영제 처방 종류 선택*/
            BEGIN                    
                /*오더가 1건 이하면서 소아1, 1회 처방 */
                IF (V_ORD_COUNT < 2) AND (V_CHL_GUBN = '1') THEN 
                    V_SIDE_GUBN := '5';
                    V_QTY := '1';
                /*오더가 1건 이하면서 소아2, 1회 처방 */            
                ELSIF (V_ORD_COUNT <2) AND (V_CHL_GUBN = '2') THEN
                    V_SIDE_GUBN := '6';        
                    V_QTY := '1';            
                /*오더가 1건 이하면서 소아3, 1회 처방 */        
                ELSIF (V_ORD_COUNT <2) AND (V_CHL_GUBN = '3') THEN                                                               
                    V_SIDE_GUBN := '7';        
                    V_QTY := '1';            
                /*오더가 2건 이상이면서  소아1, 2회 처방 */                
                ELSIF (V_ORD_COUNT >= 2) AND (V_CHL_GUBN = '1') THEN
                    V_SIDE_GUBN := '5';        
                    V_QTY := '2';            
                /*오더가 2건 이상이면서 소아2, 2회 처방 */                        
                ELSIF (V_ORD_COUNT >= 2) AND (V_CHL_GUBN = '2') THEN             
                    V_SIDE_GUBN := '6';        
                    V_QTY := '2';            
                /*오더가 2건 이상이면서 소아3, 2회 처방 */                        
                ELSIF (V_ORD_COUNT >= 2) AND (V_CHL_GUBN = '3') THEN                            
                    V_SIDE_GUBN := '7';        
                    V_QTY := '2';            
                /*오더가 1건 이하이면서 조영제 부작용이 있으면 Side 1처방을 1회 처방 */                        
                ELSIF (V_ORD_COUNT <2) AND (V_SIDEREACTION_YN = 'Y') THEN
                    V_SIDE_GUBN := '3';        
                    V_QTY := '1';            
                /*오더가 2건 이상이면서 조영제 부작용이 있으면 Side 2처방을 1회 처방 */          
                ELSIF (V_ORD_COUNT >= 2) AND (V_SIDEREACTION_YN = 'Y') THEN        
                    V_SIDE_GUBN := '4';        
                    V_QTY := '1';            
                /*오더가 1건 이하이면 1처방을 1회 처방 */                                        
                ELSIF (V_ORD_COUNT <2) THEN                                                                
                    V_SIDE_GUBN := '1';        
                    V_QTY := '1';            
                /*오더가 2건 이상이면 2처방을 1회 처방 */                                        
                ELSIF (V_ORD_COUNT >= 2) THEN                
                    V_SIDE_GUBN := '2';        
                    V_QTY := '1';                    
                END IF;
            END;                             
        END IF;
   
        /*추가처방할 조영제 오더*/
        BEGIN           
            SELECT CNMD_KND_CD
              INTO V_SIDE_ORD
              FROM MSERMSMD
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND CNMD_TP_CD = V_SIDE_GUBN
               AND EXM_CD = IN_ORD_CD;         
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN               
                V_SIDE_ORD := null;                                      
        END;   
        /*2처방이 비어있으면 MRI 검사인지 확인해서 1처방 2회 발행*/             
        BEGIN
            IF V_ORD_SLIP = V_MRI_SLIP AND (V_SIDE_ORD IS NULL OR V_SIDE_ORD = ' ') THEN
                BEGIN                                      
                    SELECT CNMD_KND_CD
                      INTO V_SIDE_ORD
                      FROM MSERMSMD
                     WHERE HSP_TP_CD = HIS_HSP_TP_CD
                       AND CNMD_TP_CD = TO_CHAR(TO_NUMBER(V_SIDE_GUBN) - 1)
                       AND EXM_CD = IN_ORD_CD;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN    
                        IO_ERRYN := 'Y';
                        IO_ERRMSG := 'PC_MSE_SIDEAUTOPBL_263' || ' ' || SQLERRM;            
                        ROLLBACK;
                        RETURN;
                END; 
    --        ELSIF V_SIDE_ORD IS NULL THEN
    --            IO_ERRYN := 'Y';
    --            IO_ERRMSG := IN_ORD_CD || ' 오더와 매칭되는 ' ||'조영제 오더가 없습니다.';                                 
    --            ROLLBACK;
    --            RETURN;
            END IF;                
        END;      
    /*입원처방인데 예약일 이전에 퇴원일이 있으면 RETURN 하도록 수정요청 .. 재료처방일이 퇴원일 이후에 나와도 가퇴원상태면 수납될 수 있기 때문 .. 2022.02.15*/
        IF V_RPY_PACT_TP_CD = 'I' THEN
            BEGIN
                SELECT (CASE WHEN TO_CHAR(B.DS_DTM,'YYYY-MM-DD HH24:MI:SS') < TO_CHAR(A.RSV_DTM,'YYYY-MM-DD HH24:MI:SS') THEN 'Y'
				                                                                                                         ELSE 'N'
				        END) AS MTL_PBL_YN
                  INTO V_MTL_PBL_YN
                  FROM MOOOREXM A 
                     , ACPPRAAM B
                 WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                   AND A.HSP_TP_CD = B.HSP_TP_CD
                   AND A.RPY_PACT_ID = B.PACT_ID
                   AND A.ORD_ID = V_ORD_ID
                   AND B.APCN_YN = 'N'
                   ;
            END;                    
            IF V_MTL_PBL_YN = 'Y' THEN
                RETURN;
            END IF;
        END IF;                         
        /*추가처방 삭제*/              
        BEGIN         
            FOR REC_S IN (
                SELECT A.ORD_ID 
--                  INTO V_SIDE_ORD_ID
                   FROM MSERMRRD A
                      , MOOOREXM B
                 WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                   AND A.PT_NO = IN_PT_NO
                   AND A.PT_NO = B.PT_NO
                   AND A.ORD_ID = B.ORD_ID 
                   AND B.EXM_PRGR_STS_CD = 'A'    --예약상태일때만 취소
--                   AND TRUNC(A.RSV_DTM) = IN_RSV_DTM        
                   AND A.RSV_DTM BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999
                   AND B.ORD_SLIP_CTG_CD LIKE V_ORD_SLIP || '%' --같은 처방슬립만 삭제 
                   AND EXISTS(SELECT 1
                                FROM MSERMAMD
                                 WHERE HSP_TP_CD = A.HSP_TP_CD
                                 AND ATPB_YN = 'Y'
                                 AND ORD_ID = A.ORD_ID)
            )
            LOOP
                BEGIN
                    DELETE /* HIS.MS.IV.RM.EX.DeleteTm2SOrdInfo */
                      FROM MSERMAMD X
                     WHERE 1=1
                       AND X.HSP_TP_CD = HIS_HSP_TP_CD
                       AND X.ORD_ID = REC_S.ORD_ID
                       AND X.RPY_USE_QTY > 0                   
                       AND X.RPY_STS_CD  IS NULL 
                                 ;                             
                END;            
                IF HIS_HSP_TP_CD = '01' THEN   
                /*학동만 오픈초기에 소모재료로 발행된 중앙부집계될 재료를 삭제한다 (미수납에 한해서만)*/
                    BEGIN
                        DELETE /* HIS.MS.IV.RM.EX.DeleteTm2SOrdInfo */
                          FROM MSERMAMD X
                         WHERE 1=1
                           AND X.HSP_TP_CD = HIS_HSP_TP_CD
    --                       AND X.RSV_DT BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999
                           AND X.ORD_ID = REC_S.ORD_ID
                           AND X.RPY_USE_QTY > 0                   
                           AND X.RPY_STS_CD  IS NULL 
                           AND X.SGL_MIF_CD = '30073247'
                           ;                             
                    END; 
                    BEGIN
                        DELETE /* HIS.MS.IV.RM.EX.DeleteTm2SOrdInfo */
                          FROM MSERMAMD X
                         WHERE 1=1
                           AND X.HSP_TP_CD = HIS_HSP_TP_CD
    --                       AND X.RSV_DT BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999
                           AND X.ORD_ID = REC_S.ORD_ID
                           AND X.RPY_USE_QTY > 0                   
                           AND X.RPY_STS_CD  IS NULL 
                           AND X.SGL_MIF_CD = '30081274'
                           ;                             
                    END; 
                    BEGIN
                        DELETE /* HIS.MS.IV.RM.EX.DeleteTm2SOrdInfo */
                          FROM MSERMAMD X
                         WHERE 1=1
                           AND X.HSP_TP_CD = HIS_HSP_TP_CD
    --                       AND X.RSV_DT BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999
                           AND X.ORD_ID = REC_S.ORD_ID
                           AND X.RPY_USE_QTY > 0                   
                           AND X.RPY_STS_CD  IS NULL 
                           AND X.SGL_MIF_CD = '30081754'
                           ;                             
                    END;  
                    BEGIN
                        DELETE /* HIS.MS.IV.RM.EX.DeleteTm2SOrdInfo */
                          FROM MSERMAMD X
                         WHERE 1=1
                           AND X.HSP_TP_CD = HIS_HSP_TP_CD
    --                       AND X.RSV_DT BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999
                           AND X.ORD_ID = REC_S.ORD_ID
                           AND X.RPY_USE_QTY > 0                   
                           AND X.RPY_STS_CD  IS NULL 
                           AND X.SGL_MIF_CD = '30000452'
                           ;                             
                    END; 
                END IF;
            END LOOP;                                                
        /*기존에 발행한 재료 DC 처리*/                             
/*    SAVEORDER 대신 추가처방 로직으로 수정*/         
            BEGIN
                FOR REC IN (
                          SELECT B.ORD_ID 
                                ,B.PACT_ID 
                        	FROM MOOORPTD A
                        	    ,MOOORFED B
                        	    ,MOOOREXM C
                        	WHERE A.HSP_TP_CD= HIS_HSP_TP_CD
                        	  AND A.HSP_TP_CD = B.HSP_TP_CD
                        	  AND A.HSP_TP_CD = C.HSP_TP_CD
--MOOORPTD와 MOOOREXM 의 ODDSC_TP_CD가 다른 데이터가 있어서 주석처리. 2022.04.28                        	                        	  
--                        	  AND A.ODDSC_TP_CD = B.ODDSC_TP_CD
--                        	  AND A.ODDSC_TP_CD = C.ODDSC_TP_CD
--                        	  AND A.ODDSC_TP_CD ='C'
                        	  AND A.ORD_ID = B.ORD_ID
                        	  AND A.REL_ORD_ID = C.ORD_ID                       
                              AND B.ORD_MRK_CTG_CD = 'A'
                              AND B.ORD_DT  = IN_RSV_DTM
                              AND A.PT_NO = B.PT_NO
                              AND A.PT_NO = C.PT_NO
                              AND A.PT_NO = IN_PT_NO
                              AND B.RPY_STS_CD ='N'
                              AND EXISTS(SELECT 1
                        	               FROM MSERMCCC
                                          WHERE HSP_TP_CD = A.HSP_TP_CD
                                            AND ORD_CTG_CD = 'BR1'
                                            AND EXM_GRP_CD = V_ORD_SLIP
                                            AND EXM_GRP_DTL_CD = C.ORD_CD
                                         )
                            )
                LOOP                                
                    IF REC.ORD_ID IS NOT NULL THEN
                        BEGIN
                            PKG_MSE_SIDE_INTERFACE.PC_DELETE_TRT_ORDER(HIS_HSP_TP_CD
                                                                      ,IN_PT_NO
                                                                      ,REC.PACT_ID
                                                                      ,REC.ORD_ID
                                                                      ,HIS_STF_NO
                                                                      ,HIS_PRGM_NM
                                                                      ,HIS_IP_ADDR);
                        EXCEPTION
                            WHEN OTHERS THEN                                                  
                                IO_ERRYN := 'Y';
                                IO_ERRMSG := sqlerrm;
                                ROLLBACK;
                                RETURN;                                                       
                        END;
                    END IF; 
                END LOOP;
            END;        
        END;  
        BEGIN
            SELECT TO_CHAR(RSV_DTM,'YYYYMMDD')
              INTO V_CURRENT_RSV_DTM
              FROM MSERMRRD
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND ORD_ID = IN_ORD_ID;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN;
        END;                                   
        /*현재 예약일이 매개변수 예약일과 다르다면 매개변수 예약일의 PACT_ID로 업데이트 */
        IF V_CURRENT_RSV_DTM != IN_RSV_DTM THEN
            SELECT O.PACT_ID
                 , O.PACT_TP_CD
                 , O.RPY_PACT_ID
                 , O.RPY_PACT_TP_CD
                 , O.RPY_CLS_SEQ
              INTO V_PACT_ID
                 , V_PACT_TP_CD
                 , V_RPY_PACT_ID
                 , V_RPY_PACT_TP_CD
                 , V_RPY_CLS_SEQ
              FROM MOOOREXM O    
                 , MSERMRRD R
             WHERE O.HSP_TP_CD = HIS_HSP_TP_CD
               AND O.HSP_TP_CD = R.HSP_TP_CD
               AND O.ORD_ID    = R.ORD_ID     
               AND TO_CHAR(R.RSV_DTM,'YYYYMMDD') = IN_RSV_DTM
               AND O.PT_NO = R.PT_NO
               AND O.PT_NO = IN_PT_NO
               AND EXISTS(SELECT 1 
                            FROM MSERMCCC
                           WHERE HSP_TP_CD = O.HSP_TP_CD
                             AND ORD_CTG_CD = 'BR1'
                             AND EXM_GRP_CD = V_ORD_SLIP
                             AND EXM_GRP_DTL_CD = O.ORD_CD);
        END IF; 
/*추가처방 발행*/                                         
        BEGIN                              
            /*원처방이 비급여면 조영제 비급여로 발행 ,아니면 보험으로 발행*/
            IF V_MED_MIFI_TP_CD = 'S' THEN 
                V_SIDE_MIFI_TP_CD  := '2';
            ELSE                 
                V_SIDE_MIFI_TP_CD := '1';
            END IF;        
--            RAISE_APPLICATION_ERROR(-20001,V_SIDE_ORD);
            PKG_MSE_SIDE_INTERFACE.PC_INSERT_MSERMAMD_AUTO( HIS_HSP_TP_CD                        
                                        , V_ORD_ID                       
                                        , 'N'                         --신구구분(N:신규, O:구)
                                        , ''                          --재료코드
                                        , V_SIDE_MIFI_TP_CD                            --보험 비보험   (F:무수가, '1':급여 ,'2':비급여)
                                        , '0'                                --사용량
                                        , V_QTY                        --수납사용량
                                        , V_SIDE_ORD 
                                        , IN_RSV_DTM        --검사예약일 (추가재료 처방일)                        
                                        , HIS_STF_NO                        
                                        , HIS_PRGM_NM                       
                                        , HIS_IP_ADDR );
            /*조영제 자동발행 후 추가로 자동발행되야하는 재료 발행*/                                        
            BEGIN
                FOR REC IN (
                        SELECT ORD_CD    TRM_ORD_CD
                             , EXM_CD
                             , PACT_TP_CD 
                             , TRTM_QTY 
                             , SV_TBL_NM
                             , MED_MIFI_TP_CD    RFED_MIFI_TP_CD
                             , NVL((SELECT INS_MIFI_TP_CD
                                      FROM AIMIRPMC
                                     WHERE HSP_TP_CD = A.HSP_TP_CD
                                       AND APY_END_DT = '9999-12-31'
                                       AND MIF_CD = A.ORD_CD),'1')                     AMD_MIFI_TP_CD    --없으면 Default로 급여   
                             , UPR_ORD_SLIP_CTG_CD         
                             , DUP_PBL_YN
                             , ORD_SLIP_CTG_CD
                         FROM MSERMATD A   --재료자동발행정보
                        WHERE A.HSP_TP_CD = HIS_HSP_TP_CD   
                          AND NOT EXISTS(SELECT 1
                                           FROM MSERMRRD X
                                              , MSERMCCC Y
                                          WHERE X.HSP_TP_CD= HIS_HSP_TP_CD
                                            AND X.HSP_TP_CD = Y.HSP_TP_CD
                                            AND Y.EXM_GRP_CD = 'EXCN_EXRM'
                                            AND X.EXRM_TP_CD = Y.EXM_GRP_DTL_CD
                                            AND X.ORD_ID = IN_ORD_ID
                                            AND Y.USE_YN = 'Y'
                                            AND Y.EXM_GRP_DTL_CD_NM = A.EXCN_EXRM_TP_CD
                                         )                                             
                )
                LOOP   
                    IF REC.DUP_PBL_YN = 'N' THEN
                    /*처지재료에 한해서 해당환자의 해당발행일에 같은 재료가 나가지 않도록 수정*/
                        BEGIN
                            SELECT 'Y'
                              INTO V_MTL_PBL_YN
                              FROM MOOORFED A
                                 , MOOORPTD B
                             WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                               AND A.HSP_TP_CD = B.HSP_TP_CD
                               AND A.ORD_ID = B.ORD_ID
                               AND A.ODDSC_TP_CD  = 'C'                                
                               AND A.PT_NO = IN_PT_NO
                               AND A.ORD_DT = IN_RSV_DTM                           
                               AND A.ORD_CD = REC.TRM_ORD_CD
                               AND A.RTN_DT IS NULL
                               AND ROWNUM  = 1
                               ;
                         EXCEPTION
                             WHEN NO_DATA_FOUND THEN
                                 V_MTL_PBL_YN := 'N';
                         END;                        
                         IF V_MTL_PBL_YN = 'Y' THEN
                             RETURN;
                         END IF;
                    END IF;     
                    BEGIN
                        SELECT A.ORD_CD
                              ,A.ORD_ID
                              ,A.PACT_ID                        
                              ,A.PACT_TP_CD
                              ,A.RPY_PACT_ID
                              ,A.RPY_PACT_TP_CD
                              ,A.RPY_CLS_SEQ
                          INTO V_ORD_CD
                              ,G_ORD_ID     
                              ,G_PACT_ID
                              ,G_PACT_TP_CD
                              ,G_RPY_PACT_ID
                              ,G_RPY_PACT_TP_CD
                              ,G_RPY_CLS_SEQ
                          FROM MOOOREXM A
                         WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                           AND A.RSV_DTM BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999
                           AND A.PT_NO = IN_PT_NO
                           AND A.ORD_CD = REC.EXM_CD ; 
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            V_ORD_CD := 'XXXXX';
                    END;              
                    /*조영제 자동발행되는 모든 검사가 예약될 경우 재료 자동발행 (예약된 검사의 처방슬립과 같은 재료만) , 환자구분이  ALL이 아니면 처방의 PACT_TP_CD와 같을 경우에만 재료발행*/                        
                    IF  V_ORD_SLIP = REC.UPR_ORD_SLIP_CTG_CD AND REC.PACT_TP_CD = V_PACT_TP_CD AND (REC.EXM_CD = IN_ORD_CD OR REC.EXM_CD = 'ALL') THEN
                        IF REC.SV_TBL_NM = 'MOOORFED' THEN    --중앙부 집계     
                            PKG_MSE_SIDE_INTERFACE.PC_INSERT_TRT_ORDER( HIS_HSP_TP_CD                        
                                                        , IN_PT_NO
                                                        , V_PACT_ID
                                                        , V_PACT_TP_CD
                                                        , V_RPY_PACT_ID
                                                        , V_RPY_PACT_TP_CD
                                                        , V_RPY_CLS_SEQ
                                                        , REC.TRM_ORD_CD         --IN_ORD_CD
                                                        , IN_RSV_DTM         --IN_ORD_DT
                                                        , IN_ORD_ID          --IN_REL_ORD_ID
                                                        , REC.TRTM_QTY        --IN_TRTM_QTY
                                                        , REC.RFED_MIFI_TP_CD       --IN_MED_MIFI_TP_CD    S:비급여 , NULL : 보험 ,급여 : N                      
                                                        , HIS_STF_NO                        
                                                        , HIS_PRGM_NM                       
                                                        , HIS_IP_ADDR );                         
                        ELSIF REC.SV_TBL_NM = 'MSERMAMD' THEN --부서 집계                                                                                                                                 
                            PKG_MSE_SIDE_INTERFACE.PC_INSERT_MSERMAMD_AUTO( HIS_HSP_TP_CD                        
                                                        , V_ORD_ID                       
                                                        , 'N'                         --신구구분(N:신규, O:구)
                                                        , ''                          --재료코드
                                                        , REC.AMD_MIFI_TP_CD              --보험 비보험   (F:무수가, '1':급여 ,'2':비급여)
                                                        , '0'                         --사용량(무수가)
                                                        , REC.TRTM_QTY                 --수납사용량
                                                        , REC.TRM_ORD_CD 
                                                        , IN_RSV_DTM                  --검사예약일 (추가재료 처방일)                        
                                                        , HIS_STF_NO                        
                                                        , HIS_PRGM_NM                       
                                                        , HIS_IP_ADDR );                        
                        END IF;
                    ELSIF  V_ORD_SLIP = REC.UPR_ORD_SLIP_CTG_CD AND REC.PACT_TP_CD = V_PACT_TP_CD AND REC.EXM_CD = V_ORD_CD THEN     
                        IF REC.SV_TBL_NM = 'MOOORFED' THEN    --중앙부 집계     
                            PKG_MSE_SIDE_INTERFACE.PC_INSERT_TRT_ORDER( HIS_HSP_TP_CD                        
                                                        , IN_PT_NO
                                                        , G_PACT_ID
                                                        , G_PACT_TP_CD
                                                        , G_RPY_PACT_ID
                                                        , G_RPY_PACT_TP_CD
                                                        , G_RPY_CLS_SEQ
                                                        , REC.TRM_ORD_CD         --IN_ORD_CD
                                                        , IN_RSV_DTM         --IN_ORD_DT
                                                        , G_ORD_ID          --IN_REL_ORD_ID
                                                        , REC.TRTM_QTY        --IN_TRTM_QTY
                                                        , REC.RFED_MIFI_TP_CD       --IN_MED_MIFI_TP_CD    S:비급여 , NULL : 보험 ,급여 : N                      
                                                        , HIS_STF_NO                        
                                                        , HIS_PRGM_NM                       
                                                        , HIS_IP_ADDR );                         
                        ELSIF REC.SV_TBL_NM = 'MSERMAMD' THEN --부서 집계                                                                                                                                 
                            PKG_MSE_SIDE_INTERFACE.PC_INSERT_MSERMAMD_AUTO( HIS_HSP_TP_CD                        
                                                        , G_ORD_ID                       
                                                        , 'N'                         --신구구분(N:신규, O:구)
                                                        , ''                          --재료코드
                                                        , REC.AMD_MIFI_TP_CD              --보험 비보험   (F:무수가, '1':급여 ,'2':비급여)
                                                        , '0'                         --사용량(무수가)
                                                        , REC.TRTM_QTY                 --수납사용량
                                                        , REC.TRM_ORD_CD 
                                                        , IN_RSV_DTM                  --검사예약일 (추가재료 처방일)                        
                                                        , HIS_STF_NO                        
                                                        , HIS_PRGM_NM                       
                                                        , HIS_IP_ADDR );                        
                        END IF;                                                     
                    END IF;
                END LOOP;
            END;                                                                             
--               IF(V_ORD_SLIP = V_CT_SLIP) THEN
--    /*검사시 사용하는 필수재료 하드코딩 (오픈 이후 조영제처럼 관리하고 발행되는 로직으로 수정 필요  12.18) */                                        
--                    IF V_PACT_TP_CD = 'O' THEN 
--                                                  
--                        PKG_MSE_SIDE_INTERFACE.PC_INSERT_TRT_ORDER( HIS_HSP_TP_CD                        
--                                                    , IN_PT_NO
--                                                    , V_PACT_ID
--                                                    , V_PACT_TP_CD
--                                                    , V_RPY_PACT_ID
--                                                    , V_RPY_PACT_TP_CD
--                                                    , V_RPY_CLS_SEQ
--                                                    , '30073247'         --IN_ORD_CD
--                                                    , IN_RSV_DTM         --IN_ORD_DT
--                                                    , IN_ORD_ID          --IN_REL_ORD_ID
--                                                    , '1'                --IN_TRTM_QTY
--                                                    , 'S'                --IN_MED_MIFI_TP_CD    S:비급여 , NULL : 보험 ,급여 : N                      
--                                                    , HIS_STF_NO                        
--                                                    , HIS_PRGM_NM                       
--                                                    , HIS_IP_ADDR );  
--                    END IF;
--                    --raise_application_error(-20001,IN_RSV_DTM || ',' || IN_ORD_ID || ',' || V_PACT_ID || ',' || V_RPY_PACT_ID);  
--                    PKG_MSE_SIDE_INTERFACE.PC_INSERT_TRT_ORDER( HIS_HSP_TP_CD                        
--                                                    , IN_PT_NO
--                                                    , V_PACT_ID
--                                                    , V_PACT_TP_CD
--                                                    , V_RPY_PACT_ID
--                                                    , V_RPY_PACT_TP_CD
--                                                    , V_RPY_CLS_SEQ
--                                                    , '30081274'         --IN_ORD_CD
--                                                    , IN_RSV_DTM         --IN_ORD_DT
--                                                    , IN_ORD_ID          --IN_REL_ORD_ID
--                                                    , '1'                --IN_TRTM_QTY
--                                                    , ''                --IN_MED_MIFI_TP_CD    S:비급여 , NULL : 보험 ,급여 : N                      
--                                                    , HIS_STF_NO                        
--                                                    , HIS_PRGM_NM                       
--                                                    , HIS_IP_ADDR 
--                                                     );                                                                              
--               ELSIF V_ORD_SLIP = V_MRI_SLIP THEN
--                    PKG_MSE_SIDE_INTERFACE.PC_INSERT_TRT_ORDER( HIS_HSP_TP_CD                        
--                                                    , IN_PT_NO
--                                                    , V_PACT_ID
--                                                    , V_PACT_TP_CD
--                                                    , V_RPY_PACT_ID
--                                                    , V_RPY_PACT_TP_CD
--                                                    , V_RPY_CLS_SEQ
--                                                    , '30081754'         --IN_ORD_CD
--                                                    , IN_RSV_DTM         --IN_ORD_DT
--                                                    , IN_ORD_ID          --IN_REL_ORD_ID
--                                                    , '1'                --IN_TRTM_QTY
--                                                    , ''                --IN_MED_MIFI_TP_CD    S:비급여 , NULL : 보험 ,급여 : N                      
--                                                    , HIS_STF_NO                        
--                                                    , HIS_PRGM_NM                       
--                                                    , HIS_IP_ADDR
--                                                      );   
--                IF V_PACT_TP_CD = 'O' THEN                                                                              
--                    PKG_MSE_SIDE_INTERFACE.PC_INSERT_TRT_ORDER(  HIS_HSP_TP_CD                        
--                                                    , IN_PT_NO
--                                                    , V_PACT_ID
--                                                    , V_PACT_TP_CD
--                                                    , V_RPY_PACT_ID
--                                                    , V_RPY_PACT_TP_CD
--                                                    , V_RPY_CLS_SEQ
--                                                    , '30000452'         --IN_ORD_CD
--                                                    , IN_RSV_DTM         --IN_ORD_DT
--                                                    , IN_ORD_ID          --IN_REL_ORD_ID
--                                                    , '1'                --IN_TRTM_QTY
--                                                    , ''                --IN_MED_MIFI_TP_CD    S:비급여 , NULL : 보험 ,급여 : N                      
--                                                    , HIS_STF_NO                        
--                                                    , HIS_PRGM_NM                       
--                                                    , HIS_IP_ADDR
--                                                     );                                        
--                END IF;
--            END IF;     
                                   
/*SAVEORDER 로 처방 내리는거 대신 추가재료 넣는 방식으로 수정 .*/                                     
--            PKG_MSE_SIDE_INTERFACE.PC_INSERT_TRT_ORDER(HIS_HSP_TP_CD
--                                                       ,IN_PT_NO
--                                                       ,V_PACT_ID    --CT오더와 같은 PACT_ID
--                                                       ,V_PACT_TP_CD
--                                                       ,V_RPY_PACT_ID
--                                                       ,V_RPY_PACT_TP_CD    
--                                                       ,V_RPY_CLS_SEQ
--                                                       ,V_SIDE_ORD    --발행할 조영제 오더
--                                                       ,IN_RSV_DTM   --발행할 오더일 
--                                                       ,IN_ORD_ID    --CT오더 ,관계처방ID (MOOORPTD 테이블의 조영제 오더와 매칭시킬 CT오더)
--                                                       ,V_QTY        --처치횟수
--                                                       ,HIS_STF_NO
--                                                       ,HIS_PRGM_NM
--                                                       ,HIS_IP_ADDR);
--        EXCEPTION
--            WHEN OTHERS THEN                                                  
--                IO_ERRYN := 'Y';
--                IO_ERRMSG := sqlerrm;
--                ROLLBACK;
--                RETURN;         
        END; 
    /*조영제 취소*/                
    ELSIF IN_FLAG = 'U' THEN 
    
    /*예약취소한 오더 검사실처방 슬립 확인*/
        BEGIN
            SELECT SUBSTR(ORD_SLIP_CTG_CD,1,2)
              INTO V_ORD_SLIP
              FROM MSERMMMC
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND EXM_CD = IN_ORD_CD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                    INSERT INTO MSERMSID_TEMP
                    (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                    VALUES( HIS_HSP_TP_CD,IN_ORD_ID,IN_RSV_DTM,'','',IN_PT_NO,'',HIS_PRGM_NM,IO_ERRMSG ,'처방슬립이 없습니다.',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                 
                RETURN;            
        END;    
    /*예약취소한 오더가 조영제가 자동발행되는 오더인지 체크*/
--        BEGIN
--            SELECT 'Y'
--               INTO V_SIDE_CHK
--               FROM MSERMCCC
--             WHERE HSP_TP_CD = HIS_HSP_TP_CD  l
--               AND EXM_GRP_CD = V_ORD_SLIP
--               AND EXM_GRP_DTL_CD = IN_ORD_CD;
--        EXCEPTION
--             WHEN NO_DATA_FOUND THEN
--                 RETURN;      
--        END;             
/*영상의학과 검사 예약취소시 발행된 모든 미수납 조영제 삭제 요청 2022-03-21*/
        BEGIN     
            SELECT 'Y'
              INTO V_SIDE_CHK
              FROM MSERMMMC
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND EXM_CD = IN_ORD_CD
               AND ORD_CTG_CD ='BR1'             
                ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                    INSERT INTO MSERMSID_TEMP
                    (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                    VALUES( HIS_HSP_TP_CD,IN_ORD_ID,IN_RSV_DTM,'','',IN_PT_NO,'',HIS_PRGM_NM,IO_ERRMSG ,'영상의학과 검사가 없습니다.',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                             
                RETURN;
        END;                 
    /*발행된 CT오더의 PACT_ID*/             
        BEGIN
            SELECT PACT_ID
                  ,PACT_TP_CD
                  ,RPY_PACT_ID
                  ,RPY_PACT_TP_CD
                  ,RPY_CLS_SEQ
              INTO V_PACT_ID
                    ,V_PACT_TP_CD
                    ,V_RPY_PACT_ID
                    ,V_RPY_PACT_TP_CD
                    ,V_RPY_CLS_SEQ
              FROM MOOOREXM
             WHERE HSP_TP_CD = HIS_HSP_TP_CD
               AND ORD_ID    = IN_ORD_ID;  
        END;                     
        /*추가처방 삭제*/              
        BEGIN                                                             
            BEGIN
                DELETE /* HIS.MS.IV.RM.EX.DeleteTm2SOrdInfo */
                  FROM MSERMAMD A                     
                 WHERE A.ATPB_YN = 'Y'
                   AND A.HSP_TP_CD = HIS_HSP_TP_CD
                   AND A.ORD_ID = IN_ORD_ID  
                   AND A.RSV_DT BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999
                   AND A.RPY_STS_CD  IS NULL 
                   AND EXISTS( SELECT 1 
                                 FROM MOOOREXM
                                WHERE HSP_TP_CD = A.HSP_TP_CD
                                  AND ORD_ID = A.ORD_ID 
                                  AND EXM_PRGR_STS_CD IN ('X','A')
                              ) 
                   AND A.RPY_USE_QTY > 0                   
--                   AND EXISTS(SELECT 1
--							    FROM MSERMMJD
--                               WHERE HSP_TP_CD = A.HSP_TP_CD
--                                 AND CNMD_INF_CD = A.SGL_MIF_CD
--                                 AND CNMD_INF_TP_CD = 'A'
--                             )                                  
                    ;                             
            END;                                        
            /*조영제 추가삭제*/
            BEGIN
                DELETE /* HIS.MS.IV.RM.EX.DeleteTm2SOrdInfo */
                  FROM MSERMAMD A                     
                 WHERE 1=1
                   AND A.HSP_TP_CD = HIS_HSP_TP_CD
                   AND A.ORD_ID = IN_ORD_ID  
                   AND A.RPY_STS_CD  IS NULL 
                   AND EXISTS( SELECT 1 
                                 FROM MOOOREXM
                                WHERE HSP_TP_CD = A.HSP_TP_CD
                                  AND ORD_ID = A.ORD_ID 
                                  AND EXM_PRGR_STS_CD IN ('X','A')
                                ) 
                   AND (A.RPY_USE_QTY > 0 OR USE_QTY > 0)
                   AND EXISTS(SELECT 1
							    FROM MSERMMJD
                               WHERE HSP_TP_CD = A.HSP_TP_CD
                                 AND CNMD_INF_CD = A.SGL_MIF_CD
                                 AND CNMD_INF_TP_CD = 'A'
                             )                                  
                    ;                             
            END; 
            IF FT_MSE_USECNTR(HIS_HSP_TP_CD,'USECNTR','TRM_DC','PC_MSE_SIDEAUTOBPL') = 'N' THEN            
    /*기존에 발행한 조영제 DC 처리*/            
    /*SAVEORDER 로직 대신 추가처방 로직으로 수정 */           
                BEGIN
                      SELECT 'Y'
                        INTO V_DATA_YN
                    	FROM MOOORPTD A
                    	    ,MOOORFED B
                    	    ,MOOOREXM C
                    	WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                    	  AND A.HSP_TP_CD = B.HSP_TP_CD
                    	  AND A.HSP_TP_CD = C.HSP_TP_CD
    --                	  AND A.ODDSC_TP_CD = B.ODDSC_TP_CD
    --                	  AND A.ODDSC_TP_CD = C.ODDSC_TP_CD
    --                	  AND A.ODDSC_TP_CD ='C'
                    	  AND A.ORD_ID = B.ORD_ID
                    	  AND A.REL_ORD_ID = C.ORD_ID                       
                          AND B.ORD_MRK_CTG_CD = 'A'
                          AND B.ORD_DT  = IN_RSV_DTM
                          AND A.PT_NO = B.PT_NO
                          AND A.PT_NO = C.PT_NO
                          AND A.PT_NO = IN_PT_NO                              
                          AND B.RPY_STS_CD ='N'        
                          --AND C.ORD_CD = IN_ORD_CD                      
                          AND ROWNUM = 1
                          AND EXISTS(SELECT 1
                    	               FROM MSERMCCC
                                      WHERE HSP_TP_CD = A.HSP_TP_CD
                                        AND ORD_CTG_CD = 'BR1'
                                        AND EXM_GRP_CD = V_ORD_SLIP
                                        AND EXM_GRP_DTL_CD = C.ORD_CD
                                     )            ; 
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_DATA_YN := 'N';                                 
                    WHEN OTHERS THEN                                      
                        V_DATA_YN := 'Y';                                 
                END;                                                                                                                       
                /*삭제할 데이터가 없으면 로그데이터 쌓음*/
                IF V_DATA_YN = 'N' THEN
                        INSERT INTO MSERMSID_TEMP
                        (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                        VALUES( HIS_HSP_TP_CD,IN_ORD_ID,IN_RSV_DTM,V_PACT_ID,V_PACT_TP_CD,IN_PT_NO,V_ORD_SLIP,HIS_PRGM_NM,IO_ERRMSG ,'삭제할 데이터를 찾을 수 없습니다.',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                                                                                                    
                END IF;
                BEGIN
                    FOR REC IN (
                              SELECT B.ORD_ID   ORD_ID
                                    ,B.PACT_ID  PACT_ID
                            	FROM MOOORPTD A
                            	    ,MOOORFED B
                            	    ,MOOOREXM C
                            	WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                            	  AND A.HSP_TP_CD = B.HSP_TP_CD
                            	  AND A.HSP_TP_CD = C.HSP_TP_CD
    --MOOORPTD와 MOOOREXM 의 ODDSC_TP_CD가 다른 데이터가 있어서 주석처리. 2022.04.28                        	
    --                        	  AND A.ODDSC_TP_CD = B.ODDSC_TP_CD
    --                        	  AND A.ODDSC_TP_CD = C.ODDSC_TP_CD
    --                        	  AND A.ODDSC_TP_CD ='C'
                            	  AND A.ORD_ID = B.ORD_ID
                            	  AND A.REL_ORD_ID = C.ORD_ID                       
                                  AND B.ORD_MRK_CTG_CD = 'A'
                                  AND B.ORD_DT  = IN_RSV_DTM
                                  AND A.PT_NO = B.PT_NO
                                  AND A.PT_NO = C.PT_NO
                                  AND A.PT_NO = IN_PT_NO                              
                                  AND B.RPY_STS_CD ='N'
    --                              AND C.ORD_CD = IN_ORD_CD                             
                                  AND EXISTS(SELECT 1
                            	               FROM MSERMCCC
                                              WHERE HSP_TP_CD = A.HSP_TP_CD
                                                AND ORD_CTG_CD = 'BR1'
                                                AND EXM_GRP_CD = V_ORD_SLIP
                                                AND EXM_GRP_DTL_CD = IN_ORD_CD
                                             )
                                )
                    LOOP                        
                        IF REC.ORD_ID IS NOT NULL THEN
                            BEGIN
                                PKG_MSE_SIDE_INTERFACE.PC_DELETE_TRT_ORDER(HIS_HSP_TP_CD
                                                                          ,IN_PT_NO
                                                                          ,REC.PACT_ID
                                                                          ,REC.ORD_ID
                                                                          ,HIS_STF_NO
                                                                          ,HIS_PRGM_NM
                                                                          ,HIS_IP_ADDR);
                            EXCEPTION
                                WHEN OTHERS THEN     
                                    IO_ERRYN := 'Y';
                                    IO_ERRMSG := sqlerrm;    
                                    INSERT INTO MSERMSID_TEMP
                                    (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                                    VALUES( HIS_HSP_TP_CD,REC.ORD_ID,IN_RSV_DTM,REC.PACT_ID,V_PACT_TP_CD,IN_PT_NO,V_ORD_SLIP,HIS_PRGM_NM,IO_ERRMSG ,'삭제실패',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                                
                                    ROLLBACK;
                                    RETURN;                                                       
                            END;                                                                                                  
                            INSERT INTO MSERMSID_TEMP
                            (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                            VALUES( HIS_HSP_TP_CD,REC.ORD_ID,IN_RSV_DTM,REC.PACT_ID,V_PACT_TP_CD,IN_PT_NO,V_ORD_SLIP,HIS_PRGM_NM,IO_ERRMSG ,'삭제성공',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                                                        
                        ELSIF REC.ORD_ID IS NULL THEN
                            BEGIN
                                INSERT INTO MSERMSID_TEMP
                                (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                                VALUES( HIS_HSP_TP_CD,REC.ORD_ID,IN_RSV_DTM,REC.PACT_ID,V_PACT_TP_CD,IN_PT_NO,V_ORD_SLIP,HIS_PRGM_NM,IO_ERRMSG ,'ORD_ID가 NULL입니다.',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                                                                                                                    
                            END;
                        END IF; 
                        V_LOOP_CNT := V_LOOP_CNT + 1;
                    END LOOP;                        
                    IF V_LOOP_CNT = 0 THEN           
                                INSERT INTO MSERMSID_TEMP
                                (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                                VALUES( HIS_HSP_TP_CD,IN_ORD_ID,IN_RSV_DTM,V_PACT_ID,V_PACT_TP_CD,IN_PT_NO,V_ORD_SLIP,HIS_PRGM_NM,IO_ERRMSG ,'LOOP타지않음.',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                                                                                                                                    
                    END IF;
                END;   
            ELSIF FT_MSE_USECNTR(HIS_HSP_TP_CD,'USECNTR','TRM_DC','PC_MSE_SIDEAUTOBPL') = 'Y' THEN   
    /*기존에 발행한 조영제 DC 처리 검사 예약할때 발행된 재료와 묶인 검사가 예약취소될때 삭제함.*/            
    /*SAVEORDER 로직 대신 추가처방 로직으로 수정 */           
                BEGIN
                      SELECT 'Y'
                        INTO V_DATA_YN
                    	FROM MOOORPTD A
                    	    ,MOOORFED B
                    	    ,MOOOREXM C
                    	WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                    	  AND A.HSP_TP_CD = B.HSP_TP_CD
                    	  AND A.HSP_TP_CD = C.HSP_TP_CD
                    	  AND A.ORD_ID = B.ORD_ID
                    	  AND A.REL_ORD_ID = C.ORD_ID                       
                    	  AND A.REL_ORD_ID = IN_ORD_ID
                          AND B.ORD_MRK_CTG_CD = 'A'
                          AND A.PT_NO = B.PT_NO
                          AND A.PT_NO = C.PT_NO
                          AND A.PT_NO = IN_PT_NO                              
                          AND NVL(B.RPY_STS_CD,'N') ='N'                            
                          AND B.ODDSC_TP_CD = 'C'
                          AND ROWNUM = 1
                          ; 
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        V_DATA_YN := 'N';                                 
                    WHEN OTHERS THEN                                      
                        V_DATA_YN := 'Y';                                 
                END;                                                                                                                       
                /*삭제할 데이터가 없으면 로그데이터 쌓음 -> 취소하는 예약일에 조영제 자동발행 처방이 있는지 확인하여 없으면 발행된 자동발행 미수납 재료 전부삭제.*/
                IF V_DATA_YN = 'N' THEN
                        INSERT INTO MSERMSID_TEMP
                        (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                        VALUES( HIS_HSP_TP_CD,IN_ORD_ID,IN_RSV_DTM,V_PACT_ID,V_PACT_TP_CD,IN_PT_NO,V_ORD_SLIP,HIS_PRGM_NM,IO_ERRMSG ,'취소하는 검사에 묶인 재료 데이터를 찾을 수 없습니다.',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                                                                                                    
                    BEGIN                       
                        SELECT 'Y'
                          INTO V_DATA_YN
                          FROM MSERMRRD R
                         WHERE R.HSP_TP_CD = HIS_HSP_TP_CD
                           AND R.PT_NO = IN_PT_NO
                           AND R.RSV_DTM BETWEEN TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') AND TO_DATE(IN_RSV_DTM,'YYYY-MM-DD') + .99999
                           AND EXISTS (SELECT 1 
                                         FROM MSERMCCC
                                        WHERE HSP_TP_CD = R.HSP_TP_CD
                                          AND EXM_GRP_CD = V_ORD_SLIP
                                          AND ORD_CTG_CD = 'BR1'
                                          AND EXM_GRP_DTL_CD = R.ORD_CD
                                          AND USE_YN = 'Y') 
                                          ;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN --예약취소날에 조영제 자동발행 검사가 없음. => 해당 예약일에 자동발행된 재료 전부 삭제. 
                            BEGIN
                                FOR REC_5 IN (SELECT B.ORD_ID   ORD_ID
                                                 , B.PACT_ID  PACT_ID
                                        	  FROM MOOORPTD A
                                        	      ,MOOORFED B
                                        	      ,MOOOREXM C
                                             WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                                        	   AND A.HSP_TP_CD = B.HSP_TP_CD
                                        	   AND A.HSP_TP_CD = C.HSP_TP_CD
                                        	   AND A.ORD_ID = B.ORD_ID
                                        	   AND A.REL_ORD_ID = C.ORD_ID --자동발행 조영제. 
                                        	   AND B.ORD_DT  = IN_RSV_DTM
                                               AND B.ORD_MRK_CTG_CD = 'A'
                                               AND A.PT_NO = B.PT_NO
                                               AND A.PT_NO = C.PT_NO
                                               AND A.PT_NO = IN_PT_NO                              
                                               AND NVL(B.RPY_STS_CD,'N') = 'N'
                                               AND B.RTN_DT IS NULL --반납하지 않은것만.  
                                               AND EXISTS (SELECT 1                             --취소하는 처방이 CT인지 MRI인지 체크 
                                                             FROM MSERMCCC
                                                            WHERE HSP_TP_CD = A.HSP_TP_CD
                                                              AND EXM_GRP_CD = V_ORD_SLIP
                                                              AND ORD_CTG_CD = 'BR1'
                                                              AND EXM_GRP_DTL_CD = C.ORD_CD
                                                              AND USE_YN = 'Y')
                                            )
                                LOOP          
                                    BEGIN
                                        PKG_MSE_SIDE_INTERFACE.PC_DELETE_TRT_ORDER(HIS_HSP_TP_CD
                                                                                  ,IN_PT_NO
                                                                                  ,REC_5.PACT_ID
                                                                                  ,REC_5.ORD_ID
                                                                                  ,HIS_STF_NO
                                                                                  ,HIS_PRGM_NM
                                                                                  ,HIS_IP_ADDR);
                                    EXCEPTION
                                        WHEN OTHERS THEN     
                                            IO_ERRYN := 'Y';
                                            IO_ERRMSG := sqlerrm;    
                                            INSERT INTO MSERMSID_TEMP
                                            (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                                            VALUES( HIS_HSP_TP_CD,REC_5.ORD_ID,IN_RSV_DTM,REC_5.PACT_ID,V_PACT_TP_CD,IN_PT_NO,V_ORD_SLIP,HIS_PRGM_NM,IO_ERRMSG ,'삭제실패',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                                
                                            ROLLBACK;
                                            RETURN;                                                       
                                    END;
                                END LOOP; 
                            END;                                                                      
                    END;                                                                
                END IF;
                BEGIN
                    FOR REC IN (
                              SELECT B.ORD_ID   ORD_ID
                                    ,B.PACT_ID  PACT_ID
                            	FROM MOOORPTD A
                            	    ,MOOORFED B
                            	    ,MOOOREXM C
                            	WHERE A.HSP_TP_CD = HIS_HSP_TP_CD
                            	  AND A.HSP_TP_CD = B.HSP_TP_CD
                            	  AND A.HSP_TP_CD = C.HSP_TP_CD
                            	  AND A.ORD_ID = B.ORD_ID
                            	  AND A.REL_ORD_ID = C.ORD_ID
                            	  AND A.REL_ORD_ID = IN_ORD_ID                       
                                  AND B.ORD_MRK_CTG_CD = 'A'
                                  AND A.PT_NO = B.PT_NO
                                  AND A.PT_NO = C.PT_NO
                                  AND A.PT_NO = IN_PT_NO                              
                                  AND NVL(B.RPY_STS_CD,'N') = 'N'                           
                                )
                    LOOP                        
                        IF REC.ORD_ID IS NOT NULL THEN
                            BEGIN
                                PKG_MSE_SIDE_INTERFACE.PC_DELETE_TRT_ORDER(HIS_HSP_TP_CD
                                                                          ,IN_PT_NO
                                                                          ,REC.PACT_ID
                                                                          ,REC.ORD_ID
                                                                          ,HIS_STF_NO
                                                                          ,HIS_PRGM_NM
                                                                          ,HIS_IP_ADDR);
                            EXCEPTION
                                WHEN OTHERS THEN     
                                    IO_ERRYN := 'Y';
                                    IO_ERRMSG := sqlerrm;    
                                    INSERT INTO MSERMSID_TEMP
                                    (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                                    VALUES( HIS_HSP_TP_CD,REC.ORD_ID,IN_RSV_DTM,REC.PACT_ID,V_PACT_TP_CD,IN_PT_NO,V_ORD_SLIP,HIS_PRGM_NM,IO_ERRMSG ,'삭제실패',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                                
                                    ROLLBACK;
                                    RETURN;                                                       
                            END;                                                                                                  
                            INSERT INTO MSERMSID_TEMP
                            (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                            VALUES( HIS_HSP_TP_CD,REC.ORD_ID,IN_RSV_DTM,REC.PACT_ID,V_PACT_TP_CD,IN_PT_NO,V_ORD_SLIP,HIS_PRGM_NM,IO_ERRMSG ,'삭제성공',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                                                        
                        ELSIF REC.ORD_ID IS NULL THEN
                            BEGIN
                                INSERT INTO MSERMSID_TEMP
                                (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                                VALUES( HIS_HSP_TP_CD,REC.ORD_ID,IN_RSV_DTM,REC.PACT_ID,V_PACT_TP_CD,IN_PT_NO,V_ORD_SLIP,HIS_PRGM_NM,IO_ERRMSG ,'ORD_ID가 NULL입니다.',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                                                                                                                    
                            END;
                        END IF; 
                        V_LOOP_CNT := V_LOOP_CNT + 1;
                    END LOOP;                        
                    IF V_LOOP_CNT = 0 THEN           
                                INSERT INTO MSERMSID_TEMP
                                (HSP_TP_CD,ORD_ID,RSV_DTM,PACT_ID,PACT_TP_CD,PT_NO,ORD_SLIP,HIS_PRGM_NM,ERRMSG,REMARK,FSR_DTM,FSR_STF_NO,FSR_PRGM_NM,FSR_IP_ADDR,LSH_DTM,LSH_STF_NO,LSH_PRGM_NM,LSH_IP_ADDR)
                                VALUES( HIS_HSP_TP_CD,IN_ORD_ID,IN_RSV_DTM,V_PACT_ID,V_PACT_TP_CD,IN_PT_NO,V_ORD_SLIP,HIS_PRGM_NM,IO_ERRMSG ,'LOOP타지않음.',SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR,SYSDATE,HIS_STF_NO,HIS_PRGM_NM,HIS_IP_ADDR );                                                                                                                                    
                    END IF;
                END;               
            END IF;      
        END; 
    END IF;
END PC_MSE_SIDEAUTOPBL;