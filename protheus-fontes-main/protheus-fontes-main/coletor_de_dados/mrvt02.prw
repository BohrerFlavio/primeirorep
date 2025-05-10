#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT02     º Autor ³Mauricio Roehrsº   Data ³  02/08/12     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ Inventario                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Função para Inventario
User Function MRVT02(_usuario)


	Private _cModelo  := ''
	Private _lOk      := .t.
	Private _cCod 	   := ''

	ZAA->(DbSetOrder(2))
	ZAA->(DbSeek(xfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL07 <> 'S'
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

		@ 01,00 VTSay "Inventario"
		@ 05,05 VTSay "Codigo da Pesagem"
		@ 06,08 VTSay "[           ]"
		@ 06,09 VTGet _cCod Pict "@!" VALID ValInv01()

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

	SZ8->(DbGoTop())
	SZ8->(DbSetOrder(3))
	if SZ8->(DbSeek(xfilial('SZ8')+alltrim(_cCod)))


		Reclock('SZ8',.f.)
		SZ8->Z8_INV := 'X'
		Msunlock()

		@09,00 VTSay "CAIXA INVENTARIADA!"
		@10,00 VTSay "Nr. Caixa:   "
		@11,00 VTSay "Cod.Produto: "
		@12,00 VTSay "Descricao:   "
		@13,00 VTSay "Dt.Producao: "
		@14,00 VTSay "Dt.Validade: "
		@15,00 VTSay "Pre-Etiq.:   "
		@10,13 VTSay _cCod
		@11,13 VTSay SZ8->Z8_COD
		@12,13 VTSay SZ8->Z8_DESCRI
		@13,13 VTSay SZ8->Z8_DATAP
		@14,13 VTSay SZ8->Z8_DATAVAL
		@15,13 VTSay SZ8->Z8_SEQPETQ
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
	@13,00 VTSay Space(30)
	@14,00 VTSay Space(30)
	@11,00 VTSay _cMens + Space(30)
	@15,00 VTSay Space(30)
	_cCod := Space(11)
return .f.


