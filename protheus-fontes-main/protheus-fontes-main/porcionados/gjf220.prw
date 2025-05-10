#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"  
#INCLUDE "XMLXFUN.CH"   
#INCLUDE "TOTVS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF220     º Autor ³ Giuliano Forgiarini Data ³  14/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consumo do WebService _SSHJTQE de integração com as WPLs   º±±
±±º          ³Bizerba                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Giuliano Forgirini                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User function GJF220()  

	odlg := MSDialog():New(10,10,230,720,'Teste WebServices Bizerba',,,,,CLR_BLACK,CLR_WHITE,,,.T.)


	oButton1 := TButton():New(10, 010, "getDataZAU010",                 oDlg, {||u_GF220a()},100,15,,,,.T.)
	oButton2 := TButton():New(10, 120, "version",                       oDlg, {||u_GF220b()},100,15,,,,.T.)
	oButton3 := TButton():New(10, 240, "dbConnectTest",                 oDlg, {||u_GF220c()},100,15,,,,.T.)
	oButton4 := TButton():New(40, 010, "getDataZAU010_LOTEStatus",      oDlg, {||u_GF220d()},100,15,,,,.T.)
	oButton5 := TButton():New(40, 120, "getDataZAU010_QTYProdActive ",  oDlg, {||u_GF220e()},100,15,,,,.T.)
	oButton6 := TButton():New(40, 240, "setDataZAU010_Sample_toDevice", oDlg, {||u_GF220f()},100,15,,,,.T.)
	oButton7 := TButton():New(70, 010, "setDataZAU010_toDevice",        oDlg, {||u_GF220g()},100,15,,,,.T.)
	oButton8 := TButton():New(70, 120, "delDataZAU010",                 oDlg, {||u_GF220h()},100,15,,,,.T.)
	oButton9 := TButton():New(70, 240, "setDevice_Sleep",               oDlg, {||u_GF220i()},100,15,,,,.T.)

	//chama o metodo responsavel por exibir a tela
	odlg:Activate(,,,.T.,,.T.,,)   //ativa a tela

return

//Função para consumo do método getDataZAU010 
//Le registros completos de produçao do DB (ZAU)
//u_GF220a(_linha,_dias,_lote,_flag) 
User Function GF220a()  

	nOpca	:=0
	aSays:={} 
	aButtons:={}

	cCadastro  := "Consumo do metodo getDataZAU010"
	cPerg      := "GF220A"

	AADD (aSays, "  Função para consumo do método getDataZAU010    ")  
	AADD (aSays, "  le registros completos de produçao do DB (ZAU) ")   
	AADD (aSays, "  O campo ZAU_FLWPL: 0 = por enviar, 1 = em produção")
	AADD (aSays, "  2 = em pausa, 3 = finalizado                   ")
	AADD (aSays, "  Dias de produção: 0 (todos)                    ")
	AADD (aSays, "  Lote de produção: 0 (todos)                    ")

	//0 = por enviar --> não trabalharemos
	//2 = em pausa   --> não trabalharemos 

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )

	Pergunte(cPerg,.f.)

	_cLote := iif(empty(mv_par03),'0', mv_par03 )
	_nFlag := iif(mv_par04 = 1,0, iif(mv_par04 = 2,1,iif(mv_par04 = 3,2,3)))

	//GF220a(_nlinha,_ndias,_clote,_nflag)
	If nopca == 1    
		Met01(iif(mv_par01 = 5,0,mv_par01),mv_par02,_cLote,_nFlag)
	endif

return

Static Function Met01(_nlinha,_ndias,_clote,_nflag)

	Local oXML 
	Local _cTipo := ''
	Local _aRet := {}
	Local i
	
	BEGIN SEQUENCE

		//O campo ZAU_FLWPL: 0 = por enviar, 1 = em produção, 2 = em pausa, 3 = finalizado
		// O withSchema é um opcional tecnico para o integrador     

		_oWS := WSbizFSWebService():New()
		_oWS:nZAU_FILIAL := 1
		_oWS:nZAU_LINHA  := _nlinha  //N
		_oWS:nDIAS       :=  _ndias   //N
		_oWS:cZAU_NUM    := _clote   //C
		_oWS:nZAU_FLWPL  := -1//_nflag   //N
		_oWS:nwithSchema := 0
		_oWS:getDataZAU010() 

		oXML := _oWS:oWSgetDataZAU010Result 

		oTipo := XmlGetChild(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, 2 )

		if mv_par05 = 1
			_cMemo := varinfo('oXML',oTipo)
			@ 116,090 To 416,707 Dialog oDlgMemo Title "Conteúdo da variável"
			@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
			Activate Dialog oDlgMemo
		endif

		_cTipo := valtype(oTipo)

		if _cTipo <> "U"
			if _cTipo == "O"
				XmlNode2Arr( oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT:_ERP_ZAU010_FILTER, "_ERP_ZAU010_FILTER" )
			endif

			oXML := XmlChildEx(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, "_ERP_ZAU010_FILTER")

			for i := 1 to len(oXML)
				aadd(_aRet,{oXML[i]:_SID:Text,       oXML[i]:_ZAU_FILIAL:Text, oXML[i]:_ZAU_NUM:Text,   oXML[i]:_ZAU_DTPROD:Text, oXML[i]:_ZAU_COD:Text,   oXML[i]:_ZAU_PLU:Text,;
				oXML[i]:_ZAU_LINHA:Text, oXML[i]:_ZAU_STATUS:Text, oXML[i]:_ZAU_PRCCLI:Text,oXML[i]:_ZAU_QPPESO:Text, oXML[i]:_ZAU_QRPESO:Text,oXML[i]:_ZAU_QPUNI:Text,;
				oXML[i]:_ZAU_QRUNI:Text, oXML[i]:_ZAU_QPCAIX:Text, oXML[i]:_ZAU_QRCAIX:Text,oXML[i]:_ZAU_TARA:Text,   oXML[i]:_ZAU_IMCBAR:Text,oXML[i]:_ZAU_PESBAN:Text,;
				oXML[i]:_ZAU_CODCLI:Text,oXML[i]:_ZAU_TIPSER:Text, oXML[i]:_ZAU_IMPROD:Text,oXML[i]:_ZAU_IMLOTE:Text, oXML[i]:_ZAU_IMTARA:Text,oXML[i]:_ZAU_IMVAL:Text,;
				oXML[i]:_ZAU_IMPRC:Text, oXML[i]:_ZAU_IMPCOM:Text, oXML[i]:_ZAU_LAYETQ:Text,oXML[i]:_ZAU_FLERP:Text,  oXML[i]:_ZAU_FLWPL:Text, oXML[i]:_ZAU_IMPRC:Text,;
				oXML[i]:_ZAU_PORCI1:Text, oXML[i]:_ZAU_PORCI2:Text, oXML[i]:_ZAU_PORCI3:Text,oXML[i]:_ZAU_PORCI4:Text,  oXML[i]:_ZAU_PORCI5:Text,  oXML[i]:_ZAU_TARAT:Text,;
				oXML[i]:_ZAU_TARAS:Text,  oXML[i]:_ZAU_OP:Text,  oXML[i]:_ZAU_RASTRE:Text,oXML[i]:_ZAU_ITARAB:Text, oXML[i]:_ZAU_IPEFIX:Text, oXML[i]:_ZAU_PBFIXO:Text,  oXML[i]:_ModifiedDate:Text})
			next
		endif

		_cMemo := ''

		for i := 1 to len(_aRet)
			_cMemo += _aRet[i,3] + '-' + _aRet[i,8] + '-' + _aRet[i,29] + chr(13) + chr(10)

		next

		@ 116,090 To 416,707 Dialog oDlgMemo Title "Retorno"
		@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
		Activate Dialog oDlgMemo

	END SEQUENCE

Return _aRet


//Função para consumo do método version() que traz a informação da versão do WebService
//Traz informações completas da versão do WebService
User Function GF220b()
	Local oXML 
	Local _aRet := {}
	Local i

	BEGIN SEQUENCE

		_oWS := WSbizFSWebService():New()
		_oWS:version() 

		oXML := _oWS:oWSVersionResult

		_aRet := oXML:cString

		_cMemo := ''

		for i := 1 to len(_aRet)  
			_cMemo +=  _aRet[i]  + chr(13) + chr(10)  
		next

		@ 116,090 To 416,707 Dialog oDlgMemo Title "Retorno"
		@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
		Activate Dialog oDlgMemo

	END SEQUENCE

Return _aRet

//Função para consumo do método dbConnectTest
//Faz teste com status de ligação ao SQL Server
User Function GF220c() 

	nOpca	:=0
	aSays:={} 
	aButtons:={}

	cCadastro  := "Consumo do metodo dbConnectionTest"
	cPerg      := "GF220C"

	AADD (aSays, "  Função para consumo do método dbConnectionTest ")  

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )

	Pergunte(cPerg,.f.)

	If nopca == 1    
		Met03()
	endif

return

Static Function Met03()

	Local oXML 
	Local _aRet := {}
	Local i
	
	BEGIN SEQUENCE

		_oWS := WSbizFSWebService():New()
		_oWS:dbConnectionTest() 

		oXML := _oWS:oWSdbConnectionTestResult

		if mv_par01 = 1
			_cMemo := varinfo('oXML',oXML)
			@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
			Activate Dialog oDlgMemo
		endif

		_aRet := oXML:cString

	END SEQUENCE

	_cMemo := ''

	for i := 1 to len(_aRet)  
		_cMemo +=  _aRet[i]  + chr(13) + chr(10)  
	next

	@ 116,090 To 416,707 Dialog oDlgMemo Title "Retorno"
	@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
	Activate Dialog oDlgMemo

	alert(oXML:CSTRING[1])

Return _aRet


//Função para consumo do método getDataZAU010_LOTEStatus 
//Le registros de produção (ZAU) da DB com parametros do LoteStatus
User Function GF220d() 
	nOpca	:=0
	aSays:={} 
	aButtons:={}

	cCadastro  := "Consumo do metodo getDataZAU010_LOTEStatus"
	cPerg      := "GF220D"

	AADD (aSays, "  Função para consumo do método getDataZAU010_LOTEStatus ")  
	AADD (aSays, "  le registros de produção (ZAU010) do DB com parametro do LoteStatus")   
	AADD (aSays, "  O campo ZAU_STATUS: A=Aberto, R=Processo, S=Parado, E=Encerrado")

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )

	Pergunte(cPerg,.f.)

	_status := iif(mv_par01 = 1, 'A', iif(mv_par01 = 2, 'R', iif(mv_par01 = 3, 'S','E')))

	If nopca == 1    
		Met04(_status)
	endif

return

Static Function Met04(_status)
	Local oXML 
	Local _cTipo := ''
	Local _aRet := {}
	Local i
	Local j

	BEGIN SEQUENCE

		// O withSchema é um opcional tecnico para o integrador
		//O camop ZAU_STATUS: A=Aberto, R=Processo, S=Parado, E=Encerrado
		_oWS := WSbizFSWebService():New()
		_oWS:nZAU_FILIAL := 0
		_oWS:cZAU_STATUS := _status  //C
		_oWS:nwithSchema := 0
		_oWS:getDataZAU010_LOTEStatus() 

		oXML := _oWS:oWSgetDataZAU010_LOTEStatusResult

		if mv_par02 = 1
			_cMemo := varinfo('oXML',oXML)
			@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
			Activate Dialog oDlgMemo
		endif


		oTipo := XmlGetChild(oXML:_GETDATAZAU010_LOTESTATUSRESULT:_DOCUMENTELEMENT, 2 )  


		_cTipo := valtype(oTipo)

		if _cTipo <> "U"
			if _cTipo == "O"
				XmlNode2Arr( oXML:_GETDATAZAU010_LOTESTATUSRESULT:_DOCUMENTELEMENT:_ERP_ZAU010_STATUS, "_ERP_ZAU010_STATUS" )
			endif

			oXML := XmlChildEx(oXML:_GETDATAZAU010_LOTESTATUSRESULT:_DOCUMENTELEMENT, "_ERP_ZAU010_STATUS")

			for i := 1 to len(oXML)
				aadd(_aRet,{oXML[i]:_ZAU_DTPROD:TEXT, oXML[i]:_ZAU_FILIAL:TEXT, oXML[i]:_ZAU_IMPROD:TEXT, oXML[i]:_ZAU_LINHA:TEXT, oXML[i]:_ZAU_NUM:TEXT,;
				oXML[i]:_ZAU_PLU:TEXT,    oXML[i]:_ZAU_PRCCLI:TEXT, oXML[i]:_ZAU_QPCAIX:TEXT, oXML[i]:_ZAU_QPPESO:TEXT, oXML[i]:_ZAU_QPUNI:TEXT,;
				oXML[i]:_ZAU_QRCAIX:TEXT, oXML[i]:_ZAU_QRPESO:TEXT, oXML[i]:_ZAU_QRUNI:TEXT,  oXML[i]:_ZAU_STATUS:TEXT})
			next      

			_cMemo := ''

			for i := 1 to len(_aRet)
				for j := 1 to 14
					_cMemo += _aRet[i,j] + '-'
				next    

				_cMemo += chr(13) + chr(10)
			next

			@ 116,090 To 416,707 Dialog oDlgMemo Title "Retorno"
			@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
			Activate Dialog oDlgMemo

		else
			msgbox('Falha na operação de apontamento!','METODO NAO CONSUMIDO!','ERRO')	
		endif

	END SEQUENCE

Return _aRet


//Função para consumo do método getDataZAU010_QTYProdActive 
//Le quantidades de registros ativos em produção (ZAU)


User Function GF220e()
	nOpca	:=0
	aSays:={} 
	aButtons:={}

	cCadastro  := "Consumo  método getDataZAU010_QTYProdActive"
	cPerg      := "GF220E"

	AADD (aSays, "  Função para consumo do método getDataZAU010_QTYProdActive ")  
	AADD (aSays, " Le quantidades de registros ativos em produção (ZAU) ")  
	AADD (aSays, "  Retorna apenas quantidades dos registros ZAU_FLERP=1.")  
	AADD (aSays, " Bom utilizar em monitorização da produção da linha,")     
	AADD (aSays, " uma vez que não necessita passar parametros e tem a produção ativa")     

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )

	Pergunte(cPerg,.f.)

	If nopca == 1    
		Met05()
	endif

return


Static Function Met05()

	Local oXML 
	Local _cTipo := ''
	Local _aRet := {}
	Local i
	Local j

	BEGIN SEQUENCE


		_oWS := WSbizFSWebService():New()
		_oWS:nZAU_FILIAL := 1
		_oWS:nwithSchema := 0
		_oWS:getDataZAU010_QTYProdActive() 

		oXML := _oWS:oWSgetDataZAU010_QTYProdActiveResult

		if mv_par01 = 1 
			_cMemo := varinfo('oXML',oXML)
			@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
			Activate Dialog oDlgMemo
		endif

		oTipo := XmlGetChild(oXML:_GETDATAZAU010_QTYPRODACTIVERESULT:_DOCUMENTELEMENT,2)

		_cTipo := valtype(oTipo)

		if _cTipo <> "U"
			if _cTipo == "O"
				XmlNode2Arr(oXML:_GETDATAZAU010_QTYPRODACTIVERESULT:_DOCUMENTELEMENT:_ERP_ZAU010_QTYPROD, "_ERP_ZAU010_QTYPROD" )
			endif

			oXML := XmlChildEx(oXML:_GETDATAZAU010_QTYPRODACTIVERESULT:_DOCUMENTELEMENT, "_ERP_ZAU010_QTYPROD")

			for i := 1 to len(oXML)
				aadd(_aRet,{oXML[i]:_ModifiedDate:Text, oXML[i]:_ZAU_FILIAL:Text, oXML[i]:_ZAU_LINHA:Text,;
				oXML[i]:_ZAU_NUM:Text,      oXML[i]:_ZAU_PLU:Text,    oXML[i]:_ZAU_QRCAIX:Text,;
				oXML[i]:_ZAU_QRPESO:Text,   oXML[i]:_ZAU_QRUNI:Text})
			next
		endif

	END SEQUENCE

	_cMemo := ''

	for i := 1 to len(_aRet)
		for j := 1 to 8
			_cMemo += _aRet[i,j] + '-'
		next    

		_cMemo += chr(13) + chr(10)
	next

	@ 116,090 To 416,707 Dialog oDlgMemo Title "Retorno"
	@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
	Activate Dialog oDlgMemo

Return _aRet



User Function GF220f() 
	nOpca	:=0
	aSays:={} 
	aButtons:={}

	cCadastro  := "Consumo  método setDataZAU010_Sample_toDevice"
	cPerg      := "GF220F"

	AADD (aSays, "  Função para consumo do método setDataZAU010_Sample_toDevice ")  
	AADD (aSays, " Serve para fazer testes sem utilizar integração. ")   
	AADD (aSays, " Pode fazer direto pelo IE porque não vai utilizar a entidade (struct) completa de dados. ")  
	AADD (aSays, " Codigo ZAU_CODCLI (codigo do cliente) é opcional. Enviar 0. ")  
	AADD (aSays, " O layout da etiqueta deverá pre-existir. ")  
	AADD (aSays, " A funcionalidade do campo MemoryTest: Utilizar 0 (false) será o processo normal. ")   
	AADD (aSays, " No entanto pode enviar dados diretos na memoria do equipamento,  ")  
	AADD (aSays, " exemplo: alterar a tara, ou uma descrição obrigar a interromper o ")  
	AADD (aSays, " processo de etiquetagem, ou carregar novamente o PLU. ")  
	AADD (aSays, " O campo UpdateDataMain: Não deveria estar no metodo, pertence ao setDataZAU010_toDevice. ")  


	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	oWnd := FormBatch( cCadastro, aSays, aButtons )

	Pergunte(cPerg,.f.)

	If nopca == 1    
		Met06()   
	endif

return

Static function Met06()   
	Local oXML 
	Local _aRet := {}

	ZAU->(DbSetOrder(1))
	if ZAU->(DbSeek(xfilial('ZAU') + mv_par02))              

		_DeviceID    := mv_par01
		_Num         := ZAU->ZAU_NUM
		_Cod         := ZAU->ZAU_COD
		_PLU         := ZAU->ZAU_COD
		_Codcli      := '0'
		_QpUni       := ZAU->ZAU_QPUNI
		_QpCaix      := ZAU->ZAU_QPCAIX
		_LayEtq      := val(ZAU->ZAU_LAYETQ)

		_Gramatura   := ZAU->ZAU_GRMATU
		_Gordura     := ZAU->ZAU_GORDUR
		_ProcRot     := ZAU->ZAU_PROCRO
		_Ingrediente := ZAU->ZAU_INGRED
		_Porc01      := ZAU->ZAU_PORCI1
		_Porc02      := ZAU->ZAU_PORCI2
		_Porc03      := ZAU->ZAU_PORCI3
		_Porc04      := ZAU->ZAU_PORCI4
		_Porc05      := ZAU->ZAU_PORCI5

		_MemoryText  := 0
		//	_UpdateDB   := 

		BEGIN SEQUENCE

			_oWS := WSbizFSWebService():New()
			_oWS:nDeviceID    := _DeviceID
			_oWS:cZAU_NUM     := _Num
			_oWS:cZAU_COD     := _Cod
			_oWS:cZAU_PLU     := _PLU
			_oWS:cZAU_CODCLI  := _CodCli
			_oWS:nZAU_QPUNI   := _QpUni
			_oWS:nZAU_QPCAIX  := _QpCaix
			_oWS:nZAU_LAYETQ  := _layEtq

			_oWS:nZAU_GRMATU := _Gramatura
			_oWS:nZAU_GORDUR := _Gordura
			_oWS:nZAU_PROCRO := _ProcRot
			_oWS:nZAU_INGRED := _Ingrediente
			_oWS:nZAU_PORCI1 := _Porc01
			_oWS:nZAU_PORCI2 := _Porc02
			_oWS:nZAU_PORCI3 := _Porc03
			_oWS:nZAU_PORCI4 := _Porc04
			_oWS:nZAU_PORCI5 := _Porc05
		
			_oWS:nMemoryText     := _MemoryText
			_oWS:nUpdateDataMain := 0
			_oWS:setDataZAU010_Sample_toDevice() 

			oXML := _oWS:oWSsetDataZAU010_Sample_toDeviceResult

			if mv_par03 = 1	
				_cMemo := varinfo('oXML',oXML)
				@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
				@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
				Activate Dialog oDlgMemo
			endif

		END SEQUENCE

	endif

Return _aRet


//Função para consumo do método setDataZAU010_toDevice
//Cria registros de produção na (ZAU)
User Function gf220g() 
	nOpca	:=0
	aSays:={} 
	aButtons:={}

	cCadastro  := "Consumo consumo do método setDataZAU010_toDevice"
	cPerg      := "GF220G"

	AADD (aSays, "  Função para consumo do método setDataZAU010_toDevice ")  
	AADD (aSays, " Cria registros de produção na (ZAU) ")   
	AADD (aSays, " Tipo Serviço: 0 = balança (peso variavel) ")  
	AADD (aSays, " Tipo Serviço: 1 = preço fixo ")
	AADD (aSays, " Tipo Serviço: 2 = peso fixo ")

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	oWnd := FormBatch( cCadastro, aSays, aButtons )

	Pergunte(cPerg,.f.)

	If nopca == 1    
		Met07()   
	endif


return


Static Function Met07()
	Local oXML 
	Local _aRet := {} 
	Local _lResult := .f.

	//UpdateDataMain  = Utilizar 0=false ou 1=true
	//Efetua atualização no banco de dados Datamaintenance.Brain, permite criar os PLU dinamicamente. 

	ZAU->(DbSetOrder(1))
	if ZAU->(DbSeek(xfilial('ZAU') + mv_par02))      

		BEGIN SEQUENCE

			_DeviceID   := mv_par01
			_Num        := ZAU->ZAU_NUM
			_Cod        := ZAU->ZAU_COD
			_PLU        := ZAU->ZAU_COD
			_Codcli     := ''
			_QpUni      := ZAU->ZAU_QPUNI
			_QpCaix     := ZAU->ZAU_QPCAIX
			_LayEtq     := val(ZAU->ZAU_LAYETQ)
			_MemoryText := 0

			_oWS := WSbizFSWebService():New()  


			//		_cMemo := varinfo('oXML',_oWS)
			//		@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			//		@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
			//		Activate Dialog oDlgMemo      

			_cMemo  := '' 
			_cImVal  := alltrim(substr(strtran(ZAU->ZAU_IMVAL,'/',''),1,4) + substr(strtran(ZAU->ZAU_IMVAL,'/',''),5,2))
			_cDtProd := alltrim(substr(strtran(dtoc(ZAU->ZAU_DTPROD),'/',''),1,4) + '20'+substr(strtran(dtoc(ZAU->ZAU_DTPROD),'/',''),5,2))
			IF (!_DeviceID = 4 .AND. !_DeviceID = 6)	
				_cTara   := alltrim(strtran(str(ZAU->ZAU_TARA),',','.'))
			ELSE				
				_cTara   := alltrim(strtran(str(ZAU->ZAU_TARAT),',','.'))
			ENDIF
			_cTaraS   := alltrim(strtran(str(ZAU->ZAU_TARAS),',','.'))
			_cTaraT   := alltrim(strtran(str(ZAU->ZAU_TARAT),',','.'))
			_cPrcCli := alltrim(strtran(str(ZAU->ZAU_PRCCLI),',','.'))

			_oWS:oWSsendData:nDeviceID       := _DeviceID   
			_oWS:oWSsendData:cZAU_FILIAL     := '1' 
			_oWS:oWSsendData:cZAU_NUM        := _Num 
			_oWS:oWSsendData:cZAU_DTPROD     := _cDtProd 
			_oWS:oWSsendData:cZAU_COD        := _Cod     
			_oWS:oWSsendData:cZAU_PLU        := _PLU   
			_oWS:oWSsendData:cZAU_LINHA      := alltrim(str(_DeviceID))//Aqui a linha deverá ser sempre igual ao device  - CUIDAR!!!!!!
			_oWS:oWSsendData:cZAU_STATUS     := 'A'
			_oWS:oWSsendData:cZAU_PRCCLI     := _cPrcCli
			_oWS:oWSsendData:cZAU_QPPESO     := str(ZAU->ZAU_QPPESO)
			_oWS:oWSsendData:cZAU_QRPESO     := '0'
			_oWS:oWSsendData:cZAU_QPUNI      := str(ZAU->ZAU_QPUNI)
			_oWS:oWSsendData:cZAU_QRUNI      := '0'                      
			_oWS:oWSsendData:cZAU_QPCAIX     := str(ZAU->ZAU_QPCAIX)      
			_oWS:oWSsendData:cZAU_QRCAIX     := '0'
			_oWS:oWSsendData:cZAU_TARA       := _cTara
			_oWS:oWSsendData:cZAU_IMCBAR     := ZAU->ZAU_IMCBAR
			_oWS:oWSsendData:cZAU_PESBAN     := str(ZAU->ZAU_PESBAN)
			_oWS:oWSsendData:cZAU_CODCLI     := '0'
			_oWS:oWSsendData:cZAU_TIPSER     := str(iif(mv_par05 = 1,0,iif(mv_par05 = 2,1,2)) )
			_oWS:oWSsendData:cZAU_IMLOTE     := ZAU->ZAU_IMLOTE
			_oWS:oWSsendData:cZAU_IMPROD     := ZAU->ZAU_IMPROD
			_oWS:oWSsendData:cZAU_IMTARA     := _cTara
			_oWS:oWSsendData:cZAU_IMVAL      := ZAU->ZAU_IMVAL
			_oWS:oWSsendData:cZAU_IMPRC      := _cPrcCli
			_oWS:oWSsendData:cZAU_IMPCOM     := ZAU->ZAU_IMPCOM
			_oWS:oWSsendData:cZAU_LAYETQ     := ZAU->ZAU_LAYETQ
			_oWS:oWSsendData:cZAU_FLERP      := '0'  //0 = nãoa enviado   1 = já enviado
			_oWS:oWSsendData:cZAU_FLWPL      := '0'
			_oWS:oWSsendData:cZAU_ADD0       := ZAU->ZAU_PORCI1
			_oWS:oWSsendData:cZAU_ADD1       := ZAU->ZAU_PORCI2
			_oWS:oWSsendData:cZAU_ADD2       := ZAU->ZAU_PORCI3
			_oWS:oWSsendData:cZAU_ADD3       := ZAU->ZAU_PORCI4
			_oWS:oWSsendData:cZAU_ADD4       := ZAU->ZAU_PORCI5
			_oWS:oWSsendData:cZAU_TX4        := ZAU->ZAU_ITARAT
			_oWS:oWSsendData:cZAU_TX5        := ZAU->ZAU_ITARAS
			_oWS:oWSsendData:cZAU_TX6        := ZAU->ZAU_RASTRE
			_oWS:oWSsendData:cZAU_TX7        := ZAU->ZAU_ITARAB
			_oWS:oWSsendData:cZAU_TX8        := ZAU->ZAU_IPEFIX
			_oWS:oWSsendData:cZAU_TX9        := ZAU->ZAU_PBFIXO
			/*			
			_oWS:oWSsendData:cZAU_TX10       := 
			_oWS:oWSsendData:cZAU_TX11       := 
			_oWS:oWSsendData:cZAU_TX12       := 
			_oWS:oWSsendData:cZAU_TX13       := 
			_oWS:oWSsendData:cZAU_TX14       := 
			_oWS:oWSsendData:cZAU_TX15       := 
			_oWS:oWSsendData:cZAU_TX16       := 
			_oWS:oWSsendData:cZAU_TX17       := 
			_oWS:oWSsendData:cZAU_TX18       := 
			_oWS:oWSsendData:cZAU_TX19       := 
			_oWS:oWSsendData:cZAU_TX20       := 
			*/
			_oWS:nUpdateDataMain             := 1

			_oWS:setDataZAU010_toDevice()

			oXML := _oWS:oWSsetDataZAU010_toDeviceResult

		END SEQUENCE   

	endif

	if mv_par03 = 1	
		_cMemo := varinfo('oXML',oXML)
		@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
		@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
		Activate Dialog oDlgMemo
	endif

	//	_Teste1 := XmlNode2Arr( _oWS:OWSRESULT, "OWSRESULT" )  
	_ValRet := valtype(oXML)   

	if _ValRet = 'U'
		msgbox('Falha na operação de apontamento!','METODO NAO CONSUMIDO!','ERRO')
	else
		_lResult := oXML:OWSRESULT:OWSRESULT[1]:LRESULT 
		if _lResult
			msgbox('Operação de apontamento realizada com sucesso!','METODO CONSUMIDO!','INFO') 
		else
			msgbox('Falha na operação de apontamento!','METODO NAO CONSUMIDO!','ERRO')		
		endif
	endif


return



//Função para consumo do método delDataZAU010
//Apaga registros de produção (ZAU) da DB com parametros do Lote
User Function GF220h() 
	nOpca	:=0
	aSays:={} 
	aButtons:={}

	cCadastro  := "Consumo do metodo delDataZAU010"
	cPerg      := "GF220H"

	AADD (aSays, "  Função para consumo do método delDataZAU010 ")  
	AADD (aSays, "  Para isso ele não poderá ter quantidade produzida")   

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )

	Pergunte(cPerg,.f.)

	If nopca == 1    
		Met08()
	endif

return

Static Function Met08()
	Local oXML 
	Local _lResult := .f.
	Local _aRet := {}


	ZAU->(DbSetOrder(1))
	if ZAU->(DbSeek(xfilial('ZAU')+mv_par01))

		BEGIN SEQUENCE

			_oWS := WSbizFSWebService():New()
			_oWS:nZAU_FILIAL := 1
			_oWS:cZAU_NUM    := mv_par01

			_oWS:delDataZAU010() 

			oXML := _oWS:oWSdelDataZAU010Result

			if mv_par02 = 1
				_cMemo := varinfo('oXML',oXML)
				@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
				@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
				Activate Dialog oDlgMemo
			endif

			_lResult := oXML:OWSRESULT:OWSRESULT[1]:LRESULT 

			if _lResult
				msgbox('Lote excluido do BD com sucesso!','METODO CONSUMIDO!','INFO')		
			else
				msgbox('Falha ao tentar excluir o lote do BD!','METODO NAO CONSUMIDO!','ERRO')		
			endif

		END SEQUENCE  


	else
		msgbox('Lote não encontrado!','METODO NAO CONSUMIDO!','ERRO')	
	endif

Return _aRet



//Função para consumo do método setDevice_Sleep 
//Bota a máquina indicada para dormir ou acordar
User Function GF220i() 
	nOpca	:=0
	aSays:={} 
	aButtons:={}

	cCadastro  := "Consumo do metodo setDevice_Sleep"
	cPerg      := "GF220I"

	AADD (aSays, "  Função para consumo do método setDevice_Sleep ")  
	AADD (aSays, "  Bota a máquina indicada para dormir ou acordar")   

	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
	FormBatch( cCadastro, aSays, aButtons )

	Pergunte(cPerg,.f.)

	If nopca == 1    
		Met09()
	endif

return

Static Function Met09()
	Local oXML 
	Local _cTipo := ''


	BEGIN SEQUENCE

		// O withSchema é um opcional tecnico para o integrador
		//O camop ZAU_STATUS: A=Aberto, R=Processo, S=Parado, E=Encerrado
		_oWS := WSbizFSWebService():New()
		_oWS:ndeviceID := mv_par01  
		_oWS:setDevice_Sleep() 

		_lStatus := _oWS:lsetDevice_SleepResult

		if mv_par02 = 1
			_cMemo := varinfo('oXML',oXML)
			@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
			@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
			Activate Dialog oDlgMemo
		endif

		alert(_lStatus) 

		if _lStatus
			msgbox('Maquina de número ' + strzero(mv_par01,2) + ' com produção ativada!','METODO CONSUMIDO!','INFO')
		else
			msgbox('Maquina de número ' + strzero(mv_par01,2) + ' com produção em repouso!','METODO CONSUMIDO!','INFO')
		endif

	END SEQUENCE

Return _lStatus

/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funções para integração ERP/WPL via consumo do WebService da Bizerba a serem usadas em outras rotinas do controle de produção.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC*/

//Interface para visualizar metodos:
Static Function IntWPL(_cMemo)

	@ 00,00 To 140,320 Dialog oDlgMemo Title "Status Transmissão WPL:"
	@ 005,005 Get _cMemo Size 150,045 MEMO Object oMemo      
	@ 055,045 BUTTON botao1 PROMPT "Fechar" OF oDlgMemo PIXEL ACTION oDlgMemo:end()
	Activate Dialog oDlgMemo  CENTERED

return

// Função que irá consumir os metodos:
// -> dbConnectionTest (testa a conexão)
// -> getDataZAU010 (pesquisa o lote para ver sua situação no BD Bizerba)
// -> setDataZAU010_toDevice (envia a produção)   
// Apontar a produção na linha/maquina indicada.
User function WBiz01(_cLote,_nDevice)
	Local _lMet01       := .t.
	Local _lMet02       := .t.
	Local _lMet03       := .t.
	Local _lRet         := .f. 
	Local _cRetLoteWpl  := ''
	Local _cRetStatWpl  := ''
	Local _cRetFlWpl    := ''   
	Local _cStatERP     := ''
	Local _cRetMemo     := ''
	Local i

	BEGIN SEQUENCE

		_oWS := WSbizFSWebService():New()  

		//Método DbConnectTest
		_oWS:dbConnectionTest() 

		oXML := _oWS:oWSdbConnectionTestResult


		if oXML:CSTRING[1] = 'True'

			_cRetMemo += 'Teste de Conexão:... OK!' + chr(13) + chr(10)

			_cRetMemo += 'Lote:...'+ ZAU->ZAU_NUM + chr(13) + chr(10)	
			ZAU->(DbSetOrder(1))
			if ZAU->(DbSeek(xfilial('ZAU') + _cLote))

				//Método getDataZAU010
				_oWS:nZAU_FILIAL := 1
				_oWS:nZAU_LINHA  := _nDevice //1 = Linhas 001 e 002, 2 = Linhas 003 e 004
				_oWS:nDIAS       :=  0       //0 = Todos
				_oWS:cZAU_NUM    := _clote   //C
				_oWS:nZAU_FLWPL  := -1       //-1 = Todos
				_oWS:nwithSchema := 0
				_oWS:getDataZAU010()

				oXML := _oWS:oWSgetDataZAU010Result

				oTipo := XmlGetChild(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, 2 )
				_cTipo := valtype(oTipo)

				if _cTipo <> "U"
					if _cTipo == "O"
						XmlNode2Arr( oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT:_ERP_ZAU010_FILTER, "_ERP_ZAU010_FILTER" )
					endif

					oXML := XmlChildEx(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, "_ERP_ZAU010_FILTER")
					for i := 1 to len(oXML)
						_cRetLoteWpl  := oXML[i]:_ZAU_NUM:Text
						_cRetStatWpl  := oXML[i]:_ZAU_STATUS:Text
						_cRetFlWpl    := oXML[i]:_ZAU_FLWPL:Text
					next
				endif


				//ZAU_FLWPL: 0 = Stand By, 1 = em produção, 2 = em pausa, 3 = finalizado

				_cStatWPL := iif(ZAU->ZAU_FLWPL = 0,'Stand By',iif(ZAU->ZAU_FLWPL = 1,'Em produção',iif(ZAU->ZAU_FLWPL = 2, 'Parado','Finalizado')))
				_cStatERP := iif(ZAU->ZAU_STATW = 'A','Stand By',iif(ZAU->ZAU_STATW = 'S','Parado',iif(ZAU->ZAU_STATW = 'R','Em Produção','Finalizado')))

				_cRetMemo += 'Status da Flag WPL no ERP:... ' + _cStatWPL + chr(13) + chr(10)	
				_cRetMemo += 'Status do lote no ERP:... ' + _cStatERP + chr(13) + chr(10)	

				if empty(_cRetLoteWpl)
					_cRetMemo += 'Status do lote na WPL:... Lote ainda não enviado!' +   chr(13) + chr(10)
				else
					_cRetMemo += 'Status do lote na WPL:... Já enviado (Flag ' +alltrim(_cRetFlWpl) + ') !' + chr(13) + chr(10)
				endif


				if  ZAU->ZAU_STATW $ '/RE'

					if _cRetStatWpl = 'E'
						_cRetMemo += 'Lote encerrado na WPL (Flag ' +alltrim(_cRetFlWpl) + ')!... (ERRO)!' + chr(13) + chr(10)
						_lMet02 := .f.
					else
						_cRetMemo += 'Envio habilitado do lote... (OK)!' + chr(13) + chr(10)
					endif

				else

				endif

				//Metodo setDataZAU010_toDevice

				_MemoryText := 0
				_oWS := WSbizFSWebService():New()

				_cImVal   := alltrim(substr(strtran(ZAU->ZAU_IMVAL,'/',''),1,4) + substr(strtran(ZAU->ZAU_IMVAL,'/',''),5,2))
				//_cDtProd  := alltrim(substr(strtran(dtoc(ZAU->ZAU_DTPROD),'/',''),1,4) + '20'+substr(strtran(dtoc(ZAU->ZAU_DTPROD),'/',''),5,2)) 
				_cDtProd  := alltrim(substr(strtran(dtoc(ZAU->ZAU_DTPROD),'/',''),1,4) + '20'+substr(strtran(dtoc(ZAU->ZAU_DTPROD),'/',''),5,2)) 
				IF (!_nDevice = 4 .AND. !_nDevice = 6)			
					_cTara   := alltrim(strtran(str(ZAU->ZAU_TARA),',','.'))
				ELSE					
					_cTara   := alltrim(strtran(str(ZAU->ZAU_TARAT),',','.'))
				ENDIF
				_cTaraS   := alltrim(strtran(str(ZAU->ZAU_TARAS),',','.'))
				_cTaraT   := alltrim(strtran(str(ZAU->ZAU_TARAT),',','.'))
				_cPrcCli  := alltrim(strtran(str(ZAU->ZAU_PRCCLI),',','.'))
				//_cPrcCli2  := AllTrim(StrTran(transform(ZAU->ZAU_PRCCLI,'@E 99.99'),',','.'))   
				//_cPesBrt := AllTrim(StrTran(transform(_nPesBrt,'@E 999.99'),',',''))
				//alert(_cPrcCli)
				//alert(_cPrcCli2)

				_cLayPrc   := getmv('SI_LAYPRC')//parametro que contem a relação de layouts que possuem peso e preço no codigo de barras
				_cLayPes   := getmv('SI_LAYPES')//parametro que contem a relação de layouts que pessuem somente o peso no codigo de barras
				
				_cTpCodBar := iif(ZAU->ZAU_LAYETQ $ _cLayPrc,'3',iif(ZAU->ZAU_LAYETQ $ _cLayPes,'8','1'))//Se o layout estiver no parametro deverá utilizar o codigo de barras com preço e peso
				
				
				dbSelectArea('SB1')
				_cPluCli := fBuscaCpo('SB1',1,xFilial('SB1') + ZAU->ZAU_COD,'B1_PLUCLI')
				_cCodTab := fBuscaCpo('SB1',1,xFilial('SB1') + ZAU->ZAU_COD,'B1_TABNUTR')//codigo tabela nutricional

				if empty(_cCodTab)//caso o campo esteja em branco é necessário enviar para a maquina '00' para manter o padrão da string
					_cCodTab := '00'		
				endif   
				
				//alert(len(_cCodTab))		
				//alert('Vai mandar a tabela: ' + _cCodTab)
				//alert(_cTpCodBar + ZAU->ZAU_IMCBAR)
					
				_cIMCBAR := iif(_cTpCodBar $ '3/8',_cTpCodBar + alltrim(_cPluCli), _cTpCodBar + ZAU->ZAU_IMCBAR)
				
				
				
				_oWS:oWSsendData:nDeviceID       := _nDevice
				_oWS:oWSsendData:cZAU_FILIAL     := '1'
				_oWS:oWSsendData:cZAU_NUM        := ZAU->ZAU_NUM
				_oWS:oWSsendData:cZAU_DTPROD     := _cDtProd
				_oWS:oWSsendData:cZAU_COD        := ZAU->ZAU_COD
				_oWS:oWSsendData:cZAU_PLU        := substr(ZAU->ZAU_COD,1,6) + _cCodTab //ZAU->ZAU_COD
				_oWS:oWSsendData:cZAU_LINHA      := alltrim(str(_nDevice))//Aqui a linha deverá ser sempre igual ao device  - CUIDAR!!!!!!
				_oWS:oWSsendData:cZAU_STATUS     := 'A'
				_oWS:oWSsendData:cZAU_PRCCLI     := _cPrcCli
				_oWS:oWSsendData:cZAU_QPPESO     := str(ZAU->ZAU_QPPESO)
				_oWS:oWSsendData:cZAU_QRPESO     := '0'
				_oWS:oWSsendData:cZAU_QPUNI      := str(ZAU->ZAU_QPUNI)
				_oWS:oWSsendData:cZAU_QRUNI      := '0'
				_oWS:oWSsendData:cZAU_QPCAIX     := str(ZAU->ZAU_QPCAIX)
				_oWS:oWSsendData:cZAU_QRCAIX     := '0'
				_oWS:oWSsendData:cZAU_TARA       := _cTara                                                                                                                         
				_oWS:oWSsendData:cZAU_IMCBAR     := iif(_cTpCodBar $ '3/8',_cTpCodBar + _cPluCli, _cTpCodBar + ZAU->ZAU_IMCBAR)//Se usar o tipo 3, a Bizerba irá imprimir um codigo do tipo UPC
				//_oWS:oWSsendData:cZAU_IMCBAR   := _cTpCodBar + ZAU->ZAU_IMCBAR//Se for ean128 envia o codigo '3' senão vai enviar o codigo '1' que identifica ean13 _cTpCodBar + 
				_oWS:oWSsendData:cZAU_PESBAN     := str(ZAU->ZAU_PESBAN)
				_oWS:oWSsendData:cZAU_CODCLI     := '0'
				_oWS:oWSsendData:cZAU_TIPSER     := '0'
				_oWS:oWSsendData:cZAU_IMLOTE     := ZAU->ZAU_IMLOTE
				_oWS:oWSsendData:cZAU_IMPROD     := ZAU->ZAU_IMPROD
				_oWS:oWSsendData:cZAU_IMTARA     := _cTara
				_oWS:oWSsendData:cZAU_IMVAL      := ZAU->ZAU_IMVAL
				_oWS:oWSsendData:cZAU_IMPRC      := _cPrcCli
				_oWS:oWSsendData:cZAU_IMPCOM     := ZAU->ZAU_IMPCOM
				
				IF (_nDevice <> 4 .AND. _nDevice <> 6)
					_oWS:oWSsendData:cZAU_LAYETQ     := ZAU->ZAU_LAYETQ
				ELSE					
					IF(!Empty(ZAU->ZAU_PBFIXO))
						_oWS:oWSsendData:cZAU_LAYETQ     := '001'
					ELSE
						_oWS:oWSsendData:cZAU_LAYETQ     := '002'
					ENDIF					
				ENDIF
				
				_oWS:oWSsendData:cZAU_FLERP      := alltrim(str(ZAU->ZAU_FLERP))  //0 = não enviado   1 = já enviado
				_oWS:oWSsendData:cZAU_FLWPL      := alltrim(str(ZAU->ZAU_FLWPL))
				_oWS:oWSsendData:cZAU_ADD0       := ZAU->ZAU_PORCI1
				_oWS:oWSsendData:cZAU_ADD1       := ZAU->ZAU_PORCI2
				_oWS:oWSsendData:cZAU_ADD2       := ZAU->ZAU_PORCI3
				_oWS:oWSsendData:cZAU_ADD3       := ZAU->ZAU_PORCI4
				_oWS:oWSsendData:cZAU_ADD4       := ZAU->ZAU_PORCI5
				_oWS:oWSsendData:cZAU_TX4        := ZAU->ZAU_ITARAT
				_oWS:oWSsendData:cZAU_TX5        := ZAU->ZAU_ITARAS
				_oWS:oWSsendData:cZAU_TX6        := ZAU->ZAU_RASTRE
				_oWS:oWSsendData:cZAU_TX7        := ZAU->ZAU_ITARAB
				_oWS:oWSsendData:cZAU_TX8        := ZAU->ZAU_IPEFIX
				_oWS:oWSsendData:cZAU_TX9        := ZAU->ZAU_PBFIXO
				/*				
				_oWS:oWSsendData:cZAU_TX10      := 
				_oWS:oWSsendData:cZAU_TX11      := 
				_oWS:oWSsendData:cZAU_TX12      := 
				_oWS:oWSsendData:cZAU_TX13      := 
				_oWS:oWSsendData:cZAU_TX14      := 
				_oWS:oWSsendData:cZAU_TX15      := 
				_oWS:oWSsendData:cZAU_TX16      := 
				_oWS:oWSsendData:cZAU_TX17      := 
				_oWS:oWSsendData:cZAU_TX18      := 
				_oWS:oWSsendData:cZAU_TX19      := 
				_oWS:oWSsendData:cZAU_TX20      := 
				*/
				_oWS:nUpdateDataMain             := 1

				_oWS:setDataZAU010_toDevice()

				oXML := _oWS:oWSsetDataZAU010_toDeviceResult

				_ValRet := valtype(oXML)

				if _ValRet = 'U'
					_cRetMemo += ' Metodo não consumido... (ERRO)!' + chr(13) + chr(10)
					_lMet03 := .f.
				else
					_lResult := oXML:OWSRESULT:OWSRESULT[1]:LRESULT
					if _lResult
						_cRetMemo += 'Apontamento do lote realizado... (OK)!' + chr(13) + chr(10)
					else
						_cRetMemo += ' Metodo não consumido... (ERRO2)!' + chr(13) + chr(10)
						_lMet03 := .f.
					endif
				endif

			else
				_cRetMemo += ' Lote não encontrado no ERP... (ERRO)!' + chr(13) + chr(10)
				_lMet03 := .f.
			endif

		else
			_cRetMemo += ' Teste de Conexão:..... ERRO!' + chr(13) + chr(10)
			_lMet01 := .f.
		endif

	END SEQUENCE

	if _lMet01 .and. _lMet02 .and. _lMet03		
		_cRetMemo += ' APONTAMENTO REALIZADO COM SUCESSO!' + chr(13) + chr(10)
		_lRet := .t.
	else
		_cRetMemo += ' APONTAMENTO NAO REALIZADO!' + chr(13) + chr(10)	
	endif            

	IntWPL(_cRetMemo)

return _lRet  



// Função que irá consumir os metodos:
// -> dbConnectionTest (testa a conexão)
// -> getDataZAU010 (pesquisa o lote para ver sua situação no BD Bizerba)
// -> setDevice_Sleep (bota a maquina para dormir)   
User function WBiz02(_cLote,_nDevice)
	Local _lMet01       := .t.
	Local _lMet02       := .t.
	Local _lMet03       := .t.
	Local _lMet04       := .f.
	Local _lret         := .t. 
	Local _cRetLoteWpl  := ''
	Local _cRetStatWpl  := ''
	Local _cRetFlWpl    := ''   
	Local _cStatERP     := ''
	Local _cRetMemo     := ''   
	Local _lStatus      := .f.
	Local _lStatusDel   := .f.  
	Local _DelPLU       := .f.
	Local i
	
	BEGIN SEQUENCE

		_oWS := WSbizFSWebService():New()  

		//Método DbConnectTest
		_oWS:dbConnectionTest() 

		oXML := _oWS:oWSdbConnectionTestResult

		if oXML:CSTRING[1] = 'True'

			_cRetMemo += 'Teste de Conexão:..... OK!' + chr(13) + chr(10)


			ZAU->(DbSetOrder(1))
			if ZAU->(DbSeek(xfilial('ZAU') + _cLote))

				//Método getDataZAU010
				_oWS:nZAU_FILIAL := 1
				_oWS:nZAU_LINHA  := _nDevice //1 = Linhas 001 e 002, 2 = Linhas 003 e 004
				_oWS:nDIAS       :=  0       //0 = Todos
				_oWS:cZAU_NUM    := _clote   //C
				_oWS:nZAU_FLWPL  := -1       //-1 = Todos
				_oWS:nwithSchema := 0
				_oWS:getDataZAU010()

				oXML := _oWS:oWSgetDataZAU010Result

				oTipo := XmlGetChild(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, 2 )
				_cTipo := valtype(oTipo)

				//		_cMemo := varinfo('oXML',oTipo)
				//		@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
				//		@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
				//		Activate Dialog oDlgMemo      

				if _cTipo <> "U"
					if _cTipo == "O"
						XmlNode2Arr( oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT:_ERP_ZAU010_FILTER, "_ERP_ZAU010_FILTER" )
					endif

					oXML := XmlChildEx(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, "_ERP_ZAU010_FILTER")
					for i := 1 to len(oXML)
						_cRetLoteWpl  := oXML[i]:_ZAU_NUM:Text
						_cRetStatWpl  := oXML[i]:_ZAU_STATUS:Text
						_cRetFlWpl    := oXML[i]:_ZAU_FLWPL:Text
					next
				endif

				//ZAU_FLWPL: 0 = Stand By, 1 = em produção, 2 = em pausa, 3 = finalizado

				_cStatWPL := iif(ZAU->ZAU_FLWPL = 0,'Stand By',iif(ZAU->ZAU_FLWPL = 1,'Em produção',iif(ZAU->ZAU_FLWPL = 2, 'Parado','Finalizado')))
				_cStatERP := iif(ZAU->ZAU_STATW = 'A','Stand By',iif(ZAU->ZAU_STATW = 'S','Parado',iif(ZAU->ZAU_STATW = 'R','Em Produção','Finalizado')))

				_cRetMemo += 'Status da Flag WPL no ERP:... ' + _cStatWPL + chr(13) + chr(10)	
				_cRetMemo += 'Status do lote no ERP:... ' + _cStatERP + chr(13) + chr(10)	

				if empty(_cRetLoteWpl)
					_cRetMemo += 'Status do lote na WPL:... Lote ainda não enviado!' +   chr(13) + chr(10)
				else
					_cRetMemo += 'Status do lote na WPL:... Já enviado (Flag ' +alltrim(_cRetFlWpl) + ') !' + chr(13) + chr(10)
				endif


				if _cRetStatWpl = 'E'
					_cRetMemo += 'Lote encerrado na WPL (Flag ' +alltrim(_cRetFlWpl) + ')!... (ERRO)!' + chr(13) + chr(10)
					_lMet02 := .f.
				else
					_cRetMemo += 'Processo habilitado... (OK)!' + chr(13) + chr(10)  

					//Metodo setDevice_Sleep
					_oWS:ndeviceID := _nDevice  
					_oWS:setDevice_Sleep() 

					_lStatus := _oWS:lsetDevice_SleepResult
					if _lStatus
						_cRetMemo += 'Consumo do metodo Sleep... (OK)!' + chr(13) + chr(10)

						if ZAU->ZAU_CTRLP = 'V' 
							If Aviso("Confirma exclusão?","Encerrar definitivamente a produção deste lote?",{"Confirma","Cancela"}) == 1			  
								_DelPlu := .t.
							endif 
						endif

						if _DelPlu
							//Metodo DeleteCustomer_toDevice
							//Propriedades de envio: ndeviceID,nPlu,nCustomerID 
							_oWS:ndeviceID   := _nDevice
							_oWs:nPlu        := val(ZAU->ZAU_COD)
							_oWs:nCustomerID := 0

							_oWS:DeletePLUCustomer_toDevice()

							_lStatusDel := _oWs:lDeletePLUCustomer_toDeviceResult

							if _lStatusDel          

								reclock('ZAU',.f.)
								ZAU->ZAU_DELWPL := 'S'
								msunlock()				  

								_cRetMemo += 'Consumo do metodo DeletePLU... (OK)!' + chr(13) + chr(10)  
								_lMet04 := .t.
							else
								_cRetMemo += 'Metodo não consumido... (ERRO2)!' + chr(13) + chr(10)
								_lMet04 := .f.
							endif     

						endif 

					else
						_cRetMemo += 'Metodo não consumido... (ERRO2)!' + chr(13) + chr(10)
						_lMet03 := .f.
					endif	

				endif

			else
				_cRetMemo += 'Lote não encontrado no ERP... (ERRO)!' + chr(13) + chr(10)
				_lMet03 := .f.
			endif

		else
			_cRetMemo += 'Teste de Conexão:..... ERRO!' + chr(13) + chr(10)
			_lMet01 := .f.
		endif

	END SEQUENCE

	if _lMet01 .and. _lMet02 .and. _lMet03		
		_cRetMemo += 'WPL ADORMECIDA!' + chr(13) + chr(10)
	else
		_cRetMemo += 'NAO FOI POSSIVEL ADORMER WPL!' + chr(13) + chr(10)	
	endif            

	if _lMet04
		_cRetMemo += 'PLU excluído da WPL!' + chr(13) + chr(10) 
	else
		_cRetMemo += 'PLU ainda ativo na WPL!' + chr(13) + chr(10)
	endif

	IntWPL(_cRetMemo)

return   

// Função que irá consumir os metodos:
// -> dbConnectionTest (testa a conexão)
// -> getDataZAU010 (pesquisa o lote para ver sua situação no BD Bizerba)
// -> setDataZAU010_toDevice (envia a produção)   
// Apontar a produção na linha/maquina indicada.
// ESPECIFICO PARA COLETOR DE DADOS
User function WBiz03(_cLote,_nDevice)
	Local _lMet01       := .t.
	Local _lMet02       := .t.
	Local _lMet03       := .t.
	Local _Ret         := .f. 
	Local _cRetLoteWpl  := ''
	Local _cRetStatWpl  := ''
	Local _cRetFlWpl    := ''   
	Local _cStatERP     := ''
	Local i

	BEGIN SEQUENCE

		_oWS := WSbizFSWebService():New()  

		//Método DbConnectTest
		_oWS:dbConnectionTest() 

		oXML := _oWS:oWSdbConnectionTestResult

		if oXML:CSTRING[1] = 'True'

			ZAU->(DbSetOrder(1))
			if ZAU->(DbSeek(xfilial('ZAU') + _cLote))

				//Método getDataZAU010
				_oWS:nZAU_FILIAL := 1
				_oWS:nZAU_LINHA  := _nDevice //1 = Linhas 001 e 002, 2 = Linhas 003 e 004
				_oWS:nDIAS       :=  0       //0 = Todos
				_oWS:cZAU_NUM    := _clote   //C
				_oWS:nZAU_FLWPL  := -1       //-1 = Todos
				_oWS:nwithSchema := 0
				_oWS:getDataZAU010()

				oXML := _oWS:oWSgetDataZAU010Result

				oTipo := XmlGetChild(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, 2 )
				_cTipo := valtype(oTipo)

				if _cTipo <> "U"
					if _cTipo == "O"
						XmlNode2Arr( oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT:_ERP_ZAU010_FILTER, "_ERP_ZAU010_FILTER" )
					endif

					oXML := XmlChildEx(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, "_ERP_ZAU010_FILTER")
					for i := 1 to len(oXML)
						_cRetLoteWpl  := oXML[i]:_ZAU_NUM:Text
						_cRetStatWpl  := oXML[i]:_ZAU_STATUS:Text
						_cRetFlWpl    := oXML[i]:_ZAU_FLWPL:Text
					next
				endif

				//ZAU_FLWPL: 0 = Stand By, 1 = em produção, 2 = em pausa, 3 = finalizado

				//	_cStatWPL := iif(ZAU->ZAU_FLWPL = 0,'Stand By',iif(ZAU->ZAU_FLWPL = 1,'Em produção',iif(ZAU->ZAU_FLWPL = 2, 'Parado','Finalizado')))
				//	_cStatERP := iif(ZAU->ZAU_STATW = 'A','Stand By',iif(ZAU->ZAU_STATW = 'S','Parado',iif(ZAU->ZAU_STATW = 'R','Em Produção','Finalizado')))

				if  ZAU->ZAU_STATW $ 'R/E'
					if _cRetStatWpl = 'E' 
						VTAlert('Lote encerrado na WPL!' ,'ERRO2',.T.,500,1)
						_lMet02 := .f.
						return _Ret 
					endif
				endif

				//Metodo setDataZAU010_toDevice

				_MemoryText := 0
				_oWS := WSbizFSWebService():New()

				_cImVal  := alltrim(substr(strtran(ZAU->ZAU_IMVAL,'/',''),1,4) + substr(strtran(ZAU->ZAU_IMVAL,'/',''),5,2))
				_cDtProd := alltrim(substr(strtran(dtoc(ZAU->ZAU_DTPROD),'/',''),1,4) + '20'+substr(strtran(dtoc(ZAU->ZAU_DTPROD),'/',''),5,2)) 
				IF (!_nDevice = 4 .AND. !_nDevice = 6)			
					_cTara   := alltrim(strtran(str(ZAU->ZAU_TARA),',','.'))
				ELSE					
					_cTara   := alltrim(strtran(str(ZAU->ZAU_TARAT),',','.'))
				ENDIF
				_cTaraS   := alltrim(strtran(str(ZAU->ZAU_TARAS),',','.'))
				_cTaraT   := alltrim(strtran(str(ZAU->ZAU_TARAT),',','.'))
				_cPrcCli := alltrim(strtran(str(ZAU->ZAU_PRCCLI),',','.'))

				_oWS:oWSsendData:nDeviceID       := _nDevice
				_oWS:oWSsendData:cZAU_FILIAL     := '1'
				_oWS:oWSsendData:cZAU_NUM        := ZAU->ZAU_NUM
				_oWS:oWSsendData:cZAU_DTPROD     := _cDtProd
				_oWS:oWSsendData:cZAU_COD        := ZAU->ZAU_COD
				_oWS:oWSsendData:cZAU_PLU        := ZAU->ZAU_COD
				_oWS:oWSsendData:cZAU_LINHA      := alltrim(str(_nDevice))//Aqui a linha deverá ser sempre igual ao device  - CUIDAR!!!!!!
				_oWS:oWSsendData:cZAU_STATUS     := 'A'
				_oWS:oWSsendData:cZAU_PRCCLI     := _cPrcCli
				_oWS:oWSsendData:cZAU_QPPESO     := str(ZAU->ZAU_QPPESO)
				_oWS:oWSsendData:cZAU_QRPESO     := '0'
				_oWS:oWSsendData:cZAU_QPUNI      := str(ZAU->ZAU_QPUNI)
				_oWS:oWSsendData:cZAU_QRUNI      := '0'
				_oWS:oWSsendData:cZAU_QPCAIX     := str(ZAU->ZAU_QPCAIX)
				_oWS:oWSsendData:cZAU_QRCAIX     := '0'
				_oWS:oWSsendData:cZAU_TARA       := _cTara
				_oWS:oWSsendData:cZAU_IMCBAR     := ZAU->ZAU_IMCBAR
				_oWS:oWSsendData:cZAU_PESBAN     := str(ZAU->ZAU_PESBAN)
				_oWS:oWSsendData:cZAU_CODCLI     := '0'
				_oWS:oWSsendData:cZAU_TIPSER     := '0'
				_oWS:oWSsendData:cZAU_IMLOTE     := ZAU->ZAU_IMLOTE
				_oWS:oWSsendData:cZAU_IMPROD     := ZAU->ZAU_IMPROD
				_oWS:oWSsendData:cZAU_IMTARA     := _cTara
				_oWS:oWSsendData:cZAU_IMVAL      := ZAU->ZAU_IMVAL
				_oWS:oWSsendData:cZAU_IMPRC      := _cPrcCli
				_oWS:oWSsendData:cZAU_IMPCOM     := ZAU->ZAU_IMPCOM
				_oWS:oWSsendData:cZAU_LAYETQ     := ZAU->ZAU_LAYETQ
				_oWS:oWSsendData:cZAU_FLERP      := alltrim(str(ZAU->ZAU_FLERP))  //0 = não enviado   1 = já enviado
				_oWS:oWSsendData:cZAU_FLWPL      := alltrim(str(ZAU->ZAU_FLWPL))
				_oWS:oWSsendData:cZAU_ADD0       := ZAU->ZAU_PORCI1
				_oWS:oWSsendData:cZAU_ADD1       := ZAU->ZAU_PORCI2
				_oWS:oWSsendData:cZAU_ADD2       := ZAU->ZAU_PORCI3
				_oWS:oWSsendData:cZAU_ADD3       := ZAU->ZAU_PORCI4
				_oWS:oWSsendData:cZAU_ADD4       := ZAU->ZAU_PORCI5
				_oWS:oWSsendData:cZAU_TX4        := ZAU->ZAU_ITARAT
				_oWS:oWSsendData:cZAU_TX5        := ZAU->ZAU_ITARAS
				_oWS:oWSsendData:cZAU_TX6        := ZAU->ZAU_RASTRE
				_oWS:oWSsendData:cZAU_TX7        := ZAU->ZAU_ITARAB
				_oWS:oWSsendData:cZAU_TX8        := ZAU->ZAU_IPEFIX
				_oWS:oWSsendData:cZAU_TX9        := ZAU->ZAU_PBFIXO
				/*				
				_oWS:oWSsendData:cZAU_TX10      := 
				_oWS:oWSsendData:cZAU_TX11      := 
				_oWS:oWSsendData:cZAU_TX12      := 
				_oWS:oWSsendData:cZAU_TX13      := 
				_oWS:oWSsendData:cZAU_TX14      := 
				_oWS:oWSsendData:cZAU_TX15      := 
				_oWS:oWSsendData:cZAU_TX16      := 
				_oWS:oWSsendData:cZAU_TX17      := 
				_oWS:oWSsendData:cZAU_TX18      := 
				_oWS:oWSsendData:cZAU_TX19      := 
				_oWS:oWSsendData:cZAU_TX20      := 
				*/
				_oWS:nUpdateDataMain             := 1
				_oWS:setDataZAU010_toDevice()

				oXML := _oWS:oWSsetDataZAU010_toDeviceResult

				_ValRet := valtype(oXML)

				if _ValRet = 'U'          
					VTAlert('Metodo não consumido...' ,'ERRO3',.T.,500,1)
					_lMet03 := .f.
				else
					_lResult := oXML:OWSRESULT:OWSRESULT[1]:LRESULT
					if !_lResult
						VTAlert('Metodo não consumido...' ,'ERRO2',.T.,500,1)
						_lMet03 := .f.
					endif
				endif

			else 
				VTAlert('Lote não encontrado no ERP...' ,'ERRO3',.T.,500,1)
				_lMet03 := .f.
			endif

		else                                                               
			VTAlert(' Teste de Conexão!' ,'ERRO1',.T.,500,1)
			_lMet01 := .f.
		endif

	END SEQUENCE

	if _lMet01 .and. _lMet02 .and. _lMet03		
		VTAlert(' APONTAMENTO REALIZADO COM SUCESSO!' ,'Aviso',.T.,500,1)
		_Ret := .t.
	else
		VTAlert(' APONTAMENTO NAO REALIZADO!' ,'Falha',.T.,500,1)
	endif            

return _Ret  


// Função que irá consumir os metodos:
// -> dbConnectionTest (testa a conexão)
// -> getDataZAU010 (pesquisa o lote para ver sua situação no BD Bizerba)
// -> setDevice_Sleep (bota a maquina para dormir)   
// ESPECÍFICO PARA COLETOR DE DADOS
User function WBiz04(_cLote,_nDevice)
	Local _lMet01       := .t.
	Local _lMet02       := .t.
	Local _lMet03       := .t.
	Local _lMet04       := .f.
	Local _Ret         := .t. 
	Local _cRetLoteWpl  := ''
	Local _cRetStatWpl  := ''
	Local _cRetFlWpl    := ''   
	Local _cStatERP     := ''  
	Local _lStatus      := .f.
	Local _lStatusDel   := .f.  
	Local _DelPLU       := .f.
	Local i

	BEGIN SEQUENCE

		_oWS := WSbizFSWebService():New()  

		//Método DbConnectTest
		_oWS:dbConnectionTest() 

		oXML := _oWS:oWSdbConnectionTestResult

		if oXML:CSTRING[1] = 'True'

			ZAU->(DbSetOrder(1))
			if ZAU->(DbSeek(xfilial('ZAU') + _cLote))

				//Método getDataZAU010
				_oWS:nZAU_FILIAL := 1
				_oWS:nZAU_LINHA  := _nDevice //1 = Linhas 001 e 002, 2 = Linhas 003 e 004
				_oWS:nDIAS       :=  0       //0 = Todos
				_oWS:cZAU_NUM    := _clote   //C
				_oWS:nZAU_FLWPL  := -1       //-1 = Todos
				_oWS:nwithSchema := 0
				_oWS:getDataZAU010()

				oXML := _oWS:oWSgetDataZAU010Result

				oTipo := XmlGetChild(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, 2 )
				_cTipo := valtype(oTipo)

				//		_cMemo := varinfo('oXML',oTipo)
				//		@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
				//		@ 055,005 Get _cMemo Size 250,080 MEMO Object oMemo
				//		Activate Dialog oDlgMemo      

				if _cTipo <> "U"
					if _cTipo == "O"
						XmlNode2Arr( oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT:_ERP_ZAU010_FILTER, "_ERP_ZAU010_FILTER" )
					endif

					oXML := XmlChildEx(oXML:_GETDATAZAU010RESULT:_DOCUMENTELEMENT, "_ERP_ZAU010_FILTER")
					for i := 1 to len(oXML)
						_cRetLoteWpl  := oXML[i]:_ZAU_NUM:Text
						_cRetStatWpl  := oXML[i]:_ZAU_STATUS:Text
						_cRetFlWpl    := oXML[i]:_ZAU_FLWPL:Text
					next
				endif

				//ZAU_FLWPL: 0 = Stand By, 1 = em produção, 2 = em pausa, 3 = finalizado

				//_cStatWPL := iif(ZAU->ZAU_FLWPL = 0,'Stand By',iif(ZAU->ZAU_FLWPL = 1,'Em produção',iif(ZAU->ZAU_FLWPL = 2, 'Parado','Finalizado')))
				//_cStatERP := iif(ZAU->ZAU_STATW = 'A','Stand By',iif(ZAU->ZAU_STATW = 'S','Parado',iif(ZAU->ZAU_STATW = 'R','Em Produção','Finalizado')))

				//_cRetMemo += 'Status da Flag WPL no ERP:... ' + _cStatWPL + chr(13) + chr(10)	
				//_cRetMemo += 'Status do lote no ERP:... ' + _cStatERP + chr(13) + chr(10)	

				//if empty(_cRetLoteWpl)
				//	_cRetMemo += 'Status do lote na WPL:... Lote ainda não enviado!' +   chr(13) + chr(10)
				//else
				//	_cRetMemo += 'Status do lote na WPL:... Já enviado (Flag ' +alltrim(_cRetFlWpl) + ') !' + chr(13) + chr(10)
				//endif


				if _cRetStatWpl = 'E'
					VTAlert('Lote encerrado na WPL!... (ERRO)!' ,'ERRO',.T.,500,1)
					return _Ret
				else


					//Metodo setDevice_Sleep
					_oWS:ndeviceID := _nDevice  
					_oWS:setDevice_Sleep() 

					_lStatus := _oWS:lsetDevice_SleepResult
					if _lStatus

						/*  if ZAU->ZAU_CTRLP = 'V' 
						If Aviso("Confirma exclusão?","Encerrar definitivamente a produção deste lote?",{"Confirma","Cancela"}) == 1			  
						_DelPlu := .t.
						endif 
						endif
						*/  
						if _DelPlu
							//Metodo DeleteCustomer_toDevice
							//Propriedades de envio: ndeviceID,nPlu,nCustomerID 
							_oWS:ndeviceID   := _nDevice
							_oWs:nPlu        := val(ZAU->ZAU_COD)
							_oWs:nCustomerID := 0

							_oWS:DeletePLUCustomer_toDevice()

							_lStatusDel := _oWs:lDeletePLUCustomer_toDeviceResult

							if _lStatusDel          

								reclock('ZAU',.f.)
								ZAU->ZAU_DELWPL := 'S'
								msunlock()				  

								_lMet04 := .t.
							else 
								VTAlert('Metodo não consumido!' ,'ERRO4',.T.,500,1)
								_lMet04 := .f.
							endif     

						endif 

					else 
						VTAlert('Metodo não consumido!' ,'ERRO3',.T.,500,1)
						_lMet03 := .f.
					endif	

				endif

			else
				VTAlert('Lote não encontrado no ERP!' ,'ERRO3',.T.,500,1)
				_lMet03 := .f.
			endif

		else
			VTAlert('Teste de conexão...' ,'ERRO',.T.,500,1)
			_lMet01 := .f.
		endif

	END SEQUENCE

	if _lMet01 .and. _lMet02 .and. _lMet03		
		_cRetMemo += 'WPL ADORMECIDA!' + chr(13) + chr(10) 
		_Ret := .t.
	else
		_cRetMemo += 'NAO FOI POSSIVEL ADORMECER WPL!' + chr(13) + chr(10)	
		_Ret := .f.
	endif            

	if _lMet04
		_cRetMemo += 'PLU excluído da WPL!' + chr(13) + chr(10) 
	else
		_cRetMemo += 'PLU ainda ativo na WPL!' + chr(13) + chr(10)
	endif

return _Ret 
