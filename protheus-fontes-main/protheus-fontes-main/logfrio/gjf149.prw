#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF149  ºAutor  ³Giuliano Forgiarini   º Data ³  20/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de Arquivos de pedido para envio LogFrio           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

User Function GJF149()
	Local _aArqTrb    := {}
	Private area      := getarea()
	Private cIPerg    := "GJF149"
	Private _aTexto   := {}
	Private _lOK      := .t.


	if Pergunte(cIPerg,.T.)

		if empty(mv_par02) .or. empty(mv_par04)
			alert('Parametros essenciais em branco!')
			_lOk := .f.
		endif
		/*	
		if !file(mv_par05)
		alert('Mapeamento de rede "' + mv_par05 + '" não encontrado!')
		_lOk := .f.
		endif
		*/
	Endif

	if _lOk

		GeraTMP()

		aCampos := {}  
		AADD(aCampos,{"OKAY"    , "@X",  "OK"       })
		AADD(aCampos,{"CODCLI"  , "@X",  "Cliente"  })
		AADD(aCampos,{"LOJA"    , "@X",  "Loja"     })
		AADD(aCampos,{"NUM"     , "@X",  "Numero"   })
		AADD(aCampos,{"DTPED"   , ""  ,  "Data"     })
		AADD(aCampos,{"STATUS"  , "@X",  "Status"   })

		aRotina  := { {"Gerar","u_GJF149Pr"  ,0,4}}

		cCadastro := 'Escolha de Documentos para Geração de Arquivo EDI'

		dbselectarea('TMP')

		TMP->(dbgotop())


		MarkBrowse("TMP","OKAY",,aCampos,,'S')                              //Mostra os campos do TMP no MarkBrow

	endif

	// ProcData 04/2023 - Chamada para fechar arquivo de trabalho
	u_arqtrb ("FechaTodos",,,, @_aArqTrb)
return

//Função para gerar arquivo TMP
Static Function GeraTMP()
	_cQueryI := ""
	_cQueryI += "SELECT ZZ4_NUM, ZZ4_CODCLI, ZZ4_LOJA, ZZ4_NOME, ZZ4_MUN, ZZ4_DATA, ZZ4_STATUS "
	_cQueryI += " FROM " + RetSQLTab('ZZ4')
	_cQueryI += " WHERE "    
	_cQueryI += RetSQLFil('ZZ4') + " AND"
	_cQueryI += "(ZZ4_DATA between '" + DTOS(mv_par01) + "' and '" + DTOS(mv_par02) + "') and "
	_cQueryI += "(ZZ4_NUM between '" + mv_par03 + "' and '" + mv_par04 + "') and "
	_cQueryI += " ZZ4_STATUS  = 'L' AND
	_cQueryI += RetSQLDel("ZZ4") 
	_cQueryI += "order by ZZ4_NUM, ZZ4_CODCLI, ZZ4_LOJA"

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get _cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	if select("QRY") <> 0
		DBSelectArea("QRY")
		DBCloseArea()
	endif

	TcQuery _cQueryI New Alias "QRY"

	_aArqTrb    := {} // inicializa o array do arquivo
	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	aStru := {}                                           

	aadd(aStru,{"NUM"    , "C",   09, 0,   "@!",'Numero'})	
	aadd(aStru,{"CODCLI" , "C",   06, 0,   "@!",'Cliente'})
	aadd(aStru,{"LOJA"   , "C",   02, 0,   "@!",'Loja'})  
	aadd(aStru,{"NOME"   , "C",   40, 0,   "@!",'Nome'})
	aadd(aStru,{"DTPED"  , "D",   08, 0,   "@!",'Data'})
	aadd(aStru,{"OKAY"   , "C",   01, 0,   "@!",'Ok'})
	aadd(aStru,{"STATUS" , "C",   20, 0,   "@!",'Status'})

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
		TMP->CODCLI  := QRY->ZZ4_CODCLI
		TMP->LOJA    := QRY->ZZ4_LOJA
		TMP->NUM     := QRY->ZZ4_NUM
		TMP->DTPED   := STOD(QRY->ZZ4_DATA)
		TMP->OKAY    := ''
		TMP->NOME    := QRY->ZZ4_NOME
		msunlock()
		QRY->(dbskip())
	enddo
Return

//Função que aglutina os processamentos
//para geração do(s) arquivo(s) de pedidos
User Function GJF149Pr()

	Private _cNrDoc := ''
	Private _cDataArq := ""
	Private _cChavDoc := ""
	Private _nSeqArq := 0
	Private _aTexto := {}

	_area := getarea() 

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

		MsgRun("Aguarde... Aglutinando dados para arquivo...",,{||  SFSelePP(TMP->NUM) })

		TMP->(DbSkip())
	enddo

	MsgRun("Aguarde... Gerando o Arquivo..." ,,{||  SFGeraArquivo() })

	GeraTMP()

	TMP->(DbGoTop())

	CloseBrowse()

Return


//função que monta o vetor para TXT
Static Function SFSelePP(_Num)
	DbSelectArea('ZZ5')
	ZZ5->(DbSetOrder(1))
	ZZ5->(DBGoTop())


	if ZZ5->(DbSeek(xfilial('ZZ5')+alltrim(_Num)))

		_DocAtual   := ''
		_nSeq       := 0
		_VlrTotBrut := 0
		_TotBrut    := 0

		_lMens      := .f.
		_cCodCli    := fbuscaCPO('ZZ4',2,xfilial('ZZ4')+_Num,'ZZ4_CODCLI')
		_cLoja      := fbuscaCPO('ZZ4',2,xfilial('ZZ4')+_Num,'ZZ4_LOJA')   
		_nTotalProd  := 0
		_nQuant 		:= 0
		While ZZ5->(!Eof()) .and. ZZ5->ZZ5_FILIAL = xfilial('ZZ5') .and. ZZ5->ZZ5_NUM = alltrim(_Num)

			_nTotalProd += ZZ5->ZZ5_QPPESO
			_nQuant++

			ZZ5->(DbSkip())
		enddo             

		ZZ5->(DbGoTop())
		ZZ5->(DbSeek(xfilial('ZZ5')+alltrim(_Num)))

		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xfilial('SA1')+_cCodCli+_cLoja))

		_Identificador   := '2'
		_Cod_Dest        := space(10)
		_Raz_Soc_Dest    := padr(alltrim(SA1->A1_NOME),50,'')
		_Ende_Entrega    := padr(alltrim(SA1->A1_END),50,'')
		_Bairro_Entrega  := padr(alltrim(SA1->A1_BAIRRO),20,'')
		_Cep_Entrega     := padr(alltrim(SA1->A1_CEP),9,'')
		_Cidade_Entrega  := padr(alltrim(SA1->A1_MUN),25,'')
		_Estado_Entrega  := padr(alltrim(SA1->A1_EST),2,'')
		_Num_Pedido      := padr(alltrim(_Num),10,'')
		_Dt_Pedido       := alltrim(strzero(day(ZZ4->ZZ4_DATA),2)) + alltrim(strzero(month(ZZ4->ZZ4_DATA),2)) + substr(alltrim(str(year(ZZ4->ZZ4_DATA))),3,2)
		_Qtde_Itens      := strzero(_nQuant,4)
		_Vlr_Total_Prod  := strzero(ZZ4->ZZ4_TOTAL	 * 100,13)
		_Peso_Liq_Pedido := strzero(_nTotalProd * 1000,10)
		_Num_Nf          := space(10)
		_Sif             := space(10)
		_Num_Carga       := space(10)
		_Peso_Brt_Pedido := replicate('0',10)
		_Cnpj_Cpf_Desti  := padr(alltrim(SA1->A1_CGC),14,'')
		_Serie_Nf        := space(3)
		_Data_Nf         := space(8)
		_Data_Entrega    := alltrim(strzero(day(ZZ4->ZZ4_DTENTR),2)) + alltrim(strzero(month(ZZ4->ZZ4_DTENTR),2)) + alltrim(str(year(ZZ4->ZZ4_DTENTR)))
		_Hora_Entrega1   := space(5)
		_Hora_Entrega2   := space(5)
		_Hora_Entrega3   := space(5)
		_Hora_Entrega4   := space(5)
		_Valor_ICMS      := space(12)
		_Valor_IPI       := space(12)
		_Valor_ICMS_ST   := space(12)
		_Valor_Tot_NF	  := space(12)
		_Tipo_Frete      := 'C'
		_Cnpj_Redesp     := space(14)
		_Raz_Soc_Redesp  := space(50)
		_Ende_Redesp     := space(50)
		_Cep_Redesp      := space(8)
		_Cidade_Redesp   := space(30)
		_Bairro_Redesp   := space(20)
		_Estado_Redesp   := space(2)	

		_cTexto := _Identificador + _Cod_Dest + _Raz_Soc_Dest + _Ende_Entrega + _Bairro_Entrega + _Cep_Entrega + _Cidade_Entrega + _Estado_Entrega;
		+ _Num_Pedido + _Dt_Pedido + _Qtde_Itens + _Vlr_Total_Prod + _Peso_Liq_Pedido + _Num_Nf + _Sif + _Num_Carga + _Peso_Brt_Pedido;
		+ _Cnpj_Cpf_Desti + _Serie_Nf + _Data_Nf + _Data_Entrega + _Hora_Entrega1 + _Hora_Entrega2 + _Hora_Entrega3 + _Hora_Entrega4;
		+ _Valor_ICMS + _Valor_IPI + _Valor_ICMS_ST + _Valor_Tot_Nf + _Tipo_Frete + _Cnpj_Redesp + _Raz_Soc_Redesp + _Ende_Redesp;
		+ _Cep_Redesp + _Cidade_Redesp + _Bairro_Redesp + _Estado_Redesp 

		Aadd(_aTexto,_cTexto)

		While ZZ5->(!Eof()) .and. ZZ5->ZZ5_FILIAL = xfilial('ZZ5') .and. ZZ5->ZZ5_NUM = alltrim(_Num)

			DbSelectArea('SB1')
			_cDescProd        := fBuscaCPO('SB1',1,xfilial('SB1')+ZZ5->ZZ5_COD,'B1_DESC')	 

			_Identificador    := '3'
			_Co_Produt_Ant    := space(10)
			_Descr_Produto    := padr(alltrim(substr(_cDescProd,1,50)),50,'')
			_Qtde_Produto     := strzero(ZZ5->ZZ5_QPCAIX,4)
			_Vlr_Unitario     := strzero(ZZ5->ZZ5_PRCFIN * 100000,13)
			_Peso_Liq_Item    := strzero(ZZ5->ZZ5_QPPESO * 1000,10)
			_Num_Pedido       := padr(alltrim(_Num),10,'')
			_Placa_Veiculo    := space(11)
			_Cod_Produto      := padr(alltrim(ZZ5->ZZ5_COD),20,'')
			_Qtde_Volumes     := strzero(ZZ5->ZZ5_QPCAIX,10)
			_Num_Lote_Fabr    := space(10)
			_Data_Validade    := space(8)
			_Peso_BRT_Item  	:= space(10)


			//Montagem dos cabeçalhos de cada Pedido que será enviada no arquivo

			_cTexto := _Identificador + _Co_Produt_Ant + _Descr_Produto + _Qtde_Produto + _Vlr_Unitario + _Peso_Liq_Item + _Num_Pedido;
			+ _Placa_Veiculo + _Cod_Produto + _Qtde_Volumes + _Num_Lote_Fabr + _Data_Validade + _Peso_BRT_Item

			Aadd(_aTexto,_cTexto)

			ZZ5->(DbSkip())

		EndDo  

	endif

Return

//Função destinada a gerar o txt 
//com base no vetor criado
Static Function SFGeraArquivo()

	Local nTamLin, cLin, cCpo 
	Local _X
	
	Private cString  := ""
	//Unid|Diret|tipo | |   Data  | |Doc+Serie| |  Sequencial
	Private cArqTxt := alltrim(mv_par05)
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

Return

