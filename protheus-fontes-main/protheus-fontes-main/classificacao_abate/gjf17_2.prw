#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "totvs.ch"
#INCLUDE "colors.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±�ÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³GJF17  ºAutor  ³Giuliano Forgiarini º Data ³  14/01/08      º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Pesagens de produto acabado - Mi�dos                       º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºManute��o ³ Mauricio Lopes Roehrs              º Data ³  05/12/14       ±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF17_2()

	Private _cNumBal  	:= ''
	Private _lBal      	:= .f.            //Ativa��o dos parametros da balan�a
	Private oObj
	Private nResp      	:= 0

	/////Variavel especial para se utilizar em testes da rotina
	Private _SIMULA := 0
	/////Essa variavel simula o peso capturado. Se valor = 0, est� desativada
		/*  No scanear a pr�-etiqueta o sistema chama esta rotina abaixo 
		- Cod.Pre-Etq. -  ZZP_NUM  - u_gjf17v_2()  */
	lOk := .f.
	oDesc    := ''
	oDataV   := ''
	oTaraP   := 0
	oTaraS   := 0
	_cPetq  	:= space(11)
	vNumPrev := ''
	vPreDes  := ''
	vClassif := ''
	campo1   := space(11)

	cPerg := "GJF17"
	Private cCadastro := "Pesagens de Produto Acabado - Embalagem"

	private cString    := "ZZ9"
	Private _lIntPCP  := GETMV("SI_INTPCP")

	if !pergunte(cPerg,.t.)
		Return
	endif

	// Chama a fun��o que conecta a balan�a
	//conectBal()

	SetKey(123,{|| pergunte(cPerg,.f.)}) // Seta a tecla F12 para acionamento dos parametros

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a Filtragem                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cNumBal := alltrim(GetAdvFVal('SX5','X5_DESCRI',FWxfilial('SX5')+'Z6'+substr(GetComputername(),1,5),1))
	if empty(_cNumBal)
		alert('Esta��o sem permiss�o para produzir!')
		return
	endif

	DbSelectArea("ZZ9")

	gjf17pes()

	Set Key 123 To // Desativa a tecla F12 do acionamento dos parametros
	DbCloseArea()

Return

//PRODUCAO - PESAGEM
static function gjf17pes()

	_lLiber := .t.
	_nTP    := 0
	_nTS    := 0
	_nTara  := 0

	RegToMemory("SZ8",.T.)
	RegToMemory("ZZP",.T.)
	M->Z8_ID :=  GetSx8num('SZ8','Z8_ID')
	ConfirmSx8()
	M->Z8_CONTROL := _cNumBal + M->Z8_ID
	M->Z8_LOTE    := mv_par05
	M->Z8_OPERA   := cUserName
	M->Z8_OPERE   := cUserName
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
		oEtiq := 'Padr�o'
	elseif mv_par02 = 2
		M->Z8_ETIQ := 'ES'
		oEtiq := 'Espanhol'
	elseif mv_par02 = 3
		M->Z8_ETIQ := 'FR'
		oEtiq := 'Frances'
	endif
	if mv_par03 = 1
		M->Z8_TF := 'N'
		oTF      := 'N�o'
	else
		M->Z8_TF := 'S'
		oTF      := 'Sim'
	endif
	if mv_par04 = 1
		M->Z8_MDESP := 'N'
		oDesp := 'N�o''
	else
		M->Z8_MDESP := 'S'
		oDesp := 'Sim'
	endif
	oDesc := ' '

	TotCaix := contaC()

	DEFINE MSDIALOG oDlg TITLE 'Pesagem de Produto Acabado' from 0,0 To 430,600 PIXEL

	oFont      := tFont():New("courier new",,-18,,.t.,,,,)
	oFont2     := tFont():New(,,,,.t.,,,,)
	oSayDesc   := tSay():New(100,04,{|| oDesc },oDlg,,oFont,,,,.T.,CLR_HBLUE,CLR_HBLUE,200,30)

	oSayLabel7 := tSay():New(110,004,{|| 'Data de Validade:'},oDlg,,,,,,.T.,,,200,30)
	oSayDataV  := tSay():New(110,060,{|| oDataV},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel3 := tSay():New(120,004,{|| 'Tipo de Produ��o:'},oDlg,,,,,,.T.,,,200,30)
	oSayTipo   := tSay():New(120,060,{|| oTipo},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel4 := tSay():New(130,004,{|| 'Tratamento a Frio?'},oDlg,,,,,,.T.,,,200,30)
	oSayTF     := tSay():New(130,060,{|| oTF},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel5 := tSay():New(140,004,{|| 'Tipo de Etiqueta:'},oDlg,,,,,,.T.,,,200,30)
	oSayEtiq   := tSay():New(140,060,{|| oEtiq},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel6 := tSay():New(150,004,{|| 'Mensagem Despojo?'},oDlg,,,,,,.T.,,,200,30)
	oSayDesp   := tSay():New(150,060,{|| oDesp},oDlg,,oFont2,,,,.T.,,,200,30)/**/
	oSayLabel7 := tSay():New(150,100,{|| 'Tara Primaria:'},oDlg,,,,,,.T.,,,200,30)
	oSayTarap  := tSay():New(150,150,{|| transform(oTaraP,'@E9.999')},oDlg,,oFont2,,,,.T.,,,200,30)
	oSayLabel8 := tSay():New(160,100,{|| 'Tara Secundaria:'},oDlg,,,,,,.T.,,,200,30)
	oSayTaraS  := tSay():New(160,150,{|| transform(oTaraS,'@E9.999')},oDlg,,oFont2,,,,.T.,,,200,30)

	_aAlter := {'COD','QUANT'}

	obj  := MsMGet():New("SZ8" ,SZ8->(RECNO()),3   ,     ,     ,     ,          ,{14,2,65,300}, _aAlter      ,,,,,oDlg,,,.F. )
	obj2 := MsMGet():New("ZZP" ,ZZP->(RECNO()),3   ,     ,     ,     ,          ,{65,2,95,300},              ,,,,,oDlg,,,.F. )

	@ 185,005  BUTTON 'Consultar'  SIZE 57,20 ACTION gjf17con()  OBJECT oBtn2
	@ 185,240  BUTTON 'Abandonar'  SIZE 57,20 ACTION ODlg:end()  OBJECT oBtn3
	@ 013,017  SAY 'Caixas produzidas no dia:'+ transform(TotCaix,'@E 9,999')
	ACTIVATE MSDIALOG oDlg CENTERED //ON INIT EnchoiceBar(oDlg,{||gjf17ok()},{||ODlg:end()})
	Set Key 118 To
	Set Key 119 To
	Set Key 121 To
return

//Para excluir uma pesagem
static function gjf17del()
	SZ8->(dbsetorder(3))
	if SZ8->(MsSeek(FWxfilial('SZ8')+ZZ9->ZZ9_CONTRO))  .and. ;
	msgbox('Deseja realmente excluir essa pesagem?','CONFIRMA��O DE OPERA��O','YESNO')

		if !u_gjf34CCX(SZ8->Z8_DATAS)
			return .f.
		endif

		if empty(SZ8->Z8_DATAS) .and. SZ8->Z8_BALAN = getComputerName()

			SZU->(dbsetorder(2))
			SZU->(MsSeek(FWxfilial('SZU')+SZ8->Z8_NUMPREV))

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

			u_gjf17his(2,'EXCLUSAO DA PRODUCAO',.f.,'','','000011',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)
			apmsginfo("Opera��o realizada com sucesso!","Exclus�o")
		else
			msgbox('Caixa j� carregada ou pesada em outra balan�a!','OPERACAO IMPOSS�VEL','STOP')
		endif
	endif
return

static function gjf17pro(_lValid,cZZPNum)
	Local nCont
	if !_lLiber
		return
	endif

	if _lValid
		//conectBal()
		_lLiber := .f.
		//para realizar a produ��o: pesagem e etiqueta
		if !empty(M->Z8_COD) .and. M->Z8_QUANT > 0

			sleep(6000)                                     //Tempo de 3 seg para estabilizar a balan�a

			if _SIMULA = 0
				//M->Z8_PESOBR := gjf17cap()
				M->Z8_PESOBR := 0
				M->Z8_PESOBR := newCaptura()
			else
				M->Z8_PESOBR := _SIMULA
			endif

			if M->Z8_PESOBR < 1 .or. M->Z8_PESOBR > 40      //se a pesagem n�o estiver entre 1 e 40, � porque t� com problema
				msgbox('Problema na captura da pesagem!','PESO INCONSISTENTE!' , 'STOP')
				//oObj:CloseConnection()
				_lLiber := .t.
				return
			endif

			M->Z8_PESO := M->Z8_PESOBR - M->Z8_TARA         //calculo do peso liquido

			diasVal := GetAdvFVal('SB1','B1_VALID',FWxfilial("SB1")+alltrim(M->Z8_COD),1)

			if !msgbox(transform(M->Z8_PESOBR,'@E 99.999'),'CONFIRMA PESAGEM?','YESNO')
				//oObj:CloseConnection()
				_lLiber := .t.
				return
			endif

			SZU->(dbsetorder(2))
			if SZU->(MsSeek(FWxfilial('SZU')+vNumPrev))
				if SZU->ZU_FECHADO = 'S'
					msgbox('Produ��o n�o prevista para esse produto ou j� encerrada!','NAO � POSSIVEL PRODUZIR!','STOP')
					M->Z8_COD    := space(6)
					M->Z8_DESCRI := space(1)
					//oObj:CloseConnection()
					_lLiber := .t.
					odlg:Refresh()
					return .f.
				endif
			endif

			_lPesMinMds := getMV('SI_PESMINM')
			_nPesMin := GetAdvFVal('SB1','B1_PESOMIN',FWxfilial("SB1")+alltrim(M->Z8_COD),1)
			_cCorOri := GetAdvFVal('SB1','B1_CORORI',FWxfilial("SB1")+alltrim(M->Z8_COD),1)
			_nPesFix := GetAdvFVal('SB1','B1_PESFIX',FWxfilial("SB1")+alltrim(M->Z8_COD),1)
			_cdExp := alltrim(GetAdvFVal('SB1','B1_DESTINO',FWxfilial('SB1') + alltrim(M->Z8_COD),1))
			_cGrupo := GetAdvFVal('SB1','B1_GRUPO',FWxfilial("SB1")+alltrim(M->Z8_COD),1)
			_cFarm := GetAdvFval('SBM','BM_FARM',FWxfilial('SBM')+_cGrupo,1)

			if _lPesMinMds .and. _cCorOri = 'M'
				if _nPesMin <> 0
					if M->Z8_PESO < _nPesMin
						msgbox('Peso Liq. da caixa abaixo do informado no cadastro!' + transform(_nPesMin,'@E 99.99'),'NAO � POSSIVEL PRODUZIR!','STOP')
						M->Z8_COD    := space(6)
						M->Z8_DESCRI := space(1)
						_lLiber := .t.
						odlg:Refresh()
						return .f.
					endif
				endif
			endif

			//_dtAbate := GetAdvFVal('SZ2',2,FWxFilial('SZ2') + vPreDes,'Z2_DATAABT')

			_nNumEtq    	:= SZU->ZU_NUMETQ
			M->Z8_DATAP 	:= SZU->ZU_DTPROD   //Assume a data de produ��o especificada na previs�o. Alterado em 04.04.11
			M->Z8_FILORI  	:= FWxfilial('SB1')
			M->Z8_FIL     	:= FWxfilial('SB1')
			M->Z8_CODORI  	:= M->Z8_COD
			//M->Z8_DATAVAL 	:= _dtAbate + diasVal //M->Z8_DATAP + diasVal     //calculo da data de validade
			M->Z8_NUMPREV 	:= vNumPrev                  //grava��o do numero da previs�o de produ��o no registro da caixa  (veio da gjf17v() )
			M->Z8_PREDES  	:= alltrim(vPreDes)
			M->Z8_CLASSIF 	:= alltrim(vClassif)
			M->Z8_DTENTES 	:= ddatabase
			M->Z8_LOTE    	:= SZU->ZU_LOTE
			M->Z8_ORIGEM   := 'P'
			M->Z8_SEQPETQ := cZZPNum
			/*
			_cdExp := getmv('SI_CODEXP')
			if alltrim(M->Z8_COD) $ _cdExp//tratamento do calculo de dias de validade de acordo com o tipo de produto ser exporta��o ou n�o
				M->Z8_DATAVAL := M->Z8_DATAP + diasVal   //calculo da data de validade
			else
				M->Z8_DATAVAL := _dtAbate + diasVal
			endif
			*/

			if _cdExp = 'ME'	
				// valida��o feita para confirmar vinda da data do abate da pr�-etiqueta
				If	!empty(_dtAbate)
					//M->Z8_DATAVAL := _dtAbate + diasVal
					M->Z8_DATAVAL := SZU->ZU_DTABT + diasVal
				else
					M->Z8_DATAVAL := SZU->ZU_DTPROD + diasVal
				endif
			else
				//M->Z8_DATAVAL := SZU->ZU_DTPROD + diasVal	
				// Dia 28/06/23 - conversado com Mathy ( qualidade ) e nos foi informado que a data de validade � formada sobre a data de abate
				M->Z8_DATAVAL := SZU->ZU_DTABT + diasVal							
			endif

			obj:refresh()
			//esta fun��o grava a quantidade produzida na previs�o de produ��o
			if !gjf17pre()              
				//msgbox('N�mero de pe�as a ser produzido deve ser exato a� previsa�o!','PRIORIDADE POR PEÇAS!','STOP')
				M->Z8_COD    := space(6)
				M->Z8_DESCRI := space(1)
				_lLiber := .t.
				return .f.
			endif

			//dbclosearea('SZU')
			dbselectarea('SZ8')

			_cEst := getComputerName()
			dbselectarea('ZAM')
			ZAM->(dbSetOrder(2))
			if ZAM->(MsSeek(FWxFilial('ZAM') + alltrim(_cEst)))
				_cIp := alltrim(ZAM->ZAM_IP)
			else
				_cIp := ""
			endif

			if _nPesFix <> 0
				M->Z8_PESFIX := _nPesFix
				M->Z8_PESO   := _nPesFix
				M->Z8_PESOBR := (_nPesFix + M->Z8_TARA)
			endif

			if SZU->ZU_MPPORC == "S" //se for materia prima

				gravaZAS()

				SZ2->(DbSetOrder(2))
				if  SZ2->(MsSeek(FWxfilial('SZ2')+ZAS->ZAS_PREDES))// se houver o apontamento de OP...
					_dDataAbt := SZ2->Z2_DATAABT
				else
					_dDataAbt := date()
				endif

				u_GJF111k("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_PREDES,ZAS->ZAS_DTPROD,(_dDataAbt+ZAS->ZAS_VALID),1,_cIp,ZAS->ZAS_HORA)
			else
				if alltrim(M->Z8_COD) $ alltrim(getMv('SI_MDSMEX'))
					U_ETQEMBMDS("S600","IP",M->Z8_CONTROL,M->Z8_COD,M->Z8_QUANT,M->Z8_PESOBR,M->Z8_PESO,M->Z8_TARA,M->Z8_PREDES,M->Z8_CLASSIF,;
					M->Z8_TF,M->Z8_DATAP,M->Z8_ETIQ,M->Z8_DATAVAL,1,M->Z8_LOTE,_cIp,M->Z8_SEQPETQ,M->Z8_HORA)
				else
					u_GJF111a("S600","IP",M->Z8_CONTROL,M->Z8_COD,M->Z8_QUANT,M->Z8_PESOBR,M->Z8_PESO,M->Z8_TARA,M->Z8_PREDES,M->Z8_CLASSIF,;
					M->Z8_TF,M->Z8_DATAP,M->Z8_ETIQ,M->Z8_DATAVAL,1,M->Z8_LOTE,_cIp,M->Z8_SEQPETQ,"",M->Z8_HORA,"R")
				endif

				recLock('SZ8',.t.)

				For nCont := 1 To FCount()             //numero de campos na tabela corrente
					If "FILIAL"$Field(nCont)
						FieldPut(nCont,FWxFilial("SZ8"))
					Else
						FieldPut(nCont,M->&(FIELDNAME(nCont)))
					Endif
				Next nCont

				SZ8->Z8_INV := 'P'
				SZ8->Z8_SETPRO := 'E'
				SZ8->Z8_FARM := _cFarm
				MsUnLock()

				u_gjf17his(1,'PRODUCAO',.f.,'','','000012',M->Z8_CONTROL,M->Z8_LOCAL,M->Z8_LOCALIZ,M->Z8_PALLET)      //grava o histórico da caixa

				dbselectarea('SB1')
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

				ZZP->(dbSetOrder(1))
				ZZP->(dbGoTop())
				if ZZP->(MsSeek(FWxFilial('ZZP')+M->ZZP_NUM))
					reclock('ZZP',.f.)
					ZZP->ZZP_CONTRO := SZ8->Z8_CONTROL
					msunlock()
				endif

				SB1->(dbclosearea())
				//limpa os campos na memoria
				M->Z8_ID      := GetSx8num('SZ8','Z8_ID')
				ConfirmSx8()
				M->Z8_DATA    := date()
				M->Z8_HORA    := time()
				M->Z8_BALAN   := getComputerName()
				M->Z8_OPERA   := cUserName
				diasVal       := ' '
				M->Z8_VALID   := ' '
				M->Z8_DATAVAL := stod('')
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
				M->Z8_SEQPETQ := cZZPNum
				TotCaix++
				obj:setfocus()
				oDlg:refresh()
			endif
		else
			msgbox("Codigo do produto ou quantidade n�o digitada!","OPERACAO RECUSADA!","STOP")
			M->Z8_DESCRI := space(1)
			return .f.
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
	M->ZZP_NUM := space(10)
	//oObj:CloseConnection()
return

static function gjf17pre()
	//fun��o para atualizar a quantidade produzida na previs�o de produ��o

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
			overflow := .t.                    //se a previs�o foi cumprida, ent�o o overflow determina o seu encerramento
		endif
		case SZU->ZU_PRIORI = "P"
		if SZU->ZU_QPPESO  <= qRealP + M->Z8_PESO
			overflow := .t.                    //se a previs�o foi cumprida, ent�o o overflow determina o seu encerramento
		endif
		case SZU->ZU_PRIORI = "A"
		if SZU->ZU_QPPESO <= qRealP + M->Z8_PESO .or. SZU->ZU_QPCAIX = qRealC + 1
			overflow := .t.
		endif
		case SZU->ZU_PRIORI = "E"                //se a previs�o for por pe�as
		if (qRealQ + M->Z8_QUANT) > qPrevQ
			msgbox('Se produzir a quantidade declarada nessa caixa,' +;
			' ent�o o n�mero de pe�as produzidas desse produto' +;
			' ir� ultrapassar!','PREVISAO DE PRODUCAO ENCERRADA!','STOP')

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
		msgbox('Previs�o de Produ��o para este produto totalmente atendida!','CONFIRMA��O DE PRODU��O!','INFO')
	endif

	ret := iif(overflow2,.f.,.t.)

return ret

static Function gjf17cap()
	// para capturar o peso
	nHdll := 0

	if !MSOpenPort(nHdll,mv_par06)
		msgbox("N�o foi poss�vel pegar informa��es da porta!",,"STOP")
		lOk := .f.
		Return 0
	endif

	cText := space(15)
	if !MsRead(nHdll,@cText)
		msgbox("N�o foi poss�vel pegar informa��es da porta!",,"STOP")
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

//Verifica se os parametros coincidem com as previs�es de produ��o da desossa
user function gjf17v_2()

	local _lValid := .t.

	
	ZZP->(dbSetOrder(1))
	if ZZP->(MsSeek(FWxFilial('ZZP')+alltrim(M->ZZP_NUM))) .and. len(alltrim(M->ZZP_NUM)) == 10
		if !empty(ZZP->ZZP_CONTRO)
			SZ8->(DbSetOrder(3))
			SZ8->(dbGoTop())
			ZAS->(DbSetOrder(1))
			ZAS->(dbGoTop())
			/*se encontrar na SZ8 reimprime*/
			if SZ8->(MsSeek(FWxFilial('SZ8')+ZZP->ZZP_CONTRO))
				_cUsuarios := getMv('SI_USRMDS')//parametro com os codigos dos usuarios que podem reimprimir etiquetas
				_cCodUser  := retCodUsr()
				if alltrim(_cCodUser) $ _cUsuarios
					if msgbox('Deseja realmente reimprimir a etiqueta?','REIMPRESS�O DE ETIQUETA','YESNO')
						_nNumEtq := GetAdvFVal('SZU','ZU_NUMETQ',FWxFilial('SZU')+alltrim(SZ8->Z8_NUMPREV),2)

						_cEst := getComputerName()
						dbselectarea('ZAM')
						ZAM->(dbSetOrder(2))
						if ZAM->(MsSeek(FWxFilial('ZAM') + alltrim(_cEst)))
							_cIp := alltrim(ZAM->ZAM_IP)
						else
							_cIp := ""
						endif

						if alltrim(SZ8->Z8_COD) $ alltrim(getMv('SI_MDSMEX'))
							U_ETQEMBMDS("S600","IP",SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
							SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIp,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA,"R")
						else
							u_GJF111a("S600","IP",SZ8->Z8_CONTROL,SZ8->Z8_COD,SZ8->Z8_QUANT,SZ8->Z8_PESOBR,SZ8->Z8_PESO,SZ8->Z8_TARA,SZ8->Z8_PREDES,SZ8->Z8_CLASSIF,;
							SZ8->Z8_TF,SZ8->Z8_DATAP,SZ8->Z8_ETIQ,SZ8->Z8_DATAVAL,1,SZ8->Z8_LOTE,_cIp,SZ8->Z8_SEQPETQ,SZ8->Z8_HORA)
						endif

					else
						_lValid := .f.
					endif
				else
					msgbox('Usuario sem permiss�o para reimpress�o de etiquetas!','REIMPRESS�O DE ETIQUETAS','STOP')
					_lValid := .f.
				endif
				
			elseif ZAS->(MsSeek(FWxFilial('ZAS') + ZZP->ZZP_CONTRO)) //SE FOR MP

				_cUsuarios := getMv('SI_USRMDS')//parametro com os codigos dos usuarios que podem reimprimir etiquetas
				_cCodUser  := retCodUsr()
				if alltrim(_cCodUser) $ _cUsuarios
					if msgbox('Deseja realmente reimprimir a etiqueta?','REIMPRESS�O DE ETIQUETA','YESNO')

						_cEst := getComputerName()
						dbselectarea('ZAM')
						ZAM->(dbSetOrder(2))
						if ZAM->(MsSeek(FWxFilial('ZAM') + alltrim(_cEst)))
							_cIp := alltrim(ZAM->ZAM_IP)
						else
							_cIp := ""
						endif
						SZ2->(DbSetOrder(2))
						if  SZ2->(MsSeek(FWxfilial('SZ2')+ZAS->ZAS_PREDES))// se houver o apontamento de OP...
							_dDataAbt := SZ2->Z2_DATAABT
						else
							_dDataAbt := date()
						endif
						//alert('linha 640 - >GJF111K ')  
						u_GJF111k("S600","IP",ZAS->ZAS_CONTRO,ZAS->ZAS_COD,ZAS->ZAS_PESOB,ZAS->ZAS_PESOL,ZAS->ZAS_TARA,ZAS->ZAS_PREDES,ZAS->ZAS_DTPROD,(_dDataAbt+ZAS->ZAS_VALID),1,_cIp,ZAS->ZAS_HORA)
					else
						_lValid := .f.
					endif
				else
					msgbox('Usuario sem permiss�o para reimpress�o de etiquetas!','REIMPRESS�O DE ETIQUETAS','STOP')
					_lValid := .f.
				endif

			endif
			M->ZZP_NUM := space(10)
			return _lValid
		else
			M->Z8_COD 	 := alltrim(ZZP->ZZP_PROD)
			M->Z8_QUANT  := GetAdvFVal('SB1','B1_QCAIX',FWxFilial('SB1')+alltrim(M->Z8_COD),1)
			M->Z8_TARA   := gjf17T_2()
			M->Z8_DESCRI := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+alltrim(M->Z8_COD),1)
			oDlg:refresh()
		endif
	else
		M->ZZP_NUM := space(10)
		_lValid := .f.
		return _lValid
	endif
	segUM := ''

	segUM := GetAdvFVal('SB1','B1_SEGUM',FWxfilial('SB1')+alltrim(M->Z8_COD),1)

	if segUM == 'PC'
		msgbox('Este produto n�o � embalado em caixas!','NAO � POSSIVEL PRODUZIR!','STOP')
		M->Z8_QUANT := 0
		_lValid := .f.
		return _lValid
	endif

	//para verifica��o se existe previsao de pesagem
	_cQuery := "SELECT COUNT(ZU_COD)AS CONTA, ZU_COD AS CODIGO,ZU_NUM AS NUM, ZU_PREDES AS PREDES FROM "+RetSqlName("SZU")+" SZU " +;
	" WHERE SZU.D_E_L_E_T_ <> '*' " +;
	"  AND SZU.ZU_COD     = '" + M->Z8_COD   +;
	"' AND SZU.ZU_DTRPRO  = '" + DTOS(date())+;
	"' AND SZU.ZU_TIPO    = '" + M->Z8_TIPO  +;
	"' AND SZU.ZU_ETIQ    = '" + M->Z8_ETIQ  +;
	"' AND SZU.ZU_TF      = '" + M->Z8_TF    +;
	"' AND SZU.ZU_MDESP   = '" + M->Z8_MDESP +;
	"' AND SZU.ZU_PREDES  <> '' "  +;
	"  AND SZU.ZU_FECHADO = 'N' " +;
	" AND SZU.ZU_FILIAL = '" + FWxfilial("SZU") + "'" +;
	" GROUP BY ZU_COD, ZU_NUM,ZU_PREDES"
	_cQuery := ChangeQuery(_cQuery)

	//* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("VER")<>0
		VER->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "VER"
	if VER->CONTA = 0

		msgbox('Produ��o n�o prevista para esse produto ou j� encerrada!','NAO � POSSIVEL PRODUZIR!','STOP')
		M->Z8_QUANT := 0
		M->Z8_COD   := GetAdvFVal('ZZP','ZZP_PROD',FWxFilial('ZZP')+alltrim(M->ZZP_NUM),1)
		odlg:Refresh()
		VER->(dbclosearea())
		dbselectarea('SZ8')
		_lValid := .f.
		return _lValid
	endif

	DbSelectArea('SB1')

	//para mostrar o label do produto

	_dtAbate := GetAdvFVal('SZ2','Z2_DATAABT',FWxFilial('SZ2') + VER->PREDES,2)

	oDesc  := GetAdvFVal('SB1','B1_DESCRED',FWxfilial('SB1')+VER->CODIGO,1)

	oDataV := _dtAbate + GetAdvFVal('SB1','B1_VALID',FWxfilial('SB1')+VER->CODIGO,1)  //date() + GetAdvFVal('SB1',1,FWxfilial('SB1')+VER->CODIGO,'B1_VALID')

	_NTARAp := GetAdvFVal('SB1','B1_CTARAP',FWxfilial('SB1')+VER->CODIGO,1)      // Linhas inseridas para buscar
	oTarap  := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_NTARAp),1)  // os campos de codigo das taras primarias

	_NTARAs := GetAdvFVal('SB1','B1_CTARASE',FWxfilial('SB1')+VER->CODIGO,1)     //Linhas inseridas para buscar
	oTaraS  := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_NTARAs),1)  // os campos de codigo das taras secundaria

	M->Z8_TARAS := oTaras

	oSayDesc:SetText(oDesc)
	oSayDataV:SetText(oDataV)
	oSayTaraP:SetText(oTaraP)
	oSayTaraS:SetText(oTaraS)

	vNumPrev := VER->NUM
	vPreDes  := VER->PREDES

	if !empty(vPreDes)

		vClassif := GetAdvFVal('SZ2','Z2_CLASSIF',FWxfilial('SZ2')+VER->PREDES,2)
	endif

	odlg:Refresh()
	VER->(dbclosearea())
	dbselectarea('SZ8')

	if _lValid
		gjf17pro(_lValid,M->ZZP_NUM)
	endif

return _lValid

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

static function gjf17con

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

	cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo tempor�rio

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
	
	u_arqtrb ("FechaTodos",,,, @_aArqTrb)


	restarea(area)
return

Static Function CapT
	_nTara := gjf17cap()
	if _nTara > 0
		msgbox('Valor da tara capturada (Kg): '+ transform(_nTara,'@E 999.999'),'Captura Realizada!','INFO')
	else
		msgbox('Problemas com a captura da Tara!','Valor inconsistente!','ERRO')
	endif

	DbSelectArea('SB1')

	_cCodTP := GetAdvFVal('SB1','B1_CTARAP',FWxfilial('SB1')+alltrim(M->Z8_COD),1)  //Linhas inseridas para verificar o codigo
	_nTP := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_cCodTP),1)      //das taras modificado por Fabian Maurer 26/08/11
	//_nTP := GetAdvFVal('ZAB',1,FWxfilial('ZAB')+alltrim(M->Z8_COD),'ZAB_TARA')
	//_nTP := GetAdvFVal('SB1',1,FWxfilial('SB1')+alltrim(M->Z8_COD),'B1_TARAP')   Linha que funcionava antes da mudan�a para codigo de tara
	M->Z8_TARA  := _nTara + (_nTP * M->Z8_QUANT)
	M->Z8_TARAS := _nTara
Return

static Function gjf17T_2()
	DbSelectArea('SB1')

	//Busca Tara Secundaria
	_cCodTS := GetAdvFVal('SB1','B1_CTARASE',FWxfilial('SB1')+alltrim(M->Z8_COD),1) // Linhas inseridas para buscar
	_nTS    := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_cCodTS),1)     // os codigos das taras Secundarias

	//Busca Tara Prim�ria
	_cCodTP := GetAdvFVal('SB1','B1_CTARAP',FWxfilial('SB1')+alltrim(M->Z8_COD),1)  // Linhas inseridas para buscar
	_nTP    := GetAdvFVal('ZAB','ZAB_TARA',FWxfilial('ZAB')+alltrim(_cCodTP),1)     // os codigos das taras Primarias
	if _nTara = 0
		_nTaraT := _nTS + (_nTP * M->Z8_QUANT)
	else
		_nTaraT := _nTara + (_nTP * M->Z8_QUANT)
	endif

	if _nTP = 0 .OR. _nTS = 0
		_nTaraT := 0
	endif

	oDlg:refresh()
return _nTaraT

//fun��o para conectar na balan�a
Static Function conectBal()

	//Define o IP da balan�a a se utilizada
	/* Feito ajuste por Flavio dia 09/04/21 para fazer a esta��o DTI02 produzir Etiqueta UE
	_cEst   := getComputerName()
	_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + iif(_cEst = 'MDS01','BMDS1',;
	iif(_cEst = 'MDS02','BMDS2',;
	iif(_cEst = 'MDS03','BMDS3',;
	iif(_cEst = 'CHR01','BCHR1',;
	iIf(_cEst = 'CAM04','BCAM1','XXXXX'))))),'ZAM_IP'))

	If _cEst = 'MDS01'
		_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + _cEst ,'ZAM_IP'))
	elseif _cEst = 'BMDS1'
		_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + _cEst ,'ZAM_IP'))
	elseif _cEst = 'MDS02'
		_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + _cEst ,'ZAM_IP'))
	elseif _cEst = 'BMDS2'
		_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + _cEst ,'ZAM_IP'))
	elseif _cEst = 'MDS03'
		_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + _cEst ,'ZAM_IP'))
	elseif _cEst = 'BMDS3'
		_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + _cEst ,'ZAM_IP'))
	elseif _cEst = 'CHR01'
		_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + _cEst ,'ZAM_IP'))
	elseif _cEst = 'BCHR1'
		_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + _cEst ,'ZAM_IP'))
	elseif _cEst = 'CAM04'
		_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + _cEst ,'ZAM_IP'))
	elseif _cEst = 'BCAM1'
		_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + _cEst ,'ZAM_IP'))
	elseif _cEst = 'DDTI02'
		_cIpBal := alltrim(GetAdvFVal('ZAM',1,FWxFilial('ZAM') + _cEst ,'ZAM_IP'))
	else
		// Se n�o for nenhuma das esta��es n�o faz nada 
	Endif
	*/

	_cEst   := getComputerName()
	_cIpBal := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + iif(_cEst = 'MDS01','BMDS1',;
	iif(_cEst = 'MDS02','BMDS2',;
	iif(_cEst = 'MDS03','BMDS3',;
	iif(_cEst = 'CHR01','BCHR1',;
	iIf(_cEst = 'CAM04','BCAM1','XXXXX'))))),1))
	if empty(_cIpBal)
		alert('Endereco IP da balanca nao encontrado!')
		return
	endif

	//Se a balan�a j� estiver conectada, disconecta...
	if _lBal
		oObj:CloseConnection()
	endif

	oObj  := tSocketClient():New()
	/* dia 03/03/22 everton configurou a balan�a para porta 9091 
	Ficou produzindo normal no MDS01 e MDS2*/
	
	//nResp := oObj:Connect( 9091, _cIpBal,1000) // String vem todo errada 
	/* Data de identifica��o da situa��o 20/05/22
	 Esta balan�a do Mi�dos MDS02  esta com configura��o invertida.
	Precisa ser configurada a porta 9091 (no equipamento fisicamente) para que no sistema esteja configurada a porta 9092 e se consiga efetuar a captura da string com peso */
	nResp := oObj:Connect( 9092, _cIpBal,1000)  //9092 precisa ser a captura nessa porta
	nResp := oObj:Send( 'Teste' )

	_lBal := .t.

return

//fun��o separada para capturar peso com a balan�a nova
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
	local i
	local j
	M->Z8_PESOBR 	:= 0

	conectBal()

	//bloco que armazena as strings que tiverem o peso est�vel
	for i:=1 to _nTam//bloco para multiplas capturas
		_cBuffer  := ''
		nQtd 	  = oObj:Receive( _cBuffer, _nMS )
		if ("ph" $ alltrim(_cBuffer)) .or. ("p`" $ alltrim(_cBuffer)) //SE TIVER "PH ou P`" NA STRING QUER DIZER QUE � UM PESO ESTAVEL
			//alert(_cBuffer)
			aAdd(aStrings,_cBuffer)
		endif
	next
	
	//verifica se o buffer n�o esta sendo retornado em branco, caso esteja reconecta na balan�a
	//if empty(_cBuffer)
	//	conectBal()
	//endif

	//bloco para tratamento das strings com peso est�vel
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

static function gravaZAS()

	_cLote := ''
	ZAR->(DbSetOrder(1))
	if ZAR->(MsSeek(FWxfilial('ZAR')+SZU->ZU_PREPORC)) .and. !empty(SZU->ZU_PREPORC)
		_cLote    := ZAR->ZAR_LOTE
		_cPreporc := SZU->ZU_PREPORC
	else

		//Verifica se houve aglutina��o de OPs para a deossa/embalagem
		ZAR->(DbSetOrder(6))
		if  ZAR->(MsSeek(FWxfilial('ZAR')+SZU->ZU_NUM))
			_cLote    := ZAR->ZAR_LOTE
			_cPreporc := ZAR->ZAR_NUM

		elseif !empty(SZU->ZU_LOTEPOR)
			_cPreporc := 'MANUAL'
			_cLote  := SZU->ZU_LOTEPOR
		else
			_cPreporc := 'MANUAL'
		endif
	endif

	reclock('ZAS',.t.)
	ZAS->ZAS_FILIAL  := FWxfilial('ZAS')
	ZAS->ZAS_CONTRO  := M->Z8_CONTROL
	ZAS->ZAS_COD     := M->Z8_COD
	ZAS->ZAS_DESC    := M->Z8_DESCRI
	ZAS->ZAS_DTPROD  := SZU->ZU_DTPROD
	ZAS->ZAS_VALID   := diasVal
	ZAS->ZAS_PESOL   := M->Z8_PESO
	ZAS->ZAS_PESOB   := M->Z8_PESOBR
	ZAS->ZAS_TARA    := M->Z8_TARA
	ZAS->ZAS_PREPOR  := _cPreporc
	ZAS->ZAS_PREEMB  := M->Z8_NUMPREV
	ZAS->ZAS_PREDES  := M->Z8_PREDES
	ZAS->ZAS_TIPO    := 'MP'
	ZAS->ZAS_SEQPET  := M->ZZP_NUM
	ZAS->ZAS_TERC	 := 'N'
	ZAS->ZAS_LOTE    := _cLote
	ZAS->ZAS_TF      := SZU->ZU_TF
	ZAS->ZAS_HORA	 := time()
	ZAS->ZAS_LIN	 := 'MDS'
	msunlock()

	ZZP->(dbSetOrder(1))
	ZZP->(dbGoTop())
	if ZZP->(MsSeek(FWxFilial('ZZP')+M->ZZP_NUM))
		reclock('ZZP',.f.)
		ZZP->ZZP_CONTRO := ZAS->ZAS_CONTRO
		msunlock()
	endif

	//limpa os campos na memoria
	M->Z8_ID      := GetSx8num('SZ8','Z8_ID')
	ConfirmSx8()
	M->Z8_DATA    := date()
	M->Z8_HORA    := time()
	M->Z8_BALAN   := getComputerName()
	M->Z8_OPERA   := cUserName
	diasVal       := ' '
	M->Z8_VALID   := ' '
	M->Z8_DATAVAL := stod('')
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

return


