#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Rwmake.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"

#DEFINE ENTER Chr(13)+Chr(10)

User Function PMXML005()

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  ³ PMXML005 ³ Autor ³ Gustavo Cornelli      ³ Data ³ Dez/2012 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Importa os arquivos XML diretamente como uma nf de entrada ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Utilizacao³ Especifico para clientes TOTVS                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³               ³                                            ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local _aArea   		:= FWGetArea()
	Local lWeb          := .F.
	Local aFiles        := {}
	Local nX            := 0     
	Local _i           
	Private aContas     := {}
	Private cIniFile    := GetAdv97()
	Private cStartPath  := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "CTE\ENTRADA\"
	Private cStartLido  := Trim(cStartPath) + "OLD\"
	Private cStartLog   := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ) + "CTE\LOG\"
	Private c2StartPath := Trim(cStartLido) + AllTrim(Str(Year(Date()))) + "\" 
	Private c3StartPath := Trim(c2StartPath) + AllTrim(Str(Month(Date()))) + "\"
	Private cStartError := Trim(cStartPath) + "ERRO\"
	Private _sArqLog 	  := alltrim(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile ))+"\cte\log\IMPCTE_"+dtos(ddatabase)+"_"+strtran(left(time(),5),":","")+".TXT"
	Private _cLog		  := ""
	Private _nImpOk 	  := 0
	Private cEmailTo    := "" 		     	// Indica a conta de e-mail do campo FROM no envio dos e-mails internos de processamento dos arquivos XML

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

	cEmailto := Alltrim(GetMv("PS_CTEMAIL"))

	// Cria Diretórios
	MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'CTE\')
	MakeDir(Trim(cStartPath))		  // Cria Diretório ENTRADA
	MakeDir(cStartLido)             // Cria Diretório ARQUIVOS IMPORTADOS
	MakeDir(c2StartPath)            // Cria Diretório ANO
	MakeDir(c3StartPath)            // Cria Diretório MES
	MakeDir(cStartError)            // Cria Diretório ERRO
	MakeDir(cStartLog)              // Cria Diretório LOG

	//aFiles := Directory(GetSrvProfString("RootPath","") + "\" + cStartPath + "*.xml")

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

	For nX := 1 To Len(aFiles)
		cFilBk := cFilAnt
		nRegSM0 := SM0->(Recno())
		nXml++
		MsAguarde({|| _ImpCTE(alltrim(aFiles[nX,1]),.T.)},"Aguarde","Importando dados do arquivo XML...",.F.)
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
Static Function _ImpCTE(cFile,lJob)
	Local cXML      := ""
	Local cError    := ""
	Local cWarning  := ""
	Local cCGC	    := ""
	Local cDoc	    := ""
	Local cSerie    := ""
	Local cLoja	    := ""
	Local lFound    := .F.
	Local lProces   := .T.
	Local nX		    := 0
	Local nY		    := 0
	Local oFullXML  := NIL
	Local oAuxXML   := NIL
	Local oXML	    := NIL
	Local aItens    := {}
	Local aHeadSF1  := {}
	Local aItemSD1  := {}
	Local aAuxItm   := {}
	Local cUFORITR  := ""
	Local cUFDESTR  := ""
	Local oDlg
	Default lJob := .T.

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

	If lProces 
		oFullXML := XmlParserFile(cStartPath + cFile,"_",@cError,@cWarning)

		//-- Erro na sintaxe do XML
		If Empty(oFullXML) .Or. !Empty(cError)
			_cLog += padr("Erro: Sintaxe XML.",85)+"Arquivo: "+cFile+ENTER			

			_MoveArq(cFile,1)
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

			//VERIFICAR PARA QUAL FILIAL SERA IMPORTADO
			cCNPJInf  := oXML:_INFCTE:_REM:_CNPJ:TEXT		
			/*  Inclusão Flávio a pedido de Henrique Jardim para complemento no arquivo do SPED*/
			cMUORITR := oXML:_INFCTE:_REM:_ENDERREME:_CMUN:TEXT
			cMUDESTR := oXML:_INFCTE:_DEST:_ENDERDEST:_CMUN:TEXT	
			cUFORITR := oXML:_INFCTE:_REM:_ENDERREME:_UF:TEXT   //Continuação da alteração 31/08/2018
			cUFDESTR := oXML:_INFCTE:_DEST:_ENDERDEST:_UF:TEXT  //Continuação da alteração 31/08/2018

			If "</CPF>" $ Upper(cXML)
				cCNPJDest := oXML:_INFCTE:_DEST:_CPF:TEXT
			Else
				cCNPJDest := oXML:_INFCTE:_DEST:_CNPJ:TEXT
			Endif

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
				_cLog += padr("Erro: Destinatário inválido. CNPJ: "+cCnpjInf,85)+"Arquivo: "+cFile+ENTER
				_MoveArq(cFile,1)    
			Endif


			if lProces
				lFound := .F.
				//-- Verifica se este ID ja foi processado
				DbSelectArea("SF1")
				SF1->(DbSetOrder(8))
				lFound := SF1->(DbSeek(xFilial("SF1")+Right(AllTrim(oXML:_InfCte:_Id:Text),44)))//Filial + Chave de acesso

				//PEGA A IDENT
				cIdEnt := U_WSAT01GetIdEnt()

				//VERIFICA O STATUS NA RECEITA FEDERAL E EM CASO DE REJEICAO NAO IMPORTA
				aStatus := U_CoNFeChv(Right(AllTrim(oXML:_InfCte:_Id:Text),44),cIdEnt,.T.)

				If aStatus[1]
					_cLog += padr("Erro: Código erro Sefaz: "+alltrim(aStatus[3]),85)+"Arquivo: "+cFile+ENTER
					_MoveArq(cFile,1)			
					lProces := .F.
				EndIf            
			Endif

			If lProces .and. lFound
				_cLog += padr("Erro: ID de CTe ja registrado na NF "+SF1->(F1_DOC+"/"+F1_SERIE)+" do fornecedor " +SF1->(F1_FORNECE+"/"+F1_LOJA),85)+"Arquivo: "+cFile+ENTER

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

					_MoveArq(cFile,1)

					lProces := .F.			
				Else
					aItens := oXML:_InfCte:_vPrest
				EndIf
			EndIf     

			If lProces    

				If cCNPJDest == "88728027000227"		// Tratamento implementado em 24/06/2013 para tratar CT-e de transferência (TES e produto diferenciados)
					cForn	  := alltrim(GetMv("PS_CTEFOR"))
					cLoja   := alltrim(GetMv("PS_CTELOJ"))
					//cCond := alltrim(GetMv("PS_CTECND")) //SERA CONSIDERADA DIRETAMENTE DO CADASTRO DO FORNECEDOR
					cTes	  := "103"
					cCC	  := alltrim(GetMv("PS_CTECCU"))
					cCod	  := "900020"
				Else
					cForn	  := alltrim(GetMv("PS_CTEFOR"))
					cLoja   := alltrim(GetMv("PS_CTELOJ"))
					//cCond := alltrim(GetMv("PS_CTECND")) //SERA CONSIDERADA DIRETAMENTE DO CADASTRO DO FORNECEDOR
					cTes	  := alltrim(GetMv("PS_CTETES"))
					cCC	  := alltrim(GetMv("PS_CTECCU"))
					cCod	  := alltrim(GetMv("PS_CTEPRD"))
				Endif
				If Empty(cForn) .or. Empty(cLoja) .or. Empty(cTes) .or. Empty(cCC) .or. Empty(cCod)
					_cLog += padr("Erro: Parametros PS_CTExxx incorretos para a filial: "+cFilAnt,85)+"Arquivo: "+cFile+ENTER

					_MoveArq(cFile,1)				
					lProces := .F.				
				Endif
			Endif

			//aadd(aHeadSF1,{"F1_COND"	,cCond				,NIL})			
			_cMU := alltrim(cMUORITR)
			_cMUR := alltrim(cMUDESTR)
			_cMUO := substr(_cMU,3,7)
			_cMUD := substr(_cMUR,3,7)
			_cUFO := alltrim(cUFORITR) //Continuação da alteração 31/08/2018
			_cUFD := alltrim(cUFDESTR) //Continuação da alteração 31/08/2018

			If lProces
				cDoc    := StrZero(Val(AllTrim(oXML:_InfCte:_Ide:_nCT:Text)),TamSx3("F1_DOC")[1])
				cSerie  := PadR(oXML:_InfCte:_Ide:_Serie:Text,TamSX3("F1_SERIE")[1])
				dEmiss  := StoD(StrTran(left(oXML:_InfCte:_Ide:_DhEmi:Text,10),"-",""))
				cChave  := Iif(ValType("oXML:_InfCte:_Id")<>"U",Right(AllTrim(oXML:_InfCte:_Id:Text),44),"")

				aHeadSF1 := {}
				aItemSD1 := {}
				aAuxItm  := {}

				DbSelectArea("SF1")
				aadd(aHeadSF1,{"F1_FILIAL"	,xFilial("SF1")	,NIL})
				aadd(aHeadSF1,{"F1_TIPO"	,"N"					,NIL})
				aadd(aHeadSF1,{"F1_FORMUL"	,"N"					,NIL})
				aadd(aHeadSF1,{"F1_DOC"		,cDoc					,NIL})
				aadd(aHeadSF1,{"F1_SERIE"	,cSerie				,NIL})
				aadd(aHeadSF1,{"F1_EMISSAO",dEmiss				,NIL})
				aadd(aHeadSF1,{"F1_FORNECE",cForn				,NIL})
				aadd(aHeadSF1,{"F1_LOJA"	,cLoja				,NIL})
				aadd(aHeadSF1,{"F1_ESPECIE","CTE"				,NIL})
				aadd(aHeadSF1,{"F1_CHVNFE"	,cChave				,NIL})
				aadd(aHeadSF1,{"F1_TPFRETE","C"					,NIL})
				aadd(aHeadSF1,{"F1_TPCTE"	,"N"				,NIL})			
				aadd(aHeadSF1,{"F1_UFORITR"	,_cUFO				 ,NIL}) //Continuação da alteração 31/08/2018
				aadd(aHeadSF1,{"F1_MUORITR"	,_cMUO				 ,NIL})
				aadd(aHeadSF1,{"F1_UFDESTR"	,_cUFD 				 ,NIL}) //Continuação da alteração 31/08/2018
				aadd(aHeadSF1,{"F1_MUDESTR"	,_cMUD 				 ,NIL})
				aadd(aHeadSF1,{"F1_INDPRES"	,"0" 				 ,NIL})
				aadd(aHeadSF1,{"F1_CODA1U"	,"" 				 ,NIL})

				For nX := 1 To Len(aItens)      
					nVUnit := round(val(oXML:_InfCte:_vPrest:_vTPrest:Text),2)
					aadd(aAuxItm,{"D1_COD"	,cCod					,NIL})				
					aadd(aAuxItm,{"D1_QUANT",1						,NIL})				
					aadd(aAuxItm,{"D1_VUNIT",nVUnit				,NIL})				
					aadd(aAuxItm,{"D1_TES"	,cTes					,NIL})				
					aadd(aAuxItm,{"D1_CC"	,cCC					,NIL})				
					aadd(aItemSD1,aAuxItm)
				Next nX

				//u_showarray(aHeadSF1)
				//u_showarray(aItemSD1)

				If !Empty(aItemSD1) .And. !Empty(aHeadSF1)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os dados do cabeçalho e itens da nota importada do XML          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Begin Transaction
						lMsHelpAuto := .F.  // se .t. direciona as mensagens de help
						lMsErroAuto := .F.  // necessario a criacao
						DbSelectArea("SF1")
						MsExecAuto({|v,x,y,w,z|MATA103(v,x,y,w,z)},aHeadSF1,aItemSD1,3)
						//alert(lMsErroAuto)
						If !lMsErroAuto
							_nImpOk ++
							_cLog += padr("OK: CTE "+cDoc+" gerada com valor de "+Transform(nVunit,"@E 999,999,999.99"),85)+"Arquivo: "+cFile+ENTER				
							_MoveArq(cFile,2)					
						else             
							//mostraerro()               
							_cLog += padr("Erro: CTE "+cDoc+" com problemas na geração automática. ",85)+"Arquivo: "+cFile+ENTER
							MostraErro()				
							DisarmTransaction()	
							_MoveArq(cFile,1)
						Endif               
					End Transaction
				Else                               
					_cLog += padr("Erro: Dados insuficientes para importação da CTE ",85)+"Arquivo: "+cFile+ENTER							
					_MoveArq(cFile,1)
				EndIf
			EndIf
		EndIf
	EndIf 
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



User Function MostraErro()
	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	Local nX     := 0
	Local nY     := 0
	Local cDoc   := ""
	Local lOk    := .T. 

	PRIVATE lMsErroAuto := .F.
	Private lMsHelpAuto	:= .T.    


	If !lMsErroAuto	

	Else	// será apresentada a janela de erro, pois não foram passados todos os campos obrigatórios da tabela SB1.	
		MostraErro()
	EndIf
	Retur
