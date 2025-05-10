#INCLUDE "Rwmake.ch"
#INCLUDE "Totvs.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³vtPorc03     º Autor ³Mauricio Roehrsº   Data ³  24/07/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ Consumo de materia-prima para receita de carne-moida.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Função para Inventario
User Function vtPorc03(_usuario)

	Private _cModelo  := ''
	Private _lOk      := .t.
	Private _lOpc     := .t.
	Private _cCod 	  := ''
	Private lin 	  := 1
	Private _cPar01   := '0'
	Private _UsrPar   := getmv('SI_USRMP')

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL14 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da Tela
	_cModelo = VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	geraTrab()

	VTClear()
	VTClearBuffer()

	//fazer aqui a tela para selecionar estorno ou consumo
	while _lOpc

		@ 01,05 VTSay "Consumo de MP P/ Moida"
		@ 03,05 VTSay "Parametros Iniciais:"
		@ 04,05 VTSay "1:Consome|8:Estorna"
		@ 05,05 VTSay "Opcao: [ ] 1:C|2:R|8:E"

		@ 05,13 VTGet _cPar01 Pict "@! "      valid (_cPar01 $ '1/2/8')

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		if _cPar01 = '1'      //Produção
			consome()
		elseif _cPar01 = '2'  //Retorno
			retorna()
		elseif _cPar01 = '8'  //Exclusão
			if (_usuario $ _UsrPar)
				estorna()
			else
				VTAlert('Usuario sem Permissao!','Aviso de Encerramento(02)',.T.,2000,1)
				exit
			endif
		endif

		VTClearBuffer()

	enddo

	//VTClear()
	VTClearBuffer()

Return

//função para realizar o consumo da materia prima
static function consome()

	VTClear()
	VTClearBuffer()

	aFields := {"COD","DESC"}
	aHeader := {"CODIGO","DESC"}
	aSize   := {06,25}

	dbselectarea('TRB')

	TRB->(dbgotop())

	//mostra o grid na tela
	nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"TRB",aHeader,aFields,aSize,"u_vtMoiBrw",)

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(11)

		listaItens(TRB->BATEL)

		VTRead

		@ 01,05 VTSay "Consumo p/ Carne Moida"
		@ lin+1,07 VTSay "Codigo da Caixa"
		@ lin+2,08 VTSay "[           ]"
		@ lin+2,09 VTGet _cCod Pict "@!" VALID leitura(TRB->BATEL)

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

return

//validação da leitura das caixas para consumo
Static Function leitura(_cBatel)

	local _cLote := ''

	//verifica itens antes da leitura
	listaItens(_cBatel)
	//filtra o lote para saber se a quantidade prevista ja foi atendida
	//filtraLotes(_cLote)
	filtraBatel(_cBatel)

	if empty(_cCod)
		return .t.
	endif

	if empty(_cBatel)
		return .t.
	endif

	ZG0->(dbSetOrder(1))
	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	if !ZAS->(MsSeek(FWxFilial('ZAS')+alltrim(_cCod)))
		mensagem('Caixa inexistente!','',2)
		return .t.
	else

		if !empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS)
			mensagem('Caixa fora de estoque!','',2)
			return .t.
		endif

		/*if empty(ZAS->ZAS_DTRMP) .and. !(ZAS->ZAS_TIPO $ 'QR/QF')
			mensagem('Nao foi feito recebim. da MP!','',2)
			return .t.
		endif*/

		if !empty(ZAS->ZAS_PREPOR) .and. !('MANUAL' $ alltrim(ZAS->ZAS_PREPOR))
			alert('Previsão Porcionados: ' + alltrim(ZAS->ZAS_PREPOR))
			mensagem('Caixa ja empenhada!','',2)
			return .t.
		endif

		if QRY->REAL >= QRY->PREV
			mensagem('Batelada já atendida!','',2)
			return .t.
		endif

		if !(ZAS->ZAS_TIPO $ "QR/QF/MP/SO")
			mensagem('Tipo de prod. nao permitido p/ moida','',2)
			return .t.
		endif

		TMP->(dbGoTop())
		while TMP->(!eof())
			if alltrim(ZAS->ZAS_COD) == alltrim(TMP->ZAV_COD)
				_cLote := TMP->ZAV_NUM
			elseif ZG0->(MsSeek(FWxFilial('ZG1')+alltrim(TMP->ZAV_COD)))
				_cLote := TMP->ZAV_NUM
			endif
			TMP->(dbSkip())
		enddo

		//se chegou até aqui efetiva o consumo
		produz(ZAS->ZAS_CONTRO,ZAS->ZAS_PESOL,_cLote,_cBatel,QRY->COD)
		mensagem(ZAS->ZAS_DESC, "CONSUMIDA!",1)

		//verifica itens após leitura
		listaItens(_cBatel)
	endif

return .t.

//função destinada a gravar as informações da caixa lida nas respectivas tabelas ao processo
Static Function produz(_caixa, _pesol, _cLote, _batel, _cod)

	//local _nSaldo := 0

	ZAV->(dbSetOrder(1))
	ZAV->(dbGoTop())
	if ZAV->(MsSeek(FWxFilial('ZAV') + alltrim(_cLote) + alltrim(_cod)))
		reclock('ZAV',.f.)
		ZAV->ZAV_QRPESO += _pesol
		if ZAV->ZAV_PREC == 'N'
			ZAV->ZAV_QPPESO += _pesol
		endif
		msunlock()
	endif

	ZAX->(dbSetOrder(1))
	ZAX->(dbGoTop())
	if ZAX->(MsSeek(FWxFilial('ZAX') + _batel)) .and. ZAV->ZAV_PREC <> 'N'
		reclock('ZAX',.f.)
		ZAX->ZAX_QTDMPC += _pesol
		if ZAX->ZAX_QTDMPC <> 0 .and. ZAX->ZAX_QTDMPC < ZAX->ZAX_QTDMP
			ZAX->ZAX_STATUS := 'R'
		elseif ZAX->ZAX_QTDMPC >= ZAX->ZAX_QTDMP
			ZAX->ZAX_STATUS := 'E'
		endif
		msunlock()
	endif

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	if ZAS->(MsSeek(FWxFilial('ZAS')+alltrim(_caixa)))//tira a caixa de estoque
		reclock('ZAS',.f.)
		ZAS->ZAS_DATAS := ddatabase
		ZAS->ZAS_HORAS := time()
		ZAS->ZAS_BATEL := _batel
		msunlock()

		u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Produz Carne Moída", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

	endif

return

//função para realizar o retorno da materia prima já consumida
static function retorna()

	nPesBr := 0
	nTara  := 0
	cImpRe := '1'

	VTClear()
	VTClearBuffer()

	aFields := {"COD","DESC"}
	aHeader := {"CODIGO","DESC"}
	aSize   := {06,25}

	dbselectarea('TRB')

	TRB->(dbgotop())

	//mostra o grid na tela
	nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"TRB",aHeader,aFields,aSize,"u_vtMoiBrw",)

	VTClear()
	VTClearBuffer()

	while _lOk

		cProx  := " "
		nPesBr := 0
		nTara  := 0

		listaItens(TRB->BATEL)

		@ 01,05 VTSay "Retorno p/ Carne Moida"
		@ lin+2,00 VTSay "Peso Bruto: ["+transform(nPesBr,'@E 999.99')+"]"
		@ lin+3,00 VTSay "Tara:       ["+transform(nTara,'@E 9.999')+"]"
		@ lin+4,00 VTSay "Impressora: [ ] 1:PUL|2:REF|3:PRI"
		@ lin+5,00 VTSay "Confirma?   [ ] (S)"

		@ lin+2,13 VTGet nPesBr Pict "@!" VALID nPesBr > 0
		@ lin+3,13 VTGet nTara  Pict "@!" VALID nTara > 0
		@ lin+4,13 VTGet cImpRe Pict "@!" VALID (cImpRe $ '123')
		@ lin+5,13 VTGet cProx  Pict "@!" VALID (cProx = 'S') .and. (leitRetor(TRB->BATEL,nPesBr,nTara,cImpRe))

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

return

//validação da leitura das caixas para estorno
Static Function leitRetor(_cBatel,nPesBr,nTara,cImpRe)

	Local _cLote := ''
	Local _cCodP := ''

	//verifica itens antes da leitura
	listaItens(_cBatel)
	//filtra o lote para saber se a quantidade prevista ja foi atendida
	filtraBatel(_cBatel)

	if empty(_cBatel)
		return .t.
	endif

	ZAX->(DbSetOrder(1))
	if !ZAX->(MsSeek(FWxfilial('ZAX')+_cBatel))
		mensagem('Batelada de produção não encontrada!','',2)
		return .f.
	elseif ZAX->ZAX_REC != 'S'
		mensagem('Batelada não é de carne moída!','',2)
		return .f.
	else
		_cCodP := CodSubGrupo(ZAX->ZAX_CODMP)
		if _cCodP = '000000'
			mensagem('Subgrupo sem código de RP associado!','',2)
			return .f.
		endif

		TMP->(dbGoTop())
		while TMP->(!eof())
			if alltrim(_cCodP) == alltrim(TMP->ZAV_COD)
				_cLote := TMP->ZAV_NUM
			endif
			TMP->(dbSkip())
		enddo

		//se chegou até aqui efetiva o retorno
		retornaCX(_cCodP,nPesBr,nTara,_cLote,_cBatel,cImpRe)
		mensagem(alltrim(ZAS->ZAS_DESC), " RETORNADA!",1)

		//verifica itens após leitura
		listaItens(ZAS->ZAS_BATEL)
	endif

return .t.

//função destinada a gravar as informações da caixa lida nas respectivas tabelas ao processo
Static Function retornaCX(_cod, _pesobr, _tara, _lote, _batel, _imp)

	SB1->(dbSetOrder(1))
	SB1->(dbGoTop())
	if SB1->(MsSeek(FWxFilial('SB1')+strzero(val(_cod),6)))//coloca a caixa em estoque
		_cID := GetSx8num('SZ8','Z8_ID')
		ConfirmSx8()
		_cContro := '00' + _cID

		reclock('ZAS',.t.)
		ZAS->ZAS_FILIAL  := FWxfilial('ZAS')
		ZAS->ZAS_CONTRO  := _cContro
		ZAS->ZAS_COD     := SB1->B1_COD
		ZAS->ZAS_DESC    := SB1->B1_DESC
		ZAS->ZAS_DTPROD  := ddatabase
		ZAS->ZAS_VALID   := SB1->B1_VALID
		ZAS->ZAS_PESOL   := (_pesobr - _tara)
		ZAS->ZAS_PESOB   := _pesobr
		ZAS->ZAS_TARA    := _tara
		ZAS->ZAS_PREEMB  := ''
		ZAS->ZAS_LOCAL   := '22'
		ZAS->ZAS_TIPO    := "RP"
		ZAS->ZAS_DESTIN  := "008"
		ZAS->ZAS_LOTE    := _lote
		ZAS->ZAS_TERC    := 'N'
		//ZAS->ZAS_DTABAT  := _dGet2
		ZAS->ZAS_BATEL   := _batel
		ZAS->ZAS_RPORIG  := _batel
		msunlock()

		u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Op.: Retorno de Produção", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))
	else
		mensagem('Código de produto inexistente!','',2)
		return .f.
	endif

	ZAV->(dbSetOrder(1))
	ZAV->(dbGoTop())
	if ZAV->(MsSeek(FWxFilial('ZAV') + alltrim(_lote) + alltrim(_cod)))
		reclock('ZAV',.f.)
		ZAV->ZAV_QRPESO -= (_pesobr - _tara)
		if ZAV->ZAV_PREC == 'N'
			ZAV->ZAV_QPPESO -= (_pesobr - _tara)
		endif
		msunlock()

		if ZAV->ZAV_PREC == 'N' .and. ZAV->ZAV_QRPESO <= 0
			reclock('ZAV',.f.)
			dbdelete()
			msunlock()
		endif
	endif

	ZAX->(dbSetOrder(1))
	ZAX->(dbGoTop())
	if ZAX->(MsSeek(FWxFilial('ZAX') + _batel))
		reclock('ZAX',.f.)
		ZAX->ZAX_QTDMPC -= (_pesobr - _tara)
		if ZAX->ZAX_QTDMPC <> 0 .and. ZAX->ZAX_QTDMPC < ZAX->ZAX_QTDMP
			ZAX->ZAX_STATUS := 'R'
		endif
		msunlock()
	endif

	Imprime(ZAS->ZAS_CONTRO,_imp)

return

//Função destinada a fazer a impressão de etiquetas
Static Function Imprime(_cContro, _cImp)
	Local _cIp  := ''
	Local _cEst := iif(_cImp = 1, 'POR01',iif(_cImp = 2, 'PAC02','PORC7')) //DEFINIR ESTAÇÕES

	ZAM->(dbSetOrder(1))
	if ZAM->(MsSeek(FWxFilial('ZAM') + alltrim(_cEst)))
		_cIp := alltrim(ZAM->ZAM_IP)
	endif
	u_DTI133('S600','IP',_cIp,_cContro)
return

//Função destinada a buscar o código de produto referente ao subgrupo em parâmetro
Static Function CodSubGrupo(_cSubGrupo)
	Local _cCod := ''

	Do Case
		Case _cSubGrupo = '0001'
			_cCod := '028685'
		Case _cSubGrupo = '0002'
			_cCod := '028686'
		Case _cSubGrupo = '0003'
			_cCod := '028687'
		Case _cSubGrupo = '0004'
			_cCod := '028688'
		Case _cSubGrupo = '0005'
			_cCod := '028689'
		Case _cSubGrupo = '0006'
			_cCod := '028690'
		Case _cSubGrupo = '0007'
			_cCod := '028691'
		Case _cSubGrupo = '0008'
			_cCod := '028693'
		Case _cSubGrupo = '0009'
			_cCod := '028692'
		Case _cSubGrupo = '0010'
			_cCod := '028695'
		Case _cSubGrupo = '0011'
			_cCod := '028696'
		Case _cSubGrupo = '0012'
			_cCod := '028697'
		Case _cSubGrupo = '0013'
			_cCod := '028694'
		Case _cSubGrupo = '0014'
			_cCod := '028698'
		Otherwise
			_cCod := '000000'
	EndCase
Return _cCod

//função para realizar o estorno da materia prima já consumida
static function estorna()

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(11)

		@ 01,05 VTSay "Estorno p/ Carne Moida"
		@ lin+1,07 VTSay "Codigo da Caixa"
		@ lin+2,08 VTSay "[           ]"
		@ lin+2,09 VTGet _cCod Pict "@!" VALID leitStorn(_cCod)

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

return

//validação da leitura das caixas para estorno
Static Function leitStorn(_cCod)

	if empty(_cCod)
		return .t.
	endif

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	if !ZAS->(MsSeek(FWxFilial('ZAS')+alltrim(_cCod)))
		mensagem('Caixa inexistente!','',2)
		return .t.
	else
		if empty(ZAS->ZAS_BATEL)
			mensagem('Caixa não foi consumida!','',2)
			return .t.
		else
			ZAX->(DbSetOrder(1))
			ZAX->(MsSeek(FWxfilial('ZAX') + alltrim(ZAS->ZAS_BATEL)))
		endif

		if empty(ZAS->ZAS_DATAS) .or. empty(ZAS->ZAS_HORAS)
			mensagem('Caixa já se encontra fora de estoque!','',2)
			return .t.
		endif

		if alltrim(ZAS->ZAS_DTPROD) != alltrim(ZAX->ZAX_DTPROD)
			mensagem('MP diverge da batelada','',2)
			return .t.
		endif

		/*if empty(ZAS->ZAS_DTRMP)
			mensagem('Nao foi feito recebim. da MP!','',2)
			return .t.
		endif*/

		if ZAS->ZAS_BATEL <> ZAX->ZAX_NUM
			mensagem('Cx. n/ pertence a batelada!','',2)
			return .t.
		endif

		if !(ZAS->ZAS_TIPO $ "QR/QF/MP/SO")
			mensagem('Tipo de prod. nao permitido p/ moida','',2)
			return .t.
		endif

		//se chegou até aqui efetiva o consumo
		estornaCX(ZAS->ZAS_CONTRO, ZAS->ZAS_PESOL, ZAS->ZAS_LOTE,ZAS->ZAS_BATEL,QRY->COD)
		mensagem(alltrim(ZAS->ZAS_DESC), "ESTORNADA!",1)

		//verifica itens após leitura
		listaItens(ZAS->ZAS_BATEL)
	endif

return .t.

//função destinada a gravar as informações da caixa lida nas respectivas tabelas ao processo
Static Function estornaCX(_caixa, _pesol, _lote, _batel, _cod)

	ZAV->(dbSetOrder(1))
	ZAV->(dbGoTop())
	if ZAV->(MsSeek(FWxFilial('ZAV') + alltrim(_lote) + alltrim(_cod)))
		reclock('ZAV',.f.)
		ZAV->ZAV_QRPESO -= _pesol
		if ZAV->ZAV_PREC == 'N'
			ZAV->ZAV_QPPESO -= _pesol
		endif
		msunlock()

		if ZAV->ZAV_PREC == 'N' .and. ZAV->ZAV_QRPESO <= 0
			reclock('ZAV',.f.)
			dbdelete()
			msunlock()
		endif

		ZAX->(dbSetOrder(1))
		ZAX->(dbGoTop())
		if ZAX->(MsSeek(FWxFilial('ZAX') +  alltrim(ZAV->ZAV_BATEL))) .and. ZAV->ZAV_PREC <> 'N'
			reclock('ZAX',.f.)
			ZAX->ZAX_QTDMPC -= _pesol
			if ZAX->ZAX_QTDMPC <> 0 .and. ZAX->ZAX_QTDMPC < ZAX->ZAX_QTDMP
				ZAX->ZAX_STATUS := 'R'
			endif
			msunlock()
		endif
	endif

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	if ZAS->(MsSeek(FWxFilial('ZAS')+alltrim(_caixa)))//coloca a caixa em estoque
		reclock('ZAS',.f.)
		ZAS->ZAS_DATAS := stod('')
		ZAS->ZAS_HORAS := ''
		ZAS->ZAS_LOTE  := ''
		ZAS->ZAS_BATEL := ''
		msunlock()

		u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Estorna Caixa Carne Moída", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

	endif

return

//função destinada a gerar os itens que o operador deve consumir do lote selecionado
Static Function listaItens(_cBatel)

	limpaItens()

	lin := 1
	_nNumItens := 8

	_cQuery := " SELECT ZAV_NUM, ZAV_COD, ZAV_QPPESO, ZAV_QRPESO"
	_cQuery += " FROM " + retSqlTab('ZAV')
	_cQuery += " WHERE " + retSqlFil('ZAV')
	_cQuery += " AND ZAV_BATEL = '" + _cBatel + "'"
	_cQuery += " AND " + retSqlDel('ZAV')
	_cQuery += " ORDER BY ZAV_NUM"

	_cQuery := ChangeQuery(_cQuery)

	if select("TMP") != 0
		TMP->(dbCloseArea())
	endif

	TCQUERY _cQuery NEW ALIAS "TMP"

	TMP->(dbGoTop())

	while TMP->(!eof())

		if lin > _nNumItens
			TMP->(DbSkip())
			loop
		endif

		@ 01+lin,05 VTSay alltrim(TMP->ZAV_COD) + "|" +;
		transform(TMP->ZAV_QPPESO,'@E 9,999.99') + "|" +;
		transform(TMP->ZAV_QRPESO,'@E 9,999.99')

		TMP->(dbSkip())
		lin++
	enddo
return

Static Function limpaItens()
	Local i
	for i:=1 to lin
		@ 01+i,01 VTSay space(50)
	next

return

User Function vtMoiBrw(modo)
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,100,1)
		_lOk := .f.
		return 0
	elseif VTLastkey()==13
		return 1
	endif
return

//função para gerar o ambiente de trabalho
Static Function geraTRAB()

	//Local _cGrpMoi := getMv('SI_GRPMOI')

	cArq  := CriaTrab( Nil, .F. )

	aStru := {}
	AADD(aStru,{"BATEL"  		,"C" 	,10 	,0	})
	AADD(aStru,{"COD"	  		,"C"	,6  	,0  })
	AADD(aStru,{"DESC"  		,"C"	,40		,0	})
	AADD(aStru,{"PREVISTO"      ,"N"	,9  	,2	})
	AADD(aStru,{"REALIZADO"     ,"N"	,9  	,2	})

	dbcreate(cArq,aStru)
	If Select('TRB')<>0
		TRB->(dbCloseArea())
	Endif
	dbUseArea( .T.,,cArq,"TRB", .F. , .F. )

	//_aArqTrb := {}
	//If Select('TRB')<>0                                  //Se um tmp com alias TMP existir, fecha-o
	//	TRB->(dbCloseArea())
	//	u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	//Endif

	//U_ArqTrb("Cria", "TRB", aStru, {}, @_aArqTrb)

	//filtraLotes('')
	filtraBatel('')

	QRY->(dbGoTop())
	while QRY->(!eof())
		if QRY->REAL >= QRY->PREV
			QRY->(dbSkip())
			loop
		endif

		//verifica se não for do grupo de moida cai fora
		/*_cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+QRY->COD,1)
		if !(_cGrupo $ _cGrpMoi)
			QRY->(dbSkip())
			loop
		endif*/

		reclock('TRB',.t.)
		TRB->BATEL	   := QRY->BATEL
		TRB->COD  	   := QRY->COD
		TRB->DESC	   := QRY->DESCRI
		TRB->PREVISTO  := QRY->PREV
		TRB->REALIZADO := QRY->REAL
		msunlock()

		QRY->(dbSkip())
	enddo

	aCampos := {}

	AADD(aCampos,{"BATEL"		,, "Batelada"		,"@!"   		})
	AADD(aCampos,{"COD"       	,, "Codigo"   		,"@!"   		})
	AADD(aCampos,{"DESC"      	,, "Descricao"		,"@!"   		})
	AADD(aCampos,{"PREVISO"		,, "Previsto" 		,"@E999,999.99" })
	AADD(aCampos,{"REALIZADO"	,, "Realizado"		,"@E999,999.99" })

return

// função para filtrar as bateladas para o ambiente de trabalho
Static Function filtraBatel(_cBatel)

	_cQuery := " SELECT ZAX_NUM AS BATEL, ZAX_CODMP AS COD, ZAX_DESCRI AS DESCRI, ZAX_QTDMP AS PREV, ZAX_QTDMPC AS REAL"
	_cQuery += " FROM " + retSqlTab('ZAX')
	_cQuery += " WHERE " + retSqlFil('ZAX')
	_cQuery += " AND ZAX_DTPROD = '" + dtos(ddatabase) + "'"
	if !empty(_cBatel)
		_cQuery += " AND ZAX_NUM = '" + _cBatel + "'"
	endif
	_cQuery += " AND ZAX_REC = 'S'"
	_cQuery += " AND " + retSqlDel('ZAX')
	_cQuery += " ORDER BY ZAX_NUM"

	_cQuery  := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

return .f.

//função para filtrar os lotes para o ambiente de trabalho.
Static Function filtraLotes(_cLote)

	_cLista := getMv('SI_MPPORC')

	_cQuery := " SELECT ZAU_NUM AS LOTE, ZAU_COD AS COD, ZAU_DESC AS DESCRI, ZAU_QPPESO AS PREV, SUM(ZAV_QRPESO) AS REAL
	_cQuery += " FROM  " + retSqlTab('ZAU') + ", " + retSqlTab('ZAV')
	_cQuery += " WHERE " + retSqlFil('ZAU') + " AND " + retSqlFil('ZAV')
	_cQuery += " AND ZAU_NUM = ZAV_NUM"
	_cQuery += " AND ZAU_DTPROD = '" + dtos(ddatabase) + "'"

	if alltrim(_cLista) == 'S'
		_cQuery += " AND ZAU_STATF = 'R'"
	endif

	if !empty(_cLote)
		_cQuery += " AND ZAU_NUM = '" + _cLote + "'"
	endif

	_cQuery += " AND ZAU_STATF <> 'E'
	_cQuery += " AND " + retSqlDel('ZAU') + " AND " + retSqlDel('ZAV')
	_cQuery += " GROUP BY ZAU_NUM, ZAU_QPPESO, ZAU_COD, ZAU_DESC
	_cQuery += " ORDER BY ZAU_NUM"

	_cQuery  := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

return .f.

//função destinada para mensagens durante o processo
Static Function mensagem(_cMens,_cMens2,_nBeep)

	Local _branco := space(50)

	VTBeep(_nBeep)
	@lin+1,00 VTSay _branco
	@lin+2,00 VTSay _branco
	@lin+3,00 VTSay _branco
	@lin+4,00 VTSay _branco
	@lin+5,00 VTSay _branco
	@lin+6,00 VTSay _branco
	@lin+7,00 VTSay _branco
	@lin+8,00 VTSay _branco

	@lin+3,11 VTSay _cCod
	@lin+4,03 VTSay _cMens
	@lin+5,03 VtSay _cMens2

	_cCod := Space(11)

return .f.

