#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI131 ºAutor  ³Daniel de Souza        º Data ³  25/10/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de Arquivos EDI NF - Carrefour                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

User Function dti131()

	Private area      := getarea()
	Private cIPerg    := ""
	Private _aTexto   := {}
	Private _lOK      := .t.
	Private _TotLiq   := 0

	cPerg := "DTI131"

	if !Pergunte(cPerg,.T.)
		return
	endif	 

	if empty(mv_par02) .or. empty(mv_par03)
		alert('Parametros essenciais em branco!')
		_lOk := .f.
	endif

	/* 
	if !file('I:\Saida')
	alert('Mapeamento de rede "I:\Saida\" não encontrado!')
	_lOk := .f.
	endif
	*/


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

		aRotina  := { {"Gerar","u_dti131Pr"  ,0,4}}

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
	_cQueryI += "(F2_DOC between '" + mv_par03 + "' and '" + mv_par04 + "') and "
	_cQueryI += " F2_CLIENTE = '001110' and "
	_cQueryI += "F2_LOJA IN('01','06','26','27') and " 
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

	aStru := {}
	_aArqTrb := {}

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

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
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
User Function DTI131Pr()

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

		u_MLR09GE(TMP->DOC,TMP->SERIE,TMP->CLIENTE,TMP->LOJA) 

		TMP->(DbSkip())
	enddo

	GeraTMP()

	TMP->(DbGoTop())

Return

//Aglutinação para gerar o arquivo TXT 
//Feito para que esta função fosse usada em 
//outros fontes
User Function DTI131GE(_Doc,_Serie,_Cliente,_Loja)    

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
	_cQuery += "select D2_FILIAL, D2_CLIENTE, D2_LOJA,D2_EMISSAO,D2_DOC,D2_SERIE,D2_COD,D2_QUANT,D2_VALBRUT,D2_TOTAL,D2_PRCVEN,D2_BASEICM," 
	_cQuery += "D2_ALIQSOL,D2_ICMSRET,F4_BASEICM,F4_SITTRIB,F4_CSTPIS, F4_CSTCOF,F4_CTIPI,"
	_cQuery += "A4_NOME,C5_PCOMPRA,C5_DTENT,C5_HRENT,D2_UM,D2_CF,D2_PICM,D2_IPI,D2_VALIPI,D2_VALICM,F2_VALICM," 
	_cQuery += "F2_BASEICM,F2_BRICMS,F2_ICMSRET,F2_VALIPI,F2_BASEIPI,F2_VALFAT, C5_TIPCOD, D2_PEDIDO, D2_ITEMPV"
	_cQuery += " FROM SF2010 (nolock)"   //(nolock)
	_cQuery += "INNER JOIN SD2010 (nolock) ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE  "
	_cQuery += "INNER JOIN SC5010 (nolock) ON C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO "
	_cQuery += "LEFT  JOIN SA4010 (nolock) ON A4_COD = F2_TRANSP  "
	_cQuery += "INNER JOIN SF4010 (nolock) ON F4_FILIAL = D2_FILIAL AND F4_CODIGO = D2_TES "
	_cQuery += "INNER JOIN SB1010 (nolock) ON B1_FILIAL = D2_FILIAL AND B1_COD = D2_COD "
	_cQuery += "where "
	_cQuery += "D2_DOC ='" + _Doc + "' and D2_SERIE = '" + _Serie + "' and "
	_cQuery += "D2_CLIENTE = '001110' and D2_LOJA IN('01','06','26','27') and " 
	_cQuery += "D2_FILIAL = '" + cFilAnt + "' and "
	_cQuery += "D2_TIPO = 'N' and "
	_cQuery += "F4_DUPLIC = 'S' and  "
	_cQuery += RetSQLName("SD2") + ".D_E_L_E_T_ = '' and "
	_cQuery += RetSQLName("SF2") + ".D_E_L_E_T_ = '' and "
	_cQuery += RetSQLName("SC5") + ".D_E_L_E_T_ = '' and "
	_cQuery += RetSQLName("SF4") + ".D_E_L_E_T_ = '' and "
	_cQuery += RetSQLName("SA4") + ".D_E_L_E_T_ = '' and "
	_cQuery += RetSQLName("SB1") + ".D_E_L_E_T_ = '' "          
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



	DbSelectArea('SM0')
	SM0->(DbSetORder(1))
	_cChavDoc   := PER->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)                     //Chave para procurar o Doc
	_cDocEDI    := fBuscaCPO('SF2',1,_cChavDoc,'F2_DOCEDI')                                //Busca o nome do arquivo se já existe
	_cCodBar    := fBuscaCPO('SB1',1,xfilial('SB1')+PER->D2_COD,'B1_CODBAR')

	_CNPJ  := SM0->M0_CGC
	_Inscr := SM0->M0_INSC


	//Montagem dos cabeçalhos de cada NF que será enviada no arquivo


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

		_lMens := .t.

	endif

	DbSelectArea('SB1')

	_cDataArq   := strtran(dtoc(stod(PER->D2_EMISSAO)),'/','')                             //Data para nomear o arquivo

	//Variáveis para o primeiro registro: HEADER-1
	_cNrDoc     := PER->(D2_DOC + padl(alltrim(D2_SERIE),3,'0'))                                    //Numero NF e série 
	_cDtHrEmis  := substr(padr(PER->D2_EMISSAO + strtran(time(),':',''),12,''),1,12)       //Data e hora da emissão da NF
	_cCFOP      := padr(PER->D2_CF,4,'0')                                            //CFOP - Codigo Fiscal de Operação
	_cNumPed    := PER->C5_PCOMPRA                                                         //Numero do pedido de compra 
	//Fim das variáveis para o registro HEADER-1


	_cCodBar    := fBuscaCPO('SB1',1,xfilial('SB1')+PER->D2_COD,'B1_CODBAR')
	_nTipCod    := fBuscaCPO('SC6',1,xfilial('SC6')+PER->(D2_PEDIDO+D2_ITEMPV),'C6_TIPCOD')
	//_cEanEntrega := iif(PER->D2_LOJA = '01','7895000009039',iif(PER->D2_LOJA = '06','7895000004119',iif(PER->D2_LOJA = '26','7895000009206',iif(PER->D2_LOJA = '27','7895000019427','47508411259052')))) //Alteração solicitada pela Gabriela / Rodrigo 04/10/2018

	///////////////////////////////////
	// Montagem do Registro HEADER-1
	//        |Tipo (2) | |   Função (3)    | |		  Nr NF(9) + Serie (3)          
	_cTexto := '01'      +      '9'          +            _cNrDoc

	//        |Data de emissão e Hora (12)| |Data de saída e hora (12)| |DATA-HORA-PREVISAO-ENTREGA(12)|
	_cTexto +=        _cDtHrEmis           +       replicate('0',12)   + 		 replicate('0',12)

	//        |         CFOP  (4)        | |       Numero Pedido 1       | | Numero Pedido 2      | |    Numero Pedido 3| 
	_cTexto +=          _cCFOP            +   alltrim(PER->C5_PCOMPRA)    +     replicate('0',15)  +    replicate('0',15)

	//        |    EAN Comprador   | |  Cod EAN Emissor Fatura  | |   Num CGC Emissor Fatura   | |  N. Inscr. Fatura       | | Cod.Uf.Inscr. Fatura
	_cTexto +=    '7895000000001'   +     '1004390800003'        +     padl(_CNPJ,15,'0')       +     padr(_Inscr,20,'')    +        'RS'

	//        | EAN Loc. Entrega (13)| |EAN local cobranca (13)| | Cod Banco (4) | | Cod Agencia Bancaria (5) |
	_cTexto +=     _cEanEntrega       +    '7895000088232'      +    space(4)     +       space(5)

	//        |  Num Conta Corrente(11)  | |  Filler(71)
	_cTexto +=          space(11)         +   Space(71)



	if _DocAtual <> PER->D2_FILIAL +  PER->D2_DOC + PER->D2_SERIE
		Aadd(_aTexto,_cTexto)
		_nSeqItem := 0

		_DocAtual := PER->D2_FILIAL + PER->D2_CLIENTE + PER->D2_LOJA + PER->D2_DOC + PER->D2_SERIE

		///////////////////////////////////
		//Montagem do registro de pagamento				

		//Variáveis para registro de condições de pagamento
		_cTipCond   := padr('3',3,'')                                                          //Tipo de condição de pagto  
		_CondPG     := fBuscaCPO('SA1',1,xfilial('SA1')+PER->(D2_CLIENTE+D2_LOJA),'A1_COND')
		_cQtdDias   := padl(alltrim(fBuscaCPO('SE4',1,xfilial('SE4')+_CondPG,'E4_COND')),3,'0')
		_cRefPrazo  := '1'                                                                     //Referencia de data para pgto
		_cRefTempo  := padr('1',3,'')                                                          //Referencia de tempo para pgto
		_cDescPag   := 'DD'                                                                    //Descrição de Cond. Pagamento
		//Fim das variáveis para registro das condições de pagamento


		DbSelectArea('SE1')
		SE1->(DbSetOrder(29))
		if SE1->(Dbseek(xfilial('SE1')+PER->D2_DOC))

			_cDtVenc := dtos(SE1->E1_VENCTO)    //Numero de períodos

			//   |Tipo reg (2)   | | Num. NF  +  Serie     | |Tipo Cond. pgto (3)| |Ref. data (1)| |Desc. CP(2) | |Quant.Dias.(3)|
			_cTexto :=     '02'   +         _cNrDoc         +   _cTipCond         +  _cRefPrazo   +   _cDescPag  +  _cQtdDias     

			//       |    Vencimento (8)        | |% Desc.Fin (6)| |%Pag.Fat.(5)| | Filler (238)  |
			_cTexto += dtos(SE1->E1_VENCTO)      +   '000000'     +   '10000'    +  space(238)

			Aadd(_aTexto,_cTexto)		
		endif
		//Fim do bloco para incluir registro da condição de pagamento

		//Inicio do bloco para incluir registro HEADER-2
		//     |Tipo reg (2)   | | Num. NF  +  Serie     | | Tipo Veic.(4)| |Cod EAN Ou CGC Transp (15)| |Tipo Ident. Transp(3) | |Nome Transp.(25)|
		_cTexto  := '03'        +         _cNrDoc         +   space(4)  +       replicate('0',15)       +         space(3)       +   space(25)

		//     |Ident. Placa Veic.(12)   | | Tipo Frente  | | Val Encargo Fin.(13) | |Taxa Aliq. ICMS Frente(5)| |Taxa Aliq. ICMS Seg.(5) | |Filler (181)|	
		_cTexto  +=    space(12)      +    'CIF'       +         replicate('0',13)  +     replicate('0',5)      +    replicate('0',5)      +  space(181)

		Aadd(_aTexto,_cTexto)		
		//fim do bloco para incluir registro HEADER-2     

	endif


	////////////////////////////////////////////////////
	//Montagem dos registros dos itens da NF
	While ! PER->(Eof())	
		_cCodBar    := fBuscaCPO('SB1',1,xfilial('SB1')+PER->D2_COD,'B1_CODBAR')
		_cCodProd := ''

		if empty(_cCodBar)
			msgbox('Necessário gerar codigo EAN 13 para o produto ' + PER->D2_COD + ' !','DADOS INSUFICIENTES!','STOP')
			_lOk := .f.
			return
		endif	


		ZA1->(DbSetOrder(2))
		if ZA1->(DbSeek(xfilial('ZA1')+PER->(alltrim(D2_CLIENTE)+alltrim(D2_LOJA)+alltrim(D2_COD))))
			if _nTipCod = 1
				_cCodProd := ZA1->ZA1_CODCLI
			elseif _nTipCod = 2
				_cCodProd := ZA1->ZA1_CODBAR
			endif
		else
			ZA1->(DbSetOrder(1))
			if ZA1->(DbSeek(xfilial('ZA1')+PER->(alltrim(D2_CLIENTE)+alltrim(D2_COD))))
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

		_TotBrut     += PER->D2_VALBRUT  //Soma dos valores brutos das linhas dos itens 
		_TotLiq      += PER->D2_TOTAL    //Soma dos valores Liquidos                  

		_nSeq++                                           //Sequencial da linha dos itens
		_cQuant  	    := strzero(PER->D2_QUANT * 1000,10)   //Quantidade do produto
		_cVlrBruto 	    := strzero(PER->D2_VALBRUT * 100,15) //Valor bruto de cada item
		_cValLiq  	    := strzero(PER->D2_TOTAL * 100,15)   //Valor liquido de cada item
		_cPrcBruto	    := strzero(PER->D2_PRCVEN * 10000,13)  //Valor unitario bruto
		_cPrcLiq  	    := strzero(PER->D2_PRCVEN * 10000,13)  //Valor unitario liquido
		_cAliqIPI 	    := strzero(PER->D2_IPI * 100,5)      //Aliquota IPI
		_cValIPI  	    := strzero(PER->D2_VALIPI * 100,15)  //Valor IPI
		_cAliqICM 	    := strzero(PER->D2_PICM * 100,5)     //Aliquota ICMS
		_cValICM   	  	 := strzero(PER->D2_VALICM * 100,15)  //Valor ICMS
		_cAliqICMST		 := iif(PER->D2_ICMSRET = 0.00,replicate('0',5),strzero(PER->D2_ALIQSOL * 100,5))  //Aliquota ICMS com substituição Tributaria
		_ValBaseCalcIcm := strzero(PER->D2_BASEICM * 100,15) //Valor de Base de Calculo de ICMS
		_VlrICMSST   	 := strzero(PER->D2_ICMSRET * 100,15) //Valor ICMS Substituição Tributária
		_AliqRdBase  	 := strzero(PER->F4_BASEICM * 100,15)  //Aliquota redução de base de ICMS
		_VlrRdBase   	 := strzero((PER->D2_VALBRUT - (PER->D2_VALBRUT * (PER->F4_BASEICM/100))) * 100,15)  //Valor redução base ICMS
		_cValTotBrut 	 := strzero(_TotBrut * 100,15)      //Valor total bruto das linhas da nota
		_cValTotLiq  	 := strzero(_TotLiq  * 100,15)      //Valor total liquido das linhas da notas
		_cCodSitTrib 	 := PER->F4_SITTRIB                 //Cod. Situação Tributaria
		_cCodNcm        := fBuscaCPO('SB1',1,xfilial('SB1')+PER->D2_COD,'B1_POSIPI') //Codigo NCM
		_cCodSitPis     := substr(PER->F4_CSTPIS,1,2)						//Codigo Situação Tributaria PIS
		_cCodSitCof     := substr(PER->F4_CSTCOF,1,2)						//Codigo Situação Tributaria Cofins 
		_cCodSitIpi	    := substr(PER->F4_CTIPI,1,2)							//Codigo Situação Tributaria IPI
		_cCodSitIcm     := substr(PER->F4_SITTRIB,1,2)						//Codigo Situação Tributaria ICMS
		_cCodProdCli    := fBuscaCPO('ZA1',1,xfilial('ZA1')+PER->(alltrim(D2_CLIENTE) + alltrim(D2_COD)),'ZA1_CODCLI')


		//    |Tipo(2)    | |  Nota + Serie | |            EAN Produto            | |   Volume Total   | |   Qtde. Faturada   |
		_cTexto :=   '04'  +     _cNrDoc     +     padl(alltrim(_cCodProdCli),14,'0')   +  replicate('0',10) +      _cQuant

		//     | |    Un.Med.(3)    | |  Qtde Entregue    | |Un. Medida Entregue   | |Peso Total Item Entregue|
		_cTexto += padr('KG',3,'')   +   replicate('0',10)  +      space(3)         +      replicate('0',8)

		//    |   Vlr.Bruto (15)   | | Vlr.Liq. (15)  | | Prc.Bruto Un (15)| |Prc.Liq. Un (15)| |Cod. Sit. Trib. |
		_cTexto +=  _cValTotBrut    +    _cValTotLiq    +     _cPrcBruto     +    _cPrcLiq      +   _cCodSitTrib

		//    |     Taxa Aliq. ICMS     | |   Taxa Aliq. ICMS. Subst. Trib.  | |   Taxa Aliq. IPI  | | Taxa Perc. Desc. Com. |
		_cTexto +=   replicate('0',5)    +           replicate('0',5)         +   replicate('0',5)  +      replicate('0',5)

		//   |		Val. Desc. Cml.     | |  Porcent. Reduc. Base. ICMS  | |  Val. Base Calc. ICMS  | | Val. ICMS Calc  |
		_cTexto +=    replicate('0',13)  +        replicate('0',5)        +      _ValBaseCalcIcm     +     _cValICM

		//    | Vlr. Base Calc. ICMS. Sit. Trib | | Vlr. ICMS Calc. Sit. Trib | |       Cod. NCM     | |   Cod. NCM. EX  |
		_cTexto +=       replicate('0',15)       +        replicate('0',15)    +  alltrim(_cCodNcm)   +       '00'

		//    |   Cod. Sit. Trib. Pis  | | Cod. Sit. Trib. Cof. | |  Cod. Sit. Trib. IPI  | |  Cod. Sit. Trib. ICMS   |
		_cTexto +=     _cCodSitPis      +       _cCodSitCof      +       _cCodSitIpi       +        _cCodSitIcm

		//    |     Taxa Aliq. Pis    | |    Taxa Aliq. Cof.    | |     Taxa MVA Icms ST      | | Filler |
		_cTexto +=  replicate('0',5)   +      replicate('0',5)   +     replicate('0',5)        +  Space(19)


		Aadd(_aTexto,_cTexto)


		_nValBasICMS := PER->F2_BASEICM	 //Valor base ICMS
		_nValTotICMS := PER->F2_VALICM   //Valor total ICMS
		_nValBaseST  := PER->F2_BRICMS   //Valor base substituição tributaria
		_nValTotST   := PER->F2_ICMSRET  //Valor total do ICMS com subst. tributaria
		_nValBaseIPI := PER->F2_BASEIPI  //Valor base IPI
		_nValTotIPI  := PER->F2_VALIPI   //Valor IPI
		_nValTotal   := PER->F2_VALFAT   //Valor total da NF

		PER->(DbSkip())
	Enddo	
	//Montagem do Registro Trailer

	_cValTotBrut    := strzero(_TotBrut * 1000,9)      //Valor total das linhas da nota
	_cValBasICMS    := strzero(_nValBasICMS * 100,16)  //Valor base ICMS
	_cValTotICMS    := strzero(_nValTotICMS * 100,15)  //Valor Total do ICMS
	_cValBaseST     := strzero(_nValBaseST * 100,15)   //Valor base substituição tributaria
	_cValTotST      := strzero(_nValTotST * 100,15)    //Valor total do ICMS com subst. Tributaria
	_cValBaseRed    := strzero(_nValBasICMS * 100,15)  //Valor base do ICMS com retençao (igual ao valor base ICMS)
	_cValTotRed     := strzero(_nValTotICMS * 100,15)  //Valor total do ICMS com retenção (igual ao valor total do ICMS)
	_cValBaseIPI    := strzero(_nValBaseIPI * 100,16)  //Valor base do IPI
	_cValTotIPI     := strzero(_nValTotIPI * 100,15)   //Valor total IPI
	_cValFat        := strzero(_nValtotal *100,15)     //Valor Total da NF


	//        |Tipo(2)| |   NF + Serie  | |    Num. Total Itens Nota  | |   Num Total Emb.  | | Qtde. Total Pallet |
	_cTexto :=   '09'  +     _cNrDoc     +       replicate('0',4)      +    replicate('0',4) +   replicate('0',15)

	//        |  Total Peso Bruto  | |Total Peso Liquido  | |Valor Base Calc Icm  | |  Vlr. Total ICMS |
	_cTexto +=      _cValTotBrut    +   replicate('0',8)   +     _cValBasICMS      +    _cValTotICMS

	//        |Vlr. Base Calc. ICMS. Subst. | | Vlr.Total ICMS Subst. | |  Val. Total Merc.  | | Vlr.Tot. Frete  |
	_cTexto += 			replicate('0',16)		  +    replicate('0',15)    +     _cValTotLiq      + replicate('0',13)

	//        |Vlr. Tot. Seguro   | |Vlr.Total Desp. Acessoria. Trib. | |Vlr. Base Calc. IPI  | |   Vlr Tot. IPI|
	_cTexto +=  replicate('0',13)  +          replicate('0',13)        +    _cValBaseIPI       +    _cValTotIPI

	//        |Vlr. Tot. Descontos  | |Vlr. Total NF  | |Vlr. Tot. Desp. Acessoria. ñ Tribt.| |        Filler      | |  
	_cTexto +=   replicate('0',15)   +    _cValFat     +          replicate('0',13)          +      replicate('0',36)


	if _DocAtual <> PER->D2_FILIAL + PER->D2_CLIENTE + PER->D2_LOJA + PER->D2_DOC + PER->D2_SERIE
		_nSeq := 0
		Aadd(_aTexto,_cTexto)
		_TotBrut := 0
		_TotLiq  := 0
	endif


Return

//Função destinada a gerar o txt 
//com base no vetor criado
Static Function SFGeraArquivo()

	Local nTamLin, cLin, cCpo 
	Local _nSeqArq  := GetMv('SI_SQAREDI')
	Local _cNomeArq  :=_cDataArq +  _cNrDoc  + strzero(_nSeqArq,10) + '.txt'
	Local _x
	Private cString  := ""
	//Unid|Diret|tipo | |   Data  | |Doc+Serie| |  Sequencial
	Private cArqTxt := alltrim(mv_par05) + 'NF'  + _cNomeArq
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
	if SF2->(DbSeek(_cChavDoc))
		reclock('SF2',.f.)
		SF2->F2_DOCEDI := 'NF'+_cNomeArq
		msunlock()
	endif
	SF2->(DbCloseArea())
	//Atualiza parametro de sequencial de arquivo
	_nSeqArq++

	PutMV('SI_SQAREDI',_nSeqArq)

Return

