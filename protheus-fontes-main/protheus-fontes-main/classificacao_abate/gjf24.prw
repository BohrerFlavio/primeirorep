#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "totvs.ch"
#INCLUDE "colors.ch"
#INCLUDE "MATA380.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF24     ºAutor  ³Giuliano Forgiarini º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Previsão e gerenciamento de Produção  - Embalagem          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigapcp - Frigorifico Silva                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF24()

	Local cCondicao 	:= ""						// Condição para a filtragem
	lOk := .f.
	aObjects := {}                                  //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()
	AAdd( aObjects, {100, 100, .T., .T. } )
	AAdd( aObjects, {100, 50, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	bLegenda1 :=  "SZU->ZU_FECHADO = 'N' .and. empty(SZU->ZU_QRPESO) .and. empty(SZU->ZU_QRCAIX) .and. SZU->ZU_FILIAL = '" + FWxfilial('SZU')+"'"
	bLegenda2 :=  "SZU->ZU_FECHADO = 'S' .and. SZU->ZU_FILIAL = '" + FWxfilial('SZU')+"'"
	bLegenda3 :=  "SZU->ZU_FECHADO = 'N' .and. (!empty(SZU->ZU_QRPESO) .or. !empty(SZU->ZU_QRCAIX)) .and. SZU->ZU_FILIAL = '" + FWxfilial('SZU')+"'"
	bLegenda4 :=  "SZU->ZU_FECHADO = 'B' .and. SZU->ZU_FILIAL = '" + FWxfilial('SZU') + "'"
	bLegenda5 :=  "SZU->ZU_FECHADO = 'B' .and. SZU->ZU_FILIAL = '" + FWxfilial('SZU') + "'  .and. empty(SZU->ZU_PREDES)"
	bLegenda6 :=  "SZU->ZU_FECHADO = 'B' .and. SZU->ZU_FILIAL = '" + FWxfilial('SZU') + "'  .and. !empty(SZU->ZU_PREDES)"

	aCores2:= { { 'BR_VERDE'	,'Aberta' },;
				{ 'BR_VERMELHO'	,'Encerrada'},;
				{ 'BR_AMARELO' 	,'Iniciada'},;
				{ 'BR_AZUL'    	,'Bloqueada'},;
				{ 'BR_BRANCO'   ,'Porc.s/Vinc.Desossa'},;
				{ 'BR_CINZA'   	,'`Porc.c/Vinc.Desossa'}}

	aCores := { {bLegenda1, 'BR_VERDE'},;
				{bLegenda2, 'BR_VERMELHO'},;
				{bLegenda3, 'BR_AMARELO'},;
				{bLegenda4, 'BR_AZUL'},;
				{bLegenda5, 'BR_BRANCO'},;
				{bLegenda6, 'BR_CINZA'}}

	Private cPerg     := "GJF24"
	Private cCadastro := "Previsão de Gerenciamento de Producao - Embalagem"
	Private aRotina    := { {"Pesquisar"   ,"AxPesqui"    ,0,1} ,;
							{"&Visualizar" ,"AxVisual"    ,0,2} ,;
							{"&Incluir"    ,"u_gjf24inc"  ,0,3} ,;
							{"&Alterar"    ,"u_gjf24alt"  ,0,4} ,;
							{"&Excluir"    ,"u_gjf24del"  ,0,5} ,;
							{"LiberarM"    ,"u_gjf24lb"   ,0,4} ,;
							{"Bloquear"    ,"u_gjf24blo"  ,0,4} ,;
							{"Liberar"     ,"u_gjf24lb2"  ,0,4} ,;
							{"ABT"     	   ,"u_tnvf"  	  ,0,4} ,;
							{"C.Exato"     ,"u_gjf24ext"  ,0,4} ,;
							{"Lib.Abate"   ,"u_gjf24lba"  ,0,4} ,;
							{"Legenda"     ,"u_gjf24leg"  ,0,2}}

	Private _nTras := 0
	Private _nDia  := 0
	Private _nCos  := 0
	Private _dDtProd  := DDATABASE
	Private _dDtRPro  := DDATABASE
	Private _dDtAbt   := (DDATABASE-1)
	Private _cNPreDes := space(10)
	Private _cCodPro  := space(6)
	Private _cUs :=  GetMV('SI_USRPOR')

	//Parametro que determina os grupos que são PA para carne moída
	Private _cGrpMoi := GetMV('SI_GRPMOI')

	Private cString := "SZU"
	//{"Vis.Cert"   ,"u_Vcert2",0,4} ,;
	/* Sobre o Botão ""LiberarM"" Descobrir proque ele foi feito sebão retirar ele*/

	dbSelectArea(cString)
	SZU->(dbsetorder(2))

	SetKey(123,{|| AlterData()})

	if !pergunte(cPerg,.t.)
		return
	endif

	AlterData()

	cCondicao := "ZU_DTRPRO >=  '" + dtos(mv_par01) + "' AND ZU_DTRPRO <=  '" + dtos(mv_par02) + "'" +;
		" AND ZU_FILIAL = '" + FWxfilial('SZU') + "'" //String para filtro
	//Aplicação da filtragem
	if !empty(mv_par03)
		cCondicao += " AND ZU_COD = '" + mv_par03 + "'"
	endif

	cCondicao += iif(mv_par04 = 1," AND ZU_MPPORC = 'S'",iif(mv_par04 = 2, " AND ZU_MPPORC <> 'S'",""))
	cCondicao += iif(!empty(mv_par05)," AND ZU_PREPORC = '" + mv_par05 + "'","")
	cCondicao += iif(mv_par06 = 1," AND ZU_PREDES <> '' ",iif(mv_par06 = 2," AND ZU_PREEMB = '' ",""))
	cCondicao += " AND ZU_AGLUT = ''  "
	cCondicao += " AND ZU_USUAR NOT IN("+_cUs+")"

	/* Ajuste para funcionar o F8   */
	//Set Key VK_F8  TO u_teste1()      // Consulta Data do Abate

	mBrowse(6,1,22,75,cString, ,,,,2,aCores,,,,{|x| AutoRefresh(x)},,,,cCondicao)

	SZU->(DbCloseArea())

	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())

	//	u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	//Endif

	//Set Key VK_F8  TO u_teste1()      // Consulta Data do Abate
	Set Key 123 to

return


//INCLUSAO DA PREVISAO DE PRODUCAO
user function gjf24inc(cAlias,nReg,nOpc)
	Local nCont
	Local _lGrv 	 := .F.
	Local aButtons	 := {{"FORM",{|| u_gjf24ism()},'Inclui Shipping Mark','Ship. Mark'}}
	Private aHeader	 := {}
	Private aCols	 := {}
	Private nUsado	 :=	0
	Private _cProd   := ''
	Private _cNumPre := ''

	AADD(aButtons, {"FORM",{|| u_gjf24ssm()},'Status Shipping Mark','Status S.M.'})

	DEFINE MSDIALOG oDlg TITLE 'Previsão de Gerenciamento de Producao' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("SZU",.T.)
	RegToMemory("ZAN",.T.)

	if dDataBase <> Date()
		M->ZU_FECHADO := 'B'
	endif
	M->ZU_DATA   := dDataBase
	M->ZU_DTPROD := _dDtProd
	M->ZU_DTRPRO := _dDtRPro
	M->ZU_PREDES := _cNPreDes
	if !empty(_cNPreDes)
		M->ZU_DTABT  := GetAdvFVal('SZ2','Z2_DATAABT',FWxfilial('SZ2')+alltrim(_cNPreDes),2)
	else
		M->ZU_DTABT  := dDataBase
	endif

	//obj := MsMGet():New("SZU" ,SZU->(RECNO()),3   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )
	obj := MsMGet():New("SZU",SZU->(RECNO()),3,,,,,aPosObj[1],,,,,,oDlg,,,.F.)

	@ aPosObj[2,1],020   BUTTON 'Mov. Internas'    SIZE 47,20 ACTION u_gjf24mov(cAlias,nReg,nOpc)   OBJECT oBtn1

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf24ok()},{||gjf24nok()},,aButtons)
	If lOk
		//Verificação se é produção de produto MP para porcionados...
		if VerPorc(nOpc)
			// Se o TMP não foi gerado manualmente cria ele...
			if Select('TMP')= 0
				GeraTMP()
				//senão, se o TMP foi criado para outro produto	...
			elseif Select('TMP')<>0 .and. _cProd <> M->ZU_COD
				//TMP->(DbCloseArea())
				GeraTMP()
			endif

			ConfirmSX8()

			_cDtLote := substr(dtos(M->ZU_DTRPRO),7,2) + substr(dtos(M->ZU_DTRPRO),5,2) + substr(dtos(M->ZU_DTRPRO),3,2)
			//SZU->ZU_LOTEUA :=  'D' +_cDtLote + 'P' + M->ZU_COD + M->ZU_NUM  //D+DDMMAA+P+CodProd+Seq D 120223 P 022500 0001982455 TAMANHO 24 
			_cCadasM := GetAdvFVal('SB1','B1_CADMERC',FWXFilial('SB1')+AllTrim(M->ZU_COD),1)
			
			cQuery := "SELECT TOP 1 ZU_NUM AS NUM, ZU_DATA AS DATA, ZU_DTRPRO AS DTRPRO , ZU_COD AS COD, ZU_LOTEUA AS LOTEUA "
			cQuery += "FROM " + RetSqlTab("SZU")
			cQuery += "WHERE " + RetSQLDel('SZU') + " AND " + RetSqlFil("SZU") + " AND ZU_COD = '" + M->ZU_COD + "' "
			cQuery += "ORDER BY ZU_NUM DESC

			cQuery := ChangeQuery(cQuery)

			if Select("TMPP") != 0
				TMPP->(dbCloseArea())
			endif

			TCQUERY cQuery NEW ALIAS "TMPP"

			_cSeqAtu := SUBSTR(TMPP->LOTEUA,15,2)
			_nSeqAtu := VAL(_cSeqAtu)

			SZU->(DbSetOrder(3))
			SZU->(DbGotop())
			SZU->(MsSeek(FWxfilial('SZU')+alltrim(M->ZU_COD)+alltrim(M->ZU_NUM)))
			//MSGINFO('D' +_cDtLote + 'P' + M->ZU_COD + _cSeqAtu,"")
			if ('D' +_cDtLote + 'P' + M->ZU_COD + _cSeqAtu $ SZU->ZU_LOTEUA)
				MSGINFO("Lote EUA já existente","")
			else				
				_dtabas := DToS(ddatabase)				
				if (TMPP->DATA <> _dtabas)
					if (_nSeqAtu >= 1 .AND. TMPP->DTRPRO <> _dtabas)
						_nSeqAtu := 0
						_LotEUA := 'D' +_cDtLote + 'P' + M->ZU_COD + "0" + ALLTRIM(STR(_nSeqAtu + 1))
					else						
						_LotEUA := 'D' +_cDtLote + 'P' + M->ZU_COD + "0" + ALLTRIM(STR(_nSeqAtu + 1))
					endif
				else
					_LotEUA := 'D' +_cDtLote + 'P' + M->ZU_COD + "0" + ALLTRIM(STR(_nSeqAtu + 1))
				endif
			endif

			if !empty(M->ZU_SHIPPIN)
				_lGrv := .T.
			endif

			recLock('SZU',.T.)
			// Grava previsao de producao						
			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,FWxFilial("SZU"))
				Else
					FieldPut(nCont,M->&(FIELDNAME(nCont)))
				Endif							
			Next nCont		
			SZU->ZU_LOTEUA := _LotEUA
			MsUnLock()

			// Grava OP na no registro de Shipping Mark
			if _lGrv
				ZY2->(DbSetOrder(1))
				if ZY2->(MsSeek(FWxFilial('ZY2')+M->ZU_SHIPPIN))
					_cNumPre := alltrim(ZY2->ZY2_NUMPRE)
					reclock('ZY2',.f.)
					if empty(_cNumPre)
						ZY2->ZY2_NUMPRE := M->ZU_NUM
					else
						ZY2->ZY2_NUMPRE := _cNumPre+"|"+M->ZU_NUM
					endif
					msunlock()
				else
					FWAlertError("Shipping Mark não encontrado!", "ERRO")
				Endif
			endif

			//Grava TMP
			If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
				TMP->(DbGotop())
				while TMP->(!eof())
					reclock('ZAN',.t.)
					ZAN->ZAN_FILIAL := FWxfilial('ZAN')
					ZAN->ZAN_PREEMB := M->ZU_NUM
					ZAN->ZAN_COD    := TMP->EMBAL
					ZAN->ZAN_DESC   := TMP->DESCR
					msunlock()
					TMP->(DbSkip())
				enddo

				//TMP->(dbCloseArea())
			Endif
		endif
	else
		RollBackSx8()
	endif

return

//ALTERAÇÃO DA PREVISAO DE PRODUCAO
User function gjf24alt(cAlias,nReg,nOpc)
	Local nCont
	Local aButtons	:= {{"PRODUTO",{|| u_gjf24emp()},'Empenhos','Empenhos'}}
	Private aHeader	:= {}
	Private aCols	:= {}
	Private _cProd := ''
	Private nUsado	:=	0

	if SZU->ZU_FECHADO = 'S'
		alert('Previsão de Produção já encerrada!')
		return
	endif

	AADD(aButtons, {"FORM",{|| u_gjf24ism()},'Inclui Shipping Mark','Ship. Mark'})
	AADD(aButtons, {"FORM",{|| u_gjf24ssm()},'Status Shipping Mark','Status S.M.'})

	DEFINE MSDIALOG oDlg TITLE 'Previsão de Gerenciamento de Producao' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	RegToMemory("SZU",.F.)
	RegToMemory("ZAN",.F.)

	_cProd := M->ZU_COD

	//Gera o arquivo TMP com o que existe já...
	GeraTMP()

	M->ZU_USALT  := cUserName
	M->ZU_HORALT := Time()

	obj := MsMGet():New("SZU" ,SZU->(RECNO()),4   ,     ,     ,     ,          ,aPosObj[1],              ,,,,,oDlg,,,.F. )

	@ aPosObj[2,1],020     BUTTON 'Mov. Internas'            SIZE 47,20 ACTION  u_gjf24mov(cAlias,nReg,nOpc)       OBJECT oBtn1

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||gjf24oka()},{||gjf24nok()},,aButtons)

	If lOk
		//Verifica se é produção de MP para porcionados...
		if VerPorc(nOpc)

			if Select('TMP')<>0 .and. _cProd <> M->ZU_COD
				//TMP->(DbCloseArea())
				GeraTMP()
			endif

			recLock('SZU',.F.)
			// Grava previsao de producao
			For nCont := 1 To FCount()
				If "FILIAL"$Field(nCont)
					FieldPut(nCont,FWxFilial("SZU"))
				Else
					FieldPut(nCont,M->&(FIELDNAME(nCont)))
				Endif
			Next nCont
			SZU->ZU_LOTEUA := M->ZU_LOTEUA
			MsUnLock()

			//Grava TMP
			ZAN->(DbSetOrder(1))
			if ZAN->(MsSeek(FWxfilial('ZAN') + SZU->ZU_NUM))
				while ZAN->(!eof()) .and. ZAN->ZAN_FILIAL = FWxfilial('ZAN') .and. ZAN->ZAN_PREEMB = SZU->ZU_NUM

					reclock('ZAN',.f.)
					DbDelete()
					msunlock()

					ZAN->(DbSkip())
				enddo
			endif

			If Select('TMP')<>0
				//Se um tmp com alias TMP existir, fecha-o
				TMP->(DbGotop())
				while TMP->(!eof())
					reclock('ZAN',.t.)
					ZAN->ZAN_FILIAL := FWxfilial('ZAN')
					ZAN->ZAN_PREEMB := SZU->ZU_NUM
					ZAN->ZAN_COD    := TMP->EMBAL
					ZAN->ZAN_DESC   := TMP->DESCR
					msunlock()
					TMP->(DbSkip())
				enddo

				//TMP->(dbCloseArea())
			Endif

		endif
	endif

	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif

return

// Função para incluir um novo sequencial de Shipping Mark
User Function gjf24ism()

	Local _cSeq := "1733" + substr(dtos(ddatabase),1,4) + "S" + strzero(getmv('SI_NSHMARK'),3)

	if FWAlertYesNo("Realmente deseja incluir um novo Shipping Mark?"+chr(13)+chr(10)+"Shipping Mark = "+_cSeq+chr(13)+chr(10)+"Quantidade máxima = 700", "CONFIRMA")
		DbSelectArea("ZY2")
		reclock('ZY2',.t.)
		ZY2->ZY2_FILIAL := FWxFilial("ZY2")
		ZY2->ZY2_SEQSM  := _cSeq
		ZY2->ZY2_NUMPRE := ""
		ZY2->ZY2_QTMCXS := 700
		ZY2->ZY2_QTRCXS := 0
		ZY2->ZY2_DATA   := ddatabase
		ZY2->ZY2_USRCRI := cUserName
		ZY2->ZY2_USRALT := ""
		ZY2->ZY2_STATUS := "A"
		msunlock()

		putmv('SI_NSHMARK', getmv('SI_NSHMARK') + 1)
	else
		FWAlertInfo("Operação cancelada!", "INFO")
	endif

Return

User Function gjf24ssm()

	Local cPerg := "GJF24SSM"
	Local _cStatus := ""

	if !pergunte(cPerg,.t.)
		return
	endif

	while empty(mv_par01)
		FWAlertWarning('Por favor, selecione um Shipping Mark para continuar!','ALERTA!')
		if !pergunte(cPerg,.t.)
			return
		endif
	end

	do case
		case mv_par02 = 1
		_cStatus := "E"
		case mv_par02 = 2
		_cStatus := "A"
	endcase

	ZY2->(DbSetOrder(1))
	if ZY2->(MsSeek(FWxFilial('ZY2')+mv_par01))
		reclock('ZY2',.f.)
		ZY2->ZY2_STATUS := _cStatus
		if _cStatus = "E"
			ZY2->ZY2_USRALT := cUserName
		endif
		msunlock()
		FWAlertSuccess('Status do Shipping Mark alterado com sucesso!','ALERTA!')
	else
		FWAlertWarning('Shipping Mark não encontrado!','ALERTA!')
	endif

Return

static function gjf24ok() //Verifica se existe campos em branco
	//Local _lOk := .f.
	local _lValPrev := .t.

	_lValPrev := mrrPrevDso(M->ZU_COD)

	if !(_lValPrev)
		Help(" ",1,"EXPORT. EUA",,"É necessário o preenchimento da previsão de desossa para produtos de exportação para os EUA.",4,1)
		lOk := _lValPrev
		return lOk
	endif

	if M->ZU_PRIORI <> 'E'
		if !empty(M->ZU_DTPROD) .and. !empty(M->ZU_TIPO) .and. !empty(M->ZU_DTRPRO) .and. ;
				!empty(M->ZU_ETIQ) .and. !empty(M->ZU_COD) .and. (M->ZU_QPCAIX !=0 .or. M->ZU_QPPESO != 0)

			_cDest    := GetAdvFVal('SB1','B1_DESTINO',FWxfilial('SB1')+M->ZU_COD,1)
			_cCori    := GetAdvFVal('SB1','B1_CORORI',FWxfilial('SB1')+M->ZU_COD,1)
			_cClas    := GetAdvFVal('SZ2','Z2_CLASSIF',FWxfilial('SZ2')+M->ZU_PREDES,2)
			_cCodGrp  := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+M->ZU_COD,1)
			_cFarm    := GetAdvFVal('SBM','BM_FARM',FWxFilial('SBM')+_cCodGrp,1)

			if _cFarm <> 'S'
				if  _cCori <> 'M'
					/* Dia 01/11/22 - Mediante ajuste de data de validade solicitado pelo Dir.Gabriel  foi preciso retirar essa regra
					de obrigatoriedade de vinculação da previsão de Produção da embalagem com a Previsão de produção da desossa*/
					/*
					if empty(M->ZU_PREDES)
						msgbox('Necessária a vinculação com Produção de Desossa!','PRODUTO PARA MERCADO EXTERNO!','STOP')
						Return lOk
					elseif _cDest == 'ME' .and. AllTrim(_cClas) == 'NE' 
						msgbox('Classificação de Desossa impossibilita o lançamento desta OP!','PRODUTO PARA MERCADO EXTERNO!','STOP')
						Return lOk					
					endif  
					*/               
				endif
			endif

			Odlg:end()
			lOk := .t.

		endif
		//Se a prioridade for peças
		//Alterado por Giuliano em 14/01/16
	else
		if !empty(M->ZU_DTPROD) .and. ;
				!empty(M->ZU_TIPO)   .and. ;
				!empty(M->ZU_DTRPRO) .and. ;
				!empty(M->ZU_ETIQ)   .and. ;
				!empty(M->ZU_COD)    .and. ;
				M->ZU_QPCAIX = 0     .and. ;
				M->ZU_QPPESO = 0     .and. ;
				M->ZU_QPQUANT = 0

			_cDest    := GetAdvFVal('SB1','B1_DESTINO',FWxfilial('SB1')+M->ZU_COD,1)
			_cCori    := GetAdvFVal('SB1','B1_CORORI',FWxfilial('SB1')+M->ZU_COD,1)
			_cClas    := GetAdvFVal('SZ2','Z2_CLASSIF',FWxfilial('SZ2')+M->ZU_PREDES,2)
			_cCodGrp  := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+M->ZU_COD,1)
			_cFarm    := GetAdvFVal('SBM','BM_FARM',FWxFilial('SBM')+_cCodGrp,1)

			//if _cFarm <> 'S'
				//if  _cCori <> 'M'
					/* Dia 01/11/22 - Mediante ajuste de data de validade solicitado pelo Dir.Gabriel  foi preciso retirar essa regra
					de obrigatoriedade de vinculação da previsão de Produção da embalagem com a Previsão de produção da desossa*/
					/*
					if empty(M->ZU_PREDES)  
						Help(" ",1,"PREDES",,"Necessária a vinculação com Produção de Desossa!",4,1)
						Return lOk 

					elseif _cDest == 'ME' .and. AllTrim(_cClas) == 'NE'   
						Help(" ",1,"CLASSIF",,"Classificação de Desossa impossibilita o lançamento desta OP!",4,1)
						Return lOk	 

					endif  
					*/
				//endif
			//endif

			if M->ZU_TOLERA <> 0
				Help(" ",1,"TOLERANCIA",,"Campo de tolerância deve estar igual a 0",4,1)
				Return lOk
			endif

			if M->ZU_CONTEXA <> 'S'
				Help(" ",1,"CONTREXATO",,"Campo de controle exato de peças deverá estar habilitado",4,1)
				Return lOk
			endif

			Odlg:end()
			lOk := .t.

		endif

	endif

Return lOk

static function gjf24oka()

	Local lOk := .t.

	//_cDest    := GetAdvFVal('SB1','B1_DESTINO',FWxfilial('SB1')+M->ZU_COD,1)
	//_cCori    := GetAdvFVal('SB1','B1_CORORI',FWxfilial('SB1')+M->ZU_COD,1)
	//_cClas    := GetAdvFVal('SZ2','Z2_CLASSIF',FWxfilial('SZ2')+M->ZU_PREDES,2)
	//_cCodGrp  := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+M->ZU_COD,1)
	//_cFarm    := GetAdvFVal('SBM','BM_FARM',FWxFilial('SBM')+_cCodGrp,1)

	//if _cFarm <> 'S'
		//if  _cCori <> 'M'
			/* Dia 01/11/22 - Mediante ajuste de data de validade solicitado pelo Dir.Gabriel  foi preciso retirar essa regra
			de obrigatoriedade de vinculação da previsão de Produção da embalagem com a Previsão de produção da desossa*/
			/*
			if empty(M->ZU_PREDES)
				msgbox('Necessária a vinculação com Produção de Desossa!','PRODUTO PARA MERCADO EXTERNO!','STOP')
				Return lOk
			elseif _cDest == 'ME' .and. AllTrim(_cClas) == 'NE' 
				msgbox('Classificação de Desossa impossibilita o lançamento desta OP!','PRODUTO PARA MERCADO EXTERNO!','STOP')
				Return lOk						
			endif   
			*/
		//endif
	//endif

	//_lOk := .t.

	Odlg:end()

Return lOk

static function gjf24nok()
	lOk := .f.
	Odlg:end()
Return

//função para calcular o peso medio por caixa e o peso medio a produzir
user function gjf24pmc()
	caixas := M->ZU_QPCAIX
	peso   := M->ZU_QPPESO
	if !empty(caixas) .and. !empty(M->ZU_COD)
		pmc    := GetAdvFVal('SB1','B1_PMCAIX',FWxfilial('SB1')+M->ZU_COD,1)
		pmedio := (caixas * pmc)
		return pmedio
	endif
return peso

//função inversa a de cima
User Function gjf24cmp()
	caixas := M->ZU_QPCAIX
	peso   := M->ZU_QPPESO
	if !empty(peso) .and. !empty(M->ZU_COD)
		cmp   := GetAdvFVal('SB1','B1_PMCAIX',FWxfilial('SB1')+M->ZU_COD,1)
		ncaix := round(peso/cmp,0)
		if mod(peso,cmp) != 0
			ncaix := ncaix + 1
		endif
		return ncaix
	endif
return caixas

//Função que calcula o peso medio e o número de caixas conforme 
//a quantidade de peças apontada
User Function gjf24qmc()
	DbSelectArea('SB1')
	_nQuant   := M->ZU_QPQUANT
	_nQMQuant := GetAdvFVal('SB1','B1_QCAIX',FWxfilial('SB1')+M->ZU_COD,1)
	_nQMPeso  := GetAdvFVal('SB1','B1_PMCAIX',FWxfilial('SB1')+M->ZU_COD,1)
	_nCaix    := _nQuant/_nQMQuant

	if _nCaix > 1
		_nCaix := round(_nCaix,0)
	else
		_nCaix := 1
	endif

	_nPeso := _nCaix * _nQMPeso

	M->ZU_QPCAIX := _nCaix
	M->ZU_QPPESO := _nPeso

Return .t.

user function gjf24enc()

	if SZU->ZU_QRPESO = 0 .or. SZU->ZU_QRCAIX = 0
		alert('Previsão de Produção não iniciada!')
		return
	endif

	if SZU->ZU_FECHADO == 'S'
		alert('Previsão de Produção já encerrada!')
	else

		//Encerrando a previsão de produção...
		reclock('SZU',.f.)
		SZU->ZU_FECHADO := 'S'
		msunlock()
	endif

return

//Função para exclusão de uma previsão de produção
user function gjf24del(cAlias,nReg,nOpc)

	RegToMemory("SZU",.F.)

	//Verfifica, primeiramente, se é produção de MP para porcionados
	if VerPorc(nOpc)

		if M->ZU_FECHADO =='S'
			alert('Previsão de Produção já encerrada!')
		elseif !empty(M->ZU_QRPESO) .or. !empty(M->ZU_QRCAIX)
			alert('Já possui produção!')
		else
			ZAN->(DbSetOrder(1))
			if ZAN->(MsSeek(FWxfilial('ZAN')+M->ZU_NUM ))
				while ZAN->(!eof())  .and. ZAN->ZAN_FILIAL = FWxfilial('ZAN') .and. ZAN->ZAN_PREEMB = M->ZU_NUM
					reclock('ZAN',.f.)
					DbDelete()
					msunlock()
					ZAN->(DbSkip())
				enddo
			endif

			//Se for uma OP para MP de porcionados
			//deve limpar campos da OP de porcionados
			//ao qual esta está vinculada
			if !empty(M->ZU_PREPORC)
				ZAR->(DbSetOrder(1))
				if ZAR->(MsSeek(FWxfilial('ZAR')+M->ZU_PREPORC))
					reclock('ZAR',.f.)
					ZAR->ZAR_CODPI  := ''
					ZAR->ZAR_QTDPI  := 0
					ZAR->ZAR_CODMP  := ''
					ZAR->ZAR_CODMP2 := ''
					ZAR->ZAR_QTDMP  := 0
					ZAR->ZAR_DTABAT := ctod('')
					ZAR->ZAR_PREEMB := ''
					msunlock()
				endif
			endif

			reclock('SZU',.f.)
			dbdelete()
			msunlock()

		endif
	endif
return

user Function gjf24leg()
	BrwLegenda('Previsão de Produção',"Legenda",aCores2)
return

Static Function gjf24T()
	DEFINE MSDIALOG oDlg2 TITLE '' from 000,000 To 90,250 OF oMainWnd PIXEL
	@ 010,003 SAY  'N. Dianteiros:' Object oSay1
	@ 020,003 SAY  'N. Traseiros:'  Object oSay2
	@ 030,003 SAY  'N. Costelas:'   Object oSay3
	@ 010,035 GET _nTras PICTURE "@E 999,999"  valid  Object oGet1
	@ 020,035 GET _nDia  PICTURE "@E 999,999"  valid  Object oGet2
	@ 030,035 GET _nCos  PICTURE "@E 999,999"  valid  Object oGet3
	@ 010,090 BMPBUTTON TYPE 1 ACTION odlg2:end() Object Obtn1
	@ 025,090 BMPBUTTON TYPE 2 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2

return

user function gjf24lb()

/* Sugestão -  Precisa ser feito um ajuste para efetuar a liberação direta quando a Prev. tiver com Status B  */
	if SZU->ZU_FECHADO != 'S'
		if SZU->ZU_MPPORC = 'S'
			if empty(SZU->ZU_PREDES)
				/* Dia 01/11/22 - Mediante ajuste de data de validade solicitado pelo Dir.Gabriel  foi preciso retirar essa regra
				de obrigatoriedade de vinculação da previsão de Produção da embalagem com a Previsão de produção da desossa*/
				//Help(" ",1,"DESOSSA",,"Necessário vincular Previsão de Produção da Desossa!",4,1)
			else
				reclock('SZU',.f.)
				SZU->ZU_FECHADO := 'N'
				msunlock()
			endif 
		endif
	else 
		Help(" ",1,"ENCERRADA",,"Status não permite esta operação!",4,1)
	endif
return

user function gjf24lb2()  

	if SZU->ZU_FECHADO = 'B'  
		reclock('SZU',.f.)
			SZU->ZU_FECHADO := 'N'
		msunlock() 
	else 
		Help(" ",1,"ENCERRADA",,"Status não permite esta operação!",4,1)
	endif
return

user function gjf24lba()

	Local _cQuery1 	:= ""
	Local _cQuery2 	:= ""
	Local cPerg		:= "GJF24L"
	Local _cCorOri	:= ""
	Local _cCodRes  := ""

	pergunte(cPerg,.T.)

	while empty(mv_par01) .or. empty(mv_par02) .or. empty(mv_par03)
		FWAlertWarning('Por favor, preencha todos os parâmetros para continuar!','ALERTA!')
		pergunte(cPerg,.T.)
	end

	do case
		case mv_par03 = 1
		_cCorOri := "'T'"
		case mv_par03 = 2
		_cCorOri := "'D'"
		case mv_par03 = 3
		_cCorOri := "'C'"
		otherwise
		_cCorOri := "'T','D','C'"
	endcase

	_cQuery1 := "SELECT B1_COD"
	_cQuery1 += " FROM " + retSqlTab('SB1')
	_cQuery1 += " WHERE " + retSqlFil('SB1')
	_cQuery1 += " AND B1_CORORI IN (" + _cCorOri + ")"
	_cQuery1 += " AND B1_MSBLQL = '2'"
	_cQuery1 += " AND B1_SEGUM <> 'PC'"
	_cQuery1 += " AND " + retSqlDel('SB1')
	_cQuery1 += " ORDER BY B1_COD"

	_cQuery1  := ChangeQuery(_cQuery1)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery1 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery1 NEW ALIAS "QRY"

	QRY->(DbGotop())

	While QRY->(!EOF())
		_cCodRes += "'" + alltrim(QRY->B1_COD) + "',"
		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo
    enddo

	_cCodRes := substr(_cCodRes, 1, (len(_cCodRes)-1))

	_cQuery2 := "UPDATE " + RetSqlName('SZU')
	_cQuery2 += " SET ZU_FECHADO = 'N'"
	_cQuery2 += " WHERE D_E_L_E_T_ <> '*'"
	_cQuery2 += " AND ZU_DTPROD = '" + dtos(mv_par01) + "'"
	_cQuery2 += " AND ZU_DTABT = '" + dtos(mv_par02) + "'"
	_cQuery2 += " AND ZU_COD IN (" + _cCodRes + ")"
	_cQuery2 += " AND ZU_FILIAL = '" + FWxFilial('SZU') + "'"
	TcSqlExec(_cQuery2)

return

user function gjf24blo()  
	if SZU->ZU_FECHADO != 'B'
		reclock('SZU',.f.)
		SZU->ZU_FECHADO := 'B'
		msunlock() 
	else
		msgbox('Status não permite essa operação!','OPERAÇÃO INVALIDA!','STOP')
	endif
return

User Function gjf24vp()

	if  empty(M->ZU_COD)
		msgbox('Preencha primeiramente o campo de codigo do produto!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

	_cCorOri := GetAdvFVal('SB1','B1_CORORI',FWxfilial('SB1')+M->ZU_COD,1) 
	_cProdD  := GetAdvFVal('SZ2','Z2_COD',FWxfilial('SZ2')+M->ZU_PREDES,2) 
	_nQtOri  := GetAdvFVal('SB1','B1_NPORI',FWxfilial('SB1')+M->ZU_COD,1) 
	_nQtPeca := GetAdvFVal('SZ2','Z2_QPPECA',FWxfilial('SZ2')+M->ZU_PREDES,2) 

	if _cCorOri = 'T' 
		msgbox('Corte de origem do produto não confere com Previsão da Desossa!','OPERAÇÃO INVALIDA!','STOP') 
		return .f.
	elseif _cCorOri = 'D' 
		msgbox('Corte de origem do produto não confere com Previsão da Desossa!','OPERAÇÃO INVALIDA!','STOP')
		return .f.
	endif

	M->ZU_QPCAIX  := 0	
	M->ZU_QPPESO  := 0
	M->ZU_QTPECAS := _nQtOri * _nQtPeca

Return .t.

Static Function AlterData()

	DEFINE MSDIALOG oDlg2 TITLE 'Apontamento de Parametros' from 000,000 To 200,250 OF oMainWnd PIXEL
	@ 009,002 SAY  'Data de Produção:' Object oSay1
	@ 021,002 SAY  'Data Real de Produção:' Object oSay2
	@ 033,002 SAY  'Data de Abate:' Object oSay3
	@ 045,002 SAY  'Código do Produto:' Object oSay4
	@ 057,002 SAY  'Prev. Produção Desossa:' Object oSay5
	@ 009,065 GET _dDtProd  SIZE 50,10 PICTURE "99/99/99"  Object oData1
	@ 021,065 GET _dDtRPro  SIZE 50,10 PICTURE "99/99/99"  Object oData2
	@ 033,065 GET _dDtAbt   SIZE 50,10 PICTURE "99/99/99"  Object oData3
	@ 045,065 GET _cCodPro  SIZE 50,10 PICTURE "@!" F3 'SB1' valid buscaOP() Object oCodP
	@ 057,065 GET _cNPreDes SIZE 50,10 PICTURE "@!" F3 'SZ2' Object oOp02
	@ 075,002 SAY  '[F12]Alterar Parametros' Object oSay3
	@ 075,090 BMPBUTTON TYPE 1 ACTION odlg2:end() Object Obtn2
	ACTIVATE MSDIALOG oDlg2

	M->ZU_DTPROD := _dDtProd
	M->ZU_DTRPRO := _dDtRPro
	M->ZU_PREDES := _cNPreDes
return .t.

// Busca uma sugestão de OP da Desossa baseado no cadastro do código do produto
Static Function buscaOP()
	_cProg := GetAdvFVal('SB1','B1_PROGRAM',FWxfilial('SB1')+alltrim(_cCodPro),1)
	_cCOrig := GetAdvFVal('SB1','B1_CORORI',FWxfilial('SB1')+alltrim(_cCodPro),1)
	if !empty(_cProg)
		_cNPreDes := GetAdvFVal('SZ2','Z2_NUM',FWxfilial('SZ2')+dtos(_dDtAbt)+substr(_cProg,1,3)+alltrim(_cCOrig),11)
	else
		FWAlertWarning("Produto não possui programa relacionado no cadastro!", "ATENÇÃO")
	endif
Return .T.

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

//Função para alterar rapidamente o campo que determina o
//controle exato de produção
User Function gjf24ext()
	local _ext

	_ext := iif(SZU->ZU_CONTEXA = 'N' .or. empty(SZU->ZU_CONTEXA),'S','N')

	reclock('SZU',.f.)
	SZU->ZU_CONTEXA := _ext
	msunlock()  

return 

//Execblock para ser acionado no gatilho do campo ZU_COD para SU_ETIQ
User Function gjf24ET()

	//Pega os  codigos que serão produzidos com etiquetas em espanhol
	Local _cCodPEs := GETMV('SI_PETQES')
	Local Ret      := M->ZU_ETIQ

	if alltrim(M->ZU_COD) $ _cCodPEs
		Ret := 'ES'
	endif

return Ret

//monta o cabeçalho do acols para o TMP
Static Function gjf24Ahead(cAlias)

	Local i
	aHeader := {}

	_cAlias  := cAlias 		// ZAN
	_aCpoSX3 := FwSX3Util():GetAllFields(_cAlias)
	For i := 1 To Len(_aCpoSX3)
		If (X3Uso(GetSx3Cache(_aCpoSX3[i], 'X3_USADO')))
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

//Montagem do aCols   para o TMP
static Function gjf24Acols(nOpc)
	Local nI, nPos
	//If nOpc == 3

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

	nPos  := aScan(aHeader,{ |x| AllTrim(x[2])== "ZAN_COD" })
	if nPos > 0
		aCols[1,nPos]	:= StrZero(len(acols)+1,Len(aCols[1,nPos]))
	endif
	aCols[1,nUsado+1] := .F.

	aCols := {}

	TMP->(DbGoTop())

	Do While TMP->(!Eof()) 

		if !('PP' $ TMP->EMBAL) 
			_cDesc := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1')+TMP->EMBAL,1)
			aAdd(aCols,Array(nUsado+1))
			aCols[Len(aCols),1] := TMP->EMBAL
			aCols[Len(aCols),2] := _cDesc
			aCols[Len(aCols),nUsado+1] := .F.  
		endif 

		TMP->(DbSkip())
	Enddo 

Return

//Gera arquivo de trabalho
Static Function GeraTRB()

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	_aArqTrb    := {} 
	aStru := {}

	aadd(aStru,{"EMBAL" , "C",   15, 0,   "@!",'Cod.Emb.'})
	aadd(aStru,{"DESCR" , "C",   20, 0,   "@!",'Descri.'})

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

return

//Gera arquivo temporário para requisição das embalagens
Static Function GeraTMP()

	GeraTRB()	
	dbSelectArea("ZAN")
	ZAN->(dbSetOrder(1))
	if ZAN->(MsSeek(FWxFilial('ZAN')+M->ZU_NUM)) .and. _cProd = M->ZU_COD

		Do While ZAN->(!Eof()) .and. FWxFilial('ZAN') ==  ZAN->ZAN_FILIAL .and. ZAN->ZAN_PREEMB == M->ZU_NUM

			DbSelectArea('TMP')
			reclock('TMP',.t.)
			TMP->EMBAL :=  ZAN->ZAN_COD
			TMP->DESCR :=  ZAN->ZAN_DESC
			msunlock()

			ZAN->(DbSkip())
		Enddo    

	else

		SG1->(DbSetOrder(1))
		SG1->(DbGoTop())
		if SG1->(MsSeek(FWxfilial('SG1')+M->ZU_COD))
			while SG1->(!eof()) .and. SG1->G1_COD = M->ZU_COD 
				if !('PP' $ SG1->G1_COMP) 
					_cDesc := GetAdvFVal('SB1','B1_DESC',FWxfilial('SB1')+SG1->G1_COMP,1)
					DbSelectArea('TMP')
					reclock('TMP',.t.)
					TMP->EMBAL := SG1->G1_COMP
					TMP->DESCR  := _cDesc
					msunlock()
				endif 

				SG1->(DbSkip())  

			enddo
		endif     

	endif

	_cProd := M->ZU_COD

return

//Grava as alterações do TMP caso existam
Static Function GravaTMP()

	Local nIt
	//Local nPosDel 		:= Len(aHeader) + 1

	//TMP->(DbCloseArea())

	GeraTRB()

	For nIt := 1 To Len(aCols)
		if !aCols[nIt,nUsado+1]
			DbSelectArea('TMP')
			reclock('TMP',.t.)
			TMP->EMBAL := aCols[nIt,1]
			TMP->DESCR := aCols[nIt,2]
			msunlock()
		endif
	Next


	oDlg2:end()

Return 

//Função destinada a realizar movimentações internas
User Function gjf24Mov(cAlias,nReg,nOpc)

	if Empty(M->ZU_COD)
		alert('Por favor, indique o codigo do produto!')
		return 
	elseif  M->ZU_COD <> _cProd .and. !empty(_cProd)
		//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		//	TMP->(dbCloseArea())
		//Endif
		//está gerando o TMP "manualmente"
		GeraTMP()
	elseif !empty(M->ZU_COD) .and. empty(_cProd)
		//está gerando o TMP "manualmente"
		GeraTMP()       
	endif

	nOpc := 4

	gjf24Ahead("ZAN")                                                           //Monta oa vetor aHeader

	nUsado := Len(aHeader)

	gjf24Acols(nOpc)

	DEFINE DIALOG oDlg2 TITLE "Requisição Embalagens" FROM 020,50 To 200,450 PIXEL

	oGetDad := MSGetDados():New (005, 005, 50, 200,nOpc,"AllwaysTrue","AllwaysTrue",,.T.,{"ZAN_COD"},)

	@ 060,020     BUTTON 'Cancela' SIZE 40,10 ACTION oDlg2:end() OBJECT oBtn1
	@ 060,100     BUTTON 'Salva'   SIZE 40,10 ACTION GravaTMP() OBJECT oBtn2

	ACTIVATE DIALOG oDlg2 CENTERED 

return

//Função que verifica se existe relação com
//industria de porcionados
Static Function VerPorc(nOpc)
	Local _lRet   := .t.
	Local _lFound := .f.

	if M->ZU_MPPORC = 'S'

		if empty(M->ZU_PREDES) .and. nOpc <> 5
			//Help(" ",1,"DESOSSA",,"Necessário vincular Previsão de Produção da Desossa!",4,1)
			//_lRet := .f.
		else
			//_cCodPorc := GetAdvFVal('ZAR','ZAR_COD',FWxfilial('ZAR') + M->ZU_PREPORC,1)
			_cTipo := GetAdvFVal('SB1','B1_TIPO',FWxfilial('SB1') + M->ZU_COD,1)

			if _cTipo $ "QR/QF/MP/SO/MP/PP"
				_lFound := .t.
			endif

			if !_lFound
				If Aviso("Confirma operação?","Produto MP não pertence à batelada do dia!",{"Confirma","Cancela"}) == 1
					_lRet := .t.
				endif
			endif
		endif
	endif

return _lRet

//Execblock para gatilho no campo ZU_COD para o campo ZU_MPPORC 
User Function GF24po()

	_cRet := ''

	DbSelectArea('SB1')
	_grp := GetAdvFVal('SB1','B1_GRUPO',FWxfilial('SB1')+M->ZU_COD,1)

	if _grp $ '4006/4007/4008/4009'
		_cRet := 'S'
	endif

return _cRet

//Função para validação do campo ZU_PREPORC 
User Function gjf24po()
	Local _lRetChav := nil
	Local _lRetCpo  := nil
	Local _lRetEmp  := nil
	Local _lRet     := nil
	Local _cEmp     := ''

	_lRetChav := iif(!ExistChav("SZU",,5,'OPS!'),.f.,.t.)

	_lRetCpo := iif(!ExistCpo('ZAR',,1),.f.,.t.)

	_cEmp := GetAdvFVal('ZAR','ZAR_EMP',FWxfilial('ZAR')+M->ZU_PREPORC,1)

	_lRetEmp := iif(_cEmp == 'N',.f.,.t.)

	if  !_lRetChav
		Help(" ",1,"PORCIONADOS",,"Produção já vinculada!",4,1)
		_lRet := .f.
	elseif !_lRetCpo
		Help(" ",1,"PORCIONADOS",,"Produção inexistente!",4,1)
		_lRet := .f.
	elseif !_lRetEmp
		Help(" ",1,"PORCIONADOS",,"Novos empenhos bloqueados!",4,1)
		_lRet := .f.
	else
		_lRet := .t.
	endif

return _lRet

/*data Criação - 17/10/19 - Flávio 
Solicitação = Valeska
Função para validação da data do Abate 
Quando a data do abate for muito velha o sistema emite um aviso 
colocar no valid do campo ZU_COD  - U_gjf24ver(M->ZU_PREDES) */
User Function gjf24ver(_nPreDes)
	Local _dDTMenor   := date() - 4
	Local _dData := date()

	If !Empty(alltrim(_nPreDes))
		_dData := GetAdvFVal('SZ2','Z2_DTPROD',FWxfilial('SZ2')+alltrim(_nPreDes),2)
		if _dData <  _dDTMenor
			msgbox('Abate Antigo , Favor alterar o campo Data Produção','OPERAÇÃO NEGADA!','STOP')
		endif
	Endif

Return .T.

/*  Função criada para mostrar o nr da data do abate da tabela SZ2 */
User Function tnvf()
	Local cCodigo := alltrim(SZU->ZU_PREDES) 
	_cDTABT := GetAdvFVal('SZ2','Z2_DATAABT',FWxfilial('SZ2')+alltrim(cCodigo),2) 

	if !empty(alltrim(cCodigo))	
		
		_sdDD := substr(dtos(_cDTABT),7,2) 	
		_sdMM := substr(dtos(_cDTABT),5,2) 	
		_sdAA := substr(dtos(_cDTABT),1,4) 	

		_sData := _sdDD +' / '+_sdMM + ' / ' + _sdAA	
		Help(" ",1,'Abate',,'Data Abate Nr: '+_sData,4,1)
	else
		alert('!! Sem Data do Abate !!')
	endif

Return 

/*/{Protheus.doc} mrrPrevDso
	(Função para validar a previsão de desossa quando produto for para exportação dos EUA )
	@type  Static Function
	@author Mauricio Roehrs
	@since 09/01/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function mrrPrevDso(_cCodProd)
	Local _lValid := .t.

	_cCadMerc    := GetAdvFVal('SB1','B1_CADMERC',FWxfilial('SB1')+_cCodProd,1)

	if alltrim(_cCadMerc) == 'U'
		if empty(M->ZU_PREDES)
			_lValid := .f.
		endif
	endif

Return _lValid

/*/{Protheus.doc} User Function mrrQpPeso
	(long_description)
	@type  Function
	@author Mauricio Roehrs
	@since 24/01/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
User Function mrrQpPeso(_nQpPeso,_cCodProd)

	_nPsMxEua := SuperGetMV('SI_PSMXEUA',.t.,4762.8) //peso maximo para criar uma op de embalagem... se não encontrar o parametro pega o peso fixado de 4500kg 
	_cCadMerc := GetAdvFVal("SB1", "B1_CADMERC", FWxFilial("SB1") + _cCodProd, 1)

	if _nQpPeso > _nPsMxEua .and. alltrim(_cCadMerc) == 'U'
		Help(" ",1,"EXPORT. EUA",,"Peso maximo para lançamento de OP de embalagem não deve ultrapassar " + transform(_nPsMxEua,'@E 99999.99')+ "kg (SI_PSMXEUA)",4,1)
		return .f.
	endif

Return .t.
