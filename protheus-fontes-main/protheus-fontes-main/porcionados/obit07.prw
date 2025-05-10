
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

user function obit07()

	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3       	:= "Consumo x produção lotes porcionados"
	Local titulo       	:= "Consumo x produção lotes porcionados"
	Local nLin         	:= 80

	Local Cabec1       	:= "   Produto produzido                              Dt Prod.  Produto consumido "
	Local Cabec2       	:= ""
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "M"
	Private nomeprog    := "obit07" // Coloque aqui o nome do programa para impressao no cabecalho
	Private cPerg       := 'OBIT07'
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "obit07" // Coloque aqui o nome do arquivo usado para impressao em disco

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte(cPerg,.F.)

	wnrel := SetPrint('ZAS',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'ZAS')

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return




static function consulta()
	Local _cQuery := ""
	if MV_PAR05 == 1
		_cQuery += " select "
		_cQuery += " rtrim(ZAU_COD)+'-'+rtrim(ZAU_IMPROD) AS 'IPROD' "
		_cQuery += " ,rtrim(ZAS.ZAS_COD)+'-'+rtrim(ZAS.ZAS_DESC)  AS 'ICONSUMO' "
		_cQuery += " ,ZAU_QRPESO AS 'KGPROD' "
		_cQuery += " ,ZAS.ZAS_PESOL AS 'KGCONSUMO' "
		_cQuery += " ,ZAU_DTPROD  AS 'DTPROD' "
		_cQuery += " ,ISNULL(QRETORNO.ZAS_PESOL,0) AS 'QRET' "
		_cQuery += " ,ZAS.ZAS_CONTRO, ZAU_NUM "
	else
		_cQuery += " select "
		_cQuery += " rtrim(ZAU_COD)+'-'+rtrim(ZAU_IMPROD) AS 'IPROD' "
		_cQuery += " ,rtrim(ZAS.ZAS_COD)+'-'+rtrim(ZAS.ZAS_DESC)  AS 'ICONSUMO' "
		_cQuery += " ,(select SUM(ZAU_QRPESO) from " + RETSQLNAME ("ZAU") +" AS ZAU2 WHERE ZAU2.D_E_L_E_T_ = '' "
		_cQuery += " AND ZAU2.ZAU_COD = ZAU.ZAU_COD AND ZAU2.ZAU_DTPROD = ZAU.ZAU_DTPROD) AS 'KGPROD' "
		_cQuery += " ,sum(ZAS.ZAS_PESOL) AS 'KGCONSUMO' "
		_cQuery += " ,ZAU_DTPROD AS 'DTPROD' "
		_cQuery += " ,SUM(ISNULL(QRETORNO.ZAS_PESOL,0)) AS 'QRET' "
	endif
	_cQuery += " from " + RETSQLNAME ("ZAU") +" ZAU "
	_cQuery += " LEFT join " + RETSQLNAME ("ZLI") +" ZLI ON ZAU_NUM = ZLI_NUM AND ZLI.D_E_L_E_T_ ='' "
	_cQuery += " LEFT join " + RETSQLNAME ("ZAS") +" ZAS ON ZLI_CONTRO = ZAS_CONTRO AND ZAS.D_E_L_E_T_ = '' "
	_cQuery += " OUTER apply(SELECT ZAS_PESOL FROM " + RETSQLNAME ("ZAS") +" ZAS2 "
	_cQuery += " WHERE ZAS2.ZAS_FILIAL = ZAS.ZAS_FILIAL AND ZAS2.ZAS_RPORIG = ZAS.ZAS_CONTRO AND ZAS2.D_E_L_E_T_ = '' AND ZAS2.ZAS_RPORIG <> '') AS QRETORNO "
	_cQuery += " where ZAU_DTPROD BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND ZAU.D_E_L_E_T_ = '' "
	_cQuery += " AND ZAU_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	_cQuery += " AND ZAU_NUM BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"' "
	_cQuery += " AND ZAS.ZAS_CONTRO BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' "
	if MV_PAR05 == 2
		_cQuery += " group by ZAU_COD, ZAU_IMPROD, ZAS.ZAS_COD,ZAS.ZAS_DESC,ZAU_DTPROD "
		_cQuery += " HAVING sum(ZAS.ZAS_PESOL) > 0 "
	endif
	if MV_PAR05 == 1
		_cQuery += " order by ZAU_COD, ZAU_NUM "
	else
		_cQuery += " order by ZAU_COD "
	endif
	_cQuery  := ChangeQuery(_cQuery)

	If Select("TRB") != 0
		TRB->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TRB"

return()

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local _cCod := ""
	Local _nProd := 0
	Local _nCons := 0
	Local _cCodZAU := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	consulta()

	TRB->(dbGoTop())

	while TRB->(!eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nLin > 70 // Salto de Página. Neste caso o formulario tem 70 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		if empty(_cCod)
			@nlin,02 psay "Início da Produção: " + dtoc(MV_PAR03)
			nlin++
			@nlin,02 psay "Fim da Produção:    " + dtoc(MV_PAR04)
			nlin++
		endif
		if !_cCod == TRB->IPROD
			@nlin,00 psay replicate('-',132)
			nlin++
			@nlin,02 psay LEFT(TRB->IPROD,19)
			if MV_PAR05 == 1
				@nlin,23 psay TRB->ZAU_NUM
				@nlin,34 psay transform(TRB->KGPROD,'@E 999,999,999.99')
			endif
			@nlin,50 psay DTOC(STOD(TRB->DTPROD))
			_nProd   := TRB->KGPROD
			if MV_PAR05 == 1
				_cCodZAU := TRB->ZAU_NUM
			endif
		endif
		if MV_PAR05 == 1 .AND. !_cCodZAU == TRB->ZAU_NUM
			@nlin,18 psay TRB->ZAU_NUM
			@nlin,34 psay transform(TRB->KGPROD,'@E 999,999,999.99')
			_nProd += TRB->KGPROD
		endif
		if MV_PAR05 == 1
			@nlin,60 psay LEFT(TRB->ICONSUMO,21)
			@nlin,83 psay TRB->ZAS_CONTRO
		else
			@nlin,60 psay LEFT(TRB->ICONSUMO,40)
		endif
		@nlin,102 psay transform(TRB->KGCONSUMO-TRB->QRET,'@E 999,999,999.99')

		//@nlin,118 psay TRB->LOTEPA

		_nCons += TRB->KGCONSUMO-TRB->QRET

		nlin++
		_cCod := TRB->IPROD
		if MV_PAR05 == 1
			_cCodZAU := TRB->ZAU_NUM
		endif
		TRB->(DbSkip())
		if !_cCod == TRB->IPROD
			@nlin,17 psay "Total produzido: " + transform(_nProd,'@E 999,999,999.99')
			@nlin,85 psay "Total consumido: " + transform(_nCons,'@E 999,999,999.99')
			@nlin,118 psay "#" + transform(_nCons-_nProd,'@E 99,999,999.99')
			_nCons := 0
			nlin++
			nlin++
		endif

	enddo

	TRB->(dbCloseArea())

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
