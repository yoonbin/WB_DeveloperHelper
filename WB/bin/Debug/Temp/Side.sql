FUNCTION      FT_GET_SIDE_EXM	    ( IN_HSP_TP_CD         IN VARCHAR2
                                     , IN_ORD_ID           IN VARCHAR2	
                                     , IN_PT_NO		       IN VARCHAR2  
                                     , IN_ORD_SLIP_CTG_CD  IN VARCHAR2   --처방분류 : RC(CT), RM(MRI)
                                     , IN_FLAG		       IN VARCHAR2)  --검사코드 = EXM_CD , 검사일 = EXM_DT      
    RETURN VARCHAR2
    /**********************************************************************
    작 성 자 : 오원빈 
    작 성 일 : 2021-10-05
    내    용 : 조영제를 사용한 검사의 최근 검사명과 검사일을 리턴함.
               
    수정이력 : 
    **********************************************************************/        
IS
    R_VALUE                VARCHAR2(100) :='';                    --RETURN 값
    R_ORD_CD			MOOOREXM.ORD_CD%TYPE := '';
    R_FMT_DTM			MOOOREXM.RTM_FMT_DTM%TYPE := '';
BEGIN 
    BEGIN                                               
		--검사
		SELECT ORD_CD
		      ,RTM_FMT_DTM
		  INTO R_ORD_CD
		      ,R_FMT_DTM
		  FROM
			(
			SELECT RTM_FMT_DTM,ORD_CD
				FROM MOOOREXM A
				WHERE HSP_TP_CD = '01'
				AND EXISTS(
							SELECT 1 	--묶인 재료목록
								FROM MSERMAMD X
							 WHERE HSP_TP_CD = A.HSP_TP_CD
							   AND ORD_ID = A.ORD_ID
							   AND RPY_USE_QTY > 0
							   AND EXISTS( SELECT 1         --조영제 목록
							                 FROM MSERMMJD Y
							                WHERE Y.HSP_TP_CD = X.HSP_TP_CD
							                  AND Y.CNMD_INF_TP_CD = 'A'
							                  AND Y.CNMD_INF_CD = X.SGL_MIF_CD
							             )
						  )
				AND EXM_PRGR_STS_CD IN ('E','D','N')
				AND PT_NO = IN_PT_NO
				AND EXISTS(SELECT 1
							 FROM MSERMMMC X
							     ,CCOOCCSC Y
				            WHERE X.HSP_TP_CD = A.HSP_TP_CD
				              AND X.HSP_TP_CD = Y.HSP_TP_CD
				              AND X.EXM_CD  = A.ORD_CD
				              AND X.ORD_SLIP_CTG_CD = Y.ORD_SLIP_CTG_CD
				              AND Y.UPR_ORD_SLIP_CTG_CD = IN_ORD_SLIP_CTG_CD)	--처방슬립 
				ORDER BY A.RTM_FMT_DTM DESC
			)A
		WHERE 1=1
		  AND ROWNUM = 1
		  ;
	EXCEPTION
		WHEN OTHERS THEN
			R_ORD_CD := '';
			R_FMT_DTM := '';    	   
	END;

	IF IN_FLAG = 'EXM_CD' THEN
		R_VALUE := R_ORD_CD;
	ELSIF IN_FLAG = 'EXM_DT' THEN
		R_VALUE := R_FMT_DTM;
	END IF;
	
	RETURN R_VALUE;
   
END;