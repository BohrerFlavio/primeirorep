#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF17  ºAutor  ³Giuliano Forgiarini º Data ³  14/01/08      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesagens de produto acabado - embalagem                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF17()

	//Local aIndSZ8   	:= {}						// Arquivo e número de índice utilizado
	//Local cCondicao 	:= ""						// Condição para a filtragem
	Private _cNumBal  := ''
	Private _lBal      := .f.            //Ativação dos parametros da balança
	Private oObj
	Private nResp      := 0
	Private vNumPrev   := ''
	/////Variavel especial para se utilizar em testes da rotina. 
	Private _SIMULA := getMv('SI_PESO')	
	/////Essa variavel simula o peso capturado. Se valor = 0, está desativada

	lOk := .f.
	oDesc    := ''
	oDataV   := ''
	oTaraP   := 0
	oTaraS   := 0
	vPreDes  := ''
	vClassif := ''

	cPerg := "GJF17"
	Private cCadastro := "Pesagens de Produto Acabado - Embalagem"
	/*
	Private aRotina := { {"Pesquisar","AxPesqui",0,1}  ,;
	{"Visualizar","AxVisual",0,2} ,;
	{"Produzir","u_gjf17pes",0,3} ,;
	{"Relatorio","u_gjf17imp",0,2},;
	{"Excluir","u_gjf17del",0,5}}
	*/
	private cString    := "ZZ9"
	Private _lIntPCP  := GETMV("SI_INTPCP")

	if !pergunte(cPerg,.t.)
		Return
	endif

	// Chama a função que conecta a balança
	//conectBal()

	SetKey(123,{|| pergunte(cPerg,.f.)}) // Seta a tecla F12 para acionamento dos parametros

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a Filtragem                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cNumBal := alltrim(GetAdvFval('SX5','X5_DESCRI',FWxfilial('SX5')+'Z6'+substr(GetComputername(),1,5),1))
	if empty(_cNumBal)
		alert('Estação sem permissão para produzir!')
		return
	endif

	DbSelectArea("ZZ9")

	//SET FILTER TO ZZ9_DATA = date() .and. ZZ9_BALAN = getComputerName()  .and.  ZZ9_FILIAL = FWxfilial('ZZ9')

	//mBrowse(6      ,1      ,22     ,75     ,cString, ,,,,1     ,)
	//      LIN INI,COL INI,LIN FIN,COL FIN,ALIAS  , ,,,,funcao,cores
	u_gjf17pes()

	Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros
	DbCloseArea('ZZ9')

Return

//PRODUCAO - PESAGEM
user function gjf17pes()

	_lLiber := .t.
	_nTP    := 0
	_nTS    := 0
	_nTara  := 0

	RegToMemory("SZ8",.T.)
	M->Z8_ID :=  GetSx8num('SZ8','Z8_ID')
	ConfirmSx8()
	M->Z8_CONTROL := _cNumBal + M->Z8_ID
	//M->Z8_DATAP   := mv_par01
	//oDataP        := mv_par01
	//oLote         := mv_par05
	M->Z8_LOTE    := mv_par05
	M->Z8_OPERA   := cUserName
	M->Z8_FILIAL  := FWxfilial('SZ8')

	if mv_par01 = 1
		M->Z8_TIPO := 'P'
		oTipo := 'Processo'
	else
		M->Z8_TIPO := 'R'
		oTipo := 'Reprocesso'
	endif
	if mv_par02 = 1
		M->Z8_ETIQ := 'PA'
		oEtiq := 'Padrão'
	elseif mv_par02 = 2
		M->Z8_ETIQ := 'ES'
		oEtiq := 'Espanhol'
	elseif mv_par02 = 3
		M->Z8_ETIQ := 'FR'
		oEtiq := 'Frances'
	endif
	if mv_par03 = 1
		M->Z8_TF := 'N'
		oTF      := 'Não'
	else
		M->Z8_TF := 'S'
		oTF      := 'Sim'
	endif
	if mv_par04 = 1
		M->Z8_MDESP := 'N'
		oDesp := 'Não''
	else
		M->Z8_MDESP := 'S'
		oDesp := 'Sim'
	endif
	oDesc := ' '

	TotCaix := contaC()

	DEFINE MSDIALOG oDlg TITLE 'Pesagem de Produto Acabado' from 0,0 To 430,600 PIXEL
	SetKey(118,{|| increm(-1)})  //Seta a tecla F7
	SetKey(119,{|| increm(1)})   //Seta a tecla F8
	SetKey(121,{|| Capt()})      //Tara Manual
	SetKey(123,{|| pergunte(cPerg,.t.)}) // Seta a tecla F12 para acionamento dos parametro

	oFont      := tFont():New("courier new",,-18,,.t.,,,,)
	oFont2     := tFont():New(,,,,.t.,,,,)
	oSayDesc   := tSay():New(080,04,{|| oDesc },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)

	oSayLabel7 := tSay():New(110,004,{|| 'Data de Validade:'},oDlg,,,,,,.T.,,,200,30)
	oSayDataV  := tSay():New(110,060,{|| oDataV},oDlg,,oFont2,,,,.T.,,,200,30)
	//oSayLabel6 := tSay():New(110,004,{|| 'Data de Produção:'},oDlg,,,,,,.T.,,,200,30)
	//oSayDataP  := tSay():New(110,060,{|| oDataP},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel3 := tSay():New(120,004,{|| 'Tipo de Produção:'},oDlg,,,,,,.T.,,,200,30)
	oSayTipo   := tSay():New(120,060,{|| oTipo},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel4 := tSay():New(130,004,{|| 'Tratamento a Frio?'},oDlg,,,,,,.T.,,,200,30)
	oSayTF     := tSay():New(130,060,{|| oTF},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel5 := tSay():New(140,004,{|| 'Tipo de Etiqueta:'},oDlg,,,,,,.T.,,,200,30)
	oSayEtiq   := tSay():New(140,060,{|| oEtiq},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel6 := tSay():New(150,004,{|| 'Mensagem Despojo?'},oDlg,,,,,,.T.,,,200,30)
	oSayDesp   := tSay():New(150,060,{|| oDesp},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel7 := tSay():New(150,100,{|| 'Tara Primaria:'},oDlg,,,,,,.T.,,,200,30)
	oSayTarap  := tSay():New(150,150,{|| transform(oTaraP,'@E9.999')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel8 := tSay():New(160,100,{|| 'Tara Secundaria:'},oDlg,,,,,,.T.,,,200,30)
	oSayTaraS  := tSay():New(160,150,{|| transform(oTaraS,'@E9.999')},oDlg,,oFont2,,,,.T.,,,200,30)

	obj := MsMGet():New("SZ8" ,SZ8->(RECNO()),3   ,     ,     ,     ,          ,{14,2,65,300},              ,,,,,oDlg,,,.F. )

	// inst.  obj.     met. alias,registro      ,oper,p.res,p.res,p.res,vet.campos,vet.coord.,vet.campos.alt, ,
	@ 185,005  BUTTON 'Produzir'   SIZE 57,20 ACTION gjf17pro()  OBJECT oBtn1
	@ 185,070  BUTTON 'Consultar'  SIZE 57,20 ACTION gjf17con()  OBJECT oBtn2
	@ 185,240  BUTTON 'Abandonar'  SIZE 57,20 ACTION ODlg:end()  OBJECT oBtn3
	@ 013,017  SAY 'Caixas produzidas no dia:'+ transform(TotCaix,'@E 9,999')
	@ 016,008  SAY '[F7]Dim.  [F8]Aum.  [F10]Tara Manual  [F12]Param. Iniciais'
	ACTIVATE MSDIALOG oDlg CENTERED //ON INIT EnchoiceBar(oDlg,{||gjf17ok()},{||ODlg:end()})
	Set Key 118 To
	Set Key 119 To
	Set Key 121 To
return

//Incrementa ou decrementa a quantidade
Static Function Increm(i)
	M->Z8_QUANT += i
	if M->Z8_QUANT < 1
		Alert("Quantidade Insuficiente!")
		M->Z8_QUANT := 1
	endif

	u_gjf17T()

Return

//Para excluir uma pesagem
user function gjf17del()
	SZ8->(dbsetorder(3))
	if SZ8->(MsSeek(FWxfilial('SZ8')+ZZ9->ZZ9_CONTRO))  .and. ;
		msgbox('Deseja realmente excluir essa pesagem?','CONFIRMAÇÃO DE OPERAÇÃO','YESNO')

		if !u_gjf34CCX(SZ8->Z8_DATAS)
			return .f.
		endif

		if empty(SZ8->Z8_DATAS) .and. SZ8->Z8_BALAN = getComputerName()

			SZU->(dbsetorder(2))
			SZU->(MsSeek(FWxfilial('SZU')+SZ8->Z8_NUMPREV))

			//para descontar a quantidade já produzida na previsão de produção
			//if SZU->ZU_FECHADO == 'S'
			//	u_gjf32(SZ8->Z8_NUMPREV,'R') // função criada para realizar as movimentações internas (SD3)
			//	pergunte(cPerg,.f.)
			//endif

			reclock('SZU',.f.)
			SZU->ZU_FECHADO := 'N'
			SZU->ZU_QRPESO  := SZU->ZU_QRPESO  - SZ8->Z8_PESO
			SZU->ZU_QRCAIX  := SZU->ZU_QRCAIX  - 1
			SZU->ZU_QRQUANT := SZU->ZU_QRQUANT - SZ8->Z8_QUANT
			msunlock()

			reclock('SZ8',.f.)
			SZ8->Z8_DATAE := date()
			SZ8->Z8_HORAE := time()
			msunlock()

			reclock('SZ8',.f.)
			DBdelete()
			msunlock()

			reclock('ZZ9',.f.)
			DBdelete()
			msunlock()

			u_gjf17his(2,'EXCLUSAO DA PRODUCAO',.f.,'','','000011',SZ8->Z8_CONTROL)
			apmsginfo("Operação realizada com sucesso!","Exclusão")
		else
			msgbox('Caixa já carregada ou pesada em outra balança!','OPERACAO IMPOSSÍVEL','STOP')
		endif
	endif
return

static function gjf17pro()
	Local nCont

	diasVal  := 0
	vNumPrev := ''
	vPreDes  := ''
	vClassif := ''

	if !_lLiber
		return
	endif
	if gjf17v()
		//conectBal()
		_lLiber := .f.
		//para realizar a produção: pesagem e etiqueta
		if !empty(M->Z8_COD) .and. M->Z8_QUANT > 0

			sleep(6000)                                     //Tempo de 3 seg para estabilizar a balança

			if _SIMULA = 0
				//M->Z8_PESOBR := digitaPeso()// Dia 22/02 Flávio voltou
				//M->Z8_PESOBR := u_gjf17cap() //captura por porta serial				
				M->Z8_PESOBR := 0
				M->Z8_PESOBR := newCaptura()
			else
				M->Z8_PESOBR := _SIMULA
			endif

			if M->Z8_PESOBR < 1 .or. M->Z8_PESOBR > 40      //se a pesagem não estiver entre 1 e 40, é porque tá com problema
				msgbox('Problema na captura da pesagem!','PESO INCONSISTENTE!' , 'STOP')
				_lLiber := .t.							
				return
			endif

			M->Z8_PESO := M->Z8_PESOBR - M->Z8_TARA         //calculo do peso liquido

			diasVal := GetAdvFval('SB1','B1_VALID',FWxfilial("SB1")+alltrim(M->Z8_COD),1)

			if !msgbox(transform(M->Z8_PESOBR,'@E 99.999'),'CONFIRMA PESAGEM?','YESNO')
				_lLiber := .t.									
				return
			endif

			SZU->(dbsetorder(2))
			if SZU->(MsSeek(FWxfilial('SZU')+vNumPrev))
				if SZU->ZU_FECHADO = 'S'
					msgbox('Produção não prevista para esse produto ou já encerrada!','NAO É POSSIVEL PRODUZIR!','STOP')
					M->Z8_COD    := space(6)
					M->Z8_DESCRI := space(1)
					//oObj:CloseConnection()
					_lLiber := .t.
					return .f.
				endif
			endif

			_lPesMinMds := getMV('SI_PESMINM')
			_nPesMin := GetAdvFval('SB1','B1_PESOMIN',FWxfilial("SB1")+alltrim(M->Z8_COD),1)
			_cCorOri := GetAdvFval('SB1','B1_CORORI',FWxfilial("SB1")+alltrim(M->Z8_COD),1)

			if _lPesMinMds .and. _cCorOri = 'M'
				if _nPesMin <> 0
					if M->Z8_PESO < _nPesMin 
						msgbox('Peso Liq. da caixa abaixo do informado no cadastro!' + transform(_nPesMin,'@E 99.99'),'NAO É POSSIVEL PRODUZIR!','STOP')
						M->Z8_COD    := space(6)
						M->Z8_DESCRI := space(1)
						_lLiber := .t.
						return .f.
					endif
				endif
			endif

			_dtAbate := GetAdvFval('SZ2','Z2_DATAABT',FWxFilial('SZ2') + vPreDes,2)

			_nNumEtq    := SZU->ZU_NUMETQ
			M->Z8_DATAP := SZU->ZU_DTPROD   //Assume a data de produção especificada na previsão. Alterado em 04.04.11			
			M->Z8_FILORI  := FWxfilial('SB1')
			M->Z8_FIL     := FWxfilial('SB1')
			M->Z8_CODORI  := M->Z8_COD
			//M->Z8_DATAVAL := iif(empty(vPreDes),M->Z8_DATAP,_dtAbate) + diasVal   //calculo da data de validade
			M->Z8_NUMPREV := vNumPrev                  //gravação do numero da previsão de produção no registro da caixa  (veio da gjf17v() )
			M->Z8_PREDES  := alltrim(vPreDes)
			M->Z8_CLASSIF := alltrim(vClassif)
			M->Z8_DTENTES := ddatabase
			M->Z8_LOTE    := SZU->ZU_LOTE
			M->Z8_ORIGEM  := 'P'

			_cdExp := getmv('SI_CODEXP')

			if alltrim(M->Z8_COD) $ _cdExp//tratamento do calculo de dias de validade de acordo com o tipo de produto ser exportação ou não
				M->Z8_DATAVAL := M->Z8_DATAP + diasVal   //calculo da data de validade
			else
				M->Z8_DATAVAL := iif(empty(vPreDes),M->Z8_DATAP,_dtAbate) + diasVal   //calculo da data de validade
			endif

			obj:refresh()

			if !gjf17pre()                             //esta função grava a quantidade produzida na previsão de produção
				//msgbox('Número de peças a ser produzido deve ser exato à previsão!','PRIORIDADE POR PEÇAS!','STOP')
				M->Z8_COD    := space(6)
				M->Z8_DESCRI := space(1)
				_lLiber := .t.
				return .f.
			endif

			_cEst := getComputerName()
			ZAM->(dbSetOrder(2))
			if ZAM->(MsSeek(FWxFilial('ZAM') + alltrim(_cEst)))
				_cIp := alltrim(ZAM->ZAM_IP)
			else
				_cIp := ""
			endif

			u_GJF111a(mv_par08,mv_par09,M->Z8_CONTROL,M->Z8_COD,M->Z8_QUANT,M->Z8_PESOBR,M->Z8_PESO,M->Z8_TARA,M->Z8_PREDES,M->Z8_CLASSIF,;
				M->Z8_TF,M->Z8_DATAP,M->Z8_ETIQ,M->Z8_DATAVAL,_nNumEtq,M->Z8_LOTE,_cIp,M->Z8_SEQPETQ,,M->Z8_HORA,,M->Z8_NUMPREV)

			recLock('SZ8',.t.)
			For nCont := 1 To FCount()             //numero de campos na tabela corrente
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,FWxFilial("SZ8"))
				Else
					FieldPut(nCont,M->&(FIELDNAME(nCont)))
				Endif
			Next nCont
			MsUnLock()

			u_gjf17his(1,'PRODUCAO',.f.,'','','000012',M->Z8_CONTROL)               //grava o histórico da caixa

			//dbselectarea('SB1')
			reclock('ZZ9',.t.)
			ZZ9->ZZ9_FILIAL  := FWxfilial('SB1')
			ZZ9->ZZ9_DATA    := M->Z8_DATA
			ZZ9->ZZ9_HORA    := M->Z8_HORA
			ZZ9->ZZ9_BALAN   := M->Z8_BALAN
			ZZ9->ZZ9_OPERA   := M->Z8_OPERA
			ZZ9->ZZ9_QUANT   := M->Z8_QUANT
			ZZ9->ZZ9_TARA    := M->Z8_TARA
			ZZ9->ZZ9_PESO    := M->Z8_PESO
			ZZ9->ZZ9_PESOBR  := M->Z8_PESOBR
			ZZ9->ZZ9_CONTROL := M->Z8_CONTROL
			ZZ9->ZZ9_COD     := M->Z8_COD
			ZZ9->ZZ9_DESCRI  := M->Z8_DESCRI
			ZZ9->ZZ9_DATAVA  := M->Z8_DATAVAL
			ZZ9->ZZ9_NUMPREV := M->Z8_NUMPREV
			msunlock()

			//limpa os campos na memoria
			M->Z8_ID      := GetSx8num('SZ8','Z8_ID')
			ConfirmSx8()
			M->Z8_DATA    := date()
			M->Z8_HORA    := time()
			M->Z8_BALAN   := getComputerName()
			M->Z8_OPERA   := cUserName
			diasVal       := ' '
			M->Z8_VALID   := ' '
			M->Z8_QUANT   := 0
			M->Z8_TARA    := 0
			M->Z8_TARAS   := 0
			M->Z8_PESO    := 0
			M->Z8_PESOBR  := 0
			M->Z8_PREDES  := ' '
			M->Z8_CLASSIF := ' '
			M->Z8_NUMPREV := ' '
			M->Z8_DESCRI  := ' '
			M->Z8_DATAP   := stod('')
			M->Z8_DTENTES := stod('')
			oDesc         := ' '
			oDataV        := ' '
			oTaraP        := 0
			oTaraS        := 0
			M->Z8_OPERE   := cUserName
			M->Z8_CONTROL := _cNumBal + M->Z8_ID
			TotCaix++
			obj:setfocus()
			oDlg:refresh()
		else
			msgbox("Codigo do produto ou quantidade não digitada!","OPERACAO RECUSADA!","STOP")
			M->Z8_DESCRI := space(1)
		endif
		_lLiber := .t.
	endif
	If Select("SB1")<>0
		SB1->(dbCloseArea())
	Endif
	If Select("SZU")<>0
		SZU->(dbCloseArea())
	Endif
	If Select("SZ8")<>0
		SZ8->(dbCloseArea())
	Endif

	vPreDes  := ''
	vNumPrev := ''
	vClassif := ''
	//oObj:CloseConnection()
return

Static Function digitaPeso()

	Local _nPeso := 0

	DEFINE MSDIALOG oDlg2 TITLE 'Peso da Caixa' from 000,000 To 100,250 PIXEL
	@ 010,002 SAY  'Peso Caixa:' Object oSayPes
	@ 010,035 GET _nPeso PICTURE "@E 99.99" SIZE 30,6  VALID !empty(_nPeso) .and. _nPeso > 0 Object oGet2
	@ 010,95 BMPBUTTON TYPE 1 ACTION (_lOk := .t.,odlg2:end()) Object ObtnPes1
	@ 025,95 BMPBUTTON TYPE 2 ACTION odlg2:end() Object ObtnPes2
	ACTIVATE MSDIALOG oDlg2 CENTERED

return _nPeso

//Função que grava o histórico de caixas
user function gjf17his(pTipo,pDesc,_lRep,_cFilOri,_cFilDes,_cCodMsg,_cControl,_cLocal,_cLocaliz,_cPallet)
	reclock('SZV',.t.)
	SZV->ZV_FILIAL  := FWxfilial('SZV')
	SZV->ZV_ID      := GetSx8num('SZV','ZV_ID')
	ConfirmSx8()
	if !empty(_cControl)
		SZV->ZV_CONTROL := _cControl
	else
		SZV->ZV_CONTROL := SZ8->Z8_CONTROL
	endif
	if !empty(_cLocal)
		SZV->ZV_LOCAL := _cLocal
	endif
	if !empty(_cLocaliz)
		SZV->ZV_LOCALIZ := _cLocaliz
	endif
	if !empty(_cPallet)
		SZV->ZV_PALLET := _cPallet
	endif
	SZV->ZV_DATA    := date()
	SZV->ZV_HORA    := time()
	SZV->ZV_FILORI  := _cFilOri
	SZV->ZV_FILDES  := _cFilDes

	if _lRep
		SZV->ZV_DESC    := 'REPROCESSO'
		SZV->ZV_REP     :=  'S'
	else
		SZV->ZV_DESC    := pDesc
	endif

	SZV->ZV_USAR    := cUserName
	SZV->ZV_EST     := getComputerName()
	if pTipo == 1
		SZV->ZV_TIPO   := 'E'
	elseif pTipo == 2
		SZV->ZV_TIPO   := 'S'
	elseif pTipo == 3
		SZV->ZV_TIPO   := 'M'
	elseif pTipo == 4
		SZV->ZV_TIPO   := 'P'
	endif

	SZV->ZV_CODMSG := _cCodMsg

	MsUnLock()
	//Dbclosearea('SZV')


return

static function gjf17pre()
	//função para atualizar a quantidade produzida na previsão de produção

	qPrevC := SZU->ZU_QPCAIX
	qRealC := SZU->ZU_QRCAIX
	qPrevP := SZU->ZU_QPPESO
	qRealP := SZU->ZU_QRPESO
	qPrevQ := SZU->ZU_QPQUANT
	qRealQ := SZU->ZU_QRQUANT

	overflow  := .f.
	overflow2 := .f.

	do case
		case SZU->ZU_PRIORI = "C"
		if SZU->ZU_QPCAIX = qRealC + 1
			overflow := .t.                    //se a previsão foi cumprida, então o overflow determina o seu encerramento
		endif
		case SZU->ZU_PRIORI = "P"
		if SZU->ZU_QPPESO  <= qRealP + M->Z8_PESO
			overflow := .t.                    //se a previsão foi cumprida, então o overflow determina o seu encerramento
		endif
		case SZU->ZU_PRIORI = "A"
		if SZU->ZU_QPPESO <= qRealP + M->Z8_PESO .or. SZU->ZU_QPCAIX = qRealC + 1
			overflow := .t.
		endif
		case SZU->ZU_PRIORI = "E"                //se a previsão for por peças
		if (qRealQ + M->Z8_QUANT) > qPrevQ
			msgbox('Se produzir a quantidade declarada nessa caixa,' +;
			' então o número de peças produzidas desse produto' +;
			' irá ultrapassar!','PREVISAO DE PRODUCAO ENCERRADA!','STOP')

			overflow  := .t.
			overflow2 := .t.
		endif
	endcase

	reclock('SZU',.f.)

	if !overflow2
		SZU->ZU_QRCAIX  := qRealC + 1
		SZU->ZU_QRPESO  := qRealP + M->Z8_PESO
		SZU->ZU_QRQUANT := qRealQ + M->Z8_QUANT
	endif

	if overflow .or. overflow2
		SZU->ZU_FECHADO := 'S'
		if _lIntPCP
			u_GJF32(vNumPrev)
		endif
		pergunte(cPerg,.f.)

	endif

	MsUnLock()

	if overflow
		msgbox('Previsão de Produção para este produto totalmente atendida!','CONFIRMAÇÃO DE PRODUÇÃO!','INFO')
	endif

	ret := iif(overflow2,.f.,.t.)

return ret

//função separada para capturar peso com a balança nova
Static Function newCaptura()

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
	M->Z8_PESOBR 	:= 0

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
	//alert('Peso da balanca: '+ transform(nPeso,'@E 99.999'))

return nPeso

// para capturar o peso por porta serial
user Function gjf17cap()

	nHdll := 0

	if !MSOpenPort(nHdll,mv_par06)
		msgbox("Não foi possível pegar informações da porta!",,"STOP")
		lOk := .f.
		Return 0
	endif

	cText := space(15)
	if !MsRead(nHdll,@cText)
		msgbox("Não foi possível pegar informações da porta!",,"STOP")
		lOk := .f.
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

	nPeso := val(cPeso)/(10**mv_par07)

	if valtype(nPeso) == 'N'
		v := npeso
	else
		v     := 0
		nPeso := 0
	endif
	msClosePort(nHdll)
	lOk := .t.
Return nPeso

//Verifica se os parametros coincidem com as previsões de produção da desossa
static function gjf17v()

	if !empty(M->Z8_COD)
		M->Z8_COD := padl(alltrim(M->Z8_COD),6,'0')
	else
		return .t.
	endif

	segUM := ''

	segUM := GetAdvFval('SB1','B1_SEGUM',FWxfilial('SB1')+alltrim(M->Z8_COD),1)

	if segUM == 'PC'
		msgbox('Este produto não é embalado em caixas!','NAO É POSSIVEL PRODUZIR!','STOP')
		M->Z8_QUANT := 0
		return .f.
	endif
	//para verificação se existe previsao de pesagem
	_cQuery := "SELECT COUNT(ZU_COD)AS CONTA, ZU_COD AS CODIGO,ZU_NUM AS NUM, ZU_PREDES AS PREDES FROM "+RetSqlName("SZU")+" SZU " +;
	" WHERE SZU.D_E_L_E_T_ <> '*' " +;
	"  AND SZU.ZU_COD     = '" + M->Z8_COD   +; //"' AND SZU.ZU_DTPROD  = '" + DTOS(M->Z8_DATAP) +;
	"' AND SZU.ZU_DTRPRO  = '" + DTOS(date())+;
	"' AND SZU.ZU_TIPO    = '" + M->Z8_TIPO  +;
	"' AND SZU.ZU_ETIQ    = '" + M->Z8_ETIQ  +;
	"' AND SZU.ZU_TF      = '" + M->Z8_TF    +;
	"' AND SZU.ZU_MDESP   = '" + M->Z8_MDESP +;
	"' AND SZU.ZU_FECHADO = 'N' "+;
	" AND SZU.ZU_FECHADO <> 'B' "+;
	" AND SZU.ZU_FILIAL = '" + FWxfilial("SZU") + "'" +;
	" GROUP BY ZU_COD, ZU_NUM,ZU_PREDES"
	//"' AND SZU.ZU_QPCAIX  > SZU.ZU_QRCAIX "  +;
	_cQuery := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("VER")<>0
		VER->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "VER"

	if VER->CONTA = 0
		msgbox('Produção não prevista para esse produto ou já encerrada!','NAO É POSSIVEL PRODUZIR!','STOP')
		M->Z8_QUANT := 0
		VER->(dbclosearea())
		dbselectarea('SZ8')
		return .f.
	endif

	DbSelectArea('SB1')

	//para mostrar o label do produto

	_dtAbate := GetAdvFval('SZ2','Z2_DATAABT',FWxFilial('SZ2') + VER->PREDES,2)

	oDesc  := GetAdvFval('SB1','B1_DESCRED',FWxfilial('SB1')+VER->CODIGO,1)
	oDataV := date() + GetAdvFval('SB1','B1_VALID',FWxfilial('SB1')+VER->CODIGO,1)

	_NTARAp := GetAdvFval('SB1','B1_CTARAP',FWxfilial('SB1')+VER->CODIGO,1)      // Linhas inseridas para buscar
	oTarap  := GetAdvFval('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_NTARAp),1)  // os campos de codigo das taras primarias

	_NTARAs := GetAdvFval('SB1','B1_CTARASE',FWxfilial('SB1')+VER->CODIGO,1)     //Linhas inseridas para buscar
	oTaraS  := GetAdvFval('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_NTARAs),1)  // os campos de codigo das taras secundaria

	M->Z8_TARAS := oTaras

	oSayDesc:SetText(oDesc)
	oSayDataV:SetText(oDataV)
	oSayTaraP:SetText(oTaraP)
	oSayTaraS:SetText(oTaraS)

	vNumPrev := VER->NUM
	vPreDes  := VER->PREDES

	if !empty(vPreDes)
		vClassif := GetAdvFval('SZ2','Z2_CLASSIF',FWxfilial('SZ2')+VER->PREDES,2)
	endif

	odlg:Refresh()
	VER->(dbclosearea())
	dbselectarea('SZ8')
	oBtn1:setfocus()

return .t.

static function contaC()

	_cQuery := "SELECT COUNT(*) AS CAIXAS FROM "+RetSqlName("SZ8")+" SZ8 " +;
	" WHERE SZ8.D_E_L_E_T_ <> '*' " +;
	"  AND SZ8.Z8_DATA    = '" + DTOS(Date())+;
	"' AND SZ8.Z8_DATAE   = ' '" +;
	"  AND SZ8.Z8_FILIAL = '"+ FWxfilial("SZ8") + "'" +;
	"  AND SZ8.Z8_BALAN   = '" + GetComputerName()+"'"

	_cQuery := ChangeQuery(_cQuery)

	If Select("CON")!= 0
		CON->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "CON"
	nCaixas := CON->CAIXAS
	CON->(dbclosearea())

return nCaixas

static function gjf17con()

	cQuery := "SELECT Z8_COD AS CODIGO,Z8_DESCRI AS DESCRI, COUNT(Z8_COD) AS CAIXAS, SUM(Z8_PESO) AS PESO "+;
	"FROM SZ8010                                                                               "+;
	"WHERE SZ8010.D_E_L_E_T_ <> '*' AND Z8_DATAE = ' ' AND Z8_DATA = '" + DTOS(DATE())+"'"      +;
	" AND Z8_BALAN = '" + GetComputerName()+"'"                                                 +;
	" AND Z8_FILIAL = '" + FWxfilial('SZ8')+"'"                                                   +;
	" GROUP BY Z8_COD, Z8_DESCRI                                                               "+;
	" ORDER BY Z8_COD"

	cQuery := ChangeQuery(cQuery)

	If Select("QRY")<>0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"

	area := getarea()

	cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	dbSelectarea('QRY')

	aStru := dbStruct()                                                           //Pega a estrutura do QRY e atribui a um vetor

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	_aArqTrb    := {} 
	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	QRY->(dbgotop())

	SBM->(dbsetorder(1))

	while QRY->(!eof())
		DbSelectArea('TMP')
		reclock('TMP',.t.)
		TMP->CODIGO  := QRY->CODIGO
		TMP->DESCRI  := QRY->DESCRI
		TMP->CAIXAS  := QRY->CAIXAS
		TMP->PESO    := QRY->PESO
		msunlock()
		QRY->(dbskip())
	enddo

	aCampos := {}
	aadd(aCampos,{"CODIGO" ,"Codigo ",""})
	aadd(aCampos,{"DESCRI" ,"Descricao   ",""})
	aadd(aCampos,{"CAIXAS" ,"Caixas ","@E 999"  })
	aadd(aCampos,{"PESO"   ,"Peso   ","@E 9,999.99"})

	TMP->(dbgotop())

	DEFINE MSDIALOG oEnc TITLE 'Consulta de Pesagens do Dia' from 00,00 to 240,610 OF oMainWnd PIXEL

	@ 005,005 To 100,300 Browse "TMP"  fields aCampos object oiBrowse
	@ 103,250  BUTTON 'Sair'        SIZE 40,15 ACTION oEnc:end() OBJECT oBtn

	ACTIVATE MSDIALOG oEnc

	//dbclosearea('TMP')
	//dbclosearea('QRY')
	TMP->(dbCloseArea())
	QRY->(dbCloseArea())

	u_arqtrb("FechaTodos",,,, @_aArqTrb)

	restarea(area)
return

Static Function CapT()
	_nTara := u_gjf17cap()
	if _nTara > 0
		msgbox('Valor da tara capturada (Kg): '+ transform(_nTara,'@E 999.999'),'Captura Realizada!','INFO')
	else
		msgbox('Problemas com a captura da Tara!','Valor inconsistente!','ERRO')
	endif

	_cCodTP := GetAdvFval('SB1','B1_CTARAP',FWxfilial('SB1')+alltrim(M->Z8_COD),1)  //Linhas inseridas para verificar o codigo
	_nTP := GetAdvFval('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_cCodTP),1)      //das taras modificado por Fabian Maurer 26/08/11
	//_nTP := GetAdvFval('ZAB',1,FWxfilial('ZAB')+alltrim(M->Z8_COD),'ZAB_TARA')
	//_nTP := GetAdvFval('SB1',1,FWxfilial('SB1')+alltrim(M->Z8_COD),'B1_TARAP')   Linha que funcionava antes da mudança para codigo de tara
	M->Z8_TARA  := _nTara + (_nTP * M->Z8_QUANT)
	M->Z8_TARAS := _nTara
Return

User Function gjf17T()
	DbSelectArea('SB1')

	//Busca Tara Secundaria
	_cCodTS := GetAdvFval('SB1','B1_CTARASE',FWxfilial('SB1')+alltrim(M->Z8_COD),1) // Linhas inseridas para buscar
	_nTS    := GetAdvFval('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_cCodTS),1)     // os codigos das taras Secundarias

	//Busca Tara Primária
	_cCodTP := GetAdvFval('SB1','B1_CTARAP',FWxfilial('SB1')+alltrim(M->Z8_COD),1)  // Linhas inseridas para buscar
	_nTP    := GetAdvFval('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_cCodTP),1)     // os codigos das taras Primarias
	if _nTara = 0
		_nTaraT := _nTS + (_nTP * M->Z8_QUANT)
	else
		_nTaraT := _nTara + (_nTP * M->Z8_QUANT)
	endif

	if _nTP = 0 .OR. _nTS = 0
		_nTaraT := 0
	endif

return _nTaraT

//função para conectar na balança
Static Function conectBal()

	//Define o IP da balança a se utilizada
	_cEst   := getComputerName()
	//_cEst := 'MDS02'

	_cIpBal := alltrim(GetAdvFval('ZAM','ZAM_IP',FWxFilial('ZAM') + iif(_cEst = 'MDS01','BMDS1',;
	iif(_cEst = 'MDS02','BMDS2',;
	iif(_cEst = 'MDS03','BMDS3',;
	iif(_cEst = 'CHR01','BCHR1',;
	iif(_cEst = 'DTI30','BCHR1',;
	iIf(_cEst = 'CAM04','BCAM1','XXXXX')))))),1))

	if empty(_cIpBal)
		alert('Endereço IP da balança não encontrado!')
		return
	endif

	//Se a balança já estiver conectada, desconecta...
	if _lBal
		oObj:CloseConnection()
	endif

	oObj  := tSocketClient():New()
	nResp := oObj:Connect( 9092, _cIpBal,1000)  //9092
	nResp := oObj:Send( 'Teste' )

	_lBal := .t.

return
