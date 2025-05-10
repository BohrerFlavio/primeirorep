#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"
#INCLUDE "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF106    ºAutor  ³Microsiga           º Data ³  20/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Arquivo de leitura do pedido de compra do EDI             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GJF106()

	pergunte("GJF28",.f.)

	Private nTamFile := 0
	Private _cCabec  := ''
	Private _cSum    := ''
	Private _cTipo   := ''
	Private _nlin    := 0
	Private aCond    := {}
	Private aDesc    := {}
	Private aItem    := {}
	Private aGrade   := {}
	Private aCross   := {}
	Private aDir     := Directory('I:\Entrada\*.*')
	Private cArq 
	Private aRotina := {}
	Private lInverte := .f.
	Private cMark    := GetMark()  
	Private oMark
	Private _nGeral := MV_PAR10
	//Private _nBig := MV_PAR11
	//Private _nZFF := MV_PAR12
	aRotinaAnt       := aRotina

	IF MsgNoYes('Os pedidos EDI são atualizados automaticamente a cada 30 minutos. Caso deseje atualiza-los agora clique em "SIM", caso contrário clique em "NÃO"')
		MSGRUN('Importando pedidos...',, {|| u_DWLEDI(), SLEEP(30000)})
    ELSE
		RETURN
    ENDIF

	if len(aDir) = 0
		MsgAlert("Arquivos ou diretorio inexistente! Verifique a origem dos arquivos.","Atencao!")
		Return
	endif

	//if !pergunte(cPerg,.t.)
	//	return
	//endif
	//else
	//	OkLeTxt()
	//endif

	GeraTMP()

	aCampos := {}        
	AADD(aCampos,{"OKAY"    ,, "OK"                  ,"@!"})
	AADD(aCampos,{"ARQUIVO" ,, "Arquivos Disponíveis","@!"})

	//dbselectarea('TMP')
	//IndRegua("TMP",cArq,"ARQUIVO",,,"Selecionando Registros...") //ordena
	TMP->(dbgotop())

	DEFINE MSDIALOG oDlg TITLE "Importação de Arquivo EDI" From 9,0 To 400,1000 PIXEL

	oMark := MsSelect():New("TMP","OKAY","",aCampos,@lInverte,@cMark,{17,1,160,500},,,,,) 
	oMark:bMark := {| | Disp()}        

	TButton():New(170, 070, "Gerar"  , oDlg,{|| u_GJF106Pr() },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )   
	TButton():New(170, 390, "Sair"   , oDlg,{|| oDlg:end()   },40,020,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED 

	//MarkBrowse("TMP","OKAY",,aCampos,,'S')                              //Mostra os campos do TMP no MarkBrow

	aRotina := aRotinaAnt

Return

Static Function Disp()

	RecLock("TMP",.F.)
	If Marked("OKAY")	   
		TMP->OKAY := cMark
	Else     
		TMP->OKAY := ""
	Endif             
	msunlock()
	oMark:oBrowse:Refresh()
Return()

//Função que realiza o processamento
User Function GJF106Pr()

	Private _lOK  := .t.

	//IndRegua("TMP",cArq,"ARQUIVO+OKAY",,,"Selecionando Registros...") //ordena
	TMP->(dbgotop())         

	while TMP->(!eof())      
		if !empty(TMP->OKAY)   
			OkLeTxt('I:\Entrada\'+TMP->ARQUIVO)
			if _lOk 
				FRename('I:\Entrada\'+TMP->ARQUIVO,'I:\Entrada\OK_'+TMP->ARQUIVO)
			endif
		endif
		TMP->(DbSkip())
	enddo

	GeraTMP()             

	TMP->(DbGotop())

return

//Função para gerar TMP de arquivos
Static Function GeraTMP()
	Local i
	//cArq  := CriaTrab( Nil, .F. )                                                 //Cria arquivo temporário

	aDir  := Directory('I:\Entrada\*.*')

	_aArqTrb := {}
	aStru := {}  
	AADD(aStru,{"OKAY"   ,"C",02,0	})
	aadd(aStru,{"ARQUIVO","C",40,0   })

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o  
	//	DbSelectArea('TMP')
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	//IndRegua("TMP",cArq,"ARQUIVO+OKAY",,,"Selecionando Registros...") //ordena

	If Select('TMP')<>0                               //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {"ARQUIVO","OKAY"}, @_aArqTrb)

	TMP->(dbgotop())

	//Esse laço serve para atribuir ao TMP os valores
	for i := 1 to len(aDir)
		if substr(aDir[i,1],1,2) <> 'OK' .and.;
		substr(aDir[i,1],1,2) = 'PD'
			reclock('TMP',.t.)
			TMP->ARQUIVO := alltrim(aDir[i,1])
			TMP->OKAY    := space(1)
			msunlock()
		endif
	next

Return



//Função para ler TXT
Static Function OkLeTxt(_cArquivo)

	if !file(alltrim(_cArquivo))
		MsgAlert("Arquivo TXT não foi encontrado! Verifique os parametros.","Atencao!")
		Return
	endif

	nHandle := FOPEN(alltrim(_cArquivo),FO_READ)
	cString := ''

	nTamFile := fSeek(nHandle,0,FS_END)

	if nTamFile  = 0
		MsgAlert("O arquivo está em branco!","Atencao!")
		return
	endif

	Processa({|| RunCont()  },"Realizando leitura do arquivo...")
	Processa({|| ProcCont() },"Realizando processamento do pedido...")

	FCLOSE(nHandle)

Return



Static Function RunCont()

	if !_lOK
		return
	endif

	ProcRegua(nTamFile)

	fseek(nHandle,0,FS_SET)

	//Leitura da linha do cabeçalho

	cString := FREADSTR(nHandle,274)

	aItem   := {}  //Esvaziando o vetor de itens - em 06.04.11

	If nHandle == -1
		MsgAlert("O arquivo nao pode ser aberto! Verifique os parametros.","Atencao!")
		_lOK := .f.
		Return
	Endif

	if substr(cString,273,2) <> CHR(13)+CHR(10)
		MsgAlert("Falha no cabeçalho do arquivo! Verifique sua estrutura.","Atencao!")
		_lOK := .f.
		Return
	else
		_cCabec := cString
	endif

	//Leitura das linhas das condições de pagamento
	_nlin := 0
	_cTipo := FREADSTR(nHandle,2)

	while _cTipo = '02'

		_nlin++

		cString := FREADSTR(nHandle,45)

		if substr(cString,44,2) <> CHR(13)+CHR(10)
			MsgAlert("Falha na linha "+ str(_nlin) + " das condições de pagamento! Verifique sua estrutura.","Atencao!")
			FSEEK(nHandle,-47,FS_RELATIVE)

			_fim := .f.
			_lOk := .f.

			while !(_fim)
				_pos := FREADSTR(nHandle,1)

				if _pos = CHAR(13)
					_pos := FREADSTR(nHandle,1)
					if _pos = CHAR(10)
						_fim := .t.
					endif
				endif
			enddo
		else
			AADD(aCond,cString)
		endif
		_cTipo  := FREADSTR(nHandle,2)
	enddo

	//Leitura das linhas dos descontos e encargos do pedido

	_nlin := 0

	while _cTipo = '03'

		_nlin++

		cString := FREADSTR(nHandle,122)

		if substr(cString,121,2) <> CHR(13)+CHR(10)
			MsgAlert("Falha na linha "+ str(_nlin) + " dos descontos! Verifique sua estrutura.","Atencao!")
			FSEEK(nHandle,-124,FS_RELATIVE)

			_fim := .f.
			_lOk := .f.

			while !(_fim)
				_pos := FREADSTR(nHandle,1)

				if _pos = CHAR(13)
					_pos := FREADSTR(nHandle,1)
					if _pos = CHAR(10)
						_fim := .t.
					endif
				endif

			enddo
		else
			AADD(aDesc,cString)
		endif
		_cTipo  := FREADSTR(nHandle,2)
	enddo

	//Leitura das linhas dos itens do pedido

	if _cTipo <> '04'
		MsgAlert("Itens do pedido não foram encontrados!","Falha na estrutura do arquivo!")
		_lOK := .f.
		Return
	endif

	_nlin := 0

	while _cTipo = '04'

		_nlin++

		cString := FREADSTR(nHandle,305)

		if substr(cString,304,2) <> CHR(13)+CHR(10)
			MsgAlert("Falha na linha "+ str(_nlin) + " dos itens dos pedidos! Verifique sua estrutura.","Atencao!")
			FSEEK(nHandle,-307,FS_RELATIVE)

			_fim := .f.
			_lOk := .f.

			while !(_fim)
				_pos := FREADSTR(nHandle,1)

				if _pos = CHAR(13)
					_pos := FREADSTR(nHandle,1)
					if _pos = CHAR(10)
						_fim := .t.
					endif
				endif

			enddo
		else
			AADD(aItem,cString)
		endif
		_cTipo  := FREADSTR(nHandle,2)
	enddo

	//Leitura das linhas dos descontos e encargos do pedido

	_nlin := 0

	while _cTipo = '03'

		_nlin++

		cString := FREADSTR(nHandle,122)

		if substr(cString,121,2) <> CHR(13)+CHR(10)
			MsgAlert("Falha na linha "+ str(_nlin) + " dos descontos! Verifique sua estrutura.","Atencao!")
			FSEEK(nHandle,-124,FS_RELATIVE)

			_fim := .f.
			_lOk := .f.

			while !(_fim)
				_pos := FREADSTR(nHandle,1)

				if _pos = CHAR(13)
					_pos := FREADSTR(nHandle,1)
					if _pos = CHAR(10)
						_fim := .t.
					endif
				endif

			enddo
		else
			AADD(aDesc,cString)
		endif
		_cTipo  := FREADSTR(nHandle,2)
	enddo

	//Leitura das linhas da grade

	_nlin := 0

	while _cTipo = '05'

		_nlin++

		cString := FREADSTR(nHandle,37)

		if substr(cString,36,2) <> CHR(13)+CHR(10)
			MsgAlert("Falha na linha "+ str(_nlin) + " dos itens dos pedidos! Verifique sua estrutura.","Atencao!")
			FSEEK(nHandle,-39,FS_RELATIVE)

			_fim := .f.
			_lOk := .f.

			while !(_fim)
				_pos := FREADSTR(nHandle,1)

				if _pos = CHAR(13)
					_pos := FREADSTR(nHandle,1)
					if _pos = CHAR(10)
						_fim := .t.
					endif
				endif

			enddo
		else
			AADD(aGrade,cString)
		endif
		_cTipo  := FREADSTR(nHandle,2)
	enddo

	//Leitura do Crossdocking

	_nlin := 0

	while _cTipo = '06'

		_nlin++

		cString := FREADSTR(nHandle,71)

		if substr(cString,70,2) <> CHR(13)+CHR(10)
			MsgAlert("Falha na linha "+ str(_nlin) + " dos itens dos pedidos! Verifique sua estrutura.","Atencao!")
			FSEEK(nHandle,-72,FS_RELATIVE)

			_fim := .f.
			_lOk := .f.

			while !(_fim)
				_pos := FREADSTR(nHandle,1)

				if _pos = CHAR(13)
					_pos := FREADSTR(nHandle,1)
					if _pos = CHAR(10)
						_fim := .t.
					endif
				endif

			enddo
		else
			AADD(aCross,cString)
		endif
		_cTipo  := FREADSTR(nHandle,2)
	enddo

	//Leitura do sumário
	FSEEK(nHandle,-2,FS_RELATIVE)

	cString := FREADSTR(nHandle,124)

	if substr(cString,123,2) <> CHR(13)+CHR(10)
		MsgAlert("Falha no sumario do arquivo! Verifique sua estrutura.","Atencao!")
		_lOK := .f.
		Return
	else
		_cSum := cString
	endif

Return

Static Function ProcCont()
	Local i
	_NumPP    := ''
	_Cli      := ''
	_Lj       := ''
	_nBuffer  := 0
	_Nome     := ''
	_cPComp   := ''
	_dDtEnt   := DDATABASE
	_cHrEnt   := time()
	_cCodProd := ''
	_ProdCli  := ''
	_cDescPro := ''
	_nQuantP  := 0
	_nQuantC  := 0
	_nPreco   := 0
	_nValDCom := 0
	_SitFin   := ''
	_Blq1     := ''
	_Blq2     := ''
	_CNPJCli  := ''

	if !_lOK
		return
	endif

	_nBuffer := len(aCond) + len(aDesc) + len(aItem) + len(aGrade) + len(aCross) + 2

	ProcRegua(_nBuffer)

	//Montagem do cabeçalho do pré-pedido com base nos dados do arquivo
	_NumPP:= GETSX8NUM('ZZ4','ZZ4_NUM')
	confirmSX8()

	/* 
		Problema = Quando vem pedidos do MAXXI o CNPJ vem em local diferente noa arquivo de texto.
		Solução = Então quando for importar os pedidos do MAXXI, marcar o parâmetro com 'SIM' MV_PAR14
		Se for pedido do MAXXI 			
		Retorno da Nathalia dia 06/05/20 -  Não tem como ela identificar os arquivos, porque maxxi e walmart vem todos iguais  */
	/*
	IF MV_PAR14 = 1
		//_CNPJCliM := substr(_cCabec,195,14)
		_CNPJCliM := GetAdvFval('SA1',3,FWxfilial('SA1') + 'A1_CGC')
		
	Else
		// Se for demais pedidos
		_CNPJCli := substr(_cCabec,195,14)
		
	Endif
	*/

	/*
	IF _nMaxxi = 1
		_CNPJCliM := substr(_cCabec,195,14)
		//_CNPJCli := GetAdvFval('SA1',3,FWxfilial('SA1') + 'A1_CGC')
		_CNPJCli :=  _CNPJCliM
	else
		_CNPJCliM := substr(_cCabec,181,14)
		_CNPJCli :=  _CNPJCliM
	Endif
	// Se for PDWMS.... Nathalia D. (pdwms)
	// Se for PDWMS....Mariana  (PDZFF)
	If  _nBig = 1 .or. _nZFF = 1
		_CNPJCliM := substr(_cCabec,209,14)
		_CNPJCli :=  _CNPJCliM
	ENDIF

	Dia 28/05/22 - Estamos com problema , nos arquivos baixados com início "PDWMS" temos vários clientes . E pelo que notei cadas cliente escreve em um local do 
	cabeçalho seu cnpj. Então para resolver o problema preciso identificar que cliente e o seu local de escrita do cnpj, para identificar em nosso cadastro correto e 
	gravar certo a inclusão do pedido com a lija correta
	*/
	Do Case
			case _nGeral = '01'
				/* Maxxi Big Nacional/Walmart  - arquivo PDWMS... */
				_CNPJCliM := substr(_cCabec,195,14)
				_CNPJCli :=  _CNPJCliM
			case _nGeral = '02'
				/* Angeloni - arquivo   - arquivo PDANG... */
				_CNPJCliM := substr(_cCabec,181,14)
				_CNPJCli :=  _CNPJCliM
			case _nGeral = '03'
				/* Zaffari  - arquivo   - arquivo  PDZFF...  walmart Nacional */
				_CNPJCliM := substr(_cCabec,209,14)
				_CNPJCli :=  _CNPJCliM
			case _nGeral = '04'
				// KOCH
				_CNPJCliM := substr(_cCabec,181,14)
				_CNPJCli :=  _CNPJCliM
			otherwise
				MSGALERT( 'CNPJ de Cliente não cadastrado', '!!!! Atenção !!!!' )
				return .T.
	EndCase

	//_CNPJCliM := substr(_cCabec,181,14)
	SA1->(DbSetOrder(3))
	SA1->(MsSeek(FWxfilial('SA1')+_CNPJCli))

	_CNPJCli := SA1->A1_CGC
	_Cli     := alltrim(SA1->A1_COD)
	_Lj      := alltrim(SA1->A1_LOJA)
	_Nome    := SA1->A1_NOME
	_cPComp  := alltrim(substr(_cCabec,9,20))
	_dDtEnt  := stod(substr(_cCabec,61,8))
	_cHrEnt  := substr(_cCabec,69,2) + ':' +substr(_cCabec,71,2)
	_cVen    := SA1->A1_VEND
	_cNRep   := GetAdvFval('SA3','A3_NOME',FWxfilial('SA3')+_cVen,1)   
	_cMun    := SA1->A1_MUN

	_nComVen := 0.00
	_nComCli := 0.00 
	_nCom    := 0.00

	_nComVen  := GetAdvFval('SA3','A3_COMIS',FWxfilial('SA3')+_cVen,1)  
	_nComCli  := SA1->A1_COMIS

	if _nComCli = 0
		_nCom := _nComVen
	else
		_nCom := _nComCli
	endif     

	if empty(_Cli)
		MsgAlert("CNPJ("+_CNPJCli+") não cadastrado! Verifique estrutura do arquivo.","Atencao!")
		_lOK := .f.
		Return
	endif

	ZZ4->(DbSetOrder(7))
	if ZZ4->(MsSeek(FWxfilial('ZZ4')+_Cli+_Lj+_cPComp))
		MsgAlert("Pedido de Compra " + _cPComp + " do cliente " + _Cli + "/" +_Lj +;
		" ("+alltrim(_Nome) +") já importado! Exclua o Pre-Pedido anterior.","Informação já Processada!")
		_lOK := .f.
		Return
	endif

	//Laço para verificar consistencia dos codigos dos produtos
	x        := 1
	_nTipCod := 1 //Variavel que define o tipo de codificação vinda do pedido do cliente

	for i := 1 to len(aItem)
		//_ProdCli  := padl(substr(aItem[i],16,14),14,'0')
		_ProdCli := alltrim(substr(aItem[i],16,14))

		ZA1->(DbSetOrder(4))
		if ZA1->(MsSeek(FWxfilial('ZA1') + _Cli + _Lj + _ProdCli))
			//_cCodProd := ZA1->ZA1_COD  
			_nTipCod := 1
		else
			ZA1->(DbSetOrder(3))
			if ZA1->(MsSeek(FWxfilial('ZA1') + _Cli + _ProdCli))
				//	_cCodProd := ZA1->ZA1_COD
				_nTipCod := 1   
			else                    
				ZA1->(DbSetOrder(10))
				if ZA1->(MsSeek(FWxfilial('ZA1') + _Cli + _Lj + _ProdCli))
					//_cCodProd := ZA1->ZA1_COD
					_nTipCod := 2       
				else
					ZA1->(DbSetOrder(9))
					if ZA1->(MsSeek(FWxfilial('ZA1') + _Cli + _ProdCli))
						//	_cCodProd := ZA1->ZA1_COD
						_nTipCod := 2   
					else
						alert('Correlação de produtos não localizada do produto ' + _ProdCli + '!')
						_lOK := .f.
						return
					endif
				endif
			endif
		endif

	next

	if !_lOK
		return
	endif

	//Gravação do cabeçalho do pré-pedido de venda
	reclock('ZZ4',.t.)
	ZZ4->ZZ4_FILIAL := FWxfilial('ZZ4')
	ZZ4->ZZ4_NUM    := _NumPP
	ZZ4->ZZ4_STATUS := 'B'
	ZZ4->ZZ4_ORIGEM := 'E'
	ZZ4->ZZ4_DATA   := DDATABASE
	ZZ4->ZZ4_DATAC  := DDATABASE
	ZZ4->ZZ4_TPOPER := 'V'
	ZZ4->ZZ4_CODCLI := _Cli
	ZZ4->ZZ4_LOJA   := _Lj
	ZZ4->ZZ4_NOME   := _Nome
	ZZ4->ZZ4_PCOMPR := _cPComp
	ZZ4->ZZ4_DTENT  := _dDtEnt
	ZZ4->ZZ4_HRENT  := _cHrEnt
	ZZ4->ZZ4_REPRES := _cVen
	ZZ4->ZZ4_NOMREP := _cNRep
	ZZ4->ZZ4_TIPCOD := _nTipCod
	ZZ4->ZZ4_MUN    := _cMun  
	ZZ4->ZZ4_COMIS  := _nCom 
	//ZZ4->ZZ4_TIPOPR := iif(_lPorc .and. _lDeso,'',iif(_lPorc,'P','D'))
	msunlock()

	ZZ4->(DbSetOrder(2))
	ZZ4->(MsSeek(FWxfilial('ZZ4')+_NumPP))

	//Gravação dos itens do pré-pedido de venda

	//Variáveis para verificar o tipo de produção
	_lPorc := .f.
	_lDeso := .f.

	for i := 1 to len(aItem) 
		_ProdCli  := alltrim(substr(aItem[i],16,14))
		_nQuantP  := val(substr(aItem[i],102,11))/100 //Alteração Cristiano
		//_nPreco   := val(substr(aItem[i],181,15))/100
		_nPreco   := val(substr(aItem[i],185,11))/100 //Alteração Livia
		_nValDCom := val(substr(aItem[i],219,15))/100

		ZA1->(DbSetOrder(4))
		if ZA1->(MsSeek(FWxfilial('ZA1') + _Cli + _Lj + _ProdCli))
			_cCodProd := ZA1->ZA1_COD
			_nTipCod := 1
		else
			ZA1->(DbSetOrder(3))
			if ZA1->(MsSeek(FWxfilial('ZA1') + _Cli + _ProdCli))
				_cCodProd := ZA1->ZA1_COD
				_nTipCod := 1
			else
				ZA1->(DbSetOrder(10))
				if ZA1->(MsSeek(FWxfilial('ZA1') + _Cli + _Lj + _ProdCli))
					_cCodProd := ZA1->ZA1_COD 
					_nTipCod := 2
				else
					ZA1->(DbSetOrder(9))
					if ZA1->(MsSeek(FWxfilial('ZA1') + _Cli + _ProdCli))
						_cCodProd := ZA1->ZA1_COD
						_nTipCod := 2
					else
						alert('Correlação de produtos não localizada do produto ' + _ProdCli + '!')
						_lOK := .f.
						return
					endif
				endif
			endif
		endif

		_cDescPro := GetAdvFval('SB1','B1_DESC',FWxfilial('SB1')+_cCodProd,1)

		_nQuantC := NMCaixas(_cCodProd, _nQuantP)

		if !_lOK
			return
		endif

		//Verificar qual o tipo de produção 
		_cGrp := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+_cCodProd,1)

		if '56' $ _cGrp
			_lPorc := .t.
		else
			_lDeso := .t.   	
		endif

		reclock('ZZ5',.t.)
		ZZ5->ZZ5_FILIAL := FWxfilial('ZZ5')
		ZZ5->ZZ5_NUM    := _NumPP
		ZZ5->ZZ5_ITEM   := strzero(i,3)
		ZZ5->ZZ5_COD    := _cCodProd
		ZZ5->ZZ5_DESC   := _cDescPro
		ZZ5->ZZ5_QPCAIX := _nQuantC
		ZZ5->ZZ5_QPPESO := _nQuantP
		ZZ5->ZZ5_PRECO  := _nPreco
		ZZ5->ZZ5_PRIORI := 'P'
		ZZ5->ZZ5_TPBONI := iif(_nValDCom = 0,'','D')
		ZZ5->ZZ5_BONIF  := iif(_nValDCom = 0,0,_nValDCom)
		ZZ5->ZZ5_RESERV := 'N' 
		ZZ5->ZZ5_TIPCOD := _nTipCod   
		ZZ5->ZZ5_SLDPOR := _nQuantP
		ZZ5->ZZ5_PRECAR := GetAdvFval('ZZ4','ZZ4_PRECAR',FWxFilial('ZZ4') + _NumPP,2)
		msunlock()
	next

	reclock('ZZ4',.f.)
	ZZ4->ZZ4_TIPOPR := iif(_lPorc .and. _lDeso,'',iif(_lPorc,'P','D'))
	msunlock()

Return

//Função que calcula o numero médio de caixas
Static Function NMCaixas(produto, peso)
	caixas := 0

	SB1->(dbsetorder(1))
	if SB1->(Msseek(FWxfilial('SB1')+produto))
		cmp   := SB1->B1_PMCAIX
		ncaix := round(peso/cmp,0)
		return ncaix
	endif

return caixas
