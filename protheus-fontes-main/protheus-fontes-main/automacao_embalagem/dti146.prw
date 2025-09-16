#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"
#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"

//--------------------------------------------------------------------------------------
/*/{Protheus.doc} CONECT 
@Type			: Função de Usuário
@Sample			: U_CONECT()
@Description	: Rotina para gravação do % de Gordura nas caixas da SZ8 automaticamente
                  postgreSQL
@Param			: Nulo
@Return			: Nulo
@ --------------|-----------------------------------------------------------------------
@Author			: Flávio
@Since			: Jan/2022
@version		: Protheus 12.1.25 e posteriores
@Comments		: Rotina de complemento de dados nas caixas, captura do % de gordura recebemndo 
informações do sensor 
/*/
//--------------------------------------------------------------------------------------

Static Function etqim(_sPercG,_cObjK,cCx,cCdp,nperc,cTabela,_cStrg)
	npercC := 0
	cProduto := cCdp
	cGravar := 'N'
	cPercCar := ''
	/* Variável nperc vem com o % e Gordura.
	Então logo a baixo é gerado o calculo do % da carne no produto */
	npercC := 100 - nperc
	/* 
	Regra para troca de código para necessidade André 
	Para resfriado:  - 10826 - 10827 - 21135 - 21999 - 22000
    OBS - Valeska vai criar o Produto . Trocar por 99
	Para congelado: - 19231 - 19233 - 12725 - 10914  - 19545 
	OBS - Valeska vai criar o Produto . Trocar por 98
	OBS - Não utilizado , pois definiu-se que iamos gravar em todas as caixas o % de carne
	*/
	/*  Produto cadastrado então simular produto
	010826 -  Resfriado
	019231 -  Congelado
	OBS - Solicitado que gravasse o Percentual de carne em todas as caixas.
	*/
	/* arredondar */
	npercC := Round( npercC, 0 )

	if npercC > 0 .and. npercC < 70
		cPercCar := 'de 1 a 69 %'
	elseif npercC > 69 .and. npercC < 75
		cPercCar := 'de 70 a 74 %'
	elseif npercC > 74 .and. npercC < 80
		cPercCar := 'de 75 a 79 %'
	elseif npercC > 79 .and. npercC < 85
		cPercCar := 'de 80 a 84 %'
	elseif npercC > 84 .and. npercC < 101
		cPercCar := 'de 85 a 100 %'
	endif
	cGravar := 'S'

    IF cGravar = 'S' 
		// Gravando na SZ8 para ter o registro para futura impressão de % de gordura caso precise
		IF cTabela = 'SZ8'
			SZ8->(DbSetOrder(3))
			if SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(cCx)))
				reclock('SZ8',.f.)
				//SZ8->Z8_PERCGRX := alltrim(str(npercC))
				SZ8->Z8_PERCRXN := npercC
				SZ8->Z8_STRRX := "Raio X ID -> "+alltrim(_cObjK)+" - Perc. Carne -> "+ cPercCar +"Caixa -> "+cCx+" - hora-"+time()+' -ROT. DTI146'
				msunlock()
				//RegEve1('Registro Efetivado na SZ8','OK','Inf.Gravada',30,_cStrg,SZ8->Z8_COD,'RAIOX')
			endif
		elseif cTabela = 'ZAS'
			/* grava dados na ZAS porque caixas vão para porcionados */
			ZAS->(DbSetOrder(1))
			if ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(cCx)))
				reclock('ZAS',.f.)
				//ZAS->ZAS_PERCGX := alltrim(str(Round( npercC, 0 )))
				ZAS->ZAS_PERCCX := npercC
				ZAS->ZAS_STRRX := "Raio X ID -> "+alltrim(_cObjK)+" - Perc. Carne -> "+ cPercCar +"Caixa -> "+cCx+" - hora -"+time()+' -ROT. DTI146'
				msunlock()
				//RegEve1('Registro Efetivado na SZ8','OK','Inf.Gravada',30,_cStrg,ZAS->ZAS_COD,'RAIOX')
			endif
		endif
	Endif

return


Static Function FQuery2(cBatchK)
	Local cont := 0
	Local cBatchV := space(5)
	// Esta buscando o id que esta gravado a porcentagem de gordura
	cQuery2 := "SELECT * "
	cQuery2 += "  FROM result" 
	cQuery2 += " WHERE objectkey =" + str(cBatchK)
	cQuery2 += "  order by resultkey" 

	cQuery2 := ChangeQuery(cQuery2)
	TCQuery cQuery2 New Alias "TRB3"
	cont++
	If !TRB3->(Eof())
		While !TRB3->(Eof())
			if cont = 2
				cBatchV := alltrim(str(Round( TRB3->value, 0 )))
				cVPerc := TRB3->value
			endif
			cont++
			TRB3->(DbSkip())
		Enddo
	EndIf

	TRB3->(DbCloseArea())

Return cBatchV

///////////////////// FUNÇÃO DE JOB DO SENSOR ANTES DO RAIO X ////////////////////
User function DTI146()
	Private _nTime    := 1500   //tempo em milissegundos usado para frear o loop
	Private _ncont    := 0
	cVPerc := 0
	/* Preparando Função automática*/
	RPCSetType(3) //não consome licença.
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "PCP" //TABLES "SA1", "SB1"

	_cIPSe01 := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxfilial('ZAM')+'SEN01',1))
	//_cIPEmb01 := alltrim(GetAdvFVal('ZAM',1,FWxfilial('ZAM')+'BEMB1','ZAM_IP'))

	//Criando conexão ethernet para sensor antes do RAIO X
	oObj  := tSocketClient():New()
	nResp := oObj:Connect(2111, ALLTRIM(_cIPSe01), 1000 )//_cIPSe01 = 10.6.20.20
	nResp := oObj:Send( 'Teste' )
	_cString := CaptIP()
	/* teste buscando dados da balança da Embalagem  */
	/*
	oObj  := tSocketClient():New()
	nResp := oObj:Connect(1703, _cIPEmb01, 1000 )//IP 10.0.0.227
	nResp := oObj:Send( 'Teste' )
	_cString := CaptIP()
	*/
	//return
	while .t.
		//sleep(_nTime+500)
		PrSEN('SEN01')
		//_ncont++
	enddo

	RESET ENVIRONMENT

return

//Função que vai fazer a pesagem das caixas via conexão socket (ethernet)
Static Function CaptIP()
	local _cString  := ''

	nQtd = oObj:Receive(_cString,500)

return _cString

/* Rotina de gravação da % de gordura automática*/
Static Function PrSEN(_sen)

	//Captura peso e código
	//1 _cString := CaptIP()
	/* Efetuar processo de captura de string */
	//Captura peso e código
	_cString := CaptIP()
	/*Por enquanto vou testar com string do parâmetro  SI_SERX	 */
	//_cString := '0'+GetMV('SI_SERX')

	//Verifica validação da leitura do codigo
	//_cString := '0'+alltrim(GetMV('SI_SERX'))

	if !Ler(_cString,_sen)//-------------------------Estou aqui
		return .f.
	else
		/* Se vai Gravar na SZ8 */
		Registro(_cString) //Função que realiza o registro da Gordura
	Endif

	//sleep(_nTime)

return .t.


Static Function Ler(_cString,_sen)
	//_cSeqsen := alltrim(substr(_cString,1,14))    //Sequencial da pré-etiqueta 02000027704534
	_cSeqsen := alltrim(substr(_cString,2,14))

	if empty(_cSeqsen)		
		return .f.
	endif

return .t.


Static Function Registro(_Strg)
	 /* Busca informações no banco do Raio X */
	CONECTR(_Strg)
Return .T.


Static Function CONECTR(_Stg)

	Private cDBPostgres  := "Postgres/PostgreSQL30"		// através do DBAccess
	Private cSrvPostgres := "10.0.10.4"					// através do DBAccess
	Private nPort 		 := 7890						// através do DBAccess
	Private nHndProtheus := AdvConnection()
	Private nHndPostgres
	Private cVq1 := ''
	Private cFamRX := ''
	Private cObjtkey :=space(20)
	cTabela := ''
	cEtqNread :=''
	_lok := 'F'

	//validar se vem informação primeiro
	if empty(_Stg)
		s := .t.
		Return s
	endif

	_c1 := substr(_Stg,2,2)		
	_c3 := substr(_Stg,7,9)

	_CSeqpE := alltrim(_c1)+'000'+alltrim(_c3)

	/*  Verificar em qual tabela foi gravado a caixa*/
	ZAS->(dbsetorder(10))
	SZ8->(dbsetorder(16))
	If SZ8->(Msseek(FWxfilial('SZ8')+alltrim(_CSeqpE)))
		cTabela := 'SZ8'
	elseif ZAS->(Msseek(FWxfilial('ZAS')+alltrim(_CSeqpE)))
		// No momento só temos duas tabelas de registro de estoque SZ8 e ZAS
		cTabela := 'ZAS'
	else
		cTabela := 'NAO'
	Endif

	//sleep(_nTime+1000)// fiquei aqui dia 03/02/22
	if cTabela = 'SZ8'
		// Só verifica se existe
		cCaixa := SZ8->Z8_CONTROL
		cFamRX := GetAdvFVal('SB1','B1_FAMRX',FWxfilial('SB1') + alltrim(SZ8->Z8_COD),1)
		cCodP := SZ8->Z8_COD
	elseif cTabela = 'ZAS'
		cCaixa := GetAdvFVal('ZAS','ZAS_CONTRO',FWxfilial('ZAS')+ alltrim(_CSeqpE),10)
		cCod := GetAdvFVal('ZAS','ZAS_COD',FWxfilial('ZAS') + alltrim(_CSeqpE),10)
		cFamRX := GetAdvFVal('SB1','B1_FAMRX',FWxfilial('SB1') + alltrim(cCod),1)
		cCodP := cCod
	Else
		_Stg := space(15)
		Return .f.
	endif
	/* Acionar o timer para tentar atrasar 2 segundos e ver se vai gravar o registro da ordem certa!!*/
	//sleep(1500) // um minuto e meio para tentar acertar o registro
	sleep(6000)
	/* Aguardar até o banco do Raio X Gravar o registro para após o Protheus Ler*/
	//sleep(10000) 

	// Cria uma nova conexão com um banco de dados SGBD através do DBAccess
	nHndPostgres := TcLink(cDBPostgres,cSrvPostgres,nPort)
	_cDtHoje := dtos(date())
	_cDtHoje := substr(_cDtHoje,1,4) + "-" + substr(_cDtHoje,5,2) + "-" + substr(_cDtHoje,7,2)

	If nHndPostgres < 0
		UserException("Erro (" + str(nHndPostgres,4) + ") ao conectar com " + cDBPostgres + " em " + cSrvPostgres)
	Else
        // Conexão com PostgreSQL
        TCSetConn(nHndPostgres)

		cQuery := "SELECT *"
		cQuery += "  FROM object" 		
		cQuery += " WHERE barcode = '" + substr(_Stg,2,14) + "'"
		cQuery += " and time between '" + _cDtHoje + " 00:00:00" + "' and '" + _cDtHoje + " 23:59:59" + "'"
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery New Alias "TRB1" //2022-02-10 23:59:59

		If !TRB1->(Eof())
			While !TRB1->(Eof())
				cObjtkey := str(TRB1->objectkey)
				varFat := Fquery2(TRB1->objectkey)
				// Imprimir a pré etiqueta de % e Gordura
				// cVPerc = Valor inteiro da porcentagem de carne  
				etqim(varFat,cObjtkey,cCaixa,cCodP,cVPerc,cTabela,_CSeqpE)

				TRB1->(DbSkip())
			Enddo
		else
			//TRB1->(DbCloseArea())
			//_lok = 'T'
		EndIf
		if _lok = 'F'
			TRB1->(DbCloseArea())
		endif
        // Fecha conexão com PostgreSQL
        TCUnLink(nHndPostgres)

        // Retorna conexão com Protheus
        TCSetConn(nHndProtheus)
	EndIf	
	_Stg := space(15)
	_lok := 'F'

Return .f.


Static Function RegEve1(_desc,_status,_resp,_cod,_string,_prod,_emb)
	// RegEve('Registro Efetivado na SZ8','OK','Inf.Gravada','30','RAIOX')
	_nID := ZA9->(RecCount()) + 1

	//ZA9->(DbSetOrder(1))
	dbselectarea("ZA9")
	reclock('ZA9',.t.)
		ZA9->ZA9_FILIAL := FWxfilial('ZA9')
		ZA9->ZA9_ID     := _nID
		ZA9->ZA9_DESC   := _desc
		ZA9->ZA9_DATA   := date()
		ZA9->ZA9_HORA   := time()
		ZA9->ZA9_STATUS := _status
		ZA9->ZA9_COD    := _cod
		ZA9->ZA9_RESP   := _resp
		ZA9->ZA9_STRING := _String
		ZA9->ZA9_PROD   := _prod
		ZA9->ZA9_EMB    := _emb
		ZA9->ZA9_PESOB  := 10
		ZA9->ZA9_TARA   := 0
	msunlock()
return


User function DTI147()

	//Private  _cGet1   := space(11)
	//Private  _cMemo   := ""
	//Private _oFont    := tFont():New("courier new",,-14,,.t.,,,,)
	Private _dGet2 := Date()
	_cData := DTOS(_dGet2)
	_cData := SUBSTR(_cData,7,2)+"/"+SUBSTR(_cData,5,2)+"/"+SUBSTR(_cData,1,4)

	/*DEFINE DIALOG oDlg TITLE "Preenchimento de % carne" FROM 180,180 TO 750,800 PIXEL

	_oMemo   := TMultiget():New(55,15,{|u|if(Pcount()>0,_cMemo:=u,_cMemo)},oDlg,280,130,_oFont,,,,,.T.,,,,,,.t.)

	_oSay1   := TSay():New(220,005, {|| 'Codigo da Caixa:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet1   := TGet():New(220,140, {|u| If(PCount() > 0, _cGet1:= u, _cGet1)}, oDlg,, 009, "@!",{||Leitura()}, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,, _cGet1,,,,.t.,)
	_oSay2   := TSay():New(235,005, {|| 'Data:'}, oDlg,, _oFont,,,, .T.,, CLR_WHITE, 200, 20)
	_oGet2   := TGet():New(235,025, {|u| If(PCount() > 0,_dGet2:=u,_dGet2)}, oDlg,, 009, "@D",, 0,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,,"_dGet2",,,,.t.,)

	_oBtn1 := TButton():New(255,210, "%.Carne"    , oDlg,{||preenche()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	_oBtn2 := TButton():New(255,260, "Sair"    , oDlg,{||oDlg:end()},40,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED*/

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00" MODULO "PCP"

	u_dtilog(cFilAnt, "DTI147", "Início Raio-X -> " + time(), "I")

	exec()
	putmv("SI_ULTDTRX",_cData+" "+time())

	u_dtilog(cFilAnt, "DTI147", "Fim Raio-X -> " + time(), "F")

	RESET ENVIRONMENT

Return


Static Function Leitura()
	Local _lRet := .f.

	//Se o campo estiver em branco
	if empty(_cGet1)
		_lRet := .t.
	else

		/*Verificar se caixa é Parda (SZ8) ou Branca (ZAS) - Fazer.....*/
		SZ8->(DbSetOrder(3))
		ZAS->(dbsetorder(1))
		If SZ8->(Msseek(FWxfilial('SZ8')+alltrim(_cGet1)))
			cTabela := 'SZ8'
		elseif ZAS->(Msseek(FWxfilial('ZAS')+alltrim(_cGet1)))
			// No momento só temos duas tabelas de registro de estoque SZ8 e ZAS
			cTabela := 'ZAS'
		else
			cTabela := 'NAO'
		Endif

		//Se o tamanho do codigo for menor que 10 digitos
		if len(alltrim(_cGet1)) < 10 
			_lRet := .f.
		else

				//SZ8->(DbSetOrder(3))
				if cTabela = 'ZAS'//!SZ8->(MsSeek(FWxfilial("SZ8")+alltrim(_cGet1)))
					//Help(" ",1,"ERRO",,"Caixa de PA não encontrada!",4,1)
					// mostrar ZAS
					complem(_cGet1,cTabela)	
					_cMemo :=  padc('[ PREENCHIMENTODE % CARNE CAIXA PORCIONADOS  ]',280,' ')	+ chr(13) + chr(10)
					_cMemo += Replicate("=",68) + chr(13) + chr(10)
					_cMemo += "Codigo Caixa:   " + ZAS->ZAS_CONTRO + chr(13) + chr(10)
					_cMemo += "Codigo Produto: " + ZAS->ZAS_COD + chr(13) + chr(10)
					_cMemo += "Descrição:      " + ZAS->ZAS_DESC + chr(13) + chr(10)
					_cMemo += "Data Produção:  " + dtoc(ZAS->ZAS_DTPROD) + chr(13) + chr(10)
					_cMemo += "Peso Bruto:     " + transform(ZAS->ZAS_PESOB,"@ 999.99") + chr(13) + chr(10)
					_cMemo += "Tara:           " + transform(ZAS->ZAS_TARA,"@ 9.999") + chr(13) + chr(10)
					_cMemo += "Peso Liquido:   " + transform(ZAS->ZAS_PESOL,"@ 999.99") + chr(13) + chr(10)
					_cMemo += "String :      " + ZAS->ZAS_STRRX + chr(13) + chr(10)
					_cMemo += "% Carne:           " + transform(ZAS->ZAS_PERCCX,"@ 999") + chr(13) + chr(10)
					_cMemo += Replicate("=",68) + chr(13) + chr(10)
					_oMemo:refresh()

				elseif cTabela = 'SZ8'
							complem(_cGet1,cTabela)	
							_cMemo :=  padc('[ PREENCHIMENTODE % CARNE CAIXA EMBALAGEM ]',280,' ')	+ chr(13) + chr(10)
							_cMemo += Replicate("=",68) + chr(13) + chr(10)
							_cMemo += "Codigo Caixa:   " + SZ8->Z8_CONTROL + chr(13) + chr(10)
							_cMemo += "Codigo Produto: " + SZ8->Z8_COD + chr(13) + chr(10)
							_cMemo += "Descrição:      " + SZ8->Z8_DESCRI + chr(13) + chr(10)
							_cMemo += "Data Produção:  " + dtoc(SZ8->Z8_DATAP) + chr(13) + chr(10)
							_cMemo += "Peso Bruto:     " + transform(SZ8->Z8_PESOBR,"@ 999.99") + chr(13) + chr(10)
							_cMemo += "Tara:           " + transform(SZ8->Z8_TARA,"@ 9.999") + chr(13) + chr(10)
							_cMemo += "Peso Liquido:   " + transform(SZ8->Z8_PESO,"@ 999.99") + chr(13) + chr(10)
							_cMemo += "String :      " + SZ8->Z8_STRRX + chr(13) + chr(10)
							_cMemo += "% Carne:           " + transform(SZ8->Z8_PERCRXN,"@ 999") + chr(13) + chr(10)
							_cMemo += Replicate("=",68) + chr(13) + chr(10)
							_oMemo:refresh()
				else
					Help(" ",1,"ERRO",,"-> Caixa  não encontrada! <-",4,1)
				endif	

		endif
	endif

return _lRet


Static Function complem(_cControl,cTAB)
	
	Private cDBPostgres  := "Postgres/PostgreSQL30"		// através do DBAccess
	Private cSrvPostgres := "10.0.10.4"					// através do DBAccess
	Private nPort 		 := 7890						// através do DBAccess
	Private nHndProtheus := AdvConnection()
	Private nHndPostgres
	Private cPerCar :=''
	Private cVP2 := 0

	//ZAS->(dbsetorder(1))
	//SZ8->(dbsetorder(3))
	If cTAB = 'SZ8'//SZ8->(Msseek(FWxfilial('SZ8')+alltrim(_cControl))) 
		_Stg := alltrim(SZ8->Z8_SEQPETQ)
		//cTabela := 'SZ8'
	Elseif cTAB = 'ZAS'//ZAS->(Msseek(FWxfilial('ZAS')+alltrim(_cControl)))
		_Stg := alltrim(ZAS->ZAS_SEQPET)
		//cTabela := 'ZAS'
	Endif

	_CSeqpE := _Stg

	// Cria uma nova conexão com um banco de dados SGBD através do DBAccess
	nHndPostgres := TcLink(cDBPostgres,cSrvPostgres,nPort)
	_cData := dtos(_dGet2)
	_cData := substr(_cData,1,4) + "-" + substr(_cData,5,2) + "-" + substr(_cData,7,2)

	If nHndPostgres < 0
		UserException("Erro (" + str(nHndPostgres,4) + ") ao conectar com " + cDBPostgres + " em " + cSrvPostgres)		
	Else
		TCSetConn(nHndPostgres)
		cQuery := "SELECT *"
		cQuery += "  FROM object" 
		cQuery += " WHERE barcode like '%"+substr(_CSeqpE,6,9)+"%'"
		cQuery += " and time between '" + _cData + " 00:00:00" + "' and '" + _cData + " 23:59:59" + "'"
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery New Alias "TRB9"

		If !TRB9->(Eof())
			While !TRB9->(Eof())
				cObjtkey := str(TRB9->objectkey)				
				varFat := Fq2(TRB9->objectkey)
				//etqim(varFat,cObjtkey,cCaixa,cCodP,cVPerc,cTabela,_CSeqpE)
				nVP3 := 100-cVP2
				nVP4 := Round( nVP3, 0 )

				if nVP4 > 0 .and. nVP4 < 70
					cPerCar := 'de 1 a 69 %'
				elseif nVP4 > 69 .and. nVP4 < 75
					cPerCar := 'de 70 a 74 %'
				elseif nVP4 > 74 .and. nVP4 < 80
					cPerCar := 'de 75 a 79 %'
				elseif nVP4 > 79 .and. nVP4 < 85
					cPerCar := 'de 80 a 84 %'
				elseif nVP4 > 84 .and. nVP4 < 101
					cPerCar := 'de 85 a 100 %'
				endif

				if cTabela = "SZ8"
					SZ8->(DbSetOrder(3))
					if SZ8->(MsSeek(FWxfilial('SZ8')+alltrim(_cControl)))
						reclock('SZ8',.f.)	
						//SZ8->Z8_PERCRXN := varFat
						SZ8->Z8_PERCRXN := nVP4
						SZ8->Z8_STRRX := "Raio X ID -> "+alltrim(cObjtkey)+" - Perc. Carne -> "+ cPerCar +"Caixa -> "+_cControl+" - hora-"+time()+' -Rot.DTI147'
						msunlock()
					Endif
				Elseif cTabela = "ZAS"
					ZAS->(DbSetOrder(1))
					if ZAS->(MsSeek(FWxfilial('ZAS')+alltrim(_cControl)))
						reclock('ZAS',.f.)
						ZAS->ZAS_PERCCX := nVP4
						ZAS->ZAS_STRRX := "Raio X ID -> "+alltrim(cObjtkey)+" - Perc. Carne -> "+ cPerCar +"Caixa -> "+_cControl+" - hora-"+time()+' -Rot.DTI147'
						msunlock()
					Endif
				endif
				TRB9->(DbSkip())

			Enddo
		else
		//	TRB9->(DbCloseArea())
		EndIf

		TRB9->(DbCloseArea())

	Endif

	_Stg := space(15)	
	// buscar valor select * FROM object where barcode like '%28140423%'
	// depois  - select * FROM result where objectkey = 227617

return     


Static Function FQ2(cBatchK)
	Local cont := 0
	Local cBatchV := space(5)
	// Esta buscando o id que esta gravado a porcentagem de gordura
	cQuery2 := "SELECT * "
	cQuery2 += "  FROM result" 
	cQuery2 += " WHERE objectkey =" + str(cBatchK )
	cQuery2 += "  order by resultkey" 
	cQuery2 := ChangeQuery(cQuery2)
	TCQuery cQuery2 New Alias "TRB3"
	cont++
	If !TRB3->(Eof())
		While !TRB3->(Eof())
			if cont = 2
				cBatchV := alltrim(str(Round( TRB3->value, 0 )))
				cVP2 := TRB3->value
			endif
			cont++
			TRB3->(DbSkip())
		Enddo
	EndIf

	TRB3->(DbCloseArea())

Return (cBatchV)


Static Function preenche()
		nSZ8:=0
		nZAS:=0
		exec()
		_cMemo :=  padc('[ RESULTADO GERAL DO PREENCHIMENTO  ]',280,' ')	+ chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)
		_cMemo += "-> Início do Processo <- "  + chr(13) + chr(10)
		_cMemo += "PREENCHIDO % de CARNE ATÉ O MOMENTO  : " + SUBSTR(DTOS(date()),7,2)+"/"+SUBSTR(DTOS(date()),5,2)+"/"+SUBSTR(DTOS(date()),3,2) + chr(13) + chr(10)
		_cMemo += "Alterados SZ8 Total :   	  " + transform(nSZ8,"@ 999,999") + chr(13) + chr(10)
		_cMemo += "Alterados ZAS Total :   	  " + transform(nZAS,"@ 999,999") + chr(13) + chr(10)
		_cMemo += Replicate("=",68) + chr(13) + chr(10)
		_oMemo:refresh()

return .T.


Static Function exec()
	Private cDBPostgres  := "Postgres/PostgreSQL30"		// através do DBAccess
	Private cSrvPostgres := "10.0.10.4"					// através do DBAccess
	Private nPort 		 := 7890						// através do DBAccess
	Private nHndProtheus := AdvConnection()
	Private nHndPostgres
	//Private cVP2 := 0
	Private cVP99 := 0
	Private nCont := 0
	Private _CSeqpE :=''
	Private _lOK := 'F'
	Private cTabela := "NAO"
	Private _c1 := ""
	Private _c3 := ""
	Private _cUltDt := alltrim(GetMV("SI_ULTDTRX"))
	contsz8 := 0
	contzas := 0
	//_cData := SUBSTR(DTOS(date()),1,4)+"-"+SUBSTR(DTOS(date()),5,2)+"-"+SUBSTR(DTOS(date()),7,2)
	//_cData := DTOS(_dGet2)
	//_cData := SUBSTR(_cData,1,4)+"-"+SUBSTR(_cData,5,2)+"-"+SUBSTR(_cData,7,2)

	/* Cria tabela temporária */
	//cArq  := CriaTrab( Nil, .F. )                          //temporario

	_aArqTrb := {}
	aStru := {}                                    //estrutura
	AADD(aStru,{"Z8_SQEPETQ"    ,"C",  14, 0})
	AADD(aStru,{"Z8_cObj"  	,"C",  15, 0})	
	AADD(aStru,{"Z8_PERCRXN"   	,"N",  10, 0}) 
	AADD(aStru,{"Z8_STRRX"  	,"C",  260, 0})	

	//dbcreate(cArq,aStru)
	//If Select('TMP')<>0	
	//	TMP->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )     //cria temp
	//Index On Z8_cObj To (cArq)

	If Select('TMP')<>0                               		// Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqtrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	nHndPostgres := TcLink(cDBPostgres,cSrvPostgres,nPort)
	If nHndPostgres < 0
		UserException("Erro (" + str(nHndPostgres,4) + ") ao conectar com " + cDBPostgres + " em " + cSrvPostgres)
	Else

		TCSetConn(nHndPostgres)
		cQuery3 := "SELECT *"
		cQuery3 += "  FROM object"
		//cQuery3 += " WHERE time between '"+_cData+' 00:00:00'+"' AND '"+_cData+' 23:59:59'+"'"
		cQuery3 += " WHERE time >= '"+_cUltDt+"'"
		cQuery3 += " AND barcode not like '%CL-Au%'"
		cQuery3 += " AND barcode not like '%NoRead%'"
		cQuery3 += " order by objectkey ASC"
		cQuery3 := ChangeQuery(cQuery3)
		TCQuery cQuery3 New Alias "TRB8"

		If !TRB8->(Eof())
			While !TRB8->(Eof())
				nCont++
				cObjtkey := str(TRB8->objectkey)
				varFat := Fq3(TRB8->objectkey)
				_c1 := alltrim(substr(TRB8->barcode,1,2))
				_c3 := alltrim(substr(TRB8->barcode,6,9))
				_CSeqpE := alltrim(_c1)+'000'+alltrim(_c3)
				//_CSeqpE := alltrim(substr(TRB8->barcode,1,9))
				/* Verificar se existe na SZ8 e ZAS*/
				// grava dados
				// Object-objectkey -  - seqet
				FQ4(cObjtkey,cVP99,_CSeqpE)
				TRB8->(DbSkip())
			Enddo
		EndIf

		TRB8->(DbCloseArea())

        TCUnLink(nHndPostgres)       
        TCSetConn(nHndProtheus)

	Endif

	// Só lendo a tabela temporária
	FQ99()

	nSZ8:= contsz8
	nZAS:= contzas

	contsz8 := 0
	contzas := 0

Return .T.


Static Function FQ3(cBatchK)
	Local cont := 0
	Local cBatchV := space(5)
	// Esta buscando o id que esta gravado a porcentagem de gordura
	cQuery5 := "SELECT * "
	cQuery5 += "  FROM result" 
	cQuery5 += " WHERE objectkey =" + str(cBatchK )
	cQuery5 += "  order by resultkey"

	cQuery5 := ChangeQuery(cQuery5)
	TCQuery cQuery5 New Alias "TRB7"
	cont++
	If !TRB7->(Eof())
		While !TRB7->(Eof())
			if cont = 2
				cBatchV := alltrim(str(Round( TRB7->value, 0 )))
				cVP99 := TRB7->value
			endif
			cont++
			TRB7->(DbSkip())
		Enddo
	else
		// Se não achou registro na tabela result grava zerado 
		cBatchV := '00'
		cVP99 := 500
	EndIf

	TRB7->(DbCloseArea())
	
Return (cBatchV)

/*  object Key        Seq.Etiqueta*/
Static Function FQ4(_nIDobjec,_N2,_SeqpE)
	cPerCar:= ''
	// rotina para salvar os dados na tabela temporária
	/*
	AADD(aStru,{"Z8_SQEPETQ"    ,"C",  14, 0})
	AADD(aStru,{"Z8_cObj"  	,"C",  15, 0})
	AADD(aStru,{"Z8_PERCRXN"   	,"N",  10, 0})
	AADD(aStru,{"Z8_STRRX"  	,"C",  260, 0})
	*/
	If _N2 = 500
		cPerCar :='Sem reg.na Result'
		nVP101 := 500
	else
		nVP100 := 100 - _N2
		nVP101 := Round( nVP100, 0 )
	Endif

	if nVP101 > 0 .and. nVP101 < 70
		cPerCar := 'de 1 a 69 %'
	elseif nVP101 > 69 .and. nVP101 < 75
		cPerCar := 'de 70 a 74 %'
	elseif nVP101 > 74 .and. nVP101 < 80
		cPerCar := 'de 75 a 79 %'
	elseif nVP101 > 79 .and. nVP101 < 85
		cPerCar := 'de 80 a 84 %'
	elseif nVP101 > 84 .and. nVP101 < 101
		cPerCar := 'de 85 a 100 %'
	endif

	DbSelectArea('TMP')
	Reclock('TMP',.t.)
		TMP->Z8_SQEPETQ  := _SeqpE
		TMP->Z8_cObj := _nIDobjec
		TMP->Z8_PERCRXN := nVP101
		TMP->Z8_STRRX    := "Raio X ID -> "+alltrim(_nIDobjec)+" - Perc. Carne -> "+ cPerCar +"SeqpEtq -> "+_SeqpE+" -hora-"+time()+'-Rot.exec'
	MsUnlock()

Return


Static Function FQ5()
	Local _cCaixa := ''
	// Rotina antiga....
	//  Rotina para grvar dados na SZ8 e ZAS
	//DbSelectArea('ZAS')
	//ZAS->(DbGoTop())
	//_teste:= '0053513377'
	DbSelectArea('SZ8')
	_cCaixa := GetAdvFVal('SZ8','Z8_SEQPETQ',FWxfilial('SZ8')+alltrim(_teste),3)
	//_nQTDAni := GetAdvFVal('SZG',1,FWxfilial('SZG')+VER1->ZK_NUMAM,'ZG_QTDTOT')
	if  !('CL000to' $ _CSeqpE)
		//conout('linha 780 - Seq. PETQ->'+_cCaixa)
	endif
	//SZ8->(DbSelectArea('SZ8'))
	//SZ8->(DbGoTop())
	//SZ8->(dbsetorder(16))
	SZ8->(dbsetorder(16))

	//ZAS->(dbsetorder(10))
	//If SZ8->(Msseek(FWxfilial('SZ8')+alltrim(_CSeqpE)))

	If SZ8->(Msseek(FWxfilial('SZ8')+alltrim(_CSeqpE)))
		_cSTRRX := alltrim(SZ8->Z8_STRRX)
		if !empty(_cSTRRX)
			TRB8->(DbSkip())
			_lOK := 'T'
		endif
		_cControl := SZ8->Z8_CONTROL
		cTabela := 'SZ8'
	elseif ZAS->(Msseek(FWxfilial('ZAS')+alltrim(_CSeqpE)))
		// No momento só temos duas tabelas de registro de estoque SZ8 e ZAS
		_cSTRRX := alltrim(ZAS->ZAS_STRRX)
		if !empty(_cSTRRX)
			TRB8->(DbSkip())
			_lOK := 'T'
		endif
		_cControl := ZAS->ZAS_CONTRO 
		cTabela := 'ZAS'
	else
		//sleep(1000)
		TRB8->(DbSkip())
		_lOK := 'T'
	Endif

	nVP100 := 100-cVP99
	nVP101 := Round( nVP100, 0 )

	if nVP101 > 0 .and. nVP101 < 70
		cPerCar := 'de 1 a 69 %'
	elseif nVP101 > 69 .and. nVP101 < 75
		cPerCar := 'de 70 a 74 %'
	elseif nVP101 > 74 .and. nVP101 < 80
		cPerCar := 'de 75 a 79 %'
	elseif nVP101 > 79 .and. nVP101 < 85
		cPerCar := 'de 80 a 84 %'
	elseif nVP101 > 84 .and. nVP101 < 101
		cPerCar := 'de 85 a 100 %'
	endif

	if cTabela = "SZ8"
			/*
			reclock('SZ8',.f.)
			SZ8->Z8_PERCRXN := nVP101
			SZ8->Z8_STRRX := "Raio X ID -> "+alltrim(cObjtkey)+" - Perc. Carne -> "+ cPerCar +"Caixa -> "+_cControl+" - hora-"+time()+' -Rot.exec'
			msunlock()
			*/
	Elseif cTabela = "ZAS"
			/*
			reclock('ZAS',.f.)	
			ZAS->ZAS_PERCCX := nVP101
			ZAS->ZAS_STRRX := "Raio X ID -> "+alltrim(cObjtkey)+" - Perc. Carne -> "+ cPerCar +"Caixa -> "+_cControl+" - hora-"+time()+' -Rot.DTI147'  					  					
			msunlock()
			*/
	endif

	SZ8->(dbCloseArea())
	ZAS->(dbCloseArea())

Return .t.


Static Function FQ99()
	local _lOK := 'F'
	Local nConts := 0
	contsz8 := 0
	contzas := 0
	dbSelectArea('TMP')
	TMP->(dbGotop())

	SZ8->(dbsetorder(16))
	SZ8->(dbGotop())
	ZAS->(dbsetorder(10))
	ZAS->(dbGotop())

	While TMP->(!Eof())
		nConts++
		_lOK := 'F'
		/*
		TMP->Z8_SQEPETQ  := _SeqpE
		TMP->Z8_cObj := _nIDobjec
		TMP->Z8_PERCRXN := nVP101
		TMP->Z8_STRRX   := "Raio X ID -> "+alltrim(_n
		*/                                 
		//if  !('CL000to' $ _CSeqpE) .or. !('No000d' $ _CSeqpE)

		If SZ8->(Msseek(FWxfilial('SZ8')+alltrim(TMP->Z8_SQEPETQ)))
			_cSTRRX := alltrim(SZ8->Z8_STRRX)
			if !empty(_cSTRRX)
				//TMP->(DbSkip())
				_lOK := 'T'
			endif
			//sleep(2000)
			/* Gravar só em registros não preenchidos Z8_STRRX
			e quando exisitir registro na tabela result (indicado pelo campo PERCRXN =500)
			*/
			if _lOK = 'F' .and. TMP->Z8_PERCRXN < 500
				reclock('SZ8',.f.)
				SZ8->Z8_PERCRXN := TMP->Z8_PERCRXN
				SZ8->Z8_STRRX := TMP->Z8_STRRX
				msunlock()
				contsz8++
			endif
		endif

		if ZAS->(Msseek(FWxfilial('ZAS')+alltrim(TMP->Z8_SQEPETQ)))
			// No momento só temos duas tabelas de registro de estoque SZ8 e ZAS
			_cSTRRX := alltrim(ZAS->ZAS_STRRX)
			if !empty(_cSTRRX)
				//TMP->(DbSkip())
				_lOK := 'T'
			endif
			//sleep(2000)
			/* Gravar só em registros não preenchidos Z8_STRRX 
			e quando exisitir registro na tabela result (indicado pelo campo PERCRXN =500)
			*/
			if _lOK = 'F' .and. TMP->Z8_PERCRXN < 500
				reclock('ZAS',.f.)
				ZAS->ZAS_PERCCX := TMP->Z8_PERCRXN
				ZAS->ZAS_STRRX := TMP->Z8_STRRX
				msunlock()
				contzas++
			Endif
		Endif

		TMP->(dbSkip())

	Enddo

return .t.
