#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF78     º Autor ³Giuliano Forgiarini º Data ³  19/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro e manutenção de pautas do ICMS de produtos        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP/SIGAOMS                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF78()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lOk := .f.
	aObjects := {}                                             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )


	Private cString := "ZZF"

	Private cCadastro := "Cadastro de Pautas de ICMS de Produto Acabado"
	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
	{"Visualizar","AxVisual",0,2} ,;
	{"Incluir","AxInclui",0,3} ,;
	{"Alterar","AxAltera",0,4} ,;
	{"Alt.lote","u_gjf78lt()",0,4} ,; 
	{"Desativar","u_gjf78d",0,4} ,;
	{"Importar","u_gjf78m",0,3} ,;
	{"Atual.Pauta","u_gjf78p",0,4} ,;
	{"Excluir","AxDeleta",0,5} }


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a Filtragem                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("ZZF")
	ZZF->(DbSetOrder(1))
	ZZF->(DbGotop())

	mBrowse(6,1,22,75,cString, ,,,,1 ,)

Return


User Function gjf78m()
	_dData := stod('')
	DEFINE MSDIALOG oDlg2 TITLE 'Data de Vigência' from 000,000 To 70,200 OF oMainWnd PIXEL  
	@ 010,003 SAY  'Data:' Object oSay1
	@ 010,025 GET _dData PICTURE "99/99/99"  Object oData
	@ 010,060 BMPBUTTON TYPE 1 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2                                   
	if msgbox('Deseja importar as pautas com a vigência informada?','CONFIRMAÇÃO','YESNO')
		Processa({||Importa()},"IMPORTAÇÃO DE PRODUTOS DE PA","Realizando importação...") 
	endif
return .t.                                                                       

User Function gjf78p()
	Processa({||Pauta()},"ATUALIZAÇÃO DE PAUTAS DE PRODUTOS DE PA","Realizando atualização...")
return .t.

Static Function Importa() 


	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())     
	SB1->(DbSeek(xfilial('SB1')))

	ProcRegua(SB1->(recCount())) 

	While SB1->(!eof()) .and. SB1->B1_FILIAL = xfilial('SB1')   

		incProc()   

		if SB1->B1_TIPO <> 'PR' .or. SB1->B1_TIPO <> 'PA' .or. SB1->B1_MSBLQL = '1'
			SB1->(DbSkip())
			loop
		endif                                                                          

		ZZF->(DbSetOrder(1))
		reclock('ZZF',.t.)
		ZZF->ZZF_FILIAL := xfilial('SB1')
		ZZF->ZZF_COD    := SB1->B1_COD
		ZZF->ZZF_DESC   := SB1->B1_DESC
		ZZF->ZZF_ATIVO  := 'N'
		ZZF->ZZF_VIGENC := _dData    
		ZZF->ZZF_VL_ICM := SB1->B1_VLR_ICM
		msunlock()
		SB1->(DbSkip())
	enddo

	ZZF->(DbGoTop())

return .t.


Static Function Pauta() 

	ZZF->(DbSetOrder(1))
	ZZF->(DbGoTop())     
	ZZF->(DbSeek(xfilial('SB1')))

	ProcRegua(ZZF->(recCount())) 

	While ZZF->(!eof()) .and. ZZF->ZZF_FILIAL = xfilial('SB1')   

		incProc()   
		if empty(ZZF->ZZF_VL_ICM)
			ZZF->(DbSkip())
			loop
		endif 
		if ZZF->ZZF_ATIVO <> "S"
			ZZF->(DbSkip())
			loop
		endif 

		SB1->(DbSetOrder(1))
		if SB1->(DbSeek(xfilial('SB1')+alltrim(ZZF->ZZF_COD)))
			reclock('SB1',.f.)
			SB1->B1_VLR_ICM := ZZF->ZZF_VL_ICM
			msunlock()
		endif
		ZZF->(DbSkip())
	enddo

return .t.


User Function gjf78lt(cAlias,nReg)    

	Local lOk 		 := .F.                                  
	Local aCposAlt	 := {}
	Private aHeader	 := {}
	Private aCols	 := {}
	Private nUsado	 :=	0 
	Private aGets	:= {}
	Private aTela	:= {} 

	_dData := stod('')
	DEFINE MSDIALOG oDlg2 TITLE 'Data de Vigência' from 000,000 To 70,200 OF oMainWnd PIXEL  
	@ 010,003 SAY  'Data:' Object oSay1
	@ 010,025 GET _dData PICTURE "99/99/99"  Object oData
	@ 010,060 BMPBUTTON TYPE 1 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2                                   



	Private aCampos := {}     

	nUsado := gjf78head(4)   
	//Monta o aHeader para o grid
	gjf78col(4)                                          //Monta o corpo das colunas do grif 

	dbsetorder(1)            

	DEFINE MSDIALOG oEnc TITLE "Alteração em Lote de Pautas" from 0,0 To 360,810 OF oMainWnd PIXEL  

	oCar  := MSGetDados():New (30,2,170,400,4,,,,.F.,,,.F.,,,,,,oEnc)

	ACTIVATE MSDIALOG oEnc ON INIT EnchoiceBar(oEnc,{||lOk := .t. .and. Obrigatorio(aGets,aTela),;
	Iif(lOk,oEnc:End(),oEnc:refresh())}, {||oEnc:End()}, ,) CENTERED

	If lOk
		gjf78Grav()
	Endif


Return

static Function gjf78col(nOpc)
	Local nI, nPos


	dbSelectArea("ZZF")
	dbSetOrder(1)
	dbSeek(xFilial('ZZF'))

	Do While ZZF->(!Eof()) .and. xFilial('SB1') ==  ZZF->ZZF_FILIAL   
		if ZZF->ZZF_VIGENC <> _dData  
			DbSkip()
			loop
		endif
		aAdd(aCols,Array(nUsado+1))

		For nI := 1 to nUsado
			If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Else										// Campo Virtual
				cCpo := AllTrim(Upper(aHeader[nI,2]))
				aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
			Endif
		Next nI

		aCols[Len(aCols),nUsado+1] := .F.

		ZZF->(DbSkip())	
	Enddo

Return

Static Function gjf78head(cAlias)

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek("ZZF")
	//Do While !Eof() .and. (X3_ARQUIVO == "ZZF")
		/*
		If 	at(Upper(AllTrim(X3_CAMPO)), "ZZF_FILIAL ZZF_COD") > 0
		DbSkip()
		Loop
		Endif
		*/
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := "ZZF"
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 		  .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZZ5_FILIAL")

			aAdd(aHeader, { GetSx3Cache(_aCpoSX3[i], 'X3_TITULO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_PICTURE')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_TAMANHO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_DECIMAL')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_VALID')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_USADO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_TIPO')		,;
							GetSx3Cache(_aCpoSX3[i], 'X3_ARQUIVO')	,;
							GetSx3Cache(_aCpoSX3[i], 'X3_CONTEXT')	})
		Endif
	Next i

Return len(aHeader)


Static Function gjf78Grav(nOpc)

	Local nIt
	Local nCont
	Local nNumItem

	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                                       	// Indica se todas as gravacoes obtiveram sucesso

	Begin Transaction

		DbSelectArea("ZZF")
		ZZF->(DbSetOrder(1))
		ZZF->(DbGoTop())
		ZZF->(DbSeek(xfilial('SB1')))
		nNumItem := 1  // Contador para os Itens
		nIt := 1
		While ZZF->(!eof()) .and. ZZF->ZZF_FILIAL = xfilial('SB1')   
			if ZZF->ZZF_VIGENC <> _dData  
				DbSkip()
				loop
			endif
			RecLock("ZZF",.F.)
			ZZF->ZZF_FILIAL := xfilial('SB1') 
			ZZF->ZZF_COD    := alltrim(aCols[nIt, 1]) 
			ZZF->ZZF_DESC   := alltrim(aCols[nIt, 2]) 
			ZZF->ZZF_VIGENC := aCols[nIt, 3]
			ZZF->ZZF_ATIVO  := alltrim(aCols[nIt, 4]) 
			ZZF->ZZF_VL_ICM := aCols[nIt, 5] 
			MsUnlock()  
			nIt++
			ZZF->(DbSkip())
		enddo

	End Transaction

Return lGraOk

User Function gjf78d()    

	_dData := stod('')
	DEFINE MSDIALOG oDlg2 TITLE 'Data de Vigência' from 000,000 To 70,200 OF oMainWnd PIXEL  
	@ 010,003 SAY  'Data:' Object oSay1
	@ 010,025 GET _dData PICTURE "99/99/99"  Object oData
	@ 010,060 BMPBUTTON TYPE 1 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2                                   

	if msgbox('Deseja desativar as pautas com a vigência informada?','CONFIRMAÇÃO','YESNO')
		Processa({||Desativa()},"DESATIVAÇÃO DE TABELA","Processando registros...") 
	endif


Return  

Static Function Desativa()

	ZZF->(DbSetOrder(1))
	ZZF->(DbGoTop())
	ZZF->(DbSeek(xfilial('ZZF')))

	ProcRegua(ZZF->(recCount())) 

	while ZZF->(!eof()) .and. ZZF->ZZF_FILIAL = xfilial('ZZF')
		IncProc()
		if ZZF->ZZF_VIGENC = _dData
			reclock('ZZF',.f.)
			ZZF->ZZF_Ativo := 'N'
			msunlock()
		endif
		ZZF->(DbSkip())
	enddo

Return
