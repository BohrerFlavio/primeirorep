#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "totvs.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI218  ºAutor  ³ Adonai Gabriel         º Data ³  10/01/25 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle de tranferencias de MP                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DTI218()

	Private lInverte := .f.
	Private cMark    := GetMark()
	Private oMark
	Private aRotina  := {}
	Private aObjects := {}
	Private aPosObj  := {}
	Private aInfo    := {}
	Private aSizeAut := MsAdvSize()
	Private nUltItem := 0
	Private _nCont 	 := 0

	AAdd(aObjects, {315, 50, .T., .T.})
	AAdd(aObjects, {100, 100, .T., .T.})
	aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
	aPosObj := MsObjSize(aInfo, aObjects, .T.)

	aX           := aPosObj[1]
	aX[3]        += 60
	aPosObj[1]   := aX
	aPosObj[2,1] += 60

	Private cPerg     := "DTI218"
	Private cCadastro := "Controle de Transferencias p/ Porcionados"

	aRotina := {{"Pesquisar"  ,"AxPesqui"   ,0,1},;
				{"Visualizar" ,"u_DTI218V " ,0,2},;
				{"Incluir"    ,"u_DTI218I"  ,0,3},;
				{"Alterar"    ,"u_DTI218A"  ,0,4},;
				{"Excluir"    ,"u_DTI218X"  ,0,5},;
				{"Transferir" ,"u_DTI218T"  ,0,4},;
				{"Estornar"   ,"u_DTI218S"  ,0,4},;
				{"Encerrar"   ,"u_DTI218E"  ,0,4},;
				{"Liberar"    ,"u_DTI218L"  ,0,4},;
				{"Receber"    ,"u_DTI218R"  ,0,4},;
				{"Legenda"    ,"u_DTI218G"  ,0,1}}

	private cString := "ZMP"

	if !pergunte(cPerg,.t.)
		return
	endif

	Private bLegenda1 := "ZMP->ZMP_STATUS = 'A'"
	Private bLegenda2 := "ZMP->ZMP_STATUS = 'T'"
	Private bLegenda3 := "ZMP->ZMP_STATUS = 'E'"
	Private bLegenda4 := "ZMP->ZMP_STATUS = 'R'"

	Private aCores :=  {{bLegenda1, 'BR_AZUL'    },;       // Transferencia Aberta
                        {bLegenda2, 'BR_AMARELO' },;       // Transferencia Em andamento
                        {bLegenda3, 'BR_VERMELHO'},;       // Transferencia Encerrada
                        {bLegenda4, 'BR_VERDE'   }}        // Transferencia Recebida

	Private aCores2 := {{'BR_AZUL'    ,'Aberta'      },;   // Transferencia Aberta
                        {'BR_AMARELO' ,'Em andamento'},;   // Transferencia Em andamento
                        {'BR_VERMELHO','Encerrada'   },;   // Transferencia Encerrada
                        {'BR_VERDE'   ,'Recebida'    }}    // Transferencia Recebida

	dbSelectArea(cString)
	ZMP->(dbSetOrder(1))
	ZMP->(dbgobottom())

	cCondicao := "ZMP_DATA >=  '" + dtos(mv_par01) + "' AND ZMP_DATA <=  '" + dtos(mv_par02) + "'" + " AND ZMP_FILIAL = '" + FWxfilial('ZMP') + "'"

	mBrowse(6,1,22,75,cString,,,,,2,aCores,,,,,,,,cCondicao)

	If Select('ZMP') <> 0
		ZMP->(dbCloseArea())
	Endif

Return

//Disponibiliza a legenda
User Function DTI218G(cAlias,nReg,nOpc)
	BrwLegenda(cCadastro,"Legenda",aCores2)
Return

//Função destinada a visualização de transferencias
User Function DTI218V(cAlias,nReg,nOpc)
	Local oDlg		:= NIL
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("ZMP")

	DTI218Ahead("ZMQ")                                                           //Monta oa vetor aHeader

	nUsado := Len(aHeader)

	DTI218Acols(nOpc)															//Monta oa vetor aCols

	oEnc := MsMGet():New("ZMP" ,ZMP->(RECNO()), nOpc,,,,, aPosObj[1]  ,,3,,,,oDlg,,,.F. )
	oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],nOpc,"AllwaysTrue","AllwaysTrue","+ZMQ_ITEM",.T.)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()}, {||oDlg:End()}, , aButtons)

return

//Função destinada a inclusão de transferencias
User Function DTI218I(cAlias,nReg,nOpc)
	Local oDlg		:= NIL
	Local lOk 		:= .F.
	Local aButtons	:= {}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private nUsado	:=	0
	Private oGet	:= NIL
	Private aGets	:= {}
	Private aTela	:= {}

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	_cTransf := getSx8Num('ZMP','ZMP_NUM')
	nUsado := DTI218Ahead("ZMQ")
	GeraItens()
	DTI218Acols(nOpc)

	RegToMemory("ZMP",.T.)

	M->ZMP_NUM := _cTransf

	oEnc := MsMGet():New("ZMP",ZMP->(RECNO()),nOpc,,,,,aPosObj[1],,3,,,,oDlg,,,.F.)
	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"u_DTI218LinOk(n,'I')","u_DTI218TudOk","+ZMQ_ITEM",.T.,,,.F.,999,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := U_DTI218TudOk().and.Obrigatorio(aGets,aTela).and.u_DTI218LinOk(n,'I'),Iif(lOk,oDlg:End(),)},{||oDlg:End()},,aButtons)

	If  lOk
		ConfirmSx8()
		DTI218Grav(nOpc)
	else
		RollBackSX8()
	Endif

return

//Função destinada a alteração de transferencias
User Function DTI218A(cAlias,nReg,nOpc)

	Local oDlg		    := NIL
	Local lOk 		    := .F.
	Local aButtons	    := {}
	Private aHeader	    := {}
	Private aCols	    := {}
	Private nUsado	    :=	0
	Private oGet	    := NIL
	Private aGets	    := {}
	Private aTela	    := {}

	DbSelectArea(cAlias)

	DEFINE MSDIALOG oDlg TITLE cCadastro from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	nUsado := DTI218Ahead("ZMQ")                                                 //Monta o aHeader

	DTI218Acols(nOpc)                                                            //Monta o Acols

	RegtoMemory('ZMP')

	oEnc := MsMGet():New("ZMP",ZMP->(RECNO()),nOpc,,,,,aPosObj[1],,3,,,,oDlg,,,.F.)
	oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"u_DTI218LinOk(n,'A')","u_DTI218TudOk","+ZMQ_ITEM",.T.,,,.F.,999,,,,)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := u_DTI218TudOk().and.u_DTI218LinOk(n,'A').and.Obrigatorio(aGets,aTela),Iif(lOk,oDlg:End(), oDlg:refresh())}, {||oDlg:End()}, , aButtons)

	If lOk
		DTI218Grav(nOpc)
	Endif

Return

//Função para encerrar a transferencia
User Function DTI218E()
    if FWAlertYesNo('Tem certeza que deseja encerrar essa transferência?','ATENÇÃO')
        if ZMP->ZMP_STATUS = 'A' .and. ZMP->ZMP_TOTTRA <= 0
            FWAlertError('Status da transferência impede a operação.','OPERACAO INVALIDA')
        elseif ZMP->ZMP_STATUS = 'E'
			if ZMP->ZMP_TOTREC <= 0
				FWAlertError('Nenhuma caixa recebida, operação inválida!','ERRO')
			else
				reclock('ZMP',.f.)
				ZMP->ZMP_STATUS := 'R'
				msunlock()
				FWAlertInfo('Operação de transferencia marcada como recebida.','INFO')
			endif
        else
            reclock('ZMP',.f.)
            ZMP->ZMP_STATUS := 'E'
            msunlock()
			DeleteItens(ZMP->ZMP_NUM)
            FWAlertInfo('Operação de transferencia encerrada.','INFO')
        endif
    endif
return

//Exclui permanentemente os itens sem caixas transferidas
Static Function DeleteItens(_cTransf)
	Local _cQuery := ""
	_cQuery := "DELETE FROM " + RetSqlName("ZMQ")
	_cQuery += " WHERE ZMQ_FILIAL = '" + FWxFilial("ZMQ") + "'"
	_cQuery += " AND ZMQ_NUM = '" + _cTransf + "'"
	_cQuery += " AND ZMQ_QUANT <= 0"

	If TcSQLExec(_cQuery) < 0	
		MsgStop(TcSqlError())
	Endif
Return 

//Montagem do aCols
static Function DTI218Acols(nOpc)
	Local nI, nPos

	If nOpc == 3

		/*aCols := Array(1,nUsado+1)

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

		aCols[1,nUsado+1] := .F.*/
	Else

		RegToMemory("ZMP")

		dbSelectArea("ZMQ")
		dbSetOrder(1)
		MsSeek(FWxFilial('ZMQ')+ZMP->ZMP_NUM,.T.)

		Do While ZMQ->(!Eof()) .and. FWxFilial('ZMQ') ==  ZMQ->ZMQ_FILIAL .and. ZMQ->ZMQ_NUM == ZMP->ZMP_NUM
			aAdd(aCols,Array(nUsado+1))

			For nI := 1 to nUsado
				If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
					aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Else										// Campo Virtual
					cCpo := AllTrim(Upper(aHeader[nI,2]))
					aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Endif
			Next nI

			nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZMQ_ITEM"})
            if nPos > 0
                aCols[1,nPos]	:= StrZero(len(acols)+1,Len(aCols[1,nPos]))
            endif
            aCols[Len(aCols),nUsado+1] := .F.

			ZMQ->(DbSkip())
		Enddo

	Endif

Return

//Monta o aHeader
Static Function DTI218Ahead(cAlias)

	Local i
	aHeader := {}

	_cAlias  := cAlias 		// ZMQ
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i],'X3_USADO')) .And. AllTrim(GetSx3Cache(_aCpoSX3[i],'X3_CAMPO')) != "ZMQ_FILIAL" .And. AllTrim(GetSx3Cache(_aCpoSX3[i],'X3_CAMPO')) != "ZMQ_NUM")
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
Static Function DTI218Grav(nOpc)

	Local nIt
	Local nCont
    Local nNumItem
	Local nPosDel 		:= Len(aHeader) + 1
	Local nCpo
	Local bCampo		:= { |nCPO| Field(nCPO) }
	Local lGraOk 		:= .T.                              // Indica se todas as gravacoes obtiveram sucesso
	Local _cDesc 		:= ""

	Begin Transaction

		DbSelectArea("ZMP")
		DbSetOrder(1)
		If INCLUI
			//Se a opção foi de incluir registros, faz isso
			RecLock("ZMP",.T.)
		Else
			RecLock("ZMP",.F.)
		Endif

		For nCont := 1 To FCount()
			If "FILIAL"$Field(nCont)
				FieldPut(nCont,FWxFilial("ZMP"))
			Else
				FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
			Endif
		Next nCont
		ZMP->ZMP_USERIN := cUserName
		MsUnLock()

		DbSelectArea("ZMQ")
		DbSetOrder(1)
        nNumItem := 1  // Contador para os Itens

		For nIt := 1 To Len(aCols)
			If aCols[nIt, nPosDel]  // Verifica se o item foi deletado
				If MsSeek(FWxFilial("ZMQ") + M->ZMP_NUM + StrZero(nIt,3))
					RecLock("ZMQ",.F.)
					DbDelete()
					MsUnlock()
				Endif
			Endif
		Next

		For nIt := 1 To Len(aCols)

			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

				_cDesc := GetAdvFVal("SB1","B1_DESCRED",FWxFilial("SB1")+aCols[nIt, 1],1)
				If ALTERA
					If MsSeek(FWxFilial("ZMQ")+ M->ZMP_NUM + StrZero(nIt,3))
						RecLock("ZMQ",.F.)
					Else
						RecLock("ZMQ",.T.)
					Endif
				Else
					RecLock("ZMQ",.T.)
				Endif

				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
						ZMQ->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo

				ZMQ->ZMQ_FILIAL	 := FWxFilial("ZMQ")
				ZMQ->ZMQ_NUM	 := ZMP->ZMP_NUM
                ZMQ->ZMQ_ITEM    := strzero(nNumItem,3)
				ZMQ->ZMQ_DESC	 := _cDesc

                nNumItem++
				MsUnlock()
			Endif
		Next nIt

	End Transaction

Return lGraOk

//Função para gerar os itens de transferência automaticamente
Static Function GeraItens()
	Local i := 0
	Local _cCodMP := "011760/011061/019231/012648/012109/011761/011766/010826/010827/012252/020715/011763/012254/026546/026545"
	Local _aCodMP := StrTokArr(_cCodMP, '/')

	for i := 1 to len(_aCodMP)
		aadd(aCols, {_aCodMP[i],GetAdvFVal("SB1","B1_DESCRED",FWxFilial("SB1")+_aCodMP[i],1),0,0,.F.})
	next
Return 

//Testa todo aCols
User Function DTI218TudOk()

	Local lRetorno	:= .T.
	Local nTot		:= 0
	Local nX
	Local nI

	If Empty(M->ZMP_NUM) .or. nTot == Len(aCols)
		lRetorno := .F.
		FWAlertWarning("Campo obrigatório não preenchido!","ALERTA!")  // Campos obrigatorios
	EndIf

	If INCLUI
		If ZMP->(MsSeek(FWXFILIAL("ZMP") + M->ZMP_NUM))
			lRetorno := .F.
			FWAlertWarning("Transferência já existe!",1,"ALERTA!")  // Campo ja Existe
		Endif
	Endif

	_nTam := Len(aCols)

	for nX := 1 To _nTam
		_ColCod := GDFieldGet('ZMQ_COD',nX)
		For nI := 1 To _nTam
			if (GDFieldGet('ZMQ_COD',nI) = _ColCod) .and. (nI <> nX)
				FWAlertError('Produtos da transferência repetidos!','ERRO!')
				lRetorno := .F.
				exit
			endif
		Next nI
	Next nX

Return lRetorno

//Teste de validação da linha do grid
User Function DTI218LinOk(n,op)

	Local lRetorno 	:= .T.
	Local nPosDel 	:= Len(aHeader) + 1
	Local nCpo
	Local nI
	Local nX

	if lRetorno
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
					FWAlertError('Produtos da transferência repetidos! ('+ _ColCod + ')','ERRO!')
					lRetorno := .f.
					exit
				endif
			Next nI
		Next nX
	endif

	if lRetorno
        if empty(aCols[n,1])
            FWAlertWarning('Produto não informado!','OPERAÇÃO IRREGULAR!')
            lRetorno := .F.
        endif
	endif

Return lRetorno

//Função para liberar novamente a transferencia
User Function DTI218L()
	if FWAlertYesNo('Tem certeza que deseja liberar essa transferência?','ATENÇÃO')
        if ZMP->ZMP_STATUS $ 'R/T/A'
            FWAlertError('Status da transferência impede a operação.','OPERACAO INVALIDA')
        else
            reclock('ZMP',.f.)
            ZMP->ZMP_STATUS := 'A'
            msunlock()
            FWAlertInfo('Operação de transferencia liberada.','INFO')
        endif
    endif
return

//Função para excluir transferencia
User Function DTI218X()
    if FWAlertYesNo('Tem certeza que deseja excluir essa transferência?','ATENÇÃO')
        if ZMP->ZMP_STATUS = 'R'
            FWAlertError('Status da transferência impede a operação.','OPERACAO INVALIDA')
        else
            ZMQ->(DbSetOrder(1)) 
            if ZMQ->(MsSeek(FWxfilial('ZMQ') + ZMP->ZMP_NUM))
                while ZMQ->(!eof()) .and. ZMQ->(ZMQ_FILIAL + ZMQ_NUM) = ZMP->(ZMP_FILIAL + ZMP_NUM)
                    reclock('ZMQ',.f.) 
                    dbdelete()
                    msunlock()
                    ZMQ->(DbSkip())
                enddo
            endif	
            reclock('ZMP',.f.)
            dbdelete()
            msunlock()              
            FWAlertInfo('Operação de transferencia excluída.','INFO')
        endif
    endif
return

//Mostra mensagem na janela
Static Function SetMsg(_cMsg1, _cMsg2, _cMsg3, _cMsg4)
	oSayD1:SetText(_cMsg1)
	oSayD2:SetText(_cMsg2)
	if !empty(_cMsg3)
		oSayI1:SetText(_cMsg3)
	endif
	if !empty(_cMsg4)
		oSayI2:SetText(_cMsg4)
	endif
	oDlgT:refresh()
Return

//Função para realizar a transferencia e leitura das caixas
User Function DTI218T()
	//Cria a caixa de diálogo para localizar uma caixa
	Local cCaixa := space(11)
	Local _Mens1 := ''
	Local _Mens2 := ''
	Local _Mens3 := ''
	Local campo  := space(11)
	_nCont 		 := ZMP_TOTTRA

	_Mens3 := 'Total = ' + Transform(_nCont, "@E 999")

	DEFINE MSDIALOG oDlgT TITLE 'Localização de caixas para transferencia:' from 000,000 To 150,400 OF oMainWnd PIXEL
	@ 10,03 SAY  'Caixa:' Object oSay1

	@ 01,04  MSGET campo VAR cCaixa SIZE 60,11 OF oDlgT VALID ValidTran(cCaixa)
	oFont1  := tFont():New("courier new",,-20,,.t.,,,,)
	oFont2  := tFont():New("courier new",,-15,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _Mens1 },oDlgT,,oFont1,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	oSayD2  := tSay():New(30,10,{|| _Mens2 },oDlgT,,oFont1,,,,.T.,CLR_HRED,CLR_HRED,200,35)
	oSayI1  := tSay():New(10,145,{|| _Mens3 },oDlgT,,oFont2,,,,.T.,CLR_BLACK,CLR_BLACK,100,30)

	@ 60,160 BMPBUTTON TYPE 1 ACTION oDlgT:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgT
Return

//Função de verificação e gravação de transferência nas caixas
Static Function ValidTran(cCaixa)
	Local _lSZ8  := .f.
	Local _lZAS  := .f.
	Local _cCod  := ""
	Local _cDesc := ""

	if empty(cCaixa)
		return .t.
	endif

	SZ8->(DbGoTop())
	SZ8->(DbSetOrder(3))
	ZAS->(DbGoTop())
	ZAS->(DbSetOrder(1))
	if ZAS->(MsSeek(FWxfilial('ZAS') + alltrim(cCaixa)))
		_lZAS := .t.
		_cCod := ZAS->ZAS_COD
	elseif SZ8->(MsSeek(FWxfilial('SZ8') + alltrim(cCaixa)))
		_lSZ8 := .t.
		_cCod := SZ8->Z8_COD
	else
		Sinv(2)
		SetMsg('','Caixa não encontrada!')
		return .f.
	endif

	if _lZAS
		if !empty(ZAS->ZAS_DTRMP) .and. !empty(ZAS->ZAS_CODTRA)
			Sinv(2)
			SetMsg('','Caixa já foi recebida nos Porcionados!')
			return .f.
		endif
	elseif _lSZ8
		if !empty(SZ8->Z8_DTRPOR) .and. !empty(SZ8->Z8_CODTRAI)
			Sinv(2)
			SetMsg('','Caixa já foi recebida nos Porcionados!')
			return .f.
		endif
	endif

	if _lZAS
		if !empty(ZAS->ZAS_CODTRA)
			if ZAS->ZAS_CODTRA = ZMP->ZMP_NUM
				Sinv(2)
				SetMsg('','Caixa já transferida!')
				return .f.
			elseif ZAS->ZAS_CODTRA != ZMP->ZMP_NUM
				Sinv(2)
				SetMsg('','Caixa em outra transferência!')
				return .f.
			endif
		endif
	elseif _lSZ8
		if !empty(SZ8->Z8_CODTRAI)
			if SZ8->Z8_CODTRAI = ZMP->ZMP_NUM
				Sinv(2)
				SetMsg('','Caixa já transferida!')
				return .f.
			elseif SZ8->Z8_CODTRAI != ZMP->ZMP_NUM
				Sinv(2)
				SetMsg('','Caixa em outra transferência!')
				return .f.
			endif
		endif
	endif

	ZMQ->(DbSetorder(2))
	if !ZMQ->(MsSeek(FWxfilial('ZMQ')+_cCod+ZMP->ZMP_NUM))
		nUltItem := BuscaUltI(ZMP->ZMP_NUM)
		_cDesc := GetAdvFVal("SB1","B1_DESCRED",FWxFilial("SB1")+_cCod,1)
		RecLock("ZMQ",.T.)
		ZMQ->ZMQ_FILIAL	 := FWxFilial("ZMQ")
		ZMQ->ZMQ_NUM	 := ZMP->ZMP_NUM
		ZMQ->ZMQ_ITEM    := strzero(nUltItem,3)
		ZMQ->ZMQ_DESC    := _cDesc
		ZMQ->ZMQ_COD     := _cCod
		ZMQ->ZMQ_QUANT   := 0
		ZMQ->ZMQ_QTREAL  := 0
		MsUnlock()
	endif

	if ZMP->ZMP_STATUS = "E"
		Sinv(2)
		SetMsg('','Transferencia desabilitada, já encerrada!')
		return .f.
	elseif ZMP->ZMP_STATUS = "R"
		Sinv(2)
		SetMsg('','Transferencia desabilitada, já encerrada!')
		return .f.
	else
		if _lZAS
			reclock('ZAS',.f.)
			ZAS->ZAS_CODTRA := ZMQ->ZMQ_NUM
			ZAS->ZAS_ITETRA := ZMQ->ZMQ_ITEM
			ZAS->ZAS_DTRANS := ddatabase
			msunlock()
		elseif _lSZ8
			reclock('SZ8',.f.)
			SZ8->Z8_CODTRAI := ZMQ->ZMQ_NUM
			SZ8->Z8_ITETRAI := ZMQ->ZMQ_ITEM
			SZ8->Z8_DTRANSI := ddatabase
			msunlock()
		endif

		reclock('ZMQ',.f.)
		ZMQ->ZMQ_QUANT := ZMQ->ZMQ_QUANT + 1
		msunlock()

		reclock('ZMP',.f.)
		if ZMP->ZMP_STATUS = 'A'
			ZMP->ZMP_STATUS := 'T'
		endif
		ZMP->ZMP_TOTTRA := ZMP->ZMP_TOTTRA + 1
		msunlock()

		_nCont := ZMP->ZMP_TOTTRA

		if _lZAS
			u_gjf17his(3,'TRANSF. PORC. - ' + ZMQ->ZMQ_NUM,.f.,,,'000038',ZAS->ZAS_CONTRO,ZAS->ZAS_LOCAL,ZAS->ZAS_LOCALI,ZAS->ZAS_PALLET)
			_cMens1 := alltrim(ZAS->ZAS_CONTRO) + '  ' + alltrim(ZAS->ZAS_COD) + '  ' + alltrim(ZAS->ZAS_DESC) + ' transferida!'
			_cMens2 := ''
		elseif _lSZ8
			u_gjf17his(3,'TRANSF. PORC. - ' + ZMQ->ZMQ_NUM,.f.,,,'000038',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
			_cMens1 := alltrim(SZ8->Z8_CONTROL) + '  ' + alltrim(SZ8->Z8_COD) + '  ' + alltrim(SZ8->Z8_DESCRI) + ' transferida!'
			_cMens2 := ''
		endif
		_cMens3 := 'Total = ' + Transform(_nCont, "@E 999")

		Sinv(1)

	endif

	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)
	oSayI1:SetText(_cMens3)
	oDlgT:refresh()

return .f.

//Função para buscar o último item criado na transferência 
Static Function BuscaUltI(_cNum)
	Local _cQuery := ""
	_cQuery := "SELECT TOP 1 ZMQ_ITEM"
	_cQuery += " FROM  " + RetSQLTab('ZMQ') + " (NOLOCK)"
	_cQuery += " WHERE " + RetSQLFil('ZMQ')
	_cQuery += " AND ZMQ_NUM = '" + _cNum + "'"
	_cQuery += " AND " + RetSQLDel('ZMQ')
	_cQuery += " ORDER BY ZMQ_NUM, ZMQ_ITEM DESC"

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TMP"
Return val(TMP->ZMQ_ITEM) + 1

//Função para receber a transferencia e leitura das caixas
User Function DTI218R()
	//Cria a caixa de diálogo para localizar uma caixa
	Local cCaixa := space(11)
	Local _Mens1 := ''
	Local _Mens2 := ''
	Local _Mens3 := ''
	Local _Mens4 := ''
	Local campo  := space(11)
	Local cPerg  := "DTI218R"
	_nCont := ZMP_TOTREC

	if !pergunte(cPerg,.t.)
		return
	endif

	_Mens3 := 'Total = ' + Transform(_nCont, "@E 999")
	_Mens4 := 'Local: ' + alltrim(mv_par01)

	DEFINE MSDIALOG oDlgT TITLE 'Localização de caixas para recebimento:' from 000,000 To 150,400 OF oMainWnd PIXEL
	@ 10,03 SAY  'Caixa:' Object oSay1

	@ 01,04 MSGET campo VAR cCaixa SIZE 60,11 OF oDlgT VALID ValidRec(cCaixa)
	oFont1  := tFont():New("courier new",,-20,,.t.,,,,)
	oFont2  := tFont():New("courier new",,-15,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _Mens1 },oDlgT,,oFont1,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	oSayD2  := tSay():New(30,10,{|| _Mens2 },oDlgT,,oFont1,,,,.T.,CLR_HRED,CLR_HRED,200,35)
	oSayI1  := tSay():New(10,145,{|| _Mens3 },oDlgT,,oFont2,,,,.T.,CLR_BLACK,CLR_BLACK,100,30)
	oSayI2  := tSay():New(10,95,{|| _Mens4 },oDlgT,,oFont2,,,,.T.,CLR_BLACK,CLR_BLACK,100,30)

	@ 60,020 BMPBUTTON TYPE 5 ACTION DTI218P(cPerg) Object Obtn1
	@ 60,160 BMPBUTTON TYPE 1 ACTION oDlgT:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgT
Return

//Disponibiliza a troca de parâmetros
Static Function DTI218P(_cPerg)
	if !pergunte(_cPerg,.t.)
		return
	endif
	SetMsg('','','Total = ' + Transform(_nCont, "@E 999"),'Local: ' + alltrim(mv_par01))
Return

//Função de verificação e gravação de transferência nas caixas
Static Function ValidRec(cCaixa)
	Local _lSZ8 := .f.
	Local _lZAS := .f.
	Local _cCod := ""

	if empty(cCaixa)
		return .t.
	endif

	SZ8->(DbGoTop())
	SZ8->(DbSetOrder(3))
	ZAS->(DbGoTop())
	ZAS->(DbSetOrder(1))
	if ZAS->(MsSeek(FWxfilial('ZAS') + alltrim(cCaixa)))
		_lZAS := .t.
		_cCod := ZAS->ZAS_COD
	elseif SZ8->(MsSeek(FWxfilial('SZ8') + alltrim(cCaixa)))
		_lSZ8 := .t.
		_cCod := SZ8->Z8_COD
	else
		Sinv(2)
		SetMsg('','Caixa não encontrada!')
		return .f.
	endif

	if _lZAS
		if !empty(ZAS->ZAS_CODTRA)
			if ZAS->ZAS_CODTRA != ZMP->ZMP_NUM
				Sinv(2)
				SetMsg('','Caixa em outra transferência!')
				return .f.
			endif
		endif
	elseif _lSZ8
		if !empty(SZ8->Z8_CODTRAI)
			if SZ8->Z8_CODTRAI != ZMP->ZMP_NUM
				Sinv(2)
				SetMsg('','Caixa em outra transferência!')
				return .f.
			endif
		endif
	endif

	if _lZAS
		if !empty(ZAS->ZAS_DTRMP) .and. !empty(ZAS->ZAS_CODTRA)
			Sinv(2)
			SetMsg('','Caixa já foi recebida nos Porcionados!')
			return .f.
		endif
	elseif _lSZ8
		if !empty(SZ8->Z8_DTRPOR) .and. !empty(SZ8->Z8_CODTRAI)
			Sinv(2)
			SetMsg('','Caixa já foi recebida nos Porcionados!')
			return .f.
		endif
	endif

	if ZMP->ZMP_STATUS != "E"
		Sinv(2)
		SetMsg('','Recebimento desabilitado, transferência não foi encerrada!')
		return .f.
	endif

	ZMQ->(DbSetorder(2))
	if _lZAS
		if ZMQ->(MsSeek(FWxfilial('ZMQ')+_cCod+ZMP->ZMP_NUM))
			reclock('ZAS',.f.)
			ZAS->ZAS_CODTRA := ZMQ->ZMQ_NUM
			ZAS->ZAS_ITETRA := ZMQ->ZMQ_ITEM
			ZAS->ZAS_DTRMP  := ddatabase
			ZAS->ZAS_LOCAL  := mv_par01
			msunlock()
		endif
	elseif _lSZ8
		if ZMQ->(MsSeek(FWxfilial('ZMQ')+_cCod+ZMP->ZMP_NUM))
			reclock('SZ8',.f.)
			SZ8->Z8_CODTRAI := ZMQ->ZMQ_NUM
			SZ8->Z8_ITETRAI := ZMQ->ZMQ_ITEM
			SZ8->Z8_DTRPOR  := ddatabase
			SZ8->Z8_LOCAL   := mv_par01
			msunlock()
		endif
	endif

	reclock('ZMQ',.f.)
	ZMQ->ZMQ_QTREAL := ZMQ->ZMQ_QTREAL + 1
	msunlock()

	reclock('ZMP',.f.)
	ZMP->ZMP_TOTREC := ZMP->ZMP_TOTREC + 1
	msunlock()

	_nCont := ZMP->ZMP_TOTREC

	if _lZAS
		u_gjf17his(1,'RECEB. PORC. - ' + ZMQ->ZMQ_NUM,.f.,,,'000038',ZAS->ZAS_CONTRO,ZAS->ZAS_LOCAL,ZAS->ZAS_LOCALIZ,ZAS->ZAS_PALLET)
		_cMens1 := alltrim(ZAS->ZAS_CONTRO) + '  ' + alltrim(ZAS->ZAS_COD) + '  ' + alltrim(ZAS->ZAS_DESC) + ' recebida!'
		_cMens2 := ''
	elseif _lSZ8
		u_gjf17his(1,'RECEB. PORC. - ' + ZMQ->ZMQ_NUM,.f.,,,'000038',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
		_cMens1 := alltrim(SZ8->Z8_CONTROL) + '  ' + alltrim(SZ8->Z8_COD) + '  ' + alltrim(SZ8->Z8_DESCRI) + ' recebida!'
		_cMens2 := ''
	endif
	_cMens3 := 'Total = ' + Transform(_nCont, "@E 999")

	Sinv(1)

	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)
	oSayI1:SetText(_cMens3)
	oDlgT:refresh()

return .f.

//Função para receber a transferencia e leitura das caixas
User Function DTI218S()
	//Cria a caixa de diálogo para localizar uma caixa
	Local cCaixa := space(11)
	Local _Mens1 := ''
	Local _Mens2 := ''
	Local _Mens3 := ''
	Local campo  := space(11)
	_nCont 		 := ZMP_TOTTRA
	_Mens3 := 'Total = ' + Transform(_nCont, "@E 999")

	DEFINE MSDIALOG oDlgT TITLE 'Localização de caixas para estornar:' from 000,000 To 150,400 OF oMainWnd PIXEL
	@ 10,03 SAY  'Caixa:' Object oSay1

	@ 01,04  MSGET campo VAR cCaixa SIZE 60,11 OF oDlgT VALID ValidEst(cCaixa)
	oFont1  := tFont():New("courier new",,-20,,.t.,,,,)
	oFont2  := tFont():New("courier new",,-15,,.t.,,,,)
	oSayD1  := tSay():New(30,10,{|| _Mens1 },oDlgT,,oFont1,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,35)
	oSayD2  := tSay():New(30,10,{|| _Mens2 },oDlgT,,oFont1,,,,.T.,CLR_HRED,CLR_HRED,200,35)
	oSayI1  := tSay():New(10,145,{|| _Mens3 },oDlgT,,oFont2,,,,.T.,CLR_BLACK,CLR_BLACK,100,30)

	@ 60,160 BMPBUTTON TYPE 1 ACTION oDlgT:end() Object Obtn1

	ACTIVATE MSDIALOG oDlgT
Return

//Função de verificação e gravação de transferência nas caixas
Static Function ValidEst(cCaixa)
	Local _lSZ8 := .f.
	Local _lZAS := .f.
	Local _cCod := ""

	if empty(cCaixa)
		return .t.
	endif

	SZ8->(DbGoTop())
	SZ8->(DbSetOrder(3))
	ZAS->(DbGoTop())
	ZAS->(DbSetOrder(1))
	if ZAS->(MsSeek(FWxfilial('ZAS') + alltrim(cCaixa)))
		_lZAS := .t.
		_cCod := ZAS->ZAS_COD
	elseif SZ8->(MsSeek(FWxfilial('SZ8') + alltrim(cCaixa)))
		_lSZ8 := .t.
		_cCod := SZ8->Z8_COD
	else
		Sinv(2)
		SetMsg('','Caixa não encontrada!')
		return .f.
	endif

	if _lZAS
		if empty(ZAS->ZAS_DTRANS) .and. empty(ZAS->ZAS_CODTRA) .and. empty(ZAS->ZAS_ITETRA)
			Sinv(2)
			SetMsg('','Caixa não foi transferida!')
			return .f.
		endif
	elseif _lSZ8
		if empty(ZAS->ZAS_DTRANS) .and. empty(ZAS->ZAS_CODTRA) .and. empty(ZAS->ZAS_ITETRA)
			Sinv(2)
			SetMsg('','Caixa não foi transferida!')
			return .f.
		endif
	endif

	ZMQ->(DbSetorder(2))
	if _lZAS
		if !ZMQ->(MsSeek(FWxfilial('ZMQ')+ZAS->ZAS_COD+ZMP->ZMP_NUM))
			Sinv(2)
			SetMsg('','Sem transferencia para este produto!')
			return .f.
		endif
	elseif _lSZ8
		if !ZMQ->(MsSeek(FWxfilial('ZMQ')+SZ8->Z8_COD+ZMP->ZMP_NUM))
			Sinv(2)
			SetMsg('','Sem transferencia para este produto!')
			return .f.
		endif
	endif

	if ZMP->ZMP_STATUS = "E"
		Sinv(2)
		SetMsg('','Estorno desabilitado, transferência já encerrada!')
		return .f.
	elseif ZMP->ZMP_STATUS = "R"
		Sinv(2)
		SetMsg('','Estorno desabilitado, transferência já recebida!')
		return .f.
	endif

	if _lZAS
		reclock('ZAS',.f.)
		ZAS->ZAS_CODTRA := ""
		ZAS->ZAS_ITETRA := ""
		ZAS->ZAS_DTRANS := stod("")
		msunlock()
	elseif _lSZ8
		reclock('SZ8',.f.)
		SZ8->Z8_CODTRAI := ""
		SZ8->Z8_ITETRAI := ""
		SZ8->Z8_DTRANSI := stod("")
		msunlock()
	endif

	reclock('ZMQ',.f.)
	ZMQ->ZMQ_QUANT := ZMQ->ZMQ_QUANT - 1
	msunlock()

	reclock('ZMP',.f.)
	ZMP->ZMP_TOTTRA := ZMP->ZMP_TOTTRA - 1
	msunlock()

	_nCont := ZMP->ZMP_TOTTRA

	if _lZAS
		u_gjf17his(2,'ESTORNO. TRANSF. - ' + ZMQ->ZMQ_NUM,.f.,,,'000038',ZAS->ZAS_CONTRO,ZAS->ZAS_LOCAL,ZAS->ZAS_LOCALI,ZAS->ZAS_PALLET)
		_cMens1 := alltrim(ZAS->ZAS_CONTRO) + '  ' + alltrim(ZAS->ZAS_COD) + '  ' + alltrim(ZAS->ZAS_DESC) + ' estornada!'
		_cMens2 := ''
	elseif _lSZ8
		u_gjf17his(2,'ESTORNO. TRANSF. - ' + ZMQ->ZMQ_NUM,.f.,,,'000038',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
		_cMens1 := alltrim(SZ8->Z8_CONTROL) + '  ' + alltrim(SZ8->Z8_COD) + '  ' + alltrim(SZ8->Z8_DESCRI) + ' estornada!'
		_cMens2 := ''
	endif
	_cMens3 := 'Total = ' + Transform(_nCont, "@E 999")

	Sinv(1)

	oSayD1:SetText(_cMens1)
	oSayD2:SetText(_cMens2)
	oSayI1:SetText(_cMens3)
	oDlgT:refresh()

return .f.

//Função para executar o som ao ler caixa ou peça
static function Sinv(t)
	do case
		case t = 1
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GE.WAV',0)
		case t = 2
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GEER.WAV',0)
		case t = 3
		WINEXEC('C:\smartclient\sndrec32.exe /play /close /embedding C:\smartclient\GNENC.WAV',0)
	endcase
return
