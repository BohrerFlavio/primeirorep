#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF103  ºAutor  ³Giuliano Forgiarini   º Data ³  23/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de Arquivos EDI NF                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

User Function GJF103()

	Private area      := getarea()
	Private cIPerg    := "GJF103"
	Private _aTexto   := {}
	Private _lOK      := .t.

	if Pergunte(cIPerg,.T.)

		if empty(mv_par02) .or. empty(mv_par04) .or. empty(mv_par06)
			alert('Parametros essenciais em branco!')
			_lOk := .f.
		endif

		if !file('I:\Saida')
			alert('Mapeamento de rede "I:\Saida\" não encontrado!')
			_lOk := .f.
		endif

	Endif

	if _lOk

		GeraTMP()

		aCampos := {}  
		AADD(aCampos,{"OKAY"    , "@X",  "OK"       })
		AADD(aCampos,{"CLIENTE" , "@X",  "Cliente"  })
		AADD(aCampos,{"LOJA"    , "@X",  "Loja"     })
		AADD(aCampos,{"DOC"     , "@X",  "Numero"   })
		AADD(aCampos,{"SERIE"   , "@!",  "Serie"    })
		AADD(aCampos,{"EMISS"   , ""  ,  "Emissao"  })
		AADD(aCampos,{"NOMCLI"  , "@X",  "Nome"     })

		aRotina  := { {"Gerar","u_GJF103Pr"  ,0,4}}

		cCadastro := 'Escolha de Documentos para Geração de Arquivo EDI'

		dbselectarea('TMP')

		TMP->(dbgotop())


		MarkBrowse("TMP","OKAY",,aCampos,,'S')                              //Mostra os campos do TMP no MarkBrow

	endif

return

//Função para gerar arquivo TMP
Static Function GeraTMP()
	_cQueryI := ""
	_cQueryI += "select F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_NOMCLI,F2_EMISSAO, F2_DOCEDI "
	_cQueryI += " FROM SF2010 (nolock)"   //(nolock)
	_cQueryI += "where "
	_cQueryI += "(F2_EMISSAO between '" + DTOS(mv_par01) + "' and '" + DTOS(mv_par02) + "') and "
	_cQueryI += "(F2_DOC between '" + mv_par06 + "' and '" + mv_par07 + "') and "
	_cQueryI += " F2_CLIENTE = '" + mv_par03 + "' and "
	_cQueryI += "(F2_LOJA between '"+ mv_par04 + "' and '" + mv_par05 + "') and "
	_cQueryI += RetSQLName("SF2") + ".D_E_L_E_T_ = '' and "
	_cQueryI += "F2_FILIAL = '" + cFilAnt + "' and "
	_cQueryI += "F2_DOCEDI = '' "
	_cQueryI += "order by F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if select("QRY") <> 0
		DBSelectArea("QRY")
		DBCloseArea()
	endif

	TcQuery _cQueryI New Alias "QRY"

	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário
	_aArqTrb := {}
	aStru := {}

	aadd(aStru,{"CLIENTE", "C",   06, 0,   "@!",'Cliente'})
	aadd(aStru,{"LOJA"   , "C",   02, 0,   "@!",'Loja'})
	aadd(aStru,{"DOC"    , "C",   09, 0,   "@!",'Numero'})
	aadd(aStru,{"SERIE"  , "C",   03, 0,   "@!",'Serie'})
	aadd(aStru,{"OKAY"   , "C",   01, 0,   "@!",'Ok'})
	aadd(aStru,{"EMISS"  , "D",   08, 0,   " " ,'Emissao'})
	aadd(aStru,{"NOMCLI" , "C",   20, 0,   "@!",'Nome'})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	If Select('TMP')<>0                               //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)


	QRY->(dbgotop())
	//Esse laço serve para atribuir ao TMP os valores
	while QRY->(!eof())
		DbSelectArea('TMP')
		reclock('TMP',.t.)
		TMP->CLIENTE := QRY->F2_CLIENTE
		TMP->LOJA    := QRY->F2_LOJA
		TMP->DOC     := QRY->F2_DOC
		TMP->SERIE   := QRY->F2_SERIE
		TMP->EMISS   := STOD(QRY->F2_EMISSAO)
		TMP->OKAY    := IIF(empty(QRY->F2_DOCEDI),SPACE(1),'S')  
		TMP->NOMCLI  := QRY->F2_NOMCLI
		msunlock()
		QRY->(dbskip())
	enddo
Return

//Função que aglutina os processamentos
//para geração do(s) arquivo(s) de NF
User Function GJF103Pr()

	Private _cNrDoc := ''
	Private _cDataArq := ""
	Private _cChavDoc := ""

	DbSelectArea('TMP')
	TMP->(DbGoTop())

	while TMP->(!eof())

		if TMP->OKAY <> 'S'
			TMP->(DbSkip())
			loop
		endif

		u_GJF103GE(TMP->DOC,TMP->SERIE,TMP->CLIENTE,TMP->LOJA) 

		TMP->(DbSkip())
	enddo

	GeraTMP()

	TMP->(DbGoTop())

Return

//Aglutinação para gerar o arquivo TXT 
//Feito para que esta função fosse usada em 
//outros fontes
User Function GJF103GE(_Doc,_Serie,_Cliente,_Loja)    

	Private _cDataArq := ""  
	Private _cNrDoc := ''
	Private _nSeqArq := 0
	Private _aTexto := {}
	Private _cChavDoc := ''
	_area := getarea()   

	_lOk := .t.  // flavio acrescentou

	if _lOk
		MsgRun("Aguarde... Realizando a Query para EDI...",,{||  SFSeleNF(_Doc,_Serie,_Cliente,_Loja) })
	endif

	if _lOk
		MsgRun("Aguarde... Gerando o Arquivo para EDI..." ,,{||  SFGeraArquivo() })
	endif  

	restarea(_area)

Return

Static Function SFSeleNF(_Doc,_Serie,_Cliente,_Loja)		
	_cQuery := ""
	_cQuery += "select D2_FILIAL, D2_CLIENTE, D2_LOJA, A1_CGC, D2_EMISSAO,D2_DOC,D2_SERIE,D2_COD,D2_QUANT,D2_VALBRUT,D2_TOTAL,D2_PRCVEN," 
	_cQuery += "D2_ALIQSOL,D2_ICMSRET,F4_BASEICM,A4_NOME,C5_PCOMPRA,C5_DTENT,C5_HRENT,D2_UM,D2_CF,D2_PICM,D2_IPI,D2_VALIPI,D2_VALICM,F2_VALICM," 
	_cQuery += "F2_BASEICM,F2_BRICMS,F2_ICMSRET,F2_VALIPI,F2_BASEIPI,F2_VALFAT, A1_LOJACOB, C5_TIPCOD, D2_PEDIDO, D2_ITEMPV"
	_cQuery += " FROM SF2010 SF2 (nolock) "   //(nolock)
	_cQuery += "INNER JOIN SD2010 SD2 (nolock) ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE "
	_cQuery += "INNER JOIN SC5010 SC5 (nolock) ON C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO "
	_cQuery += "LEFT JOIN SA4010 SA4 (nolock) ON A4_COD = F2_TRANSP AND SA4.D_E_L_E_T_ = '' "
	_cQuery += "INNER JOIN SA1010 SA1 (nolock) ON A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA "
	_cQuery += "INNER JOIN SF4010 SF4 (nolock) ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES "
	_cQuery += "INNER JOIN SB1010 SB1 (nolock) ON B1_FILIAL = D2_FILIAL AND B1_COD = D2_COD "
	_cQuery += "where "
	_cQuery += "D2_DOC ='" + _Doc + "' and D2_SERIE = '" + _Serie + "' and "
	_cQuery += "D2_CLIENTE = '" + _Cliente + "' and D2_LOJA = '"+ _Loja +"' and "
	_cQuery += "D2_FILIAL = '" + cFilAnt + "' and "
	_cQuery += "D2_TIPO = 'N' and "
	_cQuery += "F4_DUPLIC = 'S' and "
	_cQuery += "SD2.D_E_L_E_T_ = '' and "
	_cQuery += "SF2.D_E_L_E_T_ = '' and "
	_cQuery += "SA1.D_E_L_E_T_ = '' and "
	_cQuery += "SC5.D_E_L_E_T_ = '' and "
	_cQuery += "SF4.D_E_L_E_T_ = '' and "
	_cQuery += "SA4.D_E_L_E_T_ = '' and "
	_cQuery += "SB1.D_E_L_E_T_ = '' "
	_cQuery += "order by D2_FILIAL, D2_CLIENTE, D2_LOJA, D2_DOC, D2_SERIE, D2_PEDIDO, D2_ITEMPV "

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if select("PER") <> 0
		DBSelectArea("PER")
		DBCloseArea()
	endif

	TcQuery _cQuery New Alias "PER" 

	//alert('Gerou a query')

	DBSelectArea("PER")
	PER->(DBGoTop())    

	_DocAtual   := '' 
	_nSeq       := 0  
	_VlrTotBrut := 0
	_TotBrut    := 0
	_aTexto     := {} 
	_lMens      := .f.
	_GLNPrim    := alltrim(GetMv('SI_GLNPRIM'))              

	While ! PER->(Eof())

		DbSelectArea('SM0')
		SM0->(DbSetORder(1))

		//	if PER->D2_FILIAL = '00'

		_CNPJ  := SM0->M0_CGC
		_Inscr := SM0->M0_INSC

		//elseif PER->D2_FILIAL = '01'
		//	_CNPJ       := '88728027000227'
		//	_Inscr      := '1000086809'
		//endif

		//Montagem dos cabeçalhos de cada NF que será enviada no arquivo

		DbSelectArea('SB1')
		_cNrDoc     := PER->(D2_DOC+D2_SERIE)
		_cChavDoc   := PER->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)                     //Chave para procurar o Doc
		_cDocEDI    := GetAdvFVal('SF2','F2_DOCEDI',_cChavDoc,1)                                //Busca o nome do arquivo se já existe
		_CNPJLocCob := GetAdvFVal('SA1','A1_CGC',FWxfilial('SA1')+PER->(D2_CLIENTE+A1_LOJACOB),1) //CNPJ do local de cobrança
		_cCodBar    := GetAdvFVal('SB1','B1_CODBAR',FWxfilial('SB1')+PER->D2_COD,1)
		_nTipCod    := GetAdvFVal('SC6','C6_TIPCOD',FWxfilial('SC6')+PER->(D2_PEDIDO+D2_ITEMPV),1)

		if !_lMens
			if !empty(_cDocEDI)
				if !msgbox('Arquivo de nome ' + _cDocEDI + ' já gerado deste documento. Continuar?',;
				'ARQUIVO DE NF PARA EDI JÁ GERADO!','YESNO')
					_lOk   := .f.
					_lMens := .t.
					return
				else
					msgbox('Será gerado um arquivo com novo sequencial...','CONFIRMAÇÃO!','INFO')

				endif
			endif

			if empty(_cCodBar)
				msgbox('Necessário gerar codigo EAN 13 para o produto ' + PER->D2_COD + ' !','DADOS INSUFICIENTES!','STOP')
				_lOk := .f.
				return
			endif

			if empty(_CNPJLocCob)
				msgbox('Necessário apontar loja de cobrança no cadastro de clientes!','DADOS INSUFICIENTES!','STOP')
				_lOk := .f.
				return
			endif

			_lMens := .t.

		endif


		_cDataArq   := strtran(dtoc(stod(PER->D2_EMISSAO)),'/','')                             //Data para nomear o arquivo
		_cDtHrEmis  := substr(padr(PER->D2_EMISSAO + strtran(time(),':',''),12,''),1,12)       //Data e hora da emissão da NF
		_cDtHrEntr  := padr(PER->C5_DTENT + strtran(PER->C5_HRENT,':',''),12,'')               //Data e hora da entrada da carga
		_cTipCond   := padr('1',3,'')                                                          //Tipo de condição de pagto
		_cRefData   := padr('5',3,'')                                                          //Referencia de data para pgto
		_cRefTempo  := padr('1',3,'')                                                          //Referencia de tempo para pgto
		_cTipPer    := padr('CD',3,'')                                                         //Tipo de período
		_cTipPCP    := padr('12E',3,'')                                                        //Tipo de % da cond. de pagto
		_TipValCP   := '262'                                                                   //Tipo de valor da cond. pgto

		//        |Tipo (2) | |   Função (3)    | |Tipo (3)| |   Nr NF(9) | |     Serie (3)          | | Subserie (2)|
		_cTexto := '01'      +  padr('9',3,'')   +  '325'   +  PER->D2_DOC + padr(PER->D2_SERIE,3,'') +     space(2)

		//        |Data de emissão e Hora (12)| |Data de saída e hora (12)|
		_cTexto +=        _cDtHrEmis           +        _cDtHrEmis

		//        |Data hr entrega (12)| |          CFOP  (5)   | | Nr. Ped. Comprador (20)  |
		_cTexto +=     _cDtHrEntr       +  padr(PER->D2_CF,5,'') +  padr(PER->C5_PCOMPRA,20,'') //iif(PER->D2_CLIENTE = '007980',replicate('0',20),padr(PER->C5_PCOMPRA,20,''))

		//        | Ped. Sist. Emis.| |Num. Contrato | | Lista preços   | |       EAN Comprador      |
		_cTexto +=    space(20)      +   space(15)    +   space(15)      +      replicate('0',13)

		//        | EAN Cobr. Fatura (13)| |EAN Loc. Entrega (13)| | EAN Fornecedor (13)| | EAN Emissor da nf (13)   |
		_cTexto +=   replicate('0',13)    +    replicate('0',13)  +     _GLNPrim         +       _GLNPrim

		//        |  CNPJ Comprador (14)  | |CNPJ Loc.cobr. (lj. 01)| |  CNPJ Loc. Entr (14)  | |CNPJ Fornecedor (14)|
		_cTexto += padr(PER->A1_CGC,14,'') + padr(_CNPJLocCob,14,'') + padr(PER->A1_CGC,14,'') +  padr(_CNPJ,14,'')

		//         |CNPJ Emissor (14) | |    Estado (2)  | | Insc.Est.Emis(20) | |Tipo Cod.Transp. (3)| |   Codigo Transp. (14)     |
		_cTexto += padr(_CNPJ,14,'')  + padr('RS',2,'')  +  padr(_Inscr,20,'') +    padr('251',3,'')  + padr('8708477000138',14,'')

		//        |               Nome Transp. (30)             | |Cond. entr. (3) |
		_cTexto +=  padr('TRANSP ARRIECHE DA SILVA LTDA',30,'') +       'CIF'


		if _DocAtual <> PER->D2_FILIAL + PER->D2_CLIENTE + PER->D2_LOJA + PER->D2_DOC + PER->D2_SERIE
			Aadd(_aTexto,_cTexto)
			_nSeqItem := 0
			_DocAtual := PER->D2_FILIAL + PER->D2_CLIENTE + PER->D2_LOJA + PER->D2_DOC + PER->D2_SERIE

			//Montagem dos registros de pagamentos
			_nNumPar  := 0
			_nValTot  := 0
			DbSelectArea('SE1')
			SE1->(DbSetOrder(29))
			if SE1->(Msseek(FWxfilial('SE1')+PER->D2_DOC))
				While SE1->(!eof()) .and. SE1->E1_FILIAL  =  FWxfilial('SE1');
				.and. SE1->E1_PREFIXO =  PER->D2_FILIAL;
				.and. SE1->E1_NUM     =  PER->D2_DOC

					if SE1->E1_TIPO <> 'NF'
						SE1->(DbSkip())
						loop
					endif

					_nNumPar++                 //Para contar o numero de parcelas
					_nValTot += SE1->E1_VALOR  //Valor total a ser pago

					SE1->(DbSkip())
				enddo

				SE1->(DbGoTop())
			endif

			_PercCP  := ''
			_cNumPer := ''

			if SE1->(Msseek(FWxfilial('SE1')+PER->D2_DOC))
				While SE1->(!eof()) .and. SE1->E1_FILIAL  =  FWxfilial('SE1');
				.and. SE1->E1_PREFIXO =  PER->D2_FILIAL;
				.and. SE1->E1_NUM     =  PER->D2_DOC

					if SE1->E1_TIPO <> 'NF'
						SE1->(DbSkip())
						loop
					endif

					_cValor  := strzero(SE1->E1_VALOR * 100,15)                //Valor do título
					_PercCP  := strzero((SE1->E1_VALOR / _nValTot * 10000),5)  //Percentual da condição de pagamento
					_cNumPer := strzero(SE1->E1_VENCTO - SE1->E1_EMISSAO,3)    //Numero de períodos

					//   |Tipo reg (2)| |Cond. pgto (3)| |Ref. data (3)| |Ref. Tempo(3)| |Tip.Per.(3)| |Num.Per.(3)|
					_cTexto :=     '02'     +   _cTipCond    +   _cRefData   +   _cRefTempo  +  _cTipPer   +  _cNumPer

					//       |    Vencimento (8)        | |Tip. % CP (3)| |% CP(5)| |Tip.Vlr.(3)| |    Valor(15)  |
					_cTexto += padr(dtos(SE1->E1_VENCTO),8,'') +   _cTipPCP    + _PercCP +  _TipValCP  +     _cValor

					Aadd(_aTexto,_cTexto)

					SE1->(DbSkip())
				enddo
			endif

			//Montagem dos registros dos descontos e encargos da NF (registro desnecessário)

		endif

		//Montagem dos registros dos itens da NF

		_cCodProd := ''

		ZA1->(DbSetOrder(2))
		if ZA1->(MsSeek(FWxfilial('ZA1')+PER->(alltrim(D2_CLIENTE)+alltrim(D2_LOJA)+alltrim(D2_COD))))
			if _nTipCod = 1
				_cCodProd := ZA1->ZA1_CODCLI
			elseif _nTipCod = 2
				_cCodProd := ZA1->ZA1_CODBAR
			endif
		else
			ZA1->(DbSetOrder(1))
			if ZA1->(MsSeek(FWxfilial('ZA1')+PER->(alltrim(D2_CLIENTE)+alltrim(D2_COD))))
				if _nTipCod = 1
					_cCodProd := ZA1->ZA1_CODCLI
				elseif _nTipCod = 2
					_cCodProd := ZA1->ZA1_CODBAR
				endif
			else
				alert('Correlação do produto ' + alltrim(PER->D2_COD) + ' não localizada!')
				_lOk := .f.
				Return
			endif
		endif

		_nSeq++                                           //Sequencial da linha dos itens
		_cQuant      := strzero(PER->D2_QUANT * 100,15)   //Quantidade do produto
		_cVlrBruto   := strzero(PER->D2_VALBRUT * 100,15) //Valor bruto de cada item
		_cValLiq     := strzero(PER->D2_TOTAL * 100,15)   //Valor liquido de cada item
		_cPrcBruto   := strzero(PER->D2_PRCVEN * 100,15)  //Valor unitario bruto
		_cPrcLiq     := strzero(PER->D2_PRCVEN * 100,15)  //Valor unitario liquido
		_cAliqIPI    := strzero(PER->D2_IPI * 100,5)      //Aliquota IPI
		_cValIPI     := strzero(PER->D2_VALIPI * 100,15)  //Valor IPI
		_cAliqICM    := strzero(PER->D2_PICM * 100,5)     //Aliquota ICMS
		_cValICM     := strzero(PER->D2_VALICM * 100,15)  //Valor ICMS
		_cAliqICMST  := iif(PER->D2_ICMSRET = 0.00,replicate('0',5),strzero(PER->D2_ALIQSOL * 100,5))  //Aliquota ICMS com substituição Tributaria
		_VlrICMSST   := strzero(PER->D2_ICMSRET * 100,15) //Valor ICMS Substituição Tributária
		_AliqRdBase  := strzero(PER->F4_BASEICM * 100,5)  //Aliquota redução de base de ICMS
		_VlrRdBase   := strzero((PER->D2_VALBRUT - (PER->D2_VALBRUT * (PER->F4_BASEICM/100))) * 100,15)  //Valor redução base ICMS

		//    |Tipo(2)| |  Seq. (4)      | | Nr.Item Ped.(5)| |Tip.Cod.Prod(3)| |   Cod. Prod.(14)    |
		_cTexto :=   '04'  + strzero(_nSeq,4) + replicate('0',5) + padr('EN',3,'') + padr(_cCodProd,14,'')

		//    |refer. prod. (20)| |Un.Med.(3)| | Nr.Und.Cons.(5)| |Quantidade Prod.(15)| |Tipo Emb.(3)|
		_cTexto += replicate('0',20) +    'KGM'   + replicate('0',5) +      _cQuant         +   space(3)

		//    |Vlr.Bruto (15)| | Vlr.Liq. (15)| | Prc.Bruto Un (15)| |Prc.Liq. Un (15)| |Nr. Lote(20)|
		_cTexto +=  _cVlrBruto    +    _cValLiq    +     _cPrcBruto     +    _cPrcLiq      +   space(20)

		//    |Nr.Ped.Comp.(20)| |Peso Bruto item (15)| |Vol.Bruto item (15)| | Cod.Class.Fiscal(14) |
		_cTexto +=     space(20)    +  replicate('0',15)   +  replicate('0',15)  +      space(14)

		//   |Cod.Sit.Trib(5) | |       CFOP (5)      | |  %Desc.Fin.(5)  | |     Vlr.Desc.Fin.(15)  |
		_cTexto +=    space(5)     + padr(PER->D2_CF,5,'') +  replicate('0',5) +      replicate('0',15)

		//    | % Desc.Com.(5) | | Vlr.Desc.Com. (15) | |  %Desc.Prom.(5)  | |   Vlr.Desc.Prom.(15)  |
		_cTexto += replicate('0',5) +  replicate('0',15)   +  replicate('0',5)  +     replicate('0',15)

		//    |  % Enc.Fin.(5)    | | Vlr.Enc.Fin. (15) | |  Aliq. IPI (5)  | |   Valor IPI.(15)     |
		_cTexto += replicate('0',5) +  replicate('0',15)  +     _cAliqIPI     +          _cValIPI

		//    |% Aliq.ICMS(5)   | |Valor ICMS (15)| |Aliq.ICMS Subst.Trib(5)| | Vlr.ICMS Subst. Trib(15)|
		_cTexto +=   _cAliqICM   +    _cValICM     +      _cAliqICMST        +      _VlrICMSST

		//    |%Aliq.Red.Base(5)| |Vlr.Red.Base(15)| |%Desc.Repasse ICMS(5)| |Vlr.Desc.Rep. ICMS (15)|
		_cTexto +=  _AliqRdBase   +   _VlrRdBase     +   replicate('0',5)    +     replicate('0',15)

		Aadd(_aTexto,_cTexto)

		_TotBrut     += PER->D2_VALBRUT  //Soma dos valores brutos das linhas dos itens
		_nValBasICMS := PER->F2_BASEICM	 //Valor base ICMS
		_nValTotICMS := PER->F2_VALICM   //Valor total ICMS
		_nValBaseST  := PER->F2_BRICMS   //Valor base substituição tributaria
		_nValTotST   := PER->F2_ICMSRET  //Valor total do ICMS com subst. tributaria
		_nValBaseIPI := PER->F2_BASEIPI  //Valor base IPI
		_nValTotIPI  := PER->F2_VALIPI   //Valor IPI
		_nValTotal   := PER->F2_VALFAT   //Valor total da NF

		PER->(DbSkip())

		//Montagem dos registros do sumário

		_cValTotBrut  := strzero(_TotBrut * 100,15)      //Valor total das linhas da nota
		_cValBasICMS  := strzero(_nValBasICMS * 100,15)  //Valor base ICMS
		_cValTotICMS  := strzero(_nValTotICMS * 100,15)  //Valor Total do ICMS
		_cValBaseST   := strzero(_nValBaseST * 100,15)   //Valor base substituição tributaria
		_cValTotST    := strzero(_nValTotST * 100,15)    //Valor total do ICMS com subst. Tributaria
		_cValBaseRed  := strzero(_nValBasICMS * 100,15)  //Valor base do ICMS com retençao (igual ao valor base ICMS)
		_cValTotRed   := strzero(_nValTotICMS * 100,15)  //Valor total do ICMS com retenção (igual ao valor total do ICMS)
		_cValBaseIPI  := strzero(_nValBaseIPI * 100,15)  //Valor base do IPI
		_cValTotIPI   := strzero(_nValTotIPI * 100,15)   //Valor total IPI
		_cValFat      := strzero(_nValtotal *100,15)     //Valor Total da NF

		//        |Tipo(2)| |  Nr. Linhas (4)| | Qtd. Embal. (15)| |Peso B.Total(15 )| |Peso L.Total(15)|
		_cTexto :=   '09'  + replicate('0',4) + replicate('0',15) + replicate('0',15) + replicate('0',15)

		//        |  Cubagem (15)   | |Vlr.Total Linhas(15)| |Vlr. Total Desc.(15)| |Vlr. Total Enc.(15)|
		_cTexto += replicate('0',15) +   _cValTotBrut       +   replicate('0',15)  +  replicate('0',15)

		//        |Vlr.Tot.Abat(15)| | Vlr.Total Frete(15)| |Vlr. Total Seguro(15)| |Vlr.Desp.Acess.(15)|
		_cTexto += replicate('0',15)+   replicate('0',15)  +   replicate('0',15)   + replicate('0',15)

		//        |Vlr.Bas ICMS(15)| |Vlr.Total ICMS(15)| |Vl.Base Subs.Trib(15)| |Vl.Tot Subs.Trib.(15)|
		_cTexto +=  _cValBasICMS    +   _cValTotICMS     +     _cValBaseST       +      _cValTotST

		//        |Vl.Bas.Red(15)| |Vlr.Total Red.(15)| |Vlr.Base Calc.IPI(15)| |Vlr.Tot IPI(15)| |  Valor total NF (15) |
		_cTexto +=  _cValBaseRed  +  _cValTotRed       +    _cValBaseIPI       +   _cValTotIPI   +       _cValFat


		if _DocAtual <> PER->D2_FILIAL + PER->D2_CLIENTE + PER->D2_LOJA + PER->D2_DOC + PER->D2_SERIE
			_nSeq := 0
			Aadd(_aTexto,_cTexto)
			_TotBrut := 0
		endif
	End

Return

//Função destinada a gerar o txt 
//com base no vetor criado
Static Function SFGeraArquivo()
	Local _x
	Local nTamLin, cLin, cCpo 
	Local _nSeqArq  := GetMv('SI_SQAREDI')
	Local _cNomeArq  :=_cDataArq +  _cNrDoc  + strzero(_nSeqArq,10) + '.txt'
	Private cString  := ""
	//Unid|Diret|tipo | |   Data  | |Doc+Serie| |  Sequencial
	Private cArqTxt := 'I:\Saida\NF'  + _cNomeArq
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
		cCpo  := _aTexto[_X]+cEOL
		fWrite(nHdl,cCpo,Len(cCpo))
	Next 

	fClose(nHdl)

	SF2->(DbSetOrder(1))
	if SF2->(MsSeek(_cChavDoc))   
		_cDoc    := SF2->F2_DOC
		_cNomcli := SF2->F2_NOMCLI
		_cCliLoj := SF2->(F2_CLIENTE+F2_LOJA)
		reclock('SF2',.f.)
		SF2->F2_DOCEDI := 'NF'+_cNomeArq
		msunlock()
	endif
	SF2->(DbCloseArea())
	//Atualiza parametro de sequencial de arquivo
	_nSeqArq++

	PutMV('SI_SQAREDI',_nSeqArq)

	_nExec := WinExec('C:\smartclient\EDI.bat')

	if _nExec = 0                                                                                                                
		msgbox('Rotina de envio de arquivo EDI está sendo executada. Verifique tela de confirmação!','ENVIO ARQUIVO EDI!','INFO')
	else
		EDIWfw(_cDoc ,_cNomcli,_cCliLoj)
		msgbox('Falha na execução do aplicativo de emissão dos arquivos de EDI! Refaça a operação manualmente.','ENVIO ARQUIVO EDI!','STOP')
	endif

Return


Static Function EDIWfw(_cNota,_cNomCli,_cClieFor)
	Local i
	_cMens := 'NF nr. ' + _cNota + ' do Cliente ' + _cNomCli + '('+_cClieFor+') '
	_cMens +=  'foi gerado arquivo de NF por EDI!' + CHR(13)+CHR(10)
	_cTit  := 'Workflow Frigorífico Silva: Aviso de falha no envio em EDI'
	//_cDest := 'faturamento@frigorificosilva.com.br,faturamento2@frigorificosilva.com.br'     Alterado para os novos integrantes do Faturamento - feito por Flávio dia 28/08/2017
	_cDest := 'andrea.almeida@frigorificosilva.com.br,julio.labrea@frigorificosilva.com.br,fabio.bastos@frigorificosilva.com.br'

	_aEmail := u_GJF54(_cMens,_cTit,_cDest)

	for i := 1 to len(_aEmail)
		if !_aEmail[i]
			alert('ERRO WORKFLOW ('+ str(i) +')')
		endif
	next

return
