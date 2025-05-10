#INCLUDE "rwmake.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MLR57     ºAutor  ³Mauricio Roehrs     º Data ³  08/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina responsavel pela importação dos dados do arquivo     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE/SIGAPON                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MLR57()
	Local _aArqTrb      := {}
	local _lOk := .f.
	Private aTela    	:= {}
	Private aStru    	:= {}
	Private aCampos  	:= {}
	Private cArq
	Private cIPerg  	:= "MLR57"
	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	if !pergunte(cIPerg,.t.)
		return
	endif

	geraTmp()
	Processa({|| _lOk := importa(mv_par01)} ,"PROCESSAMENTO DE REGISTROS","Importando arquivo de refeições...")
	if _lOk
		Confirma()
	endif

	/*
	DbSelectArea('TMP')
	TMP->(DbGoTop())
	DEFINE MSDIALOG oDlg TITLE 'Apontamento dos valores de vale transporte' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	@ 010,005 To 220,800 Browse "TMP" fields aCampos object oBrow

	oBrow:oBrowse:bldBlClick :=  {|| Excluir()}

	@aPosObj[2,3]-5,aPosObj[2,1] BUTTON btn01 PROMPT "Confirmar" 		   	OF oDlg 	SIZE 40,15 PIXEL ACTION Confirma()
	//@aPosObj[2,3]-5,aPosObj[2,1]+50 BUTTON btn02 PROMPT "Excluir" 				OF oDlg  SIZE 40,15 PIXEL ACTION Excluir()
	@aPosObj[2,3]-5,aPosObj[2,1]+100 BUTTON btn03 PROMPT "Sair"    			OF oDlg  SIZE 40,15 PIXEL ACTION oDlg:end()

	ACTIVATE MSDIALOG oDlg CENTERED
	*/

	TMP->(DbCloseArea())

	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb("FechaTodos",,,, @_aArqTrb) 

return

Static Function Excluir()

	local _cMat    := TMP->MAT
	local _dData   := TMP->DTIMP
	local _cHora   := TMP->HORA
	local _cCodRef := TMP->CODREF
	local _cTpRef  := TMP->TPREF

	DEFINE MSDIALOG oDlg2 TITLE 'Exclusao do Registro' from 000,000 To 125,200 OF oMainWnd PIXEL

	@ 015,018 SAY  'CONFIRMA A EXCLUSAO?' Object oSay1

	@ 040,008 BMPBUTTON TYPE 1 ACTION CnfExc(_cMat,_dData,_cHora,_cCodRef,_cTpRef) Object Obtn1
	//@ 060,040 BMPBUTTON TYPE 3 ACTION DesVal(_nValor) Object Obtn2
	@ 040,073 BMPBUTTON TYPE 2 ACTION oDlg2:end() Object Obtn3

	ACTIVATE MSDIALOG oDlg2 CENTERED

return


Static Function CnfExc(_cMat,_dData,_cHora,_cCodRef,_cTpRef)

	TMP->(DbGoTop())
	IndRegua("TMP",cArq,"MAT+DTOS(DTIMP)+HORA+CODREF+TPREF",,,OemToAnsi("Selecionando Registros..."))
	while TMP->(!eof())

		MsSeek(_cMat + dtos(_dData) + _cHora + _cCodRef + _cTpRef,.t.)
		if found()

			reclock('TMP',.f.)
			dbDelete()
			msunlock()

			exit
		endif

		TMP->(dbSkip())
	enddo

	oBrow:oBrowse:refresh()
	oDlg:refresh()
	odlg2:end()
return .t.

Static Function Confirma()

	Processa({||Gravar()} ,"PROCESSAMENTO DE REGISTROS","Efetivando a gravação dos registros...")

return


Static Function Gravar()

	local _nRegs := contagem()

	ProcRegua(_nRegs)
	dbSelectArea('ZB8')
	TMP->(dbGoTop())
	while TMP->(!eof())

		IncProc("Gravando registros...Matricula: "+Alltrim(TMP->MAT))

		SRA->(dbGoTop())
		SRA->(dbSetOrder(1))
		if SRA->(MsSeek(FWxFilial('SRA') + alltrim(TMP->MAT)))
			if SRA->RA_SITFOLH = 'D'//verifica se o funcionario está demitido
				if TMP->DTIMP > SRA->RA_DEMISSA //se a data de importação for
					TMP->(dbSkip())
					loop
				endif
			else
				if GeraQRY(TMP->MAT, TMP->DTIMP)
					TMP->(dbSkip())
					loop
				endif
			endif
		endif

		ZB8->(dbGoTop())
		ZB8->(dbSetOrder(10))
		if ZB8->(MsSeek(FWxFilial('ZB8') + TMP->MAT + dtos(TMP->DTIMP) + TMP->CODREF))	//procura se existem informações na tabela igual a do arquivo
			TMP->(DbSkip())
			loop
		endif

		_cNum := GetSx8num('ZB8','ZB8_NUM')
		ConfirmSX8()

		reclock('ZB8',.t.)
		ZB8->ZB8_FILIAL  := FWxFilial('ZB8')
		ZB8->ZB8_MAT 	 := TMP->MAT
		ZB8->ZB8_PD 	 := TMP->PD
		ZB8->ZB8_DATA 	 := TMP->DTIMP
		ZB8->ZB8_HORA 	 := TMP->HORA
		ZB8->ZB8_CODREF  := TMP->CODREF
		ZB8->ZB8_DSCREF  := TMP->DSCREF
		ZB8->ZB8_TPREF   := TMP->TPREF
		ZB8->ZB8_DESCTP  := TMP->DSCTP
		ZB8->ZB8_VLREF   := TMP->VLREF
		ZB8->ZB8_VLDSC   := TMP->VLDSC
		ZB8->ZB8_NUM     := _cNum
		ZB8->ZB8_CC      := TMP->CC
		ZB8->ZB8_TPIMP   := 'A'
		msunlock()

		_cRes := ''
		TMP->(dbSkip())
	enddo

	msgbox('Processo de ção concluído com sucesso!','OPERAÇÃO CONCLUIDA','INFO')

	_cNomeArq := retFileName(mv_par01)

	frename(mv_par01,'D:\OK_'+_cNomeArq+'.txt')

return

Static Function GeraQRY(_cMat, _dDtImp)

    _cQuery := "SELECT R8_MAT, R8_DATAINI, R8_DATAFIM, R8_SEQ"
	_cQuery += " FROM  " + retSqlTab('SR8')
    _cQuery += " WHERE " + retSqlFil('SR8')
    _cQuery += " AND R8_MAT = '" + _cMat + "'"
	_cQuery += " AND R8_DATAINI <= '" + dtos(_dDtImp) + "'"
	_cQuery += " AND R8_DATAFIM >= '" + dtos(_dDtImp) + "'"
	_cQuery += " AND " + retSqlDel('SR8')

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	//verifica se houve retorno na query
    Count to nCount

    If nCount > 0
        Return .T.
    endif

return .F.


static function contagem()

	local _nCont := 0

	TMP->(dbGoTop())
	while TMP->(!eof())

		_nCont++

		TMP->(dbSkip())
	enddo

return _nCont

Static Function geraTmp()

	//cArq  := CriaTrab( Nil, .F. )

	aadd(aCampos,{"MAT" 		,"Matricula"   						,""})
	aadd(aCampos,{"CODREF"  ,"Cod. Ref."							,""})
	aadd(aCampos,{"DSCREF"  ,"Descri. Ref."						,""})
	aadd(aCampos,{"TPREF"  	,"Tipo Ref."	   					,""})
	aadd(aCampos,{"DSCTP"  	,"Descri. Tipo Ref."					,""})
	aadd(aCampos,{"DTIMP"    ,"Data"      					 		,"99/99/99"})
	aadd(aCampos,{"HORA"    ,"Hora"  								,"99:99"})
	aadd(aCampos,{"VLREF"   ,"Valor Ref."       					,"@E 999.99"})
	aadd(aCampos,{"VLDSC"   ,"Valor Desc."       				,"@E 999.99"})
	aadd(aCampos,{"PD"      ,"Verba"					  				,""})
	aadd(aCampos,{"CC"      ,"Centro de Custo"	  				,""})

	aadd(aStru,{"MAT"  		, "C",  06,  0,   "@!"        	 	, 'Matricula'        })
	aadd(aStru,{"CODREF"   	, "C",  03,  0,   "@!"         		, 'Cod. Ref.'        })
	aadd(aStru,{"DSCREF"   	, "C",  40,  0,   "@!"         		, 'Descri. Ref.'     })
	aadd(aStru,{"TPREF" 		, "C",  03,  2,   "@!"  				, 'Tipo Ref.'        })
	aadd(aStru,{"DSCTP"   	, "C",  40,  0,   "@!"         		, 'Descri. Tipo Ref.'})
	aadd(aStru,{"DTIMP"   	, "D",  08,  0,   "99/99/99"        , 'Data'					})
	aadd(aStru,{"HORA"    	, "C",  05,  0,   "99:99"         	, 'Hora'					})
	aadd(aStru,{"VLREF"   	, "N",  05,  2,   "@E 999.99"       , 'Valor Ref.'			})
	aadd(aStru,{"VLDSC"   	, "N",  05,  2,   "@E 999.99"       , 'Valor Desc.'		})
	aadd(aStru,{"PD"  	 	, "C",  03,  0,   "@!"         		, 'Verba'				})
	aadd(aStru,{"CC"  	 	, "C",  09,  0,   "@!"         		, 'Centro de Custo'  })

	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	_aArqTrb    := {}
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {"MAT","CODREF","TPREF"}, @_aArqTrb)

	//dbcreate(cArq,aStru)
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	TMP->(DbGoTop())
	//IndRegua("TMP",cArq,"MAT+CODREF+TPREF",,,OemToAnsi("Selecionando Registros..."))

return


Static Function Importa(cArquivo)
	//Local aCabec  := {}
	//Local aItens  := {}
	//Local aCliente:= {}
	//Local aFornece:= {}
	Local nCont   := 0
	//LOCAL nHdl:= nHdlA := 0
	//Local nX
	//Local nTamFile, nTamLin, cBuffer, nBtLidos
	//Local lExiste := .T.
	//Local lHabil  := .F.
	Local _cRes := ''
	Local _cMatri := ''
	Private nHdl  := 0
	Private cEOL  := "CHR(8)"

	If Empty(Alltrim(cArquivo))
		Alert("Nao existem arquivos para importar. Processo ABORTADO")
		Return.F.
	EndIf

	//+---------------------------------------------------------------------+
	//| Abertura do arquivo texto                                           |
	//+---------------------------------------------------------------------+
	cArqTxt := cArquivo

	nHdl := fOpen(cArqTxt,0 )
	IF nHdl == -1
		IF FERROR()== 516
			ALERT("Feche o programa que gerou o arquivo.")
		EndIF
	EndIf

	//+---------------------------------------------------------------------+
	//| Verifica se foi possível abrir o arquivo                            |
	//+---------------------------------------------------------------------+
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArquivo+" nao pode ser aberto! Verifique os parametros.","Atencao!" )
		Return
	Endif

	FSEEK(nHdl,0,0 )
	nTamArq:=FSEEK(nHdl,0,2 )
	FSEEK(nHdl,0,0 )
	fClose(nHdl)

	FT_FUse(cArquivo )  //abre o arquivo
	FT_FGoTop()         //posiciona na primeira linha do arquivo

	nTamLinha := Len(FT_FREADLN() ) //Ve o tamanho da linha
	FT_FGOTOP()

	//+---------------------------------------------------------------------+
	//| Verifica quantas linhas tem o arquivo                               |
	//+---------------------------------------------------------------------+
	nLinhas := FT_FLastRec()

	ProcRegua(nLinhas)

	While !FT_FEOF()
		IF nCont > nLinhas
			exit
		endif

		IncProc("Lendo arquivo texto...Linha "+Alltrim(str(nCont)))

		cLinha := Alltrim(FT_FReadLn())
		nRecno := FT_FRecno() // Retorna a linha corrente

		//alert(cLinha)
		if !empty(cLinha )

			_cTpRef 	 := substr(cLinha,1,3)
			_cMat   	 := substr(cLinha,4,6)
			_dData  	 := stod(substr(cLinha,10,8))
			_cHora  	 := substr(cLinha,18,2)
			_cMin   	 := substr(cLinha,20,2)
			_cHraFull 	 := alltrim(_cHora) + ":" + alltrim(_cMin)
			_cCodRef  	 := Substr(cLinha,24,3)
			_cMatri 	 := _cMat

			if _cCodRef == '004'
				_cTpRef := '006'
			endif

			_cPd     := GetAdvFVal('ZB6','ZB6_PD',FWxFilial('ZB6') + _cCodRef,1)
			_cDscRef := GetAdvFVal('ZB6','ZB6_DESC',FWxFilial('ZB6') + _cCodRef,1)
			_cDscTp  := GetAdvFVal('ZB7','ZB7_DESCRI',FWxFilial('ZB7') + _cTpRef,1)
			_nVlRef  := GetAdvFVal('ZB7','ZB7_VLREF',FWxFilial('ZB7') + _cTpRef,1)
			_nVlDsc  := GetAdvFVal('ZB7','ZB7_VLDSC',FWxFilial('ZB7') + _cTpRef,1)
			_cCC     := GetAdvFVal('SRA','RA_CC',FWxFilial('SRA') + _cMat,1)

			if Substr(cLinha,22,2 ) <> cEmpAnt
				FT_FSKIP()
				nCont++
				loop
			Endif

			if empty(_cDscTp)
				FT_FSKIP()
				nCont++
				loop
			endif

			/* 
				Verificação para identificar se func.tem  cracha provisório ativo
			Caso tenha o sistema vai ler a matrícula provisória do arquivo do refeitório e vai gravar na matrícula permanente.
			 */
			_cRes := verfc(_cMat)

			if _cRes <> ''
				_cMatri := _cRes
			endif

			reclock('TMP',.t.)
			TMP->MAT 	:= _cMatri
			TMP->CODREF := _cCodRef
			TMP->DSCREF := alltrim(_cDscRef)
			TMP->TPREF 	:= _cTpRef
			TMP->DSCTP  := alltrim(_cDscTp)
			TMP->DTIMP  := _dData
			TMP->HORA   := alltrim(_cHraFull)
			TMP->VLREF  := _nVlRef
			TMP->VLDSC  := _nVlDsc
			TMP->PD 	:= _cPd
			TMP->CC     := _cCC
			msunlock()
		endif

		FT_FSKIP()
	EndDo

	FT_FUSE()
	fClose(nHdl )
Return .t.


Static Function verfc(_cMAT)
	Local _cMprov := ''

	dbSelectArea('SPE')
	SPE->(dbGoTop())
	while SPE->(!eof())

		if alltrim(_cMAT) = alltrim(SPE->PE_MATPROV)  //.and. DTOC(SPE->PE_DATAFIM) <= DTOC(Date())
			_cMprov := SPE->PE_MAT
			exit
		Else
			_cMprov := _cMAT
		Endif

		SPE->(dbSkip())
	enddo

Return _cMprov


