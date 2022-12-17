<sql id="HIS.MS.IV.NI.RT.SelectNonInterPretationRsv"><!--
    Clss :  text
    Desc : 미판독 조회 (진료예약일 기준으로 조회)
    Author : 이지케어텍 오원빈
    Create date : 2021-11-05
    Update date : 2022-01-10 오원빈, PACS상태 추가 
-->
SELECT /*HIS.MS.IV.NI.RT.SelectNonInterPretationRsv*/
			 CD_NM
			,PHTG_DTM
			,PT_NO
			,PT_NM
			,PT_BRDY_DT
			,MED_DEPT_CD
			,WD_DEPT_CD
			,EXRM_TP_CD
			,EXM_CHDR_STF_NO
			,EXM_CHDR_STF_NM
			,RSV_DTM
			,PACT_TP_CD
			,PACT_ID
			,DMD_EXPT_DT
			,ORD_CD
			,CHDR_SEARCH_TYPE
			,(SELECT DTRL1_NM FROM CCCCCSTE WHERE COMN_GRP_CD = '414' AND COMN_CD = EXM_PRGR_STS_CD) EXM_PRGR_STS_CD
			, PACS_STATUS --M:매칭, L:임시판독, C: 확정판독
			,ORD_ID
			,MED_RSV_INFO
			,MDAL_KND_CD
			,IPTN_RM_NM
			,TO_CHAR(NEXT_MED_RSV,'YYYY-MM-DD HH24:MI') 	NEXT_MED_RSV
  FROM
	(SELECT /*+ leading(a c) */  E.CD_NM                                             CD_NM
				, TO_CHAR(D.PHTG_DTM, 'YYYY-MM-DD')                   PHTG_DTM
				, C.PT_NO                                             PT_NO
				, B.PT_NM                                             PT_NM
				, TO_CHAR(B.PT_BRDY_DT, 'YYYY-MM-DD')                 PT_BRDY_DT
				, D.MED_DEPT_CD                                       MED_DEPT_CD
				, C.WD_DEPT_CD                                        WD_DEPT_CD
				, E.EXRM_TP_CD                                        EXRM_TP_CD
				, C.EXM_CHDR_STF_NO									EXM_CHDR_STF_NO
				, XCOM.FT_CNL_SELSTFINFO('4',C.EXM_CHDR_STF_NO, C.HSP_TP_CD, NULL)    EXM_CHDR_STF_NM
				, TO_CHAR(C.RSV_DTM,'YYYY-MM-DD HH24:MI') AS RSV_DTM
				, C.PACT_TP_CD
				, C.PACT_ID
				/*
				외래 : 해당처방의 검사실시일자를 기준으로 다음달 15일을 청구예정일자로 한다.
				입원 : 해당처방을 입력 한 환자의 입원내역에서 퇴원일자를 가져온다.(퇴원하지 않은 환자는 청구예정일자를 표기 할 수 없음)
				퇴원일자를 기준으로 다음달의 1일을 청구예정일자로 한다.
				*/
				, CASE C.PACT_TP_CD WHEN 'O' THEN TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(D.PHTG_DTM,'YYYY-MM') ,'YYYY-MM'),1) + 14,'YYYY-MM-DD')
				        						WHEN 'I' THEN (SELECT TO_CHAR(TO_DATE(TO_CHAR(ADD_MONTHS(DS_DTM,1),'YYYY-MM')||'-01','YYYY-MM-DD'),'YYYY-MM-DD')
										                         FROM ACPPRAAM
										                        WHERE HSP_TP_CD  = C.HSP_TP_CD
										                          AND PACT_ID = C.PACT_ID
										                          AND APCN_YN = 'N'
										                          AND SIHS_YN = 'N'
										                          AND DS_DTM IS NOT NULL
										                       )
				   END DMD_EXPT_DT      --청구예정일.
				, C.ORD_CD
				, CASE WHEN C.ORD_CTG_CD IN ('BR1','BN1','PDL','IMC','CHV','IMP','IMA','NR') THEN '2' ELSE '1' END CHDR_SEARCH_TYPE	--처방분류코드에 따라서 희망의사 목록을 조회.
				, C.EXM_PRGR_STS_CD
                , (SELECT READSTATUS
                     FROM(SELECT READSTATUS 
                      	    FROM HINF.MSERMINF_ORU 
                      	   WHERE HISORDERID = FT_GET_PACS_HISORDERID(C.HSP_TP_CD,C.ORD_ID) 
                      	  	 AND PATID = C.PT_NO 
                      	ORDER BY WORKTIME DESC)X
                     WHERE ROWNUM = 1) 		PACS_STATUS
				, C.ORD_ID
				, (SELECT LISTAGG(MED_DEPT_CD||' : '|| TO_CHAR(MED_RSV_DTM,'YYYY-MM-DD HH24:MI'), CHR(13)||CHR(10)) WITHIN GROUP (ORDER BY MED_RSV_DTM)
						 FROM ACPPRODM
						WHERE HSP_TP_CD = C.HSP_TP_CD
							AND MED_DT > SYSDATE
							AND PT_NO = C.PT_NO
							AND APCN_DTM IS NULL
							AND MEF_RPY_CLS_CD <> '1'
							AND MED_RSV_TP_CD NOT IN ('8','9','A','C','F','H')
						) MED_RSV_INFO	--다음 진료일자
				, E.MDAL_KND_CD
				--, E.IPTN_RM_NM
				, (SELECT SECTION
                      	  FROM(SELECT SECTION
                      	  		 FROM HINF.MSERMINF_ORR
                      	  		WHERE HISORDERID = FT_GET_PACS_HISORDERID(D.HSP_TP_CD,D.ORD_ID) 
                      	  		  AND PATID = D.PT_NO 
                      	  	 ORDER BY WORKTIME DESC)X
                      	  	 WHERE ROWNUM = 1)   IPTN_RM_NM
				, A.MED_RSV_DTM 	NEXT_MED_RSV
		FROM (SELECT HSP_TP_CD
		 		    ,MED_RSV_DTM
		   	        ,PT_NO
		        FROM ACPPRODM X
		       WHERE   1=1
			     AND X.MED_RSV_DTM IS NOT NULL
			     AND  TRUNC(X.MED_DT)  >  SYSDATE
			     AND  X.APCN_DTM IS NULL
			     AND  X.MEF_RPY_CLS_CD <> '1'
			     AND  X.HSP_TP_CD   = :HIS_HSP_TP_CD
			     AND  X.MED_RSV_TP_CD NOT IN ('8','9','A','C','F','H')           -- 2017-10-19 박성진 'F','H' 추가
			     AND  X.APCN_YN = 'N'
			    ) A
		    ,PCTPCPAM_DAMO	B
		    ,(SELECT *
		        FROM MOOOREXM
		        WHERE HSP_TP_CD = :HIS_HSP_TP_CD
		          AND ODDSC_TP_CD = 'C'
		          AND EXM_PRGR_STS_CD IN ('E','D')
		        ) C
		    ,MSERMAAD D
		    ,MSERMMMC E
		WHERE 1=1
			AND A.MED_RSV_DTM BETWEEN TO_DATE(:PHTG_SDTM, 'YYYY-MM-DD') AND TO_DATE(:PHTG_EDTM, 'YYYY-MM-DD') + .99999
			AND A.PT_NO = B.PT_NO
			AND A.PT_NO = C.PT_NO
			AND A.PT_NO = D.PT_NO
			AND A.HSP_TP_CD = C.HSP_TP_CD
			AND A.HSP_TP_CD = D.HSP_TP_CD
			AND A.HSP_TP_CD = E.HSP_TP_CD
			AND D.ORD_CTG_CD = :ORD_CTG_CD
			AND D.ORD_CTG_CD = C.ORD_CTG_CD
			AND D.ORD_CTG_CD = E.ORD_CTG_CD
			AND C.EXM_PRGR_STS_CD = D.EXM_PRGR_STS_CD
			AND (:EXM_CHDR_STF_NO IS NULL OR C.EXM_CHDR_STF_NO LIKE NVL(:EXM_CHDR_STF_NO,'') || '%')
			AND C.PT_NO LIKE :PT_NO || '%'
			AND C.ORD_ID = D.ORD_ID
			AND C.ORD_CD = E.EXM_CD			
			AND E.ORD_SLIP_CTG_CD <> 'MIG'
			AND NVL(:EXM_GRP_DTL_CD,'1') = NVL(:EXM_GRP_DTL_CD,'1')
<IsEqual Prepend="" Property="EXM_GRP_DTL_CD" CompareValue="">
			AND NVL(E.MDAL_KND_CD,'*') = NVL(E.MDAL_KND_CD,'*') 
</IsEqual><IsNotEqual Prepend="" Property="EXM_GRP_DTL_CD" CompareValue="">		
		    AND NVL(E.MDAL_KND_CD,'*') IN( SELECT TRIM(REGEXP_SUBSTR(:EXM_GRP_DTL_CD,'[^,]+',1,LEVEL)) AS MDAL
		    																 FROM DUAL
		    																 CONNECT BY INSTR(:EXM_GRP_DTL_CD,',',1,LEVEL-1)>0
		    																 )
</IsNotEqual>		    																 
		    AND ((NVL(E.IPTN_RM_NM,'*') = NVL(:IPTN_RM_NM, '*')) or (E.IPTN_RM_NM = NVL(:IPTN_RM_NM, E.IPTN_RM_NM)))
	 )A
  WHERE 1=1
  AND A.NEXT_MED_RSV =  TO_DATE(XBIL.FT_ACP_ACPPRAAM_AFTER_ACPPRODM('원외', A.PT_NO, SYSDATE, '' , :HIS_HSP_TP_CD),'YYYY-MM-DD HH24:MI')
</sql>