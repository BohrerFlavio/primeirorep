#INCLUDE "Rwmake.ch"  
#INCLUDE "Protheus.ch"   
#INCLUDE "Topconn.ch"
#INCLUDE "fileio.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "vkey.ch"  
#INCLUDE "colors.ch" 
#INCLUDE "totvs.ch"
   
/*/                                                                          


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Controles   º Autor ³ AP6 IDE            º Data ³  	      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ 	 Tela de controle de Pesos e Impressão de Pré-Etiquetas   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Para controle de liberação do peso de alguns cortes        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/



Static Function LiberaD()
	oTxtRetD  := 'Liberada Produção Dianteiro sem Peso!'
	
	PUTMV('SI_PESMIND',.F.)
	
	oSayTxtLRD:CtrlRefresh()
	oAut:refresh() 
		
	oTxtRetT  := ''
	oTxtBlT	 := ''
	oTxtBlD	 := ''
	
Return

Static Function BlockD()
	oTxtBlD  := 'Bloqueada Produção do Dianteiro sem Peso!'

	PUTMV('SI_PESMIND',.T.)
	 
	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtBRD:CtrlRefresh() 
	
	oAut:refresh()
	
	oTxtRetD  := ''
	oTxtRetT  := ''
	oTxtBlT	 := ''
	
Return


Static Function LiberaT()
	
	oTxtRetT  := 'Liberada Produção do Traseiro sem Peso!'
	PUTMV('SI_PESMINT',.F.)
	 
	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtLRT:CtrlRefresh() 
	oAut:refresh()
	oTxtRetD := ''
	oTxtBlT	 := ''
	oTxtBlD	 := ''
Return

Static Function BlockT()
	oTxtBlT  := 'Bloqueada Produção do Traseiro sem Peso!'

	PUTMV('SI_PESMINT',.T.)
	//Refresh para mostrar Bloqueio do Traseiro
	oSayTxtBRT:CtrlRefresh() 
	oAut:refresh()
	oTxtRetD  := ''
	oTxtRetT  := ''
	oTxtBlD	 := ''
Return

Static Function Limpamsg()

	oTxtRetD  	:= ''
	oTxtRetT  	:= ''
	oTxtBlD	 	:= ''
	oTxtBlT		:= ''
	oTxtEmb		:= ''
	oTxtMds		:= ''
	oTxtMds		:= ''
Return

Static Function Vis()
	
	oTxtEmb := ''
	oTxtMds := ''
	_nEmb 	:= GetMV('SI_IMPPETQ')
	_nMDS  	:= GetMV('SI_IMPETQ2')
	/*Visualização da Rotina da Embalagem*/
	If !empty(alltrim(_nEmb))
		oTxtEmb  := 'Rotina utilizada pela estação :'+_nEmb+' na Embalagem!'	
	else
		oTxtEmb  := 'Rotina de Produção de Etiquetas sem ser utilizada na Embalagem!'
	endif
	// Refresh para mostrar o Status da Embalagem
	oSayTxtE:CtrlRefresh() 
	
	/*Visualização da Rotina dos Miudos*/
	
	If !empty(alltrim(_nMDS))	
		oTxtMds  := 'Rotina utilizada pela estação :'+_nMDS+' nos Miúdos!'	
	else
		oTxtMds  := 'Rotina de Produção de Etiquetas sem ser utilizada nos Miúdos!'
	endif
	// Refresh para mostrar o Status do Miúdos
	oSayTM:CtrlRefresh() 
	
	oAut:refresh()
	oTxtRetD  	:= ''
	oTxtRetT  	:= ''
	oTxtBlD	 	:= ''
	oTxtBlT		:= ''
	
Return

Static Function Emb()
	
	PUTMV('SI_IMPPETQ','')
	oTxtEmb  := 'Liberada rotina da Embalagem para produção de Etiquetas Internas!'
	//oSayTxtE 	:= tSay():New(095,020,{|| oTxtEmb	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)//015 
	oSayTxtE:CtrlRefresh() 
	oAut:refresh()
	oTxtRetD  	:= ''
	oTxtRetT  	:= ''
	oTxtBlD	 	:= ''
	oTxtBlT		:= ''
	oTxtMds		:= ''
	
Return

Static Function Mds()
	oTxtEmb		:= ''	
	
	PUTMV('SI_IMPETQ2','')
	oTxtMds  := 'Liberada rotina dos Miúdos para produção de Etiquetas Internas!'
	//oSayTM 	:= tSay():New(095,020,{|| oTxtMds	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)//015 
	oSayTM:CtrlRefresh()
	
	oAut:refresh()
	oTxtRetD  	:= ''
	oTxtRetT  	:= ''
	oTxtBlD	 	:= ''
	oTxtBlT		:= ''
	oTxtEmb		:= ''
	
	
	
Return

User Function tela_controle()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	private oFont     := tFont():New("courier new",,-28,,.t.,,,,)
	private oFont2    := tFont():New("courier new",,-24,,.t.,,,,)     
	private oFont3    := tFont():New("courier new",,-12,,.t.,,,,)     
	                  
	Private oTxtTitulo 	:= 'Controle Peso Traseiro/Dianteiro'
	Private oTxtRetT  	:= ''
	Private oTxtBlT		:= ''
	Private oTxtRetD  	:= ''
	Private oTxtBlD		:= ''
	
	Private oTxtEmb		:= ''
	Private oTxtMds		:= ''

	
	//RPCSetType(3) //não consome licença.
	//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "ACD" //TABLES "SA1", "SB1"
	aTables := {'SA1','SB1'}
	RPCSetEnv('01','00','industria','industria',"ACD","U_tela_controle",aTables,,,,)


	DEFINE MSDIALOG oAut TITLE 'Acompanhamento da Produção' from 000,000 To 350,750  PIXEL
	
	/* Objetos da Liberação Traseiro/Dianteiro*/
	oSayTxtBRT  := tSay():New(095,020,{|| oTxtBlT	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oSayTxtLRT  := tSay():New(095,020,{|| oTxtRetT	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30) 
	oSayTxtBRD  := tSay():New(095,020,{|| oTxtBlD 	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)	
	oSayTxtLRD  := tSay():New(095,020,{|| oTxtRetD	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	
	
	/* Objetos das Etiquetas Internas EMB/MDS*/
	oSayTxtE 	:= tSay():New(095,020,{|| oTxtEmb	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)
	oSayTM 		:= tSay():New(135,020,{|| oTxtMds	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,270,30)

	oGrupoL1 := tGroup():New(05, 10, 80, 310,'Acompanhamento da Produção', oAut,,, .t.)	
	oGrupoL2 := tGroup():New(85, 10, 170, 310,'MSG', oAut,,, .t.)	
	oGrupoL3 := tGroup():New(30, 253, 76, 305,'Pré-Etiq.Liberação', oAut,,, .t.)

	 
	oSayTxtTit 	:= tSay():New(015,035,{|| oTxtTitulo	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,60)
	 
	
	/* Colocar botão */
	_oBtn01 := TButton():New(037, 46,"Liberar Peso Traseiro", oAut,{|| LiberaT() },60,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn03 := TButton():New(054, 46, "Bloqueia Peso Traseiro"    , oAut,{|| BlockT() },60,012,,,.F.,.T.,.F.,,.F.,,,.F. )
		
	_oBtn05 := TButton():New(040, 130, "LIMPA MSG"   , oAut,{|| Limpamsg() },40,015,,oFont3,.F.,.T.,.F.,,.F.,,,.F. )
	
	_oBtn02 := TButton():New(037, 190, "Liberar Peso Dianteiro"   , oAut,{|| LiberaD() },60,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn04 := TButton():New(054, 190, "Bloqueia Peso Dianteiro"   , oAut,{|| BlockD() },60,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	// Liberação da rotina de Pré-Etiqueta
	_oBtn06 := TButton():New(040, 260, "Vis.Rot."   , oAut,{|| Vis() },40,010,,oFont3,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn07 := TButton():New(052, 260, "Lib.EMB"   , oAut,{|| Emb() },40,010,,oFont3,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn08 := TButton():New(064, 260, "Lib.MDS"   , oAut,{|| Mds() },40,010,,oFont3,.F.,.T.,.F.,,.F.,,,.F. )
	
	/* Mensagens de retorno */
	//DEFINE MSDIALOG oAut TITLE 'Retorno Botões' from 010,095 To 200,650  PIXEL
	//  CLR_WHITE
	
	
	_oBtn01:SetColor(CLR_WHITE,CLR_GREEN)
	_oBtn02:SetColor(CLR_WHITE,CLR_GREEN)
	_oBtn05:SetColor(CLR_WHITE,CLR_GREEN)
	_oBtn03:SetColor(CLR_WHITE,CLR_GREEN)
	_oBtn04:SetColor(CLR_WHITE,CLR_GREEN)
	
	
	_oBtn06:SetColor(CLR_WHITE,CLR_RED)
	_oBtn07:SetColor(CLR_WHITE,CLR_RED)
	_oBtn08:SetColor(CLR_WHITE,CLR_RED)
	//oTimerE01:Activate()

	ACTIVATE MSDIALOG oAut CENTERED

	RESET ENVIRONMENT

return





