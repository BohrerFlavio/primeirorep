#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT14     º Autor ³Mauricio Roehrs    º ³  02/12/15        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ apontamento de produção no setor de corte(Montagem)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MRVT14(_usuario)

	Private _cModelo  := ''
	Private _lOk      := .t.
	Private _cCod1	   := ''
	Private _cCod2	   := ''
	Private _lTela    := .t.
	Private _cImp     := ' '
	Private _cIp      := ''
	Private _cProd1   := space(06)
	Private _cOpc     := ' '

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL18 <> 'S'
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

	while _lTela

		_cImp := ' '

		VTRead

		@ 01,05 VTSay "PROD. DO CORTE(Montagem)"
		@ 03,05 VTSay "Selecione a Impressora"
		@ 04,05 VTSay "1:CORTE|2:DES. [ ]"
		@ 16,00 VTSay "ESC para Sair"

		@ 04,21 VTGet _cImp Pict "@!" VALID _cImp $ '1/2'

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		//se for Corte
		if _cImp == '1'

			_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + 'ICRT1',1))

			//se for desossa
		elseif _cImp == '2'

			_cIp := alltrim(GetAdvFVal('ZAM','ZAM_IP',FWxFilial('ZAM') + 'IDSO2',1))

		endif

		VTClear()
		VTClearBuffer()

		_cImp := ' '

		while _lOk

			VTRead

			@ 01,05 VTSay "PROD. DO CORTE(Montagem)"
			@ 03,05 VTSay "Selecione a opcao"
			@ 04,08 VTSay "1:Produz:"
			@ 05,08 VTSay "2:Reimprime:"
			@ 06,08 VTSay "[ ]"
			@ 06,09 VTGet _cOpc Pict "@!" VALID _cOpc $ '1/2'
			@ 16,00 VTSay "ESC para Sair"
			VTRead

			If (VTLastKey() == 27)
				exit
			EndIF

			if _cOpc = '1'
				produz()
			elseif _cOpc = '2'
				reimprime()
			endif

			VTClearBuffer()

		enddo

		VTClear()
		VTClearBuffer()

	enddo

	VTClear()
	VTClearBuffer()

Return

Static Function reimprime()

	Private _lOk := .t.

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(11)

		VTRead

		@ 01,05 VTSay "PRODUCAO DO CORTE(Desmonte)"
		@ 03,05 VTSay "Codigo da Carcaça"
		@ 04,08 VTSay "[           ]"
		@ 04,09 VTGet _cCod Pict "@!" VALID setaCod(alltrim(_cCod))
		@ 16,00 VTSay "ESC para Sair"
		VTRead

		If (VTLastKey() == 27)
			exit
		EndIF

		VTClearBuffer()
		_cCod := Space(11)
	enddo

	VTClear()
	VTClearBuffer()

return

Static Function setaCod(_codBar)

	ZAJ->(dbSetOrder(10))
	ZAJ->(dbGoTop())
	if ZAJ->(MsSeek(FWxFilial('ZAJ') + alltrim(_codBar))) .and. len(alltrim(_codBar)) = 10 .and. _codBar <> '0000000000'
		vtImprime(ZAJ->ZAJ_NUM,ZAJ->ZAJ_NUMAM,ZAJ->ZAJ_LOTE,ZAJ->ZAJ_CONTRO,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_LADO,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_COD)
		return .t.
	endif

	ZAJ->(dbSetOrder(11))
	ZAJ->(dbGoTop())
	if ZAJ->(MsSeek(FWxFilial('ZAJ') + alltrim(_codBar))) .and. len(alltrim(_codBar)) = 10 .and. _codBar <> '0000000000'
		vtImprime(ZAJ->ZAJ_NUM,ZAJ->ZAJ_NUMAM,ZAJ->ZAJ_LOTE,ZAJ->ZAJ_CONTRO,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_LADO,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_COD)
		return .t.
	else
		VtMens('Registro nao encontrado!')
		_cCod := space(11)
		return .f.
	endif

return .t.

Static Function produz()

	Private _lOk := .t.

	VTClear()
	VTClearBuffer()
	while _lOk
		_lValid := .f.
		_cCod1  := Space(11)
		_cCod2  := Space(11)

		VTRead

		@ 01,05 VTSay "PROD. DO CORTE(Montagem)"
		@ 03,05 VTSay "Codigo da Etiqueta"
		@ 04,07 VTSay "[           ]"

		@ 06,05 VTSay "Codigo da Etiqueta"
		@ 07,07 VTSay "[           ]"

		@ 04,08 VTGet _cCod1 Pict "@!" VALID ValCod(_cCod1)
		@ 07,08 VTGet _cCod2 Pict "@!" VALID ValCod(_cCod2)
		@ 16,00 VTSay "ESC para Sair"
		VTRead

		If (VTLastKey() == 27)
			exit
		EndIF

		_lValid := compara(_cCod1,_cCod2)

		if _lValid
			setProd(ZAJ->ZAJ_COD)
		endif

		VTClearBuffer()
		_cCod1 := Space(11)
		_cCod2 := Space(11)

	enddo

	VTClear()
	VTClearBuffer()

return

Static Function compara(_codBar1,_codBar2)

	Local _lSt    := .t.
	Local _aInfo1 := {}
	Local _aInfo2 := {}
	Local i

	if _codBar1 == _codBar2
		_lSt := .f.
	else

		ZAJ->(DbGoTop())
		ZAJ->(DbSetOrder(2))
		if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_codBar1))) .and. len(alltrim(_codBar1)) = 10
			aAdd(_aInfo1,ZAJ->ZAJ_NUMAM)
			aAdd(_aInfo1,ZAJ->ZAJ_CONTRO)
			aAdd(_aInfo1,ZAJ->ZAJ_LADO)
			_prod1 := ZAJ->ZAJ_COD
		else
			_lSt := .f.
		endif

		if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_codBar2))) .and. len(alltrim(_codBar2)) = 10
			aAdd(_aInfo2,ZAJ->ZAJ_NUMAM)
			aAdd(_aInfo2,ZAJ->ZAJ_CONTRO)
			aAdd(_aInfo2,ZAJ->ZAJ_LADO)
			_prod2 := ZAJ->ZAJ_COD
		else
			_lSt := .f.
		endif

		if _lSt

			if len(_aInfo1) == len(_aInfo2)

				for i:= 1 to len(_aInfo1)
					if _aInfo1[i] != _aInfo2[i]
						_lSt := .f.
					endif
				next

			else
				_lSt := .f.
			endif

		endif
	endif

	if _lSt
		ZZS->(dbSetOrder(1))
		ZZS->(dbGoTop())
		if ZZS->(MsSeek(FWxFilial('ZZS') + alltrim(_prod1) + alltrim(_prod2)))

			_cProd1 := ZZS->ZZS_CORTE3

		elseif ZZS->(MsSeek(FWxFilial('ZZS') + alltrim(_prod2) + alltrim(_prod1)))

			_cProd1 := ZZS->ZZS_CORTE3

		else
			VtMens('Nao ha correlacao para estes produtos!','')
			_lSt := .f.
		endif
	else
		VtMens('Etqs. n pertencem a mesma carcaca!','')
	endif

return _lSt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função para inserção dos codigos de produtos que     ³
//³ que irão gerar registros na ZAJ e gerar Etiquetas    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function setProd(_prod)

	Local _cConf       := ' '
	Private _lOk       := .t.

	VtLimpa()
	VTClearBuffer()

	while _lOk

		@ 08,00 VTSay "Prod.[      ]"
		@ 09,00 VTSay "Confirma?(s/n) [ ] "
		@ 08,06 VTSay _cProd1

		@ 16,00 VTSay "ESC para Sair"
		//@ 06,06 VTGet _cProd1 Pict "@!" VALID ValProd(_cProd1)
		@ 09,16 VTGet _cConf  Pict "@!" VALID _cConf $ 'S/N/s/n'  .and. !empty(_cProd1)

		VTRead

		If (VTLastKey() == 27)
			exit
		EndIF

		if _cConf $ 'S/s'
			VtGrava(_cProd1)
			VtDeleta()
		endif

		_cProd1 := space(6)
		_cConf  := ' '
		VTClear()
		VTClearBuffer()
		exit

	enddo

	VTClear()
	VTClearBuffer()
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³              Valida Codigo de Produto               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValProd(_cCodProd)

	if empty(_cCodProd)
		return .t.
	endif

	DbSelectArea('SB1')
	SB1->(DbGoTop())
	SB1->(DbSetOrder(1))
	if SB1->(MsSeek(FWxFilial('SB1') + _cCodProd))

		if SB1->B1_MSBLQL != '2'
			VTAlert('Produto bloqueado, entre em contato com o PCP!','Atenção!',.T.,1500,1)
			return .f.
		endif

		if SB1->B1_SEGUM != 'PC'
			VTAlert('Tipo do produto não está cadastrado como Peça!','Atenção!',.T.,1500,1)
			return .f.
		endif

		return .t.
	endif

	VTAlert('Codigo de Produto não encontrado ou não cadastrado!!','Atenção!',.T.,1500,1)

return .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³         Valida Codigo Lido da Etiqueta               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValCod(_cCodBar)

	if empty(_cCodBar)
		return .f.
	endif

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(2))
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCodBar))) .and. len(alltrim(_cCodBar)) = 10
		if !empty(ZAJ->ZAJ_PREPED) .or. !empty(ZAJ->ZAJ_PRECAR) .or. !empty(ZAJ->ZAJ_ITEM)
			VtMens('Carcaça já carregada ou fora de estoque!',_cCodBar)
			_cCod1 := space(11)
			_cCod2 := space(11)
			return .f.
		endif

		if (!empty(ZAJ->ZAJ_DATAS) .or. !empty(ZAJ->ZAJ_HORAS)) .and. (empty(ZAJ->ZAJ_PREPED) .or. empty(ZAJ->ZAJ_PRECAR) .or. empty(ZAJ->ZAJ_ITEM))
			VtMens('Carcaça já produzida ou fora de estoque!',_cCodBar)
			_cCod1 := space(11)
			_cCod2 := space(11)
			return .f.
		endif

		return .t.//se retornar TRUE é pq não há nada de errado com a carcaça
	endif

	VtMens('Carcaça não identificada!',_cCodBar)//se não entrar no if é pq não encontrou a carcaça e retorna FALSO
	_cCod1 := space(11)
	_cCod2 := space(11)

return .f.

Static Function VtMens(_cMens,_cCodBar)
	@09,00 VTSay Space(30)
	@10,00 VTSay "Nr. Peça:    "+Space(30)
	@10,11 VTSay _cCodBar
	@11,00 VTSay Space(30)
	@12,00 VTSay Space(30)
	@13,00 VTSay Space(30)
	@14,00 VTSay Space(30)
	@11,00 VTSay _cMens + Space(30)
	@15,00 VTSay Space(30)
	//_cCod := Space(11)
return .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³              Grava os dados nas Tabelas              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VtGrava(_cProd)

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(2))
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod1))) .and. len(alltrim(_cCod1)) = 10

		_cControl := ZAJ->ZAJ_CONTRO
		_cNumam	  := ZAJ->ZAJ_NUMAM
		_cLote 	  := ZAJ->ZAJ_LOTE
		_cLado	  := ZAJ->ZAJ_LADO
		_cDiant	  := ZAJ->ZAJ_CDIAN
		_dDtCorte := ZAJ->ZAJ_DTCORT
		_cPredes  := ZAJ->ZAJ_PREDES
		_cNum 	  := GetSx8num('ZAJ','ZAJ_NUM')
		ConfirmSX8()

		DbSelectArea('SB1')
		_cDescri := GetAdvFVal('SB1',"B1_DESC",FWxfilial('SB1') + _cProd,1)
		_cCorOri := GetAdvFVal('SB1',"B1_CORORI",FWxfilial('SB1') + _cProd,1)

		reclock('ZAJ',.t.)
		ZAJ->ZAJ_FILIAL  := FWxfilial('ZAJ')
		ZAJ->ZAJ_CONTRO  := _cControl
		ZAJ->ZAJ_COD     := _cProd
		ZAJ->ZAJ_DESCRI  := substr(_cDescri,1,20)
		ZAJ->ZAJ_CORORI  := _cCorOri
		ZAJ->ZAJ_NUMAM   := _cNumam
		ZAJ->ZAJ_LOTE    := _cLote
		ZAJ->ZAJ_NUM     := _cNum
		ZAJ->ZAJ_LADO    := _cLado
		ZAJ->ZAJ_NIVEL   := 1
		ZAJ->ZAJ_REGORI  := alltrim(_cCod1)
		ZAJ->ZAJ_REGOR2  := alltrim(_cCod2)
		ZAJ->ZAJ_CDIAN   := _cDiant
		ZAJ->ZAJ_DATA    := ddatabase
		ZAJ->ZAJ_DTCORT  := _dDtCorte
		ZAJ->ZAJ_PREDES  := _cPredes
		msunlock()
		//chama função de impressão
		VtImprime(_cNum,_cNumam,_cLote,_cControl,_cDescri,_cLado,_cDescri,_cProd)

	endif

return

Static Function VtLimpa()
	@09,00 VTSay Space(40)
	@10,00 VTSay Space(40)
	@11,00 VTSay Space(40)
	@12,00 VTSay Space(40)
	@13,00 VTSay Space(40)
	@14,00 VTSay Space(40)
	@15,00 VTSay Space(40)
	//_cCod := Space(11)
return .f.

Static Function VtDeleta()

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(2))
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod1))) .and. len(alltrim(_cCod1)) = 10
		reclock('ZAJ',.f.)
		ZAJ->ZAJ_DATAS  := ddatabase
		ZAJ->ZAJ_HORAS  := time()
		msunlock()
	endif

	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod2))) .and. len(alltrim(_cCod2)) = 10
		reclock('ZAJ',.f.)
		ZAJ->ZAJ_DATAS  := ddatabase
		ZAJ->ZAJ_HORAS  := time()
		msunlock()
	endif

return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                 Imprime a Etiqueta                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VtImprime(_cNum,_cNumam,_cLote,_cControl,_cDescri,_cLado,_cDescri,_cProd)	//VtImprime(_cNum, _cProd)

	_Font01 	:= "60,60"
	_Font02 	:= "70,70"

	ZAJ->(dbSetOrder(2))
	ZAJ->(dbGoTop())
	if ZAJ->(MsSeek(FWxFilial('ZAJ') + alltrim(_cNum)))

		SZK->(dbSetOrder(4))
		SZK->(dbGoTop())
		if SZK->(MsSeek(FWxFilial('SZK') + alltrim(ZAJ->ZAJ_NUMAM) + alltrim(ZAJ->ZAJ_CONTRO)))

			_ZK_COBGOR 	:= SZK->ZK_COBGOR
			_ZK_DENT   	:= SZK->ZK_DENT
			_ZK_CONTROL := SZK->ZK_CONTROL
			_ZK_PROGRAM := SZK->ZK_PROGRAM
			_ZK_RASTRO	:= SZK->ZK_RASTRO
			_ZK_OBS		:= SZK->ZK_OBS
			_ZK_CATEG	:= SZK->ZK_CATEG
			_ZK_CLASSIF	:= SZK->ZK_CLASSIF
			_ZK_CLASESP	:= SZK->ZK_CLASESP

			dAbate := GetAdvFVal('SZG','ZG_DATA',FWxFilial('SZG')+ SZK->ZK_NUMAM,1)

		endif

		//MSCBPRINTER('S600','IP',,,,,_cIpImp)

		MSCBPRINTER('S600','IP',,,,,_cIp)
		MSCBCHKSTATUS(.f.)
		MSCBBEGIN(1,6)

		MSCBBOX(01,16,60,33)

		//Lado
		MSCBSAY(50, 17,ZAJ->ZAJ_LADO,"N","0","100,100")

		//Codigo de Barras
		MSCBSAYBAR(08,17,ZAJ->ZAJ_NUM,"N","C",10,,.t.,,,2,2,.t.)

		MSCBBOX(01,35,14,48)
		MSCBSAY(3, 36,'Gord',"N","E","8,8")
		MSCBSAY(6, 40,_ZK_COBGOR,"N","0",_Font01)

		MSCBBOX(17, 35,31,48)
		MSCBSAY(20, 36,'Dent',"N","E","8,8")

		MSCBSAY(23, 40,iif(_ZK_DENT = '1','DL',_ZK_DENT),"N","0",_Font01)

		MSCBBOX(34, 35,60,48)

		MSCBSAY(35, 36,'Cod.Prod.',"N","E","8,8")
		MSCBSAY(35, 40,_cProd,"N","0",_Font01)

		MSCBBOX(02,50,60,70)
		MSCBLINEV(39,50,70)
		MSCBLINEH(39,60,60)

		MSCBSAY(03, 52,'SEQ.',"N","E","8,8")
		MSCBSAY(13, 52,_ZK_CONTROL,"N","0",_Font02)

		_cDescri := ZAJ->ZAJ_DESCRI
		MSCBSAY(03, 62,substr(_cDescri,1,9),"N","0",_Font01)

		MSCBSAY(40, 52,'Abate',"N","E","8,8")
		MSCBSAY(40, 55,ZAJ->ZAJ_NUMAM,"N","E","8,8")

		MSCBSAY(40, 62,'Lote',"N","E","8,8")
		MSCBSAY(40, 66,ZAJ->ZAJ_LOTE,"N","E","8,8")

		MSCBBOX(02,72,60,77)
		MSCBSAY(02,73, GetMv("MV_NUMIF") + strtran(dtoc(dAbate),'/','') +'0000',"N","E","8,8")

		MSCBBOX(02,79,30,89)
		MSCBSAY(03,80,'SIF',"N","E","8,8")
		MSCBSAY(07,84,GetMv("MV_NUMIF"), "N","E","28,15")

		MSCBBOX(32,79,60,89)
		MSCBSAY(33,80,'Data Abate',"N","E","8,8")
		MSCBSAY(37,84,dtoc(dAbate),"N","E","28,15")

		nL := 125

		Private _cPrograma   := _ZK_PROGRAM
		Private nomePrograma := GetAdvFVal('SZ6','Z6_DESC',FWxFilial('SZ6')+_cPrograma,1)

		MSCBBOX(02,93,60,98)
		If _ZK_OBS == '0'  //ok
			MSCBSAY(03,94, 'SISBOV:'+ _ZK_RASTRO ,"N","E","8,8")
		Endif
		_cCateg := GetAdvFVal('SZ5','Z5_DESC',FWxfilial('SZ5')+ _ZK_CATEG,1)
		if _ZK_PROGRAM = '006'
			MSCBBOX(02,100,60,109)
			MSCBSAY(03,101,_cCateg,"N","0",_Font01)// *** Verificar campo novo
			MSCBBOX(02,110,60,120)
			// caso M->ZK_COBGOR for = 1 colocar'ANGUS - MAGRO'
			MSCBSAY(10,111,'ANGUS',"N","0","90,105")
			MSCBBOX(02,124,60,144)// quadrado
			MSCBSAY(10,125,_ZK_CLASSIF,"N","0","180,300")
		else
			MSCBBOX(02,100,60,109)
			MSCBSAY(03,101,_cCateg,"N","0",_Font01)
			MSCBBOX(02,110,60,130)
			MSCBSAY(12,111,_ZK_CLASSIF,"N","0","162,270")
			If !Empty(nomePrograma) .and. nomePrograma != '001'
				MSCBSAY(03,138,substr(nomePrograma,1,10), "N","0","100,80")// aqui esta sendo modificado
			endif
		endif

		//Aqui imprime a Classificação Especial
		//if _ZK_CLASESP = '1' .and. (AllTrim(_ZK_CLASSIF) != 'NE' .or. AllTrim(_ZK_CLASSIF) != 'USA') .and. _ZK_DENT > '4'
		if _ZK_CLASESP = '2' .and. (AllTrim(_ZK_CLASSIF) != 'NE' .or. AllTrim(_ZK_CLASSIF) != 'BR') .and. _ZK_DENT > '4'
			MSCBBOX(16,145,45,120)
			MSCBSAY(17,147,'HK',"N","0","200,200")
		elseif _ZK_CLASESP = '1' .and. AllTrim(_ZK_CLASSIF) = 'USA'
			MSCBBOX(16,145,45,120)
			MSCBSAY(17,147,'USA',"N","0","200,200")
		elseif _ZK_CLASESP = '2' .and. AllTrim(_ZK_CLASSIF) = 'BR'
			MSCBBOX(16,145,45,120)
			MSCBSAY(17,147,'BR',"N","0","200,200")
		elseif _ZK_CLASESP = '1' .and. AllTrim(_ZK_CLASSIF) != 'NE' .and. _ZK_DENT <= '4' 
			MSCBBOX(16,145,45,120)
			MSCBSAY(17,148,'CN',"N","0","200,200")
		endif

		//****************************  FIM  *****************************************
		MSCBSAY(13,285,"DTI","N","0","100,190")

		MSCBEND()
		MSCBCLOSEPRINTER()

	endif
return

