PROCEDURE      PC_MSE_MSEPMPMD_PACSNEW_TRG_DSMC ( IN_HSP_TP_CD       IN        VARCHAR2
	                                            , IN_PTHL_NO         IN        VARCHAR2
	                                            , IN_EXM_CD          IN        VARCHAR2
	                                            , IN_STF_NO          IN        VARCHAR2
	                                            , IN_PRGM_NM         IN        VARCHAR2
	                                            , IN_IP_ADDR         IN        VARCHAR2 
	                                            , IO_ERRYN           IN OUT    VARCHAR2
	                                            , IO_ERRMSG          IN OUT    VARCHAR2
	                                            ) 

    -- NAME         : 병리데이터 병리 PACS 연동
    -- DESC         : 병리 접수, 결과저장 시 병리 PACS에 대이터 전송
    -- AUTHOR       :  
    -- CREATE DATE  :  
    -- UPDATE DATE  : 최종 수정일자 , 수정자, 수정개요

AS     
	V_PTHL_NO VARCHAR2(15) := '';
BEGIN
     
   	BEGIN
 		INSERT 
           INTO MSERMINF_ORR F ( F.QUEUEID                                                                                         -- 1. QueueID
                              , F.FLAG                                                                                            -- 2. 처리여부
                              , F.WORKTIME                                                                                        -- 3. 작업일시
                              , F.PATID                                                                                           -- 4. 환자ID
                              , F.PATID2                                                                                          -- 5. 환자ID2
                              , F.PATID3                                                                                          -- 6. 환자ID3
                              , F.ACCESSIONNO                                                                                     -- 7. 검사고유번호
                              , F.EVENTTYPE                                                                                       -- 8. Order Event Type
                              , F.HISORDERID                                                                                      -- 9. HIS Order ID (HIS System 상의 현재 Order의 유일 키)
                              , F.EMERGENCY                                                                                       --10. 응급판독구분
                              , F.EXAMDATE                                                                                        --11. 검사시행일자(오더발행일자 아님)
                              , F.EXAMTIME                                                                                        --12. 검사시행시간(오더발행일자 아님)
                              , F.EXAMROOM                                                                                        --13. 검사실
                              , F.EXAMROOMID                                                                                      --14. 검사실 ID
                              , F.EXAMCODE                                                                                        --15. 검사코드
                              , F.EXAMNAME                                                                                        --16. 검사명
                              , F.ORDERDOC                                                                                        --17. Order 발행의
                              , F.DISEASE                                                                                         --18. 상병명
                              , F.DISEASE1                                                                                        --19. 상병명1
                              , F.DISEASE2                                                                                        --20. 상병명2
                              , F.REQUESTMEMO                                                                                     --21. 전달사항
                              , F.REQUESTMEMO1                                                                                    --22. 전달사항1
                              , F.REQUESTMEMO2                                                                                    --23. 전달사항2
                              , F.OPDEPT                                                                                          --24. 검사 시행과
                              , F.OPDEPTID                                                                                        --25. 검사 시행과 ID
                              , F.OPDOC                                                                                           --26. 검사 시행 의사
                              , F.OPTECH                                                                                          --27. 검사 시행 방사선사
                              , F.ORDERFROM                                                                                       --28. Order 발행과
                              , F.ORDERFROMID                                                                                     --29. Order 발행과 ID
                              , F.RECPTDATE                                                                                       --30. 접수일자(방사선과에서 오더를 접수한 시간)
                              , F.RECPTTIME                                                                                       --31. 접수시간
                              , F.SPECIALREADING                                                                                  --32. 지정 판독의
                              , F.PATNAME                                                                                         --33. 환자이름
                              , F.PATNAME2                                                                                        --34. 환자이름2
                              , F.PATPERSONALID                                                                                   --35. 주민번호
                              , F.PATBIRTHDAY                                                                                     --36. 생년월일
                              , F.PATZIP                                                                                          --37. 우편번호
                              , F.PATADDRESS1                                                                                     --38. 환자주소1
                              , F.PATADDRESS2                                                                                     --39. 환자주소2
                              , F.PATTELNO1                                                                                       --40. 전화번호1
                              , F.PATTELNO2                                                                                       --41. 전화번호2
                              , F.PATATTENDDOC                                                                                    --42. 주치의
                              , F.PATREFERDOC                                                                                     --43. 의뢰의
                              , F.PATSEX                                                                                          --44. 성별
                              , F.PATDEPT                                                                                         --45. 진료과
                              , F.PATDEPTID                                                                                       --46. 진료과 ID
                              , F.PATTYPE                                                                                         --47. 환자유형 (입원/외래)
                              , F.PATWARD                                                                                         --48. 병동
                              , F.PATWARDID                                                                                       --49. 병동ID
                              , F.PATROOMNO                                                                                       --50. 병실
                              , F.PATROOMNOID                                                                                     --51. 병실ID
                              , F.ERRCOUNT                                                                                        --52. Error일경우 재전송 횟수
                              , F.EPATNAME                                                                                        --53. 환자영문명
                              , F.COOPHOSPID                                                                                      --54. 병원 ID
                              , F.TREATMENTTYPE                                                                                   --55. 특진여부
                              , F.MEDICALCOST                                                                                     --56. 급여구분
                              , F.MODALITY                                                                                        --57. 장비
                              , F.SECTION                                                                                         --58. 판독섹션
                              )

                        SELECT TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') || LPAD(SEQ_PACS_QUE_NO.NEXTVAL, 4, '0') QUEUEID                     -- 1. QueueID : YYYYMMDDhhmmss+SEQ(0000~9999) varchar2(18)   Not Null
                              , 'N'                                                                          FLAG                     -- 2. 처리여부 : Default : N (Y/N) varchar2(1) Not Null
                              , SYSDATE                                                                      WORKTIME                     -- 3. 작업일시 date Not Null
                              , M.PT_NO                                                                      PATID                     -- 4. 환자ID varchar2(20) Not Null
                              , ''                                                                           PATID2                     -- 5. 환자ID2 : 사용안함 varchar2(20)
                              , ''                                                                           PATID3                     -- 6. 환자ID3 : 사용안함 varchar2(20)
                              , IN_PTHL_NO                                                                    ACCESSIONNO                 -- 7. 검사고유번호 varchar2(10) Not Null
                              , DECODE(C.PLEX_PRGR_STS_CD, 'C','NW'  -- NW : 검사접수     
                                                            , 'D','OK'
                                                            , 'N','OK'
                                                            , 'E','OK'  -- OK : 검사시행
                                                            , 'F','CA'  -- CA : 시행취소
                                                            , 'R','CA') EVENTTYPE -- CA : 접수취소                                           -- 8. Order Event Type : NW : 신규 /  OK : 검사정보변경 / CA : 취소  varchar2(2) Not Null
                              , M.ORD_ID                                HISORDERID                                                          -- 9. HIS Order ID (HIS System 상의 현재 Order의 유일 키) varchar2(128)   Not Null
                              , DECODE(M.EMRG_YN,'Y','E',NVL(M.EMRG_YN,'N')) EMERGENCY                                                     --10. 응급판독구분 : N:Normal / M:필수판독 / E:응급판독 / T: Today / I: In / R: Report  / O:Out  /G:General  /U: Unbrace  varchar2(1)
                              , TO_CHAR(C.ACPT_DTM,'YYYYMMDD')               EXAMDATE                             --11. 검사시행일자(오더발행일자 아님)   **** varchar2(8) Not Null
                              , TO_CHAR(C.ACPT_DTM,'HH24MISS')               EXAMTIME                                                 --12. 검사시행시간(오더발행일자 아님)  varchar2(6)
                              , XSUP.FT_MSE_FRCT_NM(M.ORD_SLIP_CTG_CD, M.HSP_TP_CD) EXAMROOM                                               --13. 검사실  varchar2(30)
                              , M.ORD_SLIP_CTG_CD                                   EXAMROOMID                                               --14. 검사실 ID : 사용 안 함  varchar2(10)
                              , M.ORD_CD                                            EXAMCODE                                              --15. 검사코드  varchar2(20) Not Null
                              , M.ORD_NM                                            EXAMNAME           --16. 검사명  varchar2(128) Not Null
                              , M.FSR_STF_NO                                        ORDERDOC                                              --17. Order 발행의  varchar2(12)
                              , FT_MSE_DISS(C.PT_NO, IN_HSP_TP_CD)                DISEASE                                           --18. 상병명 varchar2(4000)
                              , ''                                                  DISEASE1                                              --19. 상병명1 varchar(1024)
                              , ''                                                  DISEASE2                                              --20. 상병명2 varchar(255)
                              , M.ORD_RMK_CNTE || CASE WHEN M.COPN_CNTE IS NOT NULL THEN '/' END ||
                                REPLACE(REPLACE(REPLACE(M.COPN_CNTE, CHR(13)||CHR(10)
                                                                   , CHR(13)||CHR(10)), CHR(13)
                                                                                      , CHR(13)||CHR(10)), CHR(10)
                                                                                                         , CHR(13)||CHR(10))  REQUESTMEMO    --21. 전달사항 varchar2(4000)
                              , ''                                                                                            REQUESTMEMO1    --22. 전달사항1 varchar(1024)
                              , ''                                                                                            REQUESTMEMO2    --23. 전달사항2 varchar(255)
                              , SUBSTRB(XCOM.FT_PDE_SELDEPTNM(M.ORD_CTG_CD, IN_HSP_TP_CD)   , 1, 20)                                        OPDEPT        --24. 검사 시행과 varchar2(30)
                              , M.ORD_CTG_CD                                                                                  OPDEPTID       --25. 검사 시행과 ID : 사용 안 함 varchar2(10)
                              , C.TH1_IPDR_STF_NO                                                                             OPDOC --26. 검사 시행 의사 varchar2(12)
                              , C.FSR_STF_NO                                                                                  OPTECH --27. 검사 시행 방사선사 varchar2(12)
                              , SUBSTRB(XCOM.FT_PDE_SELDEPTNM(M.PBSO_DEPT_CD, IN_HSP_TP_CD) , 1, 20)                                        ORDERFROM     --28. Order 발행과 varchar2(30)
                              , M.PBSO_DEPT_CD                                                                                ORDERFROMID    --29. Order 발행과 ID : 사용 안 함  varchar2(10)
                              , TO_CHAR(C.ACPT_DTM,'YYYYMMDD')                                                                RECPTDATE--30. 접수일자(방사선과에서 오더를 접수한 시간) varchar2(8)
                              , TO_CHAR(C.ACPT_DTM,'HH24MISS')                                                                RECPTTIME--31. 접수시간 varchar2(6)
                              , ''                                                                                            SPECIALREADING    --32. 지정 판독의  varchar2(12)
                              , P.PT_NM                                                                                       PATNAME    --33. 환자이름 varchar2(50)  Not Null
                              , ''                                                                                            PATNAME2    --34. 환자이름2 varchar2(50)
                              , CASE WHEN P.SEC_RRN IS NULL THEN ''
                                     ELSE SUBSTR(P.SEC_RRN,1,6) || '-' ||
                                          SUBSTR(P.SEC_RRN,7,7)
                                END                                                                                           PATPERSONALID    --35. 주민번호 varchar2(14)
                              , TO_CHAR(P.PT_BRDY_DT,'YYYYMMDD')                                                              PATBIRTHDAY    --36. 생년월일 (YYYYMMDD) varchar2(8) Not Null
                              , CASE WHEN LENGTH(F.HM_POST_NO) = 6 THEN SUBSTR(F.HM_POST_NO, 1, 3) || '-' ||  SUBSTR(F.HM_POST_NO, 4, 3)
                                     ELSE F.HM_POST_NO
                                END                                                                                           PATZIP    --37. 우편번호  varchar2(20)
                              , F.HM_BSC_ADDR || ' ' || F. HM_DTL_ADDR                                                        PATADDRESS1    --38. 환자주소1 varchar2(100)
                              , ''                                                                                            PATADDRESS2    --39. 환자주소2 varchar2(100)
                              , XBIL.FT_PCT_GETCTAD(IN_HSP_TP_CD, M.PT_NO, '0', '00')                                       PATTELNO1     --40. 전화번호1 varchar2(20)
                              , F.HM_TEL_NO                                                                                   PATTELNO2    --41. 전화번호2  varchar2(20)
                              , M.ANDR_STF_NO                                                                                 PATATTENDDOC--42. 주치의  varchar2(12)
                              , ''                                                                                            PATREFERDOC    --43. 의뢰의  varchar2(12)
                              , DECODE(P.SEX_TP_CD,'F','F','M','M','O')                                                       PATSEX    --44. 성별 (M : Male / F : Female / O : Other)  varchar2(1) Not Null
                              , SUBSTRB(XCOM.FT_PDE_SELDEPTNM(C.MED_DEPT_CD  , IN_HSP_TP_CD) , 1, 20)                                         PATDEPT   --45. 진료과 varchar2(30)  Not Null
                              , C.MED_DEPT_CD                                                                                 PATDEPTID--46. 진료과 ID : 사용 안 함 varchar2(10)
                              , M.PACT_TP_CD                                                                                  PATTYPE--47. 환자유형 (입원/외래) (I : In patient / O : Out patient / E : Emergency patient)  varchar2(1)   Not Null
                              , SUBSTRB(XCOM.FT_PDE_SELDEPTNM(M.WD_DEPT_CD, IN_HSP_TP_CD) , 1, 20)                                            PATWARD --48. 병동  varchar2(30)
                              , M.WD_DEPT_CD                                                                                  PATWARDID--49. 병동ID : 사용 안 함 varchar2(10)
                              , M.PRM_NO                                                                                      PATROOMNO    --50. 병실   varchar2(30)
                              , M.PRM_NO                                                                                      PATROOMNOID    --51. 병실ID : 사용 안 함  varchar2(10)
                              , ''                                                                                            ERRCOUNT    --52. Error일경우 재전송 횟수 number(1)
                              , ''                                                                                            EPATNAME    --53. 환자영문명
                              , M.HSP_TP_CD                                                                                   COOPHOSPID    --54. 병원 ID
                              , '2'                                                                                           TREATMENTTYPE    --55. 특진여부 (2 : 일반 / 1 : 특진)
                              , ''                                                                                            MEDICALCOST--56. 급여/비급여 여부 (1 급여 / 2 비급여)
                              , 'GM'                                                                                            MODALITY --57. 장비 varchar(10)
                              , M.ORD_SLIP_CTG_CD                                                                             SECTION    --58. 판독섹션 varchar(20)
                           FROM MOOOREXM M
                              , MSEPMPMD C
                              , PCTPCPAM_DAMO P
                              , XBIL.PCTPCPAV F
                          WHERE 0=0
                            AND C.PTHL_NO         = IN_PTHL_NO
                            AND M.SPCM_PTHL_NO    = C.PTHL_NO
                            AND M.HSP_TP_CD       = IN_HSP_TP_CD
                            AND M.ORD_CD          = IN_EXM_CD --L65107
                            AND M.HSP_TP_CD       = C.HSP_TP_CD
                            AND M.PT_NO           = P.PT_NO
                            AND M.PT_NO           = F.PT_NO(+)
                            AND F.PT_REL_TP_CD(+) = '0';  
                           
    EXCEPTION
        WHEN  OTHERS  THEN
           IO_ERRYN  := 'Y';
           IO_ERRMSG := '병리 PACS Insert 처리 중 에러 발생. ErrCd = ' || TO_CHAR(SQLCODE);
           RETURN;           
    END;  
END;