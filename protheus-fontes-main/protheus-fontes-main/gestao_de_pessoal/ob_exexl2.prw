#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

user function ob_exExl2()
	local oExcel     := nil
	private cPath	 := AllTrim(GetTempPath())
	private cAlExc   := GetNextAlias()
	private cQuery   := ""
	cPerg :=  "ob_exExl2"

	if Pergunte(cPerg,.T.)
		FWMsgRun(, {|oSay| _dzGerH( oSay ) }, "Processando...", "Buscando dados..." )
	EndIf

Return

static function _dzGerH(oSay)
	Local _y
	oExcel := FWMSEXCEL():New()
	oExcel:SetFontSize(8)
	oExcel:SetFont("Arial")
/*
	cQuery := " SELECT PC_CC,CTT_DESC01,PC_MAT,PC_DATA,RA_FILIAL,RA_NOME,SUM(HORAS_EXTRAS) AS HORAS_EXTRAS , SUM(HORAS_NORMAIS) AS HORAS_NORMAIS"
	cQuery += " FROM"
	cQuery += " (SELECT PC_FILIAL,PC_CC,CTT_DESC01,PC_MAT,PC_DATA, PC_PD, CASE WHEN PC_PD IN "+FormatIn(Alltrim(MV_PAR06),',') 
	cQuery += "       THEN ISNULL(sum(CAST(PC_QUANTC AS INT)+(((PC_QUANTC - CAST(PC_QUANTC AS INT)) /60) *100)),0) ELSE 0 END AS HORAS_EXTRAS,"
	cQuery += "       CASE WHEN PC_PD IN "+FormatIn(Alltrim(MV_PAR05),',')
	cQuery += "       THEN ISNULL(sum(CAST(PC_QUANTC AS INT)+(((PC_QUANTC - CAST(PC_QUANTC AS INT)) /60) *100)),0) ELSE 0 END AS HORAS_NORMAIS"
	cQuery += " FROM "+RetSqlName("SPC")+" AS SPC"
	cQuery += " INNER JOIN "+RetSqlName("CTT")+" AS CTT ON CTT_CUSTO = PC_CC AND CTT.D_E_L_E_T_ = ''"
	cQuery += " WHERE SPC.D_E_L_E_T_ = '' " 
	cQuery += " AND (PC_PD IN "+FormatIn(Alltrim(MV_PAR05),',')+" OR PC_PD IN " + FormatIn(Alltrim(MV_PAR06),',')+")"
	cQuery += " AND PC_DATA BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"'"
	cQuery += " AND PC_CC BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	cQuery += " GROUP BY PC_FILIAL,PC_MAT,PC_DATA, PC_PD,PC_CC,CTT_DESC01"
	cQuery += " ) AS TOTAL_DIA"
	cQuery += " INNER JOIN "+RetSqlName("SRA")+" AS SRA ON RA_MAT = PC_MAT AND RA_FILIAL = PC_FILIAL AND SRA.D_E_L_E_T_ = ''"
	cQuery += " GROUP BY RA_FILIAL,PC_CC,CTT_DESC01,PC_DATA,PC_MAT,RA_NOME"
	cQuery += " ORDER BY CTT_DESC01,RA_NOME,PC_DATA"
	*/
	cQuery := "SELECT PC_CC,CTT_DESC01,PC_MAT,PC_DATA,RA_FILIAL,RA_NOME,SUM(HORAS_EXTRAS) AS HORAS_EXTRAS , SUM(HORAS_NORMAIS) AS HORAS_NORMAIS"
	cQuery += " FROM"
	cQuery += " (SELECT PC_FILIAL,PC_CC,CTT_DESC01,PC_MAT,PC_DATA, PC_PD, CASE WHEN PC_PD IN "+FormatIn(Alltrim(MV_PAR06),',') 
	cQuery += "       THEN ISNULL(sum(CAST(PC_QUANTC AS INT)+(((PC_QUANTC - CAST(PC_QUANTC AS INT)) /60) *100)),0) ELSE 0 END AS HORAS_EXTRAS,"
	cQuery += "       CASE WHEN PC_PD IN "+FormatIn(Alltrim(MV_PAR05),',')
	cQuery += "       THEN ISNULL(sum(CAST(PC_QUANTC AS INT)+(((PC_QUANTC - CAST(PC_QUANTC AS INT)) /60) *100)),0) ELSE 0 END AS HORAS_NORMAIS"
	cQuery += " FROM "+RetSqlName("SPC")+" AS SPC"
	cQuery += " INNER JOIN "+RetSqlName("CTT")+" AS CTT ON CTT_CUSTO = PC_CC AND CTT.D_E_L_E_T_ = ''"
	cQuery += " WHERE SPC.D_E_L_E_T_ = '' " 
	cQuery += " AND (PC_PD IN "+FormatIn(Alltrim(MV_PAR05),',')+" OR PC_PD IN " + FormatIn(Alltrim(MV_PAR06),',')+")"
	cQuery += " AND PC_DATA BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"'"
	cQuery += " AND PC_CC BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	cQuery += " GROUP BY PC_FILIAL,PC_MAT,PC_DATA, PC_PD,PC_CC,CTT_DESC01"
	cQuery += " UNION ALL "
	cQuery += " SELECT PH_FILIAL AS PC_FILIAL, PH_CC AS PC_CC,CTT_DESC01,PH_MAT AS PC_MAT,PH_DATA AS PC_DATA, PH_PD AS PC_PD, CASE WHEN PH_PD IN "+FormatIn(Alltrim(MV_PAR06),',') 
	cQuery += "       THEN ISNULL(sum(CAST(PH_QUANTC AS INT)+(((PH_QUANTC - CAST(PH_QUANTC AS INT)) /60) *100)),0) ELSE 0 END AS HORAS_EXTRAS,"
	cQuery += "       CASE WHEN PH_PD IN "+FormatIn(Alltrim(MV_PAR05),',')
	cQuery += "       THEN ISNULL(sum(CAST(PH_QUANTC AS INT)+(((PH_QUANTC - CAST(PH_QUANTC AS INT)) /60) *100)),0) ELSE 0 END AS HORAS_NORMAIS"
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
				_dIni+=1
			Enddo
			oExcel:AddColumn(cPlano,cTitulo,'TOTAL H. NORMAIS',3,2)
			oExcel:AddColumn(cPlano,cTitulo,'TOTAL H. EXTRAS',3,2)
			oExcel:AddColumn(cPlano,cTitulo,'TOTAL',3,2)
			mudaCC := .f.
		Endif

		AADD(aInfH,{trb->PC_DATA,trb->HORAS_NORMAIS,trb->HORAS_EXTRAS})


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
			while _x <= len(oExcel:atable[1][3]) - 3 //varro o array pegando somente os campos datas 
				_lEnco := .f.
				for _y := 1 to len(aInfH)
					if left(oExcel:atable[1][3][_x][1],8) == dtoc(aInfH[_y][1])   //vejo as datas que tem informacao
						AADD(aLin,fConvHr(aInfH[_y][2],'H'))
						AADD(aLin,fConvHr(aInfH[_y][3],'H'))
						_ntotN := _ntotN + aInfH[_y][2]
						_ntotE := _ntotE + aInfH[_y][3]
						_lEnco := .t.
					endif
				next _y

				if !_lEnco //no final se eu nao encontro registro do funcionario no SPC preencho com 0
					AADD(aLin,0.00)
					AADD(aLin,0.00)
				Endif
				_x := _x + 2
			Enddo
			//AADD(aLin,_ntotN)
			//AADD(aLin,_ntotE)
			//AADD(aLin,_ntotN + _ntotE)

			AADD(aLin,fConvHr(_ntotN, 'H'))
			AADD(aLin,fConvHr(_ntotE, 'H'))
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
			_dIni+=1
		Enddo
		oExcel:AddColumn(cPlano,cTitulo,'TOTAL H. NORMAIS',3,2)
		oExcel:AddColumn(cPlano,cTitulo,'TOTAL H. EXTRAS',3,2)
		oExcel:AddColumn(cPlano,cTitulo,'TOTAL',3,2)

		aLin:={}
		AADD(aLin,cbkpMat)
		AADD(aLin,cckpNom)
		_x := 3
		_ntotN := 0.00
		_ntotE := 0.00
		while _x <= len(oExcel:atable[1][3]) - 3 //varro o array para saber quantas datas foram criadas
			_lEnco := .f.
			for _y := 1 to len(aInfH)
				if left(oExcel:atable[1][3][_x][1],8) == dtoc(aInfH[_y][1])   //vejo as datas que tem informacao
					AADD(aLin,fConvHr(aInfH[_y][2],'H'))
					AADD(aLin,fConvHr(aInfH[_y][3],'H'))
					_ntotN := _ntotN + aInfH[_y][2]
					_ntotE := _ntotE + aInfH[_y][3]
					_lEnco := .t.
				endif
			next _y

			if !_lEnco //no final se eu nao encontro registro do funcionario no SPC preencho com 0
				AADD(aLin,0.00)
				AADD(aLin,0.00)
			Endif
			_x := _x + 2
		Enddo
		AADD(aLin,fConvHr(_ntotN, 'H'))
		AADD(aLin,fConvHr(_ntotE, 'H'))
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
