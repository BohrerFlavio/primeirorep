#INCLUDE "Rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MRVT22    บ Autor ณ Adonai Gabriel บ  Data ณ     15/04/25  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Aplica็ใo para microterminais VT-100 para rotina de        บฑฑ
ฑฑบ          ณ entrada em estoque de caixas produzidas na Bizerba         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function MRVT22()

	Local   _cLote    := ''
	Private _Lot      := ''
	Private _cNumam   := ''
	Private _lOk      := .t.
	Private _cModelo  := '' 
	Private _nAni     := 0
	Private _dData	  := stod("")
	Private cBrinco   := ""

	//Define o tamanho da tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	DbSelectArea('SZG')
	SZG->(DbSetOrder(3))
	if !SZG->(MsSeek(FWxfilial('SZG')+'A'))
		VTAlert('Nใo hแ Abate!','Aviso',.T.,1000,1)
		return .t.
	endif

	_cNumam := SZG->ZG_NUMAM
	_dData  := SZG->ZG_DATA

	//La็o para realizar a opera็ใo
	//de escolha do lote e produ็ใo deste
	While _lOk

		_cLote := Space(06)
		@ 02,00 VTSay "Digite numero do lote que"
		@ 03,00 VTSay "serแ validado"
		@ 06,00 VTSay "Aviso de Matan็a nบ: " + _cNumam
		@ 09,00 VTSay "LOTE: [      ]"
		@ 09,07 VTGet _cLote Pict "@!"
		@ 16,00 VTSay "ESC para Sair"
		VTRead
		If (VTLastKey() == 27)
			VTAlert('Aplica็ใo Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		DbSelectArea('SZ4')
		SZ4->(DbSetOrder(1))

		_cLote := alltrim(_cLote)

		if len(_cLote) < 6  
			_cLote := padl(_cLote,6,'0') 
		endif

		if SZ4->(MsSeek(FWxfilial('SZ4')+_cNumam+_cLote))

			_nAni := SZ4->Z4_QUANT

			DbSelectArea('SZK')
			SZK->(DbSetOrder(3))
			If !SZK->(Msseek(FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)))
				//inclui registro na SZK caso ainda nใo existam
				u_pcp017sele(1)
			else
				//Verifica se o lote jแ foi produzido
				SZK->(DbSetOrder(3))
				SZK->(Msseek(FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE),.t.))

				lSreg := .t.

				Do while SZK->(!eof()) .and. SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE)==FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)

					if empty(SZK->ZK_BRINCO)
						lSReg := .f.
					endif

					SZK->(DbSkip())
				EndDo

				if lSreg
					VTAlert('Lote com produ็ใo encerrada!','Aten็ใo',.T.,500,1) 
					loop
				endif

				VTAlert('Lote com produ็ใo jแ iniciada!','Aten็ใo',.T.,500,1)  
			Endif
		else
			VTAlert('Lote nใo encontrado!','Erro',.T.,500,1)
			loop
		endif

		_Lot := _cLote

		DbSelectArea('SZK')
		SZK->(DbGoTop())
		SZK->(DbSetOrder(3))
		SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot))

		LeBrinco(_cNumam,_Lot)

		VTClear()
		VTClearBuffer()

	EndDo

	VTClear()
	VTClearBuffer()

Return .t.

//Realiza efetivamento os apontamentos.           
Static Function LeBrinco(_cNumam,_Lot)

	Local _cNumBr  := GetAdvFVal('ZRT','ZRT_NUM',FWXFilial('ZRT')+_cNumam+_Lot,1)
	Local _lDescl  := .f.

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(17,30)
	endif

	aFields := {"ZK_LOTE","ZK_ORDEM","ZK_BRINCO"}
	aHeader := {'LOTE','ORD','BRINCO'}
	aSize   := {06,03,15}

	_lOk := .t.

	DbSelectArea("SZK")
	SZK->(DbGoTop())
	SZK->(DbSetOrder(3))
	SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot))

	while _lOk

		If (VTLastKey() == 27)
			VTAlert('Opera็ใo Cancelada!','Aviso de Encerramento',.T.,1000,1)
			exit
		EndIf

		SET FILTER TO SZK->ZK_NUMAM = _cNumam .and. SZK->ZK_LOTE = alltrim(_Lot)

		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"SZK",aHeader,aFields,aSize,"u_GVT01Tip",)

		SET FILTER TO

		if _lOk

			_nOrdem  := SZK->ZK_ORDEM
			_lDescl  := .f.
			//Bloco para indexar por ordem interna do lote
			DbSelectArea("SZK")
			SZK->(DbGoTop())
			SZK->(DbSetOrder(3))
			SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot+str(_nOrdem,3,0)))
			//Fim do bloco para indexar

			cBrinco := SZK->ZK_BRINCO+" "

			VTClear()
			VTClearBuffer()

			@ 02,00 VTSay "LOTE:   " + _Lot
			@ 03,00 VTSay "ORDEM:  " + str(_nOrdem,3,0)
			@ 05,00 VTSay "BRINCO: [                ]"
			@ 16,00 VTSay "ESC para Sair"

			@ 05,09 VTGet cBrinco Pict "@!" VALID ValBrinco(alltrim(cBrinco))

			VTRead

			If (VTLastKey() == 27)
				VTAlert('Opera็ใo Cancelada!','Aviso de Encerramento',.T.,500,1)
			else
				If (VTLastKey() == 27)
					VTAlert('Opera็ใo Cancelada!','Aviso de Encerramento',.T.,500,1)
				else
					if RepBrinco(cBrinco,_cNumam,_Lot)
						VTAlert('Brinco jแ cadastrado! (Enter:Continuar)','Tente novamente!',.T.)
					else
						if VtYesNo("Brinco: " + cBrinco,"Confirma apontamento?",.T.)
							if !VerBrinco(cBrinco,_cNumam)
								VTAlert('Brinco nใo encontrado! Serแ desclassificado. (Enter:Continuar)','Aten็ใo!',.T.)
								_lDescl := .t.
							endif

							reclock('SZK',.F.)
								if _lDescl
									SZK->ZK_SINC := 'S'
								endif
								SZK->ZK_BRINCO := cBrinco
							msunlock()

							if GetAdvFVal('ZRI','ZRI_DIVGTA',FWXFilial('ZRI')+cBrinco+_cNumBr,2) = 'S'
								VTAlert('Sequencial com diverg๊ncia, serแ desclassificado. (Enter:Continua)','Aviso!',.T.)
							endif
						else
							VTAlert('Opera็ใo Cancelada!','Aviso',.T.,500,1)
							Return
						endif
					endif
				EndIf

				_nOrdem := SZK->ZK_ORDEM
				//Bloco para posicionar no proximo registro ainda nใo preenchido
				DbSelectArea("SZK")
				SZK->(DbSetOrder(3))
				SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot))

				_nOrdem := 1

				while SZK->(!eof()) .and. ((FWxfilial('SZK')+_cNumam+_Lot) = SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE))

					if !empty(SZK->ZK_BRINCO)
						_nOrdem++
					endif

					SZK->(DbSkip())
				enddo

				if _nAni < _nOrdem
					_nOrdem := _nAni
				endif

				SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot+str(_nOrdem,3,0)))
				//Fim do bloco
			endif
		endif

		VTClear()
		VTClearBuffer()

	enddo

	_lOk := .t.
	VTClear()
	VTClearBuffer()

Return

// Verifica se o brinco jแ foi cadastrado
Static Function RepBrinco(_cBrinco,_cNumam,_Lot)

	Local _cQuery   := ""
	Local nCount    := 0 
	Local _lRet     := .f.

	_cQuery := " SELECT ZK_BRINCO"
	_cQuery += " FROM " + retSqlTab('SZK') + "(NOLOCK)"
	_cQuery += " WHERE " + retSqlFil('SZK')
	_cQuery += " AND ZK_NUMAM = '" + _cNumam + "'"
	_cQuery += " AND ZK_LOTE = '" + _Lot + "'"
	_cQuery += " AND ZK_BRINCO = '" + _cBrinco + "'"
	_cQuery += " AND " + retSqlDel('SZK')

	cAlias := GetNextAlias()
	TCQuery _cQuery new alias &cAlias

	(cAlias)->(dbGoTop())

	//verifica se houve retorno na query
	Count to nCount

	If nCount > 0
		_lRet := .t.
	endif

	(cAlias)->(dbCloseArea())

Return _lRet

// Valida็ใo da informa็ใo de brinco
Static Function VerBrinco(_cBrinco,_cNumam)

	Local _cQuery   := ""
    Local nCount    := 0 
    Local _lRet     := .f.

    _cQuery := " SELECT ZRI_BRINCO"
    _cQuery += " FROM " + retSqlTab('ZRI') + "(NOLOCK)"
	_cQuery += " INNER JOIN " + retSqlTab('ZRT') + " (NOLOCK) ON (ZRI_NUM = ZRT_NUM)"
    _cQuery += " WHERE " + retSqlFil('ZRI') + " AND " + retSqlFil('ZRT')
    _cQuery += " AND ZRT_NUMAM = '" + _cNumam + "'"
    _cQuery += " AND ZRI_BRINCO = '" + _cBrinco + "'"
    _cQuery += " AND " + retSqlDel('ZRI') + " AND " + retSqlDel('ZRT')

    cAlias := GetNextAlias()
	TCQuery _cQuery new alias &cAlias

    (cAlias)->(dbGoTop())

    //verifica se houve retorno na query
    Count to nCount

    If nCount > 0
        _lRet := .t.
    endif

    (cAlias)->(dbCloseArea())

Return _lRet

// Valida็ใo da informa็ใo de brinco
Static Function ValBrinco(_cBrinco)

	if empty(_cBrinco)
		Return .F.
	elseif len(_cBrinco) < 15
		Return .F.
	else
		if len(_cBrinco) = 16
			cBrinco := substr(_cBrinco,2,15)
		else
			cBrinco := _cBrinco
		endif
		Return .T.
	endif

Return
