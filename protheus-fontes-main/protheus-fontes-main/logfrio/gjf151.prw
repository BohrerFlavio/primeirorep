#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF151  ºAutor  ³Giuliano Forgiarini   º Data ³  22/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de Arquivo de faturamento para LogFrio - SP        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

User Function GJF151()
	Local _aArqTrb      := {} // inicializa o array do arquivo
	local nOpca	:=0
	local aSays:={}, aButtons:={}

	Private area      := getarea()
	Private _aTexto   := {}
	Private cCadastro := "Geração de arquivo de NF para LogFrio"
	Private _lOk      := .t.
	Private cPerg     := "GJF151"

	if !Pergunte(cPerg,.t.)
		return
	endif

	if empty(mv_par01) .or. empty(mv_par02) .or. empty(mv_par03)
		alert('Parametros essenciais em branco!')
		_lOk := .f.  
		return
	endif
	/*	
	if !file(mv_par03)
	alert('Caminho para geração de arquivo não encontrado!')
	_lOk := .f.    
	return
	endif
	*/  

	GeraTMP()

	aCampos := {}  
	AADD(aCampos,{"OKAY"    , "@X",  "OK"       })
	AADD(aCampos,{"DOC"     , "@X",  "Documento"  })
	AADD(aCampos,{"SERIE"   , "@X",  "Serie"     })
	AADD(aCampos,{"CLIENTE" , "@X",  "Cliente"   })
	AADD(aCampos,{"LOJA"    , "@x"  ,"Loja"     })
	AADD(aCampos,{"NOMCLI"  , "@X",  "Nome"   })
	AADD(aCampos,{"EMISSAO" , ""  ,  "Emissao"     })	

	aRotina  := { {"Gerar","u_GJF151Pr"  ,0,4}}

	cCadastro := 'Escolha de Documentos para Geração de Arquivo '

	dbselectarea('TMP')

	TMP->(dbgotop())


	MarkBrowse("TMP","OKAY",,aCampos,,'S')                              //Mostra os campos do TMP no MarkBrow

	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb)

Return

Static Function SFSeleNF(_Doc,_Serie)		

	if !_lOk
		return
	endif

	_cQuery := ""
	_cQuery += "select D2_FILIAL, D2_CLIENTE, D2_LOJA, D2_EMISSAO,D2_DOC,D2_SERIE,D2_COD,D2_QUANT,D2_QTSEGUM,D2_PRCVEN," 
	_cQuery += "C5_DTENT,C5_HRENT,F2_VALICM," 
	_cQuery += "F2_BASEICM,F2_BRICMS,F2_ICMSRET,F2_VALIPI,F2_BASEIPI,F2_VALFAT, D2_PEDIDO, D2_ITEMPV"
	_cQuery += " FROM SF2010 (nolock)"   //(nolock)
	_cQuery += "INNER JOIN SD2010 (nolock) ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE  "
	_cQuery += "INNER JOIN SC5010 (nolock) ON C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO "
	_cQuery += "where "
	_cQuery += "D2_DOC ='" + _Doc + "' and D2_SERIE = '" + _Serie + "' and "
	_cQuery += "D2_FILIAL = '" + cFilAnt + "' and "
	_cQuery += "D2_TIPO = 'N' and "
	_cQuery += RetSQLName("SD2") + ".D_E_L_E_T_ = '' and "
	_cQuery += RetSQLName("SF2") + ".D_E_L_E_T_ = '' and "
	_cQuery += RetSQLName("SC5") + ".D_E_L_E_T_ = '' "
	_cQuery += " order by D2_FILIAL, D2_CLIENTE, D2_LOJA, D2_DOC, D2_SERIE, D2_PEDIDO, D2_ITEMPV "

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

	_nQtd      := 0
	_nPLiqT    := 0
	_nPBruT    := 0   
	_nValTot   := 0


	PER->(DBGoTop())    

	//Montagem dos cabeçalhos de cada NF que será enviada no arquivo
	DbSelectArea('SA1')   
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	DbSeek(xfilial('SA1')+PER->(alltrim(D2_CLIENTE) + alltrim(D2_LOJA) ))

	DbSelectArea('ZZ4')
	ZZ4->(DbSetOrder(6))
	DbSeek(xfilial('ZZ4')+PER->D2_PEDIDO)

	DbSelectArea('SB1')

	_nValTotICMS := PER->F2_VALICM   //Valor total ICMS  
	_cValTotICMS := strzero(_nValTotICMS * 100,12)  //Valor Total do ICMS  ->LogFrio 

	_nValTotIPI  := PER->F2_VALIPI   //Valor IPI
	_cValTotIPI  := strzero(_nValTotIPI * 100,12)   //Valor total IPI   ->LogFrio

	_nValTotST   := PER->F2_ICMSRET  //Valor total do ICMS com subst. tributaria
	_cValTotST   := strzero(_nValTotST * 100,12)    //Valor total do ICMS com subst. Tributaria ->LogFrio

	_nValTotal   := PER->F2_VALFAT   //Valor total da NF    
	_cValFat     := strzero(_nValtotal *100,12)     //Valor Total da NF ->LogFrio

	_cDataArq   := strtran(dtoc(stod(PER->D2_EMISSAO)),'/','')                             //Data para nomear o arquivo  ->LogFrio
	_cDtHrEmis  := substr(padr(PER->D2_EMISSAO + strtran(time(),':',''),12,''),1,12)       //Data e hora da emissão da NF

	DbSelectArea('ZZ5')
	ZZ5->(DbsetOrder(1))   
	DbSeek(xfilial('ZZ5')+ZZ4->ZZ4_NUM)
	while ZZ5->(!eof()) .and. ZZ5->ZZ5_FILIAL = xfilial('ZZ5') .and. ZZ5->ZZ5_NUM = ZZ4->ZZ4_NUM
		_nQtd    += iif(ZZ5->ZZ5_QRPESO <> 0,1,0)
		_nPLiqT  += ZZ5->ZZ5_QRPESO
		_nPBruT  += ZZ5->ZZ5_QRPESB  
		_nBonif  := IIF (ZZ5->ZZ5_TPBONI = 'A',ZZ5->ZZ5_BONIF,IIF(ZZ5->ZZ5_TPBONI = 'D',ZZ5->ZZ5_BONIF * (-1),0))
		_nValTot += ZZ5->ZZ5_QRPESO * (ZZ5->ZZ5_PRECO +  _nBonif)

		ZZ5->(DbSkip())
	enddo

	_Identificador   := '2'
	_Cod_Dest        := space(10)
	_Raz_Soc_Dest    := padr(alltrim(SA1->A1_NOME),50,'')
	_Ende_Entrega    := padr(alltrim(SA1->A1_END),50,'')
	_Bairro_Entrega  := padr(alltrim(SA1->A1_BAIRRO),20,'')
	_Cep_Entrega     := padr(alltrim(SA1->A1_CEP),9,'')
	_Cidade_Entrega  := padr(alltrim(SA1->A1_MUN),25,'')
	_Estado_Entrega  := padr(alltrim(SA1->A1_EST),2,'')
	_Num_Pedido      := padr(alltrim(ZZ4->ZZ4_NUM),10,'')
	_Dt_Pedido       := alltrim(strzero(day(ZZ4->ZZ4_DATA),2)) + alltrim(strzero(month(ZZ4->ZZ4_DATA),2)) + substr(alltrim(str(year(ZZ4->ZZ4_DATA))),3,2)
	_Qtde_Itens      := strzero(_nQtd,4)
	_Vlr_Total_Prod  := strzero(_nValTot * 100,13)
	_Peso_Liq_Pedido := strzero(_nPLiqT * 1000,10)
	_Num_Nf          := padr(alltrim(PER->D2_DOC),10,'')
	_Sif             := space(10)
	_Num_Carga       := space(10)
	_Peso_Brt_Pedido := strzero(_nPBruT * 1000,10)
	_Cnpj_Cpf_Desti  := padr(alltrim(SA1->A1_CGC),14,'')
	_Serie_Nf        := padr(alltrim(PER->D2_SERIE),3,'')
	_Data_Nf         := substr(PER->D2_EMISSAO,7,2)+substr(PER->D2_EMISSAO,5,2)+substr(PER->D2_EMISSAO,1,4)
	_Data_Entrega    := alltrim(strzero(day(ZZ4->ZZ4_DTENTR),2)) + alltrim(strzero(month(ZZ4->ZZ4_DTENTR),2)) + alltrim(str(year(ZZ4->ZZ4_DTENTR)))
	_Hora_Entrega1   := space(5)
	_Hora_Entrega2   := space(5)
	_Hora_Entrega3   := space(5)
	_Hora_Entrega4   := space(5)   

	_Valor_Tot_NF	  := _cValFat
	_Tipo_Frete      := 'C'
	_Cnpj_Redesp     := space(14)
	_Raz_Soc_Redesp  := space(50)
	_Ende_Redesp     := space(50)
	_Cep_Redesp      := space(8)
	_Cidade_Redesp   := space(30)
	_Bairro_Redesp   := space(20)
	_Estado_Redesp   := space(2)	

	_cTexto := _Identificador + _Cod_Dest + _Raz_Soc_Dest + _Ende_Entrega + _Bairro_Entrega + _Cep_Entrega + _Cidade_Entrega + _Estado_Entrega;
	+ _Num_Pedido + _Dt_Pedido + 	_Qtde_Itens + _Vlr_Total_Prod + _Peso_Liq_Pedido + _Num_Nf + _Sif + _Num_Carga + _Peso_Brt_Pedido;
	+ _Cnpj_Cpf_Desti + _Serie_Nf + _Data_Nf + _Data_Entrega + _Hora_Entrega1 + _Hora_Entrega2 + _Hora_Entrega3 + _Hora_Entrega4;
	+ _cValTotICMS + _cValTotIPI + _cValTotST + _Valor_Tot_Nf + _Tipo_Frete + _Cnpj_Redesp + _Raz_Soc_Redesp + _Ende_Redesp;
	+ _Cep_Redesp + _Cidade_Redesp + _Bairro_Redesp + _Estado_Redesp 

	Aadd(_aTexto,_cTexto)

	While PER->(!eof())
		//Montagem dos registros dos itens da NF
		DbSelectArea('SB1')
		_cDescProd        := fBuscaCPO('SB1',1,xfilial('SB1')+PER->D2_COD,'B1_DESC')	 

		_Identificador    := '3'
		_Co_Produt_Ant    := space(10)
		_Descr_Produto    := padr(alltrim(substr(_cDescProd,1,50)),50,'')
		_Qtde_Produto     := strzero(PER->D2_QTSEGUM,4)
		_Vlr_Unitario     := strzero(PER->D2_PRCVEN * 100000,13)
		_Peso_Liq_Item    := strzero(PER->D2_QUANT * 1000,10)
		_Num_Pedido       := padr(alltrim(ZZ4->ZZ4_NUM),10,'')
		_Placa_Veiculo    := space(11)
		_Cod_Produto      := padr(alltrim(PER->D2_COD),20,'')
		_Qtde_Volumes     := strzero(PER->D2_QTSEGUM,10)
		_Num_Lote_Fabr    := space(10)
		_Data_Validade    := space(8)
		_Peso_BRT_Item  	:= space(10)

		//Montagem dos cabeçalhos de cada Pedido que será enviada no arquivo

		_cTexto := _Identificador + _Co_Produt_Ant + _Descr_Produto + _Qtde_Produto + _Vlr_Unitario + _Peso_Liq_Item + _Num_Pedido;
		+ _Placa_Veiculo + _Cod_Produto + _Qtde_Volumes + _Num_Lote_Fabr + _Data_Validade + _Peso_BRT_Item

		if empty(_Data_Entrega)
			alert("Data de entrega em branco. Preencher no pré-pedido.")
			_lOk := .f.
			return
		endif

		Aadd(_aTexto,_cTexto)

		PER->(DbSkip())

	EndDo


Return

//Função destinada a gerar o txt 
//com base no vetor criado
Static Function SFGeraArquivo()

	Local nTamLin, cLin, cCpo 
	Local _x
	Private cString  := ""
	//Unid|Diret|tipo | |   Data  | |Doc+Serie| |  Sequencial
	Private cArqTxt := alltrim(mv_par04)
	Private nHdl    := fCreate(cArqTxt)
	Private cEOL    := "CHR(13)+CHR(10)"

	if !_lOk
		return
	endif

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

	msgbox('Arquivo gerado com sucesso!','FIM DE PROCESSAMENTO','INFO')

Return    


//Função para gerar arquivo TMP
Static Function GeraTMP()
	_cQueryI := ""
	_cQueryI += "SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_NOMCLI, F2_EMISSAO"
	_cQueryI += " FROM " + RetSQLTab('SF2')
	_cQueryI += " WHERE "    
	_cQueryI += RetSQLFil('SF2') + " AND"
	_cQueryI += "(F2_DOC between '" + mv_par01 + "' and '" + mv_par02 + "') and "
	_cQueryI += " F2_SERIE = '" + mv_par03 + "' and "
	_cQueryI += RetSQLDel("SF2") 
	_cQueryI += "order by F2_DOC, F2_SERIE"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if select("QRY") <> 0
		DBSelectArea("QRY")
		DBCloseArea()
	endif

	TcQuery _cQueryI New Alias "QRY"

	_aArqTrb    := {}
	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	aStru := {}                                           

	aadd(aStru,{"DOC"      , "C",   09, 0,   "@!",'Numero'})	
	aadd(aStru,{"SERIE"    , "C",   03, 0,   "@!",'Serie'})
	aadd(aStru,{"CLIENTE"  , "C",   06, 0,   "@!",'Cliente'})  
	aadd(aStru,{"LOJA"     , "C",   02, 0,   "@!",'Loja'})
	aadd(aStru,{"NOMCLI"   , "C",   60, 0,   "@!",'Nome'})
	aadd(aStru,{"OKAY"     , "C",   01, 0,   "@!",'Ok'})
	aadd(aStru,{"EMISSAO"  , "D",   08, 0,   "",'Emissao'})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	// ProcData 04/2023 - Chamada para criação do arquivo de trabalho
	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)
	
	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
	Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	QRY->(dbgotop())
	//Esse laço serve para atribuir ao TMP os valores
	while QRY->(!eof())
		reclock('TMP',.t.)
		TMP->DOC      := QRY->F2_DOC
		TMP->SERIE    := QRY->F2_SERIE
		TMP->CLIENTE  := QRY->F2_CLIENTE
		TMP->LOJA     := QRY->F2_LOJA
		TMP->EMISSAO  := STOD(QRY->F2_EMISSAO)
		TMP->OKAY     := ''
		TMP->NOMCLI   := QRY->F2_NOMCLI
		msunlock()
		QRY->(dbskip())
	enddo
Return      

//Função que aglutina os processamentos
//para geração do(s) arquivo(s) de NF
User Function GJF151Pr()

	Private _cNrDoc   := ''
	Private _cDataArq := ""
	Private _cChavDoc := ""
	Private _nSeqArq  := 0
	Private _aTexto   := {}

	_area := getarea() 

	if !_lOk
		return
	endif

	DbSelectArea('SM0')
	SM0->(DbSetORder(1))	
	//_aTexto     := {}

	_Identificador := '1'
	_CNPJ     		:= padr(alltrim(SM0->M0_CGC),14,'')
	_NomeCom  		:= padr(alltrim(SM0->M0_NOMECOM),50,'')
	_Data_Arq 		:= alltrim(strzero(day(DdataBase),2)) + alltrim(strzero(month(DdataBase),2)) + substr(alltrim(str(year(DdataBase))),3,2)

	_cTexto := _Identificador + _CNPJ + _NomeCom + _Data_Arq

	Aadd(_aTexto,_cTexto)    

	DbSelectArea('TMP') 

	TMP->(DbGoTop())

	while TMP->(!eof())

		if TMP->OKAY <> 'S'
			TMP->(DbSkip())
			loop
		endif

		MsgRun("Aguarde... Aglutinando dados para arquivo...",,{||  SFSeleNF(TMP->DOC,TMP->SERIE) })

		TMP->(DbSkip())
	enddo

	MsgRun("Aguarde... Gerando o Arquivo..." ,,{||  SFGeraArquivo() })

	GeraTMP()

	TMP->(DbGoTop())

	CloseBrowse()

Return

