#INCLUDE "TBICONN.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} STI_CP51
Rotina que efetua a impressใo/gera็ใo do pedido de compra em PDF
@author 	Evandro Mugnol
@since 		29/01/2019
@return 	Nil, Fun็ใo nใo tem retorno
@obs 		N/A
/*/

User Function STI_CP51(_cTpExec, _cPedCmp, _cFilial, _nTpImp, _nTpLayout, _nRegistro, _cNmFornec)

Private _cNL         := CHR(13) + CHR(10)
Private _cPrograma   := "STI_CP51"
Private _cRelat      := "Pedido de Compra" //Nome do relatorio
Private _cTitulo     := _cRelat	//Titulo do relatorio
Private _cLogoEmp    := GetSrvProfString("Startpath","") + IIF(cEmpAnt == "08","logoracao.bmp", IIF(cEmpAnt == "07", "logotransp.bmp","logosilva.bmp"))
Private _cParam1     := "" //Guarda em forma de texto os parametros utilizados
Private _cParam2     := "" //Guarda em forma de texto os parametros utilizados
Private _cEmitido    := "Emitido em " + DTOC(DATE()) //Texto com a data de emissao do relatorio
Private _cArquivo    := IIF(_cTpExec == "1",_cPrograma + DTOS(DATE()) + SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2) + SUBSTR(TIME(), 7, 2), STRTRAN(STRTRAN(STRTRAN(STRTRAN(AllTrim(_cNmFornec)," ","_"),"-",""),".",""),"/","") + "_" + AllTrim(_cFilial) + "_" + AllTrim(_cPedCmp) )																																					
Private _cPath       := "C:\temp\"
Private _nHandle     := 0

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

Private _nMarTop     := 0030 			//Define a margem superior
Private _nMarLeft    := 0020 			//Define a margem esquerda
Private _nMarBottom  := 0580		 	//Define a margem inferior
Private _nMarRight   := 0820 			//Define a margem direita

Private _nLinhaLim   := 15 				//Limite de linhas por pagina
Private _nLinhaImp   := _nLinhaLim + 1 	//Contem o numero da linha impressa (come็a maior que nLinhaLim para iniciar uma nova pagina)
Private _nItemAltu   := 7  				//Altura da linha dos itens
Private _nLinha      := 0  				//Contem a altura da linha que sera impressa dentro do relatorio
Private _nPaginImp   := 0  				//Contem o numero da pagina
Private _lImpInic    := .T.

Private _cRegAtu     := ""
Private _cRegFil     := ""
Private _cRegFab     := ""
Private _cRegPro     := ""
Private _nFabNecVl   := 0
Private _nNumReg     := 0 //Numero de registros retornados pela query
Private _nNumRegIm   := 0 //Numero de registros retornados pela query

Private _cMv_par01   := ""

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
Private _nTotIcmCom	 := 0
Private _nTotDesc    := 0

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
Private _cNumCot	:= ""
Private _nMostraVlr	:= 1 		//Mostra Valores para Layout
//Private _cTitulo	:= ""
Private _cPlanilha	:= ""

// Parametros do relatorio
If(_cTpExec == "2")
	mv_par01 := _cPedCmp
	mv_par02 := _cFilial
	mv_par03 := _nTpImp
	mv_par04 := _nTpLayout
	mv_par05 := _nRegistro
	mv_par06 := _nMostraVlr
EndIf

// Consulta SQL
If !_CONSULT()
	Return()
EndIf

_oPrn := FWMsPrinter():New(_cArquivo, 6, .F., , .T.) 	//Cria o objeto de impressใo

If (mv_par03 == 1) 	//PDF
	FERASE(_cPath + _cArquivo + ".pdf") //Exclui arquivo PDF caso ele exista
	_oPrn:cPathPDF := _cPath
	_oPrn:SetResolution(72)
	_oPrn:SetLandscape()
	_oPrn:SetPaperSize(9)
	_oPrn:SetMargin(0,0,0,0)
    If(_cTpExec == "2")
		_oPrn:SetViewPDF(.F.)
	EndIf	

	// Imprime dados
	Processa({ || _LAYOUT()}, "Gerando relat๓rio PDF. Por Favor, aguarde.", "", .F.)

	_oPrn:EndPage()
	_oPrn:Preview()
	FreeObj(_oPrn)
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _CONSULT บ Autor ณ Evandro Mugnol     บ Data ณ 29/01/2019  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Faz a consulta dos dados na base de dados.                 บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _CONSULT()

Local _cQuery := ""

//Layout do relatorio para o Fornecedor/Cotacao
If mv_par04 == 1
	_cQuery += "SELECT C7.C7_NUM, C7.C7_QUJE, C7.C7_QTDACLA, C7.C7_NUMCOT,"
	_cQuery += "SubString(C7.C7_EMISSAO,7,2)+'/'+SubString(C7.C7_EMISSAO,5,2)+'/'+SubString(C7.C7_EMISSAO,1,4) AS C7_EMISSAO, "
	_cQuery += "C7.C7_FILENT, C7.C7_FILIAL, C7.C7_LOJA, C7.C7_FORNECE, A2.A2_NOME, A2.A2_END, A2.A2_BAIRRO, "
	_cQuery += "A2.A2_CEP, A2.A2_MUN, A2.A2_EST, A2.A2_DDD, A2.A2_TEL, A2.A2_CGC, A2.A2_INSCR, C7.C7_ITEM, "
	_cQuery += "C7.C7_NUMSC, C7.C7_UM, C7.C7_PRODUTO, B1.B1_ESPECIF, B1.B1_GRUPO, B1.B1_TIPO, C7.C7_QUANT, C7.C7_PRECO, C7.C7_IPI, "
	_cQuery += "C7.C7_PICM, C7.C7_TOTAL, C7.C7_VALSOL, "
	_cQuery += "SubString(C7.C7_DATPRF,7,2)+'/'+SubString(C7.C7_DATPRF,5,2)+'/'+SubString(C7.C7_DATPRF,1,4) AS C7_DATPRF, "
	_cQuery += "C7.C7_COND, E4.E4_DESCRI, E4.E4_COND, C7.C7_TPFRETE, C7.C7_OBS, ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C7_OBSM)),'') AS C7OBSM, C7.C7_USER, C7.C7_TIPO, C7.C7_CONAPRO, "
	_cQuery += "C7.C7_VALFRE, C7.C7_VALICM, C7.C7_VALIPI, C7.C7_LOCAL, C7.C7_SEGURO, C7.C7_DESPESA, C7.C7_ICMSRET, C7.C7_ICMCOMP, C7.C7_DESCRI, C7.C7_MARCAC, C7.C7_VLDESC "
	_cQuery += "FROM " + RetSqlName('SC7') + " C7 WITH (NOLOCK) "
	_cQuery += "LEFT JOIN " + RetSqlName('SA2') + "  A2 WITH (NOLOCK) ON A2.A2_COD = C7.C7_FORNECE "
	_cQuery += "                   				 AND A2.A2_LOJA   = C7.C7_LOJA "
	_cQuery += "                                 AND A2.D_E_L_E_T_ <> '*' "
	_cQuery += "LEFT JOIN " + RetSqlName('SB1') + "  B1 WITH (NOLOCK) ON B1.B1_COD = C7.C7_PRODUTO "
	_cQuery += "                   				 AND B1.B1_FILIAL = C7.C7_FILIAL  "
	_cQuery += "                                 AND B1.D_E_L_E_T_ <> '*' "
	_cQuery += "LEFT JOIN " + RetSqlName('SE4') + "  E4 WITH (NOLOCK) ON E4.E4_CODIGO = C7.C7_COND "
	_cQuery += "                                 AND E4.D_E_L_E_T_ <> '*' "
	_cQuery += "WHERE C7.C7_NUM = '" + mv_par01 + "' "
	If !Empty(mv_par02)
		_cQuery += "AND	C7.C7_FILIAL IN	(" + mv_par02 + ") "
	EndIf
	_cQuery += "AND C7.D_E_L_E_T_ =	'' "
	_cQuery += "ORDER BY C7.C7_NUM, C7.C7_ITEM "
Endif

If (Select("TRB1") <> 0)
	TRB1->(dbCloseArea())
EndIf

TcQuery _cQuery New Alias "TRB1"

_nTot703 := Contar("TRB1", "!Eof()")

dbSelectArea("TRB1")
TRB1->(dbGoTop())

_nNumReg := 0

If TRB1->(EOF())
	MsgInfo("Nenhum registro encontrado.")
	Return()
EndIf

Count To _nNumReg
TRB1->(dbGoTop())

//Armazena informacoes do fornecedor para o cabecalho
_cPedComp := TRB1->C7_NUM
_cEmissao := TRB1->C7_EMISSAO
_cFornec  := TRB1->C7_FORNECE
_cLoja    := TRB1->C7_LOJA
_cNmFornc := TRB1->A2_NOME
_cEnderec := TRB1->A2_END
_cBairro  := TRB1->A2_BAIRRO
_cCep     := TRB1->A2_CEP
_cCidade  := TRB1->A2_MUN
_cUF	  := TRB1->A2_EST
_cTelDDD  := TRB1->A2_DDD
_cTel     := TRB1->A2_TEL
_cCnpj    := TRB1->A2_CGC
_cIE      := TRB1->A2_INSCR
_cNumCot  := TRB1->C7_NUMCOT

_CONSEMP()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _CONSRODPบ Autor ณ Evandro Mugnol     บ Data ณ 29/01/2019  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Faz a consulta dos dados para popular os registros do      บฑฑ
ฑฑบ           ณ rodap้                                                     บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _CONSRODP()

Local _cQuery := ""

//Layout do relatorio para o Fornecedor
If mv_par04 == 1
	_cQuery += "SELECT C7.C7_NUM, C7.C7_QUJE, C7.C7_QTDACLA, "
	_cQuery += "SubString(C7.C7_EMISSAO,7,2)+'/'+SubString(C7.C7_EMISSAO,5,2)+'/'+SubString(C7.C7_EMISSAO,1,4) AS C7_EMISSAO, "
	_cQuery += "C7.C7_FILENT, C7.C7_FILIAL, C7.C7_LOJA, C7.C7_FORNECE, A2.A2_NOME, A2.A2_END, A2.A2_BAIRRO, "
	_cQuery += "A2.A2_CEP, A2.A2_MUN, A2.A2_EST, A2.A2_DDD, A2.A2_TEL, A2.A2_CGC, A2.A2_INSCR, C7.C7_ITEM, "
	_cQuery += "C7.C7_NUMSC, C7.C7_UM, C7.C7_PRODUTO, B1.B1_ESPECIF, B1.B1_GRUPO, B1.B1_TIPO, C7.C7_QUANT, C7.C7_PRECO, C7.C7_IPI, "
	_cQuery += "C7.C7_PICM, C7.C7_TOTAL, C7.C7_VALSOL, "
	_cQuery += "SubString(C7.C7_DATPRF,7,2)+'/'+SubString(C7.C7_DATPRF,5,2)+'/'+SubString(C7.C7_DATPRF,1,4) AS C7_DATPRF, "
	_cQuery += "C7.C7_COND, E4.E4_DESCRI, E4.E4_COND, C7.C7_TPFRETE, C7.C7_OBS, ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C7_OBSM)),'') AS C7OBSM, C7.C7_USER, C7.C7_TIPO, C7.C7_CONAPRO, "
	_cQuery += "C7.C7_VALFRE, C7.C7_VALICM, C7.C7_VALIPI, C7.C7_SEGURO, C7.C7_DESPESA, C7.C7_ICMSRET, C7.C7_ICMCOMP, C7.C7_DESCRI, C7.C7_MARCAC, C7.C7_VLDESC "
	_cQuery += "FROM " + RetSqlName('SC7') + " C7 WITH (NOLOCK) "
	_cQuery += "LEFT JOIN " + RetSqlName('SA2') + " A2 WITH (NOLOCK) ON A2.A2_COD = C7.C7_FORNECE "
	_cQuery += "                   				 AND A2.A2_LOJA   = C7.C7_LOJA "
	_cQuery += "                                 AND A2.D_E_L_E_T_ <> '*' "
	_cQuery += "LEFT JOIN " + RetSqlName('SB1') + " B1 WITH (NOLOCK) ON B1.B1_COD = C7.C7_PRODUTO "
	_cQuery += "                   				 AND B1.B1_FILIAL = C7.C7_FILIAL  "
	_cQuery += "                                 AND B1.D_E_L_E_T_ <> '*' "
	_cQuery += "LEFT JOIN " + RetSqlName('SE4') + " E4 WITH (NOLOCK) ON E4.E4_CODIGO = C7.C7_COND "
	_cQuery += "                                 AND E4.D_E_L_E_T_ <> '*' "
	_cQuery += "WHERE C7.C7_NUM = '" + mv_par01 + "' "
	If !Empty(mv_par02)
		_cQuery += "AND	C7.C7_FILIAL IN	(" + mv_par02 + ") "
    EndIf
	_cQuery += "AND C7.D_E_L_E_T_	=	'' "
	_cQuery += "ORDER BY C7.C7_NUM, C7.C7_ITEM "
EndIf

If (Select("TRB2") <> 0)
	TRB2->(dbCloseArea())
EndIf

TcQuery _cQuery New Alias "TRB2"

dbSelectArea("TRB2")
TRB2->(dbGoTop())

If TRB2->(EOF())
	MsgInfo("Nenhum registro encontrado.")
	Return()
EndIf

TRB2->(dbGoTop())
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _CONSEMP บ Autor ณ Evandro Mugnol     บ Data ณ 12/01/2019  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Consulta da empresa do usuแrio logada.                     บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _CONSEMP()

// Posiciona o Arquivo de Empresa SM0
cAlias := Alias()
dbSelectArea("SM0")
dbSetOrder(1)
nRegistro := Recno()
dbSeek((cEmpAnt) + TRB1->C7_FILENT)	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _NOVAPAG บ Autor ณ Evandro Mugnol     บ Data ณ 29/01/2019  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Inicia uma nova pagina.                                    บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _NOVAPAG()

If (_nPaginImp != 0) 	//Se nao for a primeira pagina
	_oPrn:EndPage() 	//Encerra a pagina anterior
EndIf

_nPaginImp++ 			//Incrementa o numero da pagina
_nLinhaImp := 0 		//Zera o numero de itens impressos

_oPrn:StartPage() 		//Inicia a pagina

_oPrn:Box(_nMarTop, _nMarLeft, _nMarBottom, _nMarRight, "-2") 	//Imprime as margens da pagina

_oPrn:Box(030,143,120,410)	//Box Informacoes empresa
_oPrn:Box(030,410,120,820)	//Box Informacoes fornecedor
_oPrn:Box(030,143,050,820)	//Box Titulo Pedido

If cEmpAnt == "01"
	_oPrn:SayBitmap(_nMarTop + 0032, _nMarLeft + 0008, _cLogoEmp, 110, 22) //Imprime o logo da empresa frigorํfico silva
Else
	_oPrn:SayBitmap(_nMarTop + 0010, _nMarLeft + 0008, _cLogoEmp, 110, 70) //Imprime o logo da empresa ind๚stria de ra็๕es e transportadora
Endif

//Box Informa็๕es Empresa
_oPrn:Say(042, 300, " COTAวรO: " + _cNumCot + " REFERENTE AO PEDIDO DE COMPRA N.: " + _cPedComp,_oFtTitulo)
_oPrn:Say(042, 705, " EMISSรO: " + _cEmissao,													_oFtTitulo)
_oPrn:Say(059, 148, " EMPRESA: " + AllTrim(SM0->M0_NOMECOM),									_oFtEmpFor)
_oPrn:Say(067, 148, "ENDEREวO: " + AllTrim(SM0->M0_ENDENT), 									_oFtEmpFor)
_oPrn:Say(075, 148, "     CEP: " + Transform(SM0->M0_CEPENT, "!@R 99999-999"), 					_oFtEmpFor)
_oPrn:Say(083, 148, "  CIDADE: " + AllTrim(SM0->M0_CIDENT),   									_oFtEmpFor)
_oPrn:Say(091, 148, "      UF: " + AllTrim(SM0->M0_ESTENT),										_oFtEmpFor)
_oPrn:Say(099, 148, "    TEL.: " + AllTrim(SM0->M0_TEL ),									 	_oFtEmpFor)
_oPrn:Say(107, 148, "CNPJ/CPF: " + Transform(SM0->M0_CGC , "@R 99.999.999/9999-99"),			_oFtEmpFor)
_oPrn:Say(115, 148, "      IE: " + SM0->M0_INSC,						 						_oFtEmpFor)

//Box Informa็๕es Fornecedores
_oPrn:Say(059, 415, "FORNECEDOR: " + _cFornec + " - " + _cLoja + " - " + AllTrim(_cNmFornc),	_oFtEmpFor)
_oPrn:Say(067, 415, "  ENDEREวO: " + AllTrim(_cEnderec),										_oFtEmpFor)
_oPrn:Say(075, 415, "    BAIRRO: " + AllTrim(_cBairro),											_oFtEmpFor)
_oPrn:Say(083, 415, "       CEP: " + Transform(_cCep, "!@R 99999-999"),							_oFtEmpFor)
_oPrn:Say(091, 415, "    CIDADE: " + AllTrim(_cCidade) + " UF: " + AllTrim(_cUF),				_oFtEmpFor)
_oPrn:Say(099, 415, "      TEL.: " + Transform(STRTRAN(AllTrim(_cTelDDD),"0",""), "@R (99)" ) + Transform(STRTRAN(STRTRAN(AllTrim(_cTel),"-","")," ",""), "@R 9999-9999"), _oFtEmpFor)
_oPrn:Say(107, 415, "  CNPJ/CPF: " + Transform(_cCNPJ, "@R 99.999.999/9999-99"),				_oFtEmpFor)
_oPrn:Say(115, 415, "        IE: " + _cIE,														_oFtEmpFor)

_oPrn:Line(_nMarTop + 0090, _nMarLeft, _nMarTop + 0090, _nMarRight) //Imprime linha divisoria entre titulo e cabecalho

//_oPrn:SayAlign (_nMarBottom, _nMarLeft, _cPrograma, 								_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:SayAlign (_nMarBottom, _nMarLeft + 0750, "Pแgina: " + StrZero(_nPaginImp, 4), _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)

_nLinha := _nMarTop + 0090

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _RODAPE  บ Autor ณ Evandro Mugnol     บ Data ณ 20/01/2019  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Chamada das Informa็๕es do Rodap้.                         บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _RODAPE()

_CONSRODP()

_cComprador := UsrFullName(TRB2->C7_USER)

_oPrn:Line(_nMarBottom - 0120, _nMarLeft, _nMarBottom - 0120, _nMarRight) 	//Imprime linha divisoria para separar os parametros no rodape
_oPrn:SayAlign (_nMarBottom - (_nItemAltu * 2), _nMarLeft + 0002, _cParam1, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:SayAlign (_nMarBottom - (_nItemAltu * 1), _nMarLeft + 0002, _cParam2, _oFtItem, 1000, 0, CLR_BLACK, 0, 0)

_oPrn:Box(_nMarBottom - 0100,020,_nMarBottom - 0120,350)	//Box Local de Entrega
_oPrn:Box(_nMarBottom - 0100,350,_nMarBottom - 0120,650)	//Box Local de Cobran็a
_oPrn:Box(_nMarBottom - 0100,650,_nMarBottom - 0120,820)	//Box Condi็ใo de Pagamento

_oPrn:Say(_nMarBottom - 0159,0025, 'Tipo MC:       Finalidade "Material Uso e Consumo" - Incide IPI'											, _oFtCabec, 2000, 0, CLR_BLACK, 0, 0)	
_oPrn:Say(_nMarBottom - 0152,0025, 'Tipo MP/EM/MS: Finalidade "Industrializa็ใo"       - Revenda (Incide IPI) e Produ็ใo Pr๓pria (Susp. IPI)'	, _oFtCabec, 2000, 0, CLR_BLACK, 0, 0)	

_oPrn:Say(_nMarBottom - 0140,0025, "NOTAS:", 	_oFtCabec)
_oPrn:Say(_nMarBottom - 0133,0025, "Sำ ACEITAREMOS A MERCADORIA SE NA SUA NOTA FISCAL CONSTAR O NฺMERO DO NOSSO PEDIDO DE COMPRA.", _oFtItem, 1000, 0, CLR_BLACK, 0, 0)	
_oPrn:Say(_nMarBottom - 0127,0025, "ENVIAR O XML DA NOTA FISCAL PARA: centralxml@frigorificosilva.com.br COM CำPIA PARA recebimento@frigorificosilva.com.br",									_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0121,0025, "Sำ SERรO RECEBIDOS MERCADORIAS EM QUE A NOTA FISCAL ESTIVER DE ACORDO COM O PEDIDO DE COMPRA.", _oFtItem, 1000, 0, CLR_BLACK, 0, 0)

_oPrn:Say(_nMarBottom - 0112,0025, "LOCAL DE ENTREGA:", 	_oFtCabec)	
_oPrn:Say(_nMarBottom - 0103,0025, "CEP: " + Transform(SM0->M0_CEPENT, "!@R 99999-999") + " " + AllTrim(SM0->M0_ENDENT) + " " +  AllTrim(SM0->M0_CIDENT) + " / " + AllTrim(SM0->M0_ESTENT),		_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
_oPrn:Say(_nMarBottom - 0112,0355, "LOCAL DE COBRANวA:", 	_oFtCabec)	
_oPrn:Say(_nMarBottom - 0103,0355, "CEP: " + Transform(SM0->M0_CEPCOB, "!@R 99999-999") + " " + AllTrim(SM0->M0_ENDCOB) + " " +  AllTrim(SM0->M0_CIDCOB) + " / " + AllTrim(SM0->M0_ESTCOB), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)	
_oPrn:Say(_nMarBottom - 0112,0655, IIF(mv_par06 == 1,"CONDIวรO DE PAGTO: " + TRB2->E4_COND,""), 	_oFtCabec)	
_oPrn:Say(_nMarBottom - 0103,0655, IIF(mv_par06 == 1,SubStr(TRB2->E4_DESCRI,1,34),""), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)			

_oPrn:Box(_nMarBottom - 0080,0020,_nMarBottom - 0100,275)
_oPrn:Box(_nMarBottom - 0080,0275,_nMarBottom - 0100,350)
_oPrn:Box(_nMarBottom - 0080,0350,_nMarBottom - 0100,650)
_oPrn:Box(_nMarBottom - 0100,0650,_nMarBottom - 0040,735)
_oPrn:Box(_nMarBottom - 0100,0735,_nMarBottom - 0040,820)
_oPrn:Box(_nMarBottom - 0040,0650,_nMarBottom - 0020,820)
_oPrn:Box(_nMarBottom,0650,_nMarBottom - 0020,820)

_oPrn:Box(_nMarBottom - 0040,0020,_nMarBottom - 0080,650)	//Box Observa็ใo
_oPrn:Box(_nMarBottom - 0020,0020,_nMarBottom - 0040,150)	//Box Comprador
_oPrn:Box(_nMarBottom - 0020,0150,_nMarBottom - 0040,650)	//Box Aprovador
_oPrn:Box(_nMarBottom,0020,_nMarBottom - 0020,650)			//Box Legenda

_oPrn:Say(_nMarBottom - 0092,0025, "TRANSPORTADORA:", 	_oFtCabec)
//_oPrn:Say(_nMarBottom - 0083,0025, AllTrim (""), _oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0092,0280, "CIF/FOB:", 	_oFtCabec)	
_oPrn:Say(_nMarBottom - 0083,0280, IF( TRB2->C7_TPFRETE $ "F","FOB",IF( TRB2->C7_TPFRETE $ "C","CIF"," " )), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0092,0355, "OBS DO FRETE:", 	_oFtCabec)
_oPrn:Say(_nMarBottom - 0083,0355, "", 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)

_oPrn:Say(_nMarBottom - 0072,0025, "OBSERVAวิES:", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)

If( Len(_cObs) <= 190 )
	_oPrn:Say(_nMarBottom - 0066,0025, AllTrim(_cObs), 	_oFtObs, 1000, 0, CLR_BLACK, 0, 0)
Else
	_oPrn:Say(_nMarBottom - 0066,0025, AllTrim(SUBSTR(_cObs,001,190)),  _oFtObs, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:Say(_nMarBottom - 0060,0025, AllTrim(SUBSTR(_cObs,191,190)),  _oFtObs, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:Say(_nMarBottom - 0054,0025, AllTrim(SUBSTR(_cObs,381,190)),  _oFtObs, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:Say(_nMarBottom - 0048,0025, AllTrim(SUBSTR(_cObs,571,190)),  _oFtObs, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:Say(_nMarBottom - 0042,0025, AllTrim(SUBSTR(_cObs,761,190)),  _oFtObs, 1000, 0, CLR_BLACK, 0, 0)
EndIf

_oPrn:Say(_nMarBottom - 0032,0025, "COMPRADOR RESPONSมVEL:", 				_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0023,0025, Substr(UPPER(_cComprador),1,60), 		_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)

//_oPrn:Say(_nMarBottom - 0032,0155, "APROVADOR(ES):", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
//_oPrn:Say(_nMarBottom - 0023,0155, IIF(mv_par04 == 3,"",UPPER(_cAprov)), 	_oFtAprov, 1000, 0, CLR_BLACK, 0, 0)

//_oPrn:Say(_nMarBottom - 0012,0025, "LEGENDAS DA APROVAวรO:", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
//_oPrn:Say(_nMarBottom - 0003,0025, "BLQ = BLOQUEADO | OK = LIBERADO | ?? = AGUAR. LIB. | ## = NIVEL LIB.", 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)

_oPrn:Say(_nMarBottom - 0092,0650, "      IPI:" + IIF(mv_par06 == 1,Transform(_nTotIPI, "@E 99,999.99"),"0,00"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0083,0650, "    FRETE:" + IIF(mv_par06 == 1,Transform(_nTotFrete, "@E 99,999.99"),"0,00"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0073,0650, "     ICMS:" + IIF(mv_par06 == 1,Transform(_nTotICMS, "@E 99,999.99"),"0,00"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0063,0650, "  ICMS ST:" + IIF(mv_par06 == 1,Transform(_nTotIcmRet, "@E 99,999.99"),"0,00"), _oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0053,0650, "ICM DIFAL:" + IIF(mv_par06 == 1,Transform(_nTotIcmCom, "@E 99,999.99"),"0,00"), _oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0043,0650, " DESCONTO:" + IIF(mv_par06 == 1,Transform(_nTotDesc, "@E 99,999.99"),"0,00"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)

_oPrn:Say(_nMarBottom - 0085,0739, " TOTAL MERCADORIA:", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0077,0740, + IIF(mv_par06 == 1,Transform(_nTotMerc, "@E 99,999,999.999999"),"0,00"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0065,0735, " TOTAL C/ IMPOSTOS:", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0057,0740, + IIF(mv_par06 == 1,Transform(_nTotImp + _nTotDesp + _nTotIcmRet + _nTotIcmCom + _nTotFrete - _nTotDesc , "@E 99,999,999.999999"),"0,00"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0027,0680, " TOTAL GERAL:", 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0027,0735, " " + IIF(mv_par06 == 1,Transform(_nTotMerc + _nTotIPI + _nTotDesp + _nTotIcmRet + _nTotIcmCom + _nTotFrete - _nTotDesc, "@E 99,999,999.999999"),"0,00"), 	_oFtRodape, 1000, 0, CLR_BLACK, 0, 0)
_oPrn:Say(_nMarBottom - 0007,0700, IIF((TRB2->C7_CONAPRO != "B"), " PEDIDO LIBERADO", " PEDIDO BLOQUEADO"), 	_oFtCabec, 1000, 0, CLR_BLACK, 0, 0)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _LAYOUT  บ Autor ณ Evandro Mugnol     บ Data ณ 29/01/2019  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Gera a impressao dos dados para o layout.                  บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _LAYOUT()

ProcRegua(_nNumReg)
_nNumRegIm := 0

TRB1->(DbGoTop())
While TRB1->(!EOF())
	_nNumRegIm++
	IncProc("Imprimindo registro " + cValToChar(_nNumRegIm) + " de " + cValToChar(_nNumReg) + "...")

	_nLinhaImp++
	_nLinha += _nItemAltu
	
	If _lImpInic = .T.
		_NOVAPAG()
		_L1_CABE()
		_lImpInic := .F.
	EndIf

	_L1_LIN1()

	TRB1->(DbSkip())
EndDo

If _nLinhaImp >= 14
	_NOVAPAG()
	_RODAPE()
Else
	_RODAPE()
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _L1_CABE บ Autor ณ Evandro Mugnol     บ Data ณ 29/01/2019  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Gera a impressao do cabe็lho dos itens do pedido.          บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _L1_CABE()

//Titulo do Relatorio de Fornecedor
If mv_par04 == 1
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0002, "Item"				, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0030, "SC"					, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0048, "Grupo/Tp"			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0086, "Prod."				, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0115, "Descri็ใo"			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0360, "UN"					, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0380, "Marca Cotada"		, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0440, "Quantidade"			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0503, "Vlr Unit."			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0554, "Vlr Total"			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0599, "Vlr Desc."			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0641, "%IPI"				, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0663, "%ICMS"				, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0689, "ICMS-ST Total"		, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0750, "Dt. Fatur."			, _oFtCabec, 1000, 0, CLR_BLACK, 0, 0)
Endif

_nLinha += _nItemAltu
_nLinha += (_nItemAltu / 2)
_oPrn:Line(_nLinha, _nMarLeft, _nLinha, _nMarRight) 	//Imprime linha divisoria entre cabe็alho e itens
_nLinha -= (_nItemAltu / 2)
_nLinha += _nItemAltu

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _L1_LIN1 บ Autor ณ Evandro Mugnol     บ Data ณ 29/01/2019  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Gera a impressao dos itens do pedido.                      บฑฑ
ฑฑบ           ณ                                                            บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _L1_LIN1()

Local nX
Local nBegin
_Produto  := AllTrim(TRB1->C7_PRODUTO)
_DescPrd  := AllTrim(TRB1->C7_DESCRI)
_nPosicao := 430

If !Empty(TRB1->C7OBSM) .And. !(TRB1->C7_OBS $ TRB1->C7OBSM)

	cVar:="cObs"
	Eval(MemVarBlock(cVar),TRB1->C7OBSM)

	aAux1 := strTokArr(cObs, chr(13)+chr(10))
	nQtdLinhas := 0
	For nX := 1 To  Len(aAux1)
		nQtdLinhas += Ceiling(Len(aAux1[nX]) / 70)
	Next nX

	_R110cObs(aAux1, 70)

Endif

If mv_par04 == 1
	_oPrn:SayAlign(_nLinha, _nMarLeft + 002, TRB1->C7_ITEM, 										_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 022, TRB1->C7_NUMSC, 										_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 051, TRB1->B1_GRUPO+"/"+TRB1->B1_TIPO, 						_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0086, AllTrim(SUBSTR(TRB1->C7_PRODUTO,1,06)), 				_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0360, AllTrim(TRB1->C7_UM), 								_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0380, AllTrim(SUBSTR(TRB1->C7_MARCAC,1,25)), 				_oFtObs,  1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0407, TRANSFORM(TRB1->C7_QUANT, "@E 99,999,999.999999"),	_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0475, TRANSFORM(TRB1->C7_PRECO, "@E 9,999,999.999999"), 	_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0538, TRANSFORM(TRB1->C7_TOTAL, "@E 99,999,999.99")	, 		_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0592, TRANSFORM(TRB1->C7_VLDESC, "@E 999,999.99"), 			_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0646, TRANSFORM(TRB1->C7_IPI, "@R 99"), 					_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0669, TRANSFORM(TRB1->C7_PICM, "@R 99"), 					_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha, _nMarLeft + 0701, TRANSFORM(TRB1->C7_VALSOL, "@E 999,999.99")	, 		_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
	_oPrn:SayAlign(_nLinha-1, _nMarLeft + 0753, TRB1->C7_DATPRF, 									_oFtDtEntr, 1000, 0, CLR_BLACK, 0, 0)
EndIf

//Calcula os Totais de IPI, ICMS, FRETE, DESPESA, TOTAL MERCADORIA, TOTAL COM IMPOSTOS E TOTAL GERAL
_nTotIPI    += TRB1->C7_VALIPI
_nTotICMS   += TRB1->C7_VALICM
_nTotFrete  += TRB1->C7_VALFRE
_nTotMerc   += TRB1->C7_TOTAL
_nTotDesp   += TRB1->C7_DESPESA
_nTotImp    += TRB1->C7_TOTAL + TRB1->C7_VALIPI
_nTotIcmRet += TRB1->C7_ICMSRET
_nTotIcmCom += TRB1->C7_ICMCOMP
_nTotDesc	+= TRB1->C7_VLDESC

If !Empty(TRB1->C7_OBS) 
	_cObs += "IT"+TRB1->C7_ITEM + ": " + AllTrim(TRB1->C7_OBS)
	If (_nTot703 > _nValObs)
		_cObs += " - "
	EndIf
	_nValObs++
EndIf

If mv_par04 == 1
	nTamDesc := 45
	If Len(_DescPrd) > 45
		// Imprime descri็ใo do produto quando tem mais que 45 caracteres (2 ou mais linhas junto com conte๚do do campo C6_OBSM)
		nLinTot := MlCount(_DescPrd,nTamDesc)

		_oPrn:SayAlign(_nLinha, _nMarLeft + 0115, MemoLine(_DescPrd,nTamDesc,1), 			_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		For nBegin := 2 To nLinTot
			_nLinha += 10
			_oPrn:SayAlign(_nLinha, _nMarLeft + 0115, MemoLine(_DescPrd,nTamDesc,nBegin), 	_oFtItem, 1000, 0, CLR_BLACK, 0, 0)
		Next nBegin

		_nLinha += 8
		_nLinha += (8 / 2)
		If ( _nLinha <= _nMarBottom - 20)
			_oPrn:Line(_nLinha, _nMarLeft, _nLinha, _nMarRight) 	//Imprime linha divisoria entre cabe็alho e itens
		EndIf	
		_nLinha -= (8 / 2)
	Else 
		// Imprime descri็ใo do produto quando tem menos que 70 caracteres (somente 1 linha)
		_oPrn:SayAlign(_nLinha, _nMarLeft + 0115, MemoLine(_DescPrd,nTamDesc,1), 	_oFtItem, 1000, 0, CLR_BLACK, 0, 0)

		_nLinha += _nItemAltu
		_nLinha += (_nItemAltu / 2)
		If ( _nLinha <= _nMarBottom - 20)
			_oPrn:Line(_nLinha, _nMarLeft, _nLinha, _nMarRight) 	//Imprime linha divisoria entre cabe็alho e itens
		EndIf
		_nLinha -= (_nItemAltu / 2)
	EndIf
EndIf

If ( _nLinha >= _nPosicao ) .AND. ( _nTot703 < 20 )
	_nFator := 150
Else
	_nFator := 20
EndIf

If ( _nLinha >= _nMarBottom - _nFator )
	_lImpInic := .T.
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa  ณ _R110cObsบ Autor ณ Evandro Mugnol     บ Data ณ 31/01/2019  บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Receber conte๚do do campo C6_OBMS para a impressใo correta บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametros ณ aAux1    => Pegar array do cObs01 onde foi separado com    ณฑฑ
ฑฑบ           ณ             "enter" como quebra de linha                   บฑฑ
ฑฑบ           ณ nTamLinha=> Defini็ใo do mแximo de caracteres que precisa  บฑฑ
ฑฑบ           ณ             ser definido na linha do campo C6_OBSM         บฑฑ
ฑฑศอออออออออออฯอออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
Static Function _R110cObs(aAux1, _nTamLinha)

Local cVar
Local nObs := 1
Local xTam := "( _nTamLinha *( nY - 1 )) + 1"
Local nX, nY
Local nQtdLinhas := 0
Local Comple := ""
For nX := 1 To Len(aAux1)
	nY := 1
	nQtdLinhas := Ceiling(Len(aAux1[nX]) / _nTamLinha)
	While nY <= nQtdLinhas .And. nObs <= 16
		cVar   := "cObs"
		&cVar  := Substr(aAux1[nX], &xTam , IIF( nY <> nQtdLinhas, _nTamLinha, (( Len(aAux1[nX]) - ( &xTam ))) + 1 ))
		Comple += " " + AllTrim(&cVar)
		nObs++
		nY++
	EndDo
Next nY	

_DescPrd += " ==> " + AllTrim(Comple)	// NรO MEXER NESTA LINHA DEVIDO AO CONTEฺDO DO CAMPO _Comple

Return
