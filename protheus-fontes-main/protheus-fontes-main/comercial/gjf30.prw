#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"                                                                                                  	
#INCLUDE "protheus.ch"                      
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³GJF30     ºAutor  ³Giuliano Forgiarini º Data ³  29/01/08      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.      ³ Liberação de pré-pedidos de venda                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso        ³ Sigaoms - Frigorifico Silva                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºManutenção ³ Reformulação da Rotina ºAutor ³Mauricio Roehrs ºData ³19/06/13º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF30()

	Private _lSldFlag   := .f.    //Para utilizaçao da função gjf28sld()
	Private aBrowse1 := {}
	Private _UltOrd  := 0

	Private cPerg   := "GJF30"
	Private cCadastro := "Liberação de Pré-Pedidos de Venda"

	if !pergunte(cPerg,.t.)
		return
	endif

	aHead    := {'','Numero','Marca','Data','Codigo','Loja','Nome do Cliente','Cidade'}
	//Largura das colunas
	aLargCol := {40,   40   ,  20   ,  40  ,   30   ,  20  ,      130         ,   40   }

	// Vetor com elementos do Browse
	aBrowse1 := {}
	aBrowse2 := {}

	Private cString := "ZZ4"
	dbSelectArea(cString)
	ZZ4->(dbSetOrder(2))
	ZZ4->(dbgobottom())

	DEFINE DIALOG oDlg TITLE "Pre-pedidos" FROM 020,50 To 700,1000 PIXEL
	// Cria Browse
	oBrowse1 := TCBrowse():New(00,60,400,280,,aHead,aLargCol,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	montabrow()

	TButton():New( 030, 005, "Operar",      oDlg,{|| u_gjf30OP(aBrowse1[oBrowse1:nAt,02])},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 045, 005, "Sair",        oDlg,{|| oDlg:end()                        },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

return

//OPERAÇÃO DOS PRE-PEDIDOS DE VENDA
User Function gjf30OP(_cNumPP)

	Local aButtons	  := {}
	Local _lOk       := .f.
	Private aHeader  := {}
	Private aCols	  := {}
	Private nUsado	  :=	0
	Private oGet	  := NIL
	Private _cCarga  := ''
	Private _nPesoL  := 0
	Private _nCaix   := 0
	Private _nFatC   := 0
	Private _cCod    := ''
	Private oDlg2    := NIL

	ZZ4->(DbSetOrder(2))
	ZZ4->(MsSeek(FWxfilial('ZZ4')+_cNumPP))

	cAlias := 'ZZ4'

	_nPrevCx   := ZZ4->ZZ4_QPCAIX
	_nPrevPs   := ZZ4->ZZ4_QPPESO
	_nTotal    := ZZ4->ZZ4_TOTAL
	_dData     := ZZ4->ZZ4_DATA
	_cObs      := ZZ4->ZZ4_OBS
	_cTpOper   := ZZ4->ZZ4_TPOPER
	_cCliente  := ZZ4->ZZ4_CODCLI
	_cLoja     := ZZ4->ZZ4_LOJA
	_cPCompr   := ZZ4->ZZ4_PCOMPR

	_cmpPrevCx := space(05)
	_cmpPrevPs := space(10)
	_cmpTotal  := space(12)
	_cmpObs    := space(100)
	_cmpDt     := space(10)
	_aTpOper   := CTBCBOX('ZZ4_TPOPER')
	_cCodCli   := space(6)
	_cCodLoj   := space(2)
	_cPedCom   := space(6)

	AADD(aButtons, {'FORM'   ,{||u_gjf28sld() , oDlg2:Refresh() }, 'Consulta Saldo' , 'Saldo'  } )

	aHead2    := {'Cod.Produto','Qt.Prev.Caix','Qt.Pre.Peso','Preco','Priorizar','Tolerancia','Descricao','Tipo Bonific','Bonificacao','Preco Final',;
	'Observacao','Cx.Reserv.?','Data Prod. In.','Data Prod. Fi.','User Alt.','Data Alter.','Hora Alt.' }
	//Largura das colunas
	//cod.prod     qt.prevcaix    qt.pre.peso   preco  priorizar    tolerancia   descricao  tipo bonific    bonificacao    preco final
	aLargCol2 := {      20     ,      30      ,       40    ,   40  ,     20    ,      40    ,     130   ,       20     ,      20     ,       20    ,;
	130    ,      30      ,       30    ,      30      ,       60    ,      30     ,     30    }
	//observacao    Cx Reserv    Data Prod In  Data Prod. Fi    User Alt    Data Alter.    Hora Alt.

	montabr2(_cNumPP)

	//Verifica a situação do cliente
	sit := gjf30v(ZZ4->ZZ4_CODCLI, ZZ4->ZZ4_LOJA)

	DEFINE MSDIALOG oDlg2 TITLE cCadastro from 00,00 To 570,855 OF oMainWnd PIXEL

	//DADOS DO PEDIDO
	oGrupo1  := tGroup():New(05, 10, 40, 390,'Dados do Pedido', oDlg2,,, .t.)

	@ 01,02 SAY "Data: "
	@ 12,35 MSGET _cmpDt VAR _dData PICTURE "99/99/9999" SIZE 40,08 of oDlg2 PIXEL
	@ 01,13 SAY "Pre-Pedido: " + ZZ4->ZZ4_NUM  of oDlg2
	@ 01,25 SAY "Tp. Operação: "
	@ 12,240 COMBOBOX _cTpOper items _aTpOper SIZE 50,08 of oDlg2 PIXEL
	@ 01,37 SAY "Cod.Pre.Carr: " + ZZ4->ZZ4_PRECAR of oDlg2
	@ 02,02 SAY "Qtd. Prev. Peso: "
	@ 24,60  MSGET _cmpPrevPs VAR _nPrevPs PICTURE "@E 999,999.99" SIZE 40,08 of oDlg2 PIXEL WHEN .F.
	@ 02,13 SAY "Qtd. Prev. Caixa: "
	@ 24,150 MSGET _cmpPrevCx VAR _nPrevCx PICTURE "@E 99999" SIZE 30,08 of oDlg2 PIXEL WHEN .F.
	@ 02,25 SAY "Total: "
	@ 24,217 MSGET _cmpTotal VAR _nTotal PICTURE "@E 9,999,999.99" SIZE 50,08 of oDlg2 PIXEL WHEN .F.
	@ 02,37 SAY "Ped. Compr.: "
	@ 24,330 MSGET _cPedCom VAR _cPCompr SIZE 50,08 of oDlg2 PIXEL WHEN .T.

	//DADOS DO CLIENTE
	oGrupo2  := tGroup():New(45, 10, 93, 390,'Dados do Cliente', oDlg2,,, .t.)

	@ 04,02 SAY "Codigo: " of oDlg2
	@ 04,10 SAY "Loja: " of oDlg2
	@ 04,14 SAY "Cliente: "       + substr(ZZ4->ZZ4_NOME,1,25) of oDlg2
	@ 04,30 SAY "Desconto: "      + transform(ZZ4->ZZ4_DESC,'@E 999.99') of oDlg2
	@ 04,37 SAY "Lim. Cred: "     + ZZ4->(iif(ZZ4_LIMCRE = 'L',"Liberado","Bloqueado")) of oDlg2
	@ 05,02 SAY "Cod. Repres.: "  + ZZ4->ZZ4_REPRES of oDlg2
	@ 05,10 SAY "Nome Repres.: "  + substr(ZZ4->ZZ4_NOMREP,1,25) of oDlg2
	@ 05,25 SAY "Valor Comis.: "  + transform(ZZ4->ZZ4_COMIS,'@E 99.99') of oDlg2
	@ 05,33 SAY "Cred. Vigente: " + alltrim(transform(ZZ4->ZZ4_CREVIG,'@E 999,999,999.99')) of oDlg2
	@ 06,02 SAY "Observação: "
	@ 51,36 MSGET _cCodCli VAR _cCliente SIZE 10,08 of oDlg2 PIXEL WHEN .T.
	@ 51,94 MSGET _cCodLoj VAR _cLoja SIZE 04,08 of oDlg2 PIXEL WHEN .T.
	@ 76,51 MSGET _cmpObs VAR _cObs SIZE 300,08 of oDlg2 PIXEL WHEN .T.

	//HISTORICO
	oGrupo3  := tGroup():New(97, 10, 140, 390,'Historico', oDlg2,,, .t.)

	@ 08,02 SAY "Hora Lib.: "     + ZZ4->ZZ4_HLIB of oDlg2
	@ 08,09 SAY "Data Lib.: "     + dtoc(ZZ4->ZZ4_DTLIB) of oDlg2
	@ 08,16 SAY "Usu. Lib.: " 	  + substr(ZZ4->ZZ4_USULIB,1,15) of oDlg2
	@ 08,26 SAY "Dt. Entrada: "   + dtoc(ZZ4->ZZ4_DTENT) of oDlg2
	@ 08,35 SAY "Hora Entrada: "  + ZZ4->ZZ4_HRENT of oDlg2
	@ 09,02 SAY "Hr.Cad.Portal: " + ZZ4->ZZ4_HORAC of oDlg2
	@ 09,09 SAY "Dt.Cad.Portal: " + dtoc(ZZ4->ZZ4_DATAC) of oDlg2
	@ 10,02 SAY iif(sit,"SITUAÇÃO FINANCEIRA APROVADA!","SITUAÇÃO FINANCEIRA IRREGULAR!")

	oBrowse2 := TCBrowse():New(160,00,427,100,,aHead2,aLargCol2,oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	// Seta vetor para a browse
	oBrowse2:SetArray(aBrowse2)

	// Monta a linha a ser exibina no Browse
	if len(aBrowse2) = 0//verifica se há algo no vetor para evitar error.log

		oBrowse2:bLine := {||{'','','','','','','','','','','','','','','','','',''} }

	else
		oBrowse2:bLine := {||{aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],transform(aBrowse2[oBrowse2:nAt,04],"@E 999,999.99"),;
		transform(aBrowse2[oBrowse2:nAT,05],"@E 999.99"),;
		aBrowse2[oBrowse2:nAT,06],aBrowse2[oBrowse2:nAT,07],aBrowse2[oBrowse2:nAT,08],;
		iif(aBrowse2[oBrowse2:nAT,09] = 'D', 'Desconto',;
		iif(aBrowse2[oBrowse2:nAT,09] = 'A','Acrescimo','')),;
		transform(aBrowse2[oBrowse2:nAT,10],"@E 99.99"),transform(aBrowse2[oBrowse2:nAT,11],"@E 999.99"),;
		aBrowse2[oBrowse2:nAT,12],aBrowse2[oBrowse2:nAT,13],aBrowse2[oBrowse2:nAT,14],;
		aBrowse2[oBrowse2:nAT,15],aBrowse2[oBrowse2:nAT,16],aBrowse2[oBrowse2:nAT,17],;
		aBrowse2[oBrowse2:nAT,18]} }
	endif

	oBrowse2:nScrollType := 1

	Set Key VK_F10 TO u_gjf28sld()

	TButton():New(270, 005, "Liberar"  , oDlg2,{|| Libera() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(270, 055, "Bloquear" , oDlg2,{|| Bloqueia()  },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(270, 105, "At.Preço" , oDlg2,{|| AtPreco()   },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(270, 330, "Sair"     , oDlg2,{|| oDlg2:end() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(270, 155, "SEFAZ"    , oDlg2,{|| u_gjf173(SA1->A1_COD,SA1->A1_LOJA,2) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(145, 005, "Alterar"  , oDlg2,{|| Alterar(ZZ4->ZZ4_NUM)   },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg2 CENTERED

	Set Key VK_F10 TO u_gjf28sld()

return


//Função para liberação de pedidos
Static Function Libera()

	Local stt   := ''
	Local i
	Local _cRepres := ""
	Local _lDesc := .F.

	//Verifica se existe algum item com mais de 30% de desconto
	if cEmpAnt = "01"
		ZZ5->(dbSetOrder(1))
		ZZ5->(MsSeek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
		while ZZ5->(!eof()) .and. ZZ5->ZZ5_NUM == ZZ4->ZZ4_NUM .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5')

			nDesc := (ZZ5->ZZ5_PRECO - ZZ5->ZZ5_PRCFIN) / ZZ5->ZZ5_PRECO
			if nDesc > 0.3
				FWAlertError("Produto " + alltrim(ZZ5->ZZ5_COD) + " tem desconto maior que 30%!","ALERTA!")
				_lDesc := .T.
			endif

			ZZ5->(dbskip())
		enddo
	endif

	if _lDesc
		if !FWAlertYesNo("Existem produtos com desconto maior que 30% neste pedido." + chr(13) + chr(10);
				+ "Deseja liberar mesmo assim?","CONFIRMA!")
			Return
		endif
	endif

	//Verifica a situação do cliente
	cli := gjf30v(_cCliente, _cLoja)

	if ZZ4->ZZ4_STATUS = 'E'
		stt := 'S'
	else
		stt := 'L'
	endif

	if ZZ4->ZZ4_TPOPER = 'B'
		if !msgbox('Deseja continuar a liberação deste pré-pedido? (S/N)','TIPO DE OPERAÇÃO DE BONIFICAÇÃO!','YESNO')
			return
		endif
	endif

	if !cli
		msgbox('Cliente em situação irregular!','LIBERAÇÃO NEGADA!','STOP')
		return
	else
		if _cCliente != ZZ4->ZZ4_CODCLI .or. _cLoja != ZZ4->ZZ4_LOJA
			_cRepres := GetAdvFVal('SA1','A1_VEND',FWxfilial('SA1')+_cCliente+_cLoja,1)
			reclock('ZZ4',.f.)
			ZZ4->ZZ4_CODCLI := _cCliente
			ZZ4->ZZ4_LOJA   := _cLoja
			ZZ4->ZZ4_NOME 	:= alltrim(GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+_cCliente+_cLoja,1))
			ZZ4->ZZ4_MUN 	:= alltrim(GetAdvFVal('SA1','A1_MUN',FWxfilial('SA1')+_cCliente+_cLoja,1))
			ZZ4->ZZ4_REPRES := _cRepres
			ZZ4->ZZ4_NOMREP := alltrim(GetAdvFVal('SA3','A3_NOME',FWxfilial('SA3')+_cRepres,1))
			ZZ4->ZZ4_COMIS  := GetAdvFVal('SA3','A3_COMIS',FWxfilial('SA3')+_cRepres,1)
			ZZ4->ZZ4_CREVIG := GetAdvFVal('SA1','A1_LC',FWxfilial('SA1')+_cCliente+_cLoja,1)
			ZZ4->ZZ4_PCOMPR := _cPCompr
			msunlock()

			//gjf30sit(ZZ4->ZZ4_CODCLI, ZZ4->ZZ4_LOJA)
		endif
	endif

	if (ZZ4->ZZ4_LIMCRE = 'B')
		msgbox('Entre em contato com o setor Financeiro!','LIMITE DE CREDITO DO CLIENTE EXCEDIDO!','STOP')
		return
	endif

	stcar := .f.
	ZZ5->(dbsetorder(1))
	ZZ5->(MsSeek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM))
	while ZZ5->(!eof()) .and. ZZ5->ZZ5_NUM == ZZ4->ZZ4_NUM .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5')

		if !empty(ZZ5->ZZ5_QRCAIX) .or. !empty(ZZ5->ZZ5_QRPESO)
			stt := 'S'
			exit
		endif

		ZZ5->(dbskip())
	enddo

	//Grava alterações na ZZ5
	for i := 1 to len(aBrowse2)

		ZZ5->(DbSetOrder(1))
		if ZZ5->(MsSeek(FWxfilial('ZZ5')+ZZ4->ZZ4_NUM + aBrowse2[i,01]))
			reclock('ZZ5',.f.)
			ZZ5->ZZ5_TPBONI :=  aBrowse2[i,09] //tipo de bonificacao
			ZZ5->ZZ5_BONIF  :=  aBrowse2[i,10] //bonificação
			ZZ5->ZZ5_QPCAIX :=  aBrowse2[i,03] //qntd. caixas
			ZZ5->ZZ5_QPPESO :=  aBrowse2[i,04] //qtd. em peso
			ZZ5->ZZ5_COD    :=  aBrowse2[i,02] //cod. do prod.
			ZZ5->ZZ5_DESC   :=  aBrowse2[i,08] //desc. do prod.
			ZZ5->ZZ5_PRECO  :=  aBrowse2[i,05] //preco do prod.
			ZZ5->ZZ5_PRCFIN :=  aBrowse2[i,11] //preco final do prod.
			msunlock()
		endif
	next

	if ZZ4->ZZ4_STATUS = 'E'
		ZZ3->(DbSetOrder(2))
		if ZZ3->(MsSeek(FWxfilial('ZZ3')+ZZ4->ZZ4_PRECAR))
			if ZZ3->ZZ3_STATUS = 'B'
				sttc := 'B'
			else
				sttc := 'S'
			endif

			reclock('ZZ3',.f.)
			ZZ3->ZZ3_STATUS := sttc
			msunlock()

		endif
	endif

	reclock('ZZ4',.f.)
	ZZ4->ZZ4_STATUS := stt
	ZZ4->ZZ4_HLIB   := time()
	ZZ4->ZZ4_DTLIB  := date()
	ZZ4->ZZ4_USULIB := cUserName
	ZZ4->ZZ4_QPCAIX := _nPrevCx
	ZZ4->ZZ4_QPPESO := _nPrevPs
	ZZ4->ZZ4_TOTAL  := _nTotal
	ZZ4->ZZ4_OBS    := _cObs
	ZZ4->ZZ4_DATA   := _dData
	ZZ4->ZZ4_TPOPER := _cTpOper
	ZZ4->ZZ4_CODCLI := _cCliente
	ZZ4->ZZ4_LOJA   := _cLoja
	ZZ4->ZZ4_PCOMPR := _cPCompr
	msunlock()

	oDlg2:end()

	montabrow()

	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg:refresh()

return

//Função que retorna a confirmação do bloqueio
Static Function Bloqueia()

	if _cCliente != ZZ4->ZZ4_CODCLI .or. _cLoja != ZZ4->ZZ4_LOJA
		_cRepres := GetAdvFVal('SA1','A1_VEND',FWxfilial('SA1')+_cCliente+_cLoja,1)
		reclock('ZZ4',.f.)
		ZZ4->ZZ4_CODCLI := _cCliente
		ZZ4->ZZ4_LOJA   := _cLoja
		ZZ4->ZZ4_NOME 	:= alltrim(GetAdvFVal('SA1','A1_NOME',FWxfilial('SA1')+_cCliente+_cLoja,1))
		ZZ4->ZZ4_MUN 	:= alltrim(GetAdvFVal('SA1','A1_MUN',FWxfilial('SA1')+_cCliente+_cLoja,1))
		ZZ4->ZZ4_REPRES := _cRepres
		ZZ4->ZZ4_NOMREP := alltrim(GetAdvFVal('SA3','A3_NOME',FWxfilial('SA3')+_cRepres,1))
		ZZ4->ZZ4_COMIS  := GetAdvFVal('SA3','A3_COMIS',FWxfilial('SA3')+_cRepres,1)
		ZZ4->ZZ4_CREVIG := GetAdvFVal('SA1','A1_LC',FWxfilial('SA1')+_cCliente+_cLoja,1)
		ZZ4->ZZ4_PCOMPR := _cPCompr
		ZZ4->ZZ4_STATUS := 'B'
		msunlock()
	else
		reclock('ZZ4',.f.)
		ZZ4->ZZ4_STATUS := 'B'
		msunlock()
	endif

	oDlg2:end()

	montabrow()

	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg:refresh()

return

//Verifica a situação do cliente a abrevia a digitação de codigos
Static Function gjf30v(_cCli, _cLoj)

	_Bloq := GetAdvFVal('SA1','A1_MSBLQL',FWxfilial('SA1')+_cCli+_cLoj,1)

	sit := iif(_Bloq = '1',.f.,.t.)

return(sit)


User Function gjf30des(_num)
	if !empty(ZZ4->ZZ4_DESC)
		return .t.
	endif
	ZZ5->(dbsetorder(1))
	ZZ5->(MsSeek(FWxfilial('ZZ5')+_num))
	_lDesc := .f.
	while ZZ5->(!eof()) .and. _num = ZZ5->ZZ5_NUM  .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5')
		if  !empty(ZZ5->ZZ5_TPBONI)
			_lDesc := .t.
			exit
		endif
		ZZ5->(dbskip())
	enddo
return _lDesc

//Monta browse
Static Function montabrow()

	// Vetor com elementos do Browse
	aBrowse1 := {}

	//Ordena por pre-carregamento e marcas
	ZZ4->(DbSetOrder(1))
	ZZ4->(MsSeek(FWxfilial('ZZ4') + mv_par01))

	while ZZ4->(!eof()) .and. ZZ4->ZZ4_FILIAL = FWxfilial('ZZ4')  .and. ZZ4->ZZ4_PRECAR <= mv_par02

		do case
			case mv_par03 == 1
			if ZZ4->ZZ4_STATUS $ 'C/F'
				ZZ4->(DbSkip())
				loop
			endif
			case mv_par03 == 2
			if ZZ4->ZZ4_STATUS $ 'E/C/F' .or. ZZ4->ZZ4_STATUS <> 'B'
				ZZ4->(DbSkip())
				loop
			endif
			case mv_par03 == 3
			if ZZ4->ZZ4_STATUS $ 'C/F' .or. !(ZZ4->ZZ4_STATUS $ 'L/E')
				ZZ4->(DbSkip())
				loop
			endif
		endcase

		_Stt := ZZ4->ZZ4_STATUS

		aadd(aBrowse1,{RetCores(_Stt),ZZ4->ZZ4_NUM,ZZ4->ZZ4_MARCA,ZZ4->ZZ4_DATA,;
		ZZ4->ZZ4_CODCLI,ZZ4->ZZ4_LOJA,ZZ4->ZZ4_NOME,ZZ4->ZZ4_MUN})

		ZZ4->(DbSkip())
	enddo

	if len(aBrowse1) = 0
		aadd(aBrowse1,{RetCores('B'),'','','','','','',''})
	endif

	// Seta vetor para a browse
	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse

	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAT,02],aBrowse1[oBrowse1:nAT,03],;
	aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06],;
	aBrowse1[oBrowse1:nAT,07],aBrowse1[oBrowse1:nAT,08]} }

	oBrowse1:nScrollType := 1
	oBrowse1:bLDblClick  := {|| ordena(oBrowse1:ColPos()) }

return

Static Function montabr2(_cNumPP)

	// Vetor com elementos do Browse
	aBrowse2 := {}

	//Ordena por pre-carregamento e marcas
	ZZ5->(DbSetOrder(1))
	ZZ5->(MsSeek(FWxfilial('ZZ5') + _cNumPP))

	while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ5') .and. ZZ5->ZZ5_NUM = _cNumPP

		aadd(aBrowse2,{ZZ5->ZZ5_ITEM,ZZ5->ZZ5_COD,ZZ5->ZZ5_QPCAIX,ZZ5->ZZ5_QPPESO,ZZ5->ZZ5_PRECO,ZZ5->(iif(ZZ5_PRIORI = 'C','Caixa',;
		iif(ZZ5_PRIORI = 'P','Peso','Automatico'))),;
		ZZ5->ZZ5_TOLERA,ZZ5->ZZ5_DESC,ZZ5->ZZ5_TPBONI,ZZ5->ZZ5_BONIF,ZZ5->ZZ5_PRCFIN,;
		ZZ5->ZZ5_OBS,ZZ5->(iif(ZZ5_RESERV = 'N','Nao','Sim')),ZZ5->ZZ5_DTPINI,ZZ5->ZZ5_DTPFIM,ZZ5->ZZ5_USERAL,;
		ZZ5->ZZ5_DATAAL,ZZ5->ZZ5_HORAAL})

		ZZ5->(DbSkip())
	enddo

return


Static Function RetCores(_Stt)
	local ret   := iif(_Stt = 'B', LoadBitmap(GetResources(),'br_azul'),iif(_Stt = 'L',LoadBitmap(GetResources(),'br_verde'),;
	iif(_Stt = 'C', LoadBitmap(GetResources(),'br_amarelo'),iif(_Stt = 'S',LoadBitmap(GetResources(),'br_laranja'),;
	iif(_Stt = 'E', LoadBitmap(GetResources(),'br_vermelho'),iif(_Stt = 'F',LoadBitmap(GetResources(),'br_preto'),''))))))

return  ret


Static Function GetPrec(_Cod)
	prc := 0
	area := getarea()

	cQuery := " SELECT DA1_PRCVEN
	cQuery += " FROM  " + RetSqlTab('SA1') + "  ,  " + RetSqlTab('DA1') + "  ,  " + RetSqlTab('DA0')
	cQuery += " WHERE " + RetSQLFil('SA1') + " AND " + RetSQLFil('DA1') + " AND " + RetSQLFil('DA0')"
	cQuery += " AND DA1_CODPRO = '" + _Cod + "'"
	cQuery += " AND A1_COD     = '" + ZZ4->ZZ4_CODCLI + "'"
	cQuery += " AND A1_LOJA    = '" + ZZ4->ZZ4_LOJA + "'"
	cQuery += " AND DA0_CODTAB = DA1_CODTAB"
	cQuery += " AND DA0_CODTAB = A1_TABELA"
	cQuery += " AND " + RetSQLDel('SA1') + " AND " + RetSQLDel('DA1') + " AND " + RetSQLDel('DA0')

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

//Função para atualizar preço
Static Function AtPreco()
	Local _lExist := .f.
	local _lFlag  := .f.
	Local i

	for i := 1 to len(aBrowse2)
		_cTpBoni  := aBrowse2[i,09] //tipo de bonificação
		_cCodPro  := aBrowse2[i,02] //cod do produto
		_nPrecPro := aBrowse2[i,05] //preço do produto
		_nBonif   := aBrowse2[i,10] //bonificação

		//chama função que retorna o preço do produto cadastrado na tabela
		_nPrecTab := GetPrec(_cCodPro)

		if _nPrecTab <> _nPrecPro
			if msgbox('Preço' + transform(_nPrecPro,'@E 999.99') + '  divergente de '+;
			transform(_nPrecTab,'@E 999.99') +'. Deseja atualizar preço?',;
			'Divergência produto ' + alltrim(_cCodPro),'YESNO')

				aBrowse2[i,5] := _nPrecTab

				if empty(_cTpBoni)
					aBrowse2[i,11] := _nPrecTab
					aBrowse2[i,10] := 0
				elseif substr(_cTpBoni,1,1) = 'D'
					aBrowse2[i,11] := (_nPrecTab - _nBonif)
				elseif substr(_cTpBoni,1,1) = 'A'
					aBrowse2[i,11] := (_nPrecTab + _nBonif)
				endif

				_lFlag := .t.
			endif
		endif

	next

	if _lFlag = .f.
		//alert('Não há preços alterados!!')
		MsgInfo('Não há preços alterados!!')
	else
		oBrowse2:DrawSelect()
	endif
return


Static Function Alterar(_cNum)

	Private _cItem     := aBrowse2[oBrowse2:nAt,01] //item do pre-pedido
	Private _cTpBoni   := aBrowse2[oBrowse2:nAt,09] //tipo de bonificacao
	Private _nBonif    := aBrowse2[oBrowse2:nAt,10] //bonificação
	Private _nCaix     := aBrowse2[oBrowse2:nAt,03] //qntd. caixas
	Private _nPeso     := aBrowse2[oBrowse2:nAt,04] //qtd. em peso
	Private _cCod      := aBrowse2[oBrowse2:nAt,02] //cod. do prod.
	Private _cDescri   := aBrowse2[oBrowse2:nAt,08] //desc. do prod.
	Private _nPreco    := aBrowse2[oBrowse2:nAt,05] //preco do prod.
	Private _nPrcFin   := aBrowse2[oBrowse2:nAt,11] //preco final do prod.
	Private oDlgA      := NIL
	Private _aTpBoni   := CTBCBOX('ZZ5_TPBONI')
	Private _cmpCx     := space(04)
	Private _cmpPs     := space(07)
	Private _cmpCod    := space(06)
	Private _cmpPrc    := space(06)
	Private _cmpPrcFin := space(06)
	Private _cmpDesc   := space(40)
	Private _cmpBonif  := space(06)

	@ 116,010 To 425,425 Dialog oDlgA Title "Alteração do Pedido"

	@ 001,001 SAY 'Cod. Prod: '
	@ 011,040 MSGET _cmpCod  VAR _cCod PICTURE "@E 999999" SIZE 30,08 F3 "SB1" of oDlgA PIXEL
	@ 011,077 MSGET _cmpDesc VAR alltrim(_cDescri) SIZE 100,08 of oDlgA PIXEL WHEN .F.

	@ 002,001 SAY 'Qt.Prev.Caix: '
	@ 025,045 MSGET _cmpCx VAR _nCaix PICTURE "@E 9999" SIZE 30,08 of oDlgA PIXEL VALID iif(_nCaix <= 0,.f.,.t.)

	@ 002,010 SAY 'Qt.Prev.Peso: '
	@ 025,117 MSGET _cmpPs VAR _nPeso PICTURE "@E 9,999.99" SIZE 30,08 of oDlgA PIXEL VALID iif(_nPeso <= 0,.f.,.t.)

	@ 003,001 SAY 'Tp. Bonif.: '
	@ 039,040 COMBOBOX _cTpBoni items _aTpBoni SIZE 40,08 of oDlgA PIXEL

	@ 003,010 SAY 'Bonificação: '
	@ 039,121 MSGET _cmpBonif VAR _nBonif PICTURE "@E 999.99" SIZE 30,08 of oDlgA PIXEL

	@ 004,001 SAY 'Preco: '
	@ 052,040 MSGET _cmpPrc VAR _nPreco PICTURE "@E 999.99" SIZE 30,08 of oDlgA PIXEL WHEN .F.

	@ 004,011 SAY 'Prec. Fin.: '
	@ 052,121 MSGET _cmpPrcfin VAR _nPrcFin PICTURE "@E 999.99" SIZE 30,08 of oDlgA PIXEL WHEN .F.

	_cmpCX:bLostFocus     := {|| gjf30pmc(_nCaix)  }
	_cmpPs:bLostFocus     := {|| gjf30cmp(_nPeso)  }
	_cmpCod:bLostFocus    := {|| gjf30prod(_cCod)  }
	_cmpBonif:bLostFocus  := {|| gjf30bonif(_nBonif,_cTpBoni) }
	oDlgA:refresh()

	@ 138,040  BUTTON 'Ok'   SIZE 40,15 ACTION ConfAlt()  OBJECT oBtn10
	@ 138,120  BUTTON 'Cancelar'   SIZE 40,15 ACTION oDlgA:end()  OBJECT oBtn10
	Activate Dialog oDlgA CENTERED

return

//Converte caixa pra peso
Static Function gjf30pmc(_nCaix)
	pmedio := 0
	prod 	 := aBrowse2[oBrowse2:nAt,02]
	SB1->(dbsetorder(1))
	if SB1->(MsSeek(FWxfilial('SB1')+prod))
		pmc    := SB1->B1_PMCAIX
		pmedio := (_nCaix * pmc)
		_nPeso := pmedio
	endif
	oDlgA:refresh()
return

//Função inversa a de cima
Static Function gjf30cmp(_nPeso)
	caixas := 0
	prod   := aBrowse2[oBrowse2:nAt,02]

	SB1->(dbsetorder(1))
	if SB1->(MsSeek(FWxfilial('SB1')+prod))
		cmp   := SB1->B1_PMCAIX
		ncaix := round(_nPeso/cmp,0)
		_nCaix := ncaix
		oDlgA:refresh()
		return
	endif
	oDlgA:refresh()
return caixas

//retorna a descrição do produto
Static Function gjf30prod(_cCod)
	SB1->(DbSetOrder(1))
	if SB1->(MsSeek(FWxfilial('SB1')+_cCod))
		_cDescri   := SB1->B1_DESCRED
		_nPrecTab := GetPrec(_cCod)
		_nPreco   := _nPrecTab
		_nPrcFin  := _nPreco
	endif

	oDlgA:refresh()
return

//retorna a o valor da bonificação
Static Function gjf30bonif(_nBonifi,_cTpBoni)

	if empty(_cTpBoni)
		_nPrcFin := _nPreco
		_nBonif  := 0
	elseif substr(_cTpBoni,1,1) = 'D'
		_nPrcFin := (_nPreco - _nBonifi)
	elseif substr(_cTpBoni,1,1) = 'A'
		_nPrcFin := (_nPreco + _nBonifi)
	endif

	oDlgA:refresh()
return

//atualiza o browse2 com as informações da alteração
Static Function ConfAlt()

	Local i
	aBrowse2[oBrowse2:nAt,09] := _cTpBoni //tipo de bonificacao
	aBrowse2[oBrowse2:nAt,10] := _nBonif  //bonificação
	aBrowse2[oBrowse2:nAt,03] :=  _nCaix  //qntd. caixas
	aBrowse2[oBrowse2:nAt,04] := _nPeso   //qtd. em peso
	aBrowse2[oBrowse2:nAt,02] := _cCod    //cod. do prod.
	aBrowse2[oBrowse2:nAt,08] := _cDescri //desc. do prod.
	aBrowse2[oBrowse2:nAt,05] := _nPreco  //preco do prod.
	aBrowse2[oBrowse2:nAt,11] := _nPrcFin //preco final do prod.
	_nPrevPs := 0
	_nPrevCx := 0
	_nTotal  := 0

	for i = 1 to len(aBrowse2)
		_nPrevPs += aBrowse2[i,04]
		_nPrevCx += aBrowse2[i,03]
		_nTotal  += aBrowse2[i,04] * aBrowse2[i,11]
	next

	oBrowse2:DrawSelect()
	oDlgA:end()
	oDlg2:refresh()
return

//função para ordenação do browse
Static Function ordena(_Ord)
	if _Ord = _UltOrd
		aBrowse1 := aSort(aBrowse1,,, {|x, y| x[_Ord] > y[_Ord]})
		_UltOrd := 0
	else
		aBrowse1 := aSort(aBrowse1,,, {|x, y| x[_Ord] < y[_Ord]})
		_UltOrd := _Ord
	endif

	// Seta vetor para a browse
	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse

	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAT,02],aBrowse1[oBrowse1:nAT,03],;
	aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06],;
	aBrowse1[oBrowse1:nAT,07],aBrowse1[oBrowse1:nAT,08]} }

	oBrowse1:nScrollType := 1
	oBrowse1:bLDblClick     := {|| ordena(oBrowse1:ColPos()) }

	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg:refresh()
return
