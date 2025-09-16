#INCLUDE "Rwmake.ch"  
#INCLUDE "Protheus.ch"   
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"   
#INCLUDE "tbiconn.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGFVT01     บ Autor ณGiuliano Forgiariniบ Data ณ  25/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Aplica็ใo para microterminais VT-100 para informar dados deบฑฑ
ฑฑบ          ณtipifica็ใo de carca็as durante o abate                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GFVT01()

	Local   _cLote    := ''
	Private _Lot      := ''
	Private _cNumam   := ''
	Private _lOk      := .t.
	Private _cModelo  := '' 
	Private _nAni     := 0
	Private _dData	  := stod("")

	//Prepara o ambiente para a rotina
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00' MODULO 'PCP' TABLES 'SZG','SZK','SZ4','SZD','SZE'

	//Define o tamanho da tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

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
		//    VTClear()
		//    VTClearBuffer()

		_cLote := Space(06)
		@ 02,00 VTSay "Digite numero do lote que"
		@ 03,00 VTSay "serแ produzido neste"
		@ 04,00 VTSay "momento:"
		@ 06,00 VTSay "Aviso de Matan็a nบ: " + _cNumam
		@ 09,00 VTSay "LOTE: [      ]"    //09
		@ 09,07 VTGet _cLote Pict "@!"
		@ 16,00 VTSay "ESC para Sair"
		VTRead
		If (VTLastKey() == 27)
			VTAlert('Aplica็ใo Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		SZ4->(DbSetOrder(1))

		_cLote := alltrim(_cLote)

		if len(_cLote) < 6  
			_cLote := padl(_cLote,6,'0') 
		endif

		if SZ4->(MsSeek(FWxfilial('SZ4')+_cNumam+_cLote))

			_nAni := SZ4->Z4_QUANT

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

					if  empty(SZK->ZK_COBGOR) .or. empty(SZK->ZK_DENT) .or. empty(SZK->ZK_CONFORM)
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

		SZK->(DbGoTop())
		SZK->(DbSetOrder(3))
		SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot))

		//Tip00()
		Tip01()

	EndDo

	VTClear()
	VTClearBuffer()

Return .t.


//Rotina para tipifica็ใo. 
//Realiza efetivamento os apontamentos.           
Static Function Tip01()

	//Local _nSeq  := 0
	//Local _lNovo := .f.
	local _cGord
	local _cDent
	local _cConf
	local _cRaca
	local _cProg
	local _cControl := ""

	SZK->(DbSetOrder(3))
	SZK->(DbGoTop())
	SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot))

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(17,30)
	endif

	aFields := {"ZK_LOTE","ZK_ORDEM","ZK_COBGOR","ZK_DENT","ZK_CONFORM"}
	aHeader := {'LOTE','ORD','GOR','DEN','CON'}
	aSize   := {06,03,03,03,03}

	DbSelectArea("SZK")

	_lOk := .t.

	SZK->(DbGoTop())
	SZK->(DbSetOrder(3))
	SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot))

	while _lOk

		If (VTLastKey() == 27)
			VTAlert('Opera็ใo Cancelada!','Aviso de Encerramento(03)',.T.,1000,1)
			exit
		EndIf

		SET FILTER TO SZK->ZK_NUMAM = _cNumam .and. SZK->ZK_LOTE = alltrim(_Lot)

		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"SZK",aHeader,aFields,aSize,"u_GVT01Tip",)

		SET FILTER TO

		if _lOk
			//_nSeq  := 0
			//_lNovo := .f.

			_nOrdem   := SZK->ZK_ORDEM
			_cControl := SZK->ZK_ITEM
			//Bloco para indexar por ordem interna do lote  

			SZK->(DbGoTop())
			SZK->(DbSetOrder(3))
			SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot+str(_nOrdem,3,0)))
			//Fim do bloco para indexar

			_cGord := SZK->ZK_COBGOR
			_cDent := SZK->ZK_DENT
			_cConf := SZK->ZK_CONFORM
			_cRaca := SZK->ZK_RACA
			_cProg := SZK->ZK_PROGRAM
			

			VTClear()
			VTClearBuffer()

			@ 02,00 VTSay "LOTE:       " + _Lot
			@ 03,00 VTSay "ORDEM LOTE: " + str(_nOrdem,3,0)			
			@ 05,00 VTSay "GORDURA:    [  ]"
			@ 06,00 VTSay "DENTICAO:   [ ]"
			@ 07,00 VTSay "CONFORMAวAO:[ ]"
			@ 08,00 VTSay "RACA:       [   ]"
			@ 09,00 VTSay "PROGRAMA:   [   ]"

			@ 16,00 VTSay "ESC para Sair"

			VTRead

			@ 05,13 VTGet _cGord Pict "@!" VALID ValGord(alltrim(_cGord))
			@ 06,13 VTGet _cDent Pict "@!" VALID (_cDent $ '02468') .or. empty(_cDent)
			@ 07,13 VTGet _cConf Pict "@!" VALID (_cConf $ '123')   .or. empty(_cConf)
			@ 08,13 VTGet _cRaca Pict "@!" VALID ValRaca(_cRaca)
			@ 09,13 VTGet _cProg Pict "@!" VALID ValProg(_cProg)			
			VTRead

			If (VTLastKey() == 27)
				VTAlert('Opera็ใo Cancelada!','Aviso de Encerramento(05)',.T.,500,1)
			else
				VTAlert('Confirma apontamento? (Enter:Sim,Esc:Nao)','Atencao',.T.)

				If (VTLastKey() == 27)
					VTAlert('Opera็ใo Cancelada!','Aviso de Encerramento(04)',.T.,500,1)
				else
					if  empty(_cGord) .and. empty(_cDent) .and. empty(_cConf)
						VTAlert('Nenhum campo preenchido!','Opera็ใo cancelada!',.T.,500,1) 
					else

						reclock('SZK',.F.)
						SZK->ZK_COBGOR     := iif(_cGord = "2.", "2+", _cGord)
						SZK->ZK_DENT       := _cDent
						SZK->ZK_CONFORM    := _cConf    						
						SZK->ZK_RACA       := _cRaca
						SZK->ZK_PROGRAM    := _cProg
						SZK->ZK_DATAABT    := _dData
						msunlock()

						//Comandos para avan็ar no sequencial 
						/*
						_nSeq++
						_cControl := strzero(_nSeq,6)
						*/
					endif
				EndIf

				_nOrdem := SZK->ZK_ORDEM
				//Bloco para posicionar no proximo registro ainda nใo preenchido
				SZK->(DbSetOrder(3))
				SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot))

				_nOrdem := 1

				while SZK->(!eof()) .and. ((FWxfilial('SZK')+_cNumam+_Lot) = SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE))

					if  !empty(SZK->ZK_COBGOR) .and. !empty(SZK->ZK_DENT) .and. !empty(SZK->ZK_CONFORM)
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

Return


// Valida็ใo da informa็ใo de gordura (alltrim(_cGord) $ '1|2|2+|3|4|5') .or. empty(_cGord)
Static Function ValGord(_cGord)

	if empty(_cGord)
		Return .F.
	elseif _cGord = '1'
		Return .T.
	elseif _cGord = '2'
		Return .T.
	elseif _cGord = '2.'
		Return .T.
	elseif _cGord = '3'
		Return .T.
	elseif _cGord = '4'
		Return .T.
	elseif _cGord = '5'
		Return .T.
	else
		Return .F.
	endif

Return

// Busca ๚ltimo sequencial do abate enviado por parโmetro
Static Function buscaSeq(_cNumam)
	Local _cQuery := ""
	Local _cRet   := {"000000",0,"000000"}

	_cQuery := "SELECT TOP (1) ZK_CONTROL AS SEQUENCIAL, ZK_ORDEM AS ORDEM, ZK_LOTE AS LOTE"
	_cQuery += " FROM " + retSqlTab('SZK') + " (NOLOCK)"
	_cQuery += " WHERE " + retSqlFil('SZK')
	_cQuery += " AND ZK_NUMAM = '" + _cNumam + "'"
	_cQuery += " AND ZK_CONTROL <> ''"
	_cQuery += " AND " + retSqlDel('SZK')
	_cQuery += " ORDER BY ZK_CONTROL DESC"

	_cQuery  := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbGoTop())

    If QRY->(!EOF())
        _cRet := {QRY->SEQUENCIAL, QRY->ORDEM, QRY->LOTE}
    endif

    QRY->(dbCloseArea())

Return _cRet

//Fun็ใo para validar o sequencial
Static Function ValSeq(_cSeq)

	SZK->(DbSetOrder(4))
	SZK->(DbGoTop())
	SZK->(MsSeek(FWxfilial('SZK')+_cNumam))

	_nCont := 0

	Do While SZK->(!eof()) .and. SZK->(ZK_FILIAL+ZK_NUMAM) == FWxFilial('SZK')+_cNumam
		_nCont++
		SZK->(DbSkip())
	Enddo

	SZK->(DbGoTop())
	SZK->(DbSetOrder(5))
	SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot))

	if _nCont < val(_cSeq)
		VTAlert('Sequencial impossํvel!!',str(_ncont),.T.,1000,1)
		ret := .f.
	else
		Ret := .t.
	endif

Return Ret


//Fun็ใo de usuแrio para interagir com a VTDBBrowse
User Function GVT01Tip(modo)    
	if VTLastkey()==27
		VTAlert('Opera็ใo Cancelada!','Aviso de Encerramento(02)',.T.,500,1) 
		//VTBeep(3)   
		_lOk := .f.
		return 0
	elseif VTLastkey()==13   
		return 1
	endif 

return   


//Fun็ใo para validar os programas
Static Function ValProg(cPr)

	if empty(cPr)
		return .t.
	endif 

	SZ6->(DbSetOrder(1))
	if SZ6->(MsSeek(FWxfilial('SZ6')+alltrim(cPr)))
		if SZ6->Z6_LISTA = 'S'
			VTAlert(alltrim(SZ6->Z6_DESC),'Programa',.T.,500,1)
			return .t.
		else
			VTAlert('Programa nใo Listado!','Erro',.T.,500,1)
			return .T. 
		endif
	else
		VTAlert('Programa Invแlido!','Erro',.T.,500,1)
		return .f. 
	endif

return .t.


//Fun็ใo para validar as ra็as
Static Function ValRaca(cRc)

	if empty(cRc)
		return .t.
	endif 

	ZA8->(DbSetOrder(1))
	if ZA8->(MsSeek(FWxfilial('ZA8')+alltrim(cRc)))
		VTAlert(alltrim(ZA8->ZA8_DESC),'Ra็a',.T.,500,1)
		return .t. 
	else
		VTAlert('Ra็a Invแlida!','Erro',.T.,500,1)
		return .f. 
	endif

return .t.


//Segunda rotina para tipifica็ใo. 
//Realiza efetivamento os apontamentos.        
Static Function Tip02()

	Local _nSeq  := 0
	Local _lNovo := .f.
	local _cRaca
	local _cProg 
	//local _cEsp  := ''   tirado Mateus 11/03/22

	SZK->(DbSetOrder(3))
	SZK->(DbGoTop())
	SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot))

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(17,30)
	endif

	aFields := {"ZK_LOTE","ZK_ORDEM","ZK_RACA","ZK_PROGRAM"}
	aHeader := {'LOTE','ORD','RACA','PROG'}
	aSize   := {06,03,03,03}

	DbSelectArea("SZK")

	_lOk := .t.

	SZK->(DbGoTop())
	SZK->(DbSetOrder(3))
	SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot))

	while _lOk

		If (VTLastKey() == 27)
			VTAlert('Opera็ใo Cancelada!','Aviso de Encerramento(03)',.T.,1000,1)
			//	_ok := .f.
			exit
		EndIf

		SET FILTER TO SZK->ZK_NUMAM = _cNumam .and. SZK->ZK_LOTE = alltrim(_Lot)

		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"SZK",aHeader,aFields,aSize,"u_GVT01Tip",)

		SET FILTER TO

		if _lOk
			_nSeq  := 0
			_lNovo := .f.
			_nOrdem      := SZK->ZK_ORDEM
			//Bloco para indexar por ordem interna do lote  

			SZK->(DbGoTop())
			SZK->(DbSetOrder(3))
			SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot+str(_nOrdem,3,0)))
			//Fim do bloco para indexar

			_cRaca := SZK->ZK_RACA
			_cProg := SZK->ZK_PROGRAM

			VTClear()
			VTClearBuffer()

			@ 02,00 VTSay "LOTE:       " + _Lot
			@ 03,00 VTSay "ORDEM LOTE: " + str(_nOrdem,3,0)
			@ 06,00 VTSay "RACA:       [   ]"
			@ 07,00 VTSay "PROGRAMA:   [   ]" 

			@ 16,00 VTSay "ESC para Sair"

			VTRead

			@ 06,13 VTGet _cRaca Pict "@!" VALID ValRaca(_cRaca)
			@ 07,13 VTGet _cProg Pict "@!" VALID ValProg(_cProg)

			VTRead

			If (VTLastKey() == 27)
				VTAlert('Opera็ใo Cancelada!','Aviso de Encerramento(05)',.T.,500,1)
			else
				VTAlert('Confirma apontamento? (Enter:Sim,Esc:Nao)','Atencao',.T.)

				If (VTLastKey() == 27)
					VTAlert('Opera็ใo Cancelada!','Aviso de Encerramento(04)',.T.,500,1)
				else

					reclock('SZK',.F.)
					SZK->ZK_RACA       := _cRaca
					SZK->ZK_PROGRAM    := _cProg  
					msunlock()
				EndIf

				_nOrdem := SZK->ZK_ORDEM
				//Bloco para posicionar no proximo registro ainda nใo preenchido
				SZK->(DbSetOrder(3))
				SZK->(MsSeek(FWxfilial('SZK')+_cNumam+_Lot))

				_nOrdem := 1

				while SZK->(!eof()) .and. ((FWxfilial('SZK')+_cNumam+_Lot) = SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE))
					_nOrdem++	
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

Return


//Rotina de menu para tipifica็ใo.        
Static Function Tip00()

	While _lOk

		_cOper := Space(01)
		@ 02,00 VTSay "Digite a op็ใo de opera็ใo"
		@ 03,00 VTSay "a ser realizada no processo:"
		@ 06,00 VTSay "Aviso de Matan็a nบ: " + _cNumam
		@ 09,00 VTSay "OPERAวรO: [ ]"   
		@ 09,12 VTGet _cOper Pict "@!" 
		@ 13,00 VTSay "1 - Tipifica็ใo Silva
		@ 14,00 VTSay "2 - Tipifica็ใo Externa
		@ 16,00 VTSay "ESC para Sair"
		VTRead
		If (VTLastKey() == 27)
			VTAlert('Aplica็ใo Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		if  _cOper = '1'
			Tip01()
		elseif  _cOper = '2'
			Tip02()
		endif

	EndDo

	VTClear()
	VTClearBuffer()

Return
