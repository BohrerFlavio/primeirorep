#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF40     ºAutor  ³Giuliano Forgiarini º Data ³  07/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consultas de posição de estoque                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaoms - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF40()
	aObjects := {}                                                                 
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX    :=aPosObj[1]                                                            
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	Private cPerg     := "GJF40"
	Private _nTotCaix := 0
	Private _nTotPes  := 0.00
	Private _nTotEmp  := 0.00 

	if !pergunte(cPerg,.t.)
		return
	endif

	Processa({||u_PrGJF40()},"CONSULTA DE ESTOQUE DE PA","Gerando arquivo de trabalho...")

return

User Function PrGJF40
	Private cString := "SB1"
	dbSelectArea(cString)       
	dbselectarea('SB1')
	SB1->(dbSetOrder(1))
	SB1->(dbgotop())

	If MV_PAR01 == 1
		_fArm:= 'R'
	ElseIf MV_PAR01 == 2
		_fArm:= 'C'
	ElseIf MV_PAR01 == 3
		_fArm:= 'S'
	Else
		_fArm:= ''
	EndIf

	If MV_PAR02 == 1
		_codOri:= "'D'"
	ElseIf MV_PAR02 == 2
		_codOri:= "'T'"
	ElseIf MV_PAR02 == 3
		_codOri:= "'C'"
	ElseIf MV_PAR02 == 4
		_codOri:= "'M','R'"
	Else
		_codOri:= ""
	EndIf

	cQuery:= " SELECT A.PRODUTO CODIGO, "
	cquery+=" A.B1_DESC DESCRI,"
	cQuery+=" COALESCE(SUM(AA.ZU_QRCAIX),0) AS _C_PROD, COALESCE(SUM(AA.ZU_QRPESO),0) AS _P_PROD,"
	cQuery+=" COALESCE(SUM(C_BB), 0) _C_PREV, COALESCE(SUM(P_BB), 0) _P_PREV, COALESCE(SUM(C_CC), 0) _C_CAR,"
	cQuery+=" COALESCE(SUM(P_CC), 0) _P_CAR, COALESCE(SUM(C_DD), 0) _C_EMP, COALESCE(SUM(P_DD), 0) _P_EMP,"
	cquery+=" COALESCE(SUM(EE.Z8_QTCAIX), 0) _C_EST, COALESCE(SUM(EE.Z8_QTPESO), 0) _P_EST,"
	cQuery+=" COALESCE(SUM(C_BB), 0) + COALESCE(SUM(EE.Z8_QTCAIX), 0) - COALESCE(SUM(C_DD), 0) _C_SAL, COALESCE(SUM(P_BB), 0) + COALESCE(SUM(EE.Z8_QTPESO), 0) - COALESCE(SUM(P_DD), 0) _P_SAL"
	cQuery+= " FROM "
	cQuery+= " 	("
	cQuery+= " 	SELECT B1_COD PRODUTO, B1_DESC"
	cQuery+= "  FROM  "+RetSqlTab("SB1,SBM")
	cQuery+= "  WHERE "+RetSqlFil("SB1,SBM")+" AND"
	cQuery+= " 	      B1_GRUPO = BM_GRUPO AND"
	cQuery+= " 	      B1_TIPO IN('PR','PA') AND "
	cQuery+= " 	      (B1_SEGUM = 'CX' OR B1_SEGUM = 'SC') AND"
	cQuery+= " 	      B1_MSBLQL <> '1' AND "
	If !Empty(MV_PAR04)
		cQuery+= "     B1_FAM = '"+MV_PAR04+"' AND "   
	EndIf
	cQuery+= " 	      B1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' AND"
	If !Empty(_fArm)
		cQuery+= " 	      BM_FARM = '"+_fArm+"' AND"
	EndIf
	If !Empty(_codOri)
		cQuery+= " 	      B1_CORORI IN ("+_codOri+") AND"
	EndIf
	cQuery+= " 	      "+RetSqlDel("SB1,SBM")
	cQuery+= " 	) A "     
	//AND ZU_FECHADO = 'N'
	cQuery+= " 	LEFT JOIN (SELECT ZU_COD,  SUM(ZU_QRCAIX) ZU_QRCAIX, SUM(ZU_QRPESO) ZU_QRPESO FROM "+RetSqlTab("SZU")+" WHERE "+RetSqlFil("SZU")+" AND ZU_DTRPRO = CONVERT(CHAR,GETDATE(),112) AND "+RetSqlDel("SZU")+" GROUP BY ZU_COD) AA ON AA.ZU_COD = A.PRODUTO"
	cQuery+= " 	LEFT JOIN (SELECT ZU_COD,  SUM(ZU_QPCAIX-ZU_QRCAIX) C_BB, SUM(ZU_QPPESO-ZU_QRPESO) P_BB FROM "+RetSqlTab("SZU")+" WHERE "+RetSqlFil("SZU")+"  AND ZU_DTRPRO = CONVERT(CHAR,GETDATE(),112) AND "+RetSqlDel("SZU")+" GROUP BY ZU_COD) BB ON BB.ZU_COD = A.PRODUTO"
	cQuery+= " 	LEFT JOIN (SELECT ZZ5_COD, SUM(ZZ5_QRCAIX) C_CC, SUM(ZZ5_QRPESO) P_CC FROM "+RetSqlTab("ZZ5,ZZ4")+" WHERE "+RetSqlFil("ZZ5,ZZ4")+" AND ZZ5_NUM = ZZ4_NUM AND ZZ4_DATA = CONVERT(CHAR,GETDATE(),112) AND ZZ4_TPOPER <> 'C' AND "+RetSqlDel("ZZ5,ZZ4")+" GROUP BY ZZ5_COD) CC ON CC.ZZ5_COD = A.PRODUTO"
	cQuery+= " 	LEFT JOIN (SELECT ZZ5_COD, SUM(ZZ5_QPCAIX-ZZ5_QRCAIX) C_DD, SUM(ZZ5_QPPESO-ZZ5_QRPESO) P_DD FROM "+RetSqlTab("ZZ5,ZZ4")+" WHERE "+RetSqlFil("ZZ5,ZZ4")+" AND ZZ5_STATUS <> 'E' AND ZZ5_NUM = ZZ4_NUM AND (ZZ4_DATA BETWEEN CONVERT(CHAR,GETDATE()-1,112) AND CONVERT(CHAR,GETDATE(),112)) AND ZZ4_TPOPER <> 'C' AND ZZ4_STATUS NOT IN('E','F','P') AND "+RetSqlDel("ZZ5,ZZ4")+" GROUP BY ZZ5_COD) DD ON DD.ZZ5_COD = A.PRODUTO"
	cQuery+= " 	LEFT JOIN (SELECT Z8_COD,  COUNT(Z8_CONTROL) Z8_QTCAIX, SUM(Z8_PESO) Z8_QTPESO FROM "+RetSqlTab("SZ8")+" WHERE "+RetSqlFil("SZ8")+" AND Z8_FIL = '"+ cFilAnt + "' AND  Z8_ENCONTR <> 'N' AND Z8_DATAS = '' AND Z8_PREPED = '' AND Z8_PRECAR = '' AND Z8_ITEM = '' AND "+RetSqlDel("SZ8")+" GROUP BY Z8_COD) EE ON EE.Z8_COD = A.PRODUTO"
	cQuery+= " GROUP BY A.PRODUTO, A.B1_DESC"
	cQuery+= " ORDER BY "+IIF(MV_PAR08 == 1, "A.PRODUTO, A.B1_DESC", IIF(MV_PAR08 == 2, "A.B1_DESC, A.PRODUTO", "_P_SAL, A.B1_DESC, A.PRODUTO"))

	//cQuery := "SELECT B1_COD as CODIGO,B1_DESC AS DESCRI FROM SB1010 WHERE SB1010.B1_TIPO IN('PR','PA') AND SB1010.B1_FILIAL = '"+xfilial('SB1')+ "' AND "
	//cQuery += " (SB1010.B1_SEGUM = 'CX' OR SB1010.B1_SEGUM = 'SC') AND SB1010.D_E_L_E_T_ <> '*' AND  SB1010.B1_MSBLQL <> '1' AND "                                "
	//cQuery += "  SB1010.B1_FILIAL = '"+ xfilial('SB1') + "' AND (SB1010.B1_GRUPO BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "')                        "

	//if !empty(mv_par04)
	//	cQuery += " AND SB1010.B1_FAM = '" + mv_par04 + "'"   
	//endif
	//  cQuery += " ORDER BY B1_DESC,B1_COD"  

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery  := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"
	Count To _nCount
	QRY->(dbgotop())

	//ProcRegua(QRY->(recCount()))

	area := getarea() 

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('QRY')       

	//IndRegua("TMP",cArq,"ZE_NUMERO+ZE_PRODUTO+ZE_RAST+ZE_CATEG+ZE_OG",,,"Selecionando Registros...") //ordena

	aStru := dbStruct()                                                           //Pega a estrutura do QRY e atribui a um vetor
	aStru[1,3]:= 6    
	aStru[2,3]:= 35   

	/*
	aadd(aStru,{"C_EST"    , "N",  04, 0,   "@E 9,999"    , 'Caixas Est.'})
	aadd(aStru,{"P_EST"    , "N",  10, 2,   "@E 9,999.99" , 'Peso Est.'  })
	aadd(aStru,{"C_SAL"    , "N",  04, 0,   "@E 9,999"    , 'Caixas Saldo'})
	aadd(aStru,{"P_SAL"    , "N",  10, 2,   "@E 9,999.99" , 'Peso Saldo'  }) 
	aadd(aStru,{"C_PREV"    , "N",  04, 0,   "@E 9,999"    , 'Caixas Prev.'})
	aadd(aStru,{"P_PREV"    , "N",  10, 2,   "@E 9,999.99" , 'Peso Prev.'  })
	aadd(aStru,{"C_CAR"    , "N",  04, 0,   "@E 9,999"    , 'Caixas Carreg.'})
	aadd(aStru,{"P_CAR"    , "N",  10, 2,   "@E 9,999.99" , 'Peso Carreg'  })
	aadd(aStru,{"C_EMP"    , "N",  04, 0,   "@E 9,999"    , 'Caixas Emp.'})
	aadd(aStru,{"P_EMP"    , "N",  10, 2,   "@E 9,999.99" , 'Peso Emp.'  })
	aadd(aStru,{"C_PROD"    , "N",  04, 0,   "@E 9,999"    , 'Caixas Prod'})
	aadd(aStru,{"P_PROD"    , "N",  10, 2,   "@E 9,999.99" , 'Peso Prod'  })
	*/

	aadd(aStru,{"C_EST"    , "N",  04, 0})
	aadd(aStru,{"P_EST"    , "N",  10, 2})
	aadd(aStru,{"C_SAL"    , "N",  04, 0})
	aadd(aStru,{"P_SAL"    , "N",  10, 2}) 
	aadd(aStru,{"C_PREV"    , "N",  04, 0})
	aadd(aStru,{"P_PREV"    , "N",  10, 2})
	aadd(aStru,{"C_CAR"    , "N",  04, 0})
	aadd(aStru,{"P_CAR"    , "N",  10, 2})
	aadd(aStru,{"C_EMP"    , "N",  04, 0})
	aadd(aStru,{"P_EMP"    , "N",  10, 2})
	aadd(aStru,{"C_PROD"    , "N",  04, 0})
	aadd(aStru,{"P_PROD"    , "N",  10, 2})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado 
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	_aArqTrb := {}
	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FECHATODOS",,,, @_aArqTrb)
	Endif
	U_ArqTrb("CRIA", "TMP", aStru, {}, @_aArqTrb)

	Procregua(_nCount)

	//SBM->(dbsetorder(1))
	while QRY->(!eof())  
		IncProc("Carregando registros...") 

		If MV_PAR03 = 2 .AND. ((QRY->_C_PREV = 0 .AND. QRY->_P_PREV = 0) .AND. QRY->_C_EST = 0 .AND. QRY->_C_EMP = 0)
			QRY->(dbskip())
			Loop
		EndIf

		DbSelectArea("TMP")
		Reclock('TMP', .t.)
		TMP->CODIGO  := alltrim(QRY->CODIGO)

		TMP->DESCRI  := alltrim(QRY->DESCRI)

		TMP->P_PREV  := QRY->_P_PREV 
		TMP->C_PREV  := QRY->_C_PREV

		if  QRY->_P_PREV < 0  .OR. QRY->_C_PREV < 0                                   
			TMP->P_PREV  := 0  
			TMP->C_PREV  := 0
		endif

		TMP->C_PROD  := QRY->_C_PROD
		TMP->P_PROD  := QRY->_P_PROD
		TMP->C_CAR   := QRY->_C_CAR
		TMP->P_CAR   := QRY->_P_CAR   
		TMP->C_EMP   := QRY->_C_EMP
		TMP->P_EMP   := QRY->_P_EMP               

		TMP->C_EST   := QRY->_C_EST
		TMP->P_EST   := QRY->_P_EST

		TMP->C_SAL   := 	TMP->C_PREV + 	TMP->C_EST - 	TMP->C_EMP//QRY->_C_SAL
		TMP->P_SAL   := 	TMP->P_PREV + 	TMP->P_EST - 	TMP->P_EMP//QRY->_P_SAL
		msUnlock()

		/* 
		codGrupo := fbuscacpo('SB1',1,xfilial('SB1')+alltrim(QRY->CODIGO),'B1_GRUPO')
		codOri   := fbuscacpo('SB1',1,xfilial('SB1')+alltrim(QRY->CODIGO),'B1_CORORI')
		fArm     := fbuscacpo('SBM',1,xfilial('SBM')+codGrupo,'BM_FARM') 

		do case
		case mv_par01 = 1
		if fArm != 'R'
		QRY->(dbskip())
		loop
		endif
		case mv_par01 = 2
		if fArm != 'C'
		QRY->(dbskip())
		loop
		endif
		case mv_par01 = 3
		if fArm != 'S'
		QRY->(dbskip())
		loop
		endif
		endcase

		do case
		case mv_par02 = 1
		if codOri != 'D'
		QRY->(dbskip())
		loop
		endif
		case mv_par02 = 2  
		if codOri != 'T'
		QRY->(dbskip())
		loop
		endif
		case mv_par02 = 3 
		if codOri != 'C'
		QRY->(dbskip())
		loop
		endif
		case  mv_par02 = 4
		if codOri != 'M' .and. codOri != 'R'
		QRY->(dbskip())
		loop
		endif
		endcase



		//Query para calcular o que foi produzido
		cQuery3 := " SELECT SUM(ZU_QRCAIX) AS C_PROD,SUM(ZU_QRPESO) AS P_PROD FROM SZU010 WHERE '" + alltrim(QRY->CODIGO) + "' = ZU_COD  "
		cQuery3 += "  AND ZU_DTRPRO = CONVERT(CHAR,GETDATE(),112) AND ZU_FILIAL = '" + xfilial('SZU')+"'" 
		cQuery3 += "  AND SZU010.D_E_L_E_T_ <> '*'   "   

		cQuery3  := ChangeQuery(cQuery3)

		If Select("QRY3")<>0
		QRY3->(dbCloseArea())
		Endif

		TCQUERY cQuery3 NEW ALIAS "QRY3"

		//Query para calcular o que está previsto
		cQuery4 := "SELECT SUM(ZU_QPCAIX-ZU_QRCAIX) AS C_PREV , SUM(ZU_QPPESO-ZU_QRPESO)AS P_PREV "
		cQuery4 += " FROM SZU010 WHERE '" + alltrim(QRY->CODIGO) + "' = ZU_COD  AND ZU_FECHADO = 'N' "
		cQuery4 += " AND ZU_DTRPRO = CONVERT(CHAR,GETDATE(),112) AND ZU_FILIAL = '" + xfilial('SZU')+"'" 
		cQuery4 += " AND SZU010.D_E_L_E_T_ <> '*'"  

		cQuery4  := ChangeQuery(cQuery4)

		If Select("QRY4")<>0
		QRY4->(dbCloseArea())
		Endif

		TCQUERY cQuery4 NEW ALIAS "QRY4"

		//Query pra calcular o que foi carregado
		cQuery5 := "SELECT SUM(ZZ5_QRCAIX) AS C_CAR, SUM(ZZ5_QRPESO) AS P_CAR FROM ZZ5010,ZZ4010 "//,ZZ3010"
		cQuery5 += " WHERE '" + alltrim(QRY->CODIGO) + "' = ZZ5_COD                                    " 
		cQuery5 += " AND ZZ5_NUM = ZZ4_NUM AND "//ZZ4_PRECAR = ZZ3_NUM AND                                "
		cQuery5 += " ZZ4_DATA = '" + dtos(ddatabase) + "'"
		//cQuery5 += " ZZ4_DATA = CONVERT(CHAR,GETDATE(),112)                                           "
		//	cQuery5 += " AND ZZ3010.D_E_L_E_T_ <> '*'                                                      "
		cQuery5 += " AND ZZ4010.D_E_L_E_T_ <> '*'                                                      "
		cQuery5 += " AND ZZ5010.D_E_L_E_T_ <> '*'                                                      "
		cQuery5 += " AND ZZ4_TPOPER <> 'C'                                                             " 
		cQuery5 += " AND  ZZ4_FILIAL = '" + xfilial('ZZ4')+"'                                          "
		//	cQuery5 += " AND  ZZ3_FILIAL = '" + xfilial('ZZ3')+"'                                          "
		cQuery5 += " AND  ZZ5_FILIAL = '" + xfilial('ZZ5')+"'                                          "  

		cQuery5  := ChangeQuery(cQuery5)

		If Select("QRY5")<>0
		QRY5->(dbCloseArea())
		Endif

		TCQUERY cQuery5 NEW ALIAS "QRY5"

		//Query para calcular o empenho
		cQuery6 :=  " SELECT SUM(ZZ5_QPCAIX-ZZ5_QRCAIX) AS C_EMP, SUM(ZZ5_QPPESO -ZZ5_QRPESO) AS P_EMP   "
		cQuery6 +=  " FROM ZZ5010,ZZ4010 WHERE  ZZ5_COD = '" + alltrim(QRY->CODIGO) + "' AND ZZ5_STATUS <> 'E'"
		cQuery6 +=  " AND ZZ5_FILIAL = '" + xfilial('ZZ5')+"'  AND                                       "   
		cQuery6 +=  "     ZZ4_FILIAL = '" + xfilial('ZZ4') +"' AND                                       "
		cQuery6 +=  " ZZ5_NUM = ZZ4_NUM AND " 
		cQuery6 +=  " (ZZ4_DATA BETWEEN '" + DTOS(ddatabase-1) + "' AND '" + DTOS(ddatabase) + "') AND     "
		cQuery6 +=  " ZZ4010.D_E_L_E_T_ <> '*' AND ZZ4_TPOPER <> 'C' AND                                 " 
		cQuery6 +=  " ZZ4_STATUS NOT IN('E','F','P') AND                        "
		cQuery6 +=  " ZZ5010.D_E_L_E_T_ <> '*'                                                           " 

		cQuery6  := ChangeQuery(cQuery6)

		If Select("QRY6")<>0
		QRY6->(dbCloseArea())
		Endif

		TCQUERY cQuery6 NEW ALIAS "QRY6"

		//Para trazer o saldo atual do produto
		SZI->(DbSetOrder(1))
		SZI->(DbSeek(xfilial('SZI')+alltrim(QRY->CODIGO)))


		if mv_par03 = 2 .and. ((QRY4->C_PREV = 0 .and. QRY4->P_PREV = 0) .and. SZI->ZI_QTCAIX = 0 .and.  QRY6->C_EMP = 0)
		QRY->(dbskip())
		loop
		endif


		reclock('TMP',.t.)
		TMP->CODIGO  := alltrim(QRY->CODIGO)

		TMP->DESCRI  := alltrim(QRY->DESCRI)

		TMP->P_PREV  := QRY4->P_PREV 
		TMP->C_PREV  := QRY4->C_PREV

		if  QRY4->P_PREV < 0  .or. QRY4->C_PREV < 0                                   
		TMP->P_PREV  := 0  
		TMP->C_PREV  := 0
		endif

		TMP->C_PROD  := QRY3->C_PROD
		TMP->P_PROD  := QRY3->P_PROD
		TMP->C_CAR   := QRY5->C_CAR
		TMP->P_CAR   := QRY5->P_CAR   
		TMP->C_EMP   := QRY6->C_EMP
		TMP->P_EMP   := QRY6->P_EMP               

		TMP->C_EST   := SZI->ZI_QTCAIX
		TMP->P_EST   := SZI->ZI_QTPESO

		TMP->C_SAL   := QRY4->C_PREV + C_EST - C_EMP
		TMP->P_SAL   := QRY4->P_PREV + P_EST - P_EMP
		msunlock()
		*/

		QRY->(dbskip())   

	EndDo

	aCampos := {}                                         
	aadd(aCampos,{"CODIGO"  ,"Codigo ",""})
	aadd(aCampos,{"DESCRI"  ,"Descricao   ",""})
	aadd(aCampos,{"C_PREV"  ,"Previsao Caixas","@E 999,999"  })
	aadd(aCampos,{"P_PREV"  ,"Pevisao Peso   ","@E 999,999.99"})   
	aadd(aCampos,{"C_PROD"  ,"Produção Caixas","@E 999,999"  })
	aadd(aCampos,{"P_PROD"  ,"Produção Peso  ","@E 999,999.99"})
	aadd(aCampos,{"C_EST"   ,"Estoque Caixas ","@E 999,999"  })
	aadd(aCampos,{"P_EST"   ,"Estoque Peso   ","@E 999,999.99"})
	aadd(aCampos,{"C_CAR"   ,"Carreg. Caixas ","@E 999,999"  })
	aadd(aCampos,{"P_CAR"   ,"Carreg. Peso   ","@E 999,999.99"})
	aadd(aCampos,{"C_EMP"   ,"Empenho Caixas ","@E 999,999"  })
	aadd(aCampos,{"P_EMP"   ,"Empenho Peso   ","@E 999,999.99"})
	aadd(aCampos,{"C_SAL"   ,"Saldo Caixas   ","@E 999,999"  })
	aadd(aCampos,{"P_SAL"   ,"Saldo Peso     ","@E 999,999.99"})

	COUNT To _nCount
	ProcRegua(_nCount)
	TMP->(dbgotop()) 

	while TMP->(!eof()) 
		IncProc("Verificando validade dos produtos...")
		cQuery2 := "SELECT COUNT(*) AS VALIDADE FROM "+RetSqlName("SZ8")+" SZ8"+;
		" WHERE SZ8.D_E_L_E_T_ <> '*' " +;
		"  AND SZ8.Z8_DATAE = ' '"+;
		"  AND SZ8.Z8_DATAS = ' '"+;    
		"  AND SZ8.Z8_ENCONTR <> 'N'"+;    
		"  AND SZ8.Z8_FILIAL = '" + xfilial('SZ8')+"'"+;
		"  AND SZ8.Z8_FIL = '"    + cFilAnt+"'"+;
		"  AND SZ8.Z8_COD = '" + TMP->CODIGO + "'" +;
		"  AND SZ8.Z8_DATAVAL BETWEEN '" + DTOS(date()) + "' AND '" + DTOS(date()+mv_par07) + "'" 

		cQuery2 := ChangeQuery(cQuery2)

		If Select("TMP2")<>0
			TMP2->(dbCloseArea())
		Endif    

		_valid := 0

		TCQUERY cQuery2 NEW ALIAS "TMP2"
		_valid := TMP2->VALIDADE
		TMP2->(dbclosearea()) 

		if _valid <> 0 
			area := getarea()
			DbSelectArea('SB1')

			_cProd := alltrim(fBuscaCPO('SB1',1,xfilial('SB1')+TMP->CODIGO,'B1_DESCRED'))

			MSGBOX('Produto de codigo ' + alltrim(TMP->CODIGO) + ' ('+ _cProd + ')';
			+ ' possui '+ transform(_valid,'@E 9,999') + ' caixas '+;
			'a vencer em ' + transform(mv_par07,'@E 999') + ' dias!', 'AVISO DE VENCIMENTO DE CAIXAS','INFO')  

			SB1->(DbCloseArea())
			restarea(area)     
		endif

		_nTotCaix  += TMP->C_EST
		_nTotPes   += TMP->P_EST
		_nTotEmp   += TMP->P_EMP

		TMP->(dbskip())
	enddo  

	DbSelectArea('TMP')
	//if mv_par08 = 1
	//	IndRegua("TMP",cArq,"CODIGO+DESCRI",,,"Selecionando Registros...") //ordena
	//elseif mv_par08 = 2 
	//	IndRegua("TMP",cArq,"DESCRI+CODIGO",,,"Selecionando Registros...") //ordena
	//elseif mv_par08 = 3
	//	IndRegua("TMP",cArq,"STRZERO(C_SAL,3)+DESCRI+CODIGO",,,"Selecionando Registros...") //ordena
	//endif 

	TMP->(dbgotop())

	DEFINE MSDIALOG oEnc TITLE 'Consulta de Posição de Estoque de PA do Dia' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	//from 05,05 To 600,1000 OF oMainWnd PIXEL

	@ 020,005 BUTTON 'Sair'      SIZE 40,15 ACTION oEnc:end() OBJECT oBtn 
	@ 020,050 BUTTON 'Validade'  SIZE 40,15 ACTION u_gjf108() OBJECT oBtn2 
	@ 020,095 BUTTON 'Imprimir'  SIZE 40,15 ACTION u_sti_r506() OBJECT oBtn3 
	@ 020,140 BUTTON 'Excel' 	 SIZE 40,15 ACTION u_sti_r507() OBJECT oBtn4 
	@ 040,003 To aSizeAut[4]-50,aSizeAut[3] Browse "TMP"  fields aCampos object oiBrowse

	//@ 001,025 say 'Saldos Totais:'
	@ 1.5, 025 say 'Total De Caixas: ' + transform(_nTotCaix,'@E 999,999')
	@ 1.5, 037 say 'Total De Peso: ' + transform(_nTotPes, '@E 999,999,999.99')
	@ 1.5, 050 say 'Total De Peso Empenhado: ' + transform(_nTotEmp, '@E 999,999,999.99')

	ACTIVATE MSDIALOG oEnc CENTERED

	TMP->(dbCloseArea())
	QRY->(dbCloseArea())
	
	u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	

Return    
