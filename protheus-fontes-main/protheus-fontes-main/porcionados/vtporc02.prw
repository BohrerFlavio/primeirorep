#INCLUDE "Rwmake.ch"
#INCLUDE "Totvs.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³vtPorc02     º Autor ³Mauricio Roehrsº   Data ³  29/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ Consumo de materia-prima para porcionados.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function vtPorc02(_usuario)

	Private _cModelo  	:= ''
	Private _lOk      	:= .t.
	Private _lOpc     	:= .t.
	Private _cCod 	  	:= ''
	Private _cPar01   	:= '0'
	Private lin 	  	:= 1
	Private _nSomaPeso  := 0
	Private _UsrPar  	:= getmv('SI_USRMP')

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL13 <> 'S'
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

	geraTrab()

	VTClear()
	VTClearBuffer()

	//fazer aqui a tela para selecionar estorno ou consumo
	while _lOpc

		@ 01,05 VTSay "Consumo de MP"
		@ 03,05 VTSay "Parametros Iniciais:"
		@ 04,05 VTSay "1:Consome MP|8:Estorna"
		@ 06,05 VTSay "Opcao: [ ] 1:C|8:E"

		@ 06,13 VTGet _cPar01 Pict "@! "      valid (_cPar01 $ '1/8')

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,1000,1)
			exit
		EndIF

		if _cPar01 = '1'      //Produção MP
			consome()
		elseif _cPar01 = '8'  //Estorno
			if (_usuario $ _UsrPar)
				estorna()
			else
				VTAlert('Usuario sem Permissao!','Aviso de Encerramento(02)',.T.,2000,1)
				exit
			endif
		endif

		VTClearBuffer()

	enddo

	VTClear()
	VTClearBuffer()

Return

static function consome()

	aFields := {"COD","DESCRI"}
	aHeader := {"CODIGO","DESCRI"}
	aSize   := {06,25}

	dbselectarea('TMP')

	TMP->(dbgotop())

	//mostra o grid na tela
	nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"TMP",aHeader,aFields,aSize,"u_vtMPBrw",)

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(11)

		//VTRead

		@ 01,05 VTSay "Consumo de Materia-Prima"
		@ lin+1,07 VTSay "Codigo da Caixa"
		@ lin+2,08 VTSay "[           ]"
		@ lin+3,05 VTSay "Peso Consumido:"

		_nPesCons := buscaPeso(TMP->BATEL)

		@ lin+3,21 VTSay transform(_nPesCons,'@E 9,999.99')
		@ lin+2,09 VTGet _cCod Pict "@!" VALID leitura(TMP->BATEL,_cCod)

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,1000,1)
			exit
		EndIF

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

return


Static Function leitura(_Batel,_cod)

	local _lProd := .f.
	//Local _cGrpMoi := getMv('SI_GRPMOI')

	if empty(_cod)
		return .t.
	endif
	ZAX->(DbSetOrder(1))
	ZAX->(MsSeek(FWxfilial('ZAX') + alltrim(_Batel)))

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())

	if !ZAS->(MsSeek(FWxFilial('ZAS')+_cod))
		mensagem('Caixa inexistente!','',2)
		return .t.
	else

		if !empty(ZAS->ZAS_DATAS) .or. !empty(ZAS->ZAS_HORAS)
			mensagem('Caixa fora de estoque!','',2)
			return .t.
		endif

		/*if empty(ZAS->ZAS_DTRMP)
			mensagem('Nao foi feito recebim. da MP!','',2)
			return .t.
		endif*/

		if !empty(ZAS->ZAS_DTBLOQ)
			mensagem('Caixa bloqueada para consumo. Somente com autorização do PCP!','',2)
			return .t.
		endif

		/*_cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+_cod,1)
		if (_cGrupo $ _cGrpMoi)
			mensagem('Erro, prod. pertence ao grp. de moida!','',2)
			return .t.
		endif*/

		//valida produto alternativo
		if !U_Obit08(ZAX->ZAX_CODMP, ZAS->ZAS_COD)
			mensagem("Não há relação do produto "+ALLTRIM(ZAS->ZAS_COD)+" c/ produto da batelada "+ALLTRIM(ZAX->ZAX_CODMP)+"!",'',2)
			Return .F.
		endif

		_lProd := .t.

		if (_lProd)
			produz(_cod, ZAS->ZAS_PESOL, _Batel)
			mensagem("MP: " + ZAS->ZAS_DESC, "CONSUMIDA!",1)
		else
			mensagem("Nao ha producao p/ este prod.",'',2)
		endif

	endif

return .t.

//produzir a caixa
Static Function produz(_cod, _pesol, _batel)

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	if ZAS->(MsSeek(FWxFilial('ZAS')+_cod))
		reclock('ZAS',.f.)
		ZAS->ZAS_DATAS  := ddatabase
		ZAS->ZAS_HORAS  := time()
		ZAS->ZAS_BATEL  := _batel
		msunlock()

		u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Consumo Caixa", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

		//incrementa a quantidade de peso na batelada
		ZAX->(DbSetOrder(1))
		ZAX->(dbGoTop())
		if ZAX->(MsSeek(FWxFilial('ZAX') + _batel))
			reclock('ZAX',.f.)
			ZAX->ZAX_QTDMPC += _pesol
			if ZAX->ZAX_QTDMPC <> 0 .and. ZAX->ZAX_QTDMPC < ZAX->ZAX_QTDMP
				ZAX->ZAX_STATUS := 'R'
			elseif ZAX->ZAX_QTDMPC >= ZAX->ZAX_QTDMP
				ZAX->ZAX_STATUS := 'E'
			endif
			msunlock()
		endif

		@ lin+3,21 VTSay transform(ZAX->ZAX_QTDMPC,'@E 9,999.99')
	endif

return

//função para realizar o estorno da materia prima já consumida
static function estorna()

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(11)

		@ 01,05 VTSay "Estorno de Materia-Prima"
		@ lin+1,07 VTSay "Codigo da Caixa"
		@ lin+2,08 VTSay "[           ]"
		@ lin+2,09 VTGet _cCod Pict "@!" VALID leitStorn(_cCod)//validação da leitura para estorno

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

Static Function leitStorn(_cod)//validação da leitura para estorno

	if empty(_cod)
		return .t.
	endif

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	if !ZAS->(MsSeek(FWxFilial('ZAS')+alltrim(_cod)))
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

		if  ZAX->ZAX_NUM <> ZAS->ZAS_BATEL
			mensagem('Cx. n/ pertence a batelada!','',2)
			return .t.
		endif

		if alltrim(ZAS->ZAS_COD) == alltrim(ZAX->ZAX_CODMP)
			_lEst := .t.
		else
			mensagem('MP diverge da batelada','',2)
			return .t.
		endif

		if (_lEst)
			estornaCx(_cod, ZAS->ZAS_PESOL, ZAS->ZAS_BATEL)
			mensagem("MP: " + alltrim(ZAS->ZAS_DESC) + " ESTORNADA!", transform(buscaPeso(ZAS->ZAS_BATEL),'@E 9,999.99'),1)
		else
			mensagem("Nao ha producao p/ este prod.",'',2)
		endif

	endif

return .t.

//função para estornar a caixa consumida
Static Function estornaCx(_cod, _pesol, _batel)

	ZAS->(dbSetOrder(1))
	ZAS->(dbGoTop())
	if ZAS->(MsSeek(FWxFilial('ZAS')+_cod))
		reclock('ZAS',.f.)
		ZAS->ZAS_DATAS  := stod('')
		ZAS->ZAS_HORAS  := ''
		ZAS->ZAS_BATEL  := ''
		msunlock()

		u_obit02(ZAS->ZAS_CONTRO, retCodUsr(), ZAS->ZAS_LOCAL, ZAS->ZAS_LOCALI, "Estorna Caixa Consumida", ZAS->ZAS_PALLET, "ZAS", alltrim(FUNNAME()))

		//incrementa a quantidade de peso na batelada
		ZAX->(DbSetOrder(1))
		ZAX->(dbGoTop())
		if ZAX->(MsSeek(FWxFilial('ZAX') + _batel))
			reclock('ZAX',.f.)
			ZAX->ZAX_QTDMPC -= _pesol
			if ZAX->ZAX_QTDMPC <> 0 .and. ZAX->ZAX_QTDMPC < ZAX->ZAX_QTDMP
				ZAX->ZAX_STATUS := 'R'
			endif
			msunlock()
		endif

		@ lin+3,21 VTSay transform(ZAX->ZAX_QTDMPC,'@E 9,999.99')
	endif

return

static function buscaPeso(_Batel)

	local _nPeso := 0

	ZAX->(DbSetOrder(1))
	if ZAX->(MsSeek(FWxfilial('ZAX') + alltrim(_Batel)))
		_npeso := ZAX->ZAX_QTDMPC
	endif

return _npeso

Static Function mensagem(_cMens,_cMens2,_nBeep)

	Local _branco := space(50)

	VTBeep(_nBeep)
	@lin+4,00  VTSay _branco
	@lin+5,00  VTSay _branco
	@lin+6,00  VTSay _branco
	@lin+7,00  VTSay _branco
	@lin+8,00  VTSay _branco
	@lin+9,00  VTSay _branco
	@lin+10,00 VTSay _branco
	@lin+11,00 VTSay _branco

	@lin+4,11  VTSay _cCod
	@lin+5,03  VTSay _cMens
	@lin+6,03  VtSay _cMens2

	_cCod := Space(11)

return .f.

//função para gerar o ambiente de trabalho
Static Function geraTRAB()

	//Local _cGrpMoi := getMv('SI_GRPMOI')

	//cArq  := CriaTrab( Nil, .F. )

	aStru := {}
	AADD(aStru,{"BATEL"  ,"C"	,10   ,0	})
	AADD(aStru,{"COD"  ,"C"	,6	   ,0	})
	AADD(aStru,{"DESCRI" ,"C"	,40	,0	})

	//dbcreate(cArq,aStru)
	//If Select('TMP')<>0
	//	TMP->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq,"TMP", .F. , .F. )

	_aArqTrb :={}
	If Select('TMP')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TMP->(dbCloseArea())
		u_arqTrb("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TMP", aStru, {}, @_aArqTrb)

	filtraBatel()

	QRY->(dbGoTop())
	while QRY->(!eof())
		/*_cGrupo := GetAdvFval('SB1','B1_GRUPO',FWxfilial('SB1')+QRY->COD,1)
		if (_cGrupo $ _cGrpMoi)
			QRY->(dbSkip())
			loop
		endif*/
		DbSelectArea('TMP')
		reclock('TMP',.t.)
		TMP->BATEL	:= QRY->BATEL
		TMP->COD    := QRY->COD
		TMP->DESCRI	:= QRY->DESCRI
		msunlock()

		QRY->(dbSkip())
	enddo

	aCampos := {}

	AADD(aCampos,{"BATEL"  	,, "Lote"			,"@!"   			})
	AADD(aCampos,{"COD" 	,, "MP"	    		,"@!"   			})
	AADD(aCampos,{"DESCRI"	,, "Descricao"		,"@!"   			})

return

//função para filtrar os lotes para o ambiente de trabalho.
Static Function filtraBatel()

	_cQuery := " SELECT ZAX_NUM AS BATEL, ZAX_DESCRI AS DESCRI, ZAX_CODMP AS COD"
	_cQuery += " FROM  " + retSqlTab('ZAX')
	_cQuery += " WHERE " + retSqlFil('ZAX')
	_cQuery += " AND ZAX_DTPROD = '" + dtos(ddatabase) + "'"
	_cQuery += " AND ZAX_REC = 'N'"
	_cQuery += " AND " + retSqlDel('ZAX')
	_cQuery += " ORDER BY ZAX_NUM"

	_cQuery  := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

return .f.

User Function vtMPBrw(modo)
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,100,1)
		_lOk := .f.
		return 0
	elseif VTLastkey()==13
		return 1
	endif
return
