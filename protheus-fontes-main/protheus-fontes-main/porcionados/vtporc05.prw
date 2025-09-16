#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³vtPorc05   º Autor ³Mauricio Roehrsº   Data ³  17/04/17     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ apontamento de caixas na saida da tavil, para porcionados  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Função para Inventario
User Function vtPorc05(_usuario)


	Private _cModelo  := ''
	Private _lOk      := .t.
	Private _cCod 	   := ''

	ZAA->(DbSetOrder(2))
	ZAA->(DbSeek(xfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL20 <> 'S'
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

		@ 01,00 VTSay "Apontamento de Producao"
		@ 05,07 VTSay "Codigo da Caixa"
		@ 06,08 VTSay "[           ]"
		@ 06,09 VTGet _cCod Pict "@!" VALID valida()

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

Static Function valida()

	if empty(_cCod)
		return .t.
	endif

	ZAS->(DbGoTop())
	ZAS->(DbSetOrder(1))
	if ZAS->(DbSeek(xfilial('ZAS')+alltrim(_cCod)))

		if !empty(ZAS->ZAS_APTPRD)
			NaoAchou('Caixa ja escaneada!')
			Return .f.
		endif

		if ZAS->ZAS_TIPO <> 'PA'
			NaoAchou('Caixa nao e de PA!')
			Return .f.	
		endif

		Reclock('ZAS',.f.)
		ZAS->ZAS_APTPRD := 'S'//produzida = SIM
		Msunlock()

		u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Apontamento de Produção", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

		@09,00 VTSay "APONTAMENTO CONFIRMADO!"
		@10,00 VTSay "Nr. Caixa:   "
		@11,00 VTSay "Cod.Produto: "
		@12,00 VTSay "Descricao:   "
		@10,13 VTSay _cCod
		@11,13 VTSay ZAS->ZAS_COD
		@12,13 VTSay ZAS->ZAS_DESC
		_cCod := Space(11)
		Return .f.

	else
		NaoAchou('Caixa não encontrada!')
		Return .f.
	endif


Return .f.

Static Function NaoAchou(_cMens)
	VTBeep(1)
	@09,00 VTSay Space(30)
	@10,00 VTSay "Cod. Cx:   "+Space(30)
	@10,11 VTSay _cCod
	@11,00 VTSay Space(30)
	@12,00 VTSay Space(30)
	@11,00 VTSay _cMens + Space(30)
	_cCod := Space(11)
return .f.


