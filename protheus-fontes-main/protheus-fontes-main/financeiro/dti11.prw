#INCLUDE "topconn.ch"  
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch" 
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
±±ºPrograma  ³DTI11     ºAutor  ³Fabian Maurer ?Data ? 09/08/16         º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±ºDesc.     ³Realiza desbloqueio para movimentação comercial e financeiraº±?
±±?         ³dos clientes avaliados junto ao seu cadastro                º±?
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±?
±±?Programador   ?Mauricio Lopes Roehrs				 ?Data ? 11/08/16    ³±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±ºUso       ³Financeiro                                                  º±?
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/

User Function DTI11()
	Local _aArqTrb      := {}
	Private _aTexto 	:= {}
	Private _cTexto 	:= ''
	Private aTela    	:= {}
	Private aStru    	:= {}
	Private aCampos  	:= {}
	Private cArq
	Private cMark    	:= GetMark()  
	Private oMark
	Private marc      := .f.     
	Private lInverte	:= .f.
	Private aButtons  := {} 
	Private _dDtPp    := date()
	Private _lConf    := .f.
	aObjects            := {}
	aPosObj             := {}
	aInfo               := {}
	aSizeAut            := MsAdvSize()

	AAdd( aObjects, { 315, 50, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	Processa({||montabrow()} ,"PROCESSAMENTO DE REGISTROS","montando tela com os clientes...")

	//bloco para ajustar tamanho da tela conforme a resolução do monitor.
	pixTela1:=0
	pixTela2:=0        
	if aSizeAut[6] >= 696
		pixTela1 := aSizeAut[6] - 370
	else
		pixTela1 := aSizeAut[6] - 298
	endif

	if aSizeAut[5] >= 1538 
		pixTela2 := aSizeAut[5] - 780
	else
		pixTela2 := aSizeAut[5] - 655
	endif

	DbSelectArea('TMP')
	TMP->(dbGoTop())
	DEFINE MSDIALOG oDlg TITLE 'Gerenciamento de Desbloqueio de Clientes' from aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	//oMark  := MsSelect():New("TMP","OK","",aCampos,@lInverte,@cMark,{aSizeAut[7],00,pixTela1,pixTela2})  //275
	oMark  := MsSelect():New("TMP","OK","",aCampos,@lInverte,@cMark,{30,00,pixTela1,pixTela2})  //275
	oMark:bMark := {| | Disp()}        

	//@ 010,005 To 220,800 Browse "TMP" fields aCampos object oBrow

	Aadd( aButtons, {"MARCATODOS", {|| MarkAll(1)}  , "Marca Todos", "Marca Todos" , {|| .T.}} )   
	Aadd( aButtons, {"DESMARCTDS", {|| MarkAll(2)}  , "Desmarca Todos", "Desmarca Todos" , {|| .T.}} )   
	Aadd( aButtons, {"DataCarr"  , {|| apontaDtPP()}, "Informa Data Pre-Carr.", "Informa Data Pre-Carr.", {|| .T.}} )   
	Aadd( aButtons, {"BUSCACLI"  , {|| apontaCli()} ,"Busca Cliente", "Busca Cliente" , {|| .T.}} )   


	//oMark:oBrowse:bldBlClick :=  {|| apontaCli()}

	//@aPosObj[2,3]-5,aPosObj[2,1] BUTTON btn01 PROMPT "Salvar" 		   	OF oDlg 	SIZE 40,15 PIXEL ACTION GravCli()
	//@aPosObj[2,3]-5,aPosObj[2,1]+50 BUTTON btn02 PROMPT "Gerar Arquivo" 	OF oDlg  SIZE 40,15 PIXEL ACTION GeraArq()
	//@aPosObj[2,3]-5,aPosObj[2,1]+100 BUTTON btn03 PROMPT "Sair" 			OF oDlg  SIZE 40,15 PIXEL ACTION oDlg:end()

	//ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()},{||oDlg:End()},,@aButtons))

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||verifPP()},{||lOk := .f., oDlg:End()},,@aButtons))

	//ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()})
	//ACTIVATE MSDIALOG oDlg CENTERED

	TMP->(DbCloseArea())

	u_arqtrb ("FechaTodos",,,, @_aArqTrb) 

Return


Static Function markAll(_opc)

	TMP->(dbgotop())   

	while TMP->(!eof())                               
		reclock('TMP',.f.)    
		if _opc = 1//se for 1 marca
			TMP->OK := cMark
		else//senao desmarca           
			TMP->OK := ''
		endif
		msunlock()
		TMP->(dbskip())
	enddo      

	TMP->(dbgotop())   

	oMark:oBrowse:Refresh()

return .t.


Static Function montabrow()

	aadd(aCampos,{"OK"    	,,"OK" 	     			      ,"@!"})
	aadd(aCampos,{"COD" 	   ,,"Codigo"	 					,"@!"  })
	aadd(aCampos,{"NOMECLI"	,,"Nome Cliente"				,"@!"  })
	aadd(aCampos,{"MOTBLQL"	,,"Mot. Bloqueio"    		,"@!"  })
	aadd(aCampos,{"SIMOTBL" ,,"Mot.Blq.Mov."	  			,"@!"  })
	aadd(aCampos,{"POMOTBL" ,,"Mot.Blq.Port."      		,"@!"  })

	/*
	aadd(aStru,{"OK"        , "C",  02,  0,   "@!"         , 'Ok		  		    		  '})
	aadd(aStru,{"COD"  		, "C",  06,  0,   "@!"         , 'Codigo		  				  '})
	aadd(aStru,{"NOMECLI"  	, "C",  40,  0,   "@!"         , 'Nome    					  '})
	aadd(aStru,{"MOTBLQL"   , "C",  40,  0,   "@!"         , 'Mot.Bloqueio     		  '})
	aadd(aStru,{"SIMOTBL"   , "C",  40,  0,   "@!"         , 'Mot.Blq.Mov.				  '})
	aadd(aStru,{"POMOTBL"   , "C",  40,  0,   "@!"         , 'Mot.Bql.Port.				  '})
	*/

	aadd(aStru,{"OK"        , "C",  02,  0})
	aadd(aStru,{"COD"  		, "C",  06,  0})
	aadd(aStru,{"NOMECLI"  	, "C",  40,  0})
	aadd(aStru,{"MOTBLQL"   , "C",  40,  0})
	aadd(aStru,{"SIMOTBL"   , "C",  40,  0})
	aadd(aStru,{"POMOTBL"   , "C",  40,  0})

	//dbcreate(cArq,aStru) 
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	_aArqTrb := {}
	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FECHATODOS",,,, @_aArqTrb)
	Endif
	U_ArqTrb("CRIA", "TMP", aStru, {}, @_aArqTrb)

	filtraCli()

	//TMP->(DbGotop())

	QRY->(dbGoTop())
	Procregua(recCount("QRY"))     
	While QRY->(!eof())

		IncProc('Processando dados do Cliente n.? ' + QRY->A1_COD)
		dbSelectArea('SA1')	
		_cNome  := fBuscaCpo('SA1',1,xFilial('SA1') + alltrim(QRY->A1_COD),'A1_NOME')
		_cMotBl := fBuscaCpo('SA1',1,xFilial('SA1') + alltrim(QRY->A1_COD),'A1_MOTBLQL')
		_cMotSi := fBuscaCpo('SA1',1,xFilial('SA1') + alltrim(QRY->A1_COD),'A1_SIMOTBL')
		_cMotPo := fBuscaCpo('SA1',1,xFilial('SA1') + alltrim(QRY->A1_COD),'A1_POMOTBL')

		DbSelectArea("TMP")
		reclock('TMP',.t.)
		TMP->COD 	 := QRY->A1_COD
		TMP->NOMECLI := substr(_cNome,1,40)
		TMP->MOTBLQL := substr(_cMotBl,1,40)
		TMP->SIMOTBL := substr(_cMotSi,1,40)
		TMP->POMOTBL := substr(_cMotPo,1,40)	
		msunlock()

		QRY->(DbSkip())
	enddo

	TMP->(DbGoTop())

return

//Função que chama a telinha de alteração dos vales-transporte
Static Function apontaCli()
	Local 	_Campo2 := space(6)
	Private  _cCod   := TMP->COD

	DEFINE MSDIALOG oDlg2 TITLE 'Digite o Codigo do Cliente' from 000,000 To 150,200 OF oMainWnd PIXEL

	@ 015,002 SAY  'Cod. Cli' Object oSay1
	@ 001,005 MSGET _Campo2 VAR _cCod SIZE 35,11 VALID Completa() OF oDlg2

	//@ 030,002 SAY  'Valor' Object oSay2
	//@ 002,005 MSGET _Campo1 VAR _nValor SIZE 35,11  PICTURE "@E 999.99"  OF oDlg2


	@ 060,008 BMPBUTTON TYPE 1 ACTION CnfCli() Object Obtn1
	//@ 060,040 BMPBUTTON TYPE 3 ACTION DesVal(_nValor) Object Obtn2
	@ 060,073 BMPBUTTON TYPE 2 ACTION oDlg2:end() Object Obtn3

	ACTIVATE MSDIALOG oDlg2 CENTERED

return


Static Function Completa()

	if !empty(_cCod)
		_cCod  := padl(alltrim(_cCod),6,'0')
	endif

	oDlg2:refresh()
return .t.

Static Function filtraCli()
	//, A1_MOTBLQL, A1_SIMOTBL, A1_POMOTBL
	local _dDtLimite := dDatabase - 90

	_cQuery := " SELECT A1_COD
	_cQuery += " FROM " + retSqlTab("SA1")
	_cQuery += " WHERE " + retSqlFil("SA1")
	_cQuery += " AND (A1_SIBLQL = '1' OR A1_MSBLQL = '1' OR A1_POBLQL = '1')
	_cQuery += " AND A1_ULTCOM <> '' AND A1_ULTCOM >= '" + dtos(_dDtLimite) + "'"
	_cQuery += " AND " + retSqlDel("SA1")                                 
	_cQuery += " GROUP BY A1_COD
	_cQuery += " ORDER BY A1_COD

	MsgRun("Aguarde... Realizando contagem de registros...",,{||  GeraTMP() })

return 


//Função que confirma a inserção do codigo do cliente
Static Function CnfCli()


	TMP->(DbGoTop())
	while TMP->(!eof())	
		if _cCod = TMP->COD
			RecLock("TMP",.F.)
			If !Marked("OK")
				TMP->OK := cMark
			Else
				TMP->OK := ""
			Endif
			msunlock()
			exit
		else
			TMP->(DbSkip())
		endif

	enddo

	//oBrow:oBrowse:refresh()
	oMark:oBrowse:Refresh()
	oDlg:refresh()
	odlg2:end()
return  .t.


Static Function verifPP()

	local _lRet := .f.

	if _lConf
		GravCli()
		_lRet := .t.          
		_lConf := .f.
	else
		alert('Confirme a data do Pre-carregamento!')	
	endif

return _lRet



Static Function GravCli()
	Processa({||Gravar()} ,"PROCESSAMENTO DE REGISTROS","Efetivando a gravação dos Cliente selecionados...")
return

Static Function Gravar()


	TMP->(dbGoTop())
	procRegua(RecCount("TMP"))
	While TMP->(!eof())

		IncProc('Processando dados do Cliente n.? ' + TMP->COD)	
		If !empty(TMP->OK)
			dbSelectArea('SA1')
			SA1->(dbSetOrder(1))
			SA1->(dbGoTop())
			if SA1->(dbSeek(xFilial('SA1') + TMP->COD))
				while xFilial('SA1') == SA1->A1_FILIAL .and. SA1->A1_COD = TMP->COD
					//alert('Vai desbloquear o Cliente:' + SA1->A1_COD)

					reclock('SA1',.f.)
					//Bloqueio movimento
					SA1->A1_SIBLQL  := '2'
					SA1->A1_SIMOTBL := ''
					SA1->A1_SIDTBL  := stod('')
					//Bloqueio do Cliente			 	
					SA1->A1_MSBLQL  := '2'
					SA1->A1_MOTBLQL := ''
					SA1->A1_DTBLQL  := stod('')
					//Bloqueio do Portal			 	
					SA1->A1_POBLQL  := '2'
					SA1->A1_POMOTBL := ''
					SA1->A1_PODTBL  := stod('')															      
					msunlock()			         


					//Libera o pr?pedido				
					buscaPp(TMP->COD)                                
					QRY2->(dbGoTop())
					while QRY2->(!eof())
						dbSelectArea('ZZ4')					
						ZZ4->(dbSetOrder(2))
						ZZ4->(dbGoTop())
						if ZZ4->(dbSeek(xFilial('ZZ4') + QRY2->ZZ4_NUM))
							//alert('achou pre-ped:' + ZZ4->ZZ4_NUM)

							_cLimCre := ZZ4->ZZ4_LIMCRE
							if _cLimCre = 'B'
								_cLimCre  := 'L'
							endif


							reclock('ZZ4',.f.)
							ZZ4->ZZ4_LIMCRE := _cLimCre
							ZZ4->ZZ4_SIBLQL := '2'
							ZZ4->ZZ4_USLIBF := cUserName
							ZZ4->ZZ4_HRULFI := time()
							ZZ4->ZZ4_DTULFI := ddatabase					
							msunlock()

						endif                             
						QRY2->(dbSkip())
					enddo								
					SA1->(dbSkip())
				enddo	
			endif
			reclock('TMP',.f.)	
			TMP->OK := ""			
			msunlock()	
		endif             	
		TMP->(dbSkip())	
	enddo	

	alert('Cliente e Pre-predidos liberados com Sucesso!!')
	oMark:oBrowse:Refresh()
	TMP->(dbGoTop())
return


Static Function GeraTMP()   

	_cQuery  := ChangeQuery(_cQuery)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

return

Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("OK")
		TMP->OK := cMark
	Else
		TMP->OK := ""
	Endif
	msunlock()
	oMark:oBrowse:Refresh()
Return

Static Function buscaPp(_cCli)

	_cQuery2 := " SELECT ZZ4_NUM
	_cQuery2 += " FROM " + retSqlTab("ZZ4") + ", " + retSqlTab('ZZ3')
	_cQuery2 += " WHERE " + retSqlFil("ZZ4") + " AND " + retSqlFil('ZZ3')
	_cQuery2 += " AND ZZ4_CODCLI = '" + _cCli + "'"
	_cQuery2 += " AND ZZ3_NUM = ZZ4_PRECAR
	_cQuery2 += " AND ZZ4_STATUS <> 'F' AND ZZ4_SIBLQL <> '2'
	_cQuery2 += " AND ZZ3_DTCAR = '" + dtos(_dDtPp) + "'"
	_cQuery2 += " AND " + retSqlDel('ZZ4') + " AND " + retSqlDel('ZZ3')
	_cQuery2 += " ORDER BY ZZ4_NUM


	_cQuery2  := ChangeQuery(_cQuery2)

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery2 Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	If Select("QRY2") != 0
		QRY2->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "QRY2"	

return       


//Função que chama a telinha de alteração dos vales-transporte
Static Function apontaDtPP()
	local 	_Campo2    := date()

	DEFINE MSDIALOG oDlg3 TITLE 'Informe a Data do Pre-Carregamento' from 000,000 To 130,200 OF oMainWnd PIXEL

	@ 015,002 SAY  'Dt. Carregamento:' Object oSay1
	@ 001,005 MSGET _Campo2 VAR _dDtPp SIZE 35,11 PICTURE '99/99/99' VALID !Vazio() OF oDlg3

	@ 040,040 BMPBUTTON TYPE 1 ACTION cnfDt() Object Obtn1

	ACTIVATE MSDIALOG oDlg3 CENTERED

return

//Função que confirma a inserção
Static Function CnfDt()

	_lConf := .t.

	odlg3:end()
return
