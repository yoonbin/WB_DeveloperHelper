<sql id="HIS.MS.TR.RE.ST.SelectYearlyTherapyCountExm">
<!--
    Clss :  Text
    Desc :  연보보고용처방수통계조회(전남대전용-검사)
    Author : OWB
    Create date : 2022-12-09
    Update date : 2022-12-09
-->
WITH DATALIST AS
(
 SELECT /*+ LEADING(A B C O P) */
        A.HSP_TP_CD                                                                         HSP_TP_CD
      , C.TH1_ASST_GRP_NM                                                                   GUBN
      , A.ORD_CD                                                                            ORD_CD
      , A.PACT_TP_CD                                                                        PACT_TP_CD
      , TO_CHAR(A.PHTG_DTM, 'MM')                                                        ORD_DT
      , XBIL.FT_PCT_AGE( 'AGE', A.PHTG_DTM, P.PT_BRDY_DT)                                AGES
      , COUNT(*)                                                                            CNT

   FROM MSERMAAD A
      , MSERMCCC B
      , MSERMCCC C
      , MOOOREXM O
      , PCTPCPAM_DAMO P
  WHERE 1=1
 AND A.HSP_TP_CD          = :HIS_HSP_TP_CD
 AND A.HSP_TP_CD          = O.HSP_TP_CD
 AND A.ORD_ID             = O.ORD_ID 
 AND A.PHTG_DTM BETWEEN  TO_DATE(:TO_DT || '0101', 'YYYYMMDD')
                       AND TO_DATE(:TO_DT || '1231', 'YYYYMMDD') + .99999
 AND A.ORD_CTG_CD = 'RH'
 AND A.ORD_CD             = B.EXM_GRP_DTL_CD
 AND O.ODDSC_TP_CD        = 'C'
 AND O.EXM_RTN_REQ_DTM IS NULL
 AND NVL(O.PRN_ORD_YN,'N') = 'N'
 AND A.EXM_PRGR_STS_CD NOT IN ('C','F')

 AND B.HSP_TP_CD          = A.HSP_TP_CD
 AND B.ORD_CTG_CD         = 'RH'
 AND B.EXM_GRP_CD         IN ('RH_EXM_CD_1', 'RH_EXM_CD_2') -- RH_EXM_CD_1, RH_EXM_CD_2, RH_TRTM_CD_1, RH_TRTM_CD_2

 AND C.HSP_TP_CD          = A.HSP_TP_CD
 AND C.ORD_CTG_CD         = 'RH'
 AND C.EXM_GRP_CD         = '0'
 AND C.EXM_GRP_DTL_CD     = B.EXM_GRP_CD                      -- 물리치료, 재활치료

 AND A.PT_NO = P.PT_NO

  GROUP BY A.HSP_TP_CD, C.TH1_ASST_GRP_NM, A.ORD_CD, A.PACT_TP_CD
         , TO_CHAR(A.PHTG_DTM, 'MM')
         , XBIL.FT_PCT_AGE( 'AGE', A.PHTG_DTM, P.PT_BRDY_DT)
)

SELECT A.HSP_TP_CD                           HSP_TP_CD
     , A.GUBN                                GUBUN
     , A.PACT_TP_CD                          PACT_TP_CD
     , (SELECT COMN_CD_NM FROM CCCCCSTE WHERE COMN_GRP_CD = 'PA054' AND COMN_CD = A.PACT_TP_CD) PACT_TP_NM
     , TO_CHAR(SUM(DECODE(ORD_DT, '01', A.CNT, 0)))   MON01
     , TO_CHAR(SUM(DECODE(ORD_DT, '02', A.CNT, 0)))   MON02
     , TO_CHAR(SUM(DECODE(ORD_DT, '03', A.CNT, 0)))   MON03
     , TO_CHAR(SUM(DECODE(ORD_DT, '04', A.CNT, 0)))   MON04
     , TO_CHAR(SUM(DECODE(ORD_DT, '05', A.CNT, 0)))   MON05
     , TO_CHAR(SUM(DECODE(ORD_DT, '06', A.CNT, 0)))   MON06
     , TO_CHAR(SUM(DECODE(ORD_DT, '07', A.CNT, 0)))   MON07
     , TO_CHAR(SUM(DECODE(ORD_DT, '08', A.CNT, 0)))   MON08
     , TO_CHAR(SUM(DECODE(ORD_DT, '09', A.CNT, 0)))   MON09
     , TO_CHAR(SUM(DECODE(ORD_DT, '10', A.CNT, 0)))   MON10
     , TO_CHAR(SUM(DECODE(ORD_DT, '11', A.CNT, 0)))   MON11
     , TO_CHAR(SUM(DECODE(ORD_DT, '12', A.CNT, 0)))   MON12
     , TO_CHAR(SUM(A.CNT))                            SUMCNT
  FROM DATALIST A
 WHERE 1=1
   AND ( (:EXEC_GUBN = '*')
         OR
         (:EXEC_GUBN = '2' AND AGES <  17 )
         OR
         (:EXEC_GUBN = '1' AND AGES >= 17 )
       )
 GROUP BY A.HSP_TP_CD, A.GUBN, A.PACT_TP_CD
ORDER BY GUBUN,PACT_TP_CD
</sql>