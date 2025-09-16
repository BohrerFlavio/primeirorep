#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} XMLCTE10
// Ponto de entrada Central XML - Verifica se registro é válido para ser exibido na tela
@author Marcelo Alberto Lauschner
@since 22/05/2019
@version 1.0
@return lRet , Logical, Retorna .T./.F. se o registro em cursor será adicionado

@type User Function
/*/
User Function XMLCTE10()
	Local	aAreaOld	:= GetArea()
	Local	lRet		:= .T. 
	Local	nOpcFil		:= ParamIxb
	
	
	If nOpcFil == 2	// Posicionado no cadastro de fornecedor
		If Empty(MV_PAR17)	
			If SA2->(FieldPos("A2_TIPORUR")) > 0 .And. Alltrim(SA2->A2_TIPORUR) $ "L#"
				lRet	:= .F.
			Else
				lRet	:= .T. 
			Endif
		Endif
		
	ElseIf nOpcFil == 3 // Posicionado no cadastro de Clientes 

	Endif
		
	// Se for rotina automática não executa o filtro 
	If lAutoExec
		lRet	:= .T. 
	Endif
	
	RestArea(aAreaOld)
	
Return	lRet
