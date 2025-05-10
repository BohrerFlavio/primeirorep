#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF135º Autor ³     Giuliano Forgiariniº Data ³  15/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Conferencia de Transferencias º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento/PCP                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF135()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio   "
	Local cDesc2         := "para conferencia de transferencia de PA entre as     "
	Local cDesc3         := "unidades da empresa conferindo caixa a caixa do      "
	Local cPict          := "produto acabado." 

	Local titulo         := "CONFERENCIA DE TRANSFERENCIA DE PRODUTO ACABADO"
	Local nLin           := 80

	Local Cabec1         := "Codigo          Filial      Filial      Documento       Data   "
	Local Cabec2         := "Transferencia   Origem      Destino       Fiscal               "
	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.                                              
	Private CbTxt        := ""
	Private limite       := 80
	Private tamanho      := "M"
	Private nomeprog     := "GJF135" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "GJF135"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "GJF135" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "ZAC"

	dbSelectArea("ZAC")
	dbSetOrder(1)

	pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

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

	dbSelectArea(cString)
	ZAC->(dbSetOrder(1))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	ZAC->(SetRegua(RecCount()))


	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		//	Exit
	Endif


	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	ZAC->(dbGoTop())
	if ZAC->(dbseek(xfilial('ZAC') + mv_par01))

		_cFilOri    := iif(ZAC->ZAC_FILORI = 'SM','00','01')
		_cFilDes    := iif(ZAC->ZAC_FILDES = 'SM','00','01') // Alterado por Fabian Maurer em 28/03/12 -> original estava assim: _cFilDes := iif(ZAC->ZAC_FILORI = 'SM','01','00')

		@nlin,02 psay ZAC->ZAC_NUM
		@nlin,18 psay _cFilOri
		@nlin,30 psay _cFilDes
		@nlin,40 psay ZAC->ZAC_NOTA
		@nlin,55 psay ZAC->ZAC_DATA

		nlin++
		@nlin,00 psay replicate('-',132)
		nlin++

		ZAD->(DbSetOrder(1))

		if ZAD->(DbSeek(xfilial('ZAD')+ ZAC->ZAC_NUM))

			While ZAD->(!eof()) .and. ZAD->ZAD_FILIAL = xfilial('ZAD') .and. ZAD->ZAD_NUM = ZAC->ZAC_NUM

				If nLin > 75
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif    

				if  _cFilOri <> _cFilDes               //Alterado por Fabian Maurer em 28/03/12 -> original estava assim: _cFilOri <> cFilAnt
					_codProd := ZAD->ZAD_COD           //Alterado por Fabian Maurer em 28/03/12 -> original estava assim: altrim(ZAD->ZAD_COD)
					_cDescri := fBuscaCPO('SB1',1,_cFilDes + _codProd,'B1_DESC')
				else
					_codProd := alltrim(ZAD->ZAD_CODORI)
					_cDescri := fBuscaCPO('SB1',1,_cFilOri + _codProd,'B1_DESC')
				endif

				@nlin,05 psay 'Item ' + ZAD->ZAD_ITEM + ': ' + alltrim(_codProd) + ' - ' + _cDescri 
				@nlin,65 psay 'Quant. Embarcada: ' + transform(ZAD->ZAD_QUANT,'@E 999,999') +;
				'  Quant. Transferida: ' + transform(ZAD->ZAD_QTREAL,'@E 999,999')
				nlin++

				ZAE->(DbSetOrder(3))

				_cChave  := xfilial('ZAE') + _cFilOri + ZAD->(ZAD_PRECAR + ZAD_PREPED + ZAD_ITEM)

				if  ZAE->(DbSeek(_cChave + 'S' ))

					_Col := 0

					while ZAE->(!eof()) .and. ZAE->(ZAE_FILIAL + ZAE_FIL + ZAE_PRECAR + ZAE_PREPED + ZAE_ITEM + ZAE_MOVIM) = _cChave + 'S'

						_cContro := ZAE->ZAE_CONTRO

						If nLin > 75
							Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
							nLin := 9 
						Endif

						if mv_par02 = 1					
							@nlin,05+_Col psay _cContro  

							if ZAE->(DbSeek(_cChave + 'E' + _cContro)) 		
								@nlin,20+_Col psay "Transf. Completa"
							endif 
							ZAE->(DbSeek(_cChave + 'S' + _cContro))
							if _Col = 0 
								_Col := 40
							elseif _Col = 40
								_Col := 80					
							elseif _Col = 80
								_Col := 0
								nlin++
							endif 	  

						elseif mv_par02 = 2   

							if ZAE->(DbSeek(_cChave + 'E' + _cContro)) 

								@nlin,05+_Col psay _cContro
								@nlin,20+_Col psay "Transf. completa"

								if _Col = 0 
									_Col := 40
								elseif _Col = 40
									_Col := 80					
								elseif _Col = 80
									_Col := 0
									nlin++
								endif

							endif

							ZAE->(DbSeek(_cChave + 'S' + _cContro))
						endif 

						ZAE->(DbSkip())
					enddo 

					nlin++

				endif
				ZAD->(DbSkip())
			enddo
		endif
	else
		return
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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
