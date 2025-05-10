#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "totvs.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "APVT100.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºJF181   º Autor ³ Lucas Bolzan º Data ³  15/02/2023                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina de validação entre pré-etiqueta e etiqueta interna   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAPCP                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION MRVT21(_usuario)

	PRIVATE _lTela   := .t.
	PRIVATE _cModelo := ' '
	PRIVATE _cCaixa  := ""
	PRIVATE _lOk 	 := .F.

	ZZR->(DbSetOrder(3))
	ZZR->(DbGoTop())
	ZAA->(DbSetOrder(2))
	ZAA->(DbGoTop())
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))
	
	IF ZAA->ZAA_APL27 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		RETURN .t.
	ENDIF

	_cModelo = VTModelo()

	IF _cModelo <> 'RF'
		VTSetSize(2,16)
	ELSE
		VTSetSize(20,30)
	ENDIF

	VTClear()
	VTClearBuffer()

	WHILE _lTela
        _cNumPE   := Space(14) //CODIGO LIDO DA PRÉ-ETIQUETA
        _cNumEI   := Space(6)  //CODIGO LIDO DA ETIQUETA INTERNA
		_cCodProd := Space(14) //COD DO PRODUTO APÓS LEITURA DA ETIQUETA INTERNA

		@ 01,01 VTSay "Leitura da pre etiqueta:"
		@ 02,01 VTGet _cNumPE Pict "@!" VALID val(cValToChar(len(alltrim(_cNumPE)))) = 14
		@ 03,01 VTSay "Leitura da etiqueta interna:"
		@ 04,01 VTGet _cNumEI Pict "@!" VALID val(cValToChar(len(alltrim(_cNumEI)))) = 6

		VTRead
		//TRANSFORMA NUMEROS DA FAMILIA DO RAIO X PARA "0000"
		cPEdit := STRTRAN(_cNumPE, SUBSTR(_cNumPE, 3, 4), '0000')

		if ZZR->(MsSeek(FWxfilial('ZZR') + cPEdit))
			_cCodProd := ZZR->ZZR_COD
			_lOk := .T.
		else
			_cCodProd := ""
		endif

		IF (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,5,1)
			exit
		ENDIF

		_cCaixa := ZZR->ZZR_CONTRO

		ValidaRegras()
	ENDDO

	VTClear()
	VTClearBuffer()

RETURN


STATIC FUNCTION ValidaRegras()
	//Verifica se a numeração da Pré-etiqueta é 14
	IF (val(cValToChar(len(alltrim(_cNumPE)))) = 14)
		conout("Pre-Etiqueta " + _cNumPE + " com 14 digitos")
		//Verifica se a numeração da etiqueta interna é 6
		IF (val(cValToChar(len(alltrim(_cNumEI)))) = 6)
			conout("Etiqueta interna " + _cNumEI + " com 6 digitos")
			IF (_cCodProd = _cNumEI)
				conout("Etiqueta interna e produto com mesmo codigo")
				IF (_cCaixa = 'xxxxxxxxxx')
					conout("Pre Etiqueta bloqueada")
					VTAlert('Pre-etiqueta inutilizada. Rejeite será acionado', 'AVISO',.T.,3,1)
				ELSE
					conout("Impressao liberada")
					VTAlert('Impressao Liberada', 'AVISO',.T.,3,0)
					IF _lOk
						reclock('ZZR',.F.)
						ZZR->ZZR_REJ := .F.
						msunlock()
					ENDIF
				ENDIF
			ELSEIF (_cCodProd <> _cNumEI)
				conout("Etiqueta interna e produto nao tem o mesmo codigo")
				conout("Rejeite acionado")
				IF _lOk
					reclock('ZZR',.F.)
					ZZR->ZZR_REJ := .T.
					ZZR->ZZR_CONTROL := 'xxxxxxxxxx'
					msunlock()
				ENDIF
				VTAlert('Etiquetas não compativeis. Rejeite será acionado', 'AVISO',.T.,3,1)
			ELSE
				conout("Excessao nao planejada")
				VTAlert('HOUVE EXCECAO NÃO PLANEJADA', 'AVISO',.T.,3,1)
			ENDIF
		ELSE
			conout("Etiqueta interna " + _cNumEI + " nao tem 6 digitos")
			VTAlert("O nº inserido na etiqueta interna não contem 6 digitos" ,'Aviso',.T.,3,1)
		ENDIF
	ELSE
		conout("Pre-Etiqueta " + _cNumPE + " nao tem 14 digitos")
		VTAlert("O nº inserido na pré-etiqueta não contem 14 digitos" ,'Aviso',.T.,5,1)
	ENDIF

	_lOk := .F.

	conout("-----------------------------------------------------")

	VTClear()
	VTClearBuffer()

RETURN
