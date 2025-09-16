#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "vkey.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF158 ºGiuliano José ta Forgiarini   º Data ³  26/11/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Avaliação de Vendas                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Comercial e Diretoria                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF158()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio  "
	Local cDesc2         := "para avaliação do desempenho de vendas do setor     "
	Local cDesc3         := "comercial da empresa conforme os parametros.        "
	Local cPict          := ""
	Local titulo       	:= "RELATORIO DE AVALIACAO DE VENDAS"
	Local nLin         	:= 80
	Local Cabec1       	:= "Supervisor        Dados do Cliente"
	Local Cabec2       	:= "                        Data       Pedido          Previsto(kg)        Realizado(kg)       Valor(R$)"
	Local imprime      	:= .T.
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private limite      := 80
	Private Tamanho     := "M"
	Private nomeprog    := "GJF158" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "GJF158"
	Private cPergI      := "GF158I"
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "GJF158" // Coloque aqui o nome do arquivo usado para impressao em disco   
	Private _cClientes   := '' 


	if msgbox('Deseja selecionar os clientes para geração do relatório?','FILTRO DE CLIENTES','YESNO')
		montabrow()	
	endif

	Set Key VK_F12 To montabrow()

	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZZ4',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	//para verificação se existe previsao de pesagem
	cQuery := " SELECT ZZ4_USAR, ZZ4_CODCLI, ZZ4_LOJA, ZZ4_NUM, ZZ4_DATA, ZZ5_PRCFIN, A1_OKFS, SUM(ZZ5_QPPESO) AS QPPESO, SUM(ZZ5_QRPESO)AS QRPESO"
	cQuery += " FROM " + RetSQLTab('ZZ4') + "," + RetSQLTab('ZZ5') + "," + RetSQLTab('SA1') 
	cQuery += " WHERE " + RetSQLFil('ZZ4') + " AND " + RetSQLFil('ZZ5') + " AND " + RetSQLFil('SA1')   
	cQuery += " AND ZZ4_NUM = ZZ5_NUM AND ZZ4_CODCLI = A1_COD AND A1_LOJA = ZZ4_LOJA AND A1_OKFS <> ''"
	cQuery += " AND (ZZ4_DATA BETWEEN '"   + dtos(mv_par01) + "' AND '" + dtos(mv_par02) + "')"
	cQuery += " AND ZZ4_STATUS = 'F' AND ZZ4_TPOPER = 'V'  AND ZZ5_QRPESO <> 0 " 

	_origem := iif(mv_par03 = 1,'P',iif(mv_par03 = 2,'D',iif(mv_par03 = 3,'E','')))

	if !empty(_origem)
		cQuery += " AND ZZ4_ORIGEM <> '" + _origem + "'"
	endif

	cQuery +=  "AND " + RetSQLDel('ZZ4') + " AND " + RetSQLDel('ZZ5') + " AND " + RetSQLDel('SA1')

	cQuery += " GROUP BY ZZ4_USAR, ZZ4_CODCLI, ZZ4_LOJA, ZZ4_DATA, ZZ4_NUM, ZZ5_PRCFIN, A1_OKFS"
	cQuery += " ORDER BY ZZ4_USAR, ZZ4_CODCLI, ZZ4_LOJA, ZZ4_DATA, ZZ4_NUM, ZZ5_PRCFIN, A1_OKFS"

	cQuery := ChangeQuery(cQuery)

	If Select("VEN") != 0
		VEN->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "VEN"  

	//	* Mostrar a consulta */
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZZ4')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem 
	Local _cUsuar   := '' 
	Local _cCli     := ''  
	Local _cData    := ''
	Local _cPedido  := ''
	Local _nQPPeso  := 0.00  
	Local _nQRPeso  := 0.00  
	Local _nQRPesoV := 0.00 
	Local _nQRPesoC := 0.00     
	Local _nQPPesoV := 0.00 
	Local _nQPPesoC := 0.00
	Local _cPedido  := ''
	Local _nQPPeso  := 0.00  
	Local _nQRPeso  := 0.00
	Local _nTotalV  := 0.00
	Local _ntotalC  := 0.00
	Local _nTotalP  := 0.00

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	VEN->(SetRegua(RecCount()))

	VEN->(dbGoTop())

	DbSelectArea('ZZ4')
	ZZ4->(DbSetOrder(1))

	While VEN->(!EOF())

		incregua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		if nLin > 70
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		endif

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif 

		if _cUsuar <> VEN->ZZ4_USAR
			@nlin,01 psay VEN->ZZ4_USAR
			_cUsuar := VEN->ZZ4_USAR	
			nlin++
		endif

		if _cCli <> VEN->(ZZ4_CODCLI + ZZ4_LOJA) 
			_cNomcli := fBuscaCPO('SA1',1,xfilial('SA1')+VEN->(ZZ4_CODCLI+ZZ4_LOJA),'A1_NOME')
			@nlin,20 psay VEN->ZZ4_CODCLI
			@nlin,30 psay VEN->ZZ4_LOJA 
			@nlin,35 psay alltrim(_cNomCli)
			_cCli  := VEN->(ZZ4_CODCLI + ZZ4_LOJA)
			_cData := ''
			nlin++
		endif                      

		if _cData <> VEN->ZZ4_DATA 
			@nlin,20 psay stod(VEN->ZZ4_DATA)
			_cData := VEN->ZZ4_DATA   	
		endif

		_cPedido  := VEN->ZZ4_NUM
		_nQPPeso  += VEN->QPPESO 
		_nQRPeso  += VEN->QRPESO
		_nQRPesoC += VEN->QRPESO
		_nQRPesoV += VEN->QRPESO  	                 
		_nQPPesoC += VEN->QPPESO
		_nQPPesoV += VEN->QPPESO  	
		_nTotalV  += (VEN->ZZ5_PRCFIN * VEN->QRPESO)
		_nTotalC  += (VEN->ZZ5_PRCFIN * VEN->QRPESO)
		_nTotalP  += (VEN->ZZ5_PRCFIN * VEN->QRPESO)  

		VEN->(dbSkip()) // Avanca o ponteiro do registro no arquivo 


		if _cPedido <> VEN->ZZ4_NUM .or. VEN->(eof())
			@nlin,35  psay _cPedido
			@nlin,50  psay transform(_nQPPeso,'@E 999,999.99')   
			@nlin,70  psay transform(_nQRPeso,'@E 999,999.99')
			@nlin,90  psay transform(_nTotalP,'@E 999,999.99')
			_cPedido := VEN->ZZ4_NUM
			_nQPPeso := 0.00
			_nQRPeso := 0.00 
			_nTotalP := 0.00

			nlin++
		endif

		if _cCli <> VEN->(ZZ4_CODCLI + ZZ4_LOJA) .or. VEN->(eof())   
			nlin++  
			@nlin,001 psay 'Total Cliente: ' //+ replicate('-',75)  
			@nlin,047 psay transform(_nQPPesoC,'@E 999,999,999.99')
			@nlin,067 psay transform(_nQRPesoC,'@E 999,999,999.99')
			@nlin,087 psay transform(_nTotalC, '@E 999,999,999.99')

			_nTotalC  := 0.00 
			_nQRPesoC := 0.00                                      
			_nQPPesoC := 0.00
			nlin+=2
		endif                      

		if _cUsuar <> VEN->ZZ4_USAR.or. VEN->(eof()) 
			nlin++  
			@nlin,001 psay 'Total Supervisor: ' //+ replicate('-',88) 
			@nlin,047 psay transform(_nQPPesoV,'@E 999,999,999.99')
			@nlin,067 psay transform(_nQRPesoV,'@E 999,999,999.99')
			@nlin,087 psay transform(_nTotalV,'@E 999,999,999.99')
			_nTotalV  := 0.00                  
			_nQRPesoV := 0.00                 
			_nQPPesoV := 0.00
			nlin+=2
		endif		
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	DbCloseArea('VEN')
	DbCloseArea('ZZ4')

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

//Função para gerar arquivo TMP
Static Function GeraTMP()

	if !pergunte(cPergI,.t.)
		return .f.
	endif

	_cQueryI := ""
	_cQueryI += " SELECT A1_OKFS, A1_COD, A1_LOJA, A1_NOME"
	_cQueryI += " FROM " + RetSQLTab('SA1')
	_cQueryI += " WHERE " + RetSQLFil('SA1')
	_cQueryI += " AND (A1_COD BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "')"
	_cQueryI += " AND " + RetSQLDel('SA1')	
	if mv_par03 = 1
		_cQueryI += " AND A1_OKFS <> '' " 	
	endif
	_cQueryI += " ORDER BY A1_COD, A1_NOME "


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

	aadd(aSt/ru,{"A1_COD"  , "C",   06, 0,   "@!",'Cliente'})
	aadd(aStru,{"A1_LOJA" , "C",   02, 0,   "@!",'Loja'})
	aadd(aStru,{"A1_NOME" , "C",   60, 0,   "@!",'Nome'})   
	aadd(aStru,{"A1_OKFS" , "C",   01, 0,   "@!",'OK'})

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
		TMP->A1_COD   := QRY->A1_COD
		TMP->A1_LOJA  := QRY->A1_LOJA
		TMP->A1_NOME  := QRY->A1_NOME  
		TMP->A1_OKFS  := QRY->A1_OKFS
		msunlock()
		QRY->(dbskip())
	enddo
Return .t.


User Function GJF158Gr()

	TMP->(DbGoTop())  

	while TMP->(!eof())

		SA1->(DbSetOrder(1))
		if SA1->(DbSeek(xfilial('SA1')+TMP->(A1_COD+A1_LOJA)))
			reclock('SA1',.f.)
			SA1->A1_OKFS := TMP->A1_OKFS
			msunlock()
		endif
		TMP->(DbSkip())
	enddo

	closebrowse()

return   


User Function GJF158MT()

	TMP->(DbGoTop())  

	while TMP->(!eof())
		reclock('TMP',.f.)
		TMP->A1_OKFS := iif(TMP->A1_OKFS = 'S',' ','S')
		msunlock()
		TMP->(DbSkip())
	enddo

	TMP->(DbGoTop())


return    

Static Function montabrow()
	if GeraTMP()

		aCampos := {}
		AADD(aCampos,{"A1_OKFS" , "@X",  "OK"      })
		AADD(aCampos,{"A1_COD"  , "@X",  "Codigo"  })
		AADD(aCampos,{"A1_LOJA" , "@X",  "Loja"    })
		AADD(aCampos,{"A1_NOME" , "@X",  "Nome"    })

		aRotina  := { {"Gravar","u_GJF158Gr"  ,0,4},;
		{"Todos","u_GJF158MT"  ,0,4}	}

		cCadastro := 'Escolha os clientes para geração do relatório'

		dbselectarea('TMP')

		TMP->(dbgotop())

		MarkBrowse("TMP","A1_OKFS",,aCampos,,'S')                              //Mostra os campos do TMP no MarkBrow
	endif   

	pergunte(cPerg,.F.)

return
