#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE 'dbtree.ch'
#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma   ³DTI68     ºAutor  ³Mauricio Roehrs     º Data ³  30/08/18      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.      ³ pesagem de pallets				                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso        ³ Sigapcp - Frigorifico Silva                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºManutenção ³ 															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//tabela ZBF
User Function DTI68()
	Private  _cGet1   := space(11)
	Private  _cGet2   := '00.00'
	Private  _nGet3   := 00.00
	Private  _cMemo   := ""
	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	Private _cSay4    := 'Codigo Produto MP/PP:'
	Private _cSay5    := 'Peso Bruto Caixa:'
	Private _cSay6    := 'Tara Caixa: '
	Private _cSay7    := 'Prod. Terc.: '
	Private _cCodUser  := retCodUsr()

	DEFINE DIALOG oDlg TITLE "Pesagem de Pallets" FROM 180,180 TO 750,800 PIXEL

	_oMemo   := TMultiget():New(55,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg,280,130,_oFont,,,,,.T.,,,,,,.t.)

	_oSay2   := TSay():New(240,005, {|| 'Peso do Pallet:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	//_oGet2   := TGet():New(240,100, {|u| If(PCount() > 0, _cGet2:= u, _cGet2)}, oDlg,, 009, "@E 99.99",{||valPes()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet2,,,,.t.,)
	_oGet2   := TSay():New(240,100, {|u| If(PCount() > 0, _cGet2:= u, _cGet2)}, oDlg,, _oFont,,,,.T.,, CLR_WHITE, 200, 20)

	
	//_oBtn1 := TButton():New(255,140, "Pesar    ", oDlg,{||Captura()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn1 := TButton():New(255,200, "Imprimir", oDlg,{||Gravar()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )//	
	_oBtn3 := TButton():New(255,260, "Sair     ", oDlg,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

Return

Static Function valPes()

	local _lRet := .t.

	if empty(_cGet2)
		_lRet := .f.
	elseif val(_cGet2) <= 0
		_lRet := .f.
		// Dia 10/11/21 - Bohrer - regra nova , validar im loko
	elseif val(_cGet2) < 15 .or. val(_cGet2) > 40
		_lRet := .f.
	endif

	if !_lRet
		_cMemo :=  padc('[ PESAGEM DE PALLETS ]',280,' ')	+ chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)
		_cMemo += "É necessário informar o peso do Pallet" + chr(13) + chr(10)
		_cMemo += "Peso deve ser maior que 0(Zero)       "  + chr(13) + chr(10)
		_cMemo += "Hora:    " + ZBF->ZBF_HORA + chr(13) + chr(10)
		_cMemo += "Data:    " + dtoc(ZBF->ZBF_DATA) + chr(13) + chr(10)
		_cMemo += "Usuario: " + cUserName + chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)
		_oMemo:refresh()
	endif

return _lRet

//Função destinada a fazer a re-impressão de etiquetas
Static Function Imprime(_cNum,_dData,_cHora,_nPeso)
	//Local _produto  := ''
	//Local _ip 		:= ''

	_cEst := getComputerName()
	dbselectarea('ZAM')
	ZAM->(dbSetOrder(1))
	if ZAM->(dbSeek(xFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	else
		_cIp := ""
	endif

	u_GJF111q('S600','IP',_cIp,_cNum,_dData,_cHora,_nPeso)

return

static function gravar()
	
	/* Fazer rotina de captura e gravação
		Balança TI400 .
		OBS - se basear no fonte da desossa 
		GXR01 - IP 10.6.0.9
	*/	
	local _cString  := ""

	_cIpBGRX := alltrim(fBuscaCPO('ZAM',1,xFilial('ZAM') +'GXR02','ZAM_IP'))	
	oObj  := tSocketClient():New()	
	nResp := oObj:Connect(9000, _cIpBGRX, 1000 )
	nResp := oObj:Send( 'Teste' )
	_cString := CaptIP()
	
	/*Comentado por Lucas Bolzan em atendimento ao chamado 402)
	//_Peso:= strtran(substr(alltrim(_cString),1,5),',','.')
	//_Peso:= strtran(substr(alltrim(_cString),7,5),',','.')	
	*/
	_pt1peso := substr(alltrim(_cString),7,2)
	_pt2peso := substr(alltrim(_cString),9,3)
	_Peso := _pt1peso + "."+ _pt2peso	
	
	_oGet2:SetText(_Peso)
	
	//if val(_cGet2) > 0 //faz nova validação no peso
	if val(_Peso) > 0 //faz nova validação no peso
	
		_cNum := GetSx8num('ZBF','ZBF_NUM')
		ConfirmSX8()

		reclock('ZBF',.t.)
		ZBF->ZBF_FILIAL := xFilial('ZBF')
		ZBF->ZBF_NUM 	:= _cNUm
		ZBF->ZBF_DATA 	:= ddatabase
		ZBF->ZBF_HORA 	:= time()
		ZBF->ZBF_PESO 	:= val(_Peso)
		ZBF->ZBF_USRINC := _cCodUser
		msunlock()

		_cMemo :=  padc('[ PESAGEM DE PALLETS ]',280,' ')	+ chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)
		_cMemo += "Codigo do Pallet: " + ZBF->ZBF_NUM + chr(13) + chr(10)
		_cMemo += "Data da Pesagem:  " + dtoc(ZBF->ZBF_DATA) + chr(13) + chr(10)
		_cMemo += "Hora da Pesagem:  " + ZBF->ZBF_HORA + chr(13) + chr(10)
		_cMemo += "Peso do Pallet:   " + transform(ZBF->ZBF_PESO,"@ 999.99") + chr(13) + chr(10)
		_cMemo += "Usuario:          " + cUserName + chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)
		_oMemo:refresh()

		//_cGet2 := '00.00'
		_oGet2:CtrlRefresh()

		imprime(ZBF->ZBF_NUM, ZBF->ZBF_DATA, ZBF->ZBF_HORA, ZBF->ZBF_PESO)
		//msgbox('Pallet pesado com sucesso!','Pesagem de Pallets!','INFO')
	else
		_cMemo :=  padc('[ PESAGEM DE PALLETS ]',280,' ')	+ chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)
		_cMemo += "É necessário informar o peso do Pallet" + chr(13) + chr(10)
		_cMemo += "Peso deve ser maior que 0(Zero)       "  + chr(13) + chr(10)
		_cMemo += "Hora:    " + ZBF->ZBF_HORA + chr(13) + chr(10)
		_cMemo += "Data:    " + dtoc(ZBF->ZBF_DATA) + chr(13) + chr(10)
		_cMemo += "Usuario: " + cUserName + chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)
		_oMemo:refresh()

		_cGet2 := '00.00'
		_oGet2:CtrlRefresh()
	endif
return

Static Function informaPeso()

	local _lOk := .f.

	DEFINE MSDIALOG oDlg2 TITLE 'Peso do Pallet' from 000,000 To 100,250 PIXEL
	@ 010,002 SAY  'Peso Pallet:' Object oSayPes
	@ 010,035 GET _nGet2 PICTURE "@E 99.99" SIZE 30,6  VALID !empty(_nGet2) .and. _nGet2 > 0 Object oGet2
	@ 025,002 SAY  'Tara Strech:' Object oSayPes
	@ 025,035 GET _nGet3 PICTURE "@E 99.99" SIZE 30,6 Object oGet3
	@ 010,95 BMPBUTTON TYPE 1 ACTION (_lOk := .t.,odlg2:end()) Object ObtnPes1
	@ 025,95 BMPBUTTON TYPE 2 ACTION odlg2:end() Object ObtnPes2
	ACTIVATE MSDIALOG oDlg2 CENTERED

Return _lOk

//função para conectar na balança
Static Function conectBal()

	//Define o IP da balança a se utilizada
	_cIpBal := alltrim(fBuscaCPO('ZAM',1,xFilial('ZAM') + iif(_cPar02 = '1','BABT1','BABT2'),'ZAM_IP'))

	if empty(_cIpBal)
		alert('Endereço IP da balança não encontrado!')
		return
	endif

	//Se a balança já estiver conectada, disconecta...
	if _lBal
		oObj:CloseConnection()
	endif

	oObj  := tSocketClient():New()
	nResp := oObj:Connect( 9092, _cIpBal,1000)  //9092	
	nResp := oObj:Send( 'Teste' )

	_lBal := .t.

return

//função separada para capturar peso com a balança nova
Static Function Captura()

	local _nTam     := getMv('SI_QTPESMD')//parametro com valor total de strings de peso a serem armazenadas para tratamento
	local _nMS      := getMV('SI_QTMSMD') //parametro com a velocidade em milissegundos para capturas de peso
	//local _nStrOk   := 0
	local aStrings  := {}
	local aPesos    := {}
	local nPeso 	:= 0
	local _nMaior   := 0
	local _nCont    := 0
	local cPeso     := ""
	local cC        := ""
	local _cBuffer  := ""
	//local _nPesosOk := 0
	Local i
	Local j
	
	conectBal()

	//bloco que armazena as strings que tiverem o peso estável
	
	for i:=1 to _nTam//bloco para multiplcas capturas
		_cBuffer   := ""
		nQtd 	   = oObj:Receive( _cBuffer, _nMS )
		if ("ph" $ alltrim(_cBuffer)) .or. ("p`" $ alltrim(_cBuffer)) //SE TIVER "PH" NA STRING QUER DIZER QUE É UM PESO ESTAVEL
			//alert(_cBuffer)
			aAdd(aStrings,_cBuffer)
		endif
	next

	//alert(_cBuffer)

	//verifica se o buffer não esta sendo retornado em branco, caso esteja reconecta na balança
	//if empty(_cBuffer)
	//	conectBal()
	//endif

	//bloco para tratamento das strings com peso estável
	for i:= 1 to len(aStrings)
		do Case
			Case at("ph",aStrings[i])> 0
			cPeso := substr(aStrings[i],at("ph",aStrings[i])+2,6)
			cC := "h"
			Case at("p`",aStrings[i])> 0
			cPeso := substr(aStrings[i],at("p`",aStrings[i])+2,6)
			cC := "`"
			Case at("h",aStrings[i]) > 0
			cPeso := substr(aStrings[i],at("h",aStrings[i])+1,6)
			cC := "h"
			Case at("p ",aStrings[i])> 0
			cPeso := substr(aStrings[i],at("p ",aStrings[i])+2,6)
			cC := " "
			Otherwise
			cPeso :='000000'
			cC := ""
		Endcase

		cPeso := substr(aStrings[i],at("`",aStrings[i])+1,6)
		cPeso := substr(aStrings[i],at(cC,aStrings[i])+1,6)
		nPeso := val(cPeso)/(1000)
		if nPeso > 0 //adiciona no vetor de pesos ok somente pesos acima de zero
			aAdd(aPesos,nPeso)
		endif
	next

	//bloco para tratamento de incidencias, ou seja, utiliza somente o peso que tiver mais incidencias dentro do vetor
	for i:= 1 to len(aPesos)//_nPesosOk
		//alert(aPesos[i])
		_nCont := 0
		for j:=1 to len(aPesos)//_nPesosOk
			if aPesos[i] == aPesos[j]
				_nCont++
			endif
		next

		if _nCont > _nMaior
			nPeso   := aPesos[i]
			_nMaior := _nCont
		endif
	next

	oObj:CloseConnection()
	alert('Peso da balanca: '+ transform(nPeso,'@E 99.999'))

return nPeso

Static Function consulta()

	_area       := getarea()
	aStru 		:= {}
	
	_dDtBusca := date() - 30//pega a data 30 dias pra tras
	
	cQuery := " SELECT ZBF_NUM, ZBF_DATA, ZBF_HORA, ZBF_HORA, ZBF_USRINC, ZBF_PESO
	cQuery += " FROM " + retSqlTab('ZBF')
	cQuery += " WHERE " + retSqlFil('ZBF')
	cQuery += " AND ZBF_DATAS = ''"
	cQuery += " AND ZBF_DATA >= '" + dtos(_dDtBusca) + "'"
	cQuery += " AND " + retSqlDel('ZBF')
	cQuery += " ORDER BY ZBF_NUM"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	cQuery := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	area := getarea()

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('QRY')

	_aArqTrb := {}
	aStru := dbStruct()
	aadd(aStru,{"NUMERO" , "C",  10, 0,    "" , 'Numero'  	})
	aadd(aStru,{"DTINC"  , "D",  8,  0,    "" , 'Data'    	})
	aadd(aStru,{"HORA"   , "C",  5,  0,    "" , 'Hora'    	})
	aadd(aStru,{"PESO"   , "N",  5,  2,    "" , 'Peso'    	})
	aadd(aStru,{"USER"   , "C",  6,  0,    "" , 'Cod.Usuar.'})
	aadd(aStru,{"NOME"   , "C",  20, 0,    "" , 'Nome'    	})

	//dbcreate(cArq,aStru)
	//If Select("TMPP")!=0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMPP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMPP", .F. , .F. )

	If Select('TMPP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMPP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMPP", aStru, {}, @_aArqTrb)

	PswOrder(1) // ordena pelo nome de usuário

	QRY->(dbGoTop())
	while QRY->(!eof())

		PswSeek(AllTrim(QRY->ZBF_USRINC)) // Posiciona no usuário desejado
		cNomeUsr := PswRet()[1][2] // Recebe o nome do do usuário.
		cNome    := PswRet()[1][4] // Recebe o nome completo do usuário.

		DbSelectArea("TMPP")
		reclock("TMPP",.t.)
		TMPP->NUMERO  := QRY->ZBF_NUM
		TMPP->DTINC   := STOD(QRY->ZBF_DATA)
		TMPP->HORA    := QRY->ZBF_HORA
		TMPP->PESO    := QRY->ZBF_PESO
		TMPP->USER    := QRY->ZBF_USRINC
		TMPP->NOME    := cNome
		msunlock()

		QRY->(dbskip())

	enddo

	aCampos := {}

	aadd(aCampos,{"NUMERO" ,"Numero    	"  	,""   		})
	aadd(aCampos,{"DTINC"  ,"Data      	"  	,"@!" 		})
	aadd(aCampos,{"HORA"   ,"Hora		" 	,"@!" 		})
	aadd(aCampos,{"PESO"   ,"Peso 		" 	,"@E 99.99" })
	aadd(aCampos,{"USER"   ,"Cod.Usuar. " 	,"@!" 		})
	aadd(aCampos,{"NOME"   ,"Nome   	"   ,"@!"   	})

	TMPP->(dbgotop())

	DEFINE MSDIALOG oCon TITLE 'Consulta de Pallets' from 00,00 to 240,835 OF oMainWnd PIXEL

	@ 005,005 To 90,420 Browse "TMPP"  fields aCampos object oiBrowse
	//@ 008,005 say 'Total de Caixas: ' + transform(_nTotCaix,'@E 999,999')
	//@ 008,030 say 'Total de Peso: '   + transform(_nTotPeso,'@E 999,999,999.99')

	@ 103,170  BUTTON 'Alterar'     SIZE 40,15 ACTION alterar()    	OBJECT oBtn
	@ 103,215  BUTTON 'Excluir'  	SIZE 40,15 ACTION excluir()    	OBJECT oBtn
	@ 103,260  BUTTON 'Dar baixa'   SIZE 40,15 ACTION baixar()    	OBJECT oBtn
	@ 103,305  BUTTON 'Reimprimir'  SIZE 40,15 ACTION Reimp()    	OBJECT oBtn
	@ 103,350  BUTTON 'Sair'        SIZE 40,15 ACTION oCon:end() 	OBJECT oBtn
	ACTIVATE MSDIALOG oCon

	//dbclosearea("TMPP")
	//dbclosearea('PRO')

	TMPP->(dbCloseArea())
	//QRY->(dbCloseArea())

	restarea(_area)

return

//reimpressão da etiqueta
static function Reimp()

	imprime(TMPP->NUMERO, TMPP->DTINC, TMPP->HORA, TMPP->PESO)

return

static function baixar()

	ZBF->(dbSetOrder(1))
	ZBF->(dbGoTop())
	if ZBF->(dbSeek(xFilial('ZBF') + TMPP->NUMERO))
		reclock('ZBF',.f.)
		ZBF->ZBF_DATAS 	:= dDatabase
		ZBF->ZBF_HORAS 	:= time()
		ZBF->ZBF_USRBAI := retCodUsr()
		msunlock()
	endif

	reclock('TMPP',.f.)
	dbdelete()
	msunlock()

	oCon:refresh()
	TMPP->(dbGoTop())

return

static function excluir()

	ZBF->(dbSetOrder(1))
	ZBF->(dbGoTop())
	if ZBF->(dbSeek(xFilial('ZBF') + TMPP->NUMERO))
		reclock('ZBF',.f.)
		ZBF->ZBF_USREXC := retCodUsr()
		dbDelete()
		msunlock()
	endif

	reclock('TMPP',.f.)
	dbdelete()
	msunlock()

	oCon:refresh()
	TMPP->(dbGoTop())

return

/** **/
static function alterar()

	local _npeso := TMPP->ZBF_PESO//

	local _lOk := .f.

	DEFINE MSDIALOG oDlg2 TITLE 'Alterar Dados' from 000,000 To 100,250 PIXEL
	@ 010,002 SAY  'Peso Pallet:' Object oSayPes
	@ 010,035 GET _npeso PICTURE "@E 99.99" SIZE 30,6  VALID !empty(_npeso) .and. _npeso > 0 Object oGet2
	@ 010,95 BMPBUTTON TYPE 1 ACTION (_lOk := .t.,odlg2:end()) Object ObtnPes1
	@ 025,95 BMPBUTTON TYPE 2 ACTION odlg2:end() Object ObtnPes2
	ACTIVATE MSDIALOG oDlg2 CENTERED

	if _lOK
		ZBF->(dbSetOrder(1))
		ZBF->(dbGoTop())
		if ZBF->(dbSeek(xFilial('ZBF') + TMPP->NUMERO))
			if _npeso > 0
				reclock('ZBF',.f.)
				ZBF->ZBF_PESO 	:= _npeso
				ZBF->ZBF_USRALT := retCodUsr()
				msunlock()
	
				reclock('TMPP', .f.)
				TMPP->PESO := _npeso
				msunlock()
			endif
		endif

		oCon:refresh()
		//TMPP->(dbGoTop())

	endif

return
//Função que vai fazer a pesagem das caixas via conexão socket (ethernet)
Static Function CaptIP()
	local _cString  := ""

	nQtd := oObj:Receive(_cString,1000)
	
	/* 
	Problema - quando se abre um telnet o sistema deixa de receber informações
	verificar  uma forma de capturar uma informação e dar um alert na tela do botão
	*/

return _cString
