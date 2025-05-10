#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"

User Function ML_CGAD()

	aHeader := {}
	aCols   := {}
	aAdd(aHeader, {"Serie",           "D1_Serie",       "",                3,  0,  ".F.",                " ",  "C",  "SD1" } )
	aAdd(aHeader, {"Nota Fiscal",     "D1_Nota",        "",                9,  0,  ".F.",                " ",  "C",  "SD1" } )
	aAdd(aHeader, {"Item",            "D1_Item",        "",                2,  0,  ".F.",                " ",  "C",  "SD1" } )
	aAdd(aHeader, {"Pedido",          "D1_Pedido",      "",                6,  0,  ".F.",                " ",  "C",  "SD1" } )
	aAdd(aHeader, {"Produto",         "D1_Produto",     "",               15,  0,  ".F.",                "SB1","C",  "SD1" } )
	aAdd(aHeader, {"Descricao",       "D1_Descr",       "",               30,  0,  ".F.",                " ",  "C",  "SD1" } )
	aAdd(aHeader, {"Fornec.",         "D1_Fornec",      "",                9,  0,  ".F.",                "SA2","C",  "SD1" } )
	aAdd(aHeader, {"Nome",            "D1_Nome",        "",               30,  0,  ".F.",                " ",  "C",  "SD1" } )
	aAdd(aHeader, {"Quant..",         "D1_Quant",       "@e 999,999.99",   9,  2,  ".F.",                " ",  "N",  "SD1" } )
	aAdd(aHeader, {"Um",              "D1_UM",          ""             ,   2,  0,  ".F.",                " ",  "C",  "SD1" } )
	aAdd(aHeader, {"Quant.Sec.",      "D1_QtSec",       "@e 999,999.99",   9,  2,  ".F.",                " ",  "N",  "SD1" } )
	aAdd(aHeader, {"Um Sec.",         "D1_UMSec",       ""             ,   2,  0,  ".F.",                " ",  "C",  "SD1" } )
	aAdd(aHeader, {"Vlr Unit.",       "D1_Valor",       "@e 999,999.99",   9,  2,  ".F.",                " ",  "N",  "SD1" } )
	aAdd(aHeader, {"Total",           "D1_Total",       "@e 999,999.99",  11 , 2,  ".F.",                " ",  "N",  "SD1" } )
	aAdd(aHeader, {"Emissao",         "D1_Emissao",     "@e"           ,   8 , 0,  ".F.",                " ",  "D",  "SD1" } )
	aAdd(aHeader, {"Comprador",       "D1_Comprad",     "",                6,  0,  ".T.",                " ",  "C",  "SD1" } )
	aAdd(aHeader, {"Nome",            "D1_NomeCom",     "",               30,  0,  ".T.",                " ",  "C",  "SD1" } )
	aAdd(aHeader, {"% Comissao",      "D1_Comiss",      "@e 999,999.99",  11 , 2,  ".T.",                " ",  "N",  "SD1" } )
	aAdd(aHeader, {"% Vlr Comis.",    "D1_VlComis",     "@e 999,999.99",  11 , 2,  ".T.",                " ",  "N",  "SD1" } )

	cPerg := "MLCGAD"
	Pergunte(cPerg,.T.)                                   

	//'SD1.D1_PERCREN, SC7.C7_TPCOM, SC7.C7_TPANIM, SC7.C7_COMPR, '+;
	//'SB1.B1_DESC, SA2.A2_NOME, SA3.A3_NOME, SA3.A3_CARCACA '+;
	///"AND SD1.D1_COD IN ('001051','001048','001037','001052','001049','001040','001053','001050','001044','000431','000439','000432') "+;        // NOVO JRL 19/02/2004
	//'SD1.D1_VUNIT, SD1.D1_TOTAL, convert(char(12),convert(datetime,SD1.D1_DTDIGIT),3) as D1_DTDIGIT, '+;

	// Query para pegar itens que geram comissao    

	cQuery := 'SELECT SD1.D1_SERIE, SD1.D1_NFPROD, SD1.D1_DOC, SD1.D1_ITEM, '+;
	'SD1.D1_PEDIDO, SD1.D1_COD, SD1.D1_FORNECE, SD1.D1_LOJA, '+;
	'SD1.D1_QUANT, SD1.D1_UM, SD1.D1_QTSEGUM, SD1.D1_SEGUM, '+;
	'SD1.D1_VUNIT, SD1.D1_TOTAL, convert(char(12),convert(datetime,SD1.D1_DTDIGIT),3) as D1_DTDIGIT, '+;
	'SC7.C7_COMPR, SA3.A3_NOME, SB1.B1_DESC, SA2.A2_NOME '+;
	'FROM '+;
	'SF1' + cEmpAnt + '0 SF1, '+;
	'SD1' + cEmpAnt + '0 SD1, '+;  
	'SC7' + cEmpAnt + '0 SC7, '+;
	'SB1' + cEmpAnt + '0 SB1, '+;
	'SA2' + cEmpAnt + '0 SA2, '+;
	'SA3' + cEmpAnt + '0 SA3 '+;
	'WHERE '+;
	"SF1.F1_FILIAL BETWEEN '" + Mv_Par05 + "' AND '" + Mv_Par06 + "'" +;
	"AND SF1.F1_DTDIGIT Between '" + Dtos(Mv_Par01) + "' and '" + Dtos(Mv_Par02)+ "' "+;
	"AND SF1.F1_TIPO = 'N' "+;
	"AND SF1.D_E_L_E_T_ <> '*' "+;
	"AND SD1.D1_FILIAL BETWEEN '" + Mv_Par05 + "' AND '" + Mv_Par06 + "'" +;
	'AND SD1.D1_DOC = SF1.F1_DOC '+;
	'AND SD1.D1_SERIE = SF1.F1_SERIE '+;
	'AND SD1.D1_FORNECE = SF1.F1_FORNECE '+;
	'AND SD1.D1_LOJA = SF1.F1_LOJA '+;
	"AND SD1.D1_PEDIDO <> '' "+;
	"AND SD1.D1_COD IN ('000230') "+;
	"AND SD1.D_E_L_E_T_ <> '*' "+;
	"AND SC7.C7_FILIAL BETWEEN '" + Mv_Par05 + "' AND '" + Mv_Par06 + "'" +;
	'AND SC7.C7_NUM = SD1.D1_PEDIDO '+;
	'AND SC7.C7_ITEM = SD1.D1_ITEMPC '+;
	"AND SC7.C7_COMPR Between '" + Mv_Par03 + "' and '" + Mv_Par04 + "' "+;
	"AND SC7.C7_PRODUTO = SD1.D1_COD "+;
	"AND SC7.C7_LOJA	= SD1.D1_LOJA "+;
	"AND SC7.C7_FORNECE = SD1.D1_FORNECE "+;
	"AND SC7.D_E_L_E_T_ <> '*' "+;
	"AND SB1.B1_FILIAL = '" + xFilial('SB1') + "' "+;
	'AND SB1.B1_COD = SD1.D1_COD '+;
	"AND SB1.D_E_L_E_T_ <> '*' "+;
	"AND SA2.A2_FILIAL = '" + xFilial('SA2') + "' "+;
	'AND SA2.A2_COD = SD1.D1_FORNECE '+;
	'AND SA2.A2_LOJA = SD1.D1_LOJA '+;
	"AND SA2.D_E_L_E_T_ <> '*' "+;
	"AND SA3.A3_FILIAL = '" + xFilial('SA3') + "' "+;
	'AND SA3.A3_COD = SC7.C7_COMPR '+;
	"AND SA3.D_E_L_E_T_ <> '*' "+;
	'ORDER BY '+;
	'SF1.F1_FILIAL, '+;
	'SF1.F1_DTDIGIT '

	TCQuery cQuery Alias 'TMP' New
	DbSelectArea('TMP')

	Processa( {|| PCalcula() },"Selecionando Notas Fiscais de Compra ","Aguarde..." )

	If Len(acols) > 0
		_nMax := Len( aCols )
		@ 000,000 TO 280,700 DIALOG DMER003 TITLE "Comissionamento Sobre Compras"
		@ 005,005 TO 120,350 MultiLine Modify Delete Valid L903_NLine() Freeze 1
		@ 125,260 BmpButton Type 01 Action FPGrava()
		@ 125,290 BmpButton Type 06 Action FImpre()
		@ 125,320 BmpButton Type 02 Action Close(DMER003)
		Activate Dialog DMER003 Centered
	Else
		MsgBox('Nao existem notas selecionadas para estes parametros', 'Atencao')
	EndIf

	DbSelectArea('TMP')
	DbCloseArea()
Return(Nil)

Static Function L903_Nline()
	DlgRefresh(DMER003)
Return(.T.)

//Calcula Comissao
Static Function PCalcula()
	ProcRegua(RecCount())
	DbSelectArea("TMP")
	Dbgotop()
	Do While .not. Eof()
		IncProc()

		nValComis := Round( 5 * TMP->D1_TOTAL / 100 ,2)

		_xTpComp:="Carcaca"

		_xTpAnim := "Boi"

		//Adiciona os valores dos campos no acols
		//_xTpComp, _xTpAnim, TMP->D1_PERCREN, TMP->C7_VEND, TMP->A3_NOME,;

		aAdd( aCols,{ TMP->D1_SERIE, TMP->D1_DOC, TMP->D1_ITEM, TMP->D1_PEDIDO,;
		TMP->D1_COD, TMP->A2_NOME, TMP->D1_FORNECE + "/" + TMP->D1_LOJA,;
		TMP->B1_DESC, TMP->D1_QUANT, TMP->D1_UM, TMP->D1_QTSEGUM,;
		TMP->D1_SEGUM, TMP->D1_VUNIT, TMP->D1_TOTAL, "" ,;
		TMP->C7_COMPR, TMP->A3_NOME, 5, nValComis, .F.} )

		DbSelectArea("TMP")
		DbSkip()
	EndDo
Return(Nil)

//Não é para gravar comissao no SE3 - Geraldo
Static Function FPGrava()
	//Processa( {|| Pgrava() },"Gravando Comissoes de Compras","Aguarde..." )
	Close(DMER003)
Return(Nil)

Static Function FImpre()
	Local _nn
	Titulo  := "COMISSAO COMPRA DE GADO  -  PERIODO: "+Dtoc(Mv_par01) + "-" + dtoc(Mv_par02)
	Tamanho :="M"
	CDESC1  :=OemToAnsi("Relatorio de comissoes de compras")
	Cdesc2  :=OemToAnsi("")
	Cdesc3  :=OemToAnsi("")
	areturn :={"Zebrado",1,"Administracao",2,2,1,"",1 }
	nomeprog:="ML_CGAD"
	nLASTKEY:= 0
	cstring :="SA1"
	wnrel   :="ML_CGAD"
	LI      := 99
	wnrel:=setprint(cstring,wnrel,"",titulo,cdesc1,cdesc2,cdesc3,.T.)

	If LastKey()== 27 .or. nLastKey == 27
		return
	EndIf
	fErase(__RelDir + wnrel + '.##r')
	Setdefault(aReturn,cString)

	If LastKey()== 27 .or. nLastKey == 27
		return
	EndIf

	M_Pag:=1
	Cabec1 :="Emissao       NF     Fornecedor              Produto                            Cabecas    Val Total    %Com    Val Comissao"
	Cabec2 :=""

	//Cabec1 :="Ser Nota   IT Pedido Produto-Descricao                Fornecedor - Nome                          "
	//Cabec2 :="    Emissao    Tp Compra     Quantidade     Secundaria     Vlr Unit.  Vlr Total     Rend.(%)    % Comissao  Vlr Comissao "
	/*/
	UNI 999999 99 999999 99999999999999 dddddddddddddddddddddddddddddd 999999/99 dddddddddddddddddddddddddddddd 99,999.99 kg 99999.99 cc
	99,999.99 9999,999.99 99/99/99 Peso Vivo Novilho 9999.99% 999999-mmmmmmmmmmmmmmmmmmmmmmmmmmmmmm    999,9%     999,999.99
	0123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
	0         1         2         3         4         5         6         7         8         9         0         1         2         3
	/*/

	_aItens := aClone( aCols )
	aSort( _aItens ,,,{ |X,Y| X[16]+X[15] < Y[16]+Y[15] } )

	cVend := "*******"

	For _nn := 1 to Len(_aItens)
		//		"AND SC7.C7_FILIAL = '" + xFilial('SC7') + "' "+;
		//		"SF1.F1_FILIAL = '" + xFilial('SF1') + "' " +;
		// 		"AND SC7.C7_FILIAL = '" + xFilial('SC7') + "' "+;
		// Query para pegar itens que nao geram comissao     

		///			'SB1.B1_DESC, SA2.A2_NOME, SA3.A3_NOME, SA3.A3_CARCACA '+;
		If  cVend <> _aItens[_nn,16]      

			nTCabn 	:= 0

			//		"AND SC7.C7_TPANIM <> '' "+;
			//		"AND SC7.C7_TPCOM <> '' "+;      

			///"AND SF1.F1_DTDIGIT Between '" + Dtos(Mv_Par01) + "' and '" + Dtos(Mv_Par02)+ "' "+;

			cQuery2 := 'SELECT SD1.D1_SERIE, SD1.D1_NFPROD, SD1.D1_DOC, SD1.D1_ITEM, '+;
			'SD1.D1_PEDIDO, SD1.D1_COD, SB1.B1_DES , CSD1.D1_FORNECE, SD1.D1_LOJA, '+;
			'SA2.A2_NOME , SD1.D1_QUANT, SD1.D1_UM, SD1.D1_QTSEGUM, SD1.D1_SEGUM, '+;
			'SD1.D1_VUNIT, SD1.D1_TOTAL, convert(char(12),convert(datetime,SD1.D1_DTDIGIT),3) as D1_DTDIGIT, '+;
			'SC7.C7_COMPR, SA3.A3_NOME '+;
			'FROM '+;
			'SF1' + cEmpAnt + '0 SF1, '+;
			'SD1' + cEmpAnt + '0 SD1, '+;
			'SC7' + cEmpAnt + '0 SC7, '+;
			'SB1' + cEmpAnt + '0 SB1, '+;
			'SA2' + cEmpAnt + '0 SA2, '+;
			'SA3' + cEmpAnt + '0 SA3 '+;
			'WHERE '+;
			"SF1.F1_FILIAL BETWEEN '" + Mv_Par05 + "' AND '" + Mv_Par06 + "'" +;  
			"AND SF1.F1_DTDIGIT Between '" + Dtos(Mv_Par01) + "' and '" + Dtos(Mv_Par02)+ "' "+;
			"AND SF1.F1_TIPO = 'N' "+;
			"AND SF1.D_E_L_E_T_ <> '*' "+;
			"AND SD1.D1_FILIAL BETWEEN '" + Mv_Par05 + "' AND '" + Mv_Par06 + "'" +;
			'AND SD1.D1_DOC = SF1.F1_DOC '+;
			'AND SD1.D1_SERIE = SF1.F1_SERIE '+;
			'AND SD1.D1_FORNECE = SF1.F1_FORNECE '+;
			'AND SD1.D1_LOJA = SF1.F1_LOJA '+;
			"AND SD1.D1_PEDIDO <> '' "+;
			"AND SD1.D1_COD NOT IN ('000230') "+;
			"AND SD1.D_E_L_E_T_ <> '*' "+;
			"AND SC7.C7_FILIAL BETWEEN '" + Mv_Par05 + "' AND '" + Mv_Par06 + "'" +;
			'AND SC7.C7_NUM = SD1.D1_PEDIDO '+;
			'AND SC7.C7_ITEM = SD1.D1_ITEMPC '+;
			"AND SC7.C7_COMPR <> '' "+;
			"AND SC7.C7_COMPR = '" + _aItens[_nn,19] + "' "+;
			"AND SC7.C7_PRODUTO = SD1.D1_COD "+;
			"AND SC7.C7_LOJA	= SD1.D1_LOJA "+;
			"AND SC7.C7_FORNECE = SD1.D1_FORNECE "+;
			"AND SC7.D_E_L_E_T_ <> '*' "+;
			"AND SB1.B1_FILIAL = '" + xFilial('SB1') + "' "+;
			'AND SB1.B1_COD = SD1.D1_COD '+;
			"AND SB1.D_E_L_E_T_ <> '*' "+;
			"AND SA2.A2_FILIAL = '" + xFilial('SA2') + "' "+;
			'AND SA2.A2_COD = SD1.D1_FORNECE '+;
			'AND SA2.A2_LOJA = SD1.D1_LOJA '+;
			"AND SA2.D_E_L_E_T_ <> '*' "+;
			"AND SA3.A3_FILIAL = '" + xFilial('SA3') + "' "+;     
			'AND SA3.A3_COD = SC7.C7_COMPR '+;
			"AND SA3.D_E_L_E_T_ <> '*' "+;
			'ORDER BY '+;
			'SF1.F1_FILIAL, '+;
			'SF1.F1_DTDIGIT '




			TCQuery cQuery2 Alias '_pr1' New

			DbSelectArea('_pr1')
			_pr1 -> (dbgotop ())
			Do While !EOF()
				nTCabn	+= _PR1->D1_QTSEGUM
				_pr1 -> (dbskip ())
			EndDo

			_pr1 -> (dbclosearea ())

		EndIf
		// Final Query para pegar itens que nao calcula comissao

		If Li > 60 .or. cVend <> _aItens[_nn,19]

			If _nn > 1 .and. cVend <> _aItens[_nn,19]
				Li += 1
				@ Li , 000 Psay "Total Classes Comissionadas"
				@ Li , 79  PSay nTCab   Picture "@e 99999"
				@ Li , 86 PSay nTTotal Picture "@e 99,999,999.99"
				@ Li , 109 PSay nTComis Picture "@e 99,999,999.99"
				Li += 1
				@ Li , 000 Psay Replicate("-",132)
				Li += 1
				@ Li , 000 Psay "Total Classes Nao Comissionadas "
				@ Li , 79  PSay nTCabn   Picture "@e 99999"
				Li += 1
				@ Li , 000 Psay Replicate("-",132)
			EndIf

			If cVend <> _aItens[_nn,19]
				cVend := _aItens[_nn,19]
				nTComis := 0
				nTCab	  := 0
				nTTotal := 0       
			EndIf

			Li := Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,18)+1
			@Li , 000 PSay cVend + "-"+ _aItens[_nn,20]
			LI += 2
		End

		nTComis += _aItens[_nn,19]
		nTCab   += _aItens[_nn,11]
		nTTotal += _aItens[_nn,14]

		_linha1 := TransForm(_aItens[_nn,15],"@E") + ;
		_aItens[_nn,2] + "   " + ;
		Left(_aItens[_nn,8],20) + "    " + ;
		Left(_aItens[_nn,6],30)  + "    "+;
		TransForm(_aItens[_nn,11],"@e 99999")  + "  " + ;
		TransForm(_aItens[_nn,14],"@e 99,999,999.99")+"  " + ;
		TransForm(_aItens[_nn,18],"@e 999.99%")  + "  " + ;
		TransForm(_aItens[_nn,19],"@e 9,999,999.99")

		_linha3 := "    "

		@ LI , 000 Psay _linha1
		Li += 1
	Next 

	If _nn > 1
		Li += 1
		@ Li , 000 Psay "Total Classes Comissionadas"
		@ Li , 79  PSay nTCab   Picture "@e 99999"
		@ Li , 86  PSay nTTotal Picture "@e 99,999,999.99"
		@ Li , 109 PSay nTComis Picture "@e 99,999,999.99"
		Li += 1
		@ Li , 000 Psay Replicate("-",132)
		Li += 1
		@ Li , 000 Psay "Total Classes Nao Comissionadas "
		@ Li , 79  PSay nTCabn   Picture "@e 99999"
		Li += 1
		@ Li , 000 Psay Replicate("-",132)
	EndIf

	If aReturn[5] == 1
		Set Printer to Commit
		Ourspool(wnrel)
	EndIf

	FT_PFLUSH()
Return(Nil)

