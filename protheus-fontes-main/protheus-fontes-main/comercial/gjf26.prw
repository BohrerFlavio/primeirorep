#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"
#INCLUDE "Totvs.ch"

Static __cArqLog1
Static __cArqLog2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF26     ºAutor  ³Giuliano Forgiarini º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gerenciamento de pré-carregamentos                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaoms - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF26()

	lOk := .f.
	Private aCores   := {}
	Private aCores2  := {}
	Private _cHoraPortal := GetMv('SI_HORAPOR')
	Private _lSldFlag   := .f.    //Para utilizaçao da função gjf28sld()
	Private _lSalv      := .f.
	Private _cEmpresa := FWCodEmp()

	aObjects := {}                                            // dimensao janelas
	aPosObj  := {}
	aInfo    := {}

	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 :=  "ZZ3->ZZ3_STATUS == 'A'"
	bLegenda2 :=  "ZZ3->ZZ3_STATUS == 'C'"
	bLegenda3 :=  "ZZ3->ZZ3_STATUS == 'B'"
	bLegenda4 :=  "ZZ3->ZZ3_STATUS == 'E'"
	bLegenda5 :=  "ZZ3->ZZ3_STATUS == 'S'"
	bLegenda6 :=  "ZZ3->ZZ3_STATUS == 'F'"

	aCores2:= { {'BR_VERDE'   ,'Aberto'    },;
				{'BR_AMARELO' ,'Carregando'},;
				{'BR_AZUL'    ,'Bloqueado' },;
				{'BR_VERMELHO','Encerrado' },;
				{'BR_LARANJA' ,'Em Espera' },;
				{'BR_PRETO' ,'Faturado '   }}

	aCores := { {bLegenda1, 'BR_VERDE'   },;
				{bLegenda2, 'BR_AMARELO' },;
				{bLegenda3, 'BR_AZUL'    },;
				{bLegenda4, 'BR_VERMELHO'},;
				{bLegenda5, 'BR_LARANJA' },;
				{bLegenda6, 'BR_PRETO' }}

	Private cPerg1   := "GJF26"
	Private cPerg    := cPerg1
	Private cFilAux  := FWxfilial('SE1')
	Private cCadastro := "Previsão de Gerenciamento de Pré-carregamentos e pré-pedidos"
	Private aRotina  := MenuDef()                             // Chamada da funcao menudef() que contem aRotina
	
	if !pergunte(cPerg1,.t.)
		return
	endif

	Private cString := "ZZ3"
	//Indice para a filtragem
	cCondicao := "ZZ3_DTCAR >=  '" + dtos(mv_par01) + "' AND ZZ3_DTCAR <=  '" + dtos(mv_par02) + "'" +;
	" AND ZZ3_FILIAL = '" + FWxfilial('ZZ3') + "'" //String para filtro
	//Aplicação da filtragem

	dbSelectArea(cString)
	ZZ3->(dbSetOrder(1))
	ZZ3->(dbgobottom())

	//mbrowse sem a função AutoRefresh para atualizar o browse automaticamente
	mBrowse(6,1,22,75,cString, ,,,,2,aCores,,,,,,,,cCondicao)

	//mBrowse(6,1,22,75,cString, ,,,,2,aCores,,,,{|x| AutoRefresh(x)},,,,cCondicao)
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores

	If Select('ZZ3')<>0
		ZZ3->(dbCloseArea())
	Endif

	If Select('ZZ4')<>0
		ZZ4->(dbCloseArea())
	Endif

return

//INCLUSAO DE UM PRÉ-CARREGAMENTO
User Function gjf26inc()
	Local nCont
	lOk := .f.

	DEFINE MSDIALOG oDlg TITLE 'Pré-Carregamentos' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("ZZ3",.T.)
	obj := MsMGet():New("ZZ3" ,ZZ3->(RECNO()),3   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )
	// inst.  obj.     met. alias,registro      ,oper,p.res,p.res,p.res,vet.campos,vet.coord.,vet.campos.alt, ,
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf26ok()},{||gjf26nok()})

	If lOk
		begin transaction
			recLock('ZZ3',.T.)
			// Grava pré-carregamento
			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,FWxFilial("ZZ3"))
				Else
					FieldPut(nCont,M->&(FIELDNAME(nCont)))
				Endif
			Next nCont
			ConfirmSx8()
			MsUnLock()
		end transaction
	else
		RollBackSx8()
	endif

return

//ALTERAÇAO DO PRÉ-CARREGAMENTO
User Function gjf26alt()
	Local nCont

	if ZZ3->ZZ3_STATUS == 'C' .or. ZZ3->ZZ3_STATUS = 'E' .or. ZZ3->ZZ3_STATUS = 'F'        //Essa condicional verifica o status do PCar
		msgbox('Status não permite alteração!','ERRO','STOP')
		return .f.
	endif

	// ------------ INICIO TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION
	/*
	_cUsuarios := GetMv('MV_MENCOM')
	_cCodUser  := RetCodUsr()

	If U_BLQ_FUS(ZZ3->ZZ3_NUM)
		If AllTrim(_cCodUser) $ _cUsuarios
			If FWAlertYesNo("Deseja realizar a Alteração ?","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
				_xRet := U_PSW_LIB(ZZ3->ZZ3_NUM, 1)		// Passo 1 no segundo parâmetro quando informado pré-carregamento no primeiro parâmetro
				If !_xRet
					Return .F.
				EndIf
			Else
				Return .F.
			EndIf
		Else
			FWAlertError("Não é permitido manutenção neste pré-carregamento.","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
			Return .F.
		EndIf
	EndIf
	*/
	// ------------ FINAL TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION

	lOk := .f.

	DEFINE MSDIALOG oDlg TITLE 'Pré-Carregamentos' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("ZZ3",.f.)
	M->ZZ3_USUALT     := cUserName
	M->ZZ3_STATUS     := 'B'
	obj := MsMGet():New("ZZ3" ,ZZ3->(RECNO()),4   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )
	// inst.  obj.     met. alias,registro      ,oper,p.res,p.res,p.res,vet.campos,vet.coord.,vet.campos.alt, ,
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf26ok()},{||gjf26nok()})

	If lOk
		begin transaction
			recLock('ZZ3',.f.)
			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,FWxFilial("ZZ3"))
				Else
					FieldPut(nCont,M->&(FIELDNAME(nCont)))
				Endif
			Next nCont
			MsUnLock()
		end transaction
	endif

return


//Função static para validar a inclusão de um novo Pré-Carregamento
static function gjf26ok()
	
	if !empty(M->ZZ3_DTCAR) .and. !empty(M->ZZ3_PLACA)
		lOk := .t.
		oDlg:end()
	else
		msgbox('Campos em branco!','ERRO!','STOP')
	endif
	
	
return lOk

//Função de validação do veículo
Static Function gjf26VV()
	if M->ZZ3_PROPRI = 'S'
		DA3->(DbSetOrder(3))
		if !DA3->(MsSeek(FWxfilial('DA3')+alltrim(M->ZZ3_PLACA)))
			msgbox('Veiculo próprio não existe no cadastro!','ERRO!','STOP')
			return .f.
		elseif DA3->DA3_ATIVO <> '1'
			msgbox('Veiculo próprio inativo!','ERRO!','STOP')
			return .f.
		endif
	endif

return .t.

//Função static para cancelar a inclusão de um Pré-Carregamento
static function gjf26nok()
	lOk := .f.
	Odlg:end()
Return lOk

//EXCLUSAO DE UM PRE-CARREGAMENTO
User Function gjf26exc()

	if ZZ3->ZZ3_STATUS != 'B'
		alert('Status não permite exclusão do pré-carregamento!','ERRO','STOP')  //Verificação de status do Pré-Carregamento
		return
	endif

	ZZ4->(dbsetorder(1))
	if ZZ4->(Msseek(FWxfilial('ZZ4')+ZZ3->ZZ3_NUM))
		msgbox('Existem pré-pedidos vinculados a este pré-carregamento!','ERRO','STOP')   //Verifica se algum Pré-Pedido não está encerrado
		return
	endif

	if APMSGYESNO('Confirma Exclusão do Carregamento?','ATENÇÃO')
		reclock('ZZ3',.f.)
		dbdelete()
		msunlock()
	endif

return

//ENCERRAMENTO DE UM PRE-CARREGAMENTO
User Function gjf26enc()

	if ZZ3->ZZ3_PESAR = 'S'
		alert('Não é possível encerrar manualmente este Pre-Carregamento!','ERRO','STOP')  //Verificação de status do Pré-Carregamento
		return
	endif

	if APMSGYESNO('Confirma encerramento do Pre-Carregamento?','ATENÇÃO')
		reclock('ZZ3',.f.)
		ZZ3->ZZ3_STATUS := 'E'
		msunlock()
		//Bloco destinado a limpeza das caixas separadas para carregamento e gravacao das mesmas no historico
		u_devSeparacao(ZZ3->ZZ3_NUM)
	endif

return

// Função para ativa opção de visualização da legenda
User Function gjf26lPC
	BrwLegenda('Pré-Carregamentos','Legenda',aCores2)
return

// VINCULAÇÃO DE PRE-PEDIDOS AO CARREGAMENTO
User Function gjf26vinc()

	private aRotina :={}
	Private _cOri := ''
	Private lInverte := .f.
	Private cMark    := GetMark()
	Private oMark
	Private cPerg2   := "GJF26I"
	Private marc     := .f.

	if !pergunte(cPerg2,.t.)
		pergunte(cPerg1,.f.)
		return
	endif

	area := getarea()

	if !(ZZ3->ZZ3_STATUS $ 'BSA')
		alert('Status não permite vinculação ao pré-carregamento','ERRO','STOP')
		pergunte(cPerg1,.f.)
		return
	endif

	/*/ESTAVA COMETADA JÁ, VER SE NÃO IRA INFLUENCIAR
	if !(ZZ5->ZZ5_USRSOL .or. ZZ5_DTSPOR <> '') // Caso for ATM mostrar para usuario
		alert('Produto ATM','ERRO','STOP')
		pergunte(cPerg1,.f.)
		return
	endif/*/

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	// ------------ INICIO TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION
	/*
	_cUsuarios := GetMv('MV_MENCOM')
	_cCodUser  := RetCodUsr()

	If U_BLQ_FUS(ZZ3->ZZ3_NUM)
		If AllTrim(_cCodUser) $ _cUsuarios
			If FWAlertYesNo("Deseja realizar a vinculação ao pré-carregamento ?","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
				_xRet := U_PSW_LIB(ZZ3->ZZ3_NUM, 1)		// Passo 1 no segundo parâmetro quando informado pré-carregamento no primeiro parâmetro
				If !_xRet
					Return .F.
				EndIf
			Else
				Return .F.
			EndIf
		Else
			FWAlertError("Não é permitido manutenção neste pré-carregamento.","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
			Return .F.
		EndIf
	EndIf
	*/
	// ------------ FINAL TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION


	dbSelectarea('ZZ4')
	ZZ4->(dbSetOrder(1))

	aStru := {}
	_aArqTrb := {}

	AADD(aStru,{"ZZ4_OK"      ,"C"	,2		,0	})
	aadd(aStru,{"ZZ4_DESORI"  , "C"  ,30   ,0 })
	AADD(aStru,{"ZZ4_NUM"     ,"C"	,6		,0	})
	AADD(aStru,{"ZZ4_MARCA"   ,"C"	,2		,0 })
	AADD(aStru,{"ZZ4_CODCLI"  ,"C"	,6		,0	})
	AADD(aStru,{"ZZ4_LOJA"    ,"C"	,2		,0 })
	AADD(aStru,{"ZZ4_NOME"    ,"C"	,30	,0	})
	AADD(aStru,{"ZZ4_NOMREP"  ,"C"	,20	,0	})
	AADD(aStru,{"ZZ4_MUN "    ,"C"	,20	,0	})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	//TMP->(dbgotop())

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)


	ZZ4->(dbgotop())
	//Esse laço serve para atribuir ao TMP os valores
	while ZZ4->(!eof()) .and. empty(ZZ4->ZZ4_PRECAR)

		if mv_par02 = 1
			if ZZ4->ZZ4_ORIGEM <> 'D'
				ZZ4->(DbSkip())
				loop
			endif
		elseif mv_par02 = 2
			if ZZ4->ZZ4_ORIGEM <> 'E'
				ZZ4->(DbSkip())
				loop
			endif
		elseif mv_par02 = 3
			if ZZ4->ZZ4_ORIGEM <> 'P'
				ZZ4->(DbSkip())
				loop
			endif
			if  !empty(mv_par01)
				if  ZZ4->ZZ4_REPRES <> mv_par01
					ZZ4->(DbSkip())
					loop
				endif
			endif
		endif

		if ZZ4->ZZ4_ORIGEM = 'P' .and. !empty(_cHoraPortal)
			if ZZ4->ZZ4_DATAC = DDATABASE .and.;
			ZZ4->ZZ4_HORAC > _cHoraPortal
				ZZ4->(DbSkip())
				loop
			endif
		endif

		if ZZ4->ZZ4_DATAC < mv_par03 .or. ZZ4->ZZ4_DATAC > mv_par04
			ZZ4->(DbSkip())
			loop
		endif

		do case
			case ZZ4->ZZ4_ORIGEM = 'D'
			_cOri := 'Digitação'
			case ZZ4->ZZ4_ORIGEM = 'E'
			_cOri := 'EDI'
			case ZZ4->ZZ4_ORIGEM = 'P'
			_cOri := 'Portal'
		endcase

		DbSelectArea('TMP')
		reclock('TMP',.t.)
		TMP->ZZ4_NUM    := ZZ4->ZZ4_NUM
		TMP->ZZ4_CODCLI := ZZ4->ZZ4_CODCLI
		TMP->ZZ4_LOJA   := ZZ4->ZZ4_LOJA
		TMP->ZZ4_NOME   := ZZ4->ZZ4_NOME
		TMP->ZZ4_MARCA  := ZZ4->ZZ4_MARCA
		TMP->ZZ4_NOMREP := ZZ4->ZZ4_NOMREP
		TMP->ZZ4_DESORI := _cOri
		TMP->ZZ4_MUN    := ZZ4->ZZ4_MUN
		msunlock()

		ZZ4->(dbskip())
	enddo

	aCampos := {}

	AADD(aCampos,{"ZZ4_OK"      ,, "OK"       ,"@!"   })
	AADD(aCampos,{"ZZ4_NUM"     ,, "Numero"     ,"@!"   })
	AADD(aCampos,{"ZZ4_CODCLI"  ,, "Cod.Cliente","@!"   })
	AADD(aCampos,{"ZZ4_LOJA"    ,, "Loja"       ,"@!"   })
	AADD(aCampos,{"ZZ4_NOME "   ,, "Descricao"  ,"@!"   })
	AADD(aCampos,{"ZZ4_MARCA"   ,, "Marca"      ,"@E 99"})
	AADD(aCampos,{"ZZ4_NOMREP"  ,, "Repres."    ,"@!"   })
	AADD(aCampos,{"ZZ4_DESORI"  ,, "Origem"     ,"@!"   })
	AADD(aCampos,{"ZZ4_MUN"     ,, "Municipio"  ,"@!"   })

	dbselectarea('TMP')

	TMP->(dbgotop())

	DEFINE MSDIALOG oDlg TITLE "Vincular Pré-pedidos" From 9,0 To 400,1000 PIXEL
	oMark := MsSelect():New("TMP","ZZ4_OK","",aCampos,@lInverte,@cMark,{17,1,160,500},,,,,)
	oMark:bMark := {| | Disp()}

	TButton():New(170, 020, "Marcar Todos"    , oDlg,{|| u_gjf26sel() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 070, "Vincular"        , oDlg,{|| u_gjf26vpp() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 120, "Pre-Pedido"      , oDlg,{|| u_gjf26cpp() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 390, "Sair"            , oDlg,{|| oDlg:end() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED

	pergunte(cPerg1,.f.)

Return(.T.)


// Efetua a consulta do pré-pedido que está posicionado
User Function gjf26cpp()

	Local oDlg		:= NIL
	Local nOpc      := 2
	Local aButtons	:= {}

	// as variáveis cCadastro e aRotina são obrigatórias para funcionamento da MsMGet() - não remover
    Private cCadastro := "Consulta Pré-Pedido de Venda"
    Private aRotina   := {{"Obrigatorio 1" , "AxVisual", 0, 2} ,;                        
                          {"Obrigatorio 2" , "AxVisual", 0, 2}  }                        
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	area := GetArea()

	aObjects := {}
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           := aPosObj[1]
	aX[3]        += 60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZ4")

	gjf26aHead("ZZ5")            // Monta oa vetor aHeader

	nUsado := Len(aHeader)

	gjf26aCols(nOpc)			 // Monta oa vetor aCols

	DbSelectArea('SA1')
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(FWxfilial('SA1') + TMP->(ZZ4_CODCLI+ZZ4_LOJA)))

	DbSelectArea("ZZ4")
	DbSetOrder(2)
	MsSeek(FWxFilial("ZZ4") + TMP->ZZ4_NUM)
	
	oEnc    := MsMGet():New("ZZ4" ,ZZ4->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","+ZZ5_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, , aButtons)

	RestArea(area)

Return


// Monta oa aHeader
Static Function gjf26aHead(cAlias)

	Local i
	aHeader := {}

	//DbSelectArea("SX3")
	//DbSetOrder(1)
	//MsSeek(cAlias)
	//Do While !Eof() .and. (X3_ARQUIVO == cAlias)
	//	If 	at(Upper(AllTrim(X3_CAMPO)), "ZZ5_FILIAL ZZ5_NUM") > 0
	//		DbSkip()
	//		Loop
	//	Endif
	//	If X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
	//		nUsado++
	//		aAdd(aHeader,{Trim(X3Titulo()),X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_ARQUIVO,X3_CONTEXT})
	//	Endif
	//	DbSkip()
	//Enddo

	_cAlias  := cAlias			// ZZ5
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 				.And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZZ5_FILIAL" .And. ;
		   AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) != "ZZ5_NUM")

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


// Montagem do aCols
static Function gjf26aCols(nOpc)
	Local nI, nPos
	If nOpc == 3
		aCols := Array(1,nUsado+1)
		For nI = 1 To Len(aHeader)
			If aHeader[nI,8] == "C"
				aCols[1,nI] := Space(aHeader[nI,4])
			ElseIf aHeader[nI,8] == "N"
				aCols[1,nI] := 0
			ElseIf aHeader[nI,8] == "D"
				aCols[1,nI] := CtoD(" / / ")
			ElseIf aHeader[nI,8] == "M"
				aCols[1,nI] := ""
			Else
				aCols[1,nI] := .F.
			EndIf
		Next nI

		nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZZ5_ITEM" })
		if nPos > 0
			aCols[1,nPos]	:= StrZero(len(acols)+1,Len(aCols[1,nPos]))
		endif
		aCols[1,nUsado+1] := .F.
	Else
		RegToMemory("ZZ4")

		dbSelectArea("ZZ5")
		dbSetOrder(1)
		MsSeek(FWxFilial('ZZ5')+TMP->ZZ4_NUM,.T.)
		Do While ZZ5->(!Eof()) .and. FWxFilial('ZZ5') ==  ZZ5->ZZ5_FILIAL .and. ZZ5->ZZ5_NUM == TMP->ZZ4_NUM
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

			ZZ5->(DbSkip())
		Enddo
	Endif

Return


Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("ZZ4_OK")
		TMP->ZZ4_OK := cMark
	Else
		TMP->ZZ4_OK := ""
	Endif
	msunlock()
	oMark:oBrowse:Refresh()
Return()

//Efetiva vinculação de um PP a um Pre-Carregamento
User Function gjf26vpp()

	If ZZ3->ZZ3_STATUS $ 'C/E/F'
		alert('Status do  Pré-Carregamento impede operação!')
		return
	endif

	ZZ4->(dbsetorder(1))
	TMP->(dbgotop())

	if TMP->(RecCount())<> 0

		while TMP->(!eof())                                                           //O campo com 'S' significa que o registro foi assinalado
			if !empty(TMP->ZZ4_OK)
				marc := .t.
				ZZ4->(dbsetorder(2))
				if ZZ4->(Msseek(FWxfilial('ZZ4')+TMP->ZZ4_NUM))

					reclock('ZZ4',.f.)
					ZZ4->ZZ4_PRECAR := ZZ3->ZZ3_NUM
					if ZZ4->ZZ4_STATUS = 'P'
						ZZ4->ZZ4_STATUS := 'B'
					endif
					//if empty(ZZ4->ZZ4_EMAILU)
					if empty(alltrim(ZZ4->ZZ4_EMAILU))
						ZZ4->ZZ4_EMAILU := u_gjf54USR()
					endif
					//if empty(ZZ4->ZZ4_USAR)
						ZZ4->ZZ4_USAR := cUserName
					//endif
					msunlock()
				endif
			endif
			TMP->(dbskip())
		enddo

		if marc
			msgbox('Pre-pedidos vinculados ao Pre-carregamento! '+ZZ3->ZZ3_NUM,"CONFIRMAÇÃO","INFO")
		else
			msgbox('Não houveram Pré-pedidos selecionados!',"OPERACAO NULA",'INFO')
		endif

	endif

	oDlg:end()

return

//Função que marca todos os pre-pedidos a serem vinculados

User Function gjf26sel()
	TMP->(dbgotop())

	while TMP->(!eof())
		reclock('TMP',.f.)
		TMP->ZZ4_OK := cMark
		msunlock()
		TMP->(dbskip())
	enddo

	TMP->(dbgotop())

	oMark:oBrowse:Refresh()

return .t.

//PRE-PEDIDOS DO PRE-CARREGAMENTO SELECIONADO
User Function gjf26pp()

	area := getarea()
	lOk := .f.
	Private aRotinaBKP0  := {}
	Private aCores      := {}
	Private aCores2     := {}

	// ------------ INICIO TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION
	/*
	_cUsuarios := GetMv('MV_MENCOM')
	_cCodUser  := RetCodUsr()

	If U_BLQ_FUS(ZZ3->ZZ3_NUM)
		If AllTrim(_cCodUser) $ _cUsuarios
			If FWAlertYesNo("Deseja realizar manutenção nos pré-pedidos ?","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
				_xRet := U_PSW_LIB(ZZ3->ZZ3_NUM, 1)		// Passo 1 no segundo parâmetro quando informado pré-carregamento no primeiro parâmetro
				If !_xRet
					Return .F.
				EndIf
			Else
				Return .F.
			EndIf
		Else
			FWAlertError("Não é permitido manutenção nos pré-pedidos.","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
			Return .F.
		EndIf
	EndIf
	*/
	// ------------ FINAL TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION
	
	aObjects := {}
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	bLegenda1 := "ZZ4->ZZ4_STATUS $ 'BP'"          // bloqueado
	bLegenda2 := "ZZ4->ZZ4_STATUS == 'C'"          // carregando
	bLegenda3 := "ZZ4->ZZ4_STATUS == 'L'"          // liberado
	bLegenda4 := "ZZ4->ZZ4_STATUS == 'E'"          // encerrado
	bLegenda5 := "ZZ4->ZZ4_STATUS == 'S'"          // em espera
	bLegenda6 := "ZZ4->ZZ4_STATUS == 'F'"          // faturado

	aCores := { {bLegenda1, 'BR_AZUL'    },;       // bloqueado
	{bLegenda2, 'BR_AMARELO' },;       // carregando
	{bLegenda3, 'BR_VERDE'   },;       // liberado
	{bLegenda4, 'BR_VERMELHO'},;       // encerrado
	{bLegenda5, 'BR_LARANJA' },;       // em espera
	{bLegenda6, 'BR_PRETO'   }}        // faturado
	//			   {bLegenda7, 'BR_BRANCO'  },;       // importado
	//			   {bLegenda8, 'BR_CINZA'   }}        // portal

	aCores2:= { { 'BR_AZUL'   ,'Bloqueado'      },;    // bloqueado
	{ 'BR_AMARELO'   ,'Carregando'  },;    // carregando
	{ 'BR_VERDE'     ,'Liberado'    },;    // liberado
	{ 'BR_VERMELHO'  ,'Encerrado'   },;    // encerrado
	{ 'BR_LARANJA'   ,'Em Espera'   },;    // em espera
	{ 'BR_PRETO'     ,'Faturado'    }}    // Faturado
	//				{ 'BR_BRANCO'    ,'Importado'   },;    // Importado
	//				{ 'BR_CINZA'     ,'Portal'      }}     // Portal

	Private cPerg3   := "GJF26P"

	Private cCadastro := "Pré-Pedidos de Venda"
	aRotinaBKP0 := aRotina
	aRotina := {{ "Pesquisa"	  		, "AxPesqui"  , 	0, 1},; 	//"Pesquisar"
				{ "Visualizar"	 		, "u_gjf28Visu", 	0, 2},; 	//"Visualizar"
				{ "Incluir"		  		, "u_gjf28Incl", 	0, 3},; 	//"Incluir"
				{ "Alterar"		  		, "u_gjf28Alte", 	0, 4},; 	//"Alterar"
				{ "Redistribuicao"		, "u_gjf28Redis", 	0, 5},; 	//"Redistribuicao"
				{ "Define DT. Produção"	, "u_gjf28DtProd", 	0, 5},; 	//"Def. Data Producao"
				{ "Datas Prod"	  		, "u_GJF133", 		0, 4},;	 	//"Definição do intervalo de produção"
				{ "Produtos"	  		, "u_gjf52Visp",  	0, 2},; 	//"Consultar"
				{ "Dev.Portal"	  		, "u_gjf28dev", 	0, 4},;     //"Devolver ao Portal"
				{ "Encerrar"	  		, "u_gjf28enc", 	0, 4},;     //"Encerrar"
				{ "Excluir"		  		, "u_gjf28Excl", 	0, 5},;     //"Excluir"
				{ "Consultar"	  		, "u_gjf28pos", 	0, 5},;     //"consultar"
				{ "Resumo Carga"  		, "u_gjf41"	, 		0, 4},;     //"Resumo Carga"
				{ "Enviar Fusion" 		, "u_gjf28F" , 		0, 3},;  	//"Enviar Fusion"
				{ "Cancelar Seq. Fusion", "u_gjf28CS", 		0, 3},;  	//"Cancelar Seq. Fusion"
				{ "Legenda"		  		, "u_gjf28Leg", 	0, 1},;     //"Legenda"
				{ "Define 1/3 Valid."	, "u_mitfs004", 	0, 5},; 	//"Seleciona Sim/Nao para selecao de caixas com 1/3 de validade"
				{ "Manif. Carga An" 	, "u_gjf26MaCA",	0 ,2},;		//"Relatório do manifesto de carga analítico"
				{ "Orcamento" 			, "u_gjf26orc", 	0, 3}}  	//"Orçamento"

	cString := 'ZZ4'
	if !pergunte(cPerg3,.t.)
		pergunte(cPerg1,.f.)
		return
	endif

	cCondicao2 := "ZZ4_PRECAR =  '" + ZZ3->ZZ3_NUM + "' AND ZZ4_FILIAL = '" + FWxfilial('ZZ4') + "'"

	cCondicao2 += iif(mv_par01 = 1, " AND ZZ4_TIPOPR = 'D' ",iif(mv_par01 = 2," AND ZZ4_TIPOPR = 'P' ",""))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a Filtragem                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea(cString)
	ZZ4->(dbSetOrder(1))

	//mBrowse sem a função AutoRefresh para atualização automática
	mBrowse(6,1,22,75,cString, ,,,,1,aCores,,,,,,,,cCondicao2)

	//mBrowse(6,1,22,75,cString, ,,,,1,aCores,,,,{|x| AutoRefresh(x)},,,,cCondicao2)
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores
	//Encerra o filtro e refaz os índices padrões
	aRotina := aRotinaBKP0
	restarea(area)

	pergunte(cPerg1,.f.)

	//só libera se o status do picking
	//if ZZ3->ZZ3_STPCK == 'B'
	//	reclock('ZZ3',.f.)
	//	ZZ3->ZZ3_STPCK  := 'L'
	//	ZZ3->ZZ3_USRPCK := ''
	//	msunlock()
	//endif

return

// Função utilizada para mostrar informações do pedido de forma resumida
// Pedido do Rodrigo para envio de PrintScreens
User Function gjf26orc()
	Local aIPPed := {}
	Local _cCodCli  	:= ZZ4->ZZ4_CODCLI
	Local _cNomeCli 	:= ZZ4->ZZ4_NOME
	Local _cLoja     	:= ZZ4->ZZ4_LOJA
	Local _nTotal     	:= 0.0

	_cQuery := "SELECT ZZ5_COD, ZZ5_DESC, ZZ5_QPCAIX, ZZ5_QPPESO, ZZ5_PRCFIN"
	_cQuery += " FROM  " + RetSQLTab('ZZ5') + " (NOLOCK)"
	_cQuery += " WHERE " + RetSQLFil('ZZ5')
	_cQuery += " AND ZZ5_NUM = '" + ZZ4->ZZ4_NUM + "'"
	_cQuery += " AND " + RetSQLDel('ZZ5')
	_cQuery += " ORDER BY ZZ5_ITEM"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	TMP->(dbGoTop())

	while (TMP->(!EOF()))
		Aadd(aIPPed, {TMP->ZZ5_COD, TMP->ZZ5_DESC, transform(TMP->ZZ5_QPCAIX, '@E 999,999'), transform(TMP->ZZ5_QPPESO, '@E 999,999.99') + " kg", "R$ " + transform(TMP->ZZ5_PRCFIN, '@E 999,999.99')})
		_nTotal += (TMP->ZZ5_QPPESO * TMP->ZZ5_PRCFIN)

		TMP->(dbSkip())
	end

	if empty(aIPPed) .or. Len(aIPPed) = 0
		Aadd(aIPPed, {"------", " ", "0", "0,0" + " kg", "R$ " + "0,00"})
	endif

	@ 116,010 To 680,450 Dialog oDlgO Title "Orçamento"

	@ 01,01 SAY 'FRIGORÍFICO SILVA INDÚSTRIA E COMÉRCIO LTDA'
	@ 02,01 SAY 'CLIENTE: ' + _cNomeCli
	@ 03,01 SAY 'CÓD. CLI.: ' + _cCodCli + ' -  LOJA: ' + _cLoja
	@ 20,01 SAY 'TOTAL PEDIDO: R$ ' + transform(_nTotal, '@E 999,999,999.99')

	oBrowse2 := TWBrowse():New(46, 01, 230, 210,,{'CODIGO','DESCRIÇÃO', 'QPCAIX  ', 'QPPESO ', 'PRCFIN '},{10,30,15,15,15},oDlgO,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse2:SetArray(aIPPed)
	oBrowse2:bLine := {||{aIPPed[oBrowse2:nAt,01],aIPPed[oBrowse2:nAt,02],aIPPed[oBrowse2:nAt,03],aIPPed[oBrowse2:nAt,04],aIPPed[oBrowse2:nAt,05]}} 

	@ 270,90 BMPBUTTON TYPE 2 ACTION oDlgO:end() Object Obtn2
	Activate Dialog oDlgO CENTERED

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MENUDEF  ³ Autor ³ Evandro Mugnol        ³ Data ³21/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Isola opcoes de menu para que as opcoes da rotina possam   ³±±
±±³          ³ ser lidas pelas bibliotecas framework da Versao 10         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ <Vide Parametros Formais>                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

	Local nPos := 0
	Private aRotina := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	//³    2 - Simplesmente Mostra os Campos                         ³
	//³    3 - Inclui registros no Bancos de Dados                   ³
	//³    4 - Altera o registro corrente                            ³
	//³    5 - Remove o registro corrente do Banco de Dados          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	_cUsuarios := getMv('MV_MENCOM')
	_cUsrPick  := alltrim(getMv('SI_USRPICK'))
	_cCodUser  := retCodUsr()
	_cNomUsr   := UsrRetName(_cCodUser)
    _aGrupos   := UsrRetGrp(_cNomUsr, _cCodUser)
	nPos := aScan(_aGrupos,{|aVal|aVal = "000002"})
	if nPos = 0
		_lGrpLib := .F.
	else
		_lGrpLib := .T.
	endif
	/* Liberação exclusiva de Picking liberado a partir da segunda vez - "Lib. Pick. M."   */
	if alltrim(_cCodUser) $ _cUsrPick

		aRotina := {{"Pesquisar"    	, "AxPesqui"    , 0 , 1 , 0 , .F. } ,;
					{"Visualizar"   	, "AxVisual"    , 0 , 2 , 0 , NIL } ,;
					{"Incluir"      	, "u_gjf26inc"  , 0 , 3 , 0 , NIL } ,;
					{"Alterar"      	, "u_gjf26alt"  , 0 , 4 , 0 , NIL } ,;
					{"Excluir"      	, "u_gjf26exc"  , 0 , 5 , 0 , NIL } ,;
					{"Alt. Pre-Carreg"	, "u_gjf26tod"  , 0 , 5 , 0 , NIL } ,;
					{"Solic. Prod. F9"	, "u_gjf26f9"   , 0 , 5 , 0 , NIL } ,;
					{"Pre-Pedidos"  	, "u_gjf26pp"   , 0 , 2 , 0 , NIL } ,;
					{"Vincular PP"  	, "u_gjf26vinc" , 0 , 2 , 0 , NIL } ,;
					{"Marcas"       	, "u_gjf26mrc"  , 0 , 2 , 0 , NIL } ,;
					{"Encerrar"     	, "u_gjf26enc"  , 0 , 2 , 0 , NIL } ,;
					{"Legenda"      	, "u_gjf26lPC"  , 0 , 2 , 0 , NIL } ,;
					{"Sinc. Datas"  	, "u_gjf26Si"   , 0 , 2 , 0 , NIL } ,;
					{"Auto Dt. Prod."  	, "u_gf26aPrd"  , 0 , 2 , 0 , NIL } ,;
					{"Valid Dt. Prod."  , "u_mitfs005"  , 0 , 4 , 0 , NIL } ,;
					{"Lib. Picking" 	, "u_gjf26pck"  , 0 , 2 , 0 , NIL } ,;
					{"Lib. Pick. M." 	, "u_gjf26lib"  , 0 , 2 , 0 , NIL } ,;
					{"Manif. Carga An" 	, "u_gjf26MaCA" , 0 , 2 , 0 , NIL } ,;
					{"Descontos p/ Carga", "u_gjf26dpc" , 0 , 2 , 0 , NIL } ,;
					{"Pendurados" 		, "u_gjf26pen"  , 0 , 2 , 0 , NIL } ,;
					{"Pend. Alt. Car." 	, "u_gjf26peA"  , 0 , 2 , 0 , NIL } ,;
					{"Congelados" 		, "u_gjf26con"  , 0 , 2 , 0 , NIL } ,;
					{"ATM		" 		, "u_gjf26atm"  , 0 , 2 , 0 , NIL } ,;
					{"Faltas	" 		, "u_gjf26fal"  , 0 , 2 , 0 , NIL } }
					if _lGrpLib
						aadd(aRotina,{"Lib. Pre-Pedidos"	, "u_gjf30"		, 0 , 2 , 0 , NIL })
					endif

	ElseIf  alltrim(_cCodUser) $ _cUsuarios
		aRotina := {{"Pesquisar"    	, "AxPesqui"    , 0 , 1 , 0 , .F. } ,;
					{"Visualizar"   	, "AxVisual"    , 0 , 2 , 0 , NIL } ,;
					{"Incluir"      	, "u_gjf26inc"  , 0 , 3 , 0 , NIL } ,;
					{"Alterar"      	, "u_gjf26alt"  , 0 , 4 , 0 , NIL } ,;
					{"Excluir"      	, "u_gjf26exc"  , 0 , 5 , 0 , NIL } ,;
					{"Alt. Pre-Carreg"	, "u_gjf26tod"  , 0 , 5 , 0 , NIL } ,;
					{"Solic. Prod. F9"	, "u_gjf26f9"   , 0 , 5 , 0 , NIL } ,;
					{"Pre-Pedidos"  	, "u_gjf26pp"   , 0 , 2 , 0 , NIL } ,;
					{"Vincular PP"  	, "u_gjf26vinc" , 0 , 2 , 0 , NIL } ,;
					{"Marcas"       	, "u_gjf26mrc"  , 0 , 2 , 0 , NIL } ,;
					{"Encerrar"     	, "u_gjf26enc"  , 0 , 2 , 0 , NIL } ,;
					{"Legenda"      	, "u_gjf26lPC"  , 0 , 2 , 0 , NIL } ,;
					{"Sinc. Datas"  	, "u_gjf26Si"   , 0 , 2 , 0 , NIL } ,;
					{"Auto Dt. Prod."  	, "u_gf26aPrd"  , 0 , 2 , 0 , NIL } ,;
					{"Valid Dt. Prod."  , "u_mitfs005"  , 0 , 4 , 0 , NIL } ,;
					{"Lib. Picking" 	, "u_gjf26pck"  , 0 , 2 , 0 , NIL } ,;
					{"Manif. Carga An" 	, "u_gjf26MaCA" , 0 , 2 , 0 , NIL } ,;
					{"Descontos p/ Carga", "u_gjf26dpc" , 0 , 2 , 0 , NIL } ,;
					{"Pendurados" 		, "u_gjf26pen"  , 0 , 2 , 0 , NIL } ,;
					{"Pend. Alt. Car." 	, "u_gjf26peA"  , 0 , 2 , 0 , NIL } ,;
					{"Congelados" 		, "u_gjf26con"  , 0 , 2 , 0 , NIL } ,;
					{"ATM		" 		, "u_gjf26atm"  , 0 , 2 , 0 , NIL } ,;
					{"Faltas	" 		, "u_gjf26fal"  , 0 , 2 , 0 , NIL } }
					if _lGrpLib
						aadd(aRotina,{"Lib. Pre-Pedidos"	, "u_gjf30"		, 0 , 2 , 0 , NIL })
					endif

	Else
		aRotina := {{"Pesquisar"        , "AxPesqui"    , 0 , 1 , 0 , .F. } ,;
					{"Visualizar"   	, "AxVisual"    , 0 , 2 , 0 , NIL } ,;
					{"Incluir"      	, "u_gjf26inc"  , 0 , 3 , 0 , NIL } ,;
					{"Alterar"      	, "u_gjf26alt"  , 0 , 4 , 0 , NIL } ,;
					{"Excluir"      	, "u_gjf26exc"  , 0 , 5 , 0 , NIL } ,;
					{"Alt. Pre-Carreg"	, "u_gjf26tod"  , 0 , 5 , 0 , NIL } ,;
					{"Solic. Prod. F9"	, "u_gjf26f9"   , 0 , 5 , 0 , NIL } ,;
					{"Pre-Pedidos"  	, "u_gjf26pp"   , 0 , 2 , 0 , NIL } ,;
					{"Vincular PP"  	, "u_gjf26vinc" , 0 , 2 , 0 , NIL } ,;
					{"Marcas"       	, "u_gjf26mrc"  , 0 , 2 , 0 , NIL } ,;
					{"Encerrar"     	, "u_gjf26enc"  , 0 , 2 , 0 , NIL } ,;
					{"Auto Dt. Prod."  	, "u_gf26aPrd"  , 0 , 2 , 0 , NIL } ,;
					{"Valid Dt. Prod."  , "u_mitfs005"  , 0 , 4 , 0 , NIL } ,;
					{"Legenda"      	, "u_gjf26lPC"  , 0 , 2 , 0 , NIL } ,;
					{"Manif. Carga An" 	, "u_gjf26MaCA" , 0 , 2 , 0 , NIL } ,;
					{"Descontos p/ Carga", "u_gjf26dpc" , 0 , 2 , 0 , NIL } ,;
					{"Pendurados" 		, "u_gjf26pen"  , 0 , 2 , 0 , NIL } ,;
					{"Pend. Alt. Car." 	, "u_gjf26peA"  , 0 , 2 , 0 , NIL } ,;
					{"Congelados" 		, "u_gjf26con"  , 0 , 2 , 0 , NIL } ,;
					{"ATM		" 		, "u_gjf26atm"  , 0 , 2 , 0 , NIL } ,;
					{"Faltas	" 		, "u_gjf26fal"  , 0 , 2 , 0 , NIL } }
					if _lGrpLib
						aadd(aRotina,{"Lib. Pre-Pedidos"	, "u_gjf30"		, 0 , 2 , 0 , NIL })
					endif
	EndIf

Return aRotina


// Sincronizar Datas do Pre-Pedido com as do Pre-carregamento
User Function gjf26Si()

	ZZ4->(DbSetORder(1))
	if ZZ4->(MsSeek(FWxfilial('ZZ4') + ZZ3->ZZ3_NUM))
		While ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4') .and. ZZ4->ZZ4_PRECAR = ZZ3->ZZ3_NUM

			Reclock('ZZ4',.f.)
			ZZ4->ZZ4_DATA := ZZ3->ZZ3_DTCAR
			msunlock()

			ZZ4->(DbSkip())
		enddo
		
	endif

return


Static Function gjf89wfw(_nProd,_dDataABT,_nNvinc,_nDABT,_cDes,_dDtEmb,_cZZWM)			
	local _cDest  := ''
	//local _VLD := 'N'
	Local _cMens := ''
	//Local _cAtivaR := GetMV('SI_LIBR88')
	
		_cMens := 'Esta é uma mensagem automática do sistema. Por favor não responda!' + chr(13) + chr(10)
		
		//alert(' 1895 enviando mensagem...')
	
		_cMens += 'Na Data do Abate de :'+ dtoc(_dDataABT) + chr(13) + chr(10)
		_cMens +=   chr(13) + chr(10)		 
		_cTit  := 'Workflow de Log: Aviso de quais usuarios executou a rotina Sinc. Datas'
		u_GJF54(_cMens,_cTit,_cDest)
		
return

//Gerenciamento das marcas
User Function  gjf26mrc()
	Local _cPerg     := "GJF31b"
	Local _cPerg2    := "GJF26"
	Private aTela    := {}
	Private aStru    := {}
	Private aCampos  := {}
	Private aMarcas  := {}
	Private _cMarca  := space(3)
	Private _nTotMrc := 0
	Private cArq
	
	_aArqTrb := {}

	if ZZ3->ZZ3_STATUS = 'E' .or. ZZ3->ZZ3_STATUS = 'C' .or. ZZ3->ZZ3_STATUS = 'F'
		msgbox('Status não permite nenhum tipo de alteração!','OPERACAO NEGADA','STOP')
		return
	endif

	// ------------ INICIO TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION
	/*
	_cUsuarios := GetMv('MV_MENCOM')
	_cCodUser  := RetCodUsr()

	If U_BLQ_FUS(ZZ3->ZZ3_NUM)
		If AllTrim(_cCodUser) $ _cUsuarios
			If FWAlertYesNo("Deseja realizar a Alteração das Marcas ?","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
				_xRet := U_PSW_LIB(ZZ3->ZZ3_NUM, 1)		// Passo 1 no segundo parâmetro quando informado pré-carregamento no primeiro parâmetro
				If !_xRet
					Return .F.
				EndIf
			Else
				Return .F.
			EndIf
		Else
			FWAlertError("Não é permitido manutenção neste pré-carregamento.","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
			Return .F.
		EndIf
	EndIf
	*/
	// ------------ FINAL TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION

	if !pergunte(_cPerg,.t.)
		pergunte(_cPerg2,.f.)
		return
	endif

	montabrow()
	if mv_par01 = 1
		IndRegua("TMP",cArq,"MARCA+CODCLI+LOJA",,,"Selecionando Registros...") //ordena
	elseif mv_par01 = 2
		IndRegua("TMP",cArq,"MUN+CODCLI+LOJA",,,"Selecionando Registros...") //ordena
	elseif mv_par01 = 3
		IndRegua("TMP",cArq,"PESO+CODCLI+LOJA",,,"Selecionando Registros...") //ordena
	else
		IndRegua("TMP",cArq,"ORDEM+CODCLI+LOJA",,,"Selecionando Registros...") //ordena
	endif

	DbSelectArea('TMP')

	DEFINE MSDIALOG oEnc TITLE 'Gerenciamento de Marcas do Pré-Carregamento' from 0,0 To 400,800 OF oMainWnd PIXEL //To 290,620

	@ 010,005 To 170,400 Browse "TMP" fields aCampos object oBrow

	oBrow:oBrowse:bldBlClick :=  {|| AltMrc()}

	@180,220 BUTTON btn01 PROMPT "Confirmar" OF oEnc SIZE 40,15 PIXEL ACTION GravMrc()
	@180,300 BUTTON btn02 PROMPT "Sair" OF oEnc  SIZE 40,15 PIXEL ACTION oEnc:end()

	ACTIVATE MSDIALOG oEnc CENTERED

	TMP->(DbCloseArea())
	u_arqtrb ("FechaTodos",,,, @_aArqTrb)

	pergunte(_cPerg2,.f.)

Return

//Função que grava as marcas na tabela do banco
Static Function GravMrc()
	TMP->(DbGoTop())	
	While TMP->(!eof())
		ZZ4->(DbSetOrder(2))
		ZZ4->(DbGoTop())
		if ZZ4->(MsSeek(FWxfilial('ZZ4') + TMP->NUM))
			reclock('ZZ4',.f.)
			ZZ4->ZZ4_MARCA := TMP->MARCA
			msunlock()
		endif
		TMP->(DbSkip())
	enddo

	oEnc:end()
return

//Função que chama a telinha de alteração de marca
Static Function AltMrc()
	Local _UltMarc  := ''
	Local _PrxMArc  := ''

	//Para sugerir a marca
	if mv_par02 = 1
		ASORT(aMarcas)

		_UltMarc := ATAIL(aMarcas)

		_PrxMarc := iif(!empty(_UltMarc),iif(_UltMarc = strzero(_nTotMrc,3),strzero(_nTotMrc,3),strzero(val(_UltMarc)+1,3)),'001')

		_cMarca  := iif(empty(TMP->MARCA),_PrxMarc,TMP->MARCA)
	else
		_cMarca := TMP->MARCA
	endif

	DEFINE MSDIALOG oDlg2 TITLE 'Marcas' from 000,000 To 100,150 OF oMainWnd PIXEL
	@ 009,002 SAY  'Marca:' Object oSay1
	@ 009,040 GET _cMarca  SIZE 30,10  PICTURE "@!" VALID ValMrc() Object oMarc

	@ 025,040 BMPBUTTON TYPE 1 ACTION CnfMrc() Object Obtn2
	ACTIVATE MSDIALOG oDlg2

return

//Função para validar a marca digitada
//na verdade para adicionar os zeros
Static Function ValMrc()

	if empty(_cMarca)

		_Achou := 0
		_Achou := ASCAN(aMarcas,TMP->MARCA)

		if _Achou <> 0
			aMarcas[_Achou] := ''
		endif
	else
		if !empty(_cMarca)
			_cMarca := padl(alltrim(_cMarca),3,'0')
			_Achou  := ASCAN(aMarcas,_cMarca)
		endif

		if _Achou <> 0
			return .f.
		else
			AADD(aMarcas,_cMarca)
		endif
	endif

return .t.

//Função que confirma a inserção das marcas
Static Function CnfMrc()

	reclock('TMP',.f.)
	TMP->MARCA := _cMarca
	msunlock()

	odlg2:end()

	oBrow:oBrowse:refresh()
	oEnc:refresh()
return  .t.

//Montagem do browse para definição de marcas
Static Function montabrow()

	//cArq  := CriaTrab( Nil, .F. )
	_aArqTrb := {}
	_nOrd := 1
	aadd(aCampos,{"MARCA" ,"Marcas"     ,""})
	aadd(aCampos,{"NUM"   ,"Pre-Pedidos",""})
	aadd(aCampos,{"CODCLI","Cliente"    ,""})
	aadd(aCampos,{"LOJA"  ,"Loja"       ,""})
	aadd(aCampos,{"NOME"  ,"Nome"       ,""})
	aadd(aCampos,{"MUN"   ,"Cidade"     ,""})
	aadd(aCampos,{"BAIRRO","Bairro"     ,""})
	aadd(aCampos,{"CAIX"  ,"Caixas"     ,""})
	aadd(aCampos,{"PESO"  ,"Peso"     	,""})

	aadd(aStru,{"MARCA"  , "C",  03, 0,   "@!"  			, 'Marca   '})
	aadd(aStru,{"NUM"    , "C",  06, 0,   "@!"  			, 'Pre-Ped.'})
	aadd(aStru,{"CODCLI" , "C",  06, 0,   "@!"  			, 'Cliente '})
	aadd(aStru,{"LOJA"   , "C",  02, 0,   "@!"  			, 'Loja    '})
	aadd(aStru,{"NOME"   , "C",  30, 0,   "@!"  			, 'Nome    '})
	aadd(aStru,{"MUN"    , "C",  20, 0,   "@!"  			, 'Cidade  '})
	aadd(aStru,{"BAIRRO" , "C",  20, 0,   "@!"  			, 'Bairro  '})
	aadd(aStru,{"ORDEM"  , "C",  03, 0,   "@!"  			, 'Ordem   '})
	aadd(aStru,{"CAIX"   , "N",  06, 0,   "@E 999,999"  	, 'Caixas  '})
	aadd(aStru,{"PESO"   , "N",  09, 2,   "@E 9,999,999.99"	, 'Peso    '})

	//dbcreate(cArq,aStru)
	//If Select("TMP") != 0
	//	TMP->(DbCloseArea())
	//endif
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	//TMP->(DbGotop())

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	ZZ4->(DbSetOrder(1))
	ZZ4->(DbGoTop())
	if ZZ4->(MsSeek(FWxfilial('ZZ4') + ZZ3->ZZ3_NUM))

		_nOrd := 1

		While ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4') .and. ZZ4->ZZ4_PRECAR = ZZ3->ZZ3_NUM

			DbSelectAre('TMP')
			reclock('TMP',.t.)
			TMP->MARCA   := iif(empty(ZZ4->ZZ4_MARCA),space(3),ZZ4->ZZ4_MARCA)
			TMP->NUM     := ZZ4->ZZ4_NUM
			TMP->CODCLI  := ZZ4->ZZ4_CODCLI
			TMP->LOJA    := ZZ4->ZZ4_LOJA
			TMP->NOME    := ZZ4->ZZ4_NOME
			TMP->MUN     := ZZ4->ZZ4_MUN
			TMP->BAIRRO  := GetAdvFVal('SA1','A1_BAIRRO',FWxfilial('SA1')+TMP->CODCLI+TMP->LOJA,1)
			TMP->CAIX    := ZZ4->ZZ4_QPCAIX
			TMP->PESO    := ZZ4->ZZ4_QPPESO
			TMP->ORDEM   := strzero(_nOrd,3)
			msunlock()

			_nOrd++

			if !empty(TMP->MARCA)
				AADD(aMarcas,TMP->MARCA)
			endif

			ZZ4->(DbSkip())
		enddo
	endif

	TMP->(DbGoTop())

	_nTotMrc := _nOrd

return

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

// Função para liberar o picking de caixas caso ainda não tenha sido liberado
User Function gjf26Pck()

	if ZZ3->ZZ3_STPCK $ 'P/S/L'
		FWAlertError('Separação das caixas do carregamento já iniciada ou liberada!','OPERAÇÃO NEGADA!')
	else
		if ZZ3->ZZ3_LIBPCK = "N"
			if FWAlertYesNo('Tem certeza que deseja liberar para picking?','Liberar o Picking!')
				reclock('ZZ3',.f.)
				ZZ3->ZZ3_STPCK  := 'L'
				ZZ3->ZZ3_USRPCK := ''
				ZZ3->ZZ3_LIBPCK := "S"
				msunlock()
				u_gjf31his('Liberado para picking','L')
				FWAlertInfo('Carregamento liberado para separação de caixas!','Liberação do Picking')
			endif
		else
			FWAlertWarning('Carregamento já foi liberado! Para liberá-lo novamente contate o Matheus!','ATENÇÃO!')
		endif
	endif

return

// Função exclusiva do Matheus para re-liberar o picking
User Function gjf26lib()

	if ZZ3->ZZ3_LIBPCK = 'N'
		FWAlertWarning('Picking ainda não foi liberado. Autorização desnecessária.','ATENÇÃO!')
	else
		reclock('ZZ3',.f.)
		ZZ3->ZZ3_STPCK  := 'B'
		ZZ3->ZZ3_USRPCK := ''
		ZZ3->ZZ3_LIBPCK := "N"
		msunlock()
		u_gjf31his('Picking bloqueado pelo Comercial','B')
		FWAlertInfo('Carregamento liberado para alteração novamante!','INFO')
	endif

return

//Função auxiliar para retorno do status dos pre-pedidos e montar o grid
Static Function RetStatus(_Stt)
	Local ret := iif(_Stt = 'B','Bloqueado',;
	iif(_Stt = 'L','Liberado' ,;
	iif(_Stt = 'E','Encerrado',;
	iif(_Stt = 'C','Carregando...',;
	iif(_Stt = 'S','Em Espera',;
	iif(_Stt = 'F','Faturado',''))))))
return ret

//Função auxiliar para retorno das cores da legenda
Static Function RetCores(_Stt)
	local ret   := iif(_Stt = 'B', LoadBitmap(GetResources(),'br_azul'),iif(_Stt = 'L',LoadBitmap(GetResources(),'br_verde'),;
	iif(_Stt = 'C', LoadBitmap(GetResources(),'br_amarelo'),iif(_Stt = 'S',LoadBitmap(GetResources(),'br_laranja'),;
	iif(_Stt = 'E', LoadBitmap(GetResources(),'br_vermelho'),iif(_Stt = 'F',LoadBitmap(GetResources(),'br_preto'),''))))))
return  ret

// Função para filtrar pedidos com pendurados
User Function gjf26tod()
	gjf26apc(0)
return

// Função para filtrar pedidos com pendurados
User Function gjf26pen()
	gjf26fil(1)
return

// Função para filtrar pedidos com pendurados
User Function gjf26peA()
	gjf26apc(1)
return

// Função para filtrar pedidos com pendurados
User Function gjf26con()
	gjf26apc(2)
return

// Função para filtrar pedidos com pendurados
User Function gjf26atm()
	gjf26apc(3)
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função para visualizar marcas contendo produtos conforme parâmetro           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function gjf26fil(_nTipo)

	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()
	_lAchou				:= .f.

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           :=aPosObj[1]
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	//Cabeçalhos das colunas
	aHeader  := {'','Numero','Status','Doca','Marca','Data','Codigo','Loja','Nome do Cliente','Cidade'}
	//Largura das colunas
	aLargCol := {20,   30   ,   40   ,  30  ,  20   ,  40  ,   30   ,  20  ,      130         ,   40   }

	// Vetor com elementos do Browse
	aBrowse := {}

	//Ordena por pre-carregamento e marcas
	ZZ4->(DbSetOrder(5))
	ZZ4->(MsSeek(FWxfilial('ZZ4') + ZZ3->ZZ3_NUM))
	while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4')  .and. ZZ4->ZZ4_PRECAR = ZZ3->ZZ3_NUM

		_Stt := ZZ4->ZZ4_STATUS

		//chama a função que filtra os tipos de produtos que serão apresentados na tela de pre-pedidos
		//se for somente caixas, somente peças, peças com caixas ou todos - por Mauricio Roehrs 14/04/15
		_lAchou := filtraProd(_nTipo,ZZ4->ZZ4_NUM)

		if _lAchou
			aadd(aBrowse,{RetCores(_Stt),ZZ4->ZZ4_NUM,RetStatus(_Stt),ZZ4->ZZ4_LOCAR,ZZ4->ZZ4_MARCA,;
			ZZ4->ZZ4_DATA,ZZ4->ZZ4_CODCLI,ZZ4->ZZ4_LOJA,ZZ4->ZZ4_NOME,ZZ4->ZZ4_MUN})
		endif

		ZZ4->(DbSkip())

	enddo

	DEFINE DIALOG oDlg TITLE "Pendurados" FROM 020,50 To 700,1000 PIXEL
	// Cria Browse
	oBrowse := TCBrowse():New(00,00,480,340,,aHeader,aLargCol,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	// Seta vetor para a browse
	oBrowse:SetArray(aBrowse)

	// Monta a linha a ser exibina no Browse
	if len(aBrowse) <= 0  //verifica se tem algo no vetor para não dar error.log
		oBrowse:bLine := {||{'','','','','','','','','',''} }
	else
		oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAT,04],;
		aBrowse[oBrowse:nAT,05],aBrowse[oBrowse:nAT,06],aBrowse[oBrowse:nAT,07],;
		aBrowse[oBrowse:nAT,08],aBrowse[oBrowse:nAT,09],aBrowse[oBrowse:nAT,10]} }
	endif

	oBrowse:nScrollType := 1

	ACTIVATE DIALOG oDlg CENTERED

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função para alterar pré-carregamento                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function gjf26apc(_nTipo)

	Local _aStru   := {}
	Local _aCpoBrw := {}
	Local _lOk     := .F.
	Local oDlg 

	Private lInverte := .F.
	Private cMark    := GetMark()   
	Private oMark

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Código Novo Pré-Carregamento")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _cCodCarr   := Space(06)
	Private _cOldCarr	:= Space(06)

	PRIVATE nQtdTit		:= 0

	if !pergunte("GJF26APC",.t.)
		return
	endif

	// ------------ INICIO TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION
	/*
	_cUsuarios := GetMv('MV_MENCOM')
	_cCodUser  := RetCodUsr()

	If U_BLQ_FUS(ZZ3->ZZ3_NUM)
		If AllTrim(_cCodUser) $ _cUsuarios
			If FWAlertYesNo("Deseja realizar a Alteração do Pré-Carregamento ?","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
				_xRet := U_PSW_LIB(ZZ3->ZZ3_NUM, 1)		// Passo 1 no segundo parâmetro quando informado pré-carregamento no primeiro parâmetro
				If !_xRet
					Return .F.
				EndIf
			Else
				Return .F.
			EndIf
		Else
			FWAlertError("Não é permitido manutenção neste pré-carregamento.","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
			Return .F.
		EndIf
	EndIf
	*/
	// ------------ FINAL TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION

	if ZZ3->ZZ3_STPCK $ 'P/S/L' .and. ZZ3->ZZ3_ISRESU = "N"
		//FWAlertError('Separação das caixas do carregamento já iniciada ou liberada! Solicite o bloqueio para efetuar alterações!','OPERAÇÃO NEGADA!')
		FWAlertError('Carregamento já foi liberado! Para liberá-lo novamente contate o Matheus!','OPERAÇÃO NEGADA!')
		Return
	else
		if ZZ3->ZZ3_LIBPCK = "S" .and. ZZ3->ZZ3_ISRESU = "N"
			FWAlertError('Carregamento já foi liberado! Para liberá-lo novamente contate o Matheus!','OPERAÇÃO NEGADA!')
			Return
		endif
	endif

	_aCores := {}
	_aArqTrb := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra Listagem dos pre-pedidos para serem selecionados                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Ajuste trocando o campo Origem por Marca - -AADD(_aStru,{"ORIGEM" 	, "C"	,9		,0		})  06/07/20
	// Solicitação feita no chamado ID 130 
	// Cria um arquivo de apoio
	AADD(_aStru,{"OK"      	, "C"	,2		,0		})
	AADD(_aStru,{"NUMERO"   , "C"	,6		,0		})
	AADD(_aStru,{"STATUS"  	, "C"	,13		,0		})
	AADD(_aStru,{"MARCA" 	, "C"	,9		,0		})
	AADD(_aStru,{"DATAP" 	, "D"	,8 		,0		})
	AADD(_aStru,{"CLIENTE"  , "C"	,6 		,0		})
	AADD(_aStru,{"LOJA"   	, "C"	,2		,0		})
	AADD(_aStru,{"NOMECLI"  , "C"	,40		,0		})
	AADD(_aStru,{"CIDADE"   , "C"	,25		,0		})
	AADD(_aStru,{"PRECAR" 	, "C"	,6 		,0		})
	AADD(_aStru,{"QTPPESO"  , "N"	,9		,2		})
	AADD(_aStru,{"QTPCAIX"  , "N"	,6		,0		})
	AADD(_aStru,{"CLIBLOQ"  , "C"	,3		,0		})
	AADD(_aStru,{"STATLEG"  , "C"	,1		,0		})

	//_cArqTrb := Criatrab(_aStru,.T.)
	//DbUseArea(.T.,,_cArqTrb,"TTRB")

	If Select('TTRB')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TTRB->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TTRB", _aStru, {}, @_aArqTrb)

	// Alimenta o arquivo de apoio com os registros da selecao da query
	cQuery1 := " SELECT *"
	cQuery1 += "   FROM " + RetSQLTab("ZZ4")
	cQuery1 += "  WHERE " + RetSQLFil("ZZ4")
	cQuery1 += "    AND ZZ4_PRECAR = '" + ZZ3->ZZ3_NUM + "'"
	cQuery1 += "    AND ZZ4_STATUS NOT IN('C','E','F','R') "
	cQuery1 += "    AND " + RetSQLDel("ZZ4")
	if mv_par01 = 1
		cQuery1 += " ORDER BY ZZ4_MUN"
	elseif mv_par01 = 2
		cQuery1 += " ORDER BY ZZ4_MARCA"
	elseif mv_par01 = 3
		cQuery1 += " ORDER BY ZZ4_CODCLI, ZZ4_LOJA"
	endif

	cQuery1 := ChangeQuery(cQuery1)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1), "TRB1", .F., .T.)

	TRB1->(DbGotop())
	While TRB1->(!Eof())
		_lAchou := filtraProd(_nTipo,TRB1->ZZ4_NUM)
		if _lAchou
			DbSelectArea("TTRB")
			RecLock("TTRB",.T.)
			TTRB->NUMERO  := TRB1->ZZ4_NUM
			DO CASE
			CASE TRB1->ZZ4_STATUS == "L"
				TTRB->STATUS := "Liberado"
			CASE TRB1->ZZ4_STATUS == "C"
				TTRB->STATUS := "Carregando..."
			CASE TRB1->ZZ4_STATUS == "E"
				TTRB->STATUS := "Encerrado"
			CASE TRB1->ZZ4_STATUS == "S"
				TTRB->STATUS := "Espera"
			CASE TRB1->ZZ4_STATUS == "B"
				TTRB->STATUS := "Bloqueado"
			CASE TRB1->ZZ4_STATUS == "F"
				TTRB->STATUS := "Faturado"
			CASE TRB1->ZZ4_STATUS == "I"
				TTRB->STATUS := "Importado"
			CASE TRB1->ZZ4_STATUS == "P"
				TTRB->STATUS := "Portal"
			CASE TRB1->ZZ4_STATUS == "R"
				TTRB->STATUS := "Producao"
			OTHERWISE
				TTRB->STATUS := "Verificar"
			ENDCASE
			/*DO CASE
			CASE TRB1->ZZ4_ORIGEM == "E"
				//TTRB->ORIGEM := "EDI"
			CASE TRB1->ZZ4_ORIGEM == "P"
				//TTRB->ORIGEM := "Portal"
			CASE TRB1->ZZ4_ORIGEM == "D"
				// TTRB->ORIGEM := "Digitacao"
			OTHERWISE
				//TTRB->STATUS := "Verificar"
			ENDCASE*/
			TTRB->DATAP   := STOD(TRB1->ZZ4_DATA)
			TTRB->CLIENTE := TRB1->ZZ4_CODCLI
			TTRB->LOJA    := TRB1->ZZ4_LOJA
			TTRB->NOMECLI := TRB1->ZZ4_NOME
			TTRB->CIDADE  := TRB1->ZZ4_MUN
			TTRB->PRECAR  := TRB1->ZZ4_PRECAR
			TTRB->QTPPESO := TRB1->ZZ4_QPPESO
			TTRB->QTPCAIX := TRB1->ZZ4_QPCAIX
			TTRB->MARCA   := TRB1->ZZ4_MARCA
			DO CASE
				CASE TRB1->ZZ4_SIBLQL == "1"
					TTRB->CLIBLOQ := "Sim"
				CASE TRB1->ZZ4_SIBLQL == "2"
					TTRB->CLIBLOQ := "Nao"
				OTHERWISE
					TTRB->CLIBLOQ := "Xxx"
			ENDCASE
			TTRB->STATLEG := "1"		// Verde
			MsunLock()
		endif

		TRB1->(DbSkip())      
	Enddo   		

	TRB1->(DbCloseArea())

	// Define as cores dos itens de legenda
	aCores := {}
	aAdd(aCores,{"TTRB->STATLEG == '1'" , "BR_VERDE"		})
	aAdd(aCores,{"TTRB->STATLEG == '2'" , "BR_VERMELHO"		})

	// Define quais colunas (campos da TTRB) serao exibidas na MsSelect
	// Trocado campo origem por marca  ---  {"ORIGEM"	,, "Origem"      			,"@!"	},;
	_aCpoBrw := {{"OK"		,, "Mark"           		,"@!"	},;
				{"NUMERO"	,, "Numero"   				,"@!"	},;
				{"STATUS"	,, "Status"           		,"@!"	},;
				{"MARCA"	,, "Marca"      			,"@!"	},;
				{"DATAP"	,, "Data"     				,"@D"	},;
				{"PRECAR" 	,, "Cod.Pre.Carr"    		,"@!"	},;
				{"CLIENTE"	,, "Cod.Cli."        		,"@!"	},;
				{"LOJA"	,, "Loja"      				,"@!"	},;
				{"NOMECLI"	,, "Nome Cli."        		,"@!"	},;
				{"CIDADE" 	,, "Cidade"    				,"@!"	},;
				{"QTPPESO"	,, "Qt.Prev.Peso"   		,"@E 9,999,999.99"},;
				{"QTPCAIX"	,, "Qt.Prev.Caix"   		,"@E 999,999"},;
				{"CLIBLOQ"	,, "Cli. Bloq?"        		,"@!"	}}

	// Cria uma Dialog
	DEFINE MSDIALOG oDlg TITLE "Marcar Pré-Pedidos que necessitam alterar Pré-Carregamentos" From 9,0 To 500,900 PIXEL

	@ 033 , 010 Say OemToAnsi("Quantidade Pré-Pedidos Marcados:") PIXEl OF oDlg
	@ 033 , 110 Say oQtda VAR nQtdTit Picture "@E 99999" SIZE 50,8 PIXEl OF oDlg

	DbSelectArea("TTRB")
	DbGotop()

	// Cria a MsSelect
	oMark := MsSelect():New("TTRB","OK","",_aCpoBrw,@lInverte,@cMark,{43,2,238,450},,,,,aCores)
	oMark:bMark := {| | _Disp(oQtda)}


	//oMark:bLDblClick  := {|| alert('?') }

	// Exibe a Dialog
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||_lOk := .T., oDlg:End()},{||_lOk := .F., oDlg:End()})

	If _lOk
		DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(150), C(450) PIXEL
		@ C(005), C(010) SAY "INFORME O NOVO CÓDIGO DO PRÉ-CARREGAMENTO"	   		Size C(300), C(12) FONT _oFtArial34 COLOR CLR_HRED 	PIXEL OF _oTela
		
		@ C(030), C(010) SAY "Pré-Carregamento"                            	   		Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
		@ C(030), C(080) MSGET _cCodCarr Valid NaoVazio() .And. _VldCod() F3 "ZZ3"  Size C(055), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela
		
		DEFINE SBUTTON FROM C(050), C(150) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (_bOk := .T., _oTela:End())
		DEFINE SBUTTON FROM C(050), C(175) TYPE 2 OBJECT _oCancel ENABLE OF _oTela	ACTION (_bOk := .F., _oTela:End())
		
		ACTIVATE MSDIALOG _oTela CENTERED                                                                        

		If _bOk
			_cStpck := GetAdvFVal('ZZ3','ZZ3_STPCK',FWxfilial('ZZ3')+_cCodCarr,2)
			_cIsresu := GetAdvFVal('ZZ3','ZZ3_ISRESU',FWxfilial('ZZ3')+_cCodCarr,2)
			_cLibpck := GetAdvFVal('ZZ3','ZZ3_LIBPCK',FWxfilial('ZZ3')+_cCodCarr,2)
			if _cStpck $ 'P/S/L' .and. _cIsresu = "N"
				FWAlertError('Carregamento já foi liberado! Para liberá-lo novamente contate o Matheus!','OPERAÇÃO NEGADA!')
				Return
			else
				if _cLibpck = "S" .and. _cIsresu = "N"
					FWAlertError('Carregamento já foi liberado! Para liberá-lo novamente contate o Matheus!','OPERAÇÃO NEGADA!')
					Return
				endif
			endif
			TTRB->(dbGoTop())
			While TTRB->(!Eof())
				If TTRB->STATLEG = "2"
					DbSelectArea("ZZ4")
					DbSetOrder(2)
					MsSeek(FWxFilial("ZZ4") + TTRB->NUMERO)
					If Found()
						_cOldCarr := ZZ4->ZZ4_PRECAR
						RecLock("ZZ4",.F.)
						ZZ4->ZZ4_PRECAR := _cCodCarr
						MsUnlock()
						ZZ5->(DbSetOrder(1))
						ZZ5->(MsSeek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
						While ZZ5->(!eof()) .and. ZZ5->(ZZ5_FILIAL+ZZ5_NUM) = FWxfilial('ZZ5')+ZZ4->ZZ4_NUM
							reclock('ZZ5',.f.)
								ZZ5->ZZ5_PRECAR := _cCodCarr
								ZZ5->ZZ5_DATAAL := date()
								ZZ5->ZZ5_HORAAL := time()
								ZZ5->ZZ5_USERAL := cUserName
							msunlock()
							ZZ5->(DbSkip())
						enddo
						u_dtilog(cFilAnt, "GJF26", "Pedido " + ZZ4->ZZ4_NUM + " movido de " + _cOldCarr + " para " + _cCodCarr, "A")
					Endif	
				Endif
				TTRB->(DbSkip())
			Enddo
			MsgAlert("Alteração Realizada com Sucesso.")
		Else
			MsgAlert("Cancelado pelo Operador. Nenhuma Alteração Será Realizada.")
		Endif
	Endif

	// Fecha a Area e elimina os arquivos de apoio criados em disco.
	TTRB->(DbCloseArea())

	u_arqtrb("FechaTodos",,,, @_aArqTrb)

	// Dia 08/06/23 - Flavio comentou 
	//IIF(File(_cArqTrb + GetDBExtension()), FErase(_cArqTrb + GetDBExtension()), Nil)

Return

//Função para filtrar o tipo de produto do pre-pedido
Static Function filtraProd(_nTipo, _cPreped)

	Local _lRet    := .f.
	Local _cGrupo  := ''

	if _nTipo = 0
		Return .T.
	endif

	ZZ5->(DbSetOrder(1))
	ZZ5->(DbGoTop())
	if ZZ5->(MsSeek(FWxFilial('ZZ5') + _cPreped))
		while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxFilial('ZZ5') .and. ZZ5->ZZ5_NUM = _cPreped

			if _nTipo = 1
				if GetAdvFVal('SB1','B1_SEGUM',FWxFilial('SB1') + alltrim(ZZ5->ZZ5_COD),1) = 'PC'
					_lRet := .t.
				endif
			elseif _nTipo = 2
				_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxFilial('SB1') + alltrim(ZZ5->ZZ5_COD),1)
				if GetAdvFVal('SBM','BM_FARM',FWxFilial('SBM') + _cGrupo,1) = 'C'
					_lRet := .t.
				endif
			elseif _nTipo = 3
				if 'ATM' $ GetAdvFVal('SB1','B1_BASE3',FWxFilial('SB1') + alltrim(ZZ5->ZZ5_COD),1)
					_lRet := .t.
				endif
			endif

			ZZ5->(dbSkip())
		enddo

	endif

return _lRet

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao executada ao Marcar/Desmarcar um registro              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Disp(oQtda)
RecLock("TTRB",.F.)
If Marked("OK")
	TTRB->OK 	  := cMark
	TTRB->STATLEG := "2"
	nQtdTit++
Else
	TTRB->OK 	  := ""
	TTRB->STATLEG := "1"
	nQtdTit--
Endif
MsUnlock()

oMark:oBrowse:Refresh()
oQtda:Refresh()

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua Consistencia no Código Informado                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _VldCod()
_lRet := .T.

DbSelectArea("ZZ3")
DbSetOrder(2)
MsSeek(FWxFilial("ZZ3") + _cCodCarr)
If Found()
	If ZZ3->ZZ3_DTCAR < DATE()
	    MsgAlert("Código de Pré-Carregamento Não é Válido, pois já Foi Carregado em " + DTOC(ZZ3->ZZ3_DTCAR) + ". Verifique!!!")
	    _lRet := .F.
	Endif
Else
    MsgAlert("Código de Pré-Carregamento Não Encontrado no Cadastro. Verifique!!!")
    _lRet := .F.
Endif


Return(_lRet)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função para executar F9 - solicitação da produção            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function gjf26f9()

Private lTelaLog := .F.
Private oDlg     := NIL
Private oFont    := NIL
Private oMemo    := NIL
Private cFile    := ""
Private cCaminho := AllTrim(GetPvProfString(GetEnvServer(),"RootPath","",GetADV97()))+"\log_spf9\"

// Cria diretório
//If !File(cCaminho)
//   MakeDir(cCaminho)
//Endif

// ------------ INICIO TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION
/*
_cUsuarios := GetMv('MV_MENCOM')
_cCodUser  := RetCodUsr()

If U_BLQ_FUS(ZZ3->ZZ3_NUM)
	If AllTrim(_cCodUser) $ _cUsuarios
		If FWAlertYesNo("Deseja realizar a Solicitação da Produção ?","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
			_xRet := U_PSW_LIB(ZZ3->ZZ3_NUM, 1)		// Passo 1 no segundo parâmetro quando informado pré-carregamento no primeiro parâmetro
			If !_xRet
				Return .F.
			EndIf
		Else
			Return .F.
		EndIf
	Else
		FWAlertError("Não é permitido manutenção neste pré-carregamento.","Já Existe Sequenciamento na Fusion para este Pré-Carregamento.")
		Return .F.
	EndIf
EndIf
*/
// ------------ FINAL TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION

// Alimenta o arquivo de apoio com os registros da selecao da query
cQuery1 := " SELECT ZZ4_PRECAR, ZZ4_CODCLI, ZZ4_LOJA, ZZ4_NOME, ZZ4_DATA, ZZ5_NUM, ZZ5_ITEM, ZZ5_COD, ZZ5_SOLPRO, ZZ5_USRSOL, ZZ5_DTSPOR"
cQuery1 += "   FROM " + RetSQLTab("ZZ4") + "," + RetSQLTab("ZZ5")
cQuery1 += "  WHERE " + RetSQLFil("ZZ4") + " AND " + RetSQLFil("ZZ5")
cQuery1 += "    AND ZZ4_NUM = ZZ5_NUM
cQuery1 += "    AND ZZ4_PRECAR = '" + ZZ3->ZZ3_NUM + "'"
cQuery1 += "    AND " + RetSQLDel("ZZ4") + " AND " + RetSQLDel("ZZ5")
cQuery1 += " ORDER BY ZZ4_PRECAR, ZZ5_NUM, ZZ5_ITEM "

cQuery1 := ChangeQuery(cQuery1)

DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1), "TRB1", .F., .T.)

cPerg6 := "GF28SOL"

If !pergunte(cPerg6,.t.)
	TRB1->(DbCloseArea())
	Return
Endif

// Caso já exista o pré-carregamento, antes deleta para gerar novamente
_cQuery := " UPDATE " + RetSqlName( "SZZ" )
_cQuery += "    SET D_E_L_E_T_ = '*' "
_cQuery += "  WHERE D_E_L_E_T_ = ' ' "
_cQuery += "    AND ZZ_PRECAR = '" + TRB1->ZZ4_PRECAR + "' "
_cQuery += "    AND ZZ_FILIAL = '" + FWxFilial( "SZZ" ) + "' "

Begin Transaction
TCSqlExec( _cQuery )
End Transaction


_nVez := 1
TRB1->(DbGotop())
While TRB1->(!Eof())

	_cProd    := TRB1->ZZ5_COD
	_cGrupo   := GetAdvFVal('SB1','B1_GRUPO',FWxFilial('SB1') + _cProd,1)
	_cPorc    := GetAdvFVal('SBM','BM_PORC',FWxFilial('SBM') + _cGrupo,1)
   // alert('foi')
	_cUserSol := TRB1->ZZ5_USRSOL
	_dDtSol   := TRB1->ZZ5_DTSPOR

	lTelaLog := .T.
	If _nVez == 1
		GeraLog("                                   RESUMO DO PROCESSAMENTO DA SOLICITAÇAO DA PRODUÇÃO - F9")
		GeraLog(Replicate("=", 130))
		GeraLog("        PRE-CARREG    PRE-PEDIDO   CLIENTE                                                                                  ITEM    PRODUTO        QTDE    SOL.PROD.    SOLICITANTE        DT.SOLIC.")
		GeraLog(Replicate("-", 190))
		_nVez := 2
	Endif

	If !Empty(_cPorc)
		// Solicita Producao?
		If mv_par01 == 1		// Sim
			_cSolProd := 'S'
			_cUserSol := PADR(cUserName, 20, " ")
			_dDtSol   := STOD(TRB1->ZZ4_DATA)
		Else					// Não
			_cSolProd := ' '
			_cUserSol := Space(20)
			_dDtSol   := stod('')
		Endif

		DbSelectArea("ZZ5")
		DbSetOrder(2)
		MsSeek(FWxFilial("ZZ5") + TRB1->ZZ5_NUM + TRB1->ZZ5_COD + TRB1->ZZ5_ITEM)
		If Found()
			GeraLog(PADR( "Antes "															,12, " ") + ;
			        PADR( ZZ3->ZZ3_NUM														,06, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( ZZ5->ZZ5_NUM														,06, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ; 
			        PADR( TRB1->ZZ4_CODCLI + "-" + TRB1->ZZ4_LOJA + " " + TRB1->ZZ4_NOME 	,60, " ") + ; 
			        PADR( ZZ5->ZZ5_ITEM														,03, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( ZZ5->ZZ5_COD														,08, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( Transform(ZZ5->ZZ5_QPCAIX, "@E 999.999")							,07, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( IIF(ZZ5->ZZ5_SOLPRO == "S", "Sim", "Nao")							,13, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( ZZ5->ZZ5_USRSOL													,20, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( DTOC(ZZ5->ZZ5_DTSPOR)												,10, " "))
			
			RecLock("ZZ5",.F.)
			ZZ5->ZZ5_SOLPRO := _cSolProd
			ZZ5->ZZ5_USRSOL := _cUserSol
			ZZ5->ZZ5_DTSPOR := _dDtSol
			MsUnlock()
			
			GeraLog(PADR( "Depois"															,12, " ") + ;
			        PADR( SPACE(06)    														,06, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ; 
			        PADR( Replicate("_",60)                                                	,60, " ") + ; 
			        PADR( SPACE(03)          												,03, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( SPACE(08)     													,08, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( SPACE(07)                                  						,07, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( IIF(_cSolProd == "S", "Sim", "Nao")								,13, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( _cUserSol          												,20, " ") + ;
			        PADR( SPACE(06)															,06, " ") + ;
			        PADR( DTOC(_dDtSol)            											,10, " "))
			
			// Efetua gravação na tabela SZZ
			DbSelectArea("SZZ")
			RecLock("SZZ",.T.)
			SZZ->ZZ_FILIAL := FWxFilial("SZZ")
			SZZ->ZZ_PRECAR := ZZ3->ZZ3_NUM
			SZZ->ZZ_PREPED := ZZ5->ZZ5_NUM
			SZZ->ZZ_CODCLI := TRB1->ZZ4_CODCLI 
			SZZ->ZZ_LOJCLI := TRB1->ZZ4_LOJA
			SZZ->ZZ_NOMCLI := TRB1->ZZ4_NOME
			SZZ->ZZ_CODPRD := ZZ5->ZZ5_COD
			SZZ->ZZ_DESCRI := GetAdvFVal('SB1', 'B1_DESC', FWxFilial('SB1') + ZZ5->ZZ5_COD, 1)
			SZZ->ZZ_QTDSOL := ZZ5->ZZ5_QPCAIX
			SZZ->ZZ_QTDPES := ZZ5->ZZ5_QPPESO
			SZZ->ZZ_SOLPRO := _cSolProd
			SZZ->ZZ_DTSPOR := _dDtSol
			SZZ->ZZ_USRSOL := _cUserSol
			MsUnlock()
		Endif
		If Empty(ZZ_DTSPOR)
			ALERT("FALTA DADOS NO CAMP Dt Solicit P- ZZ_DTSPOR")
		Endif
		If Empty(ZZ_USRSOL)
			ALERT("FALTA DADOS NO CAMPO User Solicit-ZZ_USRSOL")
		EndIf 
	Endif

	TRB1->(DbSkip())      
Enddo   		

TRB1->(DbCloseArea())

// Somente mostra tela de log se executou encontrou dados para processamento
If lTelaLog
	cMask  := "Arquivos Texto (*.TXT) |*.txt|"
	cTexto := MemoRead(__cArqLog2)

	DEFINE FONT oFont Name "Courier New" SIZE 5,0

	DEFINE MSDIALOG oDlg TITLE __cArqLog2 FROM 3, 0 TO 500, 915 PIXEL

	@ 5, 5 GET oMemo VAR cTexto Memo SIZE 445, 220 OF oDlg PIXEL
	oMemo:bRClicked := { || AllwaysTrue() }
	oMemo:oFont     := oFont

	DEFINE SBUTTON FROM 235, 275 TYPE  1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
	DEFINE SBUTTON FROM 235, 245 TYPE 13 ACTION (cFile := cGetFile(cMask, ""), IF(cFile == "", .T., MemoWrite(cFile, cTexto))) ENABLE OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTER
Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Geralog - Geração do log de processamento                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GeraLog(cLogErro)

//__cArqLog1 := "\log_spf9\" + ZZ3->ZZ3_NUM + "_as_" + Substr(Time(),1,2) + "-" + Substr(Time(),4,2) + "_por_" + Alltrim(cUserName) + ".log"
__cArqLog2 := "C:\relsiga\" + ZZ3->ZZ3_NUM + "_as_" + Substr(Time(),1,2) + "-" + Substr(Time(),4,2) + "_por_" + Alltrim(cUserName) + ".log"

/*
If !File(__cArqLog1)
	If (nHandle1 := MSFCreate(__cArqLog1,0)) == -1
		Return
	EndIf
Else
	If (nHandle1 := FOpen(__cArqLog1,2)) == -1
		Return
	EndIf
EndIf
*/

If !File(__cArqLog2)
	If (nHandle2 := MSFCreate(__cArqLog2,0)) == -1
		Return
	EndIf
Else
	If (nHandle2 := FOpen(__cArqLog2,2)) == -1
		Return
	EndIf
EndIf

//FSeek(nHandle1,0,2)
//FWrite(nHandle1,cLogErro+chr(13)+chr(10),200)
//FClose(nHandle1)

FSeek(nHandle2,0,2)
FWrite(nHandle2,cLogErro+chr(13)+chr(10),200)
FClose(nHandle2)

Return


/*/{Protheus.doc} User Function gj26aPrd
	(função para automatização de preenchimendo dos intervalos de datas dos pré-pedidos dentro do carregamento.)
	@type  Function
	@author Mauricio Roehrs
	@since 07/03/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function gf26aPrd()
	
	if msgbox('Tem certeza que deseja realizar o preenchimento automático do intervalo das datas de produção?','Automação de datas de produção!','YESNO')
		Processa( { || fillData(ZZ3->ZZ3_NUM,'') }, 'Carregando registros...', 'Aguarde...')
	endif
	
	msgbox('Processamento finalizado!','AUTOMAÇÃO DE DATAS DE PRODUÇÃO','INFO')

Return 


/*
Dias de validade precisa ser no maximo 1/3. ou seja se o produto tem 60 dias de validade a caixa mais antiga não pode ter menos que 40 dias de validade
*/
/*/{Protheus.doc} fillData
	(Realiza o preenchimento das datas)
	@type  Static Function
	@author Mauricio Roehrs
	@since 07/03/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fillData(_cPrecar,_preped) 

	Local _cQuery := ""
	Local _cQryIt := ""
	
	//função para limpar as reservas existentes antes de realiza-las

	_cQuery := " SELECT ZZ4_NUM, ZZ4_AUTDTP,ZZ4_DATENT"
	_cQuery += " FROM " + retSqlTab("ZZ4") + "(NOLOCK)"
	_cQuery += " WHERE " + retSqlFil("ZZ4")
	_cQuery += " AND ZZ4_PRECAR = '"+_cPrecar+"'"
	_cQuery += " AND ZZ4_STATUS IN ('B','L','A')"
	_cQuery += " AND " + retSqlDel("ZZ4")

	cAlias := GetNextAlias()
	TCQuery _cQuery new alias &cAlias
	(cAlias)->(dbGoTop())
	
	while (cAlias)->(!eof())

		_cQryIt := " SELECT ZZ5_COD, ZZ5_NUM, R_E_C_N_O_ AS ZZ5RECNO, ZZ5_QPCAIX, ZZ5_ITEM "
		_cQryIt += " FROM " +retSqlTab("ZZ5") + " (NOLOCK)"
		_cQryIt += " WHERE " + retSqlFil("ZZ5")
		_cQryIt += " AND ZZ5_NUM = '"+(cAlias)->ZZ4_NUM+"'"
		_cQryIt += " AND ZZ5_DTPINI = '' AND ZZ5_DTPFIM = ''"
		_cQryIt += " AND " + retSqlDel('ZZ5')

		cAls := GetNextAlias()
		TCQuery _cQryIt new alias &cAls

		(cAls)->(dbGoTop())
		while (cAls)->(!eof())

			//função que realiza a limpeza das datas de produção selecionadas
			//u_mitfs003((cAls)->ZZ5_COD,(cAls)->ZZ5_QPCAIX,(cAlias)->ZZ4_NUM,(cAlias)->ZZ4_AUTDTP)
			IF (_cEmpresa == "01")
				u_mitfs002((cAls)->ZZ5_COD,(cAls)->ZZ5_ITEM, (cAls)->ZZ5RECNO,(cAls)->ZZ5_QPCAIX,(cAlias)->ZZ4_NUM,(cAlias)->ZZ4_AUTDTP,stod(''),stod(''),(cAlias)->ZZ4_DATENT)
			ENDIF

			(cAls)->(dbSkip())
		enddo

		(cAlias)->(dbSkip())
	enddo

	(cAlias)->(dbCloseArea())
	(cAls)->(dbCloseArea())
Return 

/*/{Protheus.doc} mitfs002
	(separa as caixas para evitar que outro pré-pedido reserve as mesmas datas)
	@type  Static Function
	@author Mauricio Roehrs
	@since 07/03/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function mitfs002(_codProd,_cItem,_nRecno,_nQpCaix,_cPreped,_cAuto,_dataini,_datafim,_dataEnt)
//							1		2		3		4		 5		 6		7		8		9
	Local cQuery   := ""
	local _cCondicao := ""
	local _cInner := ""
	local _cGrp := substr(alltrim(GetAdvFVal('SB1','B1_GRUPO', FWxFilial('SB1') + _codProd,1)),1,2)

	if !empty(_dataEnt) .and. _cAuto == 'S'
		if _cGrp == '56' //se for porcionados usa data de produção
			_cInner := ""
			_cCondicao := " AND Z8_DATAP >= DATEADD(day, ROUND((B1_VALID/3),0)*-1, '" + _dataEnt + "')"
		else
			_cInner := " INNER JOIN " + retSqlTab('SZ2') + " (NOLOCK) ON (" + retSqlFil('SZ2') + " AND Z2_NUM = Z8_PREDES AND " + retSqlDel('SZ2') + ")"
			_cCondicao :=  " AND Z2_DATAABT >= DATEADD(day, ROUND((B1_VALID/3),0)*-1, '" + _dataEnt + "')"
		endif
	elseif empty(_dataEnt) .and. _cAuto == 'S'
		if _cGrp == '56' //se for porcionados usa data de produção
			_cInner := ""
			_cCondicao := " AND Z8_DATAP >= DATEADD(day, ROUND((B1_VALID/3),0)*-1, GETDATE())"
		else
			_cInner := " INNER JOIN " + retSqlTab('SZ2') + " (NOLOCK) ON (" + retSqlFil('SZ2') + " AND Z2_NUM = Z8_PREDES AND " + retSqlDel('SZ2') + ")"
			_cCondicao := " AND Z2_DATAABT >= DATEADD(day, ROUND((B1_VALID/3),0)*-1, GETDATE())"
		endif
	else
		_cCondicao := ""
	endif

	cQuery := "SELECT TOP " + cValtoChar(round(_nQpCaix,0)) + " Z8_CONTROL AS CONTROL, Z8_COD AS COD, Z8_DATAP AS DATAP, Z8_DATAVAL, B1_VALID, ROUND(B1_VALID-(B1_VALID/3),0) AS VIDAUTIL, DATEDIFF(day, GETDATE(),Z8_DATAVAL) AS DIASVAL"
	cQuery += " FROM " + retSqlTab('SZ8') 
	cQuery += _cInner
	cQuery += " INNER JOIN " + retSqlTab('SB1') + " (NOLOCK) ON (B1_COD = Z8_COD AND B1_FILIAL = '" + cFilAnt + "')"
	cQuery += " WHERE " + retSqlFil('SZ8')
	cQuery += + _cCondicao
	cQuery += " AND Z8_FIL = '" + cFilAnt + "'"
	cQuery += " AND Z8_DATAS = ''"
	cQuery += " AND Z8_HORAS = ''"
	cQuery += " AND Z8_ITEM = ''"
	cQuery += " AND Z8_PREPED = ''"
	cQuery += " AND Z8_PRECAR = ''"
	cQuery += " AND Z8_AUTOPED = ''"
	//cQuery += " AND Z8_AUTOPED <> ''"
	cQuery += " AND Z8_DATAVAL > Z8_DATAP"
	cQuery += " AND Z8_DATAVAL > '" + dtos(date()) + "'"
	if !empty(_dataini) .and. !empty(_datafim)
		cQuery += " AND Z8_DATAP BETWEEN '" + dtos(_dataini) + "' AND '" + dtos(_datafim) + "'"
	endif
	cQuery += " AND Z8_COD = '" + _codProd + "'"
	cQuery += " AND " + retSqlDel('SZ8') + " AND " + retSqlDel('SB1')
	cQuery += " ORDER BY Z8_DATAP ASC"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cAlsBox := GetNextAlias()
	TCQuery cQuery new alias &cAlsBox
	//Inicio do processo de coleta das datas de produção

	(cAlsBox)->(DbGoTop())

	If ! (cAlsBox)->(EoF())
		_dtIni := stod((cAlsBox)->DATAP)
		_dtFim := stod((cAlsBox)->DATAP)
	/*Else		
		If(_cAuto = 'S')
			MsgAlert("As datas de produção inicial e final não serão aplicadas para o pedido " + _cPreped + " item: " + _cItem + "." + " As caixas em estoque não atendem às regras e/ou já estão vinculadas a pedidos", "Atenção")		
		EndIf*/
	EndIf

	_dtIni := stod((cAlsBox)->DATAP)
	_dtFim := stod((cAlsBox)->DATAP) 

	while (cAlsBox)->(!eof())  

		//Reserva as caixas com o pre-pedido em processamento
		SZ8->(DbSetOrder(3))
		SZ8->(MsSeek(FWxfilial('SZ8') + (cAlsBox)->CONTROL))
		reclock('SZ8',.f.)
			SZ8->Z8_AUTOPED := _cPreped
		SZ8->(msunlock())

		(cAlsBox)->(DbSkip())

		if (cAlsBox)->(!eof())
			_dtFim := stod((cAlsBox)->DATAP)
		endif

	enddo

	if empty(_dataini) .and. empty(_datafim)
		ZZ5->(dbGoTo(_nRecno))
		reclock('ZZ5',.f.)
			ZZ5->ZZ5_DTPINI := _dtIni
			ZZ5->ZZ5_DTPFIM := _dtFim
		ZZ5->(msunlock()) 
	endif
	(cAlsBox)->(dbclosearea())
Return 


/*/{Protheus.doc} mitfs003
	(Função destinada a limpeza das datas de reserva das caixas antes de uma nova reserva)
	@type  User Function
	@author Mauricio Roehrs
	@since 15/03/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User Function mitfs003(_codProd,_nQpCaix,_cPreped,_cAuto)

	Local cQuery   := ""
	cQuery := "SELECT Z8_CONTROL AS CONTROL, Z8_COD AS COD, Z8_DATAP AS DATAP, Z8_DATAVAL"
	cQuery += " FROM " +retSqlTab('SZ8') + "(NOLOCK)"
	cQuery += " WHERE " + retSqlFil('SZ8')
	cQuery += " AND Z8_FIL = '"+cFilAnt+"'"
	cQuery += " AND Z8_DATAS = ''"
	cQuery += " AND Z8_HORAS = ''" 
	cQuery += " AND Z8_ITEM = ''"
	cQuery += " AND Z8_PREPED = ''"
	cQuery += " AND Z8_PRECAR = ''"
	cQuery += " AND Z8_AUTOPED = '"+alltrim(_cPreped)+"'"
	cQuery += " AND Z8_COD = '"+alltrim(_codProd)+"'"
	cQuery += " AND " + retSqlDel('SZ8')
	cQuery += " ORDER BY Z8_DATAP ASC"

	cAlsBox := GetNextAlias()
	TCQuery cQuery new alias &cAlsBox
	//Inicio do processo de coleta das datas de produção

	(cAlsBox)->(DbGoTop())

	while (cAlsBox)->(!eof())
		SZ8->(DbSetOrder(3))
		SZ8->(MsSeek(FWxfilial('SZ8') + (cAlsBox)->CONTROL))
		reclock('SZ8',.f.)
			SZ8->Z8_AUTOPED := ""
		SZ8->(msunlock())

		(cAlsBox)->(DbSkip())
	enddo

	(cAlsBox)->(dbclosearea())

return

User Function Gjf26MaCA()
	_cQuery2 := "SELECT ZZ4_NUM AS PEDIDO"
	_cQuery2 += " FROM  " + RetSQLTab('ZZ4') + " (NOLOCK)"
	_cQuery2 += " WHERE " + RetSQLFil('ZZ4')
	_cQuery2 += " AND ZZ4_PRECAR = '" + ZZ3->ZZ3_NUM + "'"
	_cQuery2 += " AND " + RetSQLDel('ZZ4')
	_cQuery2 += " ORDER BY ZZ4_NUM DESC"

	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP2") != 0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP2"

	SetMVValue("GJF53","MV_PAR01",ZZ3->ZZ3_NUM, .T.)
	SetMVValue("GJF53","MV_PAR02",ZZ3->ZZ3_NUM, .T.)
	SetMVValue("GJF53","MV_PAR03",GetAdvFval( 'ZZ4','ZZ4_NUM',FWxFilial('ZZ4') + ZZ3->ZZ3_NUM,1), .T.)
	SetMVValue("GJF53","MV_PAR04",TMP2->PEDIDO, .T.)

	pergunte("GJF53", .T.)

	U_GJF53()
Return

// Chama o relatório FFM03 - Descontos p/ Carga
User Function gjf26dpc()

	SetMVValue("FFM03","MV_PAR01",ZZ3->ZZ3_NUM, .T.)
	SetMVValue("FFM03","MV_PAR02",ZZ3->ZZ3_NUM, .T.)
	SetMVValue("FFM03","MV_PAR03",4, .T.)

	pergunte("FFM03", .T.)

	U_FFM03()

Return

// Chama o relatório GJF59 - Faltas
User Function gjf26fal()

	SetMVValue("GJF59","MV_PAR01",ZZ3->ZZ3_NUM, .T.)
	SetMVValue("GJF59","MV_PAR02",ZZ3->ZZ3_NUM, .T.)
	SetMVValue("GJF59","MV_PAR03",(ddatabase-365), .T.)
	SetMVValue("GJF59","MV_PAR04",(ddatabase+365), .T.)

	pergunte("GJF59", .T.)

	U_GJF59()

Return
