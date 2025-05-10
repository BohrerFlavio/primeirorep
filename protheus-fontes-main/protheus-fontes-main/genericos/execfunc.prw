#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} EXECFUNC 
@Type			: Função de Usuário
@Sample			: U_EXECFUNC()
@Description	: Fonte utilizado para montar uma tela para que seja executada uma função de usuário ou padrão
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Evandro Mugnol
@Since			: Nov/2021
@version		: Protheus 12.1.27 e posteriores
@Comments		: Exemplo de como chamar a função U_TESTE()
/*/
//--------------------------------------------------------------------------------------
User Function EXECFUNC()

	Local cString := Space(150)
	Local oGet1
	Local oDlg

	DEFINE MSDIALOG oDlg TITLE "Executar Programas" FROM C(178),C(181) TO C(323),C(543) PIXEL

	@ C(032),C(005) Say "Nome do programa / Função a ser executado" Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlg

	@ C(042),C(005) MsGet oGet1 Var cString Size C(171),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

	@ C(056),C(052) Button "Executar" Size C(037),C(012) PIXEL OF oDlg ACTION( { ExecutaStr( Alltrim(cString) ), oGet1:refresh() } )
	@ C(056),C(091) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

	ACTIVATE MSDIALOG oDlg CENTERED

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BacaProc
Função para validar o texto e executar
@Since      Nov/2021
@Param      cString, character, função que será executada
/*/
//-------------------------------------------------------------------
Static Function ExecutaStr(cString)

	If Empty( cString )
		MsgAlert("Comando a ser executado não informado. Verifique!")
		Return
	Endif

	If ( At( "(", cString ) <= 0 .And. At( ")", cString ) <= 0 )    // Não tem os parenteses
		cString := cString + "()"
	EndIf

	// Retira os espacos em qualquer lugar
	cString := StrTran( cString, " ", "" )

	If FindFunction(cString)
		&cString
	Else
		MsgAlert( "Função não existe no RPO !")
	EndIf

	cString := Space(100)

Return
