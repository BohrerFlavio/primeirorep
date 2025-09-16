#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF131  ºAutor  ³Giuliano Forgiarini º Data ³  04/01/12     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±            
±±ºDesc.     ³ Controle de tranferencias de PA                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF131()

	aObjects            := {}                                                                 
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]                                                            
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	lOk         := .f.
	aIndZAC   	:= {}					                                                               	// Arquivo e número de índice utilizado
	cCondicao 	:= ""					                                                               	// Condição para a filtragem

	Private cPerg     := "GJF131"
	Private _cDoc     := ''
	Private _cSerie   := ''
	Private _cFilOri  := ''
	Private _cFilDes  := ''
	Private _cCliente := '000434'  
	Private _cLoja    := ''


	Private cCadastro := "Controle de Transferencias de PA"
	Private aRotina := { {"Pesquisar"  ,"AxPesqui"   ,0,1} ,;
	{"Visualizar" ,"u_gjf131V " ,0,2},;
	{"Incluir"    ,"u_gjf131I"  ,0,3},;
	{"Liberar"    ,"u_gjf131L"  ,0,4},;
	{"Bloquear"   ,"u_gjf131B"  ,0,4},;
	{"Encerrar"   ,"u_gjf131E"  ,0,4},;
	{"Alterar"    ,"AxAltera"   ,0,4},;
	{"Excluir"    ,"u_gjf131X"  ,0,5},;
	{"Legenda"    ,"u_gjf131G"  ,0,1}}     

	private cString := "ZAC"   

	if !pergunte(cPerg,.t.)
		return
	endif

	Private bLegenda1 := "ZAC->ZAC_STATUS = 'L'"   
	Private bLegenda2 := "ZAC->ZAC_STATUS = 'E'"   
	Private bLegenda3 := "ZAC->ZAC_STATUS = 'C'"   
	Private bLegenda4 := "ZAC->ZAC_STATUS = 'B'"   

	Private aCores := {{bLegenda1, 'BR_VERDE'   },;      // Transferencia liberada
	{bLegenda2, 'BR_VERMELHO'},;      // Transferencia encerrada
	{bLegenda3, 'BR_AMARELO' },;      // Transferencia em curso
	{bLegenda4, 'BR_AZUL'    }}       // Transferencia bloqueada

	Private aCores2:= {{'BR_VERDE'   ,'Liberada' },;     // Transferencia liberada
	{'BR_VERMELHO','Encerrada'},;     // Transferencia encerrada
	{'BR_AMARELO' ,'Em curso' },;     // Transferencia em curso
	{'BR_AZUL'    ,'Bloqueada'}}      // Transferencia bloqueada



	dbSelectArea(cString)
	ZAC->(dbSetOrder(1))

	cCondicao := "ZAC->ZAC_DATA >= mv_par01 .and. ZAC->ZAC_DATA <= mv_par02 .and. ZAC->ZAC_FILIAL = xfilial('ZAC')"


	FilBrowse("ZAC",@aIndZAC,@cCondicao)


	mBrowse( 6, 1, 22, 75,cString,,,,,,aCores,,,,{|x| AutoRefresh(x)}) 

	Set Key 123 To 																	// Desativa a tecla F12 do acionamento dos parametros

	If ( Len(aIndZAC)>0 )
		EndFilBrw("ZAC",@aIndZAC)                                                   //Encerra o filtro e refaz os índices padrões
	endif     

	DbCloseArea('ZAC')   

Return

User Function gjf131G(cAlias,nReg,nOpc)
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return


//Função destinada a visualização de transferencias
User Function gjf131V(cAlias,nReg,nOpc)
	Local   lOk     := .f.
	Private aGets	:= {}
	Private aTela	:= {} 

	aCampos := {}

	RegToMemory("ZAC",.f.)

	_cSerie     := iif(M->ZAC_FILORI = 'SM','10 ','20 ')   
	_cFilOri    := iif(M->ZAC_FILORI = 'SM','00','01')        
	_cFilDes    := iif(M->ZAC_FILORI = 'SM','01','00')        

	CriaTMP()

	DEFINE MSDIALOG oDlg TITLE 'Incluir Tranferência' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	oEnc := MsMGet():New("ZAC" ,ZAC->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )

	@ 170,005 To 250,350 Browse "TMP"  fields aCampos object oiBrowse

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()}, , )

	FilBrowse("ZAC",@aIndZAC,@cCondicao)

return

//Função destinada a inclusão de transferencias
User Function gjf131I(cAlias,nReg,nOpc)
	Local   lOk     := .f.
	Private aGets	:= {}
	Private aTela	:= {} 

	aCampos := {}

	RegToMemory("ZAC",.t.)

	CriaTMP()

	DEFINE MSDIALOG oDlg TITLE 'Incluir Tranferência' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	oEnc := MsMGet():New("ZAC" ,ZAC->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )

	@ 170,005 To 250,350 Browse "TMP"  fields aCampos object oiBrowse
	//oEnc  := MSGetDados():New (220,2,266,256,2,,,,.F.,,,.F.,len(aCols),,,,,oDlg)

	//ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, ,)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , )

	If  lOk  
		Gravar()
		confirmsx8()      
	else
		Rollbacksx8()
	Endif

	FilBrowse("ZAC",@aIndZAC,@cCondicao)

return

//Rotina para criar o arquivo temporário 
//para totalizadores de peças processadas
Static Function  criaTMP()
	Local _aArqTrb    := {}
	
	If Select('TMP')<>0                                                         
		DbSelectArea('TMP')
		DbCloseArea('TMP')
	endif

	aCampos := {}
	aadd(aCampos,{"ZAD_ITEM"  ,"Item"       ,"@!"         })
	aadd(aCampos,{"ZAD_CODORI","Cod.Origem" ,"@!"         })
	aadd(aCampos,{"ZAD_DESC"  ,"Descricao"  ,"@!"         })
	aadd(aCampos,{"ZAD_COD   ","Cod.Destino","@!"         })
	aadd(aCampos,{"ZAD_QUANT" ,"Quant"      ,"@E 999,999" })
	aadd(aCampos,{"ZAD_QTREAL","Qt. Real"   ,"@E 999,999" })


	aStru := ZAD->(Dbstruct())

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	//dbcreate(cArq,aStru)
	// ProcData 04/2023 - Chamada para criar arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)
	
	//Cria a estrutura do vetor no TMP criado
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	ZAD->(DbGoTop())
	ZAD->(DbSetOrder(1))
	if ZAD->(DbSeek(xfilial('ZAD')+ZAC->ZAC_NUM))
		While ZAD->(!eof()) .and. xfilial('ZAD')+ZAD->ZAD_NUM = ZAC->(ZAC_FILIAL+ZAC_NUM)

			reclock('TMP',.t.)
			TMP->ZAD_CODORI := ZAD->ZAD_CODORI
			TMP->ZAD_COD    := ZAD->ZAD_COD
			TMP->ZAD_DESC   := ZAD->ZAD_DESC
			TMP->ZAD_QUANT  := ZAD->ZAD_QUANT
			TMP->ZAD_QTREAL := ZAD->ZAD_QTREAL
			TMP->ZAD_ITEM   := ZAD->ZAD_ITEM
			TMP->ZAD_PRECAR := ZAD->ZAD_PRECAR
			TMP->ZAD_PREPED := ZAD->ZAD_PREPED 
			TMP->ZAD_FIL    := _cFilDes    //ATENÇAO: esse campo é para a filial de DESTINO!!!
			msunlock()

			ZAD->(DbSkip())
		enddo
	endif
	TMP->(DbGoTop())

Return 


////Funções para atualização do mBrowse////
Static Function AutoRefresh(oDlg)
	Local oTimer
	oTimer := TTimer():New(2, {|| PBrow() }, oDlg)  
	oTimer:Activate()
Return .T.

////Funções para atualização do mBrowse////
Static Function PBrow()
	oBrowse := getObjBrow() 
	oBrowse:default() 
	oBrowse:refresh()
Return

//Função para carregar a nf e formar a transferencia
User Function GJF131Ca()                           
	Local ret      := 'B'
	Local _cPrecar := ''
	_cDoc       := M->ZAC_NOTA 
	_cSerie     := iif(M->ZAC_FILORI = 'SM','10 ','20 ')   
	_cFilOri    := iif(M->ZAC_FILORI = 'SM','00','01')        
	_cFilDes    := iif(M->ZAC_FILORI = 'SM','01','00')        
	_cCliente   := '000434'  
	_cLoja      := iif(M->ZAC_FILDES = 'SM','02','01')  


	ZAC->(DbSetOrder(4))
	if ZAC->(DbSeek(xfilial('ZAC') + _cDoc + _cFilOri + _cFilDes))
		alert('Devolução já gerada para este documento!')
		return ret
	endif

	DbSelectArea('TMP')

	SD2->(DbSetOrder(3)) 
	//Varredura para verificar se existe mais de um pre-carregamento no documento fiscal
	//SD2->(DbSeek(xfilial('SD2') + _cDoc + _cSerie + _cCliente))
	if SD2->(DbSeek(_cFilOri  + _cDoc + _cSerie + _cCliente + _cLoja)) 
		_cPrecar := SD2->D2_PRECAR
		While SD2->(!eof()) .and. (_cFilOri + _cDoc + _cSerie + _cCliente + _cLoja) = _cFilOri+SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)  

			if _cPrecar <> SD2->D2_PRECAR
				msgbox('Existe mais de 1 pre-carregamento relacionado a esta transferencia!','OPERACAO IRREGULAR','STOP')
				return
			endif 
			SD2->(DbSkip())
		enddo
	endif

	SD2->(DbGoTop())
	//SD2->(DbSeek(xfilial('SD2') + _cDoc + _cSerie + _cCliente))
	if SD2->(DbSeek(_cFilOri  + _cDoc + _cSerie + _cCliente + _cLoja))
		While SD2->(!eof()) .and. (_cFilOri + _cDoc + _cSerie + _cCliente + _cLoja) = _cFilOri + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)		
			if !(SD2->D2_TES $ '638/202/639/201')         //Alterado por Fabian Maurer dia 04/04/13, troca dos TES, antes era(SD2->D2_TES $ '524/525/639/201')
				alert('Produto de ordem ' + SD2->D2_ITEM + ' e codigo ' + alltrim(SD2->D2_COD) + ' não possui TES de tranferência!')
				SD2->(DbSkip())
				loop
			endif

			ZZE->(DbSetOrder(1))
			if ZZE->(DbSeek(xfilial('ZZE') + _cFilOri + padr(alltrim(SD2->D2_COD),14,"")+_cFilDes))
				_cCodDes := ZZE->ZZE_CODDES
			else     
				//			_cCodDes := SD2->D2_COD  
				msgbox('Correlacionamento para o produto ' +alltrim(SD2->D2_COD)+ ' do documento fiscal inexistente!','OPERACAO IRREGULAR','STOP')
				return
			endif                       

			_cItem := fBuscaCPO('SC6',1,_cFilOri+SD2->(D2_PEDIDO+D2_ITEMPV),'C6_ITEM')

			reclock('TMP',.t.)
			TMP->ZAD_CODORI := SD2->D2_COD 
			TMP->ZAD_COD    := _cCodDes 
			TMP->ZAD_DESC   := SD2->D2_DESCRI
			TMP->ZAD_QUANT  := SD2->D2_QTSEGUM 
			TMP->ZAD_ITEM   := PADL(_cItem,3,'0')
			TMP->ZAD_PRECAR := SD2->D2_PRECAR
			TMP->ZAD_PREPED := SD2->D2_PREPED
			TMP->ZAD_FIL    := _cFilDes
			msunlock()  

			SD2->(DbSkip())
		enddo
	endif

	TMP->(DbGoTop())

	oiBrowse:oBrowse:refresh() 
	oDlg:refresh()  

return ret


//Grava cabecalho e itens
Static Function Gravar(nOpc)

	Local nCont
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	// Indica se todas as gravacoes obtiveram sucesso
	Begin Transaction

		DbSelectArea("ZAC")
		DbSetOrder(1)
		If INCLUI             
			//Se a opção foi de incluir registros, faz isso    
			RecLock("ZAC",.T.)
		Else                                                             //Senão...
			RecLock("ZAC",.F.)                                             
		Endif

		For nCont := 1 To FCount()

			If "FILIAL"$Field(nCont)
				FieldPut(nCont,xFilial("ZAC"))
			Else
				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
			Endif

		Next nCont

		MsUnLock()

		DbSelectArea("ZAD")
		DbSetOrder(1)  
		if INCLUI
			TMP->(DbGoTop())
			While TMP->(!eof())
				reclock('ZAD',.t.)
				ZAD->ZAD_FILIAL := xfilial('ZAD')
				ZAD->ZAD_NUM    := ZAC->ZAC_NUM
				ZAD->ZAD_COD    := TMP->ZAD_COD
				ZAD->ZAD_CODORI := TMP->ZAD_CODORI
				ZAD->ZAD_DESC   := TMP->ZAD_DESC
				ZAD->ZAD_QUANT  := TMP->ZAD_QUANT 
				ZAD->ZAD_ITEM   := TMP->ZAD_ITEM 
				ZAD->ZAD_PRECAR := TMP->ZAD_PRECAR
				ZAD->ZAD_PREPED := TMP->ZAD_PREPED
				ZAD->ZAD_FIL    := TMP->ZAD_FIL
				msunlock()   
				TMP->(DbSkip())
			enddo

			DbSelectArea('TMP')
			TMP->(DbCloseArea())

		endif

	End Transaction

Return .t.


//Disponibiliza a legenda
User Function gjf131N(cAlias,nReg,nOpc) 
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return

//Função para liberar transferencia
User Function GJF131L()             
	if ZAC->ZAC_STATUS $ 'L/E/C'
		msgbox('Status impede a operação.','OPERACAO INVALIDA','STOP')
	else
		reclock('ZAC',.f.)
		ZAC->ZAC_STATUS := 'L'  
		msunlock()              
		msgbox('Operação de transferencia liberada.','OPERACAO CONFIRMADA','INFO')
	endif
return

//Função para bloquear transferencia
User Function GJF131B()             
	if ZAC->ZAC_STATUS $ 'B/E/C'
		msgbox('Status impede a operação.','OPERACAO INVALIDA','STOP')
	else
		reclock('ZAC',.f.)
		ZAC->ZAC_STATUS := 'B'  
		msunlock()              
		msgbox('Operação de transferencia bloqueada.','OPERACAO CONFIRMADA','INFO')
	endif
return

//Função para encerrar transferencia
User Function GJF131E()             
	if ZAC->ZAC_STATUS = 'B'
		msgbox('Status impede a operação.','OPERACAO INVALIDA','STOP')
	else
		reclock('ZAC',.f.)
		ZAC->ZAC_STATUS := 'E'  
		msunlock()              
		msgbox('Operação de transferencia encerrada.','OPERACAO CONFIRMADA','INFO')
	endif
return

//Função para excluir transferencia
User Function GJF131X()             
	if ZAC->ZAC_STATUS <> 'L'
		msgbox('Status impede a operação.','OPERACAO INVALIDA','STOP')
	else
		ZAD->(DbSetOrder(1)) 
		if ZAD->(DbSeek(xfilial('ZAD') + ZAC->ZAC_NUM))
			while ZAD->(!eof()) .and. ZAD->(ZAD_FILIAL + ZAD_NUM) = ZAC->(ZAC_FILIAL + ZAC_NUM)
				reclock('ZAD',.f.) 
				dbdelete()
				msunlock()
				ZAD->(DbSkip())
			enddo
		endif	
		reclock('ZAC',.f.)
		dbdelete()
		msunlock()              
		msgbox('Operação de transferencia excluída.','OPERACAO CONFIRMADA','INFO')
	endif
return



