
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

user function obit06()

	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3       	:= "Entradas e saídas do pulmão"
	Local titulo       	:= "Entradas e saídas do pulmão"
	Local nLin         	:= 80

	Local Cabec1       	:= "  Código Descrição                                 Etiqueta    Dt Prod. Peso Liq. Dt Saída  Destino"
	Local Cabec2       	:= ""
	Local aOrd 			:= {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "M"
	Private nomeprog    := "obit06" // Coloque aqui o nome do programa para impressao no cabecalho
	Private cPerg       := 'OBIT06'
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "obit06" // Coloque aqui o nome do arquivo usado para impressao em disco

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

	_cQuery += " SELECT ZAS_CONTRO, ZAS_COD, ZAS_DESC, ZAS_DTPROD, ZAS_PESOL, ZAS_PESOB, "
	_cQuery += " ISNULL(ZLI_DATAIN, '') as ZLI_DATAIN, ZLI_HORAIN, ZAU_NUM, ZAU_COD, ZAU_DESC, "
    _cQuery += " ISNULL((SELECT SUM(ZAS_PESOL) FROM " + RETSQLNAME ("ZAS") +" ZAS2 WHERE ZAS2.ZAS_RPORIG = ZAS.ZAS_CONTRO AND ZAS2.D_E_L_E_T_ = '' AND ZAS2.ZAS_RPORIG <> ''),0) AS QRETORNO "
	_cQuery += " FROM " + RETSQLNAME ("ZAS") +" ZAS "
	_cQuery += " LEFT JOIN " + RETSQLNAME ("ZLI") +" ZLI ON ZAS_CONTRO = ZLI_CONTRO AND ZLI.D_E_L_E_T_ = '' "
	_cQuery += " LEFT JOIN " + RETSQLNAME ("ZAU") +" ZAU ON ZLI_NUM = ZAU_NUM AND ZAU.D_E_L_E_T_ = '' "
	_cQuery += " WHERE ZAS.D_E_L_E_T_ = '' AND ZAS_LOCAL = '22' "
	_cQuery += " AND ZAS_DTPROD BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' "
	//_cQuery += " AND ZLI_DATAIN BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"' "
	_cQuery += " AND ZAS_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	_cQuery += " ORDER BY ZAS.ZAS_COD, ZAS.ZAS_DTPROD "

	_cQuery  := ChangeQuery(_cQuery)

	If Select("TRB") != 0
		TRB->(dbCloseArea())
	Endif

	TCQUERY _cQuery NEW ALIAS "TRB"

return()

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local _cCod := ""
	Local _nSaldo := 0

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
		if !_cCod == TRB->ZAS_COD
			@nlin,02 psay alltrim(TRB->ZAS_COD)
			@nlin,09 psay alltrim(TRB->ZAS_DESC)
		endif
		@nlin,51 psay alltrim(TRB->ZAS_CONTRO)
		@nlin,63 psay DTOC(STOD(TRB->ZAS_DTPROD))
		@nlin,75 psay transform(TRB->ZAS_PESOL-TRB->QRETORNO,'@E 999.99')
		@nlin,82 psay DTOC(STOD(TRB->ZLI_DATAIN))
		@nlin,92 psay left(ALLTRIM(TRB->ZAU_COD) + " " + ALLTRIM(TRB->ZAU_DESC),40)
		if empty(TRB->ZLI_DATAIN)
			_nSaldo += TRB->ZAS_PESOL-TRB->QRETORNO
		endif
		nlin++
		_cCod := TRB->ZAS_COD
		TRB->(DbSkip())
	enddo

	if !empty(_cCod)
		@nlin,50 psay "Saldo no pulmão: "+ transform(_nSaldo,'@E 999,999,999.99')
	endif
	
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
