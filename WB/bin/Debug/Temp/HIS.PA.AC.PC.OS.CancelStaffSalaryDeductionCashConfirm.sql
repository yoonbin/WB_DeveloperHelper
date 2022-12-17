<sql id="HIS.PA.AC.PC.OS.CancelStaffSalaryDeductionCashConfirm">
<!--                                                                                                                                                         
    Clss : text                                                                                                                                              
    Desc : 직원급여공제내역 현금영수증승인내역 승인취소                                                        
    Author : 김한울                                                                                                                          
    Create date : 2018-07-30                                                                                                                               
    Update date :                                                                                                                             
-->                                                                                                                                                          
UPDATE /*HIS.PA.AC.PC.OS.CancelStaffSalaryDeductionCashConfirm*/
       ACPPSTRD A
   SET A.UNCL_SCLS_CD = '6'   -- 승인: 1, 원상태: 6
     , A.CRCP_CTRA_CD = null
     , A.CRCP_NO      = null
     , A.CASH_APBT_NO = null
     , A.APBT_DTM     = null
     , A.CRCP_WK_STF_NO = :HIS_STF_NO --현금영수증 승인취소 직원사번추가 2018-07-31
     , A.LSH_STF_NO   = :HIS_STF_NO
     , A.LSH_DTM      = :HIS_LSH_DTM
     , A.LSH_PRGM_NM  = :HIS_PRGM_NM
     , A.LSH_IP_ADDR  = :HIS_IP_ADDR     
 WHERE A.HSP_TP_CD = :HIS_HSP_TP_CD
   AND A.UNCL_SEQ  = :IN_UNCL_SEQ
   AND A.RPY_SEQ   = :IN_RPY_SEQ      
   AND A.UNCL_LCLS_CD = '3'

</sql> 