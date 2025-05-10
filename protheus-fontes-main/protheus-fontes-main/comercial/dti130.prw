#INCLUDE "rwmake.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DTI130   ºAutor  ³Daniel de Souza      º Data ³  25/10/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Arquivo de leitura do pedido de compra do EDI             º±±
±±º          ³  Carrefour                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function dti130()

	Private nTamFile  := 0
	Private _cCabec   := ''
	Private _cObs     := ''
	Private _cSum     := ''
	Private _cCond	   := ''
	Private _cTipo    := ''
	Private _cTrailer := ''
	Private _nlin     := 0
	Private aCond     := {}
	Private aItens    := {}
	Private aGrade    := {}
	Private aCross    := {}
	Private aDir      := Directory('I:\Entrada\*.*')
	Private cPerg     := "GJF28"
	Private cArq
	aRotinaAnt        := aRotina                                

	if cEmpAnt <> '01'
		msgbox('Rotina inválida para esta empresa','OPERAÇÃO INVALIDA','STOP')
		return
	endif

	if len(aDir) = 0
		MsgAlert("Arquivos ou diretorio inexistente! Verifique a origem dos arquivos.","Atencao!")
		Return
	endif

	GeraTMP()

	aCampos := {} 
	AADD(aCampos,{"OKAY"    , "@X",  "OK"                  })
	AADD(aCampos,{"ARQUIVO" , "@X",  "Arquivos disponíveis"})

	aRotina  := { {"Gerar","u_dti131Pr"  ,0,4}}

	cCadastro := 'Importação de Arquivo EDI'

	dbselectarea('TMP')
	IndRegua("TMP",cArq,"ARQUIVO",,,"Selecionando Registros...") //ordena
	TMP->(dbgotop())

	MarkBrowse("TMP","OKAY",,aCampos,,'S')                              //Mostra os campos do TMP no MarkBrow

	aRotina := aRotinaAnt

	pergunte(cPerg,.f.)

Return

//Função que realiza o processamento
User Function dti130Pr()

	Private _lOK  := .t.

	IndRegua("TMP",cArq,"ARQUIVO+OKAY",,,"Selecionando Registros...") //ordena
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
	aadd(aStru,{"ARQUIVO", "C",   40, 0,   "@!",'Nome do Arquivo'})
	aadd(aStru,{"OKAY"   , "C",   01, 0,   "@!",'Ok'})

	//dbcreate(cArq,aStru)                                                          //Cria a estrutura do vetor no TMP criado
	//If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o  
	//	DbSelectArea('TMP')
	//	TMP->(dbCloseArea())
	//Endif
	//Manda usar o TMP
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )
	//IndRegua("TMP",cArq,"ARQUIVO+OKAY",,,"Selecionando Registros...") //ordena
	//TMP->(dbgotop())         

	If Select('TMP')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {"ARQUIVO","OKAY"}, @_aArqTrb)

	//Esse laço serve para atribuir ao TMP os valores
	for i := 1 to len(aDir)
		if substr(aDir[i,1],1,2) <> 'OK' .and.;
		substr(aDir[i,1],1,2) = 'OR'
			DbSelectArea('TMP')
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

	aItens := {}

	if !_lOK
		return
	endif

	ProcRegua(nTamFile)

	fseek(nHandle,0,FS_SET)

	//Leitura da linha do cabeçalho

	cString := FREADSTR(nHandle,352)

	aItem   := {}  

	If nHandle == -1
		MsgAlert("O arquivo nao pode ser aberto! Verifique os parametros.","Atencao!")
		_lOK := .f.
		Return
	Endif

	if substr(cString,351,2) <> CHR(13)+CHR(10)
		MsgAlert("Falha no cabeçalho do arquivo! Verifique sua estrutura.","Atencao!")
		_lOK := .f.
		Return
	else
		_cCabec := cString
	endif

	_cPComp  := alltrim(substr(_cCabec,3,15))

	//Leitura da linha de observações

	_nlin := 0
	_cTipo := FREADSTR(nHandle,2)

	_nlin := 0

	if _cTipo = '11'

		_nlin++

		FSEEK(nHandle,-2,FS_RELATIVE)
		cString := FREADSTR(nHandle,352)
		_cObs := cString

	else
		MsgAlert("Falha no registro das observações! Verifique sua estrutura.","Atencao!")
		_lOK := .f.
		Return

	endif  

	//Condições de pagamento 

	_nlin := 0
	_cTipo := FREADSTR(nHandle,2)


	if _cTipo = '02'

		_nlin++	
		FSEEK(nHandle,-2,FS_RELATIVE)
		cString := FREADSTR(nHandle,352)	
		_cCond  := cString

	else

		MsgAlert("Falha no Registro de Condições de Pagamento!","Falha na estrutura do arquivo!")
		_lOK := .f.
		return

	endif

	_cTipo := FREADSTR(nHandle,2)

	//Leitura das linhas dos produtos

	_nlin := 0

	FSEEK(nHandle,-2,FS_RELATIVE)

	while _cTipo = '03'

		_nlin++
		cString := FREADSTR(nHandle,352)

		if substr(cString,351,2) <> CHR(13)+CHR(10)

			MsgAlert("Falha na linha "+ str(_nlin) + " dos Produtos! Verifique sua estrutura.","Atencao!")
			_lOK := .f.
			return
		else    

			AADD(aItens,cString + _cPComp)
		endif
		_cTipo  := FREADSTR(nHandle,2)  
		FSEEK(nHandle,-2,FS_RELATIVE)

	enddo

	//Leitura do Registro Trailer 

	_nlin := 0 

	if _cTipo = '09'

		_nlin++

		FSEEK(nHandle,-2,FS_RELATIVE)
		cString    := FREADSTR(nHandle,352)	
		_cTrailer  := cString					

	else
		MsgAlert("Falha no Registro Trailer!","Falha na estrutura do arquivo!")
		_lOK := .f.
		return

	endif
	_cTipo := FREADSTR(nHandle,2)

Return

Static Function ProcCont()
	Local i
	Local j
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

	if !_lOK
		return
	endif

	//_nBuffer := len(aCond) + len(aDesc) + len(aItem) + len(aGrade) + len(aCross) + 2

	ProcRegua(_nBuffer)

	//Montagem do cabeçalho do pré-pedido com base nos dados do arquivo
	_NumPP := GETSX8NUM('ZZ4','ZZ4_NUM')
	confirmSX8()

	_Cli     := '001110'
	_Lj      := ''   
	_CNPJCli := GetAdvFval("SA1",'A1_CGC',FWxfilial('SA1')+_Cli+_Lj,1)
	_Nome    := GetAdvFval("SA1",'A1_NOME',FWxfilial('SA1')+_Cli+_Lj,1)
	_cVen    := GetAdvFval("SA1",'A1_VEND',FWxfilial('SA1')+_Cli+_Lj,1)
	_cPComp  := alltrim(substr(_cCabec,3,15))

	//_dDtEnt  := stod(substr(_cCabec,61,8))
	//_cHrEnt  := substr(_cCabec,69,2) + ':' +substr(_cCabec,71,2)

	_cNRep   := GetAdvFval('SA3','A3_NOME',FWxfilial('SA3')+_cVen,1)
	_cMun    := GetAdvFval('SA1','A1_MUN',FWxfilial('SA1')+_Cli+_Lj,1)

	_nComVen := 0.00
	_nComCli := 0.00 
	_nCom    := 0.00

	_nComVen := GetAdvFval('SA3','A3_COMIS',FWxfilial('SA3')+_cVen,1)
	_nComCli := GetAdvFval('SA1','A1_COMIS',FWxfilial('SA1')+_Cli+_Lj,1)

	if _nComCli = 0
		_nCom := _nComVen
	else
		_nCom := _nComCli
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

	for i := 1 to len(aItens)
		//_ProdCli  := padl(substr(aItem[i],16,14),14,'0')
		_ProdCli := alltrim(substr(aItens[i],21,14))

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
	ZZ4->ZZ4_OBS    := 'Pedido N°: ' + alltrim(substr(_cPComp,5,15))
	ZZ4->ZZ4_DTENT  := _dDtEnt
	ZZ4->ZZ4_HRENT  := _cHrEnt
	ZZ4->ZZ4_REPRES := _cVen
	ZZ4->ZZ4_NOMREP := _cNRep
	ZZ4->ZZ4_TIPCOD := _nTipCod
	ZZ4->ZZ4_MUN    := _cMun  
	ZZ4->ZZ4_COMIS  := _nCom 
	ZZ4->ZZ4_USAR   := cUserName
	msunlock()

	ZZ4->(DbSetOrder(2))
	ZZ4->(MsSeek(FWxfilial('ZZ4')+_NumPP))

	//Gravação dos itens do pré-pedido de venda

	for j := 1 to len(aItens)    

		_ProdCli  := alltrim(substr(aItens[j],21,14))
		_nQuantP  := round(val(substr(aItens[j],79,9))/1000,2)
		_nPreco   := round(val(substr(aItens[j],88,17))/1000000,2)
		_cPcompI  := substr(aItens[j],353,15)

		//_nValDCom := val(substr(aItens[i],219,15))/100
		if _cPComp = _cPcompI

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

			reclock('ZZ5',.t.)
			ZZ5->ZZ5_FILIAL := FWxfilial('ZZ5')
			ZZ5->ZZ5_NUM    := _NumPP
			ZZ5->ZZ5_ITEM   := strzero(j,3)
			ZZ5->ZZ5_COD    := alltrim(_cCodProd)
			ZZ5->ZZ5_DESC   := _cDescPro
			ZZ5->ZZ5_QPCAIX := _nQuantC
			ZZ5->ZZ5_QPPESO := _nQuantP
			ZZ5->ZZ5_PRECO  := _nPreco
			ZZ5->ZZ5_PRIORI := 'P'			
			ZZ5->ZZ5_RESERV := 'N' 
			ZZ5->ZZ5_TIPCOD := _nTipCod
			ZZ5->ZZ5_PRECAR := GetAdvFval('ZZ4','ZZ4_PRECAR',FWxFilial('ZZ4') + _NumPP,2)
			msunlock()
		endif

	next
Return

//Função que calcula o numero médio de caixas
Static Function NMCaixas(produto, peso)
	caixas := 0

	SB1->(dbsetorder(1))
	if SB1->(MsSeek(FWxfilial('SB1')+produto))
		cmp   := SB1->B1_PMCAIX
		ncaix := round(peso/cmp,0)
		return ncaix
	endif

return caixas
