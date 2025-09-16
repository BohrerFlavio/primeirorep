#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "totvsmail.ch"
#INCLUDE "ap5mail.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGJF54     บ Autor ณGiuliano Forgiarini บ Data ณ  07/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para emissใo de email a ser usada em registro de    บฑฑ
ฑฑบ          ณ ocorrencias no sistema                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ sigapcp                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GJF54(_cMens,_cTit,_cDest,_cArq)

	Local _cSMTP    := AllTrim(GetMV('MV_RELSERV')) //'webmail.frigorificosilva.com.br:587'     //SMTP servidor de email     
	Local _cRemet   := AllTrim(GetMV('MV_RELACNT')) //'workflow@frigorificosilva.com.br' 		//Email remetente
	Local _cUser    := AllTrim(GetMV('MV_RELACNT')) //'workflow@frigorificosilva.com.br' 		//Conta de usuแrio para logon
	Local _cPass    := AllTrim(GetMV('MV_RELPSW'))  //Senha para logon  - nova senha - FrigSilva@2018   -- old 'wfw%'   
	Local _aConnect := {}
	Local nTimeOut:= GetMv("MV_RELTIME",,120)
	Local lAutentica:= GetMv("MV_RELAUTH",,.F.)
	Local lEnviado := .F.

	//Conecta
	CONNECT SMTP SERVER _cSMTP ACCOUNT _cUser PASSWORD _cPass TIMEOUT nTimeOut Result lConectou

	aadd(_aConnect,lConectou)

	//Fun็ใo que efetiva o envio do email 
	If lAutentica                     
		lOk := MailAuth(_cRemet,_cPass)
	EndIf

	If lOk
		if empty(_cArq)
			Send Mail From _cRemet To _cDest Subject _cTit Body _cMens  Result lEnviado
		else
			Send Mail From _cRemet To _cDest Subject _cTit Body _cMens ATTACHMENT _cArq Result lEnviado
		endif
	elseif !lOk
		GET MAIL ERROR cErro
		MsgAlert(cErro)

	endif

	aadd(_aConnect,lEnviado)

	// Disconect
	DISCONNECT SMTP SERVER Result lDisConectou

	aadd(_aConnect,lDisConectou)

Return _aConnect    


User Function gjf54USR() 
	_cEmail := ''
	_aDados :={}    // Array de 2 dimens๕es.
	// a dimensao 1 contem os dados cadastrais do usuario
	// a dimensao 2 contem os dados de detalhe
	// a dimensao 3 contem os menus de cada modulo


	cCodusr :=  RetCodUsr()       
	PswOrder(1) // ordem de pesquisa por codigo
	if pswseek(cCodusr,.t.)  
		_aDados := pswret()
		_cEmail := alltrim(_aDados[1][14])
	endif
return _cEmail    


//Fun็ใo de teste
User Function gjf54T()
	//u_GJF54('Teste','setordti@frigorificosilva.com.br',)
	alert('OK!')
return
