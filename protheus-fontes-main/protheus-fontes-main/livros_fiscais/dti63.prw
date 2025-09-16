#INCLUDE 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณdti63  บAutor  ณ Wellington            บ Data ณ 19/07/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para realizar a limpeza dos flags de contabiliza-บฑฑ
ฑฑบ          ณ cao das notas fiscais livros fiscais                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ dti61                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function dti63()

	Local cGetNF:= Space(9)
	Local cGetSe:= Space(3)
	Local dGetDT:= CtoD("")
	Local nX := 0
	Local cNotaFis := "Nบ Nota Fiscal:"
	Local cSerie   := "S้rie:"
	Local cData    := "Data Emissใo:" 
	local _sFiltro := ""
	Private aDados:= {}
	Private oDlg  := Nil
	Private oBrw  := Nil
	Private oGetNF:= Nil
	Private oGetSe:= Nil
	Private oGetDt:= Nil
	Private oNo   := LoadBitmap(GetResources(), "LBNO")
	Private oOk   := LoadBitmap(GetResources(), "LBTIK")
	Private nopc  := 0

	AADD(aDados, {.T., '', '', '', '', '', ''})

	DEFINE MSDIALOG oDlg FROM 0,0 TO 300,567 PIXEL TITLE 'Limpeza Flags Contabiliza็ใo (Livros Fiscais)'

	@ 0.1, 01 SAY cNotaFis of oDlg
	@ 0.6, 01 GET oGetNF VAR cGetNF OF oDlg
	@ 0.1, 07 SAY cSerie of oDlg
	@ 0.6, 07 GET oGetSe VAR cGetSe VALID Nota(@aDados, cGetNF, cGetSe, dGetDT, @_sFiltro) OF oDlg
	@ 0.1, 12 SAY cData of oDlg
	@ 0.6, 12 GET oGetDt VAR dGetDT VALID Nota(@aDados, cGetNF, cGetSe, dGetDT, @_sFiltro) OF oDlg

	oBrw:= TCBrowse():New(20, 01, 285, 115, , {'', 'Dt Emissใo', 'N๚mero', 'S้rie', 'Cli/For', 'Loja', 'Valor'}, {10, 30, 25, 20, 20, 15, 20}, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
	oBrw:SetArray(aDados)
	oBrw:bLine:= {|| {IIF(	aDados[oBrw:nAt, 01], oOk, oNo),;
	aDados[oBrw:nAt, 02],;
	aDados[oBrw:nAt, 03],;
	aDados[oBrw:nAt, 04],;
	aDados[oBrw:nAt, 05],;
	aDados[oBrw:nAt, 06],;
	Transform(aDados[oBrw:nAt, 07],"@e 999,999,999,999.99")}}

	TButton():New(006, 170, "Marcar Todos" 		, oDlg,{|| MarkAll(@aDados,.T.) },50,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(006, 230, "Desmarcar Todos"	, oDlg,{|| MarkAll(@aDados,.F.) },50,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	TButton():New(138, 050, "Filtro" , oDlg,{|| _Filtro(@aDados,cGetNF, cGetSe, dGetDT, @_sFiltro) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(138, 190, "Confirmar" , oDlg,{|| nOpc:= 1, oDlg:End()},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(138, 240, "Cancelar"	, oDlg,{|| nOpc:= 0, oDlg:End()},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )


	// Evento de duplo click na celula
	oBrw:bLDblClick   := {|| AcaoOnClick()}

	ACTIVATE MSDIALOG oDlg CENTERED

	IF nOpc == 1
		FOR nX := 1 TO Len(aDados)

			IF aDados[nX , 1] == .T. //para todos os dados do array ele testa se esta marcado o checkbox para deletar do banco

				dbSelectArea("SF3")
				dbSetOrder(1)
				dbSeek(XFilial("SF3")+aDados[nx,3]+aDados[nx,4]+aDados[nx,5]+aDados[nx,6])

				IF found()

					RecLock("SF3",.F.)
					SF3->F3_DTLANC := StoD('')
					SF3->(MsUnLock())

					//MsgInfo("NF: "+aDados[nx,3]+" "+aDados[nx,4]+"liberada para recontabiliza็ใo")
				ENDIF
			ENDIF

		NEXT nX
	ELSE
		return(.F.)
	ENDIF

Return        

// --------------------------------------------------------------------------
// Filtra registros no markbrowse
Static Function _Filtro (aDados,cGetNF, cGetSe, dGetDT, _sFiltro)

	SF3->(_sFiltro := BuildExpr("SF3",oDlg))

	Nota(@aDados,cGetNF, cGetSe, dGetDT, _sFiltro)

Return


Static Function MarkAll(_aMark,_lMark)
	Local _i

	For _i := 1 to Len(_aMark)
		_aMark[_i,01] := _lMark
	next

	// Seta vetor para a browse
	oBrw:SetArray(_aMark)

	// Monta a linha a ser exibina no Browse
	oBrw:bLine:= {|| {IIF(	_aMark[oBrw:nAt, 01], oOk, oNo),;
	_aMark[oBrw:nAt, 02],;
	_aMark[oBrw:nAt, 03],;
	_aMark[oBrw:nAt, 04],;
	_aMark[oBrw:nAt, 05],;
	_aMark[oBrw:nAt, 06],;
	Transform(_aMark[oBrw:nAt, 07],"@e 999,999,999,999.99")}}

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณdti63  บAutor  ณ					     บ Data ณ  08/17/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  confere se a nota fiscal informada pelo o usuario existe  บฑฑ
ฑฑบ          ณ  no banco de dados                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Nota(aDados, cGetNF, cGetSE, dGetDT, _sFiltro)
	Local lRet:= .T.      
	Local _lContinua	:= .F.
	Local _cFilTel 		:= "F3_FILIAL == '"+xFilial("SF3")+"' "

	IF !empty(cGetNF+cGetSE)
		_cFilTel += " .and. F3_NFISCAL == '"+cGetNF+"' "
		_cFilTel += " .and. F3_SERIE == '"+cGetSE+"' "
		_lContinua	:= .T.
	endif

	IF !empty(dGetDT)
		_cFilTel += " .and. DtoS(F3_EMISSAO) == '"+DtoS(dGetDT)+"' "
		_lContinua	:= .T.
	endif

	IF !empty(_sFiltro)
		_cFilTel += " .and. " + _sFiltro
		_lContinua	:= .T.
	endif

	IF _lContinua
		// Aplica o filtro
		dbselectarea ("SF3")
		set filter to &(_cFilTel)
		SF3->(dbGoTop ())
		aDados:= {}
		Do While !EOF()
			AADD(aDados, {.T., SF3->F3_EMISSAO, SF3->F3_NFISCAL, SF3->F3_SERIE, SF3->F3_CLIEFOR, SF3->F3_LOJA, SF3->F3_VALCONT})
			SF3->(dbSkip())
		EndDo

		dbselectarea ("SF3")
		set filter to

	endif

	IF Len(aDados)==0
		AADD(aDados, {.T., '', '', '', '', '', ''})
	endif  

	oBrw:SetArray(aDados)
	oBrw:bLine:= {|| {IIF(	aDados[oBrw:nAt, 01], oOk, oNo),;
	aDados[oBrw:nAt, 02],;
	aDados[oBrw:nAt, 03],;
	aDados[oBrw:nAt, 04],;
	aDados[oBrw:nAt, 05],;
	aDados[oBrw:nAt, 06],;
	Transform(aDados[oBrw:nAt, 07],"@e 999,999,999,999.99")}}

	oBrw:Refresh()

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณAcaoOnClick() ณ Autor ณ    				ณ Data ณ17/08/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Fun็ใo do duplo clique na linha. Atualiza a op็ใo de edi็ใoณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ GTI62                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AcaoOnClick()

	IF oBrw:ColPos() == 1
		aDados[oBrw:nAt][1] := !aDados[oBrw:nAt][1]
	endif

Return
