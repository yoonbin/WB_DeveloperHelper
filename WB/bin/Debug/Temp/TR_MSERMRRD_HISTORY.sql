TRIGGER HSUP.TR_MSERMRRD_HISTORY 
AFTER UPDATE ON  HSUP.MSERMRRD 
REFERENCING OLD AS OLD NEW AS NEW

FOR EACH ROW
DECLARE
  WK_STF_NM  VARCHAR2(500) := '';
  WK_PGRM_NM VARCHAR2(500) := '';
  WK_IP_ADDR VARCHAR2(50)  := '';
  
BEGIN
    
    /**************************************************************************************************************************************************
    *    서비스이름  : TR_MSERMRRD_HISTORY
    *    최초 작성일 : 2013.04.27
    *    최초 작성자 : EZCARETECH 김승모
    *    DESCRIPTION : 예약검사 슬롯 HISTORY 관리 내역
    *        AS_IS명 : TRIGGER HISSUP.TR_SRSCHDDT 
    *                 트리거로 관리하던 HISTORY를 프로시져로 변경
    **************************************************************************************************************************************************/
    
    --시스템정보 조회..수작업 이력을 보기위함
   BEGIN
     SELECT /*+ XSUP.TR_MSERMRRD_HISTORY */
            SYS_CONTEXT('USERENV','IP_ADDRESS')
          , PROGRAM
          , SYS_CONTEXT('USERENV','HOST')
       INTO WK_IP_ADDR
          , WK_PGRM_NM
          , WK_STF_NM
       FROM V$SESSION
      WHERE AUDSID  = USERENV('SESSIONID')
        AND SID     = (SELECT SID FROM V$MYSTAT WHERE ROWNUM = 1) ;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
           WK_STF_NM  := '';
           WK_PGRM_NM := '';
           WK_IP_ADDR := '';
      WHEN OTHERS THEN
                --RAISE_APPLICATION_ERROR(-20000, 'TRIGGER ERROR : SESSION SELECTING'||' '||TO_CHAR(SQLCODE));
           NULL;
   END;                                                                                                             
   
--   RAISE_APPLICATION_ERROR('-20001','_' || :NEW.PT_NO || '_' || :NEW.ORD_DT || '_' || :NEW.ORD_SEQ || '_');        
   ---------------------------------------------------------------------------------------------------------------------------------------------------------
   IF UPDATING THEN
--   RAISE_APPLICATION_ERROR('-20001','_' || :NEW.PT_NO || '_' || :NEW.ORD_DT || '_' || :NEW.ORD_SEQ || '_');        
--       IF ( NVL(:NEW.SPRP_TP_CD,'N') IN ('Y','R','N') ) THEN --예약을 취소할 경우에만 INSERT 
--       IF ( NVL(:NEW.PT_NO,'X') <> NVL(:OLD.PT_NO,'X') ) THEN
            INSERT INTO HSUP.MSERMRHH ( FSR_DTM
            
                                  ,RSV_HST_SEQ
                                  
                                  ,HSP_TP_CD
                                  
                                  ,ORD_ID  
                                  
                                  ,PT_NO
                                  
                                  ,ORD_DT
                                  
                                  ,ORD_SEQ
                                  
                                  ,ORD_CD
                                  
                                  ,EXRM_TP_CD
                                  
                                  ,RSV_DTM
                                  
                                  ,RSVP_ACPT_TP_CD
                                  
                                  ,CHDR_STF_NO
                                  
                                  ,RMK
                                  
                                  ,FMR_INPT_DTM
                                  
                                  ,FMR_RSV_STF_NO
                                  
                                  ,FSR_PRGM_NM
                                  
                                  ,FSR_IP_ADDR
                                  
                                  ,LSH_DTM
                                  
                                  ,LSH_STF_NO
                                  
                                  ,LSH_PRGM_NM
                                  
                                  ,LSH_IP_ADDR
                                  
                                  ,FSR_STF_NO 
                                  
                                  ,SPRP_TP_CD
                                  
                                  , ADL_CHL_TP_CD                                                --성인소아구분코드
                                  
                                  , ENRM_UGRP_CD                                                 --내시경예약관리사용자그룹코드
                                  
                                  , ADD_SLOT_YN                                                  --추가슬롯여부
                                  --2017.06.30 LIM ADD
                                  , INTG_RSV_YN                                                  --통합예약여부
                                  , PT_CALL_DTM                                                  --환자호출일시
                                  , PT_CALL_MEMO_CNTE                                            --환자호출메모내용
                                  , CTNT_YN                                                      --연속여부
                                  , RSV_SEQ
                                  , TRSV_YN
                                  , EMRG_SLOT_YN
                                  , SLOT_NO
                                  , RMK_CNTE
                                  , MEMO
                                  , PT_ARVL_EXPT_DTM
                                  , DEPT_CHC_CNTE
                                  , RSV_REF_CNTE
                                  , CONN_ORD_ID
                                  )
                          VALUES( SYSDATE                --기록시간(= 취소작업 처리시간)
                          
                                 , TO_CHAR(SYSDATE, 'YYYYMMDD') || LPAD(TO_CHAR(XSUP.SEQ_RSV_HST_SEQ.NEXTVAL ),13,'0') --(SELECT NVL(MAX(RSV_HST_SEQ), 0)+ 1 FROM  MSERMRHH) -- 2018.12.20 속도 문제로 조회하지 않고 SEQ 생성 후 NEXTVAL로 함.
                                 
                                 ,:NEW.HSP_TP_CD
                                 
                                 ,NVL(:NEW.ORD_ID,   :OLD.ORD_ID)
                                 
                                 ,NVL(:NEW.PT_NO,    :OLD.PT_NO)
                                                                   
                                 ,NVL(:NEW.ORD_DT,   :OLD.ORD_DT)
                                 
                                 ,NVL(:NEW.ORD_SEQ,  :OLD.ORD_SEQ)
                                 
                                 ,NVL(:NEW.ORD_CD ,  :OLD.ORD_CD)
                                 
                                 ,:NEW.EXRM_TP_CD
                                 
                                 ,:NEW.RSV_DTM
                                 
                                 ,:NEW.RSVP_ACPT_TP_CD
                                 
                                 ,:NEW.CHDR_STF_NO
                                 
                                 ,:NEW.RMK_CNTE
                                 
                                 ,:NEW.FSR_DTM
                                 
                                 ,:NEW.FSR_STF_NO
                                 
                                 ,:NEW.FSR_PRGM_NM
                                 
                                 ,:NEW.FSR_IP_ADDR
                                 
                                 ,:NEW.LSH_DTM
                                 
                                 ,:NEW.LSH_STF_NO
                                 
                                 ,NVL(WK_PGRM_NM||WK_STF_NM,:NEW.LSH_PRGM_NM)
                                 
                                 ,NVL(WK_IP_ADDR,:NEW.LSH_IP_ADDR)
                                 
                                 ,:NEW.FSR_STF_NO
                                 
                                 ,:NEW.SPRP_TP_CD                                                   --특정인예약가능구분코드
                                 
                                 ,:NEW.ADL_CHL_TP_CD                                                --성인소아구분코드
                                  
                                 ,:NEW.ENRM_UGRP_CD                                                 --내시경예약관리사용자그룹코드
                                  
                                 ,:NEW.ADD_SLOT_YN                                                  --추가슬롯여부
                                 --2017.06.30 LIM ADD
                                 , :NEW.INTG_RSV_YN                                                  --통합예약여부
                                 , :NEW.PT_CALL_DTM                                                  --환자호출일시
                                 , :NEW.PT_CALL_MEMO_CNTE                                            --환자호출메모내용
                                 , :NEW.CTNT_YN                                                      --연속여부
                                 , :NEW.RSV_SEQ
                                 , :NEW.TRSV_YN
                                 , :NEW.EMRG_SLOT_YN
                                 , :NEW.SLOT_NO
                                 , :NEW.RMK_CNTE
                                 , :NEW.MEMO
                                 , :NEW.PT_ARVL_EXPT_DTM
                                 , :NEW.DEPT_CHC_CNTE
                                 , :NEW.RSV_REF_CNTE
                                 , :NEW.CONN_ORD_ID 
                                 );
--        END IF;
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR('-20003','TR_MSERMRRD_HISTORY');
END;










