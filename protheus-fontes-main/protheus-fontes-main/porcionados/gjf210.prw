#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"   
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF210  º Autor ³ Giuliano Forgiraini  º Data ³ 15/09/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Geração de Ordens de Produção com base nos pre-pedidos de   º±±
±±º          ³ venda recebidos pelo setor comercial                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCP porcionados                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    
User Function GJF210() 
	Local _aArqTrb    := {} // inicializa o array do arquivo
	private aRotina   :={}
	Private lInverte  := .f.
	Private cMark     := GetMark()  
	Private oMark     
	Private aBrowse1  := {} 
	Private aBrowse2  := {}
	Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)     
	Private _cGrpMoi  := GetMV('SI_GRPMOI')

	aObjects := {}    //dimensao janelas
	aPosObj  := {}
	aInfo    := {}
	aSizeAut := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	area := GetArea()
	cPerg := "GJF210"

	//GeraPerg(cPerg)

	If !Pergunte(cPerg,.T.)
		RestArea( area )
		Return
	Endif

	GeraTMP()

	aCampos  := {}
	AADD(aCampos,{"ZZ5_OK"     ,,"OK"          ,"@!" })
	AADD(aCampos,{"ZZ5_NUM"    ,,"Pre-ped."	 ,"@!" })
	AADD(aCampos,{"ZZ5_ITEM"   ,,"Item"     	 ,"@!" })
	AADD(aCampos,{"ZZ4_DT"     ,,"Data PP"  	 ,"99/99/9999" })
	AADD(aCampos,{"ZZ5_CLI"		,,"Cliente"     ,"@!" })
	AADD(aCampos,{"ZZ5_LOJA"   ,,"Loja"        ,"@!" })
	AADD(aCampos,{"ZZ5_NOME"   ,,"Nome  "      ,"@!" })
	AADD(aCampos,{"ZZ5_COD"    ,,"Produto"     ,"@!" })
	AADD(aCampos,{"ZZ5_DESC"   ,,"Descricao"   ,"@!" })
	AADD(aCampos,{"ZZ5_PRCCLI" ,,"Preco"       ,"@E 999.99"})
	//AADD(aCampos,{"ZZ5_QPCAIX" ,,"Qtd. Caix"   ,"@E 999"})
	AADD(aCampos,{"ZZ5_QPPESO" ,,"Qtd. Peso"   ,"@E 999,999.99"})
	AADD(aCampos,{"ZZ5_SLDPOR" ,,"Saldo Ped."  ,"@E 999,999.99"})

	//AADD(aCampos,{"ZZ5_DESC" 	,,"Descricao"   ,"@!"})  
	//AADD(aCampos,{"ZZ5_PRCFIN" ,,"Preco Final" ,"@E 999,999.99"})

	//Cabeçalho e colunsa do browse
	aHeader1 := {'Ordem Prod.','Lote','OP Des./Emb.','Dt.Geracao','Dt. Abate','Pedido','Item','Data','Cliente','Loja','Nome' ,'Codigo','Cod. MP','Produto','Preço','Qtd. Peso','Qtd. Caix','Qtd.Unid','Saldo Ped.','Lote'}
	aLargCol1 := {40          , 40   ,     40       ,40          ,40         ,30      ,  20  ,  30  ,    20   ,  20  ,  100  ,   30   ,30       ,   100   ,  40  ,     40     ,    40     ,40        ,   40       , 40   }

	aHeader2 := {'Ordem Prod.','Numero','Status','Data','Produto','Descricao','Dt. Abate','Peso Prev.','Caix. Prev.','Unid. Prev.','Preço','Layout','Lote'}
	aLargCol2 := {   60       ,  40   ,  40   ,  40   ,  40     ,  100      ,   40      ,   40       ,  40         ,     40      ,   40  , 40     , 40   }

	DEFINE MSDIALOG oDlg TITLE "Pedidos de Venda e Geração de Ordens de Produção" From 9,0 To 570,1280 PIXEL

	oMark := MsSelect():New("TMP","ZZ5_OK","",aCampos,@lInverte,@cMark,{05,1,100,643},,,,,)
	oMark:bMark := {| | Disp()}

	_oSay1 := TSay():New(120,1, {|| 'Pre-pedidos processados:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)

	oBrowse1 := TCBrowse():New(130,1,640,80,,aHeader1,aLargCol1,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	GeraTMP2()

	TButton():New(255, 010, "Marcar/Desmarcar", oDlg,{|| Selecionar()} ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(255, 080, "Gerar OP"        , oDlg,{|| GeraPrev()  } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(255, 150, "Alterar Qntd."   , oDlg,{|| Altera()    } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(255, 220, "Confirmar Qntd." , oDlg,{|| Altera2()   } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )  //feito pelo maumau
	TButton():New(255, 290, "Apontar Lote"    , oDlg,{|| ApLote()    } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(255, 360, "Info. Pedido"    , oDlg,{|| Info()      } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(255, 430, "Gera OPs Desossa", oDlg,{|| GerOPB()    } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(255, 500, "Legenda"         , oDlg,{|| LEgenda()   } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New(255, 570, "Sair"            , oDlg,{|| oDlg:end()  } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED

	If Select("TMP")<> 0
		TMP->(dbCloseArea())
	Endif
	If Select("TMP2")<> 0
		TMP2->(dbCloseArea())
	Endif

    // ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb("FechaTodos",,,, @_aArqTrb)
Return .T.

Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("ZZ5_OK")
		TMP->ZZ5_OK := cMark
	Else
		TMP->ZZ5_OK := ""
	Endif
	msunlock()

	oMark:oBrowse:Refresh()
Return()

//Função para alterar a quantidade a gerar na OP
Static Function Altera()
	ZZ5->(DbSetOrder(1))
	ZZ5->(MsSeek(FWxfilial('ZZ5')+TMP->(ZZ5_NUM+ZZ5_ITEM)))

	_nQtdOri := ZZ5->ZZ5_SLDPOR
	_nQtdAlt := TMP->ZZ5_SLDPOR
	_lAlt    := .f.

	DEFINE MSDIALOG oDlg2 TITLE 'Quantidade' from 000,000 To 150,250 OF oMainWnd PIXEL
	@ 009,002 SAY  'Quantidade original:' Object oSay1
	@ 021,002 SAY  'Quantidade a produzir:' Object oSay2
	@ 009,065 GET _nQtdOri  SIZE 50,10 PICTURE "@E 999,999.99"  Object oQtdOri
	@ 021,065 GET _nQtdAlt  SIZE 50,10 PICTURE "@E 999,999.99"  Object oQtdAlt

	oQtdOri:disable()

	@ 055,090 BMPBUTTON TYPE 1 ACTION EVAL({|| _lAlt := .t.,oDlg2:end()}) Object Obtn2
	ACTIVATE MSDIALOG oDlg2

	if _lAlt
		reclock('TMP',.f.)
		TMP->ZZ5_QPPESO := iif( (_nQtdAlt <= _nQtdOri .and. _nQtdAlt > 0),_nQtdAlt,_nQtdOri)
		TMP->ZZ5_SLDPOR := iif( (_nQtdAlt <= _nQtdOri .and. _nQtdAlt > 0),_nQtdOri - _nQtdAlt,_nQtdOri)
		msunlock()
	endif

	oMark:oBrowse:Refresh()
	oDlg:Refresh()

return 


//Função para alterar a quantidade a gerar na OP para todos os pedidos
Static Function Altera2()
	ZZ5->(DbSetOrder(1))
	ZZ5->(MsSeek(FWxfilial('ZZ5')+TMP->(ZZ5_NUM+ZZ5_ITEM)))

	_nQtdOri := ZZ5->ZZ5_SLDPOR
	_nQtdAlt := TMP->ZZ5_SLDPOR

	TMP->(dbGoTop())
	while TMP->(!eof())
		if empty(TMP->ZZ5_OK)
			TMP->(dbSkip())
			loop
		endif

		if TMP->ZZ5_SLDPOR = 0
			TMP->(dbSkip())
			loop
		endif

		reclock('TMP',.f.)
		TMP->ZZ5_OK := ''
		TMP->ZZ5_QPPESO := TMP->ZZ5_SLDPOR
		TMP->ZZ5_SLDPOR := 0 
		msunlock()
		TMP->(dbSkip())
	enddo

	TMP->(dbGoTop())
	oMark:oBrowse:Refresh()	
	oDlg:Refresh()

return 

//Função para apontar o lote te produção manualmente
//Função para alterar a quantidade a gerar na OP
Static Function ApLote()
	Local _lLote := .f.
	Local _cLote:= space(10)
	Local _nModo   := 1
	Local _aOpcoes := {"Vincular","Desvincular"}

	DEFINE MSDIALOG oDlg3 TITLE 'Apontar Lote' from 000,000 To 150,250 OF oMainWnd PIXEL
	@ 009,002 SAY  'Lote de produção:' Object oSay1
	@ 009,065 GET _cLote  SIZE 50,10 PICTURE "@!"  F3 "coZAUp" Object oLote

	@ 030,002 SAY  'Operação:' Object oSay2
	_oRadio1 := TRadMenu():New(030,050,_aOpcoes,{|u| Iif(PCount()==0,_nModo,_nModo:=u)},oDlg3,,{||},,,,,,100,12,,,,.T.)

	@ 055,090 BMPBUTTON TYPE 1 ACTION EVAL({|| _lLote := iif(!empty(_cLote),.t.,.f.),oDlg3:end()}) Object Obtn1
	ACTIVATE MSDIALOG oDlg3

	if _nModo = 1
		if _lLote
			ZAU->(DbSetOrder(1))
			if ZAU->(MsSeek(FWxfilial('ZAU') + _cLote))	
				TMP->(DbGoTop())

				While TMP->(!eof())

					if !empty(TMP->ZZ5_OK)
						if alltrim(ZAU->ZAU_COD) = alltrim(TMP->ZZ5_COD)
							ZZ5->(DbSetOrder(1))
							if  ZZ5->(MsSeek(FWxfilial('ZZ5')+TMP->(ZZ5_NUM+ZZ5_ITEM)))
								reclock('ZZ5',.f.)
								ZZ5->ZZ5_LOTE := _cLote
								msunlock()
							endif
						endif
					endif

					TMP->(DbSkip())
				EndDo

			endif

		endif
	else
		_cNumPP := aBrowse1[oBrowse1:nAt,02]
		_cItem  := aBrowse1[oBrowse1:nAt,03]
		ZZ5->(DbSetOrder(1))
		if ZZ5->(MsSeek(FWxfilial('ZZ5') + _cNumPP + _cItem))
			reclock('ZZ5',.f.)
			ZZ5->ZZ5_LOTE := ''
			msunlock()
		endif
	endif

	GeraTMP()
	GeraTMP2()

	oMark:oBrowse:Refresh()
	oDlg:Refresh()

return 

//Função para selecionar itens do pre-pedido para 
//geração de Op ou apontamento de lote.
Static Function Selecionar()
	TMP->(dbgotop())   

	while TMP->(!eof())
		reclock('TMP',.f.)
		TMP->ZZ5_OK := iif(empty(TMP->ZZ5_OK),cMark,"")
		msunlock()

		TMP->(dbskip())
	enddo

	TMP->(dbgotop())

	oMark:oBrowse:Refresh()
return .t.

//Função para Gerar a Previsão de Produção
Static Function GeraPrev()
	_aQuant := {}
	_cRelOp := ''

	TMP->(DbGoTop())

	While TMP->(!eof())

		if TMP->ZZ5_QPPESO = 0
			TMP->(DbSkip())
			loop
		endif

		SG1->(DbSetOrder(1))
		if SG1->(MsSeek(FWxfilial('SG1')+TMP->ZZ5_COD))

			//Função que verifica disponibilidade de PA para carregar...
			if !VerSZ8(TMP->ZZ5_COD)
				if !empty(TMP->ZZ5_OK)
					_cNum    :=  GetSx8num('ZAR','ZAR_NUM')
					ConfirmSx8()

					_cDescri :=  GetAdvFval('SB1','B1_DESC',FWxfilial('SB1') + TMP->ZZ5_COD,1)
					_cLayEtq :=  GetAdvFval('SB1','B1_LAYETQ',FWxfilial('SB1') + TMP->ZZ5_COD,1)
					_cGrupo  :=  GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1') + TMP->ZZ5_COD,1)
					_cPorc   :=  GetAdvFval('SBM','BM_PORC',FWxfilial('SBM') + _cGrupo,1)

					_aQuant := u_GJF210Q(TMP->ZZ5_QPPESO,TMP->ZZ5_COD)

					_DesCli := GetAdvFval('SA1','A1_NOME',FWxfilial('SA1') + TMP->(ZZ5_CLI+ZZ5_LOJA),1)

					//Validação das quantidades
					if _aQuant[3] <= 0 .or. _aQuant[1] <= 0 .or. _aQuant[2] <= 0  
						Help(" ",1,"PRODUTO " + alltrim(TMP->ZZ5_COD),,"Erro de cadastro/Estrutura!",4,1)
						TMP->(DbSkip())				
						loop
					endif

					reclock('ZAR',.t.)
					ZAR->ZAR_FILIAL := FWxfilial('ZAR')
					ZAR->ZAR_NUM    := _cNum
					ZAR->ZAR_DATA   := DDATABASE
					ZAR->ZAR_COD    := TMP->ZZ5_COD
					ZAR->ZAR_DESC   := _cDescri
					ZAR->ZAR_QPESOR := TMP->ZZ5_QPPESO
					ZAR->ZAR_QPPESO := _aQuant[3]
					ZAR->ZAR_QPCAIX := _aQuant[1]
					ZAR->ZAR_QPUNI  := _aQuant[2]
					ZAR->ZAR_STATUS := 'A'
					ZAR->ZAR_PREPED := TMP->ZZ5_NUM
					ZAR->ZAR_ITEMPP := TMP->ZZ5_ITEM
					ZAR->ZAR_DTPREP := TMP->ZZ4_DT
					ZAR->ZAR_PRCCLI := TMP->ZZ5_PRCCLI
					ZAR->ZAR_EMP    := 'S'
					ZAR->ZAR_LAYETQ := _cLayEtq
					ZAR->ZAR_CODCLI := TMP->ZZ5_CLI
					ZAR->ZAR_LOJA   := TMP->ZZ5_LOJA
					ZAR->ZAR_DESCLI := _DesCli
					ZAR->ZAR_GRUPO  := _cGrupo
					msunlock()

					ZZ5->(DbSetOrder(1))
					if ZZ5->(MsSeek(FWxfilial('ZZ5')+TMP->(ZZ5_NUM+ZZ5_ITEM)))
						if !empty(_cPorc)
							RecLock('ZZ5',.f.)
							ZZ5->ZZ5_SLDPOR := ZZ5->ZZ5_SLDPOR - TMP->ZZ5_QPPESO
							ZZ5->ZZ5_SOLPRO := 'S'
							if empty(ZZ5->ZZ5_DTSPOR)
								ZZ5->ZZ5_DTSPOR := TMP->ZZ4_DT//DDATABASE
							endif
							msunlock()
						endif
					endif

					_cRelOp += "OP Nº: " + ZAR->ZAR_NUM + ": " + transform(_aQuant[3],'@E 999,999.99') + "kg "  +  chr(13) + chr(10)

					_nItem := 0

					//Aqui grava demandas...
					/*while SG1->(!eof()) .and. SG1->G1_FILIAL = FWxfilial('SG1') .and. SG1->G1_COD = TMP->ZZ5_COD
						if SG1->G1_TPPORC = 'RM'
							reclock('ZAV',.t.)
							ZAV->ZAV_FILIAL := FWxfilial('ZAV')
							ZAV->ZAV_NUM    := _cNum
							ZAV_ITEM        := strzero(_nItem,3)
							ZAV->ZAV_COD    := SG1->G1_COMP
							ZAV->ZAV_QPPESO := _aQuant[3] * SG1->G1_QUANT
							msunlock()
						endif
						SG1->(DbSkip())
					enddo*/

				endif
			else
			endif
		else
			Help(" ",1,"PRODUTO " + alltrim(TMP->ZZ5_COD),,"Não há estrutura de produtos constituída para este PA!",4,1)
		endif

		TMP->(DbSkip())
	EndDo

	pergunte(cPerg,.f.)

	GeraTMP()
	GeraTMP2()

	oMark:oBrowse:Refresh()	

	if !empty(_cRelOp) 
		@ 00,00 To 130,220 Dialog oDlgMemo Title "OPs Geradas:"
		@ 005,005 Get _cRelOp Size 100,040 MEMO Object oMemo
		@ 050,025 BUTTON botao1 PROMPT "Fechar" OF oDlgMemo PIXEL ACTION oDlgMemo:end()
		Activate Dialog oDlgMemo  CENTERED
	endif

return

//Função responsável pela geração do arquivo de trabalho TMP
Static Function GeraTMP()

	cQuery := " SELECT * FROM " + RetSQLTab('ZZ4') + "," + RetSQLtab('ZZ5')
	cQuery += " WHERE " + RetSQLFil('ZZ4,ZZ5') + " AND ZZ4_NUM = ZZ5_NUM AND "
	cQuery += " ZZ4_TIPOPR = 'P' AND "
	//CqUERY += " ZZ4_STATUS NOT IN('C','E','F','R','S') AND "
	cQuery += " ZZ5_SLDPOR <> 0 AND ZZ5_LOTE = '' AND  ZZ5_SOLPRO = 'S' AND "
	cQuery += " ZZ4_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02)+ "'"
	cQuery += " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5') 
	cQuery += " ORDER BY ZZ4_NUM,ZZ5_ITEM "
	cQuery := ChangeQuery(cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY")<> 0
		QRY->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "QRY"

	QRY->(DbGotop())

	_aArqTrb := {}
	aStru	 := {}
	//cArq  := CriaTrab( Nil, .F. )
	//aStru := dbStruct()

	aadd(aStru,{"ZZ5_OK"       , "C",  2, 0})
	aadd(aStru,{"ZZ5_FILIAL"   , "C",  2, 0})
	aadd(aStru,{"ZZ5_NUM"      , "C",  6, 0})
	aadd(aStru,{"ZZ5_ITEM"     , "C",  3, 0})
	aadd(aStru,{"ZZ5_CLI"	   , "C",  6, 0})
	aadd(aStru,{"ZZ5_LOJA"     , "C",  2, 0})
	aadd(aStru,{"ZZ5_NOME"     , "C", 40, 0})
	aadd(aStru,{"ZZ5_COD"      , "C", 14, 0})
	aadd(aStru,{"ZZ5_DESC"     , "C", 25, 0})
	aadd(aStru,{"ZZ5_QPPESO"   , "N",  9, 2})
	aadd(aStru,{"ZZ5_SLDPOR"   , "N",  9, 2})
	aadd(aStru,{"ZZ5_PRCCLI"   , "N",  9, 2})
	aadd(aStru,{"ZZ4_DT"       , "D",  8, 0})

	//dbcreate(cArq,aStru)
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {"ZZ5_FILIAL","ZZ5_NUM"}, @_aArqTrb)

	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )               //cria temp
	//Index On ZZ5_FILIAL+ZZ5_NUM To (cArq)

	While QRY->(!eof())

		Reclock('TMP',.t.)
		TMP->ZZ5_FILIAL   := FWxfilial('ZZ5')
		TMP->ZZ5_NUM      := QRY->ZZ5_NUM
		TMP->ZZ5_ITEM     := QRY->ZZ5_ITEM
		TMP->ZZ5_CLI	  := QRY->ZZ4_CODCLI
		TMP->ZZ5_LOJA     := QRY->ZZ4_LOJA
		TMP->ZZ5_NOME     := QRY->ZZ4_NOME
		TMP->ZZ5_COD      := QRY->ZZ5_COD
		TMP->ZZ5_DESC     := QRY->ZZ5_DESC
		//	TMP->ZZ5_QPCAIX   := QRY->ZZ5_QPCAIX
		TMP->ZZ5_QPPESO   := 0.00  //QRY->ZZ5_SLDPOR
		TMP->ZZ5_SLDPOR   := QRY->ZZ5_SLDPOR
		TMP->ZZ5_PRCCLI   := QRY->ZZ5_PRCCLI
		TMP->ZZ4_DT       := stod(QRY->ZZ4_DATA)
		MsUnlock() 

		QRY->(DbSkip())
	enddo

	dbSelectarea('TMP')
	//IndRegua("TMP",cArq,"ZZ5_NUM+ZZ5_ITEM",,,"Selecionando Registros...") //ordena
	TMP->(dbGotop())

return

//Função para definir as quantidades nas OPs de bifes
User Function GJF210Q(_nPeso,_cCod)
	Local _aRet := {}

	//Quantidade de bandeja por caixa
	_nQtdBC  := GetAdvFval('SB1','B1_QTBCAIX',FWxfilial('SB1') + _cCod,1)
	//Peso unitário de cada bandeja
	_nPesoBa  := GetAdvFval('SB1','B1_PESBAND',FWxfilial('SB1') + _cCod,1)

	//Cálculo do número total de bandejas
	_nTotB := _nPeso/_nPesoBa

	_nResto1 := MOD(_nPeso,_nPesoBa)

	if _nResto1 <> 0
		if  round(_nTotB,0) < _nTotB
			_nTotB := round(_nTotB,0)+1
		else
			_nTotB := round(_nTotB,0)
		endif
	endif 

	//Cálculo do Número total de caixas

	_nTotCaix := _nTotB/_nQtdBC

	_nResto2 := MOD(_nTotB,_nQtdBC)

	if _nResto2 <> 0 
		if round(_nTotCaix,0) < _nTotCaix
			_nTotCaix := round(_nTotCaix,0)+1
		else 
			_nTotCaix := round(_nTotCaix,0)
		endif
	endif

	aadd(_aRet,_nTotCaix)

	_nTotB := _nTotCaix * _nQtdBC

	aadd(_aRet,_nTotB)

	//Calculo do Peso Final a ser produzido
	_nPesoF := (_nTotB * _nPesoBa)

	aadd(_aRet,_nPesoF)

return _aRet

//Função de atualização do Browse dos itens com lote apontado-
Static Function GeraTMP2()  
	/*
	cQuery2 := " SELECT * FROM " + RetSQLTab('ZZ4') + "," + RetSQLtab('ZZ5') 
	cQuery2 += " WHERE " + RetSQLFil('ZZ4,ZZ5') + " AND ZZ4_NUM = ZZ5_NUM AND "
	cQuery2 += " ZZ4_TIPOPR = 'P' AND "  
	//CqUERY += " ZZ4_STATUS NOT IN('C','E','F','R','S') AND "
	cQuery2 += iif(mv_par03 = 1," ZZ5_SLDPOR <> 0 AND ZZ5_LOTE = '' AND  "," ZZ5_SLDPOR = 0 AND ZZ5_LOTE = '' AND  ")
	cQuery2 += " ZZ4_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02)+ "'"
	cQuery2 += " AND " + RetSQLDel('ZZ4','ZZ5') 
	cQuery2 += " ORDER BY ZZ4_NUM,ZZ5_ITEM "
	cQuery2 := ChangeQuery(cQuery2)
	*/
	cQuery2 := " SELECT * FROM " + RetSQLTab('ZZ4') + "," + RetSQLtab('ZZ5') + "," + RetSQLTab('ZAR')
	cQuery2 += " WHERE " + RetSQLFil('ZZ4,ZZ5,ZAR') + " AND ZZ4_NUM = ZZ5_NUM AND ZZ4_NUM = ZAR_PREPED AND ZZ5_ITEM = ZAR_ITEMPP AND "
	cQuery2 += " ZZ4_TIPOPR = 'P' AND "
	//cQuery2 += " ZZ5_SLDPOR = 0 AND ZZ5_LOTE = '' AND  "
	cQuery2 += " ZZ5_SLDPOR <> ZZ5_QPPESO AND "
	//cQuery2 += " ZZ4_STATUS NOT IN('C','E','F','R','S') AND "
	cQuery2 += " ZZ4_DATA BETWEEN '" + dtos(mv_par01) + "' AND '" + dtos(mv_par02)+ "'"
	cQuery2 += " AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5') + " AND "	+ RetSQLDel('ZAR')
	cQuery2 += " ORDER BY ZZ4_NUM,ZZ5_ITEM "
	cQuery2 := ChangeQuery(cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY2")<> 0
		QRY2->(dbCloseArea())
	Endif
	TCQUERY cQuery2 NEW ALIAS "QRY2"

	QRY2->(DbGotop())

	// Vetor com elementos do Browse
	aBrowse1 := {}		

	While QRY2->(!eof())

		if QRY2->ZZ5_STATUS = 'E'
			_stt := 'E'
		elseif (QRY2->ZZ5_QRPESO >= QRY2->ZZ5_QPPESO)
			_stt := 'E'
		elseif (QRY2->ZZ5_QRPESO <> 0) .and. (QRY2->ZZ5_QPPESO < QRY2->ZZ5_QRPESO)
			_stt := 'P'
		else
			_stt := 'A'
		endif

		aadd(aBrowse1,{QRY2->ZAR_NUM,;
		QRY2->ZAR_LOTE,;
		QRY2->ZAR_PREEMB,;
		dtoc(stod(QRY2->ZAR_DATA)),;
		dtoc(stod(QRY2->ZAR_DTABAT)),;
		QRY2->ZZ5_NUM,;
		QRY2->ZZ5_ITEM,;
		dtoc(stod(QRY2->ZZ4_DATA)),;
		QRY2->ZZ4_CODCLI,;
		QRY2->ZZ4_LOJA,;
		QRY2->ZZ4_NOME,;
		QRY2->ZZ5_COD,;
		QRY2->ZAR_CODMP,;
		QRY2->ZZ5_DESC,;
		transform(QRY2->ZZ5_PRCCLI,'@E 999.99'),;
		transform(QRY2->ZAR_QPPESO,'@E 999,999.99'),;
		transform(QRY2->ZAR_QPCAIX,'@E 999,999.99'),;
		transform(QRY2->ZAR_QPUNI,'@E 999,999.99'),;
		transform(QRY2->ZZ5_SLDPOR,'@E 999'),;
		QRY2->ZZ5_LOTE})

		QRY2->(DbSkip())
	enddo

	if len(aBrowse1) = 0
		aadd(aBrowse1,{'','','','','','','','','','','','','','','','','','','','',''})
	endif

	oBrowse1:SetArray(aBrowse1)

	// Monta a linha a ser exibina no Browse
	oBrowse1:bLine := {||{aBrowse1[oBrowse1:nAt,01],aBrowse1[oBrowse1:nAt,02],aBrowse1[oBrowse1:nAt,03],;
	aBrowse1[oBrowse1:nAT,04],aBrowse1[oBrowse1:nAT,05],aBrowse1[oBrowse1:nAT,06],;
	aBrowse1[oBrowse1:nAT,07],aBrowse1[oBrowse1:nAT,08],aBrowse1[oBrowse1:nAT,09],;
	aBrowse1[oBrowse1:nAT,10],aBrowse1[oBrowse1:nAT,11],aBrowse1[oBrowse1:nAT,12],;
	aBrowse1[oBrowse1:nAT,13],aBrowse1[oBrowse1:nAT,14],aBrowse1[oBrowse1:nAT,15],;
	aBrowse1[oBrowse1:nAT,16],aBrowse1[oBrowse1:nAT,17],aBrowse1[oBrowse1:nAT,18],;
	aBrowse1[oBrowse1:nAT,19]}}

	oBrowse1:nScrollType := 1
	//oBrowse1:bLDblClick   := {|| Atubr2(aBrowse1[oBrowse1:nAt,02]) }

	oBrowse1:DrawSelect()
	oBrowse1:refresh()
	oDlg:refresh()

return   

//Função de atualização do Browse as OPs geradas de 
//cada item de pre-pedido
Static Function GeraTMP3()  
	Local	_cNumPP := aBrowse1[oBrowse1:nAt,02]
	Local	_cItem  := aBrowse1[oBrowse1:nAt,03]

	cQuery3 := " SELECT * FROM " + RetSQLTab('ZAR')
	cQuery3 += " WHERE " + RetSQLFil('ZAR') + " AND ZAR_PREPED = '" + alltrim(_cNumPP) + "'"
	cQuery3 += " AND ZAR_ITEMPP = '" + _cItem + "'"
	cQuery3 += " AND " + RetSQLDel('ZAR')
	cQuery3 := ChangeQuery(cQuery3)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRY3")<> 0
		QRY3->(dbCloseArea())
	Endif
	TCQUERY cQuery3 NEW ALIAS "QRY3"

	QRY3->(DbGotop())

	// Vetor com elementos do Browse
	aBrowse2 := {}

	While QRY3->(!eof())
		aadd(aBrowse2,{QRY3->ZAR_NUM,;
		QRY3->ZAR_STATUS,;
		dtoc(stod(QRY3->ZAR_DATA)),;
		QRY3->ZAR_COD,;
		QRY3->ZAR_DESC,;
		dtoc(stod(QRY3->ZAR_DTABAT)),;
		transform(QRY3->ZAR_QPPESO,'@E 999,999.99'),;
		transform(QRY3->ZAR_QPCAIX,'@E 999'),;
		transform(QRY3->ZAR_QPUNI,'@E 999,999'),;
		transform(QRY3->ZAR_PRCCLI,'@E 999.99'),;
		QRY3->ZAR_LAYETQ,;
		QRY3->ZAR_LOTE})

		QRY3->(DbSkip())
	enddo

	if len(aBrowse2) = 0
		aadd(aBrowse2,{'','','','','','','','','','','',''})
	endif

	oBrowse2:SetArray(aBrowse2)

	// Monta a linha a ser exibina no Browse
	oBrowse2:bLine := {||{aBrowse2[oBrowse2:nAt,01],aBrowse2[oBrowse2:nAt,02],aBrowse2[oBrowse2:nAt,03],;
	aBrowse2[oBrowse2:nAT,04],aBrowse2[oBrowse2:nAT,05],aBrowse2[oBrowse2:nAT,06],;
	aBrowse2[oBrowse2:nAT,07],aBrowse2[oBrowse2:nAT,08],aBrowse2[oBrowse2:nAT,09],;
	aBrowse2[oBrowse2:nAT,10],aBrowse2[oBrowse2:nAT,11],aBrowse2[oBrowse2:nAT,12]}}

	oBrowse2:nScrollType := 1
	//oBrowse1:bLDblClick   := {|| Atubr2(aBrowse1[oBrowse1:nAt,02]) }

	oBrowse2:DrawSelect()
	oBrowse2:refresh()
	oDlg4:refresh()

return   

//Função que lista as OP geradas do
//item do pre-pedido selecionado
Static Function ListOP()
	DEFINE MSDIALOG oDlg4 TITLE "Pedidos de Venda e Geração de Ordens de Produção" From 0,0 To 150,900 PIXEL

	oBrowse2 := TCBrowse():New(002,002,448,050,,aHeader2,aLargCol2,oDlg4,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	GeraTMP3()

	TButton():New(058,380, "Sair" , oDlg4,{|| oDlg4:end()  } ,60,15,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg4 CENTERED

return

//Função para visualizar informações
//do pedido de venda ao qual o item pertence
Static Function Info()

	Local	_cNumPP := aBrowse1[oBrowse1:nAt,01]
	Local _cMemo  := ''
	Local _oFont := tFont():New("courier new",,-14,,.t.,,,,)

	ZZ3->(DbSetOrder(1))
	ZZ4->(DbSetOrder(2))
	ZZ5->(DbSetOrder(1))

	if ZZ4->(MsSeek(FWxfilial('ZZ4')+_cNumPP))

		if ZZ3->(MsSeek(FWxfilial('ZZ3') + ZZ4->ZZ4_PRECAR))

			_cMemo += 'CARREGAMENTO N.: ' + ZZ3->ZZ3_NUM  + '  ' + ALLTRIM(ZZ3->ZZ3_OBS) +  chr(13) + chr(10)
			_cMemo += 'Placa: ' +  chr(13) + chr(10) 

			if !empty(ZZ3->ZZ3_LOCAR)
				_cMemo += 'Em carregamento doca '+ ZZ3->ZZ3_LOCAR +  chr(13) + chr(10)
			endif
		endif

		_cMemo += 'PEDIDO N.: ' + ZZ4->ZZ4_NUM + '   Cliente: ' + ZZ4->ZZ4_CODCLI + '  Loja: '  + ZZ4->ZZ4_LOJA +  chr(13) + chr(10)
		_cMemo += ZZ4->ZZ4_NOME  +  chr(13) + chr(10)
		_cMemo += 'ITENS: ' +  chr(13) + chr(10)

		ZZ5->(MsSeek(FWxfilial('ZZ5') + _cNumPP))
		while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = FWxfilial('ZZ4') .and. ZZ5->ZZ5_NUM = _cNumPP
			_cMemo += alltrim(ZZ5->ZZ5_COD) + '   ' + alltrim(ZZ5->ZZ5_DESC)
			ZZ5->(DbSkip())
		enddo

		DEFINE DIALOG oDlg5 TITLE "Informações do Pedido de Venda" FROM 180,180 TO 500,750 PIXEL

		_oMemo   := TMultiget():New(005,005,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg5,270,120,_oFont,,,,,.T.,,,,,,.t.)

		//_oBtn1 := TButton():New(235,260, "Sair"    , oDlg5,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )

		ACTIVATE DIALOG oDlg5 CENTERED

	endif

return   

//Função que verifica a possibilidade de carregar na SZ8
Static Function VerSZ8(_cod)
	Local _lRet := .f.

	_cCaixSZ8 := ''

	cQrySZ8 := " SELECT Z8_CONTROL FROM " + RetSQLTab('SZ8')
	cQrySZ8 += " WHERE " + RetSQLFil('SZ8') + " AND Z8_COD = '" + _cod + "' AND Z8_FIL = '" + cFilAnt + "' AND "
	cQrySZ8 += " Z8_DATAS  = '' AND Z8_HORAS = '' AND Z8_PRECAR = '' AND Z8_PREPED = '' AND Z8_ITEM = '' AND " 
	cQrySZ8 += " Z8_LOTEPOR = '' AND  "
	cQrySZ8 +=  RetSQLDel('SZ8')

	cQrySZ8 := ChangeQuery(cQrySZ8)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If Select("QRYSZ8")<> 0
		QRYSZ8->(dbCloseArea())
	Endif
	TCQUERY cQrySZ8 NEW ALIAS "QRYSZ8"

	QRYSZ8->(DbGotop())

	while QRYSZ8->(!eof())
		_cCaixSZ8 += QRYSZ8->Z8_CONTROL + chr(13) + chr(10) 
		QRYSZ8->(DbSkip())
	enddo 

	if !empty(_cCaixSZ8)

		_Mens1 := 'As seguinte caixas de PA encontram-se ' 
		_Mens1 += 'em estoque e disponíveis para carregamento: ' + chr(13) + chr(10)

		_Mens := _Mens1 + _cCaixSZ8

		@ 00,00 To 130,220 Dialog oDlgSZ8 Title "Caixas em estoque:"
		@ 005,005 Get _Mens Size 100,040 MEMO Object oMemo  
		@ 048,010 BUTTON botao1  PROMPT "Segue"  SIZE 40,15 OF oDlgSz8 PIXEL ACTION Eval({||_lRet := .f.,oDlgSZ8:end()})
		@ 048,055 BUTTON botao2 PROMPT "Sair" SIZE 40,15  OF oDlgSz8 PIXEL ACTION Eval({||_lRet := .t.,oDlgSZ8:end()})
		Activate Dialog oDlgSZ8  CENTERED

	endif

return _lRet

//Função que define as cores de status
Static Function RetCores(_Stt)
	Local ret   := iif(_Stt = 'A', LoadBitmap(GetResources(),'br_verde'),;
	iif(_Stt = 'P', LoadBitmap(GetResources(),'br_amarelo'),LoadBitmap(GetResources(),'br_vermelho')))
return  ret

Static Function Legenda()

	aCores:= { {'BR_VERDE'    ,'Aberto'    },;
	{'BR_AMARELO'  ,'Em produção...'},;
	{'BR_VERMELHO' ,'Atendido'}}

	BrwLegenda('OPs. Porcionados','Legenda',aCores)

return   
//Rotina de processamento das quantidades de MP
//por ordem de produção para aglutinação das OPs 
//da embalagem
Static Function BatchMP(_cNumOP, _cMod)
	Local _aRet    := {}
	Local _nQuant  := 0

	ZAR->(DbSetOrder(1))
	if ZAR->(MsSeek(FWxfilial('ZAR') + _cNumOP ))

		if empty(ZAR->ZAR_PREEMB)

			_cCod  := ZAR->ZAR_COD
			_nPeso := ZAR->ZAR_QPPESO
			_cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+_cCod,1)

			//Bloco de teste
			if _cMod = 'T'
				if empty(_cCod)
					alert('OP ' + _cNumOP + ' Com problema no codigo do PA! -1')
					return .f.
				elseif  _nPeso <= 0
					alert('OP ' + _cNumOP + ' Com problema na quantidade do PA! -2')
					return .f.
				elseif empty(_cGrupo)
					alert('OP ' + _cNumOP + ' Com problema no grupo do PA! -3')
					return .f.
				endif
			endif
			//Fim de teste

			//Se for moida providencia a receita
			if (_cGrupo $ _cGrpMoi)

				SG1->(DbSetOrder(6))
				SG1->(DbGoTop())
				if SG1->(MsSeek(FWxfilial('SG1') + padr(_cCod,15,'')+'RM' ))      //padl(alltrim(M->ZZ4_CODCLI),6,'0')

					while SG1->(!eof()) .and. SG1->G1_FILIAL = FWxfilial('SG1') .and. SG1->G1_COD = padr(_cCod,15,'') .and. SG1->G1_TPPORC = 'RM'

						if SG1->G1_TPPORC = 'RM'
							_nQuant := _nPeso * SG1->G1_QUANT

							//So faz o processo abaixo se estiver em modo produção
							if _cMod = 'P'
								_nPos := aScan(_aFinal,{|aVal|aVal[1] = SG1->G1_COMP})

								if _nPos <> 0
									_aFinal[_nPos,2] += _nQuant
									_cGerEmb := _aFinal[_nPos,3]
								else

									_cNumOPD := GetSx8num('SZU','ZU_NUM')
									ConfirmSx8()

									aadd(_aFinal,{SG1->G1_COMP,_nQuant,_cNumOPD})

									_cGerEmb := _cNumOPD

								endif
							endif

						endif
						SG1->(dbSkip())
					enddo

					//So atualiza registro em modo produção
					if _cMod = 'P'
						reclock('ZAR',.f.)
						ZAR->ZAR_CODMP  := 'RECEIT'
						ZAR->ZAR_QTDMP  := _nPeso
						ZAR->ZAR_PREEMB := 'RECEITA'
						msunlock()
					endif
				else
					if _cMod = 'T'
						Alert('OP ' + _cNumOP + ' do produto ' + _cCod + ' com problema na estrutura! -4')
						return .f.
					endif
				endif
			else

				SG1->(DbSetOrder(1))
				SG1->(DbGoTop())
				if SG1->(MsSeek(FWxfilial('SG1') + _cCod))

					_cTipoComp := ''
					_cCodPInt  := ''
					_nPerPInt  := 999
					while SG1->(!eof()) .and. SG1->G1_FILIAL = FWxfilial('SG1') .and. SG1->G1_COD = _cCod

						_cTipoComp := GetAdvFval('SB1','B1_TIPO',FWxfilial('SB1')+SG1->G1_COMP,1)

						if _cTipoComp = 'PP'

							//Achou o código do produto intermediário
							_cCodPInt := GetAdvFval('SB1','B1_COD',FWxfilial('SB1')+SG1->G1_COMP,1)

							//Achou o percentual de perda do produto intermediário
							if SG1->G1_PERDAA <> 0
								_nPerPInt := SG1->G1_PERDAA/100
							else
								_nPerPInt := 0
							endif

							_lAchouPP := .t.

							exit 

						else  

							_lAchouPP := .f. 

						endif

						SG1->(dbSkip())
					enddo   

					if _cMod = 'T'
						if  !_lAchouPP
							alert('PA ' + _cCod + ' Com problema na estrutura! Não encontrou seu PP! -5') 
							return .f. 
						endif
					endif

				else
					if _cMod = 'T'
						alert('PA ' + _cCod + ' Com problema na estrutura! -6')
						return .f.
					endif
				endif

				if _cMod = 'T'
					if _nPerPInt = 999
						alert('PA ' + _cCod + ' Com problema na estrutura! -7')
						return .f.
					endif
				endif
				//Acha a quantidade de produto intermediário a produzir
				_nQtdPInt := _nPeso / (1 - _nPerPInt)

				//Acha o código da matéria-prima
				_cMP    := GetAdvFval('SG1','G1_COMP',FWxfilial('SG1')+_cCodPInt,1)

				//Acha o percentual de perda da matéria-prima
				_nPerMP := GetAdvFval('SG1','G1_PERDAA',FWxfilial('SG1')+_cCodPInt,1)

				if _nPerMP <> 0
					_nPerMP := _nPerMP/100
				else 
					_nPerMP := 0
				endif

				//Acha o total de matéria-prima a ser produzida na desossa
				_nQtdMP := _nQtdPInt / (1 -_nPerMP)

				if _cMod = 'T'
					if _nQtdPInt <= 0
						alert('PA ' + _cCod + ' Com problema na estrutura! -8')
						return .f.
					elseif empty(_cMP)
						alert('PA ' + _cCod + ' Com problema na estrutura! MP não encontrada! -9')
						return .f.
					elseif  empty(_cCodPInt)
						alert('PA ' + _cCod + ' Com problema na estrutura! PP não encontrado! -10')
						return .f.
					endif
				endif

				aadd(_aRet,_cCodPInt)  //codigo produto intermediário
				aadd(_aRet,_nPerPInt)  //percentual quebra produto intermediário
				aadd(_aRet,_nQtdPInt)  //quantidade produto intermediário
				aadd(_aRet,_cMP)       //codigo matéria-prima
				aadd(_aRet,_nPerMP)    //percentual de quebra matéria-prima
				aadd(_aRet,_nQtdMP)    //quantidade final de matéria-prima

				if _cMod = 'P' 
					_nPos := aScan(_aFinal,{|aVal|aVal[1] = _aRet[4]})

					if _nPos <> 0
						_aFinal[_nPos,2] += _aRet[6]
						_cGerEmb := _aFinal[_nPos,3]
					else

						_cNumOPD :=  GetSx8num('SZU','ZU_NUM')
						ConfirmSx8()

						aadd(_aFinal,{_aRet[4],_aRet[6],_cNumOPD})

						_cGerEmb := _cNumOPD

					endif

					reclock('ZAR',.f.)
					ZAR->ZAR_CODPI  := _aRet[1]
					ZAR->ZAR_QTDPI  := _aRet[3]
					ZAR->ZAR_CODMP  := _aRet[4]
					ZAR->ZAR_CODMP2 := u_GF211AL(_aRet[4])
					ZAR->ZAR_QTDMP  := _aRet[6]
					//		ZAR->ZAR_PREEMB := _cGerEmb
					msunlock()

					aadd(_aLotesXOp,{ZAR->ZAR_NUM,_cGerEmb})

				endif

			endif
		endif
	endif

return .t.

//Função para gerar OPs de desossa em batch
Static Function GerOPB()
	Private _aFinal     := {}
	Private _aLotesXOp  := {}

	Private _lRet   := .t.

	cPerg2 := "GJF210b"

	If !Pergunte(cPerg2,.T.)
		RestArea( area )
		Return
	Endif

	if empty(mv_par02) .or. empty(mv_par03) .or. empty(mv_par04)
		alert('Parametros em branco!')
		return
	endif

	Processa({|| _lRet := DefQuant() } ,"DEFININDO QUANTIDADES","Executando calculo de quantidade de Matéria-Prima...")

	if _lRet
		Processa({|| GeraSZU(_aFinal,_aLotesXOp)} ,"OPS PARA DESOSSA","Gerando os lançamentos de Matéria-Prima...")
	endif

	Pergunte(cPerg,.f.) 

	GeraTMP2()

return   

//Define quantidades de MP
Static Function  DefQuant()
	Local _nQuant := len(aBrowse1)
	Local _lOK   := .t.
	Local x
	LOCAL I

	ProcRegua(_nQuant)

	for x := 1 to _nQuant
		_cOPPorc := aBrowse1[x,01]
		IncProc('Teste de integridade na OP ' + _cOPPorc)
		_lOK := BatchMP(_cOPPorc,'T')
		if !_lOK
			exit
		endif
	next 

	if _lOK
		If Aviso("Confirma processamentode OPs para desossa/embalagem?","Verificação de integridade OK!",{"Confirma","Cancela"}) == 1          
			for i := 1 to _nQuant
				_cOPPorc := aBrowse1[i,01]
				IncProc('Processando OP ' + _cOPPorc)
				BatchMP(_cOPPorc,'P')
			next
		endif
	else
		alert('Problema de integridade nas OPs!')
	endif

return  _lOK

//Função para gerar a SZU mediante
//o vetor criado
Static Function GeraSZU(_aOPDess,_aOps)

	Local _nQuant  := len(_aOPDess)
	Local i
	Local j
	ProcRegua(_nQuant)

	for i := 1 to _nQuant

		IncProc('Gerando OP de desossa nr.: ' + _aOPDess[i,3])

		_cDesc   := GetAdvFval('SB1','B1_DESCRED',FWxfilial('SB1') + _aOPDess[i,1],1)
		_nCmp    := GetAdvFval('SB1','B1_PMCAIX',FWxfilial('SB1') + _aOPDess[i,1],1)
		_cCorori := GetAdvFval('SB1','B1_CORORI',FWxfilial('SB1') + _aOPDess[i,1],1)

		_nCaix  := round(_aOPDess[i,2]/_nCmp,0)
		_nCaixP := _nCaix

		SZ2->(DbSetOrder(1))

		_cPredes := ''

		if _cCorori = 'T'
			_cPredes := mv_par02
		elseif _cCorori = 'D'
			_cPredes := mv_par03
		elseif _cCorori = 'T'
			_cPredes := mv_par04
		else
			_cPredes := ''
		endif

		if !empty(_cPredes)   
			SZ2->(DbSetOrder(2))
			if SZ2->(MsSeek(FWxfilial('SZ2') + _cPredes )) 
				_dDataAbt := SZ2->Z2_DATAABT
			else
				_dDataAbt := ctod("")
			endif
		endif       

		reclock('SZU',.t.)
		SZU->ZU_FILIAL   := FWxfilial('SZU')
		SZU->ZU_NUM      := _aOPDess[i,3]
		SZU->ZU_DATA     := ddatabase
		SZU->ZU_DTRPRO   := mv_par01
		SZU->ZU_DTPROD   := mv_par01
		SZU->ZU_COD      := _aOPDess[i,1]
		SZU->ZU_QPCAIX   := _nCaixP
		SZU->ZU_QPPESO   := _aOPDess[i,2]
		SZU->ZU_TIPO     := 'P'
		SZU->ZU_TF       := 'N'
		SZU->ZU_ETIQ     := 'PO'
		SZU->ZU_DESC     := _cDesc
		SZU->ZU_PREPORC  := 'AGLUTINADA'
		SZU->ZU_MPPORC   := 'S'
		SZU->ZU_CONTEXA  := 'S'
		SZU->ZU_FECHADO  := 'B'
		SZU->ZU_PRIORI   := 'P'
		SZU->ZU_NOTIMP   := 'P'
		SZU->ZU_NUMETQ   := 1
		SZU->ZU_PREDES   := _cPredes
		SZU->ZU_USUAR    := cUserName
		msunlock()   

	next

	//Atualiza a ZAR com o numero da OP da embalagem
	for j := 1 to len(_aOps)
		ZAR->(DbSetOrder(1))
		if ZAR->(MsSeek(FWxfilial('ZAR') + _aOps[j,1]))
			_cPredes  := GetAdvFval('SZU','ZU_PREDES',FWxfilial('SZU') + _aOps[j,2],2)
			_dDataAbt := GetAdvFval('SZ2','Z2_DATAABT',FWxfilial('SZ2') + _cPredes,2)
			reclock('ZAR',.f.)
			ZAR->ZAR_PREEMB := _aOps[j,2]
			ZAR->ZAR_DTABAT := _dDataAbt
			msunlock()
		endif
	next

return
