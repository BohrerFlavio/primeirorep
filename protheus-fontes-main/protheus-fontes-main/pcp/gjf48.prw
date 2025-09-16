#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF48 e pontos de entrada  Autor ³ AP6 IDE Data  01/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funções que montam o codigo EAN para os produtos de PA     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF48()

	if SB1->B1_TIPO $ 'PR/PA' .and. SB1->B1_MSBLQL = '2'
		if GetMV('SI_GLNSEQ') > 999 
			alert('OVERFLOW NUMERAÇÃO PARAMETRO SI_GLNSEQ')
		else
			_cGLN     := alltrim(GetMV('SI_GLN'))
			_cGLNSeq  := alltrim(strzero(GetMV('SI_GLNSEQ'),3))
			_cEAN12   := _cGLN + _cGLNSeq
			_cEANDig  := ''
			_cEAN13   := ''

			//Se o campo do codigo EAN 13 estiver em branco e o GLN estiver parametrizado então faz a geração do codigo
			if empty(SB1->B1_CODBAR) .and. !empty(_cGLN)
				//Pergunta para gerar o codigo caso o campo esteja em branco
				if  FWAlertYesNo('Gerar Codigo EAN 13? (S/N)','AJUSTE DE CODIGO DE BARRAS')
					_cEANDig := eandigito(_cEAN12)
					_cEAN13  := _cEAN12 + _cEANDig

					//SB1->(dbSetOrder(5))
					//SB1->(dbGoTop())
					if existchav('SB1',xfilial('SB1')+_cEAN13,5) //!SB1->(dbSeek(xFilial('SB1') + _cEAN13))
						reclock('SB1',.f.)
						SB1->B1_CODBAR := _cEAN13
						msunlock()

						PUTMV('SI_GLNSEQ',GetMV('SI_GLNSEQ')+1)

						FWAlertInfo('Codigo EAN 13 ' + _cEAN13 + ' gerado e cadastrado automaticamente!','AJUSTE DE CODIGO DE BARRAS')
					else
						FWAlertError('Produto com codificação EAN ' + _cEAN13 + ' já existente!','FALHA NA GERAÇÃO DO CODIGO EAN')
					endif
				endif
			endif
		endif
	endif

Return

//Função destinada a verificar o preenchimento dos campos 
// B1_CTARAP E B1_CTARASE caso o produto seja tipo = PA e
// sua segunda unidade de medida seja CX ou SC
// Alterado por Fabian Maurer em 25/08/11
User Function GJF48_2()
	Local _ret := .T.

	if cEmpAnt = '00'	
		If SB1->B1_TIPO <> 'PA'
			Return _ret
		Elseif !(SB1->B1_SEGUM $ 'CX/SC')
			Return _ret
		Endif

		If Empty(M->B1_CTARAP) .or. Empty(M->B1_CTARASE)
			Alert('Necessário fazer o preenchimento dos campos de codigo das taras para o CORRETO funcionamento da Embalagem!')
			_ret := .F.
		Endif
	endif

Return _ret
