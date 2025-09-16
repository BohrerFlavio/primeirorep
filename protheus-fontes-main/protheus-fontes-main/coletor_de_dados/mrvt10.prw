#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "APVT100.CH"
#INCLUDE "tbiconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MRVT10     º Autor ³Mauricio Roehrsº ³  10/07/14        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aplicação para microterminais VT-100 para rotina de        º±±
±±º          ³ devolucoes                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Função para devolucoes
User Function MRVT10(_usuario)

	Private _cModelo  := ''
	Private _cPar00   := '1'
	Private _cPar01   := space(14)  //cnpj
	Private _cPar02   := space(09)  //Doc
	Private _cPar03   := space(03)  //serie
	Private _cPar04   := '1' //Destino: 1 - estoque, 2 - repesagem, 3- reprocesso, 4 - charque, 5 - graxaria
	Private _cDesc    := ''  //Descricao do cliente
	Private _cCodCli  := ''
	Private _cLojCli  := ''
	Private _cUser    := _usuario
	Private _cNome 	:= ''
	Private _lOk      := .t.
	Private _cIpImp := alltrim(fBuscaCPO('ZAM',1,xFilial('ZAM') + 'IDEV1','ZAM_IP'))

	ZAA->(DbSetOrder(2))
	ZAA->(DbSeek(xfilial('ZAA')+_usuario))

	if ZAA->ZAA_APL11 <> 'S'
		VTAlert('Opção negada para o usuario!','Aviso',.T.,1000,1)
		return .t.
	endif

	//Define o tamanho da Tela
	_cModelo := VTModelo()

	if _cModelo <> 'RF'
		VTSetSize(2,16)
	else
		VTSetSize(20,30)
	endif

	VTClear()
	VTClearBuffer()

	while _lOk
		@ 01,05 VTSay " CONTROLE DEVOLUCOES   "
		@ 03,00 VTSay " Operação:          [ ]"
		@ 04,00 VTSay "  1 - Inclusão Lançam. "
		@ 05,00 VTSay "  2 - Exclusão Lançam. "
		@ 06,00 VTSay "  3 - Saída Câmara     "
		@ 07,00 VTSay "  4 - Estorna Saída    "
		@ 08,00 VTSay "  5 - Re-impressão     "
		@ 09,00 VTSay "  6 - Consulta NF      "
		@ 16,00 VTSay "  ESC para Sair        "

		@ 03,21  VTGet _cPar00 Pict "@! " valid (_cPar00 $ '123456')

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		if _cPar00 = '1'
			IncDev()
		elseif _cPar00 = '2'
			ExcDev()
		elseif _cPar00 = '3'
			SaiDev(0)
		elseif _cPar00 = '4'
			SaiDev(1)
		elseif _cPar00 = '5'
			ReImpr()
		elseif _cPar00 = '6'
			consNF()
		endif

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

return

//Função para incluir devoluções
Static Function IncDev()

	Local _lOk0 := .t.

	VTClear()
	VTClearBuffer()

	while _lOk0
		@ 01,05 VTSay "CONTROLE DEVOLUCOES  "
		@ 04,00 VTSay "CNPJ:[              ]"
		@ 05,00 VTSay "[                   ]"
		@ 06,00 VTSay "N. Fiscal:[         ]"
		@ 07,00 VTSay "Serie:          [   ]"
		@ 08,00 VTSay "Destino:          [ ]"
		@ 09,00 VTSay "1 - Estoque          "
		@ 10,00 VTSay "2 - Repesagem        "
		@ 11,00 VTSay "3 - Reprocesso       "
		@ 12,00 VTSay "4 - Charque          "
		@ 13,00 VTSay "5 - Graxaria         "
		@ 16,00 VTSay "ESC para Sair        "

		@ 04,06 VTGet _cPar01 Pict "@! " valid ProcCli(_cPar01) .and. !empty(_cPar01)
		@ 06,11 VTGet _cPar02 Pict "@! " valid !empty(_cPar02)
		@ 07,17 VTGet _cPar03 Pict "@! " valid !empty(_cPar03)
		@ 08,19 VTGet _cPar04 Pict "@! " valid (_cPar04 $ '12345')

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		if _cPar04 = '1'      //Estoque
			Dest_01()
		elseif _cPar04 $ '2/3/4/5'  //Repesagem//Reprocesso//Charque//Graxaria
			Dest_02()
		endif

		VTClearBuffer()

	enddo

	VTClear()
	VTClearBuffer()

return

//Função para excluir devoluções
Static Function ExcDev()

	VTClear()
	VTClearBuffer()

	aFields := {"ZN_NUM","ZN_DESTINO","ZN_COD","ZN_DESC"}
	aHeader := {'NUMERO','DES','CODIGO','DESCRICAO'}
	aSize   := {11,03,06,20}

	//Laço para realizar a operação
	//de escolha do lote e produção deste
	_lOk2 := .t.

	While _lOk2

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,2000,1)
			exit
		EndIf

		DbSelectArea('SZN')
		SZN->(DbSetOrder(7))
		SZN->(DbGoTop())
		SZN->(DbSeek(xfilial('SZN')+ DTOS(DDATABASE) + alltrim(_cUser)))

		/*SET FILTER TO (SZN->ZN_FILIAL  = xfilial('SZN') .and.;
		SZN->ZN_DTENTR  = ddatabase      .and.;
		SZN->ZN_CODUSER = _cUser         .and.;
		SZN->ZN_DESTINO = 'C')*/

		SET FILTER TO (SZN->ZN_FILIAL  = xfilial('SZN') .and.;
		SZN->ZN_DTENTR  = ddatabase        .and.;
		SZN->ZN_CODUSER = _cUser           .and.;
		empty(SZN->ZN_DTSAIDA))			   .or. ;
		(SZN->ZN_FILIAL  = xfilial('SZN')  .and.;
		SZN->ZN_DTENTR  = ddatabase        .and.;
		SZN->ZN_CODUSER = _cUser           .and.;
		SZN->ZN_DESTINO = 'C')

		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"SZN",aHeader,aFields,aSize,"u_MR10br",)

		SET FILTER TO

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(03)',.T.,2000,1)
			exit
		EndIf

		if _lOk2
			Excluir()
		endif

	EndDo

	VTClear()
	VTClearBuffer()

return

//Função para saída das devoluções das câmaras
Static Function SaiDev(_n)
	Private _lOk4       := .t.
	Private _cCodCaix  := space(10)

	VTClear()
	VTClearBuffer()

	while _lOk4

		_cCodCaix := Space(11)

		VTRead

		@ 01,05 VTSay "CONTROLE DEVOLUCOES  "
		@ 02,05 VTSay iif(_n = 0,"Saída de Câmara","Estorno Saída Câmara")
		@ 05,05 VTSay "Codigo caixa:"
		@ 06,08 VTSay "[           ]"
		@ 06,09 VTGet _cCodCaix Pict "@!" VALID ValSai(_n)
		@ 16,00 VTSay "ESC para Sair"
		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

Return

//Função para reimprimir
Static Function ReImpr()

	VTClear()
	VTClearBuffer()

	aFields := {"ZN_NUM","ZN_DESTINO","ZN_COD","ZN_DESC"}
	aHeader := {'NUMERO','DES','CODIGO','DESCRICAO'}
	aSize   := {11,03,06,20}

	//Laço para realizar a operação
	//de escolha do lote e produção deste
	_lOk2 := .t.

	While _lOk2

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(02)',.T.,2000,1)
			exit
		EndIf

		DbSelectArea('SZN')
		SZN->(DbSetOrder(7))
		SZN->(DbSeek(xfilial('SZN')+ DTOS(DDATABASE) + _cUser))

		SET FILTER TO SZN->ZN_FILIAL = xfilial('SZN') .and.;
		SZN->ZN_DTENTR = ddatabase      .and.;
		SZN->ZN_CODUSER = _cUser        .and.;
		empty(SZN->ZN_DTSAIDA)          .and.;
		SZN->ZN_DESTINO $ 'RP'

		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"SZN",aHeader,aFields,aSize,"u_MR10br",)

		SET FILTER TO

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(03)',.T.,2000,1)
			exit
		EndIf

		if _lOk2
			if VTYesNo("Confirma impressão?","Impressão Etiqueta",.T.)
				if !empty(_cIpImp)
					imprime(_cIpImp,SZN->ZN_COD,SZN->ZN_DATAP,SZN->ZN_DTENTR,SZN->ZN_QUANT,SZN->ZN_PESOL,SZN->ZN_DESTINO,SZN->ZN_NUM,SZN->ZN_CODDEST)
				else
					VTAlert('IP da Impressora não cadastrado!','Aviso de Encerramento(05)',.T.,1000,1)
				endif
			endif

		endif

	EndDo

	VTClear()
	VTClearBuffer()

return

// Função para efetivar a exclusão
Static Function Excluir()
	Local _cConf := 'X'
	VTClear()
	VTClearBuffer()

	@ 01,05 VTSay "CONTROLE DEVOLUCOES  "
	//                          (E)stoque             (R)epesagem         re(P)rocesso      (C)harque (G)raxaria
	@ 02,05 VTSay "Destino: " + iif(SZN->ZN_DESTINO = 'E','Estoque',;
	iif(SZN->ZN_DESTINO = 'R','Repesagem',;
	iif(SZN->ZN_DESTINO = 'P','Reprocesso',;
	iif(SZN->ZN_DESTINO = 'C','Charque','Graxaria'))))
	@ 03,05 VTSay "Cod. Caixa:    " + SZN->ZN_CONTROL
	@ 04,05 VTSay "Data Produção: " + dtoc(SZN->ZN_DATAP)
	@ 05,05 VTSay "Produto:       " + SZN->ZN_COD
	@ 06,05 VTSay "Descricao:     " + SZN->ZN_DESC
	@ 07,05 VTSay "Quant.:        " + alltrim(transform(SZN->ZN_QUANT,' @E 999'))
	@ 08,05 VTSay "Peso Bru.:     " + alltrim(transform(SZN->ZN_PESOB,' @E 999.99'))
	@ 09,05 VTSay "Peso Liq.:     " + alltrim(transform(SZN->ZN_PESOL,' @E 999.99'))

	@ 11,05 VTSay "Confirma?            [ ]"

	@ 11,27 VTGet _cConf  Pict "@!" VALID _cConf = 'X'
	@ 16,00 VTSay "ESC para Sair"
	VTRead

	If (VTLastKey() == 27)
		VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
	else
		SZ8->(DbSetOrder(3))
		SZ8->(DbGoTop())
		if SZ8->(DbSeek(xFilial('SZ8') + SZN->ZN_CONTROL))
			if SZN->ZN_DESTINO = 'E' .and. !empty(SZN->ZN_CONTROL)
				reclock('SZ8',.f.)
				SZ8->Z8_PRECAR := 'AJUSTE'
				SZ8->Z8_PREPED := 'AJUSTE'
				SZ8->Z8_ITEM   := 'AJU'
				SZ8->Z8_DATAS  := DDATABASE
				SZ8->Z8_HORAS  := '99:99'
				msunlock()
			endif
		endif
		u_gjf17his(2,'EST.DEV. ' + SZN->ZN_NUM,.f.,'','','000027',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

		reclock('SZN',.f.)
		DbDelete()
		msunlock()

	EndIF

	VTClear()
	VTClearBuffer()

return

//Para localizar o cliente através do CNPJ
Static Function ProcCli(_cnpj)
	Local _lRet := .t.

	SA1->(DbSetOrder(3))
	if SA1->(DbSeek(xfilial('SA1')+_cnpj)) .and. len(_cnpj) = 14
		_cNome   := substr(SA1->A1_NOME,1,19)
		_cCodCli := SA1->A1_COD
		_cLojCli := SA1->A1_LOJA
		@ 05,00 VTSay "[" + _cNome + "]"
	elseif alltrim(_cnpj) = '9'
		_cNome   := 'INDEFINIDO!'
		@ 05,00 VTSay "[" + padr(_cNome,19," ") +"]"
		_cCodCli := '999999'
		_cLojCli  := '99'
	else
		@ 05,00 VTSay "[NÃO LOCALIZADO!!!!!]"
		_cNome   := ''
		_cCodCli := ''
		_cLojCli  := ''
		_lRet := .f.
	endif
return _lRet

//Destino 01: estoque
//Caixas devolvidas intactas
Static Function Dest_01()
	Private _lOk2       := .t.
	Private _cCodCaix  := Space(11)

	VTClear()
	VTClearBuffer()

	while _lOk2

		_cCodCaix := Space(14)

		VTRead

		@ 01,05 VTSay "CONTROLE DEVOLUCOES  "
		@ 02,05 VTSay "Destino: Estoque"
		@ 05,05 VTSay "Codigo caixa:"
		//@ 06,08 VTSay "[          ]"
		@ 06,08 VTSay "[               ]"			
		@ 06,09 VTGet _cCodCaix Pict "@!" VALID ValDest01()
		@ 16,00 VTSay "ESC para Sair"
		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		_cCodCaix := Space(10)

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

Return

//Demais destinos
//Caixas para repesagem/reprocesso/charque/graxaria
Static Function Dest_02()
	Private _lOk2    := .t.
	Private _cCodP  := space(6)
	Private _cPrdDest := space(6)
	Private _cDescP  := ''
	Private _cDescP2 := ''
	Private _cQuant := space(3)
	Private _cPesoB := space(6)
	Private _cPesoL := space(6)
	Private _cTara  := space(5)
	Private _cDiaP  := space(2)
	Private _cMesP  := space(2)
	Private _cAnoP  := space(2)
	Private _cConf  := 'X'

	VTClear()
	VTClearBuffer()

	while _lOk2

		_cCodCaix := Space(11)

		VTRead

		@ 01,05 VTSay "CONTROLE DEVOLUCOES  "
		//                          (E)stoque             (R)epesagem         re(P)rocesso      (C)harque (G)raxaria
		@ 02,05 VTSay "Destino: " + iif(_cPar04 = '2','Repesagem',iif(_cPar04 = '3','Reprocesso',iif(_cPar04 = '4','Charque','Graxaria')))
		@ 03,05 VTSay "Data Produção:[  /  /  ]"
		@ 04,05 VTSay "Produto:        [      ]"
		@ 05,05 VTSay "Descricao:[            ]"
		@ 06,05 VTSay "Quant.:             [   ]"
		@ 07,05 VTSay "Peso Bru.:       [      ]"
		@ 08,05 VTSay "Tara:            [     ]"
		@ 09,05 VTSay "Peso Liq.:       [      ]"
		if _cPar04 $ '2/3'//se for reprocesso ou repesagem exibe o campo
			@ 10,05 VTSay "Prod. Destino:  [      ]"
			@ 11,05 VTSay "Descricao:[            ]"
		endif
		@ 12,05 VTSay "Confirma?            [ ]"

		@ 03,20 VTGet _cDiaP 	Pict "@! 99" VALID (len(alltrim(_cDiaP)) = 2) .and. !empty(_cDiaP)
		@ 03,23 VTGet _cMesP 	Pict "@! 99" VALID (len(alltrim(_cMesP)) = 2) .and. !empty(_cMesP)
		@ 03,26 VTGet _cAnoP 	Pict "@! 99" VALID (len(alltrim(_cAnoP)) = 2) .and. !empty(_cAnoP)
		@ 04,22 VTGet _cCodP  	Pict "@!" VALID ValDest02(1,_cCodP)
		@ 06,26 VTGet _cQuant 	Pict "@E 999" VALID valQuant(_cCodP,val(_cQuant))//(val(_cQuant) > 0)// .and. val(_cQuant) < 20)
		@ 07,23 VTGet _cPesoB 	Pict "@E 999.99" VALID ValDest02_2('B')
		@ 08,23 VTGet _cTara  	Pict "@!" VALID ValDest02_2('T')
		if _cPar04 $ '2/3' //se for reprocesso ou repesagem captura valor do campo
			@ 10,22 VTGet _cPrdDest Pict "@!" VALID ValDest02(2,_cPrdDest)
		endif
		@ 12,27 VTGet _cConf  	Pict "@!" VALID _cConf = 'X'
		@ 16,00 VTSay "ESC para Sair"
		VTRead

		If (VTLastKey() == 27)
			VTAlert('Operação Cancelada!','Aviso de Encerramento(05)',.T.,100,1)
			_lOk2 := .f.
		else

			_cDest := iif(_cPar04 = '2','R',iif(_cPar04 = '3','P',iif(_cPar04 = '4','C','G')))

			//Grava a devolução
			_dDataP := ctod(alltrim(_cDiaP)+'/'+alltrim(_cMesP)+'/'+alltrim(_cAnoP))
			GravaSZN('',_cDest, _cCodP, val(_cQuant), val(_cPesoL), val(_cPesoB),_cDescP , _cPar02, _cPar03, _cCodCli, _cLojCli,_cNome,_dDataP,_cUser,_cPrdDest)
			//Imprime etiqueta...

			//Se for reprocesso...
			if _cDest $ 'R/P'

				if VTYesNo("Confirma impressão?","Impressão Etiqueta",.T.)
					if !empty(_cIpImp)
						imprime(_cIpImp,SZN->ZN_COD,SZN->ZN_DATAP,SZN->ZN_DTENTR,SZN->ZN_QUANT,SZN->ZN_PESOL,SZN->ZN_DESTINO,SZN->ZN_NUM,SZN->ZN_CODDEST)
					else
						VTAlert('IP da Impressora não cadastrado!','Aviso de Encerramento(05)',.T.,1000,1)
					endif
				endif
			endif

			_cCodP  	 := space(6)
			_cDescP 	 := ''
			_cDescP2	 := ''
			_cQuant 	 := space(3)
			_cPesoB 	 := space(6)
			_cPesoL 	 := space(6)
			_cTara  	 := space(5)
			_cDiaP  	 := space(2)
			_cMesP  	 := space(2)
			_cAnoP  	 := space(2)
			_cPrdDest 	 := space(6)
		EndIf

		VTClearBuffer()
	enddo

	VTClear()
	VTClearBuffer()

Return

//Função de validação destino 1 - estoque
//Função de validação de leitura da caixa para entrar em estoque
Static Function ValDest01()
	//Se o numero lido tiver 10 caracteres
	if(len(alltrim(_cCodCaix)) = 10)		
		SZN->(DbSetOrder(2))
		SZ8->(DbSetOrder(3))
		if !SZ8->(DbSeek(xfilial('SZ8') + alltrim(_cCodCaix))) .or. len(alltrim(_cCodCaix)) <> 10 //se não achar na SZ8
			limpaTela()
			@ 06,08 VTSay "[           ]"
			@ 08,04 VTSay "Caixa inexistente!             "

			/*elseif SZN->(DbSeek(xfilial('SZN')+alltrim(_cCodCaix))) //se achar na SZN
			limpaTela()
			@ 06,08 VTSay "[           ]"
			@ 08,04 VTSay "Caixa já apontada em devolução!"*/
			return .t.
		elseif empty(SZ8->Z8_DATAS)  .and. empty(SZ8->Z8_HORAS)  .and.;   //se a caixa já estiver em estoque
		empty(SZ8->Z8_PRECAR) .and. empty(SZ8->Z8_PREPED) .and.;
		empty(SZ8->Z8_ITEM)
			limpaTela()
			@ 06,08 VTSay "[           ]"
			@ 08,04 VTSay "Caixa em estoque!             "
			return .t.
		else
			limpaTela()
			@ 07,04 VTSay 'Codigo:    ' + SZ8->Z8_CONTROL
			@ 08,04 VTSay 'Produto:   ' + SZ8->Z8_COD
			@ 09,04 VTSay SZ8->Z8_DESCRI
			@ 10,04 VTSay 'Saida:     ' + dtoc(SZ8->Z8_DATAS)
			@ 11,04 VTSay 'Pre-pedido:' + SZ8->Z8_PREPED

			//Função de gravação de histórico
			u_gjf17his(1,'DEVOL.PED ' + SZ8->Z8_PREPED,.f.,'','','000028',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

			//Função de ajuste na tabela SZ8
			AjSZ8()
			//                          (E)stoque             (R)epesagem         re(P)rocesso      (C)harque (G)raxaria
			_cDest := iif(_cPar04 = '1','E',iif(_cPar04 = '2','R',iif(_cPar04 = '3','P',iif(_cPar04 = '4','C','G'))))

			GravaSZN(_cCodCaix,_cDest, SZ8->Z8_COD, SZ8->Z8_QUANT, SZ8->Z8_PESO, SZ8->Z8_PESOBR, SZ8->Z8_DESCRI, _cPar02, _cPar03, _cCodCli , _cLojCli,_cNome,stod(""),_cUser)
			//(_cControl,_cDest, _cCod      , _nQuant      , _nPesoL     , _nPesoB       , _cDesc        , _cDoc  , _cSerie, _cCliente, _cLoja  ,_dDataP ,_cUser)
		endif

		_cCodCaix := Space(11)
	elseif(len(alltrim(_cCodCaix)) = 14)
		SZN->(DbSetOrder(2))
		SZ8->(DbSetOrder(28))
		if !SZ8->(DbSeek(xfilial('SZ8') + alltrim(_cCodCaix))) .or. len(alltrim(_cCodCaix)) <> 14 //se não achar na SZ8
			limpaTela()			
			@ 06,08 VTSay "[               ]"			
			@ 08,04 VTSay "Caixa inexistente!             "			
			return .t.
		elseif empty(SZ8->Z8_DATAS)  .and. empty(SZ8->Z8_HORAS)  .and.;   //se a caixa já estiver em estoque
		empty(SZ8->Z8_PRECAR) .and. empty(SZ8->Z8_PREPED) .and.;
		empty(SZ8->Z8_ITEM)
			limpaTela()
			@ 06,08 VTSay "[               ]"
			@ 08,04 VTSay "Caixa em estoque!             "
			return .t.
		else
			limpaTela()
			@ 07,04 VTSay 'Codigo:    ' + SZ8->Z8_CONTROL
			@ 08,04 VTSay 'Produto:   ' + SZ8->Z8_COD
			@ 09,04 VTSay SZ8->Z8_DESCRI
			@ 10,04 VTSay 'Saida:     ' + dtoc(SZ8->Z8_DATAS)
			@ 11,04 VTSay 'Pre-pedido:' + SZ8->Z8_PREPED

			//Função de gravação de histórico
			u_gjf17his(1,'DEVOL.PED ' + SZ8->Z8_PREPED,.f.,'','','000028',SZ8->Z8_CONTROL,SZ8->Z8_LOCAL,SZ8->Z8_LOCALIZ,SZ8->Z8_PALLET)

			//Função de ajuste na tabela SZ8
			AjSZ8()
			//                          (E)stoque             (R)epesagem         re(P)rocesso      (C)harque (G)raxaria
			_cDest := iif(_cPar04 = '1','E',iif(_cPar04 = '2','R',iif(_cPar04 = '3','P',iif(_cPar04 = '4','C','G'))))

			GravaSZN(_cCodCaix,_cDest, SZ8->Z8_COD, SZ8->Z8_QUANT, SZ8->Z8_PESO, SZ8->Z8_PESOBR, SZ8->Z8_DESCRI, _cPar02, _cPar03, _cCodCli , _cLojCli,_cNome,stod(""),_cUser)
			//(_cControl,_cDest, _cCod      , _nQuant      , _nPesoL     , _nPesoB       , _cDesc        , _cDoc  , _cSerie, _cCliente, _cLoja  ,_dDataP ,_cUser)
		endif

		_cCodCaix := Space(15)

	endif
return .t.

//Função de validação destino 2 - repesagem
//Função de validação do codigo do produto
Static Function ValDest02(_opc,_codprd)
	Local _lRet := .t.

	if _opc == 2
		if empty(_codprd)
			return .t.
		endif
	endif

	DbSelectAre('SB1')
	SB1->(DbSetOrder(1))
	if !SB1->(DbSeek(xfilial('SB1')+_codprd))
		VTAlert('Produto inexistente!','Operação Irregular!',.T.,1000,1)
		if _opc == 2
			@ 11,16 VTSay space(12)
		else
			@ 05,16 VTSay space(12)
		endif
		_lRet := .f.
	else
		if _opc <> 2 .and. SB1->B1_TIPO <> 'PA'
			VTAlert('Produto Invalido!','Operação Irregular!',.T.,1000,1)
			//@ 05,16 VTSay space(12)
			if _opc == 2
				@ 11,16 VTSay space(12)
			else
				@ 05,16 VTSay space(12)
			endif
			_lRet := .f.
		elseif _opc <> 1 .and. SB1->B1_TIPO $ 'MC/EM/AI/PI/MP/PR'
			VTAlert('Produto Invalido!','Operação Irregular!',.T.,1000,1)
			if _opc == 2
				@ 11,16 VTSay space(12)
			else
				@ 05,16 VTSay space(12)
			endif
			_lRet := .f.
		endif

		if _opc == 2
			_cDescP2 := substr(SB1->B1_DESCRED,1,12)
			@ 11,16 VTSay _cDescP2
		else
			_cDescP  := substr(SB1->B1_DESCRED,1,12)
			@ 05,16 VTSay _cDescP
		endif
	endif

return _lRet

//Função de validação destino 2 - repesagem
//Função de validação do peso bruto e tara
Static Function ValDest02_2(_v)
	Local _lRet := .t.
	if _v = 'B'
		if val(_cPesoB) < 0 .or. val(_cPesoB) > 999
			VTAlert('Peso bruto inválido!','Operação Irregular!',.T.,500,1)
			_lRet := .f.
		endif
	else
		if val(_cTara) < 0 .or. val(_cTara) > 4
			VTAlert('Tara inválida!','Operação Irregular!',.T.,500,1)
			_lRet := .f.
		endif
	endif

	if _lRet
		_nPesoL := val(_cPesoB) - val(_cTara)
		_cPesoL := strtran(alltrim(transform(_nPesoL,"@E 999.99")),',','.')
		@ 09,23 VTSay _cPesoL
	endif

return _lRet

//Função de validação da saída ou estorno da câmara
Static Function ValSai(_n)
	Local _lRet:= .t.

	SZN->(DbSetOrder(8))

	//se for 0(zero) é saida da camara
	//se for 1 é estorno da camara
	if _n = 0
		_lRet:= iif(!empty(SZN->ZN_DTENTR),.f.,.t.)
	else
		_lRet:= iif(!empty(SZN->ZN_DTSAIDA),.f.,.t.)
	endif

	if !_lRet
		if len(_cCodCaix) < 10
			@ 06,08 VTSay "[           ]"
			@ 08,04 VTSay "Codigo inválido!"
		else
			if !SZN->(DbSeek(xfilial('SZN')+alltrim(_cCodCaix)))
				@ 06,08 VTSay "[           ]"
				@ 08,04 VTSay "Caixa inexistente!"
			else
				_cDescDest := iif(SZN->ZN_DESTINO = 'R', 'Repesagem',;
				iif(SZN->ZN_DESTINO = 'P', 'Reprocesso',;
				iif(SZN->ZN_DESTINO = 'C', 'Charque','Graxaria')))
				@ 07,04 VTSay 'Codigo:    ' + SZN->ZN_NUM
				@ 08,04 VTSay 'Produto:   ' + SZN->ZN_COD
				@ 09,04 VTSay SZN->ZN_DESC
				@ 10,04 VTSay 'Entrada:   ' + dtoc(SZN->ZN_DTENTR)
				@ 11,04 VTSay 'Destino:' + _cDescDest

				reclock('SZN',.f.)
				SZN->ZN_DTSAIDA := iif(_n = 0,ddatabase,stod(''))
				msunlock()

				u_gjf17his(2,'EST.DEV. ' + SZN->ZN_NUM,.f.,'','','000027', "9999999999")
			endif
		endif
	endif

	_cCodCaix := Space(11)

return .f.

//Função destinada a gravação da tabela SZN
Static Function GravaSZN(_cControl,_cDest, _cCod, _nQuant, _nPesoL, _nPesoB, _cDesc, _cDoc, _cSerie, _cCliente, _cLoja,_cNomeCli,_dDataP,_cUser,_prodDest)

	_cNum :=  GetSx8num('SZN','ZN_NUM')
	ConfirmSx8()

	reclock('SZN',.t.)
	SZN->ZN_FILIAL    := xfilial('SZN')
	SZN->ZN_NUM       := _cNum
	SZN->ZN_CONTROL   := _cControl
	SZN->ZN_DESTINO   := _cDest
	SZN->ZN_COD       := _cCod
	SZN->ZN_QUANT     := _nQuant
	SZN->ZN_PESOL     := _nPesoL
	SZN->ZN_PESOB     := _nPesoB
	SZN->ZN_DTENTR    := ddatabase
	if _cDest $ 'C/G'
		SZN->ZN_DTSAIDA  := ddatabase
	endif
	SZN->ZN_DESC      := _cDesc
	SZN->ZN_DOC       := _cDoc
	SZN->ZN_SERIE     := _cSerie
	SZN->ZN_CLIENTE   := _cCliente
	SZN->ZN_LOJA      := _cLoja
	SZN->ZN_NOMECLI	:= _cNomeCli
	SZN->ZN_DATAP     := _dDataP
	SZN->ZN_CODUSER   := _cUser
	SZN->ZN_CODDEST   := _prodDest
	msunlock()

	//se o destino for charque
	if _cDest == 'C'

		_cID :=  GetSx8num('ZZZ','ZZZ_CONTRO')
		ConfirmSx8()

		_nPesoLiq := _nPesoL
		_nPesoBrt := _nPesoB
		_cCodPrd  := '005023'
		_cOrig    := 'D'
		_cRegOri  := _cControl
		_cPrdOri  := _cCod
		_dDtEntr  := ddatabase
		_cHrEntr  := time()

		reclock('ZZZ',.t.)
		ZZZ->ZZZ_FILIAL := xFilial('ZZZ')
		ZZZ->ZZZ_CONTRO := _cID
		ZZZ->ZZZ_CODPRO := _cCodPrd
		ZZZ->ZZZ_PESLIQ := _nPesoLiq
		ZZZ->ZZZ_PESBRT := _nPesoBrt
		ZZZ->ZZZ_ORIGEM := _cOrig
		ZZZ->ZZZ_REGORI := _cRegOri
		ZZZ->ZZZ_PRDORI := _cPrdOri
		ZZZ->ZZZ_DATAE  := _dDtEntr
		ZZZ->ZZZ_HORAE  := _cHrEntr
		msunlock()

	endif

return

//Função destinada ao ajuste na tabela SZ8
Static Function AjSZ8()
	reclock('SZ8',.f.)
	SZ8->Z8_PRECAR  := ''
	SZ8->Z8_PREPED  := ''
	SZ8->Z8_ITEM    := ''
	SZ8->Z8_DATAS   := STOD('')
	SZ8->Z8_HORAS   := ''
	SZ8->Z8_ORIGEM  := 'D'
	SZ8->Z8_CARPICK := ''
	SZ8->Z8_PICKING := ''
	msunlock()
return

//Função para tratar o browse
User function MR10Br(modo)
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(00)',.T.,2000,1)
		_lOk2 := .f.
		return 0
	elseif VTLastkey()==13
		return 1
	endif
return

User function MR10Br2(modo)
	if VTLastkey()==27
		VTAlert('Operação Cancelada!','Aviso de Encerramento(00)',.T.,2000,1)
		//_lOk4 := .f.
		return 0
	elseif VTLastkey()==13
		return 1
	endif
return

//Função de impressão da etiqueta de devolução quando repesagem ou reprocesso
Static Function imprime(_IP,_cod,_dataP,_dataE,_quant,_pesol,_dest,_num,_coddest)

	MSCBPRINTER('S600','IP',,,,,_IP)
	//modelo, 'IP' ,,,,,endereço ip do server de impressao(IP DA ZEBRA)
	MSCBCHKSTATUS(.f.)
	MSCBBEGIN(1,6,40)

	fonte1  := "50,50"
	fonte2  := "35,20"

	MSCBSAY(72,30,"DEVOLUCAO","R","C",fonte1)
	MSCBBOX(68,01,68,180,7)                            //Linha Divisoria

	_cDescProd := fBuscaCpo('SB1',1,xFilial('SB1') + SZN->ZN_COD,'B1_DESCRED')
	MSCBSAY(62,05,"Produto:   " + _cod,"R","F",fonte2)
	MSCBSAY(62,74,_cDescProd,"R","F",fonte2)//57

	_cProdDest := fBuscaCpo('SB1',1,xFilial('SB1') + SZN->ZN_CODDEST,'B1_DESCRED')
	MSCBSAY(58,05,"Prod.Dest.:" + _coddest,"R","F",fonte2)
	MSCBSAY(58,74,_cProdDest,"R","F",fonte2)

	MSCBBOX(54,01,54,180,7)                            //Linha Divisoria

	MSCBSAY(50,05,"Data de Producao:","R","F",fonte2)
	MSCBSAY(50,90,dtoc(_dataP),"R","F",fonte2)

	MSCBSAY(46,05,"Data Entrada Devol.:","R","F",fonte2)
	MSCBSAY(46,90,dtoc(_dataE),"R","F",fonte2)

	MSCBBOX(42,01,42,180,7)                            //Linha Divisoria

	//MSCBLineH(40,75,58,7) //linha divisoria

	MSCBSAY(36,05,"Quantidade: ","R","F",fonte2)
	MSCBSAY(36,68,transform(_quant,'@E 9999'),"R","F",fonte2)

	MSCBSAY(30,05,"Peso Liq.: ","R","F",fonte2)
	MSCBSAY(30,68,transform(_pesol,'@E 999.99'),"R","F",fonte2)

	MSCBBOX(26,01,26,180,7)                            //Linha Divisoria

	MSCBSAY(22,05,"Destino: ","R","F",fonte2)
	//descrição do destino
	_cDescDest := iif(_dest = 'R', 'Repesagem',;
	iif(_dest = 'P', 'Reprocesso',;
	iif(_dest = 'C', 'Charque','Graxaria')))
	MSCBSAY(22,48,_cDescDest,"R","F",fonte2)
	//MSCBLineV(1,20,130)

	MSCBSAYBAR(06,62,_num,"R","C",11,.F.,.T.,,,4,1,.T.)

	MSCBEND()
	MSCBCLOSEPRINTER()
return

Static Function limpaTela()

	@ 07,04 VTSay space(25)
	@ 08,04 VTSay space(25)
	@ 09,04 VTSay space(25)
	@ 10,04 VTSay space(25)
	@ 11,04 VTSay space(25)

return

Static Function valQuant(_cod,_quant)

	if _quant <= 0
		return .f.
	endif

	DbSelectAre('SB1')
	SB1->(DbSetOrder(1))
	if SB1->(DbSeek(xfilial('SB1')+alltrim(_cod)))
		if SB1->B1_SEGUM = 'PC'
			if _quant > 1
				VTAlert('Qtd invalida, limite maximo para peca é 1 !','Operação Irregular!',.T.,500,1)
				return .f.
			endif
		endif
	endif

return .t.

//BLOCO PARA CONSULTA DE NF
/*em desenvolvimento*/
static function consNF()

	Local _lOk3 := .t.
	Local _nfOpc := '0'

	VTClear()
	VTClearBuffer()

	while _lOk3
		@ 01,05 VTSay "CONTROLE DEVOLUCOES   "
		@ 04,00 VTSay "Escolha uma das opções"
		@ 05,00 VTSay "de consulta de NF"
		@ 06,00 VTSay "Opcoes:          [ ]	"
		@ 07,00 VTSay "1 - CNPJ do Cliente 	"
		@ 08,00 VTSay "2 - Nossa NF      	"
		@ 16,00 VTSay "ESC para Sair        "

		@ 06,18 VTGet _nfOpc Pict "@! " valid !empty(_nfOpc) .and. _nfOpc $ '1/2'
		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		if _nfOpc = '1'
			findCNPJ(_nfOpc)
		elseif _nfOpc = '2'
			findNF(_nfOpc)
		endif

		VTClearBuffer()

	enddo

	VTClear()
	VTClearBuffer()

return

/*SELECT TOP 10 F2_DOC, A1_COD, A1_LOJA, A1_CGC, F2_CLIENTE, F2_EMISSAO FROM SA1010 SA1, SF2010 SF2
WHERE A1_CGC = '83646984002072'  AND F2_CLIENTE = A1_COD AND A1_LOJA = F2_LOJA AND F2_EMISSAO < '20180726'
ORDER BY F2_EMISSAO DESC*/

static function findCNPJ(_opc)

	Local _lOk4   := .t.
	Local _cnpj   := space(14)
	Local _cDiaE  := space(2)
	Local _cMesE  := space(2)
	Local _cAnoE  := space(2)

	VTClear()
	VTClearBuffer()

	while _lOk4

		@ 01,05 VTSay "CONTROLE DEVOLUCOES   "
		@ 04,00 VTSay "CNPJ:[              ] "
		@ 05,00 VTSay "[                   ] "
		@ 06,00 VTSay "Dt. Emissao:[  /  /  ]"

		@ 16,00 VTSay "ESC para Sair        "

		@ 04,06 VTGet _cnpj Pict "@! " valid ProcCli(_cnpj) .and. !empty(_cnpj)
		@ 06,13 VTGet _cDiaE 	Pict "@! 99" VALID (len(alltrim(_cDiaE)) = 2) .and. !empty(_cDiaE)
		@ 06,16 VTGet _cMesE 	Pict "@! 99" VALID (len(alltrim(_cMesE)) = 2) .and. !empty(_cMesE)
		@ 06,19 VTGet _cAnoE 	Pict "@! 99" VALID (len(alltrim(_cAnoE)) = 2) .and. !empty(_cAnoE)

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF
		_dDtEmiss := ctod(alltrim(_cDiaE)+'/'+alltrim(_cMesE)+'/'+alltrim(_cAnoE))
		querys(_opc,_cnpj,_dDtEmiss)
		VTClear()
		VTClearBuffer()

		aFields := {"NOTA","SERIE","EMISSAO"}
		aHeader := {'NF','SERIE','EMISSAO'}
		aSize   := {11,6,11}
		dbSelectarea('TRB')
		TRB->(dbGoTop())
		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"TRB",aHeader,aFields,aSize,"u_MR10br2",)

		buscaItem(TRB->NOTA)

		VTClear()
		VTClearBuffer()

	enddo

	VTClear()
	VTClearBuffer()

return

static function findNF(_opc)

	Local _lOk4 := .t.
	Local _nota := space(09)

	VTClear()
	VTClearBuffer()

	while _lOk4

		@ 01,05 VTSay "CONTROLE DEVOLUCOES  "
		@ 04,00 VTSay "Nota:[         ]     "
		@ 05,00 VTSay "[                   ]"

		@ 16,00 VTSay "ESC para Sair        "

		@ 04,06 VTGet _nota Pict "@! " valid ProcNF(_nota) .and. !empty(_nota)

		VTRead

		If (VTLastKey() == 27)
			VTAlert('Aplicação Finalizada!','Aviso de Encerramento(01)',.T.,500,1)
			exit
		EndIF

		querys(_opc,_nota)
		VTClear()
		VTClearBuffer()

		aFields := {"NOTA","SERIE","EMISSAO"}
		aHeader := {'NF','SERIE','EMISSAO'}
		aSize   := {11,6,11}
		dbSelectarea('TRB')
		TRB->(dbGoTop())
		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"TRB",aHeader,aFields,aSize,"u_MR10br2",)

		buscaItem(TRB->NOTA)

		VTClear()
		VTClearBuffer()

	enddo

	VTClear()
	VTClearBuffer()

return

static function querys(_opc,_key,_dtEmiss)

	if _opc = '1'//busca por cnpj

		_cQuery := " SELECT TOP 10 F2_DOC,F2_SERIE, F2_EMISSAO"
		_cQuery += " FROM " + retSqlTab('SF2') + ", " + retSqlTab('SA1')
		_cQuery += " WHERE " + retSqlFil('SF2') + " AND " + retSqlFil('SA1')
		_cQuery += " AND A1_CGC = '"+_key+"' AND A1_COD = F2_CLIENTE
		_cQuery += " AND A1_LOJA = F2_LOJA AND F2_EMISSAO < '" + dtos(_dtEmiss) + "'"
		_cQuery += " AND " + retSqlDel('SF2') + " AND " + retSqlDel('SA1')
		_cQuery += " ORDER BY F2_EMISSAO DESC"

	elseif _opc = '2'//busca por NF

		_cQuery := " SELECT F2_DOC,F2_SERIE, F2_EMISSAO"
		_cQuery += " FROM  " + retSqlTab('SF2')
		_cQuery += " WHERE " + retSqlFil('SF2')
		_cQuery += " AND F2_DOC = '" + _key + "'"
		_cQuery += " AND " + retSqlDel('SF2')

	endif

	_cQuery := ChangeQuery(_cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "QRY"

	geraTRAB()

return

static function buscaItem(_Nf)

	_cQuery2 := " SELECT D2_COD,D2_DESCRI"
	_cQuery2 += " FROM  " + retSqlTab('SD2')
	_cQuery2 += " WHERE " + retSqlFil('SD2')
	_cQuery2 += " AND D2_DOC = '" + _Nf + "'"
	_cQuery2 += " AND " + retSqlDel('SD2')

	_cQuery2 := ChangeQuery(_cQuery2)

	If Select("TMP") != 0
		TMP->(dbCloseArea())
	Endif

	TCQUERY _cQuery2 NEW ALIAS "TMP"

	TMP->(dbGoTop())
	VTClear()
	VTClearBuffer()

	aFields := {"D2_COD","D2_DESCRI"}
	aHeader := {'CODIGO','PRODUTO'}
	aSize   := {11,20}
	nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxcol(),"TMP",aHeader,aFields,aSize,"u_MR10br2",)

	VTClear()
	VTClearBuffer()

return

//função para gerar o ambiente de trabalho
Static Function geraTRAB()

	//cArq  := CriaTrab( Nil, .F. )
	_aArqTrb := {}
	
	aStru := {}
	AADD(aStru,{"NOTA"    ,"C"	,9  ,0	})
	AADD(aStru,{"SERIE"   ,"C"	,2	,0	})
	AADD(aStru,{"EMISSAO" ,"D"	,8	,0	})

	//dbcreate(cArq,aStru)
	//If Select('TRB')<>0
	//	TRB->(dbCloseArea())
	//Endif
	//dbUseArea( .T.,,cArq,"TRB", .F. , .F. )

	If Select('TRB')<>0                                                           //Se um tmp com alias TMP existir, fecha-o
		TRB->(dbCloseArea())
		u_arqtrb ("FechaTodos",,,, @_aArqTrb)
	Endif

	U_ArqTrb("Cria", "TRB", aStru, {}, @_aArqTrb)

	QRY->(dbGoTop())
	while QRY->(!eof())
		DbSelectArea('TRB')
		reclock('TRB',.t.)
		TRB->NOTA	 := QRY->F2_DOC
		TRB->SERIE   := QRY->F2_SERIE
		TRB->EMISSAO := stod(QRY->F2_EMISSAO)
		msunlock()

		QRY->(dbSkip())
	enddo

	aCampos := {}

	AADD(aCampos,{"NOTA"  	,, "Nota"			,"@!"   			})
	AADD(aCampos,{"SEIRE" 	,, "Seire"	    	,"@!"   			})
	AADD(aCampos,{"EMISSAO"	,, "Emissao"		,"99/99/99"			})

return


//Para localizar nota fiscal
Static Function ProcNF(_cnf)
	Local _lRet := .t.

	SF2->(DbSetOrder(1))
	if SF2->(DbSeek(xfilial('SF2')+_cnf)) .and. len(_cnf) = 9
		_cNome   := substr(SF2->F2_NOMCLI,1,19)
		@ 05,00 VTSay "[" + _cNome + "]"
	elseif alltrim(_cnf) = '9'
		_cNome   := 'INDEFINIDO!'
		@ 05,00 VTSay "[" + padr(_cNome,19," ") +"]"
	else
		@ 05,00 VTSay "[NÃO LOCALIZADO!!!!!]"
		_cNome   := ''
		_lRet := .f.
	endif
return _lRet
