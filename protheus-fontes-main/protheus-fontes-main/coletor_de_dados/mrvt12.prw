#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT12     º Autor ³Mauricio Roehrsº   Data ³  18/11/15     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para apontamento da   º±±
±±º          ³ saida das camaras de resfriamento do Abate                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function MRVT12(_usuario)
	Private lOk       := .t. 
	Private _cModelo  := ''
	Private _cCod     := ''

	ZAA->(DbSetOrder(2))
	ZAA->(DbSeek(xfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL16 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	while lOk

		_cCod := Space(11)
		@ 01,05 VTSay "Controle de Saida"
		@ 02,05 VTSay "Das Camaras de"
		@ 03,05 VTSay "Resfriamento do Abate"
		@ 05,05 VTSay "Codigo da Carcaca"
		@ 06,07 VTSay "[           ]
		@ 06,08 VTGet _cCod Pict "@!" VALID vlCod()

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()
return

Static Function vlCod()

	_cNumam   := ''
	_cControl := ''
	
	if empty(_cCod)
		return .t.
	endif

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(9)) //num + numam + control
	if ZAJ->(DbSeek(xFilial('ZAJ')+alltrim(_cCod))) .and. len(alltrim(_cCod)) = 10

		if !empty(ZAJ->ZAJ_DTCORT) 		
			NaoAchou('Carcaça já escaneada!')			
			return .f.	
		endif

		if !empty(ZAJ->ZAJ_DATAS) .or. !empty(ZAJ->ZAJ_HORAS)
			NaoAchou('Carcaça fora de estoque!')		
			return .f.	
		endif	                              


		_cNumam 	 := ZAJ->ZAJ_NUMAM
		_cControl := ZAJ->ZAJ_CONTRO
		_cLado    := ZAJ->ZAJ_LADO

		if empty(ZAJ->ZAJ_ZAPNUM)
			ZAJ->(dbSetOrder(1))
			ZAJ->(dbSeek(xFilial('ZAJ') + _cNumam + _cControl))
			while ZAJ->(!eof()) .and. (xFilial('ZAJ') == ZAJ->ZAJ_FILIAL) .and. (ZAJ->ZAJ_NUMAM == _cNumam) .and. (ZAJ->ZAJ_CONTRO == _cControl)  	

				if ZAJ->ZAJ_LADO != _cLado
					ZAJ->(dbSkip())
					loop	   
				endif            

				//VTAlert(ZAJ->ZAJ_NUM + " | " + ZAJ->ZAJ_CONTRO + " | " + ZAJ->ZAJ_LADO,'Aviso!',.T.,2000,1)		
				reclock('ZAJ',.f.)               
				ZAJ->ZAJ_DTCORT := dDataBase
				msunlock()
				ZAJ->(dbSkip())	
			enddo      
		else
			reclock('ZAJ',.f.)               
			ZAJ->ZAJ_DTCORT := dDataBase
			msunlock()   
		endif
		simAchou()
		return .t.
	else
		NaoAchou('Carcaça não encontrada!')
		_cNumam   := ''
		_cControl := ''
	endif

return .f.      


Static Function NaoAchou(_cMens)

	VTBeep(1)
	vtLimpa()

	@09,00 VTSay Space(30)
	@10,00 VTSay "Cod. Etq.:   "+Space(30)
	@10,14 VTSay _cCod
	@11,00 VTSay ''+Space(30)
	@12,00 VTSay ''+Space(30)
	@13,00 VTSay ''+Space(30)
	@11,00 VTSay _cMens + Space(30)

	_cCod := Space(11)
return .f.  

Static Function SimAchou()

	vtLimpa() 

	@09,00 VTSay "CARCACA LIBERADA!"
	@10,00 VTSay "Cod. Etq.:   "
	@11,00 VTSay "Abate: "
	@12,00 VTSay "Sequencial:   "		
	@10,14 VTSay _cCod
	@11,14 VTSay _cNumam
	@12,14 VTSay _cControl

	_cCod := Space(11)
	_cNumam   := ''
	_cControl := ''
return .f.

Static Function vtLimpa()

	@09,00 VTSay Space(40)
	@10,00 VTSay Space(40)
	@10,14 VTSay Space(40)
	@11,00 VTSay Space(40)
	@12,00 VTSay Space(40)
	@13,00 VTSay Space(40)
	@11,00 VTSay Space(40)

return .f.
