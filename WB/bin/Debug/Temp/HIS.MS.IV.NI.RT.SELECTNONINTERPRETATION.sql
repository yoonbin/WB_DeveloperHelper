<sql id="HIS.MS.IV.NI.RT.SELECTNONINTERPRETATION"><!--
    Clss :  text
    Desc : 미확인 조회
    Author : 이지케어텍 김세용
    Create date : 2012-03-27
    Update date : 2012-03-27 
                  2017-04-05 윤정식 수정 : 이대 병원 구분작업
                  2021-08-31 오원빈, MDAL_KND_CD , IPTN_RM_NM 값이 null이면 조회 안되는 문제 수정
                  2021-10-19 오원빈 , 모달리티,판독섹션 멀티체크 추가
                  2022-01-10 오원빈 , PACS_STATUS 추가 
-->
                 SELECT   /*HIS.MS.IV.NI.RT.SELECTNONINTERPRETATION*/ 
                        B.CD_NM                                             CD_NM
                      , TO_CHAR(A.PHTG_DTM, 'YYYY-MM-DD')                   PHTG_DTM
                      , A.PT_NO                                             PT_NO
                      , C.PT_NM                                             PT_NM
                      , TO_CHAR(C.PT_BRDY_DT, 'YYYY-MM-DD')                 PT_BRDY_DT
                      , A.MED_DEPT_CD                                       MED_DEPT_CD
                      , A.WD_DEPT_CD                                        WD_DEPT_CD
                      , A.EXRM_TP_CD                                        EXRM_TP_CD
                      , D.EXM_CHDR_STF_NO									EXM_CHDR_STF_NO
                      , XCOM.FT_CNL_SELSTFINFO('4',D.EXM_CHDR_STF_NO, D.HSP_TP_CD, NULL)    EXM_CHDR_STF_NM
                      , TO_CHAR(D.RSV_DTM,'YYYY-MM-DD HH24:MI') AS RSV_DTM
          			  , A.PACT_TP_CD
          			  , D.PACT_ID
			          /*
			          외래 : 해당처방의 검사실시일자를 기준으로 다음달 15일을 청구예정일자로 한다.
			          입원 : 해당처방을 입력 한 환자의 입원내역에서 퇴원일자를 가져온다.(퇴원하지 않은 환자는 청구예정일자를 표기 할 수 없음)
			                퇴원일자를 기준으로 다음달의 1일을 청구예정일자로 한다.
			           */
          			  , CASE A.PACT_TP_CD WHEN 'O' THEN TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(A.PHTG_DTM,'YYYY-MM') ,'YYYY-MM'),1) + 14,'YYYY-MM-DD')
                                          WHEN 'I' THEN (SELECT TO_CHAR(TO_DATE(TO_CHAR(ADD_MONTHS(DS_DTM,1),'YYYY-MM')||'-01','YYYY-MM-DD'),'YYYY-MM-DD')
                                                           FROM ACPPRAAM
                                                          WHERE HSP_TP_CD  = D.HSP_TP_CD
                                                            AND PACT_ID = D.PACT_ID
                                                            AND APCN_YN = 'N'
                                                            AND SIHS_YN = 'N'
                                                            AND DS_DTM IS NOT NULL
                                
                                                         )
                               			   END DMD_EXPT_DT      --청구예정일.
                      , D.ORD_CD
                      , CASE WHEN D.ORD_CTG_CD IN ('BR1','BN1','PDL','IMC','CHV','IMP','IMA','NR') THEN '2' ELSE '1' END CHDR_SEARCH_TYPE	--처방분류코드에 따라서 희망의사 목록을 조회.
                      , (SELECT DTRL1_NM FROM CCCCCSTE WHERE COMN_GRP_CD = '414' AND COMN_CD = A.EXM_PRGR_STS_CD) EXM_PRGR_STS_CD
                      , (SELECT READSTATUS
                      	  FROM(SELECT READSTATUS 
                      	  		 FROM HINF.MSERMINF_ORU 
                      	  		WHERE HISORDERID = FT_GET_PACS_HISORDERID(A.HSP_TP_CD,A.ORD_ID) 
                      	  		  AND PATID = A.PT_NO 
                      	  	 ORDER BY WORKTIME DESC)X
                      	  	 WHERE ROWNUM = 1) 		PACS_STATUS
                      	  	 
                      , D.ORD_ID
/*
                      , CASE A.PACT_TP_CD WHEN 'O' THEN (SELECT LISTAGG(MED_DEPT_CD||' : '|| TO_CHAR(MED_RSV_DTM,'YYYY-MM-DD HH24:MI'), chr(13)||chr(10)) WITHIN GROUP (ORDER BY MED_RSV_DTM)
													       FROM ACPPRODM
													      WHERE HSP_TP_CD = D.HSP_TP_CD
													        AND MED_DT > SYSDATE
													        AND PT_NO = D.PT_NO
													        AND APCN_DTM IS NULL
													        AND MEF_RPY_CLS_CD <> '1'  
													        AND MED_RSV_TP_CD NOT IN ('8','9','A','C','F','H')
													      )
					      END MED_RSV_INFO	--다음 진료일자
*/					      
                      , (SELECT LISTAGG(MED_DEPT_CD||' : '|| TO_CHAR(MED_RSV_DTM,'YYYY-MM-DD HH24:MI'), chr(13)||chr(10)) WITHIN GROUP (ORDER BY MED_RSV_DTM)
													       FROM ACPPRODM
													      WHERE HSP_TP_CD = D.HSP_TP_CD
													        AND MED_DT > SYSDATE
													        AND PT_NO = D.PT_NO
													        AND APCN_DTM IS NULL
													        AND MEF_RPY_CLS_CD <> '1'  
													        AND MED_RSV_TP_CD NOT IN ('8','9','A','C','F','H')
													      ) MED_RSV_INFO	--다음 진료일자
					      ,B.MDAL_KND_CD
					  --, B.IPTN_RM_NM
					  , (SELECT SECTION
                      	  FROM(SELECT SECTION
                      	  		 FROM HINF.MSERMINF_ORR
                      	  		WHERE HISORDERID = FT_GET_PACS_HISORDERID(A.HSP_TP_CD,A.ORD_ID) 
                      	  		  AND PATID = A.PT_NO 
                      	  	 ORDER BY WORKTIME DESC)X
                      	  	 WHERE ROWNUM = 1)   IPTN_RM_NM
					  , XBIL.FT_ACP_ACPPRAAM_AFTER_ACPPRODM('원외', D.PT_NO, SYSDATE, '' , D.HSP_TP_CD) AS NEXT_MED_RSV
                   FROM 
                        MSERMAAD A
                      , MSERMMMC B
                      , PCTPCPAM_DAMO C
                      , MOOOREXM D
                 WHERE A.PHTG_DTM BETWEEN TO_DATE(:PHTG_SDTM, 'YYYY-MM-DD') AND TO_DATE(:PHTG_EDTM, 'YYYY-MM-DD') + .99999
                    AND A.ORD_CTG_CD            = :ORD_CTG_CD
                    AND A.HSP_TP_CD             = :HIS_HSP_TP_CD
                    AND A.EXM_PRGR_STS_CD       IN ('E','D')
                    AND A.PACT_TP_CD            = decode(nvl(:PACT_TP_CD, 'A'), 'A', A.PACT_TP_CD, :PACT_TP_CD)
                    AND NVL(B.RSLT_NCS_YN, 'Y') = 'Y'
                    AND A.ORD_CD                = B.EXM_CD
                    AND A.HSP_TP_CD             = B.HSP_TP_CD
                    AND A.PT_NO                 = C.PT_NO
                    AND D.HSP_TP_CD				= A.HSP_TP_CD
                    AND D.ORD_ID				= A.ORD_ID
                    AND D.ODDSC_TP_CD		    = 'C'
                    AND (:EXM_CHDR_STF_NO IS NULL OR D.EXM_CHDR_STF_NO LIKE NVL(:EXM_CHDR_STF_NO,'') || '%')
                    AND D.PT_NO LIKE :PT_NO || '%'
/*                    AND B.MDAL_KND_CD = NVL(:EXM_GRP_DTL_CD, B.MDAL_KND_CD)*/
/*                    AND B.IPTN_RM_NM = NVL(:IPTN_RM_NM, B.IPTN_RM_NM)*/
<IsEqual Prepend="" Property="EXM_GRP_DTL_CD" CompareValue="">
                    AND ((NVL(B.MDAL_KND_CD,'*') = NVL(:EXM_GRP_DTL_CD, '*')) or (B.MDAL_KND_CD = NVL(:EXM_GRP_DTL_CD, B.MDAL_KND_CD)))
</IsEqual><IsEqual Prepend="" Property="IPTN_RM_NM" CompareValue="">                    
                    AND ((NVL(B.IPTN_RM_NM,'*') = NVL(:IPTN_RM_NM, '*')) or (B.IPTN_RM_NM = NVL(:IPTN_RM_NM, B.IPTN_RM_NM)))
</IsEqual><IsNotEqual Prepend="" Property="EXM_GRP_DTL_CD" CompareValue="">
                    AND B.MDAL_KND_CD IN  (select TRIM(REGEXP_SUBSTR(:EXM_GRP_DTL_CD,'[^'||','||']+',1,LEVEL)) AS MDAL_KND_CD
													from dual
													CONNECT BY INSTR(:EXM_GRP_DTL_CD,',',1,LEVEL-1)>0
												)
</IsNotEqual><IsNotEqual Prepend="" Property="IPTN_RM_NM" CompareValue="">												
					AND B.IPTN_RM_NM  IN (select TRIM(REGEXP_SUBSTR(:IPTN_RM_NM,'[^'||','||']+',1,LEVEL)) AS MDAL_KND_CD
													from dual
													CONNECT BY INSTR(:IPTN_RM_NM,',',1,LEVEL-1)>0
												)
</IsNotEqual>
                    
               ORDER BY CASE WHEN D.ORD_CTG_CD = 'BN1' THEN XBIL.FT_ACP_ACPPRAAM_AFTER_ACPPRODM('원외', D.PT_NO, SYSDATE, '' , D.HSP_TP_CD)   END ASC 

 </sql>