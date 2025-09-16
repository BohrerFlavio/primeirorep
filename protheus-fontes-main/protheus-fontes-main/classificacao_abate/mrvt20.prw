#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT20     º Autor ³Lucas Bolzan       º ³  01/09/22        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ apontamento de produção no setor de corte(Desmontagem)     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function MRVT20(_usuario)

	Local   _cDest    := ' '
	Private _cModelo  := '' 
	Private _lOk      := .t.
	Private _cCod 	   := ''
	Private _lTela    := .t.
	Private _cImp     := ' '
	Private _cIp      := ''
	Private _lTela2   := ''
	Private _cOpc     := ' '
	Private _cProd2    := Space(06)
	Private _cProd3    := Space(06)
	Private _cProd4    := Space(06)

	ZAA->(DbSetOrder(2))
	ZAA->(MsSeek(FWxfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL17 <> 'S'
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

		@ 01,05 VTSay "PRODUCAO DO CORTE(Desmonte)"
		@ 03,05 VTSay "Selecione a Impressora"
		@ 04,05 VTSay "1:TENDAL.|2:COSTELA. [ ]"
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

			@ 01,05 VTSay "PRODUCAO DO CORTE(Desmonte)"
			@ 03,05 VTSay "Selecione a opcao"
			@ 04,08 VTSay "1:Produz:"
			@ 05,08 VTSay "2:Reimprime:"
			@ 06,08 VTSay "[ ]"
			@ 06,09 VTGet _cOpc Pict "@!" VALID _cOpc $ '1/2'
			@ 16,00 VTSay "ESC para Sair"
			VTRead

			If (VTLastKey() == 27)
				//VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
				exit
			EndIF

			if _cOpc = '1'
				_cDest := pickDest()
				if (_cDest $ '1/2/3/4')
					produz(_cDest)
				else
					VtMens('Dest. nao informado!')
				endif
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
			//VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
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
		while ZAJ->(!EOF()) .and. FWxFilial('ZAJ') == ZAJ->ZAJ_FILIAL .and. ZAJ->ZAJ_REGORI == alltrim(_codBar)
			vtImprime(ZAJ->ZAJ_NUM,ZAJ->ZAJ_NUMAM,ZAJ->ZAJ_LOTE,ZAJ->ZAJ_CONTRO,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_LADO,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_COD)
			ZAJ->(dbSkip())
		enddo
	else
		VtMens('Registro nao encontrado!')
		_cCod := space(11)
		return .f.
	endif

return .t.


Static function produz(_cDest)

	Private _lOk := .t.

	VTClear()
	VTClearBuffer()

	while _lOk

		_cCod := Space(11)

		VTRead

		@ 01,05 VTSay "PRODUCAO DO CORTE(Desmonte)"
		@ 02,05 VTSay "Dest.:"+iif(_cDest = '1','Desossa',iif(_cDest = '2','Costela',iif(_cDest = '3','Carregamento','Sem Destino')))
		@ 03,05 VTSay "Codigo da Carcaça"
		@ 04,08 VTSay "[           ]"
		@ 04,09 VTGet _cCod Pict "@!" VALID ValCod()
		@ 16,00 VTSay "ESC para Sair"
		VTRead

		If (VTLastKey() == 27)
			//VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		setProd(ZAJ->ZAJ_COD, _cDest)

		VTClearBuffer()
		_cCod := Space(11)
	enddo

	VTClear()
	VTClearBuffer()

return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Função para inserção dos codigos de produtos que     ³
//³ que irão gerar registros na ZAJ e gerar Etiquetas    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function setProd(_prod,_cDest)

	//Local _cConf       := ' '
	Local _cProd1      := alltrim(_prod)
	Private _lOk       := .t.

	VtLimpa()
	VTClearBuffer()
	while _lOk

		@ 06,00 VTSay "Prod.Etq.Orig. [      ]"
		@ 07,00 VTSay "Prod.[      ]"
		@ 08,00 VTSay "Prod.[      ]"
		@ 09,00 VTSay "Prod.[      ]"
		//@ 10,00 VTSay "Confirma? [ ]"

		@ 16,00 VTSay "ESC para Sair"
		@ 06,16 VTSay _cProd1
		@ 07,06 VTGet _cProd2 Pict "@!" VALID ValProd(_cProd2)
		//@ 10,11 VTGet _cConf  Pict "@!" VALID _cConf $ 'S/N/s/n'

		VTRead

		If (VTLastKey() == 27)
			//VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		//if _cConf $ 'S/s'
		VtGrava(_cProd1,_cProd2,_cProd3,_cProd4)
		VtDeleta(_cDest)
		//endif

		//_cProd1 := space(6)
		//_cProd2 := space(6)
		//_cProd3 := space(6)
		//_cProd4 := space(6)
		//_cConf  := ' '
		exit

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()
return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³              Valida Codigo de Produto               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValProd(_cCodProd)

	local _lFind := .f.

	if empty(_cCodProd)
		return .t.
	endif

	DbSelectArea('SB1')
	SB1->(DbGoTop())
	SB1->(DbSetOrder(1))
	if SB1->(MsSeek(FWxFilial('SB1') + _cCodProd))

		ZAJ->(DbGoTop())
		ZAJ->(DbSetOrder(2))
		if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod))) .and. len(alltrim(_cCod)) = 10
			if SB1->B1_CORORI != ZAJ->ZAJ_CORORI
				VTAlert('Corte de Origem do Produto Difere do Produto Lido!','Atenção',.T.,1500,1) 
				return .f.
			endif
		endif

		if SB1->B1_MSBLQL != '2'
			VTAlert('Produto bloqueado, entre em contato com o PCP!','Atenção!',.T.,1500,1)
			return .f.   
		endif

		if SB1->B1_SEGUM != 'PC'
			VTAlert('Tipo do produto não está cadastrado como Peça!','Atenção!',.T.,1500,1)
			return .f.
		endif

		_lFind := findProds(_cCodProd) 

		return _lFind
	endif

	VTAlert('Codigo de Produto não encontrado ou não cadastrado!!','Atenção!',.T.,1000,1)

return .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³         Valida Codigo Lido da Etiqueta               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValCod()

	if empty(_cCod)
		return .f.
	endif

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(2))
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod))) .and. len(alltrim(_cCod)) = 10
		if !empty(ZAJ->ZAJ_PREPED) .or. !empty(ZAJ->ZAJ_PRECAR) .or. !empty(ZAJ->ZAJ_ITEM)
			VtMens('Carcaça já carregada ou fora de estoque!')
			_cCod := space(11)
			return .f.
		endif
		//CONDIÇÃO ABAIXO RETIRADA A PEDIDO DO HENRIQUE JARDIM DEVIDO A RASTREABILIZADA
		/*
		if (!empty(ZAJ->ZAJ_DATAS) .or. !empty(ZAJ->ZAJ_HORAS)) .and. (empty(ZAJ->ZAJ_PREPED) .or. empty(ZAJ->ZAJ_PRECAR) .or. empty(ZAJ->ZAJ_ITEM))
			
			VtMens('Carcaça já produzida ou fora de estoque!')	
			_cCod := space(11)
			return .f.
		endif
		*/
		return .t.//se retornar TRUE é pq não há nada de errado com a carcaça
	endif

	VtMens('Carcaça não identificada!')//se não entrar no if é pq não encontrou a carcaça e retorna FALSO
	_cCod := space(11)

return .f.


Static Function findProds(_prod)

	ZAT->(dbSetOrder(1))
	ZAT->(dbGoTop())
	if !ZAT->(MsSeek(FWxFilial('ZAT') + _prod))
		vtMens('Nao ha correlacao para este corte!')
		return .f.
	else

		_cProd3 := ZAT->ZAT_CORTE2
		_cProd4 := ZAT->ZAT_CORTE3

		@ 08,06 VTSay _cProd3
		@ 09,06 VTSay _cProd4

	endif

return .t.


Static Function VtMens(_cMens)
	@11,00 VTSay Space(30)
	@12,00 VTSay "Nr. Peça:    "+Space(30)
	@12,11 VTSay _cCod
	@13,00 VTSay Space(30)
	@15,00 VTSay Space(30)
	@15,00 VTSay Space(30)
	@13,00 VTSay _cMens + Space(30)

	//_cCod := Space(11)
return .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³              Grava os dados nas Tabelas              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VtGrava(_cProd1,_cProd2,_cProd3,_cProd4,_cProd5)

	Local _nGrav := 0
	Local _aProd := {}
	Local i
	
	/*if !empty(_cProd1)
	_nGrav++
	aadd(_aProd,_cProd1)
	endif*/  

	if !empty(_cProd2)
		_nGrav++
		aadd(_aProd,_cProd2)
	endif

	if !empty(_cProd3)
		_nGrav++
		aadd(_aProd,_cProd3)
	endif

	if !empty(_cProd4)
		_nGrav++
		aadd(_aProd,_cProd4)
	endif

	/*
	if !empty(_cProd5)
	_nGrav++
	aadd(_aProd,_cProd5)
	endif
	*/

	if _nGrav > 0

		ZAJ->(DbGoTop())
		ZAJ->(DbSetOrder(2))
		if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod))) .and. len(alltrim(_cCod)) = 10
			for i:=1 to _nGrav

				_cControl := ZAJ->ZAJ_CONTRO
				_cCorOri  := ZAJ->ZAJ_CORORI
				_cNumam	 := ZAJ->ZAJ_NUMAM
				_cLote 	 := ZAJ->ZAJ_LOTE
				_cLado	 := ZAJ->ZAJ_LADO
				_cDiant	 := ZAJ->ZAJ_CDIAN
				_dDtCorte := ZAJ->ZAJ_DTCORT
				_cPredes  := ZAJ->ZAJ_PREDES
				_nPesPec  := ZAJ->ZAJ_PESO
				_cNumTerc := ZAJ->ZAJ_ZAPNUM
				_cNum 	 := GetSx8num('ZAJ','ZAJ_NUM')
				ConfirmSX8()

				DbSelectArea('SB1')
				_cDescri 	:= GetAdvFVal('SB1',"B1_DESC",FWxfilial('SB1') + _aProd[i],1)
				_nPercPeso 	:= GetAdvFVal('SB1','B1_PERCQTD',FWxFilial('SB1')+_aProd[i],1) / 100
				_nPeso 		:= _nPercPeso * _nPesPec

				reclock('ZAJ',.t.)
				ZAJ->ZAJ_FILIAL  := FWxfilial('ZAJ')
				ZAJ->ZAJ_CONTRO  := _cControl
				ZAJ->ZAJ_COD     := _aProd[i]
				ZAJ->ZAJ_DESCRI  := substr(_cDescri,1,20)
				ZAJ->ZAJ_CORORI  := _cCorOri
				ZAJ->ZAJ_NUMAM   := _cNumam
				ZAJ->ZAJ_LOTE    := _cLote
				ZAJ->ZAJ_NUM     := _cNum
				ZAJ->ZAJ_LADO    := _cLado
				ZAJ->ZAJ_NIVEL   := 1
				ZAJ->ZAJ_REGORI  := alltrim(_cCod)
				ZAJ->ZAJ_CDIAN   := _cDiant
				ZAJ->ZAJ_DATA    := ddatabase
				ZAJ->ZAJ_DTCORT  := _dDtCorte
				ZAJ->ZAJ_PREDES  := _cPredes
				ZAJ->ZAJ_PESO    := _nPeso	
				ZAJ->ZAJ_ZAPNUM  := _cNumTerc
				msunlock()
				//chama função de impressão
				VtImprime(_cNum,_cNumam,_cLote,_cControl,_cDescri,_cLado,_cDescri,_aProd[i])

			next
		endif
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


Static Function VtDeleta(_cDest)

	ZAJ->(DbGoTop())
	ZAJ->(DbSetOrder(2))
	if ZAJ->(MsSeek(FWxFilial('ZAJ')+alltrim(_cCod))) .and. len(alltrim(_cCod)) = 10
		reclock('ZAJ',.f.)
		ZAJ->ZAJ_DATAS  := ddatabase
		ZAJ->ZAJ_HORAS  := time()  
		ZAJ->ZAJ_DEST   := iif(_cDest = '1', 'D',;
		iif(_cDest = '2', 'C',;
		iif(_cDest = '3', 'R',''))) //1:Desossa|2:Costela|3:Carregamento|4:Sem destino"
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
		//primeiro verifica se é produto de terceiro
		if !empty(ZAJ->ZAJ_ZAPNUM)
			_cSif 		:= GetAdvFVal('ZAP','ZAP_SIF',FWxFilial('ZAP') + ZAJ->ZAJ_ZAPNUM,3)
			_cClassif 	:= GetAdvFVal('ZAP','ZAP_CLASSI',FWxFilial('ZAP') + ZAJ->ZAJ_ZAPNUM,3)
			_cCertif 	:= GetAdvFVal('ZAP','ZAP_CERT',FWxFilial('ZAP') + ZAJ->ZAJ_ZAPNUM,3)
			_dDataP     := GetAdvFVal('ZAP','ZAP_DATAP',FWxFilial('ZAP') + ZAJ->ZAJ_ZAPNUM,3)

			//conout(_cIp)

			u_geraEtq191(ZAJ->ZAJ_NUM,ZAJ->ZAJ_COD,ZAJ->ZAJ_DESCRI,ZAJ->ZAJ_LADO,_dDataP,_cSif,_cClassif,_cCertif,'',_cIp)
		else
			SZK->(dbSetOrder(4))
			SZK->(dbGoTop())
			if SZK->(MsSeek(FWxFilial('SZK') + ZAJ->ZAJ_NUMAM + ZAJ->ZAJ_CONTRO))

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

			MSCBSAY(23, 40,iif(_ZK_DENT = '0','DL',_ZK_DENT),"N","0",_Font01)

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
			Private nomePrograma := POSICIONE('SZ6', 1, FWxFilial('SZ6')+_cPrograma, 'Z6_DESC')

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

	endif
return


Static Function pickDest()

	//Local _cConf       := ' '
	//Local _cProd1      := alltrim(_prod)
	Local _cDest  := '0'
	Private _lOk  := .t.

	//VtLimpa()
	VTClearBuffer()
	while _lOk	

		@ 06,00 VTSay "Dest.:[ ]1:DES|2:COS|3:CAR|4:S/D"

		@ 16,00 VTSay "ESC para Sair"
		@ 06,07 VTGet _cDest Pict "@!" VALID _cDest $ '1/2/3/4'

		VTRead

		If (VTLastKey() == 27)
			//VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		exit

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

return _cDest
