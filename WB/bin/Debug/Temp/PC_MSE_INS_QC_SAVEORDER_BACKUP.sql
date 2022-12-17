PROCEDURE      PC_MSE_INS_QC_SAVEORDER_BACKUP (   IN_PT_NO            IN        VARCHAR2--IN_PTNO

                                    , IN_ORD_DT            IN        VARCHAR2--IN_ORDDTE
                                    , IN_PACT_TP_CD        IN        VARCHAR2--IN_PATSECT
                                    , IN_EXM_CTG_CD        IN        VARCHAR2--IN_FRCTCD
                                    , IN_EXM_CD            IN        VARCHAR2--IN_TSTCD

                                    , IN_PT_HME_DEPT_CD    IN        VARCHAR2--IN_DPCD
                                    , IN_MED_MIFI_TP_CD    IN        VARCHAR2--IN_INSCLS
                                    , IN_FIRST            IN        VARCHAR2--방수석 추가 같은 시점에 오더 발행시 검사 그룹번호 묶어주기 위해서
                                    , HIS_HSP_TP_CD        IN        VARCHAR2--IN_HSPCL    --이준희(2012-10-12):
                                    , IN_EQUP_CD        IN      VARCHAR2--장비코드

                                    , IN_LOT_NO         IN      VARCHAR2 --LotNo
                                    , IN_MTR_CD         IN      VARCHAR2 --정도관리물질명
                                    , HIS_STF_NO        IN        MOOOREXM.FSR_STF_NO%TYPE
                                    , HIS_PRGM_NM        IN        MOOOREXM.FSR_PRGM_NM%TYPE
                                    , HIS_IP_ADDR        IN        MOOOREXM.FSR_IP_ADDR%TYPE

                                    , IO_SPCM_NO        IN OUT  VARCHAR2
                                    , IO_ORDER_CNT      IN OUT  VARCHAR2
                                    , IO_ERR_YN            IN OUT    VARCHAR2
                                    , IO_ERR_MSG        IN OUT    VARCHAR2
)
/*
--서비스 이름        : PC_MSE_ISRT_QC_ORD
--최초 작성일        : 2012-10-09
--최초 작성자        : 이지케어텍 이준희
--Description    : 정도관리 - 정도관리 오더 - 바코드 출력
*/
/*<[(btn)바코드 출력]
$$pc_mse_ins_saveorder

*/
AS
    T_WKGRP                    VARCHAR2(0010)    := '';
    T_MEDDR                    VARCHAR2(0010)    := '';
    T_ORGORDT                VARCHAR2(0010)    := '';

    --이준희(2012-10-16): 추정 기본값을 넣음; 차후, 유효한 기본값인지 재확인할 것.
    --T_MEDDEPT                VARCHAR2(0010)    := NULL;                                                --이준희(2013-04-12): 추대리님 검토에 의거해 NULL로 변경하려 했으나, 처방 발행 실패로 인해 원복함.
    --T_MEDDEPT                VARCHAR2(0010)    := '';
    T_MEDDEPT                VARCHAR2(0010)    := '-';

    T_MAXSEQ                NUMBER(005)        := 0;
    --T_ORGSEQ                NUMBER(005)        := 0;

    T_MIF_CD                VARCHAR2(20)    := '';
    T_ORD_CTG_CD            VARCHAR2(3)        := '';
    T_TH1_SPCM_CD            VARCHAR2(4)        := '';
    T_TH2_SPCM_CD            VARCHAR2(4)        := '';
    T_IN_DPCD_DECODED        VARCHAR2(32)    := 'A';
    T_ORD_SLIP_CTG_CD        CCOOCBAC.ORD_SLIP_CTG_CD%TYPE := '';
    T_ORD_NM                VARCHAR2(500)    := '';
    T_SPCNO                 MSELMCED.SPCM_NO%TYPE;

    TYPE T_VC2ARRAY200 IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

    V_EXM_CD        T_VC2ARRAY200;

    V_CNT           NUMBER := 0;

    T_DEPT_CD                VARCHAR2(0020) :='';    -- 2017.12.01   부서코드
    T_TLA_SPCM_NO            VARCHAR2(0020) :='';    -- 2017.12.01   TLA검체번호
    V_TLA_SPCM_NO            VARCHAR2(0020) :='0';    -- 2017.12.01   TLA검체번호(동일)

BEGIN
--____________________________________________________________________________________________________[To-Be]
IF    /*XSUP.PC_MSE_INS_QC_SAVEORDER*/
    IN_FIRST = '1'    --환자의 마지막 동시 검사번호 조회
THEN     --같은 시점에 오더 발행시 검사 그룹번호 묶어주기 위함.
    BEGIN
        SELECT NVL(MAX(TO_NUMBER(STM_EXM_BNDL_SEQ)), 0) + 1--<|WKGRP_SEQ
          INTO T_WKGRP
          FROM MOOOREXM--<|MOEEXAMT
         WHERE PT_NO           = IN_PT_NO
           AND ORD_DT         = TRUNC(SYSDATE)  --<|ORD_DTE
           AND HSP_TP_CD       = HIS_HSP_TP_CD  -- 병원구분
        ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IO_ERR_YN  := 'Y';
            IO_ERR_MSG := '해당 일자의 오더에 환자정보가 없습니다!' || IN_PT_NO || ', ' || IN_ORD_DT;
            RETURN;
        WHEN OTHERS THEN
            IO_ERR_YN  := 'Y';
            IO_ERR_MSG := '환자의 마지막 동시검사번호 조회시 발생. ERRCD = ' || TO_CHAR(SQLCODE);
            RETURN;
    END;
ELSE
    BEGIN
        SELECT NVL(MAX(TO_NUMBER(STM_EXM_BNDL_SEQ)), 1)--<|WKGRP_SEQ
          INTO T_WKGRP
          FROM MOOOREXM--<|MOEEXAMT
         WHERE PT_NO         = IN_PT_NO
           AND ORD_DT         = TRUNC(SYSDATE)--<|ORD_DTE
           AND HSP_TP_CD       = HIS_HSP_TP_CD  -- 병원구분
            ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IO_ERR_YN  := 'Y';
            IO_ERR_MSG := '해당 일자의 오더에 환자정보가 없습니다!' || IN_PT_NO || ', ' || IN_ORD_DT;
            RETURN;
        WHEN OTHERS THEN
            IO_ERR_YN  := 'Y';
            IO_ERR_MSG := '환자의 마지막 동시검사번호 조회시 발생. ERRCD = ' || TO_CHAR(SQLCODE);
            RETURN;
    END;
END IF;
--실제 데이터 추가 전 원 오더 및 오더 순번을 구함
BEGIN
    SELECT NVL(MAX(ORD_SEQ), 0) + 1--,
        --NVL(MAX(ORG_SEQ), 0) + 1    --의 최대값 + 1
      INTO T_MAXSEQ--,
        --T_ORGSEQ                    --이준희(2012-10-12): 현재는 사용되지 않는 듯함.
      FROM MOOOREXM--<|MOEEXAMT
     WHERE PT_NO         = IN_PT_NO
       AND ORD_DT         = TO_DATE(IN_ORD_DT,'YYYYMMDD')--<|ORD_DTE
       AND HSP_TP_CD       = HIS_HSP_TP_CD  -- 병원구분
    ;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IO_ERR_YN  := 'Y';
        IO_ERR_MSG := '해당 일자의 오더에 환자정보가 없습니다!' || IN_PT_NO || ', ' || IN_ORD_DT;
        RETURN;
    WHEN OTHERS THEN
        IO_ERR_YN  := 'Y';
        IO_ERR_MSG := '환자의 원오더 및 오더 순번 조회시 발생. ERRCD = ' || TO_CHAR(SQLCODE);
    RETURN;
END;

IF IN_FIRST = '1' THEN
BEGIN
    FOR REC IN ( SELECT COLUMN_VALUE EXM_CD
                  FROM TABLE(XCOM.FT_COM_STRING_TABLE(IN_EXM_CD,','))
               )
    LOOP
        V_CNT            := V_CNT + 1;
        V_EXM_CD (V_CNT) := REC.EXM_CD;
    END LOOP;
END;
ELSE
BEGIN

    FOR REC IN ( SELECT DISTINCT
                        A.EXM_CD         EXM_CD
                   FROM MSELMQED A
                      , MSELMEBM B
--                      , CCOOCBAC C        -- 처방코드 테이블 우선 제외 2017.12.21
                  WHERE A.DEXM_MDSC_EQUP_CD = IN_EQUP_CD
                    AND A.LOT_NO            = IN_LOT_NO
                    AND B.EXM_CD            = A.EXM_CD
--                    AND B.EXM_CD            = C.ORD_CD
                    AND A.HSP_TP_CD   = HIS_HSP_TP_CD  -- 병원구분
                    AND B.HSP_TP_CD   = HIS_HSP_TP_CD  -- 병원구분
--                    AND C.HSP_TP_CD   = HIS_HSP_TP_CD  -- 병원구분
                 ORDER BY A.EXM_CD
               )
    LOOP
        V_CNT            := V_CNT + 1;
        V_EXM_CD (V_CNT) := REC.EXM_CD;
    END LOOP;


END;
END IF;

    FOR I IN 1..V_CNT
    LOOP
        BEGIN
            SELECT A.EXM_CD            --B.MIF_CD
                 , 'CP'                --B.ORD_CTG_CD
                 , A.TH1_SPCM_CD
                 , A.TH2_SPCM_CD
                 , A.EITM_NM        --B.ORD_NM
                 , A.MED_EXM_CTG_CD --B.ORD_SLIP_CTG_CD
              INTO T_MIF_CD
                 , T_ORD_CTG_CD
                 , T_TH1_SPCM_CD
                 , T_TH2_SPCM_CD
                 , T_ORD_NM
                 , T_ORD_SLIP_CTG_CD
              FROM MSELMEBM A
--                 , CCOOCBAC B
             WHERE A.EXM_CD    = V_EXM_CD (I)
               AND A.HSP_TP_CD = HIS_HSP_TP_CD
--               AND B.ORD_CD    = A.EXM_CD
--               AND B.HSP_TP_CD = A.HSP_TP_CD
               ;

            EXCEPTION
                WHEN OTHERS THEN
                    IO_ERR_YN  := 'Y';
                    IO_ERR_MSG := SQLERRM;
                    RETURN;
        END;

        BEGIN
            XMED.PKG_MOO_SAVEORDERS.PC_SAVEORDER
            (
--                        D_ACPT_DTM                                      =>      NULL,                                           --접수일시
--                        D_ANST_END_DTM                                  =>      NULL,                                           --마취종료일시
--                        D_ANST_STR_DTM                                  =>      NULL,                                           --마취시작일시
--                        D_BBNK_TRFS_RDY_CMPL_DTM                        =>      NULL,                                           --혈액은행수혈준비완료일시
--                        D_BLCL_DTM                                      =>      NULL,                                           --채혈일시
--                        D_BRFG_DTM                                      =>      NULL,                                           --보고일시
--                        D_CNCL_RSN_REG_DT                               =>      NULL,                                           --취소사유등록일자
--                        D_CONN_ORD_DT                                   =>      NULL,                                           --연결처방일자
--                        D_DEXM_BLCL_CLSN_DTM                            =>      NULL,                                           --진단검사채혈마감일시
--                        D_DG_RINS_DT                                    =>      NULL,                                           --약반납지시일자
--                        D_DRST_FLPRS_DTM                                =>      NULL,                                           --약국조제일시
--                        D_EXM_HOPE_DT                                   =>      TO_DATE(IN_ORD_DT, 'YYYYMMDD'),                 --EXM_HOPE_DT<TST_EXP_DTE(검사 희망 일자)
--                        D_EXRM_HH_DTM                                   =>      NULL,                                           --검사실시일시
--                        D_FLPRS_DTM                                     =>      NULL,                                           --조제일시
--                        D_FMT_DT                                        =>      NULL,                                           --수행일자
--                        D_LCL_BLCL_RFFM_PRNT_DTM                        =>      NULL,                                           --지역채혈의뢰서 출력일시
--                        D_MDCN_PSD_PRO_DTM                              =>      NULL,                                           --약제보류처리일시
--                        D_NR_PSD_PRO_DTM                                =>      NULL,                                           --간호보류처리일시
--                        D_NREXM_WK_DTM                                  =>      NULL,                                           --비예약검사작업일시
--                        D_NRS_ORD_QTY_CHG_DTM                           =>      NULL,                                           --간호사처방수량변경일시
--                        D_NRS_QTY_REQ_TM_CHG_DTM                        =>      NULL,                                           --간호사처방수량요청시간변경일시
--                        D_NRS_TRNQ_TM_CHG_DTM                           =>      NULL,                                           --간호사수혈요청시간변경일시
--                        D_OP_EXPT_DT                                    =>      NULL,                                           --수술예정일자
--                        D_ORD_CRE_DT                                    =>      NULL,                                           --처방생성일자
--                        D_ORD_DT                                        =>      TO_DATE(IN_ORD_DT, 'YYYYMMDD'),                 --[추정]ORD_DT<ORD_DTE(처방 일자); 차후, 값을 +1日 시켜야 하는지 및 또는 SYSDATE를 사용해야 할지 확인 요.
--                        D_PHTG_DT                                       =>      NULL,                                           --촬영일자
--                        D_PT_RPY_DT                                     =>      NULL,                                           --환자수납일자
--                        D_RINS_DTM                                      =>      NULL,                                           --혈액은행 반납지시일시
--                        D_RPT_ORD_DT                                    =>      NULL,                                           --반복처방일자
--                        D_RSV_DTM                                       =>      NULL,                                           --<RSVDATE(예약 일시)
--                        D_RTM_CLSN_DT                                   =>      NULL,                                           --실시간 마감 일자
--                        D_RTM_FMCN_DTM                                  =>      NULL,                                           --실시간수행 취소 일시
--                        D_RTM_FMT_DTM                                   =>      NULL,                                           --실시간 수행 일시
--                        D_RTM_MED_DT                                    =>      NULL,                                           --실시간 진료 일자
--                        D_RTM_PBL_DTM                                   =>      NULL,                                           --실시간 발행 일시
--                        D_RTN_DT                                        =>      NULL,                                           --반납일자
--                        D_STK_DT                                        =>      NULL,                                           --재고일자
--                        HIS_HSP_TP_CD                                   =>      HIS_HSP_TP_CD,                                  --<HSP_CL(병원 구분 코드)
--                        HIS_HSPI_TP_CD                                  =>      '01',                                           --[추정]HSPI_TP_CD(병원 내부 구분 코드)
--                        HIS_IP_ADDR                                     =>      HIS_IP_ADDR,                                    --FSR_IP_ADDR(등록 변경 IP ADDRESS)
--                        HIS_PRGM_NM                                     =>      HIS_PRGM_NM,                                    --FSR_PRGM_NM(등록 변경 프로그램 명)
--                        HIS_STF_NO                                      =>      HIS_STF_NO,                                     --FSR_STF_NO<FST_EDITID(최초 등록 직원번호)
--                        N_AMD_QTY                                       =>      NULL,                                           --투여수량
--                        N_AMS_NO                                        =>      NULL,                                           --투약번호
--                        N_BBNK_OW_QTY                                   =>      NULL,                                           --혈액은행출고수량
--                        N_BBNK_RTN_QTY                                  =>      NULL,                                           --혈액은행반납수량
--                        N_BNDL_SORT_SEQ                                 =>      NULL,                                           --묶음 정렬 순번
--                        N_BSC_DYS                                       =>      NULL,                                           --기본일수
--                        N_CP_CHG_RSN_SEQ                                =>      NULL,                                           --CP 변경 사유 순번
--                        N_CP_SCHD_SEQ                                   =>      NULL,                                           --CP 일정 순번
--                        N_DG_BDOP_SEQ                                   =>      NULL,                                           --약묶음처방순번
--                        N_DGR_SEQ                                       =>      NULL,                                           --차수순번(MOOPTVPD)
--                        N_DNFR_ID                                       =>      NULL,                                           --치식ID
--                        N_DRST_CLSN_RCTM                                =>      NULL,                                           --약국마감회차
--                        N_EXM_NOTM                                      =>      1,                                              --<PUT_QTY(검사 횟수)
--                        N_FMT_NOTM                                      =>      NULL,                                           --수행횟수
--                        N_MDRC_FOM_SEQ                                  =>      NULL,                                           --진료기록개정순번
--                        N_MDRC_ID                                       =>      NULL,                                           --진료기록ID
--                        N_NR_FMT_NOTM                                   =>      NULL,                                           --간호수행횟수
--                        N_NREXM_RSV_DYS                                 =>      NULL,                                           --비예약검사예약일수
--                        N_NRS_ORD_CHG_QTY                               =>      NULL,                                           --간호사처방변경 수량
--                        N_NRST_ID                                       =>      NULL,                                           --간호진술문ID
--                        N_ODRER_MDRC_ID                                 =>      NULL,                                           --타과의뢰진료기록ID
--                        N_OORD_AVL_PRD                                  =>      NULL,                                           --원외처방유효기간
--                        N_ORD_NOTM                                      =>      NULL,                                           --처방횟수
--                        N_ORD_QTY                                       =>      NULL,                                           --처방수량
--                        N_PRPD_NOTM                                     =>      NULL,                                           --기간별횟수
--                        N_PT_CP_ORD_SEQ                                 =>      T_MAXSEQ,                                       --<ORD_SEQ(환자 CP 처방 순번)
--                        N_RINS_NOTM                                     =>      NULL,                                           --반납지시횟수
--                        --N_RPY_CLS_SEQ                                 =>      NULL,                                           --수납 유형 순번
--                        N_RPY_CLS_SEQ                                   =>      1,                                              --이준희(2013-04-12): 추대리님 검토에 의거해, 1로 변경함.
--                        N_RTN_QTY                                       =>      NULL,                                           --반납수량
--                        N_SCRN_SORT_SEQ                                 =>      NULL,                                           --<IN_SEQ(화면 정렬 순번)
--                        N_SORD_DTL_SEQ                                  =>      NULL,                                           --세트 처방 상세 순번
--                        --N_SORD_REG_ID                                 =>      NULL,                                           --세트 처방 등록 ID
--                        N_STM_EXM_BNDL_SEQ                              =>      T_WKGRP,                                        --<WKGRP_SEQ(동시검사 묶음 순번)
--                        N_TH2_AMD_QTY                                   =>      NULL,                                           --2번째투여수량
--                        N_TH3_AMD_QTY                                   =>      NULL,                                           --3번째투여수량
--                        N_TH4_AMD_QTY                                   =>      NULL,                                           --4번째투여수량
--                        N_TH5_AMD_QTY                                   =>      NULL,                                           --5번째투여수량
--                        N_TRTM_QTY                                      =>      NULL,                                           --처치수량
--                        N_WHL_DSG                                       =>      NULL,                                           --전체용량
--                        N_WHL_PRD_DYS                                   =>      NULL,                                           --전체기간일수
--                        RESULT                                          =>      IO_ERR_MSG,
--                        V_ABGA_FIO2_NM                                  =>      NULL,                                           --ABGAFIO2명
--                        V_ABGA_NOX_QTY_NM                               =>      NULL,                                           --ABGA일산화질소수량명
--                        V_ABGA_OXY_VLC_NM                               =>      NULL,                                           --ABGA산소함유량명
--                        V_ABGA_PATH_CLS_CD                              =>      NULL,                                           --ABGA경로유형코드
--                        V_ACS_EXPT_PRD_CD                               =>      NULL,                                           --ACS예정기간코드
--                        V_ACS_IDCT_CTG_CD                               =>      NULL,                                           --ACS적응증분류코드
--                        V_ACS_PHMC_ANS_CNTE                             =>      NULL,                                           --ACS약사답변내용
--                        V_ACS_TGT_INR_CTG_CD                            =>      NULL,                                           --ACS대상INR분류코드
--                        V_ADD_ATBA_ORD_RSN_CD                           =>      NULL,                                           --추가항생제처방사유코드
--                        V_ADD_ATBA_ORD_RSN_ETC_CNTE                     =>      NULL,                                           --추가항생제처방사유기타내용
--                        V_ADD_ORD_YN                                    =>      'N',                                            --<ORDTYPE(추가 처방 여부)
--                        V_AID_MKG_DTL_CNTE                              =>      NULL,                                           --보조기제작상세내용
--                        V_AMDPO_TP_CD                                   =>      NULL,                                           --투여위치구분코드
--                        V_AMPTH_TP_CD                                   =>      NULL,                                           --투여경로구분코드
--                        V_AMS_NO_TP_CD                                  =>      NULL,                                           --투약번호구분코드
--                        V_AMS_ORD_PSD_STS_CD                            =>      NULL,                                           --투약처방보류상태코드
--                        V_AMS_ORD_STS_CD                                =>      NULL,                                           --투약처방상태코드
--                        V_ANDR_STF_NO                                   =>      T_MEDDR,                                        --<JUCDR(주치의 직원식별 ID)
--                        V_ANMC_ETC_RSN_CNTE                             =>      NULL,                                           --임의 비급여 기타사유 내용
--                        V_ANMC_RSN_CD                                   =>      NULL,                                           --임의비급여 사유 코드
--                        V_ARCL_NO                                       =>      NULL,                                           --물품번호
--                        V_AST_YN                                        =>      NULL,                                           --AST여부
--                        V_ATBA_AMD_YN                                   =>      NULL,                                           --항생제 투여 여부
--                        V_ATBA_CTG_CLNL_CD                              =>      NULL,                                           --항생제분류임상코드
--                        V_BLCL_STF_NO                                   =>      NULL,                                           --채혈직원번호
--                        V_BLCL_YN                                       =>      NULL,                                           --채혈여부
--                        V_BLOD_RDY_STS_CD                               =>      NULL,                                           --혈액준비상태코드
--                        V_BNDL_SORT_ORD_ID                              =>      NULL,                                           --묶음 정렬 처방 ID
--                        V_BRFG_STF_NO                                   =>      NULL,                                           --보고직원번호
--                        V_CAL_CTG_CD                                    =>      NULL,                                           --열량분류코드
--                        V_CAL_NM                                        =>      NULL,                                           --열량명
--                        V_CHC_EXM_YN                                    =>      NULL,                                           --선택 검사 여부
--                        V_CHC_MED_CONR_VIST_YN                          =>      NULL,                                           --선택 진료창구 방문 여부
--                        V_CHDR_NM                                       =>      NULL,                                           --선택의명
--                        V_CHDR_STF_NO                                   =>      NULL,                                           --선택의직원식별ID
--                        V_CMED_DEPT_CD                                  =>      NULL,                                           --선택진료부서코드
--                        V_CMIF_OCUR_TP_CD                               =>      NULL,                                           --연결수가발생구분코드
--                        V_CNCL_RSN_REG_STF_NO                           =>      NULL,                                           --취소사유등록직원번호
--                        V_CNSL_YN                                       =>      'N',                                            --<CONSULT_YN(상담 여부)
--                        V_CONN_ORD_CD                                   =>      NULL,                                           --연결처방코드
--                        V_CONN_ORD_ID                                   =>      NULL,                                           --연결처방ID
--                        V_COPN_CNTE                                     =>      NULL,                                           --임상 소견 내용
--                        V_CP_APY_ID                                     =>      NULL,                                           --CP 적용 ID
--                        V_CR_EXM_YN                                     =>      NULL,                                           --CR 검사 여부
--                        V_CSDR_STF_NO                                   =>      NULL,                                           --상담의직원번호
--                        V_DEXM_BLCL_CLSN_STF_NO                         =>      NULL,                                           --진단검사채혈마감직원번호
--                        V_DEXM_BLCL_CLSN_YN                             =>      NULL,                                           --진단검사채혈마감여부
--                        V_DEXM_BLCL_YN                                  =>      NULL,                                           --진단검사채혈마감여부
--                        V_DEXM_SMWH_MGMT_YN                             =>      'Y',                                            --DEXM_SMWH_MGMT_YN<QC_YN(진단검사 정도관리 여부)
--                        V_DFA_YN                                        =>      NULL,                                           --유보항균제여부
--                        V_DG_BNDL_MAIN_YN                               =>      NULL,                                           --약묶음주여부
--                        V_DG_MIX_YN                                     =>      NULL,                                           --약혼합여부
--                        V_DG_RINS_STF_NO                                =>      NULL,                                           --약반납지시직원번호
--                        V_DGCV_OMTR_UNIT_CD                             =>      NULL,                                           --약가환산처방재료단위코드
--                        V_DGT_YN                                        =>      NULL,                                           --디지털 여부
--                        V_DRST_AMS_IQRY_CNTE                            =>      NULL,                                           --약국투약문의내용
--                        V_DRST_AMS_IQRY_YN                              =>      NULL,                                           --약국투약문의여부
--                        V_DTL_AMPTH_CLS_CD                              =>      NULL,                                           --상세투여경로유형코드
--                        V_DWT_HOPE_MED_DEPT_CD                          =>      NULL,                                           --전과전등희망진료부서코드
--                        V_DWT_HOPE_MED_STF_NO                           =>      NULL,                                           --전과전등희망진료직원번호
--                        V_DYT_WD_MLDY_TP_CD                             =>      NULL,                                           --낮병동식이끼니구분코드
--                        V_ECH_PACK_YN                                   =>      NULL,                                           --개별포장여부
--                        V_EHSP_FLIT_YN                                  =>      NULL,                                           --외부병원 필름 판독 여부
--                        V_EMRG_ADN_YN                                   =>      NULL,                                           --응급가산여부
--                        V_EMRG_YN                                       =>      NULL,                                           --응급 여부
--                        V_EQUP_MBL_PSB_YN                               =>      NULL,                                           --장비 휴대가능 여부
--                        V_ERROR_YN                                      =>      IO_ERR_YN,                                      --에러 여부
--                        V_EXM_CHDR_STF_NO                               =>      NULL,                                           --검사선택의직원번호
--                        V_EXM_CNCL_RSN_CNTE                             =>      NULL,                                           --검사취소사유내용
--                        V_EXM_PRGR_STS_CD                               =>      'X',                                            --EXM_PRGR_STS_CD<TST_STAT(검사 진행 상태 코드)
--                        V_EXM_RFFM_IPTN_NO                              =>      NULL,                                           --검사의뢰서판독번호
--                        V_EXM_TYRM_NO                                   =>      NULL,                                           --검사치료실번호
--                        V_EXRS_SV_TBL_NM                                =>      NULL,                                           --검사결과저장테이블명
--                        V_EXTN_FMT_DEPT_CD                              =>      NULL,                                           --검사처치수행부서코드
--                        V_FAMT_TGT_YN                                   =>      NULL,                                           --정액대상 여부
--                        V_FLPRS_YN                                      =>      NULL,                                           --조제여부
--                        V_FMT_DRST_DEPT_CD                              =>      NULL,                                           --수행약국부서코드
--                        V_FMT_EXRM_NO                                   =>      NULL,                                           --수행검사실번호
--                        V_FMT_STF_NO                                    =>      NULL,                                           --수행직원번호
--                        V_FSR_STF_DEPT_CD                               =>      'LM',                                           --<ED   IT_DPCD(최초 등록직원 부서 코드)
--                        V_FST_EXM_CHDR_STF_NO                           =>      NULL,                                           --최초검사선택의직원번
--                        V_HOPE_EXRM_NO                                  =>      NULL,                                           --희망검사실번호
--                        V_IDCT_ORD_ETC_CNTE                             =>      NULL,                                           --적응증처방기타내용
--                        V_IDCT_ORD_GUID_CD                              =>      NULL,                                           --적응증처방안내코드
--                        V_IMPL_EXRM_TP_CD                               =>      NULL,                                           --시행검사실구분코드
--                        V_INJC_SCHD_CNTE                                =>      NULL,                                           --주사일정내용
--                        V_INPUT_PART                                    =>      'S',                                            --M: 진료, S: 진료지원
--                        V_IORD_PSB_YN                                   =>      NULL,                                           --원내처방가능여부
--                        V_IORD_RSN_CD                                   =>      NULL,                                           --원내처방사유코드
--                        V_IRRD_YN                                       =>      NULL,                                           --방사선조사여부
--                        V_LCL_BLCL_RFFM_PRNT_STF_NO                     =>      NULL,                                           --지역채혈의뢰서 출력직원번호
--                        V_LCL_BLCL_RFFM_PRNT_YN                         =>      NULL,                                           --지역채혈의뢰서출력여부
--                        V_MAIN_GRPY_YN                                  =>      NULL,                                           --주조영술 여부
--                        V_MDG_BNDL_TP_CD                                =>      NULL,                                           --혼합약묶음구분코드
--                        V_MDNG_ADN_APY_YN                               =>      NULL,                                           --심야 가산적용 여부
--                        V_MDPR_UNIT_CD                                  =>      NULL,                                           --약품단위코드
--                        V_MDPR_UNIT_TP_CD                               =>      NULL,                                           --약품단위구분코드
--                        V_MED_FUS_DLGT_TP_CD                            =>      NULL,                                           --진료용 위임 구분 코드
--                        V_MED_MIFI_TP_CD                                =>      IN_MED_MIFI_TP_CD,                              --<INS_CLS(진료수가 보험 구분 코드)
--                        V_MED_PACT_TP_CD                                =>      NULL,                                           --진료원무접수구분코드
--                        V_MIF_CD                                        =>      T_MIF_CD,                                       --<SUGACODE(수가 코드)
--                        V_MIX_MGN_YN                                    =>      NULL,                                           --혼합주체여부
--                        V_ML_CB_SHP_CD                                  =>      NULL,                                           --식이별형태코드
--                        V_MNF_CMP_CD                                    =>      NULL,                                           --제조회사코드
--                        V_MNOP_YN                                       =>      NULL,                                           --주수술여부
--                        V_MRI_WROP_CNTE                                 =>      NULL,                                           --MRI소견서내용
--                        V_MSP_CR_EXM_YN                                 =>      NULL,                                           --진료지원CR검사여부
--                        V_MSP_DGT_YN                                    =>      NULL,                                           --진료지원디지털여부
--                        V_NCHC_YN                                       =>      NULL,                                           --비선택 여부
--                        V_NINS_PTM_ETC_RSN_CNTE                         =>      NULL,                                           --비보험 시점 기타사유 내용
--                        V_NINS_RSN_CD                                   =>      NULL,                                           --비보험 사유 코드
--                        V_NN_BLCL_RSN_CD                                =>      NULL,                                           --미채혈사유코드
--                        V_NR_EMRG_ACPT_TGT_YN                           =>      NULL,                                           --간호응급접수대상여부
--                        V_NR_RMK                                        =>      NULL,                                           --간호비고
--                        V_NREXM_CHG_TP_CD                               =>      NULL,                                           --비예약검사변경구분코
--                        V_NREXM_PACT_ID                                 =>      NULL,                                           --비예약검사원무접수ID
--                        V_NREXM_RSV_TM_UNIT_CD                          =>      NULL,                                           --비예약검사예약시간단위코드
--                        V_NREXM_WK_STF_NO                               =>      NULL,                                           --비예약검사작업직원번호
--                        --V_NRS_CFMT_TP_CD                              =>      NULL,                                           --간호사확인구분코드
--                        V_NRS_ORD_QTY_CHG_STF_NO                        =>      NULL,                                           --간호사처방수량변경직원번호
--                        V_NRS_QTY_REQ_TM_CHG_STF_NO                     =>      NULL,                                           --간호사처방수량요청시변경직원번호
--                        V_NRS_TRNQ_TM_CHG_STF_NO                        =>      NULL,                                           --간호사 수혈요청시간변경직원번호
--                        V_NRS_TRNQ_TM_CNTE                              =>      NULL,                                           --간호사수혈요청시간내용
--                        V_NXDY_ORD_YN                                   =>      NULL,                                           --익일처방여부
--                        V_ODAPL_POP_CD                                  =>      '1',                                            --<JOBTYPE(처방 적용목적 코드)
--                        V_ODDSC_TP_CD                                   =>      'C',                                            --<DC_YN(처방 중단 구분 코드)
--                        V_ONLY_UPDATE_YN                                =>      'N',                                            --진료에서는 수정시 무조건 DC 처리를 하지만 건증같은경우 UPDATE 목적의 PROCESS 도 있음
--                        V_OP_CD                                         =>      NULL,                                           --수술코드
--                        V_OP_EXPT_REG_ID                                =>      NULL,                                           --수술예정등록ID
--                        V_OP_FUS_YN                                     =>      NULL,                                           --수술용여부
--                        V_OP_NM                                         =>      NULL,                                           --수술명
--                        V_OPRS_ID                                       =>      NULL,                                           --원처방 ID
--                        V_OPRS_TP_CD                                    =>      NULL,                                           --원처방 구분 코드
--                        V_ORD_CD                                        =>      V_EXM_CD (I),                                   --<ORDCD(처방 코드)
--                        V_ORD_CONN_TP_CD                                =>      NULL,                                           --처방연결구분코드
--                        V_ORD_CTG_CD                                    =>      T_ORD_CTG_CD,                                   --<FEE_GRP(처방 분류 코드)
--                        V_ORD_FEE_RTN_RMK_CNTE                          =>      NULL,                                           --처방료반납비고내용
--                        V_ORD_FEE_RTN_RSN_CD                            =>      NULL,                                           --처방료반납사유코드
--                        V_ORD_GRP_CD                                    =>      '03',                                           --[추정]처방 그룹 코드; --"검사"를 의미함.
--                        V_ORD_ID                                        =>      NULL,                                           --처방 ID
--                        V_ORD_IN_MODE                                   =>      'I',                                            --[추정]처방 저장 모드;         I:INSERT , U:UPDATE
--                        V_ORD_MRK_CTG_CD                                =>      T_IN_DPCD_DECODED,                              --<MEDTYPE(처방 표시 분류 코드)
--                        V_ORD_NM                                        =>      T_ORD_NM,                                       --[추정]ORD_NM(처방 명)
--                        V_ORD_OCUR_TP_CD                                =>      'L1',                                           --<CR   T_GUBUN(처방발생 구분 코드)
--                        V_ORD_PRD_CYC_CD                                =>      NULL,                                           --처방기간주기코드
--                        V_ORD_RMK_CNTE                                  =>      NULL,                                           --처방 비고 내용
--                        V_ORD_SLIP_CTG_CD                               =>      T_ORD_SLIP_CTG_CD,                              --<SLIP_CD(처방 전표 분류 코드)
--                        V_PA_FUS_DLGT_TP_CD                             =>      NULL,                                           --원무용위임구분코드
--                        V_PACT_ID                                       =>      'MILM000001',                                   --[추정]FST_PACT_ID(최초 원무 접수 ID)
--                        V_PACT_TP_CD                                    =>      IN_PACT_TP_CD,                                  --<RPY_PACT_TP_CD<PATSECT(수납 원무접수 구분 코드)
--                        V_PBSO_DEPT_CD                                  =>      IN_PT_HME_DEPT_CD,                              --<ORD_SITE(발행처 부서 코드)
--                        V_PMLK_CTG_CD                                   =>      NULL,                                           --분유분류코드
--                        V_PMLK_TM1_QTY_CD                               =>      NULL,                                           --분유1회수량코드
--                        V_POWD_DG_YN                                    =>      NULL,                                           --가루약여부
--                        V_PPAY_PCH_REQ_YN                               =>      NULL,                                           --선납구매요청여부
--                        V_PRM_NO                                        =>      NULL,                                           --병실 번호
--                        V_PRN_ORD_ETC_RSN_DTL_CNTE                      =>      NULL,                                           --PRN처방기타사유상세내용
--                        V_PRN_ORD_RSN_CD                                =>      NULL,                                           --PRN처방사유코드
--                        V_PRN_ORD_YN                                    =>      NULL,                                           --PRN 처방 여부
--                        V_PSD_APLC_STF_NO                               =>      NULL,                                           --보류신청직원번호
--                        V_PT_BNG_DG_YN                                  =>      NULL,                                           --환자지참약여부
--                        V_PT_CLCTN_DEPT_CD                              =>      NULL,                                           --환자현위치부서코드
--                        V_PT_HME_DEPT_CD                                =>      T_MEDDEPT,                                      --<DPCD(환자 수진부서 코드)
--                        V_PT_MOV_PLC                                    =>      'COLL',                                         --<PT_GUIDE(환자 이동 장소)
--                        V_PT_MTD_DEPT_CD                                =>      NULL,                                           --환자진료과부서코드
--                        V_PT_NO                                         =>      IN_PT_NO,                                       --<PT_NO(환자 번호)
--                        V_RINS_STF_NO                                   =>      NULL,                                           --반납지시직원번호
--                        V_RMK_CNTE                                      =>      NULL,                                           --비고내용
--                        V_ROP_YN                                        =>      NULL,                                           --재수술여부
--
--                        --이준희(2012-11-14): 남차장님과 상의해 NULL 대신 값을 추가함.
--                        V_RPY_PACT_ID                                   =>      'MILM000001',                                   --수납원무접수ID;
--                        --이준희(2012-11-14): 남차장님과 상의해 NULL 대신 값을 추가함.
--                        V_RPY_PACT_TP_CD                                =>      IN_PACT_TP_CD,                                  --수납 원무접수 구분 코드
--                        V_RPY_STS_CD                                    =>      '',                                             --RPY_STS_CD<RCPTYPE(수납 상태 코드)
--                        V_RSCH_PRJT_NO                                  =>      NULL,                                           --연구과제번호
--                        V_RSV_PRO_STF_NO                                =>      NULL,                                           --예약처리 직원 식별 ID
--                        V_RTM_CLSN_FMT_YN                               =>      NULL,                                           --실시간 마감 수행 여부
--                        V_RTM_CLSN_STF_NO                               =>      NULL,                                           --실시간마감 직원 식별 ID
--                        V_RTM_FMCN_STF_NO                               =>      NULL,                                           --실시간수행 취소직원 식별 ID
--                        V_RTM_FMPS_COAP_DEPT_CD                         =>      NULL,                                           --실시간 수행자 비용적용부서 코드
--                        V_RTM_FMPS_WKDP_CD                              =>      NULL,                                           --실시간 수행자 근무부서 코드
--                        V_RTM_FMT_STF_NO                                =>      NULL,                                           --실시간 수행직원 식별 ID
--                        V_RTM_MEDR_AADP_CD                              =>      NULL,                                           --실시간 진료의발령 부서 코드
--                        V_RTM_MEDR_STF_NO                               =>      NULL,                                           --실시간 진료의직원 식별 ID
--                        V_RTM_MEDR_WKDP_CD                              =>      NULL,                                           --실시간 진료의근무 부서 코드
--                        V_RTM_PBL_STF_NO                                =>      NULL,                                           --실시간 발행 직원식별 ID
--                        V_RTM_PBR_AADP_CD                               =>      NULL,                                           --실시간 발행자 발령부서 코드
--                        V_RTM_PBR_WKDP_CD                               =>      NULL,                                           --실시간 발행자 근무부서 코드
--                        V_RTM_PDAU_YN                                   =>      NULL,                                           --실시간 PDA 사용여부
--                        V_RTM_USE_EQUP_CD                               =>      NULL,                                           --실시간 사용 장비 코드
--                        V_RTN_RFND_YN                                   =>      NULL,                                           --혈액은행 반납환불여부
--                        V_RTN_STF_NO                                    =>      NULL,                                           --반납직원번호
--                        V_SFIN_PSB_YN                                   =>      NULL,                                           --자가주사가능여부
--                        V_SGKY_NO                                       =>      NULL,                                           --서명키 번호
--                        V_SGNT_STF_NO                                   =>      NULL,                                           --서명 직원 번호
--                        V_SLNT_CTG_CD                                   =>      NULL,                                           --염분분류코드
--                        V_SORD_REG_ID                                   =>      NULL,                                           --세트 처방 등록 ID
--                        V_SPCL_ORD_YN                                   =>      NULL,                                           --특별 처방 여부(MOOPTVPD)
--                        V_SPCM_PTHL_NO                                  =>      NULL,                                           --검체 병리 번호
--                        V_TH1_SPCM_CD                                   =>      T_TH1_SPCM_CD,                                  --<SPC_CD_1(1번째 검체 코드)
--                        V_TH2_EXM_CHDR_STF_NO                           =>      NULL,                                           --2번째검사선택의직원번호
--                        V_TH2_IPDR_STF_NO                               =>      NULL,                                           --2번째판독의직원번호
--                        V_TH2_SPCM_CD                                   =>      T_TH2_SPCM_CD,                                  --<SPC_CD_2(2번째 검체 코드)
--                        V_TH3_EXM_CHDR_STF_NO                           =>      NULL,                                           --3번째검사선택의직원번호
--                        V_TH3_IPDR_STF_NO                               =>      NULL,                                           --3번째판독의직원번호
--                        V_TH4_IPDR_STF_NO                               =>      NULL,                                           --4번째판독의직원번호
--                        V_TH5_IPDR_STF_NO                               =>      NULL,                                           --5번째판독의직원번호
--                        V_TH6_IPDR_STF_NO                               =>      NULL,                                           --6번째판독의직원번호
--                        V_TPN_KND_CD                                    =>      NULL,                                           --TPN종류코드
--                        V_TQTY_MDPR_UNIT_CD                             =>      NULL,                                           --총량약품단위코드
--                        V_TRFS_EXPT_OW_TP_CD                            =>      NULL,                                           --수혈예정출고구분코드
--                        V_TRFS_EXPT_REQR_TM_CNTE                        =>      NULL,                                           --수혈예정소요시간내용
--                        V_TRFS_MMDC_CTG_CD                              =>      NULL,                                           --수혈제제분류코드
--                        V_UGT_TRFS_TP_CD                                =>      NULL,                                           --긴급수혈구분코드
--                        V_USG_CD                                        =>      NULL,                                           --용법코드
--                        V_USG_RMK                                       =>      NULL,                                           --용법비고
--                        V_WD_DEPT_CD                                    =>      NULL,                                           --병동 부서 코드
--                        V_WRTR_PLWK_DEPT_CD                             =>      NULL,                                           --작성자근무지부서코드
--                        V_TOTH_CD_CNTE                                  =>      NULL,                                           --치아코드내용
--                        --###################################### 오픈 후 파라미터 추가 #################################################
--                        V_MED_PACT_ID                                   =>      NULL,                                           --진료원무접수ID     - DUMMY_01 : 01
--                        V_FST_ORD_ID                                    =>      NULL,                                           --최초처방ID         - DUMMY_02 : 02
--                        V_ICSN_TP_CD                                    =>      NULL,                                           --절개구분코드       - DUMMY_03 : 03
--                        N_DDY_DYS                                       =>      NULL,                                           --디데이일수         - DUMMY_04 : 04
--                        V_DDY_PRD_CYC_CD                                =>      NULL,                                           --디데이기간주기코드 - DUMMY_05 : 05
--                        V_RNS_DR_STF_NO                                 =>      NULL,                                           --실명제의사직원번호 - DUMMY_06 : 06
--                        V_CMX_OP_RSN_CD                                 =>      NULL,                                           --DUMMY_07 : 07
--                        V_CMX_OP_RSN_CNTE                               =>      NULL,                                           --DUMMY_08 : 08
----                        V_DUMMY_09                                      =>      NULL,                                           --DUMMY_09 : 09
----                        V_DUMMY_10                                      =>      NULL,                                           --DUMMY_10 : 10
----                        V_DUMMY_11                                      =>      NULL,                                           --DUMMY_11 : 11
----                        V_DUMMY_12                                      =>      NULL,                                           --DUMMY_12 : 12
--                        V_BODY_IHBTNZ_APY_RGN_CD                        =>      NULL,
--                        V_BODY_IHBTNZ_APY_RGN_CNTE                      =>      NULL,
--                        V_BODY_IHBTNZ_APY_RSN_CD                        =>      NULL,
--                        V_BODY_IHBTNZ_APY_RSN_CNTE                      =>      NULL,
--                        V_DUMMY_13                                      =>      NULL,                                           --DUMMY_13 : 13
--                        V_DUMMY_14                                      =>      NULL,                                           --DUMMY_14 : 14
--                        V_DUMMY_15                                      =>      NULL,                                           --DUMMY_15 : 15
--                        V_DUMMY_16                                      =>      NULL,                                           --DUMMY_16 : 16
--                        V_DUMMY_17                                      =>      NULL,                                           --DUMMY_17 : 17
--                        V_DUMMY_18                                      =>      NULL,                                           --DUMMY_18 : 18
--                        V_DUMMY_19                                      =>      NULL,                                           --DUMMY_19 : 19
--                        V_DUMMY_20                                      =>      NULL,                                           --DUMMY_20 : 20
--                        V_DUMMY_21                                      =>      NULL,                                           --DUMMY_21 : 21
--                        V_DUMMY_22                                      =>      NULL,                                           --DUMMY_22 : 22
--                        V_DUMMY_23                                      =>      NULL,                                           --DUMMY_23 : 23
--                        V_DUMMY_24                                      =>      NULL,                                           --DUMMY_24 : 24
--                        V_DUMMY_25                                      =>      NULL,                                           --DUMMY_25 : 25
--                        V_DUMMY_26                                      =>      NULL,                                           --DUMMY_26 : 26
--                        V_DUMMY_27                                      =>      NULL,                                           --DUMMY_27 : 27
--                        V_DUMMY_28                                      =>      NULL,                                           --DUMMY_28 : 28
--                        V_DUMMY_29                                      =>      NULL,                                           --DUMMY_29 : 29
--                        V_DUMMY_30                                      =>      NULL,                                           --DUMMY_30 : 30
--                        V_DUMMY_31                                      =>      NULL,                                           --DUMMY_31 : 31
--                        V_DUMMY_32                                      =>      NULL,                                           --DUMMY_32 : 32
--                        V_DUMMY_33                                      =>      NULL,                                           --DUMMY_33 : 33
--                        V_DUMMY_34                                      =>      NULL,                                           --DUMMY_34 : 34
--                        V_DUMMY_35                                      =>      NULL,                                           --DUMMY_35 : 35
--                        V_DUMMY_36                                      =>      NULL,                                           --DUMMY_36 : 36
--                        V_DUMMY_37                                      =>      NULL,                                           --DUMMY_37 : 37
--                        V_DUMMY_38                                      =>      NULL,                                           --DUMMY_38 : 38
--                        V_DUMMY_39                                      =>      NULL,                                           --DUMMY_39 : 39
--                        V_DUMMY_40                                      =>      NULL,                                           --DUMMY_40 : 40
--                        V_DUMMY_41                                      =>      NULL,                                           --DUMMY_41 : 41
--                        V_DUMMY_42                                      =>      NULL,                                           --DUMMY_42 : 42
--                        V_DUMMY_43                                      =>      NULL,                                           --DUMMY_43 : 43
--                        V_DUMMY_44                                      =>      NULL,                                           --DUMMY_44 : 44
--                        V_DUMMY_45                                      =>      NULL,                                           --DUMMY_45 : 45
--                        V_DUMMY_46                                      =>      NULL,                                           --DUMMY_46 : 46
--                        V_DUMMY_47                                      =>      NULL,                                           --DUMMY_47 : 47
--                        V_DUMMY_48                                      =>      NULL,                                           --DUMMY_48 : 48
--                        V_DUMMY_49                                      =>      NULL,                                           --DUMMY_49 : 49
--                        V_DUMMY_50                                      =>      NULL                                            --DUMMY_50 : 50
                                            --###################################### 공통 ####################################################
                                              'I'                             --    처방저장모드 I:INSERT , U:UPDATE
                                            , 'S'                             --    M : 진료사용시, S : 진료지원에서 사용시
                                            , 'N'                             --    진료에서는 수정시 무조건 DC 처리를 하지만 건증같은경우 UPDATE 목적의 PROCESS 도 있음
                                            , NULL                            --    처방ID
                                            , IN_PT_NO                        --    환자번호
                                            , TO_DATE(IN_ORD_DT, 'YYYYMMDD')  --    처방일자
                                            , HIS_HSP_TP_CD             --    병원구분코드
                                            , V_EXM_CD (I)              --    처방코드
                                            , T_ORD_NM                  --    처방명
                                            , 'C'                       --    처방중단구분코드

                                            , T_IN_DPCD_DECODED         --    처방표시분류코드
                                            , T_ORD_CTG_CD              --    처방분류코드
                                            , '1'                       --    처방적용목적코드
                                            , IN_PT_HME_DEPT_CD         --    발행처부서코드
                                            , T_MEDDEPT                 --    환자수진부서코드
                                            , 'LM'                      --    최초등록직원부서코드
                                            , 'N'                       --    추가처방여부
                                            , T_MEDDR                   --    주치의직원식별ID
                                            , 'L1'                      --    처방발생구분코드
                                            , NULL                      --    원처방구분코드

                                            , NULL                      --    원처방ID
                                            , NULL                      --    화면정렬순번
                                            , NULL                      --    물품번호
                                            , T_MIF_CD                  --    수가코드
                                            , NULL                      --    응급여부
                                            , NULL                      --    PRN처방여부
                                            , IN_MED_MIFI_TP_CD         --    진료수가보험구분코드
                                            , NULL                      --    임의비급여사유코드
                                            , NULL                      --    처방비고내용
                                            , NULL                      --    병동부서코드

                                            , NULL                      --    병실번호
                                            , IN_PACT_TP_CD             --    원무접수구분코드
                                            , NULL                      --    진료원무접수구분코드 [원무접수구분코드와 동일하게 입력한다.]
                                            , 'MILM000001'              --    원무접수ID
                                            , IN_PACT_TP_CD             --    수납원무접수구분코드
                                            , 'MILM000001'              --    수납원무접수ID
                                            , 1                         --    수납유형순번
                                            , NULL                      --    환자수납일자
                                            , ''                        --    수납상태코드
                                            , '01'                      --    병원내부구분코드

                                            , NULL                      --    실시간진료일자
                                            , NULL                      --    실시간진료의직원식별ID
                                            , NULL                      --    실시간진료의발령부서코드
                                            , NULL                      --    실시간진료의근무부서코드
                                            , NULL                      --    실시간발행일시
                                            , NULL                      --    실시간발행직원식별ID
                                            , NULL                      --    실시간발행자발령부서코드
                                            , NULL                      --    실시간발행자근무부서코드
                                            , NULL                      --    실시간수행일시
                                            , NULL                      --    실시간수행직원식별ID
                                            , NULL                      --    실시간수행자비용적용부서코드
                                            , NULL                      --    실시간수행자근무부서코드

                                            , NULL                      --    실시간사용장비코드
                                            , NULL                      --    실시간수행취소직원식별ID
                                            , NULL                      --    실시간수행취소일시
                                            , NULL                      --    실시간마감직원식별ID
                                            , NULL                      --    실시간마감일자
                                            , NULL                      --    실시간마감수행여부
                                            , NULL                      --    실시간PDA사용여부
                                            , NULL                      --    연구과제번호
                                            , '03'                      --    처방그룹코드
                                            , NULL                      --    CP적용ID

                                            , NULL                      --    CP일정순번
                                            , NULL                      --    CP변경사유순번
                                            , T_MAXSEQ                  --    환자CP처방순번
                                            , NULL                      --    서명키번호
                                            , NULL                      --    서명직원번호
                                            , NULL                      --    세트처방등록ID
                                            , NULL                      --    세트처방상세순번
                                            , NULL                      --    묶음정렬처방ID
                                            , NULL                      --    묶음정렬순번
                                            , NULL                      --    선택검사여부

                                            , NULL                      --    선택진료창구방문여부
                                            , NULL                      --    비선택여부
                                            , NULL                      --    진료용위임구분코드
                                            , NULL                      --    원무용위임구분코드
                                            , T_ORD_SLIP_CTG_CD         --    처방전표분류코드

                                            --###################################### 투약(MOOORDRM)  ####################################################
                                            , NULL                      --    약묶음처방순번
                                            , NULL                      --    약묶음주여부
                                            , NULL                      --    자가주사가능여부
                                            , NULL                      --    투여경로구분코드
                                            , NULL                      --    상세투여경로유형코드
                                            , NULL                      --    AST여부
                                            , NULL                      --    투여수량
                                            , NULL                      --    2번째투여수량
                                            , NULL                      --    3번째투여수량
                                            , NULL                      --    4번째투여수량
                                            , NULL                      --    5번째투여수량
                                            , NULL                      --    약품단위구분코드

                                            , NULL                      --    약품단위코드
                                            , NULL                      --    처방기간주기코드
                                            , NULL                      --    기본일수
                                            , NULL                      --    전체기간일수
                                            , NULL                      --    기간별횟수
                                            , NULL                      --    용법코드
                                            , NULL                      --    약혼합여부
                                            , NULL                      --    용법비고
                                            , NULL                      --    전체용량
                                            , NULL                      --    총량약품단위코드

                                            , NULL                      --    주사일정내용
                                            , NULL                      --    가루약여부
                                            , NULL                      --    개별포장여부
                                            , NULL                      --    투여위치구분코드
                                            , NULL                      --    유보항균제여부
                                            , NULL                      --    환자지참약여부
                                            , NULL                      --    제조회사코드
                                            , NULL                      --    원내처방가능여부
                                            , NULL                      --    원내처방사유코드
                                            , NULL                      --    원외처방유효기간

                                            , NULL                      --    익일처방여부
                                            , NULL                      --    투약처방보류상태코드
                                            , NULL                      --    보류신청직원번호
                                            , NULL                      --    PRN처방사유코드
                                            , NULL                      --    PRN처방기타사유상세내용
                                            , NULL                      --    TPN종류코드
                                            , NULL                      --    항생제분류임상코드
                                            , NULL                      --    추가항생제처방사유코드
                                            , NULL                      --    추가항생제처방사유기타내용
                                            , NULL                      --    약반납지시직원번호

                                            , NULL                      --    약반납지시일자
                                            , NULL                      --    처방생성일자
                                            , NULL                      --    투약처방상태코드
                                            , NULL                      --    약국조제일시
                                            , NULL                      --    투약번호
                                            , NULL                      --    투약번호구분코드
                                            , NULL                      --    약국투약문의여부
                                            , NULL                      --    약국투약문의내용
                                            , NULL                      --    약국마감회차
                                            , NULL                      --    혼합주체여부

                                            , NULL                      --    수행약국부서코드
                                            , NULL                      --    조제여부
                                            , NULL                      --    조제일시
                                            , NULL                      --    약제보류처리일시
                                            , NULL                      --    시행검사실구분코드
                                            , NULL                      --    간호응급접수대상여부
                                            , NULL                      --    간호보류처리일시
                                            , NULL                      --    혼합약묶음구분코드
                                            , NULL                      --    차수순번(MOOPTVPD)
                                            , NULL                      --    특별처방여부(MOOPTVPD)

                                            --###################################### 검사(MOOOREXM)   ####################################################
                                            , T_TH1_SPCM_CD             --    1번째검체코드
                                            , T_TH2_SPCM_CD             --    2번째검체코드
                                            , 'COLL'                    --    환자이동장소
                                            , NULL                      --    장비휴대가능여부
                                            , NULL                      --    디지털여부

                                            , NULL                      --    외부병원필름판독여부
                                            , 'N'                       --    상담여부
                                            , NULL                      --    정액대상여부
                                            , NULL                      --    주조영술여부
                                            , NULL                      --    CR검사여부
                                            , NULL                      --    항생제투여여부
                                            , 1                         --    검사횟수
                                            , T_WKGRP                   --    동시검사묶음순번
                                            , NULL                      --    임상소견내용

                                            , NULL                      --    채혈여부
                                            , NULL                      --    채혈일시
                                            , NULL                      --    채혈직원번호
                                            , NULL                      --    미채혈사유코드
                                            , NULL                      --    MRI소견서내용
                                            , 'X'                       --    검사진행상태코드
                                            , NULL                      --    예약일시
                                            , NULL                      --    예약처리직원식별ID

                                            , NULL                      --    접수일시
                                            , NULL                      --    검체병리번호
                                            , NULL                      --    검사실시일시
                                            , NULL                      --    보고일시
                                            , NULL                      --    보고직원번호
                                            , NULL                      --    진료지원CR검사여부
                                            , NULL                      --    진료지원디지털여부
                                            , NULL                      --    수행검사실번호
                                            , NULL                      --    검사의뢰서판독번호
                                            , NULL                      --    검사결과저장테이블명
                                            , 'Y'                       --    진단검사정도관리여부
                                            , TO_DATE(IN_ORD_DT, 'YYYYMMDD')--    검사희망일자
                                            , NULL                      --    희망검사실번호
                                            , NULL                      --    검사취소사유내용
                                            , NULL                      --    취소사유등록직원번호
                                            , NULL                      --    취소사유등록일자
                                            , NULL                      --    2번째판독의직원번호
                                            , NULL                      --    3번째판독의직원번호
                                            , NULL                      --    4번째판독의직원번호
                                            , NULL                      --    5번째판독의직원번호
                                            , NULL                      --    6번째판독의직원번호
                                            , NULL                      --    지역채혈의뢰서출력여부
                                            , NULL                      --    지역채혈의뢰서 출력일시
                                            , NULL                      --    지역채혈의뢰서 출력직원번호
                                            , NULL                      --    반복처방일자
                                            , NULL                      --    ABGA경로유형코드
                                            , NULL                      --    ABGA산소함유량명
                                            , NULL                      --    ABGAFIO2명
                                            , NULL                      --    ABGA일산화질소수량명
                                            , NULL                      --    검사선택의직원번호
                                            , NULL                      --    최초검사선택의직원번
                                            , NULL                      --    2번째검사선택의직원번호
                                            , NULL                      --    3번째검사선택의직원번호
                                            , NULL                      --    비예약검사원무접수ID
                                            , NULL                      --    비예약검사작업직원번호
                                            , NULL                      --    비예약검사작업일시
                                            , NULL                      --    비예약검사예약일수
                                            , NULL                      --    비예약검사예약시간단위코드
                                            , NULL                      --    비예약검사변경구분코
                                            , NULL                      --    비고내용
                                            , NULL                      --    진단검사채혈마감여부
                                            , NULL                      --    진단검사채혈마감직원번호
                                            , NULL                      --    진단검사채혈마감일시
                                            , NULL                      --    진단검사채혈마감여부
                                            , NULL                      --    치아코드내용
                                            --###################################### 수혈(MOOORTFM )   ####################################################
                                            , NULL                      --    긴급수혈구분코드
                                            , NULL                      --    임의비급여기타사유내용
                                            , NULL                      --    수혈제제분류코드
                                            , NULL                      --    적응증처방안내코드
                                            , NULL                      --    적응증처방기타내용
                                            , NULL                      --    수혈예정출고구분코드
                                            , NULL                      --    처방수량
                                            , NULL                      --    수혈예정소요시간내용
                                            , NULL                      --    수술용여부
                                            , NULL                      --    수술예정일자
                                            , NULL                      --    수술명
                                            , NULL                      --    수술코드
                                            , NULL                      --    방사선조사여부
                                            , NULL                      --    혈액은행반납수량
                                            , NULL                      --    혈액은행 반납지시일시
                                            , NULL                      --    혈액은행 반납환불여부
                                            , NULL                      --    반납지시직원번호
                                            , NULL                      --    혈액준비상태코드
                                            , NULL                      --    혈액은행출고수량
                                            , NULL                      --    혈액은행수혈준비완료일시
                                            , NULL                      --    간호수행횟수
                                            , NULL                      --    간호사처방변경 수량
                                            , NULL                      --    간호사처방수량변경직원번호
                                            , NULL                      --    간호사처방수량변경일시
                                            , NULL                      --    간호사수혈요청시간내용
                                            , NULL                      --    간호사 수혈요청시간변경직원번호
                                            , NULL                      --    간호사수혈요청시간변경일시
                                            , NULL                      --    간호사처방수량요청시변경직원번호
                                            , NULL                      --    간호사처방수량요청시간변경일시

                                            --###################################### 처치(MOOORTRM )  ####################################################
                                            , NULL                      --    치식ID
                                            , NULL                      --    처방횟수
                                            , NULL                      --    전과전등희망진료부서코드
                                            , NULL                      --    전과전등희망진료직원번호
                                            , NULL                      --    보조기제작상세내용
                                            , NULL                      --    식이별형태코드
                                            , NULL                      --    열량분류코드
                                            , NULL                      --    열량명
                                            , NULL                      --    염분분류코드
                                            , NULL                      --    분유분류코드
                                            , NULL                      --    분유1회수량코드
                                            , NULL                      --    진료기록ID
                                            , NULL                      --    진료기록개정순번
                                            , NULL                      --    ACS적응증분류코드
                                            , NULL                      --    ACS대상INR분류코드
                                            , NULL                      --    ACS예정기간코드
                                            , NULL                      --    ACS약사답변내용
                                            , NULL                      --    간호비고
                                            , NULL                      --    검사처치수행부서코드

                                            --###################################### 처방료(MOOORFED )  ####################################################
                                            , NULL                      --    응급가산여부
                                            , NULL                      --    심야가산적용여부
                                            , NULL                      --    선택의직원식별ID
                                            , NULL                      --    선택의명
                                            , NULL                      --    선택진료부서코드
                                            , NULL                      --    처치수량
                                            , NULL                      --    수행횟수
                                            , NULL                      --    약가환산처방재료단위코드
                                            , NULL                      --    낮병동식이끼니구분코드
                                            , NULL                      --    주수술여부
                                            , NULL                      --    재수술여부
                                            , NULL                      --    마취시작일시
                                            , NULL                      --    마취종료일시
                                            , NULL                      --    수행일자
                                            , NULL                      --    수술예정등록ID
                                            , NULL                      --    비보험사유코드
                                            , NULL                      --    비보험시점기타사유내용
                                            , NULL                      --    타과의뢰진료기록ID
                                            , NULL                      --    간호진술문ID
                                            , NULL                      --    선납구매요청여부
                                            , NULL                      --    연결수가발생구분코드
                                            , NULL                      --    연결처방일자
                                            , NULL                      --    연결처방ID
                                            , NULL                      --    연결처방코드
                                            , NULL                      --    재고일자
                                            , NULL                      --    검사치료실번호
                                            , NULL                      --    수행직원번호
                                            , NULL                      --    반납일자
                                            , NULL                      --    반납직원번호
                                            , NULL                      --    반납지시횟수
                                            , NULL                      --    반납수량
                                            , NULL                      --    처방료반납사유코드
                                            , NULL                      --    처방료반납비고내용
                                            , NULL                      --    상담의직원번호
                                            , NULL                      --    간호사확인구분코드
                                            , NULL                      --    환자현위치부서코드
                                            , NULL                      --    환자진료과부서코드
                                            , NULL                      --    작성자근무지부서코드
                                            , NULL                      --    촬영일자

                                            --###################################### 오픈 후 파라미터 추가 #################################################
                                            , NULL                      --    진료원무접수ID     - DUMMY_01 : 01
                                            , NULL                      --    최초처방ID         - DUMMY_02 : 02
                                            , NULL                      --    절개구분코드       - DUMMY_03 : 03
                                            , NULL                      --    디데이일수         - DUMMY_04 : 04
                                            , NULL                      --    디데이기간주기코드 - DUMMY_05 : 05
                                            , NULL                      --    실명제의사직원번호 - DUMMY_06 : 06
                                            , NULL                      --V_DUMMY_07                IN VARCHAR2     -- DUMMY_07 : 07
                                            , NULL                      --V_DUMMY_08                IN VARCHAR2     -- DUMMY_08 : 08
                                            , NULL                      --V_DUMMY_09                IN VARCHAR2     -- DUMMY_09 : 09
                                            , NULL                      --V_DUMMY_10                IN VARCHAR2     -- DUMMY_10 : 10
                                            , NULL                      --V_DUMMY_11                IN VARCHAR2     -- DUMMY_11 : 11
                                            , NULL                      --V_DUMMY_12                IN VARCHAR2     -- DUMMY_12 : 12
                                            , NULL                      --V_DUMMY_13                IN VARCHAR2     -- DUMMY_13 : 13
                                            , NULL                      --V_DUMMY_14                IN VARCHAR2     -- DUMMY_14 : 14
                                            , NULL                      --V_DUMMY_15                IN VARCHAR2     -- DUMMY_15 : 15
                                            , NULL                      --V_DUMMY_16                IN VARCHAR2     -- DUMMY_16 : 16
                                            , NULL                      --V_DUMMY_17                IN VARCHAR2     -- DUMMY_17 : 17
                                            , NULL                      --V_DUMMY_18                IN VARCHAR2     -- DUMMY_18 : 18
                                            , NULL                      --V_DUMMY_19                IN VARCHAR2     -- DUMMY_19 : 19
                                            , NULL                      --V_DUMMY_20                IN VARCHAR2     -- DUMMY_20 : 20
                                            , NULL                      --V_DUMMY_21                IN VARCHAR2     -- DUMMY_21 : 21
                                            , NULL                      --V_DUMMY_22                IN VARCHAR2     -- DUMMY_22 : 22
                                            , NULL                      --V_DUMMY_23                IN VARCHAR2     -- DUMMY_23 : 23
                                            , NULL                      --V_DUMMY_24                IN VARCHAR2     -- DUMMY_24 : 24
                                            , NULL                      --V_DUMMY_25                IN VARCHAR2     -- DUMMY_25 : 25
                                            , NULL                      --V_DUMMY_26                IN VARCHAR2     -- DUMMY_26 : 26
                                            , NULL                      --V_DUMMY_27                IN VARCHAR2     -- DUMMY_27 : 27
                                            , NULL                      --V_DUMMY_28                IN VARCHAR2     -- DUMMY_28 : 28
                                            , NULL                      --V_DUMMY_29                IN VARCHAR2     -- DUMMY_29 : 29
                                            , NULL                      --V_DUMMY_30                IN VARCHAR2     -- DUMMY_30 : 30
                                            , NULL                      --V_DUMMY_31                IN VARCHAR2     -- DUMMY_31 : 31
                                            , NULL                      --V_DUMMY_32                IN VARCHAR2     -- DUMMY_32 : 32
                                            , NULL                      --V_DUMMY_33                IN VARCHAR2     -- DUMMY_33 : 33
                                            , NULL                      --V_DUMMY_34                IN VARCHAR2     -- DUMMY_34 : 34
                                            , NULL                      --V_DUMMY_35                IN VARCHAR2     -- DUMMY_35 : 35
                                            , NULL                      --V_DUMMY_36                IN VARCHAR2     -- DUMMY_36 : 36
                                            , NULL                      --V_DUMMY_37                IN VARCHAR2     -- DUMMY_37 : 37
                                            , NULL                      --V_DUMMY_38                IN VARCHAR2     -- DUMMY_38 : 38
                                            , NULL                      --V_DUMMY_39                IN VARCHAR2     -- DUMMY_39 : 39
                                            , NULL                      --V_DUMMY_40                IN VARCHAR2     -- DUMMY_40 : 40
                                            , NULL                      --V_DUMMY_41                IN VARCHAR2     -- DUMMY_41 : 41
                                            , NULL                      --V_DUMMY_42                IN VARCHAR2     -- DUMMY_42 : 42
                                            , NULL                      --V_DUMMY_43                IN VARCHAR2     -- DUMMY_43 : 43
                                            , NULL                      --V_DUMMY_44                IN VARCHAR2     -- DUMMY_44 : 44
                                            , NULL                      --V_DUMMY_45                IN VARCHAR2     -- DUMMY_45 : 45
                                            , NULL                      --V_DUMMY_46                IN VARCHAR2     -- DUMMY_46 : 46
                                            , NULL                      --V_DUMMY_47                IN VARCHAR2     -- DUMMY_47 : 47
                                            , NULL                      --V_DUMMY_48                IN VARCHAR2     -- DUMMY_48 : 48
                                            , NULL                      --V_DUMMY_49                IN VARCHAR2     -- DUMMY_49 : 49
                                            , NULL                      --V_DUMMY_50                IN VARCHAR2     -- DUMMY_50 : 50
		                                    --########################### CBNUH 파라미터 추가 2020.05.25 반영 100개 컬럼 시작 #################
		                                    , NULL                             -- V_DUMMY_51                          -- DUMMY_51 : 51
		                                    , NULL                             -- V_DUMMY_52                          -- DUMMY_52 : 52
		                                    , NULL                             -- V_DUMMY_53                          -- DUMMY_53 : 53
		                                    , NULL                             -- V_DUMMY_54                          -- DUMMY_54 : 54
		                                    , NULL                             -- V_DUMMY_55                          -- DUMMY_55 : 55
		                                    , NULL                             -- V_DUMMY_56                          -- DUMMY_56 : 56
		                                    , NULL                             -- V_DUMMY_57                          -- DUMMY_57 : 57
		                                    , NULL                             -- V_DUMMY_58                          -- DUMMY_58 : 58
		                                    , NULL                             -- V_DUMMY_59                          -- DUMMY_59 : 59
		                                    , NULL                             -- V_DUMMY_60                          -- DUMMY_60 : 60
		                                    
		                                    , NULL                             -- V_DUMMY_61                          -- DUMMY_61 : 61
		                                    , NULL                             -- V_DUMMY_62                          -- DUMMY_62 : 62
		                                    , NULL                             -- V_DUMMY_63                          -- DUMMY_63 : 63
		                                    , NULL                             -- V_DUMMY_64                          -- DUMMY_64 : 64
		                                    , NULL                             -- V_DUMMY_65                          -- DUMMY_65 : 65
		                                    , NULL                             -- V_DUMMY_66                          -- DUMMY_66 : 66
		                                    , NULL                             -- V_DUMMY_67                          -- DUMMY_67 : 67
		                                    , NULL                             -- V_DUMMY_68                          -- DUMMY_68 : 68
		                                    , NULL                             -- V_DUMMY_69                          -- DUMMY_69 : 69
		                                    , NULL                             -- V_DUMMY_70                          -- DUMMY_70 : 70
		                                    
		                                    , NULL                             -- V_DUMMY_71                          -- DUMMY_71 : 71
		                                    , NULL                             -- V_DUMMY_72                          -- DUMMY_72 : 72
		                                    , NULL                             -- V_DUMMY_73                          -- DUMMY_73 : 73
		                                    , NULL                             -- V_DUMMY_74                          -- DUMMY_74 : 74
		                                    , NULL                             -- V_DUMMY_75                          -- DUMMY_75 : 75
		                                    , NULL                             -- V_DUMMY_76                          -- DUMMY_76 : 76
		                                    , NULL                             -- V_DUMMY_77                          -- DUMMY_77 : 77
		                                    , NULL                             -- V_DUMMY_78                          -- DUMMY_78 : 78
		                                    , NULL                             -- V_DUMMY_79                          -- DUMMY_79 : 79
		                                    , NULL                             -- V_DUMMY_80                          -- DUMMY_80 : 80
		                                    
		                                    , NULL                             -- V_DUMMY_81                          -- DUMMY_81 : 81
		                                    , NULL                             -- V_DUMMY_82                          -- DUMMY_82 : 82
		                                    , NULL                             -- V_DUMMY_83                          -- DUMMY_83 : 83
		                                    , NULL                             -- V_DUMMY_84                          -- DUMMY_84 : 84
		                                    , NULL                             -- V_DUMMY_85                          -- DUMMY_85 : 85
		                                    , NULL                             -- V_DUMMY_86                          -- DUMMY_86 : 86
		                                    , NULL                             -- V_DUMMY_87                          -- DUMMY_87 : 87
		                                    , NULL                             -- V_DUMMY_88                          -- DUMMY_88 : 88
		                                    , NULL                             -- V_DUMMY_89                          -- DUMMY_89 : 89
		                                    , NULL                             -- V_DUMMY_90                          -- DUMMY_90 : 90
		                                    
		                                    , NULL                             -- V_DUMMY_91                          -- DUMMY_91 : 91
		                                    , NULL                             -- V_DUMMY_92                          -- DUMMY_92 : 92
		                                    , NULL                             -- V_DUMMY_93                          -- DUMMY_93 : 93
		                                    , NULL                             -- V_DUMMY_94                          -- DUMMY_94 : 94
		                                    , NULL                             -- V_DUMMY_95                          -- DUMMY_95 : 95
		                                    , NULL                             -- V_DUMMY_96                          -- DUMMY_96 : 96
		                                    , NULL                             -- V_DUMMY_97                          -- DUMMY_97 : 97
		                                    , NULL                             -- V_DUMMY_98                          -- DUMMY_98 : 98
		                                    , NULL                             -- V_DUMMY_99                          -- DUMMY_99 : 99
		                                    , NULL                             -- V_DUMMY_100                          -- DUMMY_100 : 100
		                                    
		                                    , NULL                             -- V_DUMMY_101                          -- DUMMY_101 : 101
		                                    , NULL                             -- V_DUMMY_102                          -- DUMMY_102 : 102
		                                    , NULL                             -- V_DUMMY_103                          -- DUMMY_103 : 103
		                                    , NULL                             -- V_DUMMY_104                          -- DUMMY_104 : 104
		                                    , NULL                             -- V_DUMMY_105                          -- DUMMY_105 : 105
		                                    , NULL                             -- V_DUMMY_106                          -- DUMMY_106 : 106
		                                    , NULL                             -- V_DUMMY_107                          -- DUMMY_107 : 107
		                                    , NULL                             -- V_DUMMY_108                          -- DUMMY_108 : 108
		                                    , NULL                             -- V_DUMMY_109                          -- DUMMY_109 : 109
		                                    , NULL                             -- V_DUMMY_110                          -- DUMMY_110 : 110
		                                    
		                                    , NULL                             -- V_DUMMY_111                          -- DUMMY_111 : 111
		                                    , NULL                             -- V_DUMMY_112                          -- DUMMY_112 : 112
		                                    , NULL                             -- V_DUMMY_113                          -- DUMMY_113 : 113
		                                    , NULL                             -- V_DUMMY_114                          -- DUMMY_114 : 114
		                                    , NULL                             -- V_DUMMY_115                          -- DUMMY_115 : 115
		                                    , NULL                             -- V_DUMMY_116                          -- DUMMY_116 : 116
		                                    , NULL                             -- V_DUMMY_117                          -- DUMMY_117 : 117
		                                    , NULL                             -- V_DUMMY_118                          -- DUMMY_118 : 118
		                                    , NULL                             -- V_DUMMY_119                          -- DUMMY_119 : 119
		                                    , NULL                             -- V_DUMMY_120                          -- DUMMY_120 : 120
		                                    
		                                    , NULL                             -- V_DUMMY_121                          -- DUMMY_121 : 121
		                                    , NULL                             -- V_DUMMY_122                          -- DUMMY_122 : 122
		                                    , NULL                             -- V_DUMMY_123                          -- DUMMY_123 : 123
		                                    , NULL                             -- V_DUMMY_124                          -- DUMMY_124 : 124
		                                    , NULL                             -- V_DUMMY_125                          -- DUMMY_125 : 125
		                                    , NULL                             -- V_DUMMY_126                          -- DUMMY_126 : 126
		                                    , NULL                             -- V_DUMMY_127                          -- DUMMY_127 : 127
		                                    , NULL                             -- V_DUMMY_128                          -- DUMMY_128 : 128
		                                    , NULL                             -- V_DUMMY_129                          -- DUMMY_129 : 129
		                                    , NULL                             -- V_DUMMY_130                          -- DUMMY_130 : 130
		                                    
		                                    , NULL                             -- V_DUMMY_131                          -- DUMMY_131 : 131
		                                    , NULL                             -- V_DUMMY_132                          -- DUMMY_132 : 132
		                                    , NULL                             -- V_DUMMY_133                          -- DUMMY_133 : 133
		                                    , NULL                             -- V_DUMMY_134                          -- DUMMY_134 : 134
		                                    , NULL                             -- V_DUMMY_135                          -- DUMMY_135 : 135
		                                    , NULL                             -- V_DUMMY_136                          -- DUMMY_136 : 136
		                                    , NULL                             -- V_DUMMY_137                          -- DUMMY_137 : 137
		                                    , NULL                             -- V_DUMMY_138                          -- DUMMY_138 : 138
		                                    , NULL                             -- V_DUMMY_139                          -- DUMMY_139 : 139
		                                    , NULL                             -- V_DUMMY_140                          -- DUMMY_140 : 140
		                                    
		                                    , NULL                             -- V_DUMMY_141                          -- DUMMY_141 : 141
		                                    , NULL                             -- V_DUMMY_142                          -- DUMMY_142 : 142
		                                    , NULL                             -- V_DUMMY_143                          -- DUMMY_143 : 143
		                                    , NULL                             -- V_DUMMY_144                          -- DUMMY_144 : 144
		                                    , NULL                             -- V_DUMMY_145                          -- DUMMY_145 : 145
		                                    , NULL                             -- V_DUMMY_146                          -- DUMMY_146 : 146
		                                    , NULL                             -- V_DUMMY_147                          -- DUMMY_147 : 147
		                                    , NULL                             -- V_DUMMY_148                          -- DUMMY_148 : 148
		                                    , NULL                             -- V_DUMMY_149                          -- DUMMY_149 : 149
		                                    , NULL                             -- V_DUMMY_150                          -- DUMMY_150 : 150
		                                    --########################### CBNUH 파라미터 추가 2020.05.25 반영 100개 컬럼 끝  #################
                                            
                                            , HIS_STF_NO                --    등록, 변경자 ID
                                            , HIS_PRGM_NM               --    등록, 변경 프로그램명
                                            , HIS_IP_ADDR               --    등록 변경 IP ADDRESS
                                            , IO_ERR_YN                 --    에러여부
                                            , IO_ERR_MSG
                );

        EXCEPTION
            WHEN OTHERS THEN
                IO_ERR_YN:= 'Y';
                IO_ERR_MSG := 'PC_SAVEORDER {[ERRCD]: ' || TO_CHAR(SQLCODE) || '}-{[SQLERRM]: ' || SQLERRM || '}-{[IO_ERR_MSG]: ' || IO_ERR_MSG;
                RETURN;
        END;

        T_MAXSEQ := T_MAXSEQ + 1;
    END LOOP;

    IO_ORDER_CNT := TO_CHAR(V_CNT);

    FOR RECBLD IN ( SELECT /*+ PKG_MSE_LM_BLOOD.PC_MSE_INSERT_BLOOD_AUTO */
                            DISTINCT
                            B.EXRM_EXM_CTG_CD                                                    EXRM_EXM_CTG_CD
                          , A.TH1_SPCM_CD                                                       TH1_SPCM_CD
                          , TO_CHAR(A.EXM_HOPE_DT, 'YYYY-MM-DD')                                EXM_HOPE_DT
                          , A.HSP_TP_CD                                                         HSP_TP_CD
                          , NVL(A.PBSO_DEPT_CD, '-')                                            PBSO_DEPT_CD
                          , NVL(A.PT_HME_DEPT_CD, '-')                                          PT_HME_DEPT_CD
                          , TO_CHAR(A.ORD_DT, 'YYYY-MM-DD')                                     ORD_DT
                          , NVL(A.STM_EXM_BNDL_SEQ, '0')                                        STM_EXM_BNDL_SEQ
                          , DECODE(A.ODAPL_POP_CD,'3','3','9','9','7','7','1')                  ODAPL_POP_CD
                          , ''                                                                  REMK
                          , FT_MSE_VRE_CHK(A.ORD_RMK_CNTE, HIS_HSP_TP_CD )                      VRE_CHK
                          , B.EXRM_EXM_CTG_CD                                                      EXRM_EXM_CTG_CD_EXTRA
                          , NVL(A.EMRG_YN, 'N')                                                    EMRG_YN                    -- 응급여부 2017.09.19
                          , NVL(B.BRCD_CNTE, 'N')                                                BRCD_CNTE
                          , NVL(B.TLA_ORD_SND_FLAG_CNTE, 'N')                                    TLA_ORD_SND_FLAG_CNTE
                       FROM MOOOREXM A
                          , MSELMEBM B
--                          , CCOOCBAC C
                      WHERE A.PT_NO           = IN_PT_NO
                        AND A.ORD_DT          = TO_DATE(IN_ORD_DT, 'YYYYMMDD')
                        AND A.EXM_PRGR_STS_CD = 'X'
                        AND A.ODDSC_TP_CD     = 'C'
                        AND A.ORD_OCUR_TP_CD  = 'L1'
                        AND A.ORD_CTG_CD      = 'CP'
                        AND A.HSP_TP_CD       = HIS_HSP_TP_CD
                        AND A.PACT_TP_CD      = IN_PACT_TP_CD
                        AND B.EXM_CD          = A.ORD_CD
                        AND B.HSP_TP_CD       = A.HSP_TP_CD
--                        AND C.ORD_CD          = A.ORD_CD
--                        AND C.HSP_TP_CD       = A.HSP_TP_CD
                      GROUP BY A.ORD_DT
                             , A.EXM_HOPE_DT
                             , B.EXRM_EXM_CTG_CD
                             , A.TH1_SPCM_CD
                             , A.HSP_TP_CD
                             , A.PBSO_DEPT_CD
                             , A.PT_HME_DEPT_CD
                             , A.STM_EXM_BNDL_SEQ
                             , DECODE(A.ODAPL_POP_CD,'3','3','9','9','7','7','1')
                             , A.PT_NO
                             , A.ORD_RMK_CNTE
                             , A.EMRG_YN
                             , B.BRCD_CNTE
                                , B.TLA_ORD_SND_FLAG_CNTE
                    ORDER BY ORD_DT DESC
                           , TO_CHAR(A.EXM_HOPE_DT, 'YYYY-MM-DD') DESC
                           , TLA_ORD_SND_FLAG_CNTE
                           , EXRM_EXM_CTG_CD
                  )
    LOOP

        -- TLA, 부서, 응급여부 확인해서 처리
        IF (RECBLD.TLA_ORD_SND_FLAG_CNTE = 'TLA' AND T_DEPT_CD = RECBLD.PT_HME_DEPT_CD ) THEN
            V_TLA_SPCM_NO := T_TLA_SPCM_NO;
        ELSE
            V_TLA_SPCM_NO := 0;
        END IF;

        --검체번호 채번
        BEGIN
              PC_MSE_INS_QC_SAVEBLCL( IN_PT_NO
                                  , RECBLD.ORD_DT
                                  , RECBLD.EXRM_EXM_CTG_CD
                                  , RECBLD.EXRM_EXM_CTG_CD_EXTRA
                                  , RECBLD.TH1_SPCM_CD

                                  , RECBLD.STM_EXM_BNDL_SEQ
                                  , RECBLD.PBSO_DEPT_CD
                                  , RECBLD.PT_HME_DEPT_CD
                                  , RECBLD.EXM_HOPE_DT
                                  , IN_PACT_TP_CD

                                  , RECBLD.REMK
                                  , RECBLD.ODAPL_POP_CD
                                  , 'N'						-- 응급여부 2017.09.19
                                  , ''
                                  , HIS_STF_NO

                                  , '0'
                                  , IN_EQUP_CD
                                  , IN_MTR_CD
                                  , IN_LOT_NO
                                  , T_SPCNO

                                  , HIS_HSP_TP_CD
                                  , HIS_STF_NO
		                          , HIS_PRGM_NM
		                          , HIS_IP_ADDR
		                          , RECBLD.TLA_ORD_SND_FLAG_CNTE   			-- 2017.10.20 TLA 구분

		                          , V_TLA_SPCM_NO   						-- 2017.10.20 TLA 구분 검체번호 동일
		                          , RECBLD.BRCD_CNTE	    				-- 2017.10.30 바코드 구분
		                          , 'N'										-- 2017.12.05 채혈팀 채혈여부
		                          , ''--T_EXM_CD  -- 이상수 추가
                                  , IO_ERR_YN
                                  , IO_ERR_MSG );

            IF IO_ERR_YN = 'Y' THEN
               IO_ERR_YN  := 'Y';
               IO_ERR_MSG := '검체번호 생성함수 호출 시 에러 발생. ERRCD = ' || TO_CHAR(SQLCODE) || SQLERRM || ' ' || IO_ERR_MSG;
               RETURN;
            END IF;
        END;

        IF (RECBLD.TLA_ORD_SND_FLAG_CNTE = 'TLA' ) THEN
            V_TLA_SPCM_NO := T_SPCNO;
        ELSE
            V_TLA_SPCM_NO := '0';
        END IF;

        T_DEPT_CD := RECBLD.PT_HME_DEPT_CD;

        IF IO_SPCM_NO IS NULL THEN
            IO_SPCM_NO := T_SPCNO;
        ELSE
            IO_SPCM_NO := IO_SPCM_NO || ',' || T_SPCNO;
        END IF;

        BEGIN
            UPDATE MSELMCED
               SET LMQC_PT_YN   = 'Y'
                 , LOT_NO       = IN_LOT_NO
                 , LSH_DTM      = SYSDATE
                 , LSH_STF_NO   = HIS_STF_NO
                 , LSH_PRGM_NM  = HIS_PRGM_NM
                 , LSH_IP_ADDR  = HIS_IP_ADDR
             WHERE SPCM_NO      = T_SPCNO
               AND HSP_TP_CD   = HIS_HSP_TP_CD  -- 병원구분
              ;
        END;
    END LOOP;

END PC_MSE_INS_QC_SAVEORDER_BACKUP;