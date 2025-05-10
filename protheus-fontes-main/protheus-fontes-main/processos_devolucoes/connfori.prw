#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} CONNFORI
@Type			: Função de Usuário
@Sample			: U_CONNFORI()
@Description	: Função que exibe browse dos documentos de saída do cliente/loja
                  de autorização de devolução (AUTDEV.PRW)
@Param			: Nenhum
@Return			: Lógico nOpcSel == 1
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2024
@version		: Protheus 12.1.2310 e posteriores
@Comments		: Nenhum
/*/
//--------------------------------------------------------------------------------------
User Function CONNFORI()

	Local aArea  	 := FWGetArea()
	Local cCadastro  := "Documentos de Saída"
	Local aRotOld    := IIF(Type('aRotina') == 'A', AClone(aRotina), {})
	Local aCampos    := {}
	Local aIndexSF2  := {}
	Local cFiltraSF2 := ''
	Local bFiltraBrw := {}
	Local nRecnoSF2  := 0
	Local cFilSF2    := ''

	Private nOpcSel  := 0

	aRotina := {}
	AAdd(aRotina, { "&Confirmar" ,"U__ConfSel",0,2,,,.T.})

	cFilSF2 := FWxFilial('SF2')
	cCodCli := M->ZH2_CODCLI
	cLojCli := M->ZH2_LOJCLI

	SF2->(DbSetOrder(1))
	cFiltraSF2 := "F2_FILIAL == '" + cFilSF2 + "' .And. "
	cFiltraSF2 += "F2_CLIENTE == '" + cCodCli + "' .And. "
	cFiltraSF2 += "F2_LOJA == '" + cLojCli + "' .And. "
	cFiltraSF2 += "F2_SERIE <> '' "

	bFiltraBrw := {|| FilBrowse("SF2",@aIndexSF2,@cFiltraSF2) }
	Eval(bFiltraBrw)

	MaWndBrowse(0,0,300,600,cCadastro,"SF2",aCampos,aRotina,,,,.T.)

	nRecnoSF2 := SF2->(Recno())
	aRotina   := AClone(aRotOld)

	// Finaliza o uso da funcao FilBrowse e retorna os indices padroes
	EndFilBrw("SF2",aIndexSF2)

	SF2->(dbGoTo(nRecnoSF2))

	FWRestArea(aArea)

Return( nOpcSel == 1 )


//-----------------------------------------------------------------------
/*/{Protheus.doc} _ConfSel
Funcao que Confirma seleção em browse específico
@Author     Evandro Mugnol
@Since      Nov/2024
@Comments	Nenhum
/*/
//-----------------------------------------------------------------------
User Function _ConfSel()

	nOpcSel := 1

	If Type("oWind") == "O"
		oWind:End()
	Else
		oWnd:End()
	EndIf

Return( Nil )
