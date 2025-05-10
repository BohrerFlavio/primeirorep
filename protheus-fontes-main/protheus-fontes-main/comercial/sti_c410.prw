#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOPCONN.CH" 

#DEFINE STR_PULA		Chr(13)+ Chr(10)

/*/{Protheus.doc} STI_C410
Rotina que efetua consulta da posição financeira do cliente informado no pré-pedido
@author 	Evandro Mugnol
@since 		16/10/2018
@return 	Nil, Função não tem retorno
@obs 		N/A
/*/

User Function STI_C410(_cCli,_cLoj) 

Local aArea   := GetArea()

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1") + _cCli + _cLoj)
If Found()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleção de dados ref. empenhos                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCTO, E1_VALOR, E1_SALDO, E1_NATUREZ AS DIAS_ATRASO, E1_NOMCLI "
	cQuery += "   FROM " + RetSqlTab("SE1")
	cQuery += "  WHERE " + RetSqlFil("SE1")
	cQuery += "    AND E1_CLIENTE = '" + _cCli + "'"
	cQuery += "    AND E1_LOJA = '" + _cLoj + "'"
	cQuery += "    AND E1_TIPO IN ('NF', 'RA', 'CH', 'CHP')
	cQuery += "    AND E1_SALDO > 0"
	cQuery += "    AND " + RetSqlDel("SE1")
	
	STI_C411(cQuery, "E1_NUM", "", "E1_VENCTO")
Else
	MsgAlert("Cliente ou Loja informados, inválidos. Verifique!")
Endif
RestArea(aArea)

Return( .T. )


/*/{Protheus.doc} STI_C411
Função para consulta genérica
@author 	Evandro Mugnol
@since 		16/10/2018
@version 	1.0
@param 		cConsSQLM, 	Caracter, Consulta SQL
@param 		cRetorM, 	Caracter, Campo que será retornado
@param 		cAgrupM, 	Caracter, Group By do SQL
@param 		cOrderM, 	Caracter, Order By do SQL
@return 	lRetorn, 	retorno se a consulta foi confirmada ou não
@example
lOK := U_STI_C411("SELECT B1_COD, B1_DESC FROM SB1010 WHERE D_E_L_E_T_ = ' ' ", "B1_COD", "", "B1_COD")
...
U_STI_C411("SELECT * FROM ZA0990", "ZA0_COD", "", "")
...
@obs O retorno da consulta é pública (__cRetorno) para ser usada em consultas específicas
A consulta não pode ter ORDER BY, pois ele já é especificado em um parâmetro
/*/

Static Function STI_C411(cConsSQLM, cRetorM, cAgrupM, cOrderM)

Local aArea   := GetArea()
Local nTamBtn := 50
Local oGrpPesqui
Local oGrpDados
Local oGrpAcoes
Local oBtnConf
Local oBtnLimp
Local oBtnCanc

// Privates
Private cConsSQL  := cConsSQLM
Private cCampoRet := cRetorM
Private cAgrup    := cAgrupM
Private cOrder    := cOrderM
Private nTamanRet := 0
Private aStruAux  := {}

// MsNewGetDados
Private oMsNew
Private aHeadAux := {}
Private aColsAux := {}

// Tamanho da janela
Private nJanLarg := 1000
Private nJanAltu := 0600

// Gets e Dialog
Private oDlgEspe
Private oGetPesq, cGetPesq := Space(100)

// Retorno
Private lRetorn    := .F.
Public  __cRetorno := ""

// Defaults
Default cConsSQLM := ""
Default cRetorM   := ""
Default cOrderM   := ""


// Se tiver o alias em branco ou não tiver campos
If Empty(cConsSQLM) .Or. Empty(cRetorM)
	MsgStop("SQL e / ou retorno em branco!", "Atenção")
	Return lRetorn
EndIf

// Criando a estrutura para a MsNewGetDados
fCriaMsNew()
__cRetorno := Space(nTamanRet)

// Criando a janela
DEFINE MSDIALOG oDlgEspe TITLE "Consulta Posição Financeira" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

// Pesquisar
@ 003, 003 GROUP oGrpPesqui TO 025, (nJanLarg/2)-3 PROMPT "Pesquisar: "	OF oDlgEspe COLOR 0, 16777215 PIXEL
@ 010, 006 MSGET oGetPesq VAR cGetPesq SIZE (nJanLarg/2)-12, 010 OF oDlgEspe COLORS 0, 16777215  VALID (fVldPesq())      PIXEL

// Dados
@ 028, 003 GROUP oGrpDados TO (nJanAltu/2)-28, (nJanLarg/2)-3 PROMPT "Títulos: "	OF oDlgEspe COLOR 0, 16777215 PIXEL
oMsNew := MsNewGetDados():New(035,;										//nTop
							  006,;										//nLeft
							  (nJanAltu/2)-31,;							//nBottom
							  (nJanLarg/2)-6,;							//nRight
							  GD_INSERT+GD_DELETE+GD_UPDATE,;			//nStyle
							  "AllwaysTrue()",;							//cLinhaOk
							  ,;										//cTudoOk
							  "",;										//cIniCpos
							  ,;										//aAlter
							  ,;										//nFreeze
							  999,;										//nMax
							  ,;										//cFieldOK
							  ,;										//cSuperDel
							  ,;										//cDelOk
							  oDlgEspe,;								//oWnd
							  aHeadAux,;								//aHeader
							  aColsAux)									//aCols                                    
oMsNew:lActive := .F.
oMsNew:oBrowse:blDblClick := {|| fConfirm()}
	
// Populando os dados da MsNewGetDados
fPopula()
	
// Ações
@ (nJanAltu/2)-25, 003 GROUP oGrpAcoes TO (nJanAltu/2)-3, (nJanLarg/2)-3 PROMPT "Ações: "			  OF oDlgEspe COLOR 0, 16777215  PIXEL
@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Confirmar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fConfirm()) PIXEL
//@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Limpar" 	SIZE nTamBtn, 013 OF oDlgEspe ACTION(fLimpar())  PIXEL
//@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*3)+12) BUTTON oBtnCanc PROMPT "Cancelar" 	SIZE nTamBtn, 013 OF oDlgEspe ACTION(fCancela()) PIXEL
	
oMsNew:oBrowse:SetFocus()

// Ativando a janela
ACTIVATE MSDIALOG oDlgEspe CENTERED

RestArea(aArea)

Return lRetorn


/*/{Protheus.doc} fCriaMsNew
Função para criar a estrutura da MsNewGetDados.
@author  	Evandro Mugnol
@since   	16/10/2018
@return		Nil
/*/

Static Function fCriaMsNew()

//Local aAreaX3 := SX3->(GetArea())
Local cQuery  := ""
Local nAtual  := 0

// Zerando o cabeçalho e a estrutura
aHeadAux := {}
aColsAux := {}

// Monta a consulta e pega a estrutura
cQuery := cConsSQL

// Group By
If !Empty(cAgrup)
	cQuery += cAgrup + STR_PULA
EndIf

// Order By
cQuery += " ORDER BY "	+ STR_PULA
If !Empty(cOrder)
	cQuery += "   "+cOrder
Else
	cQuery += "   "+cCampoRet
EndIf

TCQuery cQuery New Alias "QRY_DAD"
aStruAux := QRY_DAD->(DbStruct())
QRY_DAD->(DbCloseArea())

//DbSelectArea("SX3")
//SX3->(DbSetOrder(2)) // Campo
//SX3->(DbGoTop())

// Percorrendo os campos
For nAtual := 1 To Len(aStruAux)
	cCampoAtu := aStruAux[nAtual][1]

	// Se coneguir posicionar no campo
	If DbSeek(GetSx3Cache(cCampoAtu, 'X3_CAMPO'))
		// Cabeçalho ...	Titulo		Campo		Mask									Tamanho				Dec					Valid	Usado	Tip				F3	CBOX
		aAdd(aHeadAux,{	GetSx3Cache(cCampoAtu, 'X3_TITULO'),	cCampoAtu,	PesqPict(GetSx3Cache(cCampoAtu, 'X3_ARQUIVO'), cCampoAtu),	GetSx3Cache(cCampoAtu, 'X3_TAMANHO'),	GetSx3Cache(cCampoAtu, 'X3_DECIMAL'),	".F.",	".F.",	GetSx3Cache(cCampoAtu, 'X3_TIPO'),	"",	""})
		
		// Se o campo atual for retornar, aumenta o tamanho do retorno
		If cCampoAtu $ cCampoRet
			nTamanRet += GetSx3Cache(cCampoAtu, 'X3_TAMANHO')
		EndIf
	Else
		// Cabeçalho ...	Titulo									Campo		Mask	Tamanho					Dec						Valid	Usado	Tip						F3	CBOX
		aAdd(aHeadAux,{	Capital(StrTran(cCampoAtu, '_', ' ')),	cCampoAtu,	"",		aStruAux[nAtual][3],	aStruAux[nAtual][4],	".F.",	".F.",	aStruAux[nAtual][2],	"",	""})
		
		// Se o campo atual for retornar, aumenta o tamanho do retorno
		If cCampoAtu $ cCampoRet
			nTamanRet += aStruAux[nAtual][3]
		EndIf
	EndIf
Next

//RestArea(aAreaX3)

Return


/*/{Protheus.doc} fPopula
Função que popula a tabela auxiliar da MsNewGetDados.
@author  	Evandro Mugnol
@since   	16/10/2018
@return		Nil
/*/

Static Function fPopula()

Local cQuery := ""
Local nAtual := 0

aColsAux :={}
nCampAux := 1

// Faz a consulta
cQuery := cConsSQL + STR_PULA

// Se tiver Filtro
If !Empty(cGetPesq)
	If 'WHERE' $ cQuery
		cQuery += "   AND "
	Else
		cQuery += "   WHERE "
	EndIf
	cQuery += " ( "
	For nAtual := 1 To Len(aStruAux)
		cCampoAtu := aStruAux[nAtual][1]
		If aStruAux[nAtual][2] == 'C'
			cQuery += " UPPER("+cCampoAtu+") LIKE '%"+Upper(Alltrim(cGetPesq))+"%' OR"
		EndIf
	Next
	cQuery := SubStr(cQuery, 1, Len(cQuery)-2)
	cQuery += ")"+STR_PULA
EndIf

// Group By
If !Empty(cAgrup)
	cQuery += cAgrup + STR_PULA
EndIf

// Order By
cQuery += " ORDER BY "	+ STR_PULA
If !Empty(cOrder)
	cQuery += "   "+cOrder
Else
	cQuery += "   "+cCampoRet
EndIf

TCQuery cQuery New Alias "QRY_DAD"

// Percorrendo a estrutura, procurando campos de data
For nAtual := 1 To Len(aHeadAux)
	// Se for data
	If aHeadAux[nAtual][8] == "D"
		TCSetField('QRY_DAD', aHeadAux[nAtual][2], 'D')
	// Se for numérico
	ElseIf aHeadAux[nAtual][8] == "N"
		TCSetField('QRY_DAD', aHeadAux[nAtual][2], 'N', aHeadAux[nAtual][4], aHeadAux[nAtual][5])
	EndIf
Next

// Enquanto tiver dados
While ! QRY_DAD->(EoF())
	nCampAux := 1
	aAux := {}
	// Percorrendo os campos e adicionando no acols e com o delet
	For nAtual := 1 To Len(aStruAux)
		cCampoAtu := aStruAux[nAtual][1]
		
		If AllTrim(cCampoAtu) == "DIAS_ATRASO"
			_cDiasAtr := IIF( ( Date() - &("QRY_DAD->E1_VENCTO") ) > 0 , cValToChar( Date() - &("QRY_DAD->E1_VENCTO") ) , "Em dia")
			aAdd(aAux, _cDiasAtr)
		Else
			If aStruAux[nAtual][2] $ "N;D"
				aAdd(aAux,  &("QRY_DAD->"+cCampoAtu) )
			Else
				aAdd(aAux, cValToChar( &("QRY_DAD->"+cCampoAtu) ))
			EndIf
		Endif
	Next
	aAdd(aAux, .F.)

	aAdd(aColsAux, aClone(aAux))
	QRY_DAD->(DbSkip())
EndDo
QRY_DAD->(DbCloseArea())

// Se não tiver dados, adiciona linha em branco
If Len(aColsAux) == 0
	aAux := {}
	
	// Percorrendo os campos e adicionando no acols e com o delet
	For nAtual := 1 To Len(aStruAux)
		aAdd(aAux, '')
	Next
	aAdd(aAux, .F.)

	aAdd(aColsAux, aClone(aAux))
EndIf

// Posiciona no topo e atualiza grid
oMsNew:SetArray(aColsAux)
oMsNew:oBrowse:Refresh()

Return


/*/{Protheus.doc} fConfirm
Função de confirmação da rotina.
@author  	Evandro Mugnol
@since   	16/10/2018
@return		Nil
/*/

Static Function fConfirm()

Local aAreaX3 := SX3->(GetArea())
Local cAux := ""
Local aColsNov := oMsNew:aCols
Local nLinAtu  := oMsNew:nAt
Local nAtual

// Percorrendo os campos
For nAtual := 1 To Len(aHeadAux)
	cCampoAtu := aHeadAux[nAtual][2]

	// Se o campo atual for retornar, soma com o auxiliar
	If cCampoAtu $ cCampoRet
		cAux += aColsNov[nLinAtu][nAtual]
	EndIf
Next

// Setando o retorno conforme auxiliar e finalizando a tela
lRetorn := .T.
__cRetorno := cAux

// Se tiver retorno
If Len(__cRetorno) != 0
	// Se o tamanho for menor, adiciona
	If Len(__cRetorno) < nTamanRet
		__cRetorno += Space(nTamanRet - Len(__cRetorno))
	
	// Senão se for maior, diminui
	ElseIf Len(__cRetorno) > nTamanRet
		__cRetorno := SubStr(__cRetorno, 1, nTamanRet)
	EndIf
EndIf

oDlgEspe:End()
RestArea(aAreaX3)

Return


/*/{Protheus.doc} fLimpar
Função que limpa os dados da rotina.
@author  	Evandro Mugnol
@since   	16/10/2018
@return		Nil
/*/

Static Function fLimpar()

// Zerando gets
cGetPesq := Space(100)
oGetPesq:Refresh()

// Atualiza grid
fPopula()

// Setando o foco na pesquisa
oGetPesq:SetFocus()

Return


/*/{Protheus.doc} fCancela
Função de cancelamento da rotina.
@author  	Evandro Mugnol
@since   	16/10/2018
@return		Nil
/*/

Static Function fCancela()

//Setando o retorno em branco e finalizando a tela
lRetorn := .F.
__cRetorno := Space(nTamanRet)

oDlgEspe:End()

Return


/*/{Protheus.doc} fVldPesq
Função que valida o campo digitado.
@author  	Evandro Mugnol
@since   	16/10/2018
@return		Nil
/*/

Static Function fVldPesq()

Local lRet := .T.

// Se tiver apóstrofo ou porcentagem, a pesquisa não pode prosseguir
If "'" $ cGetPesq .Or. "%" $ cGetPesq
	lRet := .F.
	MsgAlert("<b>Pesquisa inválida!</b><br>A pesquisa não pode ter <b>'</b> ou <b>%</b>.", "Atenção")
EndIf

// Se houver retorno, atualiza grid
If lRet
	fPopula()
EndIf

Return lRet
