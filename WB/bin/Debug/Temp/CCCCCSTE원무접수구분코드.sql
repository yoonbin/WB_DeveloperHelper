SELECT '' HSP_TP_CD                               /*병원구분코드*/
     , COMN_GRP_CD                                /*공통그룹코드*/
     , COMN_CD                                    /*공통코드*/
     , COMN_CD_NM                                 /*공통코드명*/
     , COMN_CD_EXPL                               /*공통코드설명*/
     , NVL(SCRN_MRK_SEQ, 999) SCRN_MRK_SEQ        /*화면표시순번*/
     , USE_YN                                     /*사용여부*/
     , DTRL1_NM                                   /*1번째업무규칙명*/
     , DTRL2_NM                                   /*2번째업무규칙명*/
     , DTRL3_NM                                   /*3번째업무규칙명*/
     , DTRL4_NM                                   /*4번째업무규칙명*/
     , DTRL5_NM                                   /*5번째업무규칙명*/
     , DTRL6_NM                                   /*6번째업무규칙명*/
     , NEXTG_FMR_COMN_CD                          /**/
  FROM CCCCCSTE
 WHERE 1=1
   AND COMN_GRP_CD = 'PA054'
UNION ALL

SELECT HSP_TP_CD                                  /*병원구분코드*/
     , COMN_GRP_CD                                /*공통그룹코드*/
     , COMN_CD                                    /*공통코드*/
     , COMN_CD_NM                                 /*공통코드명*/
     , COMN_CD_EXPL                               /*공통코드설명*/
     , NVL(SCRN_MRK_SEQ, 999) SCRN_MRK_SEQ        /*화면표시순번*/
     , USE_YN                                     /*사용여부*/
     , DTRL1_NM                                   /*1번째업무규칙명*/
     , DTRL2_NM                                   /*2번째업무규칙명*/
     , DTRL3_NM                                   /*3번째업무규칙명*/
     , DTRL4_NM                                   /*4번째업무규칙명*/
     , DTRL5_NM                                   /*5번째업무규칙명*/
     , DTRL6_NM                                   /*6번째업무규칙명*/
     , NEXTG_FMR_COMN_CD                          /**/
  FROM CCCMCSTE
 WHERE 1=1
   AND COMN_GRP_CD = 'PA054'
 ORDER BY SCRN_MRK_SEQ, COMN_CD_NM
;