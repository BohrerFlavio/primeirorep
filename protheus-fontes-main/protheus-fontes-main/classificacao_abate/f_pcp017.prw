#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F_PCP017  ºAutor  ³3v Technology       º Data ³  27/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Producao do Abate                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºTabelas   ³ SZG,SZ4,SZK,SZE,SZD,SE5,SA2,ZAJ,SX5,SB2                    º±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    

User Function F_PCP017()

	private cString := 'SZ4'
	private aRotina :={}
	private cfiltro  := ''
	private lAltera  := .F. 
	private _cIpImp  := ''
	/*
	Parâmetros
	Status? Todos
	Balança? - COM1:4800,e,7,2               
	Decimais? - 1
	Modelo Zebra - S600           
	Porta Zebra - IP
	Imprime costela - Sim
	*/
	aSEXO   := CTBCBOX('ZK_SEXO')
	aObs    := CTBCBOX('ZK_OBS')
	_nImp := 0
	_cSisbov := space(16)
	_cSexo  := space(1)
	nCodigo := space(16)

	aObjects := {}        //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	cPerg := "PCP017"

	/*colocar regra para imprimir por estação */

	_cIpImp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + 'IABT1',1))
	//MsgInfo(_cIpImp, "Impressora")
	
	if empty(_cIpImp)
		alert('Endereço IP da impressora não encontrado!')
		return
	endif

	If !Pergunte(cPerg,.T.)
		Return
	Endif

	SZG->(DbSetOrder(3))                                 
	if  !SZG->(MsSeek(FWxfilial('SZG')+'A'))
		alert('Não há Aviso de Matança com produção aberta!')
		return
	endif

	//	SZG->(dbSetOrder(1))
	//	if !SZG->(MsSeek(FWxFilial('SZG') + '01005720'))
	//		alert('Aviso de matança não encontrado')
	//		return
	//	endif

	_cAM := SZG->ZG_NUMAM

	//Se o modo balança for IP...
	if mv_par07 = 2 .or. mv_par07 = 3

		_cIpBal := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + if(mv_par07 = 2,'BABT1','BABT2'),1))

		if empty(_cIpBal)
			alert('Endereço IP da balança não encontrado!')
			return
		endif

		oObj  := tSocketClient():New()   
		nResp := oObj:Connect( 9092, _cIpBal,1000)
		nResp := oObj:Send( 'Teste' )

	endif

	nModo  := mv_par01                                    //1-aberto 2-fechado 3- parcial 4 todos
	cCom   := mv_par02                                    //comunicaocao balanca (modo serial)
	nDec   := mv_par03                                    //precisao balanca   (modo serial)
	cMod   	:= alltrim(mv_par04)                           //modelo imp zebra
	cPor   := alltrim(mv_par05)                           //porta imp zebra 
	_nImp   := mv_par06 

	cFiltro := " FWxFilial('SZ4') = SZ4->Z4_FILIAL "
	cFiltro += " .and. SZ4->Z4_NUMAM = '" + _cAM + "'"

	do case
		case nmodo == 2
		cFiltro+= " .and. u_PCP017stat()[1] == 1"

		case nmodo == 3
		cFiltro+= " .and. u_PCP017stat()[1] == 2"

		case nmodo == 4
		cFiltro+= " .and. u_PCP017stat()[1] == 3"

	endcase

	bLegenda1 :=  "u_PCP017stat()[1]==1"                                     //verifica  sc incompleta
	bLegenda2 :=  "u_PCP017stat()[1]==2"                                     //verifica  sc completa
	bLegenda3 :=  "u_PCP017stat()[1]==3"                                     //verifica  sc completa
	bLegenda4 :=  "u_PCP017stat()[1]==4"                                     //verifica  sc completa

	aCores := { {bLegenda1, 'BR_VERMELHO'},;           // Aberto
	{bLegenda2, 'BR_VERDE'   },;           // Completo
	{bLegenda3, 'BR_AZUL'    },;           // parcial
	{bLegenda4, 'BR_AMARELO' }}            // parcial IF

	aCores2:= { { 'BR_VERMELHO','Aberto' },;           // Aberto
	{ 'BR_VERDE'   ,'Fechado'},;           // Completo
	{ 'BR_AZUL'    ,'Parcial'},;           // parcial
	{ 'BR_AMARELO' ,'Pendente'}}           // parcial  IF

	aRotina := { {"Pendente"        , "u_pcp017pend", 0, 4},;//{"Atualizar"       , "u_pcp017sele(0)", 0, 4},;
	{"Visualizar"      , "u_pcp017visu", 0, 2},;//{"Ordenar Lote"    , "u_pcp017orde", 0, 2},;
	{"Legenda"         , "u_pcp017lege", 0, 2} }//{"Remover Lote"    , "u_pcp017remo", 0, 4},;
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cCadastro 	:= "Produção do Abate"

	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to &cfiltro
	dbgotop()

	mBrowse( 6, 1, 22, 75,cString,,,,,1,acores)

	dbSelectArea(cString)
	Set Filter to

	_lStat := .t.

	SZ4->(DbSetOrder(1))
	SZ4->(MsSeek(FWxfilial('SZ4')+_cAM))

	while  SZ4->(!eof()) .and. FWxfilial('SZ4') = SZ4->Z4_FILIAL .and. SZ4->Z4_NUMAM = _cAM

		if u_PCP017stat()[1]<>2
			_lStat := .f.
		endif

		SZ4->(DbSkip())
	enddo

	if _lStat
		SZG->(DbSetOrder(1))
		SZG->(MsSeek(FWxfilial('SZG')+_cAM)) 

		reclock('SZG',.f.)
		SZG->ZG_STATUS := 'E'	
		msunlock()           

		u_gjf233(_cAM)

	endif

	//Se o modo balança for IP...
	if mv_par07 = 2 .or. mv_par07 = 3
		oObj:CloseConnection()
	endif

return


User Function PCP017remo()
	If SZ4->Z4_QTREAL <> 0
		Alert('Não é possivel remover lote, produção em andamento')
		return
	Endif

	If !ApmsgYESNO('Remove Lote:' + SZ4->Z4_LOTE + ' Aviso: '+ SZ4->Z4_NUMAM  ,'Confirme Remoção do lote?')
		Return
	Endif

	Begin Transaction

		SZK->(DBsetorder(2))

		Do While SZK->(MsSeek(FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)))
			reclock('SZK',.f.)
			SZK->(dbDelete())
			msunlock()
		EndDo

		SZE->(DBsetorder(2))

		SZE->(MsSeek(FWxFilial('SZE')+SZ4->(Z4_NUMAM+Z4_LOTE),.f.))

		Do While SZE->(!eof()) .and. SZE->(ZE_FILIAL+ZE_NUMAM+ZE_LOTE) == SZ4->(Z4_FILIAL+Z4_NUMAM+Z4_LOTE)
			reclock('SZE',.f.)
			SZE->ZE_NUMAM := ''
			SZE->ZE_LOTE  := ''
			msunlock()
			SZE->(Dbskip())
		EndDo

		reclock('SZ4',.f.)
		SZ4->(DbDelete())
		msunlock()

	End Transaction

Return


User Function PCP017des()

	Reclock('SZK',.F.)

	M->ZK_OBS     := "7"
	M->ZK_CLASABA := 'NE'
	M->ZK_TIPIF   := ""

	MsUnlock()

	classifica()

Return


User Function PCP017visu()

	laltera := .F.  // para poder alterar campos

	Private cChave := FWxFilial('SZK')
	Private aArea   := GetArea()
	Private aRotina := {{"Atualizar",  "u_pcp17gr",  0, 4},;
	{"Pesquisar",  "AxPesqui",     0, 1},;
	{"Visualizar", "AxVisual",     0, 2},; 
	{"Reimp.Etiq", "u_pcp017_ETI('R')",     0, 2} }

	cAbate := SZ4->Z4_NUMAM
	cLote  := SZ4->Z4_LOTE

	Private cCadastro  := "Produção do Abate"
	Private cString    := 'SZK'
	Private cFiltro    := "ZK_FILIAL == cChave .and. ZK_NUMAM == cAbate .And. ZK_LOTE == cLote"

	dbSelectArea(cString)
	dbSetOrder(2)

	Set Filter to &cFiltro     
	dbgotop()

	if eof()
		alert('Nao há Registros')
	else
		mBrowse( 6, 1, 22, 75,cString)
	endif

	Set Filter to

	RestArea(aArea)

Return


User Function PCP017pend()

	Private cChave := FWxFilial('SZK')

	Private aArea   := GetArea()

	Private aRotina := {	{"Atualizar",  "u_pcp17gr",  0, 4},;
	{"Pesquisar",  "AxPesqui",     0, 1},;
	{"Visualizar", "AxVisual",     0, 2} }

	cAbate := SZ4->Z4_NUMAM
	Private cCadastro  := "Produção do Abate"
	Private cString    := 'SZK'
	Private cFiltro    := "ZK_FILIAL == cChave .and. ZK_OK == 'P' .and. ZK_NUMAM == cAbate"

	dbSelectArea(cString)
	dbSetOrder(2)

	Set Filter to &cFiltro
	dbgotop()

	if eof()
		alert('Não há Pendências na Inspeção Federal Nº Aviso: '+ cAbate)
	else
		mBrowse( 6, 1, 22, 75,cString)
	endif

	Set Filter to

	RestArea(aArea)

Return


User Function pcp017sele(nmodo)
	Local i
	SZK->(DbSetOrder(3))
	SZD->(DbSetOrder(1))
	SZE->(DbSetOrder(2))
	SZ4->(DbSetOrder(1))
	SZE->(MsSeek(FWxfilial('SZE')+SZ4->(Z4_NUMAM+Z4_LOTE),.f.))

	nAni := SZ4->Z4_QUANT
	_dDataA := GetAdvFVal('SZG','ZG_DATA',FWxfilial('SZG')+SZ4->Z4_NUMAM,1)

	Somades := CalcRepl(SZE->ZE_NUMAM, SZE->ZE_LOTE)
	 _nCalcRepl := nAni - Somades
	_nUltSeq := buscaSeq(SZ4->Z4_NUMAM)


	IF !SZK->(Msseek(FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)))

		CURSORWAIT()
		SZE->(Msseek(FWxFilial('SZE')+SZ4->(Z4_NUMAM+Z4_LOTE)))
		SZ5->(MsSeek(FWxFilial('SZ5')+SZE->(ZE_CATEG)))

		Begin transaction

			cNum := GETSX8NUM('SZK','ZK_NUMERO')
			For i:= 1 to _nCalcRepl

				cRas := iif(SZE->(ZE_FILIAL+ZE_NUMAM+ZE_LOTE)==SZ4->(Z4_FILIAL+Z4_NUMAM+Z4_LOTE), SZE->ZE_RASTRO, '')

				Reclock('SZK',.t.)
				SZK->ZK_NUMERO  := cNum
				SZK->ZK_ITEM    := strzero((_nUltSeq+i),len(SZK->ZK_ITEM))
				SZK->ZK_NUMAM   := SZ4->Z4_NUMAM
				SZK->ZK_LOTE    := SZ4->Z4_LOTE
				SZK->ZK_CATEG   := SZ5->Z5_COD
				SZK->ZK_SEXO    := SZ5->Z5_SEXO
				SZK->ZK_RASTRO  := cRas
				SZK->ZK_ORDEM   := iif(empty(cRas),i ,999)
				SZK->ZK_MATURA  := 'S'  //inicia default para maturar
				SZK->ZK_OBS     := If( Empty(SZE->ZE_OBS) .OR. SZ4->Z4_RASTRO <> 'S' ,'0',SZE->ZE_OBS)  
				SZK->ZK_PROGRAM := SZ4->Z4_PROGRAM
				SZK->ZK_DATAABT := _dDataA
				Msunlock()

				SZE->(DbSkip())

			Next
			confirmsx8()
		End transaction

	Endif

	if nmodo == 1
		Return
	endif

	SZK->(DbSetOrder(3))
	SZK->(Msseek(FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE),.t.))

	lSreg := .t.
	nSeq  := 0
	Do while SZK->(!eof()) .and. SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE)==FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)
		nSeq++
		if empty(SZK->ZK_OK)
			lSReg := .f.
			if !u_pcp017GRV(nAni,nSeq)
				exit
			endif
		endif

		SZK->(DbSkip())
	EndDo

	if lSreg
		alert('Status Fechado, não há atualização')
	endif

	CURSORARROW()

return


User Function pcp017orde(cAlias,nReg,nOpc)
	Local i
	private ord17 := .T. // Apenas para permitir a alteracao do campo zk_obs

	SZK->(DbSetOrder(3))
	SZE->(DbSetOrder(2))

	If !SZK->(Msseek(FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)))

		u_pcp017sele(1)

	Endif

	CURSORWAIT()

	aStru := {} ; aHeader := {} ; aCols   := {} ; aButtons:= {}
	nOrd:=0

	AADD(aButtons, { 'PESQUISA',{||ordena(), oDlg:Refresh() },                                           'Ordenar Lote'       , 'Ordenar'   } )
	AADD(aButtons, { 'EXCLUIR' ,{||limpa(),    oDlg:Refresh() },                                         'Exclui nao localizados', 'Excluir'    } )
	AADD(aButtons, { 'BMPORD'  ,{||aCols := aSort( aCols,,, {|X, Y| X[1] > Y[1]} ), oGetDad:Refresh() }, 'Ordenao Nao Localizado', 'Não LOc'    } )
	AADD(aButtons, { 'BMPORD'  ,{||aCols := aSort( aCols,,, {|X, Y| X[1] < Y[1]} ), oGetDad:Refresh() }, 'Ordena NºOrdem'        , 'Ordem'      } )

	aadd(aStru,{"ZK_ORDEM"})			//1
	aadd(aStru,{"ZK_RASTRO"})			//2
	aadd(aStru,{"ZK_NUMERO"})			//3
	aadd(aStru,{"ZK_ITEM"})		    	//4
	aadd(aStru,{"ZK_SEXO"})			   //5
	aadd(aStru,{"ZK_OBS"})			   //6
	aadd(aStru,{"ZK_LOTE"})			   //7
	aadd(aStru,{"ZK_RACA"})		     	//8
	aadd(aStru,{"ZK_CATEG"})		   //9
	aadd(aStru,{"ZK_PROGRAM"})		   //10

	//DbSelectarea('SX3') ; DbSetOrder(2)
	//For i:=1 to len(aStru)                                //Header
	//	If MsSeek(padr(astru[i,1],10))            //existe no dic inf de lá
	//		aAdd(aHeader,{X3_DESCRIC    , X3_CAMPO   , X3_PICTURE ,;
	//		X3_TAMANHO    , X3_DECIMAL , X3_VALID ,;
	//		X3_USADO      , X3_TIPO    , X3_ARQUIVO, X3_CONTEXT })
	//	Endif
	//Next

	_cAlias  := "SZK"
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	_cAcols  := "ZK_ORDEM/ZK_RASTRO/ZK_NUMERO/ZK_ITEM/ZK_SEXO/ZK_OBS/ZK_LOTE/ZK_RACA/ZK_CATEG/ZK_PROGRAM"
	For i := 1 To Len(_aCpoSX3)
		If(X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')) .And. AllTrim(GetSx3Cache(_aCpoSX3[i], 'X3_CAMPO')) $ _cAcols)
			aAdd(aHeader, { GetSx3Cache(_aCpoSX3[i], 'X3_DESCRIC')	,;
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

	SZK->(DbSetOrder(3))             
	SZK->(DbGoTop())
	SZK->(Msseek(FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)))

	/* Monta a janela com os animais a serem ordenados - Flávio - 01/10/2016*/ 
	Do while SZK->(!eof()) .and. (SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE)==FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE))

		aAdd(aCols,Array(len(aHeader)+1))
		j := len(aCols)

		acols[j, 1]  := SZK->ZK_ORDEM
		acols[j, 2]  := SZK->ZK_RASTRO
		acols[j, 3]  := SZK->ZK_NUMERO
		acols[j, 4]  := SZK->ZK_ITEM
		acols[j, 5]  := SZK->ZK_SEXO
		acols[j, 6]  := SZK->ZK_OBS
		acols[j, 7]  := SZK->ZK_LOTE
		acols[j, 8]  := SZK->ZK_RACA
		acols[j, 9]  := SZK->ZK_CATEG
		acols[j, 10]  := SZK->ZK_PROGRAM	
		acols[j, len(aHeader)+1]       := .F.    //marca c/nao excluido		
		SZK->(DbSkip())                                                

	EndDo

	CURSORARROW()

	lOk := .f.
	aCols := aSort( aCols,,, {|X, Y| X[2] < Y[2]} )

	DEFINE MSDIALOG oDlg TITLE 'Ordenação do Lote Rastreado' ;
	from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	SET KEY VK_F4 to incre()

	oGetDad := MSGetDados():New(11, 0, aPosObj[2,3], aPosObj[2,4],nopc, "AllwaysTrue", "AllwaysTrue", "", .t.,,,.t.,1000,"u_pcp017val")
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lok:=.t.,oDlg:End()},{||lok:=.f.,iif(apmsgnoyes('Encerra sem Salvar?'),oDlg:end(),oDlg:refresh())},,aButtons)

	If !lOk
		Return .f.
	Endif

	SET KEY VK_F4

	_lDescId := .f.

	For i:=1 to len(aCols)
		if acols[i, 6] = '1'      //Se for desclassificado por motivo de brinco errado, então fode com todo o lote
			_lDescId := .t.
		endif

	Next

	/* Gravar dados na SZK aqui - após ok da segunda janela*/
	SZK->(DbSetOrder(1))

	For i:=1 to len(aCols)          //Numero               //Item 
		cChave :=  FWxFilial('SZK') + alltrim(aCols[i,3]) + alltrim(aCols[i,4]) 

		do Case
			Case acols[i,len(aHeader)+1]

			if SZK->(Msseek(cChave))
				RecLOck('SZK',.f.)
				SZK->(DbDelete())
				MsUnlock() 
			endif

			Case SZK->(Msseek(cChave))

			RecLOck('SZK',.f.)
			SZK->ZK_ORDEM   := aCols[i,1]
			SZK->ZK_OBS     := aCols[i,6] 
			/* Comantado pelo Flávio dia 07/11/2016 - para verificar se grava a raça e não limpa quando 
			a Tipificação coloca raça
			SZK->ZK_RACA    := aCols[i,8]*/
			SZK->ZK_PROGRAM := aCols[i,10]
			SZK->ZK_RASTRO  := acols[i,2]
			MsUnlock()

			// Rotina de gravação de log
			u_dtilog(cFilAnt, "U_F_PCP017", "Alteração sequencial -> " + SZK->ZK_CONTROL + " | NUMAM -> " + SZK->ZK_NUMAM, "A")

			Case !SZK->(Msseek(cChave))

			RecLOck('SZK',.t.)    
			SZK->ZK_FILIAL  := FWxfilial('SZK')
			SZK->ZK_NUMAM   := SZ4->Z4_NUMAM
			SZK->ZK_LOTE    := SZ4->Z4_LOTE
			SZK->ZK_ORDEM   := acols[i, 1]
			SZK->ZK_RASTRO  := acols[i,2] 
			SZK->ZK_NUMERO  := alltrim(aCols[i,3])
			SZK->ZK_OBS     := aCols[i,6]
			SZK->ZK_RACA    := aCols[i,8]
			SZK->ZK_CATEG   := aCols[i,9] 
			SZK->ZK_PROGRAM := aCols[i,10]
			SZK->ZK_SEXO    := acols[j,5]
			SZK->ZK_MATURA  := 'S'
			MsUnlock()

		EndCase

	Next 

	i := 1 
	// Varável criada para manter a igualdade entre ordem e item

	SZK->(DbSetOrder(3))
	SZK->(DbGoTop())
	SZK->(MsSeek(FWxfilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)))

	while SZK->(!eof()) .and. SZK->ZK_FILIAL = FWxfilial('SZK') .and.;
	SZK->ZK_NUMAM = SZ4->Z4_NUMAM .and.;
	SZK->ZK_LOTE = SZ4->Z4_LOTE             

		_lAtu := .f. // atualiza a ordem
		If SZK->ZK_ORDEM <> 999 .and. SZK->ZK_ORDEM <> val(SZK->ZK_ITEM)  // se SZK->ZK_ITEM

			_lAtu := .t.     

		Endif

		reclock('SZK',.f.)
		SZK->ZK_ITEM := strzero(i,4)
		if _lAtu
			SZK->ZK_ORDEM := i
		endif
		msunlock()
		i++
		SZK->(DbSkip())

	enddo

return


Static function proximo()
	Local i
	nOrd := 0

	for i:=1 to len(acols)
		if acols[i,1] > nOrd .and. acols[i,1] <> 999
			nOrd := acols[i,1]
		Endif
	next

Return ++nOrd


User function pcp017val()
	Local i
	nor := acols[n,1]

	If readvar() == "M->ZK_ORDEM"
		nor := M->ZK_ORDEM
	Endif

	lOk := .t.
	nOrd := 0

	for i:=1 to len(acols)
		if acols[i,1] > nOrd .and. acols[i,1] <> 999
			nOrd := acols[i,1]
		Endif
		if acols[i,1] == nor .and. n <> i .and. acols[i,1] > 0 .and. acols[i,1] <> 999
			alert('Ordem já utilizada')
			lOk := .f.
		endif
	next

Return lok


static function limpa()
	Local i
	if !ApmsgYESNO('Exclui animais não ordenados','Atenção')
		Return
	endif

	for i:=1 to len(aCols)
		if aCols[i,1] = 999
			aCols[i,len(aHeader)+1] := .t.
		Endif
	next

	oGetDad:Refresh()

Return

static function marcamotivo()
	cStat := '0'

	DEFINE MSDIALOG oDlg3 TITLE 'Motivo de Classificação' ;
	from 000,000 To 100,250 OF oMainWnd PIXEL

	@ 010,000 SAY 'Ocorrência' Object oSay2
	@ 010,030 COMBOBOX cStat ITEMS aObs size 50,50
	@ 025,085 BMPBUTTON TYPE 1 ACTION alterareg('1') Object Obtn2

	ACTIVATE MSDIALOG oDlg3

	nCodigo := space(16)
	oGetdad:Refresh()
	oCodigo:setfocus()
	Return .t.

Return


static function alterareg(_opc)

	//1 -  confirmar se foi marcado
	//2 -  Verificar cada tipo de OBS...
	If _opc = '1'  // Com sisbov

		nOrd := proximo()
		aCols := aSort( aCols,,, {|X, Y| X[4] < Y[4]} )
		n := len(aCols)  
		n2 := nCodigo
		aAdd(aCols,Array(len(aHeader)+1))
		j := len(aCols)	

		aCols[j,1] := nOrd 
		aCols[j,2] := nCodigo//_cSisbov
		aCols[j,3] := aCols[n,3]
		aCols[j,4] := strzero(val(aCols[n,4])+1,len(SZK->ZK_ITEM))
		aCols[j,5] := _cSexo //aCols[n2,5]
		aCols[j,6] := cStat
		aCols[j,7] := aCols[n,7]
		aCols[j,8] := aCols[n,8]
		aCols[j,9] := aCols[n,9]
		aCols[j,10]:= aCols[n,10]
		aCols[j, len(aHeader)+1] := .F.
		odlg3:End()

	Else  // Se  Sisbov não lancado no lote, incluir animal e marcar como Brinco errado

		cStat:= '2'	
		nOrd := proximo()
		aCols := aSort( aCols,,, {|X, Y| X[4] < Y[4]} )
		n := len(aCols)  
		n2 := nCodigo
		aAdd(aCols,Array(len(aHeader)+1))
		j := len(aCols)	

		aCols[j,1] := nOrd 
		aCols[j,2] := nCodigo 
		aCols[j,3] := aCols[n,3]
		aCols[j,4] := strzero(val(aCols[n,4])+1,len(SZK->ZK_ITEM))
		aCols[j,5] := _cSexo
		aCols[j,6] := cStat
		aCols[j,7] := aCols[n,7]
		aCols[j,8] := aCols[n,8]
		aCols[j,9] := aCols[n,9]
		aCols[j,10]:= aCols[n,10]
		aCols[j, len(aHeader)+1] := .F.

	Endif

Return


static function PesqSisbov(_cSisbov)

	SZK->(DbSetOrder(3)) 
	SZK->(DbGotop())
	SZK->(MsSeek(FWxfilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)))

	_cSexo := SZK->ZK_SEXO
	while  SZK->ZK_FILIAL = FWxfilial('SZK') .and. (SZK->(ZK_NUMAM+ZK_LOTE) = SZ4->(Z4_NUMAM+Z4_LOTE) )

		if alltrim(SZK->ZK_RASTRO) = alltrim(_cSisbov)
			//verificar se já não foi ordenado o sisbov
			if SZK->ZK_ORDEM = 999
				Return 1
			else  // Se tem sisbov e já foi ordenado
				return 2
			Endif
		endif

		SZK->(DbSkip())
	enddo 

Return 3


static function ordena()

	// Ainda aumentar o tamanho do campo de digitação do sisbov	

	DEFINE MSDIALOG oDlg2 TITLE 'SISBIV a Ordenar' ;
	from 000,000 To 100,210 OF oMainWnd PIXEL

	@ 010,003 SAY  'SISBOV' Object oSay1
	@ 010,025 GET nCodigo SIZE 60,130 PICTURE "@! 9999999999999999" Object oCodigo

	@ 037,080 BMPBUTTON TYPE 1 ACTION ordena2() Object Obtn2

	ACTIVATE MSDIALOG oDlg2

return


static function ordena2()

	if empty(nCodigo)
		alert('!! Informe o Sisbov !!')
		Return
	Endif

	// Pesquisar na SZK o Sisbov e verificar se existe
	result := PesqSisbov(nCodigo)

	If result == 1 //localizou sisbov e irá incluir

		marcamotivo()

	Elseif result == 3 // se não tem o sisbov marcar carcaça com  - -  Brinco errado

		alert('Sisbov não lançado neste Lote') 
		alterareg('2')

	Else

		alert('SISBOV jà Ordenado !!')

	Endif

	nCodigo := space(16)
	oGetdad:Refresh()
	oCodigo:setfocus()
return


static function incre()
	u_pcp017val()
	aCols[n,1] := ++nOrd
	oDlg:Refresh()
Return


static function decre()
	U_pcp017val()
	aCols[n,1] := --nOrd
	oDlg:Refresh()
Return


USer Function pcp017lege(cAviso,cLote)
	BrwLegenda(cCadastro,"Legenda",aCores2)
return


USer Function pcp017stat()

	aRet:={1,0,0,0,0,0} // 1abe 2 fec 3 parc 4 If, TOTAL OP, JA PROCESSADOS, FALTAM, pend

	SZK->(DbSetOrder(2))
	SZK->(Msseek(FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)))

	Do while SZK->(!eof()) .and. SZK->(ZK_FILIAL+ZK_NUMAM+ZK_LOTE)==FWxFilial('SZK')+SZ4->(Z4_NUMAM+Z4_LOTE)

		aRet[2]++

		If SZK->ZK_OK == 'S'
			aRet[3]++
		Endif

		If SZK->ZK_OK == ' '
			aRet[5]++
		Endif

		If SZK->ZK_OK == 'P'
			aRet[6]++
		Endif

		SZK->(DbSkip())
	EndDo

	aRet[4] := aRet[2]-(aRet[3]+aRet[6])

	do case
		case aret[6] > 0
		aRet[1]   := 4

		case aret[2] == 0
		aRet[1] := 1

		case aret[4] == 0
		aRet[1] := 2

		otherwise
		aRet[1] := 3

	endcase   
Return aRet


USer Function pcp017prd()
	Local area := GetArea()
	SZE->(DbSetOrder(2))
	SZD->(DbSetOrder(1))
	SA2->(DbSetOrder(1))

	cProd := 'AGLUTINADO-OUTROS     '
	SZE->(Msseek(FWxFilial('SZE')+SZ4->(Z4_NUMAM+Z4_LOTE)))

	If SZ4->(Z4_NUMAM+Z4_LOTE) == SZE->(ZE_NUMAM+ZE_LOTE)
		If SZD->(Msseek(FWxFilial('SZD')+SZE->ZE_NUMERO)) 
			cProd := posicione('SA2', 1 , FWxFilial('SA2')+SZD->(ZD_FORNECE+ZD_LOJA),'A2_NOME')
		Else
			cProd := ''
		Endif
	Endif
	RestArea(area)
Return cProd


User Function pcp017GRV(a,b,nAn,nSe)
	Local nCont
	Private ord17   := .F. // Apenas para permitir a alteracao do campo zk_obs
	Private aGets	:= {}
	Private aTela	:= {}
	Private Abuttons:= {}

	lok := .f.
	nrec := SZK->(recno())

	DEFINE MSDIALOG oDlg TITLE 'Produção do Abate' ;
	from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	SZK->(DbSetOrder(4))
	SZK->(Msseek(FWxFilial('SZK')+SZ4->Z4_NUMAM,.t.))
	nControl := 1

	Do While SZK->(!eof()) .and. SZK->(ZK_FILIAL+ZK_NUMAM) == FWxFilial('SZK')+SZ4->Z4_NUMAM
		nControl := val(SZK->(ZK_CONTROL))+1
		SZK->(dbSKIP())
	Enddo

	SZK->(DbSetOrder(3))
	DbselectArea('SZK')
	Dbgoto(nrec)

	RegToMemory("SZK")
	//RegToMemory("SZ4")
	dAbate := Posicione('SZG',1,FWxFilial('SZG')+ZK_NUMAM+ZK_LOTE,'ZG_DATA')

	If Empty( SZK->ZK_CONTROL ) // caso já tenha havido pesagem
		M->ZK_HORA    := time()
		M->ZK_CONTROL := strzero(nControl,6)
		M->ZK_TUBERC  := 'N'
	Endif

	oEnc := MsMGet():New("SZK" ,SZK->(RECNO()),1,,,,,aPosObj[1]  ,,3,,,,oDlg,,,.F. )

	@ aPosObj[2,1],002     BUTTON '_Próximo'            SIZE 47,20 ACTION u_pcp017ok()                 OBJECT oBtn1
	@ aPosObj[2,1],052     BUTTON '_Abandona'           SIZE 47,20 ACTION u_pcp017nok()                OBJECT oBtn2
	@ aPosObj[2,1],102     BUTTON 'Impr.Etiqueta'       SIZE 47,20 ACTION u_pcp017_ETI('I')   OBJECT oBtn3
	@ aPosObj[2,1],152     BUTTON 'Pes.Carc._Esquerda'  SIZE 47,20 ACTION u_pcp017_bal(@M->ZK_PECARC1) OBJECT oBtn4
	@ aPosObj[2,1],202     BUTTON 'Pes.Carc._Direita'   SIZE 47,20 ACTION u_pcp017_bal(@M->ZK_PECARC2) OBJECT oBtn5
	@ aPosObj[2,1],252     BUTTON 'D_esclassificar'     SIZE 47,20 ACTION u_pcp017des()                OBJECT oBtn6
	@ aPosObj[2,1]+30,002  SAY    'Produtor: ' + SZ4->Z4_NOME
	@ aPosObj[2,1]+40,002  SAY    'Animal/Tot.Lote: ' + M->ZK_ITEM + ' / ' + Strzero(SZ4->Z4_QUANT,5)//+ Strzero((C2_QUANT/2),5)   //c2_LOTE

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||u_pcp017ok()},{||u_pcp017nok()})

	If !lOk
		Return .f.
	else 

		if M->ZK_PECARC1 <> 0 .and. M->ZK_PECARC2 <> 0
			reclock('SZ4',.f.)
			SZ4->Z4_QTREAL += 1
			msunlock()
		endif

		RecLock("SZK",.F.)

		For nCont := 1 To FCount()

			If "FILIAL"$Field(nCont)
				FieldPut(nCont,FWxFilial("SZK"))
			Else
				FieldPut(nCont,M->&(FIELDNAME(nCont)))
			Endif

		Next nCont

		SZK->ZK_CONTROL := strzero(val(M->ZK_CONTROL),6)
		SZK->ZK_OK      := iif(M->ZK_DESTINO == 'I','P', 'S')
		SZK->ZK_IF      := iif(M->ZK_DESTINO $ 'I/T/R/G', 'S', SZK->ZK_IF)
		SZK->ZK_CLASABA := M->ZK_CLASSIF // memoriza o original do abate
		if M->ZK_COBGOR = '1'
			SZK->ZK_PROGRAM := '001' //Definição com a PROGEPEC e Diretoria
		endif
		MsUnLock() 

	Endif

Return .t.


User Function pcp17GR() 
	/*if empty(SZK->ZK_OK)*/
	u_pcp017grv(1,1)
	/*else
	alert('Ja atualizado')
	endif*/
Return


User Function pcp017_ETI(cFunc)

	If empty(cmod)
		Return
	Endif

	If cFunc == 'I'
		classifica()
		imprime()
	ElseIf cFunc == 'R'	
		reimprime()
	EndIf

Return


Static Function GeraETQ(_n)

	RegToMemory("SZK")
	dAbate := Posicione('SZG',1,FWxFilial('SZG')+ZK_NUMAM+ZK_LOTE,'ZG_DATA')
	ZAJ->(DbSetOrder(1))  
	ZAJ->(DbGoTop())
	if ZAJ->(MsSeek(FWxfilial('ZAJ')+M->ZK_NUMAM + M->ZK_CONTROL))

		/************************Impressão das Etiquetas***************************/

		ProcRegua(_n)	

		while ZAJ->(!eof()) .and. ZAJ->ZAJ_FILIAL = cFilant .and. ZAJ->ZAJ_NUMAM = M->ZK_NUMAM .and. ZAJ->ZAJ_CONTRO = M->ZK_CONTROL

			if ZAJ->ZAJ_REGORI <> '0000000000'
				ZAJ->(DbSkip())
				loop
			endif

			_cMens := iif(ZAJ->ZAJ_COD = '000030','TRASEIRO',iif(ZAJ->ZAJ_COD = '000031','DIANTEIRO','COSTELA')) + ' LADO ' + ZAJ->ZAJ_LADO + '...'
			//_cMens := substr(GetAdvFVal('SB1',1,FWxFilial('SB1') + ZAJ->ZAJ_COD,'B1_DESC'),1,10) + ' LADO ' + ZAJ->ZAJ_LADO + '...'

			IncProc(_cMens)

			//Impressão via LPT1
			//MSCBPRINTER(cMod,cPor)
			//Impressão via rede
			alert(_cIpImp)
			_cIpImp:= '10.11.21.38'
			MSCBPRINTER(cMod,cPor,,,,,_cIpImp)
			//MSCBPRINTER(cMod,cPor,,,,,'10.6.20.43')
			MSCBCHKSTATUS(.f.)
			MSCBBEGIN(1,6)	

			MSCBBOX(01,16,60,33)

			//Lado
			MSCBSAY(50, 17,ZAJ->ZAJ_LADO,"N","0","100,100")

			//Codigo de Barras
			MSCBSAYBAR(08,17,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,2,2,.t.)

			MSCBBOX(01,35,14,48)
			MSCBSAY(3, 36,'Gord',"N","E","8,8")
			MSCBSAY(6, 40,M->ZK_COBGOR,"N","0",_Font01)

			MSCBBOX(17, 35,31,48)
			MSCBSAY(20, 36,'Dent',"N","E","8,8")		
			MSCBSAY(23, 40,iif(M->ZK_DENT = '0','DL',M->ZK_DENT),"N","0",_Font01)

			MSCBBOX(34, 35,46,48)
			MSCBSAY(35, 36,'Conf',"N","E","8,8")
			MSCBSAY(40, 40,M->ZK_CONFORM,"N","0",_Font01)

			MSCBBOX(48, 35,60,48)
			MSCBSAY(50, 36,'Tip',"N","E","8,8")
			MSCBSAY(50, 40,M->ZK_TIPIFI,"N","0",_Font01)

			MSCBBOX(02,50,60,70)
			MSCBLINEV(39,50,70)
			MSCBLINEH(39,60,60)

			MSCBSAY(03, 52,'SEQ.',"N","E","8,8")
			MSCBSAY(13, 52,M->ZK_CONTROL,"N","0",_Font02)

			//MSCBSAY(03, 62,iif(ZAJ->ZAJ_COD = '000030','TRASEIRO',iif(ZAJ->ZAJ_COD = '000031','DIANTEIRO','COSTELA')),"N","0",_Font01)

			_cDescri := ZAJ->ZAJ_DESCRI
			MSCBSAY(03, 62,_cDescri,"N","0",_Font01)

			MSCBSAY(40, 52,'Abate',"N","E","8,8")
			MSCBSAY(40, 55,M->ZK_NUMAM,"N","E","8,8")

			MSCBSAY(40, 62,'Lote',"N","E","8,8")
			MSCBSAY(40, 66,M->ZK_LOTE,"N","E","8,8")

			MSCBBOX(02,72,60,77)
			_cNUMIF := _GetParam()
			MSCBSAY(02,73, _cNUMIF + strtran(dtoc(dAbate),'/','') +'0000',"N","E","8,8")

			MSCBBOX(02,79,30,89)
			MSCBSAY(03,80,'SIF',"N","E","8,8")
			MSCBSAY(07,84, _cNUMIF, "N","E","28,15")

			MSCBBOX(32,79,60,89)
			MSCBSAY(33,80,'Data Abate',"N","E","8,8")
			MSCBSAY(37,84,dtoc(dAbate),"N","E","28,15")

			nL := 125

			Private _cPrograma   := M->ZK_PROGRAM
			Private nomePrograma := POSICIONE('SZ6', 1, FWxFilial('SZ6')+_cPrograma, 'Z6_DESC')

			MSCBBOX(02,93,60,98)
			If M->ZK_OBS == '0'  //ok
				MSCBSAY(03,94, 'SISBOV:'+ M->ZK_RASTRO ,"N","E","8,8")
			Endif
			_cCateg := GetAdvFVal('SZ5','Z5_DESC',FWxfilial('SZ5')+M->ZK_CATEG,1)
			if M->ZK_PROGRAM = '006'
				MSCBBOX(02,100,60,109)
				MSCBSAY(03,101,_cCateg,"N","0",_Font01)// *** Verificar campo novo
				MSCBBOX(02,110,60,120)

				if  (alltrim(M->ZK_DENT) $ "0|2|4") .AND.  (M->ZK_PETOTAL >= 230)
					MSCBSAY(10,111,'BLACK',"N","0","90,105")
				Else 
					MSCBSAY(10,111,'ANGUS',"N","0","90,105")
				Endif

				MSCBBOX(02,124,60,144)// quadrado
				MSCBSAY(10,125,M->ZK_CLASSIF,"N","0","180,300")
			else
				MSCBBOX(02,100,60,109)
				MSCBSAY(03,101,_cCateg,"N","0",_Font01)
				//MSCBBOX(02,110,60,130)
				MSCBBOX(02,110,60,120)
				//MSCBSAY(12,111,M->ZK_CLASSIF,"N","0","162,270")
				MSCBSAY(10,125,M->ZK_CLASSIF,"N","0","180,300")

				//If !Empty(nomePrograma) .and. nomePrograma != '001'
				//	MSCBSAY(03,138,substr(nomePrograma,1,10), "N","0","100,80")// aqui esta sendo modificado
				//endif

				If !Empty(nomePrograma) .and. nomePrograma != '001'
					// Ajuste solicitado pelo Sr Matheus Silva para Impressão de etiquetas com Black - Dia 03/11/2016  - Flávio
					If M->ZK_PROGRAM = '002' .AND. (alltrim(M->ZK_DENT) $ "0|2|4") .AND.  (M->ZK_PETOTAL >= 230)
						MSCBSAY(10,111,'BLACK',"N","0","90,105")	
					Else  				
						MSCBSAY(10,111,substr(nomePrograma,1,10), "N","0","90,105")// aqui esta sendo modificado
					Endif

					//iif(M->ZK_COBGOR = '1',MSCBSAY(03,138,substr(nomePrograma+' - MAGRO',1,10), "N","0","100,80"),MSCBSAY(03,138,substr(nomePrograma,1,10),"N","0","100,80"))
				endif

			endif

			//Aqui imprime a Classificação Especial
			//if M->ZK_CLASESP = '1' .and. (AllTrim(M->ZK_CLASSIF) != 'NE' .or. AllTrim(M->ZK_CLASSIF) != 'USA') .and. M->ZK_DENT > '4'
			if M->ZK_CLASESP = '2' .and. (AllTrim(M->ZK_CLASSIF) != 'NE' .or. AllTrim(M->ZK_CLASSIF) != 'BR') .and. M->ZK_DENT > '4'
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,147,'HK',"N","0","200,200")
			elseif M->ZK_CLASESP = '1' .and. AllTrim(M->ZK_CLASSIF) = 'USA'
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,147,'USA',"N","0","200,200")
			//elseif M->ZK_CLASESP = '2' .and. AllTrim(M->ZK_CLASSIF) = 'BR'
			//	MSCBBOX(16,145,45,120)
			//	MSCBSAY(17,147,'BR',"N","0","200,200")
			elseif M->ZK_CLASESP = '1' .and. AllTrim(M->ZK_CLASSIF) != 'NE' .and. M->ZK_DENT <= '4' 
				MSCBBOX(16,145,45,120)
				MSCBSAY(17,148,'CN',"N","0","200,200")
			endif

			//****************************  FIM  *****************************************
			MSCBSAY(13,285,"DTI","N","0","100,190")

			MSCBEND()
			MSCBCLOSEPRINTER()

			sleep(1000)

			ZAJ->(DbSkip())

		enddo

	endif

return


//Função que manda imprimir
Static Function imprime(dAbate)

	dAbate := Posicione('SZG',1,FWxFilial('SZG')+M->ZK_NUMAM+M->ZK_LOTE,'ZG_DATA')
	_Font01 	:= "60,60"
	_Font02 	:= "70,70"
	_nCont	:=	1 

	// Se impressão costelas sim
	if mv_par06 = 1
		_nImp := 6
	else
		_nImp := 4
	endif     

	Processa({||u_GJF182(_nImp) },"REGISTROS DE CARCAÇAS","Realizando gravação de registros...")

	area := getarea()

	Processa({||GeraETQ(_nImp) },"IMPRESSÃO DE ETIQUETAS","Realizando impressão de etiquetas...")  

	restarea(area)

Return


Static Function reimprime(dAbate)
	regtomemory('SZK',.F.)
	imprime()
Return


User Function pcp017_bal(v)
	//Se for modo serial...
	if mv_par07 = 1

		nHdll := 0

		if !MSOpenPort(nHdll,cCom)
			msgbox("Não foi possível pegar informações da porta",,"STOP")
			Return 0
		endif

		cText := space(15)
		if !MsRead(nHdll,@cText)
			msgbox("Não foi possível pegar informações da porta",,"STOP")
			Return 0
		endif

		inkey(1)
		if empty(cText)
			inkey(1)
			cText := space(15)
			MsRead(nHdll,@cText)
		endif

		do Case
			Case at("p`",cText)> 0
			cPeso := substr(cText,at("p`",cText)+2,6)
			cC := "`"

			Case at("`",cText) > 0
			cPeso := substr(cText,at("`",cText)+1,6)
			cC := "`"

			Case at("p ",cText)> 0
			cPeso := substr(cText,at("p ",cText)+2,6)
			cC := " "

			Otherwise
			cPeso :='000000'
			cC := ""
		Endcase

		cPeso := substr(cText,at("`",cText)+1,6)
		cPeso := substr(cText,at(cC,cText)+1,6)

		nPeso := val(cPeso)/(10**nDec)

		if valtype(nPeso) == 'N'
			v := npeso
		else
			v     := 0
			nPeso := 0
		endif

		msClosePort(nHdll)	
		//Se for modo IP
	else
		cBuffer := ""
		nQtd = oObj:Receive( cBuffer,1000)

		if( nQtd >= 0 )
			_cPeso := substr(cBuffer,3,7)
			nPeso  := val(_cPeso)/100
			v      := npeso
			//alert(_nPeso)
		endif

	endif

	oenc:Refresh()
	M->ZK_PETOTAL := M->(ZK_PECARC1+ZK_PECARC2)

	PesoT(nPeso)  //Funçãozinha que gera TXT

Return nPeso
/*
Static function pcp017gsd3() 

cursorwait()  

reclock('SZ4',.f.)
SZ4->Z4_QTREAL += 1
msunlock()

lMsErroAuto := .F.

aMata250 :={{"D3_OP",Alltrim(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)) ,NIL},;
{"D3_TM"      ,"004"                               ,NIL},;
{"D3_LOCAL"   ,M->ZK_LOCAL                         ,NIL},;
{"D3_COD"     ,'001500'                            ,NIL},;
{"D3_QUANT"   ,2                                   ,NIL},;
{"D3_EMISSAO" ,SC2->C2_EMISSAO                     ,NIL},;
{"D3_PRDNUM"  ,M->ZK_NUMERO                        ,NIL},;
{"D3_CC"      ,SC2->C2_CC                          ,NIL},;
{"D3_PRDITEM" ,M->ZK_ITEM                          ,NIL} }


lMsErroAuto := .F.

msExecAuto({|x,Y| Mata250(x,Y)},aMata250,3)

cursorarrow() 

Return !lMsErroAuto
*/
User function pcp017ok()

	//Faz a verificação somente se o abate for bovino
	if substr(M->ZK_NUMAM,1,2) = '01'
		if  empty(M->ZK_COBGOR) .or. empty(M->ZK_DENT) .or. empty(M->ZK_CONFORM)
			msgbox('Campos de tipificação não totalmente preenchidos!','DADOS FALTANTES PARA PROCESSO','STOP')
			return .f.
		endif 
		if (M->ZK_PECARC1 < 30.00 .or. M->ZK_PECARC1 > 700.00) .or. (M->ZK_PECARC2 < 30.00 .or. M->ZK_PECARC2 > 700.00)
			msgbox('Pesos capturados inconsistentes!','DADOS FALTANTES PARA PROCESSO','STOP')
			return .f.
		endif

		_nPecarc11 := M->ZK_PECARC1 * 1.20
		_nPecarc21 := M->ZK_PECARC2 * 1.20

		_nPecarc12 := M->ZK_PECARC1 * 0.80
		_nPecarc22 := M->ZK_PECARC2 * 0.80

		//Verificação de proporcionalidade das meias-carcaças
		if (M->ZK_PECARC1 > _nPecarc21 .or. M->ZK_PECARC1 < _nPecarc22) .or.  (M->ZK_PECARC2 > _nPecarc11 .or. M->ZK_PECARC2 < _nPecarc12)
			msgbox('Pesos capturados inconsistentes!','INCONSISTENCIA NA PROPORÇÃO','STOP')
			return .f.
		endif   

	endif

	lOk := Obrigatorio(aGets,aTela)
	if lOk
		Odlg:end()
	else
		Odlg:refresh()
	end   

Return lOk

User function pcp017nok()
	lOk := .f.
	Odlg:end()
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³pcp017Sal º Autor ³ 3v Tec. Marcel V.M.º Data ³  15/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ler a tabela Sx5 - Chave = '74'  ( locais de armazenagem ) º±±
±±º          ³ Carregar numa matriz o  código do local, quantidade limite,º±±
±±º          ³ Ler a tabela SB2010  a quantidade de produtos que estão em º±±
±±º          ³ cada um destes estoques e carregar na matriz anterior a    º±±
±±º          ³ quantidade total utilizada e o saldo a armazenar.          º±±
±±º          ³ RA|RB|RC|RD|RG = Locais de Armazenagem de Estoque          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User function pcp017Sal()

	Local Saldo    	:= 0
	Local nZ

	Private aHeader	:= {}
	Private aCols  := {} 

	//SX5->(DbSetOrder(01))
	//SX5->(Dbgotop())
	//Do While !SX5->(Eof()) 
	//	If (SX5->X5_TABELA="74")
	//		SB2->(DBsetorder(01)) //B2_FILIAL+B2_COD+B2_LOCAL
	//		SB2->(Dbgotop())
	//		If SB2->(MsSeek(FWxFilial('SB2')+'001500         '+(TRIM(SX5->X5_CHAVE)),.F.))
	//			Saldo := (VAL(SX5->X5_DESCENG)-SB2->B2_QATU)
	//			Aadd( aCols, { SX5->X5_CHAVE, SX5->X5_DESCRI, SX5->X5_DESCENG, SB2->B2_QATU, Saldo,.F. } )
	//		EndIf	
	//	EndIf	
	//	SX5->(Dbskip())
	//Enddo

	aRetSX5 := FWGetSX5("74")
	for nZ:= 1 to len(aRetSX5) 		// Filial, Tabela, Chave, Descricao

		SB2->(DBsetorder(01)) 		// B2_FILIAL+B2_COD+B2_LOCAL
		SB2->(Dbgotop())
		If SB2->(MsSeek(FWxFilial('SB2')+'001500         ' + (TRIM(aRetSX5[nZ][4])),.F.))
			Saldo := Val(FWGetSX5( "74",aRetSX5[nZ][3],"en")[1][4]) - SB2->B2_QATU

			Aadd( aCols, { aRetSX5[nZ][3], aRetSX5[nZ][4], FWGetSX5( "74",aRetSX5[nZ][3],"en")[1][4], SB2->B2_QATU, Saldo,.F. } )
		EndIf	

	Next

	AADD(aHeader,{ "Local"         ,"X5_CHAVE"   ,"", 06,  0,  ".F.", " ",  "C",  "SX5"    } )
	AADD(aHeader,{ "Descricao"     ,"X5_DESCRI"  ,"", 55,  0,  ".F.", " ",  "C",  "SX5"    } )
	AADD(aHeader,{ "Quant. Maxima" ,"X5_DESCENG" ,"", 14,  0,  ".F.", " ",  "C",  "SX5"    } )
	AADD(aHeader,{ "Utilizado"     ,"B2_QATU"    ,"", 14,  2,  ".F.", " ",  "N",  "SB2"    } )
	AADD(aHeader,{ "Saldo"         ,"Saldo"      ,"", 14,  2,  ".F.", " ",  "N",  ""       } )

	@ 128,55 To 398,597 DIALOG dProd TITLE "Capacidade de Armazenagem"
	@ 4,3 To 114,260 MultiLine Modify delete //Valid OkLine()
	@ 119,224 BUTTON "_Ok" SIZE  36,16 ACTION Close(dProd)
	ACTIVATE DIALOG dProd CENTERED
Return


Static Function _ascan(cCampo)
Return ascan(aHeader,{|x|alltrim(x[2])==cCampo})


static function PesoT(_nPeso)
	nHdl := fCreate('C:\SMARTCLIENT\PESOBAL.TXT')
	fwrite(nHdl,str(_nPeso)) 
	fClose(nHdl)
return                         

//Nova rotina para classificação
//em 15.03.11
static function classifica()

	SZE->( dbSetOrder(2) ) //numam+lote
	SZE->( MsSeek(FWxFilial('SZE')+SZK->ZK_NUMAM+SZK->ZK_LOTE ) )                       

	M->ZK_CLASSIF := SZ4->Z4_CLASSIF

	if AllTrim(SZ4->Z4_CLASSIF) = 'NE'
		M->ZK_CLASSIF := 'NE'
		return
	endif

	if M->ZK_DESTINO = 'I'
		M->ZK_CLASSIF := 'HK'
		M->ZK_CLASESP := '2'
		return
	endif

	if M->ZK_DESTINO $ 'T/R/G'
		M->ZK_CLASSIF := 'NE'
		return
	endif

	if M->ZK_MATURA = 'N'
		M->ZK_CLASSIF := 'HK'
		return
	endif  

	if M->ZK_TUBERC = 'S'
		M->ZK_CLASSIF := 'HK'
		return
	endif  

	// Ajuste CLassificação - Inclusão da opção  "8" e troca de classificação -  dia  30/09/16 - Flávio
	if AllTrim(SZ4->Z4_CLASSIF) = 'RT'
		if M->ZK_OBS $ '1234568'   
			//M->ZK_CLASSIF := 'RU'
			M->ZK_CLASSIF := 'HK'
			return
		endif  
	endif

	if M->ZK_OBS = '7'
		M->ZK_CLASSIF := 'NE'
		return
	endif               

	if empty(M->ZK_CLASSIF)
		M->ZK_CLASSIF := SZ4->Z4_CLASSIF
	endif

	//Classificação específica para programas
	if M->ZK_COBGOR = '1'
		M->ZK_PROGRAM := '001'
	endif

Return      


//captura de peso via conexão Ethernet
Static Function CaPeso()
	local _cString  := ''

	nQtd = oObj:Receive(_cString,500)    	

	return _cString  
	oenc:Refresh()
	M->ZK_PETOTAL := M->(ZK_PECARC1+ZK_PECARC2)


	PesoT(nPeso)  //Funçãozinha que gera TXT

Return nPeso


Static Function _GetParam()

	_cRet := GetMv("MV_NUMIF")

Return(_cRet)

Static Function CalcRepl(numam, lote)
	Local _cQuery := ""
	Local _cRet   := 0

	_cQuery := " SELECT SUM(ZE_QTD1UM) AS SOMA"
	_cQuery += " FROM " + retSqlTab("SZE")
	_cQuery += " WHERE " + retSqlFil("SZE")
	_cQuery += " AND " + retSqlDel("SZE")	
	_cQuery += " AND ZE_NUMAM = '" + numam + "'"	
	_cQuery += " AND ZE_LOTE  = '" + lote + "'"	
	_cQuery += " AND (ZE_LOCAL IN ('AE', 'OC', 'OV'))	

	_cQuery := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbGoTop())

    If QRY->(!EOF())
        _cRet := QRY->SOMA
    endif
	
    QRY->(dbCloseArea())

Return _cRet

// Busca último sequencial do abate enviado por parâmetro
Static Function buscaSeq(_cNumam)
	Local _cQuery := ""
	Local _nRet   := 0

	_cQuery := "SELECT COUNT(ZK_ORDEM) AS SEQ"
	_cQuery += " FROM " + retSqlTab('SZK') + " (NOLOCK)"
	_cQuery += " WHERE " + retSqlFil('SZK')
	_cQuery += " AND ZK_NUMAM = '" + _cNumam + "'"
	_cQuery += " AND ZK_ITEM <> ''"
	_cQuery += " AND " + retSqlDel('SZK')

	_cQuery  := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	QRY->(dbGoTop())

    If QRY->(!EOF())
        _nRet := QRY->SEQ
    endif

    QRY->(dbCloseArea())

Return _nRet
