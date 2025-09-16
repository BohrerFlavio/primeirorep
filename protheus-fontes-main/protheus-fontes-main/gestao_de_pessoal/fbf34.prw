#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"  
#INCLUDE "protheus.ch"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁGJF96   ╨ Autor Ё FlАvio Bohrer Flores  ╨ Data Ё  29/12/10  ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Descricao Ё ProrrogaГЦo Contrato ExperiЙncia                           ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё GPE												          ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

User Function FBF34()


	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de Variaveis                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Local cDesc1         := "Este programa tem como objetivo, Imprimir o Termo"
	Local cDesc2         := "de Prorrogacao do Contrato de Experiencia        "
	Local cDesc3         := ""
	Local cPict          := "parametros informados pelo sistema"
	Local titulo         := ""
	Local nLin           := 80

	Local Cabec1         := ""                   
	Local Cabec2         := ""

	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 132
	Private tamanho      := "P"
	Private nomeprog     := "FBF34" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "FBF34"
	Private m_pag      := 01
	Private wnrel      := "FBF34" // Coloque aqui o nome do arquivo usado para impressao em disco    
	Private _cMesADM 	:= ""
	Private _cMesVCTO   := ""
	pergunte(cPerg,.F.)

	wnrel := SetPrint('SRA',NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)


	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,'SRA')

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

	Local nOrdem
	Local li    := 0

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё SETREGUA -> Indica quantos registros serao processados para a regua Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды



	_zMAT:="######"
	DbSelectArea("SRA")                // * Cadastro de Funcionarios
	DbSetOrder(1)
	DbSeek(xFilial()+mv_par01,.T.)


	While SRA->(!EOF()) .And. SRA->RA_MAT >= mv_par01 .And. SRA->RA_MAT <= mv_par02 



		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica o cancelamento pelo usuario...                             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif


		If nLin > 62  
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 20
		Endif 
		_cMesADM := mesextenso(month(SRA->RA_ADMISSA))  
		_cMesVCTO := mesextenso(month(SRA->RA_VCTOEXP))
		@ nLin, 000 PSAY  chr(20)+"  "+"             T E R M O    D E    P R O R R O G A C A O "
		nLin := nLin + 2
		@ nLin, 000 PSAY  chr(20)+"  "+"                       DO CONTRATO DE EXPERIENCIA"
		nLin := nLin + 4
		@ nLin, 004 PSAY "Por este  instrumento particular,      "+Left(SM0->M0_NOMECOM,30)+"       e" 
		nLin := nLin + 2
		@ nLin, 000 PSAY +Left(SRA->RA_NOME,30)+", partes integrantes  do  CONTRATO  DE  EXPERIENCIA"
		nLin := nLin + 2
		@ nLin, 000 PSAY "firmado em "+str(day(SRA->RA_ADMISSA),2,0)+" de "+substr(_cMesADM,1,6)+"  de "+str(year(SRA->RA_ADMISSA),4,0)+", que  deveria  expirar em "+str(day(SRA->RA_VCTOEXP),2,0)+" de "+substr(_cMesVCTO,1,6)+" de "+str(year(SRA->RA_VCTOEXP),4,0)
		@ nLin, 080 PSAY ","
		nLin := nLin + 2
		ddatafim:=SRA->RA_VCTEXP2+MV_PAR03
		@ nLin, 000 PSAY "convencionam  prorroga-lo pelo prazo de "+Alltrim(STR(mv_par03))+" ("+left(STRTRAN(EXTENSO(mv_par03),"REAIS"," "),16)+") dias, expirando na data"
		nLin := nLin + 2
		@ nLin, 000 PSAY " de "+str(day(SRA->RA_VCTEXP2),2,0)+" de "+mesextenso(month(SRA->RA_VCTEXP2))+" de "+str(year(SRA->RA_VCTEXP2),4,0)+", deixando certo,  para  fins  do artigo 451 da  CLT,"
		nLin := nLin + 2
		@ nLin, 000 PSAY " ser esta a primeira e  unica prorrogacao do mencionado contrato."
		nLin := nLin + 4
		@ nLin, 004 PSAY LEFT(SM0->M0_CIDCOB,30)+", "+str(day(SRA->RA_VCTOEXP),2,0)+" de  "+mesextenso(month(SRA->RA_VCTOEXP))+" de  "+str(year(SRA->RA_VCTOEXP),4,0)+"."
		nLin := nLin + 4
		@ nLin, 000 PSAY replicate("_",30)+SPACE(06)+replicate("_",30)
		nLin := nLin + 1
		@ nLin, 000 PSAY +Left(SM0->M0_NOMECOM,30)+SPACE(08)+Left(SRA->RA_NOME,30)      
		nLin := nLin + 4
		@ nLin, 000 PSAY replicate("_",30)+SPACE(06)+replicate("_",30)
		nLin := nLin + 1
		@ nLin, 000 PSAY "         TESTEMUNHA        "+SPACE(08)+"        TESTEMUNHA"
		nLin := nLin + 3                       
		nLin := 90

		SRA->(DbSkip())

	EndDo




	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Finaliza a execucao do relatorio...                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	DbCloseArea('SRA')

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
