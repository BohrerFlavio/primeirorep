#INCLUDE "Rwmake.ch"  
#INCLUDE "Protheus.ch"   
#INCLUDE "Topconn.ch" 
#INCLUDE "tbiconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "totvs.ch"         
#INCLUDE "vkey.ch"                                                                           


/*/                                                                          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Replica Cadastro   º Autor ³ Flávio Bohrer Flôres  º Data ³ 05/10/20  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ 	 Tela de replicação de cadastro SA1010 para SA1070      			º±±
±±º          ³ OBS - Veio do Modelo da função Tela_controle                			º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Para controle de liberação do peso de alguns cortes        			º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function DTI109()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	private oFont     := tFont():New("courier new",,-28,,.t.,,,,)
	private oFont2    := tFont():New("courier new",,-24,,.t.,,,,)     
	private oFont3    := tFont():New("courier new",,-12,,.t.,,,,)     
	                  
	Private oTxtTitulo 	:= 'Replicação de cadastros'
	Private oTxtT2 		:= 'Cod. Cliente:'
	Private oTxtRetT  	:= ''
	Private oTxtRet2	:= ''
	Private oTxtBlT		:= ''
	Private oTxtRet3  	:= ''
	Private oTxtRet4  	:= ''
	Private oTxtRetD  	:= ''
	Private oTxtBlD		:= ''
	
	Private oTxtEmb		:= ''
	Private oTxtMds		:= ''
	Private valor 		:= space(06)
	Private _cClie 		:= space(08)
	
	Private campo		:= space(11)	
	Private _cGet3 		:= space(8)	
	
	//RPCSetType(3) //não consome licença.
	//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "PCP" TABLES "SA1"

	//DEFINE MSDIALOG oAut TITLE 'Acompanhamento de Cadastros' from 000,000 To 350,750  PIXEL
	DEFINE MSDIALOG oAut TITLE 'Acompanhamento de Cadastros' from 000,000 To 250,550  PIXEL
		
	/* Objetos das Etiquetas Internas EMB/MDS*/
	oSayTxtE 	:= tSay():New(095,020,{|| oTxtEmb	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)

	oGrupoL1 := tGroup():New(05, 10, 80, 250,'Acompanhamento da cópia', oAut,,, .t.)	
	
	/*  Tirar daqui os cadastros a serem incluidos e colocar no MSGET*/
	 
	oSayTxtTit 	:= tSay():New(015,035,{|| oTxtTitulo	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,60)
	oSayTxtTit 	:= tSay():New(035,035,{|| oTxtT2		},oAut,,oFont3,,,,.T.,CLR_BLACK,CLR_BLACK,350,60)
	
	
	_oGet3   := TGet():New(035,170, {|u| If(PCount() > 0, _cGet3:= u, _cGet3)}, oAut,, 009, "@!",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet3,,,,.t.,)
	/* Colocar botão */
	
	_oBtn01 := TButton():New(047, 46,"Executa"			, oAut,{|| replicar(_cGet3) },60,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn02 := TButton():New(047, 120, "Sair"           , oAut,{|| oAut:end() },60,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	// Liberação da rotina de Pré-Etiqueta
			
	_oBtn01:SetColor(CLR_WHITE,CLR_GREEN)
	_oBtn02:SetColor(CLR_WHITE,CLR_GREEN)
	
	
	ACTIVATE MSDIALOG oAut CENTERED

	//RESET ENVIRONMENT
Return

Static Function replicar(_cCLI)
	Private _cCliete := substr(_cCLI,1,6)
	Private _cLj	 := substr(_cCLI,7,2)
	

	 If cEmpAnt == "01"  // .And. cFilAnt == "00"
		_RepT(_cCLI)
		
	Endif
	
Return




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da funcao _ReplSA1                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _RepT (_cCliente)
	Local nI
	
	cAlias := 'SA1'
	cTemp  := "SA1070"
	cCli   := substr(_cCliente,1,6)
	cLoj   := substr(_cCliente,7,2)
	aEstruExp := (cAlias)->( dbStruct() )
	
	
	cQuery2 := " SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_NOME "+;                   
	" FROM  SA1070 "+;
	" WHERE SA1070.D_E_L_E_T_ <> '*' AND "+;
	"  SA1070.A1_COD    = '" + cCli + "' AND" +;  
	"  SA1070.A1_LOJA   = '" + cLoj + "'"
	
	cQuery := ChangeQuery(cQuery2)

		
	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif
	TCQUERY cQuery2 NEW ALIAS "TMP"
	TMP->(dbGoTop())
	
	If alltrim(TMP->A1_COD) = alltrim(cCli) .AND. alltrim(TMP->A1_LOJA) = alltrim(cLoj)
		oTxtRetT  := ''
		oTxtRet2  := ''
		//MsgInfo("Localizou cadastro na Transp! "+cCli+' - '+cLoj, "Aviso")
		
		oTxtRetT  := 'O Cliente - '+cCli+' Loja - '+cLoj+ ' foi Localizado. Não irá ser replicado!!'
		//oTxtRet2  += ' Verificar se o Cadastro está idêntico ao da Empresa Frigirífico Silva !!'
		
		oSayTxtLRT  := tSay():New(095,020,{|| oTxtRetT	},oAut,,oFont3,,,,.T.,CLR_HBLUE,CLR_WHITE,270,30) 
		oSayTxtLRT  := tSay():New(110,020,{|| oTxtRet2	},oAut,,oFont3,,,,.T.,CLR_HBLUE,CLR_WHITE,270,30) 
		oSayTxtLRT:CtrlRefresh() 
		

		oTxtRet3  := ''
		oTxtRet4  := ''
		oAut:refresh()
	else
		oTxtRetT  := ''
		oTxtRet2  := ''
		cQueryAux := "SELECT "
		For nI := 1 To Len( aEstruExp )
			If nI > 1
				cQueryAux += ", "
			EndIf
			cQueryAux += aEstruExp[ nI, 1 ]
		Next
	
		cQueryAux += ", D_E_L_E_T_, " + _CalcRecA1()
		cQueryAux += "FROM " + RetSqlName(cAlias) + " " + cAlias + " "
		cQueryAux += "WHERE " + "A1_FILIAL = '" + xFilial(cAlias) + "'"
		cQueryAux += "  AND " + "A1_COD    = '" + cCli + "'"
		cQueryAux += "  AND " + "A1_LOJA   = '" + cLoj + "'"
		cQueryAux += "  AND D_E_L_E_T_ = ' ' "
	
		cQueryAux := ChangeQuery(cQueryAux, .F.)
	
		
		cQuery := "INSERT INTO " + cTemp + " ( "
		For nI := 1 To Len( aEstruExp )
			If nI > 1
				cQuery += ", "
			EndIf
			cQuery += aEstruExp[ nI, 1 ]
		Next
	
		cQuery += ", D_E_L_E_T_, R_E_C_N_O_) " + cQueryAux
	
		If TCSqlExec( cQuery ) <> 0 
	
			dbCloseArea()
			Return ( .F. )
		EndIf
	
		TCRefresh(cTemp)
	
		// Atualiza A1_CONTRIB após cópia do cliente
		cContrib := "2"
		_cQuery := "UPDATE SA1070"
		_cQuery += " SET A1_CONTRIB = '" + cContrib + "' "
		_cQuery += " WHERE D_E_L_E_T_ <> '*'"
		_cQuery += " AND A1_COD    = '" + cCli + "' "
		_cQuery += " AND A1_LOJA   = '" + cLoj + "' "
		_cQuery += " AND A1_FILIAL = '  ' "
		TcSqlExec(_cQuery)
	
	
		// Atualiza A1_MSBLQL após cópia do cliente
		cMsBlQl := "2"
		_cQuery := "UPDATE SA1070"
		_cQuery += " SET A1_MSBLQL = '" + cMsBlQl + "' "
		_cQuery += " WHERE D_E_L_E_T_ <> '*'"
		_cQuery += " AND A1_COD    = '" + cCli + "' "
		_cQuery += " AND A1_LOJA   = '" + cLoj + "' "
		_cQuery += " AND A1_FILIAL = '  ' "
		TcSqlExec(_cQuery)
		
		
		// Atualiza A1_MSBLQL após cópia do cliente
		cDTINIV := date()
		_cQuery := "UPDATE SA1070"
		_cQuery += " SET A1_DTINIV = '" + DTOS(cDTINIV) + "' "
		_cQuery += " WHERE D_E_L_E_T_ <> '*'"
		_cQuery += " AND A1_COD    = '" + cCli + "' "
		_cQuery += " AND A1_LOJA   = '" + cLoj + "' "
		_cQuery += " AND A1_FILIAL = '  ' "
		TcSqlExec(_cQuery)
		
		
		oTxtRet3  := 'Cliente - '+cCli+' Loja - '+cLoj+ ' Ainda sem cadastrado na Transp. !! '		
		oTxtRet4  := 'O SISTEMA irá replicar o Cadastro'
		oSayTxtLRT  := tSay():New(095,020,{|| oTxtRet3 	},oAut,,oFont3,,,,.T.,CLR_RED,CLR_WHITE,270,30) 
		oSayTxtLRT  := tSay():New(110,020,{|| oTxtRet4 	},oAut,,oFont3,,,,.T.,CLR_RED,CLR_WHITE,270,30) 
		oSayTxtLRT:CtrlRefresh() 
	
		oTxtRetT  := ''
		oTxtRet2  := ''
		oAut:refresh()
	Endif 

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da funcao _CalcRecA1()                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _CalcRecA1()

	cQueryN := "SELECT MAX (R_E_C_N_O_) + 1 AS PROXREC FROM SA1070"

	TCQuery cQueryN New Alias _QRY
	_ProxRec := AllTrim(Str(_QRY->PROXREC))

	DbCloseArea()

Return(_ProxRec)


user function bacaSA1()

	_cQuery := " SELECT *  FROM  SA1010" 
	
	//alert('linha 279 - Inicio --')
	
	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if Select("TMP") != 0
		TMP->(dbCloseArea())
	endif

	TCQUERY _cQuery NEW ALIAS "TMP"
	
	
	TMP->(DbGoTop())
	while TMP->(!eof())
		
		//--------------------
		
			cQuery2 := " SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_NOME "+;                   
			" FROM  SA1070 "+;
			" WHERE SA1070.D_E_L_E_T_ <> '*' AND "+;
			"  SA1070.A1_COD    = '" + TMP->A1_COD + "' AND" +;  
			"  SA1070.A1_LOJA   = '" + TMP->A1_LOJA + "'"
			
			cQuery := ChangeQuery(cQuery2)
		
				
			If Select("TMP2") != 0
				TMP2->(dbCloseArea())
			Endif
			TCQUERY cQuery2 NEW ALIAS "TMP2"
			TMP2->(dbGoTop())
			IF Empty(alltrim(TMP2->A1_COD)+alltrim(TMP2->A1_LOJA))
				/* incluir na SA1070 */ 
				//alert( 'Cod.Cliente: '+TMP->A1_COD+' - Loja:'+TMP->A1_LOJA+' Ainda não cadastrado na Transp !!' )
			Endif
				//------------
			//dbCloseArea('TMP2')
		TMP->(dbSkip())
	enddo

	//dbCloseArea('SB1')
	//dbCloseArea('SB5')
	
	//alert('FEITOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO MAURO ')
return
