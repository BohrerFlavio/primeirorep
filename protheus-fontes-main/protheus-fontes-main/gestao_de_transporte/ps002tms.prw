#INCLUDE "Topconn.ch"

User Function PS002TMS()

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³PS002TMS  ºAutor  ³Ezequiel Pianegonda º Data ³  12/04/2012 º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDesc.     ³ Exclusao de todas as tabelas envolvidas no processo gerado º±±
	±±º          ³ dos lotes/doctos entrada do TMS pelo número do lote.       º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ AP                                                         º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/

	Local nOpc		:= 0
	Local aSays		:= {}
	Local aButtons	:= {}

	Private cPerg	:= "PS002TMS"

	AADD(aSays, "Esta rotina tem como objetivo realizar a exclusão do Lote e seus respectivos ")
	AADD(aSays, "Doctos de Entrada, conforme parâmetro informado. Confirma o processamento?   ")

	AADD(aButtons, {1, .T., {|o| nOpc:= 1, o:oWnd:End()}})
	AADD(aButtons, {2, .T., {|o| o:oWnd:End()}})
	AADD(aButtons, {5, .T., {|o| Pergunte(cPerg, .T.)}})

	FormBatch("Exclusão do Lote e Doctos de Entrada", aSays, aButtons,,200)

	If nOpc != 0
		Pergunte(cPerg, .F.)
		Processa({|| Exclui()}, "")
	Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Exclui   º Autor ³ Ezequiel Pianegondaº Data ³  12/04/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Funcao de processamento...                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Exclui()

	Local cQuery	:= ""
	Local aArea		:= GetArea()
	Local cAli		:= GetNextAlias()
	Local cAli1		:= GetNextAlias()
	Local cAli2		:= GetNextAlias()
	Local cMsg		:= ""
	Local aCabDTC	:= {}
	Local aItem		:= {}
	Local aItemDTC	:= {}
	Local aCabDTP	:= {}
	Local _cNumCot  := ''

	Private lMsErroAuto := .F.

	cQuery := " SELECT *, R_E_C_N_O_ DTCRECNO "
	cQuery += " FROM  "+RetSqlTab("DTC")
	cQuery += " WHERE "+RetSqlFil("DTC")+" AND "
	cQuery += "         DTC_LOTNFC = '"+MV_PAR01+"' AND "
	cQuery += "       "+RetSqlDel("DTC")

	TCQuery ChangeQuery(cQuery) New Alias &(cAli)

	// Percorro a query para ver se posso excluir os Doctos Entrada
	Do While !&(cAli)->(EOF())
		If !Empty(&(cAli)->(DTC_DOC)) .AND. !Empty(&(cAli)->(DTC_SERIE))
			cMsg += "Nota: "+&(cAli)->(DTC_DOC)+" Serie: "+&(cAli)->(DTC_SERIE)+Chr(13)+Chr(10)
		EndIf
		&(cAli)->(dbSkip())
	EndDo

	If Len(cMsg) > 0
		cMsg := "Lote não pode ser excluído pois já foram gerados os documentos abaixo:"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+;
		cMsg + Chr(13)+Chr(10)+"Processo finalizado, nenhum Lote/Doctos de Entrada foram excluídos."
		MsgInfo(cMsg)
	Else
		BEGIN TRANSACTION

			&(cAli)->(dbGoTop())
			Do While !&(cAli)->(EOF())
				_cNumCot := &(cAli)->(DTC_NUMCOT)

				//rotina automatica para exclusao do Docto Entrada

				aCabDTC := {{"DTC_FILIAL", &(cAli)->(DTC_FILIAL), 	Nil},;
				{"DTC_FILORI", &(cAli)->(DTC_FILORI), 	Nil},;
				{"DTC_LOTNFC", &(cAli)->(DTC_LOTNFC), 	Nil},;
				{"DTC_CLIREM", &(cAli)->(DTC_CLIREM), 	Nil},;
				{"DTC_LOJREM", &(cAli)->(DTC_LOJREM), 	Nil},;
				{"DTC_DATENT", &(cAli)->(DTC_DATENT), 	Nil},;
				{"DTC_CLIDES", &(cAli)->(DTC_CLIDES), 	Nil},;
				{"DTC_LOJDES", &(cAli)->(DTC_LOJDES), 	Nil},;
				{"DTC_NUMCOT", &(cAli)->(DTC_NUMCOT), 	Nil},;
				{"DTC_CLIDEV", &(cAli)->(DTC_CLIDEV), 	Nil},;
				{"DTC_LOJDEV", &(cAli)->(DTC_LOJDEV), 	Nil},;
				{"DTC_CLICAL", &(cAli)->(DTC_CLICAL), 	Nil},;
				{"DTC_LOJCAL", &(cAli)->(DTC_LOJCAL), 	Nil},;
				{"DTC_DEVFRE", &(cAli)->(DTC_DEVFRE), 	Nil},;
				{"DTC_SERTMS", &(cAli)->(DTC_SERTMS), 	Nil},;
				{"DTC_TIPTRA", &(cAli)->(DTC_TIPTRA), 	Nil},;
				{"DTC_SERVIC", &(cAli)->(DTC_SERVIC), 	Nil},;
				{"DTC_TIPNFC", &(cAli)->(DTC_TIPNFC), 	Nil},;
				{"DTC_TIPFRE", &(cAli)->(DTC_TIPFRE), 	Nil},;
				{"DTC_SELORI", &(cAli)->(DTC_SELORI), 	Nil},;
				{"DTC_CDRORI", &(cAli)->(DTC_CDRORI), 	Nil},;
				{"DTC_CDRDES", &(cAli)->(DTC_CDRDES), 	Nil}}

				aItem :=	  {{"DTC_NUMNFC", &(cAli)->(DTC_NUMNFC), 	Nil},;
				{"DTC_SERNFC", &(cAli)->(DTC_SERNFC), 	Nil},;
				{"DTC_CODPRO", &(cAli)->(DTC_CODPRO), 	Nil},;
				{"DTC_CODEMB", &(cAli)->(DTC_CODEMB), 	Nil},;
				{"DTC_EMINFC", &(cAli)->(DTC_EMINFC), 	Nil},;
				{"DTC_QTDVOL", &(cAli)->(DTC_QTDVOL), 	Nil},;
				{"DTC_PESO"  ,	&(cAli)->(DTC_PESO)  , 	Nil},;
				{"DTC_PESOM3", &(cAli)->(DTC_PESOM3), 	Nil},;
				{"DTC_VALOR" ,	&(cAli)->(DTC_VALOR) , 	Nil},;
				{"DTC_BASSEG", &(cAli)->(DTC_BASSEG), 	Nil},;
				{"DTC_QTDUNI", &(cAli)->(DTC_QTDUNI), 	Nil},;
				{"DTC_EDI"	 ,	&(cAli)->(DTC_EDI)   , 	Nil},;
				{"DTC_ESTORN", &(cAli)->(DTC_ESTORN), 	Nil}}

				AAdd(aItemDTC,aClone(aItem))

				MSExecAuto({|u,v,x,y,z| TMSA050(u,v,x,y,z)},aCabDTC,aItemDTC,,,5)

				If lMsErroAuto
					MostraErro()
				EndIf

				&(cAli)->(dbSkip())

			EndDo

			&(cAli)->(dbCloseArea())


			// Exclusão da tabela DTP (Lote)
			cQuery := " SELECT * "
			cQuery += " FROM  "+RetSqlTab("DTP")
			cQuery += " WHERE "+RetSqlFil("DTP")+" AND "
			cQuery += "         DTP_LOTNFC = '"+MV_PAR01+"' AND "
			cQuery += "       "+RetSqlDel("DTP")
			TCQuery ChangeQuery(cQuery) New Alias &(cAli)

			aCabDTP := {}
			aCabDTP := {{"DTP_LOTNFC", &(cAli)->(DTP_LOTNFC)	, Nil},;
			{"DTP_QTDLOT", &(cAli)->(DTP_QTDLOT)	, Nil},;
			{"DTP_QTDDIG", &(cAli)->(DTP_QTDDIG)	, Nil},;
			{"DTP_TIPLOT", &(cAli)->(DTP_TIPLOT)	, Nil},;
			{"DTP_STATUS", &(cAli)->(DTP_STATUS)	, Nil},;
			{"DTP_EMPORI", &(cAli)->(DTP_EMPORI)	, Nil},;
			{"DTP_FILORI", &(cAli)->(DTP_FILORI)	, Nil}}

			lMsErroAuto := .F.

			MsExecAuto({|x, y| TMSA170(x, y)}, aCabDTP, 5)

			If lMsErroAuto
				MostraErro()
			EndIf

			&(cAli)->(dbCloseArea())

			// Exclusão da tabela DT4 (Cotação)
			cQuery := " SELECT * "
			cQuery += " FROM  "+RetSqlTab("DT4")
			cQuery += " WHERE "+RetSqlFil("DT4")+" AND "
			cQuery += "         DT4_NUMCOT = '"+_cNumCot+"' AND "
			cQuery += "       "+RetSqlDel("DT4")
			TCQuery ChangeQuery(cQuery) New Alias &(cAli1)

			aCabDT4 := {}
			aCabDT4 := {{"DT4_FILIAL" 	, &(cAli1)->(DT4_FILIAL)    	,Nil},;
			{"DT4_FILORI"  , &(cAli1)->(DT4_FILORI)      ,Nil},;
			{"DT4_NUMCOT"  , &(cAli1)->(DT4_NUMCOT)      ,Nil},;
			{"DT4_DATCOT"  , &(cAli1)->(DT4_DATCOT)      ,Nil},;
			{"DT4_HORCOT"  , &(cAli1)->(DT4_HORCOT)      ,Nil},;
			{"DT4_DDD"	 	, &(cAli1)->(DT4_DDD)   		,Nil},;
			{"DT4_TEL" 		, &(cAli1)->(DT4_TEL)   		,Nil},;
			{"DT4_PRZVAL" 	, &(cAli1)->(DT4_PRZVAL) 		,Nil},;
			{"DT4_TIPFRE"  , &(cAli1)->(DT4_TIPFRE)      ,Nil},;
			{"DT4_USER"    , &(cAli1)->(DT4_USER)        ,Nil},;
			{"DT4_SELORI" 	, &(cAli1)->(DT4_SELORI)	   ,Nil},;
			{"DT4_CDRORI" 	, &(cAli1)->(DT4_CDRORI) 		,Nil},;
			{"DT4_CDRDES" 	, &(cAli1)->(DT4_CDRDES) 		,Nil},;
			{"DT4_SERTMS" 	, &(cAli1)->(DT4_SERTMS)	   ,Nil},;
			{"DT4_TIPTRA" 	, &(cAli1)->(DT4_TIPTRA) 	   ,Nil},;
			{"DT4_SERVIC"	, &(cAli1)->(DT4_SERVIC)		,Nil},;
			{"DT4_TABFRE" 	, &(cAli1)->(DT4_TABFRE) 		,Nil},;
			{"DT4_TIPTAB" 	, &(cAli1)->(DT4_TIPTAB) 		,Nil},;
			{"DT4_SEQTAB" 	, &(cAli1)->(DT4_SEQTAB) 		,Nil},;
			{"DT4_STATUS"  , &(cAli1)->(DT4_STATUS)      ,Nil},;
			{"DT4_USRAPV" 	, &(cAli1)->(DT4_USRAPV) 		,Nil},;
			{"DT4_PESSOA"  , &(cAli1)->(DT4_PESSOA)      ,Nil},;
			{"DT4_TIPNFC"  , &(cAli1)->(DT4_TIPNFC)      ,Nil},;
			{"DT4_DISTIV"  , &(cAli1)->(DT4_DISTIV)      ,Nil},;
			{"DT4_INCISS"  , &(cAli1)->(DT4_INCISS)      ,Nil},;
			{"DT4_MOEDA"   , &(cAli1)->(DT4_MOEDA)       ,Nil},;
			{"DT4_CONTRI"  , &(cAli1)->(DT4_CONTRI)      ,Nil},;
			{"DT4_CADPOR"  , &(cAli1)->(DT4_CADPOR)      ,Nil}} 

			// Exclusão da tabela DVF (Itens da Cotação)
			cQuery := " SELECT * "
			cQuery += " FROM  "+RetSqlTab("DVF")
			cQuery += " WHERE "+RetSqlFil("DVF")+" AND "
			cQuery += "         DVF_NUMCOT = '"+_cNumCot+"' AND "
			cQuery += "       "+RetSqlDel("DVF")
			TCQuery ChangeQuery(cQuery) New Alias &(cAli2)

			aItemDVF := {}
			aItemDVF := {{"DVF_FILIAL" , &(cAli2)->(DVF_FILIAL) 		,Nil},;
			{"DVF_FILORI" , &(cAli2)->(DVF_FILORI) 		,Nil},;
			{"DVF_NUMCOT" , &(cAli2)->(DVF_NUMCOT) 		,Nil},;
			{"DVF_ITEM" 	, &(cAli2)->(DVF_ITEM)   		,Nil},;
			{"DVF_CODPRO" , &(cAli2)->(DVF_CODPRO)		,Nil},;
			{"DVF_CODEMB" , &(cAli2)->(DVF_CODEMB) 		,Nil},;
			{"DVF_QTDVOL" , &(cAli2)->(DVF_QTDVOL) 		,Nil},;
			{"DVF_QTDUNI" , &(cAli2)->(DVF_QTDUNI)      ,Nil},;
			{"DVF_PESO" 	, &(cAli2)->(DVF_PESO)   		,Nil},;
			{"DVF_VALMER"	, &(cAli2)->(DVF_VALMER)	   ,Nil}}

			lMsErroAuto := .F.

			MSExecAuto({|u,v,x,y,z| TMSA040(u,v,x,y,z)},aCabDT4,{aItemDVF},5)

			If lMsErroAuto
				MostraErro()
			EndIf

			&(cAli1)->(dbCloseArea())
			&(cAli2)->(dbCloseArea())

			// Limpa Num. Cotação no campo F2_COTTMS da empresa 01 para poder ser processado novamente
			cCotacao := Space(06)
			_cQuery := "UPDATE SF2010"
			_cQuery += " SET F2_COTTMS = '" + cCotacao + "' "
			_cQuery += " WHERE D_E_L_E_T_ <> '*'"
			_cQuery += " AND F2_COTTMS = '" + _cNumCot + "' "
			_cQuery += " AND F2_FILIAL = '00' "
			TcSqlExec(_cQuery)

		END TRANSACTION

		MsgInfo("Processo Finalizado.")

	EndIf

	RestArea(aArea)

Return
