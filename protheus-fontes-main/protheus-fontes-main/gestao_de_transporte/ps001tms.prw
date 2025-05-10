#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPS001TMS  บAutor  ณEzequiel Pianegonda บ Data ณ  09/04/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao dos lotes/doc. de entrada no TMS                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบParametrosณcEMP: codigo da empresa usado no prepare environment        บฑฑ
ฑฑบ          ณcFil: codigo da filial usado no prepare environment         บฑฑ
ฑฑบ          ณaSF2: array com os recnos das notas de saidas               บฑฑ
ฑฑบ          ณaEMP: array com a empresa e filial de origem                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function PS001TMS(cEMP, cFIL, aSF2, aEmp, cTipVei, nCDRori, nCDRdes, cTabTar)
	
	Local nX			:= 0
	Local nY			:= 0
	Local aCabDTP		:= {}
	Local aCabDTC		:= {}
	Local aItem         := {}
	Local aItemDTC		:= {}
	Local aErroAuto		:= {}
	Local cRet          := ""
	Local cLoteNfc		:= ""
	Local cErro			:= ""
	Local oError		:= ErrorBlock({|e| RollBackSX8(), MemoWrite("U_PS001TMS.TXT", e:Description)})
	Local cCotacao		:= ""
	Local aCabDT4		:= {}
	Local aItemDVF		:= {}
	Local aItemDVT		:= {}
	Local aItemDT8_1 	:= {}
	Local aItemDT8_2	:= {}
	Local nQtd			:= 0
	Local nPes			:= 0
	Local nVal			:= 0


	Local nZ     := 0
	Local cLogFile := "" //nome do arquivo de log a ser gravado
	Local aLog 	 := {}
	Local nHandle
    Local lRet := .F.   // variแvel de controle interno da rotina automatica que informa se houve erro durante o processamento

	PRIVATE lMsErroAuto := .F.  // variแvel que define que o help deve ser gravado no arquivo de log e que as informa็๕es estใo vindo เ partir da rotina automแtica.
	Private lMsHelpAuto	:= .T.  // for็a a grava็ใo das informa็๕es de erro em array para manipula็ใo da grava็ใo ao inv้s de gravar direto no arquivo temporแrio
	Private lAutoErrNoFile := .T.


	//Private lMsErroAuto	:= .F.
	Private cCliDev 	:= "000434"
	Private cLojDev 	:= "02"

	PREPARE ENVIRONMENT EMPRESA cEMP FILIAL cFIL MODULO "TMS"

	cCotacao  := GetSX8Num("DT4","DT4_NUMCOT")
	_cHora    := StrTran(Left(Time(),5),":","")
	_cServ 	  := IIF(nCDRdes=1,'018','010')
	_cUser 	  := RetCodUsr()
	_nDiasCot := GETMV("MV_VLDCOT")

	ConfirmSX8()

	nQtd 	 := 0
	nPes 	 := 0
	nVal 	 := 0
	nQtd 	 := 0                        
	nPes 	 := 0
	nVal 	 := 0
	cCod 	 := ''
	cLoj 	 := ''
	cContrib := '0'

	For nX := 1 To Len(aSF2)
		cCod := aSF2[nX, 3]
		cLoj := aSF2[nX, 4]
		nQtd += aSF2[nX, 5]
		nPes += aSF2[nX, 6]
		nVal += aSF2[nX, 7]
	Next nX
	
	//alert(cCod)
	//alert(cLoj)
	//cContrib :=  fBuscaCpo('SA1070',1,xFilial('SA1070') + cCod + cLoj,'A1_CONTRIB')
	//alert(cContrib)
	
	aCabDT4:= {	{"DT4_FILIAL" , xFilial("DT4")					,Nil},;
				{"DT4_FILORI" , "00"   				        	,Nil},;
				{"DT4_NUMCOT" , cCotacao           				,Nil},;
				{"DT4_DATCOT" , dDataBase				        ,Nil},;
				{"DT4_HORCOT" , _cHora             				,Nil},;
				{"DT4_DDD"	  , "055"			 				,Nil},;
				{"DT4_TEL" 	  , "21032525"	 					,Nil},;
				{"DT4_PRZVAL" , dDataBase + _nDiasCot			,Nil},;
				{"DT4_TIPFRE" , "1"       				        ,Nil},;
				{"DT4_USER"   , _cUser        				    ,Nil},;
				{"DT4_SELORI" , "1"	 							,Nil},;
				{"DT4_CDRORI" , iif(nCDRori=1,'01001','01002')	,Nil},;
				{"DT4_CDRDES" , iif(nCDRdes=1,'01001','01002')	,Nil},;
				{"DT4_SERTMS" , "3"								,Nil},;
				{"DT4_TIPTRA" , "1" 							,Nil},;
				{"DT4_SERVIC" , _cServ							,Nil},;
				{"DT4_TABFRE" , "0001" 							,Nil},;
				{"DT4_TIPTAB" , "01"			 				,Nil},;
				{"DT4_SEQTAB" , "00" 							,Nil},;
				{"DT4_STATUS" , "1"				            	,Nil},;
				{"DT4_USRAPV" , _cUser 							,Nil},;
				{"DT4_PESSOA" , "1" 				            ,Nil},;
				{"DT4_TIPNFC" , "0"             				,Nil},;
				{"DT4_DISTIV" , "2" 				            ,Nil},;
				{"DT4_INCISS" , "1"             				,Nil},;
				{"DT4_MOEDA"  , 1    				            ,Nil},;
				{"DT4_CONTRI" , "02"             			    ,Nil},;				
				{"DT4_CADPOR" , "2"                 			,Nil} } 

	nQtd := 0                        
	nPes := 0
	nVal := 0
	For nX := 1 To Len(aSF2)
		nQtd += aSF2[nX, 5]
		nPes += aSF2[nX, 6]
		nVal += aSF2[nX, 7]
	Next nX

	aItemDVF:= {{"DVF_FILIAL" , xFilial("DVF") 			,Nil},;
				{"DVF_FILORI" , "00" 					,Nil},;
				{"DVF_NUMCOT" , cCotacao 				,Nil},;
				{"DVF_ITEM"   , "01" 					,Nil},;
				{"DVF_CODPRO" , "000001"	 			,Nil},;
				{"DVF_CODEMB" , "CX" 					,Nil},;
				{"DVF_QTDVOL" , nQtd 					,Nil},;
				{"DVF_QTDUNI" , 0                  		,Nil},;
				{"DVF_PESO"   , nPes 					,Nil},; // peso da quantidade de volume
				{"DVF_VALMER" , nVal					,Nil} } // valor total do produto

	aItemDVT:= {{"DVT_FILIAL" , xFilial("DVT")			,Nil},;
				{"DVT_FILORI" , "00"					,Nil},;
				{"DVT_NUMCOT" , cCotacao				,Nil},;
				{"DVT_ITEM"	  , "01"					,Nil},;
				{"DVT_TIPVEI" , cTipVei					,Nil},;
				{"DVT_QTDVEI" , 1						,Nil},;
				{"DVT_ORIGEM" , "1"					   	,Nil} }

	_cTabFre := '0001'
	_cTipTab := '01'
	//_cTabTar := iif(nTabTar=1,'0001',iif(nTabTar=2,'PAR1',iif(nTabTar=3,'POA1',iif(nTabTar=4,'SCA1','SCUN'))))
	_cTabTar := cTabTar
	_cItem   := ''
	_nValor  := 0   //valor final
	_nPesAc  := 0   //calculo do peso excedido de faixa
	_nExc    := 0   //valor excedido a ser acrescetado conforme o fator

	//Hora de calcular
	DbSelectArea('DTG')
	DTG->(DbSetOrder((1)))
	If DTG->(DbSeek(xfilial('DTG')+_cTabFre +  _cTipTab + _cTabTar + cTipVei))
		While DTG->(!Eof()) .And. DTG->DTG_FILIAL = xFilial('DTG') .and.;
			DTG->DTG_TABFRE = _cTabFre .and.;
			DTG->DTG_TIPTAB = _cTipTab .and.;
			DTG->DTG_TABTAR = _cTabTar .and.;
			DTG->DTG_CODPAS = cTipVei

			If nPes <= DTG->DTG_VALATE
				If DTG->DTG_INTERV = 0
					_nValor := DTG->DTG_VALOR
					Exit
				Else
					_nExc := ( (nPes - _nPesAc) / DTG->DTG_INTERV ) * DTG->DTG_VALOR
					_nValor += _nExc
					Exit
				Endif
			Else
				_nPesAc := DTG->DTG_VALATE
				_nValor := DTG->DTG_VALOR
			Endif

			DTG->(DbSkip())
		Enddo
	Endif

	aItemDT8_1 := { {"DT8_CODPAS", cTipVei        						,Nil},;
					{"DT8_VALPAS", _nValor				            	,Nil},;
					{"DT8_VALTOT", _nValor           			   		,Nil},;
					{"DT8_FILORI", "00"             				   	,Nil},;
					{"DT8_NUMCOT", cCotacao            					,Nil},;
					{"DT8_CDRORI", iif(nCDRori=1,'01001','01002')		,Nil},;
					{"DT8_CDRDES", iif(nCDRdes=1,'01001','01002')		,Nil},;
					{"DT8_CODPRO", "000001" 			            	,Nil},;
					{"DT8_TABFRE", _cTabFre          			   		,Nil},;
					{"DT8_TIPTAB", _cTipTab 			            	,Nil},;
					{"DT8_SEQTAB", "00"              			   		,Nil},;
					{"DT8_CALMIN", "2"            			      		,Nil} }

	aItemDT8_2 := {	{"DT8_CODPAS", "TF"     			     	 	 	,Nil},;
					{"DT8_VALPAS", _nValor           			   		,Nil},;
					{"DT8_VALTOT", _nValor     			         		,Nil},;
					{"DT8_FILORI", "00"                 				,Nil},;
					{"DT8_NUMCOT", cCotacao   			         		,Nil},;
					{"DT8_CODPRO", "000001"          			   		,Nil},;
					{"DT8_CALMIN", "2"         			         		,Nil} }

	//IncDT4(aCabDT4)			// COTAวรO DE FRETE
	//IncDVF(aItemDVF)		// ITENS DA COTAวรO DE FRETE
	//IncDVT(aItemDVT)		// TIPO VEอCULO COLETA / COTAวรO
	//IncDT8(aItemDT8_2)		// COMPOSIวรO DO FRETE (para componente TF)
	//IncDT8(aItemDT8_1)		// COMPOSIวรO DO FRETE (para componente cTipVei)


	// Inclusใo do lote
	aCabDTP := {}
	aCabDTP := { {"DTP_QTDLOT", Len(aSF2)			, Nil},;
				 {"DTP_QTDDIG", 0					, Nil},;
				 {"DTP_STATUS", '1'					, Nil} }

	lMsErroAuto := .F.
	
	MsExecAuto({|x, y| cRet := TMSA170(x, y)}, aCabDTP, 3)	// Lote de Entrada de Notas Fiscais
	
	If lMsErroAuto
		aErroAuto := GetAutoGrLog()
		cErro	  := "Erro na inclusao do lote via rotina automatica" +chr(13) + chr(10)
		For nX := 1 To Len(aErroAuto)
			cErro += aErroAuto[nX]+chr(13)+chr(10)
		Next nX
		MemoWrite("U_PS001TMS.TXT", cErro)
	Else
		cLoteNfc := cRet
	EndIf

	// Inclusใo do docto entrada
	If !lMsErroAuto
		For nX := 1 To Len(aSF2)

			aCabDTC   := {}
			aItemDTC  := {}
			aErroAuto := {}

			dbSelectArea("DTC")
			dbSetorder(1)

			RegToMemory("DTC",.T.,.F.)

			_cCDRDES := fBuscaCpo('SA1',1,xFilial('SA1') + aSF2[nX, 3] + aSF2[nX, 4],'A1_CDRDES')
			_cCDRCAL := fBuscaCpo('SA1',1,xFilial('SA1') + aSF2[nX, 3] + aSF2[nX, 4],'A1_CDRDES')

			aCabDTC := { {"DTC_FILORI", "00" 							,Nil},;
						 {"DTC_LOTNFC", cLoteNfc						,Nil},;
						 {"DTC_CLIREM", "000434"						,Nil},;
						 {"DTC_LOJREM", "02"							,Nil},;
						 {"DTC_DATENT", dDataBase						,Nil},;
						 {"DTC_CLIDES", aSF2[nX, 3]						,Nil},;
						 {"DTC_LOJDES", aSF2[nX, 4]						,Nil},;
						 {"DTC_CLIDEV", "000434"   						,Nil},;
						 {"DTC_LOJDEV", "02"		   					,Nil},;
						 {"DTC_CLICAL", "000434"   						,Nil},;
						 {"DTC_LOJCAL", "02"		   					,Nil},;
						 {"DTC_DEVFRE", "1"								,Nil},;
						 {"DTC_SERTMS", "3"								,Nil},;
						 {"DTC_TIPTRA", "1"								,Nil},;
						 {"DTC_SERVIC", iif(nCDRdes=1,'018','010')	    ,Nil},;
						 {"DTC_TIPNFC", "0"		   						,Nil},;
						 {"DTC_TIPFRE", "1"								,Nil},;
						 {"DTC_CODNEG", "01"		   					,Nil},;
						 {"DTC_SELORI", "1"								,Nil},;
						 {"DTC_CDRORI", "01001"   						,Nil},;
						 {"DTC_CDRDES", _cCDRDES   						,Nil},;
						 {"DTC_CDRCAL", _cCDRCAL   						,Nil},;
						 {"DTC_DISTIV","2"								,Nil},;
						 {"DTC_NCONTR", "000000000000008"				,Nil},;
						 {"DTC_DOCTMS", "2"		   						,Nil},;
						 {"DTC_ESTORN", "1"								,Nil},;
						 {"DTC_DPCLOC", "2"								,Nil},;
						 {"DTC_EMPORI", ""								,Nil},;
						 {"DTC_EMPFIL", ""								,Nil},;
						 {"DTC_CARGA" , aSF2[nX, 8]						,Nil} }

			aItem   := { {"DTC_NUMNFC",	aSF2[nX, 1]						,Nil},;
						 {"DTC_SERNFC",	aSF2[nX, 2]						,Nil},;
						 {"DTC_CODPRO",	"000001 "						,Nil},;
						 {"DTC_CODEMB",	"CX"							,Nil},;
						 {"DTC_EMINFC",	dDataBase						,Nil},;
						 {"DTC_QTDVOL",	aSF2[nX, 5]						,Nil},;
						 {"DTC_PESO"  ,	aSF2[nX, 6]						,Nil},;
						 {"DTC_VALOR" ,	aSF2[nX, 7]						,Nil},;
						 {"DTC_BASSEG", 0 								,Nil},;
						 {"DTC_METRO3", 0								,Nil},;
						 {"DTC_QTDUNI", 0 								,Nil},;
						 {"DTC_EDI"	  ,	"2"								,Nil},;
						 {"DTC_CF"	  ,	"5101"							,Nil},;
						 {"DTC_USUAGD",	__cUserID						,Nil},;
						 {"DTC_DOCREE",	"2"								,Nil},;
						 {"DTC_PRVENT",	dDatabase + 1					,Nil},;
						 {"DTC_NFENTR",	"2"								,Nil},;
						 {"DTC_NFEID" ,	aSF2[nX, 9] 					,Nil} }

//						 {"DTC_PESOM3",	0								,Nil},;

			AAdd(aItemDTC,aClone(aItem))
			
			//u_showarray(aItemDtc)

			// Grava Num. Cota็ใo no campo F2_COTTMS da empresa 01 para nใo ser processado mais de 1 vez
			
			_cQuery := "UPDATE SF2010"
			_cQuery += "   SET F2_COTTMS = '" + cCotacao + "' "
			_cQuery += " WHERE D_E_L_E_T_ <> '*'"
			_cQuery += "   AND F2_DOC = '" + aSF2[nX, 1] + "' "
			_cQuery += "   AND F2_SERIE = '" + aSF2[nX, 2] + "' "
			_cQuery += "   AND F2_FILIAL = '00' "
			
			TcSqlExec(_cQuery)
			
			lMsErroAuto := .F.
			lRet := .F.

			AutoGrLog("Gera็ใo do arquivo de log")
			AutoGrLog("")

			MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,3)		// Notas Fiscais do Cliente (Doctos de Entrada)
			
			AutoGrLog(Replicate("-", 20))

			/*
			If lMsErroAuto
				cLogFile := "\log_tms\ps001tms_LOTE_" + cLoteNfc + ".log"
				//fun็ใo que retorna as informa็๕es de erro ocorridos durante o processo da rotina automแtica
				aLog := GetAutoGRLog()	//efetua o tratamento para validar se o arquivo de log jแ existe
				If !File(cLogFile)
					If (nHandle := MSFCreate(cLogFile,0)) <> -1
						lRet := .T.
					EndIf
				Else
					If (nHandle := FOpen(cLogFile,2)) <> -1
						FSeek(nHandle,0,2)
						lRet := .T.
					EndIf
				EndIf
				If lRet
					//grava as informa็๕es de log no arquivo especificado
					For nZ := 1 To Len(aLog)
						FWrite(nHandle,aLog[nZ]+CHR(13)+CHR(10))
					Next nZ
					FClose(nHandle)
				EndIf
			EndIf
			*/
			
			If lMsErroAuto
				MostraErro()
				aErroAuto := GetAutoGrLog()
				cErro := "Erro inclusao do Dc.Entrada via rotina automatica" + chr(13) + chr(10)
				For nY:= 1 To Len(aErroAuto)
					cErro += aErroAuto[nY]+chr(13)+chr(10)
				Next nY
				MemoWrite("U_PS001TMS.TXT", cErro)
			Else
				DTC->(dbCommit())
			EndIf

			dbSelectArea("DVU")
			dbSetOrder(1)
			Reclock("DVU", .T.)
			DVU->DVU_FILIAL	:= xFilial("DVU")
			DVU->DVU_ITEM	:= "01"
			DVU->DVU_FILORI	:= cFIL
			DVU->DVU_NUMNFC	:= aSF2[nX, 1]
			DVU->DVU_SERNFC	:= aSF2[nX, 2]
			DVU->DVU_CLIREM	:= "000434"
			DVU->DVU_LOJREM	:= "02"
			DVU->DVU_TIPVEI	:= cTipVei
			DVU->DVU_QTDVEI	:= 1
			DVU->DVU_LOTNFC	:= cLoteNfc
			MsUnLock("DVU")
			
		Next nX
	EndIf

	//trato caso deu erro
	ErrorBlock(oError)

	RESET ENVIRONMENT
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIncDT4    บAutor  ณEzequiel Pianegonda บ Data ณ  03/05/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclusao manual tabela DT4                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IncDT4(aAux)

	Local aDados := {}
	Local nX	 := 0
	Local nPos	 := 0

	dbSelectArea("DT4")
	dbSetOrder(1)

	//inicializo todos os campos da tabela DT4
	For nX := 1 To FCount()
		AADD(aDados, {DT4->(FieldName(nX)), CriaVar(DT4->(FieldName(nX)))})
	Next nX
	
	TMSA040Whe()
	//u_showarray(aDados)

	//atualizo os campos passados via parametro, no caso o cabecalho
	For nX := 1 To Len(aAux)
		nPos := ASCAN(aDados, {|x| Alltrim(x[1])==Alltrim(aAux[nX, 1])})
		If nPos != 0
			aDados[nPos, 2]:= aAux[nX, 2]
		EndIf
	Next nX
	//u_showarray(aDados)

	RecLock("DT4", .T.)
	For nX := 1 To Len(aDados)
		DT4->&(aDados[nX, 1]):= aDados[nX, 2]
	Next nX
	MsUnLock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIncDVF    บAutor  ณEzequiel Pianegonda บ Data ณ  03/05/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclusao manual na tabela DVF                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IncDVF(aAux)

	Local aDados := {}
	Local nX	 := 0
	Local nPos	 := 0

	dbSelectArea("DVF")
	dbSetOrder(1)

	//inicializo todos os campos da tabela DT4
	For nX := 1 To FCount()
		AADD(aDados, {DVF->(FieldName(nX)), CriaVar(DVF->(FieldName(nX)))})
	Next nX
	//u_showarray(aDados)

	//atualizo os campos passados via parametro, no caso o cabecalho
	For nX := 1 To Len(aAux)
		nPos := ASCAN(aDados, {|x| Alltrim(x[1])==Alltrim(aAux[nX, 1])})
		If nPos != 0
			aDados[nPos, 2]:= aAux[nX, 2]
		EndIf
	Next nX
	//u_showarray(aDados)

	RecLock("DVF", .T.)
	For nX := 1 To Len(aDados)
		DVF->&(aDados[nX, 1]):= aDados[nX, 2]
	Next nX
	MsUnLock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINCDVT    บAutor  ณEzequiel Pianegonda บ Data ณ  03/05/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclusao manual na tabela DVT                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IncDVT(aAux)

	Local aDados := {}
	Local nX	 := 0
	Local nPos	 := 0

	dbSelectArea("DVT")
	dbSetOrder(1)

	//inicializo todos os campos da tabela DVT
	For nX := 1 To FCount()
		AADD(aDados, {DVT->(FieldName(nX)), CriaVar(DVT->(FieldName(nX)))})
	Next nX
	//u_showarray(aDados)

	//atualizo os campos passados via parametro, no caso o cabecalho
	For nX := 1 To Len(aAux)
		nPos := ASCAN(aDados, {|x| Alltrim(x[1])==Alltrim(aAux[nX, 1])})
		If nPos != 0
			aDados[nPos, 2]:= aAux[nX, 2]
		EndIf
	Next nX
	//u_showarray(aDados)

	RecLock("DVT", .T.)
	For nX := 1 To Len(aDados)
		DVT->&(aDados[nX, 1]):= aDados[nX, 2]
	Next nX
	MsUnLock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIncDtc    บAutor  ณEzequiel Pianegonda บ Data ณ  16/04/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclusao manual na tabela DTC. <<NAO USAR>>                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IncDTC(aCab, aItens)

	Local aDados := {}
	Local nX	 := 0
	Local nPos	 := 0

	dbSelectArea("DTC")
	dbSetOrder(1)

	//inicializo todos os campos da tabela DTC
	For nX:= 1 To FCount()
		AADD(aDados, {DTC->(FieldName(nX)), CriaVar(DTC->(FieldName(nX)))})
	Next nX
	//u_showarray(aDados)

	//atualizo os campos passados via parametro, no caso o cabecalho
	For nX:= 1 To Len(aCab)
		nPos:= ASCAN(aDados, {|x| Alltrim(x[1])==Alltrim(aCab[nX, 1])})
		If nPos != 0
			aDados[nPos, 2]:= aCab[nX, 2]
		EndIf
	Next nX
	//u_showarray(aDados)

	//atualizo os campos passados via parametro, no caso os itens
	For nX:= 1 To Len(aItens[1])
		nPos:= ASCAN(aDados, {|x| Alltrim(x[1])==Alltrim(aItens[1, nX, 1])})
		If nPos != 0
			aDados[nPos, 2]:= aItens[1, nX, 2]
		EndIf
	Next nX
	//u_showarray(aDados)

	RecLock("DTC", .T.)
	For nX:= 1 To Len(aDados)
		DTC->&(aDados[nX, 1]):= aDados[nX, 2]
	Next nX
	MsUnLock()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIncDT8    บAutor  ณEzequiel Pianegonda บ Data ณ  03/05/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclusao manual na tabela DT8                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IncDT8(aAux)

	Local aDados := {}
	Local nX	 := 0
	Local nPos	 := 0

	dbSelectArea("DT8")
	dbSetOrder(1)

	//inicializo todos os campos da tabela DT4
	For nX := 1 To FCount()
		AADD(aDados, {DT8->(FieldName(nX)), CriaVar(DT8->(FieldName(nX)))})
	Next nX
	//u_showarray(aDados)

	//atualizo os campos passados via parametro, no caso o cabecalho
	For nX := 1 To Len(aAux)
		nPos := ASCAN(aDados, {|x| Alltrim(x[1])==Alltrim(aAux[nX, 1])})
		If nPos != 0
			aDados[nPos, 2]:= aAux[nX, 2]
		EndIf
	Next nX
	//u_showarray(aDados)


	RecLock("DT8", .T.)
	For nX := 1 To Len(aDados)
		DT8->&(aDados[nX, 1]):= aDados[nX, 2]
	Next nX
	MsUnLock()

Return

