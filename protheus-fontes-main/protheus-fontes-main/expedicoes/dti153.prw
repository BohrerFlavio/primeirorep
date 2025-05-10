#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁDTI153    ╨ Autor Ё Lucas Bolzan       ╨ Data Ё  07/09/22   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё RelatСrio de entrega de pallets	                          ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё LOGISTICA                                                  ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

User Function DTI153()

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de Variaveis                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3       	:= "Recibo de entrega de pallets"
	Local titulo       	:= "Recibo de Entrega de Pallets"
	Local nLin           := 80	
	Local Cabec1       	:= "              Data        Carregamento           Motorista          Placa       N╨ de Pallets"
	Local Cabec2         := ""
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "DTI153" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "DTI153"
	Private cbcont       := 00
	Private CONTFL       := 01
	//Private cbtxt        := Space(10)
	Private m_pag        := 01
	Private wnrel        := "DTI153" // Coloque aqui o nome do arquivo usado para impressao em disco     
	Private _cData       := Ctod("") 
	
	Private nNumReg := 0	//Armazena nЗmero de registros no relatСrio
	Private nCountReg := 0
	
	Private cString := "ZZ3"

	dbSelectArea("ZZ3")
	dbSetOrder(1)

	pergunte(cPerg,.F.)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta a interface padrao com o usuario...                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	wnrel := SetPrint(cString,NomeProg,cPerg,titulo,cDesc1,cDesc2,cDesc2,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SETREGUA -> Indica quantos registros serao processados para a regua Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды


	cQuery := " SELECT COUNT(ZBF_PREPED) AS QUANT,ZZ3_NUM,ZZ3_DTCAR,ZZ3_MOTORI,ZZ3_PLACA"
	cQuery += " FROM  " + retSqlTab('ZBF') + ', ' +  retSqlTab('ZZ4') + ', ' + retSqlTab('ZZ3')
	cQuery += " WHERE " + retSqlFil('ZBF') + " AND " + retSqlFil('ZZ4') + ' AND ' + retSqlFil('ZZ3')
	cQuery += " AND ZZ4_NUM = ZBF_PREPED AND ZZ4_PRECAR = ZZ3_NUM AND ZBF_PRECAR = ZZ3_NUM"
	cQuery += " AND ZZ3_DTCAR = '" + dtos(mv_par01) + "'"
	cQuery += " AND " + retSqlDel('ZBF') + " AND " + retSqlDel('ZZ4') + " AND " + retSqlDel('ZZ3')
	cQuery += " GROUP BY ZZ4_NUM, ZZ4_CODCLI, ZZ4_LOJA, ZZ4_NOME, ZZ4_MUN, ZBF_NUM, ZBF_PESO, ZZ3_NUM, ZZ3_OBS, ZZ3_DTCAR, ZZ3_MOTORI, ZZ3_PLACA"
	cQuery += " ORDER BY ZZ3_NUM, ZZ4_CODCLI, ZZ4_LOJA"

	cQuery := ChangeQuery(cQuery)

	If Select("QRY") != 0
		QRY->(dbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "QRY"  

	
	//Mostrar a consulta
	//@ 116,090 To 416,707 Dialog oDlgMemo Title "Consulta"
	//@ 055,005 Get cQuery Size 250,080 MEMO Object oMemo
	//Activate Dialog oDlgMemo
	

	QRY->(dbgotop())

	SetRegua(QRY->(RecCount()))
	_cData := mv_par01//QRY->DAT
	aVetor := {'0'}
	nCountReg := 1

	While QRY->(!EOF())
		
		IncRegua()

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If nLin > 75 // Salto de PАgina. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif		

		//CondiГЦo para imprimir a linha
		if(ZZ3_NUM != aVetor[1] .OR. Len(aVetor)=1)
			If(Len(aVetor) != 1)
				@nLin,080 psay nCountReg
				nlin++
				nCountReg := 1
			Endif
			@nlin,012 psay _cData
			@nlin,023 psay " | "
			@nlin,028 psay (ZZ3_NUM)
			@nlin,040 psay " | "
			@nlin,045 psay alltrim(ZZ3_MOTORI)
			@nlin,060 psay " | "
			@nlin,068 psay alltrim(ZZ3_PLACA)
			@nlin,075 psay " | "								
		else
			nCountReg++
		endif			

		aVetor := {QRY->ZZ3_NUM,QRY->ZZ3_MOTORI,QRY->ZZ3_PLACA}
						
		QRY->(dbSkip()) // Avanca o ponteiro do registro no arquivo
			
	EndDo
	@nLin,080 psay nCountReg

	DbCloseArea('QRY')

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Finaliza a execucao do relatorio...                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	SET DEVICE TO SCREEN	

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se impressao em disco, chama o gerenciador de impressao...          Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return
