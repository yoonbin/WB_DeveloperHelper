EXEC :IN_ROLE_CD := 'R0037';


INSERT INTO HEAM.EMUSRBUT
 SELECT '04' HSP_TP_CD
      , STF_NO WK_ID
      , (SELECT BUSINESS_TYP
           FROM EMBUROLT
           WHERE ROLE_CD = :IN_ROLE_CD
             AND HSP_TP_CD = '04'
        ) BUSINESS_TYP
      , :IN_ROLE_CD
      , '' START_DT
      , '' END_DT
      , '' EDIT_ID
      , ''EDIT_DT
      ,'' ROLE_AUTH_DOC_NM                                   /*Role permission document name*/
      ,'' ROLE_AUTH_RSN_CNTE                                 /*Role permission reason content*/
  FROM CNLRRUSD B
 WHERE RTRM_DT IS NULL -- 재직자 중
   AND HSP_TP_CD = '04'
 and ((aadp_cd = 'OMR') OR (AOA_WKDP_CD = 'OMR'))
--   AND USE_GRP_CD = 'DO' -- 의사가 아닌
   and not exists(select 1 from heam.emusrbut where wk_id = b.stf_no and role_Cd = :IN_ROLE_CD and hsp_TP_Cd = b.hsp_TP_Cd)
--   and stf_no in( 'PH00349', 'PH00235','PH00343')
-- and ((aadp_cd = 'DR') OR (AOA_WKDP_CD = 'DR'))
-- and stf_no <> 'ND00505'
;
select *
 FROM CNLRRUSD B
 WHERE RTRM_DT IS NULL -- 재직자 중
   AND HSP_TP_CD = '04'
 and ((aadp_cd = 'OMR') OR (AOA_WKDP_CD = 'OMR'))
;
SELECT A.*
  FROM EMUSRBUT A -- [EAM] 부서별 업무권한 정의
 WHERE 1=1
and hsp_TP_CD ='04'
and role_Cd = :IN_ROLE_CD
and wk_Id = 'DN00082'
;