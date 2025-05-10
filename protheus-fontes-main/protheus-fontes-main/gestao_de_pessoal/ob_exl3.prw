#INCLUDE 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

user function ob_Exl3()
	local oExcel     := nil
	private cPath	 := AllTrim(GetTempPath())
	private cAlExc   := GetNextAlias()
	private cQuery   := ""
	cPerg :=  "ob_Exl3"
	ValidPerg()
	if Pergunte(cPerg,.T.)
		FWMsgRun(, {|oSay| _dzGerH( oSay ) }, "Processando...", "Buscando dados..." )
	EndIf

Return

static function _dzGerH(oSay)
	Local _y
	oExcel := FWMSEXCEL():New()
	oExcel:SetFontSize(8)
	oExcel:SetFont("Arial")
	cQuery := " SELECT PC_CC,CTT_DESC01,PC_MAT,PC_DATA,RA_FILIAL,RA_NOME,SUM(HORAS_EXTRAS) AS HORAS_EXTRAS , SUM(HORAS_NORMAIS) AS HORAS_NORMAIS, SUM(SALDO) AS SALDO"
	cQuery += " FROM"
	cQuery += " (SELECT PC_FILIAL,PC_CC,CTT_DESC01,PC_MAT,PC_DATA, PC_PD, CASE WHEN PC_PD IN "+FormatIn(Alltrim(MV_PAR06),',') 
	cQuery += "       THEN ISNULL(sum(CAST(PC_QUANTC AS INT)+(((PC_QUANTC - CAST(PC_QUANTC AS INT)) /60) *100)),0) ELSE 0 END AS HORAS_EXTRAS,"
	cQuery += "       CASE WHEN PC_PD IN "+FormatIn(Alltrim(MV_PAR05),',')
	cQuery += "       THEN ISNULL(sum(CAST(PC_QUANTC AS INT)+(((PC_QUANTC - CAST(PC_QUANTC AS INT)) /60) *100)),0) ELSE 0 END AS HORAS_NORMAIS, 0 AS SALDO"
	cQuery += " FROM "+RetSqlName("SPC")+" AS SPC"
	cQuery += " INNER JOIN "+RetSqlName("CTT")+" AS CTT ON CTT_CUSTO = PC_CC AND CTT.D_E_L_E_T_ = ''"
	cQuery += " WHERE SPC.D_E_L_E_T_ = '' " 
	cQuery += " AND (PC_PD IN "+FormatIn(Alltrim(MV_PAR05),',')+" OR PC_PD IN " + FormatIn(Alltrim(MV_PAR06),',')+")"
	cQuery += " AND PC_DATA BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"'"
	cQuery += " AND PC_CC BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	cQuery += " GROUP BY PC_FILIAL,PC_MAT,PC_DATA, PC_PD,PC_CC,CTT_DESC01"
	cQuery += " UNION ALL "
	cQuery += " SELECT PI_FILIAL AS PC_FILIAL, PI_CC AS PC_CC, CTT_DESC01, PI_MAT AS PC_MAT, PI_DATA AS PC_DATA, '' AS PC_PD, " 
	cQuery += " 0 AS HORAS_EXTRAS,0 AS HORAS_NORMAIS, "
	cQuery += " ISNULL(SUM(CASE WHEN PI_PD < 500 THEN (CAST(PI_QUANT AS INTEGER) + (((PI_QUANT - CAST(PI_QUANT AS INTEGER))*100) /60)) ELSE 0 END) - "
	cQuery += " SUM(CASE WHEN PI_PD >= 500 THEN (CAST(PI_QUANT AS INTEGER) + (((PI_QUANT - CAST(PI_QUANT AS INTEGER))*100) /60)) ELSE 0 END) ,0) AS SALDO "
	cQuery += " FROM "+RetSqlName("SPI")+" AS SPI "
	cQuery += " INNER JOIN "+RetSqlName("CTT")+" AS CTT ON CTT_CUSTO = PI_CC AND CTT.D_E_L_E_T_ = '' " 
	cQuery += " WHERE SPI.D_E_L_E_T_ = '' "
	cQuery += " AND PI_DATA BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"'"
	cQuery += " AND PI_CC BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"	
	cQuery += " GROUP BY PI_FILIAL,PI_MAT,PI_DATA, PI_PD, PI_CC, CTT_DESC01 "
	cQuery += " UNION ALL "
	cQuery += " SELECT PH_FILIAL AS PC_FILIAL, PH_CC AS PC_CC,CTT_DESC01,PH_MAT AS PC_MAT,PH_DATA AS PC_DATA, PH_PD AS PC_PD, CASE WHEN PH_PD IN "+FormatIn(Alltrim(MV_PAR06),',') 
	cQuery += "       THEN ISNULL(sum(CAST(PH_QUANTC AS INT)+(((PH_QUANTC - CAST(PH_QUANTC AS INT)) /60) *100)),0) ELSE 0 END AS HORAS_EXTRAS,"
	cQuery += "       CASE WHEN PH_PD IN "+FormatIn(Alltrim(MV_PAR05),',')
	cQuery += "       THEN ISNULL(sum(CAST(PH_QUANTC AS INT)+(((PH_QUANTC - CAST(PH_QUANTC AS INT)) /60) *100)),0) ELSE 0 END AS HORAS_NORMAIS, 0 AS SALDO"
	cQuery += " FROM "+RetSqlName("SPH")+" AS SPH"
	cQuery += " INNER JOIN "+RetSqlName("CTT")+" AS CTT ON CTT_CUSTO = PH_CC AND CTT.D_E_L_E_T_ = ''"
	cQuery += " WHERE SPH.D_E_L_E_T_ = '' " 
	cQuery += " AND (PH_PD IN "+FormatIn(Alltrim(MV_PAR05),',')+" OR PH_PD IN " + FormatIn(Alltrim(MV_PAR06),',')+")"
	cQuery += " AND PH_DATA BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"'"
	cQuery += " AND PH_CC BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	cQuery += " GROUP BY PH_FILIAL,PH_MAT,PH_DATA, PH_PD,PH_CC,CTT_DESC01"
	cQuery += " ) AS TOTAL_DIA"
	cQuery += " INNER JOIN "+RetSqlName("SRA")+" AS SRA ON RA_MAT = PC_MAT AND RA_FILIAL = PC_FILIAL AND SRA.D_E_L_E_T_ = ''"
	cQuery += " GROUP BY RA_FILIAL,PC_CC,CTT_DESC01,PC_DATA,PC_MAT,RA_NOME"
	cQuery += " ORDER BY CTT_DESC01,RA_NOME,PC_DATA"

	TCQUERY cQuery NEW ALIAS "TRB"
	TcSetField("TRB","PC_DATA","D")

	_dIni:= mv_par01
	_dFim:= mv_par02

	mudaCC:= .t.
	mudaFunc:= .f.
	_nCont:= 0
	prim := .t.
	aInfH := {}
	oSay:cCaption := ("Preparando dados para planilha...")
	ProcessMessages()

	dbSelectArea("TRB")
	DbGoTop()
	While !Eof()
		aLin := {}	

		if mudaCC //CRIA AS COLUNAS E NOVO PLANO
			_nCont++
			_dIni:= mv_par01
			cPlano:= alltrim(TRB->PC_CC)+"-"+alltrim(TRB->CTT_DESC01)+alltrim(str(_nCont))
			cTitulo:= "RELACAO DAS HORAS EXTAS ENTRE "+DTOC(mv_par01)+ " E "+ DTOC(mv_par02)
			oExcel:AddworkSheet(cPlano)
			oExcel:AddTable(cPlano,cTitulo)
			oExcel:AddColumn(cPlano,cTitulo,"Matricula",1,1)
			oExcel:AddColumn(cPlano,cTitulo,"Nome",1,1)
			while _dIni <= _dFim
				oExcel:AddColumn(cPlano,cTitulo,dtoc(_dIni)+" (HN)",3,2)
				oExcel:AddColumn(cPlano,cTitulo,dtoc(_dIni)+" (HE)",3,2)
				oExcel:AddColumn(cPlano,cTitulo,dtoc(_dIni)+" (Saldo BH)",3,2)
				_dIni+=1
			Enddo
			oExcel:AddColumn(cPlano,cTitulo,'TOTAL H. NORMAIS',3,2)
			oExcel:AddColumn(cPlano,cTitulo,'TOTAL H. EXTRAS',3,2)
			oExcel:AddColumn(cPlano,cTitulo,'SALDO B.H.',3,2)
			oExcel:AddColumn(cPlano,cTitulo,'TOTAL',3,2)
			mudaCC := .f.
		Endif

		AADD(aInfH,{trb->PC_DATA,trb->HORAS_NORMAIS,trb->HORAS_EXTRAS, trb->SALDO})


		cbkpMat := trb->PC_MAT
		cckpNom := trb->RA_NOME
		cbkpCC  := trb->PC_CC
		cbkpCN  := TRB->CTT_DESC01

		dbskip()

		if trb->PC_MAT <> cbkpMat  //ao trocar de funcionario insere registro na planilha
			aLin:={}
			AADD(aLin,cbkpMat)
			AADD(aLin,cckpNom)
			_x := 3
			_ntotN := 0.00
			_ntotE := 0.00
			_ntotB := 0.00
			
			while _x <= len(oExcel:atable[1][3]) - 4 //varro o array pegando somente os campos datas 
				_lEnco := .f.
				for _y := 1 to len(aInfH)
					if left(oExcel:atable[1][3][_x][1],8) == dtoc(aInfH[_y][1])   //vejo as datas que tem informacao
						AADD(aLin,fConvHr(aInfH[_y][2],'H'))
						AADD(aLin,fConvHr(aInfH[_y][3],'H'))
						if aInfH[_y][4] < 0
							AADD(aLin,fConvHr(aInfH[_y][4]*-1,'H')*-1)
						else
							AADD(aLin,fConvHr(aInfH[_y][4],'H'))
						endif	
						_ntotN += aInfH[_y][2]
						_ntotE += aInfH[_y][3]
						_ntotB += aInfH[_y][4]
						_lEnco := .t.
						
					endif
				next _y

				if !_lEnco //no final se eu nao encontro registro do funcionario no SPC preencho com 0
					AADD(aLin,0.00)
					AADD(aLin,0.00)
					AADD(aLin,0.00)
				Endif
				_x := _x + 3
			Enddo
			//AADD(aLin,_ntotN)
			//AADD(aLin,_ntotE)
			//AADD(aLin,_ntotN + _ntotE)

			AADD(aLin,fConvHr(_ntotN, 'H'))
			AADD(aLin,fConvHr(_ntotE, 'H'))
			if _ntotB < 0
				AADD(aLin,fConvHr(_ntotB*-1, 'H')*-1)
			else	
				AADD(aLin,fConvHr(_ntotB, 'H'))
			endif
			AADD(aLin,fConvHr(_ntotN + _ntotE, 'H'))
			
			oExcel:AddRow(cPlano,cTitulo,aLin)
			aInfH := {}
		endif

		if trb->PC_CC <> cbkpCC //crio nova aba na planilha
			mudaCC := .t.
		endif

	Enddo

	if len(aInfH) >0 // vejo se tem registro a ser inserido na planilha
		_nCont++
		_dIni:= mv_par01
		cPlano:= alltrim(cbkpCC)+"-"+alltrim(cbkpCN)+alltrim(str(_nCont))
		cTitulo:= "RELACAO DAS HORAS EXTAS ENTRE "+DTOC(mv_par01)+ " E "+ DTOC(mv_par02)
		oExcel:AddworkSheet(cPlano)
		oExcel:AddTable(cPlano,cTitulo)
		oExcel:AddColumn(cPlano,cTitulo,"Matricula",1,1)
		oExcel:AddColumn(cPlano,cTitulo,"Nome",1,1)
		while _dIni <= _dFim
			oExcel:AddColumn(cPlano,cTitulo,dtoc(_dIni)+" (HN)",3,2)
			oExcel:AddColumn(cPlano,cTitulo,dtoc(_dIni)+" (HE)",3,2)
			oExcel:AddColumn(cPlano,cTitulo,dtoc(_dIni)+" (Saldo HE)",3,2)
			_dIni+=1
		Enddo
		oExcel:AddColumn(cPlano,cTitulo,'TOTAL H. NORMAIS',3,2)
		oExcel:AddColumn(cPlano,cTitulo,'TOTAL H. EXTRAS',3,2)
		oExcel:AddColumn(cPlano,cTitulo,'SALDO B.H. FINAL',3,2)
		oExcel:AddColumn(cPlano,cTitulo,'TOTAL',3,2)

		aLin:={}
		AADD(aLin,cbkpMat)
		AADD(aLin,cckpNom)
		_x := 3
		_ntotN := 0.00
		_ntotE := 0.00
		_ntotB := 0.00
		while _x <= len(oExcel:atable[1][3]) - 4 //varro o array para saber quantas datas foram criadas
			_lEnco := .f.
			for _y := 1 to len(aInfH)
				if left(oExcel:atable[1][3][_x][1],8) == dtoc(aInfH[_y][1])   //vejo as datas que tem informacao
					AADD(aLin,fConvHr(aInfH[_y][2],'H'))
					AADD(aLin,fConvHr(aInfH[_y][3],'H'))
					AADD(aLin,fConvHr(aInfH[_y][4],'H'))
					_ntotN += aInfH[_y][2]
					_ntotE += aInfH[_y][3]
					_ntotB += aInfH[_y][4]
					_lEnco := .t.
				endif
			next _y

			if !_lEnco //no final se eu nao encontro registro do funcionario no SPC preencho com 0
				AADD(aLin,0.00)
				AADD(aLin,0.00)
				AADD(aLin,0.00)
			Endif
			_x := _x + 3
		Enddo
		AADD(aLin,fConvHr(_ntotN, 'H'))
		AADD(aLin,fConvHr(_ntotE, 'H'))
		if _ntotB < 0
			AADD(aLin,fConvHr(_ntotB*-1, 'H')*-1)
		else	
			AADD(aLin,fConvHr(_ntotB, 'H'))
		endif
		AADD(aLin,fConvHr(_ntotN + _ntotE, 'H'))

		oExcel:AddRow(cPlano,cTitulo,aLin)


	Endif


	dbSelectArea("TRB")
	dbCloseArea()

	cArq:= cPath+cAlExc
	oExcel:Activate()
	oExcel:GetXMLFile(cArq)
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(cArq)
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()

return



/**************************
Pergunta
***************************/
Static Function ValidPerg()
	Local i
	Local j
	cAlias := Alias()
	aRegs  :={}

	AADD(aRegs,{cPerg,"01","Data de         ?","Data de            ?","Data de            ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Data ate        ?","Data Ate           ?","Data ate           ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","C. Custo de     ?","C. Custo de        ?","C. custo de        ?","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CTT",""})
	AADD(aRegs,{cPerg,"04","C. Custo ate    ?","C. Custo ate       ?","C. custo ate       ?","mv_ch4","C",09,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CTT",""})
	AADD(aRegs,{cPerg,"05","Verb HN (sep ,) ?","                   ?","                   ?","mv_ch5","C",45,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Verb HE (sep ,) ?","                   ?","                   ?","mv_ch6","C",45,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	DbSetOrder(1)
	For i:=1 to Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j<=Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	DbSelectArea(cAlias)
Return
