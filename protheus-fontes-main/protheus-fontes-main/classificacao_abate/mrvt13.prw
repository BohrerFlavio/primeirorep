#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT13     º Autor ³Mauricio Roehrs    º ³  22/01/14        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ apontamento de produção no setor de corte(Desmontagem)     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function MRVT13(_usuario)

	Local   _cDest    := ' '
	Private _cModelo  := '' 
	Private _lOk      := .t.
	Private _cCod 	   := ''
	Private _lTela    := .t.
	Private _cImp     := ' '
	Private _cIp      := ''
	Private _lTela2   := ''          
	Private _cOpc     := ' '            
	Private _cProd2    := Space(06)
	Private _cProd3    := Space(06)
	Private _cProd4    := Space(06)


	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL17 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da Tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	while _lTela

		_cImp := ' '

		VTRead        

		@ 01,05 VTSay "PRODUCAO DO CORTE(Desmonte)"
		@ 03,05 VTSay "Selecione a Opção"
		@ 04,05 VTSay "1:CORT.|2:DES. [ ]"  
		@ 16,00 VTSay "ESC para Sair"		   

		@ 04,21 VTGet _cImp Pict "@!" VALID _cImp $ '1/2'

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		//se for Corte
		if _cImp == '1'

			_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + 'ICRT1',1))

			//se for desossa
		elseif _cImp == '2'

			_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + 'IDSO2',1))

		endif

		VTClear()
		VTClearBuffer()

		_cImp := ' '

		while _lOk

			VTRead

			@ 01,05 VTSay "PRODUCAO DO CORTE(Desmonte)"
			@ 03,05 VTSay "Selecione a opcao"
			@ 04,08 VTSay "1:Produz:"
			//@ 05,08 VTSay "2:Reimprime:"
			@ 06,08 VTSay "[ ]"
			//@ 06,09 VTGet _cOpc Pict "@!" VALID _cOpc $ '1/2'
			@ 06,09 VTGet _cOpc Pict "@!" VALID _cOpc $ '1'
			@ 16,00 VTSay "ESC para Sair"
			VTRead

			If (VTLastKey() == 27)
				//VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
				exit
			EndIF

			if _cOpc = '1'
				_cDest := pickDest()
				if (_cDest $ '1/2/3')
					produz(_cDest)
				else
					VtMens('Dest. nao informado!')					
				endif
			//elseif _cOpc = '2'
			//	reimprime()		
			endif

			VTClearBuffer()
		enddo

		VTClear()
		VTClearBuffer()

	enddo

	VTClear()
	VTClearBuffer()

Return

Static Function reimprime()

	Private _lOk := .t.

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(11)

		VTRead

		@ 01,05 VTSay "PRODUCAO DO CORTE(Desmonte)"
		@ 03,05 VTSay "Codigo da Carcaça"
		@ 04,08 VTSay "[           ]"
		@ 04,09 VTGet _cCod Pict "@!" VALID setaCod(alltrim(_cCod))
		@ 16,00 VTSay "ESC para Sair"		
		VTRead

		If (VTLastKey() == 27)
			//VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		VTClearBuffer()
		_cCod := Space(11)
	enddo	

	VTClear()
	VTClearBuffer()

return

Static Function setaCod(_codBar)

	ZAJ->(dbSetOrder(10))
	ZAJ->(dbGoTop())
	if ZAJ->(MsSeek(FWxFilial('ZAJ') + alltrim(_codBar))) .and. len(alltrim(_codBar)) = 10 .and. _codBar <> '0000000000'
		while ZAJ->(!EOF()) .and. FWxFilial('ZAJ') == ZAJ->ZAJ_FILIAL .and. ZAJ->ZAJ_REGORI == alltrim(_codBar)
			vtImprime(ZAJ->ZAJ_NUM,ZAJ->ZAJ_NUMAM,ZAJ->ZAJ_LOTE,ZAJ->ZAJ_CONTRO,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_LADO,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_COD)
			ZAJ->(dbSkip())
		enddo
	else
		VtMens('Registro nao encontrado!')
		_cCod := space(11)
		return .f.
	endif

return .t.

Static function produz(_cDest)

	Private _lOk := .t.

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod1 := Space(11)
		_cCod2 := Space(11)
		_cCod3 := Space(11)
		_cLoc1 := Space(02)
		_cLoc2 := Space(02)
		_cLoc3 := Space(02)

		VTRead

		@ 01,05 VTSay "PRODUCAO DO CORTE(Enderec.)"
		@ 02,05 VTSay "Dest.:"+iif(_cDest = '1','Desossa',iif(_cDest = '2','Costela',iif(_cDest = '3','Carregamento','Sem Destino'))) 
		@ 03,05 VTSay "Cod. da Carcaça    Local"
		@ 04,06 VTSay "[           ]"
		@ 05,06 VTSay "[           ]"
		@ 06,06 VTSay "[           ]"
		@ 04,24 VTSay "[  ]"
		@ 05,24 VTSay "[  ]"
		@ 06,24 VTSay "[  ]"
		@ 04,07 VTGet _cCod1 Pict "@!" VALID ValCod1()
		@ 04,25 VTGet _cLoc1 Pict "@!" VALID ValLoc1()
		@ 05,07 VTGet _cCod2 Pict "@!" VALID ValCod2()
		@ 05,25 VTGet _cLoc2 Pict "@!" VALID ValLoc2()
		@ 06,07 VTGet _cCod3 Pict "@!" VALID ValCod3()
		@ 06,25 VTGet _cLoc3 Pict "@!" VALID ValLoc3()
		@ 16,00 VTSay "ESC para Sair"		
		VTRead

		If (VTLastKey() == 27)
			//VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		//setProd(ZAJ->ZAJ_COD, _cDest)

		_GrvZAW(_cCod1,_cLoc1,_cCod2,_cLoc2,_cCod3,_cLoc3,_cDest)

		VTClearBuffer()
		_cCod1 := Space(11)
		_cCod2 := Space(11)
		_cCod3 := Space(11)
		_cLoc1 := Space(02)
		_cLoc2 := Space(02)
		_cLoc3 := Space(02)

	enddo	

	VTClear()
	VTClearBuffer()

return     


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função para gravação das leituras na tabela ZAW      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _GrvZAW(_Num1,_Local1,_Num2,_Local2,_Num3,_Local3,_cDestino)
	
	// Efetua gravação da tabela ZAW caso o código da peça1 e local1 estejam informados
	If !Empty(_Num1) .And. !Empty(_Local1)
		DbSelectArea("ZAJ")
		DbGoTop()
		DbSetOrder(2)
		MsSeek(FWxFilial("ZAJ") + _Num1)
		If Found()
			_cNum    := ZAJ->ZAJ_NUM
			_cNumAm  := ZAJ->ZAJ_NUMAM
			_cLote   := ZAJ->ZAJ_LOTE
			_cContro := ZAJ->ZAJ_CONTRO
			_cProd   := ZAJ->ZAJ_COD
			_cDescri := ZAJ->ZAJ_DESCRI
			_cCorOri := ZAJ->ZAJ_CORORI
			_cOrigem := ZAJ->ZAJ_ZAPNUM
		Else
			_cNum    := Space(10)
			_cNumAm  := Space(08)
			_cLote   := Space(06)
			_cContro := Space(06)
			_cProd   := Space(14)
			_cDescri := Space(20)
			_cCorOri := Space(01)
			_cOrigem := Space(10)
		EndIf

		If Empty(_cOrigem)			// Movimentos de peças INTERNO
			DbSelectArea("SZK")
			DbGoTop()
			DbSetOrder(5)
			MsSeek(FWxFilial("SZK") + _cNumAm + _cLote + _cContro)
			If Found()
				_cLocal   := SZK->ZK_LOCAL
				_cClaAba  := SZK->ZK_CLASABA
				_cCobGor  := SZK->ZK_COBGOR
				_cDent    := SZK->ZK_DENT
				_cDestSZK := SZK->ZK_DESTINO
				_cProgram := SZK->ZK_PROGRAM
			Else
				_cLocal   := ""
				_cClaAba  := ""
				_cCobGor  := ""
				_cDent    := ""
				_cDestSZK := ""
				_cProgram := ""
			EndIf

			_dAbate := GetAdvFVal("SZG", "ZG_DATA", FWxFilial("SZG") + _cNumAm, 1, Space(TamSx3("ZG_DATA")[1]), .T.) 

			DO CASE
				CASE _cDestSZK == "R"
					_cRaca := "CONSERVA"
				CASE !Empty(_cOrigem)
					_cRaca := "TERCEIROS"
				CASE !Empty(_cProgram)
					_cRaca := GetAdvFVal("SZ6", "Z6_DESC", FWxFilial("SZ6") + _cProgram, 1, Space(TamSx3("Z6_DESC")[1]), .T.)
				OTHERWISE
					_cRaca := "BESTBEEF"
			ENDCASE

			DbSelectArea("ZAW")
			DbGoTop()
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAW") + _cNum + _cNumAm + _cContro + _cProd + _cCorOri)		// ZAW_FILIAL+ZAW_NUM+ZAW_NUMAM+ZAW_CONTRO+ZAW_COD+ZAW_CORORI
			If !Found()
				RecLock("ZAW", .T.)
				ZAW->ZAW_FILIAL := FWxFilial("ZAW")
				ZAW->ZAW_NUM    := _cNum
				ZAW->ZAW_CONTRO := _cContro
				ZAW->ZAW_COD    := _cProd
				ZAW->ZAW_DESCRI := _cDescri
				ZAW->ZAW_LOCAL  := _Local1
				ZAW->ZAW_CORORI := _cCorOri
				ZAW->ZAW_NUMAM  := _cNumAm
				ZAW->ZAW_LOTE   := _cLote
				ZAW->ZAW_DATA   := _dAbate
				ZAW->ZAW_DENT   := _cDent
				ZAW->ZAW_COBGOR := _cCobGor
				ZAW->ZAW_RACA   := _cRaca 
				ZAW->ZAW_CLAABA := _cClaAba
				ZAW->ZAW_DESTIN := _cDestino
				MsUnlock()
			EndIf
		Else						// Movimentos de peças TERCEIROS
			DbSelectArea("ZAP")
			DbGoTop()
			DbSetOrder(3)
			MsSeek(FWxFilial("ZAP") + _cOrigem)
			If Found()
				_cRaca := GetAdvFVal("ZA8", "ZA8_DESC", FWxFilial("ZA8") + ZAP->ZAP_RACA, 1, Space(TamSx3("ZA8_DESC")[1]), .T.)
			Else
				_cRaca := ""
			EndIf

			DbSelectArea("ZAW")
			DbGoTop()
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAW") + _cNum + _cNumAm + _cContro + _cProd + _cCorOri)		// ZAW_FILIAL+ZAW_NUM+ZAW_NUMAM+ZAW_CONTRO+ZAW_COD+ZAW_CORORI
			If !Found()
				RecLock("ZAW", .T.)
				ZAW->ZAW_FILIAL := FWxFilial("ZAW")
				ZAW->ZAW_NUM    := _cNum
				ZAW->ZAW_CONTRO := ""
				ZAW->ZAW_COD    := _cProd
				ZAW->ZAW_DESCRI := _cDescri
				ZAW->ZAW_LOCAL  := _Local1
				ZAW->ZAW_CORORI := _cCorOri
				ZAW->ZAW_NUMAM  := ""
				ZAW->ZAW_LOTE   := ""
				ZAW->ZAW_DATA   := Ctod("")
				ZAW->ZAW_DENT   := ""
				ZAW->ZAW_COBGOR := "" 
				ZAW->ZAW_RACA   := _cRaca 
				ZAW->ZAW_CLAABA := ""
				ZAW->ZAW_DESTIN := _cDestino
				MsUnlock()
			EndIf
		EndIf
	EndIf

	// Efetua gravação da tabela ZAW caso o código da peça2 e local2 estejam informados
	If !Empty(_Num2) .And. !Empty(_Local2)
		DbSelectArea("ZAJ")
		DbGoTop()
		DbSetOrder(2)
		MsSeek(FWxFilial("ZAJ") + _Num2)
		If Found()
			_cNum    := ZAJ->ZAJ_NUM
			_cNumAm  := ZAJ->ZAJ_NUMAM
			_cLote   := ZAJ->ZAJ_LOTE
			_cContro := ZAJ->ZAJ_CONTRO
			_cProd   := ZAJ->ZAJ_COD
			_cDescri := ZAJ->ZAJ_DESCRI
			_cCorOri := ZAJ->ZAJ_CORORI
			_cOrigem := ZAJ->ZAJ_ZAPNUM
		Else
			_cNum    := Space(10)
			_cNumAm  := Space(08)
			_cLote   := Space(06)
			_cContro := Space(06)
			_cProd   := Space(14)
			_cDescri := Space(20)
			_cCorOri := Space(01)
			_cOrigem := Space(10)
		EndIf

		If Empty(_cOrigem)			// Movimentos de peças INTERNO
			DbSelectArea("SZK")
			DbGoTop()
			DbSetOrder(5)
			MsSeek(FWxFilial("SZK") + _cNumAm + _cLote + _cContro)
			If Found()
				_cLocal   := SZK->ZK_LOCAL
				_cClaAba  := SZK->ZK_CLASABA
				_cCobGor  := SZK->ZK_COBGOR
				_cDent    := SZK->ZK_DENT
				_cDestSZK := SZK->ZK_DESTINO
				_cProgram := SZK->ZK_PROGRAM
			Else
				_cLocal   := ""
				_cClaAba  := ""
				_cCobGor  := ""
				_cDent    := ""
				_cDestSZK := ""
				_cProgram := ""
			EndIf

			_dAbate := GetAdvFVal("SZG", "ZG_DATA", FWxFilial("SZG") + _cNumAm, 1, Space(TamSx3("ZG_DATA")[1]), .T.) 

			DO CASE
				CASE _cDestSZK == "R"
					_cRaca := "CONSERVA"
				CASE !Empty(_cOrigem)
					_cRaca := "TERCEIROS"
				CASE !Empty(_cProgram)
					_cRaca := GetAdvFVal("SZ6", "Z6_DESC", FWxFilial("SZ6") + _cProgram, 1, Space(TamSx3("Z6_DESC")[1]), .T.)
				OTHERWISE
					_cRaca := "BESTBEEF"
			ENDCASE

			DbSelectArea("ZAW")
			DbGoTop()
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAW") + _cNum + _cNumAm + _cContro + _cProd + _cCorOri)		// ZAW_FILIAL+ZAW_NUM+ZAW_NUMAM+ZAW_CONTRO+ZAW_COD+ZAW_CORORI
			If !Found()
				RecLock("ZAW", .T.)
				ZAW->ZAW_FILIAL := FWxFilial("ZAW")
				ZAW->ZAW_NUM    := _cNum
				ZAW->ZAW_CONTRO := _cContro
				ZAW->ZAW_COD    := _cProd
				ZAW->ZAW_DESCRI := _cDescri
				ZAW->ZAW_LOCAL  := _Local2
				ZAW->ZAW_CORORI := _cCorOri
				ZAW->ZAW_NUMAM  := _cNumAm
				ZAW->ZAW_LOTE   := _cLote
				ZAW->ZAW_DATA   := _dAbate
				ZAW->ZAW_DENT   := _cDent
				ZAW->ZAW_COBGOR := _cCobGor 
				ZAW->ZAW_RACA   := _cRaca 
				ZAW->ZAW_CLAABA := _cClaAba
				ZAW->ZAW_DESTIN := _cDestino
				MsUnlock()
			EndIf
		Else						// Movimentos de peças TERCEIROS
			DbSelectArea("ZAP")
			DbGoTop()
			DbSetOrder(3)
			MsSeek(FWxFilial("ZAP") + _cOrigem)
			If Found()
				_cRaca := GetAdvFVal("ZA8", "ZA8_DESC", FWxFilial("ZA8") + ZAP->ZAP_RACA, 1, Space(TamSx3("ZA8_DESC")[1]), .T.)
			Else
				_cRaca := ""
			EndIf

			DbSelectArea("ZAW")
			DbGoTop()
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAW") + _cNum + _cNumAm + _cContro + _cProd + _cCorOri)		// ZAW_FILIAL+ZAW_NUM+ZAW_NUMAM+ZAW_CONTRO+ZAW_COD+ZAW_CORORI
			If !Found()
				RecLock("ZAW", .T.)
				ZAW->ZAW_FILIAL := FWxFilial("ZAW")
				ZAW->ZAW_NUM    := _cNum
				ZAW->ZAW_CONTRO := ""
				ZAW->ZAW_COD    := _cProd
				ZAW->ZAW_DESCRI := _cDescri
				ZAW->ZAW_LOCAL  := _Local2
				ZAW->ZAW_CORORI := _cCorOri
				ZAW->ZAW_NUMAM  := ""
				ZAW->ZAW_LOTE   := ""
				ZAW->ZAW_DATA   := Ctod("")
				ZAW->ZAW_DENT   := ""
				ZAW->ZAW_COBGOR := "" 
				ZAW->ZAW_RACA   := _cRaca 
				ZAW->ZAW_CLAABA := ""
				ZAW->ZAW_DESTIN := _cDestino
				MsUnlock()
			EndIf
		EndIf
	EndIf

	// Efetua gravação da tabela ZAW caso o código da peça3 e local3 estejam informados
	If !Empty(_Num3) .And. !Empty(_Local3)
		DbSelectArea("ZAJ")
		DbGoTop()
		DbSetOrder(2)
		MsSeek(FWxFilial("ZAJ") + _Num3)
		If Found()
			_cNum    := ZAJ->ZAJ_NUM
			_cNumAm  := ZAJ->ZAJ_NUMAM
			_cLote   := ZAJ->ZAJ_LOTE
			_cContro := ZAJ->ZAJ_CONTRO
			_cProd   := ZAJ->ZAJ_COD
			_cDescri := ZAJ->ZAJ_DESCRI
			_cCorOri := ZAJ->ZAJ_CORORI
			_cOrigem := ZAJ->ZAJ_ZAPNUM
		Else
			_cNum    := Space(10)
			_cNumAm  := Space(08)
			_cLote   := Space(06)
			_cContro := Space(06)
			_cProd   := Space(14)
			_cDescri := Space(20)
			_cCorOri := Space(01)
			_cOrigem := Space(10)
		EndIf

		If Empty(_cOrigem)			// Movimentos de peças INTERNO
			DbSelectArea("SZK")
			DbGoTop()
			DbSetOrder(5)
			MsSeek(FWxFilial("SZK") + _cNumAm + _cLote + _cContro)
			If Found()
				_cLocal   := SZK->ZK_LOCAL
				_cClaAba  := SZK->ZK_CLASABA
				_cCobGor  := SZK->ZK_COBGOR
				_cDent    := SZK->ZK_DENT
				_cDestSZK := SZK->ZK_DESTINO
				_cProgram := SZK->ZK_PROGRAM
			Else
				_cLocal   := ""
				_cClaAba  := ""
				_cCobGor  := ""
				_cDent    := ""
				_cDestSZK := ""
				_cProgram := ""
			EndIf

			_dAbate := GetAdvFVal("SZG", "ZG_DATA", FWxFilial("SZG") + _cNumAm, 1, Space(TamSx3("ZG_DATA")[1]), .T.) 
			
			DO CASE
				CASE _cDestSZK == "R"
					_cRaca := "CONSERVA"
				CASE !Empty(_cOrigem)
					_cRaca := "TERCEIROS"
				CASE !Empty(_cProgram)
					_cRaca := GetAdvFVal("SZ6", "Z6_DESC", FWxFilial("SZ6") + _cProgram, 1, Space(TamSx3("Z6_DESC")[1]), .T.)
				OTHERWISE
					_cRaca := "BESTBEEF"
			ENDCASE

			DbSelectArea("ZAW")
			DbGoTop()
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAW") + _cNum + _cNumAm + _cContro + _cProd + _cCorOri)		// ZAW_FILIAL+ZAW_NUM+ZAW_NUMAM+ZAW_CONTRO+ZAW_COD+ZAW_CORORI
			If !Found()
				RecLock("ZAW", .T.)
				ZAW->ZAW_FILIAL := FWxFilial("ZAW")
				ZAW->ZAW_NUM    := _cNum
				ZAW->ZAW_CONTRO := _cContro
				ZAW->ZAW_COD    := _cProd
				ZAW->ZAW_DESCRI := _cDescri
				ZAW->ZAW_LOCAL  := _Local3
				ZAW->ZAW_CORORI := _cCorOri
				ZAW->ZAW_NUMAM  := _cNumAm
				ZAW->ZAW_LOTE   := _cLote
				ZAW->ZAW_DATA   := _dAbate
				ZAW->ZAW_DENT   := _cDent
				ZAW->ZAW_COBGOR := _cCobGor 
				ZAW->ZAW_RACA   := _cRaca 
				ZAW->ZAW_CLAABA := _cClaAba
				ZAW->ZAW_DESTIN := _cDestino
				MsUnlock()
			EndIf
		Else						// Movimentos de peças TERCEIROS
			DbSelectArea("ZAP")
			DbGoTop()
			DbSetOrder(3)
			MsSeek(FWxFilial("ZAP") + _cOrigem)
			If Found()
				_cRaca := GetAdvFVal("ZA8", "ZA8_DESC", FWxFilial("ZA8") + ZAP->ZAP_RACA, 1, Space(TamSx3("ZA8_DESC")[1]), .T.)
			Else
				_cRaca := ""
			EndIf

			DbSelectArea("ZAW")
			DbGoTop()
			DbSetOrder(1)
			MsSeek(FWxFilial("ZAW") + _cNum + _cNumAm + _cContro + _cProd + _cCorOri)		// ZAW_FILIAL+ZAW_NUM+ZAW_NUMAM+ZAW_CONTRO+ZAW_COD+ZAW_CORORI
			If !Found()
				RecLock("ZAW", .T.)
				ZAW->ZAW_FILIAL := FWxFilial("ZAW")
				ZAW->ZAW_NUM    := _cNum
				ZAW->ZAW_CONTRO := ""
				ZAW->ZAW_COD    := _cProd
				ZAW->ZAW_DESCRI := _cDescri
				ZAW->ZAW_LOCAL  := _Local3
				ZAW->ZAW_CORORI := _cCorOri
				ZAW->ZAW_NUMAM  := ""
				ZAW->ZAW_LOTE   := ""
				ZAW->ZAW_DATA   := Ctod("")
				ZAW->ZAW_DENT   := ""
				ZAW->ZAW_COBGOR := "" 
				ZAW->ZAW_RACA   := _cRaca 
				ZAW->ZAW_CLAABA := ""
				ZAW->ZAW_DESTIN := _cDestino
				MsUnlock()
			EndIf
		EndIf
	EndIf

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função para inserção dos codigos de produtos que     ³
//³ que irão gerar registros na ZAJ e gerar Etiquetas    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function setProd(_prod,_cDest)

	//Local _cConf       := ' '
	Local _cProd1      := alltrim(_prod)
	Private _lOk       := .t.

	VtLimpa()
	VTClearBuffer()
	while _lOk

		@ 06,00 VTSay "Prod.Etq.Orig. [      ]"
		@ 07,00 VTSay "Prod.[      ]"
		@ 08,00 VTSay "Prod.[      ]"
		@ 09,00 VTSay "Prod.[      ]"
		//@ 10,00 VTSay "Confirma? [ ]"

		@ 16,00 VTSay "ESC para Sair"
		@ 06,16 VTSay _cProd1
		@ 07,06 VTGet _cProd2 Pict "@!" VALID ValProd(_cProd2)
		//@ 10,11 VTGet _cConf  Pict "@!" VALID _cConf $ 'S/N/s/n'

		VTRead

		If (VTLastKey() == 27)
			//VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		//if _cConf $ 'S/s'
		VtGrava(_cProd1,_cProd2,_cProd3,_cProd4)
		VtDeleta(_cDest)
		//endif

		//_cProd1 := space(6)
		//_cProd2 := space(6)
		//_cProd3 := space(6)
		//_cProd4 := space(6)
		//_cConf  := ' '
		exit

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()
return   



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³              Valida Codigo de Produto               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValProd(_cCodProd)

	local _lFind := .f.

	if empty(_cCodProd)
		return .t.
	endif

	DbSelectArea('SB1')
	SB1->(DbGoTop())
	SB1->(DbSetOrder(1))
	if SB1->(MsSeek(FWxFilial('SB1') + _cCodProd))

		ZAJ->(DbGoTop())
		ZAJ->(DbSetOrder(2))
		if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod))) .and. len(alltrim(_cCod)) = 10
			if SB1->B1_CORORI != ZAJ->ZAJ_CORORI
				VTAlert('Corte de Origem do Produto Difere do Produto Lido!','Atenção',.T.,1500,1) 
				return .f.		
			endif	
		endif 

		if SB1->B1_MSBLQL != '2'
			VTAlert('Produto bloqueado, entre em contato com o PCP!','Atenção!',.T.,1500,1)
			return .f.   
		endif

		if SB1->B1_SEGUM != 'PC'
			VTAlert('Tipo do produto não está cadastrado como Peça!','Atenção!',.T.,1500,1)
			return .f.
		endif

		_lFind := findProds(_cCodProd) 

		return _lFind   	
	endif

	VTAlert('Codigo de Produto não encontrado ou não cadastrado!!','Atenção!',.T.,1000,1)

return .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³         Valida Codigo 1 Lido da Etiqueta             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValCod1()

	if empty(_cCod1)
		return .f.
	endif

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(2))                   
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod1))) .and. len(alltrim(_cCod1)) = 10
		/* VOLTAR
		if !empty(ZAJ->ZAJ_PREPED) .or. !empty(ZAJ->ZAJ_PRECAR) .or. !empty(ZAJ->ZAJ_ITEM)
			VtMens('Carcaça já carregada ou fora de estoque!')
			_cCod := space(11)
			return .f.
		endif

		if (!empty(ZAJ->ZAJ_DATAS) .or. !empty(ZAJ->ZAJ_HORAS)) .and. (empty(ZAJ->ZAJ_PREPED) .or. empty(ZAJ->ZAJ_PRECAR) .or. empty(ZAJ->ZAJ_ITEM))
			VtMens('Carcaça já produzida ou fora de estoque!')	
			_cCod := space(11)
			return .f.
		endif
		*/

		DbSelectArea("SZK")
		DbSetOrder(5)
		MsSeek(FWxFilial("SZK") + ZAJ->ZAJ_NUMAM + ZAJ->ZAJ_LOTE + ZAJ->ZAJ_CONTRO)
		If Found()
			_cLoc1 := SZK->ZK_LOCAL
		EndIf

		return .t.//se retornar TRUE é pq não há nada de errado com a carcaça
	endif

	VtMens('Carcaça não identificada!')//se não entrar no if é pq não encontrou a carcaça e retorna FALSO
	_cCod1 := space(11)

return .f.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³         Valida Local 1 Digitado para Etiqueta        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValLoc1()                                  

	if empty(_cLoc1)
		return .f.
	endif

	NNR->(DbGoTop())
	NNR->(DbSetOrder(1))                   
	if !NNR->(MsSeek(FWxFilial('NNR') + alltrim(_cLoc1))) .and. len(alltrim(_cLoc1)) == 2
		VtMens('Local inexistente no cadastro!')
		_cLoc1 := space(02)
		return .f.
	endif

	return .t.	//se retornar TRUE é pq não há nada de errado com a carcaça

return .f.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³         Valida Codigo 2 Lido da Etiqueta             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValCod2()

	if empty(_cCod2)
		return .f.
	endif

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(2))
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod2))) .and. len(alltrim(_cCod2)) = 10
		/* VOLTAR
		if !empty(ZAJ->ZAJ_PREPED) .or. !empty(ZAJ->ZAJ_PRECAR) .or. !empty(ZAJ->ZAJ_ITEM)
			VtMens('Carcaça já carregada ou fora de estoque!')
			_cCod := space(11)
			return .f.
		endif

		if (!empty(ZAJ->ZAJ_DATAS) .or. !empty(ZAJ->ZAJ_HORAS)) .and. (empty(ZAJ->ZAJ_PREPED) .or. empty(ZAJ->ZAJ_PRECAR) .or. empty(ZAJ->ZAJ_ITEM)) 			
			VtMens('Carcaça já produzida ou fora de estoque!')	
			_cCod := space(11)
			return .f.
		endif
		*/

		DbSelectArea("SZK")
		DbSetOrder(5)
		MsSeek(FWxFilial("SZK") + ZAJ->ZAJ_NUMAM + ZAJ->ZAJ_LOTE + ZAJ->ZAJ_CONTRO)
		If Found()
			_cLoc2 := SZK->ZK_LOCAL
		EndIf

		return .t.//se retornar TRUE é pq não há nada de errado com a carcaça
	endif

	VtMens('Carcaça não identificada!')//se não entrar no if é pq não encontrou a carcaça e retorna FALSO
	_cCod2 := space(11)

return .f.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³         Valida Local 2 Digitado para Etiqueta        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValLoc2()

	if empty(_cLoc2)
		return .f.
	endif

	NNR->(DbGoTop())
	NNR->(DbSetOrder(1))
	if !NNR->(MsSeek(FWxFilial('NNR') + alltrim(_cLoc2))) .and. len(alltrim(_cLoc2)) == 2
		VtMens('Local inexistente no cadastro!')
		_cLoc2 := space(02)
		return .f.
	endif

	return .t.	//se retornar TRUE é pq não há nada de errado com a carcaça   

return .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³         Valida Codigo 3 Lido da Etiqueta             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValCod3()

	if empty(_cCod3)
		return .f.
	endif

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(2))
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod3))) .and. len(alltrim(_cCod3)) = 10
		/* VOLTAR
		if !empty(ZAJ->ZAJ_PREPED) .or. !empty(ZAJ->ZAJ_PRECAR) .or. !empty(ZAJ->ZAJ_ITEM)
			VtMens('Carcaça já carregada ou fora de estoque!')
			_cCod := space(11)
			return .f.
		endif

		if (!empty(ZAJ->ZAJ_DATAS) .or. !empty(ZAJ->ZAJ_HORAS)) .and. (empty(ZAJ->ZAJ_PREPED) .or. empty(ZAJ->ZAJ_PRECAR) .or. empty(ZAJ->ZAJ_ITEM))
			VtMens('Carcaça já produzida ou fora de estoque!')
			_cCod := space(11)
			return .f.
		endif
		*/

		DbSelectArea("SZK")
		DbSetOrder(5)
		MsSeek(FWxFilial("SZK") + ZAJ->ZAJ_NUMAM + ZAJ->ZAJ_LOTE + ZAJ->ZAJ_CONTRO)
		If Found()
			_cLoc3 := SZK->ZK_LOCAL
		EndIf

		return .t.//se retornar TRUE é pq não há nada de errado com a carcaça   
	endif

	VtMens('Carcaça não identificada!')//se não entrar no if é pq não encontrou a carcaça e retorna FALSO
	_cCod3 := space(11)

return .f.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³         Valida Local 3 Digitado para Etiqueta        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValLoc3()

	if empty(_cLoc3)
		return .f.
	endif

	NNR->(DbGoTop())
	NNR->(DbSetOrder(1))
	if !NNR->(MsSeek(FWxFilial('NNR') + alltrim(_cLoc3))) .and. len(alltrim(_cLoc3)) == 2
		VtMens('Local inexistente no cadastro!')
		_cLoc3 := space(02)
		return .f.
	endif

	return .t.	//se retornar TRUE é pq não há nada de errado com a carcaça   

return .f.


Static Function findProds(_prod)

	ZAT->(dbSetOrder(1))
	ZAT->(dbGoTop())
	if !ZAT->(MsSeek(FWxFilial('ZAT') + _prod))
		vtMens('Nao ha correlacao para este corte!')
		return .f.  
	else

		_cProd3 := ZAT->ZAT_CORTE2
		_cProd4 := ZAT->ZAT_CORTE3

		@ 08,06 VTSay _cProd3
		@ 09,06 VTSay _cProd4

	endif

return .t.

Static Function VtMens(_cMens)
	@11,00 VTSay Space(30)
	@12,00 VTSay "Nr. Peça:    "+Space(30)
	@12,11 VTSay _cCod
	@13,00 VTSay Space(30)
	@15,00 VTSay Space(30)
	@15,00 VTSay Space(30)
	@13,00 VTSay _cMens + Space(30)

	//_cCod := Space(11)
return .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³              Grava os dados nas Tabelas              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VtGrava(_cProd1,_cProd2,_cProd3,_cProd4,_cProd5)

	Local _nGrav := 0
	Local _aProd := {}
	Local i
	
	/*if !empty(_cProd1)
	_nGrav++
	aadd(_aProd,_cProd1)
	endif*/  

	if !empty(_cProd2)
		_nGrav++
		aadd(_aProd,_cProd2)
	endif

	if !empty(_cProd3)
		_nGrav++
		aadd(_aProd,_cProd3)
	endif

	if !empty(_cProd4)
		_nGrav++
		aadd(_aProd,_cProd4)
	endif

	/*     
	if !empty(_cProd5)
	_nGrav++
	aadd(_aProd,_cProd5)	
	endif
	*/

	if _nGrav > 0

		ZAJ->(DbGoTop())
		ZAJ->(DbSetOrder(2))
		if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod))) .and. len(alltrim(_cCod)) = 10
			for i:=1 to _nGrav

				_cControl := ZAJ->ZAJ_CONTRO
				_cCorOri  := ZAJ->ZAJ_CORORI
				_cNumam	 := ZAJ->ZAJ_NUMAM
				_cLote 	 := ZAJ->ZAJ_LOTE
				_cLado	 := ZAJ->ZAJ_LADO
				_cDiant	 := ZAJ->ZAJ_CDIAN
				_dDtCorte := ZAJ->ZAJ_DTCORT
				_cPredes  := ZAJ->ZAJ_PREDES
				_nPesPec  := ZAJ->ZAJ_PESO
				_cNumTerc := ZAJ->ZAJ_ZAPNUM
				_cNum 	 := GetSx8num('ZAJ','ZAJ_NUM')
				ConfirmSX8()     

				DbSelectArea('SB1')
				_cDescri 	:= GetAdvFVal('SB1',"B1_DESC",FWxfilial('SB1') + _aProd[i],1)
				_nPercPeso 	:= GetAdvFVal('SB1','B1_PERCQTD',FWxFilial('SB1')+_aProd[i],1) / 100
				_nPeso 		:= _nPercPeso * _nPesPec 

				reclock('ZAJ',.t.)
				ZAJ->ZAJ_FILIAL  := FWxfilial('ZAJ')
				ZAJ->ZAJ_CONTRO  := _cControl
				ZAJ->ZAJ_COD     := _aProd[i]
				ZAJ->ZAJ_DESCRI  := substr(_cDescri,1,20)
				ZAJ->ZAJ_CORORI  := _cCorOri
				ZAJ->ZAJ_NUMAM   := _cNumam
				ZAJ->ZAJ_LOTE    := _cLote
				ZAJ->ZAJ_NUM     := _cNum
				ZAJ->ZAJ_LADO    := _cLado
				ZAJ->ZAJ_NIVEL   := 1
				ZAJ->ZAJ_REGORI  := alltrim(_cCod)
				ZAJ->ZAJ_CDIAN   := _cDiant
				ZAJ->ZAJ_DATA    := ddatabase
				ZAJ->ZAJ_DTCORT  := _dDtCorte
				ZAJ->ZAJ_PREDES  := _cPredes
				ZAJ->ZAJ_PESO    := _nPeso	
				ZAJ->ZAJ_ZAPNUM  := _cNumTerc
				msunlock()
				//chama função de impressão
				VtImprime(_cNum,_cNumam,_cLote,_cControl,_cDescri,_cLado,_cDescri,_aProd[i])

			next
		endif
	endif

return      

Static Function VtLimpa()
	@09,00 VTSay Space(40)
	@10,00 VTSay Space(40)
	@11,00 VTSay Space(40)
	@12,00 VTSay Space(40)
	@13,00 VTSay Space(40)
	@14,00 VTSay Space(40)
	@15,00 VTSay Space(40)
	//_cCod := Space(11)
return .f.

Static Function VtDeleta(_cDest)

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(2))
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod))) .and. len(alltrim(_cCod)) = 10
		reclock('ZAJ',.f.)
		ZAJ->ZAJ_DATAS  := ddatabase
		ZAJ->ZAJ_HORAS  := time()
		ZAJ->ZAJ_DEST   := iif(_cDest = '1', 'D',;
		iif(_cDest = '2', 'C',;
		iif(_cDest = '3', 'R',''))) //1:Desossa|2:Costela|3:Carregamento|4:Sem destino"
		msunlock()
	endif

return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                 Imprime a Etiqueta                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VtImprime(_cNum,_cNumam,_cLote,_cControl,_cDescri,_cLado,_cDescri,_cProd)	//VtImprime(_cNum, _cProd)

	_Font01 	:= "60,60"
	_Font02 	:= "70,70"

	ZAJ->(dbSetOrder(2))
	ZAJ->(dbGoTop())
	if ZAJ->(MsSeek(FWxFilial('ZAJ') + alltrim(_cNum)))
		//primeiro verifica se é produto de terceiro
		if !empty(ZAJ->ZAJ_ZAPNUM)
			_cSif 		:= GetAdvFVal('ZAP','ZAP_SIF',FWxFilial('ZAP') + ZAJ->ZAJ_ZAPNUM,3)
			_cClassif 	:= GetAdvFVal('ZAP','ZAP_CLASSI',FWxFilial('ZAP') + ZAJ->ZAJ_ZAPNUM,3)
			_cCertif 	:= GetAdvFVal('ZAP','ZAP_CERT',FWxFilial('ZAP') + ZAJ->ZAJ_ZAPNUM,3)
			_dDataP     := GetAdvFVal('ZAP','ZAP_DATAP',FWxFilial('ZAP') + ZAJ->ZAJ_ZAPNUM,3)

			//conout(_cIp)

			u_geraEtq191(ZAJ->ZAJ_NUM,ZAJ->ZAJ_COD,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_LADO,_dDataP,_cSif,_cClassif,_cCertif,'',_cIp)
		else
			SZK->(dbSetOrder(4))
			SZK->(dbGoTop())
			if SZK->(MsSeek(FWxFilial('SZK') + ZAJ->ZAJ_NUMAM + ZAJ->ZAJ_CONTRO))

				_ZK_COBGOR 	:= SZK->ZK_COBGOR
				_ZK_DENT   	:= SZK->ZK_DENT
				_ZK_CONTROL := SZK->ZK_CONTROL
				_ZK_PROGRAM := SZK->ZK_PROGRAM
				_ZK_RASTRO	:= SZK->ZK_RASTRO
				_ZK_OBS		:= SZK->ZK_OBS
				_ZK_CATEG	:= SZK->ZK_CATEG
				_ZK_CLASSIF	:= SZK->ZK_CLASSIF
				_ZK_CLASESP	:= SZK->ZK_CLASESP

				dAbate := GetAdvFVal('SZG','ZG_DATA',FWxFilial('SZG')+ SZK->ZK_NUMAM,1)

			endif

			//MSCBPRINTER('S600','IP',,,,,_cIpImp)

			MSCBPRINTER('S600','IP',,,,,_cIp)
			MSCBCHKSTATUS(.f.)
			MSCBBEGIN(1,6)

			MSCBBOX(01,16,60,33)

			//Lado
			MSCBSAY(50, 17,ZAJ->ZAJ_LADO,"N","0","100,100")

			//Codigo de Barras
			MSCBSAYBAR(08,17,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,2,2,.t.)

			MSCBBOX(01,35,14,48)
			MSCBSAY(3, 36,'Gord',"N","E","8,8")
			MSCBSAY(6, 40,_ZK_COBGOR,"N","0",_Font01)

			MSCBBOX(17, 35,31,48)
			MSCBSAY(20, 36,'Dent',"N","E","8,8")

			MSCBSAY(23, 40,iif(_ZK_DENT = '0','DL',_ZK_DENT),"N","0",_Font01)

			MSCBBOX(34, 35,60,48)

			MSCBSAY(35, 36,'Cod.Prod.',"N","E","8,8")
			MSCBSAY(35, 40,_cProd,"N","0",_Font01)

			MSCBBOX(02,50,60,70)
			MSCBLINEV(39,50,70)
			MSCBLINEH(39,60,60)

			MSCBSAY(03, 52,'SEQ.',"N","E","8,8")
			MSCBSAY(13, 52,_ZK_CONTROL,"N","0",_Font02)

			_cDescri := ZAJ->ZAJ_DESCRI
			MSCBSAY(03, 62,substr(_cDescri,1,9),"N","0",_Font01)

			MSCBSAY(40, 52,'Abate',"N","E","8,8")
			MSCBSAY(40, 55,ZAJ->ZAJ_NUMAM,"N","E","8,8")

			MSCBSAY(40, 62,'Lote',"N","E","8,8")
			MSCBSAY(40, 66,ZAJ->ZAJ_LOTE,"N","E","8,8")

			MSCBBOX(02,72,60,77)
			MSCBSAY(02,73, GetMv("MV_NUMIF") + strtran(dtoc(dAbate),'/','') +'0000',"N","E","8,8")

			MSCBBOX(02,79,30,89)
			MSCBSAY(03,80,'SIF',"N","E","8,8")
			MSCBSAY(07,84,GetMv("MV_NUMIF"), "N","E","28,15")

			MSCBBOX(32,79,60,89)
			MSCBSAY(33,80,'Data Abate',"N","E","8,8")
			MSCBSAY(37,84,dtoc(dAbate),"N","E","28,15")

			nL := 125

			Private _cPrograma   := _ZK_PROGRAM
			Private nomePrograma := GetAdvFVal('SZ6', 'Z6_DESC', FWxFilial('SZ6')+_cPrograma, 1)

			MSCBBOX(02,93,60,98)
			If _ZK_OBS == '0'  //ok
				MSCBSAY(03,94, 'SISBOV:'+ _ZK_RASTRO ,"N","E","8,8")
			Endif
			_cCateg := GetAdvFVal('SZ5','Z5_DESC',FWxfilial('SZ5')+ _ZK_CATEG,1)
			if _ZK_PROGRAM = '006'
				MSCBBOX(02,100,60,109)
				MSCBSAY(03,101,_cCateg,"N","0",_Font01)// *** Verificar campo novo
				MSCBBOX(02,110,60,120)
				// caso M->ZK_COBGOR for = 1 colocar'ANGUS - MAGRO'
				MSCBSAY(10,111,'ANGUS',"N","0","90,105")
				MSCBBOX(02,124,60,144)// quadrado
				MSCBSAY(10,125,_ZK_CLASSIF,"N","0","180,300")
			else
				MSCBBOX(02,100,60,109)
				MSCBSAY(03,101,_cCateg,"N","0",_Font01)
				MSCBBOX(02,110,60,130)
				MSCBSAY(12,111,_ZK_CLASSIF,"N","0","162,270")
				If !Empty(nomePrograma) .and. nomePrograma != '001'
					MSCBSAY(03,138,substr(nomePrograma,1,10), "N","0","100,80")// aqui esta sendo modificado
				endif
			endif

			//Aqui imprime a Classificação Especial
			//if _ZK_CLASESP = '1' .and. (AllTrim(_ZK_CLASSIF) != 'NE' .or. AllTrim(_ZK_CLASSIF) != 'USA') .and. _ZK_DENT > '4'
			if _ZK_CLASESP = '2' .and. (AllTrim(_ZK_CLASSIF) != 'NE' .or. AllTrim(_ZK_CLASSIF) != 'BR') .and. _ZK_DENT > '4'
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,147,'HK',"N","0","200,200")
			elseif _ZK_CLASESP = '1' .and. AllTrim(_ZK_CLASSIF) = 'USA'
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,147,'USA',"N","0","200,200")
			elseif _ZK_CLASESP = '2' .and. AllTrim(_ZK_CLASSIF) = 'BR'
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,147,'BR',"N","0","200,200")
			elseif _ZK_CLASESP = '1' .and. AllTrim(_ZK_CLASSIF) != 'NE' .and. _ZK_DENT <= '4' 
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,148,'CN',"N","0","200,200")
			endif

			//****************************  FIM  *****************************************
			MSCBSAY(13,285,"DTI","N","0","100,190")

			MSCBEND()
			MSCBCLOSEPRINTER()
		endif

	endif
return


Static Function pickDest()

	//Local _cConf       := ' '
	//Local _cProd1      := alltrim(_prod)
	Local _cDest  := '0'
	Private _lOk  := .t.

	//VtLimpa()
	VTClearBuffer()
	while _lOk

		//@ 06,00 VTSay "Dest.:[ ]1:DES|2:COS|3:CAR|4:S/D"
		@ 06,00 VTSay "Dest.:[ ]1:DES|2:COS|3:CAR"

		@ 16,00 VTSay "ESC para Sair"
		@ 06,07 VTGet _cDest Pict "@!" VALID _cDest $ '1/2/3'

		VTRead

		If (VTLastKey() == 27)
			//VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		exit

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

return _cDest
