#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F_PCP015  ºAutor  ³3v Technology       º Data ³  20/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍLÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava Ordem de matanca                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function F_PCP015()
	Local _cUsrHEAM  := alltrim(getMv('SI_USRHEAM')) // Usuários que podem encerrar aviso de matança
	Private lInverte := .f.
	Private cMark    := GetMark()
	Private oMark
	Private aRotina  := {}

	if cUserName $ _cUsrHEAM
		aRotina := {{ "Pesquisar" ,"AxPesqui",      0, 1,  , .F. } ,;	// "Pesquisar"
					{ "Visualizar","AxVisual", 	    0, 2,  , .F. } ,;	// "Visualizar"
					{ "Gerar"     ,"U_IncPcp015()", 0, 3,  , .F. } ,;	// "Gerar"
					{ "Detalhes"  ,"U_GJF80()"    , 0, 4,  , .F. } ,; 	// "Detalhes"
					{ "Alterar"   ,"AXAltera"     , 0, 4,  , .F. } ,; 	// "Alterar"
					{ "Encerrar"  ,"u_pcp15E()"   , 0, 4,  , .F. } ,; 	// "Alterar"
					{ "Imprimir"  ,"U_GJF75()"    , 0, 4,  , .F. } ,; 	// "Imprimir"
					{ "Excluir"   ,"U_ExcPcp015()", 0, 5,  , .F. } }    // "Excluir"
	else
		aRotina := {{ "Pesquisar" ,"AxPesqui",      0, 1,  , .F. } ,;	// "Pesquisar"
					{ "Visualizar","AxVisual", 	    0, 2,  , .F. } ,;	// "Visualizar"
					{ "Gerar"     ,"U_IncPcp015()", 0, 3,  , .F. } ,;	// "Gerar"
					{ "Detalhes"  ,"U_GJF80()"    , 0, 4,  , .F. } ,; 	// "Detalhes"
					{ "Alterar"   ,"AXAltera"     , 0, 4,  , .F. } ,; 	// "Alterar"
					{ "Imprimir"  ,"U_GJF75()"    , 0, 4,  , .F. } ,; 	// "Imprimir"
					{ "Excluir"   ,"U_ExcPcp015()", 0, 5,  , .F. } }    // "Excluir"
	endif

	cString := "SZG"
	cCadastro := 'Ordens de matança'

	dbSelectArea("SZG")
	dbSetOrder(1)
	mBrowse( 6, 1,22,75,cString)
Return


User Function IncPcp015()
	Local _aRotBk := aclone(aRotina)
	Local i

	cOrdens  := ''
	aOrdens  := {}
	aObjects := {}             //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	area := GetArea()

	INCLUI := .T.

	cPerg := "PCP015"

	If !Pergunte(cPerg,.T.)
		RestArea( area )
		Return
	Endif

	dDtde   := mv_par01                                     //data
	dDtAte  := mv_par02
	cNumde  := mv_par03                                     //produtor
	cNumAte := mv_par04
	cGrupo  := mv_par05
	cNumOR := ""

	//cArq  := CriaTrab( Nil, .F. )                         //temporario

	aStru := {}

	aadd(aStru,{"OK"          , "C",   2, 0})
	aadd(aStru,{"ZD_DATA"     , "D",   8, 0})
	aadd(aStru,{"ZD_HORA"     , "C",   5, 0})
	aadd(aStru,{"ZE_NUMERO"   , "C",   6, 0})
	aadd(aStru,{"ZE_ITEM"     , "C",   3, 0})
	aadd(aStru,{"ZE_PRODUTO"  , "C",   6, 0})
	aadd(aStru,{"ZE_CATEG"    , "C",   3, 0})
	aadd(aStru,{"ORDEM"       , "C",   3, 0})
	aadd(aStru,{"ZE_NOMEFOR"  , "C",  30, 0})
	aadd(aStru,{"ZE_FORNECE"  , "C",  30, 0})
	aadd(aStru,{"ZE_LOJA"     , "C",  02, 0})
	aadd(aStru,{"ZE_DESC"     , "C",  30, 0})
	aadd(aStru,{"ZE_RAST"     , "C",  01, 0})
	aadd(aStru,{"ZE_CATDES"   , "C",  20, 0})
	aadd(aStru,{"ZE_RACDES"   , "C",  20, 0})
	aadd(aStru,{"MATURA"      , "C",   3, 0})
	aadd(aStru,{"ZE_QTD1UM"   , "N",   5, 0})
	aadd(aStru,{"ZE_PROGRAM"  , "C",   3, 0})
	aadd(aStru,{"ZE_LOCAL"    , "C",   2, 0})
	aadd(aStru,{"ZE_TPCOM"    , "C",   1, 0})
	aadd(aStru,{"ZE_RASTRO"   , "C",  18, 0})

	//dbcreate(cArq,aStru)
	//If Select('TMP')<>0
	//	TMP->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )               //cria temp
	//dbSelectArea('TMP')
	//IndRegua("TMP",cArq,"ZE_NUMERO+ZE_PRODUTO+ZE_RAST+ZE_CATEG+ZE_PROGRAM",,,"Selecionando Registros...") //ordena

	_aArqTrb := {}

	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {"ZE_NUMERO","ZE_PRODUTO","ZE_RAST","ZE_CATEG","ZE_PROGRAM"}, @_aArqTrb)

	SZD->(DbSetorder(1))  //cabecalho
	SZE->(DbSetorder(7))  //itens
	SB1->(DbSetorder(1))  //produto
	SZ6->(DbSetorder(1))  //categoria
	SZ5->(DbSetorder(1))  //raça

	SZE->(DbGoTop())
	if !empty(cNumDe)
		_cChave := FWxfilial('SZE')+cNumDe
		if !SZE->(Msseek(_cChave))
			_cChave := FWxfilial('SZE')
		endif
	else
		cNumOR := GetAdvFVal('SZD','ZD_NUMERO',FWxFilial('SZD')+dtos(dDtde),5)
		if !empty(cNumOR)
			_cChave := FWxfilial('SZE') + cNumOR
		else
			_cChave := FWxfilial('SZE')
		endif
	endif

	SZE->(Msseek(_cChave))
	Do While !SZE->(Eof()) .and. SZE->ZE_NUMERO <= cNumAte

		SZD->(MsSeek(FWxFilial('SZD')+SZE->ZE_NUMERO))

		If SZD->ZD_DATA    >= dDtde  .and. SZD->ZD_DATA    <= dDtAte  .and. ;
		   SZE->ZE_NUMERO  >= cNumde .and. SZE->ZE_NUMERO  <= cNumAte .and. ;
		   Empty( SZE->ZE_NUMAM ) .AND. !Empty( SZD->ZD_DATA )

			IF GetAdvFVal('SZ5','Z5_GRUPO',FWxFilial('SZ5')+SZE->ZE_CATEG,1) = cGrupo
				DbSelectArea('TMP')
				Reclock('TMP',.t.)

				For i:=1 to SZE->(fcount())

					NAME := FieldName( i )

					dbSelectArea('TMP')
					POSICAO := FieldPos( NAME )
					dbSelectArea('SZE')

					If POSICAO > 0
						TMP->(FieldPut(POSICAO, SZE->(FieldGet(i)) ))
					EndIf
				Next
				TMP->OK := ''
				TMP->ZE_NOMEFOR := GetAdvFVal('SA2','A2_NOME', FWxFilial('SA2')+SZD->ZD_FORNECE+SZD->ZD_LOJA,1)
				TMP->ZE_FORNECE := SZD->ZD_FORNECE
				TMP->ZE_LOJA    := SZD->ZD_LOJA
				TMP->ZD_DATA    := SZD->ZD_DATA
				TMP->ZD_HORA    := SZD->ZD_HORA
				TMP->ZE_DESC    := GetAdvFVal('SB1','B1_DESC', FWxFilial('SB1')+SZE->ZE_PRODUTO,1)
				TMP->ZE_CATDES  := GetAdvFVal('SZ5','Z5_DESC', FWxFilial('SZ5')+SZE->ZE_CATEG,1)
				//	TMP->ZE_RACDES  := GetAdvFVal('SZ6','Z6_DESC', FWxFilial('SZ6')+SZE->ZE_RACA,1)
				TMP->ZE_RACDES  := GetAdvFVal('ZA8','ZA8_DESC', FWxFilial('ZA8')+SZE->ZE_RACA,1)
				TMP->ZE_RAST    := IF(!EMPTY( SZE->ZE_RASTRO ),'1','2' )
				//	TMP->ZE_RAST    := IF( SZD->ZD_CERTIF $ 'AB' .AND. !EMPTY( TMP->ZE_RASTRO ),'1','2' )
				TMP->ZE_PROGRAM := SZE->ZE_PROGRAM
				MsUnlock()
			Endif
		Endif

		SZE->(DbSkip())
	Enddo

	dbGotop()

	aCampos := {}
	AADD(aCampos,{"OK"        ,, "OK"         ,"@!"           })
	AADD(aCampos,{"ZD_DATA"   ,, "Dt.Rec."    ,"99/99/9999"   })           //campos
	AADD(aCampos,{"ZD_HORA"   ,, "H.Rec. "    ,"99:99"        })           //campos
	AADD(aCampos,{"ZE_NUMERO" ,, "Num.Ordem"  ,"@!"           })           //campos
	AADD(aCampos,{"ZE_ITEM"   ,, "Item"       ,"@!"           })
	AADD(aCampos,{"ZE_FORNECE",, "Produtor"   ,"@!"           })
	AADD(aCampos,{"ZE_LOJA"   ,, "Loja"       ,"@!"           })
	AADD(aCampos,{"ZE_NOMEFOR",, "Nome"       ,"@!"           })
	AADD(aCampos,{"ZE_QTD1UM" ,, "Qtd."       ,"@E 999,999.99"})
	AADD(aCampos,{"ZE_RAST"   ,, "Rastreado"  ,"@!"           })
	AADD(aCampos,{"ZE_PROGRAM",, "Programa"   ,"@!"           })
	AADD(aCampos,{"MATURA"    ,, "Matura"     ,"@!"           })
	AADD(aCampos,{"ZE_CATDES" ,, "Categoria"  ,"@!"           })
	AADD(aCampos,{"ZE_RACDES" ,, "Raça"       ,"@!"           })
	AADD(aCampos,{"ZE_LOCAL"  ,, "Local"      ,"@!"           })
	AADD(aCampos,{"ZE_TPCOM"  ,, "Compra"     ,"@!"           })

	aRotina := {{ "Grava Matança"     , 'u_PCP015ger', 0, 4},;
				{ "Desmarca todos"    , 'u_PCP015des', 0, 4},;
				{ "Marca todos"       , 'u_PCP015mar', 0, 4} }

	lMarc   := .T.

	dbSelectarea('TMP')
	dbGotop()

	DEFINE MSDIALOG oDlg2 TITLE "Selecione" From 9,0 To 400,1000 PIXEL
	oMark := MsSelect():New("TMP","OK","",aCampos,@lInverte,@cMark,{17,1,160,500},,,,,)
	oMark:bMark := {| | Disp()}

	TButton():New(170, 020, "Grava Matança"   , oDlg2,{|| u_PCP015ger() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 070, "Marca todos"     , oDlg2,{|| u_PCP015mar() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 130, "Desmarca todos"  , oDlg2,{|| u_PCP015des() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 390, "Sair"            , oDlg2,{|| oDlg2:end()   },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg2 CENTERED

	TMP->(dbCloseArea())

	u_arqtrb("FechaTodos",,,, @_aArqTrb)

	RestArea( area )

	aRotina := aClone(_aRotBk)

Return


Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("OK")
		TMP->OK := cMark
	Else
		TMP->OK := ""
	Endif
	msunlock()
	oMark:oBrowse:Refresh()

Return()


User Function PCP015GER()
	Local i
	tot := 0
	Private aGets	:= {}
	Private aTela	:= {}

	dbSelectarea('TMP')
	dbGotop()

	do While !Eof()
		If !empty(TMP->OK)
			tot++
		Endif
		dbSkip()
	Enddo

	If tot == 0
		Return
	Endif

	lOk := .t.

	dbSelectarea('TMP')
	dbGotop()

	nTqtde:=0
	SZE->(DbSetOrder(1))
	do While TMP->(!Eof())
		If !empty(TMP->OK)

			dAbate := TMP->ZD_DATA + 1
			tAbate := TMP->ZD_HORA

			if SZE->(MsSeek(FWxFilial('SZE')+TMP->ZE_NUMERO+ TMP->ZE_ITEM))
				nTqtde += SZE->ZE_QTD1UM
			Endif

		Endif
		TMP->(dbSkip())
	Enddo

	DEFINE MSDIALOG oDlg TITLE 'Gera Ordem de matança' ;
		from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("SZG",.T.)

	M->ZG_QTDTOT := nTqtde

	M->ZG_HORA   := tAbate
	M->ZG_DATA   := dAbate
	M->ZG_NUMAM  := cGrupo + strzero(getmv('MV_NOM_'+cGrupo),4) + right(dtoc(dDatabase),2)
	M->ZG_STATUS := 'A'

	somadiahor(M->ZG_DATA,M->ZG_HORA,12)

	EnChoice( "SZG" ,SZG->(RECNO()), 3, , , , , ,           , , 3 )
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := Obrigatorio(aGets,aTela), oDlg:End()},{||lOk := .f., RollBackSX8() , oDlg:End()})

	If !lOk
		Return
	Endif

	putmv('MV_NOM_'+cGrupo, getmv('MV_NOM_'+cGrupo) + 1 )

	reclock('SZG',.t.)
	for i:=1 to SZG->(fcount())
		cCam := 'M->'+fieldname(i)
		SZG->(fieldput(i,&cCam))
	Next
	msunlock()

	confirmsx8()

	//Bloco de sincronia
	/*_cQuery := "INSERT INTO" + RetSQLTab('SZG') + " (ZG_FILIAL,ZG_NUMAM,ZG_AUTOR,ZG_QTDTOT,ZG_LOCAL,ZG_DATA,ZG_STATUS,ZG_OBS,ZG_SINC,R_E_C_N_O_) "
	_cQuery += "VALUES ('"+FWxfilial('SZG')+"'"
	_cQuery += ",'" + SZG->ZG_NUMAM+"'"
	_cQuery += ",'" + SZG->ZG_AUTOR+"'"
	_cQuery += "," + str(SZG->ZG_QTDTOT)+""
	_cQuery += ",'" + SZG->ZG_LOCAL+"'"
	_cQuery += ",'" + DTOS(SZG->ZG_DATA)+"'"
	_cQuery += ",'" + SZG->ZG_STATUS+"'"
	_cQuery += ",'" + SZG->ZG_OBS+"'"
	_cQuery += ",'OK'"
	_cQuery += ",'" + STR(SZG->(RECNO()))+"')"*/

	cOrdens += M->ZG_NUMAM + chr(13) + chr(10)

	Aadd(aOrdens,M->ZG_NUMAM)

	dbSelectarea('TMP')
	Set Filter to !empty(TMP->OK)
	dbGotop()

	Private cCateg  :=  ''
	Private nLote   :=  0
	Private _cGTA   :=  Space(6)
	Private cFornec :=  Space(6)

	_numDet := GETSX8NUM('SZ4','Z4_NUM')
	ConfirmSX8()

	//aMata650 := {} //Inicialização do vetor para criação da OP de Abate
	//OrdenaTMP()

	While TMP->(!Eof())

		cNumRec := TMP->ZE_NUMERO // 1a quebra - data+hora receb

		While TMP->(!Eof()) .and.  TMP->ZE_NUMERO == cNumRec

			cTpCom  := TMP->ZE_TPCOM // 3a quebra - tipo de compra

			While TMP->(!Eof()) .and. TMP->ZE_NUMERO == cNumRec .AND. TMP->ZE_TPCOM == cTpCom

				cRast := TMP->ZE_RAST // 4a quebra - rastro

				While TMP->(!Eof()) .AND. TMP->ZE_NUMERO == cNumRec .and. TMP->ZE_TPCOM == cTpCom .AND. ;
					TMP->ZE_RAST == cRast

					cCateg  := TMP->ZE_CATEG   // 5a quebra - categoria

					While TMP->(!Eof()) .AND. TMP->ZE_NUMERO == cNumRec .and. cTpCom  == TMP->ZE_TPCOM .AND.;
						cRast   == TMP->ZE_RAST  .AND.;
						cCateg  == TMP->ZE_CATEG

						cProg  := TMP->ZE_PROGRAM  // 6a quebra - origem garantida (OG)

						nLote++
						Private nQtLote := 0

						While TMP->(!Eof()) .AND. TMP->ZE_NUMERO == cNumRec .and. cTpCom  == TMP->ZE_TPCOM .AND.;
								cRast   == TMP->ZE_RAST  .AND.;
								cCateg  == TMP->ZE_CATEG .AND.;
								cProg   == TMP->ZE_PROGRAM

							IF SZE->(MsSeek(FWxFilial('SZE')+TMP->(ZE_NUMERO+ZE_ITEM)))  //salva num ord matanca
								reclock('SZE',.f.)
								SZE->ZE_NUMAM  := M->ZG_NUMAM
								SZE->ZE_LOTE   := Strzero(nLote,6)
								SZE->ZE_IDLOT  := Strzero(nLote,6)
								nQtLote += SZE->ZE_QTD1UM
								msunlock()
							EndIF

							reclock('TMP',.f.)    //exclui do markbrow
							TMP->(dbDelete())
							msunlock()
							TMP->(dbSkip())
						Enddo

						//bloco para criar vetor para geração da OP
						area       := GetArea()
						ret 	   := .T.
						_cCodProd  := GetAdvFVal('SZD',{'ZD_FORNECE','ZD_LOJA'},FWxfilial('SZD')+SZE->ZE_NUMERO,1)

						Reclock('SZ4',.t.)
						SZ4->Z4_FILIAL  := FWxFilial('SZ4')
						SZ4->Z4_NUM     := _numDet
						SZ4->Z4_NUMAM   := M->ZG_NUMAM
						SZ4->Z4_LOTE    := Strzero(nLote,6)
						SZ4->Z4_IDLOT   := Strzero(nLote,6)
						SZ4->Z4_RASTRO  := If(!Empty( SZE->ZE_RASTRO ),'S','N')
						SZ4->Z4_PROGRAM := SZE->ZE_PROGRAM
						SZ4->Z4_DESCPRO := GetAdvFVal('SZ6','Z6_DESC',FWxfilial('SZ6')+SZE->ZE_PROGRAM,1)
						SZ4->Z4_FORNECE := _cCodProd[1]
						SZ4->Z4_LOJA    := _cCodProd[2]
						SZ4->Z4_NOME    := GetAdvFVal('SA2','A2_NOME',FWxfilial('SA2')+_cCodProd[1]+_cCodProd[2],1)
						SZ4->Z4_GTA     := SZE->ZE_GTA
						SZ4->Z4_HORA    := SZE->ZE_HORA
						SZ4->Z4_CATEG   := SZE->ZE_CATEG
						SZ4->Z4_DESCAT  := GetAdvFVal('SZ5','Z5_DESC',FWxfilial('SZ5')+SZE->ZE_CATEG,1)
						SZ4->Z4_QUANT   := nQtLote
						SZ4->Z4_SEXO    := GetAdvFVal('SZ5','Z5_SEXO',FWxFilial('SZ5')+cCateg,1)
						SZ4->Z4_CLASSIF := GetAdvFVal('ZP6','ZP6_CODCLA',FWxfilial('ZP6') + "1",3)		// 'LG' - substituído em 03/10/2022
						SZ4->Z4_DATA    := M->ZG_DATA
						SZ4->Z4_COMPRAD := GetAdvFVal('SZA','ZA_COMPRA',FWxfilial('SZA')+SZE->ZE_NUMSC,1)
						SZ4->Z4_STATUSP := 'B'
						Msunlock()

						//Bloco de sincronia
						/*_cQuery := "INSERT INTO" + RetSQLTab('SZ4') + " (Z4_FILIAL,Z4_NUM,Z4_NUMAM,Z4_LOTE,Z4_IDLOT,Z4_RASTRO,Z4_PROGRAM,Z4_DESCPRO,"
						_cQuery += "Z4_FORNECE,Z4_LOJA,Z4_NOME,Z4_GTA,Z4_HORA,Z4_CATEG,Z4_DESCAT,Z4_QUANT,Z4_SEXO,Z4_CLASSIF,Z4_DATA,Z4_SINC,R_E_C_N_O_)"
						_cQuery += "VALUES ('"+FWxfilial('SZ4')
						_cQuery += "','"+SZ4->Z4_NUM
						_cQuery += "','"+SZ4->Z4_NUMAM
						_cQuery += "','"+SZ4->Z4_LOTE
						_cQuery += "','"+SZ4->Z4_IDLOT
						_cQuery += "','"+SZ4->Z4_RASTRO
						_cQuery += "','"+SZ4->Z4_PROGRAM
						_cQuery += "','"+SZ4->Z4_DESCPRO
						_cQuery += "','"+SZ4->Z4_FORNECE
						_cQuery += "','"+SZ4->Z4_LOJA
						_cQuery += "','"+SZ4->Z4_NOME
						_cQuery += "','"+SZ4->Z4_GTA
						_cQuery += "','"+SZ4->Z4_HORA
						_cQuery += "','"+SZ4->Z4_CATEG
						_cQuery += "','"+SZ4->Z4_DESCAT
						_cQuery += "',"+str(SZ4->Z4_QUANT)
						_cQuery += ",'"+SZ4->Z4_SEXO
						_cQuery += "','"+SZ4->Z4_CLASSIF
						_cQuery += "','"+DTOS(SZ4->Z4_DATA)+"','OK',"+STR(SZ4->(RECNO()))+",)"*/
						//Fim do bloco de sincronia

						//nLote++
						//Fim do bloco para criar vetor para geração da OP
					Enddo
				Enddo
			Enddo
		Enddo
	Enddo

	/*
	//Geração da OP de abate depois de gerado o vetor aMata650 nos laços acima
	//Por Giuliano Forgiarini em 05/07/2012
	MSExecAuto({|x,y| mata650(x,y)},aMata650,3)
	If lMsErroAuto
	MostraErro()
	lOk := .f.
	endif
	*/

	If !lOk
		Rollbacksx8()
	Endif

	RestArea(area)

	Set Filter To

	/* Dia 17/11/21 - Retirado esta coleta de informações. Deixado a coleta para o sistema das planilhas.*/
	if  GetMV('SI_BRCSTAR')
		// UFSM -  Comunicação com o programa das Tabelas da Rastreabilidade
		NUMAM := M->ZG_NUMAM
		CriaRastOrdemMatanca(M->ZG_NUMAM)
	endif

Return


User Function ExcPcp015()

	If !FWAlertYesNo("Você tem certeza que quer excluir a ordem de matança n° " + SZG->ZG_NUMAM,"CONFIRMAÇÃO")
		Return
	Endif

	//Testa se já houve mov. de producao
	SZ4->(dbSetOrder(1))  //aviso mat + lote
	SZ4->(MsSeek(FWxFilial('SZ4')+Rtrim(SZG->ZG_NUMAM)))
	Do While !SZ4->(Eof()) .AND. SZ4->Z4_NUMAM == SZG->ZG_NUMAM
		IF SZ4->Z4_QTREAL <> 0
			FWAlertError("Ordem de matança já possui abates!","OPERAÇÃO NEGADA!")
			Return
		Endif
		SZ4->(dbSkip())
	Enddo

	Private area := GetArea()

	Begin Transaction

		SZ4->(DbSetorder(1))
		SZ4->(MsSeek(FWxfilial('SZ4')+SZG->ZG_NUMAM))
		While SZ4->(!eof()) .and. SZ4->Z4_FILIAL = FWxfilial('SZ4') .and. SZ4->Z4_NUMAM = SZG->ZG_NUMAM
			RecLock('SZ4',.f.)
			SZ4->(dbDelete())
			msunlock()
			SZ4->(DbSkip())
		enddo

		//Exclui os rascunhos de producao - szk
		SZK->( dbSetOrder(2) ) //aviso mat + lote
		Do While SZK->( MsSeek(FWxFilial('SZK')+Rtrim(SZG->ZG_NUMAM) )  )
			RecLock('SZK',.F.)
			SZK->( dbDelete() )
			MsUnlock()
		Enddo

		//Libera as ordens de recebimento
		SZE->( dbSetOrder(2) ) // filial+no ordem+lote+categoria
		While SZE->( MsSeek( FWxFilial('SZE')+SZG->ZG_NUMAM ) )
			RecLock('SZE',.F.)
			SZE->ZE_NUMAM := Space(6)
			SZE->ZE_LOTE  := Space(6)
			MsUnlock()
		Enddo

		_cGrupo := substr(SZG->ZG_NUMAM,1,2)
		RecLock('SZG',.F.)
		SZG->(dbDelete())
		MsUnlock()

		putmv('MV_NOM_'+_cGrupo, getmv('MV_NOM_'+_cGrupo)-1)

	End Transaction

	RestArea( area )
Return

//marca todos
User Function PCP015mar()
	TMP->(dbgotop())

	dbSelectarea('TMP')
	dbGotop()
	do While !Eof()
		reclock('TMP',.f.)
		TMP->OK := cMark
		msunlock()
		dbSkip()
	Enddo

	TMP->(dbgotop())

	oMark:oBrowse:Refresh()

Return

//Desmarca todos
User Function PCP015des()

	dbSelectarea('TMP')
	TMP->(dbGotop())

	do While !Eof()
		reclock('TMP',.f.)
		TMP->OK := ' '
		msunlock()
		dbSkip()
	Enddo
	TMP->(dbgotop())
	oMark:oBrowse:Refresh()
Return


User Function ImpPcp015()
	Local cDesc1         := "O objetivo desta rotina é imprimir o"
	Local cDesc2         := "relatório de ordem de ordem de matança"
	Local cDesc3         := ""
	Local titulo         := "Ao Encarregado da I.F. " + GetMv("MV_NUMIF") + "        Ordem de matança " + transform(SZG->ZG_NUMAM,"@R 99.9999/99")
	Local nLin           := 80
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "PCP015" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := 'PCP015' // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SZG"
	Private cabec1  := 'Ordem do Abate                                         NE  Localidade               G0 Categ   Quantidade Curral           Hora'
	Private cabec2  := '    Numero do Lote  Produtor                                                                                 Rastro   Chegada   Lib'

	dbSelectArea("SZG")
	wnrel := SetPrint(cString,NomeProg,"PCY015",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Return
	Endif
	nTipo := If(aReturn[4]==1,15,18)
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local ix
	_cPerg := "PCY015"
	Pergunte(_cPerg,.F.)
	lAutoriz := (mv_par01 == 1 )       // imprime autorizante

	SetRegua(10)

	aCateg := { {'xxx',0 } } // lista de categorias

	SZD->( dbSetOrder(1) ) // numero de ordem de recebimento

	DbSelectArea('SZ4')
	dbSetOrder(1) // ordem+matanca+lote
	set filter to SZ4->Z4_NUMAM = SZG->ZG_NUMAM
	DbGotop()

	SZE->( dbSetOrder(2) ) // filial+no ordem matanca+lote+categoria

	aTPCOM := CTBCBOX('ZE_TPCOM')
	_cOrdLote := ''

	While SZ4->(!Eof())

		SZE->( MsSeek( FWxFilial('SZE')+SZ4->(Z4_NUMAM+Z4_LOTE),.f. ))

		While SZE->(!Eof()) .AND. SZE->(ZE_NUMAM+ZE_LOTE) == SZ4->(Z4_NUMAM+Z4_LOTE)

			IncProc()
			cLote   := SZE->ZE_LOTE
			nQuant  := 0    // quantidade do lote: num aviso+produtor+categoria
			nRastr  := 0    // quantidade de rastreads
			nOrfaos := 0    // quantidade de nao-rastreados

			SZD->( MsSeek( FWxFilial('SZD')+SZE->ZE_NUMERO) )

			cChe := SZD->ZD_HORA
			cHor := U_MataHora( SZG->ZG_DATA, SZD->ZD_HORA )
			dRec := SZG->ZG_DATA

			If nLin > 66
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9

				@ nLin,000      PSAY   'Data do Abate '
				@ nLin,pcol()+1 PSAY   drec picture "@D"

				nlin++
				nLin++

			Endif
			if _cOrdLote <> strzero(SZ4->Z4_ORDEM,3)+'/'+Strzero(VAL(SZE->ZE_LOTE),3)
				@ nLin,000 PSAY strzero(SZ4->Z4_ORDEM,3)+'/'+Strzero(VAL(SZE->ZE_LOTE),3)
				_cOrdLote := strzero(SZ4->Z4_ORDEM,3)+'/'+Strzero(VAL(SZE->ZE_LOTE),3)
			endif

			//	limite1 := 36
			//mcol1   := PCOL()+1
			cTexto1 := GetAdvFVal('SA2','A2_NOME',FWxFilial('SA2')+SZD->ZD_FORNECE+SZD->ZD_LOJA,1)

			@ nLin,010 PSAY  SA2->A2_COD+'-'+SA2->A2_LOJA
			@ nLin,020 PSAY  substr(cTexto1,1,20)

			@ nLin,046 PSAY  IIf(SZD->ZD_CERTIF=='N','S','N' )// Se nao tem certificado, NE=Sim(S)

			cTexto2 := GetAdvFVal('SA2','A2_MUN',FWxFilial('SA2')+SZD->ZD_FORNECE+SZD->ZD_LOJA,1)
			@ nLin,049 PSAY   substr(cTexto2,1,20)
			@ nLin,PCOL()+1 PSAY   SZ4->Z4_PROGRAM

			cMang := SZE->ZE_LOCAL

			While !Eof() .AND. SZE->ZE_NUMAM == SZG->ZG_NUMAM .AND. cLote == SZE->ZE_LOTE

				cLoc := SZE->ZE_LOCAL //Left(GetAdvFVal('SX5','X5_DESCRI',FWxFilial('SX5')+'74'+SZE->ZE_LOCAL,1),15)
				nQuant += SZE->ZE_QTD1UM

				If !Empty( SZE->ZE_RASTRO )
					nRastr  += SZE->ZE_QTD1UM
				Endif

				//totaliza por categoria
				onde := Ascan( aCateg, { |reg| reg[1] == SZE->ZE_CATEG } )

				If onde == 0
					AAdd( aCateg, { SZE->ZE_CATEG, SZE->ZE_QTD1UM } )
				Else
					aCateg[ onde,2 ] :=  aCateg[ onde,2 ] + SZE->ZE_QTD1UM
				Endif

				cCAt := Left(GetAdvFVal('SZ5','Z5_DESC',FWxFilial('SZ5')+SZE->ZE_CATEG,1),10)

				n    := ASCAN(aTpcom, {|x| left(x,1)==SZE->ZE_TPCOM})
				cTPC := iif(n==0, space(7), padr(substr(atpcom[n],3),7))

				SZE->(dbSkip())

				If SZE->ZE_LOCAL <> cMang  // abrir por mangueira
					Exit
				Endif

			Enddo

			//@ nLin,PCOL()+1  PSAY   space(1) //ctpc
			@ nLin,PCOL()+1  PSAY   cCat
			@ nLin,PCOL()+1  PSAY   nQuant  Picture '@e 999,999'
			@ nLin,PCOL()+1  PSAY   Space(2)+Right(cLoc,1)
			@ nLin,PCOL()+1  PSAY   iif(nRastr==0,'  Não ','  Sim ')
			@ nLin,PCOL()+2  PSAY   cChe
			@ nLin,PCOL()+5  PSAY   cHor

			// imprime o restante do texto do produto e cidade
			If .f. //!Empty( Substr( cTexto1, limite1 + 1 )) .OR. !Empty( Substr( cTexto2, limite2 + 1 ) )
				nlin++
				If nLin > 66
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				Endif
				@ nLin, mcol1 PSAY Substr( cTexto1, limite1 + 1 )
				@ nLin, mcol2 PSAY Substr( cTexto2, limite2 + 1 )
				nLin++
			Else
				nLin += 2
			Endif

		Enddo

		SZ4->(DbSKIP())
	Enddo

	nLin++
	nTot := 0
	//imprime totais por categoria

	If Len( aCateg ) > 1
		For ix := 2 to Len( aCateg )
			If nLin > 66
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			Endif
			@ nLin,000      PSAY 'Total de '
			@ nLin,PCOL()+1 PSAY Left(GetAdvFVal('SZ5','Z5_DESC',FWxFilial('SZ5')+aCateg[ix,1],1),10)+':'
			@ nLin,PCOL()+1 PSAY aCateg[ix,2] Picture '@e 999,999'
			nLin++
			nTot += aCateg[ix,2]
		Next ix
		@ nLin,0        PSAY "Total de animais:    "
		@ nLin,pcol()+1 PSAY ntot Picture '@e 999,999'
		nLin++

	Endif

	// Imprimir o total acumulado anualmente por grupo/ano?

	nLin += 5
	If lAutoriz
		@ nLin,000      PSAY   '---------------------------- '
		@ ++nLin,000      PSAY   SZG->ZG_AUTOR   // C,80
		@ ++nLin,000      PSAY   'Autorizante'
	Endif

	DbSelectArea('SZ4')
	dbSetOrder(10) // ordem+matanca+lote
	set filter to
	DbGotop()

	SET DEVICE TO SCREEN
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return

//Calcula a hora de liberacao da matanca
//a partir da hora de chegada
User Function MataHora( datax, horax )
	Private dRec := datax
	Private cHor := horax  + ':00'
	cHor := inctime(cHor,12,0,0)

	if val(left(chor,2)) > 24
		cHor := left(dectime(cHor,24,0,0),5)
	else
		cHor := '00:01'
	endif
Return cHor


User Function PCP015I()
	_aMarkI := GetArea()
	If IsMark( 'OK', cMark )
		RecLock( 'TMP', .F. )
		Replace TMP->OK With Space(Len(TMP->OK))
		MsUnLock()
	Else
		RecLock( 'TMP', .F. )
		Replace TMP->OK With cMark
		MsUnLock()
	EndIf
	RestArea(_aMarkI)
Return


User Function PCP015A()
	_aMarkAll1 := GetArea()
	DbSelectArea("TMP")
	TMP->(DbGoTop())
	Do While TMP->(!EoF())
		_aMarkAll2 := GetArea()
		U_PCP015I()
		RestArea(_aMarkAll2)
		DbSelectArea("TMP")
		TMP->(DbSkip())
		Loop
	Enddo
	RestArea(_aMarkAll1)
Return

//Rotina de encerramento de abate
User Function pcp15E()
	SZ4->(DbGoTop())
	SZK->(DbGoTop())
	SZ4->(DbSetOrder(1))
	SZK->(DbSetOrder(2))
	_nQtdAbt := 0

	If FWAlertYesNo('Deseja realmente encerrar o aviso de matança?','CONFIRMAÇÃO DE OPERAÇÃO')
		if SZ4->(MsSeek(FWxfilial('SZ4')+SZG->ZG_NUMAM))
			while SZ4->(!eof()) .and. FWxFilial('SZ4') = SZ4->Z4_FILIAL .and. SZ4->Z4_NUMAM = SZG->ZG_NUMAM
				_nCont := 0
				if SZK->(MsSeek(FWxfilial('SZK') + SZ4->(Z4_NUMAM + Z4_LOTE)))
					while SZK->(!eof()) .and. FWxFilial('SZK') = SZK->ZK_FILIAL .and. SZK->ZK_NUMAM = SZ4->Z4_NUMAM .and. SZK->ZK_LOTE = SZ4->Z4_LOTE
						if !empty(SZK->ZK_OK)
							_nCont++
							_nQtdAbt++
						else
							reclock('SZK',.f.)
							DbDelete()
							msunlock()
						endif

						SZK->(DbSkip())
					enddo
				endif

				//Encerra SZ4
				reclock('SZ4',.f.)
				if _nCont <= 0
					DbDelete()
				else
					SZ4->Z4_QUANT  := _nCont
					SZ4->Z4_QTREAL := _nCont
				endif
				msunlock()

				SZ4->(DbSkip())
			enddo
		endif

		//Encerra SZG
		reclock('SZG',.f.)
		SZG->ZG_STATUS := 'E'
		SZG->ZG_QTDTOT := _nQtdAbt
		msunlock()

		u_dtilog(cFilAnt, "PCP015", "Abate " + SZG->ZG_NUMAM + " encerrado manualmente", "E")

		MsgRun("Aguarde... Realizando processamento de registros... " + SZG->ZG_NUMAM ,,{||  u_GJF233(SZG->ZG_NUMAM) })
	Endif
return

//Função de retorno da sincronia
//Tabelas SZG, SZ4 e SZK
Static Function SincRet()

	//Varificação da tabela SZG
	//ZG_FILIAL,ZG_NUMAM,ZG_AUTOR,ZG_QTDTOT,ZG_LOCAL,ZG_DATA,ZG_STATUS,ZG_OBS,ZG_SINC,R_E_C_N_O_
	_cQuery := "SELECT * FROM " + RetSQLTab('SZG') + " WHERE " + RetSQLFil('SZG')+ " AND ZG_SINCRET = 'AN' "
	_cAlias := '_SZG'

	if u_GF192b(_cQuery,_cAlias)

		_SZG->(DbGoTop())

		while _SZG->(!eof())

			If (TCIsConnected())

				_cQRY := " UPDATE " + RetSQLTab('SZG') + " SET "
				_cQRY += " ZG_AUTOR   = '" + _SZG->ZG_AUTOR +"',"
				_cQRY += " ZG_QTDTOT  = " + str(_SZG->ZG_QTDTOT) +","
				_cQRY += " ZG_LOCAL   = '" + _SZG->ZG_LOCAL +"',"
				_cQRY += " ZG_DATA    = '" + _SZG->ZG_DATA +"',"
				_cQRY += " ZG_STATUS  = '" + _SZG->ZG_STATUS +"',"
				_cQRY += " ZG_OBS     = '" + _SZG->ZG_OBS +"',"
				_cQRY += " ZG_SINCRET = 'OK',"
				_cQRY += " D_E_L_E_T_ = '" + _SZG->D_E_L_E_T_ +"'"
				_cQry += " WHERE ZG_FILIAL  = '" + _SZG->ZG_FILIAL +"' AND ZG_NUMAM = '" + _SZG->ZG_NUMAM + "'"
				_nStat := TCSQLExec(_cQRY)

			EndIf
			_SZG->(DbSkip())
		enddo
	endif

	//Varificação da tabela SZ4
	//" Z4_FILIAL,Z4_NUM,Z4_NUMAM,Z4_LOTE,Z4_IDLOT,Z4_RASTRO,Z4_PROGRAM,Z4_DESCPRO,"
	//"Z4_FORNECE,Z4_LOJA,Z4_NOME,Z4_GTA,Z4_HORA,Z4_CATEG,Z4_DESCAT,Z4_QUANT,Z4_SEXO,Z4_CLASSIF,Z4_DATA,Z4_SINC,R_E_C_N_O_"
	_cQuery := "SELECT * FROM " + RetSQLTab('SZ4') + " WHERE " + RetSQLFil('SZ4')+ " AND Z4_SINCRET = 'AN' "
	_cAlias := '_SZ4'

	if u_GF192b(_cQuery,_cAlias)

		_SZ4->(DbGoTop())

		while _SZ4->(!eof())

			If (TCIsConnected())

				_cQRY := " UPDATE " + RetSQLTab('SZ4') + " SET "
				_cQRY += " Z4_NUMAM   = '" + _SZ4->Z4_NUMAM +"',"
				_cQRY += " Z4_LOTE    = '" + _SZ4->Z4_LOTE +"',"
				_cQRY += " Z4_IDLOT   = '" + _SZ4->Z4_IDLOT +"',"
				_cQRY += " Z4_RASTRO  = '" + _SZ4->Z4_RASTRO +"',"
				_cQRY += " Z4_PROGRAM = '" + _SZ4->Z4_PROGRAM +"',"
				_cQRY += " Z4_DESCPRO = '" + _SZ4->Z4_DESCPRO +"',"
				_cQRY += " Z4_FORNECE = '" + _SZ4->Z4_FORNECE +"',"
				_cQRY += " Z4_LOJA    = '" + _SZ4->Z4_LOJA +"',"
				_cQRY += " Z4_NOME    = '" + _SZ4->Z4_NOME +"',"
				_cQRY += " Z4_GTA     = '" + _SZ4->Z4_GTA +"',"
				_cQRY += " Z4_HORA    = '" + _SZ4->Z4_HORA +"',"
				_cQRY += " Z4_CATEG   = '" + _SZ4->Z4_CATEG +"',"
				_cQRY += " Z4_DESCAT  = '" + _SZ4->Z4_DESCAT +"',"
				_cQRY += " Z4_QUANT   =  " + str(_SZ4->Z4_QUANT) +","
				_cQRY += " Z4_SEXO    = '" + _SZ4->Z4_SEXO +"',"
				_cQRY += " Z4_CLASSIF = '" + _SZ4->Z4_CLASSIF +"',"
				_cQRY += " Z4_DATA    = '" + _SZ4->Z4_DATA +"',"
				_cQRY += " Z4_SINCRET = '" + _SZ4->Z4_SINCRET +"',"
				_cQRY += " D_E_L_E_T_ = '" + _SZ4->D_E_L_E_T_ +"'"
				_cQry += " WHERE Z4_FILIAL  = '" + _SZ4->Z4_FILIAL +"' AND Z4_NUM = '" + _SZ4->Z4_NUM + "'"
				_nStat := TCSQLExec(_cQRY)

			EndIf
			_SZ4->(DbSkip())
		enddo
	endif
return


Static Function getJson(NUMAM)
	local jJson
	jJson := JsonObject():New()

	jJson["USUARIO"] := "usuario@protheus"
	jJson["SENHA"] := "admin"
	jJson["NUMAM"] := NUMAM

return jJson:ToJson()


Static function CriaRastOrdemMatanca(NUMAM)

	Local aHeader as array
	Local cResource as char
	Local cServer as char
	Local cPort as char
	Local cURI as char
	Local oRestClient as object

	aHeader := {}
	cResource := "/protheus/ordem-matanca"
	//cServer := "10.0.20.7" // URL (IP) DO SERVIDOR
	cServer := "10.0.20.9"
	cPort := "80" // PORTA DO SERVIÇO REST
	cURI := "http://" + cServer + "/api" // URI DO SERVIÇO REST

	oRestClient := FwRest():New(cURI)

	AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	AAdd(aHeader, "Accept: application/json")
	AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

	oRestClient:setPath(cResource)
	oRestClient:SetPostParams(getJson(NUMAM))

	oRestClient:Post(aHeader)

	FreeObj(oRestClient)

return
