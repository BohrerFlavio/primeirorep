#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

User Function GJF80()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//Rotina de Desclassificação de Lote - Qualidade                        ?
	//?Declaracao de Variaveis                                              ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
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
	SZ4->(MsSeek(FWxfilial('SZ4')+SZG->ZG_NUMAM))

	DEFINE MSDIALOG oEnc TITLE 'Detalhes dos Lotes do Abate' from 0,0 To 250,720 OF oMainWnd PIXEL

	nUsado := gjf80head()

	inic := 0

	gjf80col()

	RegtoMemory('SZ4',.f.)

	_aAlter := {'Z4_ORDEM','Z4_COMPRAD','Z4_CLASSIF','Z4_AREAGTA','Z4_PROPGTA','Z4_DECPROD','Z4_ELEMID','Z4_TUBERC','Z4_PROGRAM'}

	oGet := MSGetDados():New (31,2,124,360, 4,,,,.F.,_aAlter, ,.F. , len(aCols), )

	ACTIVATE MSDIALOG oEnc ON INIT EnchoiceBar(oEnc,{||lOk :=.t. .and.Obrigatorio(aGets,aTela) .and. u_gjf80Ok(),Iif(lOk,oEnc:End(),;
	oEnc:refresh())}, {||oEnc:End()}, , ) CENTERED

	If lOk
		gjf80Grv()
	Endif

	If Select("SZ4")<>0
		SZ4->(dbCloseArea())
	Endif

Return


Static Function gjf80head()

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//MsSeek("SZ4")
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


Static Function gjf80col()
	Local nI
	//Local nPos
	dbSelectArea("SZ4")
	SZ4->(dbSetOrder(1))
	if 	SZ4->(MsSeek(FWxFilial('SZ4')+SZG->ZG_NUMAM,.T.))
		Do While SZ4->(!Eof()) .and. SZ4->Z4_FILIAL = FWxfilial('SZ4') .and. ;
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


Static Function gjf80Grv()
	Local nIt
	Local _lModel := .f.
	SZ4->(DbSetOrder(4))
	SZ4->(DbGoTop())
	nCpo := 0

	For nIt := 1 To Len(aCols)
		if SZ4->(MsSeek(FWxFilial("SZ4")+SZG->ZG_NUMAM+GDFieldGet('Z4_IDLOT',nIt)))    
			_cOrdem := GDFieldGet('Z4_ORDEM',  nIt)
			_lModel := .f.
			if alltrim(GDFieldGet('Z4_CLASSIF',nIt)) = 'RT'
				if GetAdvFVal('ZRT','ZRT_MODELO',FWXFilial('ZRT')+SZ4->Z4_NUMAM+SZ4->Z4_LOTE,1) = 'B'
					_lModel := .t.
				endif
			endif
			RecLock("SZ4",.F.)
			SZ4->Z4_ORDEM   := _cOrdem  //Ordem do lote
			SZ4->Z4_COMPRAD := GDFieldGet('Z4_COMPRAD',nIt)  //Comprador
			SZ4->Z4_CLASSIF := iif(_lModel, 'HK', GDFieldGet('Z4_CLASSIF',nIt))  //Classificação do lote
			SZ4->Z4_AREAGTA := GDFieldGet('Z4_AREAGTA',nIt)  //Se a ?ea de produção na GTA est?conforme
			SZ4->Z4_LOTE    := strzero(_cOrdem,6)
			SZ4->Z4_RASTRO  := GDFieldGet('Z4_RASTRO', nIt) //Se ?rastreado ou n?
			SZ4->Z4_PROPGTA := GDFieldGet('Z4_PROPGTA',nIt)  //Se a propriedade da GTA est?conforme
			//SZ4->Z4_IDADGTA := GDFieldGet('Z4_IDADGTA',nIt) //Se as idades na GTA est? conforme
			SZ4->Z4_DECPROD := iif(_lModel, 'B', GDFieldGet('Z4_DECPROD',nIt))  //Modelo de declaração do produtor
			SZ4->Z4_ELEMID  := GDFieldGet('Z4_ELEMID', nIt)  //Se os elementos identificadores estão conforme
			SZ4->Z4_TUBERC  := GDFieldGet('Z4_TUBERC', nIt)  //Se houver desclassificação por tuberculose
			SZ4->Z4_PROGRAM := GDFieldGet('Z4_PROGRAM',nIt)  //Se o lote ?de GO ou n?
			SZ4->Z4_HORA    := GDFieldGet('Z4_HORA',   nIt)  //Hora do recebimento   
			SZ4->Z4_DESCLA  := GDFieldGet('Z4_DESCLA', nIt)  //Desclassificação feita pela qualidade
			MsUnlock()   
		else
			alert('Erro SZ4')
		endif
		area := getarea()

		DbSelectArea('SZE')
		SZE->(DbSetOrder(8))
		if SZE->(MsSeek(FWxfilial('SZE')+SZ4->(Z4_NUMAM + Z4_IDLOT)))
			while SZE->(!eof()) .and. SZE->(ZE_FILIAL+ZE_NUMAM+ZE_IDLOT) = FWxfilial('SZE')+SZ4->(Z4_NUMAM + Z4_IDLOT)
				reclock('SZE',.f.)
				SZE->ZE_LOTE := SZ4->Z4_LOTE
				msunlock()
				SZE->(DbSkip())
			enddo 
		else
			alert('Erro SZE')
		endif

		restarea(area)
	Next nIt

return .t.


User Function gjf80Ok()
	Local nIt
	Local nIt2

	/*SZK->(DbSetOrder(2))
	if SZK->(MsSeek(FWxfilial('SZK')+SZG->ZG_NUMAM))
		alert('Produção do Abate já iniciada!')
		return .f.
	endif*/

	For nIt := 1 To Len(aCols)
		VlMarc := GDFieldGet('Z4_ORDEM',nIt)
		For nIt2 := 1 To Len(aCols)
			If nIt = nIt2
				loop
			endif
			If VlMarc = GDFieldGet('Z4_ORDEM',nIt2) .and. nIt != nIt2
				msgbox('Ordens estão repetidas!','ERRO!','STOP')
				return .F.
			Endif
		Next nIt2
	Next nIt

Return .T.


/////////////////////////////////////
///Função classificadora de lotes ///
/////////////////////////////////////
User Function GJF80CLS()

	_class  := GetAdvFval('ZP6','ZP6_CODCLA',FWxfilial('ZP6') + "1",3)
	/*_cNumOR := GetAdvFval('SZE','ZE_NUMERO',FWxfilial('SZE')+SZG->ZG_NUMAM+GDFieldGet('Z4_LOTE',n),2)
	_cTRACE := GetAdvFval('SZD','ZD_TRACE',FWxfilial('SZD')+_cNumOR,1)
	_cTuber := GDFieldGet('Z4_TUBERC',n) 

	//Se houver desclassificação por tuberculose
	if _cTuber = 'S'
		_class := GetAdvFval('ZP6','ZP6_CODCLA',FWxfilial('ZP6') + "1",3)
		return 	_class 
	endif

	//Classificação para Rastro = 'S'
	if GDFieldGet('Z4_RASTRO',n) = 'S'
		if GDFieldGet('Z4_DECPROD',n) = 'R'
			_class := 'BR'
		elseif GDFieldGet('Z4_DECPROD',n) = 'U'
			_class := 'USA'
		elseif GDFieldGet('Z4_PROPGTA',n) = 'C' .and.;
			GDFieldGet('Z4_AREAGTA',n) = 'C' .and.;
			GDFieldGet('Z4_DECPROD',n) = 'A' .and.;
			GDFieldGet('Z4_ELEMID',n) = 'C'
			if _cTRACE = 'S'
				_class := 'RT'
			else
				_class := 'RU'
			endif
		else  //Se n? tiver as condições para RT ou RA
			if GDFieldGet('Z4_DECPROD',n) $ 'AB' .and.;
				GDFieldGet('Z4_PROPGTA',n) = 'C'
				_class := 'RU'
			else
				_class := GetAdvFval('ZP6','ZP6_CODCLA',FWxfilial('ZP6') + "1",3)
			endif
		endif
	endif

	//Classificação para Rastro = 'N'
	if GDFieldGet('Z4_RASTRO',n) = 'N'
		if GDFieldGet('Z4_DECPROD',n) = 'R'
			_class := 'BR'
		elseif GDFieldGet('Z4_DECPROD',n) = 'U'
			_class := 'USA'
		elseif GDFieldGet('Z4_DECPROD',n) $ 'AB' .and. GDFieldGet('Z4_PROPGTA',n) = 'C'
			_class := 'RU'
		elseif GDFieldGet('Z4_DECPROD',n) $ 'S' .and. GDFieldGet('Z4_PROPGTA',n) = 'C'
			_class := 'NE'			
		else
			_class := GetAdvFval('ZP6','ZP6_CODCLA',FWxfilial('ZP6') + "1",3)
		endif
	endif*/

return _class
