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
±±ºPrograma  ³DTI29    ºAutor  ³Flávio Bohrer Flôres º Data ³  15/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.  ³  Rotina Destinada para acompanhamento da produção Porcionados º±±
±±º       ³  de forma online na Produção)                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/


User Function DTI33()
	//private oFont     := tFont():New("courier new",,-16,,.t.,,,,) 
	private oFont     := tFont():New("arial",,-16,,.f.,,,,) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aObjects            := {}                                                                 
	aPosObj             := {}
	aInfo               := {} 
	aSizeAut            := MsAdvSize()
	_codlp = 'N'
	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           := aPosObj[1]                                                            
	aX[3]        += 60                                                    
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	//Bloco inserido por Fabian Maurer para ajustar a tela conforme os Pixels
	pixTela1:=0
	pixTela2:=0        
	if aSizeAut[6] >= 890
		pixTela1 := aSizeAut[6] - 408//370
	elseif aSizeAut[6] >= 850 .and. aSizeAut[6] <= 889
		pixTela1 := aSizeAut[6] - 280 //298
	elseif aSizeAut[6] <= 849
		pixTela1 := aSizeAut[6] - 112
	endif

	if aSizeAut[5] >= 1538 
		pixTela2 := aSizeAut[5] - 1445 //780
	elseif aSizeAut[5] >=1352 .and. aSizeAut[5] <= 1537
		pixTela2 := aSizeAut[5] - 1060
	elseif aSizeAut[5] <= 1351
		pixTela2 := aSizeAut[5] - 820 //655
	endif
	//Fim do Bloco


	Private aBrowse1 := {}
	
	Private aRotina := {{"Legenda"  , "u_dti33Leg" ,0,1}}   

	oFont3     := tFont():New(,,-16,,.t.,,,,)
	//Cabeçalhos das colunas  
	aHeader1 := {'',;             // 0
	'Lote',;     		// 1
	'Produto',;   		// 2
	'Descrição',; 		//	3
	'Qt.Prev.',;      // 4
	'Qt.Real.',;      //	5	  			 	//'Qt.Prev.Caixa',; // 6
	'Caixa',; 			// 6  			 	//'Qt.Real.Caixa',; // 7
	'Caixa R.'} 		// 7    				/*'Batelada',;      // 8		 	'Data Prod.',;*/    // 9


	//Largura das colunas
	aLargCol1 := {20,8,3,10,12,9,1,1,6,9,9}

	// Configuraão para a TV da Produção POrcionados  --------- Voltar//
	//DEFINE MSDIALOG oDlg TITLE 'Acompanhamento de Produção ' from   -580,-158 To 500,500 PIXEL
	DEFINE MSDIALOG oDlg TITLE 'Acompanhamento de Produção ' from   -1200,-463 To 500,500 PIXEL
	

	// Cria Browse		
	//Define Font oFont Name 'Courier New' Size 0, -30
	//oBrowse1 := TCBrowse():New(0,0,485,820,,aHeader1,aLargCol1,oDlg,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,, )
	oBrowse1 := TCBrowse():New(0,0,pixTela1,pixTela2,,aHeader1,aLargCol1,oDlg,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,, )
		
	MsgRun("Aguarde... Realizando contagem dos registros...",,{||AtuBrow()})                                 

	oTimer1 := TTimer():New(5000, {|| AtuBrow() }, oDlg)       
	oTimer1:Activate()                                                    

	/*  Botão desativado, porque a produção na linha está na cor vermelha*/
	//TButton():New( 525,10, "Produção" , oDlg,{||linhas() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	//valor := RetCores('0') 
	/*
	oSayLabel := tSay():New(825,140,{|| '## - Produção na Linha' },oDlg,,oFont3,,,,.T.,CLR_RED,CLR_WHITE,200,30)
	oSayLabel := tSay():New(825,240,{|| '## - Em Produção' },oDlg,,oFont3,,,,.T.,CLR_YELLOW,CLR_WHITE,200,30)
	oSayLabel := tSay():New(835,140,{|| '## - Prod. Completa' },oDlg,,oFont3,,,,.T.,CLR_BLUE,CLR_WHITE,200,30)
	oSayLabel := tSay():New(835,240,{|| '## - Produção não Iniciada' },oDlg,,oFont3,,,,.T.,CLR_GREEN,CLR_WHITE,200,30)
	oSayLabel := tSay():New(835,380,{|| '## - Produziu a mais' },oDlg,,oFont3,,,,.T.,CLR_BLACK,CLR_WHITE,200,30)
	*/
	TButton():New( 825,80, "Fechar"    , oDlg,{||oDlg:end()   },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) 
	//RetCores(_Stt)
	ACTIVATE MSDIALOG oDlg CENTERED

return


//Função destinada a atualização do browse pelo timer
Static Function AtuBrow()

	Exib1() 	

	oBrowse1:SetArray(aBrowse1) 
	

	// Monta a linha a ser exibina no Browse	                            
	if len(aBrowse1) <= 0 //verifica se tem algo no vetor para não dar error.log
		oBrowse1:bLine := {||{'','','0','0.00'}}
	else
		oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],aBrowse1[oBrowse1:nAt,04],aBrowse1[oBrowse1:nAt,05],aBrowse1[oBrowse1:nAt,06],aBrowse1[oBrowse1:nAt,07],aBrowse1[oBrowse1:nAt,08]}}
	endif

	oBrowse1:DrawSelect()
	
	
	oBrowse1:refresh()		
	
	
	oDlg:refresh()
	

return   

//Funções para buscar último registro da tabela SZK
Static Function Exib1()

	// Vetor com elementos do Browse
	aBrowse1 := {}
	if  _codlp = 'S'
		_cQuery1 := "SELECT ZAU_NUM AS LOTE, ZAU_COD AS CODPRO, ZAU_QPPESO AS QPREVP,ZAU_QRPESO AS QREALP,ZAU_QPCAIX AS QPCAIXA,ZAU_QRCAIX AS QRCAIXA,ZAU_LINW AS LINHA,"
		_cQuery1 += "ZAU_DESC AS DESCRI, ZAU_BATEL AS BATELADA,ZAU_DTPROD AS DATAPROD, ZAX_CODMP AS CODIGOMP,  ZAX_QTDMP AS QTD, ZAX_QTDMPC AS CONSUMO"
		_cQuery1 += " FROM " + retSqlTab('ZAU')+ "," + retSqlTab('ZAX') 
		_cQuery1 += " WHERE " + retSqlFil('ZAU') + " AND " + retSqlFil('ZAX')
		_cQuery1 += " AND ZAU_BATEL = ZAX_NUM AND ZAU_DTPROD = '"+dtos(date())+"' AND ZAU_STATUS = 'A'"
		_cQuery1 += " AND ZAU_BATEL IN ( ZAX_NUM )" 
		_cQuery1 += " AND (ZAU_LINW = '001' OR ZAU_LINW = '002' OR ZAU_LINW = '003' OR ZAU_LINW = '004')" 
		_cQuery1 += " AND " + retSqlDel('ZAU') + " AND " + retSqlDel('ZAX')
		_cQuery1 += " ORDER BY ZAU_NUM, ZAU_COD"     
	elseIF _codlp = 'N'
		_cQuery1 := "SELECT ZAU_NUM AS LOTE, ZAU_COD AS CODPRO, ZAU_QPPESO AS QPREVP,ZAU_QRPESO AS QREALP,ZAU_QPCAIX AS QPCAIXA,ZAU_QRCAIX AS QRCAIXA,ZAU_LINW AS LINHA,"
		_cQuery1 += "ZAU_DESC AS DESCRI, ZAU_BATEL AS BATELADA,ZAU_DTPROD AS DATAPROD, ZAX_CODMP AS CODIGOMP,  ZAX_QTDMP AS QTD, ZAX_QTDMPC AS CONSUMO, B1_MOLDE AS MOLDE"
		_cQuery1 += " FROM " + retSqlTab('ZAU')+ "," + retSqlTab('ZAX')+ "," + retSqlTab('SB1')
		_cQuery1 += " WHERE " + retSqlFil('ZAU') + " AND " + retSqlFil('ZAX')+ " AND " + retSqlFil('SB1')
		_cQuery1 += " AND ZAU_BATEL = ZAX_NUM AND ZAU_DTPROD = '"+dtos(date())+"' AND ZAU_STATUS = 'A'"
		_cQuery1 += " AND ZAU_BATEL IN ( ZAX_NUM )" 
		_cQuery1 += " AND ZAU_COD = B1_COD" 
		_cQuery1 += " AND " + retSqlDel('ZAU') + " AND " + retSqlDel('ZAX')
		_cQuery1 += " ORDER BY B1_MOLDE, ZAU_NUM, ZAU_COD" 
	Endif


	_cQuery1 := ChangeQuery(_cQuery1)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("VER1")<>0
		VER1->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "VER1"
	VER1->(dbGoTop())
	If _codlp ='N'
		_cMoldes := VER1->MOLDE
	Endif                            
	_Stt := "99"
	while VER1->(!eof())														
		/*
		'Legenda',; 				 //1
		'Lote',;                // 2 
		'Codigo do Produto ',;  // 3
		'Descrição',;				// 4
		'QTD Prev.',;           // 5
		'QTD Real.',;				// 6
		'QTD Prev.Caixa',;      // 7
		'QTD Real.Caixa'}      // 8

		*/

		If ((VER1->QPCAIXA > VER1->QRCAIXA) .AND. (VER1->LINHA = '001' .OR. VER1->LINHA = '002' .OR.VER1->LINHA = '003' .OR.VER1->LINHA = '004') )
			//Vermelho  Produção na linha  
			//_Stt := "2"
			_Stt := "1"
		elseif ((VER1->QPCAIXA > VER1->QRCAIXA) .AND. (alltrim(VER1->LINHA) = '') .AND. VER1->QRCAIXA > 0 .AND. VER1->QRCAIXA < VER1->QPCAIXA)
			//Amarelo     em Produção
			//_Stt := "1"
			_Stt := "2"
		Elseif VER1->QRCAIXA = 0//((VER1->QPCAIXA > VER1->QRCAIXA) .AND. (VER1->LINHA = '001' .OR. VER1->LINHA = '002' .OR.VER1->LINHA = '003' .OR.VER1->LINHA = '004') )

			// Verde   Produção não iniciada
			_Stt := "0"
		Elseif (VER1->QPCAIXA = VER1->QRCAIXA) 
			//Azul  Produção completa 
			_Stt := "3"
		Elseif ((VER1->QPCAIXA < VER1->QRCAIXA))	
			//    Produziu a mais do que deveria
			_Stt := "4"
		Endif

		If _codlp ='N'
			If _cMoldes = VER1->MOLDE
				aadd(aBrowse1,{RetCores(_Stt),;                                // 1
				substr(VER1->LOTE,1,10),;    							// 2
				substr(VER1->CODPRO,1,6),;	                     // 3
				substr(VER1->DESCRI,1,15),;				   	   // 4 
				transform(VER1->QPREVP,'@E 999,999.99'),;  		// 5
				transform(VER1->QREALP,'@E 9,999.99'),;         // 6
				transform(VER1->QPCAIXA,'@E 9999,999'),; 			// 7
				transform(VER1->QRCAIXA,'@E 9999') })		      // 8
				VER1->(dbSkip())
			Else 
				// Linha para troca de Molde, só marcação na tela
				aadd(aBrowse1,{'',;           // 1
				'Molde',;    	// 2
				VER1->MOLDE,;	// 3
				'',;				// 4 
				'',;  		 	// 5
				'',;          	// 6
				'',; 				// 7
				''})	      	// 11  
				_cMoldes := VER1->MOLDE

			Endif    
		else
			aadd(aBrowse1,{RetCores(_Stt),;             // 1
			substr(VER1->LOTE,1,10),;    				// 2
			substr(VER1->CODPRO,1,6),;	                     // 3
			substr(VER1->DESCRI,1,15),;				   	   // 4 
			transform(VER1->QPREVP,'@E 999,999.99'),;  		// 5
			transform(VER1->QREALP,'@E 9,999.99'),;         // 6
			transform(VER1->QPCAIXA,'@E 9999,999'),; 			// 7
			transform(VER1->QRCAIXA,'@E 9999')})	         // 8
			VER1->(dbSkip())
		Endif

	enddo



Return      

Static Function linhas()          

	If  _codlp = 'S' 

		_codlp = 'N'   

	Else  

		_codlp = 'S' 	

	Endif
Return      

//Função auxiliar para retorno das cores da legenda
Static Function RetCores(_Stt)
	local ret 
	if _Stt = '0' 
		ret := LoadBitmap(GetResources(),'br_verde')
	Elseif _Stt = '1'  
		ret := LoadBitmap(GetResources(),'br_amarelo')
	Elseif  _Stt = '2'
		ret :=	LoadBitmap(GetResources(),'br_vermelho')
	Elseif _Stt = '3'
		ret :=	LoadBitmap(GetResources(),'br_azul')
	Elseif _Stt = '4'
		ret :=	LoadBitmap(GetResources(),'br_preto')
	else
		ret := LoadBitmap(GetResources(),'br_roxo')
	Endif
return  ret
