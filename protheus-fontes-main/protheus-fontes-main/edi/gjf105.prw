#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
User Function GJF105()
	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบPrograma  ณGJF105  บAutor  ณGiuliano Forgiarini   บ Data ณ  18/03/10   บฑฑ
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบDesc.     ณ Geracao de Arquivos EDI Estoque                            บฑฑ
	ฑฑบ          ณ                                                            บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบUso       ณ AP                                                        บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
	*/
	cIPerg 	:= "GJF105"
	_aTexto := {}
	if Pergunte(cIPerg,.T.)

		if empty(mv_par01) .or. empty(mv_par02) .or. empty(mv_par03) .or. empty(mv_par05)

			Help(" ",1,"ExecInterr",,'Existem perguntas em branco',4,1)
			return
		endif

		MsgRun("Aguarde... Gerando o Arquivo...",,{||  SFSeleEST() }) 
		MsgRun("Aguarde... Gerando o Arquivo...",,{||  SFGeraArquivo() })

	Endif               
Return

Static Function SFSeleEST()		

	_cQuery := ""

	_cQuery += " SELECT B1_COD,Z8_FIL, SUM(Z8_PESO) AS PESO "

	_cQuery += " FROM "+ RetSqlName("SB1")+","
	_cQuery +=           RetSqlName("SZ8")

	_cQuery += " WHERE "+RetSqlName("SZ8")+".D_E_L_E_T_ <> '*' AND "
	_cQuery +=           RetSqlName("SB1")+".D_E_L_E_T_ <> '*' AND " 
	_cQuery += "  SZ8010.Z8_DATAE = ''  AND  B1_MSBLQL <> '1' AND " 
	_cQuery += "   B1_FAM = '" + mv_par01 + "' AND " 
	_cQuery += "  ((Z8_DATAS > '" + dtos(DDATABASE) + "' AND Z8_DATA <= '" + dtos(DDATABASE) + "') OR" 
	_cQuery += "   (Z8_DATAS = ''                        AND Z8_DATA <= '" + dtos(DDATABASE) + "')) "
	_cQuery += "   AND Z8_FILIAL  = '" + xfilial("SZ8") + "'" 
	_cQuery += "   AND B1_FILIAL  = '" + xfilial("SB1") + "'" 
	_cQuery += "   AND B1_COD = Z8_CODORI " 
	_cQuery += "   AND Z8_FILORI = '" + xfilial('SB1') + "'"
	_cQuery += "  GROUP BY B1_COD,Z8_FIL "
	_cQuery += "  ORDER BY B1_COD,Z8_FIL "

	//	* Mostrar a consulta */
	@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	Activate Dialog oDlgMemo

	if select("PER") <> 0
		DBSelectArea("PER")
		DBCloseArea()
	endif

	TcQuery _cQuery New Alias "PER"
	DBSelectArea("PER")
	PER->(DBGoTop())    

	_DocAtual   := '' 
	_aTexto     := {}   

	//Montagem do cabe็alho do relatorio de estoque

	PUTMV('SI_NESTEDI',GETMV('SI_NESTEDI')+1)

	_cNumAtu := GETMV('SI_NESTEDI')

	_cDtHrEmis := substr(padr(DDATABASE + strtran(time(),':',''),12,''),1,12)  //Data e hora da emissใo do Relatorio
	_cDtHrReal := substr(padr(DDATABASE + strtran(time(),':',''),12,''),1,12)  //Data e hora da atualiza็ใo do relatorio

	if cFilAnt = '00'
		_CNPJ       := '88728027000146' 
		_Inscr      := '1090096949'
	elseif cFilAnt = '01'
		_CNPJ       := '88728027000227'
		_Inscr      := '1000086809'
	elseif cFilAnt = '02'
		_CNPJ       := '88728027000731'
		_Inscr      := '1091165278'
	endif  

	_CNPJDest := fBuscaCPO('SA1',1,xfilial('SA1')+mv_par03+mv_par04,'A1_CGC')

	do case
		case mv_par02 = '007980'       //Se for Angeloni
		_CNPJComp := '83646984000967'  //CNPJ da loja 7 - escritorio
	endcase		

	//        |Tipo (2) | |   Fun็ใo (3)    | |Num. Relatorio  (20)| |Data/hora emissao(12)| |Data/hora Realiz(12)| |Validade(12)| |Validade(12)|
	_cTexto := '01'      +  padr('9',3,'')   + strzero(_cNumAtu,20) +     _cDtHrEmis        +      _cDtHrReal      +   space(12)  +   space(12)

	//        |EAN Emis(13)| |EAN Dest(13)| |EAN compra(13)| |EAN Fornec(13)| |CNPJ Emiss(14)| | CNPJ Dest(14)| |CNPJ Comp(14)| |CNPJ Vend. (14)|
	_cTexto +=  space(13)   + space(13)    +    space(13)   +   space(13)    +      _CNPJ      +   _CNPJDest   +  _CNPJComp    +       _CNPJ

	Aadd(_aTexto,_cTexto)

	_nSeq := 0

	DbSelectArea('SB1')
	DbSelectArea('DA1')


	While ! PER->(Eof()) 

		//Montagem dos registros dos itens do relatorio de estoque

		_cCodProd := ''
		_cDescPro := ''  
		_nPreco   := 0.00 
		_cPreco   := ''
		_cPeso    := ''

		ZA1->(DbSetOrder(2))
		if ZA1->(DbSeek(xfilial('ZA1') + mv_par03 + mv_par04 + alltrim(B1_COD)))
			_cCodProd := ZA1->ZA1_CODCLI
		else
			ZA1->(DbSetOrder(1))
			if ZA1->(DbSeek(xfilial('ZA1') + mv_par03 + alltrim(B1_COD))) 
				_cCodProd := ZA1->ZA1_CODCLI 
			else
				alert('Correla็ใo de produtos nใo localizada!')
			endif		
		endif 

		_nSeq++                                                                            //Sequencial da linha dos itens 
		_cDescPro := substr(fBuscaCPO('SB1',1,xfilial('SB1')+ _cCodPro,'B1_DESC'),1,40)    //Descri็ใo do produto
		_nPreco   := fBuscaCPO('DA1',1,xfilial('DA1') + mv_par02 + _cCodProd,'DA1_PRCVEN') //Pre็o de venda
		_cPreco   := strzero(_nPreco * 100,15)                                             //Valor 

		//       |tipo(02)| | sequencial (04)| |Tipo codigo(03)| | Codigo Produto (14) | | Descricao Prod.(40)|
		_cTexto :=   '04'    + strzero(_nSeq,4) + padr('EN',3,'') + padr(_cCodProd,14,'') + apdr(_DescPro,40,'')    

		//       |Ref.Prod.(20)| |Nr.Lote (20)| |P.B.Venda(15)| |P.L.Venda(15)| |P.B.Custo(15)| |P.L.Custo(15)|
		_cTexto +=    space(20)   +  space(20)   +    _cPreco    +    _cPreco    +    _cPreco    +    _cPreco    

		//       |UN(03)| |Tip.Emb.(03)| |Nr.Unid. Emb.(05)|
		_cTexto +=   'KGM' +   space(3)   + replicate('0',5)

		Aadd(_aTexto,_cTexto)            


		//Montagem das quantidades dos itens 

		_cPeso   := strzero( PER->PESO * 100,15)    //Peso Real 

		//       |tipo(02)| |EAN Local Merc.(13)| |CNOJ loc. Merc.(14)| | Estoque Ideal (15) | |Un.(03)|
		_cTexto :=   '05'    + replicate('0',13)   +        _CNPJ        +   replicate('0',15)  +  'KGM'

		//       |Est.Real(15)| |Un.(03)| |Estoque Minimo(15)| |UM(03)| |Estoque Maximo(15)| |UM(03)| 
		_cTexto +=     _cPeso    +  'KGM'  +  replicate('0',15) +  'KGM' +  replicate('0',15) + 'KGM' 

		//       |Nivel Reposi็ใo(15)| |UM(03)| 
		_cTexto +=    replicate('0',15) + 'KGM' 

		Aadd(_aTexto,_cTexto)            		    
		PER->(DbSkip())

	enddo

Return

Static Function SFGeraArquivo()
	Local nTamLin, cLin, cCpo
	Local _x
	Private cString := ""
	Private cArqTxt := mv_par05
	Private nHdl    := fCreate(cArqTxt)
	Private cEOL    := "CHR(13)+CHR(10)"
	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif                      
	cCpo 	:= ""
	For _X := 1 to Len(_aTexto)
		cCpo    := _aTexto[_X]+cEOL
		fWrite(nHdl,cCpo,Len(cCpo))
	Next
	fClose(nHdl)
Return
