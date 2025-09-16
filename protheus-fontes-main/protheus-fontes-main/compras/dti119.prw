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
±±ºPrograma  ³Atualiza Cotações   º Autor ³ Flávio Bohrer Flôres  º Data ³ 14/03/21  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ 	 Rotina feita para atualizar cotação para gerar novamente 			º±±
±±º          ³ OBS - Veio do Modelo da função Replica Cadastro SA1070      			º±±
±±º          ³ OBS - Também conhecida como Colocar SC no AR , que consiste em   	º±±
±±º          ³  Voltar para gerar Cotação       					      			º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Para controle de liberação do peso de alguns cortes        			º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function DTI119()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	private oFont     := tFont():New("courier new",,-20,,.t.,,,,)
	private oFont2    := tFont():New("courier new",,-24,,.t.,,,,)     
	private oFont3    := tFont():New("courier new",,-12,,.t.,,,,)     
	                  
	//Private oTxtTitulo 	:= 'Replicação de cadastros'
	Private oTxtTitulo 	:= 'Atualizar P/Gerar Cotação Novamente'
	Private oTxtT2 		:= 'Nr da Solicitação de Compras (SC):'
	Private oTxtT3 		:= 'Item:'
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
	Private _cGet3 		:= space(6)
	Private _cGet4 		:= space(4)	

	
	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "PCP" 

	//DEFINE MSDIALOG oAut TITLE 'Acompanhamento de Cadastros' from 000,000 To 350,750  PIXEL
	DEFINE MSDIALOG oAut TITLE 'Acompanhamento Geração de Cotação' from 000,000 To 250,550  PIXEL
	
	
	/* Objetos das Etiquetas Internas EMB/MDS*/
	oSayTxtE 	:= tSay():New(095,020,{|| oTxtEmb	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)

	oGrupoL1 := tGroup():New(05, 10, 80, 250,'Limpeza da SC P/ Geração da Cotação', oAut,,, .t.)	
	
	/*  Tirar daqui os cadastros a serem incluidos e colocar no MSGET*/
	 
	oSayTxtTit 	:= tSay():New(015,020,{|| oTxtTitulo	},oAut,,oFont ,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,60)
	oSayTxtTit 	:= tSay():New(035,020,{|| oTxtT2		},oAut,,oFont3,,,,.T.,CLR_BLACK,CLR_BLACK,350,60)
	oSayTxtTit 	:= tSay():New(035,180,{|| oTxtT3		},oAut,,oFont3,,,,.T.,CLR_BLACK,CLR_BLACK,350,60)
	
	
	_oGet3   := TGet():New(035,140, {|u| If(PCount() > 0, _cGet3:= u, _cGet3)}, oAut,, 009, "@!",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet3,,,,.t.,)
	_oGet4   := TGet():New(035,200, {|u| If(PCount() > 0, _cGet4:= u, _cGet4)}, oAut,, 009, "@!",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet4,,,,.t.,)
	/* Colocar botão */
	
	_oBtn01 := TButton():New(060, 46,"Limpar"			, oAut,{|| limpa(_cGet3,_cGet4) },60,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn02 := TButton():New(060, 120, "Sair"           , oAut,{|| oAut:end() },60,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	// Liberação da rotina de Pré-Etiqueta
	
		
	_oBtn01:SetColor(CLR_WHITE,CLR_RED)
	_oBtn02:SetColor(CLR_WHITE,CLR_GREEN)
	
	
	ACTIVATE MSDIALOG oAut CENTERED

	RESET ENVIRONMENT
	
	
Return
/* Seekar o  registros */
Static Function limpa(_cNum,_cItem)
	
	/* Tabela SC1 */
	SC1->(DbSetOrder(1))
	SC1->(DbGotop())
	SC1->(DbSeek(xfilial('SC1')+alltrim(_cNum)+alltrim(_cItem)))
	
	//alert('Solicitação :'+SC1->C1_NUM+'--Item:'+SC1->C1_ITEM+"--Descrição:"+SC1->C1_DESCRI)
	
	if empty(alltrim(SC1->C1_COTACAO))
		/* Produto não cotado ainda
			Não preciso limpar campos*/
			oTxtRet3  := " Produto: "+alltrim(substr(SC1->C1_DESCRI,0,45 ))
			oTxtRet4  := "      Ainda não foi Cotado !!"
			oSayTxtLRT  := tSay():New(095,020,{|| oTxtRet3 	},oAut,,oFont3,,,,.T.,CLR_RED,CLR_WHITE,270,30)
			oSayTxtLRT  := tSay():New(110,020,{|| oTxtRet4 	},oAut,,oFont3,,,,.T.,CLR_RED,CLR_WHITE,270,30)  
	else
			/* Produto Cotado já , então fazer limpeza dos campos SC1->C1_COTACAO , SC1->C1_IDENT e SC1->C1_OK */
			
			
			reclock('SC1',.f.)
				SC1->C1_COTACAO := ""
				SC1->C1_IDENT := ""
				SC1->C1_OK := ""
			msunlock()
			
			oTxtRet3  := " Produto: "+substr(SC1->C1_DESCRI,0,45 )
			oTxtRet4  := " - Foi limpa a Cotação. - " 
			oSayTxtLRT  := tSay():New(095,020,{|| oTxtRet3 	},oAut,,oFont3,,,,.T.,CLR_BLUE,CLR_WHITE,270,30)
			oSayTxtLRT  := tSay():New(110,020,{|| oTxtRet4 	},oAut,,oFont3,,,,.T.,CLR_BLUE,CLR_WHITE,270,30)
			 
	endif
	
		
	
	oSayTxtLRT:CtrlRefresh() 
	
	oTxtRetT  := ''
	oTxtRet2  := ''
	oAut:refresh() 
	
Return




