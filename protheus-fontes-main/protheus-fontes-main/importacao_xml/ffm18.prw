#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Rwmake.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"


#DEFINE ENTER Chr(13)+Chr(10)

User Function FFM18()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ FFM18 ³ Autor ³ Fabian Maurer      ³ Data ³ 10/03/16		  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Importa os arquivos XML como uma nf de entrada Reiter	  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ4ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para clientes TOTVS                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local _aArea    	:= FWGetArea()
	Local lWeb          := .F.
	Local aFiles        := {}
	Local nX            := 0
	Local _i
	Private _filal		:= cfilant	
	Private cPerg  		:= "FFM18"
	Private aContas     := {}
	Private cIniFile    := GetAdv97()
	Private cStartPath  := ""
	/*  Ajuste feito por Flávio para que a importação dos XMls do Confinamento sejam contemplados - Dia 19/12/17*/
	If cfilant = "02"
		cStartPath  := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "CTE\ENTRADA\CONFINAMENTO\"
	elseif cfilant = "00"
		cStartPath  := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "CTE\ENTRADA\"
	Endif
	Private cStartLido  := ""
	/*  Ajuste feito por Flávio para que a importação dos XMls do Confinamento sejam contemplados - Dia 19/12/17*/
	If cfilant = "02"
		corte := alltrim(substr(Trim(cStartPath),1,20))
		cStartLido  := corte + "OLD\"
	elseif cfilant = "00"
		cStartLido  := Trim(cStartPath) + "OLD\"
	Endif
	Private cStartLog   := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "CTE\LOG\"
	Private c2StartPath := Trim(cStartLido) + AllTrim(Str(Year(Date()))) + "\"
	Private c3StartPath := Trim(c2StartPath) + AllTrim(Str(Month(Date()))) + "\"
	Private cStartError := ""

	/*  Ajuste feito por Flávio para que a importação dos XMls do Confinamento sejam contemplados - Dia 19/12/17*/
	If cfilant = "02"
		corte2 := alltrim(substr(Trim(cStartPath),1,20))
		cStartError := corte2 + "ERRO\"	
	elseif cfilant = "00"
		cStartError := Trim(cStartPath) + "ERRO\"
	Endif
	Private _sArqLog 	  := alltrim(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ))+"\cte\log\IMPCTE_"+dtos(ddatabase)+"_"+strtran(left(time(),5),":","")+".TXT"
	Private _cLog		  := ""
	Private _nImpOk 	  := 0
	Private cEmailTo 	  := "" 		     	// Indica a conta de e-mail do campo FROM no envio dos e-mails internos de processamento dos arquivos XML
	Private _npar03       := 0
	Private _npar01
	Private _npar04
	Private _nRetorno	  := 0 
	Private _cTagTom	  := ""

	if !pergunte(cPerg,.T.)
		return .f.
	endif

	// Verifica se está rodando via menu ou schedule
	If Select("SX6") == 0
		lWeb := .T.
		RpcSetType(3)
		RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
	EndIf

	if cEmpAnt <> '01'
		Alert("Rotina não será executada para a empresa selecionada.")
		Return
	Endif
	/*Email do Parametro - Contabilidade2@frigorificosilva.com.br*/
	cEmailto := Alltrim(GetMv("PS_CTEMAIL"))

	// Cria Diretórios
	MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'CTE\')
	MakeDir(Trim(cStartPath))	    	// Cria Diretório ENTRADA
	MakeDir(cStartLido)             	// Cria Diretório ARQUIVOS IMPORTADOS
	MakeDir(c2StartPath)            	// Cria Diretório ANO
	MakeDir(c3StartPath)            	// Cria Diretório MES
	MakeDir(cStartError)            	// Cria Diretório ERRO
	MakeDir(cStartLog)              	// Cria Diretório LOG

	aNotFiles := Directory(cStartPath+"*.*")
	For _i := 1 to len(aNotFiles)
		if upper(right(alltrim(aNotFiles[_i,1]),4)) <> '.XML'
			FErase(cStartPath+aNotFiles[_i,1])
		Endif
	Next _i

	aFiles := Directory(cStartPath + "*.xml")
	nXml   := 0

	If Len(aFiles) > 0
		_cLog := "IMPORTAÇÃO DE "+transform(Len(aFiles),"@E 999")+" ARQUIVOS DE XML CTE" +ENTER
	Endif

	_npar01		  := mv_par01
	_npar03       := mv_par02
	_npar04		  := mv_par03

	// Identifica o CNPJ que será importado o XML
	For nX := 1 To Len(aFiles)
		cFilBk := cFilAnt
		nRegSM0 := SM0->(Recno())
		nXml++
		MsAguarde({|| _ImpCTE(alltrim(aFiles[nX,1]),.T.,_npar04,_npar03)},"Aguarde","Importando dados do arquivo XML...",.F.)
		SM0->(DbGoTo(nRegSM0))
		cFilant := cFilBk
		// Quando tiver 500 XML sai da rotina, senão estoura o array do XML
		If nXml == 500
			//Return
			Exit
		EndIf
	Next nX

	if !Empty(_cLog)
		_cLog += ENTER
		_cLog += "XML CTE IMPORTADOS:     "+Transform(_nImpOK,"@E 999")+ENTER
		_cLog += "XML CTE NÃO IMPORTADOS: "+Transform(Len(afiles)-_nImpOK,"@E 999")+ENTER
		_log(_cLog)
		U_EnvMail1('',cEmailTo,'',_cLog,' LOG Importacao XML CTe' ,"")
	Endif

	If lWeb
		RpcClearEnv()
	Endif

	FWRestArea(_aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ _IMPCTE  ³ Autor ³ Evandro Mugnol        ³ Data ³ Mar/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para leitura de XMLs de CTE e importação diretamente³±±
±±³          ³ como nota de entrada                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function _ImpCTE(cFile,lJob,_cICMS,_cTip)
	Local cXML      := ""
	Local cError    := ""
	Local cWarning  := ""
	//Local cCGC	    := ""
	Local cDoc	    := ""
	Local cSerie    := ""
	Local cLoja	    := ""
	Local cCliFor	:= "      "
	Local nVUnit    := 0
	Local lFound    := .F.
	Local lProces   := .T.
	Local nX	    := 0
	//Local nY		:= 0
	Local oFullXML  := NIL
	Local oAuxXML   := NIL
	Local oXML	    := NIL
	Local aItens    := {}
	Local aHeadSF1  := {}
	Local aItemSD1  := {}
	Local aAuxItm   := {}
	//Local oDlg
	Local cFilAnt 	:= ""
	Local cEmpAnt 	:= ""
	Local _cTagEMIT := "              "
	Local _cTagREM 	:= "              " // Vem de oXML:_INFCTE:_REM:_CNPJ:TEXT
	Local _cTagDEST := "              " // Vem deoXML:_INFCTE:_DEST:_CNPJ:TEXT
	//Local _FRIGREM  := "              "
	//Local _FRIGRE2  := "              "
	Local _cConfir 	:= "N"
	Local _cMU 		:= ""
	Local _cMUR		:= ""
	Local _cMUO		:= ""
	Local _cMUD		:= ""
	Local _cUFO		:= ""
	Local _cUFD		:= ""
	Local cMUORITR 	:= ""
	Local cMUDESTR 	:= ""
	Local cUFORITR  := ""
	Local cUFDESTR  := ""
	local _cCGCEMT  := GETMV('SI_CGCEMIT')
	local _cCGCEM3  := GETMV('SI_CGCEMI3')  // continuação do parâmetro "SI_CGCEMIT"
	local _cCGCEM2  := GETMV('SI_CGCEMI2')
	Local _cCGCEM4	:= GETMV('SI_CGCEMI4')

	Default lJob 	:= .T.

	If !File(cStartPath +cFile)
		_cLog += padr("Erro: Arquivo Inexistente.",85)+"Arquivo: "+cFile+ENTER
		lProces := .F.
	Else
		cXML := MemoRead(cStartPath +cFile)
		//-- Nao processa NFE
		If "</NFE>" $ Upper(cXML)
			FErase(cStartPath+cFile)
			lProces := .F.
			_cLog += padr("Erro: XML referente a NFE.",85)+"Arquivo: "+cFile+ENTER
		EndIf
		if lProces
			If "</CANCNFE>" $ Upper(cXML) .OR. "</CANCCTE>" $ Upper(cXML)
				FErase(cStartPath+cFile)
				lProces := .F.
				_cLog += padr("Erro: XML referente a cancelamento de NFE ou CTE.",85)+"Arquivo: "+cFile+ENTER
			EndIf
		Endif
	EndIf

	//* inclusão da tag toma03*//

	If lProces
		oFullXML := XmlParserFile(cStartPath + cFile,"_",@cError,@cWarning)

		//-- Erro na sintaxe do XML
		If Empty(oFullXML) .Or. !Empty(cError)
			_cLog += padr("Erro: Sintaxe XML.",85)+"Arquivo: "+cFile+ENTER
			//_MoveArq(cFile,1)
			lProces := .F.
		Else
			oXML    := oFullXML
			oAuxXML := oXML

			//-- Resgata o no inicial da NF-e
			While !lFound
				oAuxXML := XmlChildEx(oAuxXML,"_CTE")
				If !(lFound := oAuxXML # NIL)
					For nX := 1 To XmlChildCount(oXML)
						oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_CTE")
						lFound := oAuxXML:_InfCte # Nil
						If lFound
							oXML := oAuxXML
							Exit
						EndIf
					Next nX
				EndIf

				If lFound
					oXML := oAuxXML
					Exit
				EndIf
			EndDo

			// Verificação se existe o "CPF" no campo ou repetente ou Destinatário
			IF (XmlChildEx(oXML:_INFCTE:_REM,"_CPF") <> NIL) .AND. (XmlChildEx(oXML:_INFCTE:_DEST,"_CPF") <> NIL)
				/* Inclusão dia 12/11/19 - Por Flávio */
				_cTagREM  := oXML:_INFCTE:_REM:_CPF:TEXT
				_cTagDEST := AllTrim(oXml:_INFCTE:_DEST:_CPF:TEXT)
				_cTagEMIT := oXML:_INFCTE:_EMIT:_CNPJ:TEXT
			Elseif (XmlChildEx(oXML:_INFCTE:_REM,"_CPF") <> NIL)
				_cTagREM  := oXML:_INFCTE:_REM:_CPF:TEXT
				_cTagDEST := oXML:_INFCTE:_DEST:_CNPJ:TEXT
				_cTagEMIT := oXML:_INFCTE:_EMIT:_CNPJ:TEXT
			Elseif (XmlChildEx(oXML:_INFCTE:_DEST,"_CPF") <> NIL)
				_cTagREM := oXML:_INFCTE:_REM:_CNPJ:TEXT		
				_cTagDEST := AllTrim(oXml:_INFCTE:_DEST:_CPF:TEXT)
				_cTagEMIT  := oXML:_INFCTE:_EMIT:_CNPJ:TEXT
			Else
				_cTagREM := oXML:_INFCTE:_REM:_CNPJ:TEXT
				_cTagDEST := oXML:_INFCTE:_DEST:_CNPJ:TEXT
				_cTagEMIT  := oXML:_INFCTE:_EMIT:_CNPJ:TEXT
			Endif

			If _cTagREM = "88728027000146"
				cCNPJInf  := oXML:_INFCTE:_REM:_CNPJ:TEXT
			elseif _filal =  "00" .AND. _cTagDEST = "88728027000146"		
				cCNPJInf  := oXML:_INFCTE:_DEST:_CNPJ:TEXT
			elseif _filal = "02" .AND. _cTagDEST = "88728027000731"
				cCNPJInf  := oXML:_INFCTE:_DEST:_CNPJ:TEXT	
			Else
				/* 13/11/19 - Flávio -  Criado Remetentes ou destinatários que não são o frigorífico 
				Identificado em Notas do Reiter este caso			
				*/
				cCNPJInf  := "88728027000146"
			Endif

			/*No caso de algumas empresas em específico - Criado parâmetro SI_CGCEMIT SI_CGCEMIT 					
			Dia 27/07/18  Feito por Flávio - Ajuste feito para buscar CNPJ da variável _cCGCEMT  */				 
			/*  Criar regra para toma4 com base na  ---	 (XmlChildEx(oXML:_INFCTE:_DEST,"_CPF") <> NIL)
			*/			
			/*   dia 19/11 ajuste de Tomas - Flávio
			_cTip = 1  é sobre venda
			_cTip = 2  é sobre Compra
			Exemplos de Tomador
			-  para tomador = 0-Remetente
			-  para tomador = 1-expedidor
			-  para tomador = 2-recebedor
			-  para tomador = 3-destinatário
			-  para tomador = 4-Outros
			-> fazer validações desta forma que acho que vai resolver 
			*/

			If _cTagEMIT $ _cCGCEM4 .AND. _cTip = 1
				// Se frete sobre venda
				// Regra criada para quando possuir tag TOMA3 ou TOMA4
				IF (XmlChildEx(oXML:_INFCTE:_IDE,"_TOMA3") <> NIL)
					_cTagTom := oXML:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT
				ElseIF (XmlChildEx(oXML:_INFCTE:_IDE,"_TOMA4") <> NIL)
					_cTagTom := oXML:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT
				Endif
			Elseif _cTagEMIT $ _cCGCEM4 .AND. _cTip = 2
				// Se frete sobre compra
				// Regra criada para quando possuir tag TOMA3 ou TOMA4
				IF (XmlChildEx(oXML:_INFCTE:_IDE,"_TOMA3") <> NIL)
					_cTagTom := oXML:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT
				ElseIF (XmlChildEx(oXML:_INFCTE:_IDE,"_TOMA4") <> NIL)
					_cTagTom := oXML:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT
				Endif
			Elseif _cTagEMIT $ _cCGCEMT .OR. _cTagEMIT $ _cCGCEM3
				IF (XmlChildEx(oXML:_INFCTE:_IDE,"_TOMA3") <> NIL)
					_cTagTom := oXML:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT
				ElseIF (XmlChildEx(oXML:_INFCTE:_IDE,"_TOMA4") <> NIL)
					_cTagTom := oXML:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT
				Endif
				//_cTagTom := oXML:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT
			elseif (XmlChildEx(oXML:_INFCTE:_IDE,"_TOMA4") = NIL) // demais Empresas
				_cTagTom := oXML:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT
			else
				alert('CNPJ não cadastrado , Favor solicitar a TI para Cadstrar em SI_CGCEMIT ou SI_CGCEMI3')
			endif
			_cPICMS := 0
			/*Inclusão a pedido do Henrique para complementar Entrada e gerar arquivo SPED Correta - Flávio 14/03/18 - 31/08/2018*/
			cMUORITR := oXML:_INFCTE:_REM:_ENDERREME:_CMUN:TEXT
			cMUDESTR := oXML:_INFCTE:_DEST:_ENDERDEST:_CMUN:TEXT
			cUFORITR := oXML:_INFCTE:_REM:_ENDERREME:_UF:TEXT   //Continuação da alteração 31/08/2018
			cUFDESTR := oXML:_INFCTE:_DEST:_ENDERDEST:_UF:TEXT  //Continuação da alteração 31/08/2018

			If _cTagTom = "0" .and. _cTagREM <> "88728027000146"
				/* Interromper importação de xml */     				        	
				//Inserir gravação no log
				_cLog += padr("Erro 0: Tomador Remetente não refere-se ao Frigorífico Silva ",85)+"Arquivo: "+cFile+ENTER
				lProces := .F. 			
				Return        	

			ElseIF _cTagTom = "3" 
				If cfilant = "00" .AND. _cTagDEST <> "88728027000146"
					/* Interromper importação de xml*/
					_cLog += padr("Erro 3: Tomador Destinatário não refere-se ao Frigorífico Silva ",85)+"Arquivo: "+cFile+ENTER
					Return
				Elseif cfilant = "02" .AND. _cTagDEST <> "88728027000731"
					/* Interromper importação de xml*/       
					_cLog += padr("Erro 3: Tomador Destinatário não refere-se ao Frigorífico Silva ",85)+"Arquivo: "+cFile+ENTER
					Return
				Endif

			ElseIF _cTagTom = "1" .and. _cTagEMIT <> "88728027000146"			
				/* Interromper importação de xml*/       
				_cLog += padr("Erro 1: Tomador Emitente não refere-se ao Frigorífico Silva ",85)+"Arquivo: "+cFile+ENTER        	
				Return
			EndIf        

			_lAchou := .F.
			dbSelectArea("SM0")
			dbSetOrder(1)
			dbGoTop()

			While !Eof()
				If M0_CGC == cCNPJInf
					_lAchou := .T.
					cFilAnt := M0_CODFIL
					cEmpAnt := M0_CODIGO
					Exit
				EndIf
				dbSkip()
			End

			if !_lAchou
				lProces := .F.
				_cLog += padr("Erro: Remetente inválido. CNPJ: "+cCnpjInf,85)+"Arquivo: "+cFile+ENTER
			Endif

			if lProces
				lFound := .F.
				//-- Verifica se este ID ja foi processado
				DbSelectArea("SF1")
				SF1->(DbSetOrder(8))
				lFound := SF1->(MsSeek(FWxFilial("SF1")+Right(AllTrim(oXML:_InfCte:_Id:Text),44)))//Filial + Chave de acesso
				//PEGA A IDENT
				cIdEnt := U_WSAT01GetIdEnt()
				//VERIFICA O STATUS NA RECEITA FEDERAL E EM CASO DE REJEICAO NAO IMPORTA
				aStatus := U_CoNFeChv(Right(AllTrim(oXML:_InfCte:_Id:Text),44),cIdEnt,.T.)

				If aStatus[1]
					_cLog += padr("Erro: Código erro Sefaz: "+alltrim(aStatus[3]),85)+"Arquivo: "+cFile+ENTER				
					lProces := .F.
				EndIf
			Endif

			If lProces .and. lFound
				_cLog += padr("Aviso: ID de CTe já registrado na NF "+SF1->(F1_DOC+"/"+F1_SERIE)+" do fornecedor " +SF1->(F1_FORNECE+"/"+F1_LOJA),85)+"Arquivo: "+cFile+ENTER
				_MoveArq(cFile,1)
				lProces := .F.
			EndIf
			//-- Se ID valido
			//-- Extrai tag _InfNfe:_Det
			If lProces
				If ValType(oXML:_InfCte:_vPrest) == "O"
					aItens := {oXML:_InfCte:_vPrest}
				ElseIf ValType(oXML:_InfCte:_vPrest) == "U"
					_cLog += padr("Erro: TAG _InfCte:_vPrest não localizada",85)+"Arquivo: "+cFile+ENTER
					lProces := .F.
				Else
					aItens := oXML:_InfCte:_vPrest
				EndIf
			EndIf

			If lProces
				//Regra de leitura dos XMls Feito por Maurício e  Flávio
				//1 - Frete sobre Venda - Entrada normal
				//- Destinatário (SA1 - Cliente Do Frigorífico) - Fazer validaçãAo
				//- Remetente sempre o Frigorífico Silva (CNPJ - 88728027000146)

				//	1.2 - Devoluções - Frete sobre Venda
				//	- Destinatário Frigorífico Silva (CNPJ - 88728027000146)
				//	- Remetente (SA1 - Cliente Do Frigorífico)

				//OBS - SB1 - Produto sempre o 900002 - o Tês e centro de custo buscar no cadastro do Produto

				//2 - Frete sobre Compra - Entrada normal
				//- Destinatário Frigorífico Silva (CNPJ - 88728027000146)
				//- Remetente (SA2 - Fornecedor Do Frigorífico)

				//	2.1 - Devoluções - Frete sobre Compra
				//	- Destinatário (SA2 - Fornecedor Do Frigorífico)
				//	- Remetente Frigorífico Silva (CNPJ - 88728027000146)

				//OBS - SB1 - Produto sempre o 900001 - o Tês e centro de custo buscar no cadastro do Produto

				//mv_par01  - venc.
				//mv_par02 - 1 = Venda(900002) e 2 = Compra(900001)
				// Este é para os fretes sobre venda
				If _cTagREM = "88728027000146"  .and. _cConfir = "N"//  Remetente Frigorífico Silva (CNPJ - 88728027000146)
					DbSelectArea('SA2')
					SA2->(dbSetOrder(3))
					SA2->(dbGoTop())

					DbSelectArea('SA1')
					SA1->(dbSetOrder(3))
					SA1->(dbGoTop())

					DbSelectArea('SB1')
					SB1->(dbSetOrder(1))
					SB1->(dbGoTop())
					// Regra para Cliente 
					if SA1->(MsSeek(FWxFilial('SA1') + alltrim(_cTagDEST))) .and. _npar03 = 1 .and. _cConfir = "N" //se encontrar na tabela um registro com o valor da variavel
						// 1 - Frete sobre Venda - Entrada normal  - Prod 900002
						cCliFor := GetAdvFVal('SA2','A2_COD',FWxfilial('SA2') +alltrim(_cTagEMIT),3)
						cLoja := GetAdvFVal('SA2','A2_LOJA',FWxfilial('SA2') +alltrim(_cTagEMIT),3)
						if alltrim(_cTagEMIT) $ '15644558000187|23375078000228|27375078000228|00384709000138'
							MsSeek(FWxFilial('SB1') + "900056")
							cTes  := SB1->B1_TE
							cCC   := SB1->B1_CC
							cCod  := SB1->B1_COD
							cAIcm := 17
							_cConfir := "S"
						/*
						Criado por Flávio dia28/02/19 - Solicitado Por Ana Maidana
						Foi criado o Parâmetro mv_par03 para quando tivermos xmls do CNPJ 10466983000100 e tiver _cICMS a 12 % o sistema gravar o produto  900061.
						Nos demais casos para este CNPJ o sistema deve gravar o produto 900002.
						OBS - Tentei buscar da TAG do XML mas não dá porque quando esta tag não vem com informação o sistema da erro.
						*/
						elseif alltrim(_cTagEMIT) $ '10466983000100|10466983001009|06173279000191' .AND. _cICMS = 1
							MsSeek(FWxFilial('SB1') + "900061")
							cTes  := SB1->B1_TE
							cCC   := SB1->B1_CC
							cCod  := SB1->B1_COD
							_cConfir := "S"
						elseif alltrim(_cTagEMIT) $ _cCGCEM2
							MsSeek(FWxFilial('SB1') + "900061")
							cTes  := SB1->B1_TE
							cCC   := SB1->B1_CC
							cCod  := SB1->B1_COD
							_cConfir := "S"
						elseif alltrim(_cTagEMIT) = '58890252000547|58890252000113'
							If produto = "900038" .or. produto = "900003"
								MsSeek(FWxFilial('SB1') + "900038")
								cTes  := SB1->B1_TE
								cCC   := SB1->B1_CC
								cCod  := SB1->B1_COD
								_cConfir := "S"
							endif
						else
							MsSeek(FWxFilial('SB1') + "900002")
							cTes  := SB1->B1_TE
							cCC   := SB1->B1_CC
							cCod  := SB1->B1_COD
							_cConfir := "S"
						endif
					elseif SA2->(MsSeek(FWxFilial('SA2') + alltrim(_cTagDEST)))  .and. _npar03 = 2 .and. _cConfir = "N"//se encontrar na tabela um registro com o valor da variavel
						// 2.1 - Devoluções - Frete sobre Compra  - Prod 900001
						cCliFor := GetAdvFVal('SA2','A2_COD',FWxfilial('SA2') + _cTagEMIT,3)
						cLoja := GetAdvFVal('SA2','A2_LOJA',FWxfilial('SA2') + _cTagEMIT,3)
						MsSeek(FWxFilial('SB1') + "900001")
						cTes  := SB1->B1_TE
						cCC   := SB1->B1_CC
						cCod  := SB1->B1_COD
						_cConfir := "S"
						// Regra só será testada quando tiver uma situação que conforme Henrique (contabilidade) é muito raro
					Endif
				Elseif _cTagDEST = "88728027000146" .and. _cConfir = "N"// Destinatário Frigorífico Silva (CNPJ - 88728027000146)
					DbSelectArea('SA2')
					SA2->(dbSetOrder(3))
					SA2->(dbGoTop())

					DbSelectArea('SA1')
					SA1->(dbSetOrder(3))
					SA1->(dbGoTop())

					DbSelectArea('SB1')
					SB1->(dbSetOrder(1))
					SB1->(dbGoTop())

					if SA1->(MsSeek(FWxFilial('SA1') + alltrim(_cTagREM)))  .and. _npar03 = 1 .and. _cConfir = "N"//se encontrar na tabela um registro com o valor da variavel
						//	1.2 - Devoluções - Frete sobre Venda				
						cCliFor := GetAdvFVal('SA2','A2_COD',FWxfilial('SA2') + _cTagEMIT,3)
						cLoja := GetAdvFVal('SA2','A2_LOJA',FWxfilial('SA2') + _cTagEMIT,3)
						if alltrim(_cTagEMIT) = '15644558000187' //Alterado a pedido da Ana 27/08/18
							MsSeek(FWxFilial('SB1') + "900056")
							cTes  := SB1->B1_TE
							cCC   := SB1->B1_CC
							cCod  := SB1->B1_COD
							cAIcm := 17
							_cConfir := "S"
						elseif alltrim(_cTagEMIT) = '22156176000170'   // Alterado a pedido Rayner 24/09/18
							/*  Dia 19/09 - Teve uma exceção de uma nota de devolução do cidadão "90094848000624" que precisou que o produto fosse o 900061
							então Flávio incluiu o CNPJ na marra com a regra abaixo:
							.or. alltrim(_cTagEMIT) = '90094848000624'
							Mas como é exceção foi retirado a regra
							*/
							MsSeek(FWxFilial('SB1') + "900061")
							cTes  := SB1->B1_TE
							cCC   := SB1->B1_CC
							cCod  := SB1->B1_COD
							_cConfir := "S"
						else
							MsSeek(FWxFilial('SB1') + "900002")
							cTes  := SB1->B1_TE
							cCC   := SB1->B1_CC
							cCod  := SB1->B1_COD
							_cConfir := "S"
						endif
						// Regra ok dia 10/08/2016
					Elseif SA2->(MsSeek(FWxFilial('SA2') + alltrim(_cTagREM)))  .and. _npar03 = 2 .and. _cConfir = "N"//se encontrar na tabela um registro com o valor da variavel
						//	2 - Frete sobre Compra - Entrada normal
						cCliFor := GetAdvFVal('SA2','A2_COD',FWxfilial('SA2') + _cTagEMIT,3)
						cLoja := GetAdvFVal('SA2','A2_LOJA',FWxfilial('SA2') + _cTagEMIT,3)
						MsSeek(FWxFilial('SB1') + "900001")
						cTes  := SB1->B1_TE
						cCC   := SB1->B1_CC
						cCod  := SB1->B1_COD
						_cConfir := "S"
						// Regra a ser testada................pedido para testar dia 10/08/2016
					Endif
					/* Importação de Fretes Gado Confinamento */
				Elseif alltrim(_cTagDEST) = '57495459034'
					/* Ajuste solicitado por Fabiane dia 06/02/2020 - Feito por Flávio
					- Entra aqui se Destinatário e rementente forem diferentes de 88728027000146 entra aqui
					Mas acho que a Fabiane se enganou..
					*/
						cCliFor := GetAdvFVal('SA2','A2_COD',FWxfilial('SA2') + _cTagEMIT,3)
						cLoja := GetAdvFVal('SA2','A2_LOJA',FWxfilial('SA2') + _cTagEMIT,3)
						SB1->(MsSeek(FWxfilial('SB1')+alltrim('900072')))
						cTes  := SB1->B1_TE
						cCC   := SB1->B1_CC
						cCod  := SB1->B1_COD
						_cConfir := "S"
				elseIf alltrim(_cTagDEST) = '18361860000116'
					SB1->(MsSeek(FWxfilial('SB1')+alltrim('900073')))
					// Feito para também importar Destinatário (012752 - FAZENDA JAGUARETE SIMETAL       CNPJ - 18361860000116) 
					cCliFor := GetAdvFVal('SA2','A2_COD',FWxfilial('SA2') + _cTagEMIT,3)
					cLoja := GetAdvFVal('SA2','A2_LOJA',FWxfilial('SA2') + _cTagEMIT,3)
					//MsSeek(FWxFilial('SB1') + "900073")
					cTes  := SB1->B1_TE
					cCC   := SB1->B1_CC
					cCod  := SB1->B1_COD
					_cConfir := "S"
				Else
					/* Valida para quando remetente ou destinatário não for o frigo  */
					/* Dia 13/11/19 - Flávio - Criado para demais casos*/
					DbSelectArea('SA2')
					SA2->(dbSetOrder(3))
					SA2->(dbGoTop())
					cCliFor := GetAdvFVal('SA2','A2_COD',FWxfilial('SA2') + _cTagEMIT,3)
					cLoja := GetAdvFVal('SA2','A2_LOJA',FWxfilial('SA2') + _cTagEMIT,3)
					// _cConfir = "N"//se encontrar na tabela um registro com o valor da variavel
					// //   Frete sobre Venda - Prod 900002 - Quando remetente for CAP LOGISTICA FRIGORIFICADA SA (02956834000109)
					if  alltrim(_cTagREM) = "02956834000109"
						SB1->(MsSeek(FWxfilial('SB1') + "900002"))
						cTes  := SB1->B1_TE
						cCC   := SB1->B1_CC
						cCod  := SB1->B1_COD
						_cConfir := "S"
					//   Frete sobre Compra de GADO CONFINAMENTO - Prod 900001 - Quando destinatário for Frigorífico (88728027000146)
					elseif  alltrim(_cTagDEST) = "88728027000146|58890252000547"
						SB1->(MsSeek(FWxfilial('SB1') + "900001"))
						cTes  := SB1->B1_TE
						cCC   := SB1->B1_CC
						cCod  := SB1->B1_COD
						_cConfir := "S"
					else
						SB1->(MsSeek(FWxfilial('SB1') + "900072"))
						//SB1->(MsSeek(FWxfilial('SB1') + "900003")) // ALterando Daniel 26/04/21 -  (SERVE PARA LANÇAR IDHL - REITER)
						cTes  := SB1->B1_TE
						cCC   := SB1->B1_CC
						cCod  := SB1->B1_COD
						_cConfir := "S"
					Endif
				Endif

				If Empty(cCliFor) .or. Empty(cLoja) .or. Empty(cTes) .or. Empty(cCC) .or. Empty(cCod)
					//_cLog += padr("Erro: Parametros PS_CTExxx incorretos para a filial: "+cFilAnt,85)+"Arquivo: "+cFile+ENTER
					IF Empty(alltrim(cCliFor)) .OR. Empty(cLoja)
						_cLog += padr("Erro: Falta cadastrar Emitente:"+_cTagEMIT+"Parametros PS_CTExxx incorretos : "+cFilAnt,85)+"Arquivo: "+cFile+ENTER
					Elseif Empty(cTes)
						_cLog += padr("Erro: Falta cadastro do TES ,Parametros PS_CTExxx incorretos : "+cFilAnt,85)+"Arquivo: "+cFile+ENTER
					Elseif Empty(cCC)
						_cLog += padr("Erro: Falta cadastro do Contro de Custo ,Parametros PS_CTExxx incorretos : "+cFilAnt,85)+"Arquivo: "+cFile+ENTER
					Elseif  Empty(cCod)
						_cLog += padr("Erro: Falta cadastro do Produto ,Parametros PS_CTExxx incorretos : "+cFilAnt,85)+"Arquivo: "+cFile+ENTER
					endif
					//_MoveArq(cFile,1)
					lProces := .F.
				Endif
			Endif // Fim do lProces

			If lProces .and. _cConfir = "S"
				cDoc    := StrZero(Val(AllTrim(oXML:_InfCte:_Ide:_nCT:Text)),TamSx3("F1_DOC")[1])
				cSerie  := PadR(oXML:_InfCte:_Ide:_Serie:Text,TamSX3("F1_SERIE")[1])
				dEmiss  := StoD(StrTran(left(oXML:_InfCte:_Ide:_DhEmi:Text,10),"-",""))
				cChave  := Iif(ValType("oXML:_InfCte:_Id")<>"U",Right(AllTrim(oXML:_InfCte:_Id:Text),44),"")
				/*Inclusão a pedido do Henrique para complementar Entrada e gerar arquivo SPED Correta - Flávio 14/03/18*/							
				_cMU := alltrim(cMUORITR)
				_cMUR := alltrim(cMUDESTR)
				_cMUO := substr(_cMU,3,7)
				_cMUD := substr(_cMUR,3,7)
				_cUFO := alltrim(cUFORITR) //Continuação da alteração 31/08/2018
				_cUFD := alltrim(cUFDESTR) //Continuação da alteração 31/08/2018

				aHeadSF1 := {}
				aItemSD1 := {}
				aAuxItm  := {}			

				DbSelectArea("SF1")
				aadd(aHeadSF1,{"F1_FILIAL"	,FWxFilial("SF1") ,NIL})
				aadd(aHeadSF1,{"F1_TIPO"	,"N"				 ,NIL})
				aadd(aHeadSF1,{"F1_FORMUL"	,"N"				 ,NIL})
				aadd(aHeadSF1,{"F1_DOC"		,cDoc				 ,NIL})
				aadd(aHeadSF1,{"F1_SERIE"	,cSerie			 ,NIL})
				aadd(aHeadSF1,{"F1_EMISSAO",dEmiss			 ,NIL})
				aadd(aHeadSF1,{"F1_FORNECE",cCliFor			 ,NIL})
				aadd(aHeadSF1,{"F1_LOJA"	,cLoja			 ,NIL})
				aadd(aHeadSF1,{"F1_ESPECIE","CTE"			 ,NIL})
				aadd(aHeadSF1,{"F1_CHVNFE"	,cChave			 ,NIL})
				aadd(aHeadSF1,{"F1_TPFRETE","C"				 ,NIL})
				aadd(aHeadSF1,{"F1_TPCTE"	,"N"				 ,NIL})
				aadd(aHeadSF1,{"F1_UFORITR"	,_cUFO				 ,NIL}) //Continuação da alteração 31/08/2018
				aadd(aHeadSF1,{"F1_MUORITR"	,_cMUO				 ,NIL})
				aadd(aHeadSF1,{"F1_UFDESTR"	,_cUFD 				 ,NIL}) //Continuação da alteração 31/08/2018
				aadd(aHeadSF1,{"F1_MUDESTR"	,_cMUD 				 ,NIL})

				For nX := 1 To Len(aItens)
					nVUnit := round(val(oXML:_InfCte:_vPrest:_vTPrest:Text),2)
					aadd(aAuxItm,{"D1_COD"	,cCod					,NIL})
					aadd(aAuxItm,{"D1_QUANT",1						,NIL})
					aadd(aAuxItm,{"D1_VUNIT",nVUnit				,NIL})
					aadd(aAuxItm,{"D1_TES"	,cTes					,NIL})
					aadd(aAuxItm,{"D1_CC"	,cCC					,NIL})
					If cCod = '900056'
						aadd(aAuxItm,{"D1_PICM"	,cAIcm				,NIL})
					EndIf
					aadd(aItemSD1,aAuxItm)
				Next nX

				If !Empty(aItemSD1) .And. !Empty(aHeadSF1)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os dados do cabeçalho e itens da nota importada do XML          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Begin Transaction
						lMsHelpAuto := .F.  // se .t. direciona as mensagens de help
						lMsErroAuto := .F.  // necessario a criacao
						DbSelectArea("SF1")
						MsExecAuto({|v,x,y,w,z|MATA103(v,x,y,w,z)},aHeadSF1,aItemSD1,3)
						If !lMsErroAuto
							_nImpOk ++
							_cLog += padr("OK: CTE "+cDoc+" gerada com valor de "+Transform(nVunit,"@E 999,999,999.99"),85)+"Arquivo: "+cFile+ENTER
							_cConfir := "N"
							// Gravar o nome do usuário na tabela SF1 (Solicitação Cristiane Contabilidade 25/05/23)
							DbSetOrder(1)
							MsSeek(FWxFilial("SF1")+cDoc+cSerie+cCliFor+cLoja)
							RecLock("SF1", .F.)
							SF1->F1_SILVA := AllTrim(UsrFullName(__cUserID))
							MsUnLock()
						else
							mostraerro()
							_cLog += padr("Erro: )CTE "+cDoc+" com problemas na geração automática. ",85)+"Arquivo: "+cFile+ENTER
							DisarmTransaction()
						Endif

					End Transaction

					DbSelectArea('SE2')
					SE2->(dbGoTop())
					SE2->(dbSetOrder(6))
					// Inclusão do vencimento nas contas a pagar													   			
					if SE2->(MsSeek(FWxFilial('SE2') + alltrim(cCliFor) + alltrim(cLoja) + cSerie + alltrim(cDoc) ))						
						RecLock('SE2',.F.)																	
						SE2->E2_VENCTO := _npar01
						SE2->E2_VENCREA := _npar01
						SE2->(dbCloseArea())
						MsUnlock()
					endif  
					_MoveArq(cFile,2)
				Else
					_cLog += padr("Erro: Dados insuficientes para importação da CTE ",85)+"Arquivo: "+cFile+ENTER

				EndIf

			EndIf // fim do if lProces .and. _cConfir = "S"

		EndIf // Fim else linha  238

	EndIf // Fim lProces   linha  223

	SA2->(dbCloseArea())
	SA1->(dbCloseArea())
	SB1->(dbCloseArea())

Return lProces

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo de log para conferencia                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function _Log(_sTexto)
	Local _nHdl    := 0

	If file (_sArqLog)
		_nHdl = fOpen(_sArqLog, 1)
	Else
		_nHdl = fCreate(_sArqLog, 0)
	Endif

	fSeek(_nHdl, 0, 2)      // Encontra final do arquivo
	fWrite(_nHdl, _sTexto + chr (13) + chr (10))
	fClose(_nHdl)

Return

Static Function _MoveArq(cFile,_nTipo)
	//-- Move arquivo para pasta dos erros
	cArqTXT := cStartPath+cFile
	//copia o arquivo antes da transacao
	if _nTipo == 2
		cNomNovArq  := c3StartPath+cFile
	else
		cNomNovArq  := cStartError+cFile
	Endif
	If MsErase(cNomNovArq)
		__CopyFile(cArqTXT,cNomNovArq)
		FErase(cStartPath+cFile)
	EndIf
Return
