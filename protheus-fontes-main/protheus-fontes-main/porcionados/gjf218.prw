#INCLUDE "rwmake.ch"
#INCLUDE 'protheus.ch'
#INCLUDE 'dbtree.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF218    º Autor ³ Giuliano Forgiariniº Data ³  01/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina produção, pesagem e registro de carne refilada para º±±
±±º          ³ pulmão e quebra de produção fatiadoras/refile              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sala de Refile Porcionados                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF218()

	Private _cMemo     := ""
	Private _cCodPro   := ''
	Private _cCodPP    := ''
	Private _cGet1     := space(06)
	Private _nGet1     := 0.00
	Private _dGet2     := stod("")
	Private cPerg      := "GJF218"
	Private _oFont     := tFont():New("courier new",,-14,,.t.,,,,)
	Private _cLote     := space(10)
	Private _cValLote  := space(10)
	Private _cBatel    := space(10)
	Private _cValBatel := space(10)
	Private _cProd     := 'Produto:'
	Private _cDest     := ''
	Private _cTipo     := ''
	Private _nTent     := 0
	if !pergunte(cPerg,.t.)
		return
	endif


	if empty(mv_par02)
		Help(" ",1,"PERGUNTAS",,"Parametros iniciais em branco!",4,1)
		return
	endif


	_cDest 	   := mv_par04
	_cTara     := 'Tara: ' + transform(mv_par02,'@E 99.999')
	_cTipo     := iif(mv_par01 = 1,'QR',iif(mv_par01 = 2,'QF',iif(mv_par01 = 3, 'PP',iif(mv_par01 = 4, 'MP', 'RP'))))
	_cOperacao := "Operação: " + iif(mv_par01 = 1,'Quebra Refile',iif(mv_par01 = 2,'Quebra Fatiadora',iif(mv_par01 = 3,'Produto Refilado',iif(mv_par01 = 4,'Sobra MP','Retorno de Produção'))))
	_descDest := fBuscaCpo('SX5',1,FWxFilial('SX5')+'ZP'+_cDest,'X5_DESCRI')
	if empty(_cDest)
		Help(" ",1,"PERGUNTAS",,"Destino em branco!",4,1)
		return
	endif

	if _cTipo = 'PP' .and. !(_cDest $ '007/009')
		alert('Quando o tipo for Produto Refilado o destino deve ser 007 - Bife ou 009 - Cubos/Iscas')
		return
	elseif _cTipo = 'MP' .and. _cDest <> '008'
		alert('Quando o tipo for Sobra MP o destino deve ser 008 - Sobra')
		return
	endif

	DEFINE DIALOG oDlg TITLE "Registro de Produção de Refile/Quebra" FROM 180,180 TO 700,800 PIXEL
	if mv_par03 = 1

		_oSay0   := TSay():New(005,020, {|| _cOperacao}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
		if _cTipo == "RP"
			_oSay7   := TSay():New(040,160, {|| "Caçamba de origem:"}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
			@ 040,240 MSGET _cBatel VAR _cValBatel SIZE 50,10 OF oDlg PIXEL PICTURE "@!" F3 "ZAS" VALID ValidB(2)
		else
			_oSay7   := TSay():New(040,160, {|| "Batelada Produção:"}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
			@ 040,240 MSGET _cBatel VAR _cValBatel SIZE 50,10 OF oDlg PIXEL PICTURE "@!" F3 "CoZAX" VALID ValidB(1)
		endif
		_oSay2   := TSay():New(015,020, {|| _cTara}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
		_oSay3   := TSay():New(025,020, {|| _cProd }, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 40)
		_oSay5   := TSay():New(045,020, {|| "Destino:" + _descDest }, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 100)

		_oSay4  := TSay():New(195,040, {||'Peso Bruto:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 100)

		_oGet1  := TGet():New(195,100, {|u| If(PCount() > 0,_nGet1:=u,_nGet1)}, oDlg,, 009,"@E 999.99",{||}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, "_nGet1",,,,.t.,)

		_oSay8  := TSay():New(195,160, {||'Data de Abate:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 100)

		_oGet2  := TGet():New(195,220, {|u| If(PCount() > 0,_dGet2:=u,_dGet2)}, oDlg,, 009, "@D",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,,"_dGet2",,,,.t.,)

		_oBtn0 := TButton():New(235,140, "Captura",  oDlg,{||Captura() },40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
		_oBtn1 := TButton():New(235,200, "Produzir", oDlg,{||Produzir()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	else
		_cGet1 := space(11)
		_nGet1 := 0.00
		_oSay0   := TSay():New(005,020, {|| _cOperacao}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
		_oSay6   := TSay():New(020,020, {|| 'Re-impressão de Etiquetas:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
		_oGet1   := TGet():New(210,140, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)}, oDlg,, 009, "@!",{||Leitura()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet1,,,,.t.,)
	endif

	_oMemo   := TMultiget():New(55,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg,280,130,_oFont,,,,,.T.,,,,,,.t.)

	_oBtn2 := TButton():New(235,260, "Sair"    , oDlg,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )


	ACTIVATE DIALOG oDlg CENTERED

Return
//Função de validação do lote apontado
Static function ValidL()
	Local _lRet := .t.

	if empty(_cValLote)
		_cBatel:enable()
		oDlg:Refresh()
		return .t.
	endif

	ZAU->(DbSetOrder(1))
	if !ZAU->(MsSeek(FWxfilial('ZAU')+_cValLote))
		Help(" ",1,"LOTE",,"Lote de produção não encontrado!",4,1)
		_lRet := .f.
	else
		if _cTipo = 'PP'
			if ZAU->ZAU_PROREF  = 'N'
				Help(" ",1,"LOTE",,"Produção de refilado não permitida!",4,1)
				_lRet := .f.
			endif
		endif
	endif

	_cCodPro := iif(mv_par01 <> 3,alltrim(ZAU->ZAU_COD),ZAU->ZAU_CODPI)

	if _lRet
		_cProd := 'Produto: ' + alltrim(_cCodPro) + '   ' + alltrim(fBuscaCPO('SB1',1,FWxfilial('SB1')+_cCodPro,'B1_DESC'))
	else
		_cProd := 'Produto:'
	endif

	_oSay3:SetText(_cProd)
	_cBatel:disable()
	oDlg:Refresh()

return _lRet


//Função de validação da batelada apontada
Static function ValidB(_nTp)

	if empty(_cValBatel)
		oDlg:Refresh()
		return .t.
	endif

	if _nTp == 1

		ZAX->(DbSetOrder(1))
		if !ZAX->(MsSeek(FWxfilial('ZAX')+_cValBatel))
			Help(" ",1,"BATELADA",,"Batelada de produção não encontrada!",4,1)
			return .f.
		elseif ZAX->ZAX_REC = 'S'
			Help(" ",1,"RECEITA MOIDA",,"Batelada para carne moída. Não pode ser apuradas quebras!",4,1)
			return .f.
		else

			_cCodPro := alltrim(ZAX->ZAX_CODMP)

			if mv_par01 = 3
				SG1->(DbSetOrder(2))
				if SG1->(MsSeek(FWxfilial('SG1')+_cCodPro))
					while SG1->(!eof()) .and. SG1->G1_FILIAL = FWxfilial('SG1') .and. SG1->G1_COMP = _cCodPro

						//Faz a contagem de componentes PP (Produto em Processo para bife: tem que ter só 1)
						if SG1->G1_TPPORC = 'PP'
							_cCodPP := SG1->G1_COD
							exit
						endif

						SG1->(dbSkip())
					enddo
				endif
			endif
		endif
	else
		ZAS->(DbSetOrder(1))
		if !ZAS->(MsSeek(FWxfilial('ZAS')+_cValBatel))
			Help(" ",1,"CAÇAMBA",,"Caçamba não encontrada!",4,1)
			return .f.
		else
			_cCodPro := alltrim(ZAS->ZAS_COD)
			_dGet2   := ZAS->ZAS_DTABAT
		endif

	endif

	if mv_par01 <> 3
		_cProd := 'Produto: ' + alltrim(_cCodPro) + '   ' + alltrim(fBuscaCPO('SB1',1,FWxfilial('SB1')+_cCodPro,'B1_DESC'))
	else
		_cProd := 'Produto: ' + alltrim(_cCodPP) + '   ' + alltrim(fBuscaCPO('SB1',1,FWxfilial('SB1')+_cCodPP,'B1_DESC'))
	endif

	_oSay3:SetText(_cProd)
	oDlg:Refresh()

return .t.


//Função destinada a fazer a re-impressão de etiquetas
Static Function Imprime(_cContro)
	//Local _produto := ''
	Local _cIp 		:= ''
	Local _cEst := getComputerName()

	dbselectarea('ZAM')
	ZAM->(dbSetOrder(1))
	if ZAM->(MsSeek(FWxFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)

	endif
	u_DTI133('S600','IP',_cIp,_cContro)
return

//Função destinada a produção de MP
Static Function Produzir()

	if _nGet1 > 0

		_cID :=  GetSx8num('SZ8','Z8_ID')
		ConfirmSx8()

		_cContro := '00' + _cID

		DbSelectArea('SB1')
		DbSetOrder(1)

		if MsSeek(FWxfilial('SB1')+iif(mv_par01 = 3,_cCodPP,_cCodPro))//se for produto refilado utiliza o codigo de produto intermediario

			reclock('ZAS',.t.)
			ZAS->ZAS_FILIAL  := FWxfilial('ZAS')
			ZAS->ZAS_CONTRO  := _cContro
			ZAS->ZAS_COD     := SB1->B1_COD
			ZAS->ZAS_DESC    := SB1->B1_DESC
			ZAS->ZAS_DTPROD  := ddatabase
			ZAS->ZAS_VALID   := SB1->B1_VALID
			ZAS->ZAS_PESOL   := _nGet1 - mv_par02
			ZAS->ZAS_PESOB   := _nGet1
			ZAS->ZAS_TARA    := mv_par02
			ZAS->ZAS_PREEMB  := ''
			ZAS->ZAS_LOCAL   := '22'
			ZAS->ZAS_TIPO    := _cTipo
			ZAS->ZAS_DESTIN  := _cDest
			ZAS->ZAS_LOTE    := _cValLote//ZAU->ZAU_NUM
			ZAS->ZAS_TERC    :='N'
			ZAS->ZAS_BATEL   := _cValBatel
			ZAS->ZAS_DTABAT  := _dGet2
			if _cTipo == 'RP'
				ZAS->ZAS_RPORIG := _cValBatel
			endif
			msunlock()

			u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Prod. Refile "+ STRTRAN(_cOperacao, "Operação: ", "Op.: "), ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

			_cMemo := '[ REGISTRO DE PRODUÇÃO DE '+ iif(_cTipo = 'PP','PRODUTO EM PROCESSO',iif(_cTipo = 'QR','QUEBRA REFILE',iif(_cTipo = 'QF','QUEBRA FATIADORAS',iif(_cTipo = 'MP','SOBRA MP','RETORNO DE PRODUÇÃO'))))+' ]'	+ chr(13) + chr(10)
			_cMemo += Replicate("=",68) + chr(13) + chr(10)
			_cMemo += "Codigo Caixa:   " + ZAS->ZAS_CONTRO + chr(13) + chr(10)
			_cMemo += "Codigo Produto: " + ZAS->ZAS_COD + chr(13) + chr(10)
			_cMemo += "Descrição:      " + ZAS->ZAS_DESC + chr(13) + chr(10)
			_cMemo += "Data Produção:  " + dtoc(ZAS->ZAS_DTPROD) + chr(13) + chr(10)
			_cMemo += "Peso Bruto:     " + transform(ZAS->ZAS_PESOB,"@ 999.99") + chr(13) + chr(10)
			_cMemo += "Tara:           " + transform(ZAS->ZAS_TARA,"@ 9.999") + chr(13) + chr(10)
			_cMemo += "Peso Liquido:   " + transform(ZAS->ZAS_PESOL,"@ 999.99") + chr(13) + chr(10)
			_cMemo += Replicate("=",68) + chr(13) + chr(10)

			_nGet1 := 0.00
			_oGet1:CtrlRefresh()
			_oMemo:refresh()
			oDlg:refresh()
			Imprime(ZAS->ZAS_CONTRO)
		else
			Help(" ",1,"CADASTRO",,"Problemas com o cadastro de produto!",4,1)
		endif
	else
		Help(" ",1,"PESO",,"Peso capturado inconsistente!",4,1)
	endif
return


//Função de validação das leituras de caixas e pallets
Static Function Leitura()
	Local _lRet := .f.

	//Se o campo estiver em branco
	if empty(_cGet1)
		_lRet := .t.
	else

		//Se o tamanho do codigo for menor que 10 digitos
		if len(alltrim(_cGet1)) < 10
			_lRet := .f.
		else

			ZAS->(DbSetOrder(1))
			if !ZAS->(MsSeek(FWxfilial("ZAS")+alltrim(_cGet1)))
				Help(" ",1,"ERRO",,"Registro não encontrada!",4,1)
			else

				//Verifica se a caixa ainda está em estoque
				if !empty(ZAS->ZAS_DATAS) .and. !empty(ZAS->ZAS_HORAS)
					Help(" ",1,"NÃO PERMITIDO!",,"Caixa já encontra-se fora de estoque!",4,1)
				else

					_cMemo := '[ REGISTRO DE PRODUÇÃO DE '+ iif(_cTipo = 'PP','PRODUTO EM PROCESSO',iif(_cTipo = 'QR','QUEBRA REFILE',iif(_cTipo = 'QF','QUEBRA FATIADORAS',iif(_cTipo = 'MP','SOBRA MP','RETORNO DE PRODUÇÃO'))))+' ]'	+ chr(13) + chr(10)
					_cMemo += Replicate("=",68) + chr(13) + chr(10)
					_cMemo += "Codigo Caixa:   " + ZAS->ZAS_CONTRO + chr(13) + chr(10)
					_cMemo += "Codigo Produto: " + ZAS->ZAS_COD + chr(13) + chr(10)
					_cMemo += "Descrição:      " + ZAS->ZAS_DESC + chr(13) + chr(10)
					_cMemo += "Data Produção:  " + dtoc(ZAS->ZAS_DTPROD) + chr(13) + chr(10)
					_cMemo += "Peso Bruto:     " + transform(ZAS->ZAS_PESOB,"@ 999.99") + chr(13) + chr(10)
					_cMemo += "Tara:           " + transform(ZAS->ZAS_TARA,"@ 9.999") + chr(13) + chr(10)
					_cMemo += "Peso Liquido:   " + transform(ZAS->ZAS_PESOL,"@ 999.99") + chr(13) + chr(10)
					_cMemo += "Local Destino:  " + ZAS->ZAS_LOCAL + chr(13) + chr(10)
					_cMemo += Replicate("=",68) + chr(13) + chr(10)
					_oMemo:refresh()

					Imprime(ZAS->ZAS_CONTRO)
				endif
			endif
		endif
	endif

	_cGet1 := space(11)
	_oGet1:CtrlRefresh()
return _lRet
/*
static function Captura()
	Local nHdll := 0
	Local cCom     := "COM1:9600,N,8,2" //comunicao balanca
	Local nDec     := 1  //precisao balanca
	Local cText    := ""
	Local cPeso    := ""
	Local cC       := ""
	Local nPeso    := 0
	Local nX       := 0
	Local nTaman   := 0
	Local nTempo   := 5


	if !MSOpenPort(@nHdll,cCom)
		msgbox("Não foi possível pegar informações da porta",,"STOP")
		Return 0
	endif

	cText := space(15)
	if !MsRead(nHdll,@cText)
		msgbox("Não foi possível pegar informações da porta",,"STOP")
		Return()
	endif

	//inkey(1)
	if empty(cText)
		//inkey(1)
		cText := space(15)
		//Inicializa balança
		MsWrite(nHdll,CHR(5))
		nTaman := 16

		//Realiza a leitura
		For nX := 1 To 50
			//Obtendo o tempo de espera antes de iniciar a leitura da balança e realiza a leitura
			Sleep(nTempo)
			MSRead(nHdll,@cText)

			//Obtendo os caracteres inciais
			cText := AllTrim(SubStr(AllTrim(cText),1,nTaman))

			//Se a linha retornada for igual ao tamanho limite
			If Len(AllTrim(cText)) >= nTaman
				Exit
			EndIf
			IncProc()
			_nTent := nX
			PROCESSMESSAGES()
		Next nX
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

	msClosePort(nHdll)

	if nPeso > 0
		_nGet1 := nPeso
		_oGet1:CtrlRefresh()
		_oMemo:refresh()
		oDlg:refresh()
	endif
return()
*/


static Function captura()
	Local cPorta    := "9091"//"9001"
	Local cIPServer := "10.7.0.34"//'172.16.17.200'
	Local cTimeOut  := '2000'
	Local cScript   := "Substr(cConteudo,at('`' ,cConteudo)+1,7)"
	Local oSocket
	Local nSockResp := 0
	Local nSockRead := 0
	Local cBuffer   := ''
	Local nFor01    := 0
	Local nRetorno  := 0
	Local cConteudo := ""
	/*
	local cEnder     :=   SUPERGETMV("DZ_CONFCOM", .f.,, Alltrim(FWFilial()))

	cPorta := Substr(Alltrim(cEnder),AT( ':', Alltrim(cEnder) )+1,len(alltrim(cEnder)))
	cIPServer := left(Alltrim(cEnder),AT( ':', Alltrim(cEnder))-1)
	*/
	oSocket     := tSocketClient():New()       //Criando a Classe
	For nFor01 := 1 to 10
		nSockResp := oSocket:Connect( val(cPorta),Alltrim(cIPServer),Val( cTimeOut ) )
		//Verificamos se a conexao foi efetuada com sucesso
		IF !( oSocket:IsConnected() )  //ntSocketConnected == 0 OK
			Help(,,'Ajuda',,'Não foi possivel conectar com a balança na Porta' + Chr(10) + Chr(13) +  "[ " + StrZero( nFor01,3 ) + " ]" , 1, 0 )  //"Ajuda"####não foi possivel conectar com a balança na Porta#
		Else
			if nSockResp == 0   // Conexão Ok
				Exit
			endif
		EndIF
	Next

	IF nSockResp == 0 // Indica que Está conectado // Enviando um Get Para Capturar o Peso
		Sleep (5000)
		For nFor01 := 1 To 10
			cBuffer := ""
			nSockRead = oSocket:Receive( @cBuffer,  Val( cTimeout ) )
			IF( nSockRead > 0 )
				cConteudo := cBuffer
				Exit
			Else
				cConteudo := ''
			Endif
		Next nFor01
	Else
		Help(,,'Ajuda',,'Nao foi possivel conectar a balança' + Chr(10) + Chr(13) +  "[ "  + cIpServer + "/" + cPorta + " ]" , 1, 0 )  //"Ajuda"####não foi possivel conectar com a balança. Tentavia:# ###"Balança: "
	EndIF
	oSocket:CloseConnection()   //Fechando a Conexão

	If .Not. Empty( AllTrim( cScript ) )
		cScript := "{||" +  Alltrim(cScript) + "}"
		cConteudo := Eval( &( cScript ) )
		nRetorno := Val( cConteudo ) / 10
	Else
		nRetorno := 0
	EndIf

	if nRetorno > 0
		_nGet1 := nRetorno
		_oGet1:CtrlRefresh()
		_oMemo:refresh()
		oDlg:refresh()
	endif
Return()
