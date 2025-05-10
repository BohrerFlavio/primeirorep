#INCLUDE "TBICONN.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} STI_RCOT
Rotina que efetua a impressใo das cota็๕es
@author 	Evandro Mugnol
@since 		28/01/2019
@return 	Nil, Fun็ใo nใo tem retorno
@obs 		N/A
/*/

User Function STI_RCOT(_cNumCot)

cPerg := "STI_RCOT"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Perguntas no Arquivo SX1                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If AllTrim(FunName()) == "MATA131"
	mv_par01 := _cNumCot
Else
	Pergunte(cPerg,.T.)
Endif


	//+--------------------------+
	//| Declaracao das variaveis |
	//+--------------------------+

_cPath  		   := "C:\Temp\"								// Diretorio no servidor interno onde serแ gerado o arquivo
_cFile  		   := "COTACAO_DA_FILIAL_" + Alltrim(cFilAnt) + "_DE_NUMERO_" + Alltrim(mv_par01) 	// Nome do arquivo a ser gerado
_lAdjustToLegacy := .F.											// Compatibilidade om TMSPrinter()
_lDisableSetup   := .T.											// Indice se exibe ou nใo a tela de Setup
_lServer 		   := .F.											// Indica Impressใo via SERVER
_lViewPDF 	   := .T.											// Indica se exibe ou nใo o PDF gerado
_RetImpRel       := .T.
   

	Private _cNL         := CHR(13) + CHR(10)

	Private _cPrograma   := "STI_RCOT"
	Private _cTitulo     := "Cota็ใo de Compra"								//Titulo do relatorio
	Private _cLogoEmp    := GetSrvProfString("Startpath","") + "logo.bmp"
	Private _cParam1     := "" //Guarda em forma de texto os parametros utilizados
	Private _cParam2     := "" //Guarda em forma de texto os parametros utilizados
	//Private _cArquivo    := "COTACAO_" + "999999" 																															
	//Private _cPath       := "C:\Temp\"
	Private _oPrn

	Private _oFtTitulo   := TFont():New("Courier new",,12,,.T.,,,,,.F.,.F.) //Fonte do titulo
	Private _oFtEmpFor   := TFont():New("Courier new",,10,,.T.,,,,,.F.,.F.) //Fonte do titulo
	Private _oFtCabec    := TFont():New("Courier new",,08,,.T.,,,,,.F.,.F.) //Fonte do cabecalho dos itens
	Private _oFtItem     := TFont():New("Courier new",,08,,.F.,,,,,.F.,.F.) //Fonte dos itens
	Private _oFtTotal    := TFont():New("Courier new",,08,,.T.,,,,,.F.,.T.) //Fonte do total dos itens 
	Private _oFtRodape   := TFont():New("Courier new",,08,,.F.,,,,,.F.,.F.) //Fonte do Rodape
	Private _oFtObs		 := TFont():New("Courier new",,06,,.F.,,,,,.F.,.F.) //Fonte do Rodape
	Private _oFtAprov	 := TFont():New("Courier new",,06,,.F.,,,,,.F.,.F.) //Fonte do Aprovadores
	Private _oFtNotaFil	 := TFont():New("Courier new",,08,,.T.,,,,,.F.,.F.) //Fonte das Notas 
	Private _oFtDtEntr   := TFont():New("Courier new",,08,,.T.,,,,,.F.,.F.) //Fonte da Data de Entrega
	
	Private _nMarTop     := 0030 //Define a margem superior
	Private _nMarLeft    := 0020 //Define a margem esquerda
	Private _nMarBottom  := 0580 //Define a margem inferior
	Private _nMarRight   := 0820 //Define a margem direita

	Private _nLinhaLim   := 18 //Limite de linhas por pagina
	Private _nLinhaImp   := _nLinhaLim + 1 //Contem o numero da linha impressa (come็a maior que nLinhaLim para iniciar uma nova pagina)
	Private _nItemAltu   := 7  //Altura da linha dos itens
	Private _nLinha      := 0  //Contem a altura da linha que sera impressa dentro do relatorio
	Private _nPaginImp   := 0  //Contem o numero da pagina
	Private _lImpInic    := .T.

	Private _cRegAtu     := ""
	Private _cRegFil     := ""
	Private _cRegFab     := ""
	Private _cRegPro     := ""
	Private _nFabNecVl   := 0
	Private _nNumReg     := 0 //Numero de registros retornados pela query
	Private _nNumRegIm   := 0 //Numero de registros retornados pela query
	
	Private _nI          := 0
	Private _nJ          := 0
	Private _cComprador  := ""
	Private _cAprov      := ""
	Private _nTotIPI     := 0
	Private _nTotICMS    := 0
	Private _nTotFrete   := 0
	Private _nTotMerc    := 0
	Private _nTotImp     := 0
	Private _nTotGeral   := 0
	Private _cObs        := "" 
	Private _nValObs     := 1 
	Private _nTot703     := 0	
	Private _cNotaObs    := ""
	Private _nTotDesp	 := 0
	Private	_nTotIcmRet	 := 0
	
	Private _cPedComp 	:= ""
	Private _cEmissao 	:= ""
	Private _cFornec  	:= "" 
	Private _cLoja    	:= "" 
	Private _cNmFornc 	:= ""	
	Private _cEnderec 	:= ""
	Private _cBairro  	:= ""
	Private _cCep     	:= ""
	Private _cCidade  	:= ""
	Private _cUF	  	:= ""
	Private _cTelDDD  	:= "" 
	Private _cTel     	:= ""
	Private _cCnpj    	:= ""
	Private _cIE      	:= ""
	Private _cArmazem	:= ""
	Private _nMostraVlr	:= 1 //Mostra Valores para Layout 
	Private _cTitulo	:= ""
	Private _cPlanilha	:= ""
	
	//+--------------+
	//| Consulta SQL |
	//+--------------+
	If !_CONSULT()
		Return()
	EndIf

// Verificar se o arquivo jแ existe, se existir excluir para garantir que nใo seja utilizado um arquivo gerado anteriormente
If FILE(_cPath + _cFile + ".pdf")
	FERASE(_cPath + _cFile + ".pdf")
EndIf
	
_oPrn := FWMSPrinter():New(_cFile, IMP_PDF, _lAdjustToLegacy, _cPath, _lDisableSetup,,,, _lServer,,, _lViewPDF)

//_oPrn:SetResolution(72)
_oPrn:SetLandscape()
_oPrn:SetPaperSize(9)
_oPrn:SetMargin(0,0,0,0)
_oPrn:lServer:=_lServer
_oPrn:cPathPDF:=_cPath			// Caminho p/ salvar o PDF

//+---------------+
//| Imprime dados |
//+---------------+
Processa({ || _LAYOUT1()}, "Gerando relat๓rio PDF. Por Favor, aguarde.", "", .F.)

_oPrn:EndPage()
_oPrn:Preview()				
FreeObj(_oPrn)
	
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _CONSULT บ Autor ณ Evandro Mugnol     บ Data ณ 05/01/2015  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Faz a consulta dos dados na base de dados.                 บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _CONSULT()
	cQuery1 := " SELECT * " 
	cQuery1 += "   FROM " + RetSqlTab("SC1") 
	cQuery1 += "  WHERE " + RetSqlFil("SC1") 
	cQuery1 += "    AND C1_COTACAO = '" + mv_par01 + "'"
	cQuery1 += "    AND " + RetSqlDel("SC1")

	cQuery1 := ChangeQuery(cQuery1)

	If Select("QryCOM703") != 0
		TRB1 -> (DbCloseArea())
	Endif

	TCQUERY cQuery1 NEW ALIAS "QryCOM703"
	
	_nTot703 := Contar("QryCOM703", "!Eof()") 
	
	dbSelectArea("QryCOM703")
	QryCOM703->(dbGoTop())
	
	_nNumReg := 0
	
	If QryCOM703->(EOF())
		MsgInfo("Nenhum registro encontrado.")
		Return()
	EndIf
	
	Count To _nNumReg
	QryCOM703->(dbGoTop())
	
	//Armazena informacoes do fornecedor para o cabecalho
	_cPedComp := QryCOM703->C1_COTACAO
	_cEmissao := DTOC(STOD(QryCOM703->C1_EMISSAO))
	
	_CONSEMP()
	
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _CONSEMP บ Autor ณ Evandro Mugnol     บ Data ณ 05/01/2015  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Consulta da empresa do usuแrio logada.                     บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _CONSEMP()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona o Arquivo de Empresa SM0.                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cAlias := Alias()
	dbSelectArea("SM0")
	dbSetOrder(1)   // forca o indice na ordem certa
	nRegistro := Recno()
	dbSeek((cEmpAnt)+QRYCOM703->C1_FILENT)	

Return(nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _LAYOUT1 บ Autor ณ Evandro Mugnol     บ Data ณ 05/01/2015  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Gera a impressao dos dados para o layout 1.                บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _LAYOUT1()
 	
	ProcRegua(_nNumReg)
	_nNumRegIm := 0
	
	QryCOM703->(DbGoTop())
	While QryCOM703->(!EOF())
		_nNumRegIm++
		IncProc("Imprimindo registro " + cValToChar(_nNumRegIm) + " de " + cValToChar(_nNumReg) + "...")

		_nLinhaImp++; _nLinha += _nItemAltu
		
		If ( _lImpInic = .T.)
			_NOVAPAG()
			_L1_CABE()
			_lImpInic := .F.
		EndIf
	
		_L1_LIN1()	

		QryCOM703->(DbSkip())
	EndDo	
		
		If (_nLinhaImp >= 14)
			_NOVAPAG()
			_RODAPE()
		else
			_RODAPE()
		EndIf					

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _NOVAPAG บ Autor ณ Evandro Mugnol     บ Data ณ 05/01/2015  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Inicia uma nova pagina.                                    บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _NOVAPAG()

	If (_nPaginImp != 0) //Se nao for a primeira pagina
		_oPrn:EndPage() //Encerra a pagina anterior
	EndIf
	
	_nPaginImp++ //Incrementa o numero da pagina
	_nLinhaImp := 0 //Zera o numero de itens impressos
	
	_oPrn:StartPage() //Inicia a pagina

	_oPrn:Box(_nMarTop, _nMarLeft, _nMarBottom, _nMarRight, "-2") //Imprime as margens da pagina
	
	_oPrn:Box(030,143,120,410)//Box Informacoes empresa
	_oPrn:Box(030,410,120,820)//Box Informacoes fornecedor
	_oPrn:Box(030,143,050,820)//Box Titulo Pedido			                                    
			
	_oPrn:SayBitmap(_nMarTop + 0035, _nMarLeft + 0008, _cLogoEmp, 110, 24) //Imprime o logo da empresa
	
	//Box Informa็๕es Empresa
	_oPrn:Say(042, 350, "COTAวรO DE COMPRA N.:" + _cPedComp,												_oFtTitulo)	//Imprime o Pedido de Compra	
	_oPrn:Say(042, 710, "EMISSรO: "  + _cEmissao,															_oFtTitulo)//Imprime a Data da Emissใo do Pedido de Compra	
	_oPrn:Say(059, 148, " EMPRESA: " + AllTrim(SM0->M0_NOMECOM),											_oFtEmpFor)
	_oPrn:Say(067, 148, "ENDEREวO: " + AllTrim(SM0->M0_ENDENT), 											_oFtEmpFor)
	_oPrn:Say(075, 148, "     CEP: " + Transform(SM0->M0_CEPENT, "!@R 99999-999"), 						_oFtEmpFor)
	_oPrn:Say(083, 148, "  CIDADE: " + AllTrim(SM0->M0_CIDENT),   											_oFtEmpFor)
	_oPrn:Say(091, 148, "      UF: " + AllTrim(SM0->M0_ESTENT),											_oFtEmpFor)		
	_oPrn:Say(099, 148, "    TEL.: " + AllTrim(SM0->M0_TEL ),									 			_oFtEmpFor)
	_oPrn:Say(107, 148, "CNPJ/CPF: " + Transform(SM0->M0_CGC , "@R 99.999.999/9999-99"),			   		_oFtEmpFor)
	_oPrn:Say(115, 148, "      IE: " + SM0->M0_INSC,						 								_oFtEmpFor)

	//Box Informa็๕es Fornecedores
	_oPrn:Say(059, 415, "FORNECEDOR: " ,		 	_oFtEmpFor)
	_oPrn:Say(067, 415, "  ENDEREวO: " ,												_oFtEmpFor)
	_oPrn:Say(075, 415, "    BAIRRO: " ,												_oFtEmpFor)
	_oPrn:Say(083, 415, "       CEP: " ,								_oFtEmpFor)
	_oPrn:Say(091, 415, "    CIDADE: " ,						_oFtEmpFor)		
	_oPrn:Say(099, 415, "      TEL.: " , _oFtEmpFor)
	_oPrn:Say(107, 415, "  CNPJ/CPF: " ,						_oFtEmpFor)	
	_oPrn:Say(115, 415, "        IE: " ,																_oFtEmpFor)	
	
	_oPrn:Line(_nMarTop + 0090, _nMarLeft, _nMarTop + 0090, _nMarRight) //Imprime linha divisoria entre titulo e cabecalho

	//_oPrn:SayAlign (_nMarBottom, _nMarLeft, _cPrograma, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign (_nMarBottom, _nMarLeft + 0750, "Pแgina: " + StrZero(_nPaginImp, 4), _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)

	_nLinha := _nMarTop + 0090

Return()   


//----------------------------------------------------------------------------------------------------

Static Function _L1_CABE()

	_oPrn:SayAlign(_nLinha, _nMarLeft + 0005, "Item"				, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0028, "Produto"				, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0065, "Descri็ใo"			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0325, "UN"					, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0342, "Quantidade"			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0395, "Vlr. Unitแrio"		, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0460, "%IPI"				, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0490, "Vlr. IPI"			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0535, "%ICMS"				, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0565, "Vlr. ICMS"			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0623, "%ICMS-ST"			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0670, "Vlr. ICMS-ST"		, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0750, "Vlr. Total"			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	
	_nLinha += _nItemAltu
	_nLinha += (_nItemAltu / 2)
	_oPrn:Line(_nLinha, _nMarLeft, _nLinha, _nMarRight) //Imprime linha divisoria entre cabe็alho e itens
	_nLinha -= (_nItemAltu / 2)
	_nLinha += _nItemAltu

Return()


//----------------------------------------------------------------------------------------------------

Static Function _L1_LIN1()

	Local _PartNumber := ""
	Local _Produto	  := AllTrim(QryCOM703->C1_PRODUTO)
	Local _Especie    := AllTrim(QryCOM703->C1_DESCRI)
	Local _nPosicao   := 430
	
		_oPrn:SayAlign(_nLinha, _nMarLeft + 0005, QryCOM703->C1_ITEM													, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:SayAlign(_nLinha, _nMarLeft + 0028, AllTrim(SUBSTR(QryCOM703->C1_PRODUTO,1,06))									, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:SayAlign(_nLinha, _nMarLeft + 0065, AllTrim(SUBSTR(QryCOM703->C1_DESCRI,1,60))    				, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:SayAlign(_nLinha, _nMarLeft + 0325, AllTrim(QryCOM703->C1_UM) 										, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:SayAlign(_nLinha, _nMarLeft + 0332, TRANSFORM(QryCOM703->C1_QUANT, "@E 999999999.99")		, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		/*
		_oPrn:SayAlign(_nLinha, _nMarLeft + 0590, TRANSFORM(QryCOM703->C1_PRECO, "@E 99,999,999.99")	, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:SayAlign(_nLinha, _nMarLeft + 0660, AllTrim(TransForm(QryCOM703->C8_ALIIPI ,"@R 99")) 		, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:SayAlign(_nLinha, _nMarLeft + 0683, AllTrim(TransForm(QryCOM703->C8_PICM,"@R 99"))		, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:SayAlign(_nLinha, _nMarLeft + 0690, TRANSFORM(QryCOM703->C1_TOTAL, "@E 99,999,999.99")	, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:SayAlign(_nLinha, _nMarLeft + 0753, DTOC(STOD(QryCOM703->C8_DATPRF)) 							, _oFtDtEntr, 1000, 0, CLR_BLACK, 0, 0)
		*/
	
	//Calcula os Totais de IPI, ICMS, FRETE, DESPESA, TOTAL MERCADORIA, TOTAL COM IMPOSTOS E TOTAL GERAL
	_nTotIPI    += 0	//QryCOM703->C8_VALIPI
	_nTotICMS   += 0	//QryCOM703->C8_VALICM
	_nTotFrete  += 0	//QryCOM703->C8_VALFRE
	_nTotMerc   += 0	//QryCOM703->C8_TOTAL
	_nTotDesp   += 0	//QryCOM703->C8_DESPESA
	_nTotImp    += 0	//QryCOM703->C8_TOTAL + QryCOM703->C8_VALIPI
	_nTotIcmRet += 0	//QryCOM703->C8_VALSOL
	
	/* BUSCAR DO SC7
	if !Empty(QryCOM703->C7_OBS) 
		_cObs += QryCOM703->C7_ITEM + " - " + AllTrim(QryCOM703->C7_OBS)
		If (_nTot703 > _nValObs)
			_cObs += " - "
		EndIf	
		_nValObs++ 
	EndIf
	*/	
   
	   IF(len(_Especie) > 60)
			//_oPrn:SayAlign(_nLinha + 10, _nMarLeft + 0058, AllTrim(SUBSTR(QryCOM703->B1_PARTN,26,25))		, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
			//_oPrn:SayAlign(_nLinha + 10, _nMarLeft + 0182, AllTrim(SUBSTR(QryCOM703->C7_PRODUTO,26,25))	, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
			_oPrn:SayAlign(_nLinha + 10, _nMarLeft + 0065, AllTrim(SUBSTR(QryCOM703->C1_DESCRI,61,60))		, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
			_nLinha += 14
			_nLinha += (14 / 2)
			If ( _nLinha <= _nMarBottom - 20)
				_oPrn:Line(_nLinha, _nMarLeft, _nLinha, _nMarRight) //Imprime linha divisoria entre cabe็alho e itens
			EndIf	
			_nLinha -= (14 / 2)
		
		else 
			
			_nLinha += _nItemAltu
			_nLinha += (_nItemAltu / 2)
			If ( _nLinha <= _nMarBottom - 20)
				_oPrn:Line(_nLinha, _nMarLeft, _nLinha, _nMarRight) //Imprime linha divisoria entre cabe็alho e itens
			EndIf			
			_nLinha -= (_nItemAltu / 2)

	   EndIf
	   
   If ( _nLinha >= _nPosicao ) .AND. ( _nTot703 < 20 )	   		   
		_nFator := 150   
   Else
		_nFator := 20      
   EndIf
   
   If ( _nLinha >= _nMarBottom - _nFator ) 
   	_lImpInic := .T.
   EndIf	
	
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _RODAPE  บ Autor ณ Evandro Mugnol     บ Data ณ 05/01/2015  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Chamada das Informa็๕es do Rodap้.                         บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _RODAPE()
	_cComprador := 	"<N o m e>"		//UsrFullName(QryRODP703->C7_USER)	
	
	//If (QryRODP703->C7_FILIAL == "02")
	//	_cNotaObs := Upper("Compra destinada para industrializa็ใo. Empresa Contribuinte de ICMS, Destina็ใo ISENTA de recolhimento de ICMS ST e DIFAL(E.C. 87/2015).")
	//EndIf
	//
	//If (QryRODP703->C7_FILIAL == "03")
	//	_cNotaObs := Upper("Material destinado ao Uso/Consumo em presta็ใo servi็o. Sujeito ao recolhimento do DIFAL(Diferencial de alํquotas). Empresa Nใo Contribuinte de ICMS - E.C. 87/2015.")
	//EndIf
	
	_oPrn:Line(_nMarBottom - 0120, _nMarLeft, _nMarBottom - 0120, _nMarRight) //Imprime linha divisoria para separar os parametros no rodape
	_oPrn:SayAlign (_nMarBottom - (_nItemAltu * 2), _nMarLeft + 0002, _cParam1, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign (_nMarBottom - (_nItemAltu * 1), _nMarLeft + 0002, _cParam2, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)

	_oPrn:Box(_nMarBottom - 0100,020,_nMarBottom - 0120,350)//Box Local de Entrega
	_oPrn:Box(_nMarBottom - 0100,350,_nMarBottom - 0120,650)//Box Local de Cobran็a

	_oPrn:Say(_nMarBottom - 0140,0025, "NOTAS:", 	_oFtCabec)
	_oPrn:Say(_nMarBottom - 0133,0025, "Sำ ACEITAREMOS A MERCADORIA SE NA SUA NOTA FISCAL CONSTAR O NฺMERO DO NOSSO PEDIDO DE COMPRA.", 	_oFtItem, 1000, 0, CLR_BLACK, 0, 0)	
	_oPrn:Say(_nMarBottom - 0127,0025, "ENVIAR O XML DA NOTA FISCAL PARA: FRIGORIFICOSILVA.COM.BR", 	_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:Say(_nMarBottom - 0121,0025, "Sำ SERรO RECEBIDOS MERCADORIAS EM QUE A NOTA FISCAL ESTIVER DE ACORDO COM O PEDIDO DE COMPRA.", 	_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		
	_oPrn:Say(_nMarBottom - 0112,0025, "LOCAL DE ENTREGA:", 	_oFtCabec)	
	_oPrn:Say(_nMarBottom - 0103,0025, "CEP: " + Transform(SM0->M0_CEPENT, "!@R 99999-999") + " " + AllTrim(SM0->M0_ENDENT) + " " +  AllTrim(SM0->M0_CIDENT) + " / " + AllTrim(SM0->M0_ESTENT), _oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
	_oPrn:Say(_nMarBottom - 0112,0355, "LOCAL DE COBRANวA:", 	_oFtCabec)	
	_oPrn:Say(_nMarBottom - 0103,0355, "CEP: XXXXX-XXX RUA XXXXXXX, 43 SANTA MARIA / RS", 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
	_oPrn:Say(_nMarBottom - 0112,0655, "CONDIวรO DE PAGTO " , _oFtCabec)	
	//_oPrn:Say(_nMarBottom - 0103,0655, SubStr(QryCOM703->E4_DESCRI,1,34), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)			
	
	_oPrn:Box(_nMarBottom - 0080,0020,_nMarBottom - 0100,275)
	_oPrn:Box(_nMarBottom - 0080,0275,_nMarBottom - 0100,350)
	_oPrn:Box(_nMarBottom - 0080,0350,_nMarBottom - 0100,650)
	_oPrn:Box(_nMarBottom - 0100,0650,_nMarBottom - 0040,735)
	_oPrn:Box(_nMarBottom - 0100,0735,_nMarBottom - 0040,820)
	_oPrn:Box(_nMarBottom - 0040,0650,_nMarBottom - 0020,820)
	_oPrn:Box(_nMarBottom,0650,_nMarBottom - 0020,820)
	
	_oPrn:Box(_nMarBottom - 0040,0020,_nMarBottom - 0080,650)//Box Observa็ใo			
	_oPrn:Box(_nMarBottom - 0020,0020,_nMarBottom - 0040,150)//Box Comprador
	_oPrn:Box(_nMarBottom - 0020,0150,_nMarBottom - 0040,650)//Box Aprovador
	_oPrn:Box(_nMarBottom,0020,_nMarBottom - 0020,650)//Box Legenda		
	
	_oPrn:Say(_nMarBottom - 0092,0025, "TRANSPORTADORA:", 	_oFtCabec)	
	//_oPrn:Say(_nMarBottom - 0083,0025, AllTrim (QryRODP703->A4_NOME), _oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
	_oPrn:Say(_nMarBottom - 0092,0280, "CIF/FOB:", 	_oFtCabec)	
	_oPrn:Say(_nMarBottom - 0083,0280, " " , 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
	_oPrn:Say(_nMarBottom - 0092,0355, "OBS DO FRETE:", 	_oFtCabec)	
	_oPrn:Say(_nMarBottom - 0083,0355, "", 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	 
	
	_oPrn:Say(_nMarBottom - 0072,0025, "OBSERVAวรO:", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)

	If( Len(_cObs) <= 190 )
		_oPrn:Say(_nMarBottom - 0066,0025, AllTrim(_cObs), 	_oFtObs, 1000, 0, CLR_BLACK, 0, 0)
	Else
		_oPrn:Say(_nMarBottom - 0066,0025, AllTrim(SUBSTR(_cObs,1,190)), 	 _oFtObs, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:Say(_nMarBottom - 0060,0025, AllTrim(SUBSTR(_cObs,191,190)),  _oFtObs, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:Say(_nMarBottom - 0054,0025, AllTrim(SUBSTR(_cObs,381,190)),  _oFtObs, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:Say(_nMarBottom - 0048,0025, AllTrim(SUBSTR(_cObs,571,190)),  _oFtObs, 1000, 0, CLR_BLACK, 0, 0)
		_oPrn:Say(_nMarBottom - 0042,0025, AllTrim(SUBSTR(_cObs,761,190)),  _oFtObs, 1000, 0, CLR_BLACK, 0, 0)
	EndIf	
	
	_oPrn:Say(_nMarBottom - 0032,0025, "COMPRADOR RESPONSมVEL:", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)		
	//_oPrn:Say(_nMarBottom - 0023,0025, Substr(UPPER(_cComprador),1,60), _oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
	
	_oPrn:Say(_nMarBottom - 0032,0155, "APROVADOR(ES):", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)		
	//_oPrn:Say(_nMarBottom - 0023,0155, IIF(mv_par04 == 3,"",UPPER(_cAprov)), 	_oFtAprov, 1000, 0, CLR_BLACK, 0, 0)			
	
	//_oPrn:Say(_nMarBottom - 0012,0025, "LEGENDAS DA APROVAวรO:", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)				
	//_oPrn:Say(_nMarBottom - 0003,0025, "BLQ = BLOQUEADO | OK = LIBERADO | ?? = AGUAR. LIB. | ## = NIVEL LIB.", 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
	
	_oPrn:Say(_nMarBottom - 0092,0650, "      IPI:" + Transform(_nTotIPI, "@E@Z 99,999.99"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
	_oPrn:Say(_nMarBottom - 0083,0650, "    FRETE:" + Transform(_nTotFrete, "@E@Z 99,999.99"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
	_oPrn:Say(_nMarBottom - 0073,0650, "     ICMS:" + Transform(_nTotICMS, "@E@Z 99,999.99"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)			
	_oPrn:Say(_nMarBottom - 0063,0650, "  ICMS ST:" + Transform(_nTotIcmRet, "@E@Z 99,999.99"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:Say(_nMarBottom - 0043,0650, " DESPESAS:" + Transform(_nTotDesp, "@E@Z 99,999.99"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
	
	_oPrn:Say(_nMarBottom - 0085,0735, " TOT. MERCADORIA:", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)	
	_oPrn:Say(_nMarBottom - 0077,0755, + Transform(_nTotMerc, "@E@Z 99,999,999.99"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
	_oPrn:Say(_nMarBottom - 0065,0735, " TOT. COM IMPOSTOS:", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)			
	_oPrn:Say(_nMarBottom - 0057,0755, + Transform(_nTotImp + _nTotDesp + _nTotIcmRet , "@E@Z 99,999,999.99"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
	_oPrn:Say(_nMarBottom - 0027,0690, " TOTAL GERAL:", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:Say(_nMarBottom - 0027,0750, " " + Transform(_nTotMerc + _nTotIPI + _nTotDesp + _nTotIcmRet, "@E@Z 99,999,999.99"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
	//_oPrn:Say(_nMarBottom - 0007,0700, IIF((QryRODP703->C7_CONAPRO != "B"), " PEDIDO LIBERADO", " PEDIDO BLOQUEADO"), 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)

Return()
