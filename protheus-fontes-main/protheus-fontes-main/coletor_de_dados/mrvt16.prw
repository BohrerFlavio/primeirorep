#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT16     º Autor ³Fabian Maurerº   Data ³  08/07/19       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ Controle de Cameras Para Carcaças                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Função para Inventario
User Function MRVT16(_usuario)

	Private _cModelo  := ''
	Private _lOk      := .t.
	Private _cCod 	  := ''
	Private _cCam	  := space(2)
	Private _cListcam := GetMv("SI_CAMABT")  

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL21 <> 'S'
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

	while _lOk

		_cCod := Space(11)

		VTRead

		@ 01,00 VTSay "Localizacao Carcacas"
		@ 05,05 VTSay "Camera da Carcaca"
		@ 06,08 VTSay "["+_cCam+"]"
		@ 06,09 VTGet _cCam Pict "@!" VALID _cCam $ _cListCam//ValInv02()
		@ 07,05 VTSay "Codigo da Pesagem"
		@ 08,08 VTSay "[           ]"
		@ 08,09 VTGet _cCod Pict "@!" VALID ValInv01()

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

Return

Static Function ValInv01()

	if empty(_cCod)
		return .t.
	endif

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(2))
	if ZAJ->(MsSeek(FWxfilial('ZAJ')+alltrim(_cCod)))

		if !empty(ZAJ->ZAJ_DATAS) 
			u_gjf182hs(3,'M. Fora Est. Cam '+_cCam)
		endif

		if empty(ZAJ->ZAJ_DATAS)
			u_gjf182hs(3,'Localiz. Cam '+_cCam)
		endif

		Reclock('ZAJ',.f.)
		ZAJ->ZAJ_LOCAL := _cCam
		Msunlock()

		@09,00 VTSay "Carcaca Localizada!"
		@10,00 VTSay "Nr. Carcaca:   "
		@11,00 VTSay "Cod.Produto: "
		@12,00 VTSay "Descricao:   "
		@13,00 VTSay "Dt.Producao: "
		@14,00 VTSay "Dt.Corte: "
		@15,00 VTSay "Camara: "
		@10,13 VTSay _cCod
		@11,13 VTSay ZAJ->ZAJ_COD
		@12,13 VTSay ZAJ->ZAJ_DESCRI
		@13,13 VTSay ZAJ->ZAJ_DATA
		@14,13 VTSay ZAJ->ZAJ_DTCORT
		@15,13 VTSay _cCam
		_cCod := Space(11)
		Return .f.
	else
		NaoAchou('Carcaca Não Encontrada!')
		Return .f.
	endif

Return .f.

Static Function NaoAchou(_cMens)
	VTBeep(1)
	@09,00 VTSay Space(30)
	@10,00 VTSay "Cod. Carcaca:   "+Space(30)
	@10,11 VTSay _cCod
	@11,00 VTSay Space(30)
	@12,00 VTSay Space(30)
	@13,00 VTSay Space(30)
	@14,00 VTSay Space(30)
	@11,00 VTSay _cMens + Space(30)
	@15,00 VTSay Space(30)
	_cCod := Space(11)
return .f.

Static Function ValInv02()

	if empty(_cCam)
		return .t.
	endif

	NNR->(DbGoTop())
	NNR->(DbSetOrder(1))
	if NNR->(MsSeek(FWxfilial('NNR')+alltrim(_cCam)))
		Return .t.
	else
		NaoAchou2('Camara Nao Encontrada!')
		Return .f.
	endif

Return .f.

Static Function NaoAchou2(_cMens2)
	VTBeep(1)
	@09,00 VTSay Space(30)
	@10,00 VTSay "Cod. Camera:   "+Space(30)
	@10,11 VTSay _cCam
	@11,00 VTSay Space(30)
	@12,00 VTSay Space(30)
	@13,00 VTSay Space(30)
	@14,00 VTSay Space(30)
	@11,00 VTSay _cMens2 + Space(30)
	@15,00 VTSay Space(30)
	_cCam := Space(2)
return .f.

Static Function NaoAchou3(_cMens3)
	VTBeep(1)
	@09,00 VTSay Space(30)
	@10,00 VTSay "Cod. Carcaca:   "+Space(30)
	@10,11 VTSay _cCod
	@11,00 VTSay Space(30)
	@12,00 VTSay Space(30)
	@13,00 VTSay Space(30)
	@14,00 VTSay Space(30)
	@11,00 VTSay _cMens3 + Space(30)
	@15,00 VTSay Space(30)
	_cCod := Space(11)
return .f.
