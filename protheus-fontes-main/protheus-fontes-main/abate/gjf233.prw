#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF233     º Autor ³ AP6 IDE            º Data ³  09/10/15  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Função para calculo de pesos estimados para os cortes (ZAJ) º±±
±±º          ³com base em % da produção do abate                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Abate                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF233(_Numam)
	Local _nPercTras := GetMV('SI_%TRAS')
	Local _nPercDian := GetMV('SI_%DIAN')
	Local _nPercCost := GetMV('SI_%COST')
	Local _nPercCapo := GetMV('SI_%CAPO')
	Local _nPesoEst  := 0.00
	Local _nTotTras  := 0.00
	Local _nTotDian  := 0.00
	Local _nTotCost  := 0.00
	Local _nTotCapo  := 0.00 
	Local _nPesoT    := 0.00  //Peso total (-2% de frio)

	//Atualização de valores da tabela SZK 
	dbSelectArea("SZK")
	SZK->(dbSetOrder(4))
	if SZK->(MsSeek(FWxfilial('SZK') + _Numam))

		while SZK->(!eof()) .and. SZK->ZK_FILIAL = FWxfilial('SZK') .and. SZK->ZK_NUMAM = _Numam

			SZG->(DbSetOrder(1))
			if SZG->(MsSeek(FWxfilial('SZG') + _Numam))

				_nPesoT := SZK->ZK_PETOTAL - (SZK->ZK_PETOTAL * 0.02) //Calculo do peso total da carcaça -2% de frio

				_nTotTras += ( _nPesoT  * _nPercTras)
				_nTotDian += ( _nPesoT  * _nPercDian)
				_nTotCost += ( _nPesoT  * _nPercCost)
				_nTotCapo += ( _nPesoT  * _nPercCapo)

				if SZK->ZK_IF = 'S'
					reclock('SZK',.f.)
					if SZK->ZK_PETOTAL > 200  
						_nPesDesc := SZK->ZK_PETOTAL - 20
						SZK->ZK_PESDESC := _nPesDesc - (_nPesDesc *0.02)
					elseif SZK->ZK_PETOTAL <=200
						_nPesDesc := SZK->ZK_PETOTAL - 15
						SZK->ZK_PESDESC := _nPesDesc - (_nPesDesc *0.02)
					endif
					SZK->ZK_DESCONT := 'S'
					msunlock()
				else
					reclock('SZK',.f.)
					SZK->ZK_PESDESC := SZK->ZK_PETOTAL - (SZK->ZK_PETOTAL * 0.02)
					msunlock()
				endif

			endif

			SZK->(DbSkip())
		enddo

		SZG->(DbSetOrder(1))
		if SZG->(MsSeek(FWxfilial('SZG') + _Numam))
			reclock('SZG',.f.)
			SZG->ZG_QTTRAS := _nTotTras
			SZG->ZG_QTDIAN := _nTotDian
			SZG->ZG_QTCOST := _nTotCost
			SZG->ZG_QTCAPO := _nTotCapo
			msunlock()  
		endif
	endif

	//Atualização de valores da tabela ZAJ
	dbSelectArea("ZAJ")
	dbSetOrder(1)
	if ZAJ->(MsSeek(FWxfilial('ZAJ') + _Numam))
		While ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = FWxfilial('ZAJ') .and. ZAJ->ZAJ_NUMAM = _Numam

			SZK->(DbSetOrder(4))
			if SZK->(MsSeek(FWxfilial('SZK') + ZAJ->(ZAJ_NUMAM + ZAJ_CONTRO) ))   

				//_nPesoT := SZK->ZK_PETOTAL - (SZK->ZK_PETOTAL * 0.02) //Calculo do peso total da carcaça -2% de frio      
				_nPesoT := SZK->ZK_PESDESC

				if ZAJ->ZAJ_CORORI = 'T'
					_nPesoEst := (_nPesoT / 2) * _nPercTras 
				elseif ZAJ->ZAJ_CORORI = 'D'
					_nPesoEst := (_nPesoT / 2) * _nPercDian
				else
					_nPesoEst := (_nPesoT / 2) * _nPercCost
				endif

				reclock('ZAJ',.f.)
				ZAJ->ZAJ_PESOES := _nPesoEst
				msunlock()
			endif   
			ZAJ->(DbSkip())
		enddo
	endif
Return

//função para execblock gatilho do campo ZG_STATUS = 'E'
User function GF233E()
	MsgRun("Aguarde... Realizando processamento de registros... " + SZG->ZG_NUMAM ,,{||  u_GJF233(M->ZG_NUMAM) })
return .t.
