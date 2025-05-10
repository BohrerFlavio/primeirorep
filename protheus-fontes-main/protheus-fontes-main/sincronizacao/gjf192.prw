#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF192     บ Autor ณ Giuliano Forgiarini Data ณ  04/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRotina de conexใo a base externa                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Giuliano Forgiarini                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GJF192(_cQuery)

	Private _cAliasBE := GetMV('SI_ALIASBE')  //Alias do database externo
	Private _cIPBE    := GetMV('SI_IPBE')     //Ip do servidor do database externo
	Private _nPortBE  := GetMV('SI_PORTBE')   //Porta do DBAccess par aconexใo com o database externo
	Private _lRet     := .t.

	// Instancia da Classe de Conexao ao TOTVSDBAcess
	oConx := FWDBAccess():New( _cAliasBE,_cIPBE,_nPortBE)

	//Habilita exibi็ใo dos erros no console do Protheus
	oConx:SetConsoleError(.T.)


	// Conexao com base Externa
	If !oConx:OpenConnection()
		ApMsgStop("Fuck!! Falha Conexใo com a base Externa - Erro: " + AllTrim( oConx:ErrorMessage() ))
		_lRet :=.f.
	elseif !oConx:HasConnection()
		ApMsgStop("Fuck!! Falha Conexใo com a base Externa - Erro: " + AllTrim( oConx:ErrorMessage() ))
		_lRet :=.f.
	else

		//Limpa os dados de erro
		FWDBAccess():ClearError()

		// Controlando transacao no outro lado
		oConx:TransBegin()
		If !oConx:SQLExec(_cQuery) // 'UPDATE ...', 'DELETE... ', etc.
			oConx:TransDisarm()
			_lRet :=.f.
		else
			oConx:TransEnd()

			//Finalizando uma conexใo
		EndIf

		oConx:CloseConnection()
		oConx:Finish() // <- Nao esquecer	
	EndIf
Return _lRet


//Fun็ใo de sincronia de retorno
User Function GF192b(_cQuery,_cAlias)

	Private _cAliasBE := GetMV('SI_ALIASBE')  //Alias do database externo
	Private _cIPBE    := GetMV('SI_IPBE')     //Ip do servidor do database externo
	Private _nPortBE  := GetMV('SI_PORTBE')   //Porta do DBAccess par aconexใo com o database externo
	Private _lRet     := .t.

	// Instancia da Classe de Conexao ao TOTVSDBAcess
	oConx := FWDBAccess():New( _cAliasBE,_cIPBE,_nPortBE)

	//Habilita exibi็ใo dos erros no console do Protheus
	oConx:SetConsoleError(.T.)


	// Conexao com base Externa
	If !oConx:OpenConnection()
		ApMsgStop("Fuck!! Falha Conexใo com a base Externa - Erro: " + AllTrim( oConx:ErrorMessage() ))
		_lRet :=.f.
	elseif !oConx:HasConnection()
		ApMsgStop("Fuck!! Falha Conexใo com a base Externa - Erro: " + AllTrim( oConx:ErrorMessage() ))
		_lRet :=.f.
	else

		//Limpa os dados de erro
		FWDBAccess():ClearError()

		oConx:NewAlias(_cQuery,_cAlias)
		If oConx:HasError()
			_lRet := .f.
		EndIf

		oConx:CloseConnection()
		oConx:Finish() // <- Nao esquecer	
	EndIf
Return _lRet
