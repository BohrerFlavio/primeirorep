#INCLUDE "topconn.ch"         
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"                                                                           
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch" 
#INCLUDE "tbiconn.ch"
#INCLUDE "totvs.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI15     ºAutor  ³Mauricio Roehrs     º Data ³  12/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Rotina Destinada para acompanhamento da produção de abate º±±
±±º          ³  de forma online                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// Rotina será retirada em 30/09/21 - Dia 02/09/21. Criada nova rotina U_ABATE

user function DTI15()     

return    


User Function tela_abate()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	private oFont     := tFont():New("courier new",,-36,,.t.,,,,)
	private oFont2    := tFont():New("courier new",,-24,,.t.,,,,)     
	private oFont3    := tFont():New("courier new",,-56,,.t.,,,,)     
	Private oNumam 	:= ''
	Private oLote 		:= ''
	Private oControl 	:= ''
	Private oCobGor 	:= ''
	Private oDent 		:= ''
	Private oIf			:= ''
	Private oPetotal 	:= 0                     
	Private oTxtNumam := 'Aviso de Matanca'
	Private oTxtLote  := 'Lote'
	Private oTxtSeq 	:= 'Sequencial'
	Private oTxtGord  := 'Gordura'
	Private oTxtDent  := 'Denticao'
	Private oTxtIf	  := 'Dif: '
	Private oTxtPeso  := 'Peso: '


	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "PCP" //TABLES "SA1", "SB1"


	DEFINE MSDIALOG oAut TITLE 'Acompanhamento do Abate' from 000,000 To 600,800  PIXEL

	oTimerE01 := TTimer():New(02, {|| Exib1()}, oAut)  //Timer para exibição da produção

	oGrupoAbt01 := tGroup():New(05, 10, 285, 390,'Acompanhamento do Abate', oAut,,, .t.)

	//Aviso de Matança
	oSayTxtNumam  	:= tSay():New(015,020,{|| oTxtNumam	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayNumam     	:= tSay():New(035,020,{|| oNumam   	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	//Lote                                                                                                   
	oSayTxtLote  	:= tSay():New(060,020,{|| oTxtLote	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayLote     	:= tSay():New(080,020,{|| oLote 		},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//035 
	//Sequencial                                                                                             
	oSayTxtSeq    	:= tSay():New(060,160,{|| oTxtSeq	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayControl   	:= tSay():New(080,160,{|| oControl  },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//070 
	//Gordura                                                                                                
	oSayTxtGord   	:= tSay():New(105,020,{|| oTxtGord	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayCobGor    	:= tSay():New(125,020,{|| oCobGor   },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//070 
	//Denticao                                                                                               
	oSayTxtDent   	:= tSay():New(105,160,{|| oTxtDent	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayDent      	:= tSay():New(125,160,{|| oDent     },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//070 
	//IF      
	oSayTxtIf   	:= tSay():New(150,20 ,{|| oTxtIf	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayIf		   	:= tSay():New(150,70, {|| oIf  		},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//070 
	//Peso      
	oSayTxtPeso   	:= tSay():New(200,80 ,{|| oTxtPeso	},oAut,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayPetotal   	:= tSay():New(200,180,{|| oPetotal  },oAut,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//070 

	oTimerE01:Activate()

	ACTIVATE MSDIALOG oAut CENTERED

	RESET ENVIRONMENT

return

//Funções para buscar último registro da tabela SZK
Static Function Exib1()
	_cQuery1 := " SELECT TOP 1 ZK_NUMAM, ZK_LOTE, ZK_CONTROL, ZK_COBGOR, ZK_DENT, ZK_PETOTAL, ZK_IF
	_cQuery1 += " FROM " + retSqlTab('SZK') + " , " + retSqlTab('SZG')
	_cQuery1 += " WHERE " + retSqlFil('SZK') + " AND " + retSqlFil('SZG')
	_cQuery1 += " AND ZG_DATA = '" + dtos(date()) + "'"
	_cQuery1 += " AND ZG_STATUS = 'A' AND ZG_NUMAM = ZK_NUMAM"         
	_cQuery1 += " AND ZK_CONTROL <> '' AND ZK_OK <> ''
	_cQuery1 += " AND " + retSqlDel('SZK') + " AND " + retSqlDel('SZG')
	_cQuery1 += " ORDER BY ZK_NUMAM, ZK_CONTROL DESC

	_cQuery1 := ChangeQuery(_cQuery1)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("VER1")<>0
		VER1->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "VER1"

	DbSelectArea('SB1')

	if VER1->ZK_CONTROL <> oControl
		oControl := VER1->ZK_CONTROL
		oNumam 	 := VER1->ZK_NUMAM		
		oLote    := VER1->ZK_LOTE
		oCobGor  := VER1->ZK_COBGOR
		oDent    := VER1->ZK_DENT    
		
		If VER1->ZK_IF = 'S'
			oIf := 'Sim'
		Else
			oIf := 'Nao'
		EndIf	
		
		_nPesoT := VER1->ZK_PETOTAL - (VER1->ZK_PETOTAL * 0.02) //Calculo do peso total da carcaça -2% de frio
		oPetotal := transform(_nPesoT,'@E 999.99')

		oSayNumam:SetText(oNumam)
		oSayLote:SetText(oLote)
		oSayControl:SetText(oControl)
		oSayCobGor:SetText(oCobGor)
		oSayDent:SetText(oDent)
		oSayIf:SetText(oIf)
		oSayPetotal:SetText(oPetotal)
		oAut:refresh() 
	endif
Return  



/* 
Nova Tela do Abate - Feita para Mostrarmos diferença de compra (Quente Fria)
Solicitação feita Pelo Sr Ivon porque vamos comprar carcaças Frias e quentes.
Dia 20/08/21 - Feito por Flávio Bohrer Flores
OBS  - Função feita substituir a Função TELA_ABATE
*/

User Function abate()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	private oFont     := tFont():New("courier new",,-36,,.t.,,,,)
	private oFont2    := tFont():New("courier new",,-24,,.t.,,,,)     
	private oFont3    := tFont():New("courier new",,-56,,.t.,,,,)     
	Private oNumam 	  := ''
	Private oTot 	  := 0
	Private oLote 	  := ''
	Private oControl  := ''
	Private oCobGor   := ''
	Private oDent 	  := ''
	Private oIf		  := ''
	Private oPetotal  := 0                     
	Private oTxtNumam := 'Aviso de Matanca'
	Private oTxtTot   := 'Qtd.Total Animais'
	Private oTxtLote  := 'Lote'
	Private oTxtSeq   := 'Sequencial'
	Private oTxtGord  := 'Gordura'
	Private oTxtDent  := 'Denticao'
	Private oTxtIf	  := 'Dif: '
	Private oTxtPeso  := '' 
	Private oTxtPes2  := ''
	Private oTxtPT    := ''
	Private oTxtP2    := ''


	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "PCP" //TABLES "SA1", "SB1"

	DEFINE MSDIALOG oAut TITLE 'Acompanhamento do Abate' from 000,000 To 600,950  PIXEL

	oTimerE01 := TTimer():New(02, {|| vis1()}, oAut)  //Timer para exibição da produção

	oGrupoAbt01 := tGroup():New(05, 10, 285, 450,'Acompanhamento do Abate', oAut,,, .t.)

	//Aviso de Matança
	oSayTxtNumam  	:= tSay():New(015,020,{|| oTxtNumam	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayNumam     	:= tSay():New(035,020,{|| oNumam   	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
    oSayTxtTot  	:= tSay():New(019,260,{|| oTxtTot	},oAut,,oFont2,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayTot     	:= tSay():New(035,310,{|| oTot   	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 

	//Lote                                                                                                   
	oSayTxtLote  	:= tSay():New(060,020,{|| oTxtLote	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayLote     	:= tSay():New(080,020,{|| oLote 	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//035 
	//Sequencial                                                                                             
	oSayTxtSeq    	:= tSay():New(060,160,{|| oTxtSeq	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayControl   	:= tSay():New(080,160,{|| oControl  },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//070 
	//Gordura                                                                                                
	oSayTxtGord   	:= tSay():New(105,020,{|| oTxtGord	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayCobGor    	:= tSay():New(125,020,{|| oCobGor   },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//070 
	//Denticao                                                                                               
	oSayTxtDent   	:= tSay():New(105,160,{|| oTxtDent	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayDent      	:= tSay():New(125,160,{|| oDent     },oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//070 
	//IF      
	oSayTxtIf   	:= tSay():New(150,20 ,{|| oTxtIf	},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)//015 
	oSayIf		   	:= tSay():New(150,70, {|| oIf  		},oAut,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//070 
	//Peso      	
	oSayTtPe   	:= tSay():New(200,20 ,{|| oTxtPeso	},oAut,,oFont3,,,,.T.,CLR_HRED,CLR_HRED,200,30)//015 
	oSayTtP2   	:= tSay():New(200,20 ,{|| oTxtPes2	},oAut,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayTxtt   	:= tSay():New(200,93 ,{|| oTxtPT	},oAut,,oFont3,,,,.T.,CLR_HRED,CLR_HRED,200,30)//015 
	oSayTxt2   	:= tSay():New(200,93 ,{|| oTxtP2	},oAut,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)
	oSayPetotal   	:= tSay():New(200,230,{|| oPetotal  },oAut,,oFont3,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)//070 

	oTimerE01:Activate()

	ACTIVATE MSDIALOG oAut CENTERED

	RESET ENVIRONMENT

return


//Funções para buscar último registro da tabela SZK
Static Function vis1()
	_cQuery1 := " SELECT TOP 1 ZK_NUMAM, ZK_LOTE, ZK_CONTROL, ZK_COBGOR, ZK_DENT, ZK_PETOTAL, ZK_IF
	_cQuery1 += " FROM " + retSqlTab('SZK') + " , " + retSqlTab('SZG')
	_cQuery1 += " WHERE " + retSqlFil('SZK') + " AND " + retSqlFil('SZG')
	_cQuery1 += " AND ZG_DATA = '" + dtos(date()) + "'"
	_cQuery1 += " AND ZG_STATUS = 'A' AND ZG_NUMAM = ZK_NUMAM"         
	_cQuery1 += " AND ZK_CONTROL <> '' AND ZK_OK <> ''
	_cQuery1 += " AND " + retSqlDel('SZK') + " AND " + retSqlDel('SZG')
	_cQuery1 += " ORDER BY ZK_NUMAM, ZK_CONTROL DESC

	_cQuery1 := ChangeQuery(_cQuery1)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("VER1")<>0
		VER1->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "VER1"

	DbSelectArea('SB1')

	if VER1->ZK_CONTROL <> oControl
		oControl := VER1->ZK_CONTROL
		oNumam 	 := VER1->ZK_NUMAM		
		oLote    := VER1->ZK_LOTE
		oCobGor  := VER1->ZK_COBGOR
		oDent    := VER1->ZK_DENT    
		
		If VER1->ZK_IF = 'S'
			oIf := 'Sim'
		Else
			oIf := 'Nao'
		EndIf	
		
	
		_nQTDAni := fBuscaCPO('SZG',1,xfilial('SZG')+VER1->ZK_NUMAM,'ZG_QTDTOT')
		
		oTot := transform(_nQTDAni,'@E 999')
		
		_SZETPCOM := fBuscaCPO('SZE',2,xFilial('SZE') + VER1->ZK_NUMAM+VER1->ZK_LOTE,'ZE_TPCOM')  
		
		if  alltrim(_SZETPCOM) == "Q"
			
			_nPesoT := VER1->ZK_PETOTAL //Peso quente
			oPetotal := transform(_nPesoT,'@E 999.99')
			oTxtPT := 'Quente:'
			oTxtP2 := ''
			oSayTxtt:SetText(oTxtPT)
			oSayTxt2:SetText(oTxtP2) 
			oTxtPeso  := 'Peso' 
			oTxtPes2  := '' 
			oSayTtPe:SetText(oTxtPeso)
			oSayTtP2:SetText(oTxtPes2)
		else
		
			_nPesoT := VER1->ZK_PETOTAL  - (VER1->ZK_PETOTAL * 0.02)  // Calculo do peso total da carcaça -2% de frio
			oPetotal := transform(_nPesoT,'@E 999.99')
			oTxtPT := ''
			oTxtP2 := 'Frio:'			
			oSayTxtt:SetText(oTxtPT)
			oSayTxt2:SetText(oTxtP2) 
			oTxtPeso  := '' 
			oTxtPes2  := 'Peso' 
			oSayTtPe:SetText(oTxtPeso)
			oSayTtP2:SetText(oTxtPes2)

		Endif

		oSayNumam:SetText(oNumam)		
		oSayTot:SetText(oTot)
		oSayLote:SetText(oLote)
		oSayControl:SetText(oControl)
		oSayCobGor:SetText(oCobGor)
		oSayDent:SetText(oDent)
		oSayIf:SetText(oIf)
		oSayPetotal:SetText(oPetotal)
		oAut:refresh() 
	endif
Return  
