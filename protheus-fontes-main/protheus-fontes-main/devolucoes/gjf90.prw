#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GJF90     º Autor ³Giuliano Forgiarini º Data ³  15/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Espelho de Registro de Devoluções                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCP/SIGAOMS/SIGACTB                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GJF90()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := "de espelho do registro da devolução selecionada no "
	Local cDesc3        := "grid apresentando todas as informações disponíveis"
	Local cPict         := ""
	Local titulo        := "ESPELHO DE REGISTRO DE DEVOLUÇÃO"
	Local nLin          := 80
	Local Cabec1        := ""
	Local Cabec2        := ""
	Local imprime       := .T.
	Local aOrd          := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "GJF90" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "GJF90" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SZB"

	dbSelectArea("SZB")
	dbSetOrder(1)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	wnrel := SetPrint('SZB',NomeProg,,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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
	Local _cNomeCli := fBuscaCPO('SA1',1,xfilial('SA1')+SZB->(ZB_CLIENTE + ZB_LOJA),'A1_NOME')  
	Local aDestino  := CTBCBOX('ZB_DESTINO')
	Local _cDestino := ''

	_cDestino := ASCAN(aDestino,{|x| left(x,1)==SZB->ZB_DESTINO})

	If nLin > 75 // Salto de Página.
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif 

	@nlin,000 psay '+' + replicate('=',130) + '+'
	nlin++
	@nlin,002 psay 'DADOS GERAIS DA DEVOLUÇÃO'
	nlin++
	@nlin,002 psay 'Devolução Nr.: ' + SZB->ZB_NUM  +;
	'      Data Devolução: ' + dtoc(SZB->ZB_DTREAL) +;   
	'      Data Lançamento: ' + dtoc(SZB->ZB_DATA)  +;
	'     (' + DefStt(SZB->ZB_STATUS) + ')'       
	nlni++
	@nlin,002 psay 'Destino: ' + _cDestino
	nlin++
	@nlin,002 psay 'Cliente:  ' + SZB->ZB_CLIENTE + '/' + SZB->ZB_LOJA + '    ' + _cNomeCli  
	nlin++
	@nlin,002 psay 'Nota Fiscal: ' +SZB->ZB_NF + '    ' + 'Serie: ' + SZB->ZB_SERIE  +;
	iif(ZB_NFPROPR='N','(Nota Fiscal não é propria do cliente)','')    

	if !empty(ZB_NFENTRA)  
		nlin++
		@nlin,002 psay 'NCC gerada: ' + SZB->ZB_NFENTRA
	endif 

	nlin++
	@nlin,000 psay '+' + replicate('=',130) + '+'    
	nlin++

	@nlin,002 psay 'DADOS DO SETOR DE QUALIDADE'
	nlin++         
	@nlin,002 psay 'Motivo Devolução : ' + SZB->ZB_MOTIVO
	nlin++         
	@nlin,002 psay 'Considerações :    ' + SZB->ZB_DESCQUA

	nlin++
	@nlin,002 psay 'Vistado? (S/N): ' + iif(SZB->ZB_VQUA = 'V','Sim','Aguardando...')
	@nlin,040 psay 'Responsavel:    ' + alltrim(SZB->ZB_NOMEQUA)

	nlin++
	@nlin,000 psay '+' + replicate('=',130) + '+'    
	nlin++
	@nlin,002 psay 'DADOS DO SETOR DE PCP'
	nlin++         
	@nlin,002 psay 'Considerações :    ' + SZB->ZB_DESCPCP
	nlin++
	@nlin,002 psay 'Vistado? (S/N): ' + iif(SZB->ZB_VPCP = 'V','Sim','Aguardando...')
	@nlin,040 psay 'Responsavel:    ' + alltrim(SZB->ZB_NOMEPCP)
	nlin++ 

	@nlin,000 psay '+' + replicate('=',130) + '+'    
	nlin++
	@nlin,002 psay 'DADOS DO SETOR DE COMERCIAL'
	nlin++         
	@nlin,002 psay 'Considerações :    ' + SZB->ZB_DESCCOM

	nlin++
	@nlin,002 psay 'Vistado? (S/N): ' + iif(SZB->ZB_VCOM = 'V','Sim','Aguardando...')
	@nlin,040 psay 'Responsavel:    ' + alltrim(SZB->ZB_NOMECOM)

	@nlin,000 psay '+' + replicate('=',130) + '+'    
	nlin++
	@nlin,002 psay 'DADOS DA DIRETORIA'
	nlin++
	@nlin,002 psay 'Vistado? (S/N): ' + iif(SZB->ZB_VDIR = 'V','Sim','Aguardando...')
	@nlin,040 psay 'Responsavel:    ' + alltrim(SZB->ZB_NOMEDIR)

	nlin++
	@nlin,000 psay '+' + replicate('=',130) + '+'    
	nlin += 2

	SZC->(DbSetOrder(1))
	SZC->(DbGoTop())
	SZC->(DbSeek(xfilial('SZC')+M->ZB_NUM))

	while SZC->(!eof()) .and. SZC->ZC_FILIAL = xfilial('SZC') .and. SZC->ZC_NUM = SZB->ZB_NUM   
		If nLin > 75 // Salto de Página.
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif 

		@nlin,002 psay SZC->ZC_COD
		@nlin,020 psay SZC->ZC_DESCRI
		@nlin,050 psay transform(SZC->ZC_QUANT,'@E 999.999')
		@nlin,060 psay transform(SZC->ZC_PESO,'@E 999,999.999')
		@nlin,075 psay transform(SZC->ZC_VUNIT,'@E 999.999')
		@nlin,090 psay transform(SZC->ZC_TOTAL,'@E 999,999.999')

		nlin++

		SZC->(DbSkip())
	enddo

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


static function DefStt(_par)

	local stt
	do case
		case _par = 'A'
		stt :=  'Em Aberto'      
		case _par = 'E'
		stt :=  'Pre-Nota Gerada'      
		case _par = 'N'
		stt :=  'Em Analise'      
		case _par = 'G'
		stt :=  'No Aguardo Diretoria'      
		case _par = 'D'
		stt :=  'Vistado Diretoria'      
	endcase 

return stt
