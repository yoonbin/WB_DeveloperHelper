﻿SELECT A.*
  FROM MSERMAAD A --환자별검사정보
 WHERE 1=1
   AND HSP_TP_CD = '01'
   AND ROWNUM < 100
;