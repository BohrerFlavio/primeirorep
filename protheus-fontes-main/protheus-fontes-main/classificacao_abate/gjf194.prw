#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF194    º Autor ³ Giuliano Forgiariniº Data ³  20/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de desclassificação de carcaças do abate            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Qualidade                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF194()


	//                  { "Processos Folha*", aFolProc ,0, 6,   , .F. } 
	Private aRotina := {{ "Pesquisar" ,"AxPesqui"     , 0, 1,  , .F. } ,;     //"Pesquisar"
	{ "Visualizar","AxVisual"     , 0, 2,  , .F. } ,; 	//"Visualizar"
	{ "Desclass." ,"U_GJF194D()"  , 0, 4,  , .F. } ,; 	//"Detalhes"  
	{ "Imprimir"  ,"U_GJF75()"    , 0, 4,  , .F. }} 	//"Imprimir"   
	//{ "Imprimir"  ,"U_ImpPcp015()", 0, 4},; 	//"Imprimir"

	cString := "SZG"
	cCadastro := 'Desclassificação de Lotes'

	dbSelectArea("SZG")
	dbSetOrder(1)
	mBrowse( 6, 1,22,75,cString)
Return
//


User Function gjf194D()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lOk 		:= .F.
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private aGets   := {}
	Private aTela   := {}
	Private _nNumL  := 0 


	DbSelectArea('SZ4')
	SZ4->(DbSetOrder(1))
	SZ4->(DbGoTop())
	SZ4->(DbSeek(xfilial('SZ4')+SZG->ZG_NUMAM))

	DEFINE MSDIALOG oEnc TITLE 'Desclassificação de lotes' from 0,0 To 250,720 OF oMainWnd PIXEL

	nUsado := gjf194he()

	inic := 0

	gjf194co()

	RegtoMemory('SZ4',.f.)

	oGet := MSGetDados():New (31,2,124,360, 4,,,,.F.,{"Z4_DESCLA"}, ,.F. , len(aCols), )


	ACTIVATE MSDIALOG oEnc ON INIT EnchoiceBar(oEnc,{||lOk :=.t. .and. Obrigatorio(aGets,aTela) ,Iif(lOk,oEnc:End(),;
	oEnc:refresh())}, {||oEnc:End()}, , ) CENTERED

	If lOk

		gjf194Gr()


	Endif

	If Select("SZ4")<>0
		SZ4->(dbCloseArea())
	Endif

Return               


Static Function gjf194he()

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//DbSeek("SZ4")
	//Do While !Eof() .and. (X3_ARQUIVO == "SZ4")
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "Z4_FILIAL Z4_NUMAM") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := "SZ4"
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 				.And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "Z4_FILIAL" .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "Z4_NUMAM")

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


Static Function gjf194co()
	Local nI, nPos
	dbSelectArea("SZ4")
	SZ4->(dbSetOrder(1))
	if 	SZ4->(dbSeek(xFilial('SZ4')+SZG->ZG_NUMAM,.T.))
		Do While SZ4->(!Eof()) .and. SZ4->Z4_FILIAL = xfilial('SZ4') .and. ;
		alltrim(SZ4->Z4_NUMAM) == alltrim(SZG->ZG_NUMAM)
			aAdd(aCols,Array(nUsado+1))
			For nI := 1 to nUsado
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Next nI
			aCols[Len(aCols),nUsado+1] := .F.
			_nNumL++
			SZ4->(DbSkip())
		Enddo
	endif
Return

Static Function gjf194Gr()
	Local nIt
	SZ4->(DbSetOrder(4))
	SZ4->(DbGoTop())
	nCpo := 0


	For nIt := 1 To Len(aCols)
		if SZ4->(DbSeek(xFilial("SZ4")+SZG->ZG_NUMAM+GDFieldGet('Z4_IDLOT',nIt)))
			_cNClasse := GDFieldGet('Z4_DESCLA',nIt)
			SZK->(DbSetOrder(2))
			if SZK->(DbSeek(xfilial('SZK')+SZG->ZG_NUMAM+SZ4->Z4_LOTE))    
				while SZK->(!eof()) .and. SZK->ZK_FILIAL = xfilial('SZK') .and. SZK->ZK_NUMAM = SZG->ZG_NUMAM .and. SZK->ZK_LOTE = SZ4->Z4_LOTE      
					reclock('SZK',.f.)
					SZK->ZK_CLASSIF := iif(!empty(_cNClasse),NovaClasse(_cNClasse),SZK->ZK_CLASSIF)
					SZK->ZK_CLASABA := iif(!empty(_cNClasse),NovaClasse(_cNClasse),SZK->ZK_CLASABA)
					msunlock()

					SZK->(DbSkip())
				enddo
			endif

			RecLock("SZ4",.F.)
			SZ4->Z4_DESCLA  := GDFieldGet('Z4_DESCLA', nIt)  
			SZ4->Z4_CLASSIF := GDFieldGet('Z4_CLASSIF', nIt)  
			MsUnlock()

		else
			alert('Erro SZ4')
		endif

	Next nIt


return .t.


/////////////////////////////////////
///Função classificadora de lotes ///
/////////////////////////////////////
User Function GJF194C()   

	Local _cClassif  := GDFieldGet('Z4_CLASSIF',n)
	Local _cDescla   := GDFieldGet('Z4_DESCLA',n)
	Local _cNewClass := _cClassif

	if AllTrim(_cDescla) = 'RU'
		if AllTrim(_cClassif) = 'RT'
			_cNewClass := 'RU'
		endif      

	elseif AllTrim(_cDescla) = 'HK'
		if AllTrim(_cClassif) $ 'RT/RU'
			_cNewClass := 'HK'
		endif     

	elseif AllTrim(_cDescla) = 'NE'
		if AllTrim(_cClassif) $ 'RT/RU/HK'
			_cNewClass := 'NE'
		endif        

	endif

	GDFieldPut("Z4_DESCLA",_cNewClass,n)  

return _cNewClass

//Classificação da nova classe
Static Function NovaClasse(_cClass)

	Local _cNewClass := _cClass

	if AllTrim(_cClass) = 'RU'
		if AllTrim(SZK->ZK_CLASABA) = 'RT'
			_cNewClass := 'RU'
		endif      

	elseif AllTrim(_cClass) = 'HK'
		if AllTrim(SZK->ZK_CLASABA) $ 'RT/RU'
			_cNewClass := 'HK'
		endif     

	elseif AllTrim(_cClass) = 'NE'
		if AllTrim(SZK->ZK_CLASABA) $ 'RT/RU/HK'
			_cNewClass := 'NE'
		endif        

	endif

return _cNewClass
