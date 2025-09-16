#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
#INCLUDE "totvs.ch"
#INCLUDE "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GJF28    ³ Giuliano Forgiarini           ³ Data ³ 14.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pre-pedidos de venda                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaoms                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF28()

	Private aCores      := {}
	Private aCores2     := {}
	Private aRotina     := {}
	Private cCondicao   := ''
	Private _lSldFlag   := .f.    //Para utilizaçao da função gjf28sld()
	Private cFilAux     := FWxfilial('SE1')
	Private _lSalv      := .f.
	aIndZZ4             := {}
	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	//area := getArea()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX           := aPosObj[1]
	aX[3]        += 60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	bLegenda1 := "ZZ4->ZZ4_STATUS $ 'BP'"          // bloqueado
	bLegenda2 := "ZZ4->ZZ4_STATUS == 'C'"          // carregando
	bLegenda3 := "ZZ4->ZZ4_STATUS == 'L'"          // liberado
	bLegenda4 := "ZZ4->ZZ4_STATUS == 'E'"          // encerrado
	bLegenda5 := "ZZ4->ZZ4_STATUS == 'S'"          // em espera
	bLegenda6 := "ZZ4->ZZ4_STATUS == 'F'"          // faturado
	bLegenda7 := "ZZ4->ZZ4_STATUS == 'R'"          // producao

	aCores := { {bLegenda1, 'BR_AZUL'    },;       // bloqueado
				{bLegenda2, 'BR_AMARELO' },;         // carregando
				{bLegenda3, 'BR_VERDE'   },;         // liberado
				{bLegenda4, 'BR_VERMELHO'},;         // encerrado
				{bLegenda5, 'BR_LARANJA' },;         // em espera
				{bLegenda6, 'BR_PRETO'   },;         // faturado
				{bLegenda7, 'BR_BRANCO'  }}          // branco

	//  {bLegenda8, 'BR_CINZA'   }}        // portal

	aCores2:= { { 'BR_AZUL'   	 ,'Bloqueado'   },;       // bloqueado
				{ 'BR_AMARELO'   ,'Carregando'  },;    // carregando
				{ 'BR_VERDE'     ,'Liberado'    },;    // liberado
				{ 'BR_VERMELHO'  ,'Encerrado'   },;    // encerrado
				{ 'BR_LARANJA'   ,'Em Espera'   },;    // em espera
				{ 'BR_PRETO'     ,'Faturado'    },;    // Faturado
				{ 'BR_BRANCO'    ,'Produção'    }}     // Produção
				//   { 'BR_CINZA'     ,'Portal'      }}     // Portal

	aRotina := {{ "Pesquisa"   	  		,"AxPesqui"    , 	0, 1},; 	     //"Pesquisar"
				{ "Visualizar" 	  		,"u_gjf28Visu" , 	0, 2},;	 //"Visualizar"
				{ "Incluir"    	  		,"u_gjf28Incl" , 	0, 3},;	 //"Incluir"
				{ "Alterar"    	  		,"u_gjf28Alte" , 	0, 4},;	 //"Alterar"
				{ "Datas Prod."	  		,"u_GJF133"    , 	0, 2},;	 //"Definição do intervalo de produção"
				{ "Produtos"   	  		,"u_gjf52Visp" , 	0, 2},;  //"Consultar"
				{ "Dev.Portal" 	  		,"u_gjf28dev"  , 	0, 2},;  //"Devolver ao Portal"
				{ "Encerrar"   	  		,"u_gjf28enc"  , 	0, 4},;  //"Encerrar"
				{ "Excluir"    	  		,"u_gjf28Excl" , 	0, 5},;  //"Excluir"
				{ "Consultar"  	  		,"u_gjf28pos"  , 	0, 2},;  //"Consultar"
				{ "Imp.EDI"    	  		,"u_gjf106"    , 	0, 3},;  //"Importar do EDI"
				{ "EDI GPA"    	  		,"u_mlr06"     , 	0, 3},;  //"Importar do EDI Grupo Pão de Açucar"
				{ "EDI GCF"    	 		,"u_dti130"    , 	0, 3},;  //"Importar do EDI Carrefour"
				{ "Separar PP" 	  		,"u_gjf28S"    , 	0, 3},;  //"Separar pré-pedidos"
				{ "Enviar Fusion" 		,"u_gjf28F"    , 	0, 3},;  //"Enviar Fusion"
				{ "Cancelar Seq. Fusion","u_gjf28CS"   , 	0, 3},;  //"Cancelar Seq. Fusion"
				{ "Legenda"    	  		,"u_gjf28Leg"  , 	0, 1}}   //"Legenda"

	Private cCadastro := "Pré-Pedidos de Venda"

	//if select('ZZ3') != 0														//Verifica o status do pré-carregamento e fecha seu arquivo
	//	dbclosearea('ZZ3')
	//endif

	cPerg := "GJF28"

	if !pergunte(cPerg,.t.)
		return
	endif

	cCondicao := "ZZ4_DATA >= '" + dtos(mv_par05) + "' AND ZZ4_DATA <= '" + dtos(mv_par06) + "' AND ZZ4_FILIAL = '" + FWxfilial('ZZ4') + "'"

	if mv_par03 = 2
		cCondicao += " AND ZZ4_PRECAR <> ' ' AND ZZ4_FILIAL = '" + FWxfilial('ZZ4') + "'"	
	elseif mv_par03 = 3
		cCondicao += " AND ZZ4_PRECAR = ' ' AND ZZ4_FILIAL = '" + FWxfilial('ZZ4') + "'"	
	endif

	do case
		case mv_par01 = 2
			cCondicao += " AND ZZ4_STATUS IN('B','P')"
		case mv_par01 = 3
			cCondicao += " AND ZZ4_STATUS = 'L'"
		case mv_par01 = 4
			cCondicao += " AND ZZ4_STATUS = 'E'"
		case mv_par01 = 5
			cCondicao += " AND ZZ4_STATUS = 'C'"
	endcase

	if !empty(mv_par04)
		cCondicao += " AND ZZ4_REPRES = '" + mv_par04 + "' "
	endif

	do case
		case mv_par02 = 2
			cCondicao += " AND ZZ4_ORIGEM = 'D'"
		case mv_par02 = 3
			cCondicao += " AND ZZ4_ORIGEM = 'E'"
		case mv_par02 = 4
			cCondicao += " AND ZZ4_ORIGEM = 'P'"
	endcase

	//Filtra produtos empenhados
	if !empty(mv_par07)
		_cRelPP := u_gjf28E(mv_par07)
		cCondicao += "  AND ZZ4_NUM IN(" + _cRelPP + ")"
	endif

	//Verifica o tipo de produção e faz filtragem nos pré-pedidos
	if mv_par08 <> 3
		if mv_par08 = 1
			cCondicao += " AND ZZ4_TIPOPR = 'D'"
		else
			cCondicao += " AND ZZ4_TIPOPR = 'P'"
		endif
	endif

	DbSelectArea("ZZ4")
	ZZ4->(DbSetOrder(2))

	mBrowse(6,1,22,75,"ZZ4", ,,,,2,aCores,,,,,,,,cCondicao)	

	if select('ZZ3') <> 0														
		ZZ3->(dbclosearea())
	endif

	If Select('ZZ4')<> 0
		ZZ4->(dbCloseArea())
	Endif

Return

//Disponibiliza a legenda
User Function gjf28Leg(cAlias,nReg,nOpc)
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return

//Visualiza Pré-Pedidos de Venda
User Function gjf28Visu(cAlias,nReg,nOpc)

	Local oDlg		:= NIL

	Local aButtons	:= {{"POSCLI",{|| u_gjf28Con()},'Situação do Cliente','Posicao'}}

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	area := GetArea()

	AADD(aButtons, {"AUTOM" ,{|| u_gjf28lCl()},'Liberar cliente financeiro'  ,'Liberar' } )
	AADD(aButtons, {"EDIT"  ,{|| u_gjf28cad()},'Informações do Cadastro' ,'Cadastro'} )
	AADD(aButtons, {"FORM"  ,{|| u_gjf28sld() , oDlg:Refresh() },'Consulta saldo de produtos'   , 'Saldo'  } )
	AADD(aButtons, {"BUDGET",{|| u_GJF85C()   , oDlg:Refresh() },'Consulta Credito'   , 'Credito'  } )
	AADD(aButtons, {"BMPORD",{|| u_GJF108()}  ,'Consulta Caixas','Caixas'} )
	AADD(aButtons, {"EDIT"  ,{|| u_gjf28orc()},'Orçamento','Orcamento'} )
	AADD(aButtons, {'BMPORD',{|| u_gjf28ult()},'Últ. 10 Prod. Comprados','Últ. 10 Prod.'} )

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZZ4")

	gjf28Ahead("ZZ5")                                                           //Monta oa vetor aHeader

	nUsado := Len(aHeader)

	gjf28Acols(nOpc)															//Monta oa vetor aCols

	DbSelectArea('SA1')
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(FWxfilial('SA1')+M->(ZZ4_CODCLI+ZZ4_LOJA)))

	oEnc    := MsMGet():New("ZZ4" ,ZZ4->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZZ5_ITEM",.T.)

	//oGetDad:oBrowse:bChange    := {|| u_gjf28clc() }             //Realiza todos os calculos ao mudar de linha
	//oGetDad:oBrowse:bLostFocus := {|| u_gjf28clc() }             //Realiza todos os calculos ao perder o foco da linha

	u_gjf28ke('V','A')

	if !u_GJF85S(M->ZZ4_CODCLI,M->ZZ4_LOJA)
		M->ZZ4_SITCLI := 'SITUAÇÃO FINANCEIRA IRREGULAR!'
	else
		M->ZZ4_SITCLI := 'SITUAÇÃO FINANCEIRA APROVADA!'
	endif

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, , aButtons)

	RestArea(area)

	u_gjf28ke('V','D')

Return

//Incluir Pré-Pedido de venda
User Function gjf28Incl(cAlias,nReg,nOpc)
	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {}

	AADD(aButtons, { 'FORM'   ,{||u_gjf28sld() , oDlg:Refresh() },'Consulta Saldo','Saldo'})
	AADD(aButtons, { 'BUDGET' ,{||u_GJF85C(M->ZZ4_CODCLI,M->ZZ4_LOJA) ,oDlg:Refresh()},'Consulta Credito','Credito'})
	AADD(aButtons, { 'BMPORD' ,{|| u_GJF108()},'Consulta Caixas','Caixas'})
	AADD(aButtons, { 'BMPORD' ,{|| u_gjf28pri()},'Alterar Prioridade','Alt. Prior.'} )
	AADD(aButtons, { 'BMPORD' ,{|| u_gjf28ult()},'Últ. 10 Prod. Comprados','Últ. 10 Prod.'} )

	if !empty(ZZ4->ZZ4_PRECAR)
		ZZ3->(DbSetOrder(2))
		ZZ3->(MsSeek(FWxfilial('ZZ3')+ZZ4->ZZ4_PRECAR))
	endif

	/*
	if FunName() = 'GJF26'
		if ZZ3->ZZ3_STPCK $ 'P/S'
			msgbox('Separação das caixas do carregamento já iniciada ou liberada. Solicite o bloqueio para efetuar alterações!','OPERAÇÃO NEGADA!','STOP')
			//	lOk := .f.
			//	oDlg:End()
			return
		endif
	endif
	*/
	if ZZ3->ZZ3_STPCK $ 'P/S/L' .and. ZZ3->ZZ3_ISRESU = "N"
		FWAlertError('Carregamento já foi liberado! Para liberá-lo novamente contate o Matheus!','OPERAÇÃO NEGADA!')
		Return
	else
		if ZZ3->ZZ3_LIBPCK = "S" .and. ZZ3->ZZ3_ISRESU = "N"
			FWAlertError('Carregamento já foi liberado! Para liberá-lo novamente contate o Matheus!','OPERAÇÃO NEGADA!')
			Return
		endif
	endif

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	_cnPreped := getSx8Num('ZZ4','ZZ4_NUM')
	confirmsx8()
	nUsado := gjf28Ahead("ZZ5")
	gjf28Acols(nOpc)

	RegToMemory("ZZ4",.T.)

	if select('ZZ3') != 0										//Verifica o status do pré-carregamento e o vincula
		M->ZZ4_PRECAR := ZZ3->ZZ3_NUM
	endif

	M->ZZ4_EMAILU := alltrim(u_gjf54USR())
	M->ZZ4_ORIGEM := 'D'
	M->ZZ4_NUM := _cnPreped

	oEnc := MsMGet():New("ZZ4" ,ZZ4->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_gjf28LinOk(n,'I')","u_gjf28TudOk","+ZZ5_ITEM",.T., , ,.F. , ,)

	//oGet:oBrowse:bChange    := {|| u_gjf28clc() }             //Realiza todos os calculos ao mudar de linha
	//oGet:oBrowse:bLostFocus := {|| u_gjf28clc() }             //Realiza todos os calculos ao perder o foco da linha

	u_gjf28ke('I','A')

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_gjf28TudOk().and.Obrigatorio(aGets,aTela).and.u_gjf28LinOk(n,'I'), ;
	Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

	If  lOk
		u_gjf85(M->ZZ4_CODCLI,M->ZZ4_LOJA)
		if !u_gjf85S(M->ZZ4_CODCLI,M->ZZ4_LOJA) // Cliente com título vencido!
			Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Cliente com título vencido!',4,1)
		endif
		//confirmsx8()
		gjf28Grav(nOpc)
//	else
//		Rollbacksx8()
	Endif

	u_gjf28ke('I','D')

Return

//Alteração de Pré-Pedido
User Function gjf28Alte(cAlias,nReg,nOpc)

	Local oDlg		    := NIL
	Local lOk 		    := .F.
	Local cQry 			:= ''
	Local _cUsrf9   	:= getmv('SI_USRF9')
	//Local aCposAlt	    := {}
	Local aButtons	    := {}
	//Local _cCodigo      := ''
	Private aHeader	    := {}
	Private aCols	    := {}
	Private nUsado	    :=	0
	Private oGet	    := NIL
	Private aGets	    := {}
	Private aTela	    := {}

	if !empty(ZZ4->ZZ4_PRECAR)
		ZZ3->(DbSetOrder(2))
		ZZ3->(MsSeek(FWxfilial('ZZ3')+ZZ4->ZZ4_PRECAR))
	endif

	DbSelectArea(cAlias)

	area := GetArea()

	// ------------ INICIO TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION
	/*
	_cUsuarios := GetMv('MV_MENCOM')
	_cCodUser  := RetCodUsr()

	If U_BLQ_FUS(ZZ4->ZZ4_PRECAR)
		If AllTrim(_cCodUser) $ _cUsuarios
			If FWAlertYesNo("Deseja realizar a Alteração ?","Já Existe Sequenciamento na Fusion para este Pré-Pedido.")
				_xRet := U_PSW_LIB(ZZ4->ZZ4_NUM, 2)		// Passo 2 no segundo parâmetro quando informado pré-pedido no primeiro parâmetro
				If !_xRet
					Return .F.
				EndIf
			Else
				Return .F.
			EndIf
		Else
			FWAlertError("Não é permitido manutenção neste pré-pedido.","Já Existe Sequenciamento na Fusion para este Pré-Pedido.")
			Return .F.
		EndIf
	EndIf
	*/
	// ------------ FINAL TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION

	//VERIFICAR POSSIBILIDADE DE ALTERAÇÃO DO PRE-PEDIDO
	if ZZ4->ZZ4_STATUS == 'C' .or. ZZ4->ZZ4_STATUS == 'E' .or. ZZ4->ZZ4_STATUS == 'F'  .or. ZZ4->ZZ4_STATUS == 'R'                  //Verifica o status do pré-pedido
		Help(" ",1,'OPERAÇÃO NEGADA!',,'Status não permite Alteração de Pré-Pedido!',4,1)
		return
	endif

	if ZZ3->ZZ3_STPCK $ 'P/S/L' .and. (ZZ3->ZZ3_ISRESU = "N" .or. ZZ4->ZZ4_CODCLI != "100000")
		FWAlertError('Carregamento já foi liberado! Para liberá-lo novamente contate o Matheus!','OPERAÇÃO NEGADA!')
		Return
	else
		if ZZ3->ZZ3_LIBPCK = "S" .and. (ZZ3->ZZ3_ISRESU = "N" .or. ZZ4->ZZ4_CODCLI != "100000")
			FWAlertError('Carregamento já foi liberado! Para liberá-lo novamente contate o Matheus!','OPERAÇÃO NEGADA!')
			Return
		endif
	endif

	/*if ZZ3->ZZ3_ISRESU == 'S'
		
		if !(RetCodUsr()$_cUsrf9)

			cQry := " SELECT ZZ5_SOLPRO"
			cQry += " FROM " +retSqlTab('ZZ5') + "(NOLOCK)"
			cQry += " WHERE " +retSqlFil('ZZ5')
			cQry += " AND ZZ5_NUM = '"+ZZ4->ZZ4_NUM+"'"
			cQry += " AND ZZ5_SOLPRO = 'S'"
			cQry += " AND " +retSqlDel('ZZ5')
			
			(cAlias)->(dbGoTop())

			//verifica se houve retorno na query
			Count to nCount
				
			If nCount > 0
				Help(" ",1,'OPERAÇÃO NEGADA!',,'Atenção, carregamento selecionado como resumo e com solicitação de produção (F9) já realizado, impossível realizar alteração!',4,1)
				
				(cAlias)->(dbCloseArea())
				return
			endif

			(cAlias)->(dbCloseArea())
		endif
	endif*/

	/*
	if !empty(ZZ4->ZZ4_PRECAR)//verifica se o carregamento já foi informado no pre-carregamento
	ZZ3->(dbSetOrder(2))
	ZZ3->(dbGoTop())
	if ZZ3->(MsSeek(FWxFilial('ZZ3') + ZZ4->ZZ4_PRECAR))
	if ZZ3->ZZ3_STPCK $ 'P/S'
	msgbox('Separação das caixas do carregamento já iniciada ou liberada. Solicite o bloqueio para efetuar alterações!','OPERAÇÃO NEGADA!','STOP')
	return
	endif
	endif
	endif
	*/

	//u_gjf28aj(ZZ4->ZZ4_NUM)

	AADD(aButtons, { 'FORM'   ,{||u_gjf28sld() , oDlg:Refresh() }, 'Consulta Saldo' , 'Saldo'  } )
	AADD(aButtons, { 'BUDGET' ,{||u_GJF85C(M->ZZ4_CODCLI,M->ZZ4_LOJA),oDlg:Refresh() },'Consulta Credito'   , 'Credito'  } )
	AADD(aButtons, { 'PRODUTO',{||u_GJF28an() , oDlg:Refresh() },'Analise Reserva'   , 'An.Reserva'  } )
	AADD(aButtons, { 'EDIT'   ,{||u_gjf28RCX() , oDlg:Refresh() },'Reserva'   , 'Res.Caix'  } )
	AADD(aButtons, { 'BMPORD' ,{|| u_GJF108()},'Consulta Caixas','Caixas'} )
	AADD(aButtons, { 'BMPORD' ,{|| u_gjf28cnf()},'Consulta Notas Fiscais','Cons. Notas'} )
	AADD(aButtons, { 'BMPORD' ,{|| u_gjf28pri()},'Alterar Prioridade','Alt. Prior.'} )
	AADD(aButtons, { 'BMPORD' ,{|| u_gjf28ult()},'Últ. 10 Prod. Comprados','Últ. 10 Prod.'} )

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := gjf28Ahead("ZZ5")                                                 //Monta o aHeader

	gjf28Acols(nOpc)                                                            //Monta o Acols

	RegtoMemory('ZZ4')

	M->ZZ4_STATUS := 'B'                                                        //Já bloqueia novamente o PP

	oEnc := MsMGet():New("ZZ4" ,ZZ4->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"u_gjf28LinOk(n,'A')","u_gjf28TudOk","+ZZ5_ITEM",.T., , ,.F. ,,,,,"u_gjf28Vdl")

	//oGet:oBrowse:bChange    := {|| u_gjf28clc() }             //Realiza todos os calculos ao mudar de linha
	//oGet:oBrowse:bLostFocus := {|| u_gjf28clc() }             //Realiza todos os calculos ao perder o foco da linha

	u_gjf28ke('A','A')

	if !u_GJF85S(M->ZZ4_CODCLI,M->ZZ4_LOJA)
		M->ZZ4_SITCLI := 'SITUAÇÃO FINANCEIRA IRREGULAR!'
		Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Cliente com título vencido!',4,1)
	else
		M->ZZ4_SITCLI := 'SITUAÇÃO FINANCEIRA APROVADA!'
	endif

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_gjf28TudOk().and.u_gjf28LinOk(n,'A').and.;
	Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), oDlg:refresh())}, {||oDlg:End()}, , aButtons)

	If lOk
		u_gjf85(M->ZZ4_CODCLI,M->ZZ4_LOJA)
		/*if !u_gjf85S(M->ZZ4_CODCLI,M->ZZ4_LOJA)
			//msgbox('Limite de Credito do Cliente Excedido!','OPERAÇÃO IRREGULAR!','STOP')
			// 09/12/22 -> Solicitação de remoção de aviso pelo Rodrigo Abelin
			Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Cliente com título vencido!',4,1)
		endif*/
		gjf28Grav(nOpc)
	Endif

	u_gjf28ke('A','D')

	RestArea(area)

Return

//Alterar prioridade em itens de pré-pedido
User Function gjf28pri()

	Local _cPriori := ""

	pergunte("GJF28PRI", .T.)

	do case
		case mv_par01 = 1
			_cPriori := "C"
		case mv_par01 = 2
			_cPriori := "P"
		case mv_par01 = 3
			_cPriori := "A"
		otherwise
			FWAlertError("Parâmetro inválido!","ERRO!")
			return
	endCase

	_cQueryP := "SELECT ZZ5_NUM, ZZ5_ITEM"
	_cQueryP += " FROM  " + RetSQLTab('ZZ5') + " (NOLOCK)"
	_cQueryP += " WHERE " + RetSQLFil('ZZ5')
	_cQueryP += " AND ZZ5_NUM = '" + ZZ4->ZZ4_NUM + "'"
	_cQueryP += " AND " + RetSQLDel('ZZ5')
	_cQueryP += " ORDER BY ZZ5_NUM, ZZ5_ITEM"

	_cQueryP  := ChangeQuery(_cQueryP)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQueryP Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("PRI") != 0
		PRI->(dbCloseArea())
	Endif

	TCQUERY _cQueryP NEW ALIAS "PRI"

	PRI->(dbGoTop())
	ZZ5->(dbSetOrder(1))
	ZZ5->(dbGoTop())

	While PRI->(!EOF())

		if ZZ5->(MsSeek(FWxFilial('ZZ5')+PRI->ZZ5_NUM+PRI->ZZ5_ITEM))
			reclock('ZZ5',.f.)
			ZZ5->ZZ5_PRIORI := _cPriori
			msunlock()
		endif

		PRI->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	end

Return

// Incluir um redistribuidor em vários Pré-Pedidos de uma só vez
User Function gjf28Redis()

	Local _aStru   := {}
	Local _aCpoBrw := {}
	Local _lOk     := .F.
	Local oDlg 

	Private lInverte := .F.
	Private cMark    := GetMark()   
	Private oMark
	Private aBtnRedis  := {}

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Código de Redistribuidor")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _cCodRedis   := Space(06)

	PRIVATE nQtdTit		:= 0

	_aCores := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra Listagem dos pre-pedidos para serem selecionados                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Cria um arquivo de apoio
	AADD(_aStru,{"OK"      	, "C"	,2		,0		})
	AADD(_aStru,{"NUMERO"   , "C"	,6		,0		})
	AADD(_aStru,{"STATUS"  	, "C"	,13		,0		})
	AADD(_aStru,{"ORIGEM" 	, "C"	,9		,0		})
	AADD(_aStru,{"MARCA" 	, "C"	,3		,0		})
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

	_aArqTrb := {}
	If Select('TTRB')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TTRB->(dbCloseArea())
		U_ArqTrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TTRB", _aStru, {}, @_aArqTrb)

	// Alimenta o arquivo de apoio com os registros da selecao da query
	cQuery1 := " SELECT *"
	cQuery1 += "   FROM " + RetSQLTab("ZZ4")
	cQuery1 += "  WHERE " + RetSQLFil("ZZ4")
	cQuery1 += "    AND ZZ4_PRECAR = '" + ZZ3->ZZ3_NUM + "'"
	cQuery1 += "    AND ZZ4_STATUS NOT IN('C','E','F','R') "
	cQuery1 += "    AND " + RetSQLDel("ZZ4")
	cQuery1 += " ORDER BY ZZ4_MUN "

	cQuery1 := ChangeQuery(cQuery1)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1), "TRB1", .F., .T.)

	TRB1->(DbGotop())
	While TRB1->(!Eof())
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
		DO CASE
		CASE TRB1->ZZ4_ORIGEM == "E"
			TTRB->ORIGEM := "EDI"
		CASE TRB1->ZZ4_ORIGEM == "P"
			TTRB->ORIGEM := "Portal"
		CASE TRB1->ZZ4_ORIGEM == "D"
			TTRB->ORIGEM := "Digitacao"
		OTHERWISE
			TTRB->STATUS := "Verificar"
		ENDCASE
		TTRB->MARCA  := TRB1->ZZ4_MARCA
		TTRB->DATAP   := STOD(TRB1->ZZ4_DATA)
		TTRB->CLIENTE := TRB1->ZZ4_CODCLI
		TTRB->LOJA    := TRB1->ZZ4_LOJA
		TTRB->NOMECLI := TRB1->ZZ4_NOME
		TTRB->CIDADE  := TRB1->ZZ4_MUN
		TTRB->PRECAR  := TRB1->ZZ4_PRECAR
		TTRB->QTPPESO := TRB1->ZZ4_QPPESO
		TTRB->QTPCAIX := TRB1->ZZ4_QPCAIX
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

		TRB1->(DbSkip())      
	Enddo   		

	TRB1->(DbCloseArea())

	// Define as cores dos itens de legenda
	aCores := {}
	aAdd(aCores,{"TTRB->STATLEG == '1'" , "BR_VERDE"		})
	aAdd(aCores,{"TTRB->STATLEG == '2'" , "BR_VERMELHO"		})

	// Define quais colunas (campos da TTRB) serao exibidas na MsSelect
	_aCpoBrw := {{"OK"		,, "Mark"           		,"@!"	},;
				{"NUMERO"	,, "Numero"   				,"@!"	},;
				{"STATUS"	,, "Status"           		,"@!"	},;
				{"ORIGEM"	,, "Origem"      			,"@!"	},;
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
	DEFINE MSDIALOG oDlg TITLE "Marcar Pré-Pedidos que necessitam de Redistribuição" From 9,0 To 500,900 PIXEL

	@ 033 , 010 Say OemToAnsi("Quantidade Pré-Pedidos Marcados:") PIXEl OF oDlg
	@ 033 , 110 Say oQtda VAR nQtdTit Picture "@E 99999" SIZE 50,8 PIXEl OF oDlg

	DbSelectArea("TTRB")
	DbGotop()

	// Cria a MsSelect
	oMark := MsSelect():New("TTRB","OK","",_aCpoBrw,@lInverte,@cMark,{43,2,238,450},,,,,aCores)
	oMark:bMark := {| | _Disp(oQtda)}

	Aadd( aBtnRedis, {"MARCATODOS", {|| MarkAll(1)}, "Marca Todos", "Marca Todos" , {|| .T.}} )   
	Aadd( aBtnRedis, {"DESMARCTDS", {|| MarkAll(2)}, "Desmarca Todos", "Desmarca Todos" , {|| .T.}} )   
	// Exibe a Dialog

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||_lOk := .T., oDlg:End()},{||_lOk := .F., oDlg:End()},,@aBtnRedis)

	If _lOk
		//Altera o valor "Redistribuic" de "2 - Não" para "1 - Sim"
		ZZ4->ZZ4_REDIST := "1"

		DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(150), C(450) PIXEL
		@ C(005), C(010) SAY "INFORME CÓDIGO DO REDISTRIBUIDOR"	   		Size C(300), C(12) FONT _oFtArial34 COLOR CLR_HRED 	PIXEL OF _oTela
		
		@ C(030), C(010) SAY "Redistribuidor"                            	   		Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
		@ C(030), C(080) MSGET _cCodRedis Valid NaoVazio() .And. _VldCod() F3 "SA4"  Size C(055), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

		DEFINE SBUTTON FROM C(050), C(150) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (AuxRedis(.T.), _oTela:End())
		DEFINE SBUTTON FROM C(050), C(175) TYPE 2 OBJECT _oCancel ENABLE OF _oTela	ACTION (AuxRedis(.F.), _oTela:End())

		ACTIVATE MSDIALOG _oTela CENTERED
	Endif

	// Fecha a Area e elimina os arquivos de apoio criados em disco.
	_aArqTrb := {}
	TTRB->(DbCloseArea())

	U_ArqTrb("FechaTodos",,,, @_aArqTrb)

Return

Static Function AuxRedis(_bOk)

	If _bOk
		TTRB->(dbGoTop())
		While TTRB->(!Eof())
			If TTRB->STATLEG = "2"
				DbSelectArea("ZZ4")
				DbSetOrder(2)
				MsSeek(FWxFilial("ZZ4") + TTRB->NUMERO)
				If Found()
					RecLock("ZZ4",.F.)
					ZZ4->ZZ4_REDIST := "1"
					ZZ4->ZZ4_REDIS := _cCodRedis
					MsUnlock()
				Endif	
			Endif
			TTRB->(DbSkip())
		Enddo
		MsgAlert("Alteração Realizada com Sucesso.")
	Else
		MsgAlert("Cancelado pelo Operador. Nenhuma Alteração Será Realizada.")
	Endif

Return

// Incluir data de producao inicial e final nos produtos dos pre-pedidos.
User Function gjf28DtProd()

	Local _aStru   := {}
	Local _aCpoBrw := {}
	Local _lOk     := .F.
	Local oDlg

	Private lInverte := .F.
	Private cMark    := GetMark()   
	Private oMark
	Private aBtnRedis  := {}

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Data de Produção")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _cCodRedis   := Space(06)

	PRIVATE nQtdTit		:= 0

	Private campoA := stod('')
	Private campoB := stod('')
	Private Valor1 := stod('')
	Private Valor2 := stod('')

	_aCores := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra Listagem dos pre-pedidos para serem selecionados                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Cria um arquivo de apoio
	AADD(_aStru,{"OK"      	, "C"	,2		,0		})
	AADD(_aStru,{"NUMERO"   , "C"	,6		,0		})
	AADD(_aStru,{"STATUS"  	, "C"	,13		,0		})
	AADD(_aStru,{"ORIGEM" 	, "C"	,9		,0		})
	AADD(_aStru,{"MARCA" 	, "C"	,3		,0		})
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

	_aArqTrb := {}
	If Select('TTRB')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TTRB->(dbCloseArea())
		U_ArqTrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TTRB", _aStru, {}, @_aArqTrb)

	// Alimenta o arquivo de apoio com os registros da selecao da query
	cQuery1 := " SELECT *"
	cQuery1 += "   FROM " + RetSQLTab("ZZ4")
	cQuery1 += "  WHERE " + RetSQLFil("ZZ4")
	cQuery1 += "    AND ZZ4_PRECAR = '" + ZZ3->ZZ3_NUM + "'"
	cQuery1 += "    AND ZZ4_STATUS NOT IN('C','E','F','R') "
	cQuery1 += "    AND " + RetSQLDel("ZZ4")
	cQuery1 += " ORDER BY ZZ4_MUN "

	cQuery1 := ChangeQuery(cQuery1)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1), "TRB1", .F., .T.)

	TRB1->(DbGotop())
	While TRB1->(!Eof())
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
		DO CASE
			CASE TRB1->ZZ4_ORIGEM == "E"
				TTRB->ORIGEM := "EDI"
			CASE TRB1->ZZ4_ORIGEM == "P"
				TTRB->ORIGEM := "Portal"
			CASE TRB1->ZZ4_ORIGEM == "D"
				TTRB->ORIGEM := "Digitacao"
			OTHERWISE
				TTRB->STATUS := "Verificar"
		ENDCASE
		TTRB->MARCA  := TRB1->ZZ4_MARCA
		TTRB->DATAP   := STOD(TRB1->ZZ4_DATA)
		TTRB->CLIENTE := TRB1->ZZ4_CODCLI
		TTRB->LOJA    := TRB1->ZZ4_LOJA
		TTRB->NOMECLI := TRB1->ZZ4_NOME
		TTRB->CIDADE  := TRB1->ZZ4_MUN
		TTRB->PRECAR  := TRB1->ZZ4_PRECAR
		TTRB->QTPPESO := TRB1->ZZ4_QPPESO
		TTRB->QTPCAIX := TRB1->ZZ4_QPCAIX
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

		TRB1->(DbSkip())      
	Enddo   		

	TRB1->(DbCloseArea())

	// Define as cores dos itens de legenda
	aCores := {}
	aAdd(aCores,{"TTRB->STATLEG == '1'" , "BR_VERDE"		})
	aAdd(aCores,{"TTRB->STATLEG == '2'" , "BR_VERMELHO"		})

	// Define quais colunas (campos da TTRB) serao exibidas na MsSelect
	_aCpoBrw := {{"OK"		,, "Mark"           		,"@!"	},;
				{"NUMERO"	,, "Numero"   				,"@!"	},;
				{"STATUS"	,, "Status"           		,"@!"	},;
				{"ORIGEM"	,, "Origem"      			,"@!"	},;
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
	DEFINE MSDIALOG oDlg TITLE "Marcar Pré-Pedidos Para Definir Datas de Produção" From 9,0 To 500,900 PIXEL

	@ 033 , 010 Say OemToAnsi("Quantidade Pré-Pedidos Marcados:") PIXEl OF oDlg
	@ 033 , 110 Say oQtda VAR nQtdTit Picture "@E 99999" SIZE 50,8 PIXEl OF oDlg

	DbSelectArea("TTRB")
	DbGotop()

	// Cria a MsSelect
	oMark := MsSelect():New("TTRB","OK","",_aCpoBrw,@lInverte,@cMark,{43,2,238,450},,,,,aCores)
	oMark:bMark := {| | _Disp(oQtda)}

	Aadd( aBtnRedis, {"MARCATODOS", {|| MarkAll(1)}, "Marca Todos", "Marca Todos" , {|| .T.}} )   
	Aadd( aBtnRedis, {"DESMARCTDS", {|| MarkAll(2)}, "Desmarca Todos", "Desmarca Todos" , {|| .T.}} )   
	// Exibe a Dialog

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||_lOk := .T., oDlg:End()},{||_lOk := .F., oDlg:End()},,@aBtnRedis)

	If _lOk
		DEFINE MSDIALOG _oTela TITLE _cTitulo FROM C(0), C(0) TO C(150), C(450) PIXEL
		@ C(005), C(010) SAY "INFORME DATAS DE PRODUÇÃO"	Size C(300), C(12) FONT _oFtArial34 COLOR CLR_HRED 	PIXEL OF _oTela

		@ C(030), C(010) SAY "Data Produção Inicial:" Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
		@ C(030), C(080) MSGET campoA VAR Valor1 Size C(055), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela
		@ C(045), C(010) SAY "Data Produção Final:"   Size C(100), C(10) FONT _oFtArial24 COLOR CLR_GREEN	PIXEL OF _oTela
		@ C(045), C(080) MSGET campoB VAR Valor2 Size C(055), C(10) FONT _oFCourier  COLOR CLR_GREEN	PIXEL OF _oTela

		//@ 04,08 MSGET campoE VAR valor5 SIZE 30,10  OF telaimp  picture '99/99/99' VALID !Vazio()//Data de Abate

		DEFINE SBUTTON FROM C(065), C(150) TYPE 1 OBJECT _oConfir ENABLE OF _oTela	ACTION (AuxDtProd(.T.), _oTela:End())
		DEFINE SBUTTON FROM C(065), C(175) TYPE 2 OBJECT _oCancel ENABLE OF _oTela	ACTION (AuxDtProd(.F.), _oTela:End())

		ACTIVATE MSDIALOG _oTela CENTERED
	Endif

	// Fecha a Area e elimina os arquivos de apoio criados em disco.
	_aArqTrb := {}
	TTRB->(DbCloseArea())

	U_ArqTrb("FechaTodos",,,, @_aArqTrb)

Return

Static Function AuxDtProd(_bOk)

	Local _cEmpresa := FWCodEmp()

	If _bOk
		TTRB->(dbGoTop())
		While TTRB->(!Eof())
			If TTRB->STATLEG = "2"
				DbSelectArea("ZZ4")
				ZZ4->(DbSetOrder(2))
				ZZ4->(MsSeek(FWxFilial("ZZ4") + TTRB->NUMERO))
				If Found()
					ZZ5->(DbSetOrder(1))
					ZZ5->(MsSeek(FWxFilial("ZZ5") + TTRB->NUMERO))
					While ZZ5->(!Eof()) .AND. ZZ5->ZZ5_NUM == TTRB->NUMERO
						RecLock("ZZ5",.F.)
						ZZ5->ZZ5_DTPINI := Valor1
						ZZ5->ZZ5_DTPFIM := Valor2
						MsUnlock()

						//função que realiza a limpeza das datas de produção selecionadas
						IF (_cEmpresa == '01')
							u_mitfs003(ZZ5->ZZ5_COD,ZZ5->ZZ5_QPCAIX,M->ZZ4_NUM,M->ZZ4_AUTDTP)
						ENDIF

						if !empty(ZZ5->ZZ5_DTPINI) .and. !empty(ZZ5->ZZ5_DTPFIM)
							//função que separa as caixas que possuem intervalo de data de produção
							u_mitfs002(ZZ5->ZZ5_COD, ZZ5->ZZ5_ITEM, ZZ5->(RECNO()),ZZ5->ZZ5_QPCAIX,ZZ4->ZZ4_NUM,ZZ4->ZZ4_AUTDTP,ZZ5->ZZ5_DTPINI,ZZ5->ZZ5_DTPFIM)							  
						endif

						ZZ5->(DbSkip())
					Enddo
					
				Endif
			Endif
			TTRB->(DbSkip())
		Enddo
		MsgAlert("Alteração Realizada com Sucesso.")
	Else
		MsgAlert("Cancelado pelo Operador. Nenhuma Alteração Será Realizada.")
	Endif

Return

Static Function markAll(_opc)

	TTRB->(dbgotop())   

	while TTRB->(!eof())                               
		reclock('TTRB',.f.)    
				
		If _opc = 1 
			TTRB->OK 	  := cMark
			TTRB->STATLEG := "2"
			nQtdTit++
		Else
			TTRB->OK 	  := ""
			TTRB->STATLEG := "1"
			nQtdTit--
		Endif
		msunlock()
		TTRB->(dbskip())
	enddo      

	TTRB->(dbgotop())   

	oMark:oBrowse:Refresh()

return .t.

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

Static Function _VldCod()
_lRet := .T.

DbSelectArea("SA4")
DbSetOrder(1)
MsSeek(FWxFilial("SA4") + _cCodRedis)
If !Found()
	MsgAlert("Código do Redistribuidor Não Encontrado no Cadastro. Verifique!!!")
    _lRet := .F.
ELSE
	_lRet := .T.
Endif

Return(_lRet)

//Exclusão de Pré-Pedidos de venda
User Function gjf28Excl(cAlias,nReg,nOpc)

	Local oDlg		:= NIL
	Local aButtons	:= {}
	Local _cUsrf9   := getmv('SI_USRF9')

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	if !empty(ZZ4->ZZ4_PRECAR)
		ZZ3->(DbSetOrder(2))
		ZZ3->(MsSeek(FWxfilial('ZZ3')+ZZ4->ZZ4_PRECAR))
	endif

	if ZZ4->ZZ4_STATUS == 'C' .or. ZZ4->ZZ4_STATUS == 'E' .or. ;
	ZZ4->ZZ4_STATUS == 'S' .or. ZZ4->ZZ4_STATUS == 'F' .or. ;
	ZZ4->ZZ4_STATUS == 'R'                            //Verifica o status do PP para exclusão
		Help(" ",1,'OPERAÇÃO NEGADA!',,'Status não permite exclusão de Pré-Pedido!',4,1)
		return .f.
	endif

	if ZZ3->ZZ3_STPCK $ 'P/S/L' .and. ZZ3->ZZ3_ISRESU = "N"
		FWAlertError('Carregamento já foi liberado! Para liberá-lo novamente contate o Matheus!','OPERAÇÃO NEGADA!')
		Return
	else
		if ZZ3->ZZ3_LIBPCK = "S" .and. ZZ3->ZZ3_ISRESU = "N"
			FWAlertError('Carregamento já foi liberado! Para liberá-lo novamente contate o Matheus!','OPERAÇÃO NEGADA!')
			Return
		endif
	endif

	// ------------ INICIO TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION
	/*
	_cUsuarios := GetMv('MV_MENCOM')
	_cCodUser  := RetCodUsr()

	If U_BLQ_FUS(ZZ4->ZZ4_PRECAR)
		If AllTrim(_cCodUser) $ _cUsuarios
			If FWAlertYesNo("Deseja realizar a Exclusão ?","Já Existe Sequenciamento na Fusion para este Pré-Pedido.")
				_xRet := U_PSW_LIB(ZZ4->ZZ4_NUM, 2)		// Passo 2 no segundo parâmetro quando informado pré-pedido no primeiro parâmetro
				If !_xRet
					Return .F.
				EndIf
			Else
				Return .F.
			EndIf
		Else
			FWAlertError("Não é permitido manutenção neste pré-pedido.","Já Existe Sequenciamento na Fusion para este Pré-Pedido.")
			Return .F.
		EndIf
	EndIf
	*/
	// ------------ FINAL TRATAMENTO BLOQUEIO APÓS TER SIDO SEQUENCIADO NA FUSION

	
	/*if ZZ3->ZZ3_ISRESU == 'S'
		
		if !(RetCodUsr()$_cUsrf9)

			cQry := " SELECT ZZ5_SOLPRO"
			cQry += " FROM " +retSqlTab('ZZ5') + "(NOLOCK)"
			cQry += " WHERE " +retSqlFil('ZZ5')
			cQry += " AND ZZ5_NUM = '"+ZZ4->ZZ4_NUM+"'"
			cQry += " AND ZZ5_SOLPRO = 'S'"
			cQry += " AND " +retSqlDel('ZZ5')
			
			(cAlias)->(dbGoTop())

			//verifica se houve retorno na query
			Count to nCount
				
			If nCount > 0
				Help(" ",1,'OPERAÇÃO NEGADA!',,'Atenção, carregamento selecionado como resumo e com solicitação de produção (F9) já realizado, impossível realizar exclusão!',4,1)
				
				(cAlias)->(dbCloseArea())
				return
			endif

			(cAlias)->(dbCloseArea())
		endif
	endif*/

	if ZZ4->ZZ4_SIBLQL = '2'//se já estiver liberado pelo financeiro verifica se ja foi inciiado o picking
		if !empty(ZZ4->ZZ4_PRECAR)//verifica se o carregamento já foi informado no pre-carregamento
			ZZ3->(dbSetOrder(2))
			ZZ3->(dbGoTop())
			if ZZ3->(MsSeek(FWxFilial('ZZ3') + ZZ4->ZZ4_PRECAR))
				if ZZ3->ZZ3_STPCK $ 'P/S'
					FWAlertError('Separação das caixas do carregamento já iniciada e cliente liberado pelo Financeiro!','OPERAÇÃO NEGADA!')
					return
				endif
			endif
		endif
	endif	

	ZZ5->(dbgotop())
	ZZ5->(dbsetorder(1))
	if ZZ5->(Msseek(FWxfilial('ZZ5')+alltrim(ZZ4->ZZ4_NUM)))
		while ZZ5->(!eof()) .and. alltrim(ZZ5->ZZ5_NUM) == alltrim(ZZ4->ZZ4_NUM) .and.;
		ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5')         //Esse laço serve para verificar se algum

			if ZZ5->ZZ5_QRCAIX <> 0 .or. ZZ5->ZZ5_QRPESO <> 0                      //pré-pedido já teve seu carregamento iniciado
				Help(" ",1,'CARREGAMENTO JÁ INICIADO!',,'Status não permite exclusão de Pré-Pedido!',4,1)
				return
			endif
			ZZ5->(dbskip())
		enddo
	endif

	DbSelectArea(cAlias)

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	RegToMemory("ZZ4")

	EnChoice( "ZZ4" ,ZZ4->(RECNO()), nOpc, , , , , aPosObj[1], , 3 )
	gjf28Ahead("ZZ5")

	nUsado	:= Len(aHeader)                                                           //Monta o aHeader

	gjf28Acols(nOpc)                                                                  //Monta o Acols

	oGet:= MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],;
	nOpc,"AllwaysTrue","AllwaysTrue","+ZZ5_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf28Dele(),oDlg:End()},{||oDlg:End()}, , aButtons)

	buscaTotal(ZZ4->ZZ4_PRECAR)

Return

/*/{Protheus.doc} buscaTotal
	Função para buscar o total de peso e caixas de um carregamento para popular a ZZ3
	@type Function
	@author Adonai
	@since 26/03/2024
	@param [_cPrecar], character, String com o número de pré-carregamento
/*/
Static Function buscaTotal(_cPrecar)

	_cQuery := "SELECT ZZ3_NUM AS CARGA, SUM(ZZ5_QPPESO) AS PESOT, SUM(ZZ5_QPCAIX) AS CAIXAS"
    _cQuery += " FROM " + retSqlTab('ZZ3') + " (NOLOCK)"
    _cQuery += " INNER JOIN " + retSqlTab('ZZ4') + " (NOLOCK) ON (ZZ3_NUM = ZZ4_PRECAR)"
    _cQuery += " INNER JOIN " + retSqlTab('ZZ5') + " (NOLOCK) ON (ZZ4_NUM = ZZ5_NUM)"
    _cQuery += " WHERE " + retSqlFil('ZZ3') + " AND " + retSqlFil('ZZ4') + " AND " + retSqlFil('ZZ5')
    _cQuery += " AND ZZ3_NUM = '" + _cPrecar + "'"
	_cQuery += " AND " + retSqlDel('ZZ3') + " AND " + retSqlDel('ZZ4') + " AND " + retSqlDel('ZZ5')
    _cQuery += " GROUP BY ZZ3_NUM"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TOT") != 0
		TOT->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TOT"

	TOT->(dbGoTop())

	ZZ3->(dbsetorder(2))
	if ZZ3->(Msseek(FWxfilial('ZZ3')+TOT->CARGA))
		reclock('ZZ3',.f.)
		ZZ3->ZZ3_TOTAL := TOT->PESOT
		ZZ3->ZZ3_TOTCAI := TOT->CAIXAS
		msunlock()
	endif

Return

//Encerra o Pré-Pedido de venda
user function gjf28enc()

	if cEmpAnt <> '01'
		Help(" ",1,'OPERAÇÃO INVALIDA!',,'Rotina inválida para esta empresa',4,1)
		return
	endif

	if ZZ4->ZZ4_STATUS == 'C' .or. ZZ4->ZZ4_STATUS == 'F' .or. ZZ4->ZZ4_STATUS == 'R'
		Help(" ",1,'OPERAÇÃO NEGADA!',,'Status impede encerramento do Pré-Pedido!',4,1)
		return
	endif

	if APMSGNOYES('Confirma encerramento de Pré-Pedido?','ATENÇÃO')                  //Confirmação do encerramento
		u_gjf28CRes(ZZ4->ZZ4_NUM)
		begin transaction
			reclock('ZZ4',.f.)
			ZZ4->ZZ4_STATUS := 'E'
			msunlock()
		end transaction
	endif

return

//Montagem do aCols
static Function gjf28Acols(nOpc)
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
		MsSeek(FWxFilial('ZZ5')+ZZ4->ZZ4_NUM,.T.)

		Do While ZZ5->(!Eof()) .and. FWxFilial('ZZ5') ==  ZZ5->ZZ5_FILIAL .and. ZZ5->ZZ5_NUM == ZZ4->ZZ4_NUM
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

//Monta oa aHeader
Static Function gjf28Ahead(cAlias)

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

	_cAlias  := cAlias 		// ZZ5
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) 				 .And. ;
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

//Grava cabecalho e itens
Static Function gjf28Grav(nOpc)

	Local nIt
	Local nCont
	Local nNumItem
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                                       	// Indica se todas as gravacoes obtiveram sucesso
	Local _cEmpresa 	:= FWCodEmp()
	Local _cPreCar 		:= ""
	Local _nTotal		:= 0

	Begin Transaction

		DbSelectArea("ZZ4")
		DbSetOrder(1)
		If INCLUI
			//Se a opção foi de incluir registros, faz isso
			RecLock("ZZ4",.T.)
		Else                                                             //Senão...
			RecLock("ZZ4",.F.)
		Endif

		For nCont := 1 To FCount()

			If "FILIAL"$Field(nCont)
				FieldPut(nCont,FWxFilial("ZZ4"))
			Else
				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
			Endif

		Next nCont

		MsUnLock()

		_cPrecar := M->ZZ4_PRECAR

		DbSelectArea("ZZ5")
		DbSetOrder(1)

		nNumItem := 1  // Contador para os Itens
		qCaixa  := 0
		qPeso   := 0
		_nTotal := 0.00
		_nBoni  := 0.00
		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If MsSeek(FWxFilial("ZZ5") + M->ZZ4_NUM + StrZero(nIt,3))
					//Função que cancela as reservas de caixas
					//quando um item de um pre-pedido é excluído
					u_gjf28CX()
					//u_zeraDatas(_codProd,_nQpCaix,_cPreped,_cAuto)
					//função que realiza a limpeza das datas de produção selecionadas
					IF (_cEmpresa == '01')
						u_mitfs003(ZZ5->ZZ5_COD,ZZ5->ZZ5_QPCAIX,M->ZZ4_NUM,M->ZZ4_AUTDTP)
					ENDIF
					RecLock("ZZ5",.F.)
					DbDelete()
					MsUnlock()
				Endif
			Endif
		Next

		_lTpP := .f.
		_lTpD := .f.

		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If ALTERA
					If MsSeek(FWxFilial("ZZ5")+ M->ZZ4_NUM + StrZero(nIt,3))
						RecLock("ZZ5",.F.)
					Else
						RecLock("ZZ5",.T.)
					Endif
				Else
					RecLock("ZZ5",.T.)
				Endif

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
						ZZ5->(FieldPut(FieldPos(allTrim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				ZZ5->ZZ5_FILIAL	 := FWxFilial("ZZ5")
				ZZ5->ZZ5_NUM	 := ZZ4->ZZ4_NUM                           //Atribui o numero do PP ao item
				ZZ5->ZZ5_ITEM    := strzero(nNumItem,3)
				IF (_cEmpresa == '01')
					ZZ5->ZZ5_PRECAR := _cPrecar
				ENDIF

				if ALTERA
					ZZ5->ZZ5_USERAL := cUserName							//Grava o nome do usuario
					ZZ5->ZZ5_DATAAL := DATE()
					ZZ5->ZZ5_HORAAL := TIME()
				else
					ZZ5->ZZ5_USERIN  := cUserName							//Grava o nome do usuario
					ZZ5->ZZ5_DATAAL := DATE()
					ZZ5->ZZ5_HORAAL := TIME()
				endif
				nNumItem++
				qCaixa += ZZ5->ZZ5_QPCAIX                                  //Calcula o somatorio de caixas do PP
				qPeso +=  ZZ5->ZZ5_QPPESO                                  //Calcula o somatorio de pesos
				MsUnlock()

				//função que realiza a limpeza das datas de produção selecionadas
				IF (_cEmpresa == '01')
					u_mitfs003(ZZ5->ZZ5_COD,ZZ5->ZZ5_QPCAIX,ZZ4->ZZ4_NUM,ZZ4->ZZ4_AUTDTP)
				ENDIF

				if !empty(ZZ5->ZZ5_DTPINI) .and. !empty(ZZ5->ZZ5_DTPFIM)
					//função que separa as caixas que possuem intervalo de data de produção
					u_mitfs002(ZZ5->ZZ5_COD, ZZ5->ZZ5_ITEM, ZZ5->(RECNO()),ZZ5->ZZ5_QPCAIX,ZZ4->ZZ4_NUM,ZZ4->ZZ4_AUTDTP,ZZ5->ZZ5_DTPINI,ZZ5->ZZ5_DTPFIM)
				endif

				_grp := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+ZZ5->ZZ5_COD,1)
				if substr(_grp,1,2) = '56'
					_lTpP := .t.
				else
					_lTpD := .t.
				endif
				DbSelectArea('ZZ5')
			Endif
		Next nIt

		RecLock("ZZ4",.F.)
		ZZ4->ZZ4_QPCAIX  := qCaixa                                         //Grava os somatorios no cabeçalho do PP
		ZZ4->ZZ4_QPPESO  := qPeso
		ZZ4->ZZ4_TIPOPR  := iif(_lTpP .and. _lTpD,'',iif(_lTpD,'D','P'))
		ZZ4->ZZ4_STATUS  := 'B'
		MsUnlock()

		buscaTotal(ZZ4->ZZ4_PRECAR)

		//if FunName() = 'GJF28'
		//	ZZ3->(dbSetOrder(2))
		//	ZZ3->(dbGoTOp())
		//	if ZZ3->(MsSeek(FWxFilial('ZZ3') + ZZ4->ZZ4_PRECAR))
		//		reclock('ZZ3',.f.)
		//		ZZ3->ZZ3_STPCK := 'L'
		//		msunlock()
		//	endif
		//endif

	End Transaction

Return lGraOk

/*/{Protheus.doc} ChkDtEmp
	Função para buscar o total de caixas não empenhadas
	@type Function
	@author Adonai
	@since 02/04/2024
	@param [_cCod], character, String com o código do produto
	@param [_cDtIni], character, String com a data inicial do pedido
	@param [_cDtFim], character, String com a data final do pedido
/*/
User Function ChkDtEmp(_cCod, _cDtIni, _cDtFim, _cPreped, _nTotal)

	//Local _nTotal := 0

	_cQuery1 := "SELECT COUNT(Z8_CONTROL) AS CXSZ8"
	_cQuery1 += " FROM " + RetSQLTab('SZ8') + " (NOLOCK)"
	_cQuery1 += " INNER JOIN " + RetSQLTab('SB1') + " (NOLOCK) ON (Z8_COD = B1_COD)"
	_cQuery1 += " WHERE " + RetSQLFil('SZ8') + " AND Z8_FIL = '" + cFilAnt + "'"
	_cQuery1 += " AND " + RetSQLFil('SB1')
	_cQuery1 += " AND Z8_COD = '" + alltrim(_cCod) + "'"
	_cQuery1 += " AND Z8_DATAP BETWEEN '" + dtos(_cDtIni) + "' AND '" + dtos(_cDtFim) + "'"
	_cQuery1 += " AND (Z8_AUTOPED = '" + _cPreped + "' OR Z8_AUTOPED = '')"
	_cQuery1 += " AND Z8_DATAS = ''"
	_cQuery1 += " AND B1_SEGUM <> 'PC' AND "
	_cQuery1 += RetSQLDel('SZ8') + " AND " + RetSQLDel('SB1')

	/*_cQuery2 := "SELECT SUM(ZZ5_QPCAIX) AS CXZZ5"
	_cQuery2 += " FROM " + RetSQLTab('ZZ4') + " (NOLOCK)"
	_cQuery2 += " INNER JOIN " + RetSQLTab('ZZ5') + " (NOLOCK) ON (ZZ4_NUM = ZZ5_NUM)"
	_cQuery2 += " INNER JOIN " + RetSQLTab('SB1') + " (NOLOCK) ON (ZZ5_COD = B1_COD)"
	_cQuery2 += " WHERE " + RetSQLFil('ZZ4')
	_cQuery2 += " AND " + RetSQLFil('ZZ5')
	_cQuery2 += " AND " + RetSQLFil('SB1')
	_cQuery2 += " AND ZZ5_DTPINI BETWEEN '" + _cDtIni + "' AND '" + _cDtFim + "'"
	_cQuery2 += " AND ZZ5_DTPFIM BETWEEN '" + _cDtIni + "' AND '" + _cDtFim + "'"
	_cQuery2 += " AND ZZ5_COD = '" + _cCod + "'"
	_cQuery2 += " AND B1_SEGUM <> 'PC'"
	_cQuery2 += " AND ZZ4_STATUS NOT IN ('E','F')"
	_cQuery2 += " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5') + " AND " + RetSQLDel('SB1')*/

	//cQuery := ChangeQuery(cQuery)

	cAlias1 := GetNextAlias()
	TCQuery _cQuery1 new alias &cAlias1
	(cAlias1)->(dbGoTop())

	/*cAlias2 := GetNextAlias()
	TCQuery _cQuery2 new alias &cAlias2
	(cAlias2)->(dbGoTop())*/

	//_nTotal := (cAlias1)->CXSZ8

	//_nTotal := ChkDtEmp(ZZ5->ZZ5_COD, ZZ5->ZZ5_DTPINI, ZZ5->ZZ5_DTPFIM, ZZ4->ZZ4_NUM)
	if (cAlias1)->CXSZ8 < _nTotal
		FWAlertError("Quantidade solicitada é maior que a já empenhada! Altere o intervalo de data de produção ou diminua a quantidade.", "ERRO")
		Return .F.
	endif

	(cAlias1)->(dbCloseArea())
	//(cAlias2)->(dbCloseArea())

return .T.

//Exclusão dos pré-pedidos de venda
Static Function gjf28Dele()

	Local _cEmpresa := FWCodEmp()

	DbSelectArea("ZZ5")
	ZZ5->(DbSetOrder(1))

	MsSeek(FWxFilial("ZZ5") + ZZ4->ZZ4_NUM,.t.)

	Do While ZZ5->(!Eof()) .and. FWxFilial("ZZ5") == ZZ5->ZZ5_FILIAL .AND. ZZ4->ZZ4_NUM == ZZ5->ZZ5_NUM  // Exclui os itens do PP

		//função que realiza a limpeza das datas de produção selecionadas
		IF (_cEmpresa == '01')
			u_mitfs003(ZZ5->ZZ5_COD,ZZ5->ZZ5_QPCAIX,M->ZZ4_NUM,M->ZZ4_AUTDTP)
		ENDIF

		RecLock("ZZ5",.f.)
		DbDelete()
		MsUnLock()
		ZZ5->(DbSkip())
	Enddo

	DbSelectArea("ZZ4")

	if cEmpAnt = '01'
		u_gjf28CRes(ZZ4->ZZ4_NUM)
	endif

	_cPrecar := ZZ4->ZZ4_PRECAR

	RecLock("ZZ4",.f.)
	DbDelete()
	MsUnLock()

Return

//Testa todo aCols
User Function gjf28TudOk()

	Local lRetorno	:= .T.
	Local nDesc 	:= 0
	Local nTot		:= 0
	Local nX
	Local nI

	if Empty(M->ZZ4_CODCLI) .or. Empty(M->ZZ4_LOJA)
		lRetorno := .F.
		Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
	endif
	If Empty(M->ZZ4_NUM) .or. nTot == Len(aCols)
		lRetorno := .F.
		Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
	EndIf

	If Empty(M->ZZ4_CLASSIF) .and. M->ZZ4_TPOPER = 'E'
		lRetorno := .F.
		Help("Tipo de operação requer apontamento da habilitação! ",1,"OPERCLASSIF")  // Campos obrigatorios
	EndIf

	If INCLUI
		If ZZ4->(MsSeek( FWXFILIAL("ZZ4") + M->ZZ4_NUM) )
			lRetorno := .F.
			Help(" ",1,"JAGRAVADO")  // Campo ja Existe
		Endif
	Endif

	_nTam := Len(aCols)

	for nX := 1 To _nTam

		_ColCod := GDFieldGet('ZZ5_COD',nX)

		For nI := 1 To _nTam
			if (GDFieldGet('ZZ5_COD',nI) = _ColCod) .and. (nI <> nX)
				alert('Itens do Pré-Pedido repetidos!')
				lRetorno := .F.
				exit
			endif
		Next nI

		if GDFieldGet('ZZ5_PRCFIN',nX) <= 0.0 .or. GDFieldGet('ZZ5_PRECO',nX) <= 0.0
			lRetorno := .F.
			FWAlertError("Existem itens sem preço! Por favor, corrija.","ERRO!")
			exit
		endif

	Next nX

	u_gjf85(M->ZZ4_CODCLI,M->ZZ4_LOJA)
	u_gjf85S(M->ZZ4_CODCLI,M->ZZ4_LOJA)

	if !empty(M->ZZ4_PRECAR)
		ZZ3->(DbSetOrder(2))
		if ZZ3->(MsSeek(FWxfilial('ZZ3')+M->ZZ4_PRECAR))
			if M->ZZ4_STATUS = 'C' .or. ZZ3->ZZ3_STATUS = 'E' .or. ZZ3->ZZ3_STATUS = 'F'
				Help(" ",1,'OPERAÇÃO NEGADA!',,'Status do Pré-Carregamento não permite novo Pré-Pedido!',4,1)
				lRetorno := .f.
			endif
		else
			Help(" ",1,'OPERAÇÃO NEGADA!',,'Pré-Carregamento inexistente!',4,1)
			lRetorno := .f.
		endif
	endif

Return lRetorno

//Teste de validação da linha do grid
User Function gjf28LinOk(n,op)

	Local lRetorno 	:= .T.
	Local nPosDel 	:= Len(aHeader) + 1
	Local nCpo
	Local nI
	Local nX
	Private _lValUSA	:= .f.

	if empty(M->ZZ4_CODCLI) .or. empty(M->ZZ4_LOJA)                        //Antes de continuar, o cabeçalho tem que estar
		Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Indique o cliente corretamente!',4,1)
		lRetorno := .F.
	endif

	if  lRetorno
		lRetorno := .F.
		If !aCols[n, nPosDel]                                                  // Verifica se o item foi deletado
			For nCpo := 2 To Len(aHeader)                                      // Ignora o  Item
				If !Empty(aCols[n, nCpo]) .and. ValType(aCols[n, nCpo]) <> "D"
					lRetorno := .T.
				Endif
			Next nCpo
		Else
			lRetorno := .T.
		Endif
	endif

	if lRetorno
		_nTam := Len(aCols)

		for nX := 1 To _nTam

			_ColCod := aCols[nX,1]

			For nI := 1 To _nTam
				if (aCols[nI,1] = _ColCod) .and. (nI <> nX) .and. !aCols[nX, nPosDel] .and. !aCols[nI, nPosDel]
					alert('Itens do Pré-Pedido repetidos!')
					lRetorno := .f.
					exit
				endif
			Next nI

		Next nX
	endif

	if  lRetorno
		QCaix := 0
		QPeso := 0
		RCaix := 0
		RPeso := 0

		ZZ5->(DbSetOrder(1))
		if ZZ5->(MsSeek(FWxfilial('ZZ5')+ M->ZZ4_NUM + StrZero(n,3)))
			QCaix := ZZ5->ZZ5_QPCAIX
			QPeso := ZZ5->ZZ5_QPPESO
			RCaix := ZZ5->ZZ5_QRCAIX
			RPeso := ZZ5->ZZ5_QRPESO
		endif

		_cGrp := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+aCols[n,1],1)

		/* Dia 22/12/20 Solicitado a retirada da regra pelo Rodrigo -  chamado 258 */
		//if ((M->ZZ4_TIPOPR = 'D' .and. '56' $ _cGrp) .or. (M->ZZ4_TIPOPR = 'P' .and. !('56' $ _cGrp))) .and. !aCols[n, nPosDel]			
		//	Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Tipo de produto diverge do tipo de produção!',4,1)
		//	lRetorno := .F.
		//else
			if empty(aCols[n,1])
				Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Produto não informado!',4,1)
				lRetorno := .F.
			else
				if aCols[n,4] = 0 .and. !aCols[n, nPosDel]
					Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Produto sem tabela de preços!',4,1)
					lRetorno := .F.
				else
					if aCols[n,2] = 0 .and. aCols[n,3] = 0 .and. !aCols[n, nPosDel]
						Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Quantidade de produto não informada!',4,1)
						lRetorno := .F.
					else
						if aCols[n,2] < QCaix  .and. RCaix != 0 .and. !aCols[n, nPosDel]
							Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Quantidade de caixas inferior a atual!',4,1)
							lRetorno := .F.
						else
							if aCols[n,3] < QPeso  .and. RPeso != 0   .and. !aCols[n, nPosDel]
								Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Peso inferior ao atual!',4,1)
								lRetorno := .F.
							else
								if aCols[n,9] >=  aCols[n,4] .and. !aCols[n, nPosDel]
									Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Bonificação maior que o preço!',4,1)
									lRetorno := .F.
								else
									if empty(aCols[n,8]) .and. aCols[n,9] <> 0 .and. !aCols[n, nPosDel]
										Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Tipo de Bonificação ou Bonificação em branco!',4,1)
										lRetorno := .F.
									else
										if aCols[n,nPosDel] .and. (RCaix <> 0 .or. RPeso <> 0) //M->ZZ4_STATUS = 'S'
											Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Carregamento do item excluído já iniciado!',4,1)
											lRetorno := .F.
										else
											_cProd    := aCols[n,1]
											_cGrupo   := GetAdvFVal('SB1', 'B1_GRUPO', FWxFilial('SB1') + _cProd, 1)
											_cPorc    := GetAdvFVal('SBM','BM_PORC', FWxFilial('SBM') + _cGrupo, 1)

											//validação para somente o usario Marilia Silva poder alterar produtos porcionados após solicitado
											//if aCols[n,3] <> QPeso .and. !(RetCodUsr()$'000647/000443/000526/000736') .and. !empty(_cPorc) .and. !empty(aCols[n,22])	
											/*Dia 27/02/23 conforme conversa com Rodirgo , precisamos ajustar regra. Vou comentar para que depois ele venha para acertarmos*/
											/*
											if aCols[n,3] <> QPeso .and. !(RetCodUsr()$'000443/000526') .and. !empty(_cPorc) .and. !empty(aCols[n,22])												
												Help(" ",1,'OPERAÇÃO IRREGULAR!',,"Produto porcionado '" + aCols[n,1] +"', Usuario sem permissão para reduzir quantidade!",4,1)
												lRetorno := .F.
											else
												_cProd    := aCols[n,1]
												_cGrupo   := GetAdvFVal('SB1', 1, FWxFilial('SB1') + _cProd, 'B1_GRUPO')
												_cPorc    := GetAdvFVal('SBM', 1, FWxFilial('SBM') + _cGrupo,'BM_PORC')
												//validação para somente o usario Marilia Silva poder excluir produtos porcionados após solicitado
												//if aCols[n,nPosDel] .and. !(RetCodUsr()$'000647/000443') .and. !empty(_cPorc) .and. !empty(aCols[n,22])
												if aCols[n,nPosDel] .and. !(RetCodUsr()$'000443/000526') .and. !empty(_cPorc) .and. !empty(aCols[n,22])
													//msgbox("Produto porcionado '" + aCols[n,1] +"', Usuario sem permissão para excluir o item!",'OPERACAO IRREGULAR!','STOP')
													Help(" ",1,'OPERAÇÃO IRREGULAR!',,"Produto porcionado '" + aCols[n,1] +"', Usuario sem permissão para excluir o item!",4,1)
													lRetorno := .F.
												endif
											endif*/
										endif
									endif
								endif
							endif
						endif
					endif
				endif
			endif
		//endif
	endif

	if lRetorno
		if !empty(M->ZZ4_PRECAR)
			_cStPck := GetAdvFVal('ZZ3','ZZ3_STPCK',FWxFilial('ZZ3') + M->ZZ4_PRECAR,2)
			if _cStPck <> 'B'
				_nPrevisto := pckPrev(M->ZZ4_PRECAR,aCols[n,1])
				_nSeparado := pckSep(M->ZZ4_PRECAR,aCols[n,1])
				if _nSeparado > 0
					if aCols[n,2] > qCaix//_nSeparado == _nPrevisto
						if _nSeparado == _nPrevisto
							Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Produto totalmente separado!',4,1)
							lRetorno := .F.
						endif
					else
						if aCols[n,2] < qCaix //verifica se está reduzindo a quantidade de caixas
							_nCxReduz := qCaix - aCols[n,2]
							_nPrevAtu := _nPrevisto - _nCxReduz
							if _nPrevAtu < _nSeparado
								Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Não é possível reduzir o num. de caixas, quantidade já separada supera quantidade atual!',4,1)
								lRetorno := .F.
							endif
						else
							if aCols[n,nPosDel]//verifica se está sendo excluido
								_nPrevAtu := _nPrevisto - qCaix
								if _nPrevAtu < _nSeparado
									Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Não é possível excluir o item, quantidade já separada supera quantidade atual!',4,1)
									lRetorno := .F.
								endif
							endif
						endif
					endif
				endif
			endif
		endif
	endif

	if lRetorno
		u_gjf28clc()
		u_gjf85(M->ZZ4_CODCLI,M->ZZ4_LOJA)
		u_gjf85S(M->ZZ4_CODCLI,M->ZZ4_LOJA)
	endif

	if _lValUSA
		lRetorno := .F.
	endif

Return lRetorno

//Realiza calculos necessários para serem inseridos no cabeçalho do PP
User Function gjf28clc()
	Local nIt
	QTDCaix := 0
	QTDPeso := 0
	vTotal  := 0
	TGeral  := 0
	nPosDel := Len(aHeader) + 1

	For nIt := 1 To Len(aCols)
		qCaixa  := GDFieldGet('ZZ5_QPCAIX',nIt)
		qPeso   := GDFieldGet('ZZ5_QPPESO',nIt)

		vTotal  := GDFieldGet('ZZ5_QPPESO',nIt) * GDFieldGet('ZZ5_PRCFIN',nIt)

		If !aCols[nIt, nPosDel]
			QTDCaix += qCaixa
			QTDPeso += qPeso
			if M->ZZ4_STATUS != 'E'
				TGeral  += vTotal
			endif
		endif

	Next nIt

	if GetAdvFVal('ZZ3','ZZ3_ISUSA',FWxfilial('ZZ3')+alltrim(M->ZZ4_PRECAR),2) = 'S'
		if QTDCaix > 700
			FWAlertError("Operação irregular! Pedido possui " + alltrim(cValToChar(QTDCaix)) + " itens!", "ERRO!")
			_lValUSA := .t.
		else
			_lValUSA := .f.
		endif
	endif

	M->ZZ4_QPPESO := QTDPeso
	M->ZZ4_QPCAIX := QTDCaix
	M->ZZ4_TOTAL  := TGeral

	oEnc:Refresh()

Return

//Verifica a situação do cliente a abrevia a digitação de codigos
user function gjf28v()
	area := getarea()

	if !empty(M->ZZ4_CODCLI)
		M->ZZ4_CODCLI := padl(alltrim(M->ZZ4_CODCLI),6,'0')
	endif

	if !empty(M->ZZ4_LOJA)
		M->ZZ4_LOJA := padl(alltrim(M->ZZ4_LOJA),2,'0')
	endif

	if empty(M->ZZ4_LOJA)
		return .t.
	endif

	_Cli2  := GetAdvFVal('SA1','A1_SIBLQL',FWxfilial('SA1')+M->ZZ4_CODCLI+M->ZZ4_LOJA,1)
	_Cli   := GetAdvFVal('SA1','A1_MSBLQL',FWxfilial('SA1')+M->ZZ4_CODCLI+M->ZZ4_LOJA,1)
	_Cli3  := GetAdvFVal('SA1','A1_POBLQL',FWxfilial('SA1')+M->ZZ4_CODCLI+M->ZZ4_LOJA,1)

	If SA1->(MsSeek(FWxfilial('SA1')+M->ZZ4_CODCLI+M->ZZ4_LOJA))
		// Ajuste feito para identificar se cliente esta bloqueado 
		//if _Cli2 == '1'
		if _Cli2 == '1' .or. _Cli3 == '1' 
			Help(" ",1,'CADASTRO BLOQUEADO PARA MOVIMENTAÇÃO',,'Impossivel movimentação com esse cadastro. Aponte outra loja ou consulte o setor Financeiro!',4,1)
			return .f.

		endif

		if _Cli == '1'
			//r := 'SITUAÇÃO FINANCEIRA IRREGULAR!'
			M->ZZ4_SIBLQL := '1'
		else
			M->ZZ4_SIBLQL := '2'
			//r := 'SITUAÇÃO FINANCEIRA APROVADA!'
		endif
	else
		Help(" ",1,'CADASTRO NÃO LOCALIZADO',,'Não Existe este cliente e loja cadastrado !',4,1)
		return .f.
	Endif

	If !empty(M->ZZ4_CODCLI) .and. !empty(M->ZZ4_LOJA)
		u_gjf85(M->ZZ4_CODCLI,M->ZZ4_LOJA)
		if !u_GJF85S(M->ZZ4_CODCLI,M->ZZ4_LOJA)
			Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Cliente com título vencido!',4,1)
			M->ZZ4_SITCLI := 'SITUAÇÃO FINANCEIRA IRREGULAR!'
		else
			M->ZZ4_SITCLI := 'SITUAÇÃO FINANCEIRA APROVADA!'
		endif

		// 09/12/22 -> Solicitação de remoção de aviso pelo Rodrigo Abelin
		/*If AllTrim(M->ZZ4_SITCLI) == 'SITUAÇÃO FINANCEIRA IRREGULAR!' .Or. M->ZZ4_LIMCRE == "B"
			U_STI_C410(M->ZZ4_CODCLI,M->ZZ4_LOJA)
		Endif
		*/
		// 09/12/22 -> Solicitação de remoção de aviso pelo Rodrigo Abelin
		/*
		_dVctoLC := GetAdvFVal('SA1', 1, FWxFilial('SA1') + M->ZZ4_CODCLI + M->ZZ4_LOJA, 'A1_VENCLC')
		If Date() > _dVctoLC
			Aviso( "Data Vencimento Limite de Crédito", 'A data de vencimento do limite de crédito do cliente informado expirou. FAVOR SOLICITAR REAVALIÇÃO DO CLIENTE.', {"Fechar"}, 2, )
		Endif
		*/
	Endif

return .t.

User Function gjf28vcl()

	_Cli := u_GJF85S(M->ZZ4_CODCLI,M->ZZ4_LOJA)

	if !_Cli
		r := 'SITUAÇÃO FINANCEIRA IRREGULAR!'
	else
		r := 'SITUAÇÃO FINANCEIRA APROVADA!'
	endif

return r

//Função destinada a buscar o preço do produto na tabela de preços
User Function gjf28tpr()
	prc := 0
	area := getarea()

	cQuery := "SELECT DA1_PRCVEN FROM "+RetSqlName("SA1")+" SA1, "+;
	RetSqlName("DA1")+" DA1," +RetSqlName("DA0")+" DA0" +;
	" WHERE SA1.D_E_L_E_T_ <> '*' " +;
	"  AND DA0.D_E_L_E_T_ <> '*' " +;
	"  AND DA0.DA0_FILIAL = '" + FWxfilial('DA0')+"'"+;
	"  AND DA1.D_E_L_E_T_ <> '*' " +;
	"  AND DA1.DA1_FILIAL = '" + FWxfilial('DA1')+"'"+;
	"  AND DA1.DA1_CODPRO = '" + M->ZZ5_COD +;
	"' AND SA1.A1_COD     = '" + M->ZZ4_CODCLI +;
	"' AND SA1.A1_LOJA    = '" + M->ZZ4_LOJA +;
	"' AND SA1.A1_FILIAL = '" + FWxfilial('SA1')+"'"+;
	"  AND DA0_CODTAB = DA1_CODTAB "+;
	"  AND DA0_CODTAB = A1_TABELA"
	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TPR")<>0
		TPR->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TPR"

	prc := TPR->DA1_PRCVEN

	TPR->(dbclosearea())

	restarea(area)

return prc

//Função destinada a buscar o preço do produto na tabela de preços para o cliente
User Function gf28PrCl()
	prcCli := 0
	area := getarea()

	cQuery2 := "SELECT DA1_PRCCLI FROM "+RetSqlName("SA1")+" SA1, "+;
	RetSqlName("DA1")+" DA1," +RetSqlName("DA0")+" DA0" +;
	" WHERE SA1.D_E_L_E_T_ <> '*' " +;
	"  AND DA0.D_E_L_E_T_ <> '*' " +;
	"  AND DA0.DA0_FILIAL = '" + FWxfilial('DA0')+"'"+;
	"  AND DA1.D_E_L_E_T_ <> '*' " +;
	"  AND DA1.DA1_FILIAL = '" + FWxfilial('DA1')+"'"+;
	"  AND DA1.DA1_CODPRO = '" + M->ZZ5_COD +;
	"' AND SA1.A1_COD     = '" + M->ZZ4_CODCLI +;
	"' AND SA1.A1_LOJA    = '" + M->ZZ4_LOJA +;
	"' AND SA1.A1_FILIAL  = '" + FWxfilial('SA1')+"'"+;
	"  AND DA0_CODTAB = DA1_CODTAB "+;
	"  AND DA0_CODTAB = A1_TABELA"
	cQuery2 := ChangeQuery(cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("PCLI")<>0
		PCLI->(dbCloseArea())
	Endif

	TCQUERY cQuery2 NEW ALIAS "PCLI"

	prcCli := PCLI->DA1_PRCCLI

	PCLI->(dbclosearea())

	restarea(area)

return prcCli

//Função específica para alterar preço do produto alternativo
Static Function PrecAlt()
	prc := 0
	area := getarea()

	cQuery := "SELECT DA1_PRCVEN
	cQuery += " FROM " + RetSqlTab("SA1") + "," + RetSqlTab("DA1")+"," +RetSqlTab("DA0")
	cQuery += " WHERE " + RetSQLFil('DA0') + " AND " + RetSQLFil('DA1') + " AND " + RetSQLFil('SA1')
	cQuery += " AND DA1_CODPRO = '" + GDFieldGet('ZZ5_COD',n) + "'"
	cQuery += " AND A1_COD     = '" + M->ZZ4_CODCLI + "'"
	cQuery += " AND A1_LOJA    = '" + M->ZZ4_LOJA + "'"
	cQuery += " AND DA0_CODTAB = DA1_CODTAB "
	cQuery += " AND DA0_CODTAB = A1_TABELA AND "
	cQuery += RetSQLDel('DA1') + " AND " + RetSQLDel('SA1') + " AND " + RetSQLDel('DA0')
	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TPR")<>0
		TPR->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TPR"

	prc := TPR->DA1_PRCVEN

	TPR->(dbclosearea())

	restarea(area)

return prc

//query para trazer o que será empenhado em pré-pedidos relativos ao produto
user function gjf28qr2()

	if !FWIsInCallStack("u_mitfs005")								  
		area := getarea()
		nPosDel := Len(aHeader) + 1
		_DtPIni := ctod('')
		_DtPFim := ctod('')
		If !aCols[n, nPosDel]
			_pre    := M->ZZ4_NUM
			_prod   := GDFieldGet('ZZ5_COD')
			_DtPIni := GDFieldGet('ZZ5_DTPINI')
			_DtPFim := GDFieldGet('ZZ5_DTPFIM')

			UM := GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+_prod,1)

			if um = 'CX'

				//cQuery6 := "SELECT SUM(ZZ5_QPCAIX) AS QPCAIX"
				cQuery6 := "SELECT *"
				cQuery6 += " FROM "+RetSqlName("ZZ5")+" ZZ5,"
				cQuery6 += RetSqlName("ZZ4")+" ZZ4"
				cQuery6 += " WHERE ZZ5.D_E_L_E_T_ <> '*' "
				cQuery6 += "  AND ZZ4.D_E_L_E_T_ <> '*' "
				cQuery6 += "  AND ZZ4.ZZ4_FILIAL = '" + FWxfilial('ZZ4')+"'"
				cQuery6 += "  AND ZZ5.ZZ5_FILIAL = '" + FWxfilial('ZZ5')+"'"
				cQuery6 += "  AND ZZ5.ZZ5_STATUS <> 'E'
				cQuery6 += "  AND ZZ4.ZZ4_NUM = ZZ5.ZZ5_NUM "
				cQuery6 += "  AND (ZZ4.ZZ4_STATUS <> 'E'"
				cQuery6 += "  AND ZZ4.ZZ4_STATUS <> 'F')"
				cQuery6 += "  AND ZZ4.ZZ4_TPOPER <> 'C'"
				cQuery6 += "  AND (ZZ5.ZZ5_DTPINI >= '" + DTOS(_DtPIni) + "' AND ZZ5.ZZ5_DTPFIM <= '" + DTOS(_DtPFim) + "')"
				cQuery6 += "  AND ZZ5.ZZ5_DTPINI <> '' AND ZZ5.ZZ5_DTPFIM <> '' "
				cQuery6 += "  AND ZZ4.ZZ4_NUM <> '" + _pre + "'"
				cQuery6 += "  AND ZZ5.ZZ5_COD = '" + _prod + "'"
				cQuery6 += "ORDER BY ZZ5_FILIAL, ZZ5_DTPINI"

				cQuery6 := ChangeQuery(cQuery6)

				if Select("QRY6")<>0
					QRY6->(dbCloseArea())
				endif

				TCQUERY cQuery6 NEW ALIAS "QRY6"

				// ------------ Início alteração para mostrar empenhos em 25/04/2022
				//cArq  := CriaTrab( Nil, .F. )       // Cria arquivo temporário

				dbSelectarea('QRY6')

				aStru := {}	//dbStruct()                                                           
				aadd(aStru,{"NUM_PP" , "C",  6,  0,   "" , 'Pré Pedido'     })
				aadd(aStru,{"CODIGO" , "C",  15, 0,   "" , 'Produto'        })
				aadd(aStru,{"DESCRI" , "C",  30, 0,   "" , 'Descricao'      })
				aadd(aStru,{"QTDECX" , "N",  4,  0,   "" , 'Qtde Empenhada' })
				aadd(aStru,{"DTINI"  , "D",  8,  0,   "" , 'Dt Prod. Ini'   })
				aadd(aStru,{"DTFIN"  , "D",  8,  0,   "" , 'Dt Prod. Fin'   })
				aadd(aStru,{"DTALT"  , "D",  8,  0,   "" , 'Dt Alteracao'   }) 
				aadd(aStru,{"USRAL"  , "C",  20, 0,   "" , 'Usuario Alt.'   })

				//dbcreate(cArq,aStru)                                                          
				//If Select("TMPE")!=0                // Se um tmp com alias TMP existir, fecha-o
				//	TMPE->(dbCloseArea())
				//Endif
				// Manda usar o TMP
				//dbUseArea( .T.,,cArq,"TMPE", .F. , .F. )

				_aArqTrb := {}
				If Select('TMPE')<>0                                  //Se um tmp com alias TMP existir, fecha-o
					TMPE->(dbCloseArea())
					U_ArqTrb("FechaTodos",,,, @_aArqTrb)
				Endif

				U_ArqTrb("Cria", "TMPE", aStru, {}, @_aArqTrb)

				_nTotCaix := 0
				QRY6->(dbGoTop())
				While QRY6->(!eof())
					DBSelectArea('TMPE')
					Reclock("TMPE",.T.)
					TMPE->NUM_PP := QRY6->ZZ5_NUM
					TMPE->CODIGO := QRY6->ZZ5_COD
					TMPE->DESCRI := QRY6->ZZ5_DESC
					TMPE->QTDECX := QRY6->ZZ5_QPCAIX
					TMPE->DTINI  := STOD(QRY6->ZZ5_DTPINI)
					TMPE->DTFIN  := STOD(QRY6->ZZ5_DTPFIM)
					TMPE->DTALT  := STOD(QRY6->ZZ5_DATAAL)
					TMPE->USRAL  := QRY6->ZZ5_USERAL  
					MsUnlock()   

					_nTotCaix += QRY6->ZZ5_QPCAIX

					QRY6->(dbskip())   
				EndDo    

				aCampos := {}   

				aadd(aCampos,{"NUM_PP" ,"Pré Pedido"     , "@!" })
				aadd(aCampos,{"CODIGO" ,"Produto" 	     , "@!" })
				aadd(aCampos,{"DESCRI" ,"Descricao"      , "@!" })
				aadd(aCampos,{"QTDECX" ,"Qtde Empenhada" , ""   })
				aadd(aCampos,{"DTINI"  ,"Dt Prod. Ini"   , ""   })
				aadd(aCampos,{"DTFIN"  ,"Dt Prod. Fin"   , ""   })
				aadd(aCampos,{"DTALT"  ,"Dt Alteracao"   , ""   }) 
				aadd(aCampos,{"USRAL"  ,"Usuario Alt."   , ""   })

				TMPE->(dbgotop()) 

				If _nTotCaix > 0
					DEFINE MSDIALOG oCon TITLE 'Consulta Caixas EMPENHADAS' from 00,00 to 400,1100 OF oMainWnd PIXEL

					@ 005,005 To 160,545 Browse "TMPE"  fields aCampos object oiBrowse  
					@ 014,015 say 'Total Caixas EMPENHADAS: ' + transform(_nTotCaix,'@E 999,999')

					@ 175,410 BUTTON 'Sair' SIZE 40,15 ACTION oCon:end() OBJECT oBtn 
					ACTIVATE MSDIALOG oCon
				EndIf

				_aArqTrb := {}
				//TMPE->(dbCloseArea())

				U_ArqTrb("FechaTodos",,,, @_aArqTrb)

				QRY6->(dbCloseArea())
				// Final ------------ alteração para mostrar empenhos em 25/04/2022

				/*
				_EmpFCaix := QRY6->QPCAIX
				
				QRY6->(dbclosearea())

				if _EmpFCaix <> 0
					Help(" ",1,'OPERAÇÃO IRREGULAR!',,'Já existe empenho de ' +transform( _EmpFCaix,'@E 9,999') + ' caixas para o intervalo especificado!',4,1)
				endif
				*/
			endif
		endif

		restarea(area)
	else //esse retorno do gatilho vai para a função u_mitfs005()
			_prod := oMsGetDts:aCols[oMsGetDts:nAt,5]
	endif
return 	_prod

//Função para confirmar inserçao de desconto no PP
Static Function gjf28vd()
	ret := .t.
	if empty(M->ZZ4_DESC)
		return ret
	endif
	if !(APMsgNOYES('Confirma valor total de desconto na operação?','DESCONTO'))
		ret := .f.
	endif
return ret

User Function gjf28m()
	if !empty(M->ZZ4_MARCA)
		M->ZZ4_MARCA := padl(alltrim(M->ZZ4_MARCA),3,'0')
	endif
return .t.

//Função para liberação de cliente
User Function gjf28lCl()

	Local _cNumUser := space(6)
	Local _cCodNum := space(6)

	_cNumUser := alltrim(GetAdvFVal('SX5','X5_DESCRI',FWxfilial('SX5')+'Z7' + alltrim(RetCodUsr()),1))
	if empty(_cNumUser)
		Help(" ",1,'OPERAÇÃO NEGADA!',,'Usuario sem autorização para liberar Cliente!',4,1)
		return
	endif

	_cCodNum := M->ZZ4_NUM

	//if SA1->A1_MSBLQL <> '2'
	reclock('SA1',.f.)
	SA1->A1_MSBLQL := '2'
	msunlock()
	/*
	_Cli := GetAdvFVal('SA1',1,FWxfilial('SA1')+M->ZZ4_CODCLI+M->ZZ4_LOJA,'A1_MSBLQL')
	if _Cli == '1'
	r := 'SITUAÇÃO FINANCEIRA IRREGULAR!'
	else
	r := 'SITUAÇÃO FINANCEIRA APROVADA!'
	endif
	*/
	M->ZZ4_SITCLI :=  'SITUAÇÃO FINANCEIRA APROVADA!'

	DbSelectArea('ZZ4')

	oEnc:Refresh()

	_cLimCre := ZZ4->ZZ4_LIMCRE

	if _cLimCre != 'L'
		_cLimCre := 'L'
		//msgbox('Limite de Crédito para esse Pré-Pedido liberado!','LIBERAÇÃO EFETIVADA','INFO')
		Help(" ",1,'LIBERAÇÃO EFETIVADA',,'Limite de Crédito para esse Pré-Pedido liberado!',4,1)
	endif

	reclock('ZZ4',.f.)
	ZZ4->ZZ4_LIMCRE := _cLimCre
	ZZ4->ZZ4_SIBLQL := '2'
	ZZ4->ZZ4_USLIBF := cUserName
	ZZ4->ZZ4_HRULFI := time()
	ZZ4->ZZ4_DTULFI := date()
	msunlock()

	Help(" ",1,'LIBERAÇÃO EFETIVADA',,'Cliente Liberado',4,1)
return

// Função utilizada para mostrar informações do pedido de forma resumida
// Pedido do Rodrigo para envio de PrintScreens
User Function gjf28orc()
	Local aIPPed := {}
	Local _cCodCli  	:= M->ZZ4_CODCLI
	Local _cNomeCli 	:= M->ZZ4_NOME
	Local _cLoja     	:= M->ZZ4_LOJA
	Local _nTotal     	:= 0.0

	_cQuery := "SELECT ZZ5_COD, ZZ5_DESC, ZZ5_QPCAIX, ZZ5_QPPESO, ZZ5_PRCFIN"
	_cQuery += " FROM  " + RetSQLTab('ZZ5') + " (NOLOCK)"
	_cQuery += " WHERE " + RetSQLFil('ZZ5')
	_cQuery += " AND ZZ5_NUM = '" + M->ZZ4_NUM + "'"
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

User Function gjf28cad()

	private _cConPag  	:= ALLTRIM(SA1->A1_COND)
	private _cVend    	:= GetAdvFVal('SA3','A3_NOME',FWxfilial('SA3')+SA1->A1_VEND,1)
	private _mObs     	:= SA1->A1_OBSCLI
	private _cLimCred 	:= SA1->A1_LC
	private _dLimCred 	:= SA1->A1_VENCLC
	Private _dDTFundacao := SA1->A1_DATAFU
	Private _cEmail		:= SA1->A1_EMAIL
	Private _cTab        := SA1->A1_TABELA
	Private _cDocumen    := SA1->A1_DOCUMEN

	if _lSalv
		return
	else
		_lSalv := .t.
	endif

	@ 116,010 To 425,425 Dialog oDlgC Title "Informações de Cadastro do Cliente"
	//@ 025,005 GET oMemo _mObs Size 200,036 MEMO Object 
	@ 025,005 GET _mObs Size 200,036 MEMO Object oMemo

	@ 001,001 SAY 'Razao Social:    ' + SA1->A1_NOME
	//	@ 005,001 SAY 'Data de Fundação :   ' + dtoc(SA1->A1_DATAFU)
	@ 005,001 SAY 'Data de Fundação :'
	@ 062,065 MSGET _dDTFundaca PICTURE "99/99/99" OF oDlgC PIXEL
	@ 005,015 SAY 'Documentação:    ' + iif(_cDocumen = 'P','Pendente','Em Dia')
	@ 006,001 SAY 'Vendedor:        ' + Alltrim(SA1->A1_VEND) + ' (' + alltrim(_cVend) + ')'
	@ 007,001 SAY 'Cond. Pagto:     '
	@ 090,050 MSGET _cConPag  SIZE 13,08 F3 "SE4" OF oDlgC PIXEL // Alterado por Fabian Maurer dia 09/09/19, para sair letras na condições de pagamentos!!
	//@ 090,050 MSGET _cConPag  PICTURE "@! 999" SIZE 13,08 F3 "SE4" OF oDlgC PIXEL
	@ 007,012 SAY 'Tabela de Preços:'
	@ 090,150 MSGET _cTab  PICTURE "@! 999" SIZE 10,08 F3 "DA0" OF oDlgC PIXEL
	@ 008,001 SAY 'Limite Credito:  '
	@ 103,050 MSGET _cLimCred PICTURE "@E 999,999,999.99"  OF oDlgC PIXEL
	@ 009,001 SAY 'Vencto. Credito: '
	@ 116,050 MSGET _dLimCred PICTURE "99/99/99" OF oDlgC PIXEL
	@ 010,001 SAY 'Ultima Compra:   ' + dtoc(SA1->A1_ULTCOM)
	@ 010,012 SAY 'Data do Vinculo: ' + dtoc(SA1->A1_DTINIV)
	@ 011,001 SAY 'E-mail:          '
	@ 140,027 MSGET _cEmail  SIZE 100,10 OF oDlgC PIXEL

	@ 110,170 BMPBUTTON TYPE 1 ACTION salvar() Object Obtn1
	@ 125,170 BMPBUTTON TYPE 2 ACTION oDlgC:end() Object Obtn2
	Activate Dialog oDlgC CENTERED

	_lSalv := .f.

Return

Static Function Salvar()
	reclock('SA1',.f.)
	SA1->A1_COND   := _cConPag
	SA1->A1_LC     := _cLimCred
	SA1->A1_VENCLC := _dLimCred
	SA1->A1_OBSCLI := _mObs
	SA1->A1_DATAFU := _dDTFundacao
	SA1->A1_EMAIL  := _cEmail
	SA1->A1_TABELA := _cTab
	msunlock()
	oDlgC:end()

Return

User Function gjf28cms() //Função verificadora do valor de comissão do representente

	_nComAtu := GetAdvFVal('SA3','A3_COMIS',FWxfilial('SA3')+M->ZZ4_REPRES,1)

	ret := .t.

	if !msgbox('Deseja realmente alterar comissão?','VALOR DE COMISSÃO ALTERADO!','YESNO')
		ret := .f.
	endif

	//if _nComAtu < M->ZZ4_COMIS
	//	msgbox('Valor apontado da comissão maior que o existente no cadastro','VALOR INCONSISTENTE!','STOP')
	//	ret := .f.
	//endif

return  ret

//Função de gatilho para trazer as comissões
User Function gjf28ven()

	_nComVen := 0.00
	_nComCli := 0.00
	_cSegmAt := ''
	_cX5Des	 := ''

	_cVen     := GetAdvFVal('SA1','A1_VEND',FWxfilial('SA1')+M->(ZZ4_CODCLI+ZZ4_LOJA),1)
	_nComVen  := GetAdvFVal('SA3','A3_COMIS',FWxfilial('SA3')+_cVen,1)
	_nComCli  := GetAdvFVal('SA1','A1_COMIS',FWxfilial('SA1')+M->(ZZ4_CODCLI+ZZ4_LOJA),1)
	_cNRep    := GetAdvFVal('SA3','A3_NOME',FWxfilial('SA3')+_cVen,1)

	if _nComCli = 0
		_nCom := _nComVen
	else
		_nCom := _nComCli
	endif

	M->ZZ4_REPRES := _cVen
	M->ZZ4_NOMREP := _cNRep

	/*  Inclusão das informações no campo  ZZ4_SATIV1 - com código e descrição Dia 16/11 - Flávio 	*/
	_cSegmAt  := GetAdvFVal('SA1','A1_SATIV1',FWxfilial('SA1')+M->(ZZ4_CODCLI+ZZ4_LOJA),1)

	if !empty(_cSegmAt)
		_cX5Des  := GetAdvFVal('SX5','X5_DESCRI',FWxfilial('SX5')+ 'T3' + alltrim(_cSegmAt),1)
	Endif

	M->ZZ4_SATIV1 := alltrim(_cSegmAt) +' - '+ alltrim(_cX5Des)

return _nCom


//Função para reserva de caixas
User Function gjf28rcx()
	aObjects := {}
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	aX    :=aPosObj[1]
	aX[3]        +=60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	Private cCadastro := "Reservas de Caixas para determinado Pre-Pedido"
	Private lInverte  := .f.
	Private cMark     := GetMark()
	Private oMark
	Private aRotinaBKP := {}

	area2 := getarea()

	_cCod  := GDFieldGet('ZZ5_COD')
	_cPreP := M->ZZ4_NUM
	cPerg  := "GJF28R"

	if !pergunte(cPerg,.t.)
		return
	endif

	dbSelectarea('SZ8')
	SZ8->(dbSetOrder(3))

	cQuery := "SELECT Z8_CONTROL AS CONTROL, Z8_COD AS COD, Z8_PESO AS PESO, Z8_RESERVA AS RESERVA,"
	cQuery += "Z8_DESCRI AS DESCRI, Z8_QUANT AS QUANT,Z8_DATAP AS DATAP, Z8_DATAVAL AS DATAVAL, Z8_CLASSIF AS CLASSIF"
	CQUERY += " FROM "  +RetSqlTab("SZ8") + "," + RetSqlTab("SB1")
	cQuery += " WHERE " + RetSQLFil('SZ8') + " AND " + RetSQLFil('SB1')
	cQuery += "   AND B1_MSBLQL = '2'"
	cQuery += "   AND B1_COD = Z8_COD"
	cQuery += "   AND Z8_FIL = '" + cfilAnt + "'"
	cQuery += "   AND Z8_DATAS  = ''"
	cQuery += "   AND Z8_HORAS  = ''"
	cQuery += "   AND Z8_PREPED = ''"
	cQuery += "   AND Z8_ITEM   = ''"
	cQuery += "   AND Z8_PRECAR = ''"
	cQuery += "   AND (Z8_RESERVA = '' OR Z8_RESERVA = '" + _cPreP + "')"
	cQuery += "   AND B1_FAM = '" + mv_par01 + "'"
	cQuery += "   AND B1_COD = '" + _cCod + "'"
	cQuery += " AND " + RetSQLDel('SZ8') + " AND " + RetSQLDel('SB1')
	cQuery += "  ORDER BY Z8_CONTROL"
	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	// @ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	// @ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	// Activate Dialog oDlgMemo

	If Select("RES")<>0
		RES->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "RES"

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	aStru := {}

	AADD(aStru,{"OKAY"      ,"C",02,0 })
	AADD(aStru,{"CONTROL"   ,"C",10,0 })
	AADD(aStru,{"COD"       ,"C",06,0 })
	AADD(aStru,{"DESCRI"    ,"C",20,0 })
	AADD(aStru,{"QUANT"     ,"N",02,0 })
	AADD(aStru,{"PESO"      ,"N",06,2 })
	AADD(aStru,{"DTPROD"    ,"D",08,0 })
	AADD(aStru,{"VALI"      ,"D",08,0 })
	AADD(aStru,{"CLASSIF"   ,"C",02,0 })
	AADD(aStru,{"RESERVA"   ,"C",06,0 })

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	_aArqTrb := {}
	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		U_ArqTrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	//TMP->(dbgotop())
	RES->(dbgotop())
	while RES->(!eof())
		DbSelectAea('TMP')
		reclock('TMP',.t.)
		TMP->CONTROL    := RES->CONTROL
		TMP->COD        := RES->COD
		TMP->DESCRI     := RES->DESCRI
		TMP->QUANT      := RES->QUANT
		TMP->PESO       := RES->PESO
		TMP->DTPROD     := STOD(RES->DATAP)
		TMP->VALI       := STOD(RES->DATAVAL)
		TMP->CLASSIF    := RES->CLASSIF
		TMP->RESERVA    := RES->RESERVA
		msunlock()
		RES->(dbskip())
	enddo

	aCampos := {}
	AADD(aCampos,{"OKAY"      ,, "OK"         ,"@!"   })
	AADD(aCampos,{"CONTROL"   ,, "Cod.Caixa"  ,"@!"   })
	AADD(aCampos,{"COD"       ,, "Cod.Produto","@!"   })
	AADD(aCampos,{"DESCRI"    ,, "Descrição"  ,"@!"   })
	AADD(aCampos,{"QUANT "    ,, "Quant."     ,"@E 999"})
	AADD(aCampos,{"PESO"      ,, "Peso"       ,"@E 999.99"})
	AADD(aCampos,{"DTPROD"    ,, "Data Prod." ,"99/99/9999"})
	AADD(aCampos,{"VALI"      ,, "Dt. Valid." ,"99/99/9999"})
	AADD(aCampos,{"CLASSIF"   ,, "Classif."   ,"@!" })
	AADD(aCampos,{"RESERVA"   ,, "Reserva"    ,"@!" })

	aRotinaBKP := aRotina

	aRotina := {{"Confirmar" ,"u_gjf28ef('"+_cCod+"','"+_cPrep+"')",0,2},;
	{ "Todas"  ,"u_gjf28RT()"    ,0,2}}

	dbselectarea('TMP')

	TMP->(dbgotop())

	DEFINE MSDIALOG oDlg TITLE "Reserva de Caixas de Produto Acabado" From 9,0 To 400,800 PIXEL
	oMark := MsSelect():New("TMP","OKAY","",aCampos,@lInverte,@cMark,{17,1,160,400},,,,,)
	oMark:bMark := {| | Disp()}

	TButton():New(170, 020, "Confirmar"    , oDlg,{|| u_gjf28ef(_cCod,_cPrep) },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 070, "Todas"        , oDlg,{|| u_gjf28RT() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(170, 300, "Sair"         , oDlg,{|| oDlg:end() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED

	If Select('RES')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		RES->(dbCloseArea())
	Endif

	restarea(area2)

	aRotina := aRotinaBKP

	_aArqTrb := {}
	TMP->(dbCloseArea())

	U_ArqTrb("FechaTodos",,,, @_aArqTrb)

return .t.

Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("OKAY")
		TMP->OKAY := cMark
	Else
		TMP->OKAY := ""
	Endif
	msunlock()
	oMark:oBrowse:Refresh()
Return()

User Function gjf28ef(_cCod,_cPrep)
	local _nQTDRes := 0
	local _nQTDPP  := 0
	local i

	TMP->(DbGoTop())
	While TMP->(!Eof())
		if !empty(TMP->OKAY)
			_nQTDRes++
		endif
		TMP->(DbSkip())
	enddo

	for i := 1 to len(aCols)
		if GDFieldGet('ZZ5_COD',i) = _cCod
			_nQTDPP += GDFieldGet('ZZ5_QPCAIX',i)
		endif
	next

	if _nQTDPP < _nQTDRes
		alert('Numero de Caixas reservadas maior que quantidade no Pré-pedido!')
	endif

	TMP->(DbGoTop())
	While TMP->(!Eof())
		SZ8->(DbSetOrder(3))
		if SZ8->(MsSeek(FWxfilial('SZ8')+TMP->CONTROL))
			if !empty(TMP->OKAY)
				reclock('SZ8',.f.)
				SZ8->Z8_RESERVA := _cPreP
				msunlock()
			else
				reclock('SZ8',.f.)
				SZ8->Z8_RESERVA := ''
				msunlock()
			endif
		endif
		TMP->(DbSkip())
	enddo

	oDlg:end()

return .t.

User Function gjf28RT()
	TMP->(DbGoTop())
	While TMP->(!Eof())
		reclock('TMP',.f.)
		TMP->OKAY := cMark
		msunlock()
		TMP->(dbskip())
	enddo
	TMP->(DbGoTop())
return

User Function gjf28an()

	//Local _Peso  := 0
	//Local _Quant := 0
	//Local _Caix  := 0

	Local _cCod  := GDFieldGet('ZZ5_COD')
	Local _cPrep := M->ZZ4_NUM

	cQuery := "SELECT COUNT(Z8_CONTROL) AS CAIX,  SUM(Z8_PESO) AS PESO, "
	cQuery += "SUM(Z8_QUANT) AS QUANT"
	CQUERY += " FROM "  +RetSqlName("SZ8") + " SZ8"
	cQuery += " WHERE SZ8.D_E_L_E_T_ <> '*' AND SZ8.Z8_FILIAL = '" + FWxfilial('SZ8') + "'"
	cQuery += "   AND SZ8.Z8_FIL = '" + FWxfilial('SB1') + "'"
	cQuery += "   AND SZ8.Z8_RESERVA = '" + _cPreP + "'"
	cQuery += "   AND SZ8.Z8_COD = '" + _cCod + "'"
	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP2")<>0
		TMP2->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP2"

//	msgbox('N.Caixas: ' + transform(TMP2->CAIX,'@E 999') + ' | ' + 'Peças: ' +;
//	transform(TMP2->QUANT,'@E 999') + ' | ' + 'Peso: ' +;
//	transform(TMP2->PESO,'@E 999,999.99'),'ANALISE DE RESERVA','INFO')

	Help(" ",1,'ANALISE DE RESERVA',,'N.Caixas: ' + transform(TMP2->CAIX,'@E 999') + ' | ' + 'Peças: ' + transform(TMP2->QUANT,'@E 999') + ' | ' + 'Peso: ' + transform(TMP2->PESO,'@E 999,999.99'),4,1)

	if FunName() = 'GJF28'
		pergunte(cperg,.f.)
	endif
return .t.

User Function gjf28CRes(_cPP)

	_lEnc := .f.

	SZ8->(DbSetOrder(11))
	if SZ8->(MsSeek(FWxfilial('SZ8')+FWxfilial('SB1')+_cPP))
		While SZ8->(!eof()) .and. SZ8->Z8_FIL = FWxfilial('SB1') .and. SZ8->Z8_RESERVA = _cPP
			if empty(SZ8->Z8_DATAS)  .and. empty(SZ8->Z8_HORAS)  .and. ;
			empty(SZ8->Z8_PREPED) .and. empty(SZ8->Z8_PRECAR) .and. ;
			empty(SZ8->Z8_ITEM)
				reclock('SZ8',.f.)
				SZ8->Z8_RESERVA := ''
				msunlock()
				_lEnc := .t.
				SZ8->(MsSeek(FWxfilial('SZ8')+FWxfilial('SB1')+_cPP))
			else
				SZ8->(DbSkip())
			endif
		enddo
	endif

	if _lEnc
		Alert('Caixas reservadas foram liberadas desse Pre-pedido!')
	endif

Return .t.

User Function GJF28ir()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de caixas reservadas para determinado pre-pedido de"
	Local cDesc3         := "venda.                                             "
	//Local cPict          := ""
	Local titulo       	:= "CAIXAS RESERVADAS-PRE-PEDIDO: " + ZZ4->ZZ4_NUM
	Local nLin         	:= 80

	Local Cabec1       	:= "Produto: " + TMP->COD + TMP->DESCRI
	Local Cabec2       	:= " Cod. Caixa   Quant.      Peso     Data Prod.    Data Valid.   Classif.  Reserva"
	//Local imprime      	:= .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 80
	Private Tamanho      := "P"
	Private nomeprog     := "GJF28IR" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	//Private cPerg   		:= "GJF59"
	//Private cbtxt      	:= Space(10)
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF28A" // Coloque aqui o nome do arquivo usado para impressao em disco

	//pergunte(cPerg,.F.)

	wnrel := SetPrint('SZ8',NomeProg, ,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SZ8')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//Local nOrdem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	TMP->(SetRegua(RecCount()))

	TMP->(dbGoTop())

	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 9

	While TMP->(!EOF())

		incregua()

		if TMP->OKAY != 'S'
			TMP->(DbSkip())
			loop
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 79  // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif
		@nlin,01 psay TMP->CONTROL
		@nlin,15 psay transform(TMP->QUANT,'@E 999')
		@nlin,25 psay transform(TMP->PESO,'@E 999.99')
		@nlin,35 psay TMP->DTPROD
		@nlin,50 psay TMP->VALI
		@nlin,65 psay TMP->CLASSIF
		@nlin,73 psay TMP->RESERVA

		nLin++ // Avanca a linha de impressao

		TMP->(dbSkip()) // Avanca o ponteiro do registro no arquivo

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

//Função que cancela as reservas de caixas
//quando um item de um pre-pedido é excluído
User Function gjf28CX()
	//Local _cPr := ''
	SZ8->(DbGoTop())
	SZ8->(DbSetOrder(11))
	if SZ8->(MsSeek(FWxfilial('SZ8')+FWxfilial('SB1')+M->ZZ4_NUM))
		while SZ8->(!eof()) .and. SZ8->Z8_FILIAL = FWxfilial('SZ8') .and.;
		SZ8->Z8_FIL = FWxfilial('SB1') .and.;
		SZ8->Z8_RESERVA = M->ZZ4_NUM
			if SZ8->Z8_COD = ZZ5->ZZ5_COD
				reclock('SZ8',.f.)
				SZ8->Z8_RESERVA := ''
				msunlock()
				SZ8->(MsSeek(FWxfilial('SZ8')+FWxfilial('SB1')+M->ZZ4_NUM))
			else
				SZ8->(DbSkip())
			endif
		enddo
	endif
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

//Função criada para validação de exclusão de linha na rotina de
//alterar pré-pedido
User Function gjf28Vdl()
	local ret    := .t.
	local	RCaix  := 0
	local	RPeso  := 0

	RCaix := GetAdvFVal('ZZ5','ZZ5_QRCAIX',FWxfilial('ZZ5')+M->ZZ4_NUM + StrZero(n,3),1)
	RPeso := GetAdvFVal('ZZ5','ZZ5_QRPESO',FWxfilial('ZZ5')+M->ZZ4_NUM + StrZero(n,3),1)

	if RCaix <> 0 .or. RPeso <> 0
		Help(" ",1,'ITEM PARCIALMENTE ATENDIDO',,'Exclua todas as caixas deste item do carregamento para exclui-lo!',4,1)
		ret := .f.
	endif

Return ret

//Função destinada a "devolver" o pedido para o Portal
//Muda para o Status "P"
User Function gjf28dev()

	if cEmpAnt <> '01'
		Help(" ",1,'OPERAÇÃO INVALIDA!',,'Rotina inválida para esta empresa!',4,1)
		return
	endif

	if ZZ4->ZZ4_ORIGEM <> 'P'
		Help(" ",1,'OPERAÇÃO INVALIDA!',,'A origem do pré-pedido não é do Portal',4,1)
		return
	endif

	if ZZ4->ZZ4_STATUS $ 'F/E/C/S/P/R'
		Help(" ",1,'OPERAÇÃO INVALIDA!',,'Status não permite a operação',4,1)
		return
	endif

	if !msgbox('Desejo REALMENTE devolver ao Portal?'+;
	'"Desejo REALMENTE devolver ao Portal?"','ATENÇÃO','YESNO')
		return
	endif
	reclock('ZZ4',.f.)
	ZZ4->ZZ4_STATUS := 'P'
	ZZ4->ZZ4_PRECAR := ''
	ZZ4->ZZ4_EMAILU  := ''
	msunlock()

	Help(" ",1,'OPERAÇÃO REALIZADA COM SUCESSO!',,'Pré-pedido voltou aos cuidados do Representante Comercial via Portal!',4,1)

return

/*
User Function gjf28PF2(_cPrePed)
ZZ5->(DbSetOrder(1))
ZZ5->(MsSeek(FWxfilial('ZZ5')+_cPrePed))
While ZZ5->(!eof()) .and. ZZ5->(ZZ5_FILIAL+ZZ5_NUM) = FWxfilial('ZZ5')+_cPrePed
reclock('ZZ5',.f.)
ZZ5->ZZ5_PRCFIN := iif(ZZ5_TPBONI = 'A',ZZ5->(ZZ5_PRECO+ZZ5_BONIF),iif(ZZ5_TPBONI = 'D',ZZ5->(ZZ5_PRECO-ZZ5_BONIF),ZZ5->ZZ5_PRECO))
msunlock()
ZZ5->(DbSkip())
enddo

return
*/

//Consulta ao estoque e previsão de produção para verificar a viabilidade do produto
User Function gjf28sld()

	if cEmpAnt <> '01'
		Help(" ",1,'OPERAÇÃO INVALIDA',,'Rotina inválida para esta empresa',4,1)
		return
	endif

	if _lSldFlag
		return
	else
		_lSldFlag := .t.
	endif

	if funName() $ 'GJF30'

		prod := aBrowse2[oBrowse2:nAt,02]
		pre  := ZZ4->ZZ4_NUM

	else

		nPosDel := Len(aHeader) + 1

		area := getarea()
		prod := GDFieldGet('ZZ5_COD')
		pre  := M->ZZ4_NUM
	endif

	UM      := GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1') + prod,1)
	_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1') + prod,1)
	_EmpFCaix := 0
	_cPorc := GetAdvFVal('SBM','BM_PORC',FWxfilial('SBM') + _cGrupo,1)

	if UM $ 'CX/SC' .OR. _cPorc == 'S'
		//query para trazer a validade das caixas
		cQuery4 := "SELECT COUNT(*) AS VALIDADE FROM " + RetSqlTab("SZ8")
		cQuery4 += " WHERE " +  RetSqlFil('SZ8')
		cQuery4 += "  AND Z8_FIL = '" + cFilAnt + "'"
		cQuery4 += "  AND Z8_DATAE = ' '"
		cQuery4 += "  AND Z8_DATAS = ' '"
		cQuery4 += "  AND Z8_ENCONTR <> 'N'" 		
		cQuery4 += "  AND Z8_COD = '" + prod + "'"
		cQuery4 += "  AND Z8_DATAVAL BETWEEN '" + DTOS(ddatabase) + "' AND '" + DTOS(ddatabase+15) + "'"
		cQuery4 += "  AND  " + RetSqlDel("SZ8")

		//query para trazer o que já está em estoque
		cQuery1 := "SELECT COUNT(*) AS ESTCAIX,SUM(SZ8.Z8_PESO) AS ESTPESO FROM " + RetSqlTab("SZ8")
		cQuery1 += " WHERE " +  RetSqlFil('SZ8')
		cQuery1 += "  AND Z8_FIL = '" + cFilAnt + "'"
		cQuery1 += "  AND Z8_DATAE = ' '"
		cQuery1 += "  AND Z8_DATAS = ' '"
		cQuery1 += "  AND Z8_ENCONTR <> 'N'"
		cQuery1 += "  AND Z8_COD = '" + prod + "'"
		cQuery1 += "  AND  " + RetSqlDel("SZ8")

		//query para trazer o que já está em estoque Tf e liberado
		cQuery6 := "SELECT COUNT(*) AS ESTCAIX,SUM(SZ8.Z8_PESO) AS ESTPESO FROM " + RetSqlTab("SZ8")
		cQuery6 += " WHERE " +  RetSqlFil('SZ8')
		cQuery6 += "  AND Z8_FIL = '" + cFilAnt + "'"
		cQuery6 += "  AND Z8_DATAE = ' '"
		cQuery6 += "  AND Z8_DATAS = ' '"
		cQuery6 += "  AND Z8_DATAP <= '"  + dtos(ddatabase-13) + "'"
		cQuery6 += "  AND Z8_TF = 'S'"
		cQuery6 += "  AND Z8_ENCONTR <> 'N'"
		cQuery6 += "  AND Z8_COD = '" + prod + "'"
		cQuery6 += "  AND  " + RetSqlDel("SZ8")

		//query para trazer a previsao de caixas do produto
		cQuery2 := "SELECT ZU_PRIORI AS PRIORI, SUM(ZU_QPCAIX) AS QPCAIX, SUM(ZU_QRCAIX) AS QRCAIX,"
		cQuery2 += " SUM(ZU_QPPESO) AS QPPESO, SUM(ZU_QRPESO) AS QRPESO "
		cQuery2 += " FROM " + RetSqlTab("SZU")
		cQuery2 += " WHERE " +  RetSqlFil('SZU')
		cQuery2 += "  AND ZU_FECHADO = 'N' "
		cQuery2 += "  AND ZU_DTRPRO = '"+ DTOS(ddatabase)+"'"
		cQuery2 += "  AND ZU_COD = '" + prod + "'"
		cQuery2 += "  AND  " + RetSqlDel("SZU")
		cQuery2 += "  GROUP BY ZU_PRIORI"

		//query para trazer o que já está empenhado em pré-pedidos relativo ao produto
		cQuery3 := "SELECT SUM(ZZ5_QPCAIX) AS QPCAIX, SUM(ZZ5_QRCAIX) AS QRCAIX, ZZ4_DATA AS DTEMP, "
		cQuery3 += " SUM(ZZ5_QPPESO) AS QPPESO, SUM(ZZ5_QRPESO) AS QRPESO
		cQuery3 += " FROM " + RetSqlTab("ZZ5") + "," + RetSqlTab("ZZ4")
		cQuery3 += " WHERE " + RetSqlFil('ZZ5') + " AND " + RetSqlFil('ZZ4')
		cQuery3 += "  AND ZZ5_STATUS <> 'E'
		cQuery3 += "  AND ZZ4_NUM = ZZ5_NUM "
		cQuery3 += "  AND (ZZ4_STATUS <> 'E'"
		cQuery3 += "  AND ZZ4_STATUS <> 'P'"
		cQuery3 += "  AND ZZ4_STATUS <> 'F')"
		cQuery3 += "  AND ZZ4_TPOPER <> 'C'"
		cQuery3 += "  AND ZZ4_DATA = '" + DTOS(ddatabase) + "'"
		cQuery3 += "  AND ZZ4_NUM <> '" + pre + "'"
		cQuery3 += "  AND ZZ5_COD = '" + prod + "'"
		cQuery3 += "  AND  " + RetSqlDel("ZZ4")
		cQuery3 += "  AND  " + RetSqlDel("ZZ5")
		cQuery3 += "  GROUP BY ZZ4_DATA"

		//query para trazer o que já está empenhado em pré-pedidos relativo ao produto do dia anterior e amtes do anterior
		cQuery5 := "SELECT SUM(ZZ5_QPCAIX) AS QPCAIX, SUM(ZZ5_QRCAIX) AS QRCAIX,
		cQuery5 += " SUM(ZZ5_QPPESO) AS QPPESO, SUM(ZZ5_QRPESO) AS QRPESO
		cQuery5 += " FROM " + RetSqlTab("ZZ5") + "," + RetSqlTab("ZZ4")
		cQuery5 += " WHERE " + RetSqlFil('ZZ5') + " AND " + RetSqlFil('ZZ4')
		cQuery5 += "  AND ZZ5_STATUS <> 'E'
		cQuery5 += "  AND ZZ4_NUM = ZZ5.ZZ5_NUM "
		cQuery5 += "  AND (ZZ4_STATUS <> 'E'"
		cQuery5 += "  AND ZZ4_STATUS <> 'P'"
		cQuery5 += "  AND ZZ4_STATUS <> 'F')"
		cQuery5 += "  AND ZZ4_TPOPER <> 'C'"
		cQuery5 += "  AND ZZ4_DATA = '" + DTOS(ddatabase-1) + "'"
		cQuery5 += "  AND ZZ4_NUM <> '" + pre + "'"
		cQuery5 += "  AND ZZ5_COD = '" + prod + "'"
		cQuery5 += "  AND " + RetSqlDel("ZZ4")
		cQuery5 += "  AND " + RetSqlDel("ZZ5")

		//query para trazer estoque de produtos alternativos
		cQuery7 := "SELECT ZAL_CODA AS CODA, COUNT(*) AS QUANT,SUM(Z8_PESO) AS PESO "
		cQuery7 += " FROM  " + RetSqlTab("SZ8") + "," + RetSqlTab("ZAL")
		cQuery7 += " WHERE " + RetSqlFil('SZ8') + " AND " + RetSqlFil('ZAL')
		cQuery7 += "  AND Z8_FIL = '" + cFilAnt + "' AND ZAL_FILIAL = '" + cFilAnt + "'"
		cQuery7 += "  AND Z8_COD = ZAL_CODA AND Z8_DATAE = ' '"
		cQuery7 += "  AND Z8_DATAS = ' '"
		cQuery7 += "  AND Z8_ENCONTR <> 'N'"
		cQuery7 += "  AND ZAL_COD = '" + prod + "'"
		cQuery7 += "  AND  " + RetSqlDel("SZ8") + " AND " + RetSqlDel("ZAL")
		cQuery7 += " GROUP BY ZAL_CODA "
		cQuery7 += " ORDER BY ZAL_CODA "

		//	cQuery1 := ChangeQuery(cQuery1)
		cQuery2 := ChangeQuery(cQuery2)
		cQuery3 := ChangeQuery(cQuery3)
		cQuery4 := ChangeQuery(cQuery4)
		cQuery5 := ChangeQuery(cQuery5)
		cQuery6 := ChangeQuery(cQuery6)
		cQuery7 := ChangeQuery(cQuery7)

		//	* Mostrar a consulta */
		//	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		//	@ 055,005 Get cQuery3 Size 250,080 MEMO Object oMemo
		//	Activate Dialog oDlgMemo

		If Select("QRY1")<>0
			QRY1->(dbCloseArea())
		Endif
		If Select("QRY2")<>0
			QRY2->(dbCloseArea())
		Endif
		If Select("QRY3")<>0
			QRY3->(dbCloseArea())
		Endif
		If Select("QRY4")<>0
			QRY4->(dbCloseArea())
		Endif
		If Select("QRY5")<>0
			QRY5->(dbCloseArea())
		Endif
		If Select("QRY6")<>0
			QRY6->(dbCloseArea())
		Endif
		If Select("QRY7")<>0
			QRY7->(dbCloseArea())
		Endif

		If (FunName() $ 'GJF28/GJF26')
			TCQUERY cQuery7 NEW ALIAS "QRY7"

			//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

			aStru := {}
			AADD(aStru,{"OK"      ,"C"	,2		,0	})
			AADD(aStru,{"CODA"    ,"C"	,6		,0	})
			AADD(aStru,{"DESCRI"   ,"C"	,20   ,0	})
			AADD(aStru,{"QUANT"   ,"N"	,4		,0 })
			AADD(aStru,{"PESO"    ,"N", 9		,2	})

			//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
			//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
			//	TMP->(dbCloseArea())
			//Endif
			//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

			_aArqTrb := {}
			If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
				TMP->(dbCloseArea())
				U_ArqTrb("FechaTodos",,,, @_aArqTrb)
			Endif

			U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

			QRY7->(DbGotop())

			_nRegAlt := 0

			while QRY7->(!eof())
				DbSelectArea('TMP')
				reclock('TMP',.t.)
				TMP->CODA    :=  QRY7->CODA
				TMP->DESCRI  :=  GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+QRY7->CODA,1)
				TMP->QUANT   :=  QRY7->QUANT
				TMP->PESO    :=  QRY7->PESO
				msunlock()

				_nRegAlt++

				QRY7->(DbSkip())
			enddo

			QRY7->(dbclosearea())
			TMP->(DbGoTop())

			aCampos := {}

			AADD(aCampos,{"OK"      ,,"OK "       ,"@!" })
			AADD(aCampos,{"CODA"    ,,"Produto"   ,"@!" })
			AADD(aCampos,{"DESCRI"   ,,"Descricao" ,"@!" })
			AADD(aCampos,{"QUANT"   ,,"Quant."    ,"@E 9,999"})
			AADD(aCampos,{"PESO"    ,,"Peso"      ,"@E 999,999.99"})

		EndIf

		TCQUERY cQuery1 NEW ALIAS "QRY1"
		estcx := QRY1->ESTCAIX
		estps := QRY1->ESTPESO
		QRY1->(dbclosearea())
		/*
		SZI->(DbSetOrder(1))
		if SZI->(MsSeek(FWxfilial('SZI')+prod))
		estcx := SZI->ZI_QTCAIX
		estps := SZI->ZI_QTPESO
		endif
		*/
		TCQUERY cQuery6 NEW ALIAS "QRY6"
		estTFcx := QRY6->ESTCAIX
		estTFps := QRY6->ESTPESO
		QRY6->(dbclosearea())

		TCQUERY cQuery2 NEW ALIAS "QRY2"
		prevC := 0
		prevP := 0
		while QRY2->(!eof())
			if QRY2->QRCAIX < QRY2->QPCAIX
				prevC += QRY2->(QPCAIX - QRCAIX)
				prevP += QRY2->(QPPESO - QRPESO)
			endif
			QRY2->(dbskip())
		enddo
		QRY2->(dbclosearea())

		TCQUERY cQuery3 NEW ALIAS "QRY3"
		empC   := 0
		empP   := 0
		_demp  := date()

		if (QRY3->QRCAIX < QRY3->QPCAIX)  .or. (QRY3->QRPESO < QRY3->QPPESO)
			empC   := QRY3->(QPCAIX - QRCAIX)
			empP   := QRY3->(QPPESO - QRPESO)
			_demp  := stod(QRY3->DTEMP)
		endif
		QRY3->(dbclosearea())

		TCQUERY cQuery5 NEW ALIAS "QRY5"
		empantC := 0
		empantP := 0

		if (QRY5->QRCAIX < QRY5->QPCAIX) .or. (QRY5->QRPESO < QRY5->QPPESO)
			empantC := QRY5->(QPCAIX - QRCAIX)
			empantP := QRY5->(QPPESO - QRPESO)
		endif
		QRY5->(dbclosearea())

		TCQUERY cQuery4 NEW ALIAS "QRY4"
		validad := 0
		validad := QRY4->VALIDADE
		QRY4->(dbclosearea())

		if !(FunName() $ 'GJF30')
			restarea(area)
		endif
		qCpc := 0
		qCpp := 0
		QTDc := 0
		QTDp := 0

		if FunName() $ 'GJF30'
			QTDc := aBrowse2[oBrowse2:nAt,03]
			QTDp := aBrowse2[oBrowse2:nAt,04]
		else
			If !aCols[n, nPosDel]
				QTDc := GDFieldGet('ZZ5_QPCAIX')
				QTDp := GDFieldGet('ZZ5_QPPESO')
				qCpc := GetAdvFVal('ZZ5','ZZ5_QRCAIX',FWxfilial('ZZ5') + pre + prod,2)
				qCpp := GetAdvFVal('ZZ5','ZZ5_QRCAIX',FWxfilial('ZZ5') + pre + prod,2)
				QTDc := iif((QTDc - qCpc)<0,0,(QTDc - qCpc))
				QTDp := iif((QTDp - qCpp)<0,0,(QTDp - qCpp))
			endif
		endif

		if  _demp = date()
			saldoC := iif(estTFcx <> 0,(estTFcx + prevC),(estcx + prevC)) - (empC + empantC + QTDc)
			saldoP := iif(estTFps <> 0,(estTFps + prevP),(estps + prevP)) - (empP + empantP + QTDp)
		else
			saldoC := iif(estTFcx <> 0,(estTFcx + prevC),(estcx + prevC)) - empC + empantC
			saldoP := iif(estTFps <> 0,(estTFps + prevP),(estps + prevP)) - empP + empantP
		endif

		//	_cPorc  := GetAdvFVal('SBM',1,FWxfilial('SBM') + _cGrupo,'BM_PORC')

		DEFINE MSDIALOG oSld TITLE 'Posição do Produto' from 000,000 To 400,400 OF oMainWnd PIXEL

		@ 010,070 SAY  'Caixas'        Object oSay1
		@ 010,110 SAY  ' Peso '        Object oSay2
		@ 020,015 SAY  'Estoque:'      Object oSay3
		@ 030,015 SAY  'TF Liberado:'  Object oSay7
		@ 040,015 SAY  'Previsão:'     Object oSay4
		@ 050,015 SAY  'Empenho:'      Object oSay5
		@ 060,015 SAY  'Saldo:'        Object oSay6

		//@ 070,005 SAY  'Produtos Alternativos em estoque:'  Object oSay23

		@ 020,068 SAY  '[          ]'                                     Object oSay7
		@ 020,103 SAY  '[                  ]'                             Object oSay8
		@ 020,070 SAY  transform(estcx,'@E 9,999')                 			Object oSay9
		@ 020,105 SAY  transform(estps ,'@E 999,999.99')           			Object oSay10

		@ 030,068 SAY  '[          ]'                                     Object oSay19
		@ 030,103 SAY  '[                  ]'                             Object oSay20
		@ 030,070 SAY  transform(estTFcx,'@E 9,999') 		              	Object oSay21
		@ 030,105 SAY  transform(estTFps,'@E 999,999.99')                 Object oSay22

		@ 040,068 SAY  '[          ]'                                     Object oSay11
		@ 040,103 SAY  '[                  ]'                             Object oSay12
		@ 040,070 SAY  transform(prevC,'@E 9,999')                 			Object oSay13
		@ 040,105 SAY  transform(prevP,'@E 999,999.99')            			Object oSay14

		@ 050,068 SAY  '[          ]'                                     Object oSay15
		@ 050,103 SAY  '[                  ]'                             Object oSay16
		@ 050,070 SAY  transform(empC + empantC + QTDc,'@E 9,999') 			Object oSay17
		@ 050,105 SAY  transform(empP + empantP + QTDp,'@E 999,999.99')   Object oSay18

		@ 060,068 SAY  '[          ]'                                     Object oSay19
		@ 060,103 SAY  '[                  ]'                             Object oSay20
		@ 060,070 SAY  transform(saldoC,'@E 9,999') 		               	Object oSay21
		@ 060,105 SAY  transform(saldoP,'@E 999,999.99')                  Object oSay22

		@ 075,170 BMPBUTTON TYPE 1 ACTION oSld:end() Object Obtn1

		if !empty(_cPorc) .and. FunName() $ 'GJF28/GJF26'

			oFont    := tFont():New("courier new",,-14,,.t.,,,,)

			_cSolProd := GDFieldGet('ZZ5_SOLPRO')
			_cBtn       := 'Solic./Canc.'
			_cMens1     := iif(_cSolProd = 'S','Cancelar','Solicitar')
			_cConteudo  := iif(_cSolProd = 'S','','S')
			_cUsrSol    := GDFieldGet('ZZ5_USRSOL')
			_dDtSol     := GDFieldGet('ZZ5_DTSPOR')

			oDescri1 := 'Produto Porcionado. ' + _cMens1 + ' produção?'
			oDescri2 := iif(_cSolProd = 'S','Produção solicitada!','Sem solicitação de produção!')

			oSay1 := tSay():New(100,005,{|| oDescri1 },oSld,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)

			// oBtnPorc := TButton():New(120, 075, _cBtn, oSld,{|| SolPorc()},40,020,,,.F.,.T.,.F.,,.F.,,,.F. )		// (DESABILITADO POR SOLICITAÇÃO DA MARÍLIA EM 30/11/2018)

			oSay2 := tSay():New(150,005,{|| oDescri2 },oSld,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,350,30)

		endif

		/*
		if FunName() $ ('GJF28/GJF26')
		if _nRegAlt > 0
		lInverte := .f.
		cMark    := GetMark()
		oMark := MsSelect():New("TMP","OK","",aCampos,@lInverte,@cMark,{080,1,160,200},,,,,)
		oMark:bMark := {| | Disp2()}
		endif
		endif
		*/
		@ 170,005 SAY  'Caixas por vencer em 15 dias: '+ transform(validad,'@E 999,999') Object oSay23

		ACTIVATE MSDIALOG oSld

		if (FunName() $ 'GJF26/GJF28')
			_cMarca := 0

			TMP->(DbGoTop())

			While TMP->(!eof())
				if !empty(TMP->OK)
					_cMarca++
				endif

				TMP->(DbSkip())
			enddo

			if _cMarca > 1
				Help(" ",1,'OPERAÇÃO CANCELADA',,'Mais de um produto marcado!',4,1)
			else

				TMP->(DbGoTop())
				While TMP->(!eof())
					if !empty(TMP->OK)

						GDFieldPut("ZZ5_COD" ,TMP->CODA,n)
						GDFieldPut("ZZ5_DESC",TMP->DESCRI,n)

						_prc := PrecAlt()

						GDFieldPut("ZZ5_TPBONI",'',n)
						GDFieldPut("ZZ5_BONIF",0,n)
						GDFieldPut("ZZ5_PRECO",_prc,n)
						GDFieldPut("ZZ5_PRCFIN",_prc,n)

						exit
					endif
					TMP->(DbSkip())
				enddo

			endif
		endif

	else
		// Peças em estoque
		cQuery1 := "SELECT COUNT(ZAJ_NUM) AS PECAS, SUM(ZAJ_PESO) AS PESO, ZAJ_DESCRI AS DESCRI"
		cQuery1 += " FROM  " + RetSqlTab("ZAJ")
		cQuery1 += " WHERE " + RetSqlFil('ZAJ')
		cQuery1 += " AND ZAJ_DATA BETWEEN '" +iif(prod $ "005016/005018/005020", dtos(date()-21), dtos(date()-20)) + "' AND '" + iif(prod $ "005016/005018/005020", dtos(date()-1), dtos(date())) + "'"
		cQuery1 += " AND ZAJ_DATAS = ' '"
		cQuery1 += " AND ZAJ_HORAS = ' '"
		cQuery1 += " AND ZAJ_COD = '" + prod + "'"
		cQuery1 += " AND " + RetSqlDel("ZAJ")
		cQuery1 += " GROUP BY ZAJ_DESCRI "

		// Peças em estoque e com mais de 1/3 da vida útil
		cQuery2 := "SELECT COUNT(ZAJ_NUM) AS PECAS, SUM(ZAJ_PESO) AS PESO, ZAJ_DESCRI AS DESCRI"
		cQuery2 += " FROM  " + RetSqlTab("ZAJ")
		cQuery2 += " INNER JOIN " + RetSqlTab("SB1") + " (NOLOCK) ON (ZAJ_COD = B1_COD)"
		cQuery2 += " WHERE " + RetSqlFil('ZAJ') + " AND " + RetSqlFil('SB1')
		cQuery2 += " AND ZAJ_DATAS = ' '"
		cQuery2 += " AND ZAJ_HORAS = ' '"
		cQuery2 += " AND ZAJ_DATA >= DATEADD(day, ROUND((B1_VALID/3),0)*-1, GETDATE())"
		cQuery2 += " AND ZAJ_DATA BETWEEN '" + iif(prod $ "005016/005018/005020", dtos(date()-21), dtos(date()-20)) + "' AND '" + iif(prod $ "005016/005018/005020", dtos(date()-1), dtos(date())) + "'"
		cQuery2 += " AND ZAJ_COD = '" + prod + "'"
		cQuery2 += " AND " + RetSqlDel("ZAJ") + " AND " + RetSqlDel("SB1")
		cQuery2 += " GROUP BY ZAJ_DESCRI "

		// Peças empenhadas
		cQuery3 := "SELECT SUM(ZZ5_QRCAIX) AS PECAS, SUM(ZZ5_QRPESO) AS PESO"
		cQuery3 += " FROM " + RetSqlTab("ZZ5")
		cQuery3 += " INNER JOIN " + RetSqlTab("ZZ4") + " (NOLOCK) ON (ZZ4_NUM = ZZ5_NUM)"
		cQuery3 += " WHERE " + RetSqlFil('ZZ5') + " AND " + RetSqlFil('ZZ4')
		cQuery3 += " AND ZZ5_STATUS <> 'E'"
		cQuery3 += " AND (ZZ4_STATUS <> 'E' AND ZZ4_STATUS <> 'P' AND ZZ4_STATUS <> 'F')"
		cQuery3 += " AND ZZ4_TPOPER <> 'C'"
		cQuery3 += " AND ZZ4_DATA = '" + DTOS(ddatabase) + "'"
		cQuery3 += " AND ZZ4_NUM <> '" + pre + "'"
		cQuery3 += " AND ZZ5_COD = '" + prod + "'"
		cQuery3 += " AND " + RetSqlDel("ZZ5") + " AND " + RetSqlDel("ZZ4")

		cQuery1 := ChangeQuery(cQuery1)
		cQuery2 := ChangeQuery(cQuery2)
		cQuery3 := ChangeQuery(cQuery3)

		If Select("QRY1") <> 0
			QRY1->(dbCloseArea())
		Endif
		If Select("QRY2") <> 0
			QRY2->(dbCloseArea())
		Endif
		If Select("QRY3") <> 0
			QRY3->(dbCloseArea())
		Endif

		TCQUERY cQuery1 NEW ALIAS "QRY1"
		cEstPec := QRY1->PECAS
		cEstPes := QRY1->PESO
		QRY1->(dbclosearea())

		TCQUERY cQuery2 NEW ALIAS "QRY2"
		cEstVal := QRY2->PECAS
		cEstPVal := QRY2->PESO
		QRY2->(dbclosearea())

		TCQUERY cQuery3 NEW ALIAS "QRY3"
		cEmpPec := QRY3->PECAS
		cEmpPes := QRY3->PESO
		QRY3->(dbclosearea())

		DEFINE MSDIALOG oSld TITLE 'Posição do Produto' from 000,000 To 400,400 OF oMainWnd PIXEL

		@ 010,070 SAY  'Peças'        Object oSay1
		@ 010,110 SAY  ' Peso '        Object oSay2
		@ 020,015 SAY  'Estoque:'      Object oSay3
		@ 030,015 SAY  '1/3 Validade:'  Object oSay7
		@ 040,015 SAY  'Empenho:'     Object oSay4
		//@ 050,015 SAY  'Empenho:'      Object oSay5
		//@ 060,015 SAY  'Saldo:'        Object oSay6

		//@ 070,005 SAY  'Produtos Alternativos em estoque:'  Object oSay23

		@ 020,068 SAY  '[          ]'                                     Object oSay7
		@ 020,103 SAY  '[                  ]'                             Object oSay8
		@ 020,070 SAY  transform(cEstPec,'@E 9,999')                 			Object oSay9
		@ 020,105 SAY  transform(cEstPes ,'@E 999,999.99')           			Object oSay10

		@ 030,068 SAY  '[          ]'                                     Object oSay19
		@ 030,103 SAY  '[                  ]'                             Object oSay20
		@ 030,070 SAY  transform(cEstVal,'@E 9,999') 		              	Object oSay21
		@ 030,105 SAY  transform(cEstPVal,'@E 999,999.99')                 Object oSay22

		@ 040,068 SAY  '[          ]'                                     Object oSay11
		@ 040,103 SAY  '[                  ]'                             Object oSay12
		@ 040,070 SAY  transform(cEmpPec,'@E 9,999')                 			Object oSay13
		@ 040,105 SAY  transform(cEmpPes,'@E 999,999.99')            			Object oSay14

		/*@ 050,068 SAY  '[          ]'                                     Object oSay15
		@ 050,103 SAY  '[                  ]'                             Object oSay16
		@ 050,070 SAY  transform(empC + empantC + QTDc,'@E 9,999') 			Object oSay17
		@ 050,105 SAY  transform(empP + empantP + QTDp,'@E 999,999.99')   Object oSay18

		@ 060,068 SAY  '[          ]'                                     Object oSay19
		@ 060,103 SAY  '[                  ]'                             Object oSay20
		@ 060,070 SAY  transform(saldoC,'@E 9,999') 		               	Object oSay21
		@ 060,105 SAY  transform(saldoP,'@E 999,999.99')                  Object oSay22*/

		@ 075,170 BMPBUTTON TYPE 1 ACTION oSld:end() Object Obtn1

		ACTIVATE MSDIALOG oSld

	endif

	if !(FunName() $ 'GJF30')
		if FunName() = 'GJF26'
			pergunte(cPerg1,.f.)
		else
			pergunte(cPerg,.f.)
		endif
	endif

	_lSldFlag := .f.

return

//Função para ativar ou desativar o pedido de produção
Static Function SolPorc(_C)

	_cSolProd := GDFieldGet('ZZ5_SOLPRO')
	_X        := iif(_cSolProd = 'S','','S')
	_cUsrSol  := iif(_cSolProd = 'S','',cUserName)
	_dDtSol   := iif(_cSolProd = 'S',stod(''),M->ZZ4_DATA)

	GDfieldPut('ZZ5_SOLPRO',_X)
	GDfieldPut('ZZ5_USRSOL',_cUsrSol)
	GDfieldPut('ZZ5_DTSPOR',_dDtSol)

	if _X = 'S'
		oDescri1 := 'Produto Porcionado. Cancelar produção?'
		oDescri2 := 'Produção solicitada!'
	else
		oDescri1 := 'Produto Porcionado. Solicitar produção?'
		oDescri2 := 'Sem solicitação de produção!'
	endif

	oSay1:SetText(oDescri1)
	oSay2:SetText(oDescri2)
	oSay1:CtrlRefresh()
	oSay2:CtrlRefresh()
	oSld:refresh()
return

Static Function Disp2()

	RecLock("TMP",.F.)
	If Marked("OK")
		TMP->OK := cMark
	Else
		TMP->OK := ""
	Endif

	msunlock()
	oMark:oBrowse:Refresh()

Return

User Function gjf28PF(_cPrePed)
	Local PrecoFinal := 0
	Local _cTPBoni   := GDFieldGet('ZZ5_TPBONI')
	Local _nBonif    := GDFieldGet('ZZ5_BONIF')
	Local _nPreco    := GDFieldGet('ZZ5_PRECO')
	PrecoFinal := iif(_cTPBoni = 'A',_nPreco + _nBonif,iif(_cTPBoni = 'D',_nPreco - _nBonif,_nPreco))
return PrecoFinal

//função para filtro de pre-pedidos empenhados conforme pergunta mv_par07
User Function gjf28E(_cod)
	Local ret := "''"
	ZZ4->(DbSetOrder(10))
	ZZ4->(MsSeek(FWxfilial('ZZ4')+dtos(ddatabase -1),.t.))

	while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4') .and. ZZ4->ZZ4_DATA <= ddatabase + 1

		if  ZZ4->ZZ4_STATUS $ 'E/F/P'
			ZZ4->(DbSkip())
			loop
		endif

		if ZZ4->ZZ4_TPOPER = 'C'
			ZZ4->(DbSkip())
			loop
		endif

		ZZ5->(DbSetOrder(2))
		if ZZ5->(MsSeek(FWxfilial('ZZ5') + ZZ4->ZZ4_NUM + _cod))
			if ZZ5->ZZ5_STATUS <> 'E' .and. (ZZ5->ZZ5_QPCAIX > ZZ5->ZZ5_QRCAIX  .or. ZZ5->ZZ5_QPPESO > ZZ5->ZZ5_QRPESO)
				ret += ",'" + ZZ5->ZZ5_NUM + "'"
			endif
		endif
		ZZ4->(DbSkip())
	enddo

return ret

//Função complementar para verificar posição de cliente
User Function gjf28pos()
	DbSelectArea('SA1')
	DbSetOrder(1)
	SA1->(MsSeek(FWxfilial('SA1')+ZZ4->(ZZ4_CODCLI+ZZ4_LOJA)))

	FC010CON()

	if FunName() = 'GJF28'
		pergunte(cperg,.f.)
	endif

return

//Função complementar para verificar os últimos 10 produtos comprados
User Function gjf28ult()

	SA1->(DbSetOrder(1))
	SA1->(MsSeek(FWxfilial('SA1')+ZZ4->(ZZ4_CODCLI+ZZ4_LOJA)))

	U_FC010LNF()

Return

//Função que define o funcionamento de teclas de atalho
User Function gjf28ke(_oper,_ac)
	if _ac = 'A'
		Do case
			case  _oper = 'V'
			Set Key VK_F6  TO u_gjf28cad()      // Informações de cadastro
			Set Key VK_F7  TO u_gjf28pos()      // Consulta posição do cliente
			Set Key VK_F8  TO u_gjf28lCl()      // Liberar cliente financeiro
			Set Key VK_F9  TO u_gjf28emp()		// Ordem de empenhos de produtos
			Set Key VK_F10 TO u_gjf28sld()      // Consulta saldo de produtos
			Set Key VK_F11 TO u_GJF85C()        // Consulta Credito
			Set Key VK_F12 TO u_GJF108()
			case  _oper = 'I'
			Set Key VK_F9  TO u_gjf28emp()		// Ordem de empenhos de produtos
			Set Key VK_F10 TO u_gjf28sld()      // Consulta saldo de produtos
			Set Key VK_F11 TO u_GJF85C()        // Consulta Credito
			Set Key VK_F12 TO u_GJF108()
			case  _oper = 'A'
			Set Key VK_F6  TO u_gjf28RCX()      // Reserva de caixas
			Set Key VK_F7  TO u_GJF28an()       // Analise reserva
			Set Key VK_F9  TO u_gjf28emp()		// Ordem de empenhos de produtos
			Set Key VK_F10 TO u_gjf28sld()      // Consulta saldo de produtos
			Set Key VK_F11 TO u_GJF85C()        // Consulta Credito
			Set Key VK_F12 TO u_GJF108()
			case  _oper = 'L'
			Set Key VK_F8  TO u_gjf30lib()
			Set Key VK_F9  TO u_gjf28emp()		// Ordem de empenhos de produtos
			Set Key VK_F10 TO u_gjf28sld()   	//Consulta saldo de produtos
			Set Key VK_F11 TO u_GJF85C()        //Consulta Credito
			Set Key VK_F12 TO u_GJF108()
		endcase
	else
		Set Key VK_F6  TO
		Set Key VK_F7  TO
		Set Key VK_F8  TO
		Set Key VK_F9  TO
		Set Key VK_F10 TO
		Set Key VK_F11 TO
		Set Key VK_F12 TO
	endif

return

//Função auxiliar para retorno do status dos pre-pedidos e montar o grid
Static Function RetStatus(_Stt)
	Local ret := iif(_Stt = 'B','Bloqueado',;
	iif(_Stt = 'L','Liberado' ,;
	iif(_Stt = 'E','Encerrado',;
	iif(_Stt = 'C','Carregando...',;
	iif(_Stt = 'S','Em Espera',;
	iif(_Stt = 'F','Faturado',;
	iif(_Stt = 'P','Portal','')))))))
return ret

//Função auxiliar para retorno das cores da legenda
Static Function RetCores(_Stt)
	local ret   := iif(_Stt = 'B', LoadBitmap(GetResources(),'br_azul'),iif(_Stt = 'L',LoadBitmap(GetResources(),'br_verde'),;
	iif(_Stt = 'C', LoadBitmap(GetResources(),'br_amarelo'),iif(_Stt = 'S',LoadBitmap(GetResources(),'br_laranja'),;
	iif(_Stt = 'E', LoadBitmap(GetResources(),'br_vermelho'),iif(_Stt = 'F',LoadBitmap(GetResources(),'br_preto'),;
	iif(_Stt = 'P',LoadBitmap(GetResources(),'br_branco'),'')))))))
return  ret

User Function gjf28emp()

	/*Local aObjects   := {}
	Local aPosObj    := {}
	Local aInfo      := {}
	Local aSizeAut   := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	Local aX     := aPosObj[1]
	aX[3]        += 60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60*/

	//Cabeçalhos das colunas
	Local aHeader  := {'','Pre-Carr.','Numero','Status','Marca','Data','Quantidade','Usuario','Cliente','Loja'}
	//Largura das colunas
	Local aLargCol := {20,     30    ,   30   ,   40   ,  30  ,   30  ,     50     ,    60   ,    80   ,  30  }
	// Vetor com elementos do Browse
	Local aBrowse := {}
	Local cTitle := ""

	if empty(M->ZZ5_COD)
		FWAlertWarning("Por favor, selecione o código a ser pesquisado. (Pressione ENTER)","ATENÇÃO!")
		Return
	elseif GetAdvFVal('SB1','B1_COD',FWxFilial('SB1') + M->ZZ5_COD,1,"ERRO",.T.) = "ERRO"
		FWAlertWarning("Por favor, selecione um código existente para a pesquisa.","ATENÇÃO!")
		Return
	endif

	cTitle := "Empenhos - " + M->ZZ5_COD

	_cQuery := "SELECT ZZ4_PRECAR, ZZ4_NUM, ZZ4_STATUS, ZZ4_MARCA, ZZ4_DATA, ZZ5_COD, ZZ5_QPCAIX, ZZ4_CODCLI, ZZ4_LOJA,"
	_cQuery += " CASE WHEN ZZ4_USAR = '' THEN ZZ5_USERAL ELSE ZZ4_USAR END AS USUARIO,"
	_cQuery += " CASE WHEN ZZ4_PRECAR = '' THEN '------' ELSE ZZ4_PRECAR END AS PRECAR"
	_cQuery += " FROM  " + RetSQLTab('ZZ4') + " (NOLOCK)"
	_cQuery += " INNER JOIN  " + RetSQLTab('ZZ5') + " (NOLOCK) ON (ZZ4_NUM = ZZ5_NUM)"
	_cQuery += " WHERE " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ5')
	_cQuery += " AND (ZZ4_DATA BETWEEN '" + DTOS(ddatabase-7) + "' AND '" + DTOS(ddatabase) + "')"
	_cQuery += " AND ZZ5_COD = '" + M->ZZ5_COD + "'"
	_cQuery += " AND ZZ4_STATUS NOT IN ('F','E')"
	_cQuery += " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5')
	_cQuery += " ORDER BY ZZ4_NUM"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("EMP") != 0
		EMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "EMP"

	while EMP->(!eof())

		_Stt := EMP->ZZ4_STATUS

		aadd(aBrowse,{RetCores(_Stt),EMP->PRECAR,EMP->ZZ4_NUM,RetStatus(_Stt),EMP->ZZ4_MARCA,dtoc(stod(EMP->ZZ4_DATA)),alltrim(transform(EMP->ZZ5_QPCAIX,'@E 999,999')),EMP->USUARIO,;
				alltrim(GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+EMP->ZZ4_CODCLI+EMP->ZZ4_LOJA,1)),EMP->ZZ4_LOJA})

		EMP->(DbSkip())
	enddo

	DEFINE DIALOG oDlgE TITLE cTitle FROM 020,50 To 700,1000 PIXEL
	// Cria Browse
	oBrowse := TCBrowse():New(00,00,480,340,,aHeader,aLargCol,oDlgE,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	// Seta vetor para a browse
	oBrowse:SetArray(aBrowse)

	// Monta a linha a ser exibina no Browse
	if len(aBrowse) <= 0  //verifica se tem algo no vetor para não dar error.log
		oBrowse:bLine := {||{'','','','','','','','','',''}}
	else
		oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03],aBrowse[oBrowse:nAT,04],aBrowse[oBrowse:nAT,05],;
		aBrowse[oBrowse:nAT,06],aBrowse[oBrowse:nAT,07],aBrowse[oBrowse:nAT,08],aBrowse[oBrowse:nAT,09],aBrowse[oBrowse:nAT,10]}}
	endif

	oBrowse:nScrollType := 1

	ACTIVATE DIALOG oDlgE CENTERED

Return

User Function gjf28Con()

	Local aBackRot := aClone(aRotina)

	DbSelectArea("SA1")
	If ( Pergunte("FIC010",.T.) )
		Fc010Con()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura as perguntas originais da rotina            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	pergunte(cPerg,.f.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a integridade dos dados                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRotina := aClone(aBackRot)

Return(Nil)

//Rotina para separação de pré-pedidos
//especialmente desenvolvida para gestão dos
//pre-pedidos para a fábrica de porcionados
User Function gjf28S()

	Local _cNovoNum := GETSX8NUM('ZZ4','ZZ4_NUM')
	Local _cAntNum  := ZZ4->ZZ4_NUM
	Local _lNovoNum := .f.
	Local _nItem    := 0
	Local _aItensNP := {}
	Local i
	Local j

	_cStatus := ZZ4->ZZ4_STATUS
	_cPrecar := ZZ4->ZZ4_PRECAR
	_cOrigem := ZZ4->ZZ4_ORIGEM
	_dData   := ZZ4->ZZ4_DATA
	_cTpOper := ZZ4->ZZ4_TPOPER
	_cCodCli := ZZ4->ZZ4_CODCLI
	_cLoja   := ZZ4->ZZ4_LOJA
	_cNome   := ZZ4->ZZ4_NOME
	_cMun    := ZZ4->ZZ4_MUN
	_cUsar   := ZZ4->ZZ4_USAR
	_nDesc   := ZZ4->ZZ4_DESC
	_cRepres := ZZ4->ZZ4_REPRES
	_cNomRep := ZZ4->ZZ4_NOMREP
	_nComis  := ZZ4->ZZ4_COMIS
	_dEnt    := ZZ4->ZZ4_DTENT
	_cHrEnt  := ZZ4->ZZ4_HRENT
	_cSiBlql	:= ZZ4->ZZ4_SIBLQL
	_cRedist := ZZ4->ZZ4_REDIST
	_cLimCre	:= ZZ4->ZZ4_LIMCRE
	_cCreVig := ZZ4->ZZ4_CREVIG

	if ZZ4->ZZ4_STATUS $ 'BP'

		if empty(ZZ4->ZZ4_TIPOPR)

			reclock('ZZ4',.f.)
			ZZ4->ZZ4_TIPOPR := 'D'
			msunlock()

			ZZ5->(DbSetOrder(1))
			if ZZ5->(MsSeek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
				While ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM
					DbSelectArea('SB1')
					_cGrp := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+ZZ5->ZZ5_COD,1)

					if '56' $ _cGrp
						if  !_lNovoNum
							ConfirmSX8()
							_lNovoNum := .t.

						endif

						_nItem++

						aadd(_aItensNP,{ZZ5->ZZ5_ITEM,_cNovoNum,strzero(_nItem,3),ZZ5->ZZ5_STATUS,ZZ5->ZZ5_COD,ZZ5->ZZ5_QPCAIX,ZZ5->ZZ5_QPPESO,;
						ZZ5->ZZ5_PRECO,ZZ5->ZZ5_PRIORI,ZZ5->ZZ5_TOLERA,ZZ5->ZZ5_DESC,ZZ5->ZZ5_USERIN,ZZ5->ZZ5_TPBONI,ZZ5->ZZ5_BONIF,;
						ZZ5->ZZ5_PRCFIN,ZZ5->ZZ5_OBS,ZZ5->ZZ5_RESERV,ZZ5->ZZ5_SLDPOR,ZZ5->ZZ5_SOLPRO})
					endif

					ZZ5->(DbSkip())
				enddo
			endif

			//////////BLOCO PARA AJUSTE DO PRE-PEDIDO ANTIGO
			//Laço que apaga os itens do pedido antigo
			ZZ5->(DbSetOrder(1))
			for i := 1 to len(_aItenNP)
				if ZZ5->(MsSeek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM + _aItensNP[i,1]))
					reclock('ZZ5',.f.)
					DbDelete()
					msunlock()
				endif
			next

			//Refaz totais e sequenciais dos itens do pedido antigo
			ZZ5->(DbGoTop())
			if ZZ5->(MsSeek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
				_nItem := 0
				QTDCaix := 0
				QTDPeso := 0
				vTotal  := 0
				TGeral  := 0
				While ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM

					_nItem++

					qCaixa  := ZZ5->ZZ5_QPCAIX
					qPeso   := ZZ5->ZZ5_QPPESO
					if ZZ5->ZZ5_TPBONI = 'D'
						vTotal  := ZZ5->ZZ5_QPPESO * (ZZ5->ZZ5_PRECO - ZZ5->ZZ5_BONIF)
					elseif ZZ5->ZZ5_TPBONIF = 'A'
						vTotal  := ZZ5->ZZ5_QPPESO * (ZZ5->ZZ5_PRECO + ZZ5->ZZ5_BONIF)
					else
						vTotal  := ZZ5->ZZ5_QPPESO * ZZ5->ZZ5_PRECO
					endif

					QTDCaix += qCaixa
					QTDPeso += qPeso
					if ZZ4->ZZ4_STATUS != 'E'
						TGeral  += vTotal
					endif

					reclock('ZZ5',.f.)
					ZZ5->ZZ5_ITEM := strzero(_nItem,3)
					msunlock()

					ZZ5->(DbSkip())
				enddo
			endif

			reclock('ZZ4',.f.)
			ZZ4->ZZ4_QPPESO := QTDPeso
			ZZ4->ZZ4_QPCAIX := QTDCaix
			ZZ4->ZZ4_TOTAL  := TGeral
			msunlock()

			/////FIM DO BLOCO DE AJUSTE DO PRE-PEDIDO ANTIGO/////
		else
			alert('Não há pre-pedidos a serem separados!')
		endif

		//////BLOCO PARA GERAÇÃO DO NOVO PRE-PEDIDO////////
		if _lnovoNum
			reclock('ZZ4',.t.)
			ZZ4->ZZ4_FILIAL := FWxfilial('ZZ4')
			ZZ4->ZZ4_NUM    := _cNovoNum
			ZZ4->ZZ4_STATUS := _cStatus
			ZZ4->ZZ4_PRECAR := _cPrecar
			ZZ4->ZZ4_ORIGEM := _cOrigem
			ZZ4->ZZ4_DATA   := _dData
			ZZ4->ZZ4_TPOPER := _cTpOper
			ZZ4->ZZ4_CODCLI := _cCodCli
			ZZ4->ZZ4_LOJA   := _cLoja
			ZZ4->ZZ4_NOME   := _cNome
			ZZ4->ZZ4_MUN    := _cMun
			ZZ4->ZZ4_USAR   := _cUsar
			ZZ4->ZZ4_DESC   := _nDesc
			ZZ4->ZZ4_REPRES := _cRepres
			ZZ4->ZZ4_NOMREP := _cNomRep
			ZZ4->ZZ4_COMIS  := _nComis
			ZZ4->ZZ4_DTENT  := _dEnt
			ZZ4->ZZ4_HRENT  := _cHrEnt
			ZZ4->ZZ4_SIBLQL := _cSiBlql
			ZZ4->ZZ4_REDIST := _cRedist
			ZZ4->ZZ4_TIPOPR := 'P'
			ZZ4->ZZ4_LIMCRE := _cLimCre
			ZZ4->ZZ4_CREVIG := _cCreVig
			msunlock()

			for j := 1 to len(_aItensNP)
				reclock('ZZ5',.t.)
				ZZ5->ZZ5_FILIAL := FWxfilial('ZZ5')
				ZZ5->ZZ5_NUM    := _cNovoNum
				ZZ5->ZZ5_ITEM   := _aItensNP[j,03]
				ZZ5->ZZ5_STATUS := _aItensNP[j,04]
				ZZ5->ZZ5_COD    := _aItensNP[j,05]
				ZZ5->ZZ5_QPCAIX := _aItensNP[j,06]
				ZZ5->ZZ5_QPPESO := _aItensNP[j,07]
				ZZ5->ZZ5_PRECO  := _aItensNP[j,08]
				ZZ5->ZZ5_PRIORI := _aItensNP[j,09]
				ZZ5->ZZ5_TOLERA := _aItensNP[j,10]
				ZZ5->ZZ5_DESC   := _aItensNP[j,11]
				ZZ5->ZZ5_USERIN := _aItensNP[j,12]
				ZZ5->ZZ5_TPBONI := _aItensNP[j,13]
				ZZ5->ZZ5_BONIF  := _aItensNP[j,14]
				ZZ5->ZZ5_PRCFIN := _aItensNP[j,15]
				ZZ5->ZZ5_OBS    := _aItensNP[j,16]
				ZZ5->ZZ5_RESERV := _aItensNP[j,17]
				ZZ5->ZZ5_SLDPOR := _aItensNP[j,18]
				ZZ5->ZZ5_SOLPRO := _aItensNP[j,19]
				IF (_cEmpresa == '01')
					ZZ5->ZZ5_PRECAR := _cPrecar
				ENDIF
				msunlock()
			next

			RecalcTot(_cNovoNum)
			Help(" ",1,'OPERAÇÃO REALIZADA!',,'Pre-pedidos separados nos códigos ' + _cAntNum + ' e ' + _cNovoNum + '.',4,1)
		endif

	endif

return

// Rotina para flegar os pré-pedidos do respectivo pré-carregamento
// a serem enviados para a Fusion
User Function GJF28F()

	Local _nRecZZ4  := 0
	Local _cPreCarr := ZZ4->ZZ4_PRECAR

	_nRecZZ4 := ZZ4->(Recno())

	If MsgYesNo("Confirma o envio para a Fusion de todos pré-pedidos LIBERADOS ref. pré-carregamento " + _cPreCarr + " ?", "Enviar Fusion")

		ZZ4->(DbSetOrder(1))
		ZZ4->(DbGoTop())
		ZZ4->(MsSeek(FWxFilial("ZZ4") + _cPreCarr))
		While !Eof() .And. ZZ4->ZZ4_FILIAL + ZZ4->ZZ4_PRECAR == FWxFilial("ZZ4") + _cPreCarr

			If Empty(ZZ4->ZZ4_STAFUS) .Or. ZZ4->ZZ4_STAFUS == "1"
				RecLock("ZZ4", .F.)
				ZZ4->ZZ4_STAFUS := "2"
				MsUnlock()
			ElseIf ZZ4->ZZ4_STAFUS == "4"
				RecLock("ZZ4", .F.)
				ZZ4->ZZ4_STAFUS := "2"
				ZZ4->ZZ4_MARCA  := ""
				MsUnlock()
			EndIf

			ZZ4->(DbSkip())
		EndDo

	EndIf

	ZZ4->(dbGoTo(_nRecZZ4))

Return


// Rotina para flegar os pré-pedidos do respectivo pré-carregamento
// a serem cancelados no Fusion após já terem sido sequenciados
User Function GJF28CS()

	Local _nRecZZ4  := 0
	Local _cPreCarr := ZZ4->ZZ4_PRECAR

	_nRecZZ4 := ZZ4->(Recno())

	If MsgYesNo("Confirma o cancelamento na Fusion de todos pré-pedidos JÁ SEQUENCIADOS ref. pré-carregamento " + _cPreCarr + " ?", "Enviar Cancelamento Fusion")

		ZZ4->(DbSetOrder(1))
		ZZ4->(DbGoTop())
		ZZ4->(MsSeek(FWxFilial("ZZ4") + _cPreCarr))
		While !Eof() .And. ZZ4->ZZ4_FILIAL + ZZ4->ZZ4_PRECAR == FWxFilial("ZZ4") + _cPreCarr
			
			If ZZ4->ZZ4_STAFUS == "3"
				RecLock("ZZ4", .F.)
				ZZ4->ZZ4_STAFUS := "4"
				MsUnlock()
			EndIf

			ZZ4->(DbSkip())
		EndDo

	EndIf

	ZZ4->(dbGoTo(_nRecZZ4))

Return


//Função de recalculo dos totais
//que funciona semelhante ao gjf28clc
//será usada no momento da divisão de
//pré-pedidos para gestão da fábrica de
//porcionados
Static Function RecalcTot(_pp)
	QTDCaix := 0
	QTDPeso := 0
	vTotal  := 0
	TGeral  := 0

	ZZ5->(DbSetOrder(1))
	if ZZ5->(MsSeek(FWxfilial('ZZ5')+_pp))
		while ZZ5->(!eof()) .and. FWxFilial('ZZ5') = ZZ5->ZZ5_FILIAL .and. ZZ5->ZZ5_NUM = _pp
			qCaixa  := ZZ5->ZZ5_QPCAIX
			qPeso   := ZZ5->ZZ5_QPPESO
			if ZZ5->ZZ5_TPBONI = 'D'
				vTotal  := ZZ5->ZZ5_QPPESO * (ZZ5->ZZ5_PRECO - ZZ5->ZZ5_BONIF)
			elseif ZZ5->ZZ5_TPBONIF = 'A'
				vTotal  := ZZ5->ZZ5_QPPESO * (ZZ5->ZZ5_PRECO + ZZ5->ZZ5_BONIF)
			else
				vTotal  := ZZ5->ZZ5_QPPESO * ZZ5->ZZ5_PRECO
			endif

			QTDCaix += qCaixa
			QTDPeso += qPeso
			if ZZ4->ZZ4_STATUS != 'E'
				TGeral  += vTotal
			endif
			ZZ5->(DbSkip())
		enddo

		ZZ4->(DbSetOrder(2))
		if ZZ4->(MsSeek(FWxfilial('ZZ4')+_pp))
			reclock('ZZ4',.f.)
			ZZ4->ZZ4_QPPESO := QTDPeso
			ZZ4->ZZ4_QPCAIX := QTDCaix
			ZZ4->ZZ4_TOTAL  := TGeral
			msunlock()
		endif

	endif

Return

//função para solicitação de produção de porcionados
//para todos os produtos
User Function gjf28Sol()
	Local nX
	
	cPerg6 := "GF28SOL"

	if !pergunte(cPerg6,.t.)
		return
	endif

	_nTam := Len(aCols)

	for nX := 1 To _nTam

		_cprod    := GDFieldGet('ZZ5_COD',nX)
		_cGrupo   := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1') + _cprod,1)
		_cPorc    := GetAdvFVal('SBM','BM_PORC',FWxfilial('SBM') + _cGrupo,1)
		_cUserSol := GDFieldGet('ZZ5_USRSOL',nX)
		_dDtSol   := GDFieldGet('ZZ5_DTSPOR',nX)

		if !empty(_cPorc) .and. FunName() $ 'GJF28/GJF26'

			//Solicita Producao?
			if mv_par01 = 1// 1= Sim
				_cSolProd := 'S'
				_cUserSol := cUserName
				_dDtSol   := M->ZZ4_DATA//dDataBase
			else
				_cSolProd := ''
				_cUserSol := ''
				_dDtSol   := stod('')
			endif

			GDfieldPut('ZZ5_SOLPRO',_cSolProd,nX)
			GDfieldPut('ZZ5_USRSOL',_cUserSol,nX)
			GDFieldput('ZZ5_DTSPOR',_dDtSol,nX)
		endif

	Next nX

return

//o que foi previsto para picking no carregamento
Static Function pckPrev(preCarr,_cod)

	_cQuery := " SELECT ZZ5_COD, SUM(ZZ5_QPCAIX) AS PREVISTO"
	_cQuery += " FROM " + retSqlTab('ZZ5') + ", " + retSqlTab('ZZ4') + " , " + retSqlTab('SB1')
	_cQuery += " WHERE " + retSqlFil('ZZ5') + " AND " + retSqlFil('ZZ4') + " AND " + retSqlFil('SB1')
	_cQuery += " AND ZZ4_PRECAR = '" + preCarr + "'
	_cQuery += " AND ZZ5_NUM = ZZ4_NUM AND ZZ5_COD = '" + _cod + "'"
	_cQuery += " AND B1_COD = ZZ5_COD AND B1_SEGUM = 'CX'
	_cQuery += " AND " + retSqlDel('ZZ5') + "  AND " + retSqlDel('ZZ4') +" AND " + retSqlDel('SB1')
	_cQuery += " GROUP BY ZZ5_COD
	_cQuery += " ORDER BY ZZ5_COD
	_cQuery := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbGoTop())

return iif(QRY->PREVISTO > 0, QRY->PREVISTO, 0)

Static Function pckSep(preCarr, _cod)

	_cQuery2 := " SELECT COUNT(Z8_PICKING) AS SEPARADO"
	_cQuery2 += " FROM " + retSqlTab('SZ8')
	_cQuery2 += " WHERE " + retSqlFil('SZ8')
	_cQuery2 += " AND Z8_CARPICK = '" + preCarr + "' AND Z8_FIL = '"+cFilAnt+"'"
	_cQuery2 += " AND Z8_COD = '" + _cod + "' AND Z8_PICKING = 'S'"
	_cQuery2 += " AND " + retSqlDel('SZ8')

	_cQuery2  := ChangeQuery(_cQuery2)

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY2"

	QRY2->(dbGoTop())

return iif(QRY2->SEPARADO > 0, QRY2->SEPARADO, 0)



// Consulta 10 Últimas Notas
User Function gjf28cnf()

	area := getarea()
	Private aRotinaBKP0  := {}

	aRotinaBKP0 := aRotina

	aRotina := {}

	U_STI_C400(M->ZZ4_CODCLI,M->ZZ4_LOJA)

	aRotina := aRotinaBKP0
	restarea(area)

return

/*/{Protheus.doc} User Function mitfs004
	(Função destinada à selecionar "Sim" ou "Não" para os pedidos que necessitam separar datas de produção com 1/3 de validade ou não)
	@type  Function
	@author Mauricio Roehrs
	@since 03/04/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function mitfs004()

	Local _aStru   := {}
	Local _aCpoBrw := {}
	Local _lOk     := .F.
	Local oDlg 

	Private lInverte := .F.
	Private cMark    := GetMark()   
	Private oMark
	Private aBtnRedis  := {}

	Private _oTela, _oCancel, _oConfir
	Private _cTitulo    := OemToAnsi("Data de Produção")
	Private _oFtArial24 := TFont():New ("Arial"      , 10, 24)
	Private _oFtArial30 := TFont():New ("Arial"      , 10, 34)
	Private _oFCourier  := TFont():New ("Courier New",   , 24,,.T.)
	Private _cCodRedis   := Space(06)

	PRIVATE nQtdTit		:= 0

	Private campoA := stod('')
	Private campoB := stod('')
	Private Valor1 := stod('')
	Private Valor2 := stod('')

	_aCores := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra Listagem dos pre-pedidos para serem selecionados                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Cria um arquivo de apoio
	AADD(_aStru,{"OK"      	, "C"	,2		,0		})
	AADD(_aStru,{"NUMERO"   , "C"	,6		,0		})
	AADD(_aStru,{"STATUS"  	, "C"	,13		,0		})
	AADD(_aStru,{"ORIGEM" 	, "C"	,9		,0		})
	AADD(_aStru,{"MARCA" 	, "C"	,3		,0		})
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
	_aArqTrb := {}
	If Select('TTRB')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TTRB->(dbCloseArea())
		U_ArqTrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TTRB", _aStru, {}, @_aArqTrb)

	// Alimenta o arquivo de apoio com os registros da selecao da query
	cQuery1 := " SELECT *"
	cQuery1 += "   FROM " + RetSQLTab("ZZ4")
	cQuery1 += "  WHERE " + RetSQLFil("ZZ4")
	cQuery1 += "    AND ZZ4_PRECAR = '" + ZZ3->ZZ3_NUM + "'"
	cQuery1 += "    AND ZZ4_STATUS NOT IN('C','E','F','R') "
	cQuery1 += "    AND " + RetSQLDel("ZZ4")
	cQuery1 += " ORDER BY ZZ4_MUN "

	cQuery1 := ChangeQuery(cQuery1)

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery1), "TRB1", .F., .T.)

	TRB1->(DbGotop())
	While TRB1->(!Eof())
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
		DO CASE
			CASE TRB1->ZZ4_ORIGEM == "E"
				TTRB->ORIGEM := "EDI"
			CASE TRB1->ZZ4_ORIGEM == "P"
				TTRB->ORIGEM := "Portal"
			CASE TRB1->ZZ4_ORIGEM == "D"
				TTRB->ORIGEM := "Digitacao"
			OTHERWISE
				TTRB->STATUS := "Verificar"
		ENDCASE
		TTRB->MARCA  := TRB1->ZZ4_MARCA
		TTRB->DATAP   := STOD(TRB1->ZZ4_DATA)
		TTRB->CLIENTE := TRB1->ZZ4_CODCLI
		TTRB->LOJA    := TRB1->ZZ4_LOJA
		TTRB->NOMECLI := TRB1->ZZ4_NOME
		TTRB->CIDADE  := TRB1->ZZ4_MUN
		TTRB->PRECAR  := TRB1->ZZ4_PRECAR
		TTRB->QTPPESO := TRB1->ZZ4_QPPESO
		TTRB->QTPCAIX := TRB1->ZZ4_QPCAIX
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

		TRB1->(DbSkip())      
	Enddo   		

	TRB1->(DbCloseArea())

	// Define as cores dos itens de legenda
	aCores := {}
	aAdd(aCores,{"TTRB->STATLEG == '1'" , "BR_VERDE"		})
	aAdd(aCores,{"TTRB->STATLEG == '2'" , "BR_VERMELHO"		})

	// Define quais colunas (campos da TTRB) serao exibidas na MsSelect
	_aCpoBrw := {{"OK"		,, "Mark"           		,"@!"	},;
				{"NUMERO"	,, "Numero"   				,"@!"	},;
				{"STATUS"	,, "Status"           		,"@!"	},;
				{"ORIGEM"	,, "Origem"      			,"@!"	},;
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
	DEFINE MSDIALOG oDlg TITLE "Marcar Pré-Pedidos Para Definir Datas de Produção" From 9,0 To 530,900 PIXEL

	@ 033 , 010 Say OemToAnsi("Quantidade Pré-Pedidos Marcados:") PIXEl OF oDlg
	@ 033 , 110 Say oQtda VAR nQtdTit Picture "@E 99999" SIZE 50,8 PIXEl OF oDlg

	@ 033 , 150 Say OemToAnsi("Dtas de Prod. com 1/3 de Validade?") PIXEl OF oDlg
	nRadio := 2
	aItems := {'Sim','Não'}
	oRadio := TRadMenu():New (33,250,aItems,,oDlg,,,,,,,,100,12,,,,.T.,.T.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}

	DbSelectArea("TTRB")
	DbGotop()

	// Cria a MsSelect
	oMark := MsSelect():New("TTRB","OK","",_aCpoBrw,@lInverte,@cMark,{43,2,238,450},,,,,aCores)
	oMark:bMark := {| | _Disp(oQtda)}

	Aadd( aBtnRedis, {"MARCATODOS", {|| MarkAll(1)}, "Marca Todos", "Marca Todos" , {|| .T.}} )   
	Aadd( aBtnRedis, {"DESMARCTDS", {|| MarkAll(2)}, "Desmarca Todos", "Desmarca Todos" , {|| .T.}} )   
	// Exibe a Dialog

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||_lOk := .T., oDlg:End()},{||_lOk := .F., oDlg:End()},,@aBtnRedis)

	If _lOk
		If msgbox('Tem certeza que deseja realizar o preenchimento automático para os pré-pedidos selecionados?','Automação!','YESNO')
			TTRB->(dbGoTop())
			While TTRB->(!Eof())
				If TTRB->STATLEG = "2"
					DbSelectArea("ZZ4")
					ZZ4->(DbSetOrder(2))
					if ZZ4->(MsSeek(FWxFilial("ZZ4") + TTRB->NUMERO))
						reclock('ZZ4',.f.)
						ZZ4->ZZ4_AUTDTP := iif(nRadio == 1,'S','N')
						ZZ4->(msunlock())
					endif
				Endif
				TTRB->(DbSkip())
			Enddo
			MsgInfo("Alteração Realizada com Sucesso.")
		Else
			MsgAlert("Cancelado pelo Operador. Nenhuma Alteração Será Realizada.")
		Endif
	Endif

	// Fecha a Area e elimina os arquivos de apoio criados em disco.
	//_aArqTrb := {}
	TTRB->(DbCloseArea())

	U_ArqTrb("FechaTodos",,,, @_aArqTrb)

Return

