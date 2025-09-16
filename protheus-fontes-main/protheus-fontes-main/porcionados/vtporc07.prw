#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³vtPorc07  º Autor ³Flavio Bohrer Flores  Data ³  06/09/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ Consumo de PA para porcionados.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function vtPorc07(_usuario)

	Private _cModelo  	:= ''
	Private _lOk      	:= .t.
	Private _lOpc     	:= .t.
	Private _cCod 	  	:= ''
	Private _cPar01   	:= '0'
	Private lin 	  	:= 1
	Private _nSomaPeso  := 0
	Private _UsrPar  	:= getmv('SI_USRMP')

	ZAA->(DbSetOrder(2))
	ZAA->(DbSeek(xfilial('ZAA')+_usuario))
	if ZAA->ZAA_APL26 <> 'S'
	//if ZAA->ZAA_APL25 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da Tela.
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

		@ 01,05 VTSay "Consumo de PA"
		@ 03,05 VTSay "Parametros Iniciais:"		
		@ 04,05 VTSay "1:Consome PA|8:Estorna"
		@ 06,05 VTSay "Opcao: [ ] 1:C|8:E"

		@ 06,13 VTGet _cPar01 Pict "@! "      valid (_cPar01 $ '1/8')

		VTRead
		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,1000,1)
			exit
		EndIF
		if _cPar01 = '1'      //Produção PA
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

	aFields := {"BATEL","CODMP","DESCRI"}
	aHeader := {"BATEL","CODIGO","DESCRI"}
	aSize   := {15,06,10}

	dbselectarea('TRB')

	TRB->(dbgotop())

	//mostra o grid na tela
	nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"TRB",aHeader,aFields,aSize,"u_vtMPBrw",)

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(11)

		//VTRead

		@ 01,05 VTSay "Consumo de Produto Acabado"
		@ lin+1,07 VTSay "Codigo da Caixa"
		@ lin+2,08 VTSay "[           ]"
		@ lin+3,05 VTSay "Peso Consumido:"

		_nPesCons := buscaPeso(TRB->BATEL)

		@ lin+3,21 VTSay transform(_nPesCons,'@E 9,999.99')
		@ lin+2,09 VTGet _cCod Pict "@!" VALID leitura(TRB->BATEL,_cCod)

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

static function estorna()

	aFields := {"BATEL","CODMP","DESCRI"}
	aHeader := {"BATEL","CODIGO","DESCRI"}
	aSize   := {15,06,10}

	dbselectarea('TRB')

	TRB->(dbgotop())

	//mostra o grid na tela
	nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"TRB",aHeader,aFields,aSize,"u_vtMPBr2",)

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(11)

	
		@ 01,05 VTSay "Estorno de Produto Acabado"
		@ lin+1,07 VTSay "Codigo da Caixa"
		@ lin+2,08 VTSay "[           ]"
		@ lin+3,05 VTSay "Peso Consumido:"

		_nPesCons := buscaPeso(TRB->BATEL)

		@ lin+3,21 VTSay transform(_nPesCons,'@E 9,999.99')
		@ lin+2,09 VTGet _cCod Pict "@!" VALID leitStorn(TRB->BATEL,_cCod)

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

Static Function leitStorn(_Batel,_cod)//validação da leitura para estorno

	
	if empty(_cod)
		return .t.
	endif

	ZAX->(DbSetOrder(1))
	ZAX->(DbSeek(xfilial('ZAX') + alltrim(_Batel)))

	SZ8->(dbSetOrder(3))
	SZ8->(dbGoTop())
	
	if !SZ8->(dbSeek(xFilial('SZ8')+_cod))
		mensagem('Caixa inexistente!','',2)
		return .t.
	else
		if empty(SZ8->Z8_DATAS) .or. empty(SZ8->Z8_HORAS)
			mensagem('Caixa já se encontra estoque!','',2)
			return .t.
		endif
			
		estornaCx(_cod, SZ8->Z8_PESO, _Batel)
		mensagem("PA: " + SZ8->Z8_DESCRI, "ESTORNADA!",1)
	
	endif

return .t.

static function buscaPeso(_Batel)

	local _nPeso := 0

	ZAX->(DbSetOrder(1))
	if ZAX->(DbSeek(xfilial('ZAX') + alltrim(_Batel)))
		_npeso := ZAX->ZAX_QTDMPC
	endif

return _npeso
				//Batelada - control da caixa
Static Function leitura(_Batel,_cod)
					
	if empty(_cod)
		return .t.
	endif
	ZAX->(DbSetOrder(1))
	ZAX->(DbSeek(xfilial('ZAX') + alltrim(_Batel)))

	SZ8->(dbSetOrder(3))
	SZ8->(dbGoTop())
	if !SZ8->(dbSeek(xFilial('SZ8')+_cod))
		mensagem('Caixa inexistente!','',2)
		return .t.
	else		
		
		if !empty(SZ8->Z8_DATAS) .or. !empty(SZ8->Z8_HORAS)
			mensagem('Caixa fora de estoque!','',2)
			return .t.
		endif
		
		produz(_cod, SZ8->Z8_PESO, _Batel)
		mensagem("PA: " + SZ8->Z8_DESCRI, "CONSUMIDA!",1)

	endif

return .t.

Static Function produz(_cod, _pesol, _batel)

	SZ8->(dbSetOrder(3))
	SZ8->(dbGoTop())
	if SZ8->(dbSeek(xFilial('SZ8')+_cod))
		reclock('SZ8',.f.)
		SZ8->Z8_DATAS  := date()
		SZ8->Z8_HORAS  := time()
		SZ8->Z8_BATEL  := _batel
		msunlock()

		//incrementa a quantidade de peso na batelada
		ZAX->(DbSetOrder(1))
		ZAX->(dbGoTop())
		if ZAX->(dbSeek(xFilial('ZAX') + _batel))
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

//função para estornar a caixa consumida
Static Function estornaCx(_cod, _pesol, _batel)

	SZ8->(dbSetOrder(3))
	SZ8->(dbGoTop())
	if SZ8->(dbSeek(xFilial('SZ8')+_cod))
		reclock('SZ8',.f.)
		SZ8->Z8_DATAS  := stod('')
		SZ8->Z8_HORAS  := ''
		SZ8->Z8_BATEL  := ''
		msunlock()
		//incrementa a quantidade de peso na batelada
		ZAX->(DbSetOrder(1))
		ZAX->(dbGoTop())
		if ZAX->(dbSeek(xFilial('ZAX') + _batel))
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

	Local _cGrpMoi := getMv('SI_GRPMOI')

	//cArq  := CriaTrab( Nil, .F. )

	aStru := {}
	AADD(aStru,{"BATEL"  ,"C"	,10   ,0	})
	AADD(aStru,{"CODMP"  ,"C"	,6	   ,0	})
	AADD(aStru,{"DESCRI" ,"C"	,40	,0	})

	//dbcreate(cArq,aStru)
	//If Select('TRB')<>0
	//	TRB->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq,"TRB", .F. , .F. )

	_aArqTrb :={}
	If Select('TRB')<>0                                  //Se um tmp com alias TMP existir, fecha-o
		TRB->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TRB", aStru, {}, @_aArqTrb)

	filtraLotes()

	QRY->(dbGoTop())
	while QRY->(!eof())
		DbSelectArea('SB1')
		_cGrupo := fBuscaCPO('SB1',1,xfilial('SB1')+QRY->CODMP,'B1_GRUPO')
		if (_cGrupo $ _cGrpMoi)
			QRY->(dbSkip())
			loop
		endif
		reclock('TRB',.t.)
		TRB->BATEL	:= QRY->BATEL
		TRB->CODMP  := QRY->CODMP
		TRB->DESCRI	:= QRY->DESCRI
		msunlock()

		QRY->(dbSkip())
	enddo

	aCampos := {}

	AADD(aCampos,{"BATEL"  	,, "Lote"			,"@!"   			})
	AADD(aCampos,{"CODMP" 	,, "MP"	    		,"@!"   			})
	AADD(aCampos,{"DESCRI"	,, "Descricao"		,"@!"   			})

return

//função para filtrar os lotes para o ambiente de trabalho.
Static Function filtraLotes()

	_cQuery := " SELECT ZAX_NUM AS BATEL, ZAX_DESCRI AS DESCRI, ZAX_CODMP AS CODMP
	_cQuery += " FROM  " + retSqlTab('ZAX')
	_cQuery += " WHERE " + retSqlFil('ZAX')
	_cQuery += " AND ZAX_DTPROD = '" +dtos(date()) + "'"
	//_cQuery += " AND ZAX_DTPROD = '20220813'"
	_cQuery += " AND " + retSqlDel('ZAX')
	_cQuery += " ORDER BY ZAX_NUM"

	_cQuery  := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

return .f.

User Function vtMPBr2(modo)
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,100,1)
		_lOk := .f.
		return 0
	elseif VTLastkey()==13
		return 1
	endif
return



// Removido por Mauro 17/02/2021 - algumas inconsistências
/*Static Function cDtProd(_cCdProd,_dt)
	local retorno := space(1)


	_cQuery5 := " SELECT TOP 1 AS_DTPROD, AS_LOCALI
	_cQuery5 += " FROM  " + retSqlTab('ZAS')
	_cQuery5 += " WHERE " + retSqlFil('ZAS')
	_cQuery5 += " AND ZAS_FIL = '" +cFilAnt+"'"
	_cQuery5 += " AND ZAS_COD = '" + _cCdProd + "'"
	_cQuery5 += " AND ZAS_DTPROD < "+_dt+" AND AS_HORAS = '' 
	_cQuery5 += " AND   " + retSqlDel('ZAS')
	_cQuery5 += " ORDER BY AS_DTPROD
	
//	_cQuery5 := " SELECT TOP 1 AS_DTPROD, AS_LOCALI
//	_cQuery5 += " FROM  " + retSqlTab('ZAS')
//	_cQuery5 += " WHERE " + retSqlFil('ZAS')
//	_cQuery5 += " AND AS_FIL = '" +cFilAnt+"'"
//	_cQuery5 += " AND AS_COD = '" + _cProd + "'"
//	_cQuery5 += " AND AS_DTPROD = '' AND AS_HORAS = '' 
//	_cQuery5 += " AND   " + retSqlDel('ZAS')
//	_cQuery5 += " ORDER BY AS_DTPROD

	_cQuery5  := ChangeQuery(_cQuery5)

	If Select("QRY5") != 0
		QRY5->(dbCloseArea())
	Endif

	TCQUERY _cQuery5 NEW ALIAS "QRY5"

	QRY->(dbGoTop())


//	@ 12,00 VTSay space(30)
//	@ 13,00 VTSay space(30)
//	@ 14,00 VTSay space(30)

	

	
if !empty(QRY5->ZAS_CONTRO)
		
		//@ 12,00 VTSay "Data de prod mais antiga"
		//@ 13,00 VTSay "em estoque é: " + dtoc(stod(QRY5->AS_DTPROD))
		//@ 14,00 VTSay "localizada em: " + QRY5->AS_LOCALI
		
		retorno := 'S'
	endif
	/*
	if !empty(QRY5->AS_DTPROD)
			mensagem('Existe caixa mais antiga','',2)
			RETURN
			//_lEst := .t.
	else
			mensagem('MP diverge da batelada','',2)
			//return .t.
	endif
	
	
return retorno*/

